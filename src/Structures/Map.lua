---Method for generating a random number which can be used for node ids.
---@return integer
local function GenerateId()
  return math.random(1, 1000000)
end

---Creates a new node
---@param nodeId integer
---@param position WMP_Vector
---@return WMP_Node node
local function GenerateNode(nodeId, position)
  ---@diagnostic disable-next-line: undefined-field
  return WMP_Node:New(nodeId, position)
end

---Class representation of a map.
---@class WMP_Map
WMP_Map = ZO_InitializingObject:Subclass()

---Creates a new map data structure
---@param zoneId integer
function WMP_Map:Initialize(zoneId)
  self.zoneId = zoneId

  ---A list of all the map path nodes
  ---@type WMP_Node[]
  self.pathNodes = {}
end

---Create and add a new node to the map
---@param nodePosition WMP_Vector
---@return integer|nil nodeId, WMP_Node|nil node
function WMP_Map:CreateNode(nodePosition)
  -- Get a unique id for this node
  local nodeId = GenerateId()
  while self:GetNode(nodeId) ~= nil do
    nodeId = GenerateId()
  end

  local node = GenerateNode(nodeId, nodePosition)
  table.insert(self.pathNodes, node)

  return nodeId, node
end

---Adds a node to the map
---@param node WMP_Node
---@return integer|nil nodeId, WMP_Node|nil node
function WMP_Map:AddNode(node)
  -- This node already exists
  if self:GetNode(node:GetId()) ~= nil then
    return
  end

  table.insert(self.pathNodes, node)
end

---Removes a node from the map. This method also removes any neighbour connections
---@param nodeId integer
function WMP_Map:RemoveNode(nodeId)
  local nodeIndex = self:GetNodeIndex(nodeId)
  assert(nodeIndex ~= nil, "Unable to find node with id: " .. nodeId)

  local node = self.pathNodes[nodeIndex]
  local ids = {}
  for _, neighbour in ipairs(node:GetNeighbours()) do
    table.insert(ids, neighbour:GetId())
  end

  -- Loop through all the neighbours and remove the connections.
  for _, neighbourId in ipairs(ids) do
    self:RemoveConnection(nodeId, neighbourId)
  end

  table.remove(self.pathNodes, nodeIndex)
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
  local nodeIndex = self:GetNodeIndex(nodeId)

  if nodeIndex ~= nil then
    return self.pathNodes[nodeIndex]
  end

  return nil
end

---Returns the index of a node or nil if it can't be found
---@param nodeId integer
---@return integer|nil
function WMP_Map:GetNodeIndex(nodeId)
  for i, node in ipairs(self.pathNodes) do
    if node:GetId() == nodeId then
      return i
    end
  end
  return nil
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

---Format a map so it can saved to storage
---@param map WMP_Map
---@return table
function WMP_Map.MapToStorage(map)
  local storage = {}
  storage["zoneId"] = map:GetZoneId()
  storage["nodes"] = {}

  -- Loop through each node in the map and store it's data
  for i, node in ipairs(map:GetNodes()) do
    local n, position = {}, node:GetPosition()
    n["id"] = node:GetId()
    n["position"] = { ["x"] = position.x, ["y"] = position.y }
    n["neighbours"] = {}

    -- Loop through this nodes neighbours and store
    for j, neighbour in ipairs(node:GetNeighbours()) do
      table.insert(n["neighbours"], neighbour:GetId())
    end

    table.insert(storage["nodes"], n)
  end

  return storage
end

---Creates a map from stored map data
---@param mapData table
---@return WMP_Map
function WMP_Map.StorageToMap(mapData)
  local zoneId = mapData["zoneId"]
  local nodes = mapData["nodes"]

  local allConnections = {}

  ---@type WMP_Map
  ---@diagnostic disable-next-line: undefined-field
  local newMap = WMP_Map:New(zoneId)

  -- Load all nodes from storage
  for _, node in ipairs(nodes) do
    -- Parse information
    local nodeId, position, neighbours = node["id"], node["position"], node["neighbours"]

    -- Create node
    ---@diagnostic disable-next-line: undefined-field
    local newNode = WMP_Node:New(nodeId, WMP_Vector:New(position.x, position.y))

    -- Store node connections
    for _, neighbourId in ipairs(neighbours) do
      table.insert(allConnections, { [1] = nodeId, [2] = neighbourId })
    end

    -- Add to map
    newMap:AddNode(newNode)
  end

  -- Constrct map connections
  for _, connection in ipairs(allConnections) do
    newMap:AddConnection(connection[1], connection[2])
  end

  return newMap
end
