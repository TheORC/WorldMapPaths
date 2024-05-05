local LMP = LibMapPins
local GPS = LibGPS3

local PIN_TYPE = "WMP_Marker"

---Class for creating a debug renderer
---@class WMP_Debug_Render
---@field map WMP_Map
---@field path WMP_Path
---@field linkPool ZO_ControlPool
local WMP_Debug_Render = ZO_InitializingObject:Subclass()

---Initializes a new renderer
function WMP_Debug_Render:Initialize()
  self.map = nil
  self.path = nil

  self.linkPool = ZO_ControlPool:New("WMPLink", ZO_WorldMapContainer, 'link')

  -- hack into the SetDimensions function as we need to scale the displayed path whenever the user zooms in/out
  local oldDimensions = ZO_WorldMapContainer.SetDimensions
  ZO_WorldMapContainer.SetDimensions = function(container, mapWidth, mapHeight, ...)
    local links = self.linkPool:GetActiveObjects()
    local startX, startY, endX, endY
    for _, link in pairs(links) do
      startX, startY, endX, endY = link.startX * mapWidth, link.startY * mapHeight, link.endX * mapWidth,
          link.endY * mapHeight
      ZO_Anchor_LineInContainer(link, nil, startX, startY, endX, endY)
    end
    oldDimensions(container, mapWidth, mapHeight, ...)
  end

  self:CreatePinType()

  CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function()
    self:HandleMapChange()
  end)
end

---Set the map to be rendered
---@param map WMP_Map
function WMP_Debug_Render:SetMap(map)
  self.map = map
end

---Resets the current draw map and redraws it
function WMP_Debug_Render:Reset()
  -- Release old path
  self.linkPool:ReleaseAllObjects()
  LMP:RemoveCustomPin(PIN_TYPE)
end

---Draws the current map information
function WMP_Debug_Render:Draw()
  -- Clear the old render
  self:Reset()

  if self.map == nil then
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
    local nodes = WMP_MAP_MAKER:GetMap():GetNodes()

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

---Draws a path on the current map
---@param startId number|nil
---@param goalId number|nil
function WMP_Debug_Render:DrawPath(startId, goalId)
  if not startId or not goalId then
    self:CaluclatePath()
  else
    -- Calculate a new path
    self:CaluclateShortestPath(startId, goalId)
  end

  local linkControl, startX, startY, endX, endY
  local mapWidth, mapHeight = ZO_WorldMapContainer:GetDimensions()

  -- Loop through new path
  for i, line in ipairs(self.path:GetLines()) do
    linkControl = self.linkPool:AcquireObject()

    linkControl.startX, linkControl.startY = line:GetStartPos()
    linkControl.endX, linkControl.endY = line:GetEndPos()

    --if linkControl.startX < linkControl.endX then
    --  linkControl:SetTexture("WorldMapPaths/Textures/tour_r.dds")
    --else
    --  linkControl:SetTexture("WorldMapPaths/Textures/tour_l.dds")
    --end
    linkControl:SetTexture("EsoUI/Art/AvA/AvA_transitLine.dds")
    -- 237, 177, 38
    -- linkControl:SetColor(0.8705883026123, 0.35686275362968, 0.30588236451149, 1)
    linkControl:SetColor(1, 1, 1, 1)
    linkControl:SetDrawLevel(1)

    startX, startY = linkControl.startX * mapWidth, linkControl.startY * mapHeight
    endX, endY = linkControl.endX * mapWidth, linkControl.endY * mapHeight

    ZO_Anchor_LineInContainer(linkControl, nil, startX, startY, endX, endY)
  end
end

do
  function WMP_Debug_Render:HandleMapChange()
    -- Remove the map marking
    self:Reset()

    if self.map == nil then
      return
    end

    local measurement = GPS:GetCurrentMapMeasurement()
    local zoneId = measurement:GetZoneId()

    -- Check to see if we should draw in this zone.
    if self.map:GetZoneId() == zoneId then
      self:Draw()
    end
  end

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

  ---Method for generating a path using a given world
  function WMP_Debug_Render:CaluclatePath()
    ---@type WMP_Path
    local path = WMP_Path:New()

    -- Get a path between all the nodes
    for _, node in ipairs(self.map:GetNodes()) do
      for _, neighbour in ipairs(node:GetNeighbours()) do
        path:AddLine(WMP_Line:New(node:GetLocalPosition(), neighbour:GetLocalPosition()))
      end
    end

    self.path = path
  end

  ---Method for generating a path using a given world
  function WMP_Debug_Render:CaluclateShortestPath(startId, goalId)
    ---@type WMP_Path
    local path = WMP_Path:New()

    local start = WMP_MAP_MAKER:GetMap():GetNode(startId)
    local goal = WMP_MAP_MAKER:GetMap():GetNode(goalId)

    if start == nil or goal == nil then
      d("Unable to find node ids in map")
      return
    end

    local shortestPath = WMP_Calculate(start, goal)

    if shortestPath == nil then
      d("Unabel to find shortest path")
      return
    end

    -- Loop through the short path and create lines
    if #shortestPath > 2 then
      for i = 2, #shortestPath do
        local lineEnd = shortestPath[i - 1]
        local lineStart = shortestPath[i]

        path:AddLine(WMP_Line:New(lineStart:GetLocalPosition(), lineEnd:GetLocalPosition()))
      end
    end

    self.path = path
  end
end

---@type WMP_Debug_Render
WMP_DEBUG_RENDERER = WMP_Debug_Render:New()
