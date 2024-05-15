---Class for creating lines on the map.
---@class WMP_Line
---@field startPos WMP_Vector
---@field endPos WMP_Vector
WMP_Line = ZO_InitializingObject:Subclass()

---Initializes a new line
---@param startPos WMP_Vector
---@param endPos WMP_Vector
function WMP_Line:Initialize(startPos, endPos)
  self.startPos = startPos
  self.endPos = endPos
end

---Gets the starting position of the line
---@return number
---@return number
function WMP_Line:GetStartPos()
  return self.startPos.x, self.startPos.y
end

---Gets the end position of the line
---@return number
---@return number
function WMP_Line:GetEndPos()
  return self.endPos.x, self.endPos.y
end

---Check if two lines are the same.
---@param a WMP_Line
---@param b WMP_Line
---@return boolean
function WMP_Line.__eq(a, b)
  return (a.endPos == b.endPos or a.endPos == b.startPos) and (a.startPos == b.endPos or a.startPos == b.startPos)
end
