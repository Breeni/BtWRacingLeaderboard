---@type string
local ADDON_NAME = ...
---@class Internal
local Internal = select(2, ...)

local PREFIX = "BtWRL"
C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)


--- Our current packet ID, used when sending out new requests
local packetID = 1
local function GetNextPacketID()
    local result = packetID
    packetID = packetID + 1
    return result
end

--- Callback functions to run for request responses
---@type table<number, table>
local packetCallbacks = {}

---@class GuildMemberStatus
---@field source string Who is best to send member data
---@field timestamp integer The last time the source had their data updated for the member
---@field min integer The minimum timestamp to send, only send data thats at or after this timestamp

--- Maps guild members to who ever has the latest data on that member
---@type table<string, GuildMemberStatus>
local GuildMemberStatus = {}

---@type table<string, boolean>
local RecentGuildMemberDataRequest = setmetatable({}, {
    __newindex = function(self, key, value)
        rawset(self, key, value)
        C_Timer.After(60 * 60, function()
            rawset(self, key, nil)
        end)
    end
})


---@class PacketMixin
local PacketMixin = { ControlCharacter = "\0" }
---@param id integer
function PacketMixin:Init(id)
    self.id = id
end
function PacketMixin:GetType()
    return self.ControlCharacter
end
function PacketMixin:Build()
    error("Not Implemented")
end

--- Request data stored at or after the requested timestamp
---@class RequestPlayerDataPacketMixin: PacketMixin
local RequestPlayerDataPacketMixin = Mixin({}, PacketMixin, { ControlCharacter = "\1" })
---@param id integer
---@param name string
---@param realm string
---@param timestamp integer
function RequestPlayerDataPacketMixin:Init(id, name, realm, timestamp)
    PacketMixin.Init(self, id)
    self.name = name
    self.realm = realm
    self.timestamp = timestamp
end
function RequestPlayerDataPacketMixin:Build()
    return string.format("%s\t%d\t%s\t%s\t%d", self.ControlCharacter, self.id, self.name, self.realm, self.timestamp)
end

--- Send latest timestamp for player
---@class PlayerDataStatusPacketMixin: PacketMixin
local PlayerDataStatusPacketMixin = Mixin({}, PacketMixin, { ControlCharacter = "\2" })
---@param id integer
---@param name string
---@param realm string
---@param timestamp integer
function PlayerDataStatusPacketMixin:Init(id, name, realm, timestamp)
    PacketMixin.Init(self, id)
    self.name = name
    self.realm = realm
    self.timestamp = timestamp
end
function PlayerDataStatusPacketMixin:Build()
    return string.format("%s\t%d\t%s\t%s\t%d", self.ControlCharacter, self.id, self.name, self.realm, self.timestamp)
end

--- Send sync player data
---@class PlayerDataPacketMixin: PacketMixin
local PlayerDataPacketMixin = Mixin({}, PacketMixin, { ControlCharacter = "\3" })
---@param name string
---@param realm string
---@param timestamp integer
---@param scores table<integer, integer>
---@param timestamps table<integer, integer>
function PlayerDataPacketMixin:Init(id, name, realm, timestamp, scores, timestamps)
    PacketMixin.Init(self, id)
    self.name = name
    self.realm = realm
    self.timestamp = timestamp
    self.scores = scores
    self.timestamps = timestamps
end
function PlayerDataPacketMixin:Build()
    local tbl = { self.ControlCharacter, self.id, self.name, self.realm, self.timestamp }
    for id, score in pairs(self.scores) do
        tbl[#tbl + 1] = string.format("%d", id)
        tbl[#tbl + 1] = string.format("%d", score)
        tbl[#tbl + 1] = string.format("%d", self.timestamps[id] or 0)
    end
    return table.concat(tbl, "\t")
end

--- Send status message
---@class StatusPacketMixin: PacketMixin
local StatusPacketMixin = Mixin({}, PacketMixin, { ControlCharacter = "\4" })
---@param id integer
---@param status string
function StatusPacketMixin:Init(id, status)
    PacketMixin.Init(self, id)
    self.status = status
end
function StatusPacketMixin:Build()
    return string.format("%s\t%d\t%s", self.ControlCharacter, self.id, self.status)
end

--- Send player new personal best
---@class PersonalBestPacketMixin: PacketMixin
local PersonalBestPacketMixin = Mixin({}, PacketMixin, { ControlCharacter = "\5" })
---@param id integer
---@param name string
---@param realm string
---@param raceID integer
---@param score integer
---@param timestamp integer
---@param lastUpdated integer
function PersonalBestPacketMixin:Init(id, name, realm, raceID, score, timestamp, lastUpdated)
    PacketMixin.Init(self, id)
    self.name = name
    self.realm = realm
    self.raceID = raceID
    self.score = score
    self.timestamp = timestamp
    self.lastUpdated = lastUpdated
end
function PersonalBestPacketMixin:Build()
    return string.format("%s\t%d\t%s\t%s\t%d\t%d\t%d\t%d", self.ControlCharacter, self.id, self.name, self.realm, self
        .raceID, self.score, self.timestamp, self.lastUpdated)
end

---@param id integer
---@param name string
---@param realm string
---@param timestamp integer
local function CreatePacket_RequestPlayerData(id, name, realm, timestamp)
    local result = Mixin({}, RequestPlayerDataPacketMixin)
    result:Init(id, name, realm, timestamp)
    return result
end

---@param id integer
---@param name string
---@param realm string
---@param timestamp integer
local function CreatePacket_PlayerDataStatus(id, name, realm, timestamp)
    local result = Mixin({}, PlayerDataStatusPacketMixin)
    result:Init(id, name, realm, timestamp)
    return result
end

---@param id integer
---@param name string
---@param realm string
---@param timestamp integer
---@param scores table<integer, integer>
---@param timestamps table<integer, integer>
local function CreatePacket_PlayerData(id, name, realm, timestamp, scores, timestamps)
    local result = Mixin({}, PlayerDataPacketMixin)
    result:Init(id, name, realm, timestamp, scores, timestamps)
    return result
end

---@param id integer
---@param status string
local function CreatePacket_Status(id, status)
    local result = Mixin({}, StatusPacketMixin)
    result:Init(id, status)
    return result
end

---@param id integer
---@param name string
---@param realm string
---@param raceID integer
---@param score integer
---@param timestamp integer
---@param lastUpdated integer
local function CreatePacket_PersonalBest(id, name, realm, raceID, score, timestamp, lastUpdated)
    local result = Mixin({}, PersonalBestPacketMixin)
    result:Init(id, name, realm, raceID, score, timestamp, lastUpdated)
    return result
end


---@param target "PARTY" | "GUILD" | string
---@param packet PacketMixin
local function SendPacket(target, packet)
    if target == "GUILD" or target == "PARTY" then
        ChatThrottleLib:SendAddonMessage("NORMAL", PREFIX, packet:Build(), target, nil, nil, function()
            --@debug@
            print(string.format("[%s]: Sent addon message", ADDON_NAME))
            --@end-debug@
        end);
    else
        ChatThrottleLib:SendAddonMessage("NORMAL", PREFIX, packet:Build(), "WHISPER", target);
    end
end

---@param name string
---@param realm string
---@param timestamp integer
local function RequestGuildMemberData(name, realm, timestamp)
    local id = GetNextPacketID()
    local packet = CreatePacket_RequestPlayerData(id, name, realm, timestamp)
    SendPacket("GUILD", packet)
end

function Internal.SendNewPersonalBest(raceID, score, timestamp, lastUpdated)
    local character = Internal.GetPlayer()
    local name = character:GetName()
    local realm = character:GetRealm()

    local id = GetNextPacketID()
    local packet = CreatePacket_PersonalBest(id, name, realm, raceID, score, timestamp, lastUpdated)
    SendPacket("GUILD", packet)
end

function Internal.ForceRequestGuildMemberData(name, realm)
    if not realm then
        realm = GetNormalizedRealmName()
    end

    local key = name .. "-" .. realm
    RecentGuildMemberDataRequest[key] = true

    local character = Internal.GetCharacter(name, realm)
    RequestGuildMemberData(name, realm, character and character:LastUpdated() or 0)
end
function RacingLeaderboard_RequestPlayerData(name, realm)
    Internal.ForceRequestGuildMemberData(name, realm)
end

function Internal.RequestRandomGuildMemberData()
    local numMembers = GetNumGuildMembers()
    if numMembers == 0 then
        return
    end

    for _ = 1, 20 do
        local index = math.ceil(math.random() * numMembers)
        local name, realm, _, _, _, _, _, _, isOnline = GetGuildRosterInfo(index)
        if not isOnline then
            local yearsOffline, monthsOffline, daysOffline, hoursOffline = GetGuildRosterLastOnline(index)
        end
    
        name, realm = strsplit("-", name)
        if not realm then
            realm = GetNormalizedRealmName()
        end

        local character = Internal.GetCharacter(name, realm)
        if character then -- Only pick characters that we know have the addon
            local key = name .. "-" .. realm
            if not RecentGuildMemberDataRequest[key] then
                RecentGuildMemberDataRequest[key] = true

                RequestGuildMemberData(name, realm, character and character:LastUpdated() or 0)
                break
            end
        end
    end
end

function Internal.RequestPlayerGuildMemberData()
    local character = Internal.GetPlayer()
    local name = character:GetName()
    local realm = character:GetRealm()

    -- Dont sync our data if we havent done races yet
    if character:LastUpdated() == 0 then
        return
    end

    RequestGuildMemberData(name, realm, character:LastUpdated())
end

function RacingLeaderboard_SyncPlayerData()
    Internal.RequestPlayerGuildMemberData()
end

---@param controlCharacter string
---@param ... string
local function ParsePacket(controlCharacter, id, ...)
    id = tonumber(id)
    assert(id ~= nil, "Failed to parse packet: Invalid id")

    if controlCharacter == RequestPlayerDataPacketMixin.ControlCharacter then
        local name, realm, timestamp = ...
        assert(name ~= nil, "Failed to parse Send Player Data packet: Invalid name")
        assert(realm ~= nil, "Failed to parse Send Player Data packet: Invalid realm")

        local timestamp = tonumber(timestamp)
        assert(timestamp ~= nil, "Failed to parse Request Player Data packet: Invalid timestamp")

        return CreatePacket_RequestPlayerData(id, name, realm, timestamp)
    elseif controlCharacter == PlayerDataStatusPacketMixin.ControlCharacter then
        local name, realm, timestamp = ...
        assert(name ~= nil, "Failed to parse PlayerDataStatus packet: Invalid name")
        assert(realm ~= nil, "Failed to parse PlayerDataStatus packet: Invalid realm")

        local timestamp = tonumber(timestamp)
        assert(timestamp ~= nil, "Failed to parse PlayerDataStatus packet: Invalid timestamp")

        return CreatePacket_PlayerDataStatus(id, name, realm, timestamp)
    elseif controlCharacter == PlayerDataPacketMixin.ControlCharacter then
        local name, realm, timestamp = ...
        assert(name ~= nil, "Failed to parse PlayerData packet: Invalid name")
        assert(realm ~= nil, "Failed to parse PlayerData packet: Invalid realm")

        local timestamp = tonumber(timestamp)
        assert(timestamp ~= nil, "Failed to parse PlayerData packet: Invalid timestamp")

        ---@type table<integer, integer>, table<integer, integer>
        local scores, timestamps = {}, {}
        for i = 4, select("#", ...), 3 do
            local id, score, timestamp = select(i, ...)
            id, score, timestamp = tonumber(id), tonumber(score), tonumber(timestamp)
            assert(id ~= nil, "Failed to parse PlayerData packet: Invalid race id")
            assert(score ~= nil, "Failed to parse PlayerData packet: Invalid race score")
            assert(timestamp ~= nil, "Failed to parse PlayerData packet: Invalid race timestamp")

            scores[id] = score
            timestamps[id] = timestamp
        end
        return CreatePacket_PlayerData(id, name, realm, timestamp, scores, timestamps)
    elseif controlCharacter == StatusPacketMixin.ControlCharacter then
        local status = ...
        assert(status ~= nil, "Failed to parse Status packet: Invalid status")

        return CreatePacket_Status(id, status)
    elseif controlCharacter == PersonalBestPacketMixin.ControlCharacter then
        local name, realm, raceID, score, timestamp, lastUpdated = ...
        assert(name ~= nil, "Failed to parse PersonalBest packet: Invalid name")
        assert(realm ~= nil, "Failed to parse PersonalBest packet: Invalid realm")

        local raceID, score, timestamp, lastUpdated = tonumber(raceID), tonumber(score), tonumber(timestamp),
            tonumber(lastUpdated)
        assert(raceID ~= nil, "Failed to parse PersonalBest packet: Invalid raceID")
        assert(score ~= nil, "Failed to parse PersonalBest packet: Invalid score")
        assert(timestamp ~= nil, "Failed to parse PersonalBest packet: Invalid timestamp")
        assert(lastUpdated ~= nil, "Failed to parse PersonalBest packet: Invalid lastUpdated")

        return CreatePacket_PersonalBest(id, name, realm, raceID, score, timestamp, lastUpdated)
    else
        error("Failed to parse packet: Invalid control character")
    end
end

local function CreateGuildMembersCache()
    local index = 1
    return setmetatable({}, {
        __index = function(self, key)
            local name, realm, _, level, _, _, _, _, _, _, class = GetGuildRosterInfo(index)
            while name do
                name, realm = strsplit("-", name)
                if not realm then
                    realm = GetNormalizedRealmName()
                end

                local memberKey = name .. "-" .. realm
                rawset(self, memberKey, { name = name, realm = realm, class = class })
                if memberKey == key then
                    return rawget(self, key)
                end

                index = index + 1
                name, _, _, level, _, _, _, _, _, _, class = GetGuildRosterInfo(index)
            end
            return rawget(self, key)
        end
    })
end

local GuildMembersCache = CreateGuildMembersCache()
--- Check if the requested character is within the players guild
---@param name string
---@param realm string
---@return table | nil
local function GetGuildMember(name, realm)
    if not IsInGuild() then
        return nil
    end

    local key = name .. "-" .. realm
    return GuildMembersCache[key]
end

local Messages = {
    INVALID_GUILD = "Cannot send data for players not within the guild."
}
EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(_, addonName)
    if addonName == ADDON_NAME then
        if not RacingLeaderboard_SyncData then
            RacingLeaderboard_SyncData = {}
        end
    end
end)
EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(_, isLogin)
    if isLogin then
        C_Timer.After(5, function()
            Internal.RequestPlayerGuildMemberData()
        end)
    else
        Internal.RequestRandomGuildMemberData()
    end
end)
EventRegistry:RegisterFrameEventAndCallback("GUILD_ROSTER_UPDATE", function(_, addonName)
    GuildMembersCache = CreateGuildMembersCache()
end)
EventRegistry:RegisterFrameEventAndCallback("CHAT_MSG_ADDON",
    function(event, prefix, text, channel, sender, target, zoneChannelID, localID, name, instanceID)
        if prefix ~= PREFIX then
            return
        end

        local packet = ParsePacket(strsplit("\t", text))
        if packet.ControlCharacter == RequestPlayerDataPacketMixin.ControlCharacter then
            --@debug@
            print(string.format("[%s]: New Addon Message (%d, %s - %s) - Request Player Data (%s - %s, %d)", ADDON_NAME,
                packet.id, channel, sender, packet.name, packet.realm, packet.timestamp))
            --@end-debug@
            if channel == "GUILD" then
                if not GetGuildMember(packet.name, packet.realm) then
                    return -- Dont sync data for people not in the guild
                end

                local playerName = UnitName("player")
                local playerRealm = GetNormalizedRealmName()
                local playerKey = playerName .. "-" .. playerRealm

                local key = packet.name .. "-" .. packet.realm
                local character = Internal.GetCharacter(packet.name, packet.realm)

                local isPlayer = key == playerKey
                if isPlayer and not character then
                    error("Failed to get current players data")
                end

                RecentGuildMemberDataRequest[key] = true

                GuildMemberStatus[key] = {
                    source = playerKey,
                    timestamp = character and character:LastUpdated() or 0,
                    min = packet.timestamp,
                }

                if not character then
                    -- We have no data so request someone send everything
                    C_Timer.After(math.random() * 4, function()
                        if GuildMemberStatus[key].min > 0 then
                            local id = GetNextPacketID()
                            local packet = CreatePacket_PlayerDataStatus(id, packet.name, packet.realm, 0)
                            SendPacket("GUILD", packet)
                        end
                    end)
                elseif not isPlayer and character:LastUpdated() <= packet.timestamp then
                    -- We need data from earlier than was orignally requested
                    C_Timer.After(math.random() * 4, function()
                        if GuildMemberStatus[key].min > character:LastUpdated() then
                            local id = GetNextPacketID()
                            local packet = CreatePacket_PlayerDataStatus(id, packet.name, packet.realm,
                                character:LastUpdated())
                            SendPacket("GUILD", packet)
                        end
                    end)
                else
                    if isPlayer then
                        -- We are this player so just send our latest time now
                        local id = GetNextPacketID()
                        local packet = CreatePacket_PlayerDataStatus(id, packet.name, packet.realm,
                            character:LastUpdated())
                        SendPacket("GUILD", packet)
                    else
                        C_Timer.After(math.random() * 4, function()
                            if GuildMemberStatus[key].source == playerKey then
                                local id = GetNextPacketID()
                                local packet = CreatePacket_PlayerDataStatus(id, packet.name, packet.realm,
                                    character:LastUpdated())
                                SendPacket("GUILD", packet)
                            end
                        end)
                    end
                    -- Wait until everyone who wants to has sent out their sync details so we can send the minimum amount of data
                    C_Timer.After(5, function()
                        local tbl = GuildMemberStatus[key]
                        if tbl.source ~= playerKey then
                            return
                        end

                        GuildMemberStatus[key] = nil

                        if tbl.timestamp == tbl.min and tbl.timestamp == character:LastUpdated() then -- Everyone is up to date
                            --@debug@
                            print(string.format("[%s]: Everyone is up to date for %s - %s", ADDON_NAME, packet.name, packet.realm))
                            --@end-debug@
                            return
                        end

                        local min = tbl.min
                        local scores, timestamps = character:GetScores()

                        local items = {}
                        for raceID, score in pairs(scores) do
                            local timestamp = timestamps[raceID]
                            if timestamp >= min then
                                items[#items + 1] = { raceID = raceID, score = score, timestamp = timestamp }
                            end
                        end
                        table.sort(items, function(a, b)
                            if a.timestamp == b.timestamp then
                                return a.raceID < b.raceID
                            end

                            return a.timestamp < b.timestamp
                        end)

                        if #items == 0 then -- Nothing to send
                            --@debug@
                            print(string.format("[%s]: Nothing to send for %s - %s", ADDON_NAME, packet.name, packet.realm))
                            --@end-debug@
                            return
                        end

                        local count = 0
                        local outScores, outTimestamps = {}, {}
                        for _, item in ipairs(items) do
                            outScores[item.raceID] = item.score
                            outTimestamps[item.raceID] = item.timestamp

                            count = count + 1
                            if count >= 10 then
                                local id = GetNextPacketID()
                                local packet = CreatePacket_PlayerData(id, packet.name, packet.realm, min, outScores,
                                    outTimestamps)
                                SendPacket("GUILD", packet)

                                min = item.timestamp
                                count = 0
                                outScores, outTimestamps = {}, {}
                            end
                        end

                        if count > 0 then
                            local id = GetNextPacketID()
                            local packet = CreatePacket_PlayerData(id, packet.name, packet.realm, min, outScores,
                                outTimestamps)
                            SendPacket("GUILD", packet)
                        end
                    end)
                end
            end
        elseif packet.ControlCharacter == PlayerDataStatusPacketMixin.ControlCharacter then
            --@debug@
            print(string.format("[%s]: New Addon Message (%d, %s - %s) - Player Data Status (%s - %s, %d)", ADDON_NAME,
                packet.id, channel, sender, packet.name, packet.realm, packet.timestamp))
            --@end-debug@
            if channel == "GUILD" then
                if not GetGuildMember(packet.name, packet.realm) then
                    return
                end

                local key = packet.name .. "-" .. packet.realm
                local tbl = GuildMemberStatus[key]
                if not tbl then -- Response was too late
                    return
                end
                if tbl.timestamp < packet.timestamp or (tbl.timestamp == packet.timestamp and tbl.source > sender) or key == sender then
                    GuildMemberStatus[key] = {
                        source = sender,
                        timestamp = packet.timestamp,
                        min = tbl.min
                    }
                elseif tbl.min > packet.timestamp then
                    GuildMemberStatus[key].min = packet.timestamp
                end
            end
        elseif packet.ControlCharacter == PlayerDataPacketMixin.ControlCharacter then
            --@debug@
            print(string.format("[%s]: New Addon Message (%d, %s - %s) - Player Data (%s - %s, %d, ...)", ADDON_NAME,
                packet.id, channel, sender, packet.name, packet.realm, packet.timestamp))
            --@end-debug@
            if channel == "GUILD" then
                local member = GetGuildMember(packet.name, packet.realm)
                if not member then
                    return
                end

                local character = Internal.GetCharacter(packet.name, packet.realm)
                if not character then
                    character = Internal.AddCharacter(member.name, member.realm, member.class)
                end
                if not character then
                    return
                end

                -- We were last updated earlier than this packet contains
                -- We cant use this packet because we will be missing a chunk
                if character:LastUpdated() < packet.timestamp then
                    return
                end

                local verified = (packet.name .. "-" .. packet.realm) == sender
                for raceID, score in pairs(packet.scores) do
                    character:UpdateScore(raceID, score, packet.timestamps[raceID], verified)
                end
                RacingLeaderboardFrame:Update()
            end
        elseif packet.ControlCharacter == StatusPacketMixin.ControlCharacter then
            print(string.format("[%s]: Failed to get player data for %s-%s: %s", ADDON_NAME, packet.name, packet.realm,
                Messages[packet.status] or "Unknown error"))

            local tbl = packetCallbacks[packet.id]
            packetCallbacks[packet.id] = nil

            tbl[1](packet.status, select(2, unpack(tbl)))
        elseif packet.ControlCharacter == PersonalBestPacketMixin.ControlCharacter then
            --@debug@
            print(string.format("[%s]: New Addon Message (%d, %s - %s) - Personal Best (%s - %s, %d, %d, %d, %d)",
                ADDON_NAME, packet.id, channel, sender, packet.name, packet.realm, packet.raceID, packet.score,
                packet.timestamp, packet.lastUpdated))
            --@end-debug@
            if channel == "GUILD" then
                if not GetGuildMember(packet.name, packet.realm) then
                    return
                end

                local key = packet.name .. "-" .. packet.realm
                if sender ~= key then -- Only accept new personal bests from the player directly
                    return
                end

                local character = Internal.GetCharacter(packet.name, packet.realm)
                if not character or packet.lastUpdated > character:LastUpdated() then
                    C_Timer.After(math.random() * 10, function()
                        if RecentGuildMemberDataRequest[key] then
                            return
                        end
                        RecentGuildMemberDataRequest[key] = true

                        RequestGuildMemberData(packet.name, packet.realm, character and character:LastUpdated() or 0)
                    end)
                else
                    character:UpdateScore(packet.raceID, packet.score, packet.timestamp)
                    RacingLeaderboardFrame:Update()
                end
            end
        end
    end)
