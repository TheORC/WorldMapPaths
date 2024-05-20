---Class representation of a word map.
---This class is responsible for drawing the connections between zones.
---@class WMP_World : WMP_Map
---@field pathNodes WMP_ZoneNode[]
---@diagnostic disable-next-line: undefined-field
WMP_World = WMP_Map:Subclass()

---Create a new data strucuture to contain world path connections
function WMP_World:Initialize()
  WMP_Map.Initialize(self, 0)
end

---Gets the shortest path between two zones bassed on their ids
---@param startZone integer
---@param endZone integer
---@return WMP_WorldPath|nil
function WMP_World:GetPath(startZone, endZone)
  if startZone == endZone then
    WMP_MESSENGER:Debug("WMP_World:GetPath() Unable to caluclate a world path between the same zones.")
    return nil
  end

  WMP_MESSENGER:Debug("WMP_World:GetPath() Getting path between zones <<1>> and <<2>>.", startZone, endZone)

  local startNodes = self:GetNodesInZone(startZone)
  local endNodes = self:GetNodesInZone(endZone)

  -- No path found
  if #startNodes == 0 or #endNodes == 0 then
    WMP_MESSENGER:Debug("WMP_World:GetPath() Missing world nodes in one(both) zones.")
    return nil
  end

  local allPaths, pathCount, shortestPathCount = {}, 0, 1 / 0
  for _, node in ipairs(startNodes) do
    for _, other in ipairs(endNodes) do
      -- curDistance = WMP_Vector.dist(node:GetPosition(), other:GetPosition())
      --- @type WMP_ShortestPath
      local path = WMP_ShortestPath:New(node, other)
      pathCount = path:GetLineCount()

      if not allPaths[pathCount] then
        allPaths[pathCount] = {}
      end

      table.insert(allPaths[pathCount], path)

      if pathCount < shortestPathCount then
        shortestPathCount = pathCount
      end
    end
  end

  local shortestDistance, shortestStart = 1 / 0, nil
  for _, path in ipairs(allPaths[shortestPathCount]) do
    if path:GetLength() < shortestDistance then
      shortestDistance = path:GetLength()
      shortestStart = path.startNode
    end
  end

  WMP_MESSENGER:Debug("WMP_World:GetPath() Start and end nodes found <<1>> <<2>>. Calculating path.",
    shortestStart:GetId(), endNodes[1]:GetId())

  ---@type WMP_WorldPath
  ---@diagnostic disable-next-line: undefined-field
  local worldPath = WMP_WorldPath:New(shortestStart, endNodes[1])

  if not worldPath:HasPath() then
    WMP_MESSENGER:Debug("WMP_World:GetPath() No path found.")
    return nil
  end

  WMP_MESSENGER:Debug("WMP_World:GetPath() Path found.")

  return worldPath
end

---Create a new node bassed on a zone
---@param zoneId any
---@param position any
---@return integer
---@return WMP_ZoneNode
function WMP_World:CreateNode(zoneId, position)
  assert(position ~= nil, "zoneId must be defined")
  assert(position ~= nil, "Position must be defined")

  local newId = self:GetNextId()
  ---@type WMP_ZoneNode
  ---@diagnostic disable-next-line: undefined-field
  local newNode = WMP_ZoneNode:New(zoneId, newId, position)
  table.insert(self.pathNodes, newNode)

  return newId, newNode
end

---Load an existing node into the world map
---@param node WMP_ZoneNode
function WMP_World:LoadNode(node)
  assert(getmetatable(node) == WMP_ZoneNode, 'Node must be of type WMP_ZoneNode')
  WMP_Map.LoadNode(self, node)
end

do
  ---Method for fetching a node in a zone
  ---@param zoneId integer
  ---@return WMP_ZoneNode[]
  function WMP_World:GetNodesInZone(zoneId)
    local targets = {}
    for _, node in ipairs(self.pathNodes) do
      if node:GetZoneId() == zoneId then
        table.insert(targets, node)
      end
    end

    return targets
  end
end

---Format a world map so it can saved to storage
---@param map WMP_World
---@return table
function WMP_World:MapToStorage(map)
  ---@diagnostic disable-next-line: undefined-field
  assert(map:IsInstanceOf(WMP_World), 'Map was not of type WMP_World')

  local storage = {}
  storage["zoneId"] = map:GetZoneId()
  storage["nodes"] = {}

  -- Loop through each node in the map and store it's data

  for _, node in ipairs(map:GetNodes()) do
    local n, position = {}, node:GetPosition()
    n["id"] = node:GetId()
    ---@diagnostic disable-next-line: undefined-field
    n["zoneId"] = node:GetZoneId()
    n["position"] = { ["x"] = position.x, ["y"] = position.y }
    n["neighbours"] = {}

    -- Loop through this nodes neighbours and store
    for _, neighbour in ipairs(node:GetNeighbours()) do
      table.insert(n["neighbours"], neighbour:GetId())
    end

    table.insert(storage["nodes"], n)
  end

  return storage
end

---Creates a world map from stored map data
---@param mapData table
---@return WMP_World
function WMP_World:StorageToMap(mapData)
  local nodes = mapData["nodes"]
  local allConnections = {}

  ---@type WMP_World
  ---@diagnostic disable-next-line: undefined-field
  local newMap = WMP_World:New()

  -- Load all nodes from storage
  for _, node in ipairs(nodes) do
    -- Parse information
    local zoneId, nodeId, position, neighbours = node['zoneId'], node["id"], node["position"], node["neighbours"]

    -- Create node
    ---@diagnostic disable-next-line: undefined-field
    local newNode = WMP_ZoneNode:New(zoneId, nodeId, WMP_Vector:New(position.x, position.y))

    -- Store node connections
    for _, neighbourId in ipairs(neighbours) do
      table.insert(allConnections, { [1] = nodeId, [2] = neighbourId })
    end

    -- Add to map
    newMap:LoadNode(newNode)
  end

  -- Constrct map connections
  for _, connection in ipairs(allConnections) do
    newMap:AddConnection(connection[1], connection[2], false)
  end

  return newMap
end
