---File containing logic for rendeing paths on the eso world map

-- 1) Zone
-- 2) Tamrial
-- 3) Galaxy (Wont do)


---@class WMP_Map_Manager
local WMP_Map_Manager = ZO_InitializingObject:Subclass()

function WMP_Map_Manager:Initialize()

end

function WMP_Map_Manager:LoadMap(zoneId)

end

---@type WMP_Map_Manager
WMP_MAP_MANAGER = WMP_Map_Manager:New()
