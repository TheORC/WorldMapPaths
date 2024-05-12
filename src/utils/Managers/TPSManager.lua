local GPS = LibGPS3

---File containing logic for rendeing paths on the eso world map

---Class responsible for the rendering of paths on the world map
---@class WMP_TPSManager : TPS_PathManager
---@field private m_renderer WMP_Renderer
---@field private m_map WMP_Map|nil
---@field private m_playerTarget WMP_Vector
---@diagnostic disable-next-line: undefined-field
local WMP_TPSManager = TPS_PathManager:Subclass()

---Create a normal TPS path manager
function WMP_TPSManager:Initialize()
  TPS_PathManager.Initialize(self, WMP_PATH_RENDERER)

  self.m_map = nil
  self.m_playerTarget = nil
end

---Method called everytime a ping is added to the map
---@param pingType integer
---@param pingTag integer
---@param x number
---@param y number
---@param isPingOwner boolean
function WMP_TPSManager:OnPingAdded(pingType, pingTag, x, y, isPingOwner)
  WMP_MESSENGER:Debug("OnPingAdded() Type: <<1>> Tag: <<2>> X: <<3>> Y: <<4>> Owner: <<4>>", pingType, pingTag, x, y,
    isPingOwner)

  self.m_playerTarget = WMP_Vector:New(GPS:LocalToGlobal(x, y))
  self:DrawPath(self.m_playerTarget)
end

---Method called everytime a ping is removed from the map
---@param pingType integer
---@param pingTag integer
---@param x number
---@param y number
---@param isPingOwner boolean
function WMP_TPSManager:OnPingRemoved(pingType, pingTag, x, y, isPingOwner)
  WMP_MESSENGER:Debug("OnPingRemoved() Type: <<1>> Tag: <<2>> X: <<3>> Y: <<4>> Owner: <<4>>", pingType, pingTag, x, y,
    isPingOwner)

  self.m_playerTarget = nil
  self.m_renderer:Clear()
end

---Method called when the current map being viewed is changed
---MAPTYPE_COSMIC, MAPTYPE_DEPRECATED_1, MAPTYPE_NONE, MAPTYPE_SUBZONE, MAPTYPE_WORLD, MAPTYPE_ZONE
function WMP_TPSManager:OnMapChanged()
  -- Get the information about the current map
  local mapType = GetMapType()

  WMP_MESSENGER:Debug("OnMapChanged() Type: <<1>>", mapType)

  -- Not a map we draw yet
  if (mapType ~= MAPTYPE_ZONE and mapType ~= MAPTYPE_SUBZONE) or not WMP_IsPlayerInCurrentZone() then
    WMP_MESSENGER:Debug("OnMapChanged() wrong map type or player not in zone")
    self.m_renderer:Clear()
    return
  end

  -- Load the current map
  self.m_map = WMP_GetZoneMap(WMP_GetActiveMapZoneId())

  -- We have a target draw it
  if self.m_playerTarget then
    self:DrawPath(self.m_playerTarget)
  end
end

---Method called to draw the path on the map
---@param target WMP_Vector
function WMP_TPSManager:DrawPath(target)
  WMP_MESSENGER:Debug("DrawPath() Target location <<1>>", target)

  if not self.m_map or not target then
    WMP_MESSENGER:Debug("DrawPath() No map or not target.")
    return
  end

  local zoneId = WMP_GetPlayerZoneId()
  local startPos = WMP_GetPlayerLocalPos()
  local endPos = WMP_Vector:New(GPS:GlobalToLocal(target.x, target.y))

  local pathStart = self.m_map:GetClosestNode(startPos)
  local pathEnd = self.m_map:GetClosestNode(endPos)

  if not pathStart or not pathEnd then
    WMP_MESSENGER:Debug("DrawPath() No path start or path end.")
    return
  end

  WMP_MESSENGER:Debug("DrawPath() Path start: <<1>> Path end: <<2>>", pathStart, pathEnd)

  ---@diagnostic disable-next-line: undefined-field
  local path = WMP_ZonePath:New(zoneId, pathStart, pathEnd)

  self.m_renderer:SetPath(path)
  self.m_renderer:Draw()
end

do
  ---Calculates a path between zones based on their provided id.
  ---@param startId integer
  ---@param endId integer
  ---@return WMP_Path|nil
  function WMP_TPSManager:CalculateZonePath(startId, endId)
    WMP_MESSENGER:Debug("Calculating a zone path between <<1>> and <<2>>", startId, endId)
    return nil
  end
end

---@type WMP_TPSManager
---@diagnostic disable-next-line: undefined-field
WMP_TPS_MANAGER = WMP_TPSManager:New()
