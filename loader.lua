if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/uiloader.luau"))()
local BASE = 'https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/games/'

local games = {
    [830072163] = 'greedygrowers.lua',
}

local file = games[game.CreatorId]
if file then
    loadstring(game:HttpGet(BASE .. file))()
end
