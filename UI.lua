function SagePost:CreateUI()
    local f = CreateFrame("Frame", "SagePostFrame", UIParent)
    f:SetSize(460, 520)
    f:SetPoint("CENTER")
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()

    self.Frame = f

    -- Close button (X)
    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -6, -6)

    -- Slash command
    SLASH_SAGEPOST1 = "/sp"
    SlashCmdList["SAGEPOST"] = function()
        if f:IsShown() then
            f:Hide()
        else
            f:Show()
        end
    end

    -- Title
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -14)
    title:SetText("SagePost")

    -------------------------------------------------
    -- DECLARE DROPDOWNS
    --------------------------------------------------
    local customBox
    local activityDropdown
    local difficultyDropdown

    --------------------------------------------------
    -- DEFINE ACTIVITY DROPDOWN
    --------------------------------------------------
    local activityLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    activityLabel:SetPoint("TOPLEFT", 40, -50)
    activityLabel:SetText("Activity")

    activityDropdown = CreateFrame("Frame", "SagePostActivityDropdown", f, "UIDropDownMenuTemplate")
    activityDropdown:SetPoint("TOPLEFT", activityLabel, "BOTTOMLEFT", -15, -6)
    UIDropDownMenu_SetWidth(activityDropdown, 140)

    --------------------------------------------------
    -- DEFINE DIFFICULTY DROPDOWN
    --------------------------------------------------
    local difficultyLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    difficultyLabel:SetPoint("TOPLEFT", 240, -50)
    difficultyLabel:SetText("Difficulty")

    difficultyDropdown = CreateFrame("Frame", "SagePostDifficultyDropdown", f, "UIDropDownMenuTemplate")
    difficultyDropdown:SetPoint("TOPLEFT", difficultyLabel, "BOTTOMLEFT", -15, -6)
    UIDropDownMenu_SetWidth(difficultyDropdown, 140)

    --------------------------------------------------
    -- INIT ACTIVITY DROPDOWN
    --------------------------------------------------
    UIDropDownMenu_Initialize(activityDropdown, function()
        for _, activity in ipairs(SagePost.Activities) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = activity
            info.func = function()
                UIDropDownMenu_SetSelectedValue(activityDropdown, activity)
                SagePostDB.activity = activity
                if activity == "Custom" then
                    customBox:Show()
                    for i = 1, customBox:GetNumRegions() do
                        local region = select(i, customBox:GetRegions())
                        if region:GetObjectType() == "Texture" then
                            region:Show()
                        end
                    end
                else
                    for i = 1, customBox:GetNumRegions() do
                        local region = select(i, customBox:GetRegions())
                        if region:GetObjectType() == "Texture" then
                            region:Hide()
                        end
                    end
                end
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    UIDropDownMenu_SetSelectedValue(activityDropdown, SagePostDB.activity)

    --------------------------------------------------
    -- INIT DIFFICULTY DROPDOWN
    --------------------------------------------------
    UIDropDownMenu_Initialize(difficultyDropdown, function()
        for _, difficulty in ipairs(SagePost.Difficulties) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = difficulty
            info.func = function()
                UIDropDownMenu_SetSelectedValue(difficultyDropdown, difficulty)
                SagePostDB.difficulty = difficulty
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    UIDropDownMenu_SetSelectedValue(difficultyDropdown, SagePostDB.difficulty)

    --------------------------------------------------
    -- CUSTOM EDIT BOX
    --------------------------------------------------
    customBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    customBox:SetSize(420, 22)
    customBox:SetPoint("TOPLEFT", activityDropdown, "BOTTOMLEFT", 20, -6)
    customBox:SetAutoFocus(false)
    customBox:SetTextInsets(6, 6, 3, 3)
    customBox:SetText(SagePostDB.customActivity)
    customBox:SetScript("OnTextChanged", function(self)
        SagePostDB.customActivity = self:GetText()
    end)
    customBox:SetShown(SagePostDB.activity == "Custom")

    --------------------------------------------------
    -- NUMBER BOX CONTROL
    --------------------------------------------------
    local function CreateNumberBox(labelText, key, x, y)
        local label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", f, "TOPLEFT", x, y)
        label:SetText(labelText)

        local box = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
        box:SetSize(36, 36)
        box:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -6)
        box:SetAutoFocus(false)
        box:SetNumeric(true)
        box:SetTextInsets(6, 6, 3, 3)
        box:SetJustifyH("CENTER")
        box:SetJustifyV("MIDDLE")
        box:SetText(SagePostDB[key])

        box:SetScript("OnTextChanged", function(self)
            local value = tonumber(self:GetText()) or 0
            if value < 0 then
                value = 0
            end
            if value > 40 then
                value = 40
            end
            SagePostDB[key] = value
            self:SetText(value)
        end)

        local minus = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        minus:SetSize(20, 20)
        minus:SetPoint("LEFT", box, "RIGHT", 4, 0)
        minus:SetText("-")
        minus:SetScript("OnClick", function()
            SagePostDB[key] = math.max(0, SagePostDB[key] - 1)
            box:SetText(SagePostDB[key])
        end)

        local plus = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        plus:SetSize(20, 20)
        plus:SetPoint("LEFT", minus, "RIGHT", 2, 0)
        plus:SetText("+")
        plus:SetScript("OnClick", function()
            SagePostDB[key] = math.min(40, SagePostDB[key] + 1)
            box:SetText(SagePostDB[key])
        end)
    end

    --------------------------------------------------
    -- ROLE INPUTS
    --------------------------------------------------
    local rolesY = -150
    CreateNumberBox("Tanks", "tanks", 20, rolesY)
    CreateNumberBox("Healers", "healers", 180, rolesY)
    CreateNumberBox("DPS", "dps", 340, rolesY)

    --------------------------------------------------
    -- NOTES BOX
    --------------------------------------------------
    local notesLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    notesLabel:SetPoint("TOPLEFT", 20, -300)
    notesLabel:SetText("Additional Notes / Reserved Loot")

    local notesBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    notesBox:SetSize(400, 90)
    notesBox:SetPoint("TOPLEFT", notesLabel, "BOTTOMLEFT", 0, -6)
    notesBox:SetMultiLine(true)
    notesBox:SetAutoFocus(false)
    notesBox:SetTextInsets(6, 6, 6, 6)
    notesBox:SetJustifyH("LEFT")
    notesBox:SetJustifyV("TOP")
    notesBox:SetText(SagePostDB.notes)

    notesBox:SetScript("OnTextChanged", function(self)
        SagePostDB.notes = self:GetText()
    end)

    --------------------------------------------------
    -- GENERATE BUTTON
    --------------------------------------------------
    local postBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    postBtn:SetSize(160, 32)
    postBtn:SetPoint("BOTTOM", 0, 20)
    postBtn:SetText("Generate LFG")

    postBtn:SetScript("OnClick", function()
        ChatFrame_OpenChat(SagePost:BuildPost())
    end)
end
