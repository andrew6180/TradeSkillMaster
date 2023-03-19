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

-- locals to speed up function access
local abs = abs
local CopyTable = CopyTable
local debugprofilestop = debugprofilestop
local floor = floor
local format = format
local ipairs = ipairs
local pairs = pairs
local sqrt = sqrt
local time = time
local tinsert = tinsert
local tsort = table.sort
local type = type
local unpack = unpack

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

--- Process a table of new market scan data.
-- @param scanData The market scan data.
-- @param[opt] groupItems Affects how the minBuyout data is wiped. Use nil for regular behavior.
-- @param[opt] verifyNewAlgorithm Boolean 'true' if you want to benchmark and verify the new market value algorithm.
function Data:ProcessData(scanData, groupItems, verifyNewAlgorithm)
	-- If we're currently processing data, retry in 0.2 seconds.
	-- NOTE: This will retry itself over and over until it's able to process.
	if TSM.processingData then
		return TSMAPI:CreateTimeDelay(0.2, function() Data:ProcessData(scanData, groupItems, verifyNewAlgorithm) end)
	end


	-- Wipe all of our existing "minBuyout" data for the items included in the
	-- new, incoming scan data in case of "Item Group scan", or for ALL currently
	-- cached items in memory in other cases (such as "Full" and "GetAll" scans).
	-- NOTE: It's no problem if we leave some items empty with "nil" minBuyout
	-- values. That's how TSM is supposed to work, with items having an empty "minBuyout"
	-- if there wasn't any "minBuyout" data for that item in the newest data batch.
	if groupItems then
		-- A list of items ("group scan") was provided. Wipe data for those items.
		for itemString in pairs(groupItems) do
			local itemID = TSMAPI:GetItemID(itemString)
			if TSM.data[itemID] then  -- If we have existing data for this item.
				TSM:DecodeItemData(itemID)
				TSM.data[itemID].minBuyout = nil  -- Erase its stored minBuyout value.
				TSM:EncodeItemData(itemID)
			end
		end
	else
		-- Wipe data for all items in memory, regardless of whether they're actually
		-- included in the incoming scan data or not...
		for itemID, data in pairs(TSM.data) do
			TSM:DecodeItemData(itemID)
			data.minBuyout = nil  -- Directly updates TSM.data[itemID] via reference.
			TSM:EncodeItemData(itemID)
		end
	end


	-- Convert the incoming "scanData" hashmap to a numerically indexed table,
	-- to allow us to perform batched processing (since "pairs()" wouldn't know
	-- how to resume at the current spot between our batch processing callbacks).
	-- NOTE: Doesn't use much memory, since we're re-using "data" table refs.
	local scanDataList = {}
	for itemID, data in pairs(scanData) do
		scanDataList[#scanDataList + 1] = {itemID, data}
	end


	-- Go through each item and figure out their market value / update the data table.
	-- NOTE: This processes the data in batched chunks of 500 items at a time,
	-- pausing between each chunk to allow the game client to avoid freezing.
	local index = 1
	local day = Data:GetDay()
	local function DoDataProcessing()
		for i = 1, 500 do
			-- Abort if we've reached the end of the processing queue.
			if index > #scanDataList then
				TSMAPI:CancelFrame("adbProcessDelay")
				TSM.processingData = nil
				break
			end

			-- Detect which Item ID we're processing, and read its new data (new auction records).
			local itemID, data = unpack(scanDataList[index])

			-- Calculate the market value, and optionally perform benchmarks and
			-- validation of the "new, compact algorithm" to prove correctness.
			-- NOTE: We refuse to verify data with over 200 000 "item rows", since
			-- that would risk bloating RAM and leading to a script crash. This
			-- has been VERIFIED to still WORK with 169 000 rows, but fail for
			-- an item with 686 900 table rows (script stops executing), so 200k
			-- should be a safe cutoff to prevent memory overflows during benchmark.
			local marketValue = -1
			if (not verifyNewAlgorithm) or (data.quantity >= 200000) then
				-- NOTE: Returns -1 if there aren't enough records to calculate.
				marketValue = Data:CalculateMarketValue(data, verifyNewAlgorithm)
			else
				-- Verification and benchmark requested, and item is safe to check.

				-- Perform the two calculations and benchmark the algorithms.
				-- NOTE: Debug profiling is counted in milliseconds. For the old
				-- algorithm, we're also including the time it takes to create
				-- the "bloated table", since that's how the old TSM algorithm
				-- created the table too (adds 1 row per "individual stack item").
				-- SEE: https://wowpedia.fandom.com/wiki/API_debugprofilestop
				local time_start_ms = debugprofilestop()

				-- Generate an old-school data table, where we insert one row
				-- per "item" per stack, so 5 stacks of 1000 items would mean
				-- a total of 5000 rows, each with the individual item's price.
				local data_new_records = data.records
				local data_old_table = {records={}, minBuyout=data.minBuyout, quantity=data.quantity}
				local data_old_records = data_old_table.records
				for stack_idx=1, #data_new_records do
					local stack_size, buyout_per_item = unpack(data_new_records[stack_idx])
					for this_stack_item_idx=1, stack_size do
						-- NOTE: The old algorithm used this exact tinsert()
						-- method instead of the faster "tbl[#tbl + 1]" technique,
						-- so that's why we're keeping that slow method here.
						tinsert(data_old_records, buyout_per_item)
					end
				end

				-- Verify that the "old-school table" contains ALL "expanded" items.
				if #data_old_records ~= data.quantity then
					TSM:Print(format("TABLE CREATION ERROR: item=%d, expected quantity=%d, created quantity=%d", itemID, data.quantity, #data_old_records))
				end

				-- Generate the old algorithm's value and finish its benchmark.
				local old_marketValue = Data:CalculateMarketValue(data_old_table, verifyNewAlgorithm)
				local time_elapsed_old_ms = (debugprofilestop() - time_start_ms)

				-- Now generate the new algorithm's value and benchmark it too.
				-- NOTE: This new algorithm is 1.3x-27.3x faster depending on
				-- input data size, and on average 5x faster for most data. :)
				time_start_ms = debugprofilestop()
				marketValue = Data:CalculateMarketValue(data, verifyNewAlgorithm)
				local time_elapsed_new_ms = (debugprofilestop() - time_start_ms)

				-- Verify the calculations to ensure the algorithms are equal.
				-- NOTE: Yes, the algorithms are perfectly equal for all input data.
				if old_marketValue ~= marketValue then
					TSM:Print(format("! ALGORITHM ERROR: item=%d, old=%.1f, new=%.1f", itemID, old_marketValue, marketValue))
				end

				-- Output benchmark results, but only for items with at least 500 entries.
				-- NOTE: Comment this out if you're only interested in errors
				-- above, or feel free to raise cutoff quantity to reduce logging.
				if data.quantity >= 500 then
					TSM:Print(format("+ ALGORITHM SPEED: item=%d, quantity=%d, match=%s, old=%.1f, new=%.1f, old_speed=%f ms, new_speed=%f ms, speedup=%.2f x",
					itemID, data.quantity, old_marketValue == marketValue and "YES" or "NO", old_marketValue, marketValue, time_elapsed_old_ms, time_elapsed_new_ms, time_elapsed_old_ms > 0 and (time_elapsed_old_ms / time_elapsed_new_ms) or math.huge))  -- Prevents division by zero.
				end
			end

			-- Detect whether it was POSSIBLE to calculate a market value, and
			-- ONLY proceed with the item updates if we were able to calculate
			-- a new market value. Otherwise, skip the item as if it "didn't even
			-- exist in this scan", since it basically "doesn't exist" if there
			-- were no buyout prices to calculate a new market value from!
			-- NOTE: This can happen if the scan data only contained "bid without
			-- buyout" items, meaning they didn't have any per-item buyout data,
			-- which can ONLY happen via "Scanning.lua:ProcessScanData()" when
			-- doing a normal "Full Scan" or "Group Scan" (not "GetAll"). If
			-- there aren't any buyout prices for the item, it still gets added
			-- without any "records". This differs from "GetAll" which only adds
			-- items to the queue if they had at least one "buyout price" auction.
			-- NOTE: We're skipping the empty/indeterminable items to ensure that
			-- we have identical behavior for both "GetAll" and all other scan
			-- types, so that we NEVER add "empty/missing" market values for items!
			-- NOTE: We allow a market value of "0", since it means there was
			-- valid data in the calculations. However, "0" is extremely unlikely
			-- since it would require a single, huge stack of items for a price
			-- of 1 copper or so, to make the per-item market value end up at
			-- just "0" for that item. Basically, it's never gonna happen!
			if marketValue and (marketValue >= 0) then
				-- Fetch our archived data (if we have any) for this itemID.
				TSM:DecodeItemData(itemID)
				TSM.data[itemID] = TSM.data[itemID] or {scans={}, lastScan = 0}

				-- Update market scan statistics for this item.
				local scanData = TSM.data[itemID].scans
				scanData[day] = scanData[day] or {avg=0, count=0}
				if type(scanData[day]) == "number" then
					-- Original code comment here: "This should never happen..."
					-- NOTE: WTF was TSM's original author doing here? They're
					-- converting "scanData[day]" into an array with 1 numeric
					-- value, and mixing that array data with hashmap keys below,
					-- so it seems like they're storing some data with numeric
					-- keys and others with hashmap keys, all in the same table...
					scanData[day] = {scanData[day]}
				end
				scanData[day].avg = scanData[day].avg or 0
				scanData[day].count = scanData[day].count or 0
				if #scanData[day] > 0 then
					scanData[day] = Data:ConvertScansToAvg(scanData[day])
				end
				scanData[day].avg = floor((scanData[day].avg * scanData[day].count + marketValue) / (scanData[day].count + 1) + 0.5)
				scanData[day].count = scanData[day].count + 1

				-- Remember the item's scan date, cheapest buyout price on AH right now,
				-- and how many items in total exist on AH (adds together all stacks).
				-- NOTE: We only update "minBuyout" if the scanned data for that
				-- item contains a "greater than 0" buyout value. That was mostly
				-- necessary in the past, when TSM sloppily included bid-only items
				-- in the data, but should no longer be able to happen with our new code!
				TSM.data[itemID].lastScan = TSM.db.factionrealm.lastCompleteScan
				TSM.data[itemID].minBuyout = data.minBuyout > 0 and data.minBuyout or nil
				TSM.data[itemID].quantity = data.quantity  -- Counts all items of all stacks.
				Data:UpdateMarketValue(TSM.data[itemID])

				-- Update our archived, encoded representation of this item's data.
				TSM:EncodeItemData(itemID)
			end

			-- Update our processing-index to point at the next item.
			index = index + 1
		end
	end

	TSM.processingData = true
	TSMAPI:CreateTimeDelay("adbProcessDelay", 0, DoDataProcessing, 0.1)
end

--- Calculate the current market value of an item, from the given scan data.
-- @param data The market scan data. Beware that we will automatically mutate the "data.records" table to sort the incoming data!
-- @param[opt] hide_oldschool_warning Boolean 'true' to suppress the warning if you're using the old-school algorithm. This is only useful when benchmarking!
function Data:CalculateMarketValue(data, hide_oldschool_warning)
	-- All auctions/stacks for this item (contains their price per item, and each stack's item count).
	-- NOTE: The old-school algorithm instead uses bloated records (see description further down).
	local records = data.records

	-- How many of this item currently exists in total on the auction house (combines all stacks).
	-- NOTE: This is the sum of the per-stack counts of all "records", and can be trusted completely.
	local total_quantity = data.quantity

	-- If we've been given zero records, return a market value of -1 to signal the issue.
	-- NOTE: If we don't do this filtering, we would end up with "division by zero" below.
	if (type(records) ~= "table") or (#records <= 0) then
		return -1
	end


	-- Determine which algorithm to use; either old-school or the smart, "compact" algorithm.
	if type(records[1]) ~= "table" then
		-- USE THE OLD, BRAINDEAD ALGORITHM IF WE'VE BEEN GIVEN OLD-SCHOOL "BLOATED" RECORDS.
		-- NOTE: This old TSM algorithm relies on tables with millions of entries,
		-- which often leads to out-of-memory crashes and is also extremely slow.
		if not hide_oldschool_warning then
			-- Warn if we've been called with old-school data and we haven't
			-- been told to suppress this warning (benchmarks will suppress it).
			TSM:Print("Warning: Calculating old-school market value. The calling code needs to be rewritten to use the new method!")
		end

		local totalNum, totalBuyout = 0, 0
		local numRecords = #records

		-- See "STEP 1" of new algorithm for explanation about why we MUST sort.
		tsort(records, function(a_buyout_per_item, b_buyout_per_item)
			-- Sort by "per-item buyout" in ascending order.
			return a_buyout_per_item < b_buyout_per_item
		end)

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
		local variance = 0

		for i=1, totalNum do
			variance = variance + (records[i]-uncorrectedMean)^2
		end

		local stdDev = sqrt(variance/totalNum)
		local correctedTotalNum, correctedTotalBuyout = 1, uncorrectedMean

		for i=1, totalNum do
			if abs(uncorrectedMean - records[i]) < 1.5*stdDev then
				correctedTotalNum = correctedTotalNum + 1
				correctedTotalBuyout = correctedTotalBuyout + records[i]
			end
		end

		local correctedMean = floor(correctedTotalBuyout / correctedTotalNum + 0.5)

		return correctedMean
	else
		-- Rewritten, cleaned up and faster algorithm, which uses almost zero memory
		-- and NEVER causes any memory overflow crashes, unlike the old algorithm.
		-- AUTHOR: Gnomezilla on Warmane-Icecrown [https://github.com/Bananaman].
		-- NOTE: This new algorithm is 1.3x-27.3x faster depending on input data
		-- size, and on average 5x faster for most data. :)
		-- NOTE: All code is heavily commented, to help other programmers understand
		-- the complex algorith, and to avoid future breakages due to misunderstandings.
		-- NOTE: TSM's intended algorithm is also documented online, but they
		-- describe a slightly altered (more modern) algorithm than what we're using:
		-- https://support.tradeskillmaster.com/en_US/custom-strings/how-is-auctiondb-market-value-calculated
		-- Archived in case TSM deletes the page: https://archive.ph/LhSOI


		-- How many of the cheapest items to consider (default: at least
		-- 15%, at most 30% of the cheapest items). All items which are more
		-- expensive than them are ignored.
		-- NOTE: This is considered as the total of all items (combined
		-- quantity of all items in all stacks). So if the first (cheapest)
		-- stack is massive, and subsequent stacks are small, then we'll
		-- only be calculating the value of the items of the 1st stack.
		local idx_min_percentile = total_quantity * MIN_PERCENTILE
		local idx_max_percentile = total_quantity * MAX_PERCENTILE

		-- Keep track of how many items we've processed and their combined buyout.
		local processed_quantity, processed_total_buyout = 0, 0

		-- Cutoff value for how much the "next auction" is allowed to cost,
		-- so that we can ignore all overpriced items. Default: Any price
		-- increase higher than 120% will discard all subsequent auctions.
		-- NOTE: We only need to update this when we switch to another "stack",
		-- and we're initializing it to a special "infinity" value (math.huge)
		-- to ensure that we don't use this value until we've calculated it.
		local max_jump_buyout_per_item = math.huge

		-- Keep track of the total "item index" we're at while we're traversing
		-- through our compact "stacks". This emulates the classic way TSM
		-- keeps track of the item/record counter.
		local item_idx = 0

		-- Used for signaling that we want to abort processing the remaining records.
		local skip_remaining_records = false


		-- STEP 1 (EXTREMELY IMPORTANT): We CANNOT trust the input. Our market
		-- value algorithm ONLY WORKS if the prices are SORTED in ASCENDING ORDER,
		-- but the auctions themselves are in RANDOM ORDER by default, in most
		-- cases. So we MUST forcibly sort them now, otherwise we'll randomly
		-- end up with very expensive items at the start of the list, which then
		-- becomes extremely INCORRECT market values in our database, such as
		-- thinking that "Wool Cloth" could be worth crazy amounts like "50 gold
		-- per 1 wool cloth" instead of its real market value, thus breaking TSM!
		tsort(records, function(a, b)
			-- NOTE: Direct table refs instead of unpack() speeds up the sorting
			-- by 3x, due to all the calls/comparisons involved when sorting.
			local a_stack_size, a_buyout_per_item = a[1], a[2]
			local b_stack_size, b_buyout_per_item = b[1], b[2]

			-- Sort by "per-item buyout" in ascending order, and use "stack size"
			-- in ascending order as a fallback if two stacks have identical prices.
			if a_buyout_per_item ~= b_buyout_per_item then
				return a_buyout_per_item < b_buyout_per_item
			else
				return a_stack_size < b_stack_size
			end
		end)


		-- STEP 2: Calculate the total buyout of all items we'll be processing.

		-- Process all of the compact "stack" records.
		-- NOTE: Every record is 1 auction/stack, with a size and buyout-per-item.
		for stack_idx=1, #records do
			-- Fetch the stack size and buyout-per-item of this stack.
			local stack_size, buyout_per_item = unpack(records[stack_idx])

			-- Run TSM's algorithm for EVERY individual "item" in the stack's size,
			-- so that we perform the same per-"item" work as their braindead algo.
			-- NOTE: Does nothing if "stack_size" is <= 0.
			-- NOTE: Technically, it would be possible to further optimize this
			-- algorithm to "skip past entire stacks" all at once, instead of
			-- processing every individual "virtual item from the stack", but
			-- the algorithm is already so fast that adding extra complexity
			-- is pointless and would just make it much harder to maintain!
			for this_stack_item_idx=1, stack_size do
				-- Increment the "total item index" that we're at now (across all stacks).
				-- NOTE: Emulates TSM's counting of every "item" as individual records.
				item_idx = item_idx + 1

				-- Calculate the max allowed "buyout-per-item" price jump of the
				-- current item.
				-- NOTE: Yeah this leads to weirdness if we ended up including items
				-- that were overpriced but were required by the "must process 15%+
				-- of all items no matter what" TSM requirement, but TSM fixes
				-- that problem during later filtering "steps" of the algorithm.
				-- NOTE: We're only recalculating the value when the "previous
				-- item" changes, meaning that unlike the old-school TSM algo,
				-- we don't waste time re-calculating it thousands of times in
				-- a row for large stacks of identical "per-item" prices.
				-- NOTE: This optimization has been verified to generate the EXACT
				-- same behavior/result as the old-schoold TSM algorithm.
				-- NOTE: Yes, item 1 of stack 1 keeps the pre-initialized value
				-- of "math.huge (infinity)" (above), since we don't need it yet.
				-- NOTE: In effect, we're ALWAYS comparing the CURRENT item's
				-- buyout price to a "max buyout" calculated from the "PREVIOUS
				-- item". This "stack magic" is just an optimization to reduce
				-- the CPU usage of the algorithm!
				if this_stack_item_idx == 1 and stack_idx >= 2 then
					-- We're on the FIRST item of a NEW stack (not stack 1).
					-- Re-calculate "max buyout price" based on PREVIOUS stack's price.
					-- NOTE: We could cache the "previous" data to avoid the lookup
					-- here, but we wouldn't really save any meaningful CPU usage
					-- and it would be harder for other programmers to understand.
					local previous_stack_size, previous_buyout_per_item = unpack(records[stack_idx - 1])
					max_jump_buyout_per_item = MAX_JUMP * previous_buyout_per_item
				elseif this_stack_item_idx == 2 then
					-- We're on the SECOND item of SAME stack (any stack, even stack 1).
					-- Re-calculate "max buyout price" based on THIS stack's price.
					max_jump_buyout_per_item = MAX_JUMP * buyout_per_item
				end

				-- If we're on "total item index" 2 or higher, and we've processed
				-- at least "min percentile" amount of records, AND we've -EITHER-
				-- reached the "maximum percentile" too -OR- we've reached a severely
				-- overpriced stack before we could reach the "maximum percentile",
				-- and if so, we'll skip all other records (remaining stacks/items).
				if item_idx >= 2
				and item_idx > idx_min_percentile
				and (item_idx > idx_max_percentile or buyout_per_item >= max_jump_buyout_per_item) then
					-- Signal that we want to skip the remaining records.
					skip_remaining_records = true
					break
				end

				-- Keep track of the total buyout value of all processed items.
				-- NOTE: This is the main purpose of this particular loop.
				processed_total_buyout = processed_total_buyout + buyout_per_item

				-- Calculate "how many items we have processed", which is simply
				-- the same as the current item index.
				-- NOTE: TSM's classic algo does this as "item_idx - 1" because
				-- they update this counter BEFORE they've decided whether to
				-- actually process the current item. We instead only update this
				-- after we've processed and incremented "total buyout" above,
				-- which has the same end result but is much easier to understand.
				-- NOTE: TSM's classic algo also has a weird chunk after this line,
				-- which does "if item_idx == total_quantity then
				-- processed_quantity = item_idx; end", which is complete nonsense
				-- and was only needed due to their braindead sequence of updating
				-- the "processed_quantity" variable, since they clearly just tried
				-- to avoid having "processed_quantity = 0" when "total_quantity = 1",
				-- but that was an extremely idiotic "fix" for their bad code. :)
				processed_quantity = item_idx
			end

			-- Exit from the nested loop if we've been told to stop processing records.
			if skip_remaining_records then break end
		end

		--  TSM:Print(format("processed_quantity: %d, processed_total_buyout: %d", processed_quantity, processed_total_buyout))  -- DEBUG


		-- STEP 3: Calculate the mean (simple average) of all processed items.

		local uncorrected_mean = processed_total_buyout / processed_quantity


		-- STEP 4: Calculate the standard deviation of all processed items.

		local variance = 0

		-- Process all of the compact "stack" records again, but stop when we hit the limit.
		-- NOTE: To understand this looping algorithm, look at STEP 2's comments above.
		item_idx = 0
		skip_remaining_records = false
		for stack_idx=1, #records do
			local stack_size, buyout_per_item = unpack(records[stack_idx])
			for this_stack_item_idx=1, stack_size do
				item_idx = item_idx + 1

				-- Process up to and including "processed_quantity", but not higher.
				if item_idx > processed_quantity then
					skip_remaining_records = true
					break
				end

				-- Calculate the updated variance.
				variance = variance + ((buyout_per_item - uncorrected_mean)^2)
			end

			if skip_remaining_records then break end
		end

		local std_dev = sqrt(variance / processed_quantity)

		--  TSM:Print(format("std_dev: %f, variance: %f", std_dev, variance))  -- DEBUG


		-- STEP 5: Ignore all data points that are more than 1.5x std_dev away from the average.

		-- Initialize the "corrected" quantity and buyout with 1 "fake" item
		-- that has the same value as the uncorrected mean.
		-- NOTE: We're replicating TSM 2.8's classic algorithm here... even
		-- though their algorithm might not be perfect.
		local corrected_processed_quantity, corrected_processed_total_buyout = 1, uncorrected_mean

		-- Calculate the standard deviation cutoff. Anything further away will be ignored.
		local std_dev_cutoff = 1.5 * std_dev

		-- Process all of the compact "stack" records again, but stop when we hit the limit.
		-- NOTE: To understand this looping algorithm, look at STEP 2's comments above.
		item_idx = 0
		skip_remaining_records = false
		for stack_idx=1, #records do
			local stack_size, buyout_per_item = unpack(records[stack_idx])

			-- Speedup: Since the "buyout_per_item" only changes when we switch
			-- to a different stack (all items in a stack have the same per-item
			-- prices), we can therefore pre-calculate their deviation from the
			-- average (mean) here, to avoid having to do it per-item below.
			local abs_deviation_from_mean = abs(uncorrected_mean - buyout_per_item)

			-- Speedup: We can also pre-calculate whether the items of this "stack"
			-- all fit the rule of "they're less than std_dev cutoff away from mean".
			local stack_include_items = abs_deviation_from_mean < std_dev_cutoff

			-- Loop through all virtual "items" of the current "stack".
			for this_stack_item_idx=1, stack_size do
				item_idx = item_idx + 1

				-- Process up to and including "processed_quantity", but not higher.
				if item_idx > processed_quantity then
					skip_remaining_records = true
					break
				end

				-- Calculate the filtered "quantity" and "total buyout", which
				-- ignores anything that's more than "std_dev_cutoff" away from avg.
				if stack_include_items then
					corrected_processed_quantity = corrected_processed_quantity + 1
					corrected_processed_total_buyout = corrected_processed_total_buyout + buyout_per_item
				end
			end

			if skip_remaining_records then break end
		end

		--  TSM:Print(format("corrected_processed_quantity: %d, corrected_processed_total_buyout: %d", corrected_processed_quantity, corrected_processed_total_buyout))  -- DEBUG


		-- STEP 6: Calculate our current market value by simply taking the
		-- average of the remaining (filtered) data points.
		-- NOTE: This method ensures that no poisoning of our market value can
		-- take place by those who post high volume items at astronomical prices.
		-- It also gets rid of more subtle outliers to determine the average.

		local corrected_mean = floor((corrected_processed_total_buyout / corrected_processed_quantity) + 0.5)


		return corrected_mean
	end
end