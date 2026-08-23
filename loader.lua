--!nocheck
--[[
    Loader - Game Detection + Script Loader
    1. Detects game by PlaceId
    2. Loads Compkiller library
    3. Loads game script
]]

local GITHUB_URL = "https://raw.githubusercontent.com/o6Scripts/o6Scripts/main"

local GAMES = {
    ["74102906764176"] = "games/greedy-growers.lua",
}

local placeId = tostring(game.PlaceId)
local scriptPath = GAMES[placeId]

if not scriptPath then
    warn("[Loader] Unsupported game (PlaceId: " .. placeId .. ")")
    return
end

local function fetch(path)
    local ok, content = pcall(game.HttpGet, game, GITHUB_URL .. "/" .. path, true)
    if ok and content and content ~= "" then
        return content
    end
    return nil
end

-- 1. Load Compkiller library
local libSrc = fetch("uiloader.lua")
if not libSrc then
    warn("[Loader] Failed to fetch uiloader.lua")
    return
end
loadstring(libSrc)()

-- 2. Load game script (has access to global Compkiller)
local gameSrc = fetch(scriptPath)
if gameSrc then
    loadstring(gameSrc)()
else
    warn("[Loader] Failed to fetch " .. scriptPath)
end
