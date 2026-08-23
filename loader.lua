if not game:IsLoaded() then
    game.Loaded:Wait()
end

local BASE = 'https://raw.githubusercontent.com/o6Scripts/o6scripts/main/'

-- 1. Lade deine UI-Library aus der uiloader.lua
local Library = loadstring(game:HttpGet(BASE .. 'uiloader.lua'))()

-- 2. Erstelle das Hauptfenster (passe den Namen hier nach Wunsch an)
local Window = Library:CreateWindow("o6Scripts")

-- 3. Spiele-Tabelle
local games = {
    [74102906764176] = 'greedy-growers.lua',
    [114697347887839] = 'monkey-escape.lua',
    [4588604953] = 'criminality.lua',
}

local file = games[game.PlaceId]
if file then
    task.wait(math.random())
    -- 4. Lade das Spiel-Skript und übergebe das Fenster
    local gameScript = loadstring(game:HttpGet(BASE .. 'games/' .. file))()
    if type(gameScript) == "function" then
        gameScript(Window)
    end
end
