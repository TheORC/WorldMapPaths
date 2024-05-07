---File containing logic for rendeing paths on the eso world map

-- 1) Zone
-- 2) Tamrial
-- 3) Galaxy (Wont do)

local PingLib = LibMapPing2
local GPS = LibGPS3

---Class responsible for the rendering of paths on the world map
---@class WMP_Map_Manager
---@field renderer WMP_Renderer
---@field map WMP_Map
---@field is_debug boolean
---@field player_target WMP_MVector
local WMP_Map_Manager = ZO_InitializingObject:Subclass()

function WMP_Map_Manager:Initialize()
  self.renderer = WMP_Path_Render:New()
  self.map = nil
  self.is_debug = false
  self.player_target = nil
end

function WMP_Map_Manager:LateInitialize()
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
function WMP_Map_Manager:OnPingAdded(pingType, pingTag, x, y, isPingOwner)
  self.player_target = WMP_MVector:New(x, y, false)
  self:DrawPath(WMP_MVector:New(x, y, false))
end

---Method called everytime a ping is removed from the map
---@param pingType integer
---@param pingTag integer
---@param x number
---@param y number
---@param isPingOwner boolean
function WMP_Map_Manager:OnPingRemoved(pingType, pingTag, x, y, isPingOwner)
  self.player_target = nil
  self.renderer:Clear()
end

---Method called when the current map being viewed is changed
---MAPTYPE_COSMIC, MAPTYPE_DEPRECATED_1, MAPTYPE_NONE, MAPTYPE_SUBZONE, MAPTYPE_WORLD, MAPTYPE_ZONE
function WMP_Map_Manager:OnMapChanged()
  -- Get the information about the current map
  local mapType = GetMapType()

  -- Not a map we draw yet
  if (mapType ~= MAPTYPE_ZONE and mapType ~= MAPTYPE_SUBZONE) or not self:PlayerInCurrentZone() then
    self.renderer:Clear()
    return
  end

  -- Load the current map
  self:LoadZone(self:GetCurrentZoneId())
end

---Method called to draw the path on the map
---@param target WMP_MVector
function WMP_Map_Manager:DrawPath(target)
  if not self.map or not target then
    return;
  end

  local startPos = self:GetPlayerPosition()
  local endPos = target


  local pathStart = self.map:GetClosesNode(WMP_MVector.ToLocal(startPos))
  local pathEnd = self.map:GetClosesNode(WMP_MVector.ToLocal(endPos))

  if not pathStart or not pathEnd then
    d('Unable to find path')
    return
  end

  local path = WMP_ZonePath:New(pathStart, pathEnd)

  self.renderer:SetPath(path)
  self.renderer:Draw()
end

---Toggle the renderer between the debug render and path renderer
function WMP_Map_Manager:ToggleDebug()
  self.is_debug = not self.is_debug

  if self.is_debug then
    self.renderer = WMP_Debug_Render:New()
  else
    self.renderer = WMP_Path_Render:New()
  end
end

do
  ---Load the zone with the specified id.
  ---@param zoneId integer
  function WMP_Map_Manager:LoadZone(zoneId)
    -- Don't load the map if it's already loaded
    if self.map and self.map:GetZoneId() == zoneId then
      return
    end

    local map = WMP_STORAGE:GetMap(zoneId)

    if map then
      d('Map loaded: ' .. zoneId)
      self.map = map
    end
  end

  ---Returns the id of the current viewed zone
  ---@return integer
  function WMP_Map_Manager:GetCurrentZoneId()
    local measure = GPS:GetCurrentMapMeasurement()
    return measure:GetZoneId()
  end

  ---Returns the id of the player's current zone.
  ---@return integer
  function WMP_Map_Manager:GetPlayerZoneId()
    local zoneId, _, _, _ = GetUnitWorldPosition("player")
    return zoneId
  end

  ---Checks if the player is in the currently viewed zone.
  ---@return boolean
  function WMP_Map_Manager:PlayerInCurrentZone()
    return self:GetCurrentZoneId() == self:GetPlayerZoneId()
  end

  ---Get's the player current location
  ---@return WMP_MVector
  function WMP_Map_Manager:GetPlayerPosition()
    local playerX, playerY = GetMapPlayerPosition("player")
    return WMP_MVector:New(playerX, playerY, false)
  end
end

---@type WMP_Map_Manager
WMP_MAP_MANAGER = WMP_Map_Manager:New()
