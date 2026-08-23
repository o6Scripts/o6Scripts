--!nocheck
--[[
    Greedy Growers - Headless Farm Script
    No UI, no Compkiller, no KeySystem GUI
    Toggle via getgenv().GGXW before executing
]]

-- Panda Auth - PUSL-V4
local PUSL = loadstring(game:HttpGet("https://secure.pandauth.com/pv4/lib"))()
if PUSL and type(PUSL.configure) == "function" then
    PUSL.configure({ serviceId = "o6scripts" })
end

local getgenv = getgenv or getfenv

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

-- State
getgenv().GGXW = getgenv().GGXW or {}
local GGX = getgenv().GGXW

GGX.AutoBuySeeds = GGX.AutoBuySeeds == true
GGX.AutoHarvest = GGX.AutoHarvest == true
GGX.AutoGrowAll = GGX.AutoGrowAll == true
GGX.AutoSellAll = GGX.AutoSellAll == true
GGX.AutoRebirth = GGX.AutoRebirth == true
GGX.AutoPlantSeed = GGX.AutoPlantSeed == true
GGX.AutoCollectDeadTree = GGX.AutoCollectDeadTree == true
GGX.KeepMovement = GGX.KeepMovement == true
GGX.Noclip = GGX.Noclip == true
GGX.Fly = GGX.Fly == true
GGX.BuyDelay = tonumber(GGX.BuyDelay) or 0.4
GGX.HarvestDelay = tonumber(GGX.HarvestDelay) or 0.5
GGX.GrowDelay = tonumber(GGX.GrowDelay) or 0.6
GGX.SellDelay = tonumber(GGX.SellDelay) or 0.6
GGX.RebirthDelay = tonumber(GGX.RebirthDelay) or 3
GGX.PlantDelay = tonumber(GGX.PlantDelay) or 1
GGX.CollectDeadDelay = tonumber(GGX.CollectDeadDelay) or 2
GGX.WalkSpeed = tonumber(GGX.WalkSpeed) or 16
GGX.SelectedEgg = GGX.SelectedEgg or "Basic"
GGX.SelectedSeed = GGX.SelectedSeed or "Apple"
GGX.SelectedGear = GGX.SelectedGear or "Scythe"
GGX.SelectedFertilizer = GGX.SelectedFertilizer or "None"

-- ===================== Greedy Growers Farm =====================

local FarmReplicatedStorage = game:GetService("ReplicatedStorage");
local FarmWorkspace = game:GetService("Workspace");

local function farmWaitPath(root, ...)
	local obj = root;
	for _, name in ipairs({ ... }) do
		obj = obj and obj:WaitForChild(name, 10);
		if not obj then
			return nil;
		end
	end
	return obj;
end

local FarmServices = farmWaitPath(FarmReplicatedStorage, "Packages", "_Index", "sleitnick_knit@1.6.0", "knit", "Services");

local function farmRF(serviceName, remoteName)
	local service = FarmServices and FarmServices:FindFirstChild(serviceName);
	local folder = service and service:FindFirstChild("RF");
	return folder and folder:FindFirstChild(remoteName);
end

local function farmRE(serviceName, remoteName)
	local service = FarmServices and FarmServices:FindFirstChild(serviceName);
	local folder = service and service:FindFirstChild("RE");
	return folder and folder:FindFirstChild(remoteName);
end

local FarmRemotes = {
	RequestPurchase = farmRF("SeedConveyorService", "RequestPurchase"),
	SeedSpawned = farmRE("SeedConveyorService", "SeedSpawned"),
	CollectAllFruits = farmRF("PlayerPlotService", "CollectAllFruits"),
	GrowAllFruits = farmRF("PlayerPlotService", "GrowAllFruits"),
	GetMyPlot = farmRF("PlayerPlotService", "GetMyPlot"),
	SellAll = farmRF("SellStandService", "SellAll"),
	SellTree = farmRF("SellStandService", "SellTree"),
	SellFruit = farmRF("SellFruitsService", "SellFruit"),
	BuySeed = farmRF("SeedStandService", "BuySeed"),
	DoRebirth = farmRF("RebirthService", "DoRebirth"),
	BuyEgg = farmRF("PetsService", "BuyEgg"),
	ToggleSprint = farmRF("SprintService", "ToggleSprint"),
	CollectDeadTree = farmRF("PlantRoundService", "CollectDeadTree"),
	LeaveRound = farmRF("PlantRoundService", "LeaveRound"),
	ClaimIndexReward = farmRE("IndexService", "ClaimIndexReward"),
	BuyGear = farmRF("GearShopService", "BuyGear"),
	BuyFurniture = farmRF("FurnitureShopService", "BuyFurniture"),
	BuyCanOfWorms = farmRF("WormShopService", "BuyCanOfWorms"),
	SpinWheel = farmRE("SpinWheelService", "clientSpinWheelRequest"),
	SpinWheelFinished = farmRE("SpinWheelService", "spinWheelAnimFinished"),
	MarkSpinWheel = farmRF("SpinWheelService", "MarkOpened"),
	StartRound = farmRF("PlantRoundService", "StartRound"),
};

local FarmBigField = FarmWorkspace:FindFirstChild("BigField");
local FarmConveyorSeeds = FarmBigField and FarmBigField:FindFirstChild("ConveyorSeeds");

local FarmSeedNames = {
	"Apple",
	"Astral",
	"Avocado",
	"Banana",
	"Blooming",
	"Cherry",
	"Coconut",
	"Diamond",
	"DragonFruit",
	"Elder",
	"Fig",
	"Glowing",
	"Glowshroom",
	"Inferno",
	"Lemon",
	"Magic",
	"Mango",
	"Money",
	"Mushroom",
	"Oak",
	"Orange",
	"Peach",
	"Pine",
	"Pizza",
	"Prismatic",
	"Spirit",
	"Starfruit",
	"Void",
};

local farmLastBuyAttempt = {};

local function farmNormalizeChoice(value, values)
	local text = tostring(value or "");
	for _, name in ipairs(values) do
		if string.lower(name) == string.lower(text) then
			return name;
		end
	end
	return values[1];
end

local function farmInvoke(remote, ...)
	if not remote then
		return false, "missing remote";
	end
	local ok, a, b = pcall(function(...)
		return remote:InvokeServer(...);
	end, ...);
	if not ok then
		return false, a;
	end
	if a == false then
		return false, b or "server rejected";
	end
	return true, a, b;
end

local function farmBuySpawnId(spawnId)
	if not spawnId then
		return false;
	end
	local now = os.clock();
	if farmLastBuyAttempt[spawnId] and now - farmLastBuyAttempt[spawnId] <= 0.3 then
		return false;
	end
	farmLastBuyAttempt[spawnId] = now;
	task.spawn(function()
		farmInvoke(FarmRemotes.RequestPurchase, spawnId);
	end);
	return true;
end

local function farmBuyConveyorSeeds()
	if not FarmConveyorSeeds then
		return 0;
	end
	local count = 0;
	for _, obj in ipairs(FarmConveyorSeeds:GetChildren()) do
		if obj.Name == "SeedHolder" then
			local spawnId = obj:GetAttribute("SpawnId");
			if spawnId and farmBuySpawnId(spawnId) then
				count = count + 1;
			end
		end
	end
	return count;
end

local farmHarvestAll = function() return farmInvoke(FarmRemotes.CollectAllFruits) end;
local farmGrowAll = function() return farmInvoke(FarmRemotes.GrowAllFruits) end;
local farmSellAll = function() return farmInvoke(FarmRemotes.SellAll) end;
local farmSellFruit = function() return farmInvoke(FarmRemotes.SellFruit) end;
local farmSellTree = function() return farmInvoke(FarmRemotes.SellTree) end;
local farmBuyEgg = function() return farmInvoke(FarmRemotes.BuyEgg, GGX.SelectedEgg) end;
local farmPlantSeed = function()
	GGX.SelectedSeed = farmNormalizeChoice(GGX.SelectedSeed, FarmSeedNames);
	return farmInvoke(FarmRemotes.BuySeed, GGX.SelectedSeed);
end;
local farmRebirth = function() return farmInvoke(FarmRemotes.DoRebirth) end;
local farmSprint = function() return farmInvoke(FarmRemotes.ToggleSprint) end;
local farmCollectDead = function()
	local ok, msg = farmInvoke(FarmRemotes.CollectDeadTree);
	if ok then
		task.delay(0.5, function()
			local char = game.Players.LocalPlayer.Character;
			local hrp = char and char:FindFirstChild("HumanoidRootPart");
			if not hrp then return end;
			local pos = hrp.Position;
			local closest, closestDist = nil, 30;
			for _, obj in ipairs(FarmWorkspace:GetDescendants()) do
				if obj.Name:find("PlotTree_") and obj:IsA("Model") then
					local hasLeaves = false;
					for _, d in ipairs(obj:GetDescendants()) do
						if d.Name == "Leaves" then hasLeaves = true; break; end
					end
					if not hasLeaves then
						local cf = obj:GetPivot();
						if cf then
							local dist = (cf.Position - pos).Magnitude;
							if dist < closestDist then
								closest = obj;
								closestDist = dist;
							end
						end
					end
				end
			end
			if closest then
				closest:Destroy();
			end
		end);
	end
	return ok, msg;
end;
local farmLeaveRound = function() return farmInvoke(FarmRemotes.LeaveRound) end;
local farmBuyGear = function() return farmInvoke(FarmRemotes.BuyGear, GGX.SelectedGear) end;

local farmLastNotify = 0;
local function farmNotify(title, content, good)
	local now = os.clock();
	if now - farmLastNotify < 0.8 then
		return;
	end
	farmLastNotify = now;
	pcall(function()
		warn("[GG] " .. tostring(title) .. ": " .. tostring(content))
	end);
end
getgenv().GGXW._notify = farmNotify;

local farmRunId = (getgenv().GGXW._runId or 0) + 1;
getgenv().GGXW._runId = farmRunId;

local function farmMakeLoops()
	task.spawn(function()
		while getgenv().GGXW._runId == farmRunId do
			if GGX.AutoBuySeeds then
				local count = farmBuyConveyorSeeds();
				if count > 0 then farmNotify("Conveyor", "bought " .. count .. " seed(s)") end
				task.wait(GGX.BuyDelay);
			else
				task.wait(0.5);
			end
		end
	end);
	task.spawn(function()
		while getgenv().GGXW._runId == farmRunId do
			if GGX.AutoPlantSeed then
				local lp = game.Players.LocalPlayer;
				local char = lp.Character;
				local backpack = lp:FindFirstChild("Backpack");

				-- check if correct seed tool is already equipped
				local hasCorrectTool = false;
				if char then
					for _, tool in ipairs(char:GetChildren()) do
						if tool:IsA("Tool") and tool:GetAttribute("IsSeed") then
							local seedType = tool:GetAttribute("SeedType") or tool.Name;
							if string.lower(seedType) == string.lower(GGX.SelectedSeed) then
								hasCorrectTool = true;
							end
						end
					end
				end

				-- if not equipped, try to equip from backpack
				if not hasCorrectTool and backpack then
					for _, tool in ipairs(backpack:GetChildren()) do
						if tool:IsA("Tool") and tool:GetAttribute("IsSeed") then
							local seedType = tool:GetAttribute("SeedType") or tool.Name;
							if string.lower(seedType) == string.lower(GGX.SelectedSeed) then
								char:EquipTool(tool);
								task.wait(0.3);
								hasCorrectTool = true;
								break;
							end
						end
					end
				end

				-- if still no tool, buy from shop first
				if not hasCorrectTool then
					farmInvoke(FarmRemotes.BuySeed, GGX.SelectedSeed);
					task.wait(1);
					-- try to equip again after buying
					if backpack then
						for _, tool in ipairs(backpack:GetChildren()) do
							if tool:IsA("Tool") and tool:GetAttribute("IsSeed") then
								local seedType = tool:GetAttribute("SeedType") or tool.Name;
								if string.lower(seedType) == string.lower(GGX.SelectedSeed) then
									char:EquipTool(tool);
									task.wait(0.3);
									hasCorrectTool = true;
									break;
								end
							end
						end
					end
				end

				-- now plant with correct tool equipped
				if hasCorrectTool then
					local remote = FarmRemotes.StartRound;
					if remote then
						local fert = GGX.SelectedFertilizer or "None";
						pcall(function()
							remote:InvokeServer(GGX.SelectedSeed, fert);
						end);
					end
				end
				task.wait(GGX.PlantDelay);
			else
				task.wait(0.5);
			end
		end
	end);
	task.spawn(function()
		while getgenv().GGXW._runId == farmRunId do
			if GGX.AutoHarvest then
				local ok, msg = farmHarvestAll();
				if not ok then farmNotify("Harvest", tostring(msg), false) end
				task.wait(GGX.HarvestDelay);
			else
				task.wait(0.5);
			end
		end
	end);
	task.spawn(function()
		while getgenv().GGXW._runId == farmRunId do
			if GGX.AutoGrowAll then
				local ok, msg = farmGrowAll();
				if not ok then farmNotify("Grow", tostring(msg), false) end
				task.wait(GGX.GrowDelay);
			else
				task.wait(0.5);
			end
		end
	end);
	task.spawn(function()
		while getgenv().GGXW._runId == farmRunId do
			if GGX.AutoSellAll then
				local ok, msg = farmSellAll();
				if not ok then farmNotify("Sell", tostring(msg), false) end
				task.wait(GGX.SellDelay);
			else
				task.wait(0.5);
			end
		end
	end);
	task.spawn(function()
		while getgenv().GGXW._runId == farmRunId do
			if GGX.AutoCollectDeadTree then
				-- only collect if there's an active round (dead tree only exists during a round)
				local hasRound = false;
				pcall(function()
					local remote = FarmRemotes.StartRound;
					-- check via GetActiveRounds
					local prs = FarmServices:FindFirstChild("PlantRoundService");
					local rf = prs and prs:FindFirstChild("RF");
					local getRounds = rf and rf:FindFirstChild("GetActiveRounds");
					if getRounds then
						local ok, rounds = pcall(function() return getRounds:InvokeServer() end);
						if ok and type(rounds) == "table" and #rounds > 0 then
							hasRound = true;
						end
					end
				end);
				if hasRound then
					farmCollectDead();
				end
				task.wait(GGX.CollectDeadDelay);
			else
				task.wait(0.5);
			end
		end
	end);
	task.spawn(function()
		while getgenv().GGXW._runId == farmRunId do
			if GGX.AutoRebirth then
				local ok, msg = farmRebirth();
				if not ok and tostring(msg):lower():find("missing") == nil then
					farmNotify("Rebirth", tostring(msg), false);
				end
				task.wait(GGX.RebirthDelay);
			else
				task.wait(1);
			end
		end
	end);
	if FarmRemotes.SeedSpawned then
		task.spawn(function()
			while getgenv().GGXW._runId == farmRunId do
				local ok = pcall(function()
					FarmRemotes.SeedSpawned.OnClientEvent:Connect(function(seedData)
						if getgenv().GGXW._runId ~= farmRunId or not GGX.AutoBuySeeds then return end
						local spawnId = nil;
						if typeof(seedData) == "table" then
							spawnId = seedData.spawnId or seedData.SpawnId or seedData.id or seedData.Id;
						else
							spawnId = seedData;
						end
						farmBuySpawnId(spawnId);
					end);
				end);
				if ok then
					break;
				else
					task.wait(2);
				end
			end
		end);
	end

	task.spawn(function()
		while getgenv().GGXW._runId == farmRunId do
			local lp = game.Players.LocalPlayer;
			local char = lp.Character;
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid");
				if hum and GGX.Noclip then
					for _, part in ipairs(char:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = false;
						end
					end
				end
			end
			task.wait(0.1);
		end
	end);

	task.spawn(function()
		local lp = game.Players.LocalPlayer;
		local uis = game:GetService("UserInputService");
		local ws = game:GetService("Workspace");
		local camera = ws.CurrentCamera;
		local flySpeed = 50;
		local flying = false;
		local bodyVel = nil;
		local function stopFly()
			flying = false;
			if bodyVel then
				pcall(function() bodyVel:Destroy() end);
				bodyVel = nil;
			end
			local char = lp.Character;
			local hum = char and char:FindFirstChildOfClass("Humanoid");
			if hum then
				hum:ChangeState(Enum.HumanoidStateType.GettingUp);
			end
		end
		while getgenv().GGXW._runId == farmRunId do
			local char = lp.Character;
			local hrp = char and char:FindFirstChild("HumanoidRootPart");
			local hum = char and char:FindFirstChildOfClass("Humanoid");
			if GGX.Fly and hrp and hum then
				if not flying then
					flying = true;
					hum.PlatformStand = true;
					bodyVel = Instance.new("BodyVelocity");
					bodyVel.MaxForce = Vector3.new(100000, 100000, 100000);
					bodyVel.Velocity = Vector3.new(0, 0, 0);
					bodyVel.Parent = hrp;
				end
				local moveDir = Vector3.new(0, 0, 0);
				if uis:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
				if uis:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
				if uis:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
				if uis:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
				if uis:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
				if uis:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
				if moveDir.Magnitude > 0 then
					moveDir = moveDir.Unit * flySpeed;
				end
				bodyVel.Velocity = moveDir;
			elseif flying then
				stopFly();
			end
			task.wait();
		end
		if flying then
			stopFly();
		end
	end);
end

-- ===================== Start Farming =====================
farmMakeLoops()

-- How to use:
-- Before executing, set your toggles via getgenv():
--   getgenv().GGXW.AutoHarvest = true
--   getgenv().GGXW.AutoSellAll = true
--   getgenv().GGXW.AutoBuySeeds = true
--   getgenv().GGXW.AutoGrowAll = true
--   getgenv().GGXW.AutoPlantSeed = true
--   getgenv().GGXW.AutoRebirth = true
--   getgenv().GGXW.AutoCollectDeadTree = true
--   getgenv().GGXW.Noclip = true
--   getgenv().GGXW.Fly = true
--   getgenv().GGXW.WalkSpeed = 50
--   getgenv().GGXW.SelectedSeed = "Apple"
--   getgenv().GGXW.SelectedEgg = "EggLegendary"
--   getgenv().GGXW.SelectedGear = "Scythe"
--   getgenv().GGXW.SelectedFertilizer = "Magic"
--   getgenv().GGXW.HarvestDelay = 0.5
--   getgenv().GGXW.GrowDelay = 0.6
--   getgenv().GGXW.SellDelay = 0.6
--   getgenv().GGXW.BuyDelay = 0.4
--   getgenv().GGXW.PlantDelay = 1
--   getgenv().GGXW.RebirthDelay = 3
--   getgenv().GGXW.CollectDeadDelay = 2
