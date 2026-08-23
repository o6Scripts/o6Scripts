--[[
    o6Scripts Loader
    One-liner: loadstring(game:HttpGet("https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/loader.lua"))()
]]

local PLACE_IDS = {
    [74102906764176] = "greedy-growers.lua",
}

local CDN = "https://cdn.jsdelivr.net/gh/o6Scripts/o6Scripts@main"
local CK_URL = CDN .. "https://github.com/4lpaca-pin/CompKiller/main/src/source.luau"

local placeId = game.PlaceId
local gameName = PLACE_IDS[placeId]

if not gameName then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "o6Scripts",
        Text = "Unsupported game (PlaceId: " .. tostring(placeId) .. ")",
        Duration = 5,
    })
    return
end

print("[o6] Loading Compkiller...")
local ckSrc = game:HttpGet(CK_URL)
if not ckSrc or #ckSrc < 10000 then
    warn("[o6] Compkiller fetch failed or truncated (" .. tostring(#ckSrc or 0) .. " bytes). Retry or check CDN.")
    return
end
local Compkiller = loadstring(ckSrc)()
if not Compkiller then
    warn("[o6] Failed to load Compkiller library")
    return
end
print("[o6] Compkiller loaded!")

print("[o6] Loading script: " .. gameName)
local scriptUrl = CDN .. "/games/" .. gameName .. ".lua"
local scriptSrc = game:HttpGet(scriptUrl)
if not scriptSrc or #scriptSrc < 100 then
    warn("[o6] Failed to fetch game script: " .. gameName)
    return
end
loadstring(scriptSrc)()
print("[o6] Script loaded!")
