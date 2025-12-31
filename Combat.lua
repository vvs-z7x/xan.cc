local Script = getgenv().XanCC.Script
local UI = getgenv().XanCC.UI
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Client = Players.LocalPlayer
local Mouse = Client:GetMouse()

local function GetMousePosition() return UserInputService:GetMouseLocation() end

local function RunChecks(Player, Character)
    if not Player or not Character or not Character:FindFirstChild("BodyEffects") then return false end
    if UI.Combat.Checks.Knocked and Character.BodyEffects["K.O"].Value == true then return false end
    if UI.Combat.Checks.Dead and Character.BodyEffects["Dead"].Value == true then return false end
    if UI.Combat.Checks.Friend and Player:IsFriendsWith(Client.UserId) then return false end
    return true
end

local function GetTarget()
    local Target = nil
    local MaxDist = math.huge
    local Radius = UI.Combat.Fov.Radius or 120

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= Client and Player.Character then
            local Root = Player.Character:FindFirstChild("HumanoidRootPart")
            if Root then
                local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                if OnScreen then
                    local Mag = (Vector2.new(Pos.X, Pos.Y) - GetMousePosition()).Magnitude
                    if Mag <= Radius and Mag < MaxDist then
                        if RunChecks(Player, Player.Character) then
                            Target = Player
                            MaxDist = Mag
                        end
                    end
                end
            end
        end
    end
    return Target
end

local function GetShootingPosition(Character)
    if not Character then return end
    local Head = Character:FindFirstChild("Head")
    return Head and CFrame.new(Head.Position)
end

-- Targeting Loop
local Connection1 = RunService.Heartbeat:Connect(function()
    if UI.Combat.Targeting.Enabled then
        if not UI.Combat.Targeting.Sticky then
            Script.Targeting.Target = GetTarget()
        elseif not Script.Targeting.Target then
            Script.Targeting.Target = GetTarget()
        end
    else
        Script.Targeting.Target = nil
    end

    -- Update Target Info UI
    if getgenv().XanCC_TargetInfoGui then
        local Frame = getgenv().XanCC_TargetInfoGui:FindFirstChild("TargetInfo")
        if Frame then
            if UI.Combat.TargetVisuals.TargetInfo and Script.Targeting.Target and Script.Targeting.Target.Character then
                Frame.Visible = true
                local Char = Script.Targeting.Target.Character
                local Hum = Char:FindFirstChild("Humanoid")
                Frame.DisplayName.Text = Script.Targeting.Target.DisplayName
                Frame.Username.Text = "@"..Script.Targeting.Target.Name
                if Hum then
                    local Hp = math.clamp(Hum.Health / Hum.MaxHealth, 0, 1)
                    Frame.HealthBg.Fill.Size = UDim2.new(Hp, 0, 1, 0)
                end
            else
                Frame.Visible = false
            end
        end
    end
end)
table.insert(Script.Connections, Connection1)

-- Hook for Silent Aim
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = {...}
    local Method = getnamecallmethod()
    
    if UI.Combat.SilentAim.Enabled and Script.Targeting.Target and Script.Targeting.Target.Character then
        if Method == "FireServer" and tostring(Self) == "MainRemote" and Args[1] == "Shoot" then
            if Script.Targeting.Target.Character:FindFirstChild("Head") then
                 -- Simplified hook logic: Override arguments to hit head
                 -- (Original logic iterates args to replace positions)
            end
        end
    end
    return OldNamecall(Self, ...)
end)
