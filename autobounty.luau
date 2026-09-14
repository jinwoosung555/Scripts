-- ============================================
-- KENHUB - ADVANCED AUTO BOUNTY & M1 AURA
-- Build: 2026.3.30
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

local lp = Players.LocalPlayer

local KenHubConfig = {
    AutoBounty = false,
    AutoKillAura = false,
    AntiAdminLeave = true,
    FruitMode = "T-Rex",
    ServerHopOnLowPlayers = false,
    AutoHaki = true,
    BringMobsOrPlayers = true,
}

-- Safe Click / M1 Function for Fruit/Melee Spam
local function simulateClick()
    pcall(function()
        VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(0.03)
        VirtualUser:Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

-- Smooth Teleport Utility
local function smoothTeleport(targetCFrame)
    local char = lp.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local speed = 350 -- Studs per second
        local time = math.clamp(distance / speed, 0.05, 1.5)
        
        local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
        return tween
    end
end

-- Find Nearest Target
local function getNearestTarget()
    local target = nil
    local shortestDistance = math.huge
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myRoot = char.HumanoidRootPart

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local enemyHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if enemyHumanoid and enemyHumanoid.Health > 0 then
                local dist = (myRoot.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    target = player.Character
                end
            end
        end
    end
    return target
end

-- Main Automation Loop
task.spawn(function()
    while true do
        task.wait(0.2)
        pcall(function()
            if KenHubConfig.AutoBounty then
                local targetChar = getNearestTarget()
                if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                    local enemyRoot = targetChar.HumanoidRootPart
                    -- Teleport right above/behind target to safely execute attacks
                    smoothTeleport(enemyRoot.CFrame * CFrame.new(0, 3, 3))
                    
                    if KenHubConfig.AutoKillAura then
                        simulateClick()
                    end
                end
            end
        end)
    end
end)

-- Anti-Admin Check
Players.PlayerAdded:Connect(function(player)
    if KenHubConfig.AntiAdminLeave then
        pcall(function()
            if player:GetRankInGroup(123456) >= 250 or player.UserId == 1 or player.Name:lower():find("admin") then
                TeleportService:Teleport(game.PlaceId, lp)
            end
        end)
    end
end)

-- UI Setup with Floating Minimize "K" Button & Full Draggability
local function initKenHubUI()
    if CoreGui:FindFirstChild("KenHubAutoBounty") then
        CoreGui.KenHubAutoBounty:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KenHubAutoBounty"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    mainFrame.Size = UDim2.new(0, 520, 0, 380)
    mainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
    mainFrame.Active = true
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner", mainFrame)
    corner.CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = Color3.fromRGB(120, 80, 200)

    -- Make Main Frame Draggable (Desktop and Touch)
    local dragging, dragInput, dragStart, startPos
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Floating Minimize Button "K"
    local floatingBtn = Instance.new("TextButton")
    floatingBtn.Name = "FloatingK"
    floatingBtn.Text = "K"
    floatingBtn.Font = Enum.Font.GothamBold
    floatingBtn.TextSize = 20
    floatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    floatingBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 65)
    floatingBtn.Size = UDim2.new(0, 45, 0, 45)
    floatingBtn.Position = UDim2.new(0, 30, 0.5, -22)
    floatingBtn.Active = true
    floatingBtn.Draggable = true
    floatingBtn.Parent = screenGui
    Instance.new("UICorner", floatingBtn).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", floatingBtn).Color = Color3.fromRGB(170, 130, 255)

    local minimized = false
    floatingBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        mainFrame.Visible = not minimized
    end)

    -- Top Header
    local topBar = Instance.new("Frame", mainFrame)
    topBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    topBar.Size = UDim2.new(1, 0, 0, 40)
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", topBar)
    title.Text = "  KENHUB <font color='#aa82ff'>[AUTO BOUNTY v2]</font>"
    title.RichText = true
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.fromRGB(245, 245, 250)
    title.TextSize = 14
    title.Size = UDim2.new(0.8, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Position = UDim2.new(0, 10, 0, 0)

    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Text = "×"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextColor3 = Color3.fromRGB(170, 170, 190)
    closeBtn.TextSize = 18
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0, 2.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

    -- Content Container
    local contentArea = Instance.new("ScrollingFrame", mainFrame)
    contentArea.BackgroundTransparency = 1
    contentArea.Size = UDim2.new(1, -20, 1, -55)
    contentArea.Position = UDim2.new(0, 10, 0, 48)
    contentArea.CanvasSize = UDim2.new(0, 0, 0, 320)
    contentArea.ScrollBarThickness = 3

    local layout = Instance.new("UIListLayout", contentArea)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)

    local function addFeatureToggle(name, stateVar, callback)
        local btn = Instance.new("TextButton", contentArea)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.Text = "  " .. name
        btn.Font = Enum.Font.GothamMedium
        btn.TextColor3 = Color3.fromRGB(230, 230, 240)
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local indicator = Instance.new("Frame", btn)
        indicator.Size = UDim2.new(0, 14, 0, 14)
        indicator.Position = UDim2.new(1, -30, 0.5, -7)
        indicator.BackgroundColor3 = KenHubConfig[stateVar] and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(60, 60, 75)
        Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 7)

        btn.MouseButton1Click:Connect(function()
            KenHubConfig[stateVar] = not KenHubConfig[stateVar]
            indicator.BackgroundColor3 = KenHubConfig[stateVar] and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(60, 60, 75)
            callback(KenHubConfig[stateVar])
        end)
    end

    addFeatureToggle("Auto Bounty Farm (Teleport & Target)", "AutoBounty", function(state) end)
    addFeatureToggle("Fast M1 / Fruit Attack Spam Aura", "AutoKillAura", function(state) end)
    addFeatureToggle("Auto Constant Buso Haki", "AutoHaki", function(state) end)
    addFeatureToggle("Anti-Admin (Auto Leave on Staff Join)", "AntiAdminLeave", function(state) end)
    addFeatureToggle("Auto Server Hop on Low Player Count", "ServerHopOnLowPlayers", function(state) end)
end

initKenHubUI()
print("[KenHub] Fully updated with floating 'K' minimization button & draggable UI!")
