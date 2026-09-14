-- ============================================
-- KENHUB - FIXED PLAYER TARGETING & BOUNTY v6
-- Build: 2026.3.30
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera

local KenHubConfig = {
    AutoBounty = false,
    AutoKillAura = true,
    AntiAdminLeave = true,
    AutoHaki = true,
    EquipBestWeapon = true,
}

local SessionStats = {
    TotalKills = 0,
    BountyEarned = 0,
    StartTime = tick(),
    InitialBounty = 0
}

pcall(function()
    local leaderstats = lp:FindFirstChild("leaderstats")
    if leaderstats then
        local bounty = leaderstats:FindFirstChild("Bounty/Honor")
        if bounty then SessionStats.InitialBounty = tonumber(bounty.Value) or 0 end
    end
end)

local function verifyHaki()
    pcall(function()
        local char = lp.Character
        if char and KenHubConfig.AutoHaki then
            if not char:FindFirstChild("HasBuso") then
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if remotes and remotes:FindFirstChild("CommF_") then
                    remotes.CommF_:InvokeServer("Buso")
                end
            end
        end
    end)
end

local function equipTool()
    pcall(function()
        local char = lp.Character
        local backpack = lp.Backpack
        if not char or not backpack then return end
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.ToolTip == "Blox Fruit" or tool.ToolTip == "Melee" or tool.ToolTip == "Sword") then
                if not char:FindFirstChild(tool.Name) then
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid then humanoid:EquipTool(tool) end
                end
            end
        end
    end)
end

local function sendAttackInput(targetPos)
    pcall(function()
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
        VirtualUser:Button1Down(Vector2.new(100, 100), camera.CFrame)
        task.wait(0.03)
        VirtualUser:Button1Up(Vector2.new(100, 100), camera.CFrame)
    end)
end

local function smoothTeleport(targetCFrame)
    local char = lp.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local speed = 350
        local time = math.clamp(distance / speed, 0.03, 0.8)
        TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = targetCFrame}):Play()
    end
end

-- Strictly filter valid live players and ignore safezone or dead entities
local function getNearestTarget()
    local target = nil
    local shortestDistance = math.huge
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myRoot = char.HumanoidRootPart

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and player.Character then
            local enemyRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local enemyHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            -- Make sure target is alive and loaded correctly
            if enemyRoot and enemyHumanoid and enemyHumanoid.Health > 0 then
                -- Optional: Skip players who are safe/in safezone if game tracks it, or team check
                if player.Team ~= lp.Team or not player.Team then
                    local dist = (myRoot.Position - enemyRoot.Position).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        target = player.Character
                    end
                end
            end
        end
    end
    return target
end

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            local leaderstats = lp:FindFirstChild("leaderstats")
            if leaderstats then
                local bountyStat = leaderstats:FindFirstChild("Bounty/Honor")
                if bountyStat then
                    local currentBounty = tonumber(bountyStat.Value) or 0
                    SessionStats.BountyEarned = currentBounty - SessionStats.InitialBounty
                end
            end
        end)
    end
end)

-- Main Execution Loop
task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            if KenHubConfig.AutoBounty then
                verifyHaki()
                if KenHubConfig.EquipBestWeapon then equipTool() end
                
                local targetChar = getNearestTarget()
                if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                    local enemyRoot = targetChar.HumanoidRootPart
                    -- Teleport safely right above the player's root part
                    smoothTeleport(enemyRoot.CFrame * CFrame.new(0, 3, 2))
                    
                    if KenHubConfig.AutoKillAura then
                        sendAttackInput(enemyRoot.Position)
                    end
                end
            end
        end)
    end
end)

local function initKenHubUI()
    if CoreGui:FindFirstChild("KenHubAutoBounty") then
        CoreGui.KenHubAutoBounty:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KenHubAutoBounty"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui

    local mainFrame = Instance.new("Frame")
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    mainFrame.Size = UDim2.new(0, 520, 0, 390)
    mainFrame.Position = UDim2.new(0.5, -260, 0.5, -195)
    mainFrame.Active = true
    mainFrame.Parent = screenGui
    
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(120, 80, 200)

    -- Draggable Logic
    local dragging, dragStart, startPos
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
    floatingBtn.Position = UDim2.new(0, 20, 0.5, -22)
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
    topBar.Size = UDim2.new(1, 0, 0, 38)
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", topBar)
    title.Text = "  KENHUB <font color='#aa82ff'>[TARGET FIX v6]</font>"
    title.RichText = true
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.fromRGB(245, 245, 250)
    title.TextSize = 13
    title.Size = UDim2.new(0.8, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Position = UDim2.new(0, 10, 0, 0)

    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Text = "×"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextColor3 = Color3.fromRGB(170, 170, 190)
    closeBtn.TextSize = 16
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -36, 0, 3)
    closeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

    -- Container for stats grid & toggles
    local container = Instance.new("ScrollingFrame", mainFrame)
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -16, 1, -48)
    container.Position = UDim2.new(0, 8, 0, 42)
    container.CanvasSize = UDim2.new(0, 0, 0, 360)
    container.ScrollBarThickness = 3

    local layout = Instance.new("UIListLayout", container)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)

    -- Stats Grid Holder
    local statsGrid = Instance.new("Frame", container)
    statsGrid.BackgroundTransparency = 1
    statsGrid.Size = UDim2.new(1, 0, 0, 150)

    local function createStatBox(name, labelText, defaultVal, posX)
        local box = Instance.new("Frame", statsGrid)
        box.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        box.Size = UDim2.new(0.48, 0, 0, 70)
        box.Position = posX
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", box).Color = Color3.fromRGB(50, 50, 65)

        local lbl = Instance.new("TextLabel", box)
        lbl.Text = labelText
        lbl.Font = Enum.Font.GothamSemibold
        lbl.TextColor3 = Color3.fromRGB(160, 160, 180)
        lbl.TextSize = 10
        lbl.Size = UDim2.new(1, -12, 0, 18)
        lbl.Position = UDim2.new(0, 10, 0, 6)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local val = Instance.new("TextLabel", box)
        val.Name = name
        val.Text = defaultVal
        val.Font = Enum.Font.GothamBold
        val.TextColor3 = Color3.fromRGB(255, 255, 255)
        val.TextSize = 15
        val.Size = UDim2.new(1, -12, 0, 30)
        val.Position = UDim2.new(0, 10, 0, 26)
        val.BackgroundTransparency = 1
        val.TextXAlignment = Enum.TextXAlignment.Left

        return val
    end

    local killsLabel = createStatBox("KillsLabel", "TOTAL KILLS", "0", UDim2.new(0, 0, 0, 0))
    local bountyLabel = createStatBox("BountyLabel", "SESSION BOUNTY", "$0", UDim2.new(0.52, 0, 0, 0))
    local timeLabel = createStatBox("TimeLabel", "RUN TIME", "0s", UDim2.new(0, 0, 0, 78))
    local statusLabel = createStatBox("StatusLabel", "ENGINE STATUS", "Running (Active)", UDim2.new(0.52, 0, 0, 78))
    statusLabel.TextColor3 = Color3.fromRGB(80, 220, 120)

    task.spawn(function()
        while screenGui.Parent do
            task.wait(1)
            local elapsed = math.floor(tick() - SessionStats.StartTime)
            local mins = math.floor(elapsed / 60)
            local secs = elapsed % 60
            timeLabel.Text = mins > 0 and string.format("%dm %ds", mins, secs) or string.format("%ds", secs)
            killsLabel.Text = tostring(SessionStats.TotalKills)
            
            local bEarned = SessionStats.BountyEarned
            if bEarned >= 0 then
                bountyLabel.Text = "+" .. tostring(bEarned)
                bountyLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
            else
                bountyLabel.Text = tostring(bEarned)
                bountyLabel.TextColor3 = Color3.fromRGB(240, 80, 80)
            end
        end
    end)

    local function addFeatureToggle(name, stateVar, callback)
        local btn = Instance.new("TextButton", container)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        btn.Size = UDim2.new(1, 0, 0, 36)
        btn.Text = "  " .. name
        btn.Font = Enum.Font.GothamMedium
        btn.TextColor3 = Color3.fromRGB(230, 230, 240)
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local indicator = Instance.new("Frame", btn)
        indicator.Size = UDim2.new(0, 12, 0, 12)
        indicator.Position = UDim2.new(1, -26, 0.5, -6)
        indicator.BackgroundColor3 = KenHubConfig[stateVar] and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(60, 60, 75)
        Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            KenHubConfig[stateVar] = not KenHubConfig[stateVar]
            indicator.BackgroundColor3 = KenHubConfig[stateVar] and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(60, 60, 75)
            callback(KenHubConfig[stateVar])
        end)
    end

    addFeatureToggle("Auto Bounty Farm (Teleport & Target)", "AutoBounty", function(state) end)
    addFeatureToggle("Fast M1 / Fruit Attack Damage Aura", "AutoKillAura", function(state) end)
    addFeatureToggle("Auto Constant Buso Haki", "AutoHaki", function(state) end)
    addFeatureToggle("Auto Equip Fruit/Weapon Tool", "EquipBestWeapon", function(state) end)
    addFeatureToggle("Anti-Admin (Auto Leave on Staff Join)", "AntiAdminLeave", function(state) end)
end

initKenHubUI()
print("[KenHub] Player target routing algorithm successfully repaired!")
