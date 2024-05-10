local LMP = LibMapPins
local GPS = LibGPS3

local PIN_TYPE = "WMP_Marker"

---Class for creating a debug renderer
---@class WMP_Debug_Render : WMP_Renderer
local WMP_Debug_Render = WMP_Renderer:Subclass()

---Initializes a new renderer
function WMP_Debug_Render:Initialize()
  WMP_Renderer.Initialize(self, 'Debug')

  self:CreatePinType()
end

---Clears the current draw map and redraws it
function WMP_Debug_Render:Clear()
  WMP_Renderer.Clear(self)
  LMP:RemoveCustomPin(PIN_TYPE)
end

---Draws the current map information
function WMP_Debug_Render:Draw()
  -- Clear the old render
  self:Clear()

  if not WMP_MAP_MANAGER:GetMap() then
    d('No map no render')
    return
  end

  if WMP_STORAGE:GetSetting(WMP_SETTING_KEYS.DEBUG_DRAW_POINT) then
    self:DrawPoints()
  end

  if WMP_STORAGE:GetSetting(WMP_SETTING_KEYS.DEBUG_DRAW_PATH) then
    self:DrawPath()
  end
end

---Draws all the points on the current map
function WMP_Debug_Render:DrawPoints()
  local call_later = function()
    -- All the nodes on the map
    local nodes = WMP_MAP_MANAGER:GetMap():GetNodes()

    for _, node in ipairs(nodes) do
      local nodePos = node:GetLocalPosition()

      LMP:CreatePin(PIN_TYPE, {
        node_id = node:GetId(),
      }, nodePos.x, nodePos.y, nil)
    end
  end

  -- Wait so the map is loaded
  zo_callLater(call_later, 10)
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
          WMP_WorldUI_SetCopytext(pinData.node_id)
        end
      }
    }, nil)
  end

  ---Get all the paths in the world
  ---@return WMP_Path
  function WMP_Debug_Render:GetWorldPaths()
    ---@type WMP_Path
    local path = WMP_Path:New()

    -- Get a path between all the nodes
    for _, node in ipairs(WMP_MAP_MANAGER:GetMap():GetNodes()) do
      for _, neighbour in ipairs(node:GetNeighbours()) do
        path:AddLine(WMP_Line:New(node:GetLocalPosition(), neighbour:GetLocalPosition()))
      end
    end

    return path
  end
end

---@type WMP_Debug_Render
WMP_DEBUG_RENDERER = WMP_Debug_Render:New()
