local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Blox Fruits | Aimbot & Silent Aim",
    SubTitle = "Fluent UI Interface",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- Variables for Aimbot
getgenv().AimbotConfig = {
    Enabled = false,
    SilentAim = false,
    TeamCheck = true,
    WallCheck = false,
    FOV = 150,
    Smoothness = 5,
    TargetPart = "HumanoidRootPart"
}

-- UI Elements
Tabs.Main:AddToggle("AimbotToggle", {
    Title = "Enable Camera Aimbot",
    Default = false,
    Callback = function(Value)
        getgenv().AimbotConfig.Enabled = Value
    end
})

Tabs.Main:AddToggle("SilentAimToggle", {
    Title = "Enable Silent Aim",
    Default = false,
    Callback = function(Value)
        getgenv().AimbotConfig.SilentAim = Value
    end
})

Tabs.Main:AddDropdown("TargetPartDropdown", {
    Title = "Target Hitbox",
    Values = {"HumanoidRootPart", "Head"},
    Default = 1,
    Callback = function(Value)
        getgenv().AimbotConfig.TargetPart = Value
    end
})

Tabs.Main:AddSlider("FOV是什麼", {
    Title = "FOV Radius",
    Description = "Changes the field of view circle size",
    Default = 150,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        getgenv().AimbotConfig.FOV = Value
    end
})

Tabs.Main:AddSlider("SmoothnessSlider", {
    Title = "Aim Smoothness",
    Default = 5,
    Min = 1,
    Max = 20,
    Rounding = 1,
    Callback = function(Value)
        getgenv().AimbotConfig.Smoothness = Value
    end
})

Tabs.Main:AddToggle("TeamCheckToggle", {
    Title = "Team Check",
    Default = true,
    Callback = function(Value)
        getgenv().AimbotConfig.TeamCheck = Value
    end
})

-- Core Aimbot Logic Loop
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function GetClosestPlayer()
    local target = nil
    local shortestDist = getgenv().AimbotConfig.FOV

    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            if getgenv().AimbotConfig.TeamCheck and v.Team == LocalPlayer.Team then
                continue
            end
            
            local character = v.Character
            if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
                if character.Humanoid.Health > 0 then
                    local part = character:FindFirstChild(getgenv().AimbotConfig.TargetPart)
                    if part then
                        local screenPoint, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local mouseDist = (Vector2.new(mousemoverel and workspace.CurrentCamera.ViewportSize.X/2 or Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                            if mouseDist < shortestDist then
                                shortestDist = mouseDist
                                target = character
                            end
                        end
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if not getgenv().AimbotConfig.Enabled then return end
    
    local targetChar = GetClosestPlayer()
    if targetChar and targetChar:FindFirstChild(getgenv().AimbotConfig.TargetPart) then
        local targetPart = targetChar[getgenv().AimbotConfig.TargetPart]
        local currentCamCFrame = Camera.CFrame
        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
        
        Camera.CFrame = currentCamCFrame:Lerp(targetCFrame, 1 / getgenv().AimbotConfig.Smoothness)
    end
end)

Fluent:Notify({
    Title = "Blox Fruits Script Loaded",
    Content = "Fluent UI Aimbot initialized successfully!",
    Duration = 5
})
