-- Create and update LDB launcher
---@type string
local ADDON_NAME = ...
---@class Internal
local Internal = select(2, ...)

local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)

local launcher = LDB:NewDataObject(ADDON_NAME, {
    type = "data source",
    label = ADDON_NAME,
    icon = [[Interface\ICONS\ability_dragonriding_upwardflap01]],
    OnClick = function(clickedframe, button)
        if button == "LeftButton" then
            RacingLeaderboard_Toggle()
        elseif button == "RightButton" then
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:SetText(ADDON_NAME, 1, 1, 1);
        tooltip:Show()
    end,
})

EventRegistry:RegisterCallback("ADDON_LOADED", function (_, addonName)
    if addonName == ADDON_NAME then
        if not RacingLeaderboard_LDBIcon then
            RacingLeaderboard_LDBIcon = {}
        end

        LDBIcon:Register(ADDON_NAME, launcher, RacingLeaderboard_LDBIcon)
    end
end)

function Internal.ShowMinimap()
    LDBIcon:Show(ADDON_NAME)
end
function Internal.HideMinimap()
    LDBIcon:Hide(ADDON_NAME)
end
