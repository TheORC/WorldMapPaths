---Helper class for creating map path nodes.
---@class WMP_MapMaker
---@field private map WMP_Map -- The current map being worked on
---@field private previousNode integer -- The previous placed node.
local WMP_MapMaker = ZO_InitializingObject:Subclass()

---Initializes the map maker class
function WMP_MapMaker:Initialize()
  self.m_map = nil
  self.m_previousNode = nil
end

---Adds a new zone to the zone map. If `connect_previous` is set to true, the new node will be set
---as a neighbour.
---@param connect_previous boolean whether the new node is a neighbour of the previous node
---@param oneWay boolean whether the connection with the last node is one way
function WMP_MapMaker:AddNode(connect_previous, oneWay)
  -- Check to make sure we are making a map
  if self.m_map == nil then
    WMP_MESSENGER:Warn("WMP_MapMaker:AddNode() Attempting to add a node when no map has been set")
    return
  end

  -- The player must be in the zone they are trying to add a node too
  if self.m_map:GetZoneId() ~= 0 and not WMP_IsPlayerInCurrentZone() then
    WMP_MESSENGER:Warn("WMP_MapMaker:AddNode() Attempting to add a node to a zone you are not currently in")
    return
  end

  local position = WMP_GetPlayerGlobalPos()
  local zoneId = WMP_GetPlayerZoneId()

  local nodeId, node
  if self.m_map:GetZoneId() == 0 then
    WMP_MESSENGER:Debug("WMP_MapMaker:AddNode() Adding node to world map.")
    ---@diagnostic disable-next-line: param-type-mismatch, redundant-parameter
    nodeId, node = self.m_map:CreateNode(zoneId, position)
  else
    WMP_MESSENGER:Debug("WMP_MapMaker:AddNode() Adding node to zone map.")
    nodeId, node = self.m_map:CreateNode(position)
  end

  if nodeId == nil or node == nil then
    WMP_MESSENGER:Error("WMP_MapMaker:AddNode() Add node failed to create a node.")
    return
  end

  WMP_MESSENGER:Message("Added a new node: <<1>>", node)

  -- Check to see if this should be connected to the previouslt placed node
  -- We don't do this for the world map
  if connect_previous and self.m_previousNode ~= nil and self.m_map:GetZoneId() ~= 0 then
    WMP_MESSENGER:Debug("AddNode() Connect to last placed node <<1>>", self.m_previousNode)
    self:AddConnection(nodeId, self.m_previousNode, oneWay)
  else
    self:OnUpdate()
  end

  WMP_DebugUI_SetAText(nodeId)
  self.m_previousNode = nodeId
end

---Removes a node with the specified node from the current map
---@param nodeId number
function WMP_MapMaker:RemoveNode(nodeId)
  -- Check to make sure we are making a map
  if self.m_map == nil then
    WMP_MESSENGER:Warn("WMP_MapMaker:RemoveNode() Attempting to remove a node when no map has been set")
    return
  end

  WMP_MESSENGER:Debug("WMP_MapMaker:RemoveNode() Removing node from map.")
  self.m_map:RemoveNode(nodeId)

  if self.m_previousNode == nodeId then
    self.m_previousNode = nil
  end

  WMP_MESSENGER:Message("Removed node <<1>> from map.", nodeId)
  self:OnUpdate()
end

---Adds a connection between two nodes
---@param nodeIdA number
---@param nodeIdB number
---@param oneWay boolean
function WMP_MapMaker:AddConnection(nodeIdA, nodeIdB, oneWay)
  -- Check to make sure we are making a map
  if self.m_map == nil then
    WMP_MESSENGER:Warn("WMP_MapMaker:AddConnection() Attempting to add a connection when no map has been set")
    return
  end

  if nodeIdA == nodeIdB then
    WMP_MESSENGER:Warn("WMP_MapMaker:AddConnection() Attempting to add a node to itself")
    return
  end

  WMP_MESSENGER:Debug("WMP_MapMaker:AddConnection() Adding connection between <<1>> and <<2>>. Is oneway <<3>>", nodeIdA,
    nodeIdB, oneWay)
  local success = self.m_map:AddConnection(nodeIdA, nodeIdB, not oneWay)

  if not success then
    WMP_MESSENGER:Error("WMP_MapMaker:AddConnection() Failed to create connection between nodes")
    return
  end

  WMP_MESSENGER:Message("Added connection between <<1>> and <<2>>", nodeIdA, nodeIdB)

  self:OnUpdate()
end

---Removes a connection between two nodes
---@param nodeIdA number
---@param nodeIdB number
function WMP_MapMaker:RemoveConnection(nodeIdA, nodeIdB)
  -- Check to make sure we are making a map
  if self.m_map == nil then
    WMP_MESSENGER:Warn("WMP_MapMaker:RemoveConnection() Attempting to remove a connection when no map has been set")
    return
  end

  if nodeIdA == nodeIdB then
    WMP_MESSENGER:Warn("WMP_MapMaker:RemoveConnection() Attempting to remove a node from itself")
    return
  end

  WMP_MESSENGER:Debug("WMP_MapMaker:RemoveConnection() Removing connection between <<1>> and <<2>>", nodeIdA, nodeIdB)
  local success = self.m_map:RemoveConnection(nodeIdA, nodeIdB)

  if not success then
    WMP_MESSENGER:Error("WMP_MapMaker:RemoveConnection() Failed to remove connection between nodes")
    return
  end

  WMP_MESSENGER:Message("Removed connection between <<1>> and <<2>>", nodeIdA, nodeIdB)
  self:OnUpdate()
end

---Saves the current map to the storage
function WMP_MapMaker:Save()
  if self.m_map == nil then
    WMP_MESSENGER:Warn("WMP_MapMaker:Save() Attempting to save a map when none has been set")
    return
  end

  WMP_MESSENGER:Debug("WMP_MapMaker:Save() Attempting to save a map")
  WMP_STORAGE:StoreMap(self.m_map)

  WMP_MESSENGER:Message("Saved map <<1>>", self.m_map:GetZoneId())
end

---Sets the map to update for the map maker
---@param map WMP_Map
function WMP_MapMaker:SetMap(map)
  WMP_MESSENGER:Debug("WMP_MapMaker:SetMap() Map maker map set")
  self.m_map = map
  self.m_previousNode = nil

  self:OnUpdate()
end

do
  ---Update the debug renderer
  function WMP_MapMaker:OnUpdate()
    WMP_SetDirty(true)
    WMP_TPS_DEBUG_MANAGER:Drawpath()
  end
end

---@type WMP_MapMaker
---@diagnostic disable-next-line: undefined-field
WMP_MAP_MAKER = WMP_MapMaker:New()
