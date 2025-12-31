local Script = getgenv().XanCC.Script
local UI = getgenv().XanCC.UI
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Client = Players.LocalPlayer

-- Bullet Tracers Logic
local function CreateTracer(Start, End)
    if not UI.Visuals.BulletTracer.Enabled then return end
    local Part = Instance.new("Part", workspace)
    Part.Anchored = true; Part.CanCollide = false; Part.Transparency = 1
    Part.Position = Start
    local Att0 = Instance.new("Attachment", Part); local Att1 = Instance.new("Attachment", Part)
    Att1.WorldPosition = End
    local Beam = Instance.new("Beam", Part); Beam.Attachment0 = Att0; Beam.Attachment1 = Att1
    Beam.Color = ColorSequence.new(UI.Visuals.BulletTracer.Color); Beam.FaceCamera = true; Beam.Width0 = 0.5; Beam.Width1 = 0.5
    game:GetService("Debris"):AddItem(Part, UI.Visuals.BulletTracer.FadeTime)
end

-- ESP Logic
local ESPDrawings = {}

local function UpdateESP()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= Client then
            if not ESPDrawings[Player] then
                ESPDrawings[Player] = {
                    Box = Drawing.new("Square"),
                    Name = Drawing.new("Text")
                }
                ESPDrawings[Player].Name.Center = true
            end
            
            local Objs = ESPDrawings[Player]
            local Char = Player.Character
            local Root = Char and Char:FindFirstChild("HumanoidRootPart")
            
            if UI.Visuals.ESP.Enabled and Char and Root then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
                if OnScreen then
                    local Dist = (Camera.CFrame.Position - Root.Position).Magnitude
                    local Size = 2500 / Dist
                    
                    Objs.Box.Visible = UI.Visuals.ESP.Box.Enabled
                    Objs.Box.Size = Vector2.new(Size * 0.7, Size)
                    Objs.Box.Position = Vector2.new(ScreenPos.X - (Size*0.35), ScreenPos.Y - (Size*0.5))
                    Objs.Box.Color = UI.Visuals.ESP.Box.Color
                    Objs.Box.Thickness = 1
                    
                    Objs.Name.Visible = UI.Visuals.ESP.Name.Enabled
                    Objs.Name.Text = Player.Name
                    Objs.Name.Position = Vector2.new(ScreenPos.X, ScreenPos.Y - (Size*0.5) - 15)
                    Objs.Name.Color = UI.Visuals.ESP.Name.Color
                else
                    Objs.Box.Visible = false; Objs.Name.Visible = false
                end
            else
                Objs.Box.Visible = false; Objs.Name.Visible = false
            end
        end
    end
end

local Connection = RunService.RenderStepped:Connect(UpdateESP)
table.insert(Script.Connections, Connection)
