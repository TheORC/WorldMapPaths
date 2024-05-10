---@class WMP_WorldUI
local WMP_WorldUI = ZO_InitializingObject:Subclass()

function WMP_WorldUI:Initialize(control)
  self.m_control = control

  self.m_edit = control:GetNamedChild("EditCopyBox")
  self.m_removeEdit = control:GetNamedChild("RemoveRegionRemoveEditEdit")
  self.m_connectAEdit = control:GetNamedChild("ConnectRegionNode1Edit")
  self.m_connectBEdit = control:GetNamedChild("ConnectRegionNode2Edit")
  self.m_disconnectAEdit = control:GetNamedChild("DisconnectRegionNode1Edit")
  self.m_disconnectBEdit = control:GetNamedChild("DisconnectRegionNode2Edit")
  self.m_saveButtonText = control:GetNamedChild("SaveLabel")
end

---Set the contents of the copy edit field
---@param text string
function WMP_WorldUI:SetTextCopy(text)
  self.m_edit:SetText(text)
end

---Method called to add a new node to the map
function WMP_WorldUI:AddNode()
  WMP_WORLD_MAKER:AddNode()
  self:OnMapUpdate()
end

---Removes a node from the world map
function WMP_WorldUI:RemoveNode()
  local nodeId = tonumber(self.m_removeEdit:GetText())

  if not nodeId then
    d("Make sure you provide a numeric node id.")
    return
  end

  WMP_WORLD_MAKER:RemoveNode(nodeId)
  self:OnMapUpdate()
end

---Method called to connect two nodes on the map
function WMP_WorldUI:ConnectNodes()
  local nodeAId, nodeBId = tonumber(self.m_connectAEdit:GetText()), tonumber(self.m_connectBEdit:GetText())

  if not nodeAId or not nodeBId then
    d("Make sure you provide two numeric node ids.")
    return
  end

  WMP_WORLD_MAKER:AddConnection(nodeAId, nodeBId)
  self:OnMapUpdate()
end

---Method called to disconnect two nodes on the map
function WMP_WorldUI:DisconnectNodes()
  local nodeAId, nodeBId = tonumber(self.m_disconnectAEdit:GetText()), tonumber(self.m_disconnectBEdit:GetText())

  if not nodeAId or not nodeBId then
    d("Make sure you provide two numeric node ids.")
    return
  end

  WMP_WORLD_MAKER:RemoveConnection(nodeAId, nodeBId)
  self:OnMapUpdate()
end

do
  ---Called when a change is made to the current map
  function WMP_WorldUI:OnMapUpdate()
    self.m_saveButtonText:SetColor(1, 0, 0, 1)
  end

  function WMP_WorldUI:OnMapSave()
    self.m_saveButtonText:SetColor(1, 1, 1, 1)
  end
end

---Get the Debug UI menu
---@return WMP_WorldUI
function WMP_GetWorldUI()
  return WMP_WorldMap_UI.m_object
end

function WMP_WorldUI_OnInitialized(self)
  self.m_object = WMP_WorldUI:New(self)
end

function WMP_WorldUI_AddNode(self)
  d(self.m_object)
  WMP_GetWorldUI():AddNode()
end

function WMP_WorldUI_RemoveNode(self)
  WMP_GetWorldUI():RemoveNode()
end

function WMP_WorldUI_AddConnection(self)
  WMP_GetWorldUI():ConnectNodes()
end

function WMP_WorldUI_RemoveConnection(self)
  WMP_GetWorldUI():DisconnectNodes()
end

function WMP_WorldUI_ShowPath(self)
  local showPoint = not ZO_CheckButton_IsChecked(self)
  ZO_CheckButton_SetCheckState(self, showPoint)

  WMP_STORAGE:SetSetting(WMP_SETTING_KEYS.DEBUG_DRAW_POINT, showPoint)

  WMP_DEBUG_RENDERER:Draw()
end

function WMP_WorldUI_ShowNodes(self)
  local showPath = not ZO_CheckButton_IsChecked(self)
  ZO_CheckButton_SetCheckState(self, showPath)

  WMP_STORAGE:SetSetting(WMP_SETTING_KEYS.DEBUG_DRAW_PATH, showPath)

  WMP_DEBUG_RENDERER:Draw()
end

---Sets the contents of the copy text field box
---@param text string
function WMP_WorldUI_SetCopytext(text)
  WMP_GetWorldUI():SetTextCopy(text)
end

function WMP_WorldUI_Save(self)
  WMP_WORLD_MAKER:Save()
end
