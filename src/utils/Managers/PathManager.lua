local PingLib = LibMapPing2

---@class TPS_Manager
TPS_Manager = ZO_InitializingObject:Subclass()

---Create a new TPS_Manager
---@param renderer WMP_Renderer
function TPS_Manager:Initialize(renderer)
  self.m_isEnabled = false
  self.m_renderer = renderer
end

---Enable this manager
function TPS_Manager:Enable()
  PingLib:RegisterCallback("AfterPingAdded", function(...) self:OnPingAdded(...) end)
  PingLib:RegisterCallback("AfterPingRemoved", function(...) self:OnPingRemoved(...) end)
  CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function() self:OnMapChanged() end)
  CALLBACK_MANAGER:RegisterCallback("OnWorldMapModeChanged", function() self:OnMapChanged() end)

  self.m_isEnabled = true
end

---Disable this manager
function TPS_Manager:Disable()
  PingLib:UnregisterCallback("AfterPingAdded", function(...) self:OnPingAdded(...) end)
  PingLib:UnregisterCallback("AfterPingRemoved", function(...) self:OnPingRemoved(...) end)
  CALLBACK_MANAGER:UnregisterCallback("OnWorldMapChanged", function() self:OnMapChanged() end)
  CALLBACK_MANAGER:UnregisterCallback("OnWorldMapModeChanged", function() self:OnMapChanged() end)

  self.m_isEnabled = false
end

function TPS_Manager:OnPingAdded(pingType, pingTag, x, y, isPingOwner)
  assert(false, 'OnPingAdded must be implemented')
end

function TPS_Manager:OnPingRemoved(pingType, pingTag, x, y, isPingOwner)
  assert(false, 'OnPingRemoved must be implemented')
end

function TPS_Manager:OnMapChanged()
  assert(false, 'OnMapChanged must be implemented')
end

function TPS_Manager:Drawpath()
  assert(false, 'Drawpath must be implemented')
end
