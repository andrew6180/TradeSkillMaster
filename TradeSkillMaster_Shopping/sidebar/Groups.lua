local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Shopping") -- loads the localization table

local private = {itemOperations={}}

function private.Create(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()

	local stContainer = CreateFrame("Frame", nil, frame)
	stContainer:SetPoint("TOPLEFT", 0, -35)
	stContainer:SetPoint("BOTTOMRIGHT", 0, 30)
	TSMAPI.Design:SetFrameColor(stContainer)
	frame.groupTree = TSMAPI:CreateGroupTree(stContainer, "Shopping", "Shopping_AH")
	private.groupTree = frame.groupTree
	
	local helpText = TSMAPI.GUI:CreateLabel(frame)
	helpText:SetPoint("TOPLEFT")
	helpText:SetPoint("TOPRIGHT")
	helpText:SetHeight(35)
	helpText:SetJustifyH("CENTER")
	helpText:SetJustifyV("CENTER")
	helpText:SetText(L["Select the groups which you would like to include in the search."])
	frame.helpText = helpText
	
	local startBtn = TSMAPI.GUI:CreateButton(frame, 16)
	startBtn:SetPoint("BOTTOMLEFT", 3, 3)
	startBtn:SetPoint("BOTTOMRIGHT", -3, 3)
	startBtn:SetHeight(20)
	startBtn:SetText(L["Start Search"])
	startBtn:SetScript("OnClick", private.StartScan)
	frame.startBtn = startBtn
	
	return frame
end

function private.ScanCallback(event, ...)
	if event == "filter" then
		local filter = ...
		local maxPrice
		for _, itemString in ipairs(filter.items) do
			local operation = private.itemOperations[itemString]
			local operationPrice = TSM:GetMaxPrice(operation.maxPrice, itemString)
			if not operationPrice then return end
			if operation.showAboveMaxPrice then
				maxPrice = nil
				break
			end
			maxPrice = maxPrice and max(maxPrice, operationPrice) or operationPrice
		end
		return maxPrice
	elseif event == "process" then
		local itemString, auctionItem = ...
		-- filter out auctions according to operation settings
		itemString = TSMAPI:GetBaseItemString(itemString, true)
		local operation = private.itemOperations[itemString]
		if not operation then return end
		local operationPrice = TSM:GetMaxPrice(operation.maxPrice, itemString)
		if not operationPrice then return end
		auctionItem:FilterRecords(function(record)
				if operation.evenStacks and record.count % 5 ~= 0 then
					return true
				end
				if not operation.showAboveMaxPrice then
					return (record:GetItemBuyout() or 0) > operationPrice
				end
			end)
		auctionItem:SetMarketValue(operationPrice)
		return auctionItem
	elseif event == "done" then
		TSM.Search:SetSearchBarDisabled(false)
		return
	end
end

function private.StartScan()
	TSMAPI:FireEvent("SHOPPING:GROUPS:STARTSCAN")
	wipe(private.itemOperations)
	for groupName, data in pairs(private.groupTree:GetSelectedGroupInfo()) do
		groupName = TSMAPI:FormatGroupPath(groupName, true)
		for _, opName in ipairs(data.operations) do
			TSMAPI:UpdateOperation("Shopping", opName)
			local opSettings = TSM.operations[opName]
			if not opSettings then
				-- operation doesn't exist anymore in Auctioning
				TSM:Printf(L["'%s' has a Shopping operation of '%s' which no longer exists. Shopping will ignore this group until this is fixed."], groupName, opName)
			else
				-- it's a valid operation
				for itemString in pairs(data.items) do
					local _, err = TSM:GetMaxPrice(opSettings.maxPrice, itemString)
					if err then
						TSM:Printf(L["Invalid custom price source for %s. %s"], TSMAPI:GetSafeItemInfo(itemString) or itemString, err)
					else
						private.itemOperations[itemString] = opSettings
					end
				end
			end
		end
	end
	
	local itemList = {}
	for itemString in pairs(private.itemOperations) do
		tinsert(itemList, itemString)
	end

	TSM.Search:SetSearchBarDisabled(true)
	TSM.Util:ShowSearchFrame(nil, L["% Max Price"])
	TSM.Util:StartItemScan(itemList, private.ScanCallback)
end

do
	TSM:AddSidebarFeature(L["TSM Groups"], private.Create)
end