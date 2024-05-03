--[[
    This class adds a wrapper around the storage method.
    This helps make saving and getting information easier.
]]

local dataVersion    = 1
local storageDefault = {
    ["settings"] = {}
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

---The WMP storage manager
---@type WMP_Storage
---@diagnostic disable-next-line: undefined-field
WMP_STORAGE = WMP_Storage:New()
