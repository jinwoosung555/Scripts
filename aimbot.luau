local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Create Window with WindUI Key System integration
local Window = WindUI:CreateWindow({
    Title = "Ken Hub | Combat & ESP",
    Icon = "crosshair",
    Theme = "Dark",
    Author = "Universal",
    Folder = "KenHubConfigs",
    KeySystem = true,
    KeySettings = {
        Title = "Key System Required",
        Subtitle = "Link verification system",
        Note = "Click 'Get Key' to open the portal, complete verification, and paste your key.",
        SaveInRoot = true,
        SaveKey = true,
        Key = { "https://jinwoosung555.github.io/Keyy/" }, -- Reference / Verification website link
        Actions = {
            CopyKey = {
                Text = "Get Key",
                Callback = function()
                    if setclipboard then
                        setclipboard("https://jinwoosung555.github.io/Keyy/")
                        WindUI:Notify({
                            Title = "Link Copied",
                            Content = "Key link copied to clipboard! Paste it in your browser.",
                            Duration = 5
                        })
                    else
                        WindUI:Notify({
                            Title = "Error",
                            Content = "Your executor does not support setclipboard.",
                            Duration = 5
                        })
                    end
                end
            }
        }
    }
})

-- Create Tabs
local CombatTab = Window:Tab({
    Title = "Combat",
    Icon = "target"
})

local VisualsTab = Window:Tab({
    Title = "Visuals",
    Icon = "eye"
})

-- Services & Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Configuration States
local AimbotPlayerEnabled = false
local AimbotNPCEnabled = false
local AimTargetPart = "Head"
local FOVRadius = 100
local ShowFOV = false
local ESPEnabled = false

-- FOV Circle Drawing Object
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 60
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(168, 85, 247)
FOVCircle.Visible = false

-- Combat Tab UI Elements
CombatTab:Toggle({
    Title = "Player Aimbot",
    Description = "Locks onto real players inside FOV radius",
    Default = false,
    Callback = function(state)
        AimbotPlayerEnabled = state
    end
})

CombatTab:Toggle({
    Title = "NPC Aimbot",
    Description = "Locks onto NPCs / Dummies only",
    Default = false,
    Callback = function(state)
        AimbotNPCEnabled = state
    end
})

CombatTab:Dropdown({
    Title = "Target Hitbox",
    Description = "Select target tracking part",
    Values = {"Head", "HumanoidRootPart"},
    Default = "Head",
    Callback = function(selected)
        AimTargetPart = selected
    end
})

-- Visuals Tab UI Elements
VisualsTab:Toggle({
    Title = "Show FOV Circle",
    Description = "Displays tracking field of view circle",
    Default = false,
    Callback = function(state)
        ShowFOV = state
        FOVCircle.Visible = state
    end
})

VisualsTab:Slider({
    Title = "FOV Radius Size",
    Description = "Adjust target detection range",
    Min = 20,
    Max = 400,
    Default = 100,
    Callback = function(value)
        FOVRadius = value
        FOVCircle.Radius = value
    end
})

VisualsTab:Toggle({
    Title = "Player & NPC ESP (Highlights)",
    Description = "Outlines targets in the workspace",
    Default = false,
    Callback = function(state)
        ESPEnabled = state
    end
})

-- Helper Function to check if a model is strictly an NPC
local function isNPC(model)
    if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") then
        local player = Players:GetPlayerFromCharacter(model)
        return player == nil -- Returns true if not bound to any player
    end
    return false
end

-- Target finding logic separating Players and NPCs
local function getClosestTarget()
    local closestTarget = nil
    local shortestDistance = FOVRadius
    local centerScreen = Camera.ViewportSize / 2

    -- 1. Scan Players
    if AimbotPlayerEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local targetPart = player.Character:FindFirstChild(AimTargetPart)
                if targetPart then
                    local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - centerScreen).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestTarget = targetPart
                        end
                    end
                end
            end
        end
    end

    -- 2. Scan NPCs (NPCs only)
    if AimbotNPCEnabled then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if isNPC(obj) then
                local humanoid = obj:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local targetPart = obj:FindFirstChild(AimTargetPart)
                    if targetPart then
                        local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - centerScreen).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                closestTarget = targetPart
                            end
                        end
                    end
                end
            end
        end
    end

    return closestTarget
end

-- Render loop for Aimbot and FOV updates
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Camera.ViewportSize / 2
    FOVCircle.Visible = ShowFOV

    if AimbotPlayerEnabled or AimbotNPCEnabled then
        local target = getClosestTarget()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

-- Background loop to manage ESP Highlights securely
task.spawn(function()
    while true do
        task.wait(1)
        if ESPEnabled then
            -- Handle Players ESP
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and not player.Character:FindFirstChild("WindUI_ESP") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "WindUI_ESP"
                    highlight.Adornee = player.Character
                    highlight.FillColor = Color3.fromRGB(0, 150, 255)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Parent = player.Character
                end
            end
            -- Handle NPCs ESP
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if isNPC(obj) and not obj:FindFirstChild("WindUI_ESP") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "WindUI_ESP"
                    highlight.Adornee = obj
                    highlight.FillColor = Color3.fromRGB(255, 50, 50)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Parent = obj
                end
            end
        else
            -- Clean up highlights when ESP is toggled off
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("WindUI_ESP") then
                    player.Character.WindUI_ESP:Destroy()
                end
            end
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if isNPC(obj) and obj:FindFirstChild("WindUI_ESP") then
                    obj.WindUI_ESP:Destroy()
                end
            end
        end
    end
end)

