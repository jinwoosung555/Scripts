                        -- Redz Style Hub Blox Fruits | Full Optimized Production Edition
-- Keyless / Comprehensive Executor Support (Delta, Codex, Solara, Fluxus)

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Clean up existing UI instances to prevent duplication stack leaks
if CoreGui:FindFirstChild("RedzProductionHub") then
    CoreGui.RedzProductionHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RedzProductionHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Anti-AFK Service Integration
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
end)

-- Main Draggable Window Framework
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 420)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Top Navigation Bar Header
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 350, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Redz Hub | Blox Fruits (Production Build)"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Tab Selection Menu Bar
local TabBar = Instance.new("ScrollingFrame")
TabBar.Size = UDim2.new(1, -20, 0, 35)
TabBar.Position = UDim2.new(0, 10, 0, 52)
TabBar.BackgroundTransparency = 1
TabBar.CanvasSize = UDim2.new(0, 400, 0, 0)
TabBar.ScrollBarThickness = 0
TabBar.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.Parent = TabBar

-- Dynamic Container Area for Features
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Size = UDim2.new(1, -20, 1, -100)
ContentArea.Position = UDim2.new(0, 10, 0, 95)
ContentArea.BackgroundTransparency = 1
ContentArea.CanvasSize = UDim2.new(0, 0, 2.5, 0)
ContentArea.ScrollBarThickness = 4
ContentArea.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ContentArea

-- Helper Function to Build Toggles
local function AddToggle(name, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, -10, 0, 38)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    ToggleBtn.Text = "  [Off] " .. name
    ToggleBtn.TextColor3 = Color3.fromRGB(170, 170, 170)
    ToggleBtn.TextSize = 13
    ToggleBtn.Font = Enum.Font.GothamMedium
    ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
    ToggleBtn.Parent = ContentArea

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = ToggleBtn

    local active = false
    ToggleBtn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 90)
            ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleBtn.Text = "  [On] " .. name
        else
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
            ToggleBtn.TextColor3 = Color3.fromRGB(170, 170, 170)
            ToggleBtn.Text = "  [Off] " .. name
        end
        pcall(callback, active)
    end)
end

-- Helper Function to Build Action Buttons
local function AddButton(name, callback)
    local ActionBtn = Instance.new("TextButton")
    ActionBtn.Size = UDim2.new(1, -10, 0, 38)
    ActionBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 44)
    ActionBtn.Text = "  " .. name
    ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActionBtn.TextSize = 13
    ActionBtn.Font = Enum.Font.GothamMedium
    ActionBtn.TextXAlignment = Enum.TextXAlignment.Left
    ActionBtn.Parent = ContentArea

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = ActionBtn

    ActionBtn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
end

-- Feature Implementations:

-- 1. Auto Farm Level Loop with Safety Validation
AddToggle("Auto Farm Level", function(state)
    getgenv().AutoFarm = state
    task.spawn(function()
        while getgenv().AutoFarm do
            task.wait(0.25)
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    -- Safely routes standard combat remote triggers
                    for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
                        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                            if (enemy.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude < 300 then
                                char.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0)
                                break
                            end
                        end
                    end
                end
            end)
        end
    end)
end)

-- 2. Fast Attack Hook Injection
AddToggle("Fast Attack (M1 Multiplier)", function(state)
    getgenv().FastAttack = state
    task.spawn(function()
        pcall(function()
            local CombatFramework = require(LocalPlayer.PlayerScripts:WaitForChild("CombatFramework"))
            local CombatFrameworkR = getupvalues(CombatFramework)[2]
            while getgenv().FastAttack do
                task.wait()
                if CombatFrameworkR and CombatFrameworkR.activeController then
                    CombatFrameworkR.activeController.timeToNextAttack = 0
                    CombatFrameworkR.activeController.hitboxMagnitude = 75
                    CombatFrameworkR.activeController:attack()
                end
            end
        end)
    end)
end)

-- 3. Automated Stat Allocation Builder
AddToggle("Auto Stats (Melee / Defense / Fruit)", function(state)
    getgenv().AutoStats = state
    task.spawn(function()
        while getgenv().AutoStats do
            task.wait(1.5)
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", "Melee", 3)
                ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", "Defense", 3)
                ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", "Demon Fruit", 3)
            end)
        end
    end)
end)

-- 4. Dynamic Devil Fruit Finder and Teleport
AddToggle("Devil Fruit Notifier & Auto Teleport", function(state)
    getgenv().FruitFinder = state
    task.spawn(function()
        while getgenv().FruitFinder do
            task.wait(2)
            pcall(function()
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if obj.Name:find("Fruit") and obj:FindFirstChild("Handle") then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = obj.Handle.CFrame
                        end
                    end
                end
            end)
        end
    end)
end)

-- 5. Auto Raid Framework Loop
AddToggle("Auto Raid (Dungeons & Fragments)", function(state)
    getgenv().AutoRaid = state
    task.spawn(function()
        while getgenv().AutoRaid do
            task.wait(1)
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Raids", "Select", "Flame")
            end)
        end
    end)
end)

-- 6. Sea Event Boss Tracker (Terror Shark / Sea Beasts)
AddToggle("Sea Event Tracker (Terror Shark/Beasts)", function(state)
    getgenv().SeaEvents = state
    task.spawn(function()
        while getgenv().SeaEvents do
            task.wait(3)
            pcall(function()
                for _, obj in ipairs(Workspace.Enemies:GetChildren()) do
                    if obj.Name:find("Sea Beast") or obj.Name:find("Terror Shark") then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = obj.HumanoidRootPart.CFrame + Vector3.new(0, 25, 0)
                        end
                    end
                end
            end)
        end
    end)
end)

-- 7. No-Clip Movement Bypass
AddToggle("No-Clip Explorer Mode", function(state)
    getgenv().NoClip = state
    RunService.Stepped:Connect(function()
        if getgenv().NoClip and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

-- 8. Optimized Server Hop Utility
AddButton("Server Hop (Find Alternative Server)", function()
    local ServersUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local Success, Result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(ServersUrl))
    end)
    if Success and Result and Result.data then
        for _, s in ipairs(Result.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                break
            end
        end
    end
end)

print("Redz Production Hub Loaded and Ready!")
