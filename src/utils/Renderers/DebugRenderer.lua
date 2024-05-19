---Filters a list bassed on the provided filter function
---@param arr any[]
---@param func function
---@return any[]
local function filter_inplace(arr, func)
  local filter = {}
  for i, v in ipairs(arr) do
    if func(v, i) then
      table.insert(filter, v)
    end
  end
  return filter
end

---Maps a list bassed on the provided map function
---@param arr any[]
---@param func function
---@return any[]
local function map_inplace(arr, func)
  local map = {}
  for i, v in ipairs(arr) do
    table.insert(map, func(v, i))
  end
  return map
end

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
  self.m_mapSceneShowing = false

  self.m_drawRegion = true
  self.m_drawExternal = true
  self.m_lastActiveZone = 0
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
  -- Why update the map when we are not looking at it
  if not self.m_mapSceneShowing then
    return
  end

  -- Clear the old render
  self:Clear()

  if not self.m_map then
    WMP_MESSENGER:Debug("WMP_Debug_Render:Draw() The render must have a map set to draw the paths")
    return
  end

  if WMP_STORAGE:GetSetting(WMP_SETTING_KEYS.DEBUG_DRAW_POINT) then
    WMP_MESSENGER:Debug("WMP_Debug_Render:Draw() Drawing map points")
    self:DrawPoints()
  end

  if WMP_STORAGE:GetSetting(WMP_SETTING_KEYS.DEBUG_DRAW_PATH) then
    WMP_MESSENGER:Debug("WMP_Debug_Render:Draw() Drawing map paths")
    self:DrawPath()
  end
end

---Draws all the points on the current map
function WMP_Debug_Render:DrawPoints()
  local nodes = self.m_map:GetNodes()

  for _, node in ipairs(nodes) do
    local nodePos = node:GetLocalPosition()
    local zoneId = 'none'

    if node:IsInstanceOf(WMP_ZoneNode) then
      zoneId = node:GetZoneId()
    end

    LMP:CreatePin(PIN_TYPE, {
      node_id = node:GetId(),
      zone_id = zoneId,
      neighbours = map_inplace(node:GetNeighbours(), function(neighbour)
        return neighbour:GetId()
      end)
    }, nodePos.x, nodePos.y, nil)
  end
end

---Draw the entire map
function WMP_Debug_Render:DrawPath()
  -- All the paths in the world
  local paths = self:GetWorldPaths()

  local color
  local linkControl, startPos, endPos, startX, startY, endX, endY
  local mapWidth, mapHeight = ZO_WorldMapContainer:GetDimensions()

  -- Loop through new path
  for _, line in ipairs(paths:GetLines()) do
    linkControl = self.linkPool:AcquireObject()

    startPos = line:GetStartPos()
    endPos = line:GetEndPos()

    color = line.color or { 1, 1, 1, 1 }

    linkControl.startX, linkControl.startY = startPos.x, startPos.y
    linkControl.endX, linkControl.endY = endPos.x, endPos.y

    linkControl:SetTexture("EsoUI/Art/AvA/AvA_transitLine.dds")
    linkControl:SetColor(unpack(color))
    linkControl:SetDrawLevel(1)

    startX, startY = linkControl.startX * mapWidth, linkControl.startY * mapHeight
    endX, endY = linkControl.endX * mapWidth, linkControl.endY * mapHeight

    ZO_Anchor_LineInContainer(linkControl, nil, startX, startY, endX, endY)
  end
end

---Sets the map the be rendered
---@param map any
function WMP_Debug_Render:SetMap(map)
  WMP_MESSENGER:Debug("WMP_Debug_Render:SetMap() Debug renderer map set")
  self.m_map = map
end

---Helper function for setting the zone which should be rendered
---@param zoneId any
function WMP_Debug_Render:SetActiveZone(zoneId)
  self.m_lastActiveZone = zoneId
end

---Helper function to set whether the rendered should draw region connections
---@param value boolean
function WMP_Debug_Render:SetDrawRegion(value)
  self.m_drawRegion = value
end

---Helper function to set whether the rendered should draw external connections
---@param value boolean
function WMP_Debug_Render:SetDrawExternal(value)
  self.m_drawExternal = value
end

do
  ---Create the map pin type allowing us to see where our nodes are placed
  function WMP_Debug_Render:CreatePinType()
    -- Create the pin type
    LMP:AddPinType(PIN_TYPE, function() end, nil, nil, {
      creator = function(pin)
        local _, pinData = pin:GetPinTypeAndTag()
        InformationTooltip:AddLine(zo_strformat("Id: <<1>>", pinData.node_id))

        if pinData.zone_id ~= 'none' then
          InformationTooltip:AddLine(zo_strformat("Zone: <<1>>", pinData.zone_id))
        end

        if #pinData.neighbours > 0 then
          for _, id in ipairs(pinData.neighbours) do
            InformationTooltip:AddLine(zo_strformat("Neighbour: <<1>>", id))
          end
        end
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
    local isZoneMap = self.m_map:GetZoneId() == 0

    ---Returns whether a node connection is one way
    ---@param node1 WMP_Node
    ---@param node2 WMP_Node
    ---@return boolean
    local function isBothWays(node1, node2)
      return node1:HasNeighbour(node2:GetId()) == true and node2:HasNeighbour(node1:GetId()) == true
    end

    ---Adds a new line to the path
    ---@param node1 any
    ---@param node2 any
    local function addLine(node1, node2)
      local color = { 1, 1, 1, 1 }
      if not isBothWays(node1, node2) then
        color = { 1, 0, 1, 1 }
      end
      ---@diagnostic disable-next-line: undefined-field
      path:AddLine(WMP_Line:New(node1:GetLocalPosition(), node2:GetLocalPosition(), color))
    end

    -- Get a path between all the nodes
    for _, node in ipairs(self.m_map:GetNodes()) do
      for _, neighbour in ipairs(node:GetNeighbours()) do
        if node == nil then
          d("A node is broken!")
        end

        if neighbour == nil then
          d("A neighbour is broken")
        end

        if isZoneMap then
          if self.m_drawRegion and node:GetZoneId() == neighbour:GetZoneId() then
            addLine(node, neighbour)
          end

          if self.m_drawExternal and node:GetZoneId() ~= neighbour:GetZoneId() then
            addLine(node, neighbour)
          end
        else
          addLine(node, neighbour)
        end
      end
    end

    return path
  end

  ---Returns a list of only nodes from the specified region
  ---@param zoneId integer
  ---@return WMP_Node[]
  function WMP_Debug_Render:GetRegionNodes(zoneId)
    local allNodes = self.m_map:GetNodes()

    return filter_inplace(allNodes, function(node)
      return node:GetZoneId() == zoneId
    end)
  end

  function WMP_Debug_Render:GetExternalNodes()

  end
end

---@type WMP_Debug_Render
---@diagnostic disable-next-line: undefined-field
WMP_DEBUG_RENDERER = WMP_Debug_Render:New()
