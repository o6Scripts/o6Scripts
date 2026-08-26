--!nocheck
--[[
    Greedy Growers - Farm Script with Library UI
    Requires Library loaded before this script
]]

-- Library - obfuscated uiloader from GitHub (raw) - fallback finsidhed
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/uiloader.luau"))()
if not Library or type(Library.new) ~= "function" then
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/o6Scripts/o6Scripts/main/finsidhed.luau"))()
end

-- Panda Auth - PUSL-V4
local PUSL = loadstring(game:HttpGet("https://secure.pandauth.com/pv4/lib"))()
if PUSL and type(PUSL.configure) == "function" then
    PUSL.configure({ serviceId = "o6scripts" })
end

-- Discord
task.spawn(function()
    pcall(setclipboard, "https://discord.gg/Gzae8gAfja")
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Discord",
            Text = "discord.gg/Gzae8gAfja (copied)",
            Duration = 3,
        })
    end)
end)

-- ============================================================
-- Library UI
-- ============================================================
local Window = Library.new({
    Name = "Greedy Growers",
    Keybind = "Insert",
})

local TabFarm = Window:DrawTab({ Name = "Farm", Icon = "lucide-home" })
local TabFarmLeft = TabFarm:DrawSection({ Name = "Auto Farm", Position = "left" })
local TabFarmRight = TabFarm:DrawSection({ Name = "Settings", Position = "right" })

local TabPlayer = Window:DrawTab({ Name = "Player", Icon = "lucide-user" })
local TabPlayerLeft = TabPlayer:DrawSection({ Name = "Movement", Position = "left" })
local TabPlayerRight = TabPlayer:DrawSection({ Name = "Misc", Position = "right" })

local TabBuy = Window:DrawTab({ Name = "Shop", Icon = "lucide-package" })
local TabBuyLeft = TabBuy:DrawSection({ Name = "Buy", Position = "left" })
local TabBuyRight = TabBuy:DrawSection({ Name = "Eggs & Gear", Position = "right" })

local TabMisc = Window:DrawTab({ Name = "Misc", Icon = "lucide-settings" })
local TabMiscLeft = TabMisc:DrawSection({ Name = "Info", Position = "left" })

-- ============================================================
-- State
-- ============================================================
local getgenv = getgenv or getfenv
getgenv().GGXW = getgenv().GGXW or {}
local GGX = getgenv().GGXW

local CFG = {
    AutoBuySeeds = false,
    AutoHarvest = false,
    AutoGrowAll = false,
    AutoSellAll = false,
    AutoRebirth = false,
    AutoPlantSeed = false,
    AutoCollectDeadTree = false,
    Noclip = false,
    Fly = false,
    BuyDelay = 0.4,
    HarvestDelay = 0.5,
    GrowDelay = 0.6,
    SellDelay = 0.6,
    RebirthDelay = 3,
    PlantDelay = 1,
    CollectDeadDelay = 2,
    WalkSpeed = 16,
    SelectedEgg = "Basic",
    SelectedSeed = "Apple",
    SelectedGear = "Scythe",
    SelectedFertilizer = "None",
}

-- ============================================================
-- Farm Remotes
-- ============================================================
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")

local function waitPath(root, ...)
    local obj = root
    for _, name in ipairs({...}) do
        obj = obj and obj:WaitForChild(name, 10)
        if not obj then return nil end
    end
    return obj
end

local Services = waitPath(RS, "Packages", "_Index", "sleitnick_knit@1.6.0", "knit", "Services")

local function getRF(serviceName, remoteName)
    local svc = Services and Services:FindFirstChild(serviceName)
    local folder = svc and svc:FindFirstChild("RF")
    return folder and folder:FindFirstChild(remoteName)
end

local function getRE(serviceName, remoteName)
    local svc = Services and Services:FindFirstChild(serviceName)
    local folder = svc and svc:FindFirstChild("RE")
    return folder and folder:FindFirstChild(remoteName)
end

local Remotes = {
    RequestPurchase = getRF("SeedConveyorService", "RequestPurchase"),
    SeedSpawned = getRE("SeedConveyorService", "SeedSpawned"),
    CollectAllFruits = getRF("PlayerPlotService", "CollectAllFruits"),
    GrowAllFruits = getRF("PlayerPlotService", "GrowAllFruits"),
    GetMyPlot = getRF("PlayerPlotService", "GetMyPlot"),
    SellAll = getRF("SellStandService", "SellAll"),
    SellTree = getRF("SellStandService", "SellTree"),
    SellFruit = getRF("SellFruitsService", "SellFruit"),
    BuySeed = getRF("SeedStandService", "BuySeed"),
    DoRebirth = getRF("RebirthService", "DoRebirth"),
    BuyEgg = getRF("PetsService", "BuyEgg"),
    ToggleSprint = getRF("SprintService", "ToggleSprint"),
    CollectDeadTree = getRF("PlantRoundService", "CollectDeadTree"),
    LeaveRound = getRF("PlantRoundService", "LeaveRound"),
    ClaimIndexReward = getRE("IndexService", "ClaimIndexReward"),
    BuyGear = getRF("GearShopService", "BuyGear"),
    BuyFurniture = getRF("FurnitureShopService", "BuyFurniture"),
    BuyCanOfWorms = getRF("WormShopService", "BuyCanOfWorms"),
    SpinWheel = getRE("SpinWheelService", "clientSpinWheelRequest"),
    StartRound = getRF("PlantRoundService", "StartRound"),
}

local BigField = WS:FindFirstChild("BigField")
local ConveyorSeeds = BigField and BigField:FindFirstChild("ConveyorSeeds")

local SeedNames = {
    "Apple", "Astral", "Avocado", "Banana", "Blooming", "Cherry",
    "Coconut", "Diamond", "DragonFruit", "Elder", "Fig", "Glowing",
    "Glowshroom", "Inferno", "Lemon", "Magic", "Mango", "Money",
    "Mushroom", "Oak", "Orange", "Peach", "Pine", "Pizza",
    "Prismatic", "Spirit", "Starfruit", "Void",
}

local EggNames = {"Basic", "Rare", "Epic", "Legendary", "Mythic", "Void"}
local GearNames = {"Scythe", "Axe", "Pickaxe", "Hoe"}
local FertilizerNames = {"None", "Basic", "Premium", "Magic"}

local lastBuyAttempt = {}

-- ============================================================
-- Helpers
-- ============================================================
local function normalizeChoice(value, values)
    local text = tostring(value or "")
    for _, name in ipairs(values) do
        if string.lower(name) == string.lower(text) then return name end
    end
    return values[1]
end

local function invoke(remote, ...)
    if not remote then return false, "missing remote" end
    local ok, a, b = pcall(function(...) return remote:InvokeServer(...) end, ...)
    if not ok then return false, a end
    if a == false then return false, b or "server rejected" end
    return true, a, b
end

local function buySpawnId(spawnId)
    if not spawnId then return false end
    local now = os.clock()
    if lastBuyAttempt[spawnId] and now - lastBuyAttempt[spawnId] <= 0.3 then return false end
    lastBuyAttempt[spawnId] = now
    task.spawn(function() invoke(Remotes.RequestPurchase, spawnId) end)
    return true
end

local function buyConveyorSeeds()
    if not ConveyorSeeds then return 0 end
    local count = 0
    for _, obj in ipairs(ConveyorSeeds:GetChildren()) do
        if obj.Name == "SeedHolder" then
            local spawnId = obj:GetAttribute("SpawnId")
            if spawnId and buySpawnId(spawnId) then count += 1 end
        end
    end
    return count
end

local function harvestAll() return invoke(Remotes.CollectAllFruits) end
local function growAll() return invoke(Remotes.GrowAllFruits) end
local function sellAll() return invoke(Remotes.SellAll) end
local function rebirth() return invoke(Remotes.DoRebirth) end

local function collectDead()
    local ok, msg = invoke(Remotes.CollectDeadTree)
    if ok then
        task.delay(0.5, function()
            local char = game.Players.LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local pos = hrp.Position
            local closest, closestDist = nil, 30
            for _, obj in ipairs(WS:GetDescendants()) do
                if obj.Name:find("PlotTree_") and obj:IsA("Model") then
                    local hasLeaves = false
                    for _, d in ipairs(obj:GetDescendants()) do
                        if d.Name == "Leaves" then hasLeaves = true; break end
                    end
                    if not hasLeaves then
                        local cf = obj:GetPivot()
                        if cf then
                            local dist = (cf.Position - pos).Magnitude
                            if dist < closestDist then
                                closest = obj
                                closestDist = dist
                            end
                        end
                    end
                end
            end
            if closest then closest:Destroy() end
        end)
    end
    return ok, msg
end

local lastNotify = 0
local function notify(title, content)
    local now = os.clock()
    if now - lastNotify < 0.8 then return end
    lastNotify = now
    pcall(function()
        Window.Notify.new({ Title = title, Content = content, Duration = 3 })
    end)
    warn("[GG] " .. title .. ": " .. content)
end

-- ============================================================
-- Farm Loops
-- ============================================================
local runId = (getgenv().GGXW._runId or 0) + 1
getgenv().GGXW._runId = runId

local function isAlive() return getgenv().GGXW._runId == runId end

-- Auto Buy Seeds
task.spawn(function()
    while isAlive() do
        if CFG.AutoBuySeeds then
            local n = buyConveyorSeeds()
            if n > 0 then notify("Conveyor", "Bought " .. n .. " seed(s)") end
            task.wait(CFG.BuyDelay)
        else
            task.wait(0.5)
        end
    end
end)

-- Auto Plant Seed
task.spawn(function()
    while isAlive() do
        if CFG.AutoPlantSeed then
            local lp = game.Players.LocalPlayer
            local char = lp.Character
            local backpack = lp:FindFirstChild("Backpack")

            local hasCorrectTool = false
            if char then
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") and tool:GetAttribute("IsSeed") then
                        local seedType = tool:GetAttribute("SeedType") or tool.Name
                        if string.lower(seedType) == string.lower(CFG.SelectedSeed) then
                            hasCorrectTool = true
                        end
                    end
                end
            end

            if not hasCorrectTool and backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool:GetAttribute("IsSeed") then
                        local seedType = tool:GetAttribute("SeedType") or tool.Name
                        if string.lower(seedType) == string.lower(CFG.SelectedSeed) then
                            char:EquipTool(tool)
                            task.wait(0.3)
                            hasCorrectTool = true
                            break
                        end
                    end
                end
            end

            if not hasCorrectTool then
                invoke(Remotes.BuySeed, CFG.SelectedSeed)
                task.wait(1)
                if backpack then
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") and tool:GetAttribute("IsSeed") then
                            local seedType = tool:GetAttribute("SeedType") or tool.Name
                            if string.lower(seedType) == string.lower(CFG.SelectedSeed) then
                                char:EquipTool(tool)
                                task.wait(0.3)
                                hasCorrectTool = true
                                break
                            end
                        end
                    end
                end
            end

            if hasCorrectTool then
                local remote = Remotes.StartRound
                if remote then
                    local fert = CFG.SelectedFertilizer or "None"
                    pcall(function() remote:InvokeServer(CFG.SelectedSeed, fert) end)
                end
            end
            task.wait(CFG.PlantDelay)
        else
            task.wait(0.5)
        end
    end
end)

-- Auto Harvest
task.spawn(function()
    while isAlive() do
        if CFG.AutoHarvest then
            local ok, msg = harvestAll()
            if not ok then notify("Harvest", tostring(msg)) end
            task.wait(CFG.HarvestDelay)
        else
            task.wait(0.5)
        end
    end
end)

-- Auto Grow
task.spawn(function()
    while isAlive() do
        if CFG.AutoGrowAll then
            local ok, msg = growAll()
            if not ok then notify("Grow", tostring(msg)) end
            task.wait(CFG.GrowDelay)
        else
            task.wait(0.5)
        end
    end
end)

-- Auto Sell
task.spawn(function()
    while isAlive() do
        if CFG.AutoSellAll then
            local ok, msg = sellAll()
            if not ok then notify("Sell", tostring(msg)) end
            task.wait(CFG.SellDelay)
        else
            task.wait(0.5)
        end
    end
end)

-- Auto Collect Dead Tree
task.spawn(function()
    while isAlive() do
        if CFG.AutoCollectDeadTree then
            local hasRound = false
            pcall(function()
                local prs = Services:FindFirstChild("PlantRoundService")
                local rf = prs and prs:FindFirstChild("RF")
                local getRounds = rf and rf:FindFirstChild("GetActiveRounds")
                if getRounds then
                    local ok, rounds = pcall(function() return getRounds:InvokeServer() end)
                    if ok and type(rounds) == "table" and #rounds > 0 then
                        hasRound = true
                    end
                end
            end)
            if hasRound then collectDead() end
            task.wait(CFG.CollectDeadDelay)
        else
            task.wait(0.5)
        end
    end
end)

-- Auto Rebirth
task.spawn(function()
    while isAlive() do
        if CFG.AutoRebirth then
            local ok, msg = rebirth()
            if not ok and tostring(msg):lower():find("missing") == nil then
                notify("Rebirth", tostring(msg))
            end
            task.wait(CFG.RebirthDelay)
        else
            task.wait(1)
        end
    end
end)

-- SeedSpawned listener
if Remotes.SeedSpawned then
    task.spawn(function()
        while isAlive() do
            local ok = pcall(function()
                Remotes.SeedSpawned.OnClientEvent:Connect(function(seedData)
                    if not isAlive() or not CFG.AutoBuySeeds then return end
                    local spawnId = nil
                    if typeof(seedData) == "table" then
                        spawnId = seedData.spawnId or seedData.SpawnId or seedData.id or seedData.Id
                    else
                        spawnId = seedData
                    end
                    buySpawnId(spawnId)
                end)
            end)
            if ok then break else task.wait(2) end
        end
    end)
end

-- Noclip
task.spawn(function()
    while isAlive() do
        local lp = game.Players.LocalPlayer
        local char = lp.Character
        if char and CFG.Noclip then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        task.wait(0.1)
    end
end)

-- Fly
task.spawn(function()
    local lp = game.Players.LocalPlayer
    local uis = game:GetService("UserInputService")
    local camera = WS.CurrentCamera
    local flySpeed = 50
    local flying = false
    local bodyVel = nil

    local function stopFly()
        flying = false
        if bodyVel then pcall(function() bodyVel:Destroy() end); bodyVel = nil end
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end

    while isAlive() do
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if CFG.Fly and hrp and hum then
            if not flying then
                flying = true
                hum.PlatformStand = true
                bodyVel = Instance.new("BodyVelocity")
                bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bodyVel.Velocity = Vector3.zero
                bodyVel.Parent = hrp
            end
            local dir = Vector3.zero
            if uis:IsKeyDown(Enum.KeyCode.W) then dir += camera.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S) then dir -= camera.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.A) then dir -= camera.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.D) then dir += camera.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
            if uis:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
            if dir.Magnitude > 0 then dir = dir.Unit * flySpeed end
            bodyVel.Velocity = dir
        elseif flying then
            stopFly()
        end
        task.wait()
    end
    if flying then stopFly() end
end)

-- ============================================================
-- UI - Farm Tab
-- ============================================================
TabFarmLeft:AddToggle({
    Name = "Auto Buy Seeds",
    Default = CFG.AutoBuySeeds,
    Callback = function(v) CFG.AutoBuySeeds = v end,
})

TabFarmLeft:AddToggle({
    Name = "Auto Harvest",
    Default = CFG.AutoHarvest,
    Callback = function(v) CFG.AutoHarvest = v end,
})

TabFarmLeft:AddToggle({
    Name = "Auto Grow All",
    Default = CFG.AutoGrowAll,
    Callback = function(v) CFG.AutoGrowAll = v end,
})

TabFarmLeft:AddToggle({
    Name = "Auto Sell All",
    Default = CFG.AutoSellAll,
    Callback = function(v) CFG.AutoSellAll = v end,
})

TabFarmLeft:AddToggle({
    Name = "Auto Rebirth",
    Default = CFG.AutoRebirth,
    Callback = function(v) CFG.AutoRebirth = v end,
})

TabFarmLeft:AddToggle({
    Name = "Auto Plant Seed",
    Default = CFG.AutoPlantSeed,
    Callback = function(v) CFG.AutoPlantSeed = v end,
})

TabFarmLeft:AddToggle({
    Name = "Auto Collect Dead Tree",
    Default = CFG.AutoCollectDeadTree,
    Callback = function(v) CFG.AutoCollectDeadTree = v end,
})

TabFarmRight:AddDropdown({
    Name = "Seed",
    Default = CFG.SelectedSeed,
    Values = SeedNames,
    Callback = function(v) CFG.SelectedSeed = normalizeChoice(v, SeedNames) end,
})

TabFarmRight:AddDropdown({
    Name = "Fertilizer",
    Default = CFG.SelectedFertilizer,
    Values = FertilizerNames,
    Callback = function(v) CFG.SelectedFertilizer = normalizeChoice(v, FertilizerNames) end,
})

TabFarmRight:AddSlider({
    Name = "Buy Delay",
    Default = CFG.BuyDelay,
    Min = 0.1,
    Max = 2,
    Round = 1,
    Callback = function(v) CFG.BuyDelay = v end,
})

TabFarmRight:AddSlider({
    Name = "Harvest Delay",
    Default = CFG.HarvestDelay,
    Min = 0.1,
    Max = 2,
    Round = 1,
    Callback = function(v) CFG.HarvestDelay = v end,
})

TabFarmRight:AddSlider({
    Name = "Grow Delay",
    Default = CFG.GrowDelay,
    Min = 0.1,
    Max = 2,
    Round = 1,
    Callback = function(v) CFG.GrowDelay = v end,
})

TabFarmRight:AddSlider({
    Name = "Sell Delay",
    Default = CFG.SellDelay,
    Min = 0.1,
    Max = 2,
    Round = 1,
    Callback = function(v) CFG.SellDelay = v end,
})

TabFarmRight:AddSlider({
    Name = "Rebirth Delay",
    Default = CFG.RebirthDelay,
    Min = 1,
    Max = 10,
    Round = 0,
    Callback = function(v) CFG.RebirthDelay = v end,
})

TabFarmRight:AddSlider({
    Name = "Plant Delay",
    Default = CFG.PlantDelay,
    Min = 0.5,
    Max = 5,
    Round = 1,
    Callback = function(v) CFG.PlantDelay = v end,
})

TabFarmRight:AddSlider({
    Name = "Collect Dead Delay",
    Default = CFG.CollectDeadDelay,
    Min = 0.5,
    Max = 5,
    Round = 1,
    Callback = function(v) CFG.CollectDeadDelay = v end,
})

-- ============================================================
-- UI - Player Tab
-- ============================================================
TabPlayerLeft:AddToggle({
    Name = "Noclip",
    Default = CFG.Noclip,
    Callback = function(v) CFG.Noclip = v end,
})

TabPlayerLeft:AddToggle({
    Name = "Fly",
    Default = CFG.Fly,
    Callback = function(v) CFG.Fly = v end,
})

TabPlayerRight:AddButton({
    Name = "Sprint",
    Callback = function()
        invoke(Remotes.ToggleSprint)
    end,
})

-- ============================================================
-- UI - Shop Tab
-- ============================================================
TabBuyLeft:AddButton({
    Name = "Sell All",
    Callback = function()
        local ok, msg = sellAll()
        notify("Sell", ok and "Sold!" or tostring(msg))
    end,
})

TabBuyLeft:AddButton({
    Name = "Collect All Fruits",
    Callback = function()
        local ok, msg = harvestAll()
        notify("Harvest", ok and "Harvested!" or tostring(msg))
    end,
})

TabBuyLeft:AddButton({
    Name = "Claim Index Reward",
    Callback = function()
        invoke(Remotes.ClaimIndexReward)
    end,
})

TabBuyRight:AddDropdown({
    Name = "Egg",
    Default = CFG.SelectedEgg,
    Values = EggNames,
    Callback = function(v) CFG.SelectedEgg = normalizeChoice(v, EggNames) end,
})

TabBuyRight:AddButton({
    Name = "Buy Egg",
    Callback = function()
        local ok, msg = invoke(Remotes.BuyEgg, CFG.SelectedEgg)
        notify("Egg", ok and "Bought " .. CFG.SelectedEgg or tostring(msg))
    end,
})

TabBuyRight:AddDropdown({
    Name = "Gear",
    Default = CFG.SelectedGear,
    Values = GearNames,
    Callback = function(v) CFG.SelectedGear = normalizeChoice(v, GearNames) end,
})

TabBuyRight:AddButton({
    Name = "Buy Gear",
    Callback = function()
        local ok, msg = invoke(Remotes.BuyGear, CFG.SelectedGear)
        notify("Gear", ok and "Bought " .. CFG.SelectedGear or tostring(msg))
    end,
})

-- ============================================================
-- UI - Misc Tab
-- ============================================================
TabMiscLeft:AddParagraph({
    Title = "Greedy Growers",
    Content = "by o6Scripts | discord.gg/Gzae8gAfja",
})

TabMiscLeft:AddButton({
    Name = "Copy Discord Link",
    Callback = function()
        pcall(setclipboard, "https://discord.gg/Gzae8gAfja")
        notify("Discord", "Link copied!")
    end,
})

print("[GG] Loaded!")
