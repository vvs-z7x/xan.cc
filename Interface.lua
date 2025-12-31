local Library = getgenv().XanCC.Library
local Settings = getgenv().XanCC.Settings

local Window = Library:Window({Name = "xan.cc", Size = UDim2.new(0, 550, 0, 400)})

-- [Combat Tab]
local Combat = Window:Page({Name = "Combat"})
local TargetSect = Combat:Section({Name = "Targeting"})

TargetSect:Toggle({Name = "Enable Targeting", Default = Settings.Combat.Targeting.Enabled, Callback = function(v) 
    Settings.Combat.Targeting.Enabled = v 
end}):Keybind({Default = Enum.KeyCode.C})

TargetSect:Toggle({Name = "Sticky Aim", Default = Settings.Combat.Targeting.Sticky, Callback = function(v)
    Settings.Combat.Targeting.Sticky = v
end})

local LegitSect = Combat:Section({Name = "Legitbot"})
LegitSect:Toggle({Name = "Enable Legitbot", Default = Settings.Combat.Legitbot.Enabled, Callback = function(v)
    Settings.Combat.Legitbot.Enabled = v
end})
LegitSect:Slider({Name = "Smoothness", Min = 0, Max = 1, Default = Settings.Combat.Legitbot.Smoothness, Callback = function(v)
    Settings.Combat.Legitbot.Smoothness = v
end})

local SilentSect = Combat:Section({Name = "Silent Aim"})
SilentSect:Toggle({Name = "Enable Silent Aim", Default = Settings.Combat.SilentAim.Enabled, Callback = function(v)
    Settings.Combat.SilentAim.Enabled = v
end})
SilentSect:Toggle({Name = "Double Tap", Default = Settings.Combat.SilentAim.DoubleTap, Callback = function(v)
    Settings.Combat.SilentAim.DoubleTap = v
end})

-- [Visuals Tab]
local Visuals = Window:Page({Name = "Visuals"})
local EspSect = Visuals:Section({Name = "ESP"})

EspSect:Toggle({Name = "Enabled", Default = Settings.Visuals.ESP.Enabled, Callback = function(v)
    Settings.Visuals.ESP.Enabled = v
end})
EspSect:Toggle({Name = "Boxes", Default = Settings.Visuals.ESP.Box.Enabled, Callback = function(v)
    Settings.Visuals.ESP.Box.Enabled = v
end})
EspSect:Toggle({Name = "Names", Default = Settings.Visuals.ESP.Name.Enabled, Callback = function(v)
    Settings.Visuals.ESP.Name.Enabled = v
end})

local TracerSect = Visuals:Section({Name = "Tracers"})
TracerSect:Toggle({Name = "Enabled", Default = Settings.Visuals.BulletTracer.Enabled, Callback = function(v)
    Settings.Visuals.BulletTracer.Enabled = v
end})

-- [Misc Tab]
local Misc = Window:Page({Name = "Misc"})
local SpeedSect = Misc:Section({Name = "Movement"})

SpeedSect:Toggle({Name = "CFrame Speed", Default = Settings.Misc.Movement.CFrame.Enabled, Callback = function(v)
    Settings.Misc.Movement.CFrame.Enabled = v
end}):Keybind({Default = Enum.KeyCode.X})

SpeedSect:Slider({Name = "Speed Amount", Min = 0, Max = 10, Default = Settings.Misc.Movement.CFrame.Speed, Callback = function(v)
    Settings.Misc.Movement.CFrame.Speed = v
end})

-- [Settings Tab]
local SettingsPage = Window:Page({Name = "Settings"})
local MenuSect = SettingsPage:Section({Name = "Menu"})
MenuSect:Button({Name = "Unload", Callback = function()
    getgenv().XanCC_Cleanup()
end})
MenuSect:Label({Name = "Accent Color"}):Colorpicker({Default = Settings.Theme.AccentColor, Callback = function(v)
    Library:ChangeTheme("Accent", v)
end})
