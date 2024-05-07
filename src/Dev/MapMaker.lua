local GPS = LibGPS3

---Helper function for getting the players current zone
---@return integer
local function getPlayerZone()
  local zoneId, _, _, _ = GetUnitWorldPosition("player")
  ---@diagnostic disable-next-line: return-type-mismatch
  return zoneId
end

---Method for checking whether the player is in the same zone as the MapMaker is working on.
---@return boolean
local function isPlayerInSameZone(zoneId)
  return zoneId == getPlayerZone()
end

---Creates a new vector at the players current map position
---@return WMP_Vector
local function newVectorAtPosition()
  -- Always set the map to the player location
  SetMapToPlayerLocation()

  local x, y = GetMapPlayerPosition("player")
  local gX, gY = GPS:LocalToGlobal(x, y)

  ---@diagnostic disable-next-line: undefined-field
  return WMP_Vector:New(gX, gY)
end

---Helper class for creating map path nodes.
---@class WMP_Map_Maker
---@field private map WMP_Map -- The current map being worked on
---@field private previousNode integer -- The previous placed node.
local WMP_Map_Maker = ZO_InitializingObject:Subclass()

function WMP_Map_Maker:Initialize()
  self.map = nil
  self.previousNode = nil
end

---Setup variables to start listening for updates in this zone.
---
---Checks to see if there is already information for this zone.  If there is, load this information
---and start listening for node updates.
function WMP_Map_Maker:Start()
  -- Make sure it's not already running
  if self.map ~= nil then
    d('Warning: map has already been made.')
    return
  end

  if WMP_STORAGE:GetMap(getPlayerZone()) then
    d('Existing map found, loading it: ' .. getPlayerZone())
    self.map = WMP_STORAGE:GetMap(getPlayerZone())
  else
    d('Map maker running for zone: ' .. getPlayerZone())
    ---@diagnostic disable-next-line: undefined-field
    self.map = WMP_Map:New(getPlayerZone())
  end
end

---Resets the map maker for another round
function WMP_Map_Maker:Reset()
  self.map = nil
  self.previousNode = nil
  self:OnUpdate()
end

---Adds a new zone to the zone map. If `connect_previous` is set to true, the new node will be set
---as a neighbour.
---@param connect_previous boolean whether the new node is a neighbour of the previous node
function WMP_Map_Maker:AddNode(connect_previous)
  -- Check to make sure we are making a map
  if self.map == nil then
    d('You must start make a map!')
    return
  end

  -- Check the player is in the same zone as the map
  if isPlayerInSameZone(self.map:GetZoneId()) == false then
    d('You are not in the same zone!')
    return
  end

  local position = newVectorAtPosition()
  local nodeId, node = self.map:CreateNode(position)

  if nodeId == nil or node == nil then
    d('Failed to add a node')
    return
  end

  d('Added a new node (' .. node:toString() .. ')')

  -- Check to see if this should be connected to the previouslt placed node
  if connect_previous and self.previousNode ~= nil then
    self:AddConnection(nodeId, self.previousNode)
  end

  self.previousNode = nodeId

  self:OnUpdate()
end

---Removes a node with the specified node from the current map
---@param nodeId number
function WMP_Map_Maker:RemoveNode(nodeId)
  -- Check to make sure we are making a map
  if self.map == nil then
    d('You must start make a map!')
    return
  end

  self.map:RemoveNode(nodeId)

  if self.previousNode == nodeId then
    self.previousNode = nil
  end

  d('Removed node (' .. nodeId .. ')')
  self:OnUpdate()
end

---Adds a connection between two nodes
---@param nodeIdA number
---@param nodeIdB number
function WMP_Map_Maker:AddConnection(nodeIdA, nodeIdB)
  -- Check to make sure we are making a map
  if self.map == nil then
    d('You must start make a map!')
    return
  end

  self.map:AddConnection(nodeIdA, nodeIdB)
  d('Added connection between ' .. nodeIdA .. ' and ' .. nodeIdB)

  self:OnUpdate()
end

---Removes a connection between two nodes
---@param nodeIdA number
---@param nodeIdB number
function WMP_Map_Maker:RemoveConnection(nodeIdA, nodeIdB)
  -- Check to make sure we are making a map
  if self.map == nil then
    d('You must start make a map!')
    return
  end

  self.map:RemoveConnection(nodeIdA, nodeIdB)
  d('Removed connection between ' .. nodeIdA .. ' and ' .. nodeIdB)

  self:OnUpdate()
end

---Saves the current map to the storage
function WMP_Map_Maker:Save()
  if self.map == nil then
    d("There is no map data to be saved")
    return
  end

  -- Store the map
  WMP_STORAGE:StoreMap(self.map)
  d("Map saved.")
end

---Lodas the current zone map from storage
function WMP_Map_Maker:Load()
  self:Reset()
  local map = WMP_STORAGE:GetMap(getPlayerZone())

  if map == nil then
    d("No map data found for this zone.")
    return
  end

  -- Set the map
  self.map = map
  d("Map loaded.")
end

---Returns the map.
---@return WMP_Map|nil
function WMP_Map_Maker:GetMap()
  return self.map
end

do
  function WMP_Map_Maker:OnUpdate()
    WMP_DEBUG_RENDERER:Draw()
  end
end

---@type WMP_Map_Maker
---@diagnostic disable-next-line: undefined-field
WMP_MAP_MAKER = WMP_Map_Maker:New()
