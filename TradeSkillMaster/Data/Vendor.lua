-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local Vendor = TSM:NewModule("Vendor", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table

function Vendor:OnEnable()
	Vendor:RegisterEvent("MERCHANT_SHOW", "ScanMerchant")
end

local vendorItems = {
	["item:2320:0:0:0:0:0:0"] = 10,
	["item:2321:0:0:0:0:0:0"] = 10,
	["item:2324:0:0:0:0:0:0"] = 25,
	["item:2325:0:0:0:0:0:0"] = 1000,
	["item:2604:0:0:0:0:0:0"] = 50,
	["item:2605:0:0:0:0:0:0"] = 10,
	["item:2678:0:0:0:0:0:0"] = 10,
	["item:2880:0:0:0:0:0:0"] = 100,
	["item:3371:0:0:0:0:0:0"] = 100,
	["item:3466:0:0:0:0:0:0"] = 2000,
	["item:4289:0:0:0:0:0:0"] = 50,
	["item:4291:0:0:0:0:0:0"] = 500,
	["item:4340:0:0:0:0:0:0"] = 350,
	["item:4341:0:0:0:0:0:0"] = 500,
	["item:4342:0:0:0:0:0:0"] = 2500,
	["item:4399:0:0:0:0:0:0"] = 200,
	["item:4400:0:0:0:0:0:0"] = 2000,
	["item:4470:0:0:0:0:0:0"] = 38,
	["item:6260:0:0:0:0:0:0"] = 50,
	["item:6261:0:0:0:0:0:0"] = 100,
	["item:8343:0:0:0:0:0:0"] = 2000,
	["item:10290:0:0:0:0:0:0"] = 2500,
	["item:10647:0:0:0:0:0:0"] = 2000,
	["item:10648:0:0:0:0:0:0"] = 100,
	["item:11291:0:0:0:0:0:0"] = 4500,
	["item:14341:0:0:0:0:0:0"] = 5000,
	["item:17020:0:0:0:0:0:0"] = 1000,
	["item:17194:0:0:0:0:0:0"] = 10,
	["item:17196:0:0:0:0:0:0"] = 50,
	["item:30817:0:0:0:0:0:0"] = 25,
	["item:34412:0:0:0:0:0:0"] = 1000,
	["item:35949:0:0:0:0:0:0"] = 8500,
	["item:38426:0:0:0:0:0:0"] = 30000,
	["item:38682:0:0:0:0:0:0"] = 1000,
	["item:39354:0:0:0:0:0:0"] = 15,
	["item:39501:0:0:0:0:0:0"] = 1200,
	["item:39502:0:0:0:0:0:0"] = 5000,
	["item:39684:0:0:0:0:0:0"] = 9000,
	["item:40533:0:0:0:0:0:0"] = 50000,
	["item:44835:0:0:0:0:0:0"] = 10,
	["item:44853:0:0:0:0:0:0"] = 25,
	["item:52188:0:0:0:0:0:0"] = 15000,
	["item:58274:0:0:0:0:0:0"] = 11000,
	["item:58278:0:0:0:0:0:0"] = 16000,
	["item:62323:0:0:0:0:0:0"] = 60000,
	["item:62786:0:0:0:0:0:0"] = 1000,
	["item:62787:0:0:0:0:0:0"] = 1000,
	["item:62788:0:0:0:0:0:0"] = 1000,
	["item:67319:0:0:0:0:0:0"] = 328990,
	["item:67335:0:0:0:0:0:0"] = 445561,
	["item:67348:0:0:0:0:0:0"] = 394755,
	["item:68047:0:0:0:0:0:0"] = 170437,
	["item:74659:0:0:0:0:0:0"] = 30000,
	["item:74660:0:0:0:0:0:0"] = 15000,
	["item:74832:0:0:0:0:0:0"] = 12000,
	["item:74845:0:0:0:0:0:0"] = 35000,
	["item:74851:0:0:0:0:0:0"] = 14000,
	["item:74852:0:0:0:0:0:0"] = 16000,
	["item:74854:0:0:0:0:0:0"] = 7000,
	["item:79740:0:0:0:0:0:0"] = 23,
	["item:83092:0:0:0:0:0:0"] = 20000.0000,
	["item:85583:0:0:0:0:0:0"] = 12000,
	["item:85584:0:0:0:0:0:0"] = 17000,
	["item:85585:0:0:0:0:0:0"] = 27000,
}

-- returns the vendor cost for a given target item
function TSMAPI:GetVendorCost(itemString)
	return itemString and TSM.db.global.vendorItems[itemString] or vendorItems[itemString]
end

function Vendor:ScanMerchant(first)
	for i=1, GetMerchantNumItems() do
		local itemString = TSMAPI:GetItemString(GetMerchantItemLink(i))
		if itemString then
			local _, _, price, _, numAvailable, _, extendedCost = GetMerchantItemInfo(i)
			if price > 0 and not extendedCost and numAvailable == -1 then
				TSM.db.global.vendorItems[itemString] = price
			else
				TSM.db.global.vendorItems[itemString] = nil
			end
		end
	end
	if first then
		TSMAPI:CreateTimeDelay("scanMerchantDelay", 1, function() Vendor:ScanMerchant() end)
	end
end