---Class representation of a map.
---@class WMP_Map : WMP_MapBuilder
WMP_Map = WMP_MapBuilder:Subclass()

---Creates a new map data structure
---@param zoneId integer
function WMP_Map:Initialize(zoneId)
  WMP_MapBuilder.Initialize(self)
  self.zoneId = zoneId
end

---Retunrs the map's zone id
---@return integer
function WMP_Map:GetZoneId()
  return self.zoneId
end

---Returns the shortest path between two nodes with the given ids
---@param startId integer
---@param endId integer
function WMP_Map:GetPath(startId, endId)
  assert(false, "GetPath() must be implemented before using")
end

---Format a zone map so it can saved to storage
---@param map WMP_Map
---@return table
function WMP_Map:MapToStorage(map)
  assert(false, 'You must implement a map to storage method.')
  return {}
end

---Creates a map from stored map data
---@param mapData table
---@return WMP_Map|nil
function WMP_Map:StorageToMap(mapData)
  assert(false, 'You must implement a storage to map method.')
  return nil
end
