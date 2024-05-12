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
