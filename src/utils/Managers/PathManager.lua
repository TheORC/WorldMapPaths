local PingLib = LibMapPing2

---@class TPS_PathManager
TPS_PathManager = ZO_InitializingObject:Subclass()

---Create a new TPS_PathManager
---@param renderer WMP_Renderer
function TPS_PathManager:Initialize(renderer)
  self.m_renderer = renderer
  self.m_isEnabled = false

  PingLib:RegisterCallback("AfterPingAdded", function(...)
    if not self.m_isEnabled then
      return
    end
    self:OnPingAdded(...)
  end)
  PingLib:RegisterCallback("AfterPingRemoved", function(...)
    if not self.m_isEnabled then
      return
    end
    self:OnPingRemoved(...)
  end)
  CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function()
    if not self.m_isEnabled then
      return
    end
    self:OnMapChanged()
  end)
  CALLBACK_MANAGER:RegisterCallback("OnWorldMapModeChanged", function()
    if not self.m_isEnabled then
      return
    end
    self:OnMapChanged()
  end)
end

---Enable this manager
function TPS_PathManager:Enable()
  self.m_isEnabled = true
end

---Disable this manager
function TPS_PathManager:Disable()
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
