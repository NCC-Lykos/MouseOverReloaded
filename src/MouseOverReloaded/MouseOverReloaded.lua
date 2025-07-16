-- MouseOver Addon, authored by Notviable-Draenor, updated by phys1ks

MouseOver = LibStub("AceAddon-3.0"):NewAddon("MouseOver", "AceConsole-3.0")

local main_frame = CreateFrame("Frame", "MouseOverFrame", UIParent)
local options = {}

-- GUI Setup
do
    MouseOver.main_frame = main_frame
    main_frame:SetWidth(430)
    main_frame:SetHeight(450)
    main_frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    main_frame:SetMovable(true)
    main_frame:EnableMouse(true)
    main_frame:RegisterForDrag("LeftButton")
    main_frame:SetScript("OnMouseDown", main_frame.StartMoving)
    main_frame:SetScript("OnMouseUp", main_frame.StopMovingOrSizing)
    main_frame:Hide()

    -- Background
    main_frame.background = main_frame:CreateTexture(nil, "BACKGROUND")
    main_frame.background:SetAllPoints()
    main_frame.background:SetColorTexture(0, 0, 0, 0.7)

    -- Title
    main_frame.panelString = main_frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    main_frame.panelString:SetText("MouseOver")
    main_frame.panelString:SetTextColor(1, 0.82, 0, 1)
    main_frame.panelString:SetPoint("TOP", main_frame, "TOP", 0, -15)

    ------------- Main Macro Target Section -------------
    local sectionY = -45
    local function CreateSectionCheck(label, fontSize, yPad)
        local btn = CreateFrame("CheckButton", nil, main_frame, "ChatConfigCheckButtonTemplate")
        btn:SetPoint("TOPLEFT", main_frame, "TOPLEFT", 30, sectionY)
        btn:SetWidth(22)
        btn:SetHeight(22)
        local lbl = main_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lbl:SetFont("Fonts\\FRIZQT__.TTF", fontSize or 17)
        lbl:SetTextColor(1, 0.82, 0, 1)
        lbl:SetText(label)
        lbl:SetPoint("LEFT", btn, "RIGHT", 8, 0)
        sectionY = sectionY - (yPad or 28)
        return btn, lbl
    end

    main_frame.option1, main_frame.option1String = CreateSectionCheck("Mouseover macro.", 18)
    main_frame.option2, main_frame.option2String = CreateSectionCheck("At cursor macro.", 18)
    main_frame.option3, main_frame.option3String = CreateSectionCheck("At player macro.", 18)

    -- Mutually exclusive logic for top 3 checkboxes
    local function Exclusive3(a, b, c)
        a:SetScript("OnClick", function(self)
            if self:GetChecked() then
                b:SetChecked(false)
                c:SetChecked(false)
            elseif not b:GetChecked() and not c:GetChecked() then
                self:SetChecked(true) -- Always have one checked
            end
        end)
    end
    Exclusive3(main_frame.option1, main_frame.option2, main_frame.option3)
    Exclusive3(main_frame.option2, main_frame.option1, main_frame.option3)
    Exclusive3(main_frame.option3, main_frame.option1, main_frame.option2)
    main_frame.option1:SetChecked(true)

    -- Divider 1
    main_frame.divider1 = main_frame:CreateTexture(nil, "BACKGROUND")
    main_frame.divider1:SetColorTexture(0.8, 0.8, 0.8, 0.4)
    main_frame.divider1:SetWidth(380)
    main_frame.divider1:SetHeight(2)
    main_frame.divider1:SetPoint("TOPLEFT", main_frame, "TOPLEFT", 25, sectionY + 5)

    ------------- Target Modifiers Section -------------
    local targetLabel = main_frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    targetLabel:SetFont("Fonts\\FRIZQT__.TTF", 14)
    targetLabel:SetText("Target Modifiers")
    targetLabel:SetTextColor(1, 0.8, 0.3, 1)
    targetLabel:SetPoint("TOPLEFT", main_frame, "TOPLEFT", 30, sectionY - 5)
    sectionY = sectionY - 23

    main_frame.option4, main_frame.option4String = CreateSectionCheck("harm", 16)
    main_frame.option5, main_frame.option5String = CreateSectionCheck("help", 16)
    main_frame.option6, main_frame.option6String = CreateSectionCheck("dead", 16)
    main_frame.option7, main_frame.option7String = CreateSectionCheck("nodead", 16)

    -- Divider 2
    main_frame.divider2 = main_frame:CreateTexture(nil, "BACKGROUND")
    main_frame.divider2:SetColorTexture(0.8, 0.8, 0.8, 0.4)
    main_frame.divider2:SetWidth(380)
    main_frame.divider2:SetHeight(2)
    main_frame.divider2:SetPoint("TOPLEFT", main_frame, "TOPLEFT", 25, sectionY + 5)

    ------------- Failover (Default to) Section -------------
    local failoverLabel = main_frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    failoverLabel:SetFont("Fonts\\FRIZQT__.TTF", 14)
    failoverLabel:SetText("Failover (Default to)")
    failoverLabel:SetTextColor(0.3, 1, 0.6, 1)
    failoverLabel:SetPoint("TOPLEFT", main_frame, "TOPLEFT", 30, sectionY - 8)
    sectionY = sectionY - 28

    local function CreateFailoverCheck(label, fontSize)
        local btn = CreateFrame("CheckButton", nil, main_frame, "ChatConfigCheckButtonTemplate")
        btn:SetPoint("TOPLEFT", main_frame, "TOPLEFT", 30, sectionY)
        btn:SetWidth(22)
        btn:SetHeight(22)
        local lbl = main_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lbl:SetFont("Fonts\\FRIZQT__.TTF", fontSize or 15)
        lbl:SetText(label)
        lbl:SetPoint("LEFT", btn, "RIGHT", 8, 0)
        sectionY = sectionY - 26
        return btn, lbl
    end

    main_frame.option8, main_frame.option8String = CreateFailoverCheck("Regular Behavior", 15)
    main_frame.option9, main_frame.option9String = CreateFailoverCheck("Focus", 15)
    main_frame.option10, main_frame.option10String = CreateFailoverCheck("Mouseover", 15)
    main_frame.option11, main_frame.option11String = CreateFailoverCheck("Player", 15)
    main_frame.option12, main_frame.option12String = CreateFailoverCheck("Cursor", 15)

    -- Close button
    main_frame.closeButton = CreateFrame("Button", nil, main_frame, "UIPanelButtonTemplate")
    main_frame.closeButton:SetHeight(30)
    main_frame.closeButton:SetWidth(80)
    main_frame.closeButton:SetPoint("BOTTOMRIGHT", main_frame, "BOTTOMRIGHT", -14, 14)
    main_frame.closeButton:SetText("Close")
    main_frame.closeButton:SetScript("OnClick", function() main_frame:Hide() end)

    -- Author text
    main_frame.authorString = main_frame:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    main_frame.authorString:SetText("og by Notviable-Draenor - Updated by Lykos")
    main_frame.authorString:SetPoint("BOTTOMLEFT", main_frame, "BOTTOMLEFT", 12, 14)
end

-- Slash command registering
MouseOver:RegisterChatCommand("mo", "SlashFunc")
MouseOver:RegisterChatCommand("mouseover", "SlashFunc")

function MouseOver:OnInitialize()
    MouseOver:Print("Loaded.")
end

function MouseOver:SlashFunc()
    if main_frame:IsShown() then
        main_frame:Hide()
    else
        if MacroFrame and MacroFrame:IsShown() then MacroFrame:Hide() end
        if SpellBookFrame and not SpellBookFrame:IsShown() then
            SpellBookFrame:Show()
            SpellBookFrame:ClearAllPoints()
            SpellBookFrame:SetPoint("LEFT", UIParent, "LEFT", 30, 100)
        end
        main_frame:Show()
    end
end

function generateMacroText(text)
    local outPutString = "#showtooltip " .. text .. "\n/cast "
    table.wipe(options)
    if main_frame.option1:GetChecked() then table.insert(options, "@mouseover") end
    if main_frame.option2:GetChecked() then table.insert(options, "@cursor") end
    if main_frame.option3:GetChecked() then table.insert(options, "@player") end
    if main_frame.option4:GetChecked() then table.insert(options, "harm") end
    if main_frame.option5:GetChecked() then table.insert(options, "help") end
    if main_frame.option6:GetChecked() then table.insert(options, "dead") end
    if main_frame.option7:GetChecked() then table.insert(options, "nodead") end

    if #options > 0 then
        outPutString = outPutString .. "[" .. table.concat(options, ",") .. "]"
    end

    if main_frame.option8:GetChecked() then outPutString = outPutString .. "[]" end
    if main_frame.option9:GetChecked() then outPutString = outPutString .. "[@focus]" end
    if main_frame.option10:GetChecked() then outPutString = outPutString .. "[@mouseover]" end
    if main_frame.option11:GetChecked() then outPutString = outPutString .. "[@player]" end
    if main_frame.option12:GetChecked() then outPutString = outPutString .. "[@cursor]" end

    outPutString = outPutString .. " " .. text
    return outPutString
end

-- Apply scripts to all SpellButtons (Cataclysm/MoP: 12 visible per page)
for i = 1, 12 do
    local spellLoopVar = _G["SpellButton" .. i]
    if spellLoopVar then
        spellLoopVar:SetScript("OnMouseDown", function(self, button)
            local text = GetSpellBookItemName(SpellBook_GetSpellBookSlot(self), SpellBookFrame.bookType)
            if text and not InCombatLockdown() and main_frame:IsShown() and IsControlKeyDown() and button == "RightButton" then
                CreateMacro(text, "INV_MISC_QUESTIONMARK", generateMacroText(text), 1)
                MouseOver:Print("Macro created for " .. text)
            end
        end)
    end
end