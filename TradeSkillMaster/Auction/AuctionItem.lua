-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file contains code for the AuctionItem objects
local TSM = select(2, ...)

local NewRecord, sortHelpers
local AuctionRecord = {
	Initialize = function(self)
		self.objType = "AuctionRecord"
	end,
	
	SetData = function(self, parent, count, minBid, minIncrement, buyout, bid, highBidder, seller, timeLeft)
		self.parent = parent
		self.count = count
		self.minBid = minBid
		self.minIncrement = minIncrement
		self.buyout = buyout
		self.bid = bid
		self.highBidder = highBidder
		self.seller = seller
		self.timeLeft = timeLeft
	end,
	
	IsPlayer = function(self)
		return TSMAPI:IsPlayer(self.seller) or self.parent.alts[self.seller]
	end,
	
	GetPercent = function(self)
		local itemBuyout = self:GetItemBuyout()
		local marketValue = self.parent.marketValue
		if itemBuyout and marketValue then
			return (itemBuyout / marketValue) * 100
		end
	end,
	
	GetDisplayedBid = function(self)
		local displayedBid
		if self.bid == 0 then
			displayedBid = self.minBid
		else
			displayedBid = self.bid
		end
		return displayedBid
	end,
	
	GetRequiredBid = function(self)
		local requiredBid
		if self.bid == 0 then
			requiredBid = self.minBid
		else
			requiredBid = self.bid + self.minIncrement
		end
		return requiredBid
	end,
	
	GetItemBuyout = function(self)
		if not self.buyout or self.buyout == 0 then return end
		return floor(self.buyout / self.count)
	end,
	
	GetItemDisplayedBid = function(self)
		return floor(self:GetDisplayedBid() / self.count)
	end,
	
	GetItemDestroyingBuyout = function(self)
		local itemBuyout = self:GetItemBuyout()
		if itemBuyout then
			return itemBuyout * self.parent.destroyingNum
		end
	end,
	
	GetItemDestroyingDisplayedBid = function(self)
		local itemBid = self:GetItemDisplayedBid()
		if itemBid then
			return itemBid * self.parent.destroyingNum
		end
	end,
	
	Copy = function(self)
		local o = NewRecord()
		o:SetData(self.parent, self.count, self.minBid, self.minIncrement, self.buyout, self.bid, self.highBidder, self.seller, self.timeLeft)
		o.uniqueID = self.uniqueID
		return o
	end,
	
	Equals = function(self, other)
		if self == other then
			return true
		end
		
		local params = self.parent.recordParams
		for _, key in ipairs(params) do
			if type(self[key]) == "function" then
				if self[key](self) ~= other[key](other) then
					return false
				end
			else
				if self[key] ~= other[key] then
					return false
				end
			end
		end
	
		return true
	end,
}

NewRecord = function()
	local o = {}
	setmetatable(o, AuctionRecord)
	AuctionRecord.__index = AuctionRecord
	o:Initialize()
	return o
end


--- Test Documentation
-- @name AuctionItem
-- @description Test description for the Auction Item object.
local AuctionItem = {
	-- @field Test field
	Initialize = function(self)
		self.objType = "AuctionItem"
		self.itemLink = nil
		self.marketValue = nil
		self.playerAuctions = 0
		self.records = {}
		self.alts = {}
		self.recordParams = {"buyout", "count", "seller"}
		self.shouldCompact = true
		self.texture = ""
	end,
	
	-- sets the item (or battle pet's) texture
	SetTexture = function(self, texture)
		self.texture = texture
	end,
	
	-- gets the item (or battle pet's) texture
	GetTexture = function(self)
		return self.texture
	end,
	
	-- sets the alts table used for making other players count as the current player
	SetAlts = function(self, alts)
		self.alts = alts
	end,
	
	-- sets the list of params we care about
	SetRecordParams = function(self, params)
		self.recordParams = params
	end,
	
	-- sets the itemLink
	SetItemLink = function(self, itemLink)
		self.itemLink = itemLink
	end,
	
	-- returns the itemString
	GetItemString = function(self)
		return TSMAPI:GetItemString(self.itemLink)
	end,
	
	-- returns the itemID
	GetItemID = function(self)
		return TSMAPI:GetItemID(self.itemLink)
	end,
	
	-- adds a record
	AddAuctionRecord = function(self, ...)
		local record = NewRecord()
		record:SetData(self, ...)
		if strfind(self.itemLink, "battlepet") then
			record.uniqueID = table.concat({TSMAPI:Select({2, 3, 4, 5, 6, 7}, (":"):split(self.itemLink))}, ".")
		else
			record.uniqueID = select(9, (":"):split(self.itemLink))
		end
		self:AddRecord(record)
	end,
	
	-- adds a record
	AddRecord = function(self, record)
		self.shouldCompact = true
		if record:IsPlayer() then
			self.playerAuctions = self.playerAuctions + 1
		end
		tinsert(self.records, record)
	end,
	
	-- sorts the records using the passed sortFunc
	SortRecords = function(self, sortFunc)
		sort(self.records, sortFunc)
	end,
	
	-- sets the market value of this item
	SetMarketValue = function(self, value)
		self.marketValue = value
	end,
	
	-- sorts all the records in ascending order by buyout > bid > count > seller 
	DoDefaultSort = function(self)
		self:SortRecords(function(a, b)
				local aBuyout = a:GetItemBuyout()
				local bBuyout = b:GetItemBuyout()
				if not aBuyout or aBuyout == 0 then
					return false
				end
				if not bBuyout or bBuyout == 0 then
					return true
				end
				if aBuyout == bBuyout then
					if a.seller == b.seller then
						if a.count == b.count then
							local aBid = a:GetItemDisplayedBid()
							local bBid = b:GetItemDisplayedBid()
							return aBid < bBid
						end
						return a.count < b.count
					end
					return a.seller < b.seller
				end
				return aBuyout < bBuyout
			end)
	end,
	
	-- populates the compactRecords table
	PopulateCompactRecords = function(self, sortParams, isAscending)
		if self.shouldCompact then
			self.shouldCompact = false
			self.compactRecords = {}
			self:DoDefaultSort()
			local currentRecord
			for _, record in ipairs(self.records) do
				local temp = record:Copy()
				if not currentRecord or not temp:Equals(currentRecord) then
					currentRecord = temp
					currentRecord.numAuctions = 1
					currentRecord.totalQuantity = currentRecord.count
					tinsert(self.compactRecords, currentRecord)
				else
					currentRecord.numAuctions = currentRecord.numAuctions + 1
					currentRecord.totalQuantity = currentRecord.totalQuantity + temp.count
				end
			end
		end
		
		if sortParams then
			sort(self.compactRecords, function(a, b)
					for _, key in ipairs(sortParams) do
						local sortVal = sortHelpers[key](a, b)
						if sortVal < 0 then
							return isAscending
						elseif sortVal > 0 then
							return not isAscending
						end
					end
				end)
		end
	end,
	
	-- removes all records for which shouldFilter(record) returns true
	FilterRecords = function(self, shouldFilter)
		self.shouldCompact = true
		local toRemove = {}
		for index, record in ipairs(self.records) do
			if shouldFilter(record) then
				tinsert(toRemove, index)
			end
		end
		
		for i=#toRemove, 1, -1 do
			self:RemoveRecord(toRemove[i])
		end
	end,
	
	-- removes a record at the given index
	RemoveRecord = function(self, index)
		local toRemove = self.records[index]
		if not toRemove then return end
		self.shouldCompact = true
		
		if self.compactRecords then
			for i, record in ipairs(self.compactRecords) do
				if record:Equals(toRemove) then
					if record.numAuctions > 1 then
						record.numAuctions = record.numAuctions - 1
					else
						tremove(self.compactRecords, i)
					end
					break
				end
			end
		end
		
		if toRemove:IsPlayer() then
			self.playerAuctions = self.playerAuctions - 1
		end
		
		tremove(self.records, index)
	end,
	
	-- adds up all the counts from all the records
	GetTotalItemQuantity = function(self)
		local totalQuantity = 0
		for _, record in ipairs(self.records) do
			totalQuantity = totalQuantity + record.count
		end
		return totalQuantity
	end,
	
	-- counts up the number of items (not auctions) the player has
	GetPlayerItemQuantity = function(self)
		local totalQuantity = 0
		for _, record in ipairs(self.records) do
			if record:IsPlayer() then
				totalQuantity = totalQuantity + record.count
			end
		end
		return totalQuantity
	end,
	
	IsPlayerOnly = function(self)
		for _, record in ipairs(self.records) do
			if not record:IsPlayer() then
				return false
			end
		end
		return true
	end,
	
	SetDestroyingNum = function(self, num)
		self.destroyingNum = num
	end,
}

function TSMAPI.AuctionScan:NewAuctionItem()
	local o = {}
	setmetatable(o, AuctionItem)
	AuctionItem.__index = AuctionItem
	o:Initialize()
	return o
end



local function CompareStrings(a, b)
	if a < b then
		return -1
	elseif a > b then
		return 1
	else
		return 0
	end
end

-- bunch of helper functions for AuctionItem sorting
-- negative return means a < b
-- possitive return means a > b
-- zero return means a == b
sortHelpers = {
	Percent = function(a, b)
		return (a:GetPercent() or math.huge) - (b:GetPercent() or math.huge)
	end,
	
	Buyout = function(a, b)
		return (a.buyout or math.huge) - (b.buyout or math.huge)
	end,
	
	DisplayedBid = function(a, b)
		return a:GetDisplayedBid() - b:GetDisplayedBid()
	end,

	ItemBuyout = function(a, b)
		return (a:GetItemBuyout() or math.huge) - (b:GetItemBuyout() or math.huge)
	end,
	
	ItemDisplayedBid = function(a, b)
		return a:GetItemDisplayedBid() - b:GetItemDisplayedBid()
	end,
	
	Count = function(a, b)
		return a.count - b.count
	end,
	
	Seller = function(a, b)
		return CompareStrings(a.seller, b.seller)
	end,
	
	TimeLeft = function(a, b)
		return a.timeLeft - b.timeLeft
	end,
	
	NumAuctions = function(a, b)
		return a.numAuctions - b.numAuctions
	end,
	
	Name = function(a, b)
		local aName = TSMAPI:GetSafeItemInfo(a.parent.itemLink)
		local bName = TSMAPI:GetSafeItemInfo(a.parent.itemLink)
		return CompareStrings(aName, bName)
	end,
	
	DestroyingBuyout = function(a, b)
		return (a:GetItemDestroyingBuyout() or math.huge) - (b:GetItemDestroyingBuyout() or math.huge)
	end,
}

function TSMAPI.AuctionScan:SortAuctions(data, sortParams, useCompactRecords, isAscending)
	local function compareSort(a, b)
		for _, key in ipairs(sortParams) do
			local sortVal
			if useCompactRecords then
				sortVal = sortHelpers[key](a.compactRecords[1], b.compactRecords[1])
			else
				sortVal = sortHelpers[key](a.records[1], b.records[1])
			end
			
			if sortVal < 0 then
				return isAscending
			elseif sortVal > 0 then
				return not isAscending
			end
		end
	end
	
	sort(data, compareSort)
end