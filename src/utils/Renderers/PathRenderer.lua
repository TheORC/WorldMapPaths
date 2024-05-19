---Class for creating a path renderer
---@class WMP_PathRender : WMP_Renderer
---@diagnostic disable-next-line: undefined-field
local WMP_PathRender = WMP_Renderer:Subclass()

function WMP_PathRender:Initialize()
  WMP_Renderer.Initialize(self, 'Path')
end

---Method for drawing the provided path on the current map
function WMP_PathRender:Draw()
  self:Clear()

  if self.path == nil then
    return
  end

  self:DrawPath()
end

do
  ---Method for drawing a path on the current map
  function WMP_PathRender:DrawPath()
    local linkControl, startPos, endPos, startX, startY, endX, endY
    local mapWidth, mapHeight = ZO_WorldMapContainer:GetDimensions()

    for _, line in ipairs(self.path:GetLines()) do
      -- Get a new line
      linkControl = self.linkPool:AcquireObject()

      startPos = line:GetStartPos()
      endPos = line:GetEndPos()

      -- Set the start and end positions
      linkControl.startX, linkControl.startY = startPos.x, startPos.y
      linkControl.endX, linkControl.endY = endPos.x, endPos.y

      linkControl:SetTexture("EsoUI/Art/AvA/AvA_transitLine.dds")
      linkControl:SetColor(1, 1, 1, 1)
      linkControl:SetDrawLevel(1)

      -- Traslate positions to the world size
      startX, startY = linkControl.startX * mapWidth, linkControl.startY * mapHeight
      endX, endY = linkControl.endX * mapWidth, linkControl.endY * mapHeight

      -- Draw the line
      ZO_Anchor_LineInContainer(linkControl, nil, startX, startY, endX, endY)
    end
  end
end

---@type WMP_PathRender
---@diagnostic disable-next-line: undefined-field
WMP_PATH_RENDERER = WMP_PathRender:New()
