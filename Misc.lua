local Script = getgenv().XanCC.Script
local UI = getgenv().XanCC.UI
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Client = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Connection = RunService.Heartbeat:Connect(function()
    if not Client.Character then return end
    local Root = Client.Character:FindFirstChild("HumanoidRootPart")
    local Hum = Client.Character:FindFirstChild("Humanoid")
    if not Root or not Hum then return end
    
    -- CFrame Speed
    if UI.Misc.Movement.CFrame.Enabled and Hum.MoveDirection.Magnitude > 0 then
        Root.CFrame = Root.CFrame + (Hum.MoveDirection * UI.Misc.Movement.CFrame.Speed)
    end
    
    -- Velocity Speed
    if UI.Misc.Movement.Velocity.Enabled and Hum.MoveDirection.Magnitude > 0 then
        Root.Velocity = Vector3.new(
            Hum.MoveDirection.X * UI.Misc.Movement.Velocity.Speed,
            Root.Velocity.Y,
            Hum.MoveDirection.Z * UI.Misc.Movement.Velocity.Speed
        )
    end
    
    -- Fly
    if UI.Misc.Movement.Fly.Enabled then
        local Dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then Dir = Dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then Dir = Dir - Camera.CFrame.LookVector end
        if Dir.Magnitude > 0 then
            Root.Velocity = Dir.Unit * UI.Misc.Movement.Fly.Speed
        else
            Root.Velocity = Vector3.zero
        end
    end
end)
table.insert(Script.Connections, Connection)
