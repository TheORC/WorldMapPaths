---Method for generating a hash bassed on a nodes x and y positions.
---The has max size is set at 8 characters
---@param x number
---@param y number
---@return integer
local function GenerateHash(x, y)
  return math.random(1, 1000000)
end

---Creates a new node
---@param position WMP_Vector
---@return integer nodeId, WMP_Node node
local function CreateNode(position)
  d('Creating node pos: x: ' .. position.x .. ' y: ' .. position.y)

  local nodeId = GenerateHash(position.x, position.y)
  ---@diagnostic disable-next-line: undefined-field
  return nodeId, WMP_Node:New(nodeId, position)
end

---Class representation of a map.
---@class WMP_Map
WMP_Map = ZO_InitializingObject:Subclass()

---Creates a new map data structure
---@param zoneId integer
function WMP_Map:Initialize(zoneId)
  self.zoneId = zoneId

  ---A list of all the enterences into the map
  ---@type WMP_Node[]
  self.enterences = {}

  ---A list of all the map path nodes
  ---@type WMP_Node[]
  self.pathNodes = {}
end

---Adds a new enterence node to the map
---@param enterencePosition WMP_Vector
---@return integer|nil nodeId, WMP_Node|nil node
function WMP_Map:AddEnterence(enterencePosition)
  -- Make sure the node does not already exist
  if self:GetNode(GenerateHash(enterencePosition.x, enterencePosition.y)) ~= nil then
    d('Node with the same Id already exists!')
    return nil, nil
  end

  local nodeId, node = CreateNode(enterencePosition)
  table.insert(self.enterences, node)
  return nodeId, node
end

---Adds a new enterence node to the map
---@param nodePosition WMP_Vector
---@return integer|nil nodeId, WMP_Node|nil node
function WMP_Map:AddPathNode(nodePosition)
  -- Make sure the node does not already exist
  if self:GetNode(GenerateHash(nodePosition.x, nodePosition.y)) ~= nil then
    d('Node with the same Id already exists!')
    return nil, nil
  end

  local nodeId, node = CreateNode(nodePosition)
  table.insert(self.pathNodes, node)

  return nodeId, node
end

---Remove a node from the map
---@param nodeId integer
function WMP_Map:RemoveNode(nodeId)
  local node = self:GetNode(nodeId)
  assert(node ~= nil, "Unable to find node with id: " .. nodeId)

  -- Loop through all the neighbours and remove the connections.
  for _, neighbour in ipairs(node:GetNeighbours()) do
    self:RemoveConnection(node:GetId(), neighbour:GetId())
  end
end

---Adds a connection between two nodes such that they become neighbours.
---@param nodeIdA number
---@param nodeIdB number
function WMP_Map:AddConnection(nodeIdA, nodeIdB)
  local nodeA, nodeB = self:GetNode(nodeIdA), self:GetNode(nodeIdB)

  assert(nodeA ~= nil, 'Unable to find node with id: ' .. nodeIdA)
  assert(nodeB ~= nil, 'Unable to find node with id: ' .. nodeIdB)

  nodeA:AddNeighbour(nodeB)
  nodeB:AddNeighbour(nodeA)
end

---Removes a connection between two nodes.
---@param nodeIdA number
---@param nodeIdB number
function WMP_Map:RemoveConnection(nodeIdA, nodeIdB)
  local nodeA, nodeB = self:GetNode(nodeIdA), self:GetNode(nodeIdB)

  assert(nodeA ~= nil, 'Unable to find node with id: ' .. nodeIdA)
  assert(nodeB ~= nil, 'Unable to find node with id: ' .. nodeIdB)

  nodeA:RemoveNeighbour(nodeB)
  nodeB:RemoveNeighbour(nodeA)
end

---Returns a node bassed on it's id.
---@param nodeId integer
---@return WMP_Node|nil
function WMP_Map:GetNode(nodeId)
  for _, node in ipairs(self.pathNodes) do
    if node:GetId() == nodeId then
      return node
    end
  end
  return nil
end

---Returns the enterences into the map
---@return WMP_Node[]
function WMP_Map:GetEnterences()
  return self.enterences
end

---Returns the list of map path nodes
---@return WMP_Node[]
function WMP_Map:GetNodes()
  return self.pathNodes
end

---Retunrs the map's zone id
---@return integer
function WMP_Map:GetZoneId()
  return self.zoneId
end
