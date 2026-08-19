if not game:IsLoaded() then
    game.Loaded:Wait()
end

local BASE = 'https://raw.githubusercontent.com/o6Scripts/o6scripts/main/games/'

local games = {
    [74102906764176] = 'greedy-growers.lua',
    [10144280947] = 'monkey-espace.lua',
}

local file = games[game.PlaceId]
if file then
    task.wait(math.random())
    loadstring(game:HttpGet(BASE .. file))()
end
