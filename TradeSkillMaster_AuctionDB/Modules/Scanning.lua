-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_AuctionDB                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctiondb           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Scan = TSM:NewModule("Scan", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_AuctionDB") -- loads the localization table

Scan.groupScanData = {}
Scan.filterList = {}
Scan.numFilters = 0
Scan.fullScanStartTime = 0
Scan.fullScanSecondsPerPage = -1

local verifyNewAlgorithm = false  -- DEVELOPERS: Set to "true" to validate and benchmark the new market data algorithm!


local function FullScanCallback(event, ...)
	if event == "SCAN_PAGE_UPDATE" then
		-- We're running a "Full Scan" and have received an auction page.
		-- NOTE: These normal per-page scans receive 50 items per page, and will
		-- successfully download ALL auctions on private servers, thanks to pagination.
		-- For example, while Warmane's "GetAll" only returns 55000 of 126559 auctions,
		-- the regular "Full Scan" mode retrieves all 2532 pages of 50 items each,
		-- meaning that it covers 126600 auctions (and therefore grabs them all)
		-- in this example. Users should always prefer "Full Scan" when "GetAll" fails.
		local page, total = ...

		-- Calculate the current page progress and the remainder as floating-point values.
		local progress_float = page / total
		local remaining_float = 1.0 - progress_float

		-- Estimate the remaining scan time, based on a MIX of the average per-page so far,
		-- and the previous scan's averages stored in the database (if available).
		-- NOTE: This callback triggers after we RECEIVED "page", so we count "page" too.
		-- NOTE: We don't do any "live" updates of the progress bar text. We only
		-- update the estimate when we receive a page, which is very CPU-efficient.
		local time_estimate_str = ""
		if (page >= 1) and (total > page) then
			-- Calculate how many seconds have elapsed per page-request so far.
			-- NOTE: We time it via the less-precise "time()" function, which
			-- bluntly returns whole seconds. The alternative would be to use
			-- "debugprofilestop()", which has millisecond-precision, but breaks
			-- if another addon calls "debugprofilestart()" (which resets that
			-- timer back to zero). It doesn't really matter, since our "seconds
			-- per page" is constantly re-calculated based on the latest "total
			-- amount of whole seconds elapsed", so it doesn't accumulate any
			-- rounding errors and gets more precise the more pages have been
			-- downloaded (after ~10 pages, it's basically as accurate as the
			-- debug-timer). We have to use this technique for safety!
			-- NOTE: Most servers will gradually slow down the page requests
			-- across the first 300 requests or so, which will become slower
			-- and slower, which means that the initial time estimate will
			-- grow until it settles on the correct time remainder. There's
			-- nothing we can do to predict those gradual slowdowns / throttling,
			-- which is why we're also storing the last scan's "final average"
			-- in the database and using that for our subsequent scan estimates.
			local seconds_elapsed = abs(time() - Scan.fullScanStartTime)
			local pages_remaining = total - page
			local seconds_per_page = seconds_elapsed / page

			-- Remember our "real", unweighted value, for later DB storage.
			Scan.fullScanSecondsPerPage = seconds_per_page

			-- Calculate a smoothly weighted "seconds per page" value based on
			-- a linear mix between the current "seconds per page" and the
			-- stored "final seconds per page value" from our previous scan.
			-- As we reach 100%, we'll use 100% of the current "real seconds
			-- per page". But at 0%, we'll use the stored value instead.
			-- Between that, we linearly fade the values so that we react
			-- smoothly to changes in speed. This solves the issue that all
			-- servers face, which is their gradual slowdown of page fetches,
			-- where they start out very fast (such as 1.1 seconds per page),
			-- but will have slowed down when you're at the end (such as 2.5 per
			-- page). Typical server slowdown in speed is roughly linear, which
			-- is why our linear blend between "current estimate" and "finished
			-- estimate from previous scan" creates the most accurate results
			-- we're able to get, given the server behavior. It should also
			-- work perfectly on servers which don't follow this pattern, such
			-- as if they have a perfectly linear time between all pages without
			-- any throttling at all, in which case both estimates will basically
			-- agree anyway (both the current and the saved value). This is the
			-- best we can do with the facts of the game. A totally accurate
			-- estimate is impossible, but we're as accurate as we can be.
			-- NOTE: This estimate cannot be improved, since practically all
			-- servers apply random throttling, have various loads and slowdowns
			-- throughout the day, etc. This is the best we can do since the
			-- actual speed depends on the server and is pretty unpredictable.
			-- It would be like trying to predict "the total download-time of a
			-- file that keeps fluctuating between fast and slow speeds". The
			-- best we can do is estimate based on current and previous speeds.
			local last_scan_seconds_per_page = TSM.db.factionrealm.lastScanSecondsPerPage
			if last_scan_seconds_per_page and last_scan_seconds_per_page > 0 then
				-- TSM:Print(format("Read from DB: %f (Our unweighted estimate: %f)", last_scan_seconds_per_page, seconds_per_page))  -- DEBUG
				seconds_per_page = (seconds_per_page * progress_float) + (last_scan_seconds_per_page * remaining_float)
				-- TSM:Print(format("New, weighted estimate: %f (Progress: %f / Remaining: %f)", seconds_per_page, progress_float, remaining_float))  -- DEBUG
			else
				-- TSM:Print(format("Nothing in DB yet (Our unweighted estimate: %f)", seconds_per_page))  -- DEBUG
			end

			-- Estimate the "remaining time", rounded to the nearest whole second, at least 1 second.
			local seconds_raw = max(1, floor((pages_remaining * seconds_per_page) + 0.5))

			-- Convert the estimated seconds into hours, minutes and seconds.
			local hours, minutes, seconds = TSMAPI:SecondsToHMS(seconds_raw)
			time_estimate_str = format(" (~%d:%02d:%02d)", hours, minutes, seconds)
		end

		-- Calculate progress bar from 0-100%.
		local progress_bar = min(100 * progress_float, 100)

		-- Display the progress bar with the time estimate.
		TSM.GUI:UpdateStatus(format(L["Scanning page %s/%s"], page, total) .. time_estimate_str, progress_bar)
	elseif event == "SCAN_COMPLETE" then
		-- The whole scan is complete, and wasn't interrupted by the player.

		-- Store the final "seconds elapsed per page request" into the database.
		-- NOTE: We only update it here after complete scans, to avoid poisoning
		-- with incorrect, partial-scan estimates, since most servers heavily
		-- slow down their page requests over time. The completed scan is the truth.
		if Scan.fullScanSecondsPerPage > 0 then
			TSM.db.factionrealm.lastScanSecondsPerPage = Scan.fullScanSecondsPerPage
		end

		-- Now process all of the fetched auctions.
		local data = ...
		Scan:ProcessScanData(data)
		Scan:DoneScanning()
	elseif event == "SCAN_INTERRUPTED" or event == "INTERRUPTED" then
		-- We've been interrupted by the Auction House closing.
		-- NOTE: "SCAN_INTERRUPTED" is from LibAuctionScan-1.0, which isn't used
		-- by TSM anymore, and "INTERRUPTED" is from "TSM/Auction/AuctionScanning.lua",
		-- which is what this scanner uses nowadays.
		Scan:DoneScanning()
	end
end

function Scan.ProcessGetAllScan(self)
	-- Await the "AUCTION_ITEM_LIST_UPDATE" event with the results of the "get all" scan.
	-- NOTE: This event won't be received if the server ignored/throttled the "get all" scan.
	local time_start = time()
	local progress_bar = 0
	while true do
		-- NOTE: The fake progress bar takes 20 seconds to fill to 100% with this interval.
		progress_bar = min(progress_bar + 1, 100)  -- Fake progress bar from 0-100%.
		self:Sleep(0.2)  -- Update progress bar with this interval while waiting for server data.
		if not Scan.isScanning then return end  -- Failed or aborted scan.
		if Scan.getAllLoaded then  -- We have received the list of auctions via "AUCTION_ITEM_LIST_UPDATE" event!
			break
		end

		-- NOTE: If it has taken more than 30 seconds, we can assume that the server
		-- didn't send any data and won't be replying, most likely due to hidden
		-- throttling (happens on many private servers, if scanning too soon after another).
		local time_elapsed = time() - time_start
		if time_elapsed >= 30 then
			-- If this happens, the user has most likely been throttled and should try again later.
			TSM.GUI:UpdateStatus(L["Running query... Server not responding due to throttling? Try again later..."], nil, 100)
		else
			TSM.GUI:UpdateStatus(L["Running query..."], nil, progress_bar)
		end
	end

	-- IMPORTANT: As explained in the "Scan:AUCTION_ITEM_LIST_UPDATE()" code
	-- comments, we're allowing GetAll scans even when the server DOESN'T return
	-- all auctions. For example, Warmane has chosen to limit GetAll results to
	-- only 55k auctions (even though they usually have 120k+ auctions). This
	-- means that the market data calculations will be missing data. We should
	-- therefore warn the user and tell them to use "Full Scan" instead, when
	-- they're playing on such "limited GetAll" servers. But we'll still allow
	-- use of "GetAll", with a warning message for people who INSIST on using it,
	-- since even when it only looks at half the auctions, it can still give a
	-- "pretty decent" idea of market values.
	-- NOTE: It WOULD be "best" to always throw away (ignore) incomplete "GetAll"
	-- data, but most casual players will prefer to have this feature even if those
	-- incomplete scans are much less accurate than a proper "Full Scan".
	-- NOTE: The inaccuracy of an incomplete "GetAll" scan completely depends on
	-- how the server implements "GetAll". If the server sorts the cheapest
	-- auctions first, then it's somewhat acceptable for popular items which
	-- have many stacks (and are therefore likely to contain enough data points
	-- in the "GetAll" result), and those items will "just" tend to be undervalued
	-- by 2-10% less than their real market value (since their percentile-based
	-- scans will look at less auctions than the real amount). But for very rare
	-- or unpopular items, the partial "GetAll" scan is very dangerous, since
	-- you might only receive the massively overpriced auctions of a certain
	-- item, and thereby calculate an insanely high market value for it. These
	-- dangers are increased if the server sends the auctions in a totally
	-- random order, which means an even greater risk of market price pollution
	-- by only seeing overpriced auctions for many of the items.
	-- NOTE: Furthermore, receiving incomplete "GetAll" results means that TSM
	-- will wipe all of its "cheapest, current buyout price" data for all items,
	-- and then fills them with incorrect data (or nothing at all if an item
	-- wasn't seen in the latest fetch), thus hindering your ability to look up
	-- the correct "best current buyout prices" too.
	-- NOTE: In summary, you'll have to use partial "GetAll" results at your
	-- own risk! A "Full Scan" is ALWAYS much better when your server's "GetAll"
	-- doesn't provide all auction data!
	local shown, total = GetNumAuctionItems("list")
	if total ~= Scan.getAllLoaded then  -- getAllLoaded = Same as "shown", but cached via our GetAll event.
		-- NOTE: Message is not localized, because who the hell is gonna provide
		-- translations to this project? It'd be a waste of time to translate it,
		-- especially since we dynamically insert a word based on the result.
		TSM:Print(format(
			"WARNING: Your server has %d auctions, but it%s sent %d auctions to us. Please use the normal \"Full Scan\" instead, if you want to accurately calculate the real market values of items. Your server's \"GetAll\" scan doesn't fetch all auctions!",
			total, ((total > shown) and " only" or ""), shown
		))
	else
		TSM:Print(format("All auctions received from server (%d auctions)...", Scan.getAllLoaded))
	end

	-- Collect relevant data about the auctions that we've received.
	-- NOTE: "Scan.getAllLoaded" is the count of auctions we've received from
	-- the server. One per listing. We keep this cached value to constantly verify
	-- that we're still looking at the same auction-list while we're processing.
	local data = {}
	progress_bar = 0
	for auction_idx=1, Scan.getAllLoaded do
		if (auction_idx == 1) or (auction_idx == Scan.getAllLoaded) or ((auction_idx % 100) == 0) then
			-- Update progress bar for the 1st, last, and every 100th auction.
			progress_bar = min(100*(auction_idx/Scan.getAllLoaded), 100)  -- Calculate progress bar from 0-100%.
			TSM.GUI:UpdateStatus(format(L["Scanning page %s/%s"], 1, 1), progress_bar)

			-- Yield the CPU every 100th "auction listing", to prevent freezing the game.
			self:Yield()

			-- Verify the currently visible auction count, to ensure that we're
			-- still analyzing the same list of "GetAll" auction items.
			if GetNumAuctionItems("list") ~= Scan.getAllLoaded then
				-- This can happen due to server/game issues, or if the user
				-- closes the auction GUI while we're processing. If that
				-- happens, we'll abort the scan without processing the data.
				--TSM:Print(L["GetAll scan did not run successfully due to issues on Blizzard's end. Using the TSM application for your scans is recommended."])
				TSM:Print("GetAll: Scan failed or aborted by user.")
				Scan:DoneScanning()  -- Sets isScanning and getAllLoaded to nil.
				return
			end
		end

		-- Retrieve information about this auction.
		-- * itemID = The numeric ID of the item (such as 52021, which would represent "Iceblade Arrow" for example).
		-- * stack_size = How many are in this auction's exact "stack" (such as 940, if they're selling a stack of 940).
		-- * buyout = The buyout price of the auction (to get the per-item price, we need to divide "buyout / stack_size").
		local itemID = TSMAPI:GetItemID(GetAuctionItemLink("list", auction_idx))
		--local _, _, stack_size, _, _, _, _, _, _, buyout = GetAuctionItemInfo("list", auction_idx)
		local _, _, stack_size, _, _, _, _, _, buyout = GetAuctionItemInfo("list", auction_idx)

		-- Only process this auction if we saw a valid buyout price (ignore bid-only auctions, etc).
		if itemID and buyout and (buyout > 0) then
			-- Calculate the price per item, always rounded downwards.
			-- NOTE: TSM's "buyout per item" calculations are actually a freaking
			-- mess. They basically use "floor(buyout/count)" everywhere in the
			-- code, EXCEPT in SOME places where they use "floor(buyout/count + 0.5)"
			-- which means that those round to the nearest number instead, which
			-- is definitely more correct. In fact, it would probably be even more
			-- correct to enforce a minimum value of "1", otherwise a stack of
			-- 100 items for a total buyout price of 10 copper would end up as
			-- "0 copper per item" by the basic flooring algorithm (floor(0.1) = 0).
			-- But whatever, it's extremely inconsistently used everywhere in TSM's
			-- codebase, and most places use the plain "floor downwards", so we'll
			-- do that too. It would be way too much effort to rewrite the HUNDREDS of
			-- other code locations that deal with money (all via differently named
			-- variables), just to handle smarter rounding, and it would require
			-- a lot of effort to ensure that TSM's algorithms still work afterwards.
			-- But yeah, just realize this: TSM's per-item calculations aren't great,
			-- however it really DOESN'T MATTER MUCH since it only affects items
			-- whose prices are less than 1 copper per item, which is probably
			-- why TSM's author never noticed any issues with the basic "floor()".
			local buyout_per_item = floor(buyout / stack_size)

			-- Append to the existing "data to process" for this item ID if exists, else create new item.
			data[itemID] = data[itemID]
			if not data[itemID] then
				data[itemID] = {records={}, minBuyout=math.huge, quantity=0}
			end

			-- Calculate the lowest "per-item buyout price" we're seeing for this item.
			data[itemID].minBuyout = min(data[itemID].minBuyout, buyout_per_item)

			-- Count the total amount of this item that exists on the auction house (adds together all stacks).
			-- NOTE: This is super useful when we're calculating the market value in data.lua,
			-- since it tells us immediately what the total count (quantity) of all new records is.
			data[itemID].quantity = data[itemID].quantity + stack_size

			-- BRAINDEAD OLD TSM CODE WHICH ADDS 1 RECORD PER ITEM IN THE STACK,
			-- MEANING 500 STACKS OF 1000 ARROWS WOULD BE HALF A MILLION TABLE
			-- ROWS AND WOULD LEAD TO "OUT OF MEMORY" ERRORS. DON'T DO THIS!
			-- for j=1, stack_size do
			-- 	tinsert(data[itemID].records, buyout_per_item)
			-- end

			-- Rewritten, intelligent code which adds 1 record per "stack" (auction) instead.
			-- NOTE: We avoid using hash-keys, saving memory by using a numeric array instead.
			-- NOTE: We'll store 1 table per unique itemID, and 1 record per "auction"
			-- which passed our filters (has a buyout price), meaning that it's usually
			-- a bit less than the total auction count on the server, and will never
			-- be too many rows for WoW's Lua memory system to handle.
			-- NOTE: If there is ever a server with so many auctions that even this
			-- would reach WoW's Lua memory limits, then we could possibly store
			-- the records as a concatenated, semicolon-separated string instead,
			-- which would be slower but would handle millions of auctions with ease.
			tinsert(data[itemID].records, {stack_size, buyout_per_item})
		end
	end

	-- Process the collected "GetAll" auction data as a new "complete scan" with today's date.
	TSM.db.factionrealm.lastCompleteScan = time()
	TSM.Data:ProcessData(data, nil, verifyNewAlgorithm)

	-- Show GUI progress while we're waiting for the processing.
	-- NOTE: The status text will be set to "complete" elsewhere, automatically.
	TSM.GUI:UpdateStatus(L["Processing data..."])
	while TSM.processingData do
		self:Sleep(0.2)
	end

	-- Processing is complete, so warn the user that they should reload the UI now.
	TSM:Print(L["It is strongly recommended that you reload your ui (type '/reload') after running a GetAll scan. Otherwise, any other scans (Post/Cancel/Search/etc) will be much slower than normal."])
end

function Scan:AUCTION_ITEM_LIST_UPDATE()
	Scan:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")

	-- shown = How many auctions we received in the current data batch.
	-- total = The total number of auction items.
	local shown, total = GetNumAuctionItems("list")

	-- OLD TSM CODE: It assumes that "GetAll" returns ALL auctions on official
	-- Blizzard servers, so it also checks if "shown equals the total".
	--if shown ~= total or shown == 0 then
	-- WORKAROUND: Because places like Warmane with huge auction houses DON'T
	-- return all items even via "GetAll" scans, we must ignore shown-vs-total
	-- mismatches. The server won't let us query the subsequent pages since
	-- there isn't any pagination in the "GetAll" API, and wouldn't work anyway
	-- due to the 15-30 minute cooldown for "GetAll" calls, so we can't fetch
	-- all auctions if the server is too popular. For example, typical
	-- Warmane-Icecrown "GetAll" results will be: shown=55000, total=122523,
	-- meaning that "GetAll" only receives about half of the total auctions.
	if shown <= 0 then
		--TSM:Print(L["GetAll scan did not run successfully due to issues on Blizzard's end. Using the TSM application for your scans is recommended."])
		TSM:Print("GetAll: Scan failed due to server issues.")
		Scan:DoneScanning()  -- Sets isScanning and getAllLoaded to nil.
		return
	end

	-- Cache the amount of auctions we received on the current "page/batch", so that
	-- we can validate that we're looking at this "page" while processing later.
	Scan.getAllLoaded = shown
end

function Scan:GetAllScanQuery()
	-- NOTE: This API doesn't work properly on some servers. For example, on Warmane,
	-- it always claims that you can do a "GetAll" scan after you log in, even
	-- if you're on cooldown and the server will actually be ignoring your request,
	-- which is why we had to implement timeout detection in "ProcessGetAllScan()".
	local canScan, canGetAll = CanSendAuctionQuery()
	if not canGetAll then return TSM:Print(L["Can't run a GetAll scan right now."]) end
	if not canScan then return TSMAPI:CreateTimeDelay(0.5, Scan.GetAllScanQuery) end
	Scan:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
	QueryAuctionItems("", nil, nil, nil, nil, nil, nil, nil, nil, true)
	TSMAPI.Threading:Start(Scan.ProcessGetAllScan, 1, function() Scan:DoneScanning() end)
end

local function GroupScanCallback(event, ...)
	if event == "QUERY_COMPLETE" then
		local filterList = ...
		local numItems = 0
		for _, v in ipairs(filterList) do
			numItems = numItems + #v.items
		end
		Scan.filterList = filterList
		Scan.numFilters = #filterList
		Scan:ScanNextGroupFilter()
	elseif event == "QUERY_UPDATE" then
		local current, total = ...
		TSM.GUI:UpdateStatus(format(L["Preparing Filter %d / %d"], current, total))
	elseif event == "SCAN_INTERRUPTED" or event == "INTERRUPTED" then
		-- We've been interrupted by the Auction House closing.
		-- NOTE: "SCAN_INTERRUPTED" is from LibAuctionScan-1.0, which isn't used
		-- by TSM anymore, and "INTERRUPTED" is from "TSM/Auction/AuctionScanning.lua",
		-- which is what this scanner uses nowadays.
		Scan:DoneScanning()
	elseif event == "SCAN_TIMEOUT" then
		tremove(Scan.filterList, 1)
		Scan:ScanNextGroupFilter()
	elseif event == "SCAN_PAGE_UPDATE" then
		local page, total = ...
		-- We have now received at least 1 page for this item. Show how many pages remain.
		-- NOTE: We can't provide any time estimate here, since the other group sizes are unknown.
		-- NOTE: We use this particular item's page-progress as the progress bar.
		-- NOTE: We add "+1" to the page counter, to indicate that we've received that page and are working on the next page.
		local progress_bar = min(100*(page/total), 100)  -- Calculate progress bar from 0-100%.
		TSM.GUI:UpdateStatus(format(L["Scanning %d / %d (Page %d / %d)"], ((Scan.numFilters-#Scan.filterList) + 1), Scan.numFilters, min(page + 1, total), total), nil, progress_bar)
	elseif event == "SCAN_COMPLETE" then
		local data = ...
		for _, itemString in ipairs(Scan.filterList[1].items) do
			if not Scan.groupScanData[itemString] then
				Scan.groupScanData[itemString] = data[itemString]
			end
		end
		tremove(Scan.filterList, 1)
		Scan:ScanNextGroupFilter()
	end
end

function Scan:ScanNextGroupFilter(data)
	if #Scan.filterList == 0 then
		Scan:ProcessScanData(Scan.groupScanData)
		Scan:DoneScanning()
		return
	end

	-- Apply the temporary label for when we've requested the item's 1st page,
	-- but we don't yet know how many results or pages there are for this item.
	-- NOTE: We can't provide any time estimate here, since the other group sizes are unknown.
	-- NOTE: In the label, we count the items starting at 1, to say "Scanning 1 / 2"
	-- (instead of "Scanning 0 / 2"), but for the progress bar we count starting
	-- from 0, so that it fills up properly by only proceeding after an item is done.
	local progress_bar = min(100*((Scan.numFilters-#Scan.filterList)/Scan.numFilters), 100)  -- Calculate progress bar from 0-100%.
	TSM.GUI:UpdateStatus(format(L["Scanning %d / %d (Page 1 / ?)"], ((Scan.numFilters-#Scan.filterList) + 1), Scan.numFilters), progress_bar)
	TSMAPI.AuctionScan:RunQuery(Scan.filterList[1], GroupScanCallback)
end

function Scan:StartGroupScan(items)
	Scan.isScanning = "Group"
	Scan.isBuggedGetAll = nil
	Scan.groupItems = items
	wipe(Scan.filterList)
	wipe(Scan.groupScanData)
	Scan.numFilters = 0
	TSMAPI.AuctionScan:StopScan()
	TSMAPI:GenerateQueries(items, GroupScanCallback)
	TSM.GUI:UpdateStatus(L["Preparing Filters..."])
end

function Scan:StartFullScan()
	Scan.isScanning = "Full"
	TSM.GUI:UpdateStatus(L["Running query..."])
	Scan.isBuggedGetAll = nil
	Scan.groupItems = nil
	TSMAPI.AuctionScan:StopScan()
	Scan.fullScanStartTime = time()  -- Keep track of when we started the "Full Scan".
	Scan.fullScanSecondsPerPage = -1  -- Reset the page-speed timer.
	TSMAPI.AuctionScan:RunQuery({name=""}, FullScanCallback)
end

function Scan:StartGetAllScan()
	-- Refuse to perform "GetAll" if we're called while "GetAll" is disabled.
	-- NOTE: Only happens if the player has visited the auction house and looked
	-- at the AuctionDB GUI, and THEN gone into TSM's options to disable "GetAll".
	-- The "Run GetAll Scan" button remains until /reload, so we must block it.
	if TSM.db.profile.disableGetAll then
		TSM:Print(L["You have disabled GetAll scans via AuctionDB's options."])
		return
	end

	-- Begin the "GetAll" scan.
	TSM.db.profile.lastGetAll = time()
	Scan.isScanning = "GetAll"
	Scan.isBuggedGetAll = nil
	Scan.groupItems = nil
	TSMAPI.AuctionScan:StopScan()
	Scan:GetAllScanQuery()
end

function Scan:DoneScanning()
	TSM.GUI:UpdateStatus(L["Done Scanning"], 100)
	Scan.isScanning = nil
	Scan.getAllLoaded = nil
end

function Scan:ProcessScanData(scanData)
	-- Handle scans performed via "Full Scan" and "Group Scan", but not "GetAll".
	-- NOTE: See "Scan.ProcessGetAllScan()" for full explanation of this algorithm.
	local data = {}

	for itemString, obj in pairs(scanData) do
		if TSMAPI:GetBaseItemString(itemString) == itemString then
			local itemID = obj:GetItemID()
			local quantity, minBuyout = 0, 0
			local records = {}
			for _, record in ipairs(obj.records) do
				-- Only process this auction if we saw a valid buyout price (ignore bid-only auctions, etc).
				if record.buyout and record.buyout > 0 then
					-- Calculate the price per item, always rounded downwards.
					-- NOTE: "GetItemBuyout" returns nil if no buyout or if buyout is "0".
					local itemBuyout = record:GetItemBuyout()
					if itemBuyout then
						-- Calculate the lowest "per-item buyout price" we're seeing for this item.
						if (itemBuyout < minBuyout or minBuyout == 0) then
							minBuyout = itemBuyout
						end

						-- Count the total amount of this item that exists on the auction house (adds together all stacks).
						quantity = quantity + record.count

						-- BRAINDEAD OLD TSM CODE WHICH ADDS 1 RECORD PER ITEM IN THE STACK,
						-- MEANING 500 STACKS OF 1000 ARROWS WOULD BE HALF A MILLION TABLE
						-- ROWS AND WOULD LEAD TO "OUT OF MEMORY" ERRORS. DON'T DO THIS!
						-- for i=1, record.count do
						-- 	tinsert(records, itemBuyout)
						-- end

						-- Rewritten, intelligent code which adds 1 record per "stack" (auction) instead.
						tinsert(records, {record.count, itemBuyout})
					end
				end
			end

			-- Add this item to "data to process" even if there's zero records,
			-- which can happen if they're all bid-only auctions.
			-- NOTE: This differs from the behavior of "ProcessGetAllScan", which
			-- only adds items that have at least 1 record with a buyout value.
			-- NOTE: Empty records are totally fine either way, since "ProcessData"
			-- simply ignores items that don't contain any buyout prices.
			-- NOTE: If no buyout records were found, the "minBuyout" and "quantity"
			-- fields below both have the default value of "0" (initialized above).
			data[itemID] = {records=records, minBuyout=minBuyout, quantity=quantity}
		end
	end

	-- Mark the collected auction data as a new "complete scan" with today's date,
	-- but only if this was a normal "Full Scan" (not just a "TSM item group" scan).
	if Scan.isScanning ~= "group" then
		TSM.db.factionrealm.lastCompleteScan = time()
	end

	-- Process the collected auction data.
	TSM.Data:ProcessData(data, Scan.groupItems, verifyNewAlgorithm)
end

function Scan:ProcessImportedData(auctionData)
	-- Handle manually imported auction scan data.
	-- NOTE: This function is deprecated? Nothing seems to call it, unless they're
	-- somehow calling it via another non-named technique, or perhaps it's internal
	-- for developer-use only (basically just a quick way to emulate a full scan).
	local data = {}

	for itemID, auctions in pairs(auctionData) do
		-- Process all imported auction records for this item.
		local quantity, minBuyout = 0, 0
		local records = {}
		for _, auction in ipairs(auctions) do
			-- Fetch the "price per item" and "item-count in this stack" from the auction's data.
			-- NOTE: We only import auctions with per-item buyout values (ignore bid-only auctions, etc).
			local itemBuyout, count = unpack(auction)
			if itemBuyout then
				-- Calculate the lowest "per-item buyout price" we're seeing for this item.
				if (itemBuyout < minBuyout or minBuyout == 0) then
					minBuyout = itemBuyout
				end

				-- Count the total amount of this item that exists on the auction house (adds together all stacks).
				quantity = quantity + count

				-- BRAINDEAD OLD TSM CODE WHICH ADDS 1 RECORD PER ITEM IN THE STACK,
				-- MEANING 500 STACKS OF 1000 ARROWS WOULD BE HALF A MILLION TABLE
				-- ROWS AND WOULD LEAD TO "OUT OF MEMORY" ERRORS. DON'T DO THIS!
				-- for i=1, count do
				-- 	tinsert(records, itemBuyout)
				-- end

				-- Rewritten, intelligent code which adds 1 record per "stack" (auction) instead.
				tinsert(records, {count, itemBuyout})
			end
		end

		-- Add this item to "data to process" even if there's zero records,
		-- which can happen if they're all bid-only auctions.
		data[itemID] = {records=records, minBuyout=minBuyout, quantity=quantity}
	end

	-- Process the imported auction data as a new "complete scan" with today's date.
	TSM.db.factionrealm.lastCompleteScan = time()
	TSM.Data:ProcessData(data, nil, verifyNewAlgorithm)
end
