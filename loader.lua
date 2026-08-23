--!nocheck

local GITHUB_URL = "https://raw.githubusercontent.com/o6Scripts/o6Scripts/main"

local ok, src = pcall(game.HttpGet, game, GITHUB_URL .. "/uiloader.lua", true)
if ok and src then
    loadstring(src)()
else
    warn("[Loader] Failed to fetch uiloader.lua")
end
