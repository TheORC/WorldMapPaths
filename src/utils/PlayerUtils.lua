local GPS = LibGPS3

---Returns the zone id the player is currently in
---@return integer
function WMP_GetPlayerZoneId()
  local zoneId, _, _, _ = GetUnitWorldPosition("player")
  ---@diagnostic disable-next-line: return-type-mismatch
  return zoneId
end

---Returns whether the player is in the provided zone.
---@param zoneId integer
---@return boolean
function WMP_IsPlayerInZone(zoneId)
  return zoneId == WMP_GetPlayerZoneId()
end

---Returns whether the player is in the current active map zone
---@return boolean
function WMP_IsPlayerInCurrentZone()
  return WMP_GetActiveMapZoneId() == WMP_GetPlayerZoneId()
end

---Returns the zone id of the current active map
---@return integer
function WMP_GetActiveMapZoneId()
  local measure = GPS:GetCurrentMapMeasurement()
  return measure:GetZoneId()
end

---Gets the closest zone to the provided global position
---@param x number
---@param y number
---@return integer
function WMP_GetZoneIdFromGlobalPos(x, y)
  GPS:PushCurrentMap()
  GPS:SetMapToRootMap(x, y)
  GPS:MapZoomInMax(x, y)
  local zoneId = WMP_GetActiveMapZoneId()
  GPS:PopCurrentMap()
  return zoneId
end

---Returns the player current local position
---@return WMP_Vector
function WMP_GetPlayerLocalPos()
  local x, y = GetMapPlayerPosition("player")

  ---@diagnostic disable-next-line: param-type-mismatch
  return WMP_Vector:New(x, y)
end

---Returns the player current gloabl position
---@return WMP_Vector
function WMP_GetPlayerGlobalPos()
  local position = WMP_GetPlayerLocalPos()
  local x, y = GPS:LocalToGlobal(position.x, position.y)

  return WMP_Vector:New(x, y)
end

---Converts a local x y position in a global x y position
---@param x number
---@param y number
---@return number x
---@return number y
function WMP_LocalToGlobal(x, y)
  return GPS:LocalToGlobal(x, y)
end

---Converts a global x y position in a local x y position
---@param x number
---@param y number
---@return number x
---@return number y
function WMP_GlobalToLocal(x, y)
  return GPS:GlobalToLocal(x, y)
end

---Gets a zone's map from it's zone id
---@param zoneId integer
---@return WMP_Map|nil
function WMP_GetZoneMap(zoneId)
  WMP_MESSENGER:Debug("WMP_GetZoneMap() Loading zone <<1>> from storage", zoneId)

  -- Get the map from storage
  -- TODO: change this to memory for performance
  local map = WMP_STORAGE:GetMap(zoneId)

  if map then
    WMP_MESSENGER:Debug("WMP_GetZoneMap() zone with id <<1>> loaded from storage", zoneId)
    return map
  end

  WMP_MESSENGER:Debug("WMP_GetZoneMap() zone with id <<1>> not in storage", zoneId)
  return nil
end
