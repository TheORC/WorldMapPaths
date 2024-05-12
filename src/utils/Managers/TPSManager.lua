local GPS = LibGPS3

---File containing logic for rendeing paths on the eso world map

---Class responsible for the rendering of paths on the world map
---@class WMP_TPSManager : TPS_PathManager
---@field private m_renderer WMP_Renderer
---@field private m_map WMP_Renderer
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
  ---@diagnostic disable-next-line: undefined-field
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
  self.m_playerTarget = nil
  self.m_renderer:Clear()
end

---Method called when the current map being viewed is changed
---MAPTYPE_COSMIC, MAPTYPE_DEPRECATED_1, MAPTYPE_NONE, MAPTYPE_SUBZONE, MAPTYPE_WORLD, MAPTYPE_ZONE
function WMP_TPSManager:OnMapChanged()
  -- Get the information about the current map
  local mapType = GetMapType()

  -- Not a map we draw yet
  if (mapType ~= MAPTYPE_ZONE and mapType ~= MAPTYPE_SUBZONE) or not WMP_IsPlayerInCurrentZone() then
    WMP_MESSENGER:Debug("OnMapChanged() wrong map type or player not in zone")
    self.m_renderer:Clear()
    return
  end

  -- Load the current map
  self:LoadZone(WMP_GetActiveMapZoneId())

  -- We have a target draw it
  if self.m_playerTarget then
    self:DrawPath(self.m_playerTarget)
  end
end

---Method called to draw the path on the map
---@param target WMP_Vector
function WMP_TPSManager:DrawPath(target)
  if not self:GetMap() or not target then
    return
  end

  local zoneId = WMP_GetPlayerZoneId()
  local startPos = WMP_GetPlayerLocalPos()
  ---@diagnostic disable-next-line: undefined-field
  local endPos = WMP_Vector:New(GPS:GlobalToLocal(target.x, target.y))

  local pathStart = self:GetMap():GetClosestNode(startPos)
  local pathEnd = self:GetMap():GetClosestNode(endPos)

  if not pathStart or not pathEnd then
    return
  end

  ---@diagnostic disable-next-line: undefined-field
  local path = WMP_ZonePath:New(zoneId, pathStart, pathEnd)

  self.m_renderer:SetPath(path)
  self.m_renderer:Draw()
end

---Returns the current map
---@return WMP_Map
function WMP_TPSManager:GetMap()
  return self.m_map
end

do
  ---Calculates a path between zones based on their provided id.
  ---@param startId integer
  ---@param endId integer
  ---@return WMP_Path
  function WMP_TPSManager:CalculateZonePath(startId, endId)
    return nil
  end

  ---Load the zone with the specified id.
  ---@param zoneId integer
  function WMP_TPSManager:LoadZone(zoneId)
    -- Don't load the map if it's already loaded
    if self.m_map and self.m_map:GetZoneId() == zoneId then
      WMP_MESSENGER:Debug("LoadZone() zone id is <<1>> is already loaded", zoneId)
      return
    end

    local map = WMP_STORAGE:GetMap(zoneId)
    if map then
      WMP_MESSENGER:Debug("LoadZone() zone with id <<1>> loaded from storage", zoneId)
      self.m_map = map
    else
      WMP_MESSENGER:Debug("LoadZone() zone with id <<1>> not in storage", zoneId)
    end
  end

  ---Gets the zone data for the given id
  ---@param zoneId integer
  ---@return WMP_Map|nil
  function WMP_TPSManager:GetZoneMap(zoneId)
    return WMP_STORAGE:GetMap(zoneId)
  end
end

---@type WMP_TPSManager
---@diagnostic disable-next-line: undefined-field
WMP_TPS_MANAGER = WMP_TPSManager:New()