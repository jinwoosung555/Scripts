-- ============================================
-- KENHUB - AUTO BOUNTY (KEYLESS EDITION)
-- Build: 2026-03-30
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")

local lp = Players.LocalPlayer

-- UI & Core Config
local KenHubConfig = {
    AutoBounty = false,
    AutoKillAura = false,
    AntiAdminLeave = true,
    FruitMode = "T-Rex",
    ServerHopOnLowPlayers = false,
    WebhookURL = ""
}

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    corner.Parent = parent
    return corner
end

local function createStroke(parent, color)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(60, 60, 75)
    stroke.Thickness = 1
    stroke.Parent = parent
    return stroke
end

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
    mainFrame.Name = "MainFrame"
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    mainFrame.Size = UDim2.new(0, 520, 0, 380)
    mainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    createCorner(mainFrame, 12)
    createStroke(mainFrame, Color3.fromRGB(70, 50, 120))

    -- Top Header
    local topBar = Instance.new("Frame")
    topBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.Parent = mainFrame
    createCorner(topBar, 12)

    local title = Instance.new("TextLabel")
    title.Text = "  KENHUB <font color='#aa82ff'>[AUTO BOUNTY]</font>"
    title.RichText = true
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.fromRGB(245, 245, 250)
    title.TextSize = 14
    title.Size = UDim2.new(0.8, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Parent = topBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "×"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextColor3 = Color3.fromRGB(170, 170, 190)
    closeBtn.TextSize = 18
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0, 2.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    closeBtn.Parent = topBar
    createCorner(closeBtn, 8)

    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Content Area / Toggles Container
    local contentArea = Instance.new("ScrollingFrame")
    contentArea.BackgroundTransparency = 1
    contentArea.Size = UDim2.new(1, -20, 1, -55)
    contentArea.Position = UDim2.new(0, 10, 0, 48)
    contentArea.CanvasSize = UDim2.new(0, 0, 0, 300)
    contentArea.ScrollBarThickness = 3
    contentArea.Parent = mainFrame

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = contentArea

    local function addFeatureToggle(name, stateVar, callback)
        local btn = Instance.new("TextButton")
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.Text = "  " .. name
        btn.Font = Enum.Font.GothamMedium
        btn.TextColor3 = Color3.fromRGB(230, 230, 240)
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        btn.Parent = contentArea
        createCorner(btn, 8)

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 14, 0, 14)
        indicator.Position = UDim2.new(1, -30, 0.5, -7)
        indicator.BackgroundColor3 = KenHubConfig[stateVar] and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(60, 60, 75)
        indicator.Parent = btn
        createCorner(indicator, 7)

        btn.MouseButton1Click:Connect(function()
            KenHubConfig[stateVar] = not KenHubConfig[stateVar]
            indicator.BackgroundColor3 = KenHubConfig[stateVar] and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(60, 60, 75)
            callback(KenHubConfig[stateVar])
        end)
    end

    addFeatureToggle("Auto Bounty Farm (Teleport & Target Players)", "AutoBounty", function(state)
        print("[KenHub] Auto Bounty toggled:", state)
    end)

    addFeatureToggle("Fast M1 Spam / Fruit Attack Aura (T-Rex/Leopard)", "AutoKillAura", function(state)
        print("[KenHub] Kill Aura toggled:", state)
    end)

    addFeatureToggle("Anti-Admin (Auto Leave on Staff Join)", "AntiAdminLeave", function(state)
        print("[KenHub] Anti-Admin toggled:", state)
    end)

    addFeatureToggle("Auto Server Hop on Low Player Count", "ServerHopOnLowPlayers", function(state)
        print("[KenHub] Server Hop toggled:", state)
    end)
end

-- Anti-Admin Logic Check (Kicks/Hops if specific high-rank roles join)
Players.PlayerAdded:Connect(function(player)
    if KenHubConfig.AntiAdminLeave then
        pcall(function()
            if player:GetRankInGroup(123456) >= 250 or player.UserId == 1 or player.Name:lower():find("admin") then
                TeleportService:Teleport(game.PlaceId, lp)
            end
        end)
    end
end)

initKenHubUI()
print("[KenHub] Successfully Loaded Auto Bounty Suite!")






