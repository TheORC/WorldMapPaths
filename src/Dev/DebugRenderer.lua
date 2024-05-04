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

---Draw the map
---@param startId number|nil
---@param goalId number|nil
function WMP_Debug_Render:Draw(startId, goalId)
  if self.map == nil then
    return
  end

  -- Clear the old render
  self:Reset()

  if not startId or not goalId then
    self:CaluclatePath()
  else
    -- Calculate a new path
    self:CaluclateShortestPath(startId, goalId)
  end

  local linkControl, startX, startY, endX, endY
  local mapWidth, mapHeight = ZO_WorldMapContainer:GetDimensions()

  d('draw points')
  -- All the nodes on the map
  local nodes = WMP_MAP_MAKER:GetMap():GetNodes()

  for _, node in ipairs(nodes) do
    LMP:CreatePin(PIN_TYPE, {
      node_id = node:GetId(),
    }, node:GetPosition().x, node:GetPosition().y, nil)
  end

  d('draw lines')

  -- Loop through new path
  for i, line in ipairs(self.path:GetLines()) do
    linkControl = self.linkPool:AcquireObject()

    linkControl.startX, linkControl.startY = line:GetStartPos()
    linkControl.endX, linkControl.endY = line:GetEndPos()

    if linkControl.startX < linkControl.endX then
      linkControl:SetTexture("WorldMapPaths/Textures/tour_r.dds")
    else
      linkControl:SetTexture("WorldMapPaths/Textures/tour_l.dds")
    end

    linkControl:SetColor(1, 0, 0, 1)
    linkControl:SetDrawLevel(10)

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
      d('same zone, time to draw')
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
        name = "Path Node Waypoint",
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
        path:AddLine(WMP_Line:New(node:GetPosition(), neighbour:GetPosition()))
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
    local shortestPath = WMP_Calculate(start, goal)

    -- Loop through the short path and create lines
    if #shortestPath > 2 then
      for i = 2, #shortestPath do
        local lineStart = shortestPath[i - 1]
        local lineEnd = shortestPath[i]

        path:AddLine(WMP_Line:New(lineStart:GetPosition(), lineEnd:GetPosition()))
      end
    end

    self.path = path
  end
end

---@type WMP_Debug_Render
WMP_DEBUG_RENDERER = WMP_Debug_Render:New()
