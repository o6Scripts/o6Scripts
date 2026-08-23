--!nocheck

local GITHUB_URL = "https://raw.githubusercontent.com/o6Scripts/o6Scripts/main"

local GAMES = {
    [74102906764176] = "games/greedy-growers.lua",
}

local placeId = game.PlaceId
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

local libSrc = fetch("uiloader.lua")
if not libSrc then
    warn("[Loader] Failed to fetch uiloader.lua")
    return
end
loadstring(libSrc)()


local gameSrc = fetch(scriptPath)
if gameSrc then
    loadstring(gameSrc)()
else
    warn("[Loader] Failed to fetch " .. scriptPath)
end
--!nocheck

local GITHUB_URL = "https://raw.githubusercontent.com/o6Scripts/o6Scripts/main"

local ok, src = pcall(game.HttpGet, game, GITHUB_URL .. "/uiloader.lua", true)
if ok and src then
    loadstring(src)()
else
    warn("[Loader] Failed to fetch uiloader.lua")
end
