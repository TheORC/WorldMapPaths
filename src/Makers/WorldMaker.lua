---Helper class for creating the world map.
---@class WMP_WorldMaker
---@field private world WMP_World -- The world map
local WMP_WorldMaker = ZO_InitializingObject:Subclass()

---Create a new world maker object
function WMP_WorldMaker:Initialize()
  self.world = nil
end

---Adds a new node to the world map
function WMP_WorldMaker:AddNode()
  if not self.world then
    d('There is no world map.')
    return
  end

  local playerZoneId = WMP_GetPlayerZoneId()
  local playerPos = WMP_GetPlayerGlobalPos()
  local _, node = self.world:CreateNode(playerZoneId, playerPos)
  d(zo_strformat('Added a new node (<<1>>)', tostring(node)))

  self:OnUpdate()
end

---Removes a node from the world map
---@param nodeId integer
function WMP_WorldMaker:RemoveNode(nodeId)
  if not self.world then
    d('There is no world map.')
    return
  end

  local node = self.world:GetNode(nodeId)

  if not node then
    d(zo_strformat('Unable to find the node: <<1>>', nodeId))
    return
  end

  self.world:RemoveNode(nodeId)

  self:OnUpdate()
end

---Add a connection between two nodes
---@param nodeA integer
---@param nodeB integer
function WMP_WorldMaker:AddConnection(nodeA, nodeB)
  if not self.world then
    d('There is no world map.')
    return
  end

  self.world:AddConnection(nodeA, nodeB)
  d(zo_strformat('Added connection between <<1>> and <<2>>', nodeA, nodeB))

  self:OnUpdate()
end

---Remove a connection between two nodes
---@param nodeA integer
---@param nodeB integer
function WMP_WorldMaker:RemoveConnection(nodeA, nodeB)
  if not self.world then
    d('There is no world map.')
    return
  end

  self.world:RemoveConnection(nodeA, nodeB)
  d(zo_strformat('Removed connection between <<1>> and <<2>>', nodeA, nodeB))

  self:OnUpdate()
end

---Loads the world map from storage
function WMP_WorldMaker:LoadWorldMap()
  local map = self:GetMap()

  if not map then
    ---@diagnostic disable-next-line: undefined-field
    map = WMP_World:New()
  end

  self.world = map
end

---Gets the world map
---@return WMP_World|nil
function WMP_WorldMaker:GetMap()
  if not self.world then
    ---@diagnostic disable-next-line: assign-type-mismatch
    self.world = WMP_STORAGE:GetMap(0)
  end
  return self.world
end

---Saves the world map
function WMP_WorldMaker:Save()
  WMP_STORAGE:StoreMap(self.world)
end

do
  function WMP_WorldMaker:OnUpdate()
    WMP_DEBUG_RENDERER:Draw()
  end
end

---@type WMP_WorldMaker
---@diagnostic disable-next-line: undefined-field
WMP_WORLD_MAKER = WMP_WorldMaker:New()
