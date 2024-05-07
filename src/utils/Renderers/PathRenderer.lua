---Class for creating a path renderer
---@class WMP_Path_Render : WMP_Renderer
WMP_Path_Render = WMP_Renderer:Subclass()

function WMP_Path_Render:Initialize()
  WMP_Renderer.Initialize(self)
end

---Method for drawing the provided path on the current map
function WMP_Path_Render:Draw()
  self:Clear()

  if self.path == nil then
    return
  end

  self:DrawPath()
end

do
  ---Method for drawing a path on the current map
  function WMP_Path_Render:DrawPath()
    local linkControl, startX, startY, endX, endY
    local mapWidth, mapHeight = ZO_WorldMapContainer:GetDimensions()

    for i, line in ipairs(self.path:GetLines()) do
      -- Get a new line
      linkControl = self.linkPool:AcquireObject()

      -- Set the start and end positions
      linkControl.startX, linkControl.startY = line:GetStartPos()
      linkControl.endX, linkControl.endY = line:GetEndPos()

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
