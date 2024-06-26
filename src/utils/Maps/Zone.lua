---Class representation of a map.
---@class WMP_Zone : WMP_Map
---@diagnostic disable-next-line: undefined-field
WMP_Zone = WMP_Map:Subclass()

---Creates a new map data structure
---@param zoneId integer
function WMP_Zone:Initialize(zoneId)
  WMP_Map.Initialize(self, zoneId)
end

---Format a zone map so it can saved to storage
---@param map WMP_Zone
---@return table
function WMP_Zone:MapToStorage(map)
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
---@return WMP_Zone
function WMP_Zone:StorageToMap(mapData)
  local zoneId = mapData["zoneId"]
  local nodes = mapData["nodes"]
  local allConnections = {}

  ---@type WMP_Zone
  ---@diagnostic disable-next-line: undefined-field
  local newMap = WMP_Zone:New(zoneId)

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
    newMap:LoadNode(newNode)
  end

  -- Constrct map connections
  for _, connection in ipairs(allConnections) do
    newMap:AddConnection(connection[1], connection[2], false)
  end

  return newMap
end
