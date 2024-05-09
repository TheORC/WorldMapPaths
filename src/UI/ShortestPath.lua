---@class WMP_ShortestPath : WMP_Path
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

  self:CalculateShortestPath()
end

---Calculates the shortest path between the start and end nodes
function WMP_ShortestPath:CalculateShortestPath()
  local shortestPath = WMP_Calculate(self.startNode, self.endNode)

  -- We don't have a valid path
  if not shortestPath or #shortestPath <= 1 then
    self.pathLines = {}
    return
  end

  for i = 2, #shortestPath do
    local lineEnd = shortestPath[i - 1]
    local lineStart = shortestPath[i]

    self:AddLine(WMP_Line:New(lineStart:GetLocalPosition(), lineEnd:GetLocalPosition()))
  end
end
