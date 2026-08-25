if not game:IsLoaded() then
    game.Loaded:Wait()
end

local BASE = 'https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/games/'

local games = {
    [830072163] = 'greedygrowers.lua',
}

local file = games[game.CreatorId]
if file then
    loadstring(game:HttpGet(BASE .. file))()
end
