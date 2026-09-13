lua
getgenv().AutoBountyConfig = {
    Team = "Pirates",
    Settings = {
        SpectateTarget = false,
        ESPTarget = true,
        CameraLock = true,
        BigHitbox = true,
        BypassTeleport = true,
        SkipV4Player = true,
        SkipFruit = {"Portal-Portal", "Buddha-Buddha", "Kitsune-Kitsune", "Dragon-Dragon", "Pain-Pain", "Ice-Ice", 'Dough-Dough', "T-Rex-T-Rex", "Yeti-Yeti"},
        LowHealth = {
            Min = 4000,
            Max = 6000,
        },
        Others = {
            AutoAwakeningV4 = true,
            AutoTurnRaceV3 = true,
            AutoKen = true,
        },
    },
    Weapon = {
        Melee = {
            Enabled = true,
            Delay = 0.1,
            Skills = {
                Z = {Enabled = true, Hold = 0},
                X = {Enabled = true, Hold = 0},
                C = {Enabled = true, Hold = 0},
            },
        },
        Sword = {
            Enabled = true,
            Delay = 0.1,
            Skills = {
                Z = {Enabled = true, Hold = 0},
                X = {Enabled = true, Hold = 0},
            },
        },
        Gun = {
            Enabled = true,
            Delay = 0.1,
            Skills = {
                Z = {Enabled = true, Hold = 0},
                X = {Enabled = true, Hold = 0},
            },
        },
        ["Blox Fruit"] = {
            Enabled = true,
            Delay = 0.1,
            Skills = {
                Z = {Enabled = true, Hold = 0},
                X = {Enabled = true, Hold = 0},
                C = {Enabled = true, Hold = 0},
                V = {Enabled = false, Hold = 0},
                F = {Enabled = true, Hold = 0},
            },
        },
    },
    Server = {
        StopAtBounty = 0,
        HopDelay = 5,
        HopCooldown = 15,
    },
    Webhook = {
        Enabled = false, -- Not working now.
        Url = ""
    },
}
repeat wait() until game:IsLoaded()
