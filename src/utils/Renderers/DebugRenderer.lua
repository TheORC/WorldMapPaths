local LMP = LibMapPins
local GPS = LibGPS3

local PIN_TYPE = "WMP_Marker"

---Class for creating a debug renderer
---@class WMP_Debug_Render : WMP_Renderer
---@field m_map WMP_Map
---@diagnostic disable-next-line: undefined-field
local WMP_Debug_Render = WMP_Renderer:Subclass()

---Initializes a new renderer
function WMP_Debug_Render:Initialize()
  WMP_Renderer.Initialize(self, 'Debug')
  self:CreatePinType()
  self.m_map = nil
end

---Clears the current draw map and redraws it
function WMP_Debug_Render:Clear()
  WMP_MESSENGER:Debug("WMP_Debug_Render:Clear() Clearing renderer")

  LMP:RemoveCustomPin(PIN_TYPE)
  WMP_Renderer.Clear(self)

  WMP_MESSENGER:Debug("WMP_Debug_Render:Clear() Finished clearing")
end

---Draws the current map information
function WMP_Debug_Render:Draw()
  -- Clear the old render
  self:Clear()

  if not self.m_map then
    WMP_MESSENGER:Warn("WMP_Debug_Render:Draw() The render must have a map set to draw the paths")
    return
  end

  if WMP_STORAGE:GetSetting(WMP_SETTING_KEYS.DEBUG_DRAW_POINT) then
    WMP_MESSENGER:Warn("WMP_Debug_Render:Draw() Drawing map points")
    self:DrawPoints()
  end

  if WMP_STORAGE:GetSetting(WMP_SETTING_KEYS.DEBUG_DRAW_PATH) then
    WMP_MESSENGER:Warn("WMP_Debug_Render:Draw() Drawing map paths")
    self:DrawPath()
  end
end

---Draws all the points on the current map
function WMP_Debug_Render:DrawPoints()
  -- All the nodes on the map
  local nodes = self.m_map:GetNodes()

  for _, node in ipairs(nodes) do
    local nodePos = node:GetLocalPosition()

    LMP:CreatePin(PIN_TYPE, {
      node_id = node:GetId(),
    }, nodePos.x, nodePos.y, nil)
  end
end

---Draw the entire map
function WMP_Debug_Render:DrawPath()
  -- All the paths in the world
  local paths = self:GetWorldPaths()

  local linkControl, startX, startY, endX, endY
  local mapWidth, mapHeight = ZO_WorldMapContainer:GetDimensions()

  -- Loop through new path
  for i, line in ipairs(paths:GetLines()) do
    linkControl = self.linkPool:AcquireObject()

    linkControl.startX, linkControl.startY = line:GetStartPos()
    linkControl.endX, linkControl.endY = line:GetEndPos()

    linkControl:SetTexture("EsoUI/Art/AvA/AvA_transitLine.dds")
    linkControl:SetColor(1, 1, 1, 1)
    linkControl:SetDrawLevel(1)

    startX, startY = linkControl.startX * mapWidth, linkControl.startY * mapHeight
    endX, endY = linkControl.endX * mapWidth, linkControl.endY * mapHeight

    ZO_Anchor_LineInContainer(linkControl, nil, startX, startY, endX, endY)
  end
end

---Sets the map the be rendered
---@param map any
function WMP_Debug_Render:SetMap(map)
  WMP_MESSENGER:Debug("SetMap() Debug renderer map set")
  self.m_map = map
end

do
  ---Create the map pin type allowing us to see where our nodes are placed
  function WMP_Debug_Render:CreatePinType()
    -- Create the pin type
    LMP:AddPinType(PIN_TYPE, function() end, nil, nil, {
      creator = function(pin)
        local _, pinData = pin:GetPinTypeAndTag()
        InformationTooltip:AddLine(zo_strformat("Id: <<1>>", pinData.node_id))
      end
    })

    -- Set the pin click handler
    LMP:SetClickHandlers(PIN_TYPE, {
      {
        name = "Path Node",
        callback = function(pin)
          local _, pinData = pin:GetPinTypeAndTag()
          WMP_DebugUI_SetCopytext(pinData.node_id)
        end
      }
    }, nil)
  end

  ---Get all the paths in the world
  ---@return WMP_Path
  function WMP_Debug_Render:GetWorldPaths()
    ---@type WMP_Path
    ---@diagnostic disable-next-line: undefined-field
    local path = WMP_Path:New()

    -- Get a path between all the nodes
    for _, node in ipairs(self.m_map:GetNodes()) do
      for _, neighbour in ipairs(node:GetNeighbours()) do
        ---@diagnostic disable-next-line: undefined-field
        path:AddLine(WMP_Line:New(node:GetLocalPosition(), neighbour:GetLocalPosition()))
      end
    end

    return path
  end
end

---@type WMP_Debug_Render
---@diagnostic disable-next-line: undefined-field
WMP_DEBUG_RENDERER = WMP_Debug_Render:New()
