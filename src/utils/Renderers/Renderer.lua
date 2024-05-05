---Base class for path renderers
---@class WMP_Renderer
WMP_Renderer = ZO_InitializingObject:Subclass()

function WMP_Renderer:Initialize()
  self.path = nil
  self.linkPool = ZO_ControlPool:New("WMPLink", ZO_WorldMapContainer, 'Link')
  HandleMapZoom(self)
end

---Sets the path to be rendered
---@param path WMP_Path
function WMP_Renderer:SetPath(path)
  self.path = path
end

---Method used to clear the path
function WMP_Renderer:Clear()
  self.linkPool:ReleaseAllObjects()
end

---Method used to draw the path
function WMP_Renderer:Draw()
  assert(true, "WMP_Renderer:Draw() must be overriden.")
end

do
  ---Hacks into the SetDimensions function as we need to scale the displayed path whenever the user zooms in/out
  ---@param renderer WMP_Renderer
  function HandleMapZoom(renderer)
    -- Old method
    local oldDimensions = ZO_WorldMapContainer.SetDimensions

    ---@diagnostic disable-next-line: duplicate-set-field
    ZO_WorldMapContainer.SetDimensions = function(container, mapWidth, mapHeight, ...)
      local links = renderer.linkPool:GetActiveObjects()
      local startX, startY, endX, endY

      for _, link in pairs(links) do
        startX, startY, endX, endY = link.startX * mapWidth, link.startY * mapHeight, link.endX * mapWidth,
            link.endY * mapHeight
        ZO_Anchor_LineInContainer(link, nil, startX, startY, endX, endY)
      end

      oldDimensions(container, mapWidth, mapHeight, ...)
    end
  end
end
