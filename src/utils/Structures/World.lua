---Class representation of a word map.
---This class is responsible for drawing the connections between zones.
---@class WMP_World
local WMP_World = ZO_InitializingObject:Subclass()

function WMP_World:Initialize()
  ---A list of all the map path nodes
  ---@type WMP_ZoneNode[]
  self.pathNodes = {}
end

function WMP_World:CreateNode()

end
