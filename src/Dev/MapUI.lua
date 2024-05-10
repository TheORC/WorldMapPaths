---@diagnostic disable: undefined-doc-name

---Class for creating a debug renderer
---@class WMP_Debug_Menu
local WMP_Debug_Menu = ZO_Object:Subclass()

function WMP_Debug_Menu:New(...)
  local object = ZO_Object.New(self)
  object:Initialize(...)
  return object
end

function WMP_Debug_Menu:Initialize(control)
  self.m_control = control
  self.m_edit = control:GetNamedChild("EditCopyBox")

  self.m_connectLast = control:GetNamedChild("AddRegionConnectLast")
  self.m_removeEdit = control:GetNamedChild("RemoveRegionRemoveEditEdit")

  self.m_connectAEdit = control:GetNamedChild("ConnectRegionNode1Edit")
  self.m_connectBEdit = control:GetNamedChild("ConnectRegionNode2Edit")

  self.m_disconnectAEdit = control:GetNamedChild("DisconnectRegionNode1Edit")
  self.m_disconnectBEdit = control:GetNamedChild("DisconnectRegionNode2Edit")

  self.m_saveButtonText = control:GetNamedChild("SaveText")
end

---Set the contents of the copy edit field
---@param text string
function WMP_Debug_Menu:SetTextCopy(text)
  self.m_edit:SetText(text)
end

---Method called to add a new node to the map
function WMP_Debug_Menu:AddNode()
  local connectLast = ZO_CheckButton_IsChecked(self.m_connectLast)
  WMP_MAP_MAKER:AddNode(connectLast)
  self:OnMapUpdate()
end

---Method called to remove a node from the map
function WMP_Debug_Menu:RemoveNode()
  local nodeId = tonumber(self.m_removeEdit:GetText())

  if not nodeId then
    d("Make sure you provide a numeric node id.")
    return
  end

  WMP_MAP_MAKER:RemoveNode(nodeId)
  self:OnMapUpdate()
end

---Method called to connect two nodes on the map
function WMP_Debug_Menu:ConnectNodes()
  local nodeAId, nodeBId = tonumber(self.m_connectAEdit:GetText()), tonumber(self.m_connectBEdit:GetText())

  if not nodeAId or not nodeBId then
    d("Make sure you provide two numeric node ids.")
    return
  end

  WMP_MAP_MAKER:AddConnection(nodeAId, nodeBId)
  self:OnMapUpdate()
end

---Method called to disconnect two nodes on the map
function WMP_Debug_Menu:DisconnectNodes()
  local nodeAId, nodeBId = tonumber(self.m_disconnectAEdit:GetText()), tonumber(self.m_disconnectBEdit:GetText())

  if not nodeAId or not nodeBId then
    d("Make sure you provide two numeric node ids.")
    return
  end

  WMP_MAP_MAKER:RemoveConnection(nodeAId, nodeBId)
  self:OnMapUpdate()
end

do
  ---Called when a change is made to the current map
  function WMP_Debug_Menu:OnMapUpdate()
    self.m_saveButtonText:SetColor(1, 0, 0, 1)
  end

  function WMP_Debug_Menu:OnMapSave()
    self.m_saveButtonText:SetColor(1, 1, 1, 1)
  end
end

---Get the Debug UI menu
---@return WMP_Debug_Menu
function WMP_GetDebugMenu()
  return WMP_DebugMap_UI.m_object
end

---Method called when the DebugUI is initialized
---@param self any
function WMP_DebugUI_OnInitialized(self)
  self.m_object = WMP_Debug_Menu:New(self)
end

---Sets the contents of the copy text field box
---@param text string
function WMP_DebugUI_SetCopytext(text)
  WMP_GetDebugMenu():SetTextCopy(text)
end

---Method used to focus text inside an EditBox when it revieves focus
---@param self EditBox
function WMP_DebugUI_OnEditFocus(self)
  local text = self:GetText() or ""
  self:SetSelection(0, #text)
end

---Method called to add a new node to the map
function WMP_DebugUI_Add()
  WMP_GetDebugMenu():AddNode()
end

---Method called to remove a node from the map
function WMP_DebugUI_Remove()
  WMP_GetDebugMenu():RemoveNode()
end

---Method called to connect to nodes on the map
function WMP_DebugUI_Connect()
  WMP_GetDebugMenu():ConnectNodes()
end

---Method called to connect to nodes on the map
function WMP_DebugUI_Disconnect()
  WMP_GetDebugMenu():DisconnectNodes()
end

---Method called when the show point setting is updated
function WMP_DebugUI_Setting_ShowPoint(self)
  local showPoint = not ZO_CheckButton_IsChecked(self)
  ZO_CheckButton_SetCheckState(self, showPoint)

  WMP_STORAGE:SetSetting(WMP_SETTING_KEYS.DEBUG_DRAW_POINT, showPoint)
  WMP_DEBUG_RENDERER:Draw()
end

---Method called when the show path setting is updated
function WMP_DebugUI_Setting_ShowPath(self)
  local showPath = not ZO_CheckButton_IsChecked(self)
  ZO_CheckButton_SetCheckState(self, showPath)

  WMP_STORAGE:SetSetting(WMP_SETTING_KEYS.DEBUG_DRAW_PATH, showPath)
  WMP_DEBUG_RENDERER:Draw()
end

---Method called to connect to nodes on the map
function WMP_DebugUI_Save()
  WMP_MAP_MAKER:Save()
  WMP_DebugMap_UI.m_object:OnMapSave()
end

---Method called to connect to nodes on the map
function WMP_DebugUI_Load()
  WMP_MAP_MAKER:Load()
end