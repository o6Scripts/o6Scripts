local RAW_BASE = "https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/"

local function fetch(path)
    local ok, result = pcall(game.HttpGet, game, RAW_BASE .. path, true)
    if not ok or not result then
        error("[UILoader] Fetch failed: " .. path)
    end
    return result
end

getgenv().Library = loadstring(fetch("ui.luau"))()

local Games = {
    [5158726049] = "games/greedy-growers.lua",
    [2788229376] = "games/criminality.lua",
    [4924922222] = "games/monkey-escape.lua",
}

local path = Games[game.PlaceId]

if path then
    local ok, err = pcall(loadstring(fetch(path)))
    if not ok then
        warn("[UILoader] Game script error: " .. tostring(err))
    end
else
    warn("[UILoader] NO Script for PlaceId: " .. game.PlaceId)
end
