--[[
    TransparentUI
    Public Roblox Luau UI Library
    Single-file / No external dependencies

    Features:
    - Transparent glass-style UI
    - Tabs
    - Sections
    - Buttons
    - Toggles
    - Sliders
    - Dropdowns
    - Textboxes
    - Labels
    - Keybinds
    - Notifications
    - Minimize / restore
    - Mobile-friendly
    - Draggable window
    - Custom themes
    - No external assets required
]]

local TransparentUI = {}
TransparentUI.__index = TransparentUI

--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--// Prevent duplicate UI
local Existing = CoreGui:FindFirstChild("TransparentUI")
if Existing then
    Existing:Destroy()
end

--// Theme
TransparentUI.Theme = {
    Background = Color3.fromRGB(15, 15, 18),
    Surface = Color3.fromRGB(22, 22, 27),
    Element = Color3.fromRGB(30, 30, 36),

    Accent = Color3.fromRGB(130, 130, 255),

    Text = Color3.fromRGB(245, 245, 248),
    SubText = Color3.fromRGB(160, 160, 170),

    Border = Color3.fromRGB(255, 255, 255),

    WindowTransparency = 0.16,
    SurfaceTransparency = 0.18,
    ElementTransparency = 0.08,
}

--==================================================
-- Utilities
--==================================================

local function Create(className, properties, parent)
    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    if parent then
        object.Parent = parent
    end

    return object
end

local function AddCorner(object, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    }, object)
end

local function AddStroke(object, color, transparency, thickness)
    return Create("UIStroke", {
        Color = color or Color3.new(1, 1, 1),
        Transparency = transparency or 0.85,
        Thickness = thickness or 1
    }, object)
end

local function AddPadding(object, amount)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, amount),
        PaddingBottom = UDim.new(0, amount),
        PaddingLeft = UDim.new(0, amount),
        PaddingRight = UDim.new(0, amount)
    }, object)
end

local function Tween(object, properties, duration)
    local animation = TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.2,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        properties
    )

    animation:Play()
    return animation
end

local function IsMobile()
    local camera = workspace.CurrentCamera

    if UserInputService.TouchEnabled then
        return true
    end

    if camera then
        return camera.ViewportSize.X < 850
    end

    return false
end

--==================================================
-- Window
--==================================================

function TransparentUI:CreateWindow(options)
    options = options or {}

    local WindowObject = setmetatable({}, TransparentUI)

    WindowObject.Title = options.Title or "Transparent UI"
    WindowObject.Size = options.Size or UDim2.fromOffset(560, 450)
    WindowObject.Theme = options.Theme or TransparentUI.Theme

    WindowObject.Tabs = {}
    WindowObject.Destroyed = false
    WindowObject.Minimized = false

    --// GUI
    local ScreenGui = Create("ScreenGui", {
        Name = "TransparentUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, CoreGui)

    WindowObject.ScreenGui = ScreenGui

    --// Responsive size
    local camera = workspace.CurrentCamera

    if camera and IsMobile() then
        local viewport = camera.ViewportSize

        WindowObject.Size = UDim2.fromOffset(
            math.clamp(viewport.X - 24, 300, 430),
            math.clamp(viewport.Y - 100, 350, 500)
        )
    end

    --==================================================
    -- Main Window
    --==================================================

    local Window = Create("Frame", {
        Name = "Window",

        Size = WindowObject.Size,

        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),

        BackgroundColor3 = WindowObject.Theme.Background,
        BackgroundTransparency = WindowObject.Theme.WindowTransparency,

        BorderSizePixel = 0
    }, ScreenGui)

    WindowObject.Window = Window

    AddCorner(Window, 12)
    AddStroke(
        Window,
        WindowObject.Theme.Border,
        0.88,
        1
    )

    --==================================================
    -- Top Bar
    --==================================================

    local TopBar = Create("Frame", {
        Name = "TopBar",

        Size = UDim2.new(1, 0, 0, 52),

        BackgroundColor3 = WindowObject.Theme.Surface,
        BackgroundTransparency = WindowObject.Theme.SurfaceTransparency,

        BorderSizePixel = 0
    }, Window)

    AddCorner(TopBar, 12)

    local Title = Create("TextLabel", {
        Name = "Title",

        Size = UDim2.new(1, -105, 1, 0),
        Position = UDim2.fromOffset(16, 0),

        BackgroundTransparency = 1,

        Text = WindowObject.Title,
        TextColor3 = WindowObject.Theme.Text,

        Font = Enum.Font.GothamBold,
        TextSize = 16,

        TextXAlignment = Enum.TextXAlignment.Left
    }, TopBar)

    --// Minimize
    local Minimize = Create("TextButton", {
        Name = "Minimize",

        Size = UDim2.fromOffset(34, 34),
        Position = UDim2.new(1, -45, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),

        BackgroundColor3 = WindowObject.Theme.Element,
        BackgroundTransparency = 0.15,

        Text = "—",
        TextColor3 = WindowObject.Theme.Text,

        Font = Enum.Font.GothamBold,
        TextSize = 18,

        AutoButtonColor = false
    }, TopBar)

    AddCorner(Minimize, 8)

    --==================================================
    -- Content
    --==================================================

    local Content = Create("Frame", {
        Name = "Content",

        Size = UDim2.new(1, -20, 1, -62),
        Position = UDim2.fromOffset(10, 57),

        BackgroundTransparency = 1
    }, Window)

    WindowObject.Content = Content

    --==================================================
    -- Sidebar
    --==================================================

    local Sidebar = Create("ScrollingFrame", {
        Name = "Sidebar",

        Size = UDim2.new(0, 135, 1, 0),

        BackgroundColor3 = WindowObject.Theme.Surface,
        BackgroundTransparency = 0.3,

        BorderSizePixel = 0,

        ScrollBarThickness = 0,

        AutomaticCanvasSize = Enum.AutomaticSize.Y
    }, Content)

    AddCorner(Sidebar, 10)
    AddPadding(Sidebar, 7)

    Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, Sidebar)

    WindowObject.Sidebar = Sidebar

    --==================================================
    -- Pages
    --==================================================

    local Pages = Create("Frame", {
        Name = "Pages",

        Size = UDim2.new(1, -145, 1, 0),
        Position = UDim2.fromOffset(145, 0),

        BackgroundTransparency = 1
    }, Content)

    WindowObject.Pages = Pages

    --==================================================
    -- Dragging
    --==================================================

    local Dragging = false
    local DragStart
    local StartPosition

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            Dragging = true
            DragStart = input.Position
            StartPosition = Window.Position
        end
    end)

    TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            Dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not Dragging then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local Delta = input.Position - DragStart

        Window.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,

            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
    end)

    --==================================================
    -- Floating Restore
    --==================================================

    local function CreateRestoreButton()
        if WindowObject.RestoreButton then
            WindowObject.RestoreButton:Destroy()
        end

        local Restore = Create("TextButton", {
            Name = "Restore",

            Size = UDim2.fromOffset(52, 52),

            Position = UDim2.new(
                0,
                18,
                0.7,
                0
            ),

            BackgroundColor3 = WindowObject.Theme.Background,
            BackgroundTransparency = 0.08,

            Text = "UI",
            TextColor3 = WindowObject.Theme.Text,

            Font = Enum.Font.GothamBold,
            TextSize = 13,

            AutoButtonColor = false
        }, ScreenGui)

        AddCorner(Restore, 14)
        AddStroke(Restore, WindowObject.Theme.Accent, 0.25)

        Restore.MouseButton1Click:Connect(function()
            WindowObject.Minimized = false

            Window.Visible = true

            Tween(
                Window,
                {
                    Size = WindowObject.Size
                },
                0.25
            )

            Restore:Destroy()
            WindowObject.RestoreButton = nil
        end)

        WindowObject.RestoreButton = Restore
    end

    --==================================================
    -- Minimize
    --==================================================

    Minimize.MouseButton1Click:Connect(function()
        if WindowObject.Minimized then
            return
        end

        WindowObject.Minimized = true

        Tween(
            Window,
            {
                Size = UDim2.fromOffset(0, 0)
            },
            0.22
        )

        task.delay(0.22, function()
            if WindowObject.Minimized then
                Window.Visible = false
                CreateRestoreButton()
            end
        end)
    end)

    --==================================================
    -- Public Methods
    --==================================================

    function WindowObject:SelectTab(tab)
        for _, data in ipairs(self.Tabs) do
            data.Page.Visible = false

            Tween(
                data.Button,
                {
                    BackgroundColor3 = self.Theme.Element,
                    BackgroundTransparency = 0.6
                },
                0.15
            )
        end

        tab.Page.Visible = true

        Tween(
            tab.Button,
            {
                BackgroundColor3 = self.Theme.Accent,
                BackgroundTransparency = 0.15
            },
            0.15
        )
    end

    function WindowObject:Notify(options)
        options = options or {}

        local Holder = ScreenGui:FindFirstChild("Notifications")

        if not Holder then
            Holder = Create("Frame", {
                Name = "Notifications",

                Size = UDim2.new(0, 300, 1, -20),
                Position = UDim2.new(1, -310, 0, 10),

                BackgroundTransparency = 1
            }, ScreenGui)

            Create("UIListLayout", {
                Padding = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            }, Holder)
        end

        local Notification = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 65),

            BackgroundColor3 = self.Theme.Surface,
            BackgroundTransparency = 0.1,

            BorderSizePixel = 0
        }, Holder)

        AddCorner(Notification, 9)
        AddStroke(Notification, self.Theme.Border, 0.87)

        Create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 24),
            Position = UDim2.fromOffset(10, 8),

            BackgroundTransparency = 1,

            Text = options.Title or "Notification",
            TextColor3 = self.Theme.Text,

            Font = Enum.Font.GothamBold,
            TextSize = 13,

            TextXAlignment = Enum.TextXAlignment.Left
        }, Notification)

        Create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.fromOffset(10, 32),

            BackgroundTransparency = 1,

            Text = options.Content or "",
            TextColor3 = self.Theme.SubText,

            Font = Enum.Font.Gotham,
            TextSize = 11,

            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left
        }, Notification)

        task.delay(options.Duration or 3, function()
            if Notification then
                Tween(
                    Notification,
                    {
                        BackgroundTransparency = 1
                    },
                    0.2
                )

                task.wait(0.2)

                if Notification then
                    Notification:Destroy()
                end
            end
        end)
    end

    function WindowObject:Destroy()
        self.Destroyed = true

        if self.ScreenGui then
            self.ScreenGui:Destroy()
        end
    end

    return WindowObject
end

--==================================================
-- Tab
--==================================================

function TransparentUI:CreateTab(name)
    local WindowObject = self

    local Button = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),

        BackgroundColor3 = self.Theme.Element,
        BackgroundTransparency = 0.6,

        Text = name,

        TextColor3 = self.Theme.SubText,

        Font = Enum.Font.GothamMedium,
        TextSize = 12,

        AutoButtonColor = false
    }, self.Sidebar)

    AddCorner(Button, 7)

    local Page = Create("ScrollingFrame", {
        Name = name .. "Page",

        Size = UDim2.fromScale(1, 1),

        BackgroundTransparency = 1,

        BorderSizePixel = 0,

        ScrollBarThickness = 2,

        ScrollBarImageTransparency = 0.5,

        AutomaticCanvasSize = Enum.AutomaticSize.Y,

        Visible = false
    }, self.Pages)

    AddPadding(Page, 4)

    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, Page)

    local Tab = {
        Button = Button,
        Page = Page,
        Window = self
    }

    table.insert(self.Tabs, Tab)

    Button.MouseButton1Click:Connect(function()
        WindowObject:SelectTab(Tab)
    end)

    if #self.Tabs == 1 then
        WindowObject:SelectTab(Tab)
    end

    --==================================================
    -- Section
    --==================================================

    function Tab:AddSection(text)
        return Create("TextLabel", {
            Size = UDim2.new(1, -4, 0, 26),

            BackgroundTransparency = 1,

            Text = text,

            TextColor3 = self.Window.Theme.Accent,

            Font = Enum.Font.GothamBold,
            TextSize = 12,

            TextXAlignment = Enum.TextXAlignment.Left
        }, Page)
    end

    --==================================================
    -- Label
    --==================================================

    function Tab:AddLabel(text)
        return Create("TextLabel", {
            Size = UDim2.new(1, -4, 0, 32),

            BackgroundTransparency = 1,

            Text = text,

            TextColor3 = self.Window.Theme.SubText,

            Font = Enum.Font.Gotham,
            TextSize = 12,

            TextWrapped = true,

            TextXAlignment = Enum.TextXAlignment.Left
        }, Page)
    end

    --==================================================
    -- Button
    --==================================================

    function Tab:AddButton(options)
        options = options or {}

        local ButtonObject = Create("TextButton", {
            Size = UDim2.new(1, -4, 0, 42),

            BackgroundColor3 = self.Window.Theme.Element,
            BackgroundTransparency = 0.08,

            Text = options.Title or "Button",

            TextColor3 = self.Window.Theme.Text,

            Font = Enum.Font.GothamMedium,
            TextSize = 12,

            AutoButtonColor = false
        }, Page)

        AddCorner(ButtonObject, 8)
        AddStroke(ButtonObject, self.Window.Theme.Border, 0.92)

        ButtonObject.MouseEnter:Connect(function()
            Tween(
                ButtonObject,
                {
                    BackgroundColor3 = self.Window.Theme.Accent
                },
                0.15
            )
        end)

        ButtonObject.MouseLeave:Connect(function()
            Tween(
                ButtonObject,
                {
                    BackgroundColor3 = self.Window.Theme.Element
                },
                0.15
            )
        end)

        ButtonObject.MouseButton1Click:Connect(function()
            if options.Callback then
                task.spawn(options.Callback)
            end
        end)

        return ButtonObject
    end

    --==================================================
    -- Toggle
    --==================================================

    function Tab:AddToggle(options)
        options = options or {}

        local State = options.Default == true

        local Container = Create("TextButton", {
            Size = UDim2.new(1, -4, 0, 46),

            BackgroundColor3 = self.Window.Theme.Element,
            BackgroundTransparency = 0.08,

            Text = "",

            AutoButtonColor = false
        }, Page)

        AddCorner(Container, 8)

        local Label = Create("TextLabel", {
            Size = UDim2.new(1, -70, 1, 0),
            Position = UDim2.fromOffset(13, 0),

            BackgroundTransparency = 1,

            Text = options.Title or "Toggle",

            TextColor3 = self.Window.Theme.Text,

            Font = Enum.Font.GothamMedium,
            TextSize = 12,

            TextXAlignment = Enum.TextXAlignment.Left
        }, Container)

        local Switch = Create("Frame", {
            Size = UDim2.fromOffset(40, 21),

            Position = UDim2.new(1, -52, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),

            BackgroundColor3 = Color3.fromRGB(55, 55, 62)
        }, Container)

        AddCorner(Switch, 12)

        local Knob = Create("Frame", {
            Size = UDim2.fromOffset(17, 17),

            Position = UDim2.fromOffset(2, 2),

            BackgroundColor3 = Color3.fromRGB(235, 235, 240)
        }, Switch)

        AddCorner(Knob, 9)

        local function Update()
            if State then
                Tween(
                    Switch,
                    {
                        BackgroundColor3 = self.Window.Theme.Accent
                    }
                )

                Tween(
                    Knob,
                    {
                        Position = UDim2.new(1, -19, 0, 2)
                    }
                )
            else
                Tween(
                    Switch,
                    {
                        BackgroundColor3 = Color3.fromRGB(55, 55, 62)
                    }
                )

                Tween(
                    Knob,
                    {
                        Position = UDim2.fromOffset(2, 2)
                    }
                )
            end

            if options.Callback then
                task.spawn(options.Callback, State)
            end
        end

        Container.MouseButton1Click:Connect(function()
            State = not State
            Update()
        end)

        Update()

        return {
            Set = function(_, value)
                State = value == true
                Update()
            end,

            Get = function()
                return State
            end
        }
    end

    --==================================================
    -- Slider
    --==================================================

    function Tab:AddSlider(options)
        options = options or {}

        local Minimum = options.Min or 0
        local Maximum = options.Max or 100
        local Value = options.Default or Minimum

        local Container = Create("Frame", {
            Size = UDim2.new(1, -4, 0, 62),

            BackgroundColor3 = self.Window.Theme.Element,
            BackgroundTransparency = 0.08,

            BorderSizePixel = 0
        }, Page)

        AddCorner(Container, 8)

        local Label = Create("TextLabel", {
            Size = UDim2.new(1, -70, 0, 26),
            Position = UDim2.fromOffset(12, 4),

            BackgroundTransparency = 1,

            Text = options.Title or "Slider",

            TextColor3 = self.Window.Theme.Text,

            Font = Enum.Font.GothamMedium,
            TextSize = 12,

            TextXAlignment = Enum.TextXAlignment.Left
        }, Container)

        local ValueLabel = Create("TextLabel", {
            Size = UDim2.fromOffset(55, 26),
            Position = UDim2.new(1, -65, 0, 4),

            BackgroundTransparency = 1,

            Text = tostring(Value),

            TextColor3 = self.Window.Theme.SubText,

            Font = Enum.Font.Gotham,
            TextSize = 11,

            TextXAlignment = Enum.TextXAlignment.Right
        }, Container)

        local Bar = Create("Frame", {
            Size = UDim2.new(1, -24, 0, 5),
            Position = UDim2.fromOffset(12, 42),

            BackgroundColor3 = Color3.fromRGB(55, 55, 62),

            BorderSizePixel = 0
        }, Container)

        AddCorner(Bar, 5)

        local Fill = Create("Frame", {
            Size = UDim2.new(
                (Value - Minimum) / (Maximum - Minimum),
                0,
                1,
                0
            ),

            BackgroundColor3 = self.Window.Theme.Accent,

            BorderSizePixel = 0
        }, Bar)

        AddCorner(Fill, 5)

        local dragging = false

        local function SetValueFromInput(input)
            local X = input.Position.X
            local Relative = math.clamp(
                (X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X,
                0,
                1
            )

            Value = Minimum + ((Maximum - Minimum) * Relative)

            if options.Rounding then
                local Power = 10 ^ options.Rounding
                Value = math.floor(Value * Power + 0.5) / Power
            else
                Value = math.floor(Value + 0.5)
            end

            local Percent = (Value - Minimum) / (Maximum - Minimum)

            Fill.Size = UDim2.new(
                Percent,
                0,
                1,
                0
            )

            ValueLabel.Text = tostring(Value)

            if options.Callback then
                task.spawn(options.Callback, Value)
            end
        end

        Bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then

                dragging = true
                SetValueFromInput(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if not dragging then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then

                SetValueFromInput(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then

                dragging = false
            end
        end)

        return {
            Set = function(_, value)
                Value = math.clamp(value, Minimum, Maximum)

                local Percent =
                    (Value - Minimum) /
                    (Maximum - Minimum)

                Fill.Size = UDim2.new(
                    Percent,
                    0,
                    1,
                    0
                )

                ValueLabel.Text = tostring(Value)

                if options.Callback then
                    task.spawn(options.Callback, Value)
                end
            end,

            Get = function()
                return Value
            end
        }
    end

    --==================================================
    -- Dropdown
    --==================================================

    function Tab:AddDropdown(options)
        options = options or {}

        local Values = options.Values or {}
        local Current = options.Default or Values[1]

        local Container = Create("Frame", {
            Size = UDim2.new(1, -4, 0, 46),

            BackgroundColor3 = self.Window.Theme.Element,
            BackgroundTransparency = 0.08
        }, Page)

        AddCorner(Container, 8)

        local Button = Create("TextButton", {
            Size = UDim2.fromScale(1, 1),

            BackgroundTransparency = 1,

            Text = "",

            AutoButtonColor = false
        }, Container)

        local Label = Create("TextLabel", {
            Size = UDim2.new(0.55, 0, 1, 0),
            Position = UDim2.fromOffset(12, 0),

            BackgroundTransparency = 1,

            Text = options.Title or "Dropdown",

            TextColor3 = self.Window.Theme.Text,

            Font = Enum.Font.GothamMedium,
            TextSize = 12,

            TextXAlignment = Enum.TextXAlignment.Left
        }, Button)

        local Selected = Create("TextLabel", {
            Size = UDim2.new(0.4, -10, 1, 0),
            Position = UDim2.new(0.6, 0, 0, 0),

            BackgroundTransparency = 1,

            Text = tostring(Current or "Select"),

            TextColor3 = self.Window.Theme.SubText,

            Font = Enum.Font.Gotham,
            TextSize = 11,

            TextXAlignment = Enum.TextXAlignment.Right
        }, Button)

        local Open = false

        local List = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),

            Position = UDim2.new(0, 0, 1, 4),

            BackgroundColor3 = self.Window.Theme.Surface,
            BackgroundTransparency = 0.05,

            Visible = false,

            ClipsDescendants = true,

            ZIndex = 20
        }, Container)

        AddCorner(List, 8)
        AddStroke(List, self.Window.Theme.Border, 0.85)

        local ListLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 2)
        }, List)

        for _, Item in ipairs(Values) do
            local Option = Create("TextButton", {
                Size = UDim2.new(1, -8, 0, 30),

                BackgroundColor3 = self.Window.Theme.Element,
                BackgroundTransparency = 0.3,

                Text = tostring(Item),

                TextColor3 = self.Window.Theme.Text,

                Font = Enum.Font.Gotham,
                TextSize = 11,

                AutoButtonColor = false,

                ZIndex = 21
            }, List)

            AddCorner(Option, 6)

            Option.MouseButton1Click:Connect(function()
                Current = Item
                Selected.Text = tostring(Item)

                Open = false
                List.Visible = false

                if options.Callback then
                    task.spawn(options.Callback, Item)
                end
            end)
        end

        Button.MouseButton1Click:Connect(function()
            Open = not Open

            List.Visible = Open

            if Open then
                local Height = math.min(
                    #Values * 32 + 6,
                    160
                )

                Tween(
                    List,
                    {
                        Size = UDim2.new(
                            1,
                            0,
                            0,
                            Height
                        )
                    },
                    0.18
                )
            else
                Tween(
                    List,
                    {
                        Size = UDim2.new(
                            1,
                            0,
                            0,
                            0
                        )
                    },
                    0.18
                )

                task.delay(0.18, function()
                    if not Open then
                        List.Visible = false
                    end
                end)
            end
        end)

        return {
            Set = function(_, value)
                Current = value
                Selected.Text = tostring(value)

                if options.Callback then
                    task.spawn(options.Callback, value)
                end
            end,

            Get = function()
                return Current
            end
        }
    end

    --==================================================
    -- Textbox
    --==================================================

    function Tab:AddTextbox(options)
        options = options or {}

        local Container = Create("Frame", {
            Size = UDim2.new(1, -4, 0, 48),

            BackgroundColor3 = self.Window.Theme.Element,
            BackgroundTransparency = 0.08
        }, Page)

        AddCorner(Container, 8)

        local Input = Create("TextBox", {
            Size = UDim2.new(1, -24, 1, -12),
            Position = UDim2.fromOffset(12, 6),

            BackgroundTransparency = 1,

            PlaceholderText = options.Placeholder or "Enter text...",
            PlaceholderColor3 = self.Window.Theme.SubText,

            Text = options.Default or "",

            TextColor3 = self.Window.Theme.Text,

            Font = Enum.Font.Gotham,
            TextSize = 12,

            ClearTextOnFocus = false,

            TextXAlignment = Enum.TextXAlignment.Left
        }, Container)

        Input.FocusLost:Connect(function(enterPressed)
            if options.Callback then
                task.spawn(
                    options.Callback,
                    Input.Text,
                    enterPressed
                )
            end
        end)

        return {
            Set = function(_, value)
                Input.Text = tostring(value)
            end,

            Get = function()
                return Input.Text
            end
        }
    end

    --==================================================
    -- Keybind
    --==================================================

    function Tab:AddKeybind(options)
        options = options or {}

        local CurrentKey = options.Default or Enum.KeyCode.RightShift
        local Listening = false

        local Button = Create("TextButton", {
            Size = UDim2.new(1, -4, 0, 44),

            BackgroundColor3 = self.Window.Theme.Element,
            BackgroundTransparency = 0.08,

            Text = "",

            AutoButtonColor = false
        }, Page)

        AddCorner(Button, 8)

        local Label = Create("TextLabel", {
            Size = UDim2.new(0.6, 0, 1, 0),
            Position = UDim2.fromOffset(12, 0),

            BackgroundTransparency = 1,

            Text = options.Title or "Keybind",

            TextColor3 = self.Window.Theme.Text,

            Font = Enum.Font.GothamMedium,
            TextSize = 12,

            TextXAlignment = Enum.TextXAlignment.Left
        }, Button)

        local KeyLabel = Create("TextLabel", {
            Size = UDim2.new(0.35, -10, 1, 0),
            Position = UDim2.new(0.65, 0, 0, 0),

            BackgroundTransparency = 1,

            Text = CurrentKey.Name,

            TextColor3 = self.Window.Theme.SubText,

            Font = Enum.Font.Gotham,
            TextSize = 11,

            TextXAlignment = Enum.TextXAlignment.Right
        }, Button)

        Button.MouseButton1Click:Connect(function()
            Listening = true
            KeyLabel.Text = "Press key..."
        end)

        UserInputService.InputBegan:Connect(function(input, processed)
            if Listening then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    CurrentKey = input.KeyCode
                    KeyLabel.Text = CurrentKey.Name
                    Listening = false
                end

                return
            end

            if processed then
                return
            end

            if input.KeyCode == CurrentKey then
                if options.Callback then
                    task.spawn(options.Callback)
                end
            end
        end)

        return {
            Set = function(_, key)
                CurrentKey = key
                KeyLabel.Text = key.Name
            end,

            Get = function()
                return CurrentKey
            end
        }
    end

    return Tab
end

return TransparentUI

Example

local Library = loadstring(game:HttpGet("YOUR_RAW_LIBRARY_URL"))()

local Window = Library:CreateWindow({
    Title = "My Hub"
})

local Main = Window:CreateTab("Main")

Main:AddSection("Automation")

Main:AddToggle({
    Title = "Auto Farm",
    Default = false,
    Callback = function(enabled)
        print("Auto Farm:", enabled)
    end
})

Main:AddSlider({
    Title = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(value)
        print("Speed:", value)
    end
})

Main:AddDropdown({
    Title = "Mode",
    Values = {
        "Safe",
        "Fast",
        "Instant"
    },
    Default = "Safe",
    Callback = function(value)
        print("Mode:", value)
    end
})

Main:AddTextbox({
    Title = "Username",
    Placeholder = "Enter username...",
    Callback = function(text)
        print(text)
    end
})

Main:AddKeybind({
    Title = "Toggle UI",
    Default = Enum.KeyCode.RightShift,
    Callback = function()
        print("Key pressed")
    end
})

Main:AddButton({
    Title = "Test Notification",
    Callback = function()
        Window:Notify({
            Title = "Success",
            Content = "This is a transparent UI notification.",
            Duration = 3
        })
    end
})

This version has no Sovereign Hub branding, no logo requirement, and no external WindUI dependency, so it can be published as a generic public UI library.
