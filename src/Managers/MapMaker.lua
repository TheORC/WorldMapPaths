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
  local x, y = GetMapPlayerPosition("player")
  ---@diagnostic disable-next-line: undefined-field
  return WMP_Vector:New(x, y)
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
    d('Warning: map already being made.')
    return
  end

  ---@diagnostic disable-next-line: undefined-field
  self.map = WMP_Map:New(getPlayerZone())
  d('Map maker running for zone: ' .. self.map:GetZoneId())
end

---Resets the map maker for another round
function WMP_Map_Maker:Reset()
  self.map = nil;
  self.previousNode = nil
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
    return;
  end

  local position = newVectorAtPosition()
  local nodeId, node = self.map:AddPathNode(position)

  if nodeId == nil or node == nil then
    d('Failed to add a node');
    return
  end

  d('Added a new node (' .. node:toString() .. ')')

  -- Check to see if this should be connected to the previouslt placed node
  if connect_previous and self.previousNode ~= nil then
    self:AddConnection(nodeId, self.previousNode)
  end

  self.previousNode = nodeId
end

---Removes a node with the specified node from the current map
---@param nodeId any
function WMP_Map_Maker:RemoveNode(nodeId)
  -- Check to make sure we are making a map
  if self.map == nil then
    d('You must start make a map!')
    return
  end

  self.map:RemoveNode(nodeId)
end

---Adds a connection between two nodes
---@param nodeIdA any
---@param nodeIdB any
function WMP_Map_Maker:AddConnection(nodeIdA, nodeIdB)
  -- Check to make sure we are making a map
  if self.map == nil then
    d('You must start make a map!')
    return
  end

  self.map:AddConnection(nodeIdA, nodeIdB)
  d('Added connection between ' .. nodeIdA .. ' and ' .. nodeIdB)
end

---Returns the map.
---@return WMP_Map|nil
function WMP_Map_Maker:GetMap()
  return self.map
end

---@type WMP_Map_Maker
---@diagnostic disable-next-line: undefined-field
WMP_MAP_MAKER = WMP_Map_Maker:New()
