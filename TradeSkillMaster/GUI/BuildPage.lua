-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--                http://www.curse.com/addons/wow/tradeskill-master               --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

local TSM = select(2, ...)
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local lib = TSMAPI
local customPriceFrame


--[[-----------------------------------------------------------------------------
TSMAPI:BuildPage() Support Functions
-------------------------------------------------------------------------------]]

local function CreateCustomPriceFrame()
	local frame = CreateFrame("Frame", nil, TSMMainFrame1)
	TSMAPI.Design:SetFrameBackdropColor(frame)
	frame:Hide()
	frame:SetPoint("TOPLEFT", TSMMainFrame1, "TOPRIGHT", 2, 0)
	frame:SetWidth(300)
	frame:SetHeight(400)
	
	local container = AceGUI:Create("TSMScrollFrame")
	container:SetLayout("Flow")
	container.frame:SetParent(frame)
	container.frame:SetPoint("TOPLEFT", 5, -5)
	container.frame:SetPoint("BOTTOMRIGHT", -5, 5)
	
	local page = {
		{
			type = "Label",
			relativeWidth = 1,
			text = L["Below are various ways you can set the value of the current editbox. Any combination of these methods is also supported."],
		},
		{
			type = "HeadingLine",
			relativeWidth = 1,
		},
		{
			type = "Label",
			text = TSMAPI.Design:GetInlineColor("category")..L["Fixed Gold Value"].."|r",
			relativeWidth = 1,
		},
		{
			type = "Label",
			text = L["A simple, fixed gold amount."],
			relativeWidth = 1,
		},
		{
			type = "HeadingLine",
			relativeWidth = 1,
		},
		{
			type = "Label",
			text = TSMAPI.Design:GetInlineColor("category")..L["Percent of Price Source"].."|r",
			relativeWidth = 1,
		},
		{
			type = "Label",
			text = L["Type '/tsm sources' to print out all available price sources."],
			relativeWidth = 1,
		},
		{
			type = "HeadingLine",
			relativeWidth = 1,
		},
		{
			type = "Label",
			text = TSMAPI.Design:GetInlineColor("category")..L["More Advanced Methods"].."|r",
			relativeWidth = 1,
		},
		{
			type = "Label",
			text = format("See %s for more info.", TSMAPI.Design:GetInlineColor("link").."http://bit.ly/TSMCP|r"),
			relativeWidth = 1,
		},
		{
			type = "HeadingLine",
			relativeWidth = 1,
		},
		{
			type = "Label",
			text = TSMAPI.Design:GetInlineColor("category")..L["Examples"].."|r",
			relativeWidth = 1,
		},
		{
			type = "Label",
			text = "20g50s",
			relativeWidth = 1,
		},
		{
			type = "Label",
			text = "120% crafting",
			relativeWidth = 1,
		},
		{
			type = "Label",
			text = "100% vendor + 5g",
			relativeWidth = 1,
		},
		{
			type = "Label",
			text = "max(150% dbmarket, 1.2 * crafting)",
			relativeWidth = 1,
		},
		{
			type = "Label",
			text = "max(vendor, 120% crafting)",
			relativeWidth = 1,
		},
	}
	
	TSMAPI:BuildPage(container, page)
	
	return frame
end

local function FormatCopperCustomPrice(value)
	value = gsub(value, TSMAPI:StrEscape(TSM.GOLD_TEXT), "g")
	value = gsub(value, TSMAPI:StrEscape(TSM.SILVER_TEXT), "s")
	value = gsub(value, TSMAPI:StrEscape(TSM.COPPER_TEXT), "c")
	local goldPart = select(3, strfind(value, "([0-9]+g)"))
	local silverPart = select(3, strfind(value, "([0-9]+s)"))
	local copperPart = select(3, strfind(value, "([0-9]+c)"))
	if copperPart then
		value = gsub(value, copperPart, gsub(copperPart, "c", TSM.COPPER_TEXT))
	end
	if silverPart then
		value = gsub(value, silverPart, gsub(silverPart, "s", TSM.SILVER_TEXT))
	end
	if goldPart then
		value = gsub(value, goldPart, gsub(goldPart, "g", TSM.GOLD_TEXT))
	end
	return value
end

local function AddTooltip(widget, text, title)
	if not text then return end
	widget:SetCallback("OnEnter", function(self)
			GameTooltip:SetOwner(self.frame, "ANCHOR_NONE")
			GameTooltip:SetPoint("BOTTOM", self.frame, "TOP")
			if title then
				GameTooltip:SetText(title, 1, .82, 0, 1)
			end
			if type(text) == "number" then
				GameTooltip:SetHyperlink("item:" .. text)
			elseif tonumber(text) then
				GameTooltip:SetHyperlink("enchant:"..text)
			elseif type(text) == "string" and (strfind(text, "item:")) then
				TSMAPI:SafeTooltipLink(text)
			else
				GameTooltip:AddLine(text, 1, 1, 1, 1)
			end
			GameTooltip:Show()
		end)
	widget:SetCallback("OnLeave", function()
			-- BattlePetTooltip:Hide()
			GameTooltip:ClearLines()
			GameTooltip:Hide()
		end)
end

local function CreateContainer(cType, parent, args)
	local container = AceGUI:Create(cType)
	if not container then return end
	container:SetLayout(args.layout)
	if args.title then container:SetTitle(args.title) end
	container:SetRelativeWidth(args.relativeWidth or 1)
	container:SetFullHeight(args.fullHeight)
	parent:AddChild(container)
	return container
end

local function CreateWidget(wType, parent, args)
	local widget = AceGUI:Create(wType)
	if args.settingInfo then
		args.value = args.value or args.settingInfo[1][args.settingInfo[2]]
		if args.acceptCustom then
			if tonumber(args.value) then
				args.value = TSMAPI:FormatTextMoney(args.value)
			elseif args.value then
				args.value = FormatCopperCustomPrice(args.value)
			end
		end
		local oldCallback = args.callback
		args.callback = function(...)
			local value = select(3, ...)
			if type(value) == "string" then value = value:trim() end
			if args.multiselect then
				local key = value
				value = select(4, ...)
				args.settingInfo[1][args.settingInfo[2]][key] = value
			else
				args.settingInfo[1][args.settingInfo[2]] = value
			end
			if oldCallback then oldCallback(...) end
		end
	end
	if args.text then widget:SetText(args.text) end
	if args.label then widget:SetLabel(args.label) end
	if args.width then
		widget:SetWidth(args.width)
	elseif args.relativeWidth then
		if args.relativeWidth == 1 then
			widget:SetFullWidth(true)
		else
			widget:SetRelativeWidth(args.relativeWidth)
		end
	end
	if args.height then widget:SetHeight(args.height) end
	if widget.SetDisabled then widget:SetDisabled(args.disabled) end
	AddTooltip(widget, args.tooltip, args.label)
	parent:AddChild(widget)
	return widget
end

local Add = {
	InlineGroup = function(parent, args)
		local container = CreateContainer("TSMInlineGroup", parent, args)
		container:HideTitle(not args.title)
		container:HideBorder(args.noBorder)
		container:SetBackdrop(args.backdrop)
		return container
	end,
		
	SimpleGroup = function(parent, args)
		local container = CreateContainer("TSMSimpleGroup", parent, args)
		if args.height then container:SetHeight(args.height) end
		return container
	end,
		
	ScrollFrame = function(parent, args)
		return CreateContainer("TSMScrollFrame", parent, args)
	end,
		
	Image = function(parent, args)
		local image = CreateWidget("TSMImage", parent, args)
		image:SetImage(args.image)
		image:SetSizeRatio(args.sizeRatio)
		return image
	end,
		
	Label = function(parent, args)
		local labelWidget = CreateWidget("TSMLabel", parent, args)
		labelWidget:SetColor(args.colorRed, args.colorGreen, args.colorBlue)
		return labelWidget
	end,
		
	MultiLabel = function(parent, args)
		local labelWidget = CreateWidget("TSMMultiLabel", parent, args)
		labelWidget:SetLabels(args.labelInfo)
		return labelWidget
	end,
		
	InteractiveLabel = function(parent, args)
		local iLabelWidget = CreateWidget("TSMInteractiveLabel", parent, args)
		iLabelWidget:SetCallback("OnClick", args.callback)
		return iLabelWidget
	end,
		
	Button = function(parent, args)
		local buttonWidget = CreateWidget("TSMButton", parent, args)
		buttonWidget:SetCallback("OnClick", args.callback)
		return buttonWidget
	end,
		
	GroupItemList = function(parent, args)
		local groupItemList = CreateWidget("TSMGroupItemList", parent, args)
		groupItemList:SetIgnoreVisible(args.showIgnore)
		groupItemList:SetTitle("left", args.leftTitle)
		groupItemList:SetTitle("right", args.rightTitle)
		groupItemList:SetListCallback(args.listCallback)
		groupItemList:SetCallback("OnAddClicked", args.onAdd)
		groupItemList:SetCallback("OnRemoveClicked", args.onRemove)
		return groupItemList
	end,
		
	MacroButton = function(parent, args)
		local macroButtonWidget = CreateWidget("TSMMacroButton", parent, args)
		macroButtonWidget.frame:SetAttribute("type", "macro")
		macroButtonWidget.frame:SetAttribute("macrotext", args.macroText)
		return macroButtonWidget
	end,
	
	EditBox = function(parent, args)
		local editBoxWidget = CreateWidget("TSMEditBox", parent, args)
		editBoxWidget:SetText(args.value)
		editBoxWidget:DisableButton(args.onTextChanged)
		editBoxWidget:SetAutoComplete(args.autoComplete)
		local function callback(self, event, value)
			if args.acceptCustom then
				local badPriceSource = type(args.acceptCustom) == "string" and strlower(args.acceptCustom)
				local customPrice, err = TSMAPI:ParseCustomPrice(value, badPriceSource)
				if customPrice then
					self:SetText(FormatCopperCustomPrice(value))
					self:ClearFocus()
					args.callback(self, event, value)
				else
					TSM:Print(L["Invalid custom price."].." "..err)
					self:SetFocus()
				end
			else
				args.callback(self, event, value)
			end
		end
		editBoxWidget:SetCallback(args.onTextChanged and "OnTextChanged" or "OnEnterPressed", callback)
		if args.acceptCustom then
			customPriceFrame = customPriceFrame or CreateCustomPriceFrame()
			editBoxWidget:SetCallback("OnEditFocusGained", function() customPriceFrame:Show() end)
			editBoxWidget:SetCallback("OnEditFocusLost", function() customPriceFrame:Hide() end)
		end
		return editBoxWidget
	end,
	
	GroupBox = function(parent, args)
		local groupBoxWidget = CreateWidget("TSMGroupBox", parent, args)
		groupBoxWidget:SetText(args.value)
		groupBoxWidget:SetCallback("OnValueChanged", args.callback)
		return groupBoxWidget
	end,
		
	CheckBox = function(parent, args)
		local checkBoxWidget = CreateWidget("TSMCheckBox", parent, args)
		checkBoxWidget:SetType(args.cbType or "checkbox")
		checkBoxWidget:SetValue(args.value)
		if args.label then checkBoxWidget:SetLabel(args.label) end
		if not args.width and not args.relativeWidth then
			checkBoxWidget:SetRelativeWidth(0.5)
		end
		checkBoxWidget:SetCallback("OnValueChanged", args.callback)
		return checkBoxWidget
	end,
		
	Slider = function(parent, args)
		local sliderWidget = CreateWidget("TSMSlider", parent, args)
		sliderWidget:SetValue(args.value)
		sliderWidget:SetSliderValues(args.min, args.max, args.step)
		sliderWidget:SetIsPercent(args.isPercent)
		sliderWidget:SetCallback("OnValueChanged", args.callback)
		return sliderWidget
	end,
		
	Icon = function(parent, args)
		local iconWidget = CreateWidget("Icon", parent, args)
		iconWidget:SetImage(args.image)
		iconWidget:SetImageSize(args.imageWidth, args.imageHeight)
		iconWidget:SetCallback("OnClick", args.callback)
		return iconWidget
	end,
		
	Dropdown = function(parent, args)
		local dropdownWidget = CreateWidget("TSMDropdown", parent, args)
		dropdownWidget:SetList(args.list, args.order)
		dropdownWidget:SetMultiselect(args.multiselect)
		if type(args.value) == "table" then
			for name, value in pairs(args.value) do
				dropdownWidget:SetItemValue(name, value)
			end
		else
			dropdownWidget:SetValue(args.value)
		end
		dropdownWidget:SetCallback("OnValueChanged", args.callback)
		return dropdownWidget
	end,
		
	ColorPicker = function(parent, args)
		local colorPicker = CreateWidget("TSMColorPicker", parent, args)
		colorPicker:SetHasAlpha(args.hasAlpha)
		if type(args.value) == "table" then
			colorPicker:SetColor(unpack(args.value))
		end
		colorPicker:SetCallback("OnValueChanged", args.callback)
		colorPicker:SetCallback("OnValueConfirmed", args.callback)
		return colorPicker
	end,
		
	Spacer = function(parent, args)
		args.quantity = args.quantity or 1
		for i=1, args.quantity do
			local spacer = parent:Add({type="Label", text=" ", relativeWidth=1})
		end
	end,
		
	HeadingLine = function(parent, args)
		local heading = AceGUI:Create("Heading")
		heading:SetText("")
		heading:SetRelativeWidth(args.relativeWidth or 1)
		parent:AddChild(heading)
	end,
}

-- creates a widget or container as detailed in the passed table (iTable) and adds it as a child of the passed parent
function lib.AddGUIElement(parent, iTable)
	assert(Add[iTable.type], "Invalid Widget or Container Type: "..iTable.type)
	return Add[iTable.type](parent, iTable)
end

-- goes through a page-table and draws out all the containers and widgets for that page
function TSMAPI:BuildPage(oContainer, oPageTable, noPause)
	local function recursive(container, pageTable)
		for _, data in pairs(pageTable) do
			local parentElement = container:Add(data)
			if data.children then
				parentElement:PauseLayout()
				-- yay recursive function calls!
				recursive(parentElement, data.children)
				parentElement:ResumeLayout()
				parentElement:DoLayout()
			end
		end
	end
	if not oContainer.Add then
		local container = AceGUI:Create("TSMSimpleGroup")
		container:SetLayout("fill")
		container:SetFullWidth(true)
		container:SetFullHeight(true)
		oContainer:AddChild(container)
		oContainer = container
	end
	if not noPause then
		oContainer:PauseLayout()
		recursive(oContainer, oPageTable)
		oContainer:ResumeLayout()
		oContainer:DoLayout()
	else
		recursive(oContainer, oPageTable)
	end
end