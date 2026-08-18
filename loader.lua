if not game:IsLoaded() then
    game.Loaded:Wait()
end


local BASE = 'https://raw.githubusercontent.com/o6Scripts/o6Scripts/tree/main/games'

local games = {
    [74102906764176]    = 'greedy-growers',
}   

local file = games[game.CreatorId]
if file then
    task.wait(math.random())
    loadstring(game:HttpGet(BASE .. file))()
end
