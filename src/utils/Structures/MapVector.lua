local GPS = LibGPS3

---Wrapper class around the vector class allowing us to quickly convert coordanents
---into global and local space
---@class WMP_MVector : WMP_Vector
WMP_MVector = WMP_Vector:Subclass()

function WMP_MVector:Initialize(x, y, isGlobal)
  WMP_Vector.Initialize(self, x, y)

  self.is_global = isGlobal
end

---Get's the map vector as the global coordanents
---@param pos WMP_MVector
---@return WMP_MVector
function WMP_MVector.ToGlobal(pos)
  if pos.is_global then
    return pos
  end

  return WMP_MVector:New(GPS:LocalToGlobal(pos.x, pos.y), true)
end

---Get's the map vector as the local coordanents
---@param pos WMP_MVector
---@return WMP_MVector
function WMP_MVector.ToLocal(pos)
  if not pos.is_global then
    return pos
  end

  return WMP_MVector:New(GPS:GlobalToLocal(pos.x, pos.y), false)
end
