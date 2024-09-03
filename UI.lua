---@type string
local ADDON_NAME = ...
---@class Internal
local Internal = select(2, ...)

local selectedAreaPoiID = nil
local selectedDifficultyID = nil

---@class RacingLeaderboardFrameMixin: Button
---@field Rank FontString
---@field Name FontString
---@field Score FontString
RacingLeaderboardEntryMixin = {}
function RacingLeaderboardEntryMixin:Initialize(data)
    self.Rank:SetText(data.rank)
    self.Name:SetText(data.name)
    self.Score:SetText(data.score)
end

---@class RacingLeaderboardFrameMixin: Frame, DefaultPanelMixin
---@field RaceDropdown DropDownMenu
---@field DifficultyDropdown DropDownMenu
---@field ScrollBox Frame
---@field ScrollBar Frame
RacingLeaderboardFrameMixin = {}
function RacingLeaderboardFrameMixin:OnLoad()
	tinsert(UISpecialFrames, self:GetName());
	self:RegisterForDrag("LeftButton");
    self:SetTitle(LEADERBOARD)

	local view = CreateScrollBoxListLinearView();

	local function Initializer(button, elementData)
		button:Initialize(elementData);
	end
    view:SetElementInitializer("RacingLeaderboardEntryTemplate", Initializer)

	local topPadding, bottomPadding, leftPadding, rightPadding = 10, 10, 10, 10;
	local elementSpacing = 3;
	view:SetPadding(topPadding, bottomPadding, leftPadding, rightPadding, elementSpacing);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

    self:RegisterEvent("SUPER_TRACKING_CHANGED")
end
function RacingLeaderboardFrameMixin:OnShow()
    self.RaceDropdown:SetWidth(220)
    self.RaceDropdown:SetupMenu(function(dropdown, rootDescription)
        function IsSelected(areaPoiID)
            return areaPoiID == selectedAreaPoiID
        end
        function SetSelected(areaPoiID)
            selectedAreaPoiID = areaPoiID
            self.DifficultyDropdown:GenerateMenu()
            self:Update()
        end

        local uiMapID
        for _,poi in Internal.IteratePOIs() do
            if not selectedAreaPoiID then
                selectedAreaPoiID = poi.areaPoiID
            end

            if uiMapID ~= poi.uiMapID then
                local map = C_Map.GetMapInfo(poi.uiMapID)
                rootDescription:CreateTitle(map.name)
                uiMapID = poi.uiMapID
            end

            rootDescription:CreateRadio(poi.name, IsSelected, SetSelected, poi.areaPoiID);
		end
	end)
    self.DifficultyDropdown:SetupMenu(function(dropdown, rootDescription)
        function IsSelected(difficultyID)
            return difficultyID == selectedDifficultyID
        end
        function SetSelected(difficultyID)
            selectedDifficultyID = difficultyID
            self:Update()
        end
        for _,difficulty in Internal.IterateDifficulties(selectedAreaPoiID) do
            if not selectedDifficultyID then
                selectedDifficultyID = difficulty.id
            end

            rootDescription:CreateRadio(difficulty.name, IsSelected, SetSelected, difficulty.id);
		end
	end)

    self:Update()
end
function RacingLeaderboardFrameMixin:OnDragStart()
    self:StartMoving()
end
function RacingLeaderboardFrameMixin:OnDragStop()
    self:StopMovingOrSizing()
end
function RacingLeaderboardFrameMixin:OnEvent()
    self:UpdateTrackButton()
end
function RacingLeaderboardFrameMixin:GetSelection()
    return selectedAreaPoiID, selectedDifficultyID
end
function RacingLeaderboardFrameMixin:SetSelection(areaPoiID, difficultyID)
    selectedAreaPoiID = areaPoiID
    selectedDifficultyID = difficultyID

    self.DifficultyDropdown:GenerateMenu()
    self:Update()
end
function RacingLeaderboardFrameMixin:SuperTrack()
    if not self:IsSuperTracked() and selectedAreaPoiID then
        C_SuperTrack.SetSuperTrackedMapPin(Enum.SuperTrackingMapPinType.AreaPOI, selectedAreaPoiID)
    else
        C_SuperTrack.ClearSuperTrackedMapPin()
    end
    self:UpdateTrackButton()
end
function RacingLeaderboardFrameMixin:IsSuperTracked()
    if not selectedAreaPoiID then
        return false
    end

    local type, id = C_SuperTrack.GetSuperTrackedMapPin()
    return type == Enum.SuperTrackingMapPinType.AreaPOI and id == selectedAreaPoiID
end
function RacingLeaderboardFrameMixin:Update()
    local race = Internal.GetRaceByPOI(self:GetSelection())
    if not race then
        return
    end
	self.ScrollBox:SetDataProvider(CreateDataProvider(Internal.GetCharactersForRace(race.id)), ScrollBoxConstants.RetainScrollPosition);
    self:UpdateTrackButton()
end
function RacingLeaderboardFrameMixin:UpdateTrackButton()
    self.TrackButton:SetNormalAtlas(self:IsSuperTracked() and "Waypoint-MapPin-Tracked" or "Waypoint-MapPin-Untracked")
    self.TrackButton:SetPushedAtlas(self:IsSuperTracked() and "Waypoint-MapPin-Untracked" or "Waypoint-MapPin-Tracked")
end

function RacingLeaderboard_Toggle()
    RacingLeaderboardFrame:SetShown(not RacingLeaderboardFrame:IsShown());
end
