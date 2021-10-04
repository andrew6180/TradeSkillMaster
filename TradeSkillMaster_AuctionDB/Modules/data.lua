-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_AuctionDB                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctiondb           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Data = TSM:NewModule("Data")

-- weight for the market value from X days ago (where X is the index of the table)
local WEIGHTS = {[0] = 132, [1] = 125, [2] = 100, [3] = 75, [4] = 45, [5] = 34, [6] = 33,
	[7] = 38, [8] = 28, [9] = 21, [10] = 15, [11] = 10, [12] = 7, [13] = 5, [14] = 4}
local MIN_PERCENTILE = 0.15 -- consider at least the lowest 15% of auctions
local MAX_PERCENTILE = 0.30 -- consider at most the lowest 30% of auctions
local MAX_JUMP = 1.2 -- between the min and max percentiles, any increase in price over 120% will trigger a discard of remaining auctions

function Data:ConvertScansToAvg(scans)
	if not scans then return end
	-- do a sanity check
	if type(scans) == "number" then
		scans = {scans}
	end
	if not scans.avg then
		local total, num = 0, 0
		for _, value in ipairs(scans) do
			total = total + value
			num = num + 1
		end
		scans.avg = floor(total/num+0.5)
		scans.count = num
	end
	return scans
end

function Data:GetDay(t)
	t = t or time()
	return floor(t / (60*60*24))
end

-- Updates all the market values
function Data:UpdateMarketValue(itemData)
	local day = Data:GetDay()

	local scans = CopyTable(itemData.scans)
	itemData.scans = {}
	for i=0, 14 do
		if i <= TSM.MAX_AVG_DAY then
			if type(scans[day-i]) == "number" then
				scans[day-i] = {avg=scans[day-i], count=1}
			end
			itemData.scans[day-i] = scans[day-i] and CopyTable(scans[day-i])
		else
			local dayScans = scans[day-i]
			if type(dayScans) == "table" then
				if dayScans.avg then
					itemData.scans[day-i] = dayScans.avg
				else
					-- old method
					itemData.scans[day-i] = Data:GetAverage(dayScans)
				end
			elseif dayScans then
				itemData.scans[day-i] = dayScans
			end
		end
	end
	itemData.marketValue = Data:GetMarketValue(itemData.scans)
end

-- gets the average of a list of numbers
-- DEPRECATED
function Data:GetAverage(data)
	local total, num = 0, 0
	for _, marketValue in ipairs(data) do
		total = total + marketValue
		num = num + 1
	end
	
	return num > 0 and floor((total / num) + 0.5)
end

-- gets the market value given a set of scans
function Data:GetMarketValue(scans)
	local day = Data:GetDay()
	local totalAmount, totalWeight = 0, 0

	for i=0, 14 do
		local dayScans = scans[day-i]
		if dayScans then
			local dayMarketValue
			if type(dayScans) == "table" then
				if dayScans.avg then
					dayMarketValue = dayScans.avg
				else
					-- old method
					dayMarketValue = Data:GetAverage(scans)
				end
			else
				dayMarketValue = dayScans
			end
			if dayMarketValue then
				totalAmount = totalAmount + (WEIGHTS[i] * dayMarketValue)
				totalWeight = totalWeight + WEIGHTS[i]
			end
		end
	end
	for i in ipairs(scans) do
		if i < day - 14 then
			scans[i] = nil
		end
	end
	
	return totalWeight > 0 and floor(totalAmount / totalWeight + 0.5) or 0
end

function Data:ProcessData(scanData, groupItems)
	if TSM.processingData then return TSMAPI:CreateTimeDelay(0.2, function() Data:ProcessData(scanData, groupItems) end) end
	

	-- wipe all the minBuyout data
	if groupItems then
		for itemString in pairs(groupItems) do
			local itemID = TSMAPI:GetItemID(itemString)
			if TSM.data[itemID] then
				TSM:DecodeItemData(itemID)
				TSM.data[itemID].minBuyout = nil
				TSM:EncodeItemData(itemID)
			end
		end
	else
		for itemID, data in pairs(TSM.data) do
			TSM:DecodeItemData(itemID)
			data.minBuyout = nil
			TSM:EncodeItemData(itemID)
		end
	end
	
	local scanDataList = {}
	for itemID, data in pairs(scanData) do
		tinsert(scanDataList, {itemID, data})
	end
	
	-- go through each item and figure out the market value / update the data table
	local index = 1
	local day = Data:GetDay()
	local function DoDataProcessing()
		for i = 1, 500 do
			if index > #scanDataList then
				TSMAPI:CancelFrame("adbProcessDelay")
				TSM.processingData = nil
				break
			end
			
			local itemID, data = unpack(scanDataList[index])		
			TSM:DecodeItemData(itemID)
			TSM.data[itemID] = TSM.data[itemID] or {scans={}, lastScan = 0}
			local marketValue = Data:CalculateMarketValue(data.records)
			
			local scanData = TSM.data[itemID].scans
			scanData[day] = scanData[day] or {avg=0, count=0}
			if type(scanData[day]) == "number" then
				-- this should never happen...
				scanData[day] = {scanData[day]}
			end
			scanData[day].avg = scanData[day].avg or 0
			scanData[day].count = scanData[day].count or 0
			if #scanData[day] > 0 then
				scanData[day] = Data:ConvertScansToAvg(scanData[day])
			end
			scanData[day].avg = floor((scanData[day].avg * scanData[day].count + marketValue) / (scanData[day].count + 1) + 0.5)
			scanData[day].count = scanData[day].count + 1
			
			TSM.data[itemID].lastScan = TSM.db.factionrealm.lastCompleteScan
			TSM.data[itemID].minBuyout = data.minBuyout > 0 and data.minBuyout or nil
			TSM.data[itemID].quantity = data.quantity
			Data:UpdateMarketValue(TSM.data[itemID])
			TSM:EncodeItemData(itemID)
			
			index = index + 1
		end
	end
	
	TSM.processingData = true
	TSMAPI:CreateTimeDelay("adbProcessDelay", 0, DoDataProcessing, 0.1)
end

function Data:CalculateMarketValue(records)
	local totalNum, totalBuyout = 0, 0
	local numRecords = #records
	
	for i=1, numRecords do
		totalNum = i - 1
		if i ~= 1 and i > numRecords*MIN_PERCENTILE and (i > numRecords*MAX_PERCENTILE or records[i] >= MAX_JUMP*records[i-1]) then
			break
		end
		
		totalBuyout = totalBuyout + records[i]
		if i == numRecords then
			totalNum = i
		end
	end
	
	local uncorrectedMean = totalBuyout / totalNum
	local varience = 0
	
	for i=1, totalNum do
		varience = varience + (records[i]-uncorrectedMean)^2
	end
	
	local stdDev = sqrt(varience/totalNum)
	local correctedTotalNum, correctedTotalBuyout = 1, uncorrectedMean
	
	for i=1, totalNum do
		if abs(uncorrectedMean - records[i]) < 1.5*stdDev then
			correctedTotalNum = correctedTotalNum + 1
			correctedTotalBuyout = correctedTotalBuyout + records[i]
		end
	end
	
	local correctedMean = floor(correctedTotalBuyout / correctedTotalNum + 0.5)
	
	return correctedMean
end