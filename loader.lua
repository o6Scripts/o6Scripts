--[========================================================[
    o6Scripts Loader (Modular & Fehlerfrei)
    One-liner: loadstring(game:HttpGet("https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/loader.lua"))()
]========================================================]

local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

-- Konfiguration: PlaceIDs und die dazugehörigen Skripte
local GAMES = {
    [74102906764176] = "games/greedy-growers.lua",
    -- Weitere Spiele kannst du hier ganz einfach hinzufügen:
    -- [PLACE_ID_HIER] = "games/dein-spiel.lua",
}

local REPO_BASE = "https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/"
local COMPKILLER_URL = "https://raw.githubusercontent.com/4lpaca-pin/CompKiller/main/src/source.luau"

-- Benachrichtigungs-Helper
local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 4,
        })
    end)
    print(string.format("[%s] %s", title, text))
end

-- 1. Spiel-Überprüfung
local currentPlaceId = game.PlaceId
local targetScriptPath = GAMES[currentPlaceId]

if not targetScriptPath then
    notify("o6Scripts", "Nicht unterstütztes Spiel! (ID: " .. tostring(currentPlaceId) .. ")")
    return
end

-- 2. Compkiller-Bibliothek laden
notify("o6Scripts", "Lade Compkiller...")

local successCk, ckSource = pcall(function()
    return game:HttpGet(COMPKILLER_URL)
end)

if not successCk or not ckSource or #ckSource < 500 then
    notify("o6Scripts", "Fehler: Compkiller konnte nicht geladen werden.")
    return
end

local loadCkFn, errCk = loadstring(ckSource)
if not loadCkFn then
    notify("o6Scripts", "Compkiller Syntax-Fehler: " .. tostring(errCk))
    return
end

local runCk, compkillerLib = pcall(loadCkFn)
if not runCk or not compkillerLib then
    notify("o6Scripts", "Compkiller Ausführungsfehler.")
    return
end

notify("o6Scripts", "Compkiller erfolgreich geladen!")

-- 3. Spielspezifisches Skript laden
notify("o6Scripts", "Lade Spiel-Skript...")

local scriptUrl = REPO_BASE .. targetScriptPath
local successGame, gameSource = pcall(function()
    return game:HttpGet(scriptUrl)
end)

if not successGame or not gameSource then
    notify("o6Scripts", "Fehler: Spiel-Skript nicht gefunden (" .. targetScriptPath .. ")")
    return
end

local loadGameFn, errGame = loadstring(gameSource)
if not loadGameFn then
    notify("o6Scripts", "Skript Syntax-Fehler: " .. tostring(errGame))
    return
end

-- 4. Spiel-Skript ausführen (übergibt optional Compkiller falls benötigt)
local successExec, execErr = pcall(function()
    loadGameFn(compkillerLib)
end)

if not successExec then
    notify("o6Scripts", "Laufzeitfehler im Skript: " .. tostring(execErr))
    warn(execErr)
    return
end

notify("o6Scripts", "Skript erfolgreich gestartet!")
