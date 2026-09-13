-- Blox Fruits Advanced Utility Script Template
-- Execute using a trusted executor (Delta, Fluxus, Solara, etc.)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Configuration Table
getgenv().Config = {
    Aimbot = {
        Enabled = true,
        Key = Enum.UserInputType.MouseButton2, -- Right Click to lock
        Smoothness = 5,
        AimPart = "HumanoidRootPart"
    },
    FOV = {
        Visible = true,
        Radius = 150,
        Color = Color3.fromRGB(255, 255, 255)
    },
    ESP = {
        Players = true,
        Fruits = true,
        Chests = true
    },
    FastAttack = {
        Enabled = true,
        Multiplier = 3.5
    }
}

-- FOV Circle Setup
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Config.FOV.Visible
    FOVCircle.Radius = Config.FOV.Radius
    FOVCircle.Color = Config.FOV.Color
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

-- Find Closest Target within FOV
local function GetClosestTarget()
    local target = nil
    local shortestDist = Config.FOV.Radius

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local part = player.Character:FindFirstChild(Config.Aimbot.AimPart)
            if part then
                local screenPoint, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mouseDist = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                    if mouseDist < shortestDist then
                        shortestDist = mouseDist
                        target = part
                    end
                end
            end
        end
    end
    return target
end

-- Aimbot Loop
RunService.RenderStepped:Connect(function()
    if Config.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Config.Aimbot.Key) then
        local targetPart = GetClosestTarget()
        if targetPart then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
        end
    end
end)

-- Fast Attack (M1 Modifier)
task.spawn(function()
    pcall(function()
        local CombatFramework = require(LocalPlayer.PlayerScripts.CombatFramework)
        local CombatFrameworkR = getupvalues(CombatFramework)[2]
        
        RunService.Stepped:Connect(function()
            if Config.FastAttack.Enabled and CombatFrameworkR then
                pcall(function()
                    local activeController = CombatFrameworkR.activeController
                    if activeController and activeController.grabbed then
                        activeController.timeToNextAttack = 0
                        activeController.increment = 3
                        activeController.hitboxMagnitude = 60
                        activeController:attack()
                    end
                end)
            end
        end)
    end)
end)

-- ESP Utility Functions
local function CreateESP(obj, color, textString)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "CustomESP"
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.AlwaysOnTop = true
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextSize = 14
    textLabel.Text = textString
    textLabel.Parent = billboard
    
    if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
        billboard.Parent = obj.HumanoidRootPart
    elseif obj:IsA("BasePart") then
        billboard.Parent = obj
    end
end

-- Dynamic World ESP Scanner
Task.spawn(function()
    while task.wait(2) do
        if Config.ESP.Fruits then
            for _, v in ipairs(Workspace:GetChildren()) do
                if v.Name:פשר("Fruit") and not v:FindFirstChild("CustomESP") then
                    CreateESP(v, Color3.fromRGB(255, 50, 50), v.Name)
                end
            end
        end
    end
end)

print("Blox Fruits Utility Script Loaded Successfully!")
