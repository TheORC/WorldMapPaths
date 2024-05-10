local GPS = LibGPS3

---Returns the zone id the player is currently in
---@return integer
function WMP_GetPlayerZone()
  local zoneId, _, _, _ = GetUnitWorldPosition("player")
  ---@diagnostic disable-next-line: return-type-mismatch
  return zoneId
end

---Returns whether the player is in the provided zone.
---@param zoneId integer
---@return boolean
function WMP_IsPlayerInZone(zoneId)
  return zoneId == WMP_GetPlayerZone()
end

---Returns the player current local position
---@return WMP_Vector
function WMP_GetPlayerLocalPos()
  local x, y = GetMapPlayerPosition("player")
  return WMP_Vector:New(x, y)
end

---Returns the player current gloabl position
---@return WMP_Vector
function WMP_GetPlayerGlobalPos()
  local position = WMP_GetPlayerLocalPos()
  local x, y = GPS:LocalToGlobal(position.x, position.y)
  return WMP_Vector:New(x, y)
end
