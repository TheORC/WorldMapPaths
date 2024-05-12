---@class WMP_TPSDebugManager : TPS_PathManager
---@field private m_renderer WMP_Renderer
---@diagnostic disable-next-line: undefined-field
local WMP_TPSDebugManager = TPS_PathManager:Subclass()

function WMP_TPSDebugManager:Initialize()
  TPS_PathManager.Initialize(self, WMP_DEBUG_RENDERER)
end

function WMP_TPSDebugManager:OnPingAdded()

end

function WMP_TPSDebugManager:OnPingRemoved()

end

function WMP_TPSDebugManager:OnMapChanged()

end

function WMP_TPSDebugManager:Drawpath()

end

---@type WMP_TPSDebugManager
---@diagnostic disable-next-line: undefined-field
WMP_TPS_DEBUG_MANAGER = WMP_TPSDebugManager:New()
