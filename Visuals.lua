local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Client = Players.LocalPlayer

local Settings = getgenv().XanCC.Settings
local Data = getgenv().XanCC.Data
local Drawings = getgenv().XanCC.Drawings

-- [Bullet Tracers]
local function CreateTracer(Start, End)
    if not Settings.Visuals.BulletTracer.Enabled then return end
    local Part = Instance.new("Part", workspace)
    Part.Anchored = true
    Part.CanCollide = false
    Part.Transparency = 1
    Part.Position = Start
    
    local Att0 = Instance.new("Attachment", Part)
    local Att1 = Instance.new("Attachment", Part)
    Att1.WorldPosition = End
    
    local Beam = Instance.new("Beam", Part)
    Beam.Attachment0 = Att0
    Beam.Attachment1 = Att1
    Beam.Color = ColorSequence.new(Settings.Visuals.BulletTracer.Color)
    Beam.Width0 = 0.5
    Beam.Width1 = 0.5
    Beam.FaceCamera = true
    
    game:GetService("Debris"):AddItem(Part, Settings.Visuals.BulletTracer.FadeTime)
end

-- Hook into FireServer for tracers (handled via hook in Loader, calls this if exposed, or we replicate hook here)
-- For simplicity in refactor, we rely on the hooks observing state.

-- [ESP System]
local function CreateDrawing(Type, Props)
    local Obj = Drawing.new(Type)
    for K, V in pairs(Props) do Obj[K] = V end
    table.insert(Drawings, Obj)
    return Obj
end

local ESPObjects = {}

local function UpdateESP()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= Client then
            if not ESPObjects[Player] then
                ESPObjects[Player] = {
                    Box = CreateDrawing("Square", {Thickness = 1, Color = Color3.new(1,1,1), Filled = false}),
                    Name = CreateDrawing("Text", {Size = 13, Center = true, Outline = true, Color = Color3.new(1,1,1)})
                }
            end
            
            local Objs = ESPObjects[Player]
            local Char = Player.Character
            local Root = Char and Char:FindFirstChild("HumanoidRootPart")
            
            if Settings.Visuals.ESP.Enabled and Char and Root then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                if OnScreen then
                    -- Simple Box Math
                    local Size = 2500 / ScreenPos.Z
                    Objs.Box.Visible = Settings.Visuals.ESP.Box.Enabled
                    Objs.Box.Size = Vector2.new(Size * 0.7, Size)
                    Objs.Box.Position = Vector2.new(ScreenPos.X - Size*0.35, ScreenPos.Y - Size*0.5)
                    Objs.Box.Color = Settings.Visuals.ESP.Box.Color
                    
                    Objs.Name.Visible = Settings.Visuals.ESP.Name.Enabled
                    Objs.Name.Position = Vector2.new(ScreenPos.X, ScreenPos.Y - Size*0.5 - 15)
                    Objs.Name.Text = Player.Name
                else
                    Objs.Box.Visible = false
                    Objs.Name.Visible = false
                end
            else
                Objs.Box.Visible = false
                Objs.Name.Visible = false
            end
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

-- [Target Info UI]
-- Logic to update the TargetInfo GUI created in Loader
RunService.RenderStepped:Connect(function()
    local Gui = getgenv().XanCC.TargetInfoGui
    if Gui and Gui:FindFirstChild("TargetInfo") then
        local Frame = Gui.TargetInfo
        if Settings.Combat.TargetVisuals.TargetInfo and Data.Target then
            Frame.Visible = true
            -- Update logic here (Name, Health)
            local Char = Data.Target.Character
            local Hum = Char and Char:FindFirstChild("Humanoid")
            if Frame:FindFirstChild("DisplayName") then Frame.DisplayName.Text = Data.Target.DisplayName end
            -- Additional UI updates...
        else
            Frame.Visible = false
        end
    end
end)
