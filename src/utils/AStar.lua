---Calculates the distance between two nodes.
---@param nodeA WMP_Node
---@param nodeB WMP_Node
---@return number
local function dist(nodeA, nodeB)
  return WMP_Vector.dist(nodeA:GetPosition(), nodeB:GetPosition())
end

---Check if a node is in a list
---@param set WMP_Node[]
---@param target WMP_Node
---@return boolean
local function not_in(set, target)
  for _, node in ipairs(set) do
    if node == target then
      return false
    end
  end
  return true
end

---Removes a node from the provided set and removes is.
---@param set WMP_Node[]
---@param target WMP_Node
local function remove_node(set, target)
  for i, node in ipairs(set) do
    if set[i] == target then
      table.remove(set, i)
      break
    end
  end
end

---Calculates the heuristic cost between two nodes
---@param nodeA WMP_Node
---@param nodeB WMP_Node
---@return number
local function h(nodeA, nodeB)
  return dist(nodeA, nodeB)
end

---Caluclates the a node in the provided set with the next lowest f_score
---@param set WMP_Node[]
---@param f_score number[]
---@return WMP_Node
local function calculate_lowest_f(set, f_score)
  -- Return the only item left
  if #set == 1 then
    return set[1]
  end

  local lowest, bestNode = 1 / 0, nil
  for _, node in ipairs(set) do
    local score = f_score[node]
    if score < lowest then
      lowest, bestNode = score, node
    end
  end

  ---@diagnostic disable-next-line: return-type-mismatch
  return bestNode
end

---Reverses the order of a table
---@param arr any[]
---@return table[]
local function reverseTable(arr)
  local reversed = {}
  for i = #arr, 1, -1 do
    table.insert(reversed, arr[i])
  end
  return reversed
end

---Reconstrct the shortest path.
---@param cameFrom WMP_Node[]
---@param current WMP_Node
---@return WMP_Node[]
local function reconstruct_path(cameFrom, current)
  local total_path = { current }

  while cameFrom[current] do
    current = cameFrom[current]
    table.insert(total_path, current)
  end

  return reverseTable(total_path)
end

---Caluclate the shortest path between the start and goal.
---@param start WMP_Node
---@param goal WMP_Node
---@param cost function|nil
function WMP_Calculate(start, goal, cost)
  cost = cost or h

  local open_set = { start }
  local closed_set = {}
  local came_from = {}

  local g_score, f_score = {}, {}
  g_score[start] = 0
  f_score[start] = g_score[start] + cost(start, goal)

  -- While we have nodes to search, keep looking for the shortest path
  while #open_set > 0 do
    -- Get the next closes node to the goal
    local current = calculate_lowest_f(open_set, f_score)

    -- We have found the path.
    if current == goal then
      return reconstruct_path(came_from, current)
    end

    -- We have another node
    -- Calculate it's neighbours

    remove_node(open_set, current)
    table.insert(closed_set, current)

    -- loop through each enighbour and calculate ralevent g_score and f_scores.
    for i, neighbour in ipairs(current:GetNeighbours()) do
      -- Don't process a node we have already checked
      -- This helps prevent infinet loops.
      if not_in(closed_set, neighbour) then
        -- Calculate the gscore for this neighbour
        local tentative_g = g_score[current] + dist(current, neighbour)

        if g_score[neighbour] == nil or tentative_g < g_score[neighbour] then
          -- Update the path so we can follow it back later if it proves to be the shorted
          came_from[neighbour] = current

          -- Update the neighbours g_score and f_score
          g_score[neighbour] = tentative_g
          f_score[neighbour] = tentative_g + cost(neighbour, goal)

          -- Check this is not already in the open_set
          if not_in(open_set, neighbour) then
            table.insert(open_set, neighbour)
          end
        end
      end
    end
  end

  return nil
end
