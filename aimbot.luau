--[========================================================================--
--                 KEN HUB — NEXT-GEN PREMIUM EDITION                       --
--             Enhanced Glassmorphic UI & Advanced Key System               --
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

-- Configuration & State Registry
local Config = {
    PlayerAimbot = false,
    NPCAimbot = false,
    AimbotDistance = 2500,
    MaxAimbotDistance = 10000,
    FOVEnabled = false,
    FOVSize = 120,
    MaxFOVSize = 400,
    FOVColor = Color3.fromRGB(168, 85, 247),
    SpeedBoost = false,
    SpeedValue = 24,
    JumpBoost = false,
    JumpValue = 72,
    NotificationsEnabled = true,
    PerformanceMode = false,
    WebsiteKeyURL = "https://jinwoosung555.github.io/Keyy/",
    KeyStorageFile = "KenHub_AuthKey.json"
}

local CachedNPCs = {}
local LastCacheUpdate = 0
local CacheInterval = 2.0

-- Persistent Key Validation Helper
local function SaveSavedKey(key)
    if writefile then
        pcall(function()
            writefile(Config.KeyStorageFile, HttpService:JSONEncode({Key = key, Timestamp = os.time()}))
        end)
    end
end

local function LoadSavedKey()
    if readfile and isfile and isfile(Config.KeyStorageFile) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(Config.KeyStorageFile))
        end)
        if success and data and data.Key then
            -- Optional: Check if key is expired (e.g., 24 hours = 86400 seconds)
            if os.time() - (data.Timestamp or 0) < 86400 then
                return data.Key
            end
        end
    end
    return nil
end

-- Premium FOV Circle Setup
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1.2
FOVCircle.NumSides = 90
FOVCircle.Color = Config.FOVColor
FOVCircle.Filled = false
FOVCircle.Transparency = 0.75

-- Modern Toast Notification Hub
local NotificationHolder = Instance.new("ScreenGui")
NotificationHolder.Name = "KenHubNotifications"
NotificationHolder.Parent = CoreGui
NotificationHolder.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local ToastListLayout = Instance.new("UIListLayout")
ToastListLayout.Parent = NotificationHolder
ToastListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ToastListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
ToastListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ToastListLayout.Padding = UDim.new(0, 10)

local function SendNotification(title, message, duration)
    if not Config.NotificationsEnabled then return end
    duration = duration or 3.0
    
    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(0, 300, 0, 65)
    toast.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    toast.BorderSizePixel = 0
    toast.BackgroundTransparency = 1
    toast.Parent = NotificationHolder
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = toast
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(168, 85, 247)
    stroke.Transparency = 1
    stroke.Parent = toast
    
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -24, 0, 20)
    titleLbl.Position = UDim2.new(0, 12, 0, 10)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextTransparency = 1
    titleLbl.Parent = toast
    
    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, -24, 0, 24)
    descLbl.Position = UDim2.new(0, 12, 0, 30)
    descLbl.BackgroundTransparency = 1
    descLbl.Font = Enum.Font.Gotham
    descLbl.Text = message
    descLbl.TextColor3 = Color3.fromRGB(160, 160, 175)
    descLbl.TextSize = 11
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.TextTransparency = 1
    descLbl.Parent = toast
    
    TweenService:Create(toast, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0.08}):Play()
    TweenService:Create(stroke, TweenInfo.new(0.35), {Transparency = 0.3}):Play()
    TweenService:Create(titleLbl, TweenInfo.new(0.35), {TextTransparency = 0}):Play()
    TweenService:Create(descLbl, TweenInfo.new(0.35), {TextTransparency = 0}):Play()
    
    task.delay(duration, function()
        if not toast or not toast.Parent then return end
        local tInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        TweenService:Create(toast, tInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(stroke, tInfo, {Transparency = 1}):Play()
        TweenService:Create(titleLbl, tInfo, {TextTransparency = 1}):Play()
        TweenService:Create(descLbl, tInfo, {TextTransparency = 1}):Play()
        task.wait(0.3)
        toast:Destroy()
    end)
end

-- Advanced Authentication / Key Gate UI
local KeySystemGUI = Instance.new("ScreenGui")
KeySystemGUI.Name = "KenHubKeySystem"
KeySystemGUI.Parent = CoreGui
KeySystemGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local KeyBackdrop = Instance.new("Frame")
KeyBackdrop.Parent = KeySystemGUI
KeyBackdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
KeyBackdrop.Size = UDim2.new(1, 0, 1, 0)
KeyBackdrop.BackgroundTransparency = 0.6

local KeyFrame = Instance.new("Frame")
KeyFrame.Parent = KeySystemGUI
KeyFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
KeyFrame.Position = UDim2.new(0.5, -210, 0.5, -145)
KeyFrame.Size = UDim2.new(0, 420, 0, 290)
KeyFrame.BackgroundTransparency = 1
Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 14)

local KeyStroke = Instance.new("UIStroke")
KeyStroke.Color = Color3.fromRGB(168, 85, 247)
KeyStroke.Transparency = 0.4
KeyStroke.Parent = KeyFrame

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Parent = KeyFrame
KeyTitle.BackgroundTransparency = 1
KeyTitle.Position = UDim2.new(0, 0, 0, 24)
KeyTitle.Size = UDim2.new(1, 0, 0, 30)
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.Text = "Ken Hub <font color='#a855f7'>Authentication</font>"
KeyTitle.RichText = true
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.TextSize = 18

local KeyInfo = Instance.new("TextLabel")
KeyInfo.Parent = KeyFrame
KeyInfo.BackgroundTransparency = 1
KeyInfo.Position = UDim2.new(0, 24, 0, 60)
KeyInfo.Size = UDim2.new(1, -48, 0, 35)
KeyInfo.Font = Enum.Font.Gotham
KeyInfo.Text = "Enter your active access key or visit our secure portal to generate one instantly."
KeyInfo.TextColor3 = Color3.fromRGB(150, 150, 165)
KeyInfo.TextSize = 12
KeyInfo.TextWrapped = true

local WebBtn = Instance.new("TextButton")
WebBtn.Parent = KeyFrame
WebBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
WebBtn.Position = UDim2.new(0.1, 0, 0, 105)
WebBtn.Size = UDim2.new(0.8, 0, 0, 40)
WebBtn.Font = Enum.Font.GothamMedium
WebBtn.Text = "Get Key from Portal"
WebBtn.TextColor3 = Color3.fromRGB(168, 85, 247)
WebBtn.TextSize = 13
Instance.new("UICorner", WebBtn).CornerRadius = UDim.new(0, 8)

WebBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(Config.WebsiteKeyURL)
        SendNotification("Clipboard", "Portal link copied to clipboard successfully.", 3)
        WebBtn.Text = "Portal Link Copied!"
        task.wait(2)
        WebBtn.Text = "Get Key from Portal"
    else
        SendNotification("Error", "Executor lacks setclipboard capability.", 3)
    end
end)

local KeyBox = Instance.new("TextBox")
KeyBox.Parent = KeyFrame
KeyBox.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
KeyBox.Position = UDim2.new(0.1, 0, 0, 155)
KeyBox.Size = UDim2.new(0.8, 0, 0, 40)
KeyBox.Font = Enum.Font.Gotham
KeyBox.PlaceholderText = "Paste key here (e.g., KENHUB-...-24H)"
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.TextSize = 13
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 8)

-- Auto-fill saved key if available
local savedKey = LoadSavedKey()
if savedKey then
    KeyBox.Text = savedKey
end

local SubmitKeyBtn = Instance.new("TextButton")
SubmitKeyBtn.Parent = KeyFrame
SubmitKeyBtn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
SubmitKeyBtn.Position = UDim2.new(0.1, 0, 0, 215)
SubmitKeyBtn.Size = UDim2.new(0.8, 0, 0, 42)
SubmitKeyBtn.Font = Enum.Font.GothamBold
SubmitKeyBtn.Text = "Verify & Initialize"
SubmitKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitKeyBtn.TextSize = 14
Instance.new("UICorner", SubmitKeyBtn).CornerRadius = UDim.new(0, 8)

TweenService:Create(KeyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0.02}):Play()

getgenv().VerifiedPassed = false

local function LaunchMainHub()
    getgenv().VerifiedPassed = true
    TweenService:Create(KeyBackdrop, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(KeyFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    task.wait(0.3)
    KeySystemGUI:Destroy()
    SendNotification("Ken Hub", "Authentication confirmed. Welcome back!", 3)
end

-- Instant bypass check if saved key is valid format
if savedKey and string.sub(savedKey, 1, 7) == "KENHUB-" and string.sub(savedKey, -4) == "-24H" then
    task.spawn(LaunchMainHub)
end

SubmitKeyBtn.MouseButton1Click:Connect(function()
    local text = KeyBox.Text
    if string.sub(text, 1, 7) == "KENHUB-" and string.sub(text, -4) == "-24H" then
        SaveSavedKey(text)
        LaunchMainHub()
    else
        SubmitKeyBtn.Text = "Invalid Token Format!"
        SubmitKeyBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
        task.wait(1.5)
        SubmitKeyBtn.Text = "Verify & Initialize"
        SubmitKeyBtn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
    end
end)

-- Main UI Modern Architecture
local function LoadMainUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KenHubMainUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainContainer = Instance.new("Frame")
    MainContainer.Name = "MainContainer"
    MainContainer.Parent = ScreenGui
    MainContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    MainContainer.BorderSizePixel = 0
    MainContainer.Position = UDim2.new(0.5, -280, 0.5, -200)
    MainContainer.Size = UDim2.new(0, 560, 0, 400)
    MainContainer.BackgroundTransparency = 1
    Instance.new("UICorner", MainContainer).CornerRadius = UDim.new(0, 14)

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(45, 45, 60)
    MainStroke.Transparency = 0.3
    MainStroke.Parent = MainContainer

    TweenService:Create(MainContainer, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()

    -- Top Navigation & Header Bar
    local TopBar = Instance.new("Frame")
    TopBar.Parent = MainContainer
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 48)
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 14)

    local TopBarFix = Instance.new("Frame")
    TopBarFix.Parent = TopBar
    TopBarFix.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    TopBarFix.BorderSizePixel = 0
    TopBarFix.Position = UDim2.new(0, 0, 1, -8)
    TopBarFix.Size = UDim2.new(1, 0, 0, 8)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = TopBar
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 16, 0, 0)
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = "Ken Hub  <font color='#a855f7'>v3.0</font>"
    TitleLabel.RichText = true
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = TopBar
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Position = UDim2.new(1, -42, 0, 2)
    CloseBtn.Size = UDim2.new(0, 38, 1, -2)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(200, 80, 80)
    CloseBtn.TextSize = 14

    CloseBtn.MouseButton1Click:Connect(function()
        FOVCircle:Remove()
        ScreenGui:Destroy()
    end)

    local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = TopBar
    MinBtn.BackgroundTransparency = 1
    MinBtn.Position = UDim2.new(1, -80, 0, 2)
    MinBtn.Size = UDim2.new(0, 38, 1, -2)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Color3.fromRGB(170, 170, 185)
    MinBtn.TextSize = 14

    -- Minimizable Floating Pill UI
    local FloatingPill = Instance.new("TextButton")
    FloatingPill.Name = "FloatingMinimized"
    FloatingPill.Parent = ScreenGui
    FloatingPill.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    FloatingPill.Position = UDim2.new(0, 30, 0, 30)
    FloatingPill.Size = UDim2.new(0, 48, 0, 48)
    FloatingPill.Font = Enum.Font.GothamBold
    FloatingPill.Text = "K"
    FloatingPill.TextColor3 = Color3.fromRGB(168, 85, 247)
    FloatingPill.TextSize = 20
    FloatingPill.Visible = false
    Instance.new("UICorner", FloatingPill).CornerRadius = UDim.new(0, 12)
    
    local PillStroke = Instance.new("UIStroke")
    PillStroke.Color = Color3.fromRGB(168, 85, 247)
    PillStroke.Transparency = 0.3
    PillStroke.Parent = FloatingPill

    MinBtn.MouseButton1Click:Connect(function()
        MainContainer.Visible = false
        FloatingPill.Visible = true
    end)

    FloatingPill.MouseButton1Click:Connect(function()
        MainContainer.Visible = true
        FloatingPill.Visible = false
    end)

    -- Draggable functionality for main interface window & floating icon
    local draggingMain, dragInputMain, dragStartMain, startPosMain
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingMain = true
            dragStartMain = input.Position
            startPosMain = MainContainer.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    draggingMain = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingMain and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartMain
            MainContainer.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)
        end
    end)

    -- Sidebar Navigation Setup
    local Sidebar = Instance.new("Frame")
    Sidebar.Parent = MainContainer
    Sidebar.BackgroundTransparency = 1
    Sidebar.Position = UDim2.new(0, 0, 0, 54)
    Sidebar.Size = UDim2.new(0, 145, 1, -54)

    local TabContainer = Instance.new("Frame")
    TabContainer.Parent = MainContainer
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 155, 0, 58)
    TabContainer.Size = UDim2.new(0, 395, 1, -68)

    local TabButtons = {}
    local TabPanels = {}

    local function CreateTab(name, index)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Parent = Sidebar
        tabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
        tabBtn.BackgroundTransparency = 1
        tabBtn.Position = UDim2.new(0, 10, 0, (index - 1) * 40)
        tabBtn.Size = UDim2.new(0, 125, 0, 34)
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.Text = "   " .. name
        tabBtn.TextColor3 = Color3.fromRGB(150, 150, 165)
        tabBtn.TextSize = 13
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 8)

        local panel = Instance.new("ScrollingFrame")
        panel.Parent = TabContainer
        panel.BackgroundTransparency = 1
        panel.Size = UDim2.new(1, 0, 1, 0)
        panel.CanvasSize = UDim2.new(0, 0, 0, 480)
        panel.ScrollBarThickness = 3
        panel.ScrollBarImageColor3 = Color3.fromRGB(168, 85, 247)
        panel.Visible = false

        local layout = Instance.new("UIListLayout")
        layout.Parent = panel
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 10)

        tabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(TabPanels) do p.Visible = false end
            for _, b in pairs(TabButtons) do 
                b.TextColor3 = Color3.fromRGB(150, 150, 165)
                b.BackgroundTransparency = 1
            end
            panel.Visible = true
            tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tabBtn.BackgroundTransparency = 0
            tabBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 35)
        end)

        table.insert(TabButtons, tabBtn)
        table.insert(TabPanels, panel)

        if index == 1 then
            panel.Visible = true
            tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tabBtn.BackgroundTransparency = 0
            tabBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 35)
        end

        return panel
    end

    local HomeTab = CreateTab("Home", 1)
    local AimTab = CreateTab("Combat", 2)
    local MovementTab = CreateTab("Movement", 3)
    local SettingsTab = CreateTab("Settings", 4)
    local CreditsTab = CreateTab("Credits", 5)

    local function AddHeader(parent, text)
        local lbl = Instance.new("TextLabel")
        lbl.Parent = parent
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, 0, 0, 24)
        lbl.Font = Enum.Font.GothamBold
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(210, 210, 225)
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
    end

    local function AddToggle(parent, labelText, defaultState, callback)
        local btn = Instance.new("TextButton")
        btn.Parent = parent
        btn.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
        btn.Size = UDim2.new(1, -6, 0, 38)
        btn.Font = Enum.Font.GothamMedium
        btn.Text = "  " .. labelText
        btn.TextColor3 = Color3.fromRGB(190, 190, 205)
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local statusIndicator = Instance.new("TextLabel")
        statusIndicator.Parent = btn
        statusIndicator.BackgroundTransparency = 1
        statusIndicator.Position = UDim2.new(1, -75, 0, 0)
        statusIndicator.Size = UDim2.new(0, 65, 1, 0)
        statusIndicator.Font = Enum.Font.GothamBold
        statusIndicator.Text = defaultState and "[ON]" or "[OFF]"
        statusIndicator.TextColor3 = defaultState and Color3.fromRGB(74, 222, 128) or Color3.fromRGB(239, 68, 68)
        statusIndicator.TextSize = 12

        local state = defaultState
        btn.MouseButton1Click:Connect(function()
            state = not state
            statusIndicator.Text = state and "[ON]" or "[OFF]"
            statusIndicator.TextColor3 = state and Color3.fromRGB(74, 222, 128) or Color3.fromRGB(239, 68, 68)
            callback(state)
        end)
    end

    local function AddSlider(parent, labelText, min, max, default, callback)
        local container = Instance.new("Frame")
        container.Parent = parent
        container.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
        container.Size = UDim2.new(1, -6, 0, 52)
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)

        local label = Instance.new("TextLabel")
        label.Parent = container
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 12, 0, 6)
        label.Size = UDim2.new(1, -24, 0, 18)
        label.Font = Enum.Font.GothamMedium
        label.Text = labelText .. ": " .. default
        label.TextColor3 = Color3.fromRGB(190, 190, 205)
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left

        local sliderBar = Instance.new("TextButton")
        sliderBar.Parent = container
        sliderBar.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
        sliderBar.Position = UDim2.new(0, 12, 0, 32)
        sliderBar.Size = UDim2.new(1, -24, 0, 6)
        sliderBar.AutoButtonColor = false
        sliderBar.Text = ""
        Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0, 3)

        local fill = Instance.new("Frame")
        fill.Parent = sliderBar
        fill.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

        local draggingSlider = false
        sliderBar.MouseButton1Down:Connect(function() draggingSlider = true end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local mousePos = UserInputService:GetMouseLocation()
                local absPos = sliderBar.AbsolutePosition
                local absSize = sliderBar.AbsoluteSize
                local percentage = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
                local value = math.floor(min + (max - min) * percentage)
                fill.Size = UDim2.new(percentage, 0, 1, 0)
                label.Text = labelText .. ": " .. value
                callback(value)
            end
        end)
    end

    AddHeader(HomeTab, "Overview")
    local infoCard = Instance.new("Frame")
    infoCard.Parent = HomeTab
    infoCard.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    infoCard.Size = UDim2.new(1, -6, 0, 115)
    Instance.new("UICorner", infoCard).CornerRadius = UDim.new(0, 8)

    local infoText = Instance.new("TextLabel")
    infoText.Parent = infoCard
    infoText.BackgroundTransparency = 1
    infoText.Position = UDim2.new(0, 14, 0, 12)
    infoText.Size = UDim2.new(1, -28, 1, -24)
    infoText.Font = Enum.Font.Gotham
    infoText.Text = "Ken Hub Next-Gen Premium Edition.\n\n• Version: 3.0 Refined\n• Status: Active & Secured\n• Architecture: Modular Engine\n• Support Community: f8WZ6yJxRD"
    infoText.TextColor3 = Color3.fromRGB(160, 160, 175)
    infoText.TextSize = 12
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.TextYAlignment = Enum.TextYAlignment.Top

    AddHeader(HomeTab, "Preferences")
    AddToggle(HomeTab, "Toast Notifications", Config.NotificationsEnabled, function(state) Config.NotificationsEnabled = state end)

    AddHeader(AimTab, "Target Configuration")
    AddToggle(AimTab, "Player Aimbot", Config.PlayerAimbot, function(val) Config.PlayerAimbot = val end)
    AddToggle(AimTab, "NPC Target Aimbot", Config.NPCAimbot, function(val) Config.NPCAimbot = val end)
    
    AddHeader(AimTab, "FOV & Range Parameters")
    AddToggle(AimTab, "FOV Circle Render", Config.FOVEnabled, function(val) Config.FOVEnabled = val end)
    AddSlider(AimTab, "FOV Size", 10, Config.MaxFOVSize, Config.FOVSize, function(val) Config.FOVSize = val end)
    AddSlider(AimTab, "Max Range Distance", 100, Config.MaxAimbotDistance, Config.AimbotDistance, function(val) Config.AimbotDistance = val end)

    AddHeader(MovementTab, "Player Dynamics")
    AddToggle(MovementTab, "WalkSpeed Booster", Config.SpeedBoost, function(val) Config.SpeedBoost = val end)
    AddSlider(MovementTab, "WalkSpeed Target", 16, 100, Config.SpeedValue, function(val) Config.SpeedValue = val end)
    AddToggle(MovementTab, "JumpPower Booster", Config.JumpBoost, function(val) Config.JumpBoost = val end)
    AddSlider(MovementTab, "JumpPower Target", 50, 200, Config.JumpValue, function(val) Config.JumpValue = val end)

    AddHeader(SettingsTab, "Performance & Diagnostics")
    AddToggle(SettingsTab, "Low-End Performance Mode", Config.PerformanceMode, function(val) 
        Config.PerformanceMode = val 
        SendNotification("Performance", val and "Optimization mode enabled." or "Standard performance resumed.", 2)
    end)

    AddHeader(CreditsTab, "Development Team")
    
    local function AddCreditCard(name, role)
        local card = Instance.new("Frame")
        card.Parent = CreditsTab
        card.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
        card.Size = UDim2.new(1, -6, 0, 48)
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

        local nLbl = Instance.new("TextLabel")
        nLbl.Parent = card
        nLbl.BackgroundTransparency = 1
        nLbl.Position = UDim2.new(0, 14, 0, 6)
        nLbl.Size = UDim2.new(1, -24, 0, 18)
        nLbl.Font = Enum.Font.GothamBold
        nLbl.Text = name
        nLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        nLbl.TextSize = 13
        nLbl.TextXAlignment = Enum.TextXAlignment.Left

        local rLbl = Instance.new("TextLabel")
        rLbl.Parent = card
        rLbl.BackgroundTransparency = 1
        rLbl.Position = UDim2.new(0, 14, 0, 24)
        rLbl.Size = UDim2.new(1, -24, 0, 18)
        rLbl.Font = Enum.Font.Gotham
        rLbl.Text = role
        rLbl.TextColor3 = Color3.fromRGB(140, 140, 155)
        rLbl.TextSize = 11
        rLbl.TextXAlignment = Enum.TextXAlignment.Left
    end

    AddCreditCard("Jinwoo", "Lead Developer / Architect")
    AddCreditCard("KENzoro", "Quality Assurance & Testing")
    AddCreditCard("Ayla", "UI / UX Designer")
end

-- Optimized Cached NPC Sweeper Engine
local function GetCachedNPCs()
    local currentTime = os.clock()
    if currentTime - LastCacheUpdate > CacheInterval or Config.PerformanceMode then
        table.clear(CachedNPCs)
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("Head") then
                if not Players:GetPlayerFromCharacter(obj) then
                    table.insert(CachedNPCs, obj)
                end
            end
        end
        LastCacheUpdate = currentTime
    end
    return CachedNPCs
end

RunService.RenderStepped:Connect(function()
    if not getgenv().VerifiedPassed then return end

    if Config.FOVEnabled then
        FOVCircle.Visible = true
        FOVCircle.Radius = Config.FOVSize
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    else
        FOVCircle.Visible = false
    end

    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid
        if Config.SpeedBoost then humanoid.WalkSpeed = Config.SpeedValue end
        if Config.JumpBoost then humanoid.JumpPower = Config.JumpValue end
    end

    local targetHead = nil
    local shortestDist = math.huge
    local myRoot = character and character:FindFirstChild("HumanoidRootPart")

    if Config.PlayerAimbot then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and myRoot then
                local char = player.Character
                local humanoid = char:FindFirstChild("Humanoid")
                local head = char.Head
                if humanoid and humanoid.Health > 0 then
                    local worldDist = (myRoot.Position - head.Position).Magnitude
                    if worldDist <= Config.AimbotDistance then
                        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local screenDist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(headPos.X, headPos.Y)).Magnitude
                            if (not Config.FOVEnabled or screenDist <= Config.FOVSize) and screenDist < shortestDist then
                                shortestDist = screenDist
                                targetHead = head
                            end
                        end
                    end
                end
            end
        end
    elseif Config.NPCAimbot then
        local npcs = GetCachedNPCs()
        for _, model in ipairs(npcs) do
            if model and model:FindFirstChild("Humanoid") and model:FindFirstChild("Head") and myRoot then
                local humanoid = model.Humanoid
                local head = model.Head
                if humanoid.Health > 0 then
                    local worldDist = (myRoot.Position - head.Position).Magnitude
                    if worldDist <= Config.AimbotDistance then
                        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local screenDist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(headPos.X, headPos.Y)).Magnitude
                            if (not Config.FOVEnabled or screenDist <= Config.FOVSize) and screenDist < shortestDist then
                                shortestDist = screenDist
                                targetHead = head
                            end
                        end
                    end
                end
            end
        end
    end

    if targetHead then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
    end
end)

task.spawn(function()
    while not getgenv().VerifiedPassed do
        task.wait(0.2)
    end
    LoadMainUI()
end)
