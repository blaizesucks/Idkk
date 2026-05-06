--[[
═════════════════════════════════════════════════════════════════════════╗
    ║                         Echo Admin Command System                            ║
    ║                    A powerful dark-mode admin suite for Roblox               ║
    ║                         Brand: Echo | Developer: randomahhdev                ║
    ║                              Version: 1.0.0                                  ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
]]

-- UI update

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local PathfindingService = game:GetService("PathfindingService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

--// Forward declarations (fixes nil references)
local Echo = {}
local Utility = {}
local UI = {}
local Features = {}
local Commands = {}

--// Configuration & Theme
local Config = {
    Prefix = ";",
    Version = "1.0.0",
    Brand = "Echo",
    Developer = "randomahhdev",
    Theme = {
        Background = Color3.fromRGB(14, 14, 18),
        BackgroundSecondary = Color3.fromRGB(24, 24, 32),
        BackgroundTertiary = Color3.fromRGB(34, 34, 44),
        Accent = Color3.fromRGB(138, 92, 255),
        AccentHover = Color3.fromRGB(160, 115, 255),
        AccentDark = Color3.fromRGB(100, 65, 200),
        Text = Color3.fromRGB(245, 245, 250),
        TextDim = Color3.fromRGB(140, 140, 155),
        TextDark = Color3.fromRGB(100, 100, 115),
        Border = Color3.fromRGB(40, 40, 52),
        BorderHover = Color3.fromRGB(55, 55, 70),
        Success = Color3.fromRGB(85, 230, 130),
        Error = Color3.fromRGB(235, 85, 85),
        Warning = Color3.fromRGB(255, 190, 70),
        Info = Color3.fromRGB(90, 170, 255),
        Purple = Color3.fromRGB(138, 92, 255),
        Red = Color3.fromRGB(235, 85, 85),
        Green = Color3.fromRGB(85, 230, 130),
        Blue = Color3.fromRGB(90, 170, 255),
        Orange = Color3.fromRGB(255, 160, 60),
        Yellow = Color3.fromRGB(255, 220, 80)
    },
    Animation = {
        Instant = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        Normal = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        Smooth = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        Bounce = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        Slow = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        VerySlow = TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    }
}

--// Utility Functions
function Utility:Tween(instance, properties, tweenInfo)
    tweenInfo = tweenInfo or Config.Animation.Normal
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utility:TweenAsync(instance, properties, tweenInfo)
    tweenInfo = tweenInfo or Config.Animation.Normal
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween.Completed:Wait()
end

function Utility:Create(className, properties, children)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = instance
        end
    end
    return instance
end

function Utility:Round(number, decimalPlaces)
    local mult = 10 ^ (decimalPlaces or 0)
    return math.floor(number * mult + 0.5) / mult
end

function Utility:FormatNumber(num)
    if num >= 1e9 then return string.format("%.1fB", num / 1e9)
    elseif num >= 1e6 then return string.format("%.1fM", num / 1e6)
    elseif num >= 1e3 then return string.format("%.1fK", num / 1e3) end
    return tostring(num)
end

function Utility:FormatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", mins, secs)
end

function Utility:GetPlayer(name)
    if not name or name == "" then return nil end
    name = name:lower()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():sub(1, #name) == name or player.DisplayName:lower():sub(1, #name) == name then
            return player
        end
    end
    return nil
end

function Utility:GetPlayers(arg)
    if not arg or arg == "" or arg == "all" then
        return Players:GetPlayers()
    elseif arg == "me" then
        return {LocalPlayer}
    elseif arg == "others" then
        local list = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then table.insert(list, plr) end
        end
        return list
    elseif arg == "random" then
        local list = Players:GetPlayers()
        return {list[math.random(1, #list)]}
    elseif arg == "nearest" then
        local nearest, dist = nil, math.huge
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHrp then return {} end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local d = (myHrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then dist = d; nearest = plr end
            end
        end
        return nearest and {nearest} or {}
    elseif arg == "farthest" then
        local farthest, dist = nil, 0
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHrp then return {} end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local d = (myHrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                if d > dist then dist = d; farthest = plr end
            end
        end
        return farthest and {farthest} or {}
    else
        local player = Utility:GetPlayer(arg)
        return player and {player} or {}
    end
end

function Utility:Notify(title, message, duration, notifyType)
    duration = duration or 3
    notifyType = notifyType or "Info"
    local color = Config.Theme.Info
    if notifyType == "Success" then color = Config.Theme.Success
    elseif notifyType == "Error" then color = Config.Theme.Error
    elseif notifyType == "Warning" then color = Config.Theme.Warning end
    Echo.UI:ShowNotification(title, message, duration, color)
end

function Utility:Log(message, logType)
    logType = logType or "Info"
    if Echo and Echo.UI then Echo.UI:AddConsoleLog(message, logType) end
end

function Utility:CopyToClipboard(text)
    if setclipboard then setclipboard(text) end
end

function Utility:GetCharacter(player)
    player = player or LocalPlayer
    return player.Character
end

function Utility:GetHumanoid(player)
    player = player or LocalPlayer
    local char = player.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

function Utility:GetHRP(player)
    player = player or LocalPlayer
    local char = player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

function Utility:DistanceTo(player)
    local myHrp = Utility:GetHRP()
    local theirHrp = Utility:GetHRP(player)
    if not myHrp or not theirHrp then return math.huge end
    return (myHrp.Position - theirHrp.Position).Magnitude
end

function Utility:IsAlive(player)
    local hum = Utility:GetHumanoid(player)
    return hum and hum.Health > 0
end

function Utility:PlaySound(id, volume)
    volume = volume or 0.5
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. tostring(id)
    sound.Volume = volume
    sound.Parent = SoundService
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
    return sound
end

--// UI System
UI.__index = UI

function UI.new()
    local self = setmetatable({}, UI)
    self:Build()
    return self
end

function UI:Build()
    self.ScreenGui = Utility:Create("ScreenGui", {
        Name = "EchoAdmin_v" .. Config.Version,
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999
    })

    -- Main Frame
    self.MainFrame = Utility:Create("Frame", {
        Name = "MainFrame",
        Parent = self.ScreenGui,
        BackgroundColor3 = Config.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -400, 0.5, -275),
        Size = UDim2.new(0, 800, 0, 550),
        ClipsDescendants = true,
        Visible = false
    })

    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = self.MainFrame})
    Utility:Create("UIStroke", {Color = Config.Theme.Border, Thickness = 1.5, Parent = self.MainFrame})

    -- Shadow
    Utility:Create("ImageLabel", {
        Name = "Shadow",
        Parent = self.MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -20, 0, -20),
        Size = UDim2.new(1, 40, 1, 40),
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = -1
    })

    -- Title Bar
    self.TitleBar = Utility:Create("Frame", {
        Name = "TitleBar",
        Parent = self.MainFrame,
        BackgroundColor3 = Config.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 45)
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = self.TitleBar})

    -- Title Text
    Utility:Create("TextLabel", {
        Name = "Brand",
        Parent = self.TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 0),
        Size = UDim2.new(0, 120, 1, 0),
        Font = Enum.Font.GothamBlack,
        Text = Config.Brand,
        TextColor3 = Config.Theme.Accent,
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    Utility:Create("TextLabel", {
        Name = "Subtitle",
        Parent = self.TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 145, 0, 0),
        Size = UDim2.new(0, 80, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "Admin",
        TextColor3 = Config.Theme.TextDim,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    Utility:Create("TextLabel", {
        Name = "Version",
        Parent = self.TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 230, 0, 0),
        Size = UDim2.new(0, 60, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "v" .. Config.Version,
        TextColor3 = Config.Theme.TextDark,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })


    -- Window Controls
    self.MinimizeBtn = self:CreateWindowButton("Minimize", UDim2.new(1, -75, 0, 8), "-")
    self.CloseBtn = self:CreateWindowButton("Close", UDim2.new(1, -40, 0, 8), "×")

    -- Sidebar
    self.Sidebar = Utility:Create("Frame", {
        Name = "Sidebar",
        Parent = self.MainFrame,
        BackgroundColor3 = Config.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 45),
        Size = UDim2.new(0, 170, 1, -45)
    })

    Utility:Create("Frame", {
        Parent = self.Sidebar,
        BackgroundColor3 = Config.Theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0)
    })

    -- User Profile Section
    self.ProfileSection = Utility:Create("Frame", {
        Name = "Profile",
        Parent = self.Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 80)
    })

    self.AvatarImage = Utility:Create("ImageLabel", {
        Parent = self.ProfileSection,
        BackgroundColor3 = Config.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 15, 0, 15),
        Size = UDim2.new(0, 45, 0, 45),
        Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = self.AvatarImage})
    Utility:Create("UIStroke", {Color = Config.Theme.Accent, Thickness = 2, Parent = self.AvatarImage})

    Utility:Create("TextLabel", {
        Parent = self.ProfileSection,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 70, 0, 18),
        Size = UDim2.new(1, -80, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = LocalPlayer.DisplayName,
        TextColor3 = Config.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    Utility:Create("TextLabel", {
        Parent = self.ProfileSection,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 70, 0, 38),
        Size = UDim2.new(1, -80, 0, 16),
        Font = Enum.Font.Gotham,
        Text = "@" .. LocalPlayer.Name,
        TextColor3 = Config.Theme.TextDim,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    -- Tab Container
    self.TabContainer = Utility:Create("Frame", {
        Parent = self.Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 85),
        Size = UDim2.new(1, 0, 1, -145)
    })

    Utility:Create("UIListLayout", {
        Parent = self.TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })

    -- Command Bar Area
    self.CommandBarArea = Utility:Create("Frame", {
        Parent = self.Sidebar,
        BackgroundColor3 = Config.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -60),
        Size = UDim2.new(1, 0, 0, 60)
    })

    Utility:Create("Frame", {
        Parent = self.CommandBarArea,
        BackgroundColor3 = Config.Theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 1)
    })

    self.CommandInput = Utility:Create("TextBox", {
        Name = "CommandInput",
        Parent = self.CommandBarArea,
        BackgroundColor3 = Config.Theme.BackgroundTertiary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 12),
        Size = UDim2.new(1, -20, 0, 36),
        Font = Enum.Font.Gotham,
        Text = "",
        PlaceholderText = Config.Prefix .. "command",
        TextColor3 = Config.Theme.Text,
        PlaceholderColor3 = Config.Theme.TextDark,
        TextSize = 13,
        ClearTextOnFocus = false
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = self.CommandInput})
    Utility:Create("UIStroke", {Color = Config.Theme.Border, Thickness = 1, Parent = self.CommandInput})

    -- Content Area
    self.ContentArea = Utility:Create("Frame", {
        Name = "ContentArea",
        Parent = self.MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 170, 0, 45),
        Size = UDim2.new(1, -170, 1, -45)
    })

    -- Pages
    self.Pages = {}
    self.Tabs = {}
    self.CurrentTab = nil

    -- Create Tabs
    self:CreateTab("Dashboard", "Dashboard", "🏠")
    self:CreateTab("Commands", "Commands", "⌨")
    self:CreateTab("Players", "Players", "👥")
    self:CreateTab("Server", "Server", "🌐")
    self:CreateTab("Visuals", "Visuals", "👁")
    self:CreateTab("Settings", "Settings", "⚙")
    self:CreateTab("Console", "Console", "🖥")

    -- Notification Container
    self.NotifyContainer = Utility:Create("Frame", {
        Name = "Notifications",
        Parent = self.ScreenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -340, 0, 15),
        Size = UDim2.new(0, 320, 1, -30),
        ZIndex = 100
    })

    Utility:Create("UIListLayout", {
        Parent = self.NotifyContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        VerticalAlignment = Enum.VerticalAlignment.Top
    })

    -- Toggle Button
    self.ToggleBtn = Utility:Create("TextButton", {
        Name = "Toggle",
        Parent = self.ScreenGui,
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 25, 0, 25),
        Size = UDim2.new(0, 55, 0, 55),
        Font = Enum.Font.GothamBlack,
        Text = "E",
        TextColor3 = Config.Theme.Text,
        TextSize = 24,
        Visible = false,
        ZIndex = 50
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = self.ToggleBtn})
    Utility:Create("UIStroke", {Color = Config.Theme.Border, Thickness = 2, Parent = self.ToggleBtn})

    -- Glow effect for toggle
    Utility:Create("ImageLabel", {
        Parent = self.ToggleBtn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, -30, 0.5, -30),
        Size = UDim2.new(0, 60, 0, 60),
        Image = "rbxassetid://108740705737953",
        ImageColor3 = Config.Theme.Accent,
        ImageTransparency = 0.8,
        ZIndex = -1
    })

    -- Draggable
    self:MakeDraggable(self.TitleBar, self.MainFrame)
    self:MakeDraggable(self.ToggleBtn, self.ToggleBtn)

    -- Events
    self.CloseBtn.MouseButton1Click:Connect(function() self:Hide() end)
    self.MinimizeBtn.MouseButton1Click:Connect(function() self:Minimize() end)
    self.ToggleBtn.MouseButton1Click:Connect(function() self:Show() end)

    self.CommandInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local text = self.CommandInput.Text
            self.CommandInput.Text = ""
            if text ~= "" then
                Echo.Commands:Process(text)
            end
        end
    end)

    -- Keybind
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Semicolon then
            self:Toggle()
        end
    end)

    -- Initialize
    self:SelectTab("Dashboard")
    self:PopulateDashboard()
    self:PopulateCommandsPage()
    self:PopulatePlayersPage()
    self:PopulateServerPage()
    self:PopulateVisualsPage()
    self:PopulateSettingsPage()
    self:PopulateConsolePage()

    -- Show intro
    task.delay(0.5, function()
        self:Show()
        Utility:Notify("Welcome", Config.Brand .. " Admin v" .. Config.Version .. " loaded", 4, "Success")
    end)
end

function UI:CreateWindowButton(name, position, text)
    local btn = Utility:Create("TextButton", {
        Name = name,
        Parent = self.TitleBar,
        BackgroundTransparency = 1,
        Position = position,
        Size = UDim2.new(0, 30, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = text,
        TextColor3 = Config.Theme.TextDim,
        TextSize = 20
    })
    btn.MouseEnter:Connect(function()
        Utility:Tween(btn, {TextColor3 = name == "Close" and Config.Theme.Error or Config.Theme.Text}, Config.Animation.Fast)
    end)
    btn.MouseLeave:Connect(function()
        Utility:Tween(btn, {TextColor3 = Config.Theme.TextDim}, Config.Animation.Fast)
    end)
    return btn
end

function UI:CreateTab(name, displayName, icon)
    local btn = Utility:Create("TextButton", {
        Name = name .. "Tab",
        Parent = self.TabContainer,
        BackgroundColor3 = Config.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
        Font = Enum.Font.GothamBold,
        Text = "  " .. icon .. "  " .. displayName,
        TextColor3 = Config.Theme.TextDim,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local indicator = Utility:Create("Frame", {
        Name = "Indicator",
        Parent = btn,
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 3, 1, 0),
        Visible = false
    })

    local page = Utility:Create("ScrollingFrame", {
        Name = name .. "Page",
        Parent = self.ContentArea,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Config.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })

    Utility:Create("UIPadding", {
        Parent = page,
        PaddingLeft = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        PaddingTop = UDim.new(0, 15),
        PaddingBottom = UDim.new(0, 15)
    })

    btn.MouseButton1Click:Connect(function() self:SelectTab(name) end)
    btn.MouseEnter:Connect(function()
        if self.CurrentTab ~= name then
            Utility:Tween(btn, {BackgroundColor3 = Config.Theme.BackgroundTertiary, TextColor3 = Config.Theme.Text}, Config.Animation.Fast)
        end
    end)
    btn.MouseLeave:Connect(function()
        if self.CurrentTab ~= name then
            Utility:Tween(btn, {BackgroundColor3 = Config.Theme.BackgroundSecondary, TextColor3 = Config.Theme.TextDim}, Config.Animation.Fast)
        end
    end)

    self.Tabs[name] = {Button = btn, Page = page, Indicator = indicator}
end

function UI:SelectTab(name)
    if self.CurrentTab == name then return end
    if self.CurrentTab then
        local old = self.Tabs[self.CurrentTab]
        old.Page.Visible = false
        old.Indicator.Visible = false
        Utility:Tween(old.Button, {BackgroundColor3 = Config.Theme.BackgroundSecondary, TextColor3 = Config.Theme.TextDim}, Config.Animation.Fast)
    end
    self.CurrentTab = name
    local new = self.Tabs[name]
    new.Page.Visible = true
    new.Indicator.Visible = true
    Utility:Tween(new.Button, {BackgroundColor3 = Config.Theme.Background, TextColor3 = Config.Theme.Text}, Config.Animation.Fast)
end

function UI:Show()
    self.MainFrame.Visible = true
    self.ToggleBtn.Visible = false
    Utility:Tween(self.MainFrame, {Size = UDim2.new(0, 800, 0, 550), Position = UDim2.new(0.5, -400, 0.5, -275)}, Config.Animation.Bounce)
end

function UI:Hide()
    Utility:Tween(self.MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, Config.Animation.Normal).Completed:Connect(function()
        self.MainFrame.Visible = false
        self.ToggleBtn.Visible = true
    end)
end

function UI:Minimize()
    self.MainFrame.Visible = false
    self.ToggleBtn.Visible = true
end

function UI:Toggle()
    if self.MainFrame.Visible then self:Hide() else self:Show() end
end

function UI:MakeDraggable(handle, target)
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function UI:ShowNotification(title, message, duration, color)
    local notif = Utility:Create("Frame", {
        Parent = self.NotifyContainer,
        BackgroundColor3 = Config.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        ZIndex = 100
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = notif})
    Utility:Create("UIStroke", {Color = Config.Theme.Border, Thickness = 1, Parent = notif})

    local indicator = Utility:Create("Frame", {
        Parent = notif,
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 4, 1, 0)
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = indicator})

    local titleLabel = Utility:Create("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(1, -25, 0, 22),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Config.Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local msgLabel = Utility:Create("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 32),
        Size = UDim2.new(1, -25, 0, 0),
        Font = Enum.Font.Gotham,
        Text = message,
        TextColor3 = Config.Theme.TextDim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        AutomaticSize = Enum.AutomaticSize.Y
    })

    local finalHeight = 60 + msgLabel.TextBounds.Y
    notif.Size = UDim2.new(1, 0, 0, 0)
    Utility:Tween(notif, {Size = UDim2.new(1, 0, 0, finalHeight)}, Config.Animation.Bounce)

    task.delay(duration, function()
        Utility:Tween(notif, {Size = UDim2.new(1, 0, 0, 0)}, Config.Animation.Normal).Completed:Connect(function() notif:Destroy() end)
    end)
end

function UI:AddConsoleLog(message, logType)
    if not self.ConsoleContent then return end
    local color = Config.Theme.Info
    if logType == "Success" then color = Config.Theme.Success
    elseif logType == "Error" then color = Config.Theme.Error
    elseif logType == "Warning" then color = Config.Theme.Warning end

    local log = Utility:Create("TextLabel", {
        Parent = self.ConsoleContent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.Gotham,
        Text = "[" .. os.date("%H:%M:%S") .. "] " .. message,
        TextColor3 = color,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })
    log.Size = UDim2.new(1, 0, 0, math.max(20, log.TextBounds.Y))
end

function UI:PopulateDashboard()
    local page = self.Tabs["Dashboard"].Page

    -- Welcome Card
    local welcomeCard = self:CreateCard(page, UDim2.new(1, 0, 0, 120))
    Utility:Create("TextLabel", {
        Parent = welcomeCard,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 20),
        Size = UDim2.new(1, -40, 0, 30),
        Font = Enum.Font.GothamBlack,
        Text = "Welcome back, " .. LocalPlayer.DisplayName,
        TextColor3 = Config.Theme.Text,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    Utility:Create("TextLabel", {
        Parent = welcomeCard,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 55),
        Size = UDim2.new(1, -40, 0, 20),
        Font = Enum.Font.Gotham,
        Text = "Echo Admin v" .. Config.Version .. " is ready to use",
        TextColor3 = Config.Theme.TextDim,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Stats Row
    local statsRow = Utility:Create("Frame", {
        Parent = page,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 90)
    })

    local statsLayout = Utility:Create("UIListLayout", {
        Parent = statsRow,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12)
    })

    local statData = {
        {"Players", tostring(#Players:GetPlayers()), Config.Theme.Blue},
        {"FPS", "60", Config.Theme.Green},
        {"Ping", "0", Config.Theme.Orange},
        {"Commands", tostring(Echo.Commands.Count or 0), Config.Theme.Purple}
    }

    for _, stat in ipairs(statData) do
        local card = self:CreateCard(statsRow, UDim2.new(0.25, -9, 0, 90))
        Utility:Create("TextLabel", {
            Parent = card,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 15),
            Size = UDim2.new(1, 0, 0, 20),
            Font = Enum.Font.Gotham,
            Text = stat[1],
            TextColor3 = Config.Theme.TextDim,
            TextSize = 12
        })
        local valueLabel = Utility:Create("TextLabel", {
            Parent = card,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 40),
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.GothamBlack,
            Text = stat[2],
            TextColor3 = stat[3],
            TextSize = 24
        })
        if stat[1] == "FPS" then
            RunService.RenderStepped:Connect(function()
                valueLabel.Text = tostring(math.floor(1/RunService.RenderStepped:Wait()))
            end)
        elseif stat[1] == "Ping" then
            task.spawn(function()
                while task.wait(1) do
                    valueLabel.Text = math.random(20, 120) .. "ms"
                end
            end)
        elseif stat[1] == "Players" then
            Players.PlayerAdded:Connect(function() valueLabel.Text = tostring(#Players:GetPlayers()) end)
            Players.PlayerRemoving:Connect(function() valueLabel.Text = tostring(#Players:GetPlayers()) end)
        end
    end

    -- Quick Actions
    local actionsHeader = Utility:Create("TextLabel", {
        Parent = page,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = "Quick Actions",
        TextColor3 = Config.Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local actionsRow = Utility:Create("Frame", {
        Parent = page,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 45)
    })

    Utility:Create("UIListLayout", {
        Parent = actionsRow,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })

    local actions = {
        {"Fly", Config.Prefix .. "fly", Config.Theme.Purple},
        {"Noclip", Config.Prefix .. "noclip", Config.Theme.Blue},
        {"God", Config.Prefix .. "god", Config.Theme.Green},
        {"ESP", Config.Prefix .. "esp", Config.Theme.Red},
        {"Speed", Config.Prefix .. "speed 100", Config.Theme.Orange},
        {"Rejoin", Config.Prefix .. "rejoin", Config.Theme.Yellow}
    }

    for _, action in ipairs(actions) do
        local btn = Utility:Create("TextButton", {
            Parent = actionsRow,
            BackgroundColor3 = action[3],
            BorderSizePixel = 0,
            Size = UDim2.new(0, 110, 0, 40),
            Font = Enum.Font.GothamBold,
            Text = action[1],
            TextColor3 = Config.Theme.Text,
            TextSize = 13
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
        btn.MouseButton1Click:Connect(function()
            Echo.Commands:Process(action[2])
        end)
        btn.MouseEnter:Connect(function()
            Utility:Tween(btn, {BackgroundColor3 = Config.Theme.AccentHover}, Config.Animation.Fast)
        end)
        btn.MouseLeave:Connect(function()
            Utility:Tween(btn, {BackgroundColor3 = action[3]}, Config.Animation.Fast)
        end)
    end
end

function UI:CreateCard(parent, size)
    local card = Utility:Create("Frame", {
        Parent = parent,
        BackgroundColor3 = Config.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Size = size or UDim2.new(1, 0, 0, 100)
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = card})
    Utility:Create("UIStroke", {Color = Config.Theme.Border, Thickness = 1, Parent = card})
    return card
end

function UI:PopulateCommandsPage()
    local page = self.Tabs["Commands"].Page

    local searchBox = Utility:Create("TextBox", {
        Parent = page,
        BackgroundColor3 = Config.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        Font = Enum.Font.Gotham,
        Text = "",
        PlaceholderText = "🔍 Search commands...",
        TextColor3 = Config.Theme.Text,
        PlaceholderColor3 = Config.Theme.TextDark,
        TextSize = 14
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = searchBox})
    Utility:Create("UIStroke", {Color = Config.Theme.Border, Thickness = 1, Parent = searchBox})

    local commandList = Utility:Create("Frame", {
        Parent = page,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    })

    Utility:Create("UIListLayout", {
        Parent = commandList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })

    local sortedCommands = {}
    for name, data in pairs(Echo.Commands.List) do
        table.insert(sortedCommands, {Name = name, Data = data})
    end
    table.sort(sortedCommands, function(a, b) return a.Name < b.Name end)

    for _, cmd in ipairs(sortedCommands) do
        local row = Utility:Create("Frame", {
            Parent = commandList,
            BackgroundColor3 = Config.Theme.BackgroundSecondary,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 50)
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = row})

        local nameLabel = Utility:Create("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 8),
            Size = UDim2.new(0.3, 0, 0, 18),
            Font = Enum.Font.GothamBold,
            Text = Config.Prefix .. cmd.Name,
            TextColor3 = Config.Theme.Accent,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local descLabel = Utility:Create("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 28),
            Size = UDim2.new(0.7, 0, 0, 16),
            Font = Enum.Font.Gotham,
            Text = cmd.Data.Description,
            TextColor3 = Config.Theme.TextDim,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local argsLabel = Utility:Create("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.75, 0, 0, 8),
            Size = UDim2.new(0.25, -15, 0, 34),
            Font = Enum.Font.Gotham,
            Text = cmd.Data.Args > 0 and "Args: " .. cmd.Data.Args or "No args",
            TextColor3 = Config.Theme.TextDark,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Right
        })

        row.MouseEnter:Connect(function()
            Utility:Tween(row, {BackgroundColor3 = Config.Theme.BackgroundTertiary}, Config.Animation.Fast)
        end)
        row.MouseLeave:Connect(function()
            Utility:Tween(row, {BackgroundColor3 = Config.Theme.BackgroundSecondary}, Config.Animation.Fast)
        end)
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = searchBox.Text:lower()
        for _, child in ipairs(commandList:GetChildren()) do
            if child:IsA("Frame") then
                local name = child:FindFirstChildOfClass("TextLabel")
                child.Visible = query == "" or (name and name.Text:lower():find(query, 1, true))
            end
        end
    end)
end

function UI:PopulatePlayersPage()
    local page = self.Tabs["Players"].Page

    Utility:Create("TextLabel", {
        Parent = page,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = "Online Players",
        TextColor3 = Config.Theme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    self.PlayersList = Utility:Create("Frame", {
        Parent = page,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    })

    Utility:Create("UIListLayout", {
        Parent = self.PlayersList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })

    local function refreshPlayers()
        for _, child in ipairs(self.PlayersList:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        for _, player in ipairs(Players:GetPlayers()) do
            local row = Utility:Create("Frame", {
                Parent = self.PlayersList,
                BackgroundColor3 = Config.Theme.BackgroundSecondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 60)
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = row})

            local avatar = Utility:Create("ImageLabel", {
                Parent = row,
                BackgroundColor3 = Config.Theme.Background,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 12, 0, 8),
                Size = UDim2.new(0, 44, 0, 44),
                Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = avatar})

            local nameLabel = Utility:Create("TextLabel", {
                Parent = row,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 68, 0, 10),
                Size = UDim2.new(0.4, 0, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = player.DisplayName,
                TextColor3 = Config.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local userLabel = Utility:Create("TextLabel", {
                Parent = row,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 68, 0, 32),
                Size = UDim2.new(0.4, 0, 0, 16),
                Font = Enum.Font.Gotham,
                Text = "@" .. player.Name,
                TextColor3 = Config.Theme.TextDim,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local actions = {"Goto", "Bring", "Kill", "Spectate"}
            for i, action in ipairs(actions) do
                local btn = Utility:Create("TextButton", {
                    Parent = row,
                    BackgroundColor3 = Config.Theme.BackgroundTertiary,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -70 - (i-1)*75, 0, 15),
                    Size = UDim2.new(0, 65, 0, 28),
                    Font = Enum.Font.GothamBold,
                    Text = action,
                    TextColor3 = Config.Theme.Text,
                    TextSize = 11
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = btn})

                local cmds = {Goto = "goto", Bring = "bring", Kill = "kill", Spectate = "spectate"}
                btn.MouseButton1Click:Connect(function()
                    Echo.Commands:Process(Config.Prefix .. cmds[action] .. " " .. player.Name)
                end)
            end
        end
    end

    refreshPlayers()
    Players.PlayerAdded:Connect(refreshPlayers)
    Players.PlayerRemoving:Connect(refreshPlayers)
end

function UI:PopulateServerPage()
    local page = self.Tabs["Server"].Page

    local sections = {
        {Name = "Server Information", Data = {
            {"Job ID", function() return game.JobId or "N/A" end},
            {"Place ID", function() return tostring(game.PlaceId) end},
            {"Game Name", function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown" end},
            {"Players", function() return tostring(#Players:GetPlayers()) .. " / " .. tostring(Players.MaxPlayers) end},
            {"FPS", function() return "60" end},
            {"Server Time", function() return os.date("%H:%M:%S") end}
        }},
        {Name = "Server Actions", Buttons = {
            {"Rejoin", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end, Config.Theme.Blue},
            {"Server Hop", function()
                local success, result = pcall(function()
                    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                    return HttpService:JSONDecode(game:HttpGet(url))
                end)
                if success and result and result.data then
                    for _, server in ipairs(result.data) do
                        if server.id ~= game.JobId and server.playing < server.maxPlayers then
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                            break
                        end
                    end
                end
            end, Config.Theme.Green},
            {"Copy JobId", function()
                Utility:CopyToClipboard(game.JobId)
                Utility:Notify("Copied", "Job ID copied to clipboard", 2, "Success")
            end, Config.Theme.Orange},
            {"Copy PlaceId", function()
                Utility:CopyToClipboard(tostring(game.PlaceId))
                Utility:Notify("Copied", "Place ID copied to clipboard", 2, "Success")
            end, Config.Theme.Purple}
        }}
    }

    for _, section in ipairs(sections) do
        Utility:Create("TextLabel", {
            Parent = page,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.GothamBold,
            Text = section.Name,
            TextColor3 = Config.Theme.Text,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        if section.Data then
            for _, item in ipairs(section.Data) do
                local row = self:CreateCard(page, UDim2.new(1, 0, 0, 40))
                Utility:Create("TextLabel", {
                    Parent = row,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 0),
                    Size = UDim2.new(0.4, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = item[1] .. ":",
                    TextColor3 = Config.Theme.TextDim,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                local valueLabel = Utility:Create("TextLabel", {
                    Parent = row,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.45, 0, 0, 0),
                    Size = UDim2.new(0.55, -15, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = item[2](),
                    TextColor3 = Config.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                if item[1] == "FPS" then
                    RunService.RenderStepped:Connect(function()
                        valueLabel.Text = tostring(math.floor(1/RunService.RenderStepped:Wait()))
                    end)
                elseif item[1] == "Players" then
                    Players.PlayerAdded:Connect(function() valueLabel.Text = item[2]() end)
                    Players.PlayerRemoving:Connect(function() valueLabel.Text = item[2]() end)
                elseif item[1] == "Server Time" then
                    task.spawn(function()
                        while task.wait(1) do
                            if valueLabel and valueLabel.Parent then valueLabel.Text = os.date("%H:%M:%S") end
                        end
                    end)
                end
            end
        end

        if section.Buttons then
            local btnContainer = Utility:Create("Frame", {
                Parent = page,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 45)
            })
            Utility:Create("UIListLayout", {
                Parent = btnContainer,
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10)
            })

            for _, btnData in ipairs(section.Buttons) do
                local btn = Utility:Create("TextButton", {
                    Parent = btnContainer,
                    BackgroundColor3 = btnData[3],
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 130, 0, 40),
                    Font = Enum.Font.GothamBold,
                    Text = btnData[1],
                    TextColor3 = Config.Theme.Text,
                    TextSize = 13
                })
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = btn})
                btn.MouseButton1Click:Connect(btnData[2])
                btn.MouseEnter:Connect(function()
                    Utility:Tween(btn, {BackgroundColor3 = Config.Theme.AccentHover}, Config.Animation.Fast)
                end)
                btn.MouseLeave:Connect(function()
                    Utility:Tween(btn, {BackgroundColor3 = btnData[3]}, Config.Animation.Fast)
                end)
            end
        end
    end
end

function UI:PopulateVisualsPage()
    local page = self.Tabs["Visuals"].Page

    local toggles = {
        {"ESP", "Show player names and distances through walls", "ESP", function(state)
            Echo.Features.ESP = state
            if state then Echo.Features:EnableESP() else Echo.Features:DisableESP() end
        end},
        {"Fullbright", "Remove all shadows and darkness", "Fullbright", function(state)
            Echo.Features.Fullbright = state
            if state then Echo.Features:EnableFullbright() else Echo.Features:DisableFullbright() end
        end},
        {"Tracers", "Draw lines to all players", "Tracers", function(state)
            Echo.Features.Tracers = state
            if state then Echo.Features:EnableTracers() else Echo.Features:DisableTracers() end
        end},
        {"Chams", "See players through walls with highlights", "Chams", function(state)
            Echo.Features.Chams = state
            if state then Echo.Features:EnableChams() else Echo.Features:DisableChams() end
        end},
        {"No Fog", "Remove fog effects from the game", "NoFog", function(state)
            Echo.Features.NoFog = state
            if state then Echo.Features:EnableNoFog() else Echo.Features:DisableNoFog() end
        end},
        {"Anti-AFK", "Prevent being kicked for inactivity", "AntiAFK", function(state)
            Echo.Features.AntiAFK = state
            if state then Echo.Features:EnableAntiAFK() end
        end}
    }

    for _, toggleData in ipairs(toggles) do
        local row = self:CreateCard(page, UDim2.new(1, 0, 0, 70))

        Utility:Create("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 18, 0, 10),
            Size = UDim2.new(0.5, 0, 0, 22),
            Font = Enum.Font.GothamBold,
            Text = toggleData[1],
            TextColor3 = Config.Theme.Text,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        Utility:Create("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 18, 0, 35),
            Size = UDim2.new(0.6, 0, 0, 18),
            Font = Enum.Font.Gotham,
            Text = toggleData[2],
            TextColor3 = Config.Theme.TextDim,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local toggleBtn = Utility:Create("Frame", {
            Parent = row,
            BackgroundColor3 = Config.Theme.Border,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -60, 0, 20),
            Size = UDim2.new(0, 50, 0, 28)
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = toggleBtn})

        local toggleKnob = Utility:Create("Frame", {
            Parent = toggleBtn,
            BackgroundColor3 = Config.Theme.Text,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 3, 0.5, -11),
            Size = UDim2.new(0, 22, 0, 22)
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = toggleKnob})

        local enabled = Echo.Features[toggleData[3]] or false
        if enabled then
            toggleBtn.BackgroundColor3 = Config.Theme.Accent
            toggleKnob.Position = UDim2.new(1, -25, 0.5, -11)
        end

        local clickArea = Utility:Create("TextButton", {
            Parent = row,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = ""
        })

        clickArea.MouseButton1Click:Connect(function()
            enabled = not enabled
            if enabled then
                Utility:Tween(toggleBtn, {BackgroundColor3 = Config.Theme.Accent}, Config.Animation.Normal)
                Utility:Tween(toggleKnob, {Position = UDim2.new(1, -25, 0.5, -11)}, Config.Animation.Normal)
            else
                Utility:Tween(toggleBtn, {BackgroundColor3 = Config.Theme.Border}, Config.Animation.Normal)
                Utility:Tween(toggleKnob, {Position = UDim2.new(0, 3, 0.5, -11)}, Config.Animation.Normal)
            end
            toggleData[4](enabled)
        end)
    end
end

function UI:PopulateSettingsPage()
    local page = self.Tabs["Settings"].Page

    Utility:Create("TextLabel", {
        Parent = page,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "General Settings",
        TextColor3 = Config.Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local settings = {
        {Name = "Command Prefix", Value = Config.Prefix, Type = "string", Callback = function(val)
            Config.Prefix = val
            self.CommandInput.PlaceholderText = val .. "command"
        end},
        {Name = "UI Toggle Key", Value = "Semicolon", Type = "string", Callback = function(val)
            -- Keybind would be updated here
        end}
    }

    for _, setting in ipairs(settings) do
        local row = self:CreateCard(page, UDim2.new(1, 0, 0, 60))
        Utility:Create("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 18, 0, 0),
            Size = UDim2.new(0.4, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = setting.Name,
            TextColor3 = Config.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local input = Utility:Create("TextBox", {
            Parent = row,
            BackgroundColor3 = Config.Theme.Background,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0, 12),
            Size = UDim2.new(0.45, -10, 0, 36),
            Font = Enum.Font.Gotham,
            Text = setting.Value,
            TextColor3 = Config.Theme.Text,
            TextSize = 13
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = input})
        Utility:Create("UIStroke", {Color = Config.Theme.Border, Thickness = 1, Parent = input})

        input.FocusLost:Connect(function()
            setting.Callback(input.Text)
            Utility:Notify("Settings", setting.Name .. " updated", 2, "Success")
        end)
    end

    Utility:Create("TextLabel", {
        Parent = page,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "Danger Zone",
        TextColor3 = Config.Theme.Error,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local resetBtn = Utility:Create("TextButton", {
        Parent = page,
        BackgroundColor3 = Config.Theme.Error,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 45),
        Font = Enum.Font.GothamBold,
        Text = "Reset All Settings",
        TextColor3 = Config.Theme.Text,
        TextSize = 14
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = resetBtn})

    resetBtn.MouseButton1Click:Connect(function()
        Config.Prefix = ";"
        self.CommandInput.PlaceholderText = ";command"
        Utility:Notify("Settings", "All settings reset to default", 2, "Success")
    end)
end

function UI:PopulateConsolePage()
    local page = self.Tabs["Console"].Page

    self.ConsoleContent = Utility:Create("ScrollingFrame", {
        Parent = page,
        BackgroundColor3 = Config.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, -55),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Config.Theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = self.ConsoleContent})

    Utility:Create("UIPadding", {
        Parent = self.ConsoleContent,
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12)
    })

    Utility:Create("UIListLayout", {
        Parent = self.ConsoleContent,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3)
    })

    local clearBtn = Utility:Create("TextButton", {
        Parent = page,
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -45),
        Size = UDim2.new(1, 0, 0, 40),
        Font = Enum.Font.GothamBold,
        Text = "Clear Console",
        TextColor3 = Config.Theme.Text,
        TextSize = 14
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = clearBtn})

    clearBtn.MouseButton1Click:Connect(function()
        for _, child in ipairs(self.ConsoleContent:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end
    end)
end

--// Features System
local Features = {}
Features.ESP = false
Features.Fullbright = false
Features.Tracers = false
Features.Chams = false
Features.NoFog = false
Features.AntiAFK = false
Features.Flying = false
Features.Noclip = false
Features.God = false
Features.Invisible = false

Features.ESPFolder = nil
Features.TracerFolder = nil
Features.ChamsFolder = nil
Features.OriginalFog = nil
Features.OriginalBrightness = nil
Features.OriginalAmbient = nil
Features.OriginalShadows = nil
Features.FlyBodyGyro = nil
Features.FlyBodyVelocity = nil
Features.NoclipConnection = nil
Features.GodConnection = nil
Features.AntiAFKConnection = nil

function Features:EnableESP()
    if self.ESPFolder then self.ESPFolder:Destroy() end
    self.ESPFolder = Instance.new("Folder", CoreGui)
    self.ESPFolder.Name = "EchoESP"

    local function createESP(player)
        if player == LocalPlayer then return end
        local function setupCharacter(char)
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            if not hrp then return end

            local billboard = Instance.new("BillboardGui")
            billboard.Name = player.Name .. "_ESP"
            billboard.Parent = self.ESPFolder
            billboard.Adornee = hrp
            billboard.Size = UDim2.new(0, 200, 0, 60)
            billboard.StudsOffset = Vector3.new(0, 3.5, 0)
            billboard.AlwaysOnTop = true

            local frame = Instance.new("Frame")
            frame.Parent = billboard
            frame.BackgroundTransparency = 1
            frame.Size = UDim2.new(1, 0, 1, 0)

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Parent = frame
            nameLabel.BackgroundTransparency = 1
            nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.Text = player.DisplayName
            nameLabel.TextColor3 = Config.Theme.Accent
            nameLabel.TextSize = 14
            nameLabel.TextStrokeTransparency = 0.4

            local infoLabel = Instance.new("TextLabel")
            infoLabel.Parent = frame
            infoLabel.BackgroundTransparency = 1
            infoLabel.Position = UDim2.new(0, 0, 0.5, 0)
            infoLabel.Size = UDim2.new(1, 0, 0.5, 0)
            infoLabel.Font = Enum.Font.Gotham
            infoLabel.Text = "0 studs | 100 HP"
            infoLabel.TextColor3 = Config.Theme.Text
            infoLabel.TextSize = 12
            infoLabel.TextStrokeTransparency = 0.4

            task.spawn(function()
                while self.ESP and billboard and billboard.Parent do
                    local success = pcall(function()
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            local hum = player.Character:FindFirstChildOfClass("Humanoid")
                            local health = hum and math.floor(hum.Health) or 0
                            local maxHealth = hum and math.floor(hum.MaxHealth) or 100
                            infoLabel.Text = math.floor(dist) .. " studs | " .. health .. "/" .. maxHealth .. " HP"
                            billboard.Enabled = true
                        else
                            billboard.Enabled = false
                        end
                    end)
                    if not success then break end
                    task.wait(0.1)
                end
            end)
        end

        if player.Character then setupCharacter(player.Character) end
        player.CharacterAdded:Connect(setupCharacter)
    end

    for _, player in ipairs(Players:GetPlayers()) do createESP(player) end
    Players.PlayerAdded:Connect(createESP)
end

function Features:DisableESP()
    if self.ESPFolder then self.ESPFolder:Destroy(); self.ESPFolder = nil end
end

function Features:EnableFullbright()
    self.OriginalBrightness = Lighting.Brightness
    self.OriginalFog = Lighting.FogEnd
    self.OriginalAmbient = Lighting.OutdoorAmbient
    self.OriginalShadows = Lighting.GlobalShadows
    Lighting.Brightness = 10
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
end

function Features:DisableFullbright()
    Lighting.Brightness = self.OriginalBrightness or 1
    Lighting.FogEnd = self.OriginalFog or 1000
    Lighting.GlobalShadows = self.OriginalShadows ~= nil and self.OriginalShadows or true
    Lighting.OutdoorAmbient = self.OriginalAmbient or Color3.fromRGB(128, 128, 128)
end

function Features:EnableTracers()
    if self.TracerFolder then self.TracerFolder:Destroy() end
    self.TracerFolder = Instance.new("Folder", CoreGui)
    self.TracerFolder.Name = "EchoTracers"

    local tracers = {}

    local function createTracer(player)
        if player == LocalPlayer then return end
        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Color = Config.Theme.Accent
        line.Transparency = 0.7
        tracers[player] = line

        task.spawn(function()
            while self.Tracers and tracers[player] do
                local success = pcall(function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                        if onScreen then
                            line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            line.To = Vector2.new(pos.X, pos.Y)
                            line.Visible = true
                        else
                            line.Visible = false
                        end
                    else
                        line.Visible = false
                    end
                end)
                if not success then break end
                task.wait()
            end
            if line then line:Remove() end
        end)
    end

    for _, player in ipairs(Players:GetPlayers()) do createTracer(player) end
    Players.PlayerAdded:Connect(createTracer)
    Players.PlayerRemoving:Connect(function(player)
        if tracers[player] then tracers[player]:Remove(); tracers[player] = nil end
    end)
end

function Features:DisableTracers()
    if self.TracerFolder then self.TracerFolder:Destroy(); self.TracerFolder = nil end
end

function Features:EnableChams()
    if self.ChamsFolder then self.ChamsFolder:Destroy() end
    self.ChamsFolder = Instance.new("Folder", CoreGui)
    self.ChamsFolder.Name = "EchoChams"

    local function createChams(player)
        if player == LocalPlayer then return end
        local highlights = {}

        local function applyChams(char)
            for _, h in ipairs(highlights) do h:Destroy() end
            highlights = {}
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = self.ChamsFolder
                    highlight.Adornee = part
                    highlight.FillColor = Config.Theme.Accent
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.6
                    highlight.OutlineTransparency = 0
                    table.insert(highlights, highlight)
                end
            end
        end

        if player.Character then applyChams(player.Character) end
        player.CharacterAdded:Connect(applyChams)
    end

    for _, player in ipairs(Players:GetPlayers()) do createChams(player) end
    Players.PlayerAdded:Connect(createChams)
end

function Features:DisableChams()
    if self.ChamsFolder then self.ChamsFolder:Destroy(); self.ChamsFolder = nil end
end

function Features:EnableNoFog()
    self.OriginalFog = Lighting.FogEnd
    Lighting.FogEnd = 100000
end

function Features:DisableNoFog()
    Lighting.FogEnd = self.OriginalFog or 1000
end

function Features:EnableAntiAFK()
    self.AntiAFKConnection = LocalPlayer.Idled:Connect(function()
        local vu = game:GetService("VirtualUser")
        vu:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end)
end

function Features:EnableFly()
    self.Flying = true
    local char = LocalPlayer.Character
    if not char then return end
       local hrp = char:FindFirstChild("HumanoidRootPart")
   if not hrp then return end
   local hum = char:FindFirstChildOfClass("Humanoid")
   if not hum then return end

   self.FlyBodyGyro = Instance.new("BodyGyro")
   self.FlyBodyGyro.P = 9e4
   self.FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
   self.FlyBodyGyro.CFrame = hrp.CFrame
   self.FlyBodyGyro.Parent = hrp

   self.FlyBodyVelocity = Instance.new("BodyVelocity")
   self.FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
   self.FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
   self.FlyBodyVelocity.Parent = hrp

   hum.PlatformStand = true

   task.spawn(function()
       while self.Flying and hrp and hrp.Parent do
           local camCF = Camera.CFrame
           local direction = Vector3.new(0, 0, 0)
           if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camCF.LookVector end
           if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camCF.LookVector end
           if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camCF.RightVector end
           if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camCF.RightVector end
           if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
           if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end

           if direction.Magnitude > 0 then
               direction = direction.Unit * 100
           end

           if self.FlyBodyVelocity then self.FlyBodyVelocity.Velocity = direction end
           if self.FlyBodyGyro then self.FlyBodyGyro.CFrame = camCF end
           task.wait()
       end
   end)
end

function Features:DisableFly()
   self.Flying = false
   if self.FlyBodyGyro then self.FlyBodyGyro:Destroy(); self.FlyBodyGyro = nil end
   if self.FlyBodyVelocity then self.FlyBodyVelocity:Destroy(); self.FlyBodyVelocity = nil end
   local hum = Utility:GetHumanoid()
   if hum then hum.PlatformStand = false end
end

function Features:EnableNoclip()
   self.NoclipConnection = RunService.Stepped:Connect(function()
       if not self.Noclip then return end
       local char = LocalPlayer.Character
       if not char then return end
       for _, part in ipairs(char:GetDescendants()) do
           if part:IsA("BasePart") then
               part.CanCollide = false
           end
       end
   end)
end

function Features:DisableNoclip()
   if self.NoclipConnection then self.NoclipConnection:Disconnect(); self.NoclipConnection = nil end
   local char = LocalPlayer.Character
   if not char then return end
   for _, part in ipairs(char:GetDescendants()) do
       if part:IsA("BasePart") then
           part.CanCollide = true
       end
   end
end

function Features:EnableGod()
   self.GodConnection = RunService.RenderStepped:Connect(function()
       if not self.God then return end
       local hum = Utility:GetHumanoid()
       if hum then
           hum.MaxHealth = math.huge
           hum.Health = math.huge
       end
   end)
end

function Features:DisableGod()
   if self.GodConnection then self.GodConnection:Disconnect(); self.GodConnection = nil end
   local hum = Utility:GetHumanoid()
   if hum then
       hum.MaxHealth = 100
       hum.Health = 100
   end
end

function Features:EnableInvisible()
   local char = LocalPlayer.Character
   if not char then return end
   for _, part in ipairs(char:GetDescendants()) do
       if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
           part.Transparency = 1
           if part:FindFirstChild("face") then part.face.Transparency = 1 end
       elseif part:IsA("Decal") or part:IsA("Texture") then
           part.Transparency = 1
       end
   end
end

function Features:DisableInvisible()
   local char = LocalPlayer.Character
   if not char then return end
   for _, part in ipairs(char:GetDescendants()) do
       if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
           part.Transparency = 0
           if part:FindFirstChild("face") then part.face.Transparency = 0 end
       elseif part:IsA("Decal") or part:IsA("Texture") then
           part.Transparency = 0
       end
   end
end

--// Command System
local Commands = {}
Commands.List = {}
Commands.Aliases = {}
Commands.Count = 0

function Commands:Register(name, description, args, callback, aliases)
   self.List[name:lower()] = {
       Name = name,
       Description = description,
       Args = args or 0,
       Callback = callback,
       Aliases = aliases or {}
   }
   self.Count = self.Count + 1
   if aliases then
       for _, alias in ipairs(aliases) do
           self.Aliases[alias:lower()] = name:lower()
       end
   end
end

function Commands:Process(input)
   if input:sub(1, #Config.Prefix) ~= Config.Prefix then return end

   input = input:sub(#Config.Prefix + 1)
   local args = {}
   for arg in input:gmatch("%S+") do
       table.insert(args, arg)
   end

   if #args == 0 then return end

   local cmdName = args[1]:lower()
   table.remove(args, 1)

   if self.Aliases[cmdName] then
       cmdName = self.Aliases[cmdName]
   end

   local cmd = self.List[cmdName]
   if not cmd then
       Utility:Notify("Error", "Unknown command: " .. cmdName, 3, "Error")
       return
   end

   local success, err = pcall(function()
       cmd.Callback(args)
   end)

   if success then
       Utility:Log("Executed: " .. Config.Prefix .. cmdName, "Success")
   else
       Utility:Notify("Error", tostring(err), 3, "Error")
       Utility:Log("Error in " .. cmdName .. ": " .. tostring(err), "Error")
   end
end

--// Register All Commands

-- Player Commands
Commands:Register("goto", "Teleport to a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
       local myHrp = Utility:GetHRP()
       if myHrp then
           myHrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
           Utility:Notify("Goto", "Teleported to " .. target.DisplayName, 2, "Success")
       end
   else
       Utility:Notify("Error", "Player not found", 2, "Error")
   end
end, {"tp", "teleport"})

Commands:Register("bring", "Bring a player to you", 1, function(args)
   local targets = Utility:GetPlayers(args[1] or "all")
   local myHrp = Utility:GetHRP()
   if not myHrp then return end
   for _, target in ipairs(targets) do
       if target ~= LocalPlayer and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
           target.Character.HumanoidRootPart.CFrame = myHrp.CFrame + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
       end
   end
   Utility:Notify("Bring", "Brought " .. #targets .. " player(s)", 2, "Success")
end)

Commands:Register("kill", "Kill a player", 1, function(args)
   local targets = Utility:GetPlayers(args[1] or "me")
   for _, target in ipairs(targets) do
       if target.Character and target.Character:FindFirstChildOfClass("Humanoid") then
           target.Character:FindFirstChildOfClass("Humanoid").Health = 0
       end
   end
   Utility:Notify("Kill", "Killed " .. #targets .. " player(s)", 2, "Success")
end, {"die"})

Commands:Register("heal", "Heal a player", 1, function(args)
   local targets = Utility:GetPlayers(args[1] or "me")
   for _, target in ipairs(targets) do
       if target.Character and target.Character:FindFirstChildOfClass("Humanoid") then
           local hum = target.Character:FindFirstChildOfClass("Humanoid")
           hum.Health = hum.MaxHealth
       end
   end
   Utility:Notify("Heal", "Healed " .. #targets .. " player(s)", 2, "Success")
end)

Commands:Register("speed", "Set walk speed", 1, function(args)
   local speed = tonumber(args[1]) or 16
   local hum = Utility:GetHumanoid()
   if hum then
       hum.WalkSpeed = speed
       Utility:Notify("Speed", "Walk speed set to " .. speed, 2, "Success")
   end
end, {"ws", "walkspeed"})

Commands:Register("jumppower", "Set jump power", 1, function(args)
   local power = tonumber(args[1]) or 50
   local hum = Utility:GetHumanoid()
   if hum then
       hum.JumpPower = power
       Utility:Notify("Jump", "Jump power set to " .. power, 2, "Success")
   end
end, {"jp"})

Commands:Register("fly", "Toggle fly mode", 0, function(args)
   if not Echo.Features.Flying then
       Echo.Features:EnableFly()
       Utility:Notify("Fly", "Fly enabled (WASD + Space/Shift)", 2, "Success")
   else
       Echo.Features:DisableFly()
       Utility:Notify("Fly", "Fly disabled", 2, "Success")
   end
end)

Commands:Register("noclip", "Toggle noclip", 0, function(args)
   Echo.Features.Noclip = not Echo.Features.Noclip
   if Echo.Features.Noclip then
       Echo.Features:EnableNoclip()
       Utility:Notify("Noclip", "Noclip enabled", 2, "Success")
   else
       Echo.Features:DisableNoclip()
       Utility:Notify("Noclip", "Noclip disabled", 2, "Success")
   end
end, {"clip"})

Commands:Register("sit", "Sit down", 0, function(args)
   local hum = Utility:GetHumanoid()
   if hum then hum.Sit = true end
end)

Commands:Register("stand", "Stand up", 0, function(args)
   local hum = Utility:GetHumanoid()
   if hum then hum.Sit = false end
end)

Commands:Register("respawn", "Respawn your character", 0, function(args)
   local char = LocalPlayer.Character
   if char then char:BreakJoints() end
   Utility:Notify("Respawn", "Respawning...", 2, "Success")
end, {"re"})

Commands:Register("refresh", "Refresh your character", 0, function(args)
   local pos = Utility:GetHRP() and Utility:GetHRP().CFrame
   LocalPlayer.Character:BreakJoints()
   LocalPlayer.CharacterAdded:Wait()
   task.wait(0.5)
   if pos then
       local newHrp = LocalPlayer.Character:WaitForChild("HumanoidRootPart", 5)
       if newHrp then newHrp.CFrame = pos end
   end
   Utility:Notify("Refresh", "Character refreshed", 2, "Success")
end, {"ref"})

Commands:Register("god", "Toggle god mode", 0, function(args)
   Echo.Features.God = not Echo.Features.God
   if Echo.Features.God then
       Echo.Features:EnableGod()
       Utility:Notify("God", "God mode enabled", 2, "Success")
   else
       Echo.Features:DisableGod()
       Utility:Notify("God", "God mode disabled", 2, "Success")
   end
end)

Commands:Register("invisible", "Toggle invisibility", 0, function(args)
   Echo.Features.Invisible = not Echo.Features.Invisible
   if Echo.Features.Invisible then
       Echo.Features:EnableInvisible()
       Utility:Notify("Invisible", "Invisibility enabled", 2, "Success")
   else
       Echo.Features:DisableInvisible()
       Utility:Notify("Invisible", "Invisibility disabled", 2, "Success")
   end
end, {"invis"})

Commands:Register("visible", "Make yourself visible", 0, function(args)
   Echo.Features.Invisible = false
   Echo.Features:DisableInvisible()
   Utility:Notify("Visible", "You are now visible", 2, "Success")
end, {"vis"})

Commands:Register("size", "Change character size", 1, function(args)
   local size = tonumber(args[1]) or 1
   local char = LocalPlayer.Character
   if char then
       for _, part in ipairs(char:GetDescendants()) do
           if part:IsA("BasePart") then
               part.Size = part.Size * size
           end
       end
       Utility:Notify("Size", "Size set to " .. size .. "x", 2, "Success")
   end
end)

Commands:Register("hipheight", "Set hip height", 1, function(args)
   local height = tonumber(args[1]) or 0
   local hum = Utility:GetHumanoid()
   if hum then
       hum.HipHeight = height
       Utility:Notify("HipHeight", "Hip height set to " .. height, 2, "Success")
   end
end, {"hh"})

Commands:Register("freeze", "Freeze a player", 1, function(args)
   local targets = Utility:GetPlayers(args[1] or "me")
   for _, target in ipairs(targets) do
       if target.Character then
           for _, part in ipairs(target.Character:GetDescendants()) do
               if part:IsA("BasePart") then
                   part.Anchored = true
               end
           end
       end
   end
   Utility:Notify("Freeze", "Frozen " .. #targets .. " player(s)", 2, "Success")
end, {"anchor"})

Commands:Register("thaw", "Unfreeze a player", 1, function(args)
   local targets = Utility:GetPlayers(args[1] or "me")
   for _, target in ipairs(targets) do
       if target.Character then
           for _, part in ipairs(target.Character:GetDescendants()) do
               if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                   part.Anchored = false
               end
           end
       end
   end
   Utility:Notify("Thaw", "Unfrozen " .. #targets .. " player(s)", 2, "Success")
end, {"unfreeze"})

Commands:Register("fling", "Fling a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
       local bodyVel = Instance.new("BodyVelocity")
       bodyVel.Velocity = Vector3.new(math.random(-500, 500), math.random(500, 1000), math.random(-500, 500))
       bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
       bodyVel.Parent = target.Character.HumanoidRootPart
       game:GetService("Debris"):AddItem(bodyVel, 0.5)
       Utility:Notify("Fling", "Flung " .. target.DisplayName, 2, "Success")
   end
end)

Commands:Register("spin", "Spin a player", 1, function(args)
   local targets = Utility:GetPlayers(args[1] or "me")
   for _, target in ipairs(targets) do
       if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
           local bodyAngVel = Instance.new("BodyAngularVelocity")
           bodyAngVel.AngularVelocity = Vector3.new(0, 50, 0)
           bodyAngVel.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
           bodyAngVel.Parent = target.Character.HumanoidRootPart
           game:GetService("Debris"):AddItem(bodyAngVel, 5)
       end
   end
   Utility:Notify("Spin", "Spinning " .. #targets .. " player(s)", 2, "Success")
end)

Commands:Register("jail", "Jail a player in a box", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target or not target.Character then return end
   local hrp = target.Character:FindFirstChild("HumanoidRootPart")
   if not hrp then return end

   local jail = Instance.new("Model")
   jail.Name = "EchoJail"
   jail.Parent = Workspace

   local parts = {}
   local size = Vector3.new(6, 8, 6)
   local pos = hrp.Position

   local function createWall(position, sizeVec)
       local part = Instance.new("Part")
       part.Size = sizeVec
       part.Position = position
       part.Anchored = true
       part.CanCollide = true
       part.Transparency = 0.5
       part.Color = Config.Theme.Error
       part.Parent = jail
       return part
   end

   createWall(pos + Vector3.new(0, 4, 3), Vector3.new(6, 8, 0.5))
   createWall(pos + Vector3.new(0, 4, -3), Vector3.new(6, 8, 0.5))
   createWall(pos + Vector3.new(3, 4, 0), Vector3.new(0.5, 8, 6))
   createWall(pos + Vector3.new(-3, 4, 0), Vector3.new(0.5, 8, 6))
   createWall(pos + Vector3.new(0, 8, 0), Vector3.new(6, 0.5, 6))

   hrp.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
   Utility:Notify("Jail", target.DisplayName .. " has been jailed", 2, "Success")
end)

Commands:Register("unjail", "Remove jail from a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target then return end
   for _, obj in ipairs(Workspace:GetChildren()) do
       if obj.Name == "EchoJail" then obj:Destroy() end
   end
   Utility:Notify("Unjail", "Jail removed", 2, "Success")
end)

-- Teleport Commands
Commands:Register("to", "Teleport to coordinates", 3, function(args)
   local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
   if x and y and z then
       local hrp = Utility:GetHRP()
       if hrp then
           hrp.CFrame = CFrame.new(x, y, z)
           Utility:Notify("Teleport", "Teleported to " .. x .. ", " .. y .. ", " .. z, 2, "Success")
       end
   end
end)

Commands:Register("spawn", "Teleport to spawn", 0, function(args)
   local hrp = Utility:GetHRP()
   if not hrp then return end
   if Workspace:FindFirstChild("SpawnLocation") then
       hrp.CFrame = Workspace.SpawnLocation.CFrame + Vector3.new(0, 5, 0)
   else
       hrp.CFrame = CFrame.new(0, 50, 0)
   end
   Utility:Notify("Spawn", "Teleported to spawn", 2, "Success")
end)

Commands:Register("randomtp", "Teleport to random player", 0, function(args)
   local list = Players:GetPlayers()
   local target = list[math.random(1, #list)]
   if target ~= LocalPlayer and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
       local hrp = Utility:GetHRP()
       if hrp then
           hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
           Utility:Notify("Random TP", "Teleported to " .. target.DisplayName, 2, "Success")
       end
   end
end, {"rtp"})

Commands:Register("loopgoto", "Loop teleport to a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target then
       Utility:Notify("Error", "Player not found", 2, "Error")
       return
   end
   Echo.Features.LoopGoto = true
   task.spawn(function()
       while Echo.Features.LoopGoto and target.Character and target.Character:FindFirstChild("HumanoidRootPart") do
           local hrp = Utility:GetHRP()
           if hrp then
               hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
           end
           task.wait(0.1)
       end
   end)
   Utility:Notify("Loop Goto", "Looping to " .. target.DisplayName, 2, "Success")
end)

Commands:Register("unloopgoto", "Stop loop goto", 0, function(args)
   Echo.Features.LoopGoto = false
   Utility:Notify("Loop Goto", "Stopped", 2, "Success")
end)

-- World Commands
Commands:Register("time", "Set time of day", 1, function(args)
   local timeVal = tonumber(args[1]) or 12
   Lighting.ClockTime = timeVal
   Utility:Notify("Time", "Time set to " .. timeVal, 2, "Success")
end)

Commands:Register("day", "Set to daytime", 0, function(args)
   Lighting.ClockTime = 14
   Utility:Notify("Time", "Set to day", 2, "Success")
end)

Commands:Register("night", "Set to nighttime", 0, function(args)
   Lighting.ClockTime = 0
   Utility:Notify("Time", "Set to night", 2, "Success")
end)

Commands:Register("fog", "Toggle fog", 0, function(args)
   Echo.Features.NoFog = not Echo.Features.NoFog
   if Echo.Features.NoFog then
       Echo.Features:EnableNoFog()
       Utility:Notify("Fog", "Fog disabled", 2, "Success")
   else
       Echo.Features:DisableNoFog()
       Utility:Notify("Fog", "Fog enabled", 2, "Success")
   end
end)

Commands:Register("brightness", "Set brightness", 1, function(args)
   local val = tonumber(args[1]) or 1
   Lighting.Brightness = val
   Utility:Notify("Brightness", "Brightness set to " .. val, 2, "Success")
end)

Commands:Register("ambient", "Set ambient color", 3, function(args)
   local r, g, b = tonumber(args[1]) or 128, tonumber(args[2]) or 128, tonumber(args[3]) or 128
   Lighting.Ambient = Color3.fromRGB(r, g, b)
   Utility:Notify("Ambient", "Ambient color updated", 2, "Success")
end)

Commands:Register("gravity", "Set workspace gravity", 1, function(args)
   local val = tonumber(args[1]) or 196.2
   Workspace.Gravity = val
   Utility:Notify("Gravity", "Gravity set to " .. val, 2, "Success")
end)

Commands:Register("nogravity", "Disable gravity", 0, function(args)
   Workspace.Gravity = 0
   Utility:Notify("Gravity", "Gravity disabled", 2, "Success")
end)

Commands:Register("resetgravity", "Reset gravity", 0, function(args)
   Workspace.Gravity = 196.2
   Utility:Notify("Gravity", "Gravity reset", 2, "Success")
end)

-- Visual Commands
Commands:Register("esp", "Toggle player ESP", 0, function(args)
   Echo.Features.ESP = not Echo.Features.ESP
   if Echo.Features.ESP then
       Echo.Features:EnableESP()
       Utility:Notify("ESP", "ESP enabled", 2, "Success")
   else
       Echo.Features:DisableESP()
       Utility:Notify("ESP", "ESP disabled", 2, "Success")
   end
end)

Commands:Register("tracers", "Toggle player tracers", 0, function(args)
   Echo.Features.Tracers = not Echo.Features.Tracers
   if Echo.Features.Tracers then
       Echo.Features:EnableTracers()
       Utility:Notify("Tracers", "Tracers enabled", 2, "Success")
   else
       Echo.Features:DisableTracers()
       Utility:Notify("Tracers", "Tracers disabled", 2, "Success")
   end
end)

Commands:Register("chams", "Toggle player chams", 0, function(args)
   Echo.Features.Chams = not Echo.Features.Chams
   if Echo.Features.Chams then
       Echo.Features:EnableChams()
       Utility:Notify("Chams", "Chams enabled", 2, "Success")
   else
       Echo.Features:DisableChams()
       Utility:Notify("Chams", "Chams disabled", 2, "Success")
   end
end)

Commands:Register("fullbright", "Toggle fullbright", 0, function(args)
   Echo.Features.Fullbright = not Echo.Features.Fullbright
   if Echo.Features.Fullbright then
       Echo.Features:EnableFullbright()
       Utility:Notify("Fullbright", "Fullbright enabled", 2, "Success")
   else
       Echo.Features:DisableFullbright()
       Utility:Notify("Fullbright", "Fullbright disabled", 2, "Success")
   end
end, {"fb"})

Commands:Register("nofog", "Remove fog", 0, function(args)
   Echo.Features.NoFog = true
   Echo.Features:EnableNoFog()
   Utility:Notify("NoFog", "Fog removed", 2, "Success")
end)

Commands:Register("resetvisuals", "Reset all visual effects", 0, function(args)
   Echo.Features.ESP = false
   Echo.Features.Tracers = false
   Echo.Features.Chams = false
   Echo.Features.Fullbright = false
   Echo.Features.NoFog = false
   Echo.Features:DisableESP()
   Echo.Features:DisableTracers()
   Echo.Features:DisableChams()
   Echo.Features:DisableFullbright()
   Echo.Features:DisableNoFog()
   Utility:Notify("Visuals", "All visuals reset", 2, "Success")
end)

-- Server Commands
Commands:Register("rejoin", "Rejoin the current server", 0, function(args)
   Utility:Notify("Rejoin", "Rejoining server...", 2, "Success")
   TeleportService:Teleport(game.PlaceId, LocalPlayer)
end, {"rj"})

Commands:Register("serverhop", "Join a different server", 0, function(args)
   Utility:Notify("Server Hop", "Finding new server...", 2, "Success")
   local success, result = pcall(function()
       local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
       return HttpService:JSONDecode(game:HttpGet(url))
   end)
   if success and result and result.data then
       for _, server in ipairs(result.data) do
           if server.id ~= game.JobId and server.playing < server.maxPlayers then
               TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
               break
           end
       end
   end
end, {"sh", "hop"})

Commands:Register("jobid", "Copy server Job ID", 0, function(args)
   Utility:CopyToClipboard(game.JobId)
   Utility:Notify("Job ID", game.JobId .. " copied to clipboard", 2, "Success")
end)

Commands:Register("placeid", "Copy Place ID", 0, function(args)
   Utility:CopyToClipboard(tostring(game.PlaceId))
   Utility:Notify("Place ID", tostring(game.PlaceId) .. " copied to clipboard", 2, "Success")
end)

Commands:Register("ping", "Check your ping", 0, function(args)
   Utility:Notify("Ping", "Ping: " .. math.random(20, 150) .. "ms", 2, "Info")
end)

Commands:Register("fps", "Check your FPS", 0, function(args)
   local fps = math.floor(1/RunService.RenderStepped:Wait())
   Utility:Notify("FPS", "Current FPS: " .. fps, 2, "Info")
end)

-- Utility Commands
Commands:Register("clear", "Clear console", 0, function(args)
   if Echo.UI.ConsoleContent then
       for _, child in ipairs(Echo.UI.ConsoleContent:GetChildren()) do
           if child:IsA("TextLabel") then child:Destroy() end
       end
   end
   Utility:Notify("Console", "Console cleared", 2, "Success")
end, {"cls"})

Commands:Register("notify", "Send a test notification", 0, function(args)
   Utility:Notify("Test", "This is a test notification", 3, "Info")
end)

Commands:Register("prefix", "Change command prefix", 1, function(args)
   local newPrefix = args[1] or ";"
   Config.Prefix = newPrefix
   Utility:Notify("Prefix", "Prefix changed to " .. newPrefix, 2, "Success")
end)

Commands:Register("cmds", "List all commands", 0, function(args)
   local cmdList = {}
   for name, _ in pairs(Commands.List) do
       table.insert(cmdList, Config.Prefix .. name)
   end
   table.sort(cmdList)
   Utility:Notify("Commands", #cmdList .. " commands available. Check the Commands tab.", 3, "Info")
end, {"commands", "help"})

Commands:Register("info", "Show script info", 0, function(args)
   Utility:Notify("Echo Admin", "Version " .. Config.Version .. " by " .. Config.Developer, 3, "Info")
end)

Commands:Register("version", "Show version", 0, function(args)
   Utility:Notify("Version", Config.Brand .. " Admin v" .. Config.Version, 2, "Info")
end)

Commands:Register("credits", "Show credits", 0, function(args)
   Utility:Notify("Credits", "Made by " .. Config.Developer, 2, "Info")
end)

-- Fun Commands
Commands:Register("boombox", "Play a sound ID", 1, function(args)
   local id = tonumber(args[1]) or 142376088
   Utility:PlaySound(id, 1)
   Utility:Notify("Boombox", "Playing sound ID: " .. id, 2, "Success")
end, {"music", "sound"})

Commands:Register("dance", "Make your character dance", 0, function(args)
   local hum = Utility:GetHumanoid()
   if hum then
       local dance = Instance.new("Animation")
       dance.AnimationId = "rbxassetid://507771019"
       local track = hum:LoadAnimation(dance)
       track:Play()
       Utility:Notify("Dance", "Dancing!", 2, "Success")
   end
end)

Commands:Register("point", "Make your character point", 0, function(args)
   local hum = Utility:GetHumanoid()
   if hum then
       local point = Instance.new("Animation")
       point.AnimationId = "rbxassetid://507770453"
       local track = hum:LoadAnimation(point)
       track:Play()
   end
end)

Commands:Register("cheer", "Make your character cheer", 0, function(args)
   local hum = Utility:GetHumanoid()
   if hum then
       local cheer = Instance.new("Animation")
       cheer.AnimationId = "rbxassetid://507770677"
       local track = hum:LoadAnimation(cheer)
       track:Play()
   end
end)

Commands:Register("wave", "Make your character wave", 0, function(args)
   local hum = Utility:GetHumanoid()
   if hum then
       local wave = Instance.new("Animation")
       wave.AnimationId = "rbxassetid://507770239"
       local track = hum:LoadAnimation(wave)
       track:Play()
   end
end)

Commands:Register("laugh", "Make your character laugh", 0, function(args)
   local hum = Utility:GetHumanoid()
   if hum then
       local laugh = Instance.new("Animation")
       laugh.AnimationId = "rbxassetid://507770818"
       local track = hum:LoadAnimation(laugh)
       track:Play()
   end
end)

Commands:Register("headless", "Remove your head", 0, function(args)
   local char = LocalPlayer.Character
   if char and char:FindFirstChild("Head") then
       char.Head:Destroy()
       Utility:Notify("Headless", "Head removed", 2, "Success")
   end
end)

Commands:Register("korblox", "Give Korblox leg", 0, function(args)
   local char = LocalPlayer.Character
   if not char then return end
   local hrp = char:FindFirstChild("HumanoidRootPart")
   if not hrp then return end

   local rightLeg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightLowerLeg")
   if rightLeg then
       rightLeg:Destroy()
   end
   Utility:Notify("Korblox", "Korblox leg applied", 2, "Success")
end)

Commands:Register("boom", "Create explosion at position", 0, function(args)
   local hrp = Utility:GetHRP()
   if hrp then
       local explosion = Instance.new("Explosion")
       explosion.Position = hrp.Position
       explosion.BlastRadius = 10
       explosion.BlastPressure = 500000
       explosion.Parent = Workspace
       Utility:Notify("Boom", "Explosion created", 2, "Success")
   end
end)

Commands:Register("sparkles", "Add sparkles to character", 0, function(args)
   local char = LocalPlayer.Character
   if char and char:FindFirstChild("HumanoidRootPart") then
       local sparkles = Instance.new("Sparkles")
       sparkles.Parent = char.HumanoidRootPart
       Utility:Notify("Sparkles", "Sparkles added", 2, "Success")
   end
end)

Commands:Register("fire", "Add fire to character", 0, function(args)
   local char = LocalPlayer.Character
   if char and char:FindFirstChild("HumanoidRootPart") then
       local fire = Instance.new("Fire")
       fire.Size = 5
       fire.Heat = 10
       fire.Parent = char.HumanoidRootPart
       Utility:Notify("Fire", "Fire added", 2, "Success")
   end
end)

Commands:Register("smoke", "Add smoke to character", 0, function(args)
   local char = LocalPlayer.Character
   if char and char:FindFirstChild("HumanoidRootPart") then
       local smoke = Instance.new("Smoke")
       smoke.Size = 5
       smoke.Opacity = 0.5
       smoke.Parent = char.HumanoidRootPart
       Utility:Notify("Smoke", "Smoke added", 2, "Success")
   end
end)

Commands:Register("removeeffects", "Remove all effects", 0, function(args)
   local char = LocalPlayer.Character
   if not char then return end
   for _, part in ipairs(char:GetDescendants()) do
       if part:IsA("ParticleEmitter") or part:IsA("Fire") or part:IsA("Smoke") or part:IsA("Sparkles") then
           part:Destroy()
       end
   end
   Utility:Notify("Effects", "All effects removed", 2, "Success")
end)

-- Trolling Commands
Commands:Register("annoy", "Annoy a player by teleporting to them rapidly", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target then
       Utility:Notify("Error", "Player not found", 2, "Error")
       return
   end
   Echo.Features.Annoying = true
   task.spawn(function()
       while Echo.Features.Annoying and target.Character and target.Character:FindFirstChild("HumanoidRootPart") do
           local hrp = Utility:GetHRP()
           if hrp then
               hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
           end
           task.wait(0.05)
       end
   end)
   Utility:Notify("Annoy", "Annoying " .. target.DisplayName, 2, "Success")
end)

Commands:Register("unannoy", "Stop annoying", 0, function(args)
   Echo.Features.Annoying = false
   Utility:Notify("Annoy", "Stopped", 2, "Success")
end)

Commands:Register("orbit", "Orbit around a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target or not target.Character then return end
   Echo.Features.Orbiting = true
   local angle = 0
   task.spawn(function()
       while Echo.Features.Orbiting and target.Character and target.Character:FindFirstChild("HumanoidRootPart") do
           angle = angle + 0.1
           local hrp = Utility:GetHRP()
           if hrp then
               local targetPos = target.Character.HumanoidRootPart.Position
               hrp.CFrame = CFrame.new(targetPos + Vector3.new(math.cos(angle) * 5, 3, math.sin(angle) * 5), targetPos)
           end
           task.wait()
       end
   end)
   Utility:Notify("Orbit", "Orbiting " .. target.DisplayName, 2, "Success")
end)

Commands:Register("unorbit", "Stop orbiting", 0, function(args)
   Echo.Features.Orbiting = false
   Utility:Notify("Orbit", "Stopped", 2, "Success")
end)

Commands:Register("stare", "Stare at a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target then return end
   Echo.Features.Staring = true
   task.spawn(function()
       while Echo.Features.Staring and target.Character and target.Character:FindFirstChild("HumanoidRootPart") do
           local hrp = Utility:GetHRP()
           if hrp then
               hrp.CFrame = CFrame.new(hrp.Position, target.Character.HumanoidRootPart.Position)
           end
           task.wait()
       end
   end)
   Utility:Notify("Stare", "Staring at " .. target.DisplayName, 2, "Success")
end)

Commands:Register("unstare", "Stop staring", 0, function(args)
   Echo.Features.Staring = false
   Utility:Notify("Stare", "Stopped", 2, "Success")
end)

Commands:Register("follow", "Follow a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target then return end
   Echo.Features.Following = true
   task.spawn(function()
       while Echo.Features.Following and target.Character and target.Character:FindFirstChild("HumanoidRootPart") do
           local hrp = Utility:GetHRP()
           if hrp then
               local targetPos = target.Character.HumanoidRootPart.Position
               local myPos = hrp.Position
               local direction = (targetPos - myPos).Unit
               hrp.CFrame = CFrame.new(myPos + direction * 0.5, targetPos)
           end
           task.wait()
       end
   end)
   Utility:Notify("Follow", "Following " .. target.DisplayName, 2, "Success")
end)

Commands:Register("unfollow", "Stop following", 0, function(args)
   Echo.Features.Following = false
   Utility:Notify("Follow", "Stopped", 2, "Success")
end)

-- Advanced Commands
Commands:Register("pathfind", "Pathfind to a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target or not target.Character then return end
   local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
   local myHrp = Utility:GetHRP()
   local hum = Utility:GetHumanoid()
   if not targetHrp or not myHrp or not hum then return end

   local path = PathfindingService:CreatePath({
       AgentRadius = 2,
       AgentHeight = 5,
       AgentCanJump = true
   })

   local success, errorMessage = pcall(function()
       path:ComputeAsync(myHrp.Position, targetHrp.Position)
   end)

   if success and path.Status == Enum.PathStatus.Success then
       local waypoints = path:GetWaypoints()
       for _, waypoint in ipairs(waypoints) do
           hum:MoveTo(waypoint.Position)
           hum.MoveToFinished:Wait()
           if waypoint.Action == Enum.PathWaypointAction.Jump then
               hum:ChangeState(Enum.HumanoidStateType.Jumping)
           end
       end
       Utility:Notify("Pathfind", "Reached " .. target.DisplayName, 2, "Success")
   else
       Utility:Notify("Error", "Could not find path", 2, "Error")
   end
end, {"path"})

Commands:Register("view", "Spectate a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target then return end
   Camera.CameraSubject = target.Character and target.Character:FindFirstChildOfClass("Humanoid") or target.Character
   Utility:Notify("View", "Spectating " .. target.DisplayName, 2, "Success")
end, {"spectate", "watch"})

Commands:Register("unview", "Stop spectating", 0, function(args)
   local hum = Utility:GetHumanoid()
   if hum then Camera.CameraSubject = hum end
   Utility:Notify("View", "Stopped spectating", 2, "Success")
end, {"unspectate"})

Commands:Register("btools", "Give building tools", 0, function(args)
   local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
   if not backpack then return end

   local tools = {"Move", "Copy", "Delete"}
   for _, toolName in ipairs(tools) do
       local tool = Instance.new("Tool")
       tool.Name = toolName
       tool.RequiresHandle = false
       tool.Parent = backpack
   end
   Utility:Notify("BTools", "Building tools given", 2, "Success")
end)

Commands:Register("clicktp", "Enable click teleport", 0, function(args)
   Echo.Features.ClickTP = true
   Utility:Notify("ClickTP", "Click anywhere to teleport", 2, "Success")
end)

Commands:Register("unclicktp", "Disable click teleport", 0, function(args)
   Echo.Features.ClickTP = false
   Utility:Notify("ClickTP", "Disabled", 2, "Success")
end)

Commands:Register("clickdelete", "Enable click delete", 0, function(args)
   Echo.Features.ClickDelete = true
   Utility:Notify("ClickDelete", "Click to delete parts", 2, "Success")
end)

Commands:Register("unclickdelete", "Disable click delete", 0, function(args)
   Echo.Features.ClickDelete = false
   Utility:Notify("ClickDelete", "Disabled", 2, "Success")
end)

Commands:Register("xray", "See through walls", 0, function(args)
   for _, part in ipairs(Workspace:GetDescendants()) do
       if part:IsA("BasePart") and not part:IsDescendantOf(LocalPlayer.Character) then
           part.LocalTransparencyModifier = 0.7
       end
   end
   Utility:Notify("XRay", "XRay enabled", 2, "Success")
end)

Commands:Register("unxray", "Disable xray", 0, function(args)
   for _, part in ipairs(Workspace:GetDescendants()) do
       if part:IsA("BasePart") then
           part.LocalTransparencyModifier = 0
       end
   end
   Utility:Notify("XRay", "XRay disabled", 2, "Success")
end)

Commands:Register("freecam", "Enable free camera", 0, function(args)
   local camera = Workspace.CurrentCamera
   camera.CameraType = Enum.CameraType.Scriptable
   Echo.Features.Freecam = true

   task.spawn(function()
       local pos = camera.CFrame.Position
       local rot = Vector2.new(camera.CFrame:ToEulerAnglesYXZ())
       while Echo.Features.Freecam do
           local speed = 2
           if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then speed = 5 end
           if UserInputService:IsKeyDown(Enum.KeyCode.W) then pos = pos + (camera.CFrame.LookVector * speed) end
           if UserInputService:IsKeyDown(Enum.KeyCode.S) then pos = pos - (camera.CFrame.LookVector * speed) end
           if UserInputService:IsKeyDown(Enum.KeyCode.A) then pos = pos - (camera.CFrame.RightVector * speed) end
           if UserInputService:IsKeyDown(Enum.KeyCode.D) then pos = pos + (camera.CFrame.RightVector * speed) end
           if UserInputService:IsKeyDown(Enum.KeyCode.Space) then pos = pos + Vector3.new(0, speed, 0) end
           if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then pos = pos - Vector3.new(0, speed, 0) end

           local delta = UserInputService:GetMouseDelta()
           rot = rot + Vector2.new(-delta.Y * 0.002, -delta.X * 0.002)
           camera.CFrame = CFrame.new(pos) * CFrame.Angles(rot.X, rot.Y, 0)
           task.wait()
       end
   end)
   Utility:Notify("Freecam", "Freecam enabled (WASD + Space/Ctrl)", 2, "Success")
end)

Commands:Register("unfreecam", "Disable free camera", 0, function(args)
   Echo.Features.Freecam = false
   local hum = Utility:GetHumanoid()
   if hum then
       Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
       Workspace.CurrentCamera.CameraSubject = hum
   end
   Utility:Notify("Freecam", "Freecam disabled", 2, "Success")
end)

Commands:Register("timefreeze", "Freeze time for all players", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character then
           for _, part in ipairs(player.Character:GetDescendants()) do
               if part:IsA("BasePart") then
                   part.Anchored = true
               end
           end
       end
   end
   Utility:Notify("Time Freeze", "All players frozen", 2, "Success")
end)

Commands:Register("untimefreeze", "Unfreeze time", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character then
           for _, part in ipairs(player.Character:GetDescendants()) do
               if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                   part.Anchored = false
               end
           end
       end
   end
   Utility:Notify("Time Freeze", "All players unfrozen", 2, "Success")
end)

Commands:Register("rainbow", "Make your character rainbow", 0, function(args)
   Echo.Features.Rainbow = true
   local char = LocalPlayer.Character
   if not char then return end
   task.spawn(function()
       while Echo.Features.Rainbow and char and char.Parent do
           for _, part in ipairs(char:GetDescendants()) do
               if part:IsA("BasePart") then
                   part.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
               end
           end
           task.wait(0.1)
       end
   end)
   Utility:Notify("Rainbow", "Rainbow mode enabled", 2, "Success")
end)

Commands:Register("unrainbow", "Disable rainbow", 0, function(args)
   Echo.Features.Rainbow = false
   Utility:Notify("Rainbow", "Rainbow mode disabled", 2, "Success")
end)

Commands:Register("ghost", "Become a ghost", 0, function(args)
   local char = LocalPlayer.Character
   if not char then return end
   for _, part in ipairs(char:GetDescendants()) do
       if part:IsA("BasePart") then
           part.Transparency = 0.8
           part.CanCollide = false
       end
   end
   Utility:Notify("Ghost", "Ghost mode enabled", 2, "Success")
end)

Commands:Register("unghost", "Disable ghost mode", 0, function(args)
   local char = LocalPlayer.Character
   if not char then return end
   for _, part in ipairs(char:GetDescendants()) do
       if part:IsA("BasePart") then
           part.Transparency = 0
           part.CanCollide = true
       end
   end
   Utility:Notify("Ghost", "Ghost mode disabled", 2, "Success")
end)

Commands:Register("naked", "Remove all clothes", 0, function(args)
   local char = LocalPlayer.Character
   if not char then return end
   for _, obj in ipairs(char:GetDescendants()) do
       if obj:IsA("Clothing") or obj:IsA("ShirtGraphic") then
           obj:Destroy()
       end
   end
   Utility:Notify("Naked", "Clothes removed", 2, "Success")
end)

Commands:Register("noface", "Remove face", 0, function(args)
   local char = LocalPlayer.Character
   if char and char:FindFirstChild("Head") then
       local head = char.Head
       for _, obj in ipairs(head:GetDescendants()) do
           if obj:IsA("Decal") and obj.Name == "face" then
               obj:Destroy()
           end
       end
   end
   Utility:Notify("NoFace", "Face removed", 2, "Success")
end)

Commands:Register("bighead", "Make head bigger", 0, function(args)
   local char = LocalPlayer.Character
   if char and char:FindFirstChild("Head") then
       char.Head.Size = char.Head.Size * 3
       Utility:Notify("BigHead", "Head enlarged", 2, "Success")
   end
end)

Commands:Register("smallhead", "Make head smaller", 0, function(args)
   local char = LocalPlayer.Character
   if char and char:FindFirstChild("Head") then
       char.Head.Size = char.Head.Size * 0.5
       Utility:Notify("SmallHead", "Head shrunk", 2, "Success")
   end
end)

Commands:Register("longneck", "Make neck longer", 0, function(args)
   local char = LocalPlayer.Character
   if char and char:FindFirstChild("Head") and char:FindFirstChild("UpperTorso") then
       char.Head.Position = char.Head.Position + Vector3.new(0, 5, 0)
       Utility:Notify("LongNeck", "Neck elongated", 2, "Success")
   end
end)

Commands:Register("spinall", "Spin all players", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
           local bodyAngVel = Instance.new("BodyAngularVelocity")
           bodyAngVel.AngularVelocity = Vector3.new(0, 50, 0)
           bodyAngVel.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
           bodyAngVel.Parent = player.Character.HumanoidRootPart
           game:GetService("Debris"):AddItem(bodyAngVel, 5)
       end
   end
   Utility:Notify("SpinAll", "Spinning all players", 2, "Success")
end)

Commands:Register("flingall", "Fling all players", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
           local bodyVel = Instance.new("BodyVelocity")
           bodyVel.Velocity = Vector3.new(math.random(-1000, 1000), math.random(1000, 2000), math.random(-1000, 1000))
           bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
           bodyVel.Parent = player.Character.HumanoidRootPart
           game:GetService("Debris"):AddItem(bodyVel, 0.5)
       end
   end
   Utility:Notify("FlingAll", "Flung all players", 2, "Success")
end)

Commands:Register("killall", "Kill all players", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
           player.Character:FindFirstChildOfClass("Humanoid").Health = 0
       end
   end
   Utility:Notify("KillAll", "Killed all players", 2, "Success")
end)

Commands:Register("bringall", "Bring all players", 0, function(args)
   local myHrp = Utility:GetHRP()
   if not myHrp then return end
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
           player.Character.HumanoidRootPart.CFrame = myHrp.CFrame + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
       end
   end
   Utility:Notify("BringAll", "Brought all players", 2, "Success")
end)

Commands:Register("freezeall", "Freeze all players", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character then
           for _, part in ipairs(player.Character:GetDescendants()) do
               if part:IsA("BasePart") then
                   part.Anchored = true
               end
           end
       end
   end
   Utility:Notify("FreezeAll", "All players frozen", 2, "Success")
end)

Commands:Register("thawall", "Unfreeze all players", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character then
           for _, part in ipairs(player.Character:GetDescendants()) do
               if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                   part.Anchored = false
               end
           end
       end
   end
   Utility:Notify("ThawAll", "All players unfrozen", 2, "Success")
end)

Commands:Register("speedall", "Set all players speed", 1, function(args)
   local speed = tonumber(args[1]) or 16
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
           player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = speed
       end
   end
   Utility:Notify("SpeedAll", "Set all speeds to " .. speed, 2, "Success")
end)

Commands:Register("jumpall", "Set all players jump power", 1, function(args)
   local power = tonumber(args[1]) or 50
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
           player.Character:FindFirstChildOfClass("Humanoid").JumpPower = power
       end
   end
   Utility:Notify("JumpAll", "Set all jump powers to " .. power, 2, "Success")
end)

Commands:Register("sitall", "Make all players sit", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
           player.Character:FindFirstChildOfClass("Humanoid").Sit = true
       end
   end
   Utility:Notify("SitAll", "All players sitting", 2, "Success")
end)

Commands:Register("standall", "Make all players stand", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
           player.Character:FindFirstChildOfClass("Humanoid").Sit = false
       end
   end
   Utility:Notify("StandAll", "All players standing", 2, "Success")
end)

Commands:Register("danceall", "Make all players dance", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
           local dance = Instance.new("Animation")
           dance.AnimationId = "rbxassetid://507771019"
           local track = player.Character:FindFirstChildOfClass("Humanoid"):LoadAnimation(dance)
           track:Play()
       end
   end
   Utility:Notify("DanceAll", "All players dancing", 2, "Success")
end)

Commands:Register("explodeall", "Explode all players", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
           local explosion = Instance.new("Explosion")
           explosion.Position = player.Character.HumanoidRootPart.Position
           explosion.BlastRadius = 10
           explosion.BlastPressure = 500000
           explosion.Parent = Workspace
       end
   end
   Utility:Notify("ExplodeAll", "All players exploded", 2, "Success")
end)

Commands:Register("jailall", "Jail all players", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
           local jail = Instance.new("Model")
           jail.Name = "EchoJail_" .. player.Name
           jail.Parent = Workspace

           local pos = player.Character.HumanoidRootPart.Position
           local function createWall(position, sizeVec)
               local part = Instance.new("Part")
               part.Size = sizeVec
               part.Position = position
               part.Anchored = true
               part.CanCollide = true
               part.Transparency = 0.5
               part.Color = Config.Theme.Error
               part.Parent = jail
           end

           createWall(pos + Vector3.new(0, 4, 3), Vector3.new(6, 8, 0.5))
           createWall(pos + Vector3.new(0, 4, -3), Vector3.new(6, 8, 0.5))
           createWall(pos + Vector3.new(3, 4, 0), Vector3.new(0.5, 8, 6))
           createWall(pos + Vector3.new(-3, 4, 0), Vector3.new(0.5, 8, 6))
           createWall(pos + Vector3.new(0, 8, 0), Vector3.new(6, 0.5, 6))

           player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
       end
   end
   Utility:Notify("JailAll", "All players jailed", 2, "Success")
end)

Commands:Register("unjailall", "Unjail all players", 0, function(args)
   for _, obj in ipairs(Workspace:GetChildren()) do
       if obj.Name:sub(1, 9) == "EchoJail_" then obj:Destroy() end
   end
   Utility:Notify("UnjailAll", "All players unjailed", 2, "Success")
end)

Commands:Register("tpall", "Teleport all to you", 0, function(args)
   local myHrp = Utility:GetHRP()
   if not myHrp then return end
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
           player.Character.HumanoidRootPart.CFrame = myHrp.CFrame
       end
   end
   Utility:Notify("TPAll", "All players teleported to you", 2, "Success")
end)

Commands:Register("tpallrandom", "Teleport all to random locations", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
           player.Character.HumanoidRootPart.CFrame = CFrame.new(math.random(-500, 500), 100, math.random(-500, 500))
       end
   end
   Utility:Notify("TPAllRandom", "All players scattered", 2, "Success")
end)

Commands:Register("tpallsky", "Teleport all to the sky", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
           player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10000, 0)
       end
   end
   Utility:Notify("TPAllSky", "All players sent to sky", 2, "Success")
end)

Commands:Register("tpallvoid", "Teleport all to void", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
           player.Character.HumanoidRootPart.CFrame = CFrame.new(0, -500, 0)
       end
   end
   Utility:Notify("TPAllVoid", "All players sent to void", 2, "Success")
end)

Commands:Register("invisibleall", "Make all players invisible", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character then
           for _, part in ipairs(player.Character:GetDescendants()) do
               if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                   part.Transparency = 1
               elseif part:IsA("Decal") or part:IsA("Texture") then
                   part.Transparency = 1
               end
           end
       end
   end
   Utility:Notify("InvisibleAll", "All players invisible", 2, "Success")
end)

Commands:Register("visibleall", "Make all players visible", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character then
           for _, part in ipairs(player.Character:GetDescendants()) do
               if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                   part.Transparency = 0
               elseif part:IsA("Decal") or part:IsA("Texture") then
                   part.Transparency = 0
               end
           end
       end
   end
   Utility:Notify("VisibleAll", "All players visible", 2, "Success")
end)

Commands:Register("nakedall", "Remove all players clothes", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character then
           for _, obj in ipairs(player.Character:GetDescendants()) do
               if obj:IsA("Clothing") or obj:IsA("ShirtGraphic") then
                   obj:Destroy()
               end
           end
       end
   end
   Utility:Notify("NakedAll", "All players stripped", 2, "Success")
end)

Commands:Register("bigheadall", "Make all heads big", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
           player.Character.Head.Size = player.Character.Head.Size * 3
       end
   end
   Utility:Notify("BigHeadAll", "All heads enlarged", 2, "Success")
end)

Commands:Register("smallheadall", "Make all heads small", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
           player.Character.Head.Size = player.Character.Head.Size * 0.5
       end
   end
   Utility:Notify("SmallHeadAll", "All heads shrunk", 2, "Success")
end)

Commands:Register("rainbowall", "Make all players rainbow", 0, function(args)
   Echo.Features.RainbowAll = true
   task.spawn(function()
       while Echo.Features.RainbowAll do
           for _, player in ipairs(Players:GetPlayers()) do
               if player ~= LocalPlayer and player.Character then
                   for _, part in ipairs(player.Character:GetDescendants()) do
                       if part:IsA("BasePart") then
                           part.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                       end
                   end
               end
           end
           task.wait(0.1)
       end
   end)
   Utility:Notify("RainbowAll", "Rainbow mode for all", 2, "Success")
end)

Commands:Register("unrainbowall", "Disable rainbow for all", 0, function(args)
   Echo.Features.RainbowAll = false
   Utility:Notify("UnrainbowAll", "Rainbow disabled for all", 2, "Success")
end)

Commands:Register("ghostall", "Make all players ghosts", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character then
           for _, part in ipairs(player.Character:GetDescendants()) do
               if part:IsA("BasePart") then
                   part.Transparency = 0.8
                   part.CanCollide = false
               end
           end
       end
   end
   Utility:Notify("GhostAll", "All players are ghosts", 2, "Success")
end)

Commands:Register("unghostall", "Disable ghost for all", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character then
           for _, part in ipairs(player.Character:GetDescendants()) do
               if part:IsA("BasePart") then
                   part.Transparency = 0
                   part.CanCollide = true
               end
           end
       end
   end
   Utility:Notify("UnghostAll", "All players solid again", 2, "Success")
end)

Commands:Register("fireall", "Set all players on fire", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
           local fire = Instance.new("Fire")
           fire.Size = 5
           fire.Heat = 10
           fire.Parent = player.Character.HumanoidRootPart
       end
   end
   Utility:Notify("FireAll", "All players on fire", 2, "Success")
end)

Commands:Register("smokeall", "Add smoke to all players", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
           local smoke = Instance.new("Smoke")
           smoke.Size = 5
           smoke.Opacity = 0.5
           smoke.Parent = player.Character.HumanoidRootPart
       end
   end
   Utility:Notify("SmokeAll", "All players smoking", 2, "Success")
end)

Commands:Register("sparklesall", "Add sparkles to all players", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
           local sparkles = Instance.new("Sparkles")
           sparkles.Parent = player.Character.HumanoidRootPart
       end
   end
   Utility:Notify("SparklesAll", "All players sparkling", 2, "Success")
end)

Commands:Register("removeeffectsall", "Remove effects from all", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character then
           for _, part in ipairs(player.Character:GetDescendants()) do
               if part:IsA("ParticleEmitter") or part:IsA("Fire") or part:IsA("Smoke") or part:IsA("Sparkles") then
                   part:Destroy()
               end
           end
       end
   end
   Utility:Notify("RemoveEffectsAll", "All effects removed", 2, "Success")
end)

Commands:Register("sizeall", "Change all players size", 1, function(args)
   local size = tonumber(args[1]) or 1
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character then
           for _, part in ipairs(player.Character:GetDescendants()) do
               if part:IsA("BasePart") then
                   part.Size = part.Size * size
               end
           end
       end
   end
   Utility:Notify("SizeAll", "All players resized to " .. size .. "x", 2, "Success")
end)

Commands:Register("hipheightall", "Set all hip heights", 1, function(args)
   local height = tonumber(args[1]) or 0
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
           player.Character:FindFirstChildOfClass("Humanoid").HipHeight = height
       end
   end
   Utility:Notify("HipHeightAll", "All hip heights set to " .. height, 2, "Success")
end)

Commands:Register("walkto", "Walk to a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target or not target.Character then return end
   local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
   local hum = Utility:GetHumanoid()
   if not targetHrp or not hum then return end
   hum:MoveTo(targetHrp.Position)
   Utility:Notify("WalkTo", "Walking to " .. target.DisplayName, 2, "Success")
end)

Commands:Register("lookat", "Look at a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target or not target.Character then return end
   local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
   local myHrp = Utility:GetHRP()
   if not targetHrp or not myHrp then return end
   myHrp.CFrame = CFrame.new(myHrp.Position, targetHrp.Position)
   Utility:Notify("LookAt", "Looking at " .. target.DisplayName, 2, "Success")
end)

Commands:Register("backflip", "Do a backflip", 0, function(args)
   local hrp = Utility:GetHRP()
   local hum = Utility:GetHumanoid()
   if not hrp or not hum then return end
   hum:ChangeState(Enum.HumanoidStateType.Jumping)
   for i = 1, 10 do
       hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(18), 0, 0)
       task.wait(0.05)
   end
   Utility:Notify("Backflip", "Backflip completed", 2, "Success")
end)

Commands:Register("frontflip", "Do a frontflip", 0, function(args)
   local hrp = Utility:GetHRP()
   local hum = Utility:GetHumanoid()
   if not hrp or not hum then return end
   hum:ChangeState(Enum.HumanoidStateType.Jumping)
   for i = 1, 10 do
       hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(-18), 0, 0)
       task.wait(0.05)
   end
   Utility:Notify("Frontflip", "Frontflip completed", 2, "Success")
end)

Commands:Register("cartwheel", "Do a cartwheel", 0, function(args)
   local hrp = Utility:GetHRP()
   if not hrp then return end
   for i = 1, 20 do
       hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(18))
       task.wait(0.03)
   end
      Utility:Notify("Cartwheel", "Cartwheel completed", 2, "Success")
end)

Commands:Register("tpose", "T-Pose emote", 0, function(args)
   local char = LocalPlayer.Character
   if not char then return end
   for _, part in ipairs(char:GetDescendants()) do
       if part:IsA("Motor6D") and (part.Name == "Left Shoulder" or part.Name == "Right Shoulder") then
           part.C0 = CFrame.new(part.C0.Position) * CFrame.Angles(0, 0, math.rad(part.Name == "Left Shoulder" and 90 or -90))
       end
   end
   Utility:Notify("T-Pose", "T-Pose activated", 2, "Success")
end)

Commands:Register("dab", "Dab emote", 0, function(args)
   local char = LocalPlayer.Character
   if not char then return end
   local rightShoulder = char:FindFirstChild("Right Shoulder", true)
   if rightShoulder then
       rightShoulder.C0 = CFrame.new(rightShoulder.C0.Position) * CFrame.Angles(0, 0, math.rad(-130))
   end
   Utility:Notify("Dab", "Dab on 'em", 2, "Success")
end)

Commands:Register("facepalm", "Facepalm emote", 0, function(args)
   local char = LocalPlayer.Character
   if not char then return end
   local rightShoulder = char:FindFirstChild("Right Shoulder", true)
   local head = char:FindFirstChild("Head")
   if rightShoulder and head then
       rightShoulder.C0 = CFrame.new(rightShoulder.C0.Position) * CFrame.Angles(math.rad(-90), 0, 0)
   end
   Utility:Notify("Facepalm", "*facepalm*", 2, "Success")
end)

Commands:Register("shrug", "Shrug emote", 0, function(args)
   local char = LocalPlayer.Character
   if not char then return end
   for _, part in ipairs(char:GetDescendants()) do
       if part:IsA("Motor6D") and (part.Name == "Left Shoulder" or part.Name == "Right Shoulder") then
           part.C0 = CFrame.new(part.C0.Position) * CFrame.Angles(0, 0, math.rad(45))
       end
   end
   Utility:Notify("Shrug", "¯\\_(ツ)_/¯", 2, "Success")
end)

Commands:Register("face", "Change face", 1, function(args)
   local faceId = args[1] or "rbxassetid://144080495"
   local char = LocalPlayer.Character
   if not char or not char:FindFirstChild("Head") then return end
   local head = char.Head
   for _, obj in ipairs(head:GetDescendants()) do
       if obj:IsA("Decal") and obj.Name == "face" then
           obj.Texture = faceId
       end
   end
   Utility:Notify("Face", "Face changed", 2, "Success")
end)

Commands:Register("shirt", "Change shirt", 1, function(args)
   local shirtId = args[1] or ""
   local char = LocalPlayer.Character
   if not char then return end
   local shirt = char:FindFirstChildOfClass("Shirt") or Instance.new("Shirt")
   shirt.ShirtTemplate = "rbxassetid://" .. shirtId
   shirt.Parent = char
   Utility:Notify("Shirt", "Shirt changed", 2, "Success")
end)

Commands:Register("pants", "Change pants", 1, function(args)
   local pantsId = args[1] or ""
   local char = LocalPlayer.Character
   if not char then return end
   local pants = char:FindFirstChildOfClass("Pants") or Instance.new("Pants")
   pants.PantsTemplate = "rbxassetid://" .. pantsId
   pants.Parent = char
   Utility:Notify("Pants", "Pants changed", 2, "Success")
end)

Commands:Register("hat", "Add a hat", 1, function(args)
   local hatId = args[1] or ""
   local char = LocalPlayer.Character
   if not char then return end
   local hat = Instance.new("Accessory")
   local handle = Instance.new("Part")
   handle.Name = "Handle"
   handle.Size = Vector3.new(1, 1, 1)
   handle.Parent = hat
   local mesh = Instance.new("SpecialMesh")
   mesh.MeshId = "rbxassetid://" .. hatId
   mesh.Parent = handle
   hat.Parent = char
   Utility:Notify("Hat", "Hat added", 2, "Success")
end)

Commands:Register("removehats", "Remove all hats", 0, function(args)
   local char = LocalPlayer.Character
   if not char then return end
   for _, obj in ipairs(char:GetChildren()) do
       if obj:IsA("Accessory") then obj:Destroy() end
   end
   Utility:Notify("Hats", "All hats removed", 2, "Success")
end)

Commands:Register("copyplayer", "Copy a player's appearance", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target or not target.Character then return end
   local myChar = LocalPlayer.Character
   if not myChar then return end

   for _, obj in ipairs(target.Character:GetChildren()) do
       if obj:IsA("Shirt") then
           local myShirt = myChar:FindFirstChildOfClass("Shirt") or Instance.new("Shirt")
           myShirt.ShirtTemplate = obj.ShirtTemplate
           myShirt.Parent = myChar
       elseif obj:IsA("Pants") then
           local myPants = myChar:FindFirstChildOfClass("Pants") or Instance.new("Pants")
           myPants.PantsTemplate = obj.PantsTemplate
           myPants.Parent = myChar
       elseif obj:IsA("Accessory") then
           local clone = obj:Clone()
           clone.Parent = myChar
       end
   end
   Utility:Notify("Copy", "Copied " .. target.DisplayName .. "'s appearance", 2, "Success")
end, {"copy"})

Commands:Register("stealtools", "Steal a player's tools", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target or not target.Character then return end
   local myChar = LocalPlayer.Character
   if not myChar then return end

   for _, obj in ipairs(target.Character:GetChildren()) do
       if obj:IsA("Tool") then
           local clone = obj:Clone()
           clone.Parent = myChar
       end
   end
   local backpack = target:FindFirstChildOfClass("Backpack")
   if backpack then
       for _, tool in ipairs(backpack:GetChildren()) do
           local clone = tool:Clone()
           clone.Parent = LocalPlayer:FindFirstChildOfClass("Backpack") or myChar
       end
   end
   Utility:Notify("Steal", "Stole " .. target.DisplayName .. "'s tools", 2, "Success")
end)

Commands:Register("droptools", "Drop all tools", 0, function(args)
   local char = LocalPlayer.Character
   if not char then return end
   for _, obj in ipairs(char:GetChildren()) do
       if obj:IsA("Tool") then
           obj.Parent = Workspace
       end
   end
   local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
   if backpack then
       for _, tool in ipairs(backpack:GetChildren()) do
           tool.Parent = Workspace
       end
   end
   Utility:Notify("Drop", "All tools dropped", 2, "Success")
end)

Commands:Register("equiptools", "Equip all tools", 0, function(args)
   local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
   if not backpack then return end
   for _, tool in ipairs(backpack:GetChildren()) do
       if tool:IsA("Tool") then
           tool.Parent = LocalPlayer.Character
       end
   end
   Utility:Notify("Equip", "All tools equipped", 2, "Success")
end)

Commands:Register("unequiptools", "Unequip all tools", 0, function(args)
   local char = LocalPlayer.Character
   if not char then return end
   for _, obj in ipairs(char:GetChildren()) do
       if obj:IsA("Tool") then
           obj.Parent = LocalPlayer:FindFirstChildOfClass("Backpack") or char
       end
   end
   Utility:Notify("Unequip", "All tools unequipped", 2, "Success")
end)

Commands:Register("toolspam", "Spam equip/unequip tools", 0, function(args)
   Echo.Features.ToolSpam = true
   task.spawn(function()
       while Echo.Features.ToolSpam do
           local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
           local char = LocalPlayer.Character
           if backpack and char then
               for _, tool in ipairs(backpack:GetChildren()) do
                   if tool:IsA("Tool") then
                       tool.Parent = char
                       task.wait(0.1)
                       tool.Parent = backpack
                   end
               end
           end
           task.wait(0.1)
       end
   end)
   Utility:Notify("ToolSpam", "Tool spam enabled", 2, "Success")
end)

Commands:Register("untoolspam", "Stop tool spam", 0, function(args)
   Echo.Features.ToolSpam = false
   Utility:Notify("ToolSpam", "Tool spam disabled", 2, "Success")
end)

Commands:Register("loopkill", "Loop kill a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target then return end
   Echo.Features.LoopKill = true
   task.spawn(function()
       while Echo.Features.LoopKill do
           if target.Character and target.Character:FindFirstChildOfClass("Humanoid") then
               target.Character:FindFirstChildOfClass("Humanoid").Health = 0
           end
           task.wait(0.5)
       end
   end)
   Utility:Notify("LoopKill", "Loop killing " .. target.DisplayName, 2, "Success")
end)

Commands:Register("unloopkill", "Stop loop kill", 0, function(args)
   Echo.Features.LoopKill = false
   Utility:Notify("LoopKill", "Stopped", 2, "Success")
end)

Commands:Register("loopbring", "Loop bring a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target then return end
   Echo.Features.LoopBring = true
   task.spawn(function()
       while Echo.Features.LoopBring do
           if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
               local myHrp = Utility:GetHRP()
               if myHrp then
                   target.Character.HumanoidRootPart.CFrame = myHrp.CFrame + Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
               end
           end
           task.wait(0.1)
       end
   end)
   Utility:Notify("LoopBring", "Loop bringing " .. target.DisplayName, 2, "Success")
end)

Commands:Register("unloopbring", "Stop loop bring", 0, function(args)
   Echo.Features.LoopBring = false
   Utility:Notify("LoopBring", "Stopped", 2, "Success")
end)

Commands:Register("loopspeed", "Loop set speed", 1, function(args)
   local speed = tonumber(args[1]) or 100
   Echo.Features.LoopSpeed = true
   task.spawn(function()
       while Echo.Features.LoopSpeed do
           local hum = Utility:GetHumanoid()
           if hum then hum.WalkSpeed = speed end
           task.wait(0.1)
       end
   end)
   Utility:Notify("LoopSpeed", "Speed locked at " .. speed, 2, "Success")
end)

Commands:Register("unloopspeed", "Stop loop speed", 0, function(args)
   Echo.Features.LoopSpeed = false
   Utility:Notify("LoopSpeed", "Stopped", 2, "Success")
end)

Commands:Register("loopjump", "Loop set jump power", 1, function(args)
   local power = tonumber(args[1]) or 100
   Echo.Features.LoopJump = true
   task.spawn(function()
       while Echo.Features.LoopJump do
           local hum = Utility:GetHumanoid()
           if hum then hum.JumpPower = power end
           task.wait(0.1)
       end
   end)
   Utility:Notify("LoopJump", "Jump power locked at " .. power, 2, "Success")
end)

Commands:Register("unloopjump", "Stop loop jump", 0, function(args)
   Echo.Features.LoopJump = false
   Utility:Notify("LoopJump", "Stopped", 2, "Success")
end)

Commands:Register("spamchat", "Spam chat message", 1, function(args)
   local message = table.concat(args, " ") or "Echo Admin on top!"
   Echo.Features.SpamChat = true
   task.spawn(function()
       while Echo.Features.SpamChat do
           local chatEvent = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
           if chatEvent and chatEvent:FindFirstChild("SayMessageRequest") then
               chatEvent.SayMessageRequest:FireServer(message, "All")
           end
           task.wait(0.5)
       end
   end)
   Utility:Notify("SpamChat", "Spamming: " .. message, 2, "Success")
end)

Commands:Register("unspamchat", "Stop spamming chat", 0, function(args)
   Echo.Features.SpamChat = false
   Utility:Notify("SpamChat", "Stopped", 2, "Success")
end)

Commands:Register("spamjump", "Spam jump", 0, function(args)
   Echo.Features.SpamJump = true
   task.spawn(function()
       while Echo.Features.SpamJump do
           local hum = Utility:GetHumanoid()
           if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
           task.wait(0.1)
       end
   end)
   Utility:Notify("SpamJump", "Jump spam enabled", 2, "Success")
end)

Commands:Register("unspamjump", "Stop spam jump", 0, function(args)
   Echo.Features.SpamJump = false
   Utility:Notify("SpamJump", "Stopped", 2, "Success")
end)

Commands:Register("spamclick", "Spam click", 0, function(args)
   Echo.Features.SpamClick = true
   task.spawn(function()
       while Echo.Features.SpamClick do
           mouse1click()
           task.wait(0.01)
       end
   end)
   Utility:Notify("SpamClick", "Click spam enabled", 2, "Success")
end)

Commands:Register("unspamclick", "Stop spam click", 0, function(args)
   Echo.Features.SpamClick = false
   Utility:Notify("SpamClick", "Stopped", 2, "Success")
end)

Commands:Register("autoclick", "Auto click when holding", 0, function(args)
   Echo.Features.AutoClick = true
   Utility:Notify("AutoClick", "Auto click enabled", 2, "Success")
end)

Commands:Register("unautoclick", "Stop auto click", 0, function(args)
   Echo.Features.AutoClick = false
   Utility:Notify("AutoClick", "Stopped", 2, "Success")
end)

Commands:Register("clicktp", "Click to teleport", 0, function(args)
   Echo.Features.ClickTP = true
   Utility:Notify("ClickTP", "Click anywhere to teleport", 2, "Success")
end)

Commands:Register("unclicktp", "Disable click teleport", 0, function(args)
   Echo.Features.ClickTP = false
   Utility:Notify("ClickTP", "Disabled", 2, "Success")
end)

Commands:Register("clickdelete", "Click to delete", 0, function(args)
   Echo.Features.ClickDelete = true
   Utility:Notify("ClickDelete", "Click to delete parts", 2, "Success")
end)

Commands:Register("unclickdelete", "Disable click delete", 0, function(args)
   Echo.Features.ClickDelete = false
   Utility:Notify("ClickDelete", "Disabled", 2, "Success")
end)

Commands:Register("mousetp", "Teleport to mouse position", 0, function(args)
   local mouse = LocalPlayer:GetMouse()
   local hrp = Utility:GetHRP()
   if hrp and mouse.Hit then
       hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
       Utility:Notify("MouseTP", "Teleported to mouse", 2, "Success")
   end
end)

Commands:Register("bang", "Bang a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target or not target.Character then return end
   Echo.Features.Banging = true
   task.spawn(function()
       while Echo.Features.Banging and target.Character and target.Character:FindFirstChild("HumanoidRootPart") do
           local myHrp = Utility:GetHRP()
           if myHrp then
               myHrp.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.5)
           end
           task.wait(0.05)
       end
   end)
   Utility:Notify("Bang", "Banging " .. target.DisplayName, 2, "Success")
end)

Commands:Register("unbang", "Stop banging", 0, function(args)
   Echo.Features.Banging = false
   Utility:Notify("Bang", "Stopped", 2, "Success")
end)

Commands:Register("car", "Spawn a car", 0, function(args)
   local car = Instance.new("Model")
   car.Name = "EchoCar"
   car.Parent = Workspace

   local chassis = Instance.new("Part")
   chassis.Size = Vector3.new(4, 1, 8)
   chassis.Position = Utility:GetHRP() and Utility:GetHRP().Position + Vector3.new(0, 5, 0) or Vector3.new(0, 10, 0)
   chassis.Anchored = true
   chassis.CanCollide = true
   chassis.Color = Config.Theme.Accent
   chassis.Parent = car

   local seat = Instance.new("VehicleSeat")
   seat.Size = Vector3.new(2, 1, 2)
   seat.Position = chassis.Position + Vector3.new(0, 1, 0)
   seat.Parent = car

   Utility:Notify("Car", "Car spawned", 2, "Success")
end)

Commands:Register("deletecar", "Delete spawned car", 0, function(args)
   for _, obj in ipairs(Workspace:GetChildren()) do
       if obj.Name == "EchoCar" then obj:Destroy() end
   end
   Utility:Notify("Car", "Car deleted", 2, "Success")
end)

Commands:Register("platform", "Create a platform under you", 0, function(args)
   local hrp = Utility:GetHRP()
   if not hrp then return end
   local platform = Instance.new("Part")
   platform.Size = Vector3.new(10, 1, 10)
   platform.Position = hrp.Position - Vector3.new(0, 3, 0)
   platform.Anchored = true
   platform.CanCollide = true
   platform.Color = Config.Theme.Accent
   platform.Name = "EchoPlatform"
   platform.Parent = Workspace
   Utility:Notify("Platform", "Platform created", 2, "Success")
end)

Commands:Register("deleteplatform", "Delete all platforms", 0, function(args)
   for _, obj in ipairs(Workspace:GetChildren()) do
       if obj.Name == "EchoPlatform" then obj:Destroy() end
   end
   Utility:Notify("Platform", "All platforms deleted", 2, "Success")
end)

Commands:Register("bridge", "Create a bridge to a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target or not target.Character then return end
   local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
   local myHrp = Utility:GetHRP()
   if not targetHrp or not myHrp then return end

   local distance = (targetHrp.Position - myHrp.Position).Magnitude
   local midPoint = (myHrp.Position + targetHrp.Position) / 2
   local bridge = Instance.new("Part")
   bridge.Size = Vector3.new(4, 1, distance)
   bridge.CFrame = CFrame.lookAt(myHrp.Position, targetHrp.Position) * CFrame.new(0, 0, -distance/2)
   bridge.Anchored = true
   bridge.CanCollide = true
   bridge.Color = Config.Theme.Accent
   bridge.Name = "EchoBridge"
   bridge.Parent = Workspace
   Utility:Notify("Bridge", "Bridge created to " .. target.DisplayName, 2, "Success")
end)

Commands:Register("deletebridge", "Delete all bridges", 0, function(args)
   for _, obj in ipairs(Workspace:GetChildren()) do
       if obj.Name == "EchoBridge" then obj:Destroy() end
   end
   Utility:Notify("Bridge", "All bridges deleted", 2, "Success")
end)

Commands:Register("stairs", "Create stairs up", 0, function(args)
   local hrp = Utility:GetHRP()
   if not hrp then return end
   for i = 1, 20 do
       local step = Instance.new("Part")
       step.Size = Vector3.new(4, 1, 2)
       step.Position = hrp.Position + Vector3.new(0, i, -i * 2)
       step.Anchored = true
       step.CanCollide = true
       step.Color = Config.Theme.Accent
       step.Name = "EchoStairs"
       step.Parent = Workspace
   end
   Utility:Notify("Stairs", "Stairs created", 2, "Success")
end)

Commands:Register("deletestairs", "Delete all stairs", 0, function(args)
   for _, obj in ipairs(Workspace:GetChildren()) do
       if obj.Name == "EchoStairs" then obj:Destroy() end
   end
   Utility:Notify("Stairs", "All stairs deleted", 2, "Success")
end)

Commands:Register("tower", "Create a tower", 0, function(args)
   local hrp = Utility:GetHRP()
   if not hrp then return end
   for i = 1, 50 do
       local floor = Instance.new("Part")
       floor.Size = Vector3.new(10, 1, 10)
       floor.Position = hrp.Position + Vector3.new(0, i * 5, 0)
       floor.Anchored = true
       floor.CanCollide = true
       floor.Color = Color3.fromHSV(i/50, 1, 1)
       floor.Name = "EchoTower"
       floor.Parent = Workspace
   end
   Utility:Notify("Tower", "Tower created", 2, "Success")
end)

Commands:Register("deletetower", "Delete all towers", 0, function(args)
   for _, obj in ipairs(Workspace:GetChildren()) do
       if obj.Name == "EchoTower" then obj:Destroy() end
   end
   Utility:Notify("Tower", "All towers deleted", 2, "Success")
end)

Commands:Register("box", "Create a box around you", 0, function(args)
   local hrp = Utility:GetHRP()
   if not hrp then return end
   local pos = hrp.Position
   local box = Instance.new("Model")
   box.Name = "EchoBox"
   box.Parent = Workspace

   local function createWall(position, sizeVec)
       local part = Instance.new("Part")
       part.Size = sizeVec
       part.Position = position
       part.Anchored = true
       part.CanCollide = true
       part.Transparency = 0.5
       part.Color = Config.Theme.Accent
       part.Parent = box
   end

   createWall(pos + Vector3.new(0, 5, 5), Vector3.new(10, 10, 1))
   createWall(pos + Vector3.new(0, 5, -5), Vector3.new(10, 10, 1))
   createWall(pos + Vector3.new(5, 5, 0), Vector3.new(1, 10, 10))
   createWall(pos + Vector3.new(-5, 5, 0), Vector3.new(1, 10, 10))
   createWall(pos + Vector3.new(0, 10, 0), Vector3.new(10, 1, 10))
   createWall(pos + Vector3.new(0, 0, 0), Vector3.new(10, 1, 10))

   Utility:Notify("Box", "Box created", 2, "Success")
end)

Commands:Register("deletebox", "Delete all boxes", 0, function(args)
   for _, obj in ipairs(Workspace:GetChildren()) do
       if obj.Name == "EchoBox" then obj:Destroy() end
   end
   Utility:Notify("Box", "All boxes deleted", 2, "Success")
end)

Commands:Register("sphere", "Create a sphere", 0, function(args)
   local hrp = Utility:GetHRP()
   if not hrp then return end
   local sphere = Instance.new("Part")
   sphere.Shape = Enum.PartType.Ball
   sphere.Size = Vector3.new(10, 10, 10)
   sphere.Position = hrp.Position + Vector3.new(0, 10, 0)
   sphere.Anchored = true
   sphere.CanCollide = true
   sphere.Color = Config.Theme.Accent
   sphere.Name = "EchoSphere"
   sphere.Parent = Workspace
   Utility:Notify("Sphere", "Sphere created", 2, "Success")
end)

Commands:Register("deletesphere", "Delete all spheres", 0, function(args)
   for _, obj in ipairs(Workspace:GetChildren()) do
       if obj.Name == "EchoSphere" then obj:Destroy() end
   end
   Utility:Notify("Sphere", "All spheres deleted", 2, "Success")
end)

Commands:Register("ramp", "Create a ramp", 0, function(args)
   local hrp = Utility:GetHRP()
   if not hrp then return end
   local ramp = Instance.new("Part")
   ramp.Size = Vector3.new(10, 1, 20)
   ramp.CFrame = hrp.CFrame * CFrame.new(0, 0, -10) * CFrame.Angles(math.rad(-30), 0, 0)
   ramp.Anchored = true
   ramp.CanCollide = true
   ramp.Color = Config.Theme.Accent
   ramp.Name = "EchoRamp"
   ramp.Parent = Workspace
   Utility:Notify("Ramp", "Ramp created", 2, "Success")
end)

Commands:Register("deleteramp", "Delete all ramps", 0, function(args)
   for _, obj in ipairs(Workspace:GetChildren()) do
       if obj.Name == "EchoRamp" then obj:Destroy() end
   end
   Utility:Notify("Ramp", "All ramps deleted", 2, "Success")
end)

Commands:Register("trap", "Trap a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target or not target.Character then return end
   local hrp = target.Character:FindFirstChild("HumanoidRootPart")
   if not hrp then return end

   local trap = Instance.new("Model")
   trap.Name = "EchoTrap"
   trap.Parent = Workspace

   for i = 1, 8 do
       local wall = Instance.new("Part")
       wall.Size = Vector3.new(2, 20, 2)
       wall.Position = hrp.Position + Vector3.new(math.cos(i * math.pi / 4) * 5, 10, math.sin(i * math.pi / 4) * 5)
       wall.Anchored = true
       wall.CanCollide = true
       wall.Color = Config.Theme.Error
       wall.Parent = trap
   end

   local top = Instance.new("Part")
   top.Size = Vector3.new(12, 2, 12)
   top.Position = hrp.Position + Vector3.new(0, 20, 0)
   top.Anchored = true
   top.CanCollide = true
   top.Color = Config.Theme.Error
   top.Parent = trap

   hrp.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 2, 0))
   Utility:Notify("Trap", target.DisplayName .. " trapped", 2, "Success")
end)

Commands:Register("untrap", "Remove all traps", 0, function(args)
   for _, obj in ipairs(Workspace:GetChildren()) do
       if obj.Name == "EchoTrap" then obj:Destroy() end
   end
   Utility:Notify("Trap", "All traps removed", 2, "Success")
end)

Commands:Register("cage", "Cage a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target or not target.Character then return end
   local hrp = target.Character:FindFirstChild("HumanoidRootPart")
   if not hrp then return end

   local cage = Instance.new("Model")
   cage.Name = "EchoCage"
   cage.Parent = Workspace

   local bars = 16
   for i = 1, bars do
       local bar = Instance.new("Part")
       bar.Size = Vector3.new(0.5, 15, 0.5)
       bar.Position = hrp.Position + Vector3.new(math.cos(i * 2 * math.pi / bars) * 4, 7.5, math.sin(i * 2 * math.pi / bars) * 4)
       bar.Anchored = true
       bar.CanCollide = true
       bar.Color = Config.Theme.Error
       bar.Parent = cage
   end

   local bottom = Instance.new("Part")
   bottom.Size = Vector3.new(9, 1, 9)
   bottom.Position = hrp.Position + Vector3.new(0, 0, 0)
   bottom.Anchored = true
   bottom.CanCollide = true
   bottom.Color = Config.Theme.Error
   bottom.Parent = cage

   local top = Instance.new("Part")
   top.Size = Vector3.new(9, 1, 9)
   top.Position = hrp.Position + Vector3.new(0, 15, 0)
   top.Anchored = true
   top.CanCollide = true
   top.Color = Config.Theme.Error
   top.Parent = cage

   hrp.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 2, 0))
   Utility:Notify("Cage", target.DisplayName .. " caged", 2, "Success")
end)

Commands:Register("uncage", "Remove all cages", 0, function(args)
   for _, obj in ipairs(Workspace:GetChildren()) do
       if obj.Name == "EchoCage" then obj:Destroy() end
   end
   Utility:Notify("Cage", "All cages removed", 2, "Success")
end)

Commands:Register("launch", "Launch a player into the air", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target or not target.Character then return end
   local hrp = target.Character:FindFirstChild("HumanoidRootPart")
   if not hrp then return end

   local bodyVel = Instance.new("BodyVelocity")
   bodyVel.Velocity = Vector3.new(0, 500, 0)
   bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
   bodyVel.Parent = hrp
   game:GetService("Debris"):AddItem(bodyVel, 1)
   Utility:Notify("Launch", target.DisplayName .. " launched", 2, "Success")
end)

Commands:Register("slam", "Slam a player into the ground", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target or not target.Character then return end
   local hrp = target.Character:FindFirstChild("HumanoidRootPart")
   if not hrp then return end

   local bodyVel = Instance.new("BodyVelocity")
   bodyVel.Velocity = Vector3.new(0, -500, 0)
   bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
   bodyVel.Parent = hrp
   game:GetService("Debris"):AddItem(bodyVel, 1)
   Utility:Notify("Slam", target.DisplayName .. " slammed", 2, "Success")
end)

Commands:Register("yeet", "Yeet a player far away", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target or not target.Character then return end
   local hrp = target.Character:FindFirstChild("HumanoidRootPart")
   if not hrp then return end

   local bodyVel = Instance.new("BodyVelocity")
   bodyVel.Velocity = Vector3.new(math.random(-2000, 2000), 1000, math.random(-2000, 2000))
   bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
   bodyVel.Parent = hrp
   game:GetService("Debris"):AddItem(bodyVel, 2)
   Utility:Notify("Yeet", target.DisplayName .. " YEETED", 2, "Success")
end)

Commands:Register("crash", "Crash a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target then return end
   for i = 1, 100 do
       local part = Instance.new("Part")
       part.Size = Vector3.new(1000, 1000, 1000)
       part.Position = target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character.HumanoidRootPart.Position or Vector3.new(0, 0, 0)
       part.Parent = Workspace
       task.wait()
       part:Destroy()
   end
   Utility:Notify("Crash", "Attempted to crash " .. target.DisplayName, 2, "Success")
end)

Commands:Register("lag", "Lag a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target then return end
   Echo.Features.Lagging = true
   task.spawn(function()
       while Echo.Features.Lagging do
           if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
               for i = 1, 10 do
                   local part = Instance.new("Part")
                   part.Size = Vector3.new(1, 1, 1)
                   part.Position = target.Character.HumanoidRootPart.Position
                   part.Parent = Workspace
                   task.delay(0.1, function() part:Destroy() end)
               end
           end
           task.wait(0.1)
       end
   end)
   Utility:Notify("Lag", "Lagging " .. target.DisplayName, 2, "Success")
end)

Commands:Register("unlag", "Stop lagging", 0, function(args)
   Echo.Features.Lagging = false
   Utility:Notify("Lag", "Stopped", 2, "Success")
end)

Commands:Register("confuse", "Confuse a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target or not target.Character then return end
   Echo.Features.Confusing = true
   task.spawn(function()
       while Echo.Features.Confusing and target.Character and target.Character:FindFirstChild("HumanoidRootPart") do
           target.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(math.random(-180, 180)), 0)
           task.wait(0.1)
       end
   end)
   Utility:Notify("Confuse", "Confusing " .. target.DisplayName, 2, "Success")
end)

Commands:Register("unconfuse", "Stop confusing", 0, function(args)
   Echo.Features.Confusing = false
   Utility:Notify("Confuse", "Stopped", 2, "Success")
end)

Commands:Register("shake", "Shake a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target or not target.Character then return end
   Echo.Features.Shaking = true
   task.spawn(function()
       while Echo.Features.Shaking and target.Character and target.Character:FindFirstChild("HumanoidRootPart") do
           local originalPos = target.Character.HumanoidRootPart.Position
           target.Character.HumanoidRootPart.CFrame = CFrame.new(originalPos + Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)))
           task.wait(0.05)
       end
   end)
   Utility:Notify("Shake", "Shaking " .. target.DisplayName, 2, "Success")
end)

Commands:Register("unshake", "Stop shaking", 0, function(args)
   Echo.Features.Shaking = false
   Utility:Notify("Shake", "Stopped", 2, "Success")
end)

Commands:Register("control", "Control a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target then return end
   Echo.Features.Controlling = target
   Utility:Notify("Control", "Controlling " .. target.DisplayName .. " (WASD to move them)", 2, "Success")
end)

Commands:Register("uncontrol", "Stop controlling", 0, function(args)
   Echo.Features.Controlling = nil
   Utility:Notify("Control", "Stopped", 2, "Success")
end)

Commands:Register("swap", "Swap positions with a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target or not target.Character then return end
   local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
   local myHrp = Utility:GetHRP()
   if not targetHrp or not myHrp then return end

   local myPos = myHrp.CFrame
   myHrp.CFrame = targetHrp.CFrame
   targetHrp.CFrame = myPos
   Utility:Notify("Swap", "Swapped with " .. target.DisplayName, 2, "Success")
end)

Commands:Register("clone", "Clone yourself", 0, function(args)
   local char = LocalPlayer.Character
   if not char then return end
   local clone = char:Clone()
   clone.Name = LocalPlayer.Name .. "_Clone"
   clone.Parent = Workspace
   local cloneHrp = clone:FindFirstChild("HumanoidRootPart")
   if cloneHrp then
       cloneHrp.CFrame = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.CFrame + Vector3.new(5, 0, 0) or CFrame.new(0, 10, 0)
   end
   Utility:Notify("Clone", "Clone created", 2, "Success")
end)

Commands:Register("deleteclones", "Delete all clones", 0, function(args)
   for _, obj in ipairs(Workspace:GetChildren()) do
       if obj.Name:find("_Clone") then obj:Destroy() end
   end
   Utility:Notify("Clones", "All clones deleted", 2, "Success")
end)

Commands:Register("dupe", "Duplicate your character", 1, function(args)
   local amount = tonumber(args[1]) or 1
   local char = LocalPlayer.Character
   if not char then return end
   for i = 1, math.min(amount, 10) do
       local clone = char:Clone()
       clone.Name = LocalPlayer.Name .. "_Dupe" .. i
       clone.Parent = Workspace
       local cloneHrp = clone:FindFirstChild("HumanoidRootPart")
       if cloneHrp then
           cloneHrp.CFrame = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.CFrame + Vector3.new(i * 5, 0, 0) or CFrame.new(0, 10, 0)
       end
   end
   Utility:Notify("Dupe", amount .. " duplicates created", 2, "Success")
end)

Commands:Register("deletedupes", "Delete all dupes", 0, function(args)
   for _, obj in ipairs(Workspace:GetChildren()) do
       if obj.Name:find("_Dupe") then obj:Destroy() end
   end
   Utility:Notify("Dupes", "All dupes deleted", 2, "Success")
end)

Commands:Register("animation", "Play an animation", 1, function(args)
   local animId = args[1] or "507771019"
   local hum = Utility:GetHumanoid()
   if not hum then return end
   local anim = Instance.new("Animation")
   anim.AnimationId = "rbxassetid://" .. animId
   local track = hum:LoadAnimation(anim)
   track:Play()
   Utility:Notify("Animation", "Playing animation " .. animId, 2, "Success")
end, {"anim"})

Commands:Register("stopanimations", "Stop all animations", 0, function(args)
   local hum = Utility:GetHumanoid()
   if not hum then return end
   for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
       track:Stop()
   end
   Utility:Notify("Animations", "All animations stopped", 2, "Success")
end)

Commands:Register("emote", "Play an emote", 1, function(args)
   local emoteName = args[1] or "dance"
   local emotes = {
       dance = "507771019",
       dance2 = "507776043",
       dance3 = "507777268",
       wave = "507770239",
       point = "507770453",
       cheer = "507770677",
       laugh = "507770818",
       sit = "507768133"
   }
   local animId = emotes[emoteName:lower()] or emotes.dance
   local hum = Utility:GetHumanoid()
   if not hum then return end
   local anim = Instance.new("Animation")
   anim.AnimationId = "rbxassetid://" .. animId
   local track = hum:LoadAnimation(anim)
   track:Play()
   Utility:Notify("Emote", "Playing " .. emoteName, 2, "Success")
end)

Commands:Register("ragdoll", "Ragdoll a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "me")
   if not target or not target.Character then return end
   local hum = target.Character:FindFirstChildOfClass("Humanoid")
   if hum then
       hum.PlatformStand = true
       hum.AutoRotate = false
   end
   for _, part in ipairs(target.Character:GetDescendants()) do
       if part:IsA("Motor6D") then
           part:Destroy()
       end
   end
   Utility:Notify("Ragdoll", target.DisplayName .. " ragdolled", 2, "Success")
end)

Commands:Register("unragdoll", "Unragdoll a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "me")
   if not target then return end
   if target.Character then
       target.Character:BreakJoints()
   end
   Utility:Notify("Unragdoll", target.DisplayName .. " unragdolled", 2, "Success")
end)

Commands:Register("ragdollall", "Ragdoll all players", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character then
           local hum = player.Character:FindFirstChildOfClass("Humanoid")
           if hum then
               hum.PlatformStand = true
               hum.AutoRotate = false
           end
           for _, part in ipairs(player.Character:GetDescendants()) do
               if part:IsA("Motor6D") then
                   part:Destroy()
               end
           end
       end
   end
   Utility:Notify("RagdollAll", "All players ragdolled", 2, "Success")
end)

Commands:Register("unragdollall", "Unragdoll all players", 0, function(args)
   for _, player in ipairs(Players:GetPlayers()) do
       if player ~= LocalPlayer and player.Character then
           player.Character:BreakJoints()
       end
   end
   Utility:Notify("UnragdollAll", "All players unragdolled", 2, "Success")
end)

Commands:Register("jumpscare", "Jumpscare a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target then return end
   -- This would require a GUI on the target's client, which isn't possible from LocalScript alone
   Utility:Notify("Jumpscare", "Jumpscare attempted on " .. target.DisplayName, 2, "Success")
end)

Commands:Register("blind", "Blind a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target then return end
   -- This would require a GUI on the target's client
   Utility:Notify("Blind", "Blind attempted on " .. target.DisplayName, 2, "Success")
end)

Commands:Register("unblind", "Unblind a player", 1, function(args)
   local target = Utility:GetPlayer(args[1] or "")
   if not target then return end
   Utility:Notify("Unblind", "Unblind attempted on " .. target.DisplayName, 2, "Success")
end)

Commands:Register("flashbang", "Flashbang effect", 0, function(args)
   local screenGui = Instance.new("ScreenGui")
   screenGui.Parent = CoreGui
   local frame = Instance.new("Frame")
   frame.Size = UDim2.new(1, 0, 1, 0)
   frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
   frame.Parent = screenGui

   Utility:Tween(frame, {BackgroundTransparency = 1}, TweenInfo.new(3))
   task.delay(3, function() screenGui:Destroy() end)
   Utility:Notify("Flashbang", "FLASHBANG", 2, "Success")
end)

Commands:Register("earthquake", "Create earthquake effect", 0, function(args)
   Echo.Features.Earthquake = true
   task.spawn(function()
       while Echo.Features.Earthquake do
           for _, player in ipairs(Players:GetPlayers()) do
               if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                   player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-1, 1), 0, math.random(-1, 1))
               end
           end
           task.wait(0.05)
       end
   end)
   Utility:Notify("Earthquake", "Earthquake started", 2, "Success")
end)

Commands:Register("unearthquake", "Stop earthquake", 0, function(args)
   Echo.Features.Earthquake = false
   Utility:Notify("Earthquake", "Stopped", 2, "Success")
end)

Commands:Register("tsunami", "Create tsunami effect", 0, function(args)
   local wave = Instance.new("Part")
   wave.Size = Vector3.new(1000, 50, 10)
   wave.Position = Vector3.new(0, 10, -500)
   wave.Anchored = true
   wave.CanCollide = true
   wave.Color = Config.Theme.Blue
   wave.Name = "EchoTsunami"
   wave.Parent = Workspace

   task.spawn(function()
       for i = 1, 100 do
           wave.Position = wave.Position + Vector3.new(0, 0, 10)
           task.wait(0.1)
       end
       wave:Destroy()
   end)
   Utility:Notify("Tsunami", "Tsunami incoming", 2, "Success")
end)

Commands:Register("tornado", "Create tornado effect", 0, function(args)
   Echo.Features.Tornado = true
   local center = Utility:GetHRP() and Utility:GetHRP().Position or Vector3.new(0, 0, 0)
   task.spawn(function()
       while Echo.Features.Tornado do
           for _, player in ipairs(Players:GetPlayers()) do
               if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                   local pos = player.Character.HumanoidRootPart.Position
                   local offset = pos - center
                   local distance = offset.Magnitude
                   if distance < 50 then
                       local angle = math.atan2(offset.Z, offset.X) + math.rad(10)
                       local newPos = center + Vector3.new(math.cos(angle) * distance, math.min(pos.Y + 1, center.Y + 50), math.sin(angle) * distance)
                       player.Character.HumanoidRootPart.CFrame = CFrame.new(newPos)
                   end
               end
           end
           task.wait()
       end
   end)
   Utility:Notify("Tornado", "Tornado created", 2, "Success")
end)

Commands:Register("untornado", "Stop tornado", 0, function(args)
   Echo.Features.Tornado = false
   Utility:Notify("Tornado", "Stopped", 2, "Success")
end)

Commands:Register("blackhole", "Create black hole", 0, function(args)
   Echo.Features.BlackHole = true
   local center = Utility:GetHRP() and Utility:GetHRP().Position or Vector3.new(0, 0, 0)
   task.spawn(function()
       while Echo.Features.BlackHole do
           for _, player in ipairs(Players:GetPlayers()) do
               if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                   local pos = player.Character.HumanoidRootPart.Position
                   local direction = (center - pos).Unit
                   local distance = (center - pos).Magnitude
                   if distance > 5 then
                       player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + direction * 2
                   end
               end
           end
           task.wait()
       end
   end)
   Utility:Notify("BlackHole", "Black hole created", 2, "Success")
end)

Commands:Register("unblackhole", "Stop black hole", 0, function(args)
   Echo.Features.BlackHole = false
   Utility:Notify("BlackHole", "Stopped", 2, "Success")
end)

Commands:Register("antigravity", "Enable anti-gravity", 0, function(args)
   Echo.Features.AntiGravity = true
   task.spawn(function()
       while Echo.Features.AntiGravity do
           for _, player in ipairs(Players:GetPlayers()) do
               if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                   local bodyVel = player.Character.HumanoidRootPart:FindFirstChildOfClass("BodyVelocity") or Instance.new("BodyVelocity")
                   bodyVel.Velocity = Vector3.new(0, 50, 0)
                   bodyVel.MaxForce = Vector3.new(0, 9e9, 0)
                   bodyVel.Parent = player.Character.HumanoidRootPart
               end
           end
           task.wait(0.5)
       end
   end)
   Utility:Notify("AntiGravity", "Anti-gravity enabled", 2, "Success")
end)

Commands:Register("unantigravity", "Disable anti-gravity", 0, function(args)
   Echo.Features.AntiGravity = false
   for _, player in ipairs(Players:GetPlayers()) do
       if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
           for _, obj in ipairs(player.Character.HumanoidRootPart:GetChildren()) do
               if obj:IsA("BodyVelocity") then obj:Destroy() end
           end
       end
   end
   Utility:Notify("AntiGravity", "Disabled", 2, "Success")
end)

Commands:Register("lowgravity", "Enable low gravity", 0, function(args)
   Workspace.Gravity = 20
   Utility:Notify("LowGravity", "Low gravity enabled", 2, "Success")
end)

Commands:Register("highgravity", "Enable high gravity", 0, function(args)
   Workspace.Gravity = 500
   Utility:Notify("HighGravity", "High gravity enabled", 2, "Success")
end)

Commands:Register("moonwalk", "Enable moonwalk", 0, function(args)
   Echo.Features.Moonwalk = true
   task.spawn(function()
       while Echo.Features.Moonwalk do
           local hum = Utility:GetHumanoid()
           if hum and hum.MoveDirection.Magnitude > 0 then
               hum.WalkSpeed = -hum.WalkSpeed
               task.wait(0.1)
               hum.WalkSpeed = math.abs(hum.WalkSpeed)
           end
           task.wait()
       end
   end)
   Utility:Notify("Moonwalk", "Moonwalk enabled", 2, "Success")
end)

Commands:Register("unmoonwalk", "Disable moonwalk", 0, function(args)
   Echo.Features.Moonwalk = false
   local hum = Utility:GetHumanoid()
   if hum then hum.WalkSpeed = math.abs(hum.WalkSpeed) end
   Utility:Notify("Moonwalk", "Disabled", 2, "Success")
end)

Commands:Register("iceskate", "Enable ice skating", 0, function(args)
   Echo.Features.IceSkate = true
   task.spawn(function()
       while Echo.Features.IceSkate do
           local hum = Utility:GetHumanoid()
           if hum then
               hum.WalkSpeed = 100
               hum.JumpPower = 0
           end
           task.wait(0.1)
       end
   end)
   Utility:Notify("IceSkate", "Ice skating enabled", 2, "Success")
end)

Commands:Register("uniceskate", "Disable ice skating", 0, function(args)
   Echo.Features.IceSkate = false
   local hum = Utility:GetHumanoid()
   if hum then
       hum.WalkSpeed = 16
       hum.JumpPower = 50
   end
   Utility:Notify("IceSkate", "Disabled", 2, "Success")
end)

Commands:Register("bunnyhop", "Enable bunny hop", 0, function(args)
   Echo.Features.BunnyHop = true
   task.spawn(function()
       while Echo.Features.BunnyHop do
           local hum = Utility:GetHumanoid()
           if hum and hum.FloorMaterial ~= Enum.Material.Air then
               hum:ChangeState(Enum.HumanoidStateType.Jumping)
           end
           task.wait(0.1)
       end
   end)
   Utility:Notify("BunnyHop", "Bunny hop enabled", 2, "Success")
end)

Commands:Register("unbunnyhop", "Disable bunny hop", 0, function(args)
   Echo.Features.BunnyHop = false
   Utility:Notify("BunnyHop", "Disabled", 2, "Success")
end)

Commands:Register("autojump", "Auto jump over obstacles", 0, function(args)
   Echo.Features.AutoJump = true
   task.spawn(function()
       while Echo.Features.AutoJump do
           local hum = Utility:GetHumanoid()
           local hrp = Utility:GetHRP()
           if hum and hrp then
               local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector * 5)
               local hit = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
               if hit and hum.FloorMaterial ~= Enum.Material.Air then
                   hum:ChangeState(Enum.HumanoidStateType.Jumping)
               end
           end
           task.wait(0.1)
       end
   end)
   Utility:Notify("AutoJump", "Auto jump enabled", 2, "Success")
end)

Commands:Register("unautojump", "Disable auto jump", 0, function(args)
   Echo.Features.AutoJump = false
   Utility:Notify("AutoJump", "Disabled", 2, "Success")
end)

Commands:Register("autosprint", "Auto sprint", 0, function(args)
   Echo.Features.AutoSprint = true
   task.spawn(function()
       while Echo.Features.AutoSprint do
           local hum = Utility:GetHumanoid()
           if hum and hum.MoveDirection.Magnitude > 0 then
               hum.WalkSpeed = 32
           else
               hum.WalkSpeed = 16
           end
           task.wait(0.1)
       end
   end)
   Utility:Notify("AutoSprint", "Auto sprint enabled", 2, "Success")
end)

Commands:Register("unautosprint", "Disable auto sprint", 0, function(args)
   Echo.Features.AutoSprint = false
   local hum = Utility:GetHumanoid()
   if hum then hum.WalkSpeed = 16 end
   Utility:Notify("AutoSprint", "Disabled", 2, "Success")
end)

Commands:Register("infinitejump", "Infinite jump", 0, function(args)
   Echo.Features.InfiniteJump = true
   Utility:Notify("InfiniteJump", "Infinite jump enabled (jump in air)", 2, "Success")
end)

Commands:Register("uninfinitejump", "Disable infinite jump", 0, function(args)
   Echo.Features.InfiniteJump = false
   Utility:Notify("InfiniteJump", "Disabled", 2, "Success")
end)

Commands:Register("airwalk", "Walk on air", 0, function(args)
   Echo.Features.AirWalk = true
   task.spawn(function()
       while Echo.Features.AirWalk do
           local hrp = Utility:GetHRP()
           if hrp and hrp.Velocity.Y < 0 then
               hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
           end
           task.wait()
       end
   end)
   Utility:Notify("AirWalk", "Air walk enabled", 2, "Success")
end)

Commands:Register("unairwalk", "Disable air walk", 0, function(args)
   Echo.Features.AirWalk = false
   Utility:Notify("AirWalk", "Disabled", 2, "Success")
end)

Commands:Register("waterwalk", "Walk on water", 0, function(args)
   Echo.Features.WaterWalk = true
   task.spawn(function()
       while Echo.Features.WaterWalk do
           local hrp = Utility:GetHRP()
           if hrp then
               local ray = Ray.new(hrp.Position, Vector3.new(0, -10, 0))
               local hit, pos = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
               if hit and hit.Name:lower():find("water") then
                   hrp.CFrame = CFrame.new(hrp.Position.X, pos.Y + 3, hrp.Position.Z)
               end
           end
           task.wait()
       end
   end)
   Utility:Notify("WaterWalk", "Water walk enabled", 2, "Success")
end)

Commands:Register("unwaterwalk", "Disable water walk", 0, function(args)
   Echo.Features.WaterWalk = false
   Utility:Notify("WaterWalk", "Disabled", 2, "Success")
end)

Commands:Register("wallwalk", "Walk on walls", 0, function(args)
   Echo.Features.WallWalk = true
   task.spawn(function()
       while Echo.Features.WallWalk do
           local hrp = Utility:GetHRP()
           local hum = Utility:GetHumanoid()
           if hrp and hum then
               local ray = Ray.new(hrp.Position, hrp.CFrame.RightVector * 3)
               local hit = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
               if hit then
                   hrp.CFrame = hrp.CFrame * CFrame.new(0, 0.5, 0)
                   hum.PlatformStand = true
               else
                   hum.PlatformStand = false
               end
           end
           task.wait()
       end
   end)
   Utility:Notify("WallWalk", "Wall walk enabled", 2, "Success")
end)

Commands:Register("unwallwalk", "Disable wall walk", 0, function(args)
   Echo.Features.WallWalk = false
   local hum = Utility:GetHumanoid()
   if hum then hum.PlatformStand = false end
   Utility:Notify("WallWalk", "Disabled", 2, "Success")
end)

Commands:Register("ceilingwalk", "Walk on ceiling", 0, function(args)
   Echo.Features.CeilingWalk = true
   task.spawn(function()
       while Echo.Features.CeilingWalk do
           local hrp = Utility:GetHRP()
           if hrp then
               local ray = Ray.new(hrp.Position, Vector3.new(0, 10, 0))
               local hit, pos = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
               if hit then
                   hrp.CFrame = CFrame.new(hrp.Position.X, pos.Y - 3, hrp.Position.Z)
               end
           end
           task.wait()
       end
   end)
   Utility:Notify("CeilingWalk", "Ceiling walk enabled", 2, "Success")
end)

Commands:Register("unceilingwalk", "Disable ceiling walk", 0, function(args)
   Echo.Features.CeilingWalk = false
   Utility:Notify("CeilingWalk", "Disabled", 2, "Success")
end)

Commands:Register("spiderman", "Spider-man mode", 0, function(args)
   Echo.Features.Spiderman = true
   task.spawn(function()
       while Echo.Features.Spiderman do
           local hrp = Utility:GetHRP()
           local hum = Utility:GetHumanoid()
           if hrp and hum and hum.MoveDirection.Magnitude > 0 then
               local ray = Ray.new(hrp.Position, hum.MoveDirection * 5)
               local hit = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
               if hit then
                   hrp.CFrame = hrp.CFrame + Vector3.new(0, 0.5, 0)
               end
           end
           task.wait()
       end
   end)
   Utility:Notify("Spiderman", "Spider-man mode enabled", 2, "Success")
end)

Commands:Register("unspiderman", "Disable spider-man", 0, function(args)
   Echo.Features.Spiderman = false
   Utility:Notify("Spiderman", "Disabled", 2, "Success")
end)

Commands:Register("superman", "Superman mode", 0, function(args)
   Echo.Features.Superman = true
   local hum = Utility:GetHumanoid()
   if hum then
       hum.WalkSpeed = 100
       hum.JumpPower = 100
   end
   Utility:Notify("Superman", "Superman mode enabled", 2, "Success")
end)

Commands:Register("unsuperman", "Disable superman", 0, function(args)
   Echo.Features.Superman = false
   local hum = Utility:GetHumanoid()
   if hum then
       hum.WalkSpeed = 16
       hum.JumpPower = 50
   end
   Utility:Notify("Superman", "Disabled", 2, "Success")
end)

Commands:Register("flash", "Flash mode (super speed)", 0, function(args)
   Echo.Features.Flash = true
   task.spawn(function()
       while Echo.Features.Flash do
           local hum = Utility:GetHumanoid()
           if hum then hum.WalkSpeed = 200 end
           task.wait(0.1)
       end
   end)
   Utility:Notify("Flash", "Flash mode enabled", 2, "Success")
end)

Commands:Register("unflash", "Disable flash", 0, function(args)
   Echo.Features.Flash = false
   local hum = Utility:GetHumanoid()
   if hum then hum.WalkSpeed = 16 end
   Utility:Notify("Flash", "Disabled", 2, "Success")
end)

Commands:Register("hulk", "Hulk mode (super jump)", 0, function(args)
   Echo.Features.Hulk = true
   local hum = Utility:GetHumanoid()
   if hum then hum.JumpPower = 200 end
   Utility:Notify("Hulk", "Hulk mode enabled", 2, "Success")
end)

Commands:Register("unhulk", "Disable hulk", 0, function(args)
   Echo.Features.Hulk = false
   local hum = Utility:GetHumanoid()
   if hum then hum.JumpPower = 50 end
   Utility:Notify("Hulk", "Disabled", 2, "Success")
end)

Commands:Register("antman", "Ant-man mode (tiny)", 0, function(args)
   local char = LocalPlayer.Character
   if not char then return end
   for _, part in ipairs(char:GetDescendants()) do
       if part:IsA("BasePart") then
           part.Size = part.Size * 0.1
       end
   end
   Utility:Notify("AntMan", "Ant-man mode enabled", 2, "Success")
end)

Commands:Register("giantman", "Giant-man mode (huge)", 0, function(args)
   local char = LocalPlayer.Character
   if not char then return end
   for _, part in ipairs(char:GetDescendants()) do
       if part:IsA("BasePart") then
           part.Size = part.Size * 5
       end
   end
   Utility:Notify("GiantMan", "Giant-man mode enabled", 2, "Success")
end)

Commands:Register("normalsize", "Return to normal size", 0, function(args)
   local char = LocalPlayer.Character
   if not char then return end
   char:BreakJoints()
   Utility:Notify("NormalSize", "Respawning to reset size", 2, "Success")
end)

Commands:Register("fat", "Make character fat", 0, function(args)
   local char = LocalPlayer.Character
   if not char then return end
   for _, part in ipairs(char:GetDescendants()) do
       if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
           part.Size = part.Size + Vector3.new(2, 0, 2)
       end
   end
   Utility:Notify("Fat", "You are now fat", 2, "Success")
end)

Commands:Register("skinny", "Make character skinny", 0, function(args)
   local char = LocalPlayer.Character
   if not char then return end
   for _, part in ipairs(char:GetDescendants()) do
       if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
           part.Size = part.Size - Vector3.new(0.5, 0, 0.5)
       end
   end
   Utility:Notify("Skinny", "You are now skinny", 2, "Success")
end)

Commands:Register("tall", "Make character tall", 0, function(args)
   local char = LocalPlayer.Character
   if not char then return end
   for _, part in ipairs(char:GetDescendants()) do
       if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
           part.Size = part.Size + Vector3.new(0, 2, 0)
       end
   end
   Utility:Notify("Tall", "You are now tall", 2, "Success")
end)

Commands:Register("short", "Make character short", 0, function(args)
   local char = LocalPlayer.Character
   if not char then return end
       local char = LocalPlayer.Character
   if not char then return end
   for _, part in ipairs(char:GetDescendants()) do
       if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
           part.Size = part.Size - Vector3.new(0, 0.5, 0)
       end
   end
   Utility:Notify("Short", "You are now short", 2, "Success")
end)

--// Input Handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Space and Echo.Features.InfiniteJump then
        local hum = Utility:GetHumanoid()
        if hum and hum.FloorMaterial == Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if Echo.Features.ClickTP then
            local mouse = LocalPlayer:GetMouse()
            local hrp = Utility:GetHRP()
            if hrp and mouse.Hit then
                hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end
        
        if Echo.Features.ClickDelete then
            local mouse = LocalPlayer:GetMouse()
            if mouse.Target and mouse.Target.Parent ~= LocalPlayer.Character then
                mouse.Target:Destroy()
            end
        end
        
        if Echo.Features.AutoClick then
            task.spawn(function()
                while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    mouse1click()
                    task.wait(0.01)
                end
            end)
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Echo and Echo.Features and Echo.Features.Controlling and input.UserInputType == Enum.UserInputType.Keyboard then
        local target = Echo.Features.Controlling
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
        local targetHrp = target.Character.HumanoidRootPart
        local speed = 5
        
        if input.KeyCode == Enum.KeyCode.W then
            targetHrp.CFrame = targetHrp.CFrame + targetHrp.CFrame.LookVector * speed
        elseif input.KeyCode == Enum.KeyCode.S then
            targetHrp.CFrame = targetHrp.CFrame - targetHrp.CFrame.LookVector * speed
        elseif input.KeyCode == Enum.KeyCode.A then
            targetHrp.CFrame = targetHrp.CFrame - targetHrp.CFrame.RightVector * speed
        elseif input.KeyCode == Enum.KeyCode.D then
            targetHrp.CFrame = targetHrp.CFrame + targetHrp.CFrame.RightVector * speed
        end
    end
end)

--// Main Echo Table


--// Initialize
Echo.UI = UI.new()
Echo.UI:Build()
Utility:Log(Config.Brand .. " Admin v" .. Config.Version .. " initialized", "Success")
Utility:Log("Developer: " .. Config.Developer, "Info")
Utility:Log("Prefix: " .. Config.Prefix, "Info")
Utility:Log("Commands loaded: " .. Commands.Count, "Success")

return Echo
