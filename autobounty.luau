-- ============================================
-- NEXUS FREE (KEYLESS EDITION) — SELF-CONTAINED
-- Build: 2026-03-30
-- ALL-IN-ONE — NO LOADSTRING, NO EXTERNAL URLS, KEYLESS
-- ============================================

local _BUILD_VERSION = "7.5-Keyless"
local _BUILD_BRAND = "NEXUS FREE"

-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer

-- Workspace Folders Setup
pcall(function()
    if makefolder then
        if not isfolder("Nexus") then makefolder("Nexus") end
        if not isfolder("Nexus/Data") then makefolder("Nexus/Data") end
        if not isfolder("Nexus/Assets") then makefolder("Nexus/Assets") end
        if not isfolder("Nexus/Assets/Images") then makefolder("Nexus/Assets/Images") end
        if not isfolder("Nexus/Assets/Sounds") then makefolder("Nexus/Assets/Sounds") end
    end
end)

-- ============================================
-- UTILITIES & CONFIG MODULES
-- ============================================
local Utils = {}
Utils.ROOT_FOLDER = "Nexus"
Utils.DATA_FOLDER = "Nexus/Data"
Utils.CLIENT_VERSION = "7.5-Keyless"

function Utils.formatNumber(num)
    num = num or 0
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(math.floor(num))
    end
end

function Utils.formatTime(seconds)
    seconds = math.floor(seconds or 0)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    if hours > 0 then
        return string.format("%dh %dm %ds", hours, minutes, secs)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, secs)
    else
        return string.format("%ds", secs)
    end
end

function Utils.getCurrentBounty()
    local leaderstats = lp:FindFirstChild("leaderstats")
    if leaderstats then
        local bounty = leaderstats:FindFirstChild("Bounty/Honor")
        if bounty then return tonumber(bounty.Value) or 0 end
    end
    return 0
end

local Config = {
    Values = {
        Fruit = "T-Rex",
        Region = "Auto",
        Faction = "Pirate",
        StartupSound = true,
        Webhook = "",
        ChangeTeamAt30M = true,
        AutoKillAt30M = false,
        HideProfile = false,
        TransformTRex = true,
    }
}

function Config.get(key)
    return Config.Values[key]
end

-- ============================================
-- KEYLESS AUTH BYPASS OVERRIDE
-- ============================================
local Auth = {}
Auth.IsAuthenticated = true  -- Bypass keys completely

function Auth.isAuthenticated()
    return true
end

function Auth.validateKey(key, callback)
    callback(true, "Keyless Bypass Active")
end

function Auth.tryCachedKey(callback)
    callback(true, "Keyless Bypass Active")
end

-- ============================================
-- PREMIUM GLASSMORPHIC UI (KEYLESS)
-- ============================================
local UI = {}
UI.Connections = {}

local Colors = {
    Background = Color3.fromRGB(12, 12, 15),
    Surface = Color3.fromRGB(28, 28, 36),
    SurfaceLight = Color3.fromRGB(42, 42, 55),
    Primary = Color3.fromRGB(170, 130, 255),
    PrimaryMuted = Color3.fromRGB(140, 100, 230),
    Text = Color3.fromRGB(245, 245, 250),
    TextSecondary = Color3.fromRGB(170, 170, 190),
    TextMuted = Color3.fromRGB(110, 110, 130),
    Success = Color3.fromRGB(80, 220, 120),
    Border = Color3.fromRGB(60, 60, 75),
}

local function tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    corner.Parent = parent
    return corner
end

local function createStroke(parent, color)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Colors.Border
    stroke.Thickness = 1
    stroke.Parent = parent
    return stroke
end

function UI.init()
    if CoreGui:FindFirstChild("NexusFreeUI") then
        CoreGui.NexusFreeUI:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NexusFreeUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.BackgroundColor3 = Colors.Background
    mainFrame.Size = UDim2.new(0, 560, 0, 390)
    mainFrame.Position = UDim2.new(0.5, -280, 0.5, -195)
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    createCorner(mainFrame, 12)
    createStroke(mainFrame, Colors.Border)

    -- Top Bar Header
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.BackgroundColor3 = Colors.Surface
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.Parent = mainFrame
    createCorner(topBar, 12)

    local title = Instance.new("TextLabel")
    title.Text = "  NEXUS FREE <font color='#aa82ff'>[KEYLESS]</font>"
    title.RichText = true
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Colors.Text
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Parent = topBar

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "×"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextColor3 = Colors.TextSecondary
    closeBtn.TextSize = 18
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0, 2.5)
    closeBtn.BackgroundColor3 = Colors.SurfaceLight
    closeBtn.Parent = topBar
    createCorner(closeBtn, 8)

    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Sidebar Navigation Tabs
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.BackgroundColor3 = Colors.Surface
    sidebar.Size = UDim2.new(0, 150, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.Parent = mainFrame

    local containerLayout = Instance.new("UIListLayout")
    containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    containerLayout.Padding = UDim.new(0, 5)
    containerLayout.Parent = sidebar

    -- Dashboard Content Holder
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.BackgroundTransparency = 1
    contentArea.Size = UDim2.new(1, -160, 1, -50)
    contentArea.Position = UDim2.new(0, 155, 0, 45)
    contentArea.Parent = mainFrame

    -- Stat Cards (Live Dashboard Stats)
    local function createCard(name, labelText, defaultVal, posX, posY)
        local card = Instance.new("Frame")
        card.BackgroundColor3 = Colors.SurfaceLight
        card.Size = UDim2.new(0.48, 0, 0, 75)
        card.Position = posX
        card.Parent = contentArea
        createCorner(card, 8)

        local label = Instance.new("TextLabel")
        label.Text = labelText
        label.Font = Enum.Font.GothamSemibold
        label.TextColor3 = Colors.TextSecondary
        label.TextSize = 11
        label.Size = UDim2.new(1, -15, 0, 20)
        label.Position = UDim2.new(0, 12, 0, 8)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = card

        local val = Instance.new("TextLabel")
        val.Name = name
        val.Text = defaultVal
        val.Font = Enum.Font.GothamBold
        val.TextColor3 = Colors.Text
        val.TextSize = 16
        val.Size = UDim2.new(1, -15, 0, 30)
        val.Position = UDim2.new(0, 12, 0, 32)
        val.BackgroundTransparency = 1
        val.TextXAlignment = Enum.TextXAlignment.Left
        val.Parent = card

        return val
    end

    local killsVal = createCard("KillsVal", "TOTAL KILLS", "0", UDim2.new(0, 0, 0, 0), UDim2.new(0, 0, 0, 0))
    local bountyVal = createCard("BountyVal", "SESSION BOUNTY", "+$0", UDim2.new(0.52, 0, 0, 0), UDim2.new(0, 0, 0, 0))
    local timeVal = createCard("TimeVal", "RUN TIME", "0m 0s", UDim2.new(0, 0, 0, 85), UDim2.new(0, 0, 0, 0))
    local statusVal = createCard("StatusVal", "ENGINE STATUS", "Running (Keyless)", UDim2.new(0.52, 0, 0, 85), UDim2.new(0, 0, 0, 0))
    statusVal.TextColor3 = Colors.Success

    -- Feature Toggle List Container
    local toggleContainer = Instance.new("ScrollingFrame")
    toggleContainer.Name = "Toggles"
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Size = UDim2.new(1, 0, 0, 180)
    toggleContainer.Position = UDim2.new(0, 0, 0, 175)
    toggleContainer.CanvasSize = UDim2.new(0, 0, 0, 220)
    toggleContainer.ScrollBarThickness = 3
    toggleContainer.Parent = contentArea

    local function addToggle(textString, initialValue, callback)
        local btn = Instance.new("TextButton")
        btn.BackgroundColor3 = Colors.SurfaceLight
        btn.Size = UDim2.new(1, -5, 0, 34)
        btn.Text = "  " .. textString
        btn.Font = Enum.Font.GothamMedium
        btn.TextColor3 = Colors.Text
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        btn.Parent = toggleContainer
        createCorner(btn, 6)

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 12, 0, 12)
        indicator.Position = UDim2.new(1, -25, 0.5, -6)
        indicator.BackgroundColor3 = initialValue and Colors.Success or Colors.Border
        indicator.Parent = btn
        createCorner(indicator, 6)

        local state = initialValue
        btn.MouseButton1Click:Connect(function()
            state = not state
            indicator.BackgroundColor3 = state and Colors.Success or Colors.Border
            callback(state)
        end)
    end

    local layoutToggles = Instance.new("UIListLayout")
    layoutToggles.SortOrder = Enum.SortOrder.LayoutOrder
    layoutToggles.Padding = UDim.new(0, 6)
    layoutToggles.Parent = toggleContainer

    addToggle("Auto-Transform T-Rex Rage", Config.get("TransformTRex"), function(v) end)
    addToggle("Team Switch at 30M Bounty", Config.get("ChangeTeamAt30M"), function(v) end)
    addToggle("Startup Audio Hook (Bankai)", Config.get("StartupSound"), function(v) end)
    addToggle("Hide Profile Identifiers", Config.get("HideProfile"), function(v) end)

    -- Real-time UI Loop Updates
    local startTime = tick()
    task.spawn(function()
        while screenGui.Parent do
            task.wait(1)
            local elapsed = tick() - startTime
            timeVal.Text = Utils.formatTime(elapsed)
        end
    end)
end

-- Initialize the Core UI directly with Keyless Mode
UI.init()
print("[Nexus-Keyless] [+] Successfully injected with no keys required!")





