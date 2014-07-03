-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file contains code for scanning the auction house
local TSM = select(2, ...)
local private = {}
TSMAPI:RegisterForTracing(private, "TradeSkillMaster.AuctionQueryUtil_private")


local ITEM_CLASS_LOOKUP = {}
for i, class in ipairs({GetAuctionItemClasses()}) do
	ITEM_CLASS_LOOKUP[class] = {}
	ITEM_CLASS_LOOKUP[class].index = i
	for j, subclass in pairs({GetAuctionItemSubClasses(i)}) do
		ITEM_CLASS_LOOKUP[class][subclass] = j
	end
end

local function GetItemClasses(itemString)
	local class, subClass = select(6, TSMAPI:GetSafeItemInfo(itemString))
	if not class or not ITEM_CLASS_LOOKUP[class] then return end
	return ITEM_CLASS_LOOKUP[class].index, ITEM_CLASS_LOOKUP[class][subClass]
end

function TSMAPI:GetAuctionQueryInfo(itemString)
	local name, _, rarity, _, minLevel, class, subClass, _, equipLoc = TSMAPI:GetSafeItemInfo(itemString)
	local class, subClass = GetItemClasses(itemString)
	if not name then return end
	return {name=name, minLevel=minLevel, maxLevel=minLevel, invType=0, class=class, subClass=subClass, quality=rarity}
end

local function GetCommonQueryInfo(name, items)
	local queries = {}
	for _, itemString in ipairs(items) do
		local itemQuery = TSMAPI:GetAuctionQueryInfo(itemString)
		local existingQuery
		for _, query in ipairs(queries) do
			if query.class == itemQuery.class then
				existingQuery = query
				break
			end
		end
		if existingQuery then
			existingQuery.minLevel = min(existingQuery.minLevel, itemQuery.minLevel)
			existingQuery.maxLevel = max(existingQuery.maxLevel, itemQuery.maxLevel)
			existingQuery.quality = min(existingQuery.quality, itemQuery.quality)
			if existingQuery.subClass ~= itemQuery.subClass then
				existingQuery.subClass = nil
			end
			tinsert(existingQuery.items, itemString)
		else
			itemQuery.name = name
			itemQuery.items = {itemString}
			tinsert(queries, itemQuery)
		end
	end
	return queries
end

local function GetCommonQueryInfoClass(class, items)
	local resultQuery = TSMAPI:GetAuctionQueryInfo(items[1])
	resultQuery.name = ""
	resultQuery.class = class
	for i=2, #items do
		local itemQuery = TSMAPI:GetAuctionQueryInfo(items[i])
		resultQuery.minLevel = min(resultQuery.minLevel, itemQuery.minLevel)
		resultQuery.maxLevel = max(resultQuery.maxLevel, itemQuery.maxLevel)
		resultQuery.quality = min(resultQuery.quality, itemQuery.quality)
		if resultQuery.subClass ~= itemQuery.subClass then resultQuery.subClass = nil end
	end
	resultQuery.items = items
	return {resultQuery}
end

local function GreatestSubstring(str1, str2)
	local parts1 = {(" "):split(str1)}
	local parts2 = {(" "):split(str2)}
	for i=1, #parts1 do
		if parts1[i] ~= parts2[i] then
			local subStr = table.concat(parts1, " ", 1, i-1)
			return subStr ~= "" and subStr
		end
	end
	return table.concat(parts1, " ")
end

local function ReduceStrings(strList)
	local didReduction = true
	while didReduction do
		didReduction = false
		for i=1, #strList-1 do
			if i > #strList-1 then break end
			local subStr = GreatestSubstring(strList[i], strList[i+1])
			if subStr then
				strList[i] = subStr
				tremove(strList, i+1)
				didReduction = true
			end
		end
		if not private.thread then return end
		private.thread:Yield()
	end
	return true
end

local function NumPagesCallback(event, numPages)
	if event == "NUM_PAGES" then
		local skippedItems = {}
		local score = max(#private.combinedQueries[1].items-numPages, 0)
		if private.combinedQueries[1].name == "" then
			-- This is a common class term so determine if we should use this or not.
			local cost = 0
			for _, query in ipairs(private.queries) do
				if query.score and query.class == private.combinedQueries[1].class then
					cost = cost + query.score
				end
			end
			if score >= cost and score > 0 then
				-- use the common class term
				for i=#private.queries, 1, -1 do
					local query = private.queries[i]
					local shouldRemove = (query.class == private.combinedQueries[1].class)
					if shouldRemove then
						tremove(private.queries, i)
					end
				end
				tinsert(private.queries, private.combinedQueries[1])
			end
		else
			if numPages > #private.combinedQueries[1].items then
				for _, itemString in ipairs(private.combinedQueries[1].items) do
					local query = TSMAPI:GetAuctionQueryInfo(itemString)
					query.items = {itemString}
					query.score = 0
					tinsert(private.queries, query)
				end
			elseif numPages == 0 then
				for _, itemString in ipairs(private.combinedQueries[1].items) do
					tinsert(skippedItems, itemString)
				end
			else
				-- use the common search term
				private.combinedQueries[1].score = score
				tinsert(private.queries, private.combinedQueries[1])
			end
		end
		tremove(private.combinedQueries, 1)
		private.callback("QUERY_UPDATE", private.totalQueries-#private.combinedQueries, private.totalQueries, skippedItems)
	end
	private:CheckNextCombinedQuery()
end

function private:CheckNextCombinedQuery()
	if not private.isScanning then return end
	
	if #private.combinedQueries == 0 then
		-- we're done
		sort(private.queries, function(a, b) return a.name < b.name end)
		TSM:StopGeneratingQueries()
		TSMAPI:CreateTimeDelay("queryUtilCallbackDelay", 0.05, function() private.callback("QUERY_COMPLETE", private.queries) end)
		return
	end
	
	for _, itemString in ipairs(private.combinedQueries[1].items) do
		if strlower(private.combinedQueries[1].name) == strlower(TSMAPI:GetSafeItemInfo(itemString)) then
			-- One of the items in this combined query is the same as the common search term,
			-- so it's always worth using this common search term.
			NumPagesCallback("NUM_PAGES", 1)
			return
		end
	end
	
	TSMAPI.AuctionScan:GetNumPages(private.combinedQueries[1], NumPagesCallback)
end

local function GenerateSearchTerms(names, itemList, isReversed)
	sort(names)
	if not ReduceStrings(names) then return end -- run the reduction
	
	-- create a table associating all the reduced names to a list of items
	local temp = {}
	for i, filterName in ipairs(names) do
		for j, itemString in ipairs(itemList) do
			local itemName = TSMAPI:GetSafeItemInfo(itemString)
			itemName = itemName and isReversed and strrev(itemName) or itemName -- reverse item name if necessary
			if itemName and strfind(itemName, "^"..TSMAPI:StrEscape(filterName)) then
				temp[filterName] = temp[filterName] or {}
				tinsert(temp[filterName], itemString)
			end
		end
		if not private.thread then return end
		private.thread:Yield()
	end
	
	return temp
end

local function GenerateQueriesThread(self)
	private.thread = self
	local function GenerateFilters(reverse)
		-- create a list of all item names
		local names = {}
		for _, itemString in ipairs(private.itemList) do
			local name = TSMAPI:GetSafeItemInfo(itemString)
			if type(name) == "string" and name ~= "" then
				tinsert(names, reverse and strrev(name) or name)
			end
		end
		if not private.thread then return end

		local filters, tempFilters, tempItems  = {}, {}, {}
		local numFilters = 0
		local tbl = GenerateSearchTerms(names, private.itemList, reverse)
		if not tbl then return end
		for filterName, items in pairs(tbl) do
			if #items > 1 then
				filters[reverse and strrev(filterName) or filterName] = items
				numFilters = numFilters + 1
			else
				tinsert(tempFilters, strrev(filterName)) -- reverse name for second pass
				for _, itemString in ipairs(items) do
					tinsert(tempItems, itemString)
				end
			end
		end
		
		-- try to find common search terms of reversed item names
		local tbl = GenerateSearchTerms(tempFilters, tempItems, not reverse)
		if not tbl then return end
		for filterName, items in pairs(tbl) do
			filters[reverse and filterName or strrev(filterName)] = items
			numFilters = numFilters + 1
		end
		
		return filters, numFilters
	end
	
	local endTime = debugprofilestop() + 5000
	while debugprofilestop() < endTime do
		-- request all the item info
		local tryAgain = false
		for _, itemString in ipairs(private.itemList) do
			if not TSMAPI:GetSafeItemInfo(itemString) then
				tryAgain = true
			end
		end
		if not tryAgain then break end
		self:Sleep(0.1)
	end
	
	local filters1, num1 = GenerateFilters()
	local filters2, num2 = GenerateFilters(true)
	if not filters1 or not filters2 then return end
	local filters = num2 < num1 and filters2 or filters1
	
	-- generate class filters
	local itemClasses = {}
	local classes = {GetAuctionItemClasses()}
	for _, itemString in ipairs(private.itemList) do
		local classIndex = GetItemClasses(itemString)
		if classIndex then
			itemClasses[classIndex] = itemClasses[classIndex] or {}
			tinsert(itemClasses[classIndex], itemString)
		end
	end
	
	-- create the actual queries
	local queries, combinedQueries = {}, {}
	for filterName, items in pairs(filters) do
		for _, query in ipairs(GetCommonQueryInfo(filterName, items)) do
			if #query.items > 1 then
				tinsert(combinedQueries, query)
			else
				tinsert(queries, query)
			end
		end
	end
	for class, items in pairs(itemClasses) do
		for _, query in ipairs(GetCommonQueryInfoClass(class, items)) do
			if #query.items > 1 then
				tinsert(combinedQueries, query)
			end
		end
	end
	
	private.isScanning = true
	private.queries = queries
	private.combinedQueries = combinedQueries
	private.totalQueries = #combinedQueries
end

function TSMAPI:GenerateQueries(itemList, callback)
	if private.thread then return end
	private.itemList = itemList
	private.callback = callback
	
	local function ThreadDone()
		if private.thread then
			private.thread = nil
			private:CheckNextCombinedQuery()
		end
	end
	TSMAPI.Threading:Start(GenerateQueriesThread, 0.5, ThreadDone)
end

function TSM:StopGeneratingQueries()
	private.thread = nil
	private.isScanning = nil
end