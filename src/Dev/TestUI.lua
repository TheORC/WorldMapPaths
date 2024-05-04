---Class for creating a debug renderer
---@class WMP_Test_Menu
local WMP_Test_Menu = ZO_Object:Subclass()

function WMP_Test_Menu:New(...)
  local object = ZO_Object.New(self)
  object:Initialize(...)
  return object
end

function WMP_Test_Menu:Initialize(control)
  self.m_control = control
  self.m_start = control:GetNamedChild("DataRegionStartEdit")
  self.m_goal = control:GetNamedChild("DataRegionGoalEdit")
end

function WMP_Test_Menu:Render()
  local start, goal = tonumber(self.m_start:GetText()), tonumber(self.m_goal:GetText())
  WMP_DEBUG_RENDERER:Draw(start, goal)
end

---Get the Debug UI menu
---@return WMP_Test_Menu
function WMP_GetTestMenu()
  return GetControl("WMP_Test_UI", "").m_object
end

---Method called when the DebugUI is initialized
---@param self any
function WMP_TestUI_OnInitialized(self)
  self.m_object = WMP_Test_Menu:New(self)
end

---Method called when the DebugUI is initialized
---@param self any
function WMP_TestUI_Render(self)
  WMP_GetTestMenu():Render()
end
