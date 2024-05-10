---Class representation of a word map.
---This class is responsible for drawing the connections between zones.
---@class WMP_World : WMP_PathBuilder
local WMP_World = WMP_PathBuilder:Subclass()

---Create a new data strucuture to contain world path connections
function WMP_World:Initialize()
  WMP_PathBuilder.Initialize(self)
end

---Create a new node bassed on a zone
---@param zoneId any
---@param position any
---@return integer
---@return unknown
function WMP_World:CreateNode(zoneId, position)
  assert(position ~= nil, "zoneId must be defined")
  assert(position ~= nil, "Position must be defined")

  local newId = self:GetNextId()
  local newNode = WMP_ZoneNode:New(zoneId, newId, position)
  table.insert(self.pathNodes, newNode)

  return newId, newNode
end

WMP_WORLD_PATH = WMP_World:New()
