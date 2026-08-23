--[[
    o6Scripts Loader
    One-liner: loadstring(game:HttpGet("https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/loader.lua"))()
]]

local PLACE_IDS = {
    [74102906764176] = "greedy-growers",
}

local BASE = "https://raw.githubusercontent.com/o6Scripts/o6Scripts/main"
local CK_URL = "https://raw.githubusercontent.com/4lpaca-pin/CompKiller/main/src/source.luau"

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
    warn("[o6] Compkiller fetch failed (" .. tostring(#ckSrc or 0) .. " bytes)")
    return
end
local ckFn, ckErr = loadstring(ckSrc)
if not ckFn then
    warn("[o6] Compkiller compile error: " .. tostring(ckErr))
    return
end
local Compkiller = ckFn()
if not Compkiller then
    warn("[o6] Failed to load Compkiller library")
    return
end
getgenv().Compkiller = Compkiller
print("[o6] Compkiller loaded!")

print("[o6] Loading script: " .. gameName)
local scriptUrl = BASE .. "/games/" .. gameName .. ".lua"
local scriptSrc = game:HttpGet(scriptUrl)
if not scriptSrc or #scriptSrc < 100 then
    warn("[o6] Failed to fetch game script: " .. gameName)
    return
end
local fn, loadErr = loadstring(scriptSrc)
if not fn then
    warn("[o6] Compile error: " .. tostring(loadErr))
    return
end
fn()
print("[o6] Script loaded!")
