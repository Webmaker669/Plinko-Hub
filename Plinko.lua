-- ========================================================
-- [PART 1]: INITIAL STATE, MODERN BLUR STYLING & DRAGGING
-- ========================================================

-- Configuration and Core States
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- Global Shared Variables
_G.BrainrotHubActive = true
_G.HubElements = {}

_G.HubState = {
    isTpLooping = false,
    tpSpeed = 1.0,
    tpLocations = {Vector3.new(-38, 19, 51), Vector3.new(222, 46, 52)},
    tpIndex = 1,
    isDropLooping = false,
    dropSpeed = 0.1,
    dropAmount = 1000,
    isMaxBetEnabled = false,
    isRebirthLooping = false,
    rebirthDelay = 1.0,
    isAlwaysWinEnabled = false,
    originalCFrame = nil,
    originalSize = nil,
    toggleKey = Enum.KeyCode.RightControl,
    isListeningForKey = false
}

-- Create Main ScreenGui Container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotUltimateHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
_G.HubElements.ScreenGui = screenGui

-- Screen Toggle Floating Action Button (Always Visible)
local screenToggleBtn = Instance.new("TextButton")
screenToggleBtn.Size = UDim2.new(0, 45, 0, 45)
screenToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
screenToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
screenToggleBtn.BackgroundTransparency = 0.2
screenToggleBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
screenToggleBtn.Font = Enum.Font.SourceSansBold
screenToggleBtn.TextSize = 22
screenToggleBtn.Text = "☰"
screenToggleBtn.Parent = screenGui
_G.HubElements.ScreenToggleBtn = screenToggleBtn

local screenToggleCorner = Instance.new("UICorner")
screenToggleCorner.CornerRadius = UDim.new(1, 0)
screenToggleCorner.Parent = screenToggleBtn

local screenToggleStroke = Instance.new("UIStroke")
screenToggleStroke.Color = Color3.fromRGB(80, 80, 80)
screenToggleStroke.Thickness = 1.5
screenToggleStroke.Parent = screenToggleBtn

-- Main Window Shell (Dark blurred see-through styling)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 440, 0, 310) -- Sized slightly up to store layout elements smoothly
mainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BackgroundTransparency = 0.25
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Visible = true
mainFrame.Parent = screenGui
_G.HubElements.MainFrame = mainFrame

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(70, 70, 70)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

-- Top Tab Header Bar (Only this part allows dragging)
local topDragHeader = Instance.new("Frame")
topDragHeader.Size = UDim2.new(1, 0, 0, 35)
topDragHeader.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
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
titleLabel.TextSize = 14
titleLabel.Text = "BRAINROT PLINKO SUPREME HUB"
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topDragHeader

-- Left Navigation Sidebar Panel Layout
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 115, 1, -35)
sidebar.Position = UDim2.new(0, 0, 0, 35)
sidebar.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
sidebar.BackgroundTransparency = 0.5
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame
_G.HubElements.Sidebar = sidebar

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 12)
sidebarCorner.Parent = sidebar

-- Right Content Main Panel Box
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -125, 1, -45)
contentContainer.Position = UDim2.new(0, 120, 0, 40)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame
_G.HubElements.ContentContainer = contentContainer

-- Top Drag-Bar Window Logic Handler
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

-- ========================================================
-- END OF PART 1 | STARTING PART 2 BELOW
-- ========================================================

-- ========================================================
-- [PART 2]: TAB CREATION & LAYOUT BUTTONS
-- ========================================================

local sidebar = _G.HubElements.Sidebar
local contentContainer = _G.HubElements.ContentContainer

-- Shared UI Rounding Styling Generator Function
local function applyModernTheme(element, radius, isInput)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = element

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = isInput and Color3.fromRGB(90, 90, 90) or Color3.fromRGB(55, 55, 55)
    stroke.Parent = element
end

-- Sidebar Button Builder Setup
local tabs = {}
local pages = {}
local function createTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = UDim2.new(0, 5, 0, 10 + ((order-1) * 38))
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

-- Disclaimer Asset (Underneath sidebar layout navigation options)
local disclaimerLabel = Instance.new("TextLabel")
disclaimerLabel.Size = UDim2.new(1, -10, 0, 95)
disclaimerLabel.Position = UDim2.new(0, 5, 1, -105)
disclaimerLabel.BackgroundTransparency = 1
disclaimerLabel.TextColor3 = Color3.fromRGB(160, 120, 120)
disclaimerLabel.Font = Enum.Font.SourceSansItalic
disclaimerLabel.TextSize = 11
disclaimerLabel.Text = "Disclaimer: Some features may get patched and not fixed by the script's creator."
disclaimerLabel.TextWrapped = true
disclaimerLabel.TextXAlignment = Enum.TextXAlignment.Center
disclaimerLabel.TextYAlignment = Enum.TextYAlignment.Bottom
disclaimerLabel.Parent = sidebar

-- [TAB 1 ELEMENTS]: Auto Teleport
local tpToggleBtn = Instance.new("TextButton")
tpToggleBtn.Size = UDim2.new(1, -10, 0, 40)
tpToggleBtn.Position = UDim2.new(0, 5, 0, 5)
tpToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
tpToggleBtn.BackgroundTransparency = 0.2
tpToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpToggleBtn.Font = Enum.Font.SourceSansBold
tpToggleBtn.TextSize = 15
tpToggleBtn.Text = "Auto TP: OFF"
tpToggleBtn.Parent = tpPage
applyModernTheme(tpToggleBtn, 8, false)
_G.HubElements.TpToggleBtn = tpToggleBtn

local tpSpeedLabel = Instance.new("TextLabel")
tpSpeedLabel.Size = UDim2.new(1, -10, 0, 20)
tpSpeedLabel.Position = UDim2.new(0, 5, 0, 55)
tpSpeedLabel.BackgroundTransparency = 1
tpSpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
tpSpeedLabel.Font = Enum.Font.SourceSans
tpSpeedLabel.TextSize = 13
tpSpeedLabel.Text = "TP Rate Cycle Delay (seconds):"
tpSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
tpSpeedLabel.Parent = tpPage

local tpSpeedInput = Instance.new("TextBox")
tpSpeedInput.Size = UDim2.new(1, -10, 0, 35)
tpSpeedInput.Position = UDim2.new(0, 5, 0, 80)
tpSpeedInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
tpSpeedInput.BackgroundTransparency = 0.4
tpSpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
tpSpeedInput.Font = Enum.Font.SourceSans
tpSpeedInput.TextSize = 15
tpSpeedInput.Text = tostring(_G.HubState.tpSpeed)
tpSpeedInput.ClearTextOnFocus = false
tpSpeedInput.Parent = tpPage
applyModernTheme(tpSpeedInput, 6, true)
_G.HubElements.TpSpeedInput = tpSpeedInput

-- [TAB 2 ELEMENTS]: Auto Bet & Max Bet & Board Mod
local dropToggleBtn = Instance.new("TextButton")
dropToggleBtn.Size = UDim2.new(1, -10, 0, 40)
dropToggleBtn.Position = UDim2.new(0, 5, 0, 5)
dropToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
dropToggleBtn.BackgroundTransparency = 0.2
dropToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dropToggleBtn.Font = Enum.Font.SourceSansBold
dropToggleBtn.TextSize = 15
dropToggleBtn.Text = "Auto Bet: OFF"
dropToggleBtn.Parent = dropPage
applyModernTheme(dropToggleBtn, 8, false)
_G.HubElements.DropToggleBtn = dropToggleBtn

local maxBetToggleBtn = Instance.new("TextButton")
maxBetToggleBtn.Size = UDim2.new(1, -10, 0, 30)
maxBetToggleBtn.Position = UDim2.new(0, 5, 0, 50)
maxBetToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
maxBetToggleBtn.BackgroundTransparency = 0.4
maxBetToggleBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
maxBetToggleBtn.Font = Enum.Font.SourceSansBold
maxBetToggleBtn.TextSize = 13
maxBetToggleBtn.Text = "Auto Max Bet: OFF"
maxBetToggleBtn.Parent = dropPage
applyModernTheme(maxBetToggleBtn, 6, false)
_G.HubElements.MaxBetToggleBtn = maxBetToggleBtn

local dropAmountInput = Instance.new("TextBox")
dropAmountInput.Size = UDim2.new(1, -10, 0, 35)
dropAmountInput.Position = UDim2.new(0, 5, 0, 90)
dropAmountInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
dropAmountInput.BackgroundTransparency = 0.4
dropAmountInput.TextColor3 = Color3.fromRGB(255, 255, 255)
dropAmountInput.Text = tostring(_G.HubState.dropAmount)
dropAmountInput.ClearTextOnFocus = false
dropAmountInput.Parent = dropPage
applyModernTheme(dropAmountInput, 6, true)
_G.HubElements.DropAmountInput = dropAmountInput

local winToggleBtn = Instance.new("TextButton")
winToggleBtn.Size = UDim2.new(1, -10, 0, 35)
winToggleBtn.Position = UDim2.new(0, 5, 0, 135)
winToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
winToggleBtn.BackgroundTransparency = 0.2
winToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
winToggleBtn.Font = Enum.Font.SourceSansBold
winToggleBtn.TextSize = 14
winToggleBtn.Text = "Always Win (Board Expand): OFF"
winToggleBtn.Parent = dropPage
applyModernTheme(winToggleBtn, 8, false)
_G.HubElements.WinToggleBtn = winToggleBtn

-- [TAB 3 ELEMENTS]: Auto Rebirth
local rebirthToggleBtn = Instance.new("TextButton")
rebirthToggleBtn.Size = UDim2.new(1, -10, 0, 40)
rebirthToggleBtn.Position = UDim2.new(0, 5, 0, 5)
rebirthToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
rebirthToggleBtn.BackgroundTransparency = 0.2
rebirthToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rebirthToggleBtn.Font = Enum.Font.SourceSansBold
rebirthToggleBtn.TextSize = 16
rebirthToggleBtn.Text = "Auto Rebirth: OFF"
rebirthToggleBtn.Parent = rebirthPage
applyModernTheme(rebirthToggleBtn, 8, false)
_G.HubElements.RebirthToggleBtn = rebirthToggleBtn

local rebirthStatusLabel = Instance.new("TextLabel")
rebirthStatusLabel.Size = UDim2.new(1, -10, 0, 60)
rebirthStatusLabel.Position = UDim2.new(0, 5, 0, 55)
rebirthStatusLabel.BackgroundTransparency = 1
rebirthStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
rebirthStatusLabel.Font = Enum.Font.SourceSans
rebirthStatusLabel.TextSize = 14
rebirthStatusLabel.Text = "Status: Waiting..."
rebirthStatusLabel.TextWrapped = true
rebirthStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
rebirthStatusLabel.TextYAlignment = Enum.TextYAlignment.Top
rebirthStatusLabel.Parent = rebirthPage
_G.HubElements.RebirthStatusLabel = rebirthStatusLabel

-- [TAB 4 ELEMENTS]: Settings & Hotkey Config
local bindToggleBtn = Instance.new("TextButton")
bindToggleBtn.Size = UDim2.new(1, -10, 0, 35)
bindToggleBtn.Position = UDim2.new(0, 5, 0, 30)
bindToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
bindToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
bindToggleBtn.Font = Enum.Font.SourceSansBold
bindToggleBtn.TextSize = 14
bindToggleBtn.Text = "Keybind: RightControl"
bindToggleBtn.Parent = settingsPage
applyModernTheme(bindToggleBtn, 8, false)
_G.HubElements.BindToggleBtn = bindToggleBtn

local unloadBtn = Instance.new("TextButton")
unloadBtn.Size = UDim2.new(1, -10, 0, 40)
unloadBtn.Position = UDim2.new(0, 5, 0, 120)
unloadBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
unloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
unloadBtn.Font = Enum.Font.SourceSansBold
unloadBtn.TextSize = 15
unloadBtn.Text = "UNLOAD HUB SCRIPT"
unloadBtn.Parent = settingsPage
applyModernTheme(unloadBtn, 8, false)
_G.HubElements.UnloadBtn = unloadBtn

-- ========================================================
-- END OF PART 2 | STARTING PART 3 BELOW
-- ========================================================

-- ========================================================
-- [PART 3]: AUTOMATION LOOPS, MATHEMATICS & CLEAN UNLOADER
-- ========================================================

local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local state = _G.HubState
local ui = _G.HubElements

-- Safe Converter Engine (Patches calculation formatting bugs)
local function parseRawValue(val)
    if type(val) == "number" then return val end
    if type(val) ~= "string" then return 0 end
    local cleaned = val:gsub("[%,%s]", ""):upper()
    local suffix = cleaned:sub(-1)
    if suffix == "K" then return (tonumber(cleaned:sub(1, -2)) or 0) * 1000
    elseif suffix == "M" then return (tonumber(cleaned:sub(1, -2)) or 0) * 1000000
    elseif suffix == "B" then return (tonumber(cleaned:sub(1, -2)) or 0) * 1000000000 end
    return tonumber(cleaned) or tonumber(cleaned:match("%d+")) or 0
end

-- Open/Close Handler
local function toggleGuiDisplay()
    ui.MainFrame.Visible = not ui.MainFrame.Visible
end

ui.ScreenToggleBtn.MouseButton1Click:Connect(toggleGuiDisplay)

ui.BindToggleBtn.MouseButton1Click:Connect(function()
    if not state.isListeningForKey then
        state.isListeningForKey = true
        ui.BindToggleBtn.Text = "...Press Any Key..."
        ui.BindToggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 20)
    end
end)

userInputService.InputBegan:Connect(function(input, processed)
    if state.isListeningForKey and input.UserInputType == Enum.UserInputType.Keyboard then
        state.toggleKey = input.KeyCode
        state.isListeningForKey = false
        ui.BindToggleBtn.Text = "Keybind: " .. tostring(state.toggleKey.Name)
        ui.BindToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    elseif not processed and input.KeyCode == state.toggleKey then
        toggleGuiDisplay()
    end
end)

-- Loop Thread: Auto Teleport
local function teleportLoop()
    while state.isTpLooping and _G.BrainrotHubActive do
        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)
        if rootPart then
            rootPart.CFrame = CFrame.new(state.tpLocations[state.tpIndex])
            state.tpIndex = (state.tpIndex == 1) and 2 or 1
        end
        task.wait(state.tpSpeed)
    end
end

ui.TpToggleBtn.MouseButton1Click:Connect(function()
    state.isTpLooping = not state.isTpLooping
    ui.TpToggleBtn.Text = state.isTpLooping and "Auto TP: ON" or "Auto TP: OFF"
    ui.TpToggleBtn.BackgroundColor3 = state.isTpLooping and Color3.fromRGB(40, 140, 40) or Color3.fromRGB(150, 40, 40)
    if state.isTpLooping then task.spawn(teleportLoop) end
end)

ui.TpSpeedInput.FocusLost:Connect(function()
    local num = tonumber(ui.TpSpeedInput.Text)
    if num and num >= 0 then state.tpSpeed = num else ui.TpSpeedInput.Text = tostring(state.tpSpeed) end
end)

-- Auto Dynamic Max Bet Balance Checker Safeguard
local function getLatestDropAmount()
    if state.isMaxBetEnabled then
        local leaderstats = player:FindFirstChild("leaderstats")
        local coins = leaderstats and leaderstats:FindFirstChild("Coins")
        if coins then
            local balance = parseRawValue(coins.Value)
            if balance and balance > 0 then
                ui.DropAmountInput.Text = tostring(balance)
                return balance
            end
        end
    end
    return parseRawValue(state.dropAmount) -- Fallback safely to current typed value instead of breaking at 5
end

-- Loop Thread: Auto Bet
local function dropLoop()
    local remote = game:GetService("ReplicatedStorage"):WaitForChild("BrainrotPlinkoDrop", 5)
    while state.isDropLooping and _G.BrainrotHubActive and remote do
        local activeBet = getLatestDropAmount()
        remote:FireServer(activeBet)
        task.wait(state.dropSpeed)
    end
end

ui.DropToggleBtn.MouseButton1Click:Connect(function()
    state.isDropLooping = not state.isDropLooping
    ui.DropToggleBtn.Text = state.isDropLooping and "Auto Bet: ON" or "Auto Bet: OFF"
    ui.DropToggleBtn.BackgroundColor3 = state.isDropLooping and Color3.fromRGB(40, 140, 40) or Color3.fromRGB(150, 40, 40)
    if state.isDropLooping then task.spawn(dropLoop) end
end)

ui.MaxBetToggleBtn.MouseButton1Click:Connect(function()
    state.isMaxBetEnabled = not state.isMaxBetEnabled
    ui.MaxBetToggleBtn.Text = state.isMaxBetEnabled and "Auto Max Bet: ON" or "Auto Max Bet: OFF"
    ui.MaxBetToggleBtn.BackgroundColor3 = state.isMaxBetEnabled and Color3.fromRGB(40, 140, 40) or Color3.fromRGB(150, 40, 40)
    if state.isMaxBetEnabled then getLatestDropAmount() end
end)

ui.DropAmountInput.FocusLost:Connect(function()
    local num = tonumber(ui.DropAmountInput.Text)
    if num then state.dropAmount = num else ui.DropAmountInput.Text = tostring(state.dropAmount) end
end)

-- Always Win Expansion Platform Module
ui.WinToggleBtn.MouseButton1Click:Connect(function()
    local targetPad = workspace:FindFirstChild("BrainrotPlinkoBoard") and workspace.BrainrotPlinkoBoard:FindFirstChild("BinPad1")
    if not targetPad then
        ui.WinToggleBtn.Text = "Error: BinPad1 Missing!"
        return
    end
    state.isAlwaysWinEnabled = not state.isAlwaysWinEnabled
    if state.isAlwaysWinEnabled then
        state.originalCFrame = targetPad.CFrame
        state.originalSize = targetPad.Size
        targetPad.CFrame = CFrame.new(-147.938568, 24, -57.5162621, 1, 0, 0, 0, 1, 0, 0, 0, 1)
        targetPad.Size = Vector3.new(119.05000305175781, 1.2599999904632568, 9)
        ui.WinToggleBtn.Text = "Always Win: ON"
        ui.WinToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
    else
        if state.originalCFrame and state.originalSize then
            targetPad.CFrame = state.originalCFrame
            targetPad.Size = state.originalSize
        end
        ui.WinToggleBtn.Text = "Always Win: OFF"
        ui.WinToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    end
end)

-- Loop Thread: Auto Rebirth Thread Validation Check Fix
local function rebirthLoop()
    local remote = game:GetService("ReplicatedStorage"):WaitForChild("BrainrotPlinkoRebirth", 5)
    local button = player.PlayerGui:WaitForChild("PlinkoExtraControlsGui", 5):WaitForChild("RebirthButton", 5)
    local leaderstats = player:WaitForChild("leaderstats", 5)
    local coinsValue = leaderstats and leaderstats:WaitForChild("Coins", 5)
    
    while state.isRebirthLooping and _G.BrainrotHubActive and remote and button and coinsValue do
        local requiredMoney = parseRawValue(button.Text)
        local currentMoney = parseRawValue(coinsValue.Value)
        
        if currentMoney >= requiredMoney and requiredMoney > 0 then
            ui.RebirthStatusLabel.Text = string.format("Rebirthing!\nNeed: %s | Have: %s", button.Text, tostring(currentMoney))
            remote:FireServer()
            task.wait(0.5)
        else
            ui.RebirthStatusLabel.Text = string.format("Status: Insufficient Coins\nNeed: %s | Have: %s", button.Text, tostring(currentMoney))
        end
        task.wait(state.rebirthDelay)
    end
end

ui.RebirthToggleBtn.MouseButton1Click:Connect(function()
    state.isRebirthLooping = not state.isRebirthLooping
    ui.RebirthToggleBtn.Text = state.isRebirthLooping and "Auto Rebirth: ON" or "Auto Rebirth: OFF"
    ui.RebirthToggleBtn.BackgroundColor3 = state.isRebirthLooping and Color3.fromRGB(40, 140, 40) or Color3.fromRGB(150, 40, 40)
    if state.isRebirthLooping then task.spawn(rebirthLoop) else ui.RebirthStatusLabel.Text = "Status: Waiting..." end
end)

-- Unload Module
ui.UnloadBtn.MouseButton1Click:Connect(function()
    _G.BrainrotHubActive = false
    state.isTpLooping = false
    state.isDropLooping = false
    state.isRebirthLooping = false
    if state.isAlwaysWinEnabled then
        local targetPad = workspace:FindFirstChild("BrainrotPlinkoBoard") and workspace.BrainrotPlinkoBoard:FindFirstChild("BinPad1")
        if targetPad and state.originalCFrame and state.originalSize then
            targetPad.CFrame = state.originalCFrame
            targetPad.Size = state.originalSize
        end
    end
    ui.ScreenGui:Destroy()
end)
-- ========================================================
-- END OF SCRIPT SCRIPT FRAMEWORK
-- ========================================================

