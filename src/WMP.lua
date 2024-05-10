---
--- @author: AnotherORC
---

local WMP = {}
local IS_DEBUG = true

WMP_SETTINGS = {
    NAME         = "WorldMapPaths",
    DISPLAY_NAME = "World Map Paths",
    VERSION      = "${VERSION}",
    AUTHOR       = "AnotherORC",
}

WMP_ADD_NODE_TEXT = "Add node"

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

    ZO_CreateStringId("WMP_ADD_NODE_TEXT", WMP_ADD_NODE_TEXT)
    SafeAddVersion("WMP_ADD_NODE_TEXT", 1)
    ZO_CreateStringId("SI_BINDING_NAME_WMP_ADD_NODE", GetString(WMP_ADD_NODE_TEXT))

    -- Load our storage
    WMP_STORAGE:LoadData()
    WMP_MAP_MANAGER:LateInitialize()

    SLASH_COMMANDS["/wmp"] = function(args)
        local options = parseCommandArgs(args)

        if #options == 0 or options[1] == 'help' then
            d('/wmp debug - toggle debug mode')
            d('/wmp start - starts the map maker')
            d('/wmp reset - resets the map maker')
            d('/wmp add - adds a new node to the map and connect to previous.')
            d('/wmp add false - adds node but don\'t connect to previous.')
            d('/wmp remove %1 - remove a node from the map.')
            d('/wmp connect %1 %2 - connect two nodes together')
            d('/wmp disconnect %1 %2 - remove the connection between two nodes')
            d('/wmp load - loads the current zone if it exists')
            d('/wmp save - saves the current zone to storage')
            d('/wmp list - list all the map nodes')
            d('/wmp draw - draw the current map')
            return
        end

        local command = options[1]

        if command == 'debug' then
            if WMP_DEBUG_CONTROLLER:IsDebug() then
                WMP_DEBUG_CONTROLLER:DisableDebug()
            else
                WMP_DEBUG_CONTROLLER:EnableDebug()
            end

            return
        end

        if not WMP_DEBUG_CONTROLLER:IsDebug() then
            d("Commands only active during debug mode")
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
        elseif command == 'draw' then
            if map == nil then
                d("No map to draw")
                return
            end

            WMP_DEBUG_RENDERER:SetMap(map)
            WMP_DEBUG_RENDERER:Draw()
        elseif command == 'save' then
            WMP_MAP_MAKER:Save()
        elseif command == 'load' then
            WMP_MAP_MAKER:Load()
        elseif command == 'update' then

        end
    end
end

EVENT_MANAGER:RegisterForEvent(WMP_SETTINGS.NAME, EVENT_ADD_ON_LOADED, OnAddonLoad)
