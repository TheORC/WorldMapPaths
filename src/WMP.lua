---
--- @author: AnotherORC
--- GPS (But TPS)

WMP_SETTINGS = {
    NAME         = "WorldMapPaths",
    DISPLAY_NAME = "World Map Paths",
    VERSION      = "${VERSION}",
    AUTHOR       = "AnotherORC",
}

local IS_DEBUG = false
local IS_MAKE = false

---Returns the state of make mode
---@return boolean
function WMP_InMakeMode()
    return IS_MAKE
end

---Sets the state of make mode
---@param mode boolean
function WMP_SetMakeMode(mode)
    IS_MAKE = mode
    WMP_DebugMap_UI:SetHidden(not IS_MAKE)

    if IS_MAKE then
        WMP_TPS_MANAGER:Disable()
        WMP_TPS_DEBUG_MANAGER:Enable()
    else
        WMP_TPS_MANAGER:Enable()
        WMP_TPS_DEBUG_MANAGER:Disable()
    end
end

---Returns the state of debug mode
---@return boolean
function WMP_InDebugMode()
    return IS_DEBUG
end

---Sets the state of debug mode
---@param mode boolean
function WMP_SetDebugMode(mode)
    IS_DEBUG = mode
end

---Takes a string and splits it into words
---@param args string
---@return string[]
local function parseCommandArgs(args)
    local words = {}
    local pattern = "%S+" -- Match non-whitespace characters
    local startPos, endPos = string.find(args, pattern)

    while startPos do
        local word = string.sub(args, startPos, endPos)
        table.insert(words, string.lower(word))
        startPos, endPos = string.find(args, pattern, endPos + 1)
    end

    return words
end

---This method os called when the addon is loadded for the first time
---@param _ nil
---@param name string
local function OnAddonLoad(_, name)
    -- Check if this is our addon
    if name ~= WMP_SETTINGS.NAME then return end
    EVENT_MANAGER:UnregisterForEvent(WMP_SETTINGS.NAME, EVENT_ADD_ON_LOADED)



    -- Load our storage
    WMP_STORAGE:LoadData()
    WMP_TPS_MANAGER:LateInitialize()

    ZO_WorldMap_SetCustomZoomLevels(1, 15)

    WMP_SetMakeMode(false)
    WMP_SetDebugMode(true)

    WORLD_MAP_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if newState == 'shown' then
            WMP_DEBUG_RENDERER.m_mapSceneShowing = true

            if WMP_InMakeMode() then
                WMP_DEBUG_RENDERER:Draw()
            end
        else
            WMP_DEBUG_RENDERER.m_mapSceneShowing = false
        end
    end)

    SLASH_COMMANDS["/wmp"] = function(args)
        local options = parseCommandArgs(args)

        if #options == 0 or options[1] == 'help' then
            if WMP_InMakeMode() then
                WMP_MESSENGER:Message('/wmp make - toggle make mode')
                WMP_MESSENGER:Message('/wmp debug - toggle debug mode')
                WMP_MESSENGER:Message('/wmp start - starts the map maker')
                WMP_MESSENGER:Message('/wmp reset - resets the map maker')
                WMP_MESSENGER:Message('/wmp add - adds a new node to the map and connect to previous.')
                WMP_MESSENGER:Message('/wmp add false - adds node but don\'t connect to previous.')
                WMP_MESSENGER:Message('/wmp remove %1 - remove a node from the map.')
                WMP_MESSENGER:Message('/wmp connect %1 %2 - connect two nodes together')
                WMP_MESSENGER:Message('/wmp disconnect %1 %2 - remove the connection between two nodes')
                WMP_MESSENGER:Message('/wmp load - loads the current zone if it exists')
                WMP_MESSENGER:Message('/wmp save - saves the current zone to storage')
                WMP_MESSENGER:Message('/wmp list - list all the map nodes')
            else
                WMP_MESSENGER:Message('/wmp make - toggle make mode')
                WMP_MESSENGER:Message('/wmp debug - toggle debug mode')
            end

            return
        end

        local command = options[1]

        -- Toggle the state of the the debug mode
        if command == 'debug' then
            WMP_SetDebugMode(not WMP_InDebugMode())
            WMP_MESSENGER:Message("Debug state: <<1>>", WMP_InDebugMode() and "enabled" or "disabled")
            return
        elseif command == 'make' then
            WMP_SetMakeMode(not WMP_InMakeMode())
            WMP_MESSENGER:Message("Make state: <<1>>", WMP_InMakeMode() and "enabled" or "disabled")
            return
        end

        if not WMP_InMakeMode() then
            WMP_MESSENGER:Message("You may only issue commands when in make mode.  Use '/wmp make'")
            return
        end

        if command == 'start' then
            WMP_MAP_MAKER:Start()
        elseif command == 'reset' then
            WMP_MAP_MAKER:Reset()
        elseif command == 'add' then
            local attach = not (options[2] ~= nil and options[2] == "false")
            WMP_MAP_MAKER:AddNode(attach)
        elseif command == 'remove' then
            if #options ~= 2 then
                d('Command expects a node id')
                return
            end

            local nodeId = tonumber(options[2])

            if nodeId == nil then
                d('Node ids must be integers')
                return
            end

            WMP_MAP_MAKER:RemoveNode(nodeId)
        elseif command == 'connect' then
            if #options ~= 3 then
                d('Command expects two node ids')
                return
            end

            local nodeA, nodeB = tonumber(options[2]), tonumber(options[3])

            if nodeA == nil or nodeB == nil then
                d('Node ids must be integers')
                return
            end

            WMP_MAP_MAKER:AddConnection(nodeA, nodeB)
        elseif command == 'disconnect' then
            if #options ~= 3 then
                d('Command expects two node ids')
                return
            end

            local nodeA, nodeB = tonumber(options[2]), tonumber(options[3])

            if nodeA == nil or nodeB == nil then
                d('Node ids must be integers')
                return
            end

            WMP_MAP_MAKER:RemoveConnection(nodeA, nodeB)
        elseif command == 'list' then
            if WMP_MAP_MAKER:GetMap() == nil then
                d("No map loaded")
                return
            end

            WMP_Print(WMP_MAP_MAKER:GetMap():GetNodes())
        elseif command == 'save' then
            WMP_MAP_MAKER:Save()
        elseif command == 'load' then
            WMP_MAP_MAKER:Load()
        elseif command == 'update' then

        end
    end
end

EVENT_MANAGER:RegisterForEvent(WMP_SETTINGS.NAME, EVENT_ADD_ON_LOADED, OnAddonLoad)
