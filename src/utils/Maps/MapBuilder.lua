---Method for generating a random number which can be used for node ids.
---@return integer
local function GenerateId()
  return math.random(1, 1000000)
end

---Class providing an interface for storing path information.
---@class WMP_MapBuilder
WMP_MapBuilder = ZO_InitializingObject:Subclass()

---Creates a new path builder class
function WMP_MapBuilder:Initialize()
  ---@type WMP_Node[]
  self.pathNodes = {}
end

---Adds a new node to the map
---@param position WMP_Vector
---@return integer nodeId, WMP_Node node
function WMP_MapBuilder:CreateNode(position)
  assert(position ~= nil, "Position must be defined")

  local newId = self:GetNextId()
  ---@diagnostic disable-next-line: undefined-field
  local newNode = WMP_Node:New(newId, position)
  table.insert(self.pathNodes, newNode)

  return newId, newNode
end

---Removes a node from the map.
---@param nodeId integer
function WMP_MapBuilder:RemoveNode(nodeId)
  assert(nodeId ~= nil, 'Node id must be defined')

  local nodeIndex = self:GetNodeIndex(nodeId)

  -- Node not found
  if nodeIndex == nil then
    return
  end

  local node = self.pathNodes[nodeIndex]
  local ids = {}

  for _, neighbour in ipairs(self.pathNodes) do
    if neighbour:HasNeighbour(nodeId) then
      table.insert(ids, neighbour:GetId())
    end
  end

  -- for _, neighbour in ipairs(node:GetNeighbours()) do
  --  table.insert(ids, neighbour:GetId())
  -- end

  -- Loop through all the neighbours and remove the connections.
  for _, neighbourId in ipairs(ids) do
    self:RemoveConnection(nodeId, neighbourId)
  end

  table.remove(self.pathNodes, nodeIndex)
end

---Adds an existing node to the map
---@param node WMP_Node
function WMP_MapBuilder:LoadNode(node)
  assert(node ~= nil, 'Node must be defined')

  -- This node already exists
  if self:GetNode(node:GetId()) ~= nil then
    return
  end

  table.insert(self.pathNodes, node)
end

---Adds a connection between two nodes.
---@param nodeA integer
---@param nodeB integer
---@param bothWays boolean
---@return boolean
function WMP_MapBuilder:AddConnection(nodeA, nodeB, bothWays)
  assert(nodeA ~= nil, 'NodeA must be defined')
  assert(nodeB ~= nil, 'NodeB must be defined')
  assert(bothWays ~= nil, 'Both ways must be defined')

  local a, b = self:GetNode(nodeA), self:GetNode(nodeB)

  if a == nil or b == nil then
    return false
  end

  a:AddNeighbour(b)

  if bothWays then
    b:AddNeighbour(a)
  end

  return true
end

---Removes the connection between two nodes.
---@param nodeA integer
---@param nodeB integer
---@return boolean
function WMP_MapBuilder:RemoveConnection(nodeA, nodeB)
  assert(nodeA ~= nil, 'NodeA must be defined')
  assert(nodeB ~= nil, 'NodeB must be defined')

  local a, b = self:GetNode(nodeA), self:GetNode(nodeB)

  if a == nil or b == nil then
    return false
  end

  a:RemoveNeighbour(b)
  b:RemoveNeighbour(a)
  return true
end

---Returns the node with the shortest distance to the position
---@param position WMP_Vector
---@return WMP_Node|nil
function WMP_MapBuilder:GetClosestNode(position)
  local closest, node = 1 / 0, nil
  for _, n in ipairs(self:GetNodes()) do
    local distance = WMP_Vector.dist(position, n:GetLocalPosition())
    if distance < closest then
      closest = distance
      node = n
    end
  end
  return node
end

---Returns a node bassed on it's id.
---@param nodeId integer
---@return WMP_Node|nil
function WMP_MapBuilder:GetNode(nodeId)
  local nodeIndex = self:GetNodeIndex(nodeId)

  if nodeIndex ~= nil then
    return self.pathNodes[nodeIndex]
  end

  return nil
end

---Returns the list of path nodes
---@return WMP_Node[]
function WMP_MapBuilder:GetNodes()
  return self.pathNodes
end

do
  ---Returns the index of a node or nil if it can't be found
  ---@param nodeId integer
  ---@return integer|nil
  function WMP_MapBuilder:GetNodeIndex(nodeId)
    for i, node in ipairs(self.pathNodes) do
      if node:GetId() == nodeId then
        return i
      end
    end
    return nil
  end

  ---Gets a unique id that has not already been used.
  ---@return integer
  function WMP_MapBuilder:GetNextId()
    -- Get a unique id for this node
    local nodeId = GenerateId()
    while self:GetNode(nodeId) ~= nil do
      nodeId = GenerateId()
    end
    return nodeId
  end
end

---Converts a path into a storable object
---@param map WMP_MapBuilder
---@return table
function WMP_MapBuilder.ToStorage(map)
  assert(false, "To storage needs to be extended")
  return {}
end

---Converts a stored object into a path
---@param mapData table
---@return any
function WMP_MapBuilder.FromStorage(mapData)
  assert(false, "From storage needs to be extended")
  return {}
end
