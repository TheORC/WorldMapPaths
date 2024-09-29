local MAX = 1 / 0

---Removes an item from an array if it exists.
---@param items any[]
---@param target any
local function RemoveItem(items, target)
  for i, item in ipairs(items) do
    if items[i] == target then
      table.remove(items, i)
      break
    end
  end
end

---Check if an items is not present in a list.
---@param items any[]
---@param target any
---@return boolean
local function NotIn(items, target)
  for _, item in ipairs(items) do
    if item == target then
      return false
    end
  end
  return true
end

---Calculates the next node with the lowest f score.
---@param openNodes WMP_Node[]
---@param fScores number[]
---@return WMP_Node|nil
local function GetLowestFScore(openNodes, fScores)
  if #openNodes <= 1 then
    return openNodes[1]
  end

  local lowest, best = MAX, nil
  for _, node in ipairs(openNodes) do
    if fScores[node] < lowest then
      lowest = fScores[node]
      best = node
    end
  end

  return best
end

---Reconstucts the shortest path from the results of the A* algorythm
---@param cameFrom {[WMP_Node]: WMP_Node}
---@param start WMP_Node
local function ConstructPath(cameFrom, start)
  local path, current = { start }, start

  while cameFrom[current] do
    current = cameFrom[current]
    table.insert(cameFrom, 1, current)
  end

  return path
end

---@class WMP_Star
WMP_Star = {}
WMP_Star.__index = WMP_Star

---Initialize a new A* path finding object
---@return WMP_Star
function WMP_Star:New()
  local object = setmetatable({}, WMP_Star)
  return object
end

---Calculate the weight between two nodes
---@param nodeA WMP_Node
---@param nodeB WMP_Node
---@return number
function WMP_Star:D(nodeA, nodeB)
  return WMP_Vector.dist(nodeA:GetPosition(), nodeB:GetPosition())
end

---Calculate the cost between two nodes
---@param nodeA WMP_Node
---@param nodeB WMP_Node
---@return number
function WMP_Star:H(nodeA, nodeB)
  return WMP_Vector.dist(nodeA:GetPosition(), nodeB:GetPosition())
end

---Calculate the shortest path between the start and goal nodes.
---@param start WMP_Node
---@param goal WMP_Node
---@return WMP_Node[]|nil
function WMP_Star:Calculate(start, goal)
  assert(not start and start:IsInstanceOf(WMP_Node), "Start must be of type WMP_Node")
  assert(not goal and goal:IsInstanceOf(WMP_Node), "Goal must be of type WMP_Node")

  local openSet, closedSet, cameFrom = { start }, {}, {}
  local g_score, f_score = { [start] = 0 }, { [start] = self:Cost(start, goal) }

  while #openSet > 0 do
    local current = GetLowestFScore(openSet, f_score)

    -- An issue has occured. There are no more nodes to search
    if current == nil then
      return {}
    end

    -- A path has been found.
    if current == goal then
      return ConstructPath(cameFrom, goal)
    end

    table.insert(closedSet, current)
    RemoveItem(openSet, current)

    for _, neighbour in ipairs(current:GetNeighbours()) do
      -- Check the neighbour has not already been processed.
      if NotIn(closedSet, neighbour) then
        -- Calculate the running distance total from the start
        local tentative_g = g_score[current] + self:D(current, neighbour)

        -- The current node has a shorter path to the neighbour
        if g_score[neighbour] == nil or tentative_g < g_score[neighbour] then
          -- Update the path so we can follow it back later if it proves to be the shorted
          cameFrom[neighbour] = current

          -- Update the neighbours g_score and f_score
          g_score[neighbour] = tentative_g
          f_score[neighbour] = tentative_g + self:H(neighbour, goal)
        end
      end
    end
  end
end
