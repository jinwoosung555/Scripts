--[========================================================================--
--            KEN HUB — NEXUS AI / ULTIMATE ALL-IN-ONE SUITE v8.0           --
--   Key Verification, Config GUI, Real Combat Damage, & Auto Server Hop   --
--[========================================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local canWrite = (writefile ~= nil and makefolder ~= nil)
local canRead = (readfile ~= nil and isfile ~= nil)

-- Comprehensive All-In-One Configuration Registry
local Config = {
    KeyWebsite = "https://jinwoosung555.github.io/Keyy/",
    StorageFile = "KenHub_AllInOne_v8.json",
    
    -- Auto Bounty & Combat Engine
    AutoBounty = false,
    ServerHopWhenNoTargets = true,
    SafeZone = {
        Enable = true,
        LowHealth = 2500,
        TeleportY = 600,
    },
    ChatSpam = {
        Enabled = false,
        List = {"Ken Hub Nexus AI > All", "Too Easy Auto Bounty!"},
        Delay = 12
    },
    
    -- Extra Features
    PlayerAimbot = false,
    FOVEnabled = true,
    FOVRadius = 140,
    NotificationsEnabled = true
}

-- Key Management (24H Local File Cache)
local function SaveKeyData(key)
    if canWrite then
        pcall(function()
            local payload = { Key = key, ExpiresAt = os.time() + 86400 }
            writefile(Config.StorageFile, HttpService:JSONEncode(payload))
        end)
    end
end

local function LoadKeyData()
    if canRead and isfile(Config.StorageFile) then
        local success, res = pcall(function() 
            return HttpService:JSONDecode(readfile(Config.StorageFile)) 
        end)
        if success and res and res.Key and res.ExpiresAt then
            if os.time() < res.ExpiresAt then 
                return res.Key 
            else 
                pcall(function() delfile(Config.StorageFile) end) 
            end
        end
    end
    return nil
end

-- FOV Circle Utility
local FOVCircle
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Thickness = 1.2
    FOVCircle.NumSides = 90
    FOVCircle.Color = Color3.fromRGB(168, 85, 247)
    FOVCircle.Filled = false
    FOVCircle.Transparency = 0.8
end)

-- Toast Notification Engine
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "KenHubAllInOneNotifs"
NotifGui.ResetOnSpawn = false
pcall(function() NotifGui.Parent = CoreGui end)

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.Parent = NotifGui
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifLayout.Padding = UDim.new(0, 8)

local function SendNotification(title, msg)
    if not Config.NotificationsEnabled then return end
    pcall(function()
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
    end)
end

-- Key Authentication GUI
local LaunchHubInterface

local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "KenHubAuth"
KeyGui.ResetOnSpawn = false
pcall(function() KeyGui.Parent = CoreGui end)

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
TitleLbl.Text = "Ken Hub <font color='#a855f7'>All-In-One Security</font>"
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
    else
        SendNotification("Error", "Executor does not support setclipboard.")
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
    pcall(function()
        TweenService:Create(Dim, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(Box, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    end)
    task.wait(0.3)
    pcall(function() KeyGui:Destroy() end)
    SendNotification("Ken Hub", "Key verified! Select your faction/side, then turn on Auto Bounty.")
    LaunchHubInterface()
end

local activeKey = LoadKeyData()
if activeKey and string.sub(activeKey, 1, 7) == "KENHUB-" then
    pcall(function() KeyGui:Destroy() end)
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

-- Server Hopping Utility
local function ServerHop()
    SendNotification("Server Hop", "No targets found. Hopping to a new server...")
    task.wait(1.5)
    pcall(function()
        local servers = {}
        local req = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        local body = HttpService:JSONDecode(req)
        if body and body.data then
            for _, s in ipairs(body.data) do
                if type(s) == "table" and s.maxPlayers and s.playing and s.playing < s.maxPlayers and s.id ~= game.JobId then
                    table.insert(servers, s.id)
                end
            end
        end
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end)
end

-- Get Blox Fruits Combat Remote Hook
local function GetCombatRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
    return remotes:FindFirstChild("Validator") or remotes:FindFirstChild("CommF_") or remotes:FindFirstChild("RegisterHit")
end

-- Find Closest Target
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

-- Main Configuration UI Hub Interface
LaunchHubInterface = function()
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "KenHubAllInOneUI"
    MainGui.ResetOnSpawn = false
    pcall(function() MainGui.Parent = CoreGui end)

    local MainContainer = Instance.new("Frame")
    MainContainer.Size = UDim2.new(0, 480, 0, 340)
    MainContainer.Position = UDim2.new(0.5, -240, 0.5, -170)
    MainContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    MainContainer.Parent = MainGui
    Instance.new("UICorner", MainContainer).CornerRadius = UDim.new(0, 12)

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 44)
    TopBar.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    TopBar.Parent = MainContainer
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 300, 1, 0)
    Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Ken Hub — <font color='#a855f7'>All-In-One Nexus Suite</font>"
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
        if FOVCircle then pcall(function() FOVCircle:Remove() end) end
        MainGui:Destroy()
    end)

    local ScrollPanel = Instance.new("ScrollingFrame")
    ScrollPanel.Size = UDim2.new(1, -20, 1, -56)
    ScrollPanel.Position = UDim2.new(0, 10, 0, 50)
    ScrollPanel.BackgroundTransparency = 1
    ScrollPanel.CanvasSize = UDim2.new(0, 0, 0, 300)
    ScrollPanel.ScrollBarThickness = 3
    ScrollPanel.Parent = MainContainer

    local UIList = Instance.new("UIListLayout")
    UIList.Parent = ScrollPanel
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 8)

    local function AddToggle(labelText, defaultVal, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -6, 0, 36)
        b.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
        b.Font = Enum.Font.GothamMedium
        b.Text = "  " .. labelText
        b.TextColor3 = Color3.fromRGB(180, 180, 195)
        b.TextSize = 12
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.Parent = ScrollPanel
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

    AddToggle("Auto Bounty Engine", Config.AutoBounty, function(v) 
        Config.AutoBounty = v 
        SendNotification("Nexus AI", v and "Auto Bounty started!" : "Auto Bounty paused.")
    end)
    AddToggle("Server Hop When No Targets", Config.ServerHopWhenNoTargets, function(v) Config.ServerHopWhenNoTargets = v end)
    AddToggle("SafeZone Low Health Escape", Config.SafeZone.Enable, function(v) Config.SafeZone.Enable = v end)
    AddToggle("Chat Spammer Flex", Config.ChatSpam.Enabled, function(v) Config.ChatSpam.Enabled = v end)
    AddToggle("Player Aimbot Assist", Config.PlayerAimbot, function(v) Config.PlayerAimbot = v end)
end

-- Background Worker Loops (Auto Bounty & Damage Routing)
task.spawn(function()
    while task.wait(0.25) do
        if getgenv().KenVerified then
            pcall(function()
                if Config.AutoBounty then
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChild("Humanoid")
                    
                    if root and hum then
                        -- Low Health SafeZone Check
                        if Config.SafeZone.Enable and hum.Health <= Config.SafeZone.LowHealth then
                            root.CFrame = root.CFrame + Vector3.new(0, Config.SafeZone.TeleportY, 0)
                            task.wait(5)
                            return
                        end

                        -- Target Seeking & Damage Application
                        local target = GetClosestTarget()
                        if target and target.Character then
                            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
                            local tHum = target.Character:FindFirstChild("Humanoid")
                            
                            if tRoot and tHum and tHum.Health > 0 then
                                root.CFrame = tRoot.CFrame * CFrame.new(0, 10, 4)
                                Camera.CFrame = CFrame.new(Camera.CFrame.Position, tRoot.Position)
                                
                                local tool = char:FindFirstChildOfClass("Tool")
                                if tool then
                                    tool:Activate()
                                    local remote = GetCombatRemote()
                                    if remote and remote:IsA("RemoteEvent") then
                                        pcall(function()
                                            remote:FireServer(tRoot.Position, tool)
                                        end)
                                    end
                                end
                            else
                                if Config.ServerHopWhenNoTargets then
                                    ServerHop()
                                end
                            end
                        else
                            if Config.ServerHopWhenNoTargets then
                                ServerHop()
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Chat Spammer Daemon Worker
task.spawn(function()
    while task.wait(Config.ChatSpam.Delay) do
        if getgenv().KenVerified then
            pcall(function()
                if Config.ChatSpam.Enabled and Config.AutoBounty then
                    local list = Config.ChatSpam.List
                    local msg = list[math.random(1, #list)]
                    local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                    if chatRemote and chatRemote:FindFirstChild("SayMessageRequest") then
                        chatRemote.SayMessageRequest:FireServer(msg, "All")
                    end
                end
            end)
        end
    end
end)

-- Render Loop for Aimbot and FOV
RunService.RenderStepped:Connect(function()
    if not getgenv().KenVerified then return end

    pcall(function()
        if FOVCircle then
            if Config.FOVEnabled and Config.PlayerAimbot then
                FOVCircle.Visible = true
                FOVCircle.Radius = Config.FOVRadius
                FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
            else
                FOVCircle.Visible = false
            end
        end

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
end)

