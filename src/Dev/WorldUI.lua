---@class WorldUI
local WorldUI = ZO_InitializingObject:Subclass()

function WorldUI:Initialize(control)
  self.control = control
end

function WMP_WorldUI_OnInitialized(self)
  self.m_object = WorldUI:New(self)
end
