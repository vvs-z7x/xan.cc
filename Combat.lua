local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Client = Players.LocalPlayer
local Mouse = Client:GetMouse()

local Settings = getgenv().XanCC.Settings
local Data = getgenv().XanCC.Data
local Functions = {}

-- [Helpers]
local function GetMousePosition() return UserInputService:GetMouseLocation() end

function Functions.IsVulnerable(Character)
    if not Character then return false end
    local BodyEffects = Character:FindFirstChild("BodyEffects")
    if not BodyEffects then return false end
    local Eating = BodyEffects:FindFirstChild("eating/drinking")
    local Reload = BodyEffects:FindFirstChild("Reload")
    return (Eating and Eating.Value) or (Reload and Reload.Value)
end

function Functions.RunChecks(Player, Character)
    if not Character or not Character:FindFirstChild("BodyEffects") then return false end
    if Settings.Combat.Checks.Knocked and Character.BodyEffects["K.O"].Value then return false end
    if Settings.Combat.Checks.Dead and Character.BodyEffects["Dead"].Value then return false end
    if Settings.Combat.Checks.Grabbed and Character.BodyEffects["Grabbed"].Value then return false end
    if Settings.Combat.Checks.Friend and Player:IsFriendsWith(Client.UserId) then return false end
    if Settings.Combat.Checks.Forcefield and Character:FindFirstChildWhichIsA("ForceField") then return false end
    return true
end

function Functions.GetTarget()
    local Target = nil
    local MinDist = math.huge
    local Radius = Settings.Combat.Fov.Radius

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= Client and Player.Character then
            local Root = Player.Character:FindFirstChild("HumanoidRootPart")
            if Root then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                if OnScreen then
                    local Mag = (Vector2.new(ScreenPos.X, ScreenPos.Y) - GetMousePosition()).Magnitude
                    if Mag <= Radius and Mag < MinDist then
                        if Functions.RunChecks(Player, Player.Character) then
                            Target = Player
                            MinDist = Mag
                        end
                    end
                end
            end
        end
    end
    return Target
end

-- [Main Loops]
RunService.Heartbeat:Connect(function()
    if Settings.Combat.Targeting.Enabled then
        if not Settings.Combat.Targeting.Sticky then
            Data.Target = Functions.GetTarget()
        elseif not Data.Target then
            Data.Target = Functions.GetTarget()
        end
    else
        Data.Target = nil
    end
    
    -- Target Info Logic (Signal to Visuals)
    if Data.Target and Settings.Combat.TargetVisuals.Highlight then
        -- Logic handled in Visuals via Data.Target check
    end
end)

RunService.RenderStepped:Connect(function()
    -- Legitbot (Camlock)
    if Settings.Combat.Legitbot.Enabled and Data.Target and Data.Target.Character then
        local Part = Data.Target.Character:FindFirstChild("Head") -- Simplified
        if Part then
            local Pos = Part.Position
            if Settings.Combat.Legitbot.PredictionEnabled then
                Pos = Pos + (Part.AssemblyLinearVelocity * Settings.Combat.Legitbot.PredictionValue)
            end
            local Goal = CFrame.lookAt(Camera.CFrame.Position, Pos)
            Camera.CFrame = Camera.CFrame:Lerp(Goal, Settings.Combat.Legitbot.Smoothness)
        end
    end
end)

-- [Hooks Setup]
-- Note: Hooks logic is complex and relies on the AC bypass in Loader.
-- We attach function overrides here if needed, but main hooks usually reside in Loader or are set up once.
-- Ideally, silent aim hook logic should check Settings.Combat.SilentAim.Enabled

return Functions
