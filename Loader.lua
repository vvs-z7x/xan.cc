--[[
    xan.cc - Loader
    Author: 02fg (Refactored)
    
    Instructions:
    1. Upload the other files (Library.lua, Combat.lua, etc.) to your GitHub.
    2. Change the 'RepoURL' variable below to your repository link.
]]

local RepoURL = "https://raw.githubusercontent.com/vvs-z7x/xan.cc/refs/heads/main/"

-- ======================= CLEANUP =======================
if getgenv().XanCC_Loaded then
    if getgenv().XanCC_Cleanup then getgenv().XanCC_Cleanup() end
    wait(0.1)
end

-- ======================= GLOBAL STATE =======================
getgenv().XanCC = {
    Loaded = true,
    Connections = {},
    Drawings = {},
    Hooks = {},
    
    -- Global Configuration Table (Shared across modules)
    Settings = {
        Combat = {
            Targeting = { Enabled = false, Sticky = false, Hitpoints = {"Head"} },
            Legitbot = { Enabled = false, PredictionEnabled = false, PredictionValue = 0.095, Smoothness = 2, JumpOffsetEnabled = false, JumpOffsetValue = 0 },
            SilentAim = { Enabled = false, ForceHit = false, DoubleTap = false, DoubleTapMode = "Activate", Manipulation = false, Prefire = false, PrefireSeconds = 3 },
            Fov = { StickTarget = false, StickBarrel = false, Visible = false, Radius = 120 },
            TargetVisuals = { Highlight = false, TargetText = false, TargetInfo = false, VulnerableColor = Color3.fromRGB(0, 255, 100) },
            Checks = { Knocked = false, Raycast = false, Friend = false, Forcefield = false, Grabbed = false, Dead = false },
            TargetStrafe = { Enabled = false, Distance = 10, Speed = 1, Height = 0, Random = false, SyncWithTarget = false, Return = false }
        },
        AntiAim = {
            ServerDesync = { Enabled = false, Mode = "Custom", Custom = { X=1, Y=1, Z=1, XX=1, YY=1, ZZ=1 } },
            VelocitySpoofer = { Enabled = false, Mode = "Random", Custom = { X=1, Y=1, Z=1, MinX=1, MaxX=1, MinY=1, MaxY=1, MinZ=1, MaxZ=1 } }
        },
        Misc = {
            Movement = { 
                Fly = { Enabled = false, Speed = 50 },
                CFrame = { Enabled = false, Speed = 1 },
                Velocity = { Enabled = false, Speed = 50 },
                Slippery = { Enabled = false, Speed = 50, Friction = 0.95 }
            },
            Client = { AntiJumpCooldown = false, AntiSlow = false, FaceBackwards = false, AntiStomp = false, AvatarChanger = { LoadOnDeath = false, Name = "" } }
        },
        Visuals = {
            BulletTracer = { Enabled = false, Color = Color3.fromRGB(198, 154, 196), Thickness = 2, FadeTime = 0.5, Rainbow = false },
            ESP = { 
                Enabled = false, TeamCheck = false, MaxDistance = 500,
                Box = { Enabled = false, Mode = "Normal", Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Fill = false, FillTransparency = 0.8 },
                HealthBar = { Enabled = false, Position = "Left" },
                ArmorBar = { Enabled = false, Position = "Right" },
                HeadCircle = { Enabled = false, Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Fill = false },
                Skeleton = { Enabled = false, Color = Color3.fromRGB(255, 255, 255), Thickness = 1 },
                Name = { Enabled = false, Color = Color3.fromRGB(255, 255, 255), ShowDisplayName = true },
                Distance = { Enabled = false, Color = Color3.fromRGB(200, 200, 200) },
                Chams = { Enabled = false, FillColor = Color3.fromRGB(198, 154, 196), OutlineColor = Color3.fromRGB(255, 255, 255), FillTransparency = 0.5, OutlineTransparency = 0 }
            }
        },
        Theme = { MenuKeybind = Enum.KeyCode.RightControl, AccentColor = Color3.fromRGB(198, 154, 196) }
    },
    
    -- Runtime Data (Shared across modules)
    Data = {
        Target = nil,
        Players = {},
        Esp = {},
        BulletTracers = {},
        Desync = {},
        Prefiretick = 0,
        StrafeAngle = 0,
        WasStrafing = false
    }
}

-- Cleanup Function
getgenv().XanCC_Cleanup = function()
    if getgenv().XanCC.Library then getgenv().XanCC.Library:Unload() end
    
    -- Restore Metatable Hooks
    if getgenv().XanCC_OldNamecall then
        setreadonly(getrawmetatable(game), false)
        getrawmetatable(game).__namecall = getgenv().XanCC_OldNamecall
        setreadonly(getrawmetatable(game), true)
    end
    if getgenv().XanCC_OldNewIndex then
        setreadonly(getrawmetatable(game), false)
        getrawmetatable(game).__newindex = getgenv().XanCC_OldNewIndex
        setreadonly(getrawmetatable(game), true)
    end

    for _, c in pairs(getgenv().XanCC.Connections) do pcall(function() c:Disconnect() end) end
    for _, d in pairs(getgenv().XanCC.Drawings) do pcall(function() d:Remove() end) end
    if getgenv().XanCC.TargetInfoGui then getgenv().XanCC.TargetInfoGui:Destroy() end
    
    getgenv().XanCC_Loaded = false
    getgenv().XanCC = nil
end

-- ======================= LOADER UI =======================
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LoaderGui = Instance.new("ScreenGui")
LoaderGui.Name = "XanLoader"
LoaderGui.Parent = CoreGui

local function CreateLoader()
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 280, 0, 140)
    Frame.Position = UDim2.new(0.5, -140, 0.5, -70)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Frame.BorderSizePixel = 0
    Frame.Parent = LoaderGui
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(27, 27, 27)
    Stroke.Thickness = 2
    Stroke.Parent = Frame

    local Accent = Instance.new("Frame")
    Accent.Size = UDim2.new(1, 0, 0, 2)
    Accent.BackgroundColor3 = Color3.fromRGB(198, 154, 196)
    Accent.BorderSizePixel = 0
    Accent.Parent = Frame

    local Title = Instance.new("TextLabel")
    Title.Text = "xan.cc"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 24
    Title.TextColor3 = Color3.fromRGB(198, 154, 196)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 15)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Parent = Frame

    local Status = Instance.new("TextLabel")
    Status.Text = "Initializing..."
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 11
    Status.TextColor3 = Color3.fromRGB(215, 215, 215)
    Status.BackgroundTransparency = 1
    Status.Position = UDim2.new(0, 15, 0, 70)
    Status.Size = UDim2.new(1, -30, 0, 15)
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.Parent = Frame

    local BarBg = Instance.new("Frame")
    BarBg.Size = UDim2.new(1, -30, 0, 16)
    BarBg.Position = UDim2.new(0, 15, 0, 95)
    BarBg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    BarBg.Parent = Frame
    
    local BarFill = Instance.new("Frame")
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = Color3.fromRGB(198, 154, 196)
    BarFill.BorderSizePixel = 0
    BarFill.Parent = BarBg

    return {
        Update = function(pct, text)
            Status.Text = text
            TweenService:Create(BarFill, TweenInfo.new(0.2), {Size = UDim2.new(pct/100, 0, 1, 0)}):Play()
        end,
        Destroy = function()
            TweenService:Create(Frame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
            wait(0.5)
            LoaderGui:Destroy()
        end
    }
end

local UI_Loader = CreateLoader()

-- ======================= AC BYPASS =======================
UI_Loader.Update(10, "Bypassing Anti-Cheat...")
if not getgenv().XanCC_ACBypassed then
    pcall(function() game:GetService("CorePackages").Packages:Destroy() end)
    
    local grm = getrawmetatable(game)
    setreadonly(grm, false)
    local old = grm.__namecall
    getgenv().XanCC_OldNamecall = old
    
    grm.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = tostring(args[1])
        local blocked = {"TeleportDetect", "CHECKER", "GUI_CHECK", "OneMoreTime", "checkingSPEED", "BANREMOTE", "PERMAIDBAN", "KICKREMOTE", "BR_KICKPC"}
        
        for _, block in pairs(blocked) do
            if method == block then return end
        end
        
        return old(self, ...)
    end)
    setreadonly(grm, true)
    getgenv().XanCC_ACBypassed = true
end
wait(0.2)

-- ======================= MODULE LOADING =======================
local function LoadModule(name)
    UI_Loader.Update(30, "Loading " .. name .. "...")
    local success, result = pcall(function()
        return loadstring(game:HttpGet(RepoURL .. name .. ".lua"))()
    end)
    if not success then 
        warn("Failed to load " .. name .. ": " .. tostring(result))
        return nil
    end
    return result
end

UI_Loader.Update(40, "Loading Library...")
getgenv().XanCC.Library = LoadModule("Library")

UI_Loader.Update(55, "Loading Visuals...")
LoadModule("Visuals")

UI_Loader.Update(70, "Loading Combat...")
LoadModule("Combat")

UI_Loader.Update(85, "Loading Misc...")
LoadModule("Misc")

-- ======================= INTERFACE =======================
UI_Loader.Update(95, "Building Interface...")
LoadModule("Interface")

UI_Loader.Update(100, "Done!")
wait(0.5)
UI_Loader.Destroy()
