-- ========================================================
-- [PART 1]: INITIAL STATE, BLUR SYSTEM, & COMPACT FRAMEWORK
-- ========================================================

-- Configuration and Core States
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- Script Active Trackers
_G.BrainrotHubActive = true

local isTpLooping = false
local tpSpeed = 1.0
local tpLocations = {
    Vector3.new(-38, 19, 51),
    Vector3.new(222, 46, 52)
}
local tpIndex = 1

local isDropLooping = false
local dropSpeed = 0.1
local dropAmount = 1000
local isMaxBetEnabled = false

local isRebirthLooping = false
local rebirthDelay = 1.0

local isAlwaysWinEnabled = false
local originalCFrame = nil
local originalSize = nil

-- Keybind Config
local toggleKey = Enum.KeyCode.RightControl
local isListeningForKey = false

-- Create Main ScreenGui Container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotUltimateHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Screen Toggle Floating Action Button (Always Visible)
local screenToggleBtn = Instance.new("TextButton")
screenToggleBtn.Size = UDim2.new(0, 50, 0, 50)
screenToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
screenToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
screenToggleBtn.BackgroundTransparency = 0.3
screenToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
screenToggleBtn.Font = Enum.Font.SourceSansBold
screenToggleBtn.TextSize = 24
screenToggleBtn.Text = "☰"
screenToggleBtn.Parent = screenGui

local screenToggleCorner = Instance.new("UICorner")
screenToggleCorner.CornerRadius = UDim.new(1, 0)
screenToggleCorner.Parent = screenToggleBtn

local screenToggleStroke = Instance.new("UIStroke")
screenToggleStroke.Color = Color3.fromRGB(80, 80, 80)
screenToggleStroke.Thickness = 1.5
screenToggleStroke.Parent = screenToggleBtn

-- Main Window Shell
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 300)
mainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BackgroundTransparency = 0.25 -- Acrylic blurred aesthetic base
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Visible = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(60, 60, 60)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

-- Browser Header Style Top Drag Bar
local topDragHeader = Instance.new("Frame")
topDragHeader.Size = UDim2.new(1, 0, 0, 35)
topDragHeader.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
topDragHeader.BackgroundTransparency = 0.4
topDragHeader.BorderSizePixel = 0
topDragHeader.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = topDragHeader

-- Text Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 15
titleLabel.Text = "BRAINROT PLINKO SUPREME HUB v2"
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topDragHeader

-- Left Navigation Sidebar Panel Layout
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 110, 1, -35)
sidebar.Position = UDim2.new(0, 0, 0, 35)
sidebar.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
sidebar.BackgroundTransparency = 0.5
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 12)
sidebarCorner.Parent = sidebar

-- Right Content Main Panel Box
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -120, 1, -45)
contentContainer.Position = UDim2.new(0, 115, 0, 40)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

-- Shared UI Styling Generator Function
local function applyModernTheme(element, radius, isInput)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = element

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = isInput and Color3.fromRGB(90, 90, 90) or Color3.fromRGB(50, 50, 50)
    stroke.Parent = element
end

-- Top Drag-Bar Browser Window Logic Handler
local dragging, dragInput, dragStart, startPos
topDragHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

topDragHeader.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

userInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Sidebar Button Builder Setup
local tabs = {}
local pages = {}
local function createTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = UDim2.new(0, 5, 0, 10 + ((order-1) * 42))
    btn.BackgroundColor3 = order == 1 and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(20, 20, 20)
    btn.BackgroundTransparency = 0.3
    btn.TextColor3 = order == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 170)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.Text = name
    btn.Parent = sidebar
    applyModernTheme(btn, 6, false)

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = order == 1
    page.Parent = contentContainer

    tabs[name] = btn
    pages[name] = page

    btn.MouseButton1Click:Connect(function()
        for tName, tBtn in pairs(tabs) do
            tBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            tBtn.TextColor3 = Color3.fromRGB(170, 170, 170)
            pages[tName].Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        page.Visible = true
    end)
    return page
end

-- Construct Interface Functional Tabs
local tpPage = createTab("Auto TP", 1)
local dropPage = createTab("Auto Bet", 2)
local rebirthPage = createTab("Auto Rebirth", 3)
local settingsPage = createTab("Settings", 4)

-- ========================================================
-- END OF PART 1 | STARTING PART 2 BELOW
-- ========================================================
