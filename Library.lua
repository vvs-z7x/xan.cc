local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = game:GetService("CoreGui")

local Library = {
    Flags = {},
    Theme = {
        ["Background"] = Color3.fromRGB(15, 15, 15),
        ["Inline"] = Color3.fromRGB(20, 20, 20),
        ["Page Background"] = Color3.fromRGB(30, 30, 30),
        ["Border"] = Color3.fromRGB(10, 10, 10),
        ["Outline"] = Color3.fromRGB(27, 27, 27),
        ["Accent"] = Color3.fromRGB(198, 154, 196),
        ["Element"] = Color3.fromRGB(33, 33, 33),
        ["Hovered Element"] = Color3.fromRGB(40, 40, 40),
        ["Text"] = Color3.fromRGB(215, 215, 215),
        ["Text Border"] = Color3.fromRGB(0, 0, 0)
    },
    MenuKeybind = Enum.KeyCode.RightControl,
    Connections = {},
    Threads = {},
    ThemeItems = {},
    ThemeMap = {},
    SetFlags = {},
    UnnamedConnections = 0,
    UnnamedFlags = 0,
    Pages = {},
    Sections = {}
}

Library.__index = Library
Library.Sections.__index = Library.Sections
Library.Pages.__index = Library.Pages

-- [Utility Functions]
function Library:SafeCall(Func, ...)
    local Success, Result = pcall(Func, ...)
    if not Success then warn("[Library Error]:", Result) end
    return Success, Result
end

function Library:Connect(Event, Callback)
    local Conn = Event:Connect(Callback)
    table.insert(self.Connections, {Connection = Conn})
    return Conn
end

function Library:Unload()
    for _, V in pairs(self.Connections) do V.Connection:Disconnect() end
    if self.Holder then self.Holder:Destroy() end
end

function Library:Round(Number, Float)
    local Multiplier = 1 / (Float or 1)
    return math.floor(Number * Multiplier) / Multiplier
end

-- [Helper for creating Instances]
local function Create(Class, Properties)
    local Obj = Instance.new(Class)
    for K, V in pairs(Properties) do Obj[K] = V end
    return Obj
end

-- [Main Window Logic]
function Library:Window(Data)
    local Window = {
        Name = Data.Name or "Window",
        Size = Data.Size or UDim2.new(0, 500, 0, 600),
        Pages = {},
        IsOpen = true
    }
    setmetatable(Window, Library)

    self.Holder = Create("ScreenGui", { Name = "XanUI", Parent = CoreGui, ResetOnSpawn = false })
    
    local MainFrame = Create("Frame", {
        Name = "MainFrame", Parent = self.Holder,
        Size = Window.Size, Position = UDim2.new(0.5, -250, 0.5, -300),
        BackgroundColor3 = self.Theme.Background, BorderColor3 = self.Theme.Border, BorderSizePixel = 2
    })
    
    -- Dragging Logic
    local Dragging, DragInput, DragStart, StartPos
    MainFrame.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = Input.Position
            StartPos = MainFrame.Position
        end
    end)
    MainFrame.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = Input.Position - DragStart
            MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)

    -- Elements
    local Title = Create("TextLabel", {
        Parent = MainFrame, Text = Window.Name,
        Size = UDim2.new(1, -10, 0, 20), Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1, TextColor3 = self.Theme.Accent,
        Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
    })
    Window.Elements = {Title = Title}

    local Container = Create("Frame", {
        Parent = MainFrame, Size = UDim2.new(1, -14, 1, -30),
        Position = UDim2.new(0, 7, 0, 25), BackgroundColor3 = self.Theme.Inline,
        BorderColor3 = self.Theme.Outline
    })

    local PageContainer = Create("Frame", {
        Parent = Container, Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1
    })
    local PageLayout = Create("UIListLayout", { Parent = PageContainer, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5) })

    local ContentContainer = Create("Frame", {
        Parent = Container, Size = UDim2.new(1, 0, 1, -30),
        Position = UDim2.new(0, 0, 0, 30), BackgroundTransparency = 1
    })

    -- [Page System]
    function Window:Page(PageData)
        local Page = { Name = PageData.Name, Elements = {} }
        setmetatable(Page, Library.Pages)

        local Button = Create("TextButton", {
            Parent = PageContainer, Size = UDim2.new(0, 80, 1, 0),
            Text = Page.Name, BackgroundColor3 = Library.Theme["Page Background"],
            TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12
        })

        local PageFrame = Create("ScrollingFrame", {
            Parent = ContentContainer, Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 2
        })
        local ColLayout = Create("UIListLayout", { Parent = PageFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) })
        local Padding = Create("UIPadding", { Parent = PageFrame, PaddingLeft = UDim.new(0, 5), PaddingTop = UDim.new(0, 5) })

        Button.MouseButton1Click:Connect(function()
            for _, p in pairs(ContentContainer:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
            PageFrame.Visible = true
        end)

        if #ContentContainer:GetChildren() == 1 then PageFrame.Visible = true end -- Select first page

        function Page:Section(SectionData)
            local Section = { Name = SectionData.Name }
            setmetatable(Section, Library.Sections)
            
            local SectFrame = Create("Frame", {
                Parent = PageFrame, Size = UDim2.new(1, -10, 0, 30),
                AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Library.Theme.Background,
                BorderColor3 = Library.Theme.Border
            })
            Create("TextLabel", {
                Parent = SectFrame, Text = SectionData.Name, Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1, TextColor3 = Library.Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 12
            })
            local SectContent = Create("Frame", {
                Parent = SectFrame, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 20),
                AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1
            })
            local SectLayout = Create("UIListLayout", { Parent = SectContent, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) })
            Create("UIPadding", { Parent = SectContent, PaddingLeft = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5) })

            -- [Toggle]
            function Section:Toggle(Data)
                local Toggle = { Value = Data.Default or false }
                local TFrame = Create("Frame", { Parent = SectContent, Size = UDim2.new(1, -10, 0, 25), BackgroundTransparency = 1 })
                local TBtn = Create("TextButton", {
                    Parent = TFrame, Text = "", Size = UDim2.new(0, 15, 0, 15), Position = UDim2.new(0, 0, 0.5, -7.5),
                    BackgroundColor3 = Toggle.Value and Library.Theme.Accent or Library.Theme.Element
                })
                Create("TextLabel", {
                    Parent = TFrame, Text = Data.Name, Size = UDim2.new(1, -25, 1, 0), Position = UDim2.new(0, 25, 0, 0),
                    BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })

                local function Update()
                    Toggle.Value = not Toggle.Value
                    TBtn.BackgroundColor3 = Toggle.Value and Library.Theme.Accent or Library.Theme.Element
                    if Data.Callback then Data.Callback(Toggle.Value) end
                end
                
                TBtn.MouseButton1Click:Connect(Update)
                if Data.Default then if Data.Callback then Data.Callback(true) end end

                -- Extended Toggle functions
                function Toggle:Keybind(KData)
                    -- Simplified Keybind impl for brevity
                    local Bind = { Key = KData.Default }
                    local KBtn = Create("TextButton", {
                        Parent = TFrame, Size = UDim2.new(0, 60, 0, 20), Position = UDim2.new(1, -65, 0, 2),
                        Text = Bind.Key and Bind.Key.Name or "None", BackgroundColor3 = Library.Theme.Element, TextColor3 = Library.Theme.Text
                    })
                    KBtn.MouseButton1Click:Connect(function()
                        KBtn.Text = "..."
                        local Input = UserInputService.InputBegan:Wait()
                        if Input.UserInputType == Enum.UserInputType.Keyboard then
                            Bind.Key = Input.KeyCode
                            KBtn.Text = Bind.Key.Name
                        end
                    end)
                    UserInputService.InputBegan:Connect(function(Input, Proc)
                        if not Proc and Input.KeyCode == Bind.Key then
                            if KData.Callback then KData.Callback() end
                        end
                    end)
                    return Toggle
                end

                function Toggle:Colorpicker(CData)
                    -- Simplified Colorpicker
                    local CP = { Color = CData.Default }
                    local CBtn = Create("TextButton", {
                        Parent = TFrame, Size = UDim2.new(0, 20, 0, 15), Position = UDim2.new(1, -90, 0.5, -7.5),
                        Text = "", BackgroundColor3 = CP.Color
                    })
                    -- For full implementation, reuse original colorpicker logic or basic RGB prompt
                    CBtn.MouseButton1Click:Connect(function()
                        -- Toggle color picker window (stub)
                    end)
                    return Toggle
                end

                return Toggle
            end

            -- [Slider]
            function Section:Slider(Data)
                local Slider = { Value = Data.Default or Data.Min }
                local SFrame = Create("Frame", { Parent = SectContent, Size = UDim2.new(1, -10, 0, 40), BackgroundTransparency = 1 })
                Create("TextLabel", {
                    Parent = SFrame, Text = Data.Name, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
                    TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })
                local Bar = Create("Frame", {
                    Parent = SFrame, Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 0, 25),
                    BackgroundColor3 = Library.Theme.Element
                })
                local Fill = Create("Frame", {
                    Parent = Bar, Size = UDim2.new((Slider.Value - Data.Min)/(Data.Max - Data.Min), 0, 1, 0),
                    BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0
                })
                local ValLabel = Create("TextLabel", {
                    Parent = SFrame, Text = tostring(Slider.Value), Size = UDim2.new(0, 50, 0, 20),
                    Position = UDim2.new(1, -50, 0, 0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text
                })

                local function Update(Input)
                    local SizeX = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    local NewVal = math.floor(((Data.Max - Data.Min) * SizeX) + Data.Min)
                    Slider.Value = NewVal
                    ValLabel.Text = tostring(NewVal)
                    Fill.Size = UDim2.new(SizeX, 0, 1, 0)
                    if Data.Callback then Data.Callback(NewVal) end
                end

                local Dragging = false
                Bar.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                        Update(Input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
                end)
                UserInputService.InputChanged:Connect(function(Input)
                    if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then Update(Input) end
                end)
            end

            -- [Dropdown]
            function Section:Dropdown(Data)
                local Drop = { Value = Data.Default, Open = false }
                local DFrame = Create("Frame", { Parent = SectContent, Size = UDim2.new(1, -10, 0, 30), BackgroundTransparency = 1 })
                Create("TextLabel", {
                    Parent = DFrame, Text = Data.Name, Size = UDim2.new(0.4, 0, 1, 0), BackgroundTransparency = 1,
                    TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
                })
                local MainBtn = Create("TextButton", {
                    Parent = DFrame, Text = Data.Default or "Select...", Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0.4, 0, 0, 0),
                    BackgroundColor3 = Library.Theme.Element, TextColor3 = Library.Theme.Text
                })
                
                local List = Create("Frame", {
                    Parent = SectContent, Size = UDim2.new(1, -10, 0, 0), Visible = false, BackgroundColor3 = Library.Theme.Element,
                    AutomaticSize = Enum.AutomaticSize.Y
                })
                local ListLayout = Create("UIListLayout", { Parent = List, SortOrder = Enum.SortOrder.LayoutOrder })

                MainBtn.MouseButton1Click:Connect(function()
                    Drop.Open = not Drop.Open
                    List.Visible = Drop.Open
                end)

                for _, Item in pairs(Data.Items) do
                    local ItemBtn = Create("TextButton", {
                        Parent = List, Size = UDim2.new(1, 0, 0, 20), Text = Item,
                        BackgroundColor3 = Library.Theme.Element, TextColor3 = Library.Theme.Text
                    })
                    ItemBtn.MouseButton1Click:Connect(function()
                        Drop.Value = Item
                        MainBtn.Text = Item
                        List.Visible = false
                        Drop.Open = false
                        if Data.Callback then Data.Callback(Item) end
                    end)
                end
            end
            
            -- [Button]
            function Section:Button(Data)
                local BtnFrame = Create("Frame", { Parent = SectContent, Size = UDim2.new(1, -10, 0, 30), BackgroundTransparency = 1 })
                local Btn = Create("TextButton", {
                    Parent = BtnFrame, Size = UDim2.new(1, 0, 1, 0), Text = Data.Name,
                    BackgroundColor3 = Library.Theme.Element, TextColor3 = Library.Theme.Text
                })
                Btn.MouseButton1Click:Connect(Data.Callback)
            end
            
            -- [Label]
            function Section:Label(Data)
                local LblFrame = Create("Frame", { Parent = SectContent, Size = UDim2.new(1, -10, 0, 20), BackgroundTransparency = 1 })
                Create("TextLabel", {
                    Parent = LblFrame, Text = Data.Name, Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left
                })
                local LabelObj = {}
                function LabelObj:Colorpicker(CData)
                    -- Stub
                    return LabelObj
                end
                return LabelObj
            end

            return Section
        end
        return Page
    end

    function Window:SetOpen(Bool)
        self.IsOpen = Bool
        MainFrame.Visible = Bool
    end

    return Window
end

-- [Helper Functions Exposed]
function Library:ChangeTheme(Theme, Color)
    self.Theme[Theme] = Color
end

return Library
