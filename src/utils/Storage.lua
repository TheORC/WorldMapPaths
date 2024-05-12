--[[
    This class adds a wrapper around the storage method.
    This helps make saving and getting information easier.
]]

local dataVersion    = 1

local MAP_KEY        = "maps"

local storageDefault = {
    ["settings"] = {},
    [MAP_KEY] = {}
}

WMP_SETTING_KEYS     = {
    DEBUG_DRAW_POINT = "DEBUG_DRAW_POINT",
    DEBUG_DRAW_PATH = "DEBUG_DRAW_PATH"
}

---Helper class for managing plugin data.
---@class WMP_Storage
local WMP_Storage    = ZO_InitializingObject:Subclass()

---Load any stored data from the disk.
function WMP_Storage:LoadData()
    self.storage = ZO_SavedVars:NewCharacterIdSettings("WorldMapPathsVars", dataVersion, nil, storageDefault)
end

---Return the setting with the given name
---@param settingName string
---@return any
function WMP_Storage:GetSetting(settingName)
    return self.storage["settings"][settingName]
end

---Set the value of a setting
---@param settingName string
---@param value any
function WMP_Storage:SetSetting(settingName, value)
    self.storage["settings"][settingName] = value
end

---Stores a map in storage
---@param map WMP_Map
function WMP_Storage:StoreMap(map)
    local index = self:FindMapIndex(map:GetZoneId())
    local mapData = nil

    if getmetatable(map) == WMP_Zone then
        ---@diagnostic disable-next-line: param-type-mismatch
        mapData = WMP_Zone:MapToStorage(map)
    elseif getmetatable(map) == WMP_World then
        ---@diagnostic disable-next-line: param-type-mismatch
        mapData = WMP_World:MapToStorage(map)
    else
        d("Unable to save the map. Unknonw type!")
        return
    end

    if index ~= nil then
        self.storage[MAP_KEY][index] = mapData
    else
        table.insert(self.storage[MAP_KEY], mapData)
    end
end

---Loads a map from storage
---@param zoneId integer
---@return WMP_Map|nil
function WMP_Storage:GetMap(zoneId)
    local index = self:FindMapIndex(zoneId)

    if index == nil then
        return nil
    end

    local mapData = self.storage[MAP_KEY][index]

    if zoneId == 0 then
        return WMP_World:StorageToMap(mapData)
    else
        return WMP_Zone:StorageToMap(mapData)
    end
end

do
    ---Find a zones data given it's id
    ---@param zoneId integer
    ---@return integer|nil
    function WMP_Storage:FindMapIndex(zoneId)
        for i, data in ipairs(self.storage[MAP_KEY]) do
            if data["zoneId"] == zoneId then
                return i
            end
        end

        return nil
    end
end

---The WMP storage manager
---@type WMP_Storage
---@diagnostic disable-next-line: undefined-field
WMP_STORAGE = WMP_Storage:New()
