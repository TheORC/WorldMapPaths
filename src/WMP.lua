---
--- @author: AnotherORC
---

local WMP = {}

WMP_SETTINGS = {
    NAME         = "WorldMapPaths",
    DISPLAY_NAME = "World Map Paths",
    VERSION      = "${VERSION}",
    AUTHOR       = "AnotherORC",
}

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

    SLASH_COMMANDS["/wmp"] = function(args)
        local options = parseCommandArgs(args)

        if #options == 0 or options[1] == 'help' then
            d('/wmp start - starts the map maker')
            d('/wmp reset - resets the map maker')
            d('/wmp add - adds a new node to the map and connect to previous.')
            d('/wmp add false - adds node but don\'t connect to previous.')
            d('/wmp connect %1 %2 - connect two nodes together')
            d('/wmp disconnect %1 %2 - remove the connection between two nodes')
            d('/wmp list - list all the map nodes')
            return;
        end

        local command = options[1]

        if command == 'start' then
            WMP_MAP_MAKER:Start();
        elseif command == 'add' then
            local attach = not (options[2] ~= nil and options[2] == "false")
            WMP_MAP_MAKER:AddNode(attach);
        elseif command == 'list' then
            WMP_Print(WMP_MAP_MAKER:GetMap():GetNodes())
        end
    end
end

EVENT_MANAGER:RegisterForEvent(WMP_SETTINGS.NAME, EVENT_ADD_ON_LOADED, OnAddonLoad)
