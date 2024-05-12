local english = {
  WMP_ADD_NODE_TEXT = "Add node"
}

-- Load all the english words in as default
for index, value in pairs(english) do
  ZO_CreateStringId(index, value)
  SafeAddVersion(index, 1)
  ZO_CreateStringId(zo_strformat("SI_BINDING_NAME_<<1>>", index), GetString(index, 1))
end
