---@class WMP_TPSDebugManager : TPS_PathManager
---@field private m_renderer WMP_Debug_Render
---@diagnostic disable-next-line: undefined-field
local WMP_TPSDebugManager = TPS_PathManager:Subclass()

function WMP_TPSDebugManager:Initialize()
  TPS_PathManager.Initialize(self, WMP_DEBUG_RENDERER)

  self.m_drawZoneMap = false
  self.m_map = nil
end

function WMP_TPSDebugManager:OnPingAdded()
  return
end

function WMP_TPSDebugManager:OnPingRemoved()
  return
end

function WMP_TPSDebugManager:OnMapChanged()
  local mapType = GetMapType()
  local zoneId = nil

  -- Check to see if we should load the global map
  --[[
    if mapType == MAPTYPE_MAX_VALUE or mapType == MAPTYPE_WORLD then
      zoneId = 0
      WMP_MESSENGER:Debug("OnMapChanged() Loading global map.")
    else
      zoneId = WMP_GetActiveMapZoneId()
      WMP_MESSENGER:Debug("OnMapChanged() Loading zone map <<1>>.", zoneId)
    end

    self.m_map = WMP_GetZoneMap(zoneId)

    if not self.m_map then
      WMP_MESSENGER:Debug("OnMapChanged() Map load failed.")
      return
    end
  ]]

  -- self.m_renderer:SetMap(self.m_map)
  self:Drawpath()
end

function WMP_TPSDebugManager:Drawpath()
  self.m_renderer:Draw()
end

function WMP_TPSDebugManager:LoadMap(zoneId)
  WMP_MESSENGER:Debug("OnMapChanged() Loading map <<1>>.", zoneId)
  self.m_map = WMP_GetZoneMap(zoneId)

  if not self.m_map then
    WMP_MESSENGER:Debug("OnMapChanged() Map load failed.")
    return
  end

  self.m_renderer:SetMap(self.m_map)
  self:Drawpath()
end

---@type WMP_TPSDebugManager
---@diagnostic disable-next-line: undefined-field
WMP_TPS_DEBUG_MANAGER = WMP_TPSDebugManager:New()
