if not game:IsLoaded() then game.Loaded:Wait() end

local BASE = "https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/games/"

local games = {
    [830072163] = "greedy-growers.lua",
    [33910482]  = "anime-astral.lua",
    -- add more here: [CreatorId] = "file.lua",
}

if identifyexecutor then
    local execName = tostring(identifyexecutor()):lower()
    local UNSUPPORTED = { "Solara", "Xeno" }
    for _, name in ipairs(UNSUPPORTED) do
        if execName:find(name:lower(), 1, true) then
            local ok, Library = pcall(function()
                return loadstring(game:HttpGet("https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/uiloader.luau"))()
            end)
            if ok and Library then
                -- fallback screen if you have ObsidianUltra, otherwise simple warn
                warn("[Loader] Unsupported executor: "..execName)
            end
            return
        end
    end
end

-- Preload uiloader so games can use `Library` global
pcall(function()
    local ok, res = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/uiloader.luau"))()
    end)
    if ok and res then
        getgenv().Library = res
        getgenv().uiloader = res
    end
end)

local file = games[game.CreatorId]
if file then
    task.wait(math.random())
    -- optional donation
    pcall(function() loadstring(game:HttpGet(BASE .. "donation.lua"))() end)
    loadstring(game:HttpGet(BASE .. file))()
else
    warn("[Loader] Kein Game fuer CreatorId " .. tostring(game.CreatorId))
end
