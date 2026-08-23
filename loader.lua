if not game:IsLoaded() then
    game.Loaded:Wait()
end

local BASE = 'https://raw.githubusercontent.com/o6Scripts/o6scripts/main/'

local Library = loadstring(game:HttpGet(BASE .. 'uiloader.lua'))()

local Window = Library:CreateWindow("o6Scripts Hub")

local games = {
    [74102906764176] = 'greedy-growers.lua',
    [114697347887839] = 'monkey-escape.lua',
    [4588604953] = 'criminality.lua',
}

local file = games[game.PlaceId]
if file then
    task.wait(math.random())
    local gameScript = loadstring(game:HttpGet(BASE .. 'games/' .. file))()
    if type(gameScript) == "function" then
        gameScript(Window)
    end
end
