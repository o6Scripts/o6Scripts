--[
    o6Scripts Loader
    One-liner: loadstring(game:HttpGet("https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/loader.lua"))()
]--

local PLACE_IDS = {
    [74102906764176] = "games/greedy-growers.lua",
}

local BASE = "https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/"
local CK_URL = "https://raw.githubusercontent.com/4lpaca-pin/CompKiller/main/src/source.luau"

local placeId = game.PlaceId
local gameScript = PLACE_IDS[placeId]

-- Überprüfen, ob das Spiel unterstützt wird
if not gameScript then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "o6Scripts",
            Text = "Unsupported game (PlaceId: " .. tostring(placeId) .. ")",
            Duration = 5,
        })
    end)
    warn("[o6Scripts] Unsupported game ID: " .. tostring(placeId))
    return
end

print("[o6Scripts] Loading Compkiller...")

-- Compkiller sicher abrufen
local success, ckSrc = pcall(function()
    return game:HttpGet(CK_URL)
end)

if not success or not ckSrc or #ckSrc < 1000 then
    warn("[o6Scripts] Compkiller fetch failed or source too small.")
    return
end

local ckFn, ckErr = loadstring(ckSrc)
if not ckFn then
    warn("[o6Scripts] Compkiller compile error: " .. tostring(ckErr))
    return
end

local successRun, Compkiller = pcall(ckFn)
if not successRun or not Compkiller then
    warn("[o6Scripts] Failed to execute Compkiller library.")
    return
end

print("[o6Scripts] Compkiller loaded successfully!")

-- Das eigentliche spielspezifische Skript laden
print("[o6Scripts] Loading game script...")
local gameSuccess, gameSrc = pcall(function()
    return game:HttpGet(BASE .. gameScript)
end)

if not gameSuccess or not gameSrc then
    warn("[o6Scripts] Failed to fetch game script from: " .. gameScript)
    return
end

local runGame, gameErr = loadstring(gameSrc)
if not runGame then
    warn("[o6Scripts] Game script compile error: " .. tostring(gameErr))
    return
end

-- Spiel-Skript ausführen
task.spawn(runGame)
print("[o6Scripts] Game script executed!")
