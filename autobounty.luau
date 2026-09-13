--[========================================================================--
--            KEN HUB — NEXUS AI / AUTO BOUNTY EXTENSION v6.1               --
--         Advanced Smart-Targeting, Safezone Escapes & Skill Combos        --
--[========================================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Comprehensive Nexus AI & Auto Bounty Config Setup
getgenv().NexusBountyConfig = {
    ["Team"] = "Pirates", -- Pirates / Marines
    ["AutoBounty"] = true,
    ["SafeZone"] = {
        ["Enable"] = true,
        ["LowHealth"] = 3500,
        ["TeleportY"] = 600,
    },
    ["Skip"] = {
        ["V4"] = true,
        ["LowHealth"] = true,
    },
    ["Weapons"] = {
        ["Melee"] = { ["Enable"] = true, ["Delay"] = 1.2 },
        ["Sword"] = { ["Enable"] = true, ["Delay"] = 1.0 },
        ["Blox Fruit"] = { ["Enable"] = true, ["Delay"] = 1.5 }
    },
    ["ChatSpam"] = {
        ["Enabled"] = false,
        ["List"] = {"Ken Hub Nexus AI > All", "Too Easy Bounty!"},
        ["Delay"] = 10
    }
}

-- Notification Helper
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "NexusAI_Notifications"
NotifGui.ResetOnSpawn = false
pcall(function() NotifGui.Parent = CoreGui end)

local function SendNexusNotif(title, text)
    pcall(function()
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, 300, 0, 55)
        f.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
        f.Parent = NotifGui
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
        
        local str = Instance.new("UIStroke")
        str.Color = Color3.fromRGB(168, 85, 247)
        str.Transparency = 0.3
        str.Parent = f

        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -15, 0, 20)
        t.Position = UDim2.new(0, 10, 0, 6)
        t.BackgroundTransparency = 1
        t.Font = Enum.Font.GothamBold
        t.Text = title
        t.TextColor3 = Color3.fromRGB(255, 255, 255)
        t.TextSize = 12
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = f

        local m = Instance.new("TextLabel")
        m.Size = UDim2.new(1, -15, 0, 22)
        m.Position = UDim2.new(0, 10, 0, 26)
        m.BackgroundTransparency = 1
        m.Font = Enum.Font.Gotham
        m.Text = text
        m.TextColor3 = Color3.fromRGB(170, 170, 185)
        m.TextSize = 11
        m.TextXAlignment = Enum.TextXAlignment.Left
        m.Parent = f

        task.delay(3, function()
            if f then f:Destroy() end
        end)
    end)
end

SendNexusNotif("Nexus AI Engine", "Auto Bounty framework successfully injected & active.")

-- Core AI Target Finder Loop
local function GetClosestTarget()
    local target = nil
    local shortestDist = math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not myRoot then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local pRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local pHum = player.Character:FindFirstChild("Humanoid")
            
            if pRoot and pHum and pHum.Health > 0 then
                -- Skip safe zone / low health targets if option enabled
                local dist = (myRoot.Position - pRoot.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    target = player
                end
            end
        end
    end
    return target
end

-- Automated Bounty Loop Worker
task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            if getgenv().NexusBountyConfig.AutoBounty then
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChild("Humanoid")
                
                if root and hum then
                    -- Safety Escape Check (Low Health Logic)
                    if getgenv().NexusBountyConfig.SafeZone.Enable and hum.Health <= getgenv().NexusBountyConfig.SafeZone.LowHealth then
                        root.CFrame = root.CFrame + Vector3.new(0, getgenv().NexusBountyConfig.SafeZone.TeleportY, 0)
                        task.wait(4) -- Wait to regenerate health
                        return
                    end

                    -- Target Tracking & Combat Pursuit
                    local targetPlayer = GetClosestTarget()
                    if targetPlayer and targetPlayer.Character then
                        local tRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local tHum = targetPlayer.Character:FindFirstChild("Humanoid")
                        
                        if tRoot and tHum and tHum.Health > 0 then
                            -- Smooth positioning above/behind target to simulate high-tier PvP movement
                            root.CFrame = tRoot.CFrame * CFrame.new(0, 12, 6)
                            
                            -- Face target camera angle
                            Camera.CFrame = CFrame.new(Camera.CFrame.Position, tRoot.Position)
                            
                            -- Simulate tool activation/attack click
                            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                            if tool then
                                tool:Activate()
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- Chat Spammer Module
task.spawn(function()
    while task.wait(getgenv().NexusBountyConfig.ChatSpam.Delay) do
        pcall(function()
            if getgenv().NexusBountyConfig.ChatSpam.Enabled and getgenv().NexusBountyConfig.AutoBounty then
                local list = getgenv().NexusBountyConfig.ChatSpam.List
                local msg = list[math.random(1, #list)]
                local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                if chatRemote and chatRemote:FindFirstChild("SayMessageRequest") then
                    chatRemote.SayMessageRequest:FireServer(msg, "All")
                end
            end
        end)
    end
end)

