-- ============================================================
-- KEN HUB v4.0 - BLOX FRUIT AIMBOT, SILENT AIM & FAST ATTACK
-- ============================================================
print("[Ken Hub] Initializing v4.0 Aimbot & Silent Aim systems...")
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- Global Configuration & States
_G.AimbotEnabled = false
_G.SilentAimEnabled = false
_G.AimPrediction = true
_G.AimPart = "HumanoidRootPart" -- "HumanoidRootPart" or "Head"
_G.FOVRadius = 150
_G.FastAttack = os.time()

Config = Config or {
    AutoBuso = true,
    Team = "Pirates",
}

-- Ensure Team / Character Loaded
repeat
    task.wait()
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", Config.Team)
    end)
until LocalPlayer.Character

print("[Ken Hub] Character loaded. Setting up target acquisition...")

-- ============================================================
-- 1. FOV CIRCLE VISUALIZATION
-- ============================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Filled = false
FOVCircle.Radius = _G.FOVRadius
FOVCircle.Color = Color3.fromRGB(0, 255, 150)
FOVCircle.Transparency = 0.7
FOVCircle.Thickness = 1.5
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.AimbotEnabled or _G.SilentAimEnabled
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = _G.FOVRadius
end)

-- ============================================================
-- 2. FAST ATTACK V4 (PRESERVED FROM TEMPLATE)
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
-- 3. ADVANCED TARGET FINDER (NEAREST TO MOUSE/CENTER)
-- ============================================================
local function GetBestTarget()
    local closestTarget = nil
    local shortestDist = _G.FOVRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Check Enemies (NPC/Bosses)
    if Workspace:FindFirstChild("Enemies") then
        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
            local part = enemy:FindFirstChild(_G.AimPart) or enemy:FindFirstChild("HumanoidRootPart")
            local hum = enemy:FindFirstChild("Humanoid")
            if part and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local magnitude = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if magnitude < shortestDist then
                        shortestDist = magnitude
                        closestTarget = part
                    end
                end
            end
        end
    end

    -- Check Players (PVP Mode)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local part = player.Character:FindFirstChild(_G.AimPart) or player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChild("Humanoid")
            if part and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local magnitude = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if magnitude < shortestDist then
                        shortestDist = magnitude
                        closestTarget = part
                    end
                end
            end
        end
    end

    return closestTarget
end

-- ============================================================
-- 4. AIMBOT & SILENT AIM CORE HOOKS
-- ============================================================
-- Camera Aimbot Loop
RunService.RenderStepped:Connect(function()
    if _G.AimbotEnabled then
        local targetPart = GetBestTarget()
        if targetPart then
            local targetPos = targetPart.Position
            if _G.AimPrediction and targetPart.Parent:FindFirstChild("HumanoidRootPart") then
                -- Add simple velocity vector prediction for moving players/mobs
                local vel = targetPart.Parent.HumanoidRootPart.AssemblyLinearVelocity
                targetPos = targetPos + (vel * 0.08)
            end
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        end
    end
end)

-- Silent Aim Hook (Redirects Skill/Bullet Raycasts or Target Arguments)
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, index)
    if not checkcaller() and _G.SilentAimEnabled and index == "Hit" then
        local targetPart = GetBestTarget()
        if targetPart then
            return targetPart.CFrame
        end
    end
    return oldIndex(self, index)
end)

-- ============================================================
-- 5. KEN HUB MOBILE UI INTERFACE v4
-- ============================================================
pcall(function()
    local old = CoreGui:FindFirstChild("KenHubUI")
    if old then old:Destroy() end
end)

local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "KenHubUI"
gui.ResetOnSpawn = false

local panel = Instance.new("Frame", gui)
panel.Size = UDim2.new(0, 320, 0, 440)
panel.Position = UDim2.new(0.5, -160, 0.4, -220)
panel.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
panel.BorderSizePixel = 0
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(0, 150, 255)
stroke.Thickness = 1.5

local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "KEN HUB v4.0 | Aimbot & Fast Attack"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(0, 255, 150)

local statusLbl = Instance.new("TextLabel", panel)
statusLbl.Size = UDim2.new(1, -20, 0, 25)
statusLbl.Position = UDim2.new(0, 10, 0, 40)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Status: Ready"
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize, statusLbl.TextColor3 = 12, Color3.fromRGB(200, 200, 200)
statusLbl.TextXAlignment = Enum.TextXAlignment.Left

local scroll = Instance.new("ScrollingFrame", panel)
scroll.Size = UDim2.new(1, -20, 1, -75)
scroll.Position = UDim2.new(0, 10, 0, 70)
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

-- UI Interactive Controls
createButton("Toggle Aimbot: [ OFF ]", function(btn)
    _G.AimbotEnabled = not _G.AimbotEnabled
    btn.Text = "Toggle Aimbot: [ " .. (_G.AimbotEnabled and "ON" or "OFF") .. " ]"
    statusLbl.Text = "Aimbot: " .. (_G.AimbotEnabled and "Active" or "Disabled")
end)

createButton("Toggle Silent Aim: [ OFF ]", function(btn)
    _G.SilentAimEnabled = not _G.SilentAimEnabled
    btn.Text = "Toggle Silent Aim: [ " .. (_G.SilentAimEnabled and "ON" or "OFF") .. " ]"
    statusLbl.Text = "Silent Aim: " .. (_G.SilentAimEnabled and "Active" or "Disabled")
end)

createButton("Toggle Aim Part (Root / Head)", function()
    if _G.AimPart == "HumanoidRootPart" then
        _G.AimPart = "Head"
    else
        _G.AimPart = "HumanoidRootPart"
    end
    statusLbl.Text = "Target Lock Part: " .. _G.AimPart
end)

createButton("Toggle FOV Size (150 / 300 / 500)", function()
    if _G.FOVRadius == 150 then
        _G.FOVRadius = 300
    elseif _G.FOVRadius == 300 then
        _G.FOVRadius = 500
    else
        _G.FOVRadius = 150
    end
    statusLbl.Text = "FOV Radius set to: " .. _G.FOVRadius
end)

createButton("Trigger Fast Attack Loop", function()
    _G.FastAttack = os.time()
    statusLbl.Text = "Fast Attack Loop Re-triggered!"
end)

print("[Ken Hub] v4.0 Aimbot & Silent Aim fully initialized!")
