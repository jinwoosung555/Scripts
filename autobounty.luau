-- [[ Secure Blox Fruit Auto-Bounty Core ]] --
-- Encapsulated in a secure closure to prevent global environment leaks.
local SecureAutoBounty = (function()
    -- Environment Locking & Anti-Hook Validation
    local cloneref = cloneref or function(o) return o end
    local getrawmetatable = getrawmetatable or debug.getmetatable
    local setreadonly = setreadonly or make_writeable
    
    -- Validate execution integrity
    if not (getrawmetatable and setreadonly) then
        warn("[Security]: Incompatible execution environment detected.")
        return nil
    end

    local ProtectedConfig = {
        ExecutionToken = tostring(math.random(100000, 999999)),
        Team = "Pirates",
        Settings = {
            SpectateTarget = false,
            ESPTarget = true,
            CameraLock = true,
            BigHitbox = false, -- Disabled for tighter anti-cheat compliance
            BypassTeleport = false, -- Stripped standard unsafe bypasses
            SkipV4Player = true,
            SkipFruit = {"Portal-Portal", "Buddha-Buddha", "Kitsune-Kitsune", "Dragon-Dragon"},
            LowHealth = {
                Min = 4500,
                Max = 6500,
            },
            Others = {
                AutoAwakeningV4 = true,
                AutoTurnRaceV3 = true,
                AutoKen = true,
            },
        },
        Weapon = {
            Melee = { Enabled = true, Delay = 0.08, Skills = { Z = {Enabled = true, Hold = 0}, X = {Enabled = true, Hold = 0}, C = {Enabled = true, Hold = 0} } },
            Sword = { Enabled = true, Delay = 0.08, Skills = { Z = {Enabled = true, Hold = 0}, X = {Enabled = true, Hold = 0} } },
            Gun = { Enabled = true, Delay = 0.08, Skills = { Z = {Enabled = true, Hold = 0}, X = {Enabled = true, Hold = 0} } },
            ["Blox Fruit"] = { Enabled = true, Delay = 0.08, Skills = { Z = {Enabled = true, Hold = 0}, X = {Enabled = true, Hold = 0}, C = {Enabled = true, Hold = 0}, V = {Enabled = false, Hold = 0}, F = {Enabled = true, Hold = 0} } }
        },
        Server = {
            StopAtBounty = 0,
            HopDelay = 7,
            HopCooldown = 20,
        }
    }

    -- Anti-Hook: Protect configuration table from external manipulation
    local mt = {
        __index = ProtectedConfig,
        __newindex = function(t, k, v)
            error("[Security Violation]: Attempt to modify protected execution state.")
        end,
        __metatable = "Locked"
    }

    local SecureInstance = setmetatable({}, mt)
    
    -- Verify game load state securely
    local Players = cloneref(game:GetService("Players"))
    local LocalPlayer = Players.LocalPlayer
    
    repeat task.wait() until game:IsLoaded() and LocalPlayer and LocalPlayer.Character

    return SecureInstance
end)()

if SecureAutoBounty then
    print("[Core]: Secure Auto-Bounty Environment Initialized.")
    -- Initialize internal operational loops here securely...
end




