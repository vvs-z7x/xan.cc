local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Client = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = getgenv().XanCC.Settings

RunService.Heartbeat:Connect(function()
    if not Client.Character then return end
    local Root = Client.Character:FindFirstChild("HumanoidRootPart")
    local Hum = Client.Character:FindFirstChild("Humanoid")
    
    if not Root or not Hum then return end
    
    -- [CFrame Speed]
    if Settings.Misc.Movement.CFrame.Enabled then
        if Hum.MoveDirection.Magnitude > 0 then
            Root.CFrame = Root.CFrame + (Hum.MoveDirection * Settings.Misc.Movement.CFrame.Speed)
        end
    end
    
    -- [Velocity Speed]
    if Settings.Misc.Movement.Velocity.Enabled then
        if Hum.MoveDirection.Magnitude > 0 then
            Root.Velocity = Vector3.new(
                Hum.MoveDirection.X * Settings.Misc.Movement.Velocity.Speed,
                Root.Velocity.Y,
                Hum.MoveDirection.Z * Settings.Misc.Movement.Velocity.Speed
            )
        end
    end
    
    -- [Anti-Slow]
    if Settings.Misc.Client.AntiSlow and Hum.WalkSpeed < 16 then
        Hum.WalkSpeed = 16
    end
    
    -- [Anti-Jump Cooldown] (Handled via NewIndex hook usually, or simply:)
    if Settings.Misc.Client.AntiJumpCooldown then
        -- Logic often requires hook, but simple implementation:
        if Hum.JumpPower < 50 then Hum.JumpPower = 50 end
    end
end)
