---@class WMP_ShortestPath : WMP_Path
---@diagnostic disable-next-line: undefined-field
WMP_ShortestPath = WMP_Path:Subclass()

---Creates a new shortest path object
---@param startNode WMP_Node
---@param endNode WMP_Node
function WMP_ShortestPath:Initialize(startNode, endNode)
  assert(startNode ~= nil, "The start node can not be nil")
  assert(endNode ~= nil, "The end node can not be nil")

  WMP_Path.Initialize(self)

  self.startNode = startNode
  self.endNode = endNode
  self.pathNodes = {}

  self:CalculateShortestPath()
end

---Returns the array of nodes building up the shortest path
---@return WMP_Node[]|nil
function WMP_ShortestPath:GetPathNodes()
  return self.pathNodes
end

---Returns true if there is a valid path.  A valid path is not nil and has more that
---one node.
---@return boolean
function WMP_ShortestPath:HasPath()
  return self.pathNodes ~= nil and #self.pathNodes > 1
end

do
  ---Calculates the shortest path between the start and end nodes
  function WMP_ShortestPath:CalculateShortestPath()
    self.pathNodes = WMP_Calculate(self.startNode, self.endNode)
    self.pathLines = self:NodesToLines(self.pathNodes)
  end
end
