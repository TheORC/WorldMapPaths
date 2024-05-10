---Helper class for creating the world map.
---@class WMP_ZoneMaker
---@field private world WMP_World|nil -- The world map
local WMP_ZoneMaker = ZO_InitializingObject:Subclass()

---Create a new world maker object
function WMP_ZoneMaker:Initialize()
  self.world = nil
end

---Adds a new node to the world map
function WMP_ZoneMaker:AddNode()
  if not self.worldMap then
    d('There is no world map.')
    return
  end

  local playerZoneId = WMP_GetPlayerZoneId()
  local playerPos = WMP_GetPlayerGlobalPos()
  local _, node = self.world:CreateNode(playerZoneId, playerPos)
  d(zo_strformat('Added a new node (<<1>>)', node:toString()))
end

---Removes a node from the world map
---@param nodeId integer
function WMP_ZoneMaker:RemoveNode(nodeId)
  if not self.worldMap then
    d('There is no world map.')
    return
  end

  local node = self.world:GetNode(nodeId)

  if not node then
    d(zo_strformat('Unable to find the node: <<1>>', nodeId))
    return
  end

  self.world:RemoveNode(nodeId)
end

---Add a connection between two nodes
---@param nodeA integer
---@param nodeB integer
function WMP_ZoneMaker:AddConnection(nodeA, nodeB)
  if not self.worldMap then
    d('There is no world map.')
    return
  end

  self.world:AddConnection(nodeA, nodeB)
  d(zo_strformat('Added connection between <<1>> and <<2>>', nodeA, nodeB))
end

---Remove a connection between two nodes
---@param nodeA integer
---@param nodeB integer
function WMP_ZoneMaker:RemoveConnection(nodeA, nodeB)
  if not self.worldMap then
    d('There is no world map.')
    return
  end

  self.world:RemoveConnection(nodeA, nodeB)
  d(zo_strformat('Removed connection between <<1>> and <<2>>', nodeA, nodeB))
end

function WMP_ZoneMaker:GetMap()
  if not self.worldMap then
    self.worldMap = WMP_STORAGE:GetMap(0)
  end
  return self.worldMap
end
