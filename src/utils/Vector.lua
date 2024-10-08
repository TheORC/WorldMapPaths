---Class representation of a vector.
---@class WMP_Vector
---@field public x number
---@field public y number
WMP_Vector = { x = 0, y = 0 }

---Creates a new Vector class
---@param x number
---@param y number
---@return WMP_Vector
local function new(x, y)
  return WMP_Vector:New(x, y)
end

---Creates a new vector.
---@param x number
---@param y number
---@return WMP_Vector
function WMP_Vector:New(x, y)
  local object = setmetatable({}, WMP_Vector)
  object.__index = WMP_Vector
  object.x = x or 0
  object.y = y or 0
  return object
end

---Addition
---@param a WMP_Vector
---@param b WMP_Vector
---@return WMP_Vector
function WMP_Vector.__add(a, b)
  return new(a.x + b.x, a.y + b.y)
end

---Subtraction
---@param a WMP_Vector
---@param b WMP_Vector
---@return WMP_Vector
function WMP_Vector.__sub(a, b)
  return new(a.x - b.x, a.y - b.y)
end

---Multiplication
---@param a number|WMP_Vector
---@param b WMP_Vector
---@return WMP_Vector
function WMP_Vector.__mul(a, b)
  if type(a) == "number" then
    return new(a * b.x, a * b.y)
  elseif type(b) == "number" then
    return new(b * a.x, b * a.y)
  end

  return new(a.x * b.x, a.y * b.y)
end

---Devision
---@param a WMP_Vector
---@param b number
---@return WMP_Vector
function WMP_Vector.__div(a, b)
  return new(a.x / b, a.y / b)
end

---Equals
---@param a WMP_Vector
---@param b WMP_Vector
---@return boolean
function WMP_Vector.__eq(a, b)
  return a.x == b.x and a.y == b.y
end

---Negation
---@param a WMP_Vector
---@return WMP_Vector
function WMP_Vector.__unm(a)
  return new(-a.x, -a.y)
end

---Distance
---@param a WMP_Vector
---@param b WMP_Vector
---@return number
function WMP_Vector.dist(a, b)
  return math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2)
end

---Returns a vector as a string
---@param self WMP_Vector
---@return string
function WMP_Vector.__tostring(self)
  return "Vector (" .. self.x .. ", " .. self.y .. ")"
end
