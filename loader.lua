--!nocheck
--[[
    o6Scripts Loader
    Usage: loadstring(game:HttpGet("https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/loader.lua"))()
]]

local GITHUB_URL = "https://raw.githubusercontent.com/o6Scripts/o6Scripts/main"
local CK_URL = "https://raw.githubusercontent.com/4lpaca-pin/CompKiller/main/src/source.luau"

local GAMES = {
    ["74102906764176"] = "games/greedy-growers.lua",
}

local placeId = tostring(game.PlaceId)
local scriptPath = GAMES[placeId]

if not scriptPath then
    warn("[o6] Unsupported game (PlaceId: " .. placeId .. ")")
    return
end

local function fetch(url)
    local ok, content = pcall(game.HttpGet, game, url, true)
    if ok and content and content ~= "" then
        return content
    end
    return nil
end

warn("[o6] Loading Compkiller...")
local libSrc = fetch(CK_URL)
if not libSrc then
    warn("[o6] Failed to load UI library")
    return
end
Compkiller = loadstring(libSrc)()
if not Compkiller then
    warn("[o6] Compkiller failed to initialize")
    return
end
warn("[o6] Compkiller loaded!")

warn("[o6] Loading script...")
local gameSrc = fetch(GITHUB_URL .. "/" .. scriptPath)
if gameSrc then
    loadstring(gameSrc)()
else
    warn("[o6] Failed to load game script")
end
