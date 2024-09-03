---@class Internal
local Internal = select(2, ...)

-- Localization table
local L = setmetatable({}, {
    __index = function (self, key)
        self[key] = key
        return key
    end,
})
Internal.L = L;
