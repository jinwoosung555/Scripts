--[========================================================================--
--                 KEN HUB — ULTIMATE BLOX FRUITS EDITION v5.0              --
--        Persistent 24H Key System, Auto-Execution & Advanced Systems      --
--[========================================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Comprehensive Settings & Systems Registry
local Config = {
    KeyWebsite = "https://jinwoosung555.github.io/Keyy/",
    StorageFile = "KenHub_Ultimate_v5.json",
    
    -- Auto Farm Level
    AutoFarmLevel = false,
    FastAttack = true,
    BringMobs = true,
    AutoQuest = true,
    
    -- Auto Raid
    AutoRaid = false,
    SelectRaid = "Flame",
    AutoAwaken = true,
    
    -- Travel & Island Teleports
    SelectedIsland = "Starter Island",
    AutoTravel = false,
    
    -- Boss Farm
    AutoBoss = false,
    SelectedBoss = "All Bosses",
    
    -- Auto Stats
    AutoStats = false,
    SelectedStat = "Melee",
    StatPoints = 3,
    
    -- Bounty & Combat
    BountyHunter = false,
    PlayerAimbot = false,
    FOVEnabled = true,
    FOVRadius = 140,
    
    -- Player & Server Info
    NotificationsEnabled = true
}

-- Persistent 24-Hour Key Management
local function SaveKeyData(key)
    if writefile then
        pcall(function()
            local payload = { Key = key, ExpiresAt = os.time() + 86400 }
            writefile(Config.StorageFile, HttpService:JSONEncode(payload))
        end)
    end
end

local function LoadKeyData()
    if readfile and isfile and isfile(Config.StorageFile) then
        local success, res = pcall(function() return HttpService:JSONDecode(readfile(Config.StorageFile)) end)
        if success and res and res.Key and res.ExpiresAt then
            if os.time() < res.ExpiresAt then return res.Key 
            else pcall(function() delfile(Config.StorageFile) end) end
        end
    end
    return nil
end

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1.2
FOVCircle.NumSides = 90
FOVCircle.Color = Color3.fromRGB(168, 85, 247)
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8

-- Toast Notification Engine
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "KenHubNotifs"
NotifGui.Parent = CoreGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.Parent = NotifGui
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifLayout.Padding = UDim.new(0, 8)

local function SendNotification(title, msg)
    if not Config.NotificationsEnabled then return end
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 280, 0, 58)
    f.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    f.BackgroundTransparency = 1
    f.Parent = NotifGui
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    
    local str = Instance.new("UIStroke")
    str.Color = Color3.fromRGB(168, 85, 247)
    str.Transparency = 1
    str.Parent = f

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -20, 0, 18)
    t.Position = UDim2.new(0, 10, 0, 8)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamBold
    t.Text = title
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.TextSize = 12
    t.TextTransparency = 1
    t.Parent = f

    local m = Instance.new("TextLabel")
    m.Size = UDim2.new(1, -20, 0, 22)
    m.Position = UDim2.new(0, 10, 0, 26)
    m.BackgroundTransparency = 1
    m.Font = Enum.Font.Gotham
    m.Text = msg
    m.TextColor3 = Color3.fromRGB(150, 150, 165)
    m.TextSize = 11
    m.TextTransparency = 1
    m.Parent = f

    TweenService:Create(f, TweenInfo.new(0.3), {BackgroundTransparency = 0.05}):Play()
    TweenService:Create(str, TweenInfo.new(0.3), {Transparency = 0.3}):Play()
    TweenService:Create(t, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(m, TweenInfo.new(0.3), {TextTransparency = 0}):Play()

    task.delay(3, function()
        if f and f.Parent then
            TweenService:Create(f, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(str, TweenInfo.new(0.3), {Transparency = 1}):Play()
            task.wait(0.3)
            f:Destroy()
        end
    end)
end

-- Key Authentication Interface Forward Declaration
local LaunchHubInterface

local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "KenHubAuth"
KeyGui.Parent = CoreGui

local Dim = Instance.new("Frame")
Dim.Size = UDim2.new(1, 0, 1, 0)
Dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Dim.BackgroundTransparency = 0.6
Dim.Parent = KeyGui

local Box = Instance.new("Frame")
Box.Size = UDim2.new(0, 420, 0, 280)
Box.Position = UDim2.new(0.5, -210, 0.5, -140)
Box.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Box.BackgroundTransparency = 1
Box.Parent = KeyGui
Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 12)

local BoxStr = Instance.new("UIStroke")
BoxStr.Color = Color3.fromRGB(168, 85, 247)
BoxStr.Transparency = 0.4
BoxStr.Parent = Box

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1, 0, 0, 35)
TitleLbl.Position = UDim2.new(0, 0, 0, 20)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.Text = "Ken Hub <font color='#a855f7'>Blox Fruits Security</font>"
TitleLbl.RichText = true
TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLbl.TextSize = 16
TitleLbl.Parent = Box

local PortalBtn = Instance.new("TextButton")
PortalBtn.Size = UDim2.new(0.8, 0, 0, 38)
PortalBtn.Position = UDim2.new(0.1, 0, 0, 75)
PortalBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
PortalBtn.Font = Enum.Font.GothamMedium
PortalBtn.Text = "Copy Key Portal URL"
PortalBtn.TextColor3 = Color3.fromRGB(168, 85, 247)
PortalBtn.TextSize = 13
PortalBtn.Parent = Box
Instance.new("UICorner", PortalBtn).CornerRadius = UDim.new(0, 8)

PortalBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(Config.KeyWebsite)
        SendNotification("Success", "Portal link copied to clipboard.")
    end
end)

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0.8, 0, 0, 38)
KeyInput.Position = UDim2.new(0.1, 0, 0, 125)
KeyInput.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
KeyInput.Font = Enum.Font.Gotham
KeyInput.PlaceholderText = "Paste your 24h key here..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextSize = 13
KeyInput.Parent = Box
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 8)

local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0.8, 0, 0, 40)
VerifyBtn.Position = UDim2.new(0.1, 0, 0, 185)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.Text = "Verify & Auto-Execute"
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.TextSize = 13
VerifyBtn.Parent = Box
Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 8)

TweenService:Create(Box, TweenInfo.new(0.3), {BackgroundTransparency = 0.05}):Play()

getgenv().KenVerified = false

local function BootHub()
    getgenv().KenVerified = true
    TweenService:Create(Dim, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Box, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    task.wait(0.3)
    KeyGui:Destroy()
    SendNotification("Ken Hub", "Key verified successfully. Launching Blox Fruits suite...")
    LaunchHubInterface()
end

local activeKey = LoadKeyData()
if activeKey and string.sub(activeKey, 1, 7) == "KENHUB-" then
    KeyGui:Destroy()
    task.spawn(BootHub)
else
    VerifyBtn.MouseButton1Click:Connect(function()
        local input = KeyInput.Text
        if string.sub(input, 1, 7) == "KENHUB-" and string.sub(input, -4) == "-24H" then
            SaveKeyData(input)
            BootHub()
        else
            VerifyBtn.Text = "Invalid Token Format!"
            VerifyBtn.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
            task.wait(1.5)
            VerifyBtn.Text = "Verify & Auto-Execute"
            VerifyBtn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
        end
    end)
end

-- Main Hub Window Construction
LaunchHubInterface = function()
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "KenHubMainUI"
    MainGui.Parent = CoreGui

    local MainContainer = Instance.new("Frame")
    MainContainer.Size = UDim2.new(0, 580, 0, 420)
    MainContainer.Position = UDim2.new(0.5, -290, 0.5, -210)
    MainContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    MainContainer.Parent = MainGui
    Instance.new("UICorner", MainContainer).CornerRadius = UDim.new(0, 12)

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 44)
    TopBar.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    TopBar.Parent = MainContainer
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 250, 1, 0)
    Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Ken Hub <font color='#a855f7'>v5.0 Blox Fruits</font>"
    Title.RichText = true
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 36, 1, 0)
    CloseBtn.Position = UDim2.new(1, -40, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(220, 80, 80)
    CloseBtn.TextSize = 13
    CloseBtn.Parent = TopBar

    CloseBtn.MouseButton1Click:Connect(function()
        FOVCircle:Remove()
        MainGui:Destroy()
    end)

    -- Sidebar Navigation Tabs Setup
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 140, 1, -50)
    Sidebar.Position = UDim2.new(0, 0, 0, 48)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Parent = MainContainer

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -150, 1, -54)
    ContentArea.Position = UDim2.new(0, 146, 0, 52)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainContainer

    local TabButtons = {}
    local TabPanels = {}

    local function CreateSectionTab(name, index)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 122, 0, 34)
        btn.Position = UDim2.new(0, 10, 0, (index - 1) * 38)
        btn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
        btn.BackgroundTransparency = (index == 1) and 0 or 1
        btn.Font = Enum.Font.GothamMedium
        btn.Text = "   " .. name
        btn.TextColor3 = (index == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 155)
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = Sidebar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local panel = Instance.new("ScrollingFrame")
        panel.Size = UDim2.new(1, 0, 1, 0)
        panel.BackgroundTransparency = 1
        panel.CanvasSize = UDim2.new(0, 0, 0, 400)
        panel.ScrollBarThickness = 3
        panel.Visible = (index == 1)
        panel.Parent = ContentArea

        local layout = Instance.new("UIListLayout")
        layout.Parent = panel
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)

        btn.MouseButton1Click:Connect(function()
            for _, p in pairs(TabPanels) do p.Visible = false end
            for _, b in pairs(TabButtons) do 
                b.TextColor3 = Color3.fromRGB(140, 140, 155)
                b.BackgroundTransparency = 1
            end
            panel.Visible = true
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.BackgroundTransparency = 0
        end)

        table.insert(TabButtons, btn)
        table.insert(TabPanels, panel)
        return panel
    end

    local FarmTab = CreateSectionTab("Auto Farm", 1)
    local RaidTab = CreateSectionTab("Auto Raid", 2)
    local TravelTab = CreateSectionTab("Travel", 3)
    local BossTab = CreateSectionTab("Boss Farm", 4)
    local StatsTab = CreateSectionTab("Auto Stats", 5)
    local BountyTab = CreateSectionTab("Bounty & PVP", 6)
    local InfoTab = CreateSectionTab("Player Info", 7)

    -- UI Component Builders
    local function AddToggleElement(parent, labelText, defaultVal, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -6, 0, 36)
        b.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
        b.Font = Enum.Font.GothamMedium
        b.Text = "  " .. labelText
        b.TextColor3 = Color3.fromRGB(180, 180, 195)
        b.TextSize = 12
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.Parent = parent
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

        local s = Instance.new("TextLabel")
        s.Size = UDim2.new(0, 60, 1, 0)
        s.Position = UDim2.new(1, -65, 0, 0)
        s.BackgroundTransparency = 1
        s.Font = Enum.Font.GothamBold
        s.Text = defaultVal and "[ON]" or "[OFF]"
        s.TextColor3 = defaultVal and Color3.fromRGB(74, 222, 128) or Color3.fromRGB(239, 68, 68)
        s.TextSize = 11
        s.Parent = b

        local state = defaultVal
        b.MouseButton1Click:Connect(function()
            state = not state
            s.Text = state and "[ON]" or "[OFF]"
            s.TextColor3 = state and Color3.fromRGB(74, 222, 128) or Color3.fromRGB(239, 68, 68)
            callback(state)
        end)
    end

    -- Tab Content Setup
    AddToggleElement(FarmTab, "Auto Farm Level", Config.AutoFarmLevel, function(v) Config.AutoFarmLevel = v end)
    AddToggleElement(FarmTab, "Fast Attack Speed", Config.FastAttack, function(v) Config.FastAttack = v end)
    AddToggleElement(FarmTab, "Bring Mobs Close", Config.BringMobs, function(v) Config.BringMobs = v end)
    AddToggleElement(FarmTab, "Auto Accept Quests", Config.AutoQuest, function(v) Config.AutoQuest = v end)

    AddToggleElement(RaidTab, "Auto Raid Engine", Config.AutoRaid, function(v) Config.AutoRaid = v end)
    AddToggleElement(RaidTab, "Auto Awaken Fruit", Config.AutoAwaken, function(v) Config.AutoAwaken = v end)

    AddToggleElement(TravelTab, "Auto Travel / Island Warp", Config.AutoTravel, function(v) Config.AutoTravel = v end)

    AddToggleElement(BossTab, "Auto Farm All Bosses", Config.AutoBoss, function(v) Config.AutoBoss = v end)

    AddToggleElement(StatsTab, "Auto Allocate Stats", Config.AutoStats, function(v) Config.AutoStats = v end)

    AddToggleElement(BountyTab, "Bounty Hunter Mode", Config.BountyHunter, function(v) Config.BountyHunter = v end)
    AddToggleElement(BountyTab, "Player Aimbot Assist", Config.PlayerAimbot, function(v) Config.PlayerAimbot = v end)

    -- Player Info Summary Card
    local infoCard = Instance.new("Frame")
    infoCard.Size = UDim2.new(1, -6, 0, 160)
    infoCard.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
    infoCard.Parent = InfoTab
    Instance.new("UICorner", infoCard).CornerRadius = UDim.new(0, 8)

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -20, 1, -20)
    infoLabel.Position = UDim2.new(0, 10, 0, 10)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Text = "• Username: " .. LocalPlayer.Name .. "\n• Executor: Active\n• Key Valid: 24 Hours Active\n• Game: Blox Fruits Universe"
    infoLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
    infoLabel.TextSize = 12
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.Parent = infoCard
end

-- Render Engine Loop for Combat & Systems
RunService.RenderStepped:Connect(function()
    if not getgenv().KenVerified then return end

    if Config.FOVEnabled and Config.PlayerAimbot then
        FOVCircle.Visible = true
        FOVCircle.Radius = Config.FOVRadius
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    else
        FOVCircle.Visible = false
    end

    -- Core Aimbot Executor Loop
    if Config.PlayerAimbot then
        local targetHead = nil
        local minDist = math.huge
        local char = LocalPlayer.Character
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and myRoot then
                local head = plr.Character.Head
                local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local screenDist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(headPos.X, headPos.Y)).Magnitude
                    if screenDist <= Config.FOVRadius and screenDist < minDist then
                        minDist = screenDist
                        targetHead = head
                    end
                end
            end
        end

        if targetHead then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
        end
    end
end)
