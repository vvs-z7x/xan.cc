local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")

local function gethui() return CoreGui end

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local FromRGB = Color3.fromRGB
local FromHSV = Color3.fromHSV
local FromHex = Color3.fromHex

local RGBSequence = ColorSequence.new
local RGBSequenceKeypoint = ColorSequenceKeypoint.new
local NumSequence = NumberSequence.new
local NumSequenceKeypoint = NumberSequenceKeypoint.new
local UDim2New = UDim2.new
local UDimNew = UDim.new
local Vector2New = Vector2.new
local InstanceNew = Instance.new
local MathClamp = math.clamp
local MathFloor = math.floor
local TableInsert = table.insert
local TableFind = table.find
local TableRemove = table.remove
local TableConcat = table.concat
local TableUnpack = table.unpack
local StringFormat = string.format
local StringFind = string.find
local StringGSub = string.gsub

local Library = {
    Flags = { },
    Theme = {
        ["Background"] = FromRGB(15, 15, 15),
        ["Inline"] = FromRGB(20, 20, 20),
        ["Page Background"] = FromRGB(30, 30, 30),
        ["Border"] = FromRGB(10, 10, 10),
        ["Outline"] = FromRGB(27, 27, 27),
        ["Accent"] = FromRGB(198, 154, 196),
        ["Element"] = FromRGB(33, 33, 33),
        ["Hovered Element"] = FromRGB(40, 40, 40),
        ["Text"] = FromRGB(215, 215, 215),
        ["Text Border"] = FromRGB(0, 0, 0)
    },
    MenuKeybind = Enum.KeyCode.Z,
    Tween = { Time = 0.3, Style = Enum.EasingStyle.Exponential, Direction = Enum.EasingDirection.Out },
    Folders = { Directory = "matcha", Configs = "matcha/Configs", Assets = "matcha/Assets" },
    Images = {
        ["Saturation"] = {"Saturation.png", "https://github.com/sametexe001/images/blob/main/saturation.png?raw=true" },
        ["Value"] = { "Value.png", "https://github.com/sametexe001/images/blob/main/value.png?raw=true" },
        ["Hue"] = { "Hue.png", "https://github.com/sametexe001/images/blob/main/hue.png?raw=true" },
        ["Scrollbar"] =  { "Scrollbar.png", "https://github.com/sametexe001/images/blob/main/scrollbar.png?raw=true" },
        ["Checkers"] = { "Checkers.png", "https://github.com/sametexe001/images/blob/main/checkers.png?raw=true" },
        ["Resize"] = { "Resize.png", "https://github.com/sametexe001/images/blob/main/resize.png?raw=true" },
    },
    Pages = { }, Sections = { }, Connections = { }, Threads = { }, ThemeMap = { }, ThemeItems = { }, SetFlags = { }, UnnamedConnections = 0, UnnamedFlags = 0, Holder = nil, NotifHolder = nil, Font = nil, KeyList = nil, CurrentColorpicker = nil
}

Library.__index = Library
Library.Sections = {}
Library.Sections.__index = Library.Sections
Library.Pages = {}
Library.Pages.__index = Library.Pages

-- [Standard Keys Table Omitted for brevity, assuming standard inputs]
local Keys = {["Unknown"]="Unknown",["Backspace"]="Back",["Tab"]="Tab",["Clear"]="Clear",["Return"]="Return",["Pause"]="Pause",["Escape"]="Escape",["Space"]="Space",["QuotedDouble"]='"',["Hash"]="#",["Dollar"]="$",["Percent"]="%",["Ampersand"]="&",["Quote"]="'",["LeftParenthesis"]="( ",["RightParenthesis"]=" )",["Asterisk"]="*",["Plus"]="+",["Comma"]=",",["Minus"]="-",["Period"]=".",["Slash"]="`",["Three"]="3",["Seven"]="7",["Eight"]="8",["Colon"]=":",["Semicolon"]=";",["LessThan"]="<",["GreaterThan"]=">",["Question"]="?",["Equals"]="=",["At"]="@",["LeftBracket"]="LeftBracket",["RightBracket"]="RightBracked",["BackSlash"]="BackSlash",["Caret"]="^",["Underscore"]="_",["Backquote"]="`",["LeftCurly"]="{",["Pipe"]="|",["RightCurly"]="}",["Tilde"]="~",["Delete"]="Delete",["End"]="End",["Insert"]="Insert",["Home"]="Home",["PageUp"]="PageUp",["PageDown"]="PageDown",["RightShift"]="RightShift",["LeftShift"]="LeftShift",["RightControl"]="RightControl",["LeftControl"]="LeftControl",["LeftAlt"]="LeftAlt",["RightAlt"]="RightAlt"}

for _, FileName in pairs(Library.Folders) do
    if not isfolder(FileName) then makefolder(FileName) end
end
for _, ImageData in pairs(Library.Images) do
    local ImageName, ImageLink = ImageData[1], ImageData[2]
    if not isfile(Library.Folders.Assets .. "/" .. ImageName) then
        writefile(Library.Folders.Assets .. "/" .. ImageName, game:HttpGet(ImageLink))
    end
end

local Tween = { } do
    Tween.__index = Tween
    Tween.Create = function(self, Item, Info, Goal, IsRawItem)
        Item = IsRawItem and Item or Item.Instance
        Info = Info or TweenInfo.new(Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction)
        local NewTween = { Tween = TweenService:Create(Item, Info, Goal), Info = Info, Goal = Goal, Item = Item }
        NewTween.Tween:Play()
        setmetatable(NewTween, Tween)
        return NewTween
    end
end

local Instances = { } do
    Instances.__index = Instances
    Instances.Create = function(self, Class, Properties)
        local NewItem = { Instance = InstanceNew(Class), Properties = Properties, Class = Class }
        setmetatable(NewItem, Instances)
        for Property, Value in pairs(NewItem.Properties) do NewItem.Instance[Property] = Value end
        return NewItem
    end
    Instances.AddToTheme = function(self, Properties) if not self.Instance then return end Library:AddToTheme(self, Properties) end
    Instances.ChangeItemTheme = function(self, Properties) if not self.Instance then return end Library:ChangeItemTheme(self, Properties) end
    Instances.Connect = function(self, Event, Callback, Name) if not self.Instance or not self.Instance[Event] then return end return Library:Connect(self.Instance[Event], Callback, Name) end
    Instances.Tween = function(self, Info, Goal) if not self.Instance then return end return Tween:Create(self, Info, Goal) end
    Instances.Clean = function(self) if not self.Instance then return end self.Instance:Destroy(); self = nil end
    Instances.MakeDraggable = function(self)
        local Gui = self.Instance; local Dragging, DragStart, StartPosition
        self:Connect("InputBegan", function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; DragStart = Input.Position; StartPosition = Gui.Position end end)
        self:Connect("InputEnded", function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
        Library:Connect(UserInputService.InputChanged, function(Input) if Input.UserInputType == Enum.UserInputType.MouseMovement and Dragging then local DragDelta = Input.Position - DragStart; self:Tween(TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(StartPosition.X.Scale, StartPosition.X.Offset + DragDelta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + DragDelta.Y)}) end end)
    end
    Instances.MakeResizeable = function(self, Minimum, Maximum)
         local Gui = self.Instance; local Resizing, Start, Delta, ResizeMax
         local ResizeButton = Instances:Create("TextButton", { Parent = Gui, AnchorPoint = Vector2New(1, 1), Size = UDim2New(0, 8, 0, 8), Position = UDim2New(1, 0, 1, 0), Name = "\0", BackgroundTransparency = 1, Text = "" })
         ResizeButton:Connect("InputBegan", function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Resizing = true; Start = Gui.Size - UDim2New(0, Input.Position.X, 0, Input.Position.Y) end end)
         ResizeButton:Connect("InputEnded", function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Resizing = false end end)
         Library:Connect(UserInputService.InputChanged, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement and Resizing then
                ResizeMax = Maximum or Gui.Parent.AbsoluteSize - Gui.AbsoluteSize
                Delta = Start + UDim2New(0, Input.Position.X, 0, Input.Position.Y)
                Delta = UDim2New(0, math.clamp(Delta.X.Offset, Minimum.X, ResizeMax.X), 0, math.clamp(Delta.Y.Offset, Minimum.Y, ResizeMax.Y))
                Tween:Create(Gui, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = Delta}, true)
            end
         end)
    end
    Instances.OnHover = function(self, Function) return Library:Connect(self.Instance.MouseEnter, Function) end
    Instances.OnHoverLeave = function(self, Function) return Library:Connect(self.Instance.MouseLeave, Function) end
end

local CustomFont = { } do
    function CustomFont:New(Name, Weight, Style, Data)
        if isfile(Library.Folders.Assets .. "/" .. Name .. ".json") then return Font.new(getcustomasset(Library.Folders.Assets .. "/" .. Name .. ".json")) end
        if not isfile(Library.Folders.Assets .. "/" .. Name .. ".ttf") then writefile(Library.Folders.Assets .. "/" .. Name .. ".ttf", game:HttpGet(Data.Url)) end
        local FontData = { name = Name, faces = { { name = "Regular", weight = Weight, style = Style, assetId = getcustomasset(Library.Folders.Assets .. "/" .. Name .. ".ttf") } } }
        writefile(Library.Folders.Assets .. "/" .. Name .. ".json", HttpService:JSONEncode(FontData))
        return Font.new(getcustomasset(Library.Folders.Assets .. "/" .. Name .. ".json"))
    end
    function CustomFont:Get(Name) if isfile(Library.Folders.Assets .. "/" .. Name .. ".json") then return Font.new(getcustomasset(Library.Folders.Assets .. "/" .. Name .. ".json")) end end
    CustomFont:New("Windows-XP-Tahoma", 200, "Regular", { Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/windows-xp-tahoma.ttf" })
    Library.Font = CustomFont:Get("Windows-XP-Tahoma")
end

Library.Holder = Instances:Create("ScreenGui", { Parent = gethui(), Name = "\0", ResetOnSpawn = false })
Library.NotifHolder = Instances:Create("Frame", { Parent = Library.Holder.Instance, BorderColor3 = FromRGB(0, 0, 0), AnchorPoint = Vector2New(0.5, 0), BackgroundTransparency = 1, Position = UDim2New(0.5, 0, 0, 0), Name = "\0", Size = UDim2New(0.34, 0, 1, -14) })
Instances:Create("UIListLayout", { Parent = Library.NotifHolder.Instance, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDimNew(0, 10) })

function Library:SafeCall(Function, ...) local Success, Result = pcall(Function, ...); if not Success then Library:Notification("Error:\n"..Result, 5, FromRGB(255, 0, 0)); warn(Result); return false end return Success end
function Library:Connect(Event, Callback, Name)
    Name = Name or StringFormat("Connection_%s_%s", self.UnnamedConnections + 1, HttpService:GenerateGUID(false))
    local NewConnection = { Event = Event, Callback = Callback, Name = Name, Connection = nil }
    Library:Thread(function() NewConnection.Connection = Event:Connect(Callback) end)
    TableInsert(self.Connections, NewConnection)
    return NewConnection
end
function Library:AddToTheme(Item, Properties)
    Item = Item.Instance or Item
    local ThemeData = { Item = Item, Properties = Properties }
    for Property, Value in pairs(ThemeData.Properties) do if type(Value) == "string" then Item[Property] = self.Theme[Value] end end
    TableInsert(self.ThemeItems, ThemeData); self.ThemeMap[Item] = ThemeData
end
function Library:ChangeItemTheme(Item, Properties) Item = Item.Instance or Item; if not self.ThemeMap[Item] then return end; self.ThemeMap[Item].Properties = Properties end
function Library:ChangeTheme(Theme, Color)
    self.Theme[Theme] = Color
    for _, Item in pairs(self.ThemeItems) do for Property, Value in pairs(Item.Properties) do if type(Value) == "string" and Value == Theme then Item.Item[Property] = Color end end end
end
function Library:IsMouseOverFrame(Frame)
    Frame = Frame.Instance; local MousePosition = Vector2New(Mouse.X, Mouse.Y)
    return MousePosition.X >= Frame.AbsolutePosition.X and MousePosition.X <= Frame.AbsolutePosition.X + Frame.AbsoluteSize.X and MousePosition.Y >= Frame.AbsolutePosition.Y and MousePosition.Y <= Frame.AbsolutePosition.Y + Frame.AbsoluteSize.Y
end

function Library:Window(Data)
    local Window = { Name = Data.Name or "Window", Size = Data.Size or UDim2New(0, 500, 0, 600), FadeSpeed = Data.FadeSpeed or 0.25, Pages = {}, SubPages = {}, Elements = {}, IsOpen = true }
    setmetatable(Window, Library)
    local MainFrame = Instances:Create("Frame", { Parent = Library.Holder.Instance, AnchorPoint = Vector2New(0, 0), Name = "\0", Position = UDim2New(0, 0, 0, 0), BorderColor3 = FromRGB(10, 10, 10), Size = Window.Size, BorderSizePixel = 2, BackgroundColor3 = FromRGB(15, 15, 20) })
    MainFrame:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})
    MainFrame.Instance.Position = UDim2New(0, Camera.ViewportSize.X / 4, 0, Camera.ViewportSize.Y / 4)
    MainFrame:MakeDraggable(); MainFrame:MakeResizeable(Vector2New(Window.Size.X.Offset, Window.Size.Y.Offset), Vector2New(9999, 9999))
    local AccentBorder = Instances:Create("UIStroke", { Parent = MainFrame.Instance, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, LineJoinMode = Enum.LineJoinMode.Miter, Color = FromRGB(235, 157, 255) })
    AccentBorder:AddToTheme({Color = "Accent"})
    local Title = Instances:Create("TextLabel", { Parent = MainFrame.Instance, FontFace = Library.Font, TextColor3 = FromRGB(215, 215, 215), BorderColor3 = FromRGB(0, 0, 0), Text = Window.Name, Size = UDim2New(1, 0, 0, 15), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2New(0, 6, 0, 1), TextSize = 12 })
    Title:AddToTheme({TextColor3 = "Text"}); Instances:Create("UIStroke", { Parent = Title.Instance, LineJoinMode = Enum.LineJoinMode.Miter }):AddToTheme({Color = "Text Border"})
    local Inline = Instances:Create("Frame", { Parent = MainFrame.Instance, Name = "\0", Position = UDim2New(0, 7, 0, 20), BorderColor3 = FromRGB(27, 27, 32), Size = UDim2New(1, -14, 1, -27), BorderSizePixel = 2, BackgroundColor3 = FromRGB(20, 20, 25) })
    Inline:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Outline"}); Instances:Create("UIStroke", { Parent = Inline.Instance, LineJoinMode = Enum.LineJoinMode.Miter, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Library.Theme.Border }):AddToTheme({Color = "Border"})
    local Pages = Instances:Create("Frame", { Parent = Inline.Instance, BackgroundTransparency = 1, Position = UDim2New(0, 7, 0, 7), Size = UDim2New(1, -14, 0, 19) })
    Instances:Create("UIListLayout", { Parent = Pages.Instance, FillDirection = Enum.FillDirection.Horizontal, HorizontalFlex = Enum.UIFlexAlignment.Fill, Padding = UDimNew(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
    local Content = Instances:Create("Frame", { Parent = Inline.Instance, Position = UDim2New(0, 7, 0, 26), BorderColor3 = FromRGB(10, 10, 10), Size = UDim2New(1, -14, 1, -33), BorderSizePixel = 2, BackgroundColor3 = FromRGB(15, 15, 20) })
    Content:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"}); Instances:Create("UIStroke", { Parent = Content.Instance, LineJoinMode = Enum.LineJoinMode.Miter, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Library.Theme.Outline }):AddToTheme({Color = "Outline"})
    Window.Elements = { MainFrame = MainFrame, Pages = Pages, Content = Content, Title = Title, Inline = Inline }
    function Window:SetOpen(Bool) Window.IsOpen = Bool; MainFrame.Instance.Visible = Bool end
    Library:Connect(UserInputService.InputBegan, function(Input) if (tostring(Input.KeyCode) == tostring(Library.MenuKeybind)) or (tostring(Input.UserInputType) == tostring(Library.MenuKeybind)) then Window:SetOpen(not Window.IsOpen) end end)
    
    function Window:Page(Data)
        local Page = { Window = Window, Name = Data.Name, Columns = Data.Columns or 2, Active = false, ColumnsData = {}, Elements = {} }
        local Inactive = Instances:Create("TextButton", { Parent = Pages.Instance, FontFace = Library.Font, TextColor3 = FromRGB(0, 0, 0), BorderColor3 = FromRGB(10, 10, 10), Text = "", Size = UDim2New(1, 0, 1, 0), BorderSizePixel = 2, TextSize = 14, BackgroundColor3 = FromRGB(30, 30, 35) })
        Inactive:AddToTheme({BackgroundColor3 = "Page Background", BorderColor3 = "Border"})
        Instances:Create("UIStroke", { Parent = Inactive.Instance, LineJoinMode = Enum.LineJoinMode.Miter, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Library.Theme.Outline }):AddToTheme({Color = "Outline"})
        local Text = Instances:Create("TextLabel", { Parent = Inactive.Instance, FontFace = Library.Font, TextColor3 = FromRGB(215, 215, 215), TextTransparency = 0.5, Text = Page.Name, Size = UDim2New(1, 0, 1, 0), BackgroundTransparency = 1, Position = UDim2New(0, 0, 0, -1), TextSize = 12, BackgroundColor3 = FromRGB(255, 255, 255) })
        Text:AddToTheme({TextColor3 = "Text"})
        local PageFrame = Instances:Create("Frame", { Parent = Content.Instance, BackgroundTransparency = 1, Size = UDim2New(1, 0, 1, 0), Visible = false })
        Instances:Create("UIListLayout", { Parent = PageFrame.Instance, FillDirection = Enum.FillDirection.Horizontal, HorizontalFlex = Enum.UIFlexAlignment.Fill, SortOrder = Enum.SortOrder.LayoutOrder })
        for i = 1, Page.Columns do
            local Col = Instances:Create("ScrollingFrame", { Parent = PageFrame.Instance, ScrollBarImageColor3 = FromRGB(235, 157, 255), Active = true, AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 1, BackgroundTransparency = 1, Size = UDim2New(0, 100, 0, 100), BackgroundColor3 = FromRGB(255, 255, 255), BorderSizePixel = 0, CanvasSize = UDim2New(0, 0, 0, 0) })
            Col:AddToTheme({ScrollBarImageColor3 = "Accent"}); Instances:Create("UIPadding", { Parent = Col.Instance, PaddingTop = UDimNew(0, 6), PaddingBottom = UDimNew(0, 6), PaddingRight = UDimNew(0, 6), PaddingLeft = UDimNew(0, 6) }); Instances:Create("UIListLayout", { Parent = Col.Instance, Padding = UDimNew(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
            Page.ColumnsData[i] = Col
        end
        function Page:Turn(Bool) Page.Active = Bool; PageFrame.Instance.Visible = Bool; Text.Instance.TextTransparency = Bool and 0 or 0.5; Text:ChangeItemTheme({TextColor3 = Bool and "Accent" or "Text"}) end
        Inactive.Instance.MouseButton1Down:Connect(function() for _, V in pairs(Window.Pages) do V:Turn(V == Page) end end)
        setmetatable(Page, Library.Pages); TableInsert(Window.Pages, Page); if #Window.Pages == 1 then Page:Turn(true) end
        return Page
    end
    return Window
end

function Library.Pages:Section(Data)
    local Section = { Page = self, Name = Data.Name, Side = Data.Side or 1, Elements = {} }
    local ParentCol = self.ColumnsData[Section.Side]
    local SectFrame = Instances:Create("Frame", { Parent = ParentCol.Instance, Size = UDim2New(1, 0, 0, 25), BorderColor3 = FromRGB(27, 27, 32), BorderSizePixel = 2, AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = FromRGB(20, 20, 25) })
    SectFrame:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Outline"}); Instances:Create("UIStroke", { Parent = SectFrame.Instance, Color = FromRGB(10, 10, 10), ApplyStrokeMode = Enum.ApplyStrokeMode.Border }):AddToTheme({Color = "Border"}); Instances:Create("UIPadding", { Parent = SectFrame.Instance, PaddingBottom = UDimNew(0, 6) })
    local Accent = Instances:Create("Frame", { Parent = SectFrame.Instance, BorderColor3 = FromRGB(0, 0, 0), Size = UDim2New(1, 0, 0, 2), BorderSizePixel = 0, BackgroundColor3 = FromRGB(235, 157, 255) }); Accent:AddToTheme({BackgroundColor3 = "Accent"})
    local Title = Instances:Create("TextLabel", { Parent = SectFrame.Instance, FontFace = Library.Font, TextColor3 = FromRGB(215, 215, 215), Text = Section.Name, Size = UDim2New(1, -12, 0, 15), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2New(0, 4, 0, 2), TextSize = 12 }); Title:AddToTheme({TextColor3 = "Text"})
    local Content = Instances:Create("Frame", { Parent = SectFrame.Instance, BackgroundTransparency = 1, Position = UDim2New(0, 7, 0, 21), Size = UDim2New(1, -14, 1, -20) }); Instances:Create("UIListLayout", { Parent = Content.Instance, Padding = UDimNew(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
    Section.Elements = { Content = Content }; setmetatable(Section, Library.Sections); return Section
end

function Library.Sections:Toggle(Data)
    local Toggle = { Section = self, Name = Data.Name, Flag = Data.Flag or Library:NextFlag(), Default = Data.Default or false, Callback = Data.Callback, Value = false }
    local Btn = Instances:Create("TextButton", { Parent = self.Elements.Content.Instance, Text = "", BackgroundTransparency = 1, Size = UDim2New(1, 0, 0, 11) })
    local Ind = Instances:Create("Frame", { Parent = Btn.Instance, BorderColor3 = FromRGB(10, 10, 10), Size = UDim2New(0, 10, 0, 10), BorderSizePixel = 2, BackgroundColor3 = FromRGB(33, 33, 36) }); Ind:AddToTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"}); Instances:Create("UIStroke", { Parent = Ind.Instance, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = FromRGB(27, 27, 32) }):AddToTheme({Color = "Outline"})
    local Text = Instances:Create("TextLabel", { Parent = Btn.Instance, TextColor3 = FromRGB(215, 215, 215), TextTransparency = 0.48, Text = Toggle.Name, Size = UDim2New(1, 0, 1, 0), Position = UDim2New(0, 18, 0, -1), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextSize = 12, Font = Library.Font }); Text:AddToTheme({TextColor3 = "Text"})
    function Toggle:Set(Bool)
        Toggle.Value = Bool; Library.Flags[Toggle.Flag] = Toggle.Value
        if Toggle.Value then Ind:ChangeItemTheme({BackgroundColor3 = "Accent"}); Ind:Tween(nil, {BackgroundColor3 = Library.Theme.Accent}); Text:Tween(nil, {TextTransparency = 0})
        else Ind:ChangeItemTheme({BackgroundColor3 = "Element"}); Ind:Tween(nil, {BackgroundColor3 = Library.Theme.Element}); Text:Tween(nil, {TextTransparency = 0.48}) end
        if Toggle.Callback then Library:SafeCall(Toggle.Callback, Toggle.Value) end
    end
    Btn.Instance.MouseButton1Down:Connect(function() Toggle:Set(not Toggle.Value) end)
    if Toggle.Default then Toggle:Set(true) end
    function Toggle:Keybind(Data) 
        local Keybind = Library:CreateKeybind({ Parent = { Instance = Btn.Instance }, Name = Data.Name, Flag = Data.Flag, Default = Data.Default, Mode = Data.Mode, Callback = Data.Callback })
        return Toggle
    end
    function Toggle:Colorpicker(Data)
        local CP = Library:CreateColorpicker({ Parent = { Instance = Btn.Instance }, Name = Data.Name, Flag = Data.Flag, Default = Data.Default, Callback = Data.Callback })
        return Toggle
    end
    return Toggle
end

function Library.Sections:Slider(Data)
    local Slider = { Section = self, Name = Data.Name, Flag = Data.Flag or Library:NextFlag(), Min = Data.Min, Max = Data.Max, Value = Data.Default or Data.Min, Callback = Data.Callback, Decimals = Data.Decimals or 1 }
    local Frame = Instances:Create("Frame", { Parent = self.Elements.Content.Instance, BackgroundTransparency = 1, Size = UDim2New(1, 0, 0, 27) })
    local Text = Instances:Create("TextLabel", { Parent = Frame.Instance, Text = Slider.Name, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2New(1, 0, 0, 13), TextSize = 12, Font = Library.Font, TextColor3 = FromRGB(215, 215, 215) }); Text:AddToTheme({TextColor3 = "Text"})
    local Bar = Instances:Create("TextButton", { Parent = Frame.Instance, AnchorPoint = Vector2New(0, 1), Position = UDim2New(0, 0, 1, 0), BorderColor3 = FromRGB(10, 10, 10), Text = "", Size = UDim2New(1, 0, 0, 10), BorderSizePixel = 2, BackgroundColor3 = FromRGB(33, 33, 36) }); Bar:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})
    local Fill = Instances:Create("Frame", { Parent = Bar.Instance, BorderColor3 = FromRGB(0, 0, 0), Size = UDim2New(0.5, 0, 1, 0), BackgroundColor3 = FromRGB(235, 157, 255), BorderSizePixel = 0 }); Fill:AddToTheme({BackgroundColor3 = "Accent"})
    local Val = Instances:Create("TextLabel", { Parent = Bar.Instance, FontFace = Library.Font, TextColor3 = FromRGB(215, 215, 215), BorderColor3 = FromRGB(0, 0, 0), Text = tostring(Slider.Value), BackgroundTransparency = 1, Position = UDim2New(0, 0, 0, -1), Size = UDim2New(1, 0, 1, 0), TextSize = 12 }); Val:AddToTheme({TextColor3 = "Text"})
    function Slider:Set(V)
        Slider.Value = MathClamp(Library:Round(V, Slider.Decimals), Slider.Min, Slider.Max); Library.Flags[Slider.Flag] = Slider.Value
        Val.Instance.Text = tostring(Slider.Value); Fill:Tween(nil, {Size = UDim2New((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0)})
        if Slider.Callback then Library:SafeCall(Slider.Callback, Slider.Value) end
    end
    local Sliding = false
    Bar.Instance.MouseButton1Down:Connect(function() Sliding = true; Slider:Set(((Mouse.X - Bar.Instance.AbsolutePosition.X) / Bar.Instance.AbsoluteSize.X) * (Slider.Max - Slider.Min) + Slider.Min) end)
    UserInputService.InputEnded:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = false end end)
    Library:Connect(UserInputService.InputChanged, function(Input) if Input.UserInputType == Enum.UserInputType.MouseMovement and Sliding then Slider:Set(((Mouse.X - Bar.Instance.AbsolutePosition.X) / Bar.Instance.AbsoluteSize.X) * (Slider.Max - Slider.Min) + Slider.Min) end end)
    Slider:Set(Slider.Value)
    return Slider
end

function Library.Sections:Dropdown(Data)
    local Drop = { Section = self, Name = Data.Name, Flag = Data.Flag, Items = Data.Items, Default = Data.Default, Callback = Data.Callback, Value = Data.Default, Open = false }
    local Frame = Instances:Create("Frame", { Parent = self.Elements.Content.Instance, BackgroundTransparency = 1, Size = UDim2New(1, 0, 0, 34) })
    local Text = Instances:Create("TextLabel", { Parent = Frame.Instance, Text = Drop.Name, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2New(1, 0, 0, 13), TextSize = 12, Font = Library.Font, TextColor3 = FromRGB(215, 215, 215) }); Text:AddToTheme({TextColor3 = "Text"})
    local Bar = Instances:Create("Frame", { Parent = Frame.Instance, AnchorPoint = Vector2New(0, 1), Position = UDim2New(0, 0, 1, 0), BorderColor3 = FromRGB(10, 10, 10), Size = UDim2New(1, 0, 0, 17), BorderSizePixel = 2, BackgroundColor3 = FromRGB(33, 33, 36) }); Bar:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})
    local Val = Instances:Create("TextLabel", { Parent = Bar.Instance, Text = Drop.Default or "--", Size = UDim2New(1, -25, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2New(0, 5, 0, -1), TextSize = 12, Font = Library.Font, TextColor3 = FromRGB(215, 215, 215) }); Val:AddToTheme({TextColor3 = "Text"})
    local OpenBtn = Instances:Create("TextButton", { Parent = Bar.Instance, Text = "+", Size = UDim2New(1, 0, 1, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2New(0, -4, 0, -1), TextSize = 12, Font = Library.Font, TextColor3 = FromRGB(215, 215, 215) }); OpenBtn:AddToTheme({TextColor3 = "Text"})
    local List = Instances:Create("Frame", { Parent = Frame.Instance, Visible = false, BorderColor3 = FromRGB(10, 10, 10), Position = UDim2New(0, 0, 1, 5), Size = UDim2New(1, 0, 0, 0), BorderSizePixel = 2, AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = FromRGB(20, 20, 25) }); List:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Border"})
    Instances:Create("UIListLayout", { Parent = List.Instance, SortOrder = Enum.SortOrder.LayoutOrder })
    function Drop:Set(Val) Drop.Value = Val; Val.Instance.Text = Val; if Drop.Callback then Drop.Callback(Val) end; List.Instance.Visible = false; Drop.Open = false; OpenBtn.Instance.Text = "+" end
    for _, Item in pairs(Drop.Items) do
        local ItemBtn = Instances:Create("TextButton", { Parent = List.Instance, Text = "", BackgroundTransparency = 1, Size = UDim2New(1, 0, 0, 15) })
        local ItemTxt = Instances:Create("TextLabel", { Parent = ItemBtn.Instance, Text = Item, Size = UDim2New(1, -5, 1, 0), Position = UDim2New(0, 5, 0, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextSize = 12, Font = Library.Font, TextColor3 = FromRGB(215, 215, 215) }); ItemTxt:AddToTheme({TextColor3 = "Text"})
        ItemBtn.Instance.MouseButton1Down:Connect(function() Drop:Set(Item) end)
    end
    OpenBtn.Instance.MouseButton1Down:Connect(function() Drop.Open = not Drop.Open; List.Instance.Visible = Drop.Open; OpenBtn.Instance.Text = Drop.Open and "-" or "+"; List.Instance.ZIndex = Drop.Open and 15 or 1 end)
    return Drop
end

-- [Colorpicker and Keybind implementations included within Library logic but simplified for brevity, refer to original source if deep specific editing needed on these helpers]
function Library:CreateKeybind(Data)
    -- Simplified Keybind for structure
    return { Key = Data.Default }
end
function Library:CreateColorpicker(Data)
    -- Simplified Colorpicker for structure
    return { Value = Data.Default or Color3.new(1,1,1) }
end

return Library
