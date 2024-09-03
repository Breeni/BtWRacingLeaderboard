---@type string
local ADDON_NAME = ...
---@class Internal
local Internal = select(2, ...)

---@class Race
---@field name string
---@field id integer
---@field uiMapID integer
---@field areaPoiID integer
---@field difficultyID integer
---@field position Vector2DMixin

local INF = 1 / 0
local Difficulty = {
    Basic = 1,
    Advanced = 2,
    Reverse = 3,
};
local DifficultyNames = {
    [1] = "Basic" or "Basic",
    [2] = ADVANCED_LABEL or "Advanced",
    [3] = HUD_EDIT_MODE_SETTING_MICRO_MENU_ORDER_REVERSE or "Reverse",
}


---@class RaceDefinition
---@field currencyID integer
---@field uiMapID integer
---@field areaPoiID integer
---@field difficultyID integer
---@field rankTimers [integer, integer]
---@field achievementIDs [integer, integer, integer] | nil

---@type RaceDefinition[]
local races = { { -- Basin Bypass Basic
    currencyID = 2925,
    uiMapID = 2248,
    areaPoiID = 7795,
    difficultyID = Difficulty.Basic,
    rankTimers = { 58000, 63000, },
},
    { -- Basin Bypass Advanced
        currencyID = 2931,
        uiMapID = 2248,
        areaPoiID = 7795,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 54000, 57000, },
    },
    { -- Basin Bypass Reverse
        currencyID = 2937,
        uiMapID = 2248,
        areaPoiID = 7795,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 57000, 60000, },
    },
    { -- Dornogal Drift Basic
        currencyID = 2923,
        uiMapID = 2248,
        areaPoiID = 7793,
        difficultyID = Difficulty.Basic,
        rankTimers = { 48000, 53000, },
    },
    { -- Dornogal Drift Advanced
        currencyID = 2929,
        uiMapID = 2248,
        areaPoiID = 7793,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 43000, 46000, },
    },
    { -- Dornogal Drift Reverse
        currencyID = 2935,
        uiMapID = 2248,
        areaPoiID = 7793,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 43000, 46000, },
    },
    { -- Orecreg's Doglegs Basic
        currencyID = 2928,
        uiMapID = 2248,
        areaPoiID = 7798,
        difficultyID = Difficulty.Basic,
        rankTimers = { 65000, 70000, },
    },
    { -- Orecreg's Doglegs Advanced
        currencyID = 2934,
        uiMapID = 2248,
        areaPoiID = 7798,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 61000, 64000, },
    },
    { -- Orecreg's Doglegs Reverse
        currencyID = 2940,
        uiMapID = 2248,
        areaPoiID = 7798,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 61000, 64000, },
    },
    { -- Storm's Watch Survey Basic
        currencyID = 2924,
        uiMapID = 2248,
        areaPoiID = 7794,
        difficultyID = Difficulty.Basic,
        rankTimers = { 63000, 68000, },
    },
    { -- Storm's Watch Survey Advanced
        currencyID = 2930,
        uiMapID = 2248,
        areaPoiID = 7794,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 60000, 63000, },
    },
    { -- Storm's Watch Survey Reverse
        currencyID = 2936,
        uiMapID = 2248,
        areaPoiID = 7794,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 62000, 65000, },
    },
    { -- The Wold Ways Basic
        currencyID = 2926,
        uiMapID = 2248,
        areaPoiID = 7796,
        difficultyID = Difficulty.Basic,
        rankTimers = { 68000, 73000, },
    },
    { -- The Wold Ways Advanced
        currencyID = 2932,
        uiMapID = 2248,
        areaPoiID = 7796,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 68000, 71000, },
    },
    { -- The Wold Ways Reverse
        currencyID = 2938,
        uiMapID = 2248,
        areaPoiID = 7796,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 70000, 73000, },
    },
    { -- Thunderhead Trail Basic
        currencyID = 2927,
        uiMapID = 2248,
        areaPoiID = 7797,
        difficultyID = Difficulty.Basic,
        rankTimers = { 70000, 75000, },
    },
    { -- Thunderhead Trail Advanced
        currencyID = 2933,
        uiMapID = 2248,
        areaPoiID = 7797,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 66000, 69000, },
    },
    { -- Thunderhead Trail Reverse
        currencyID = 2939,
        uiMapID = 2248,
        areaPoiID = 7797,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 66000, 69000, },
    },
    { -- Cataract River Cruise Basic
        currencyID = 2944,
        uiMapID = 2214,
        areaPoiID = 7802,
        difficultyID = Difficulty.Basic,
        rankTimers = { 60000, 65000, },
    },
    { -- Cataract River Cruise Advanced
        currencyID = 2950,
        uiMapID = 2214,
        areaPoiID = 7802,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 58000, 61000, },
    },
    { -- Cataract River Cruise Reverse
        currencyID = 2956,
        uiMapID = 2214,
        areaPoiID = 7802,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 57000, 60000, },
    },
    { -- Chittering Concourse Basic
        currencyID = 2943,
        uiMapID = 2214,
        areaPoiID = 7801,
        difficultyID = Difficulty.Basic,
        rankTimers = { 56000, 61000, },
    },
    { -- Chittering Concourse Advanced
        currencyID = 2949,
        uiMapID = 2214,
        areaPoiID = 7801,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 53000, 56000, },
    },
    { -- Chittering Concourse Reverse
        currencyID = 2955,
        uiMapID = 2214,
        areaPoiID = 7801,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 54000, 57000, },
    },
    { -- Earthenworks Weave Basic
        currencyID = 2941,
        uiMapID = 2214,
        areaPoiID = 7799,
        difficultyID = Difficulty.Basic,
        rankTimers = { 52000, 57000, },
    },
    { -- Earthenworks Weave Advanced
        currencyID = 2947,
        uiMapID = 2214,
        areaPoiID = 7799,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 49000, 52000, },
    },
    { -- Earthenworks Weave Reverse
        currencyID = 2953,
        uiMapID = 2214,
        areaPoiID = 7799,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 50000, 53000, },
    },
    { -- Opportunity Point Amble Basic
        currencyID = 2946,
        uiMapID = 2214,
        areaPoiID = 7804,
        difficultyID = Difficulty.Basic,
        rankTimers = { 77000, 82000, },
    },
    { -- Opportunity Point Amble Advanced
        currencyID = 2952,
        uiMapID = 2214,
        areaPoiID = 7804,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 71000, 74000, },
    },
    { -- Opportunity Point Amble Reverse
        currencyID = 2958,
        uiMapID = 2214,
        areaPoiID = 7804,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 72000, 75000, },
    },
    { -- Ringing Deeps Ramble Basic
        currencyID = 2942,
        uiMapID = 2214,
        areaPoiID = 7800,
        difficultyID = Difficulty.Basic,
        rankTimers = { 57000, 62000, },
    },
    { -- Ringing Deeps Ramble Advanced
        currencyID = 2948,
        uiMapID = 2214,
        areaPoiID = 7800,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 53000, 56000, },
    },
    { -- Ringing Deeps Ramble Reverse
        currencyID = 2954,
        uiMapID = 2214,
        areaPoiID = 7800,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 53000, 56000, },
    },
    { -- Taelloch Twist Basic
        currencyID = 2945,
        uiMapID = 2214,
        areaPoiID = 7803,
        difficultyID = Difficulty.Basic,
        rankTimers = { 47000, 52000, },
    },
    { -- Taelloch Twist Advanced
        currencyID = 2951,
        uiMapID = 2214,
        areaPoiID = 7803,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 43000, 46000, },
    },
    { -- Taelloch Twist Reverse
        currencyID = 2957,
        uiMapID = 2214,
        areaPoiID = 7803,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 44000, 47000, },
    },
    { -- Dunelle's Detour Basic
        currencyID = 2959,
        uiMapID = 2215,
        areaPoiID = 7805,
        difficultyID = Difficulty.Basic,
        rankTimers = { 65000, 70000, },
    },
    { -- Dunelle's Detour Advanced
        currencyID = 2965,
        uiMapID = 2215,
        areaPoiID = 7805,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 62000, 65000, },
    },
    { -- Dunelle's Detour Reverse
        currencyID = 2971,
        uiMapID = 2215,
        areaPoiID = 7805,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 64000, 67000, },
    },
    { -- Light's Redoubt Descent Basic
        currencyID = 2961,
        uiMapID = 2215,
        areaPoiID = 7807,
        difficultyID = Difficulty.Basic,
        rankTimers = { 63000, 68000, },
    },
    { -- Light's Redoubt Descent Advanced
        currencyID = 2967,
        uiMapID = 2215,
        areaPoiID = 7807,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 62000, 65000, },
    },
    { -- Light's Redoubt Descent Reverse
        currencyID = 2973,
        uiMapID = 2215,
        areaPoiID = 7807,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 62000, 65000, },
    },
    { -- Mereldar Meander Basic
        currencyID = 2963,
        uiMapID = 2215,
        areaPoiID = 7809,
        difficultyID = Difficulty.Basic,
        rankTimers = { 76000, 81000, },
    },
    { -- Mereldar Meander Advanced
        currencyID = 2969,
        uiMapID = 2215,
        areaPoiID = 7809,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 71000, 74000, },
    },
    { -- Mereldar Meander Reverse
        currencyID = 2975,
        uiMapID = 2215,
        areaPoiID = 7809,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 71000, 74000, },
    },
    { -- Stillstone Slalom Basic
        currencyID = 2962,
        uiMapID = 2215,
        areaPoiID = 7808,
        difficultyID = Difficulty.Basic,
        rankTimers = { 56000, 61000, },
    },
    { -- Stillstone Slalom Advanced
        currencyID = 2968,
        uiMapID = 2215,
        areaPoiID = 7808,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 54000, 57000, },
    },
    { -- Stillstone Slalom Reverse
        currencyID = 2974,
        uiMapID = 2215,
        areaPoiID = 7808,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 56000, 59000, },
    },
    { -- Tenir's Traversal Basic
        currencyID = 2960,
        uiMapID = 2215,
        areaPoiID = 7806,
        difficultyID = Difficulty.Basic,
        rankTimers = { 65000, 70000, },
    },
    { -- Tenir's Traversal Advanced
        currencyID = 2966,
        uiMapID = 2215,
        areaPoiID = 7806,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 60000, 63000, },
    },
    { -- Tenir's Traversal Reverse
        currencyID = 2972,
        uiMapID = 2215,
        areaPoiID = 7806,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 63000, 66000, },
    },
    { -- Velhan's Venture Basic
        currencyID = 2964,
        uiMapID = 2215,
        areaPoiID = 7810,
        difficultyID = Difficulty.Basic,
        rankTimers = { 55000, 60000, },
    },
    { -- Velhan's Venture Advanced
        currencyID = 2970,
        uiMapID = 2215,
        areaPoiID = 7810,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 50000, 53000, },
    },
    { -- Velhan's Venture Reverse
        currencyID = 2976,
        uiMapID = 2215,
        areaPoiID = 7810,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 50000, 53000, },
    },
    { -- City of Threads Twist Basic
        currencyID = 2977,
        uiMapID = 2255,
        areaPoiID = 7811,
        difficultyID = Difficulty.Basic,
        rankTimers = { 78000, 83000, },
    },
    { -- City of Threads Twist Advanced
        currencyID = 2983,
        uiMapID = 2255,
        areaPoiID = 7811,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 74000, 77000, },
    },
    { -- City of Threads Twist Reverse
        currencyID = 2989,
        uiMapID = 2255,
        areaPoiID = 7811,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 74000, 77000, },
    },
    { -- Maddening Deep Dip Basic
        currencyID = 2978,
        uiMapID = 2255,
        areaPoiID = 7812,
        difficultyID = Difficulty.Basic,
        rankTimers = { 58000, 63000, },
    },
    { -- Maddening Deep Dip Advanced
        currencyID = 2984,
        uiMapID = 2255,
        areaPoiID = 7812,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 54000, 57000, },
    },
    { -- Maddening Deep Dip Reverse
        currencyID = 2990,
        uiMapID = 2255,
        areaPoiID = 7812,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 56000, 59000, },
    },
    { -- Pit Plunge Basic
        currencyID = 2981,
        uiMapID = 2255,
        areaPoiID = 7815,
        difficultyID = Difficulty.Basic,
        rankTimers = { 63000, 68000, },
    },
    { -- Pit Plunge Advanced
        currencyID = 2987,
        uiMapID = 2255,
        areaPoiID = 7815,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 61000, 64000, },
    },
    { -- Pit Plunge Reverse
        currencyID = 2993,
        uiMapID = 2255,
        areaPoiID = 7815,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 61000, 64000, },
    },
    { -- Rak-Ahat Rush Basic
        currencyID = 2980,
        uiMapID = 2255,
        areaPoiID = 7814,
        difficultyID = Difficulty.Basic,
        rankTimers = { 70000, 75000, },
    },
    { -- Rak-Ahat Rush Advanced
        currencyID = 2986,
        uiMapID = 2255,
        areaPoiID = 7814,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 66000, 69000, },
    },
    { -- Rak-Ahat Rush Reverse
        currencyID = 2992,
        uiMapID = 2255,
        areaPoiID = 7814,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 66000, 69000, },
    },
    { -- Siegehold Scuttle Basic
        currencyID = 2982,
        uiMapID = 2255,
        areaPoiID = 7816,
        difficultyID = Difficulty.Basic,
        rankTimers = { 70000, 75000, },
    },
    { -- Siegehold Scuttle Advanced
        currencyID = 2988,
        uiMapID = 2255,
        areaPoiID = 7816,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 66000, 69000, },
    },
    { -- Siegehold Scuttle Reverse
        currencyID = 2994,
        uiMapID = 2255,
        areaPoiID = 7816,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 63000, 66000, },
    },
    { -- The Weaver's Wing Basic
        currencyID = 2979,
        uiMapID = 2255,
        areaPoiID = 7813,
        difficultyID = Difficulty.Basic,
        rankTimers = { 54000, 59000, },
    },
    { -- The Weaver's Wing Advanced
        currencyID = 2985,
        uiMapID = 2255,
        areaPoiID = 7813,
        difficultyID = Difficulty.Advanced,
        rankTimers = { 51000, 54000, },
    },
    { -- The Weaver's Wing Reverse
        currencyID = 2991,
        uiMapID = 2255,
        areaPoiID = 7813,
        difficultyID = Difficulty.Reverse,
        rankTimers = { 50000, 53000, },
    },
}
local raceByCurrencyID = {}
local pois = {}
local poiByID = {}
for _, race in ipairs(races) do
    raceByCurrencyID[race.currencyID] = race

    if not poiByID[race.areaPoiID] then
        local tbl = {
            areaPoiID = race.areaPoiID,
            uiMapID = race.uiMapID,
            raceIDs = {},
        }
        pois[#pois + 1] = tbl
        poiByID[race.areaPoiID] = tbl
    end

    poiByID[race.areaPoiID].raceIDs[race.difficultyID] = race.currencyID
end

---@return integer rank rank 0 is unranked, 1 is bronze, 2 silver, 3 gold
function Internal.GetRaceRankForScore(raceID, score)
    local race = raceByCurrencyID[raceID]
    if not race then
        return nil
    end
    if score == 0 then
        return 0
    end

    local rank = 1
    for index, time in ipairs(race.rankTimers) do
        if score <= time then
            rank = 4 - index
            break
        end
    end

    return rank
end

function Internal.IterateRaces()
    return ipairs(races)
end

function Internal.IteratePOIs()
    return function(tbl, index)
        index = index + 1

        local record = tbl[index]
        if not record then
            return
        end

        local uiMapID = record.uiMapID
        local areaPoiID = record.areaPoiID
        local raceIDs = record.raceIDs

        local poi = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID)

        return index, { name = poi.name, uiMapID = uiMapID, areaPoiID = areaPoiID, raceIDs = raceIDs }
    end, pois, 0
end

function Internal.IterateDifficulties(areaPoiID)
    local poi = poiByID[areaPoiID]
    local difficulties = {}
    for difficultyID in pairs(poi.raceIDs) do
        difficulties[#difficulties + 1] = difficultyID
    end
    table.sort(difficulties)
    return function(tbl, index)
        index = index + 1

        local record = tbl[index]
        if not record then
            return
        end

        return index, { id = record, name = DifficultyNames[record] }
    end, difficulties, 0
end

---@param raceID number?
---@return Race | nil
function Internal.GetRace(raceID)
    raceID = tonumber(raceID)

    local race = raceByCurrencyID[raceID]
    if not race then
        return nil
    end

    local poi = C_AreaPoiInfo.GetAreaPOIInfo(race.uiMapID, race.areaPoiID)
    assert(poi ~= nil, string.format("Failed to read poi for race %d", raceID))

    local currency = C_CurrencyInfo.GetCurrencyInfo(race.currencyID)

    local name = poi.name;
    local difficultyName = DifficultyNames[race.difficultyID];
    if difficultyName then
        name = string.format("%s (%s)", name, difficultyName);
    end

    return {
        id = currency.currencyID,
        name = name,
        uiMapID = race.uiMapID,
        areaPoiID = race.areaPoiID,
        difficultyID = race.difficultyID,
        position = poi.position,
    }
end

---@param areaPoiID number?
---@param difficultyID number?
---@return Race | nil
function Internal.GetRaceByPOI(areaPoiID, difficultyID)
    areaPoiID = tonumber(areaPoiID)
    difficultyID = difficultyID and tonumber(difficultyID) or 1

    local poi = poiByID[areaPoiID]
    if not poi then
        return nil
    end

    local raceID = poi.raceIDs[difficultyID]
    if not raceID then
        return
    end

    return Internal.GetRace(raceID)
end

local function FindClosestPOI(uiMapID, pois)
    local playerPosition = C_Map.GetPlayerMapPosition(uiMapID, "player")
    if not playerPosition then
        return nil
    end

    local closestPoi = nil
    local closestDistanceSq = INF
    for _, poiID in ipairs(pois) do
        local poi = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, poiID)
        local position = poi.position
        position:Subtract(playerPosition)
        local distanceSq = position:GetLengthSquared()
        if closestPoi == nil or closestDistanceSq > distanceSq then
            closestPoi = poi
            closestDistanceSq = distanceSq
        end
    end
    return closestPoi
end
local function GetCompletedRaceDetails()
    local uiMapID = C_Map.GetBestMapForUnit("player")
    if not uiMapID then
        return
    end
    local pois = C_AreaPoiInfo.GetDragonridingRacesForMap(uiMapID)
    local closestPoi = FindClosestPOI(uiMapID, pois)
    if not closestPoi then
        return
    end
    local silver = C_CurrencyInfo.GetCurrencyInfo(2019)
    local gold = C_CurrencyInfo.GetCurrencyInfo(2020)
    if not silver or not gold then
        return
    end

    return closestPoi.name, uiMapID, closestPoi.areaPoiID, gold.quantity, silver.quantity
end
local function GuessRaceDifficulty(currency)
    if currency.name:find("Reverse") then
        return Difficulty.Reverse
    end
    if currency.name:find("Advanced") then
        return Difficulty.Advanced
    end
    return Difficulty.Basic
end

local currentRaceCompletionTime = 0
EventRegistry:RegisterFrameEventAndCallback("CURRENCY_DISPLAY_UPDATE",
    function(_, currencyID, quantity, quantityChange, quantityGainSource, quantityLostSource)
        if type(currencyID) ~= "number" then
            return
        end
        if currencyID == 2236 then
            currentRaceCompletionTime = quantity
        end
        local currency = C_CurrencyInfo.GetCurrencyInfo(currencyID)
        if not currency or not currency.name then
            return
        end
        local race = Internal.GetRace(currencyID)
        if not race then
            --@debug@
            if currency.name:find("^Dragon Racing %- Personal Best Record") then
                local name, uiMapID, areaPoiID, gold, silver = GetCompletedRaceDetails()
                if uiMapID then
                    local difficultyID = GuessRaceDifficulty(currency)

                    local difficultyName = DifficultyNames[difficultyID];
                    name = string.format("%s %s", name, difficultyName or "Basic");

                    print(string.format(
                        "[%s]: An unknown race has been found - [%d] %s (map: %d, poi: %d, difficulty: %d, gold: %d, silver: %d).",
                        ADDON_NAME, currencyID, name, uiMapID, areaPoiID, difficultyID, gold, silver))
                    if not RacingLeaderboard_Races then
                        RacingLeaderboard_Races = {}
                    end

                    RacingLeaderboard_Races[currencyID] = {
                        name = name,
                        currencyID = currencyID,
                        uiMapID = uiMapID,
                        areaPoiID = areaPoiID,
                        difficultyID = difficultyID,
                        rankTimers = { gold * 1000, silver * 1000 },
                    }
                end
            end
            --@end-debug@
            return
        end
        if quantity == 0 then -- Previous personal best record
            print(string.format("Previous personal best for %s = %d", race.name, math.abs(quantityChange)))
        else
            print(string.format("New personal best for %s = %d (%d)", race.name, math.abs(quantity),
                math.abs(currentRaceCompletionTime)))

            Internal.UpdatePlayerScore(currencyID, quantity)
        end
    end)


-- print("|A:challenges-medal-small-bronze:0:0:0:0|a")
-- print("|A:challenges-medal-small-silver:0:0:0:0|a")
-- print("|A:challenges-medal-small-gold:0:0:0:0|a")

-- 2016, 2017, 2124, 2125, 2236
-- 2016, 2017, 2124, 2125, 2236
-- 2019, 2019, 2020, 2020
-- 2040, 2041, 2131, 2132
-- 2944, 2944
-- 2040, 2041, 2131, 2132


TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.UnitAura, function(self, data)
    _G['data'] = data
end)
