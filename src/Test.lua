local currentID = 0

---Get's a new id
---@return integer
local function getNextId()
  currentID = currentID + 1
  return currentID;
end

---Prints the tests to console
---@param nodes WMP_Node|WMP_Node[]|nil
function WMP_Print(nodes)
  if nodes == nil then
    d('Recieved a nil node')
    return
  end

  if type(nodes) == "table" then
    for _, node in ipairs(nodes) do
      d(node:toString())
    end
  else
    d(nodes:toString())
  end
end

function WMP_Run_Tests()
  local node1 = WMP_Node:New(getNextId(), WMP_Vector:New(0, 0))
  local node2 = WMP_Node:New(getNextId(), WMP_Vector:New(1, 0))
  local node3 = WMP_Node:New(getNextId(), WMP_Vector:New(1, 2))
  local node4 = WMP_Node:New(getNextId(), WMP_Vector:New(3, 2))
  local node5 = WMP_Node:New(getNextId(), WMP_Vector:New(3, 0))
  local node6 = WMP_Node:New(getNextId(), WMP_Vector:New(5, 0))
  local node7 = WMP_Node:New(getNextId(), WMP_Vector:New(3, -7))
  local node8 = WMP_Node:New(getNextId(), WMP_Vector:New(5, -3))

  -- Create graph
  node1:AddNeighbour(node2)
  node2:AddNeighbour(node1)
  node2:AddNeighbour(node3)
  node3:AddNeighbour(node2)
  node2:AddNeighbour(node5)
  node5:AddNeighbour(node2)
  node3:AddNeighbour(node4)
  node4:AddNeighbour(node3)
  node5:AddNeighbour(node6)
  node6:AddNeighbour(node5)
  node5:AddNeighbour(node7)
  node7:AddNeighbour(node5)
  node6:AddNeighbour(node8)
  node8:AddNeighbour(node6)
  node7:AddNeighbour(node8)
  node8:AddNeighbour(node7)

  local map = { node1, node2, node3, node4, node5, node6, node7, node8 }

  local test1 = WMP_Calculate(node1, node8)
  local test2 = WMP_Calculate(node8, node5)
  local test3 = WMP_Calculate(node7, node3)
  local test4 = WMP_Calculate(node3, node7)

  d('Test1 ----')
  WMP_Print(test1)
  d('Test2 ----')
  WMP_Print(test2)
  d('Test3 ----')
  WMP_Print(test3)
  d('Test4 ----')
  WMP_Print(test4)
end
