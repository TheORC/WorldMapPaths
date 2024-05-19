---@diagnostic disable: undefined-field

---Class for creating a path of lines
---@class WMP_Path
---@field pathLines WMP_Line[]
WMP_Path = ZO_InitializingObject:Subclass()

---Initializes a new line
---@param pathLines WMP_Line[]|WMP_Node[]|nil
function WMP_Path:Initialize(pathLines)
  -- Our path lines
  self.pathLines = {}

  -- We were passed a list of items.
  if pathLines and #pathLines > 0 then
    local first = pathLines[1]

    if first:IsInstanceOf(WMP_Line) then
      self.pathLines = pathLines
    elseif first:IsInstanceOf(WMP_Node) then
      self.pathLines = self:NodesToLines(pathLines)
    end
  end
end

---Add a new line to the path
---@param line WMP_Line
function WMP_Path:AddLine(line)
  -- Don't add the same line twice
  if self:HasLine(line) then
    return
  end

  table.insert(self.pathLines, line)
end

---Returns the list of lines in this path
---@return WMP_Line[]
function WMP_Path:GetLines()
  return self.pathLines
end

---Returns the total length of the path
---@return number
function WMP_Path:GetLength()
  local length = 0
  for _, line in ipairs(self.pathLines) do
    length = length + WMP_Vector.dist(line:GetStartPos(), line:GetEndPos())
  end

  return length
end

---Returns the number of path lines
---@return integer
function WMP_Path:GetLineCount()
  return #self.pathLines
end

do
  ---Convert a list of nodes into a path
  ---@param nodes WMP_Node[]|nil
  ---@return WMP_Line[]
  function WMP_Path:NodesToLines(nodes)
    -- We don't have a valid path
    if not nodes or #nodes <= 1 then
      return {}
    end

    local lines = {}

    for i = 2, #nodes do
      local lineEnd = nodes[i - 1]
      local lineStart = nodes[i]
      ---@diagnostic disable-next-line: undefined-field
      table.insert(lines, WMP_Line:New(lineStart:GetLocalPosition(), lineEnd:GetLocalPosition()))
    end

    return lines
  end

  ---Method to check if the path already contains a line.
  ---@param target WMP_Line
  ---@return boolean
  function WMP_Path:HasLine(target)
    for _, line in ipairs(self.pathLines) do
      if line == target then
        return true
      end
    end

    return false
  end
end
