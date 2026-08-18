if not game:IsLoaded() then
    game.Loaded:Wait()
end


local BASE = 'https://raw.githubusercontent.com/joustingmatch/Ouroboros/main/games/'

local games = {
    [9190691]    = 'greedy-growers',
}   

local file = games[game.CreatorId]
if file then
    task.wait(math.random())
    loadstring(game:HttpGet(BASE .. file))()
end
