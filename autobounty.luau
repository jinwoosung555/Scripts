--[========================================================================--
--   KEN HUB — ULTIMATE ALL-IN-ONE AUTO BOUNTY ENGINE (v11.0)              --
--   Native Combat Framework Hook, Fast Attack, & Auto Server Hop          --
--[========================================================================--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global Configuration Settings
local Config = {
    ServerHopWhenNoTargets = true,
    SafeZoneHealth = 2000,
    SafeZoneY = 600,
    FastAttackSpeed = 0.05
}

-- Blox Fruits Native Combat Framework Hook
local CombatController = nil
pcall(function()
    for _, v in ipairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "activeController") then
            CombatController = v.activeController
            break
        end
    end
end)

-- Server Hopping Utility
local function ServerHop()
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

-- Closest Player Target Finder
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

-- Fast Attack & Combat Execution Loop
task.spawn(function()
    while task.wait(Config.FastAttackSpeed) do
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            
            if root and hum then
                -- Safezone low health emergency escape
                if hum.Health <= Config.SafeZoneHealth then
                    root.CFrame = root.CFrame + Vector3.new(0, Config.SafeZoneY, 0)
                    task.wait(5)
                    return
                end

                local target = GetClosestTarget()
                if target and target.Character then
                    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
                    local tHum = target.Character:FindFirstChild("Humanoid")
                    
                    if tRoot and tHum and tHum.Health > 0 then
                        -- Maintain optimal PvP attack position
                        root.CFrame = tRoot.CFrame * CFrame.new(0, 6, 2)
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, tRoot.Position)
                        
                        -- Equip and activate active tool weapon
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then
                            if tool.Parent ~= char then
                                tool.Parent = char
                            end
                            tool:Activate()
                            
                            -- Force trigger framework attack instance if available
                            if CombatController and CombatController.attack then
                                pcall(function()
                                    CombatController:attack()
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
        end)
    end
end)



