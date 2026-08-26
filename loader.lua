if not game:IsLoaded() then game.Loaded:Wait() end

local function safeLoad(url)
    local ok, content = pcall(game.HttpGet, game, url)
    if not ok or not content or #content < 50 then warn("[Loader] HttpGet failed "..url..": "..tostring(content)) return nil end
    local fn, err = loadstring(content)
    if not fn then warn("[Loader] loadstring failed: "..tostring(err)) return nil end
    local ok2, res = pcall(fn)
    if not ok2 then warn("[Loader] pcall failed: "..tostring(res)) return nil end
    return res -- Library Table oder nil
end

local Library = safeLoad("https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/uiloader.luau")
if not Library then warn("[Loader] Library nil - check uiloader.luau raw 200") return end

local BASE = "https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/games/"
local games = {
    [830072163] = "greedy-growers.lua", -- mit - wie File wirklich heißt
}
local file = games[game.CreatorId]
if file then
    local ok, err = pcall(function() loadstring(game:HttpGet(BASE .. file))() end)
    if not ok then warn("[Loader] Game load failed: "..tostring(err)) end
else
    warn("[Loader] Kein Game für CreatorId "..game.CreatorId)
end
