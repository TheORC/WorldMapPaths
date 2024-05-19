---@class WMP_TPSDebugManager : TPS_PathManager
---@field private m_renderer WMP_Debug_Render
---@diagnostic disable-next-line: undefined-field
local WMP_TPSDebugManager = TPS_PathManager:Subclass()

function WMP_TPSDebugManager:Initialize()
  TPS_PathManager.Initialize(self, WMP_DEBUG_RENDERER)

  self.m_drawZoneMap = false
  self.m_map = nil
end

function WMP_TPSDebugManager:OnPingAdded(pingType, pingTag, x, y, isPingOwner)
  WMP_MESSENGER:Message("Ping in zone: <<1>>", WMP_GetZoneIdFromGlobalPos(WMP_LocalToGlobal(x, y)))
end

function WMP_TPSDebugManager:OnPingRemoved()
  return
end

function WMP_TPSDebugManager:OnMapChanged()
  local mapType = GetMapType()
  local zoneId = WMP_GetActiveMapZoneId()

  -- Let the renderer know which zone is being rendered
  if zoneId ~= 0 then
    self.m_renderer:SetActiveZone(zoneId)
  end

  -- self.m_renderer:SetMap(self.m_map)
  self:Drawpath()
end

---Draw the current map
function WMP_TPSDebugManager:Drawpath()
  self.m_renderer:Draw()
end

---Load a map from storage or create a new one
---@param zoneId any
function WMP_TPSDebugManager:LoadMap(zoneId)
  WMP_MESSENGER:Debug("WMP_TPSDebugManager:LoadMap() Loading map <<1>>.", zoneId)
  self.m_map = WMP_GetZoneMap(zoneId)

  -- Check to see if a map was loaded.  If not, lets create a new one
  if not self.m_map then
    WMP_MESSENGER:Debug("WMP_TPSDebugManager:LoadMap() Map load failed, creating a new map.")

    if zoneId == 0 then
      WMP_MESSENGER:Debug("WMP_TPSDebugManager:LoadMap() Create a new world map.")
      ---@diagnostic disable-next-line: undefined-field
      self.m_map = WMP_World:New()
    else
      WMP_MESSENGER:Debug("WMP_TPSDebugManager:LoadMap() Create a new zone map.")
      ---@diagnostic disable-next-line: undefined-field
      self.m_map = WMP_Zone:New(zoneId)
    end

    WMP_MESSENGER:Message("New map created for zone <<1>>", zoneId)
  end

  WMP_MAP_MAKER:SetMap(self.m_map)
  self.m_renderer:SetMap(self.m_map)

  self:Drawpath()

  WMP_MESSENGER:Message("Map loaded: <<1>>", zoneId)
end

---@type WMP_TPSDebugManager
---@diagnostic disable-next-line: undefined-field
WMP_TPS_DEBUG_MANAGER = WMP_TPSDebugManager:New()
