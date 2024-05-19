local english = {
  WMP_ADD_NODE_TEXT = "Add node"
}

-- Load all the english words in as default
for index, value in pairs(english) do
  ZO_CreateStringId(index, value)
  SafeAddVersion(index, 1)
end

---@diagnostic disable-next-line: missing-parameter
ZO_CreateStringId("SI_BINDING_NAME_WMP_ADD_NODE_TEXT", GetString(WMP_ADD_NODE_TEXT))
