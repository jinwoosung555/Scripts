-- ============================================================
-- KEN HUB v3.0 - AUTO FARM, AUTO BOSS, FAST ATTACK, QUEST & STATS
-- ============================================================
print("[Ken Hub] Initializing script v3.0...")
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Global Configuration & States
_G.ChooseWP = _G.ChooseWP or "Melee"
_G.SelectWeapon = _G.SelectWeapon or nil
_G.Stop = false
_G.FastAttack = os.time()
_G.AutoQuestEnabled = false
_G.AutoStatsEnabled = false

Config = Config or {
    Team = "Pirates",
    AntiStuck = true,
    SmartTarget = true,
    AutoBuso = true,
    SkipBadQuests = true,
    StuckThreshold = 12,
    StatPriority = {"Melee", "Defense", "Sword"} -- Order of stat upgrading
}

-- Ensure Team / Character Loaded
repeat
    task.wait()
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", Config.Team)
    end)
until LocalPlayer.Character

print("[Ken Hub] Character loaded successfully. Setting up systems...")

-- ============================================================
-- 1. WEAPON SELECTOR LOOP
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local bp = LocalPlayer:FindFirstChild("Backpack")
            local char = LocalPlayer.Character
            if not bp and not char then return end
            
            local function searchTool(folder)
                if not folder then return end
                for _, v in pairs(folder:GetChildren()) do
                    if v:IsA("Tool") and v.ToolTip == _G.ChooseWP then
                        _G.SelectWeapon = v.Name
                        return true
                    end
                end
                return false
            end

            if not searchTool(char) then
                searchTool(bp)
            end
        end)
    end
end)

-- ============================================================
-- 2. FAST ATTACK V4 (ULTRA SPEED & NO ANIMATION)
-- ============================================================
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")

local _flashyCache = {}
local _flashyCacheTime = 0
local _flashyRange = 80

local function GetAllBladeHits()
    local now = tick()
    if now - _flashyCacheTime < 0.03 then return _flashyCache end
    _flashyCacheTime = now
    
    local bladehits = {}
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return bladehits end
    
    if Workspace:FindFirstChild("Enemies") then
        for _, x in pairs(Workspace.Enemies:GetChildren()) do
            if x:FindFirstChild('Humanoid') and x:FindFirstChild('HumanoidRootPart') and x.Humanoid.Health > 0 then
                if (x.HumanoidRootPart.Position - hrp.Position).Magnitude <= _flashyRange then
                    table.insert(bladehits, x)
                end
            end
        end
    end
    _flashyCache = bladehits
    return bladehits
end

local FastAttackHandler = {}
function FastAttackHandler:Attack()
    local hits = {}
    for _, entity in pairs(GetAllBladeHits()) do
        table.insert(hits, entity)
    end
    if #hits == 0 then return end
    
    local packet = {[1] = nil, [2] = {}, [4] = "078da5141"}
    for _, target in pairs(hits) do
        RegisterAttack:FireServer(0)
        if not packet[1] then packet[1] = target.Head end
        table.insert(packet[2], {[1] = target, [2] = target.HumanoidRootPart})
        table.insert(packet[2], target)
    end
    RegisterHit:FireServer(unpack(packet))
end

task.spawn(function()
    RunService.Heartbeat:Connect(function()
        if _G.FastAttack ~= os.time() then return end
        pcall(function() FastAttackHandler:Attack() end)
    end)
end)

-- ============================================================
-- 3. UTILITY & TWEEN FUNCTIONS
-- ============================================================
local function CaculateDistance(targetPos, currentPos)
    currentPos = currentPos or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.CFrame) or CFrame.new()
    local targetVector = typeof(targetPos) == "CFrame" and targetPos.Position or targetPos
    local currentVector = typeof(currentPos) == "CFrame" and currentPos.Position or currentPos
    return (targetVector - currentVector).Magnitude
end

local TweenController = {}
function TweenController.Create(targetCFrame)
    if not targetCFrame then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local dest = typeof(targetCFrame) == "CFrame" and targetCFrame or CFrame.new(targetCFrame)
    local dist = CaculateDistance(dest)
    
    if dist <= 20 then
        hrp.CFrame = dest
        return
    end

    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end

    local duration = dist / 250
    local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = dest})
    tween:Play()
end

-- ============================================================
-- 4. AUTO STATS SYSTEM
-- ============================================================
task.spawn(function()
    while task.wait(2) do
        if _G.AutoStatsEnabled then
            pcall(function()
                for _, stat in ipairs(Config.StatPriority) do
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", stat, 1)
                end
            end)
        end
    end
end)

-- ============================================================
-- 5. AUTO QUEST SYSTEM (LEVEL-BASED DISPATCHER)
-- ============================================================
local QuestConfig = {
    [1] = {Level = 0, Mob = "Bandit", QuestName = "BanditQuest1", NPCName = "MarineQuestNPC", Position = CFrame.new(1059, 16, 1549)},
    [2] = {Level = 10, Mob = "Monkey", QuestName = "JungleQuest", NPCName = "JungleQuestNPC", Position = CFrame.new(-1598, 36, 153)},
    [3] = {Level = 30, Mob = "Gorilla", QuestName = "JungleQuest", NPCName = "JungleQuestNPC", Position = CFrame.new(-1598, 36, 153)},
    [4] = {Level = 60, Mob = "Pirate", QuestName = "PirateQuest", NPCName = "PirateQuestNPC", Position = CFrame.new(-1139, 4, 3824)},
    [5] = {Level = 90, Mob = "Brute", QuestName = "DesertQuest", NPCName = "DesertQuestNPC", Position = CFrame.new(896, 6, 4390)},
    -- Expandable list for higher seas & levels
}

local function GetCurrentQuestData()
    local level = LocalPlayer.Data.Level.Value
    local bestQuest = QuestConfig[1]
    for _, q in pairs(QuestConfig) do
        if level >= q.Level then
            bestQuest = q
        end
    end
    return bestQuest
end

task.spawn(function()
    while task.wait(1) do
        if _G.AutoQuestEnabled and not _G.Stop then
            pcall(function()
                local questActive = LocalPlayer.PlayerGui.Main.Quest.Visible
                if not questActive then
                    -- Abandon existing broken quests if any
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest")
                    
                    local currentQuest = GetCurrentQuestData()
                    if currentQuest then
                        -- Tween to questgiver NPC
                        TweenController.Create(currentQuest.Position)
                        if CaculateDistance(currentQuest.Position) < 15 then
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", currentQuest.QuestName, 1)
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- 6. COMBAT & AUTO FARM LEVEL SYSTEM
-- ============================================================
local CombatController = {}

function CombatController.SearchEnemy(mobName)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local bestTarget = nil
    local shortestDist = math.huge
    
    if Workspace:FindFirstChild("Enemies") then
        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
            if (enemy.Name == mobName or mobName == "All") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                if enemy.Humanoid.Health > 0 then
                    local dist = (enemy.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        bestTarget = enemy
                    end
                end
            end
        end
    end
    return bestTarget
end

function CombatController.StartFarmLoop()
    while task.wait() do
        if _G.Stop then break end
        
        -- Auto Buso
        if Config.AutoBuso and not LocalPlayer.Character:FindFirstChild("HasBuso") then
            pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso") end)
        end

        local questData = GetCurrentQuestData()
        local targetMob = questData and questData.Mob or "Bandit"
        
        -- If quest active, make sure we farm quest target
        local target = CombatController.SearchEnemy(targetMob)
        
        if target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid") then
            local p = target.HumanoidRootPart
            local hum = target.Humanoid
            
            if hum.Health > 0 then
                local angle = tick() * 5
                local offset = Vector3.new(math.cos(angle) * 15, 25, math.sin(angle) * 15)
                TweenController.Create(p.CFrame + offset)
                
                if _G.SelectWeapon and LocalPlayer.Backpack:FindFirstChild(_G.SelectWeapon) then
                    pcall(function() LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack[_G.SelectWeapon]) end)
                end
                
                _G.FastAttack = os.time()
            end
        else
            -- If no enemies nearby, move to quest spawn area
            if questData then
                TweenController.Create(questData.Position)
            end
        end
    end
end

-- ============================================================
-- 7. KEN HUB MOBILE UI INTERFACE V3
-- ============================================================
pcall(function()
    local old = CoreGui:FindFirstChild("KenHubUI")
    if old then old:Destroy() end
end)

local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "KenHubUI"
gui.ResetOnSpawn = false

local panel = Instance.new("Frame", gui)
panel.Size = UDim2.new(0, 320, 0, 420)
panel.Position = UDim2.new(0.5, -160, 0.4, -210)
panel.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
panel.BorderSizePixel = 0
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(0, 150, 255)
stroke.Thickness = 1.5

local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "KEN HUB v3.0 | Blox Fruit"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(0, 255, 150)

local statusLbl = Instance.new("TextLabel", panel)
statusLbl.Size = UDim2.new(1, -20, 0, 25)
statusLbl.Position = UDim2.new(0, 10, 0, 45)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Status: Ready"
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize, statusLbl.TextColor3 = 12, Color3.fromRGB(200, 200, 200)
statusLbl.TextXAlignment = Enum.TextXAlignment.Left

local scroll = Instance.new("ScrollingFrame", panel)
scroll.Size = UDim2.new(1, -20, 1, -85)
scroll.Position = UDim2.new(0, 10, 0, 75)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local list = Instance.new("UIListLayout", scroll)
list.Padding = UDim.new(0, 6)

local function createButton(name, callback)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -4, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(28, 32, 45)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.Activated:Connect(callback)
    return btn
end

-- UI Controls & Toggles
createButton("Toggle Auto Quest: [ OFF ]", function(btn)
    _G.AutoQuestEnabled = not _G.AutoQuestEnabled
    btn.Text = "Toggle Auto Quest: [ " .. (_G.AutoQuestEnabled and "ON" or "OFF") .. " ]"
end)

createButton("Toggle Auto Stats: [ OFF ]", function(btn)
    _G.AutoStatsEnabled = not _G.AutoStatsEnabled
    btn.Text = "Toggle Auto Stats: [ " .. (_G.AutoStatsEnabled and "ON" or "OFF") .. " ]"
end)

createButton("Start Auto Farm + Quest Level", function()
    _G.Stop = false
    statusLbl.Text = "Status: Auto Farming Level & Quests..."
    task.spawn(function()
        CombatController.StartFarmLoop()
    end)
end)

createButton("Stop All Operations", function()
    _G.Stop = true
    _G.AutoQuestEnabled = false
    statusLbl.Text = "Status: Stopped."
end)

createButton("Toggle Weapon Mode", function()
    local modes = {"Melee", "Sword", "Blox Fruit"}
    local currentIdx = table.find(modes, _G.ChooseWP) or 1
    _G.ChooseWP = modes[(currentIdx % #modes) + 1]
    statusLbl.Text = "Weapon Mode: " .. _G.ChooseWP
end)

print("[Ken Hub] v3.0 Script Fully Loaded with Auto Stats & Auto Quest!")
