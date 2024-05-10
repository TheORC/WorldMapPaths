---@class WMP_DebugController
local WMP_DebugController = ZO_InitializingObject:Subclass()

function WMP_DebugController:Initialize(control)
  self.control = control
  self.mapController = WMP_DebugMap_UI
  self.worldController = WMP_WorldMap_UI

  self.isWorldActive = false
  self.isDebug = false

  self:DisableDebug()
end

---Enable and show the debug menus
function WMP_DebugController:EnableDebug()
  if self.isWorldActive then
    self.worldController:SetHidden(false)
  else
    self.mapController:SetHidden(false)
  end
  self.control:SetHidden(false)
  self.isDebug = true
end

---Disable and hide the debug menus
function WMP_DebugController:DisableDebug()
  self.worldController:SetHidden(true)
  self.mapController:SetHidden(true)
  self.control:SetHidden(true)
  self.isDebug = false
end

---Turn on the world menu
function WMP_DebugController:ShowWorldMenu()
  if not self.isDebug then
    return
  end

  self.mapController:SetHidden(true)
  self.worldController:SetHidden(false)
  self.isWorldActive = true
end

---Turn on the map menu
function WMP_DebugController:ShowMapMenu()
  if not self.isDebug then
    return
  end

  self.worldController:SetHidden(true)
  self.mapController:SetHidden(false)
  self.isWorldActive = false
end

---Returns whether this is in debug mode
---@return boolean
function WMP_DebugController:IsDebug()
  return self.isDebug
end

---Initialize the debug controller
---@param self any
function WMP_DebugController_OnInitialized(self)
  ---@type WMP_DebugController
  WMP_DEBUG_CONTROLLER = WMP_DebugController:New(self)
end
