--[[
    o6Scripts Loader
    One-liner: loadstring(game:HttpGet("https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/loader.lua"))()
]]

local PLACE_IDS = {
    [74102906764176] = "greedy-growers.lua",
    [0] = "criminality.lua",        -- Hier die richtige Place ID eintragen
    [0] = "monkey-escape.lua",      -- Hier die richtige Place ID eintragen
}

local BASE = "https://raw.githubusercontent.com/o6Scripts/o6Scripts/main"
local GAMES_BASE = BASE .. "/games/"
local CK_URL = BASE .. "/src/source.luau"

local placeId = game.PlaceId
local gameName = PLACE_IDS[placeId]

if not gameName then
    pcall(function()
        local starterGui = game:GetService("StarterGui")
        starterGui:SetCore("SendNotification", {
            Title = "o6Scripts",
            Text = "Unsupported game (PlaceId: " .. tostring(placeId) .. ")",
            Duration = 5,
        })
    end)
    return
end

print("[o6] Loading Compkiller...")
local success, ckSrc = pcall(function()
    return game:HttpGet(CK_URL)
end)

if not success or not ckSrc or #ckSrc < 100 then
    warn("[o6] Failed to fetch Compkiller library")
    return
end

local ckFunc, ckErr = loadstring(ckSrc)
if ckFunc then
    pcall(ckFunc)
end

print("[o6] Loading game script...")
local gameSuccess, gameSrc = pcall(function()
    return game:HttpGet(GAMES_BASE .. gameName)
end)

if gameSuccess and gameSrc then
    local gameFunc, gameErr = loadstring(gameSrc)
    if gameFunc then
        pcall(gameFunc)
    else
        warn("[o6] Failed to compile game script: " .. tostring(gameErr))
    end
else
    warn("[o6] Failed to download game script.")
end
