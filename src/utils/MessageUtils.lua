--- Message colour values
local MessageModes = {
  MESSAGE = "808000",
  DEBUG = "808080",
  WARN = "FFAA33",
  ERROR = "FF0000"
}

---Sends a message bassed on the mode.
---@param mode string
---@param message string
---@param ... any
local function WMP_Message(mode, message, ...)
  -- We don't display this mesasge
  if mode ~= MessageModes.MESSAGE and not WMP_InDebugMode() then
    return
  end

  local convertedArgs = { ... }
  for i, item in ipairs(convertedArgs) do
    convertedArgs[i] = tostring(item)
  end

  d(zo_strformat("|c0000F1[TPS]:|r |c<<1>><<2>>|r", mode, zo_strformat(message, unpack(convertedArgs))))
end

---@class WMP_Messenger
local WMP_Messenger = ZO_Object:Subclass()

---Creates a new messenger object
---@return WMP_Messenger
function WMP_Messenger:New()
  local object = ZO_Object.New(self)
  ---@diagnostic disable-next-line: return-type-mismatch
  return object
end

---Sends a normal message
---@param message string
---@param ... any
function WMP_Messenger:Message(message, ...)
  WMP_Message(MessageModes.MESSAGE, message, ...)
end

---Sends a debug message
---@param message string
---@param ... any
function WMP_Messenger:Debug(message, ...)
  WMP_Message(MessageModes.DEBUG, message, ...)
end

---Sends a warning message
---@param message string
---@param ... any
function WMP_Messenger:Warn(message, ...)
  WMP_Message(MessageModes.WARN, message, ...)
end

---Sends an error message
---@param message string
---@param ... any
function WMP_Messenger:Error(message, ...)
  WMP_Message(MessageModes.ERROR, message, ...)
end

WMP_MESSENGER = WMP_Messenger:New()
