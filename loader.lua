if not game:IsLoaded() then game.Loaded:Wait() end

local function safeLoad(url)
    local ok, content = pcall(game.HttpGet, game, url)
    if not ok or not content or #content < 100 then
        warn("[Loader] HttpGet failed "..url..": "..tostring(content))
        return nil
    end
    local fn, err = loadstring(content)
    if not fn then
        warn("[Loader] loadstring failed: "..tostring(err))
        return nil
    end
    local ok2, res = pcall(fn)
    if not ok2 then
        warn("[Loader] pcall failed: "..tostring(res))
        return nil
    end
    if not res then
        res = rawget(getfenv(), "Library") or getgenv().Library or getgenv().uiloader
    end
    return res
end

local Library = safeLoad("https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/uiloader.luau")
if not Library or type(Library.new) ~= "function" then
    Library = safeLoad("https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/finsidhed.luau")
end
if not Library or type(Library.new) ~= "function" then
    Library = rawget(getfenv(), "Library") or getgenv().Library
end
if not Library or type(Library.new) ~= "function" then
    warn("[Loader] Library nil - check uiloader.luau raw 200 and contains Library V6")
    return
end
getgenv().Library = Library
getgenv().uiloader = Library

local BASE = "https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/games/"
local games = {
    [830072163] = "greedy-growers.lua",
    [33910482] = "anime-astral.lua",
}

local file = games[game.CreatorId]
if file then
    local ok, err = pcall(function()
        local content = game:HttpGet(BASE .. file)
        local fn, lerr = loadstring(content)
        if not fn then error(lerr) end
        fn()
    end)
    if not ok then warn("[Loader] Game load failed: "..tostring(err)) end
else
    warn("[Loader] Kein Game fuer CreatorId "..tostring(game.CreatorId))
end
