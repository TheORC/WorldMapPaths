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

  self.m_zone = nil
  self.m_playerTarget = nil
  self.m_worldPath = nil
end

---Create a normal TPS path manager
function WMP_TPSManager:LateInitialize()
  ---@diagnostic disable-next-line: assign-type-mismatch
  self.m_world = WMP_GetZoneMap(0)
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

  -- Store the player destination
  self.m_playerTarget = WMP_Vector:New(GPS:LocalToGlobal(x, y))
  self.m_playerPosition = WMP_GetPlayerGlobalPos()

  WMP_MESSENGER:Debug("WMP_TPSManager:OnPingAdded() Player target in zone: <<1>>",
    WMP_GetZoneIdFromGlobalVector(self.m_playerTarget))

  -- Calculate a world path
  self.m_worldPath = self:CalculateWorldPath(self.m_playerPosition, self.m_playerTarget)

  -- Draw
  self:DrawPath()
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
  if (mapType ~= MAPTYPE_ZONE and mapType ~= MAPTYPE_SUBZONE and mapType ~= MAPTYPE_WORLD) then
    WMP_MESSENGER:Debug("OnMapChanged() wrong map type.")
    self.m_renderer:Clear()
    return
  end

  -- Load the current map
  self.m_zone = WMP_GetZoneMap(WMP_GetActiveMapZoneId())

  -- We have a target draw it
  if self.m_playerTarget then
    self:DrawPath()
  end
end

---Method called to draw the path on the map
function WMP_TPSManager:DrawPath()
  local startPos, endPos

  -- There is not world data, just draw a path
  if not self.m_worldPath then
    WMP_MESSENGER:Debug("WMP_TPSManager:DrawPath() Draw zone path")

    -- Check this zone is the target zone
    if WMP_GetActiveMapZoneId() ~= WMP_GetPlayerZoneId() then
      return
    end

    startPos = WMP_GetPlayerLocalPos()
    endPos = WMP_Vector:New(WMP_GlobalToLocal(self.m_playerTarget.x, self.m_playerTarget.y))
  else
    WMP_MESSENGER:Debug("WMP_TPSManager:DrawPath() Draw world path")
    -- TODO: Draw path dependent on which zone is being looked at.

    self.m_renderer:SetPath(self.m_worldPath)
    self.m_renderer:Draw()
  end

  --local pathStart = self.m_zone:GetClosestNode(startPos)
  --local pathEnd = self.m_zone:GetClosestNode(endPos)

  --if not pathStart or not pathEnd then
  --  WMP_MESSENGER:Debug("DrawPath() No path start or path end.")
  --  return
  --end

  --WMP_MESSENGER:Debug("DrawPath() Path start: <<1>> Path end: <<2>>", pathStart, pathEnd)

  ---@diagnostic disable-next-line: undefined-field
  --local path = WMP_ShortestPath:New(pathStart, pathEnd)
end

do
  ---Calculates the world path between zones
  ---@param startPosition WMP_Vector
  ---@param endPosition WMP_Vector
  ---@return WMP_WorldPath|nil
  function WMP_TPSManager:CalculateWorldPath(startPosition, endPosition)
    if not self.m_world then
      WMP_MESSENGER:Error("WMP_TPSManager:CalculateWorldPath() There is not world map!")
      return nil
    end

    -- Get the path target zones
    local startId, endId = WMP_GetZoneIdFromGlobalVector(startPosition), WMP_GetZoneIdFromGlobalVector(endPosition)

    WMP_MESSENGER:Debug("WMP_TPSManager:CalculateWorldPath() Calculating world path between zones <<1>> and <<2>>.",
      startId, endId)

    -- Get the start and end nodes in the world
    local worldPath = self.m_world:GetPath(startId, endId)

    if not worldPath then
      WMP_MESSENGER:Debug("WMP_TPSManager:CalculateWorldPath() No path found.")
      return nil
    end

    return worldPath
  end
end

---@type WMP_TPSManager
---@diagnostic disable-next-line: undefined-field
WMP_TPS_MANAGER = WMP_TPSManager:New()
