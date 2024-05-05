local GPS = LibGPS3

---Search through a list of neighbours to see if the specified one already exists.
---@param neighbours WMP_Node[]
---@param target WMP_Node
---@return boolean
local function HasNeighbour(neighbours, target)
  for _, value in ipairs(neighbours) do
    if value == target then
      return true
    end
  end

  return false
end

---Removes a node from the given list
---@param neighbours WMP_Node[]
---@param target WMP_Node
local function RemoveNeighbour(neighbours, target)
  for i, node in ipairs(neighbours) do
    if node == target then
      table.remove(neighbours, i)
      break
    end
  end
end

---Class contraining a node for use in an A* path finding algorythm.
---@class WMP_Node
WMP_Node = ZO_InitializingObject:Subclass()

---Creates a new node
---@param id integer
---@param position WMP_Vector
function WMP_Node:Initialize(id, position)
  self.m_id = id

  self.m_position = position
  self.m_neighbours = {}
end

---Adds a new neighbour to this node.
---@param neighbour WMP_Node
function WMP_Node:AddNeighbour(neighbour)
  if HasNeighbour(self.m_neighbours, neighbour) == false then
    table.insert(self.m_neighbours, neighbour)
  end
end

---Removes a neighbour from this node.
---@param neighbour WMP_Node
function WMP_Node:RemoveNeighbour(neighbour)
  if HasNeighbour(self.m_neighbours, neighbour) then
    RemoveNeighbour(self.m_neighbours, neighbour)
  end
end

---Set's the position for this node
---@param pos WMP_Vector
function WMP_Node:SetPosition(pos)
  self.m_position = pos
end

---Returns the list of neighbours connected to this node.
---@return WMP_Node[]
function WMP_Node:GetNeighbours()
  return self.m_neighbours
end

---Returns the node's X position.
---@return WMP_Vector
function WMP_Node:GetPosition()
  return self.m_position
end

---Returns the node's local position based on the current active zone.
---@return WMP_Vector
function WMP_Node:GetLocalPosition()
  local gX, gy = GPS:GlobalToLocal(self.m_position.x, self.m_position.y)
  return WMP_Vector:New(gX, gy)
end

---Get the nodes id.
---@return integer
function WMP_Node:GetId()
  return self.m_id
end

---String representation of a node
---@return string
function WMP_Node:toString()
  local neighbours = ""
  for _, neighbour in ipairs(self:GetNeighbours()) do
    neighbours = neighbour:GetId() .. ", " .. neighbours
  end

  return "Node (id: " ..
      self.m_id .. " x: " .. self.m_position.x .. " y: " .. self.m_position.y .. ") (" .. neighbours .. ")"
end
