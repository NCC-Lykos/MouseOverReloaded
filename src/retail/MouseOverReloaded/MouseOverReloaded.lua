-- MouseOver Reloaded - Retail Edition (Auto-Macro on Insert)
MouseOver = LibStub("AceAddon-3.0"):NewAddon("MouseOver", "AceConsole-3.0")

local main_frame = CreateFrame("Frame", "MouseOverFrame", UIParent, "BackdropTemplate")
local options = {}

-- Utility: create/update macro by name
local function CreateOrUpdateMacro(name)
    local macroText = generateMacroText(name)
    local icon = "INV_MISC_QUESTIONMARK"
    local macroId = GetMacroIndexByName(name)
    if macroId and macroId > 0 then
        EditMacro(macroId, name, icon, macroText, 1, 1)
        MouseOver:Print("Updated macro for " .. name)
    else
        CreateMacro(name, icon, macroText, 1, 1)
        MouseOver:Print("Macro created for " .. name)
    end
end

-- Main window and logic
do
    MouseOver.main_frame = main_frame
    main_frame:SetSize(480, 300)
    main_frame:SetPoint("CENTER")
    main_frame:SetMovable(true)
    main_frame:EnableMouse(true)
    main_frame:RegisterForDrag("LeftButton")
    main_frame:SetScript("OnDragStart", main_frame.StartMoving)
    main_frame:SetScript("OnDragStop", main_frame.StopMovingOrSizing)
    main_frame:Hide()
    main_frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    main_frame:SetBackdropColor(0,0,0,0.8)

    -- Title
    local title = main_frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -12)
    title:SetText("MouseOver Reloaded")

    -- Macro Mode Section (Top 3, mutually exclusive)
    local sectionY = -38
    local function CreateSectionCheck(label, y)
        local btn = CreateFrame("CheckButton", nil, main_frame, "ChatConfigCheckButtonTemplate")
        btn:SetPoint("TOPLEFT", 24, y)
        btn:SetWidth(22)
        btn:SetHeight(22)
        local lbl = main_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lbl:SetFont("Fonts\\FRIZQT__.TTF", 15)
        lbl:SetTextColor(1, 0.82, 0, 1)
        lbl:SetText(label)
        lbl:SetPoint("LEFT", btn, "RIGHT", 7, 0)
        return btn
    end

    main_frame.option1 = CreateSectionCheck("Mouseover macro.", sectionY)
    main_frame.option2 = CreateSectionCheck("At cursor macro.", sectionY-28)
    main_frame.option3 = CreateSectionCheck("At player macro.", sectionY-56)

    -- Mutually exclusive logic
    local function Exclusive3(a, b, c)
        a:SetScript("OnClick", function(self)
            if self:GetChecked() then
                b:SetChecked(false)
                c:SetChecked(false)
            elseif not b:GetChecked() and not c:GetChecked() then
                self:SetChecked(true)
            end
        end)
    end
    Exclusive3(main_frame.option1, main_frame.option2, main_frame.option3)
    Exclusive3(main_frame.option2, main_frame.option1, main_frame.option3)
    Exclusive3(main_frame.option3, main_frame.option1, main_frame.option2)
    main_frame.option1:SetChecked(true)

    -- Divider 1
    local divider1 = main_frame:CreateTexture(nil, "BACKGROUND")
    divider1:SetColorTexture(0.8, 0.8, 0.8, 0.4)
    divider1:SetSize(410, 2)
    divider1:SetPoint("TOPLEFT", 20, sectionY-72)

    -- Target Modifiers Section
    local tmodLabel = main_frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    tmodLabel:SetFont("Fonts\\FRIZQT__.TTF", 13)
    tmodLabel:SetText("Target Modifiers")
    tmodLabel:SetTextColor(1, 0.8, 0.3, 1)
    tmodLabel:SetPoint("TOPLEFT", 26, sectionY-86)

    main_frame.option4 = CreateSectionCheck("harm", sectionY-108)
    main_frame.option5 = CreateSectionCheck("help", sectionY-136)
    main_frame.option6 = CreateSectionCheck("dead", sectionY-164)
    main_frame.option7 = CreateSectionCheck("nodead", sectionY-192)

    -- Divider 2
    local divider2 = main_frame:CreateTexture(nil, "BACKGROUND")
    divider2:SetColorTexture(0.8, 0.8, 0.8, 0.4)
    divider2:SetSize(410, 2)
    divider2:SetPoint("TOPLEFT", 20, sectionY-206)

    -- Failover Section
    local failLabel = main_frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    failLabel:SetFont("Fonts\\FRIZQT__.TTF", 13)
    failLabel:SetText("Failover (Default to)")
    failLabel:SetTextColor(0.3, 1, 0.6, 1)
    failLabel:SetPoint("TOPLEFT", 26, sectionY-220)
    main_frame.option8 = CreateSectionCheck("Regular Behavior", sectionY-242)
    main_frame.option9 = CreateSectionCheck("Focus", sectionY-270)
    main_frame.option10 = CreateSectionCheck("Mouseover", sectionY-298)
    main_frame.option11 = CreateSectionCheck("Player", sectionY-326)
    main_frame.option12 = CreateSectionCheck("Cursor", sectionY-354)

    -- Drop/EditBox Area
    local dropBox = CreateFrame("EditBox", nil, main_frame, "InputBoxTemplate")
    main_frame.dropBox = dropBox
    dropBox:SetSize(320, 32)
    dropBox:SetPoint("TOPRIGHT", main_frame, "TOPRIGHT", -30, -40)
    dropBox:SetAutoFocus(false)
    dropBox:SetFontObject(ChatFontNormal)
    dropBox:SetMultiLine(false)
    dropBox:SetText("")
    dropBox:Show()

    local dropBoxLabel = main_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropBoxLabel:SetPoint("BOTTOMLEFT", dropBox, "TOPLEFT", 2, 3)
    dropBoxLabel:SetText("|cff00ff00Drop spell here or Shift+Click spell/item|r")
    dropBoxLabel:SetFont("Fonts\\FRIZQT__.TTF", 13)

    -- Accept Shift+Click links
    hooksecurefunc("ChatEdit_InsertLink", function(link)
        if dropBox:HasFocus() then
            dropBox:Insert(link)
        end
    end)

    -- Accept drops (spell, item, etc.)
    dropBox:SetScript("OnReceiveDrag", function(self)
        local type, id = GetCursorInfo()
        if type == "spell" and id then
            local name = C_SpellBook.GetSpellBookItemName and C_SpellBook.GetSpellBookItemName(id, BOOKTYPE_SPELL)
                or GetSpellBookItemName and GetSpellBookItemName(id, BOOKTYPE_SPELL)
            if not name then
                local spellName = GetSpellInfo and GetSpellInfo(id)
                if spellName then name = spellName end
            end
            if name then
                self:SetText(name)
            end
            ClearCursor()
        elseif type == "item" and id then
            local name = GetItemInfo(id)
            if name then self:SetText(name) end
            ClearCursor()
        end
    end)

    -- OnTextChanged: create macro immediately, then clear
    dropBox:SetScript("OnTextChanged", function(self, userInput)
        local text = self:GetText()
        -- Clean up links: extract name if a link is pasted in
        text = text and text:match("%[(.-)%]") or text
        if text and text ~= "" then
            -- Only react if change was not by user typing (e.g. from Shift+Click or drag)
            if not userInput then
                CreateOrUpdateMacro(text)
                self:SetText("") -- Clear after macro
            end
        end
    end)

    -- Also allow manual entry via Enter
    dropBox:SetScript("OnEnterPressed", function(self)
        local text = self:GetText()
        text = text and text:match("%[(.-)%]") or text
        if text and text ~= "" then
            CreateOrUpdateMacro(text)
            self:SetText("")
        end
        self:ClearFocus()
    end)

    dropBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    -- Close button
    main_frame.closeButton = CreateFrame("Button", nil, main_frame, "UIPanelButtonTemplate")
    main_frame.closeButton:SetSize(80, 30)
    main_frame.closeButton:SetPoint("BOTTOMRIGHT", main_frame, "BOTTOMRIGHT", -14, 14)
    main_frame.closeButton:SetText("Close")
    main_frame.closeButton:SetScript("OnClick", function() main_frame:Hide() end)

    -- Author text
    local authorString = main_frame:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    authorString:SetText("og by Notviable-Draenor - Updated by phys1ks")
    authorString:SetPoint("BOTTOMLEFT", main_frame, "BOTTOMLEFT", 12, 14)
end

-- SLASH COMMANDS
MouseOver:RegisterChatCommand("mo", "SlashFunc")
MouseOver:RegisterChatCommand("mouseover", "SlashFunc")

function MouseOver:OnInitialize()
    MouseOver:Print("Loaded.")
end

function MouseOver:SlashFunc()
    if main_frame:IsShown() then
        main_frame:Hide()
    else
        if SpellBookFrame and not SpellBookFrame:IsShown() then
            SpellBookFrame:Show()
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