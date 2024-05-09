---@class WMP_ZonePath : WMP_ShortestPath
WMP_ZonePath = WMP_ShortestPath:Subclass()

---Creates a new zone path object
---@param zoneId integer
---@param startNode WMP_Node
---@param endNode WMP_Node
function WMP_ZonePath:Initialize(zoneId, startNode, endNode)
  assert(zoneId ~= nil, "The zone id can not be nil")
  assert(startNode ~= nil, "The start node can not be nil")
  assert(endNode ~= nil, "The end node can not be nil")

  self.zoneId = zoneId

  WMP_ShortestPath.Initialize(self, startNode, endNode)
end

---Returns the zone id for the zone path
---@return integer
function WMP_ZonePath:GetZoneId()
  return self.zoneId
end
