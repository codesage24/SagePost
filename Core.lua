-- SavedVariables
SagePostDB = SagePostDB or {}

SagePost = {}

SagePost.Defaults = {
    activity = "Molten Core",
    difficulty = "Normal",
    customActivity = "",
    tanks = 1,
    healers = 1,
    dps = 3,
    notes = ""
}

function SagePost:InitDB()
    for k, v in pairs(self.Defaults) do
        if SagePostDB[k] == nil then
            SagePostDB[k] = v
        end
    end
end

function SagePost:GetActivityText()
    if SagePostDB.activity == "Custom" then
        return SagePostDB.customActivity ~= "" and SagePostDB.customActivity or "Custom Activity"
    end
    return SagePostDB.activity
end

function SagePost:BuildPost()
    local msg = string.format(
        "[LFM] %s | Tanks: %d Healers: %d DPS: %d",
        self:GetActivityText(),
        SagePostDB.tanks,
        SagePostDB.healers,
        SagePostDB.dps
    )

    if SagePostDB.notes ~= "" then
        msg = msg .. " | " .. SagePostDB.notes
    end

    -- Escape WoW chat control characters
    msg = msg:gsub("|", "||")

    return msg
end


-- Event bootstrap
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, _, addon)
    if addon == "SagePost" then
        SagePost:InitDB()
        SagePost:CreateUI()
    end
end)
