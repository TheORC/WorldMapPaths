---Initiates focus edit box
---@param self any
---@param defaultText string
function WMP_EditBackdrop_OnInitialized(self, defaultText)
  if defaultText == nil then
    return
  end

  local editBox = self:GetNamedChild("Edit")
  editBox:SetDefaultText(defaultText)
end

---Initiates a button with a label
---@param self any
---@param labelText string
function WMP_LabelButton_OnInitialized(self, labelText)
  if labelText == nil then
    return
  end

  local label = self:GetNamedChild("Label")
  label:SetText(zo_strformat("|cFFAA33<<1>>|r", labelText))
end

---Initiates a checkbox with a label
---@param self any
---@param state boolean
---@param labelText string
function WMP_LabelCheck_OnInitialized(self, state, labelText)
  ZO_CheckButton_SetCheckState(self, state)

  if labelText == nil then
    return
  end

  local label = self:GetNamedChild("Label")
  label:SetText(zo_strformat("|cFFAA33<<1>>|r", labelText))
end
