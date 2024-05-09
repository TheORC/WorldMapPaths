---@class WMP_WorldPath : WMP_ShortestPath
WMP_WorldPath = WMP_ShortestPath:Subclass()

---Creates new world path calculator
---@param startZone WMP_Node
---@param endZone WMP_Node
function WMP_WorldPath:Initialize(startZone, endZone)
  assert(startZone ~= nil, "The start node can not be nil")
  assert(endZone ~= nil, "The end node can not be nil")

  WMP_ShortestPath.Initialize(self, startZone, endZone)

  self.zonePaths = {}
end
