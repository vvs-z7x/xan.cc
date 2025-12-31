local Library = getgenv().XanCC.Library
local Settings = getgenv().XanCC.UI
local Toggles = getgenv().XanCC.Script.Toggles
local CoreGui = game:GetService("CoreGui")

local Window = Library:Window({Name = "xan.cc", PageAmmount = 5})
local CombatTab = Window:Page({Name = "Combat", Columns = 2})
local PlayerTab = Window:Page({Name = "Player", Columns = 2})
local VisualsTab = Window:Page({Name = "Visuals", Columns = 2})
local SettingsTab = Window:Page({Name = "Settings", Columns = 2})

-- [Combat]
local TargetingSection = CombatTab:Section({Name = "Targeting", Side = 1})
TargetingSection:Toggle({Name = "Enable", Default = Settings.Combat.Targeting.Enabled, Callback = function(v) Settings.Combat.Targeting.Enabled = v end})
TargetingSection:Toggle({Name = "Sticky", Default = Settings.Combat.Targeting.Sticky, Callback = function(v) Settings.Combat.Targeting.Sticky = v end})
TargetingSection:Toggle({Name = "Target Info", Default = Settings.Combat.TargetVisuals.TargetInfo, Callback = function(v) Settings.Combat.TargetVisuals.TargetInfo = v end})

local LegitSection = CombatTab:Section({Name = "Legitbot", Side = 1})
LegitSection:Toggle({Name = "Enable", Default = Settings.Combat.Legitbot.Enabled, Callback = function(v) Settings.Combat.Legitbot.Enabled = v end})
LegitSection:Slider({Name = "Smoothness", Min = 0, Max = 1, Default = Settings.Combat.Legitbot.Smoothness, Decimals = 0.01, Callback = function(v) Settings.Combat.Legitbot.Smoothness = v end})

local SilentSection = CombatTab:Section({Name = "Silent Aim", Side = 2})
SilentSection:Toggle({Name = "Enable", Default = Settings.Combat.SilentAim.Enabled, Callback = function(v) Settings.Combat.SilentAim.Enabled = v end})
SilentSection:Toggle({Name = "Force Hit", Default = Settings.Combat.SilentAim.ForceHit, Callback = function(v) Settings.Combat.SilentAim.ForceHit = v end})

local FovSection = CombatTab:Section({Name = "FOV", Side = 2})
FovSection:Toggle({Name = "Show FOV", Default = Settings.Combat.Fov.Visible, Callback = function(v) Settings.Combat.Fov.Visible = v end})
FovSection:Slider({Name = "Radius", Min = 10, Max = 500, Default = 120, Callback = function(v) Settings.Combat.Fov.Radius = v end})

-- [Visuals]
local EspSection = VisualsTab:Section({Name = "ESP", Side = 1})
EspSection:Toggle({Name = "Enable", Default = Settings.Visuals.ESP.Enabled, Callback = function(v) Settings.Visuals.ESP.Enabled = v end})
EspSection:Toggle({Name = "Boxes", Default = Settings.Visuals.ESP.Box.Enabled, Callback = function(v) Settings.Visuals.ESP.Box.Enabled = v end})
EspSection:Toggle({Name = "Names", Default = Settings.Visuals.ESP.Name.Enabled, Callback = function(v) Settings.Visuals.ESP.Name.Enabled = v end})

local TracerSection = VisualsTab:Section({Name = "Bullet Tracers", Side = 2})
TracerSection:Toggle({Name = "Enable", Default = Settings.Visuals.BulletTracer.Enabled, Callback = function(v) Settings.Visuals.BulletTracer.Enabled = v end})
TracerSection:Colorpicker({Name = "Color", Default = Settings.Visuals.BulletTracer.Color, Callback = function(v) Settings.Visuals.BulletTracer.Color = v end})

-- [Misc]
local MoveSection = PlayerTab:Section({Name = "Movement", Side = 1})
MoveSection:Toggle({Name = "Fly", Default = Settings.Misc.Movement.Fly.Enabled, Callback = function(v) Settings.Misc.Movement.Fly.Enabled = v end})
MoveSection:Slider({Name = "Fly Speed", Min = 10, Max = 200, Default = Settings.Misc.Movement.Fly.Speed, Callback = function(v) Settings.Misc.Movement.Fly.Speed = v end})
MoveSection:Toggle({Name = "CFrame Speed", Default = Settings.Misc.Movement.CFrame.Enabled, Callback = function(v) Settings.Misc.Movement.CFrame.Enabled = v end})
MoveSection:Toggle({Name = "Velocity Speed", Default = Settings.Misc.Movement.Velocity.Enabled, Callback = function(v) Settings.Misc.Movement.Velocity.Enabled = v end})

-- [Settings]
local MenuSection = SettingsTab:Section({Name = "Menu", Side = 1})
MenuSection:Toggle({Name = "Accent Color", Default = true}):Colorpicker({Default = Settings.Settings.AccentColor, Callback = function(v)
    Settings.Settings.AccentColor = v
    Library:ChangeTheme("Accent", v)
    if getgenv().XanCC_TargetInfoGui then
        local Frame = getgenv().XanCC_TargetInfoGui:FindFirstChild("TargetInfo")
        if Frame then Frame.Accent.BackgroundColor3 = v end
    end
end})
MenuSection:Button({Name = "Unload", Callback = function() getgenv().XanCC_Cleanup() end})

-- Target Info GUI Construction
local TargetInfoGui = Instance.new("ScreenGui")
TargetInfoGui.Name = "XanTargetInfo"
TargetInfoGui.Parent = CoreGui
getgenv().XanCC_TargetInfoGui = TargetInfoGui

local TIFrame = Instance.new("Frame", TargetInfoGui)
TIFrame.Name = "TargetInfo"
TIFrame.Size = UDim2.new(0, 240, 0, 90)
TIFrame.Position = UDim2.new(0.5, 0, 0.7, 0)
TIFrame.BackgroundColor3 = Color3.fromRGB(15,15,15)
TIFrame.BorderColor3 = Color3.fromRGB(10,10,10)
TIFrame.BorderSizePixel = 2
TIFrame.Visible = false
-- Make Draggable
local Drag = Instance.new("UIDragDetector", TIFrame)

local TIAccent = Instance.new("Frame", TIFrame)
TIAccent.Name = "Accent"
TIAccent.Size = UDim2.new(1,0,0,2)
TIAccent.BackgroundColor3 = Settings.Settings.AccentColor
TIAccent.BorderSizePixel = 0

local TIName = Instance.new("TextLabel", TIFrame)
TIName.Name = "DisplayName"
TIName.Text = "Target"
TIName.Size = UDim2.new(1, -20, 0, 20)
TIName.Position = UDim2.new(0, 78, 0, 12)
TIName.BackgroundTransparency = 1
TIName.TextColor3 = Color3.fromRGB(215,215,215)
TIName.Font = Enum.Font.GothamBold
TIName.TextSize = 14
TIName.TextXAlignment = Enum.TextXAlignment.Left

local TIUser = Instance.new("TextLabel", TIFrame)
TIUser.Name = "Username"
TIUser.Text = "@user"
TIUser.Size = UDim2.new(1, -20, 0, 20)
TIUser.Position = UDim2.new(0, 78, 0, 29)
TIUser.BackgroundTransparency = 1
TIUser.TextColor3 = Color3.fromRGB(120,120,120)
TIUser.Font = Enum.Font.Gotham
TIUser.TextSize = 11
TIUser.TextXAlignment = Enum.TextXAlignment.Left

local TIHealthBg = Instance.new("Frame", TIFrame)
TIHealthBg.Name = "HealthBg"
TIHealthBg.BackgroundColor3 = Color3.fromRGB(25,25,25)
TIHealthBg.BorderColor3 = Color3.fromRGB(10,10,10)
TIHealthBg.Position = UDim2.new(0, 78, 0, 48)
TIHealthBg.Size = UDim2.new(1, -88, 0, 12)

local TIHealthFill = Instance.new("Frame", TIHealthBg)
TIHealthFill.Name = "Fill"
TIHealthFill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
TIHealthFill.BorderSizePixel = 0
TIHealthFill.Size = UDim2.new(1, 0, 1, 0)
