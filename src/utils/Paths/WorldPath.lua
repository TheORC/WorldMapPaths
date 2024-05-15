---@class WMP_WorldPath : WMP_ShortestPath
---@field pathNodes WMP_ZoneNode[]
---@diagnostic disable-next-line: undefined-field
WMP_WorldPath = WMP_ShortestPath:Subclass()

---Creates new world path calculator
---@param startZone WMP_Node
---@param endZone WMP_Node
function WMP_WorldPath:Initialize(startZone, endZone)
  WMP_ShortestPath.Initialize(self, startZone, endZone)

  self.zonePaths = {}

  self:TrimPath()
  self:ParseZoneInformation()

  -- Recalculate the path
  self.pathLines = self:NodesToLines(self.pathNodes)
end

---Returns the nodes in the provided zone.
---@param zondId integer
---@return WMP_ZoneNode[]|nil
function WMP_WorldPath:GetZoneNodes(zondId)
  return self.zonePaths[zondId]
end

do
  ---Parse the world path such that we can glean information about which parts of the path exist in
  ---which zones.
  function WMP_WorldPath:ParseZoneInformation()
    for _, node in ipairs(self.pathNodes) do
      local nodeZone = node:GetZoneId()

      if self.zonePaths[nodeZone] == nil then
        self.zonePaths[nodeZone] = {}
      end

      table.insert(self.zonePaths[nodeZone], node)
    end
  end

  ---Trims the path so that only a single node will exist in the start and end zones.
  ---This ensures that the closest path will always lead to the zone exit closest to the target
  ---location, even if that is not the closest exit for the zone.
  function WMP_WorldPath:TrimPath()
    -- Not enough data to trim
    if #self.pathNodes < 2 then
      return
    end

    local firstZoneId, lastZoneId = self.pathNodes[1]:GetZoneId(), self.pathNodes[#self.pathNodes]:GetZoneId()
    local firstIndex, lastIndex = 1, #self.pathNodes

    -- Trim leading nodes so that there is only a single node
    while self.pathNodes[firstIndex]:GetZoneId() == firstZoneId do
      firstIndex = firstIndex + 1
    end

    -- Trim trailing nodes so that there is only a single node
    while self.pathNodes[lastIndex]:GetZoneId() == lastZoneId do
      lastIndex = lastIndex - 1
    end

    local trimed = {}
    for i = firstIndex - 1, lastIndex + 1 do
      table.insert(trimed, self.pathNodes[i])
    end

    self.pathNodes = trimed
    self.startNode = self.pathNodes[1]
    self.endNode = self.pathNodes[#self.pathNodes]
  end
end
