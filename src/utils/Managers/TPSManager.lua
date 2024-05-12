---File containing logic for rendeing paths on the eso world map

-- 1) Zone
-- 2) Tamrial
-- 3) Galaxy (Wont do)

local PingLib = LibMapPing2
local GPS = LibGPS3

---Class responsible for the rendering of paths on the world map
---@class WMP_TPSManager
---@field renderer WMP_Renderer
---@field map WMP_Map
---@field is_debug boolean
---@field player_target WMP_Vector
local WMP_TPSManager = ZO_InitializingObject:Subclass()

function WMP_TPSManager:Initialize()
  self.map = nil
  self.player_target = nil
  self.renderer = WMP_PATH_RENDERER -- WMP_DEBUG_RENDERER -- WMP_PATH_RENDERER
end

function WMP_TPSManager:LateInitialize()
  local function OnPingAdded(...)
    self:OnPingAdded(...)
  end

  local function OnPingRemoved(...)
    self:OnPingRemoved(...)
  end

  local function OnMapChanged()
    self:OnMapChanged()
  end

  PingLib:RegisterCallback("AfterPingAdded", OnPingAdded)
  PingLib:RegisterCallback("AfterPingRemoved", OnPingRemoved)

  CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", OnMapChanged)
  CALLBACK_MANAGER:RegisterCallback("OnWorldMapModeChanged", OnMapChanged)
end

---Method called everytime a ping is added to the map
---@param pingType integer
---@param pingTag integer
---@param x number
---@param y number
---@param isPingOwner boolean
function WMP_TPSManager:OnPingAdded(pingType, pingTag, x, y, isPingOwner)
  self.player_target = WMP_Vector:New(GPS:LocalToGlobal(x, y))
  local lX, lY = self.player_target.x, self.player_target.y

  if self:GetPlayerZoneId() == self:GetZoneIdFromPosition(lX, lY) then
    d('In the same zone')
  else
    d('in multiple zones!')
  end

  self:DrawPath(self.player_target)
end

---Method called everytime a ping is removed from the map
---@param pingType integer
---@param pingTag integer
---@param x number
---@param y number
---@param isPingOwner boolean
function WMP_TPSManager:OnPingRemoved(pingType, pingTag, x, y, isPingOwner)
  self.player_target = nil
  self.renderer:Clear()
end

---Method called when the current map being viewed is changed
---MAPTYPE_COSMIC, MAPTYPE_DEPRECATED_1, MAPTYPE_NONE, MAPTYPE_SUBZONE, MAPTYPE_WORLD, MAPTYPE_ZONE
function WMP_TPSManager:OnMapChanged()
  -- Get the information about the current map
  local mapType = GetMapType()

  -- Not a map we draw yet
  if (mapType ~= MAPTYPE_ZONE and mapType ~= MAPTYPE_SUBZONE) or not self:PlayerInCurrentZone() then
    self.renderer:Clear()
    return
  end

  -- Load the current map
  self:LoadZone(self:GetCurrentZoneId())

  -- We have a target draw it
  if self.player_target or WMP_DEBUG_CONTROLLER:IsDebug() then
    self:DrawPath(self.player_target)
  end
end

---Method called to draw the path on the map
---@param target WMP_Vector
function WMP_TPSManager:DrawPath(target)
  -- The render handles most of this logic itself.
  if WMP_DEBUG_CONTROLLER:IsDebug() then
    self.renderer:Draw()
    return
  end

  if not self:GetMap() or not target then
    return
  end

  local zoneId = self:GetPlayerZoneId()
  local startPos = self:GetPlayerPosition()
  local endPos = WMP_Vector:New(GPS:GlobalToLocal(target.x, target.y))

  local pathStart = self:GetMap():GetClosestNode(startPos)
  local pathEnd = self:GetMap():GetClosestNode(endPos)

  if not pathStart or not pathEnd then
    return
  end

  local path = WMP_ZonePath:New(zoneId, pathStart, pathEnd)

  self.renderer:SetPath(path)
  self.renderer:Draw()
end

---Toggle the renderer between the debug render and path renderer
function WMP_TPSManager:UpdateDebugState()
  -- Clear the existing renderer
  if self.renderer then
    self.renderer:Clear()
  end

  if WMP_DEBUG_CONTROLLER:IsDebug() then
    self.renderer = WMP_DEBUG_RENDERER
  else
    self.renderer = WMP_PATH_RENDERER
  end
end

---Returns the current map
---@return WMP_Zone
function WMP_TPSManager:GetMap()
  if WMP_DEBUG_CONTROLLER:IsDebug() then
    return WMP_DEBUG_CONTROLLER:GetActiveMap()
  else
    return self.map
  end
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
    -- Not responsible for the map in debug
    if WMP_DEBUG_CONTROLLER:IsDebug() then
      return
    end

    -- Don't load the map if it's already loaded
    if self.map and self.map:GetZoneId() == zoneId then
      return
    end

    local map = WMP_STORAGE:GetMap(zoneId)
    if map then
      self.map = map
    end
  end

  ---Returns the id of the current viewed zone
  ---@return integer
  function WMP_TPSManager:GetCurrentZoneId()
    local measure = GPS:GetCurrentMapMeasurement()
    return measure:GetZoneId()
  end

  ---Returns the id of the player's current zone.
  ---@return integer
  function WMP_TPSManager:GetPlayerZoneId()
    local zoneId, _, _, _ = GetUnitWorldPosition("player")
    return zoneId
  end

  ---Checks if the player is in the currently viewed zone.
  ---@return boolean
  function WMP_TPSManager:PlayerInCurrentZone()
    return self:GetCurrentZoneId() == self:GetPlayerZoneId()
  end

  ---Get's the player current location
  ---@return WMP_Vector
  function WMP_TPSManager:GetPlayerPosition()
    return WMP_Vector:New(GetMapPlayerPosition("player"))
  end

  ---Get's the zone id at the provided position.
  ---@param x number
  ---@param y number
  ---@return integer
  function WMP_TPSManager:GetZoneIdFromPosition(x, y)
    GPS:PushCurrentMap()
    GPS:SetMapToRootMap(x, y)
    GPS:MapZoomInMax(x, y)

    local zoneId = self:GetCurrentZoneId()
    GPS:PopCurrentMap()

    return zoneId
  end

  ---Gets the zone data for the given id
  ---@param zoneId integer
  ---@return WMP_Map|nil
  function WMP_TPSManager:GetZoneMap(zoneId)
    return WMP_STORAGE:GetMap(zoneId)
  end
end

---@type WMP_TPSManager
WMP_TPS_MANAGER = WMP_TPSManager:New()
