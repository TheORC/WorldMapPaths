---@class WMP_ZonePath : WMP_Path
WMP_ZonePath = WMP_Path:Subclass()

function WMP_ZonePath:Initialize(startNode, endNode)
  WMP_Path.Initialize(self)

  assert(startNode ~= nil, "The start node can not be nil")
  assert(endNode ~= nil, "The end node can not be nil")

  self.startNode = startNode
  self.endNode = endNode

  self:CalculateShortestPath()
end

---Calculates the shortest path between the start and end nodes
function WMP_ZonePath:CalculateShortestPath()
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
