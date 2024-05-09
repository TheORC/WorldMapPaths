---Class contraining a node for use in an A* path finding algorythm.
---@class WMP_ZoneNode : WMP_Node
WMP_ZoneNode = WMP_Node:Subclass()

---Creates a new node
---@param id integer
---@param position WMP_Vector
function WMP_ZoneNode:Initialize(zoneId, id, position)
  WMP_Node.Initialize(self, id, position)
  self.zoneId = zoneId
end
