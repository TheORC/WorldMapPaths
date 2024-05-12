local PingLib = LibMapPing2

---@class TPS_PathManager
TPS_PathManager = ZO_InitializingObject:Subclass()

---Create a new TPS_PathManager
---@param renderer WMP_Renderer
function TPS_PathManager:Initialize(renderer)
  self.m_renderer = renderer
  self.m_isEnabled = false
end

---Enable this manager
function TPS_PathManager:Enable()
  PingLib:RegisterCallback("AfterPingAdded", function(...) self:OnPingAdded(...) end)
  PingLib:RegisterCallback("AfterPingRemoved", function(...) self:OnPingRemoved(...) end)
  CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function() self:OnMapChanged() end)
  CALLBACK_MANAGER:RegisterCallback("OnWorldMapModeChanged", function() self:OnMapChanged() end)

  self.m_isEnabled = true
end

---Disable this manager
function TPS_PathManager:Disable()
  PingLib:UnregisterCallback("AfterPingAdded", function(...) self:OnPingAdded(...) end)
  PingLib:UnregisterCallback("AfterPingRemoved", function(...) self:OnPingRemoved(...) end)
  CALLBACK_MANAGER:UnregisterCallback("OnWorldMapChanged", function() self:OnMapChanged() end)
  CALLBACK_MANAGER:UnregisterCallback("OnWorldMapModeChanged", function() self:OnMapChanged() end)

  self.m_isEnabled = false
end

function TPS_PathManager:OnPingAdded(pingType, pingTag, x, y, isPingOwner)
  assert(false, 'OnPingAdded must be implemented')
end

function TPS_PathManager:OnPingRemoved(pingType, pingTag, x, y, isPingOwner)
  assert(false, 'OnPingRemoved must be implemented')
end

function TPS_PathManager:OnMapChanged()
  assert(false, 'OnMapChanged must be implemented')
end

function TPS_PathManager:Drawpath()
  assert(false, 'Drawpath must be implemented')
end
