local GPS = LibGPS3

---File containing logic for rendeing paths on the eso world map

---Class responsible for the rendering of paths on the world map
---@class WMP_TPSManager : TPS_PathManager
---@field private m_renderer WMP_Renderer
---@field private m_map WMP_Map|nil
---@field private m_world WMP_World|nil
---@field private m_worldPath WMP_WorldPath|nil
---@field private m_zonePath WMP_ShortestPath|nil
---@field private m_playerTarget WMP_Vector|nil
---@field private m_playerPosition WMP_Vector|nil

---@diagnostic disable-next-line: undefined-field
local WMP_TPSManager = TPS_PathManager:Subclass()

---Create a normal TPS path manager
function WMP_TPSManager:Initialize()
  TPS_PathManager.Initialize(self, WMP_PATH_RENDERER)

  self.m_zone = nil
  self.m_playerTarget = nil
  self.m_playerPosition = nil
  self.m_worldPath = nil
  self.m_zonePath = nil
end

---Create a normal TPS path manager
function WMP_TPSManager:LateInitialize()
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

  -- Store the player position and destination
  self.m_playerPosition = WMP_GetPlayerGlobalPos()
  self.m_playerTarget = WMP_Vector:New(GPS:LocalToGlobal(x, y))

  WMP_MESSENGER:Debug("WMP_TPSManager:OnPingAdded() Player target in zone: <<1>>",
    WMP_GetZoneIdFromGlobalVector(self.m_playerTarget))

  -- Calculate the path data
  self:CalculatePaths()
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
  WMP_MESSENGER:Debug("WMP_TPSManager:OnMapChanged() Type: <<1>>", mapType)

  self.m_playerPosition = WMP_GetPlayerGlobalPos() -- Always recalculate on player position

  self:CalculatePaths()
  self:DrawPath()
end

---Method called to draw the path on the map
function WMP_TPSManager:DrawPath()
  self.m_renderer:SetPath(nil)

  local mapType = GetMapType()

  if self.m_zonePath and (mapType == MAPTYPE_ZONE or mapType == MAPTYPE_SUBZONE) then
    WMP_MESSENGER:Debug("WMP_TPSManager:DrawPath() Draw zone path")
    self.m_renderer:SetPath(self.m_zonePath)
  elseif self.m_worldPath then
    WMP_MESSENGER:Debug("WMP_TPSManager:DrawPath() Draw world path")
    self.m_renderer:SetPath(self.m_worldPath)
  end

  self.m_renderer:Draw()
end

do
  ---Perform the nessessery calcualtions to figure out which map path we should be drawing
  function WMP_TPSManager:CalculatePaths()
    if not self.m_playerTarget or not self.m_playerPosition then
      return
    end

    -- Reset the zone map
    self.m_zonePath = nil
    self.m_worldPath = self:CalculateWorldPath(self.m_playerPosition, self.m_playerTarget)

    local mapType = GetMapType()
    local activeMapZoneId = WMP_GetActiveMapZoneId()
    local targetZoneId = WMP_GetZoneIdFromGlobalVector(self.m_playerTarget)

    if mapType == MAPTYPE_ZONE or mapType == MAPTYPE_SUBZONE then
      local activeMap = WMP_GetZoneMap(activeMapZoneId)

      if not activeMap then
        return
      end

      local startNode, endNode

      if not self.m_worldPath then
        --- The player is in the same zone as the target

        startNode, endNode = activeMap:GetClosestNode(WMP_GlobalToLocalVec(self.m_playerPosition)),
            activeMap:GetClosestNode(WMP_GlobalToLocalVec(self.m_playerTarget))
      else
        local zoneNodes = self.m_worldPath:GetZoneNodes(activeMapZoneId)

        --- The player is not in the same zone as the target
        if not zoneNodes then
          return
        end

        -- Is player zone
        if WMP_IsPlayerInCurrentZone() then
          startNode = activeMap:GetClosestNode(WMP_GlobalToLocalVec(self.m_playerPosition))
          endNode = activeMap:GetClosestNode(WMP_GlobalToLocalVec(zoneNodes[1]:GetPosition()))
        end

        -- Is target zone
        if targetZoneId == activeMapZoneId then
          -- The target is in this zone
          startNode = activeMap:GetClosestNode(WMP_GlobalToLocalVec(zoneNodes[1]:GetPosition()))
          endNode = activeMap:GetClosestNode(WMP_GlobalToLocalVec(self.m_playerTarget))
        end

        -- This is a between zone
        if not startNode and not endNode then
          startNode = activeMap:GetClosestNode(WMP_GlobalToLocalVec(zoneNodes[1]:GetPosition()))
          endNode = activeMap:GetClosestNode(WMP_GlobalToLocalVec(zoneNodes[#zoneNodes]:GetPosition()))
        end
      end

      if startNode and endNode then
        ---@diagnostic disable-next-line: undefined-field
        self.m_zonePath = WMP_ShortestPath:New(startNode, endNode)
      end
    end
  end

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
