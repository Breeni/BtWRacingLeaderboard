---@type string
local ADDON_NAME = ...
---@class Internal
local Internal = select(2, ...)

---@class CharacterData
---@field name string
---@field realm string
---@field class string
---@field owned boolean
---@field verified boolean
---@field scores table<integer, integer>
---@field timestamps table<integer, integer>
---@field lastUpdated integer

---@class CharacterMixin
---@field t CharacterData
local CharacterMixin = {}
function CharacterMixin:GetName()
    return self.t.name
end
function CharacterMixin:GetRealm()
    return self.t.realm
end
function CharacterMixin:GetClass()
    return self.t.class
end
---@param raceID integer
---@return integer, integer, integer
function CharacterMixin:GetScore(raceID)
    local score = self.t.scores[raceID] or 0
    local timestamp = self.t.timestamps[raceID] or 0
    local rank = Internal.GetRaceRankForScore(raceID, score) or 0
    return score, rank, timestamp
end
function CharacterMixin:LastUpdated()
    return self.t.lastUpdated
end
function CharacterMixin:GetScores()
    return self.t.scores, self.t.timestamps
end
function CharacterMixin:UpdateScore(raceID, score, timestamp, verified)
    if not timestamp then
        timestamp = GetServerTime()
    end

    self.t.scores[raceID] = score
    self.t.timestamps[raceID] = timestamp
    self.t.lastUpdated = math.max(self.t.lastUpdated, timestamp)

    if verified ~= nil then
        self.t.verified = verified
    end
end

---@class PlayerMixin: CharacterMixin
local PlayerMixin = Mixin({}, CharacterMixin)
function PlayerMixin:GetName()
    return (UnitName("player"))
end
function PlayerMixin:GetRealm()
    return GetNormalizedRealmName()
end
function PlayerMixin:GetRace()
    return select(2, UnitRace("player"))
end
function PlayerMixin:GetClass()
    return select(2, UnitClass("player"))
end
---@param raceID integer
---@return integer, integer, integer
function PlayerMixin:GetScore(raceID)
    local currency = C_CurrencyInfo.GetCurrencyInfo(raceID)

    local score = currency and currency.quantity or 0
    local rank = Internal.GetRaceRankForScore(raceID, score) or 0
    local timestamp = self.t.timestamps[raceID] or 0

    return score, rank, timestamp
end
function PlayerMixin:UpdateScore(raceID, score, timestamp)
    CharacterMixin.UpdateScore(self, raceID, score, timestamp, true)
end

---@type table<string, CharacterMixin>
local Characters = {}

---@param realm string
---@param name string
---@return CharacterMixin | nil
function Internal.GetCharacter(name, realm)
    local key
    if realm == nil then
        key = name
    else
        key = name .. "-" .. realm
    end

    local result = Characters[key]
    if not result then
        ---@type CharacterData | nil
        local tbl = RacingLeaderboard_Characters[key]

        local playerName = UnitName("player")
        local playerRealm = GetNormalizedRealmName()
        local playerKey = playerName .. "-" .. playerRealm
        if playerKey == key then
            if not tbl then
                tbl = {
                    name = playerName,
                    realm = GetNormalizedRealmName(),
                    class = select(2, UnitClass("player")),
                    owned = true,
                    verified = true,
                    scores = {},
                    timestamps = {},
                    lastUpdated = 0,
                }
                RacingLeaderboard_Characters[key] = tbl
            end

            result = Mixin({}, PlayerMixin, { t = tbl })
        else
            if not tbl then
                return nil
            end

            result = Mixin({}, CharacterMixin, { t = tbl })
        end
        Characters[key] = result
    end

    return result
end
function Internal.GetPlayer()
    local result = Internal.GetCharacter(UnitName("player"), GetNormalizedRealmName())
    assert(result, "Failed to create player")
    return result
end
function Internal.AddCharacter(name, realm, class)
    local result = Internal.GetCharacter(name, realm)
    if not result then
        local key = name .. "-" .. realm
        local tbl = {
            name = name,
            realm = realm,
            class = class,
            owned = false,
            verified = true,
            scores = {},
            timestamps = {},
            lastUpdated = 0,
        }
        RacingLeaderboard_Characters[key] = tbl
        result = Internal.GetCharacter(name, realm)
    end
    return result
end
function Internal.RemoveCharacter(name, realm)
    local key
    if realm == nil then
        key = name
    else
        key = name .. "-" .. realm
    end

    RacingLeaderboard_Characters[key] = nil
    Characters[key] = nil
end

function Internal.UpdatePlayerScore(raceID, score, timestamp)
    local player = Internal.GetPlayer()
    if not timestamp then
        timestamp = GetServerTime()
    end

    -- Send guild alert for new personal best
    Internal.SendNewPersonalBest(raceID, score, timestamp, player:LastUpdated())
    player:UpdateScore(raceID, score, timestamp)
    RacingLeaderboardFrame:Update()
end

local icons = {
    "|A:challenges-medal-small-bronze:0:0:0:0|a",
    "|A:challenges-medal-small-silver:0:0:0:0|a",
    "|A:challenges-medal-small-gold:0:0:0:0|a"
};
local ranks = {
    CreateColor(255 / 255, 215 / 255, 0 / 255),
    CreateColor(192 / 255, 192 / 255, 192 / 255),
    CreateColor(205 / 255, 127 / 255, 50 / 255),
}
function Internal.GetCharactersForRace(raceID)
    local tbl = {}
    for _,character in pairs(RacingLeaderboard_Characters) do
        local character = Internal.GetCharacter(character.name, character.realm)
        if character then
            local color = C_ClassColor.GetClassColor(character:GetClass())
            local score, rank = character:GetScore(raceID)
            tbl[#tbl+1] = {
                name = string.format("%s - %s", color:WrapTextInColorCode(character:GetName()), character:GetRealm()),
                score = score == 0 and " - " or string.format("%s %.3f s", icons[rank] or "", score / 1000),
                order = score > 0 and score or  1/ 0
            }
        end
    end

    table.sort(tbl, function (a, b)
        if a.order == b.order then
            return a.name < b.name
        end

        return a.order < b.order
    end)
    for rank,item in ipairs(tbl) do
        local text = string.format("%d.", rank)
        local color = ranks[rank]
        item.rank = color and color:WrapTextInColorCode(text) or text
    end

    return tbl
end

EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(_, addonName)
    if addonName == ADDON_NAME then
        if not RacingLeaderboard_Characters then
            RacingLeaderboard_Characters = {}
        end
    end
end)
EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGIN", function()
    local player = Internal.GetPlayer() -- Create player object

    local tbl = player.t
    local scores = tbl.scores
    local timestamps = tbl.timestamps

    for _,race in Internal.IterateRaces() do
        local currency = C_CurrencyInfo.GetCurrencyInfo(race.currencyID)
        if currency and currency.quantity > 0 then
            if not scores[race.currencyID] then -- new score
                tbl.lastUpdated = GetServerTime()
            end

            scores[race.currencyID] = currency.quantity
            timestamps[race.currencyID] = timestamps[race.currencyID] or GetServerTime()
        end
    end
end)
