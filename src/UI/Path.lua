---Class for creating a path of lines
---@class WMP_Path
---@field pathLines WMP_Line[]
WMP_Path = ZO_InitializingObject:Subclass()

---Initializes a new line
---@param pathLines WMP_Line[]|nil
function WMP_Path:Initialize(pathLines)
  self.pathLines = pathLines or {}
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

do
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
