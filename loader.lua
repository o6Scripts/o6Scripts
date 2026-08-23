--!nocheck

local GITHUB_URL = "https://raw.githubusercontent.com/o6Scripts/o6Scripts/main"

local ok, src = pcall(game.HttpGet, game, GITHUB_URL .. "/uiloader.lua", true)
if ok and src then
    loadstring(src)()
else
    warn("[Loader] Failed to fetch uiloader.lua")
end
--!nocheck
local GITHUB_URL = "https://raw.githubusercontent.com/o6Scripts/o6Scripts/main"

local function fetch(path)
    local ok, content = pcall(function()
        return game:HttpGet(GITHUB_URL .. "/" .. path, true)
    end)
    if ok and content and content ~= "" then
        return content
    end
    return nil
end

local uiloader = fetch("uiloader.lua")
if uiloader then
    loadstring(uiloader)()
else
    warn("[Loader] Failed to fetch uiloader.lua")
end
