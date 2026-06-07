-- ========================================================
-- [PART 1]: INITIAL STATE, MODERN BLUR STYLING & DRAGGING
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
screenToggleBtn.Size = UDim2.new(0, 45, 0, 45)
screenToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
screenToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
screenToggleBtn.BackgroundTransparency = 0.2
screenToggleBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
screenToggleBtn.Font = Enum.Font.SourceSansBold
screenToggleBtn.TextSize = 22
screenToggleBtn.Text = "☰"
screenToggleBtn.Parent = screenGui

local screenToggleCorner = Instance.new("UICorner")
screenToggleCorner.CornerRadius = UDim.new(1, 0)
screenToggleCorner.Parent = screenToggleBtn

local screenToggleStroke = Instance.new("UIStroke")
screenToggleStroke.Color = Color3.fromRGB(80, 80, 80)
screenToggleStroke.Thickness = 1.5
screenToggleStroke.Parent = screenToggleBtn

-- Main Window Shell (Dark blurred see-through styling)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 300)
mainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BackgroundTransparency = 0.25
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Visible = true
mainFrame.Parent = screenGui

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
tpSpeedInput.Text = tostring(tpSpeed)
tpSpeedInput.ClearTextOnFocus = false
tpSpeedInput.Parent = tpPage
applyModernTheme(tpSpeedInput, 6, true)

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

local dropAmountInput = Instance.new("TextBox")
dropAmountInput.Size = UDim2.new(1, -10, 0, 35)
dropAmountInput.Position = UDim2.new(0, 5, 0, 90)
dropAmountInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
dropAmountInput.BackgroundTransparency = 0.4
dropAmountInput.TextColor3 = Color3.fromRGB(255, 255, 255)
dropAmountInput.Text = tostring(dropAmount)
dropAmountInput.ClearTextOnFocus = false
dropAmountInput.Parent = dropPage
applyModernTheme(dropAmountInput, 6, true)

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

-- [TAB 4 ELEMENTS]: Settings, Custom Hotkeys & Script Unloader
local bindLabel = Instance.new("TextLabel")
bindLabel.Size = UDim2.new(1, -10, 0, 20)
bindLabel.Position = UDim2.new(0, 5, 0, 5)
bindLabel.BackgroundTransparency = 1
bindLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
bindLabel.Font = Enum.Font.SourceSans
bindLabel.TextSize = 14
bindLabel.Text = "Click Button to Set Open/Close Keybind:"
bindLabel.TextXAlignment = Enum.TextXAlignment.Left
bindLabel.Parent = settingsPage

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

-- ========================================================
-- END OF PART 2 | STARTING PART 3 BELOW
-- ========================================================

-- ========================================================
-- [PART 3]: AUTOMATION LOOPS, MATHEMATICS & CLEAN UNLOADER
-- ========================================================

-- String Multiplier Text Extraction Clean Engine
local function parseNumber(str)
    local cleaned = str:gsub("[%,%s]", ""):upper()
    local suffix = cleaned:sub(-1)
    if suffix == "K" then return (tonumber(cleaned:sub(1, -2)) or 0) * 1000
    elseif suffix == "M" then return (tonumber(cleaned:sub(1, -2)) or 0) * 1000000
    elseif suffix == "B" then return (tonumber(cleaned:sub(1, -2)) or 0) * 1000000000 end
    return tonumber(cleaned) or tonumber(cleaned:match("%d+")) or 0
end

-- Display Open/Close Toggle Handler
local function toggleGuiDisplay()
    mainFrame.Visible = not mainFrame.Visible
end

screenToggleBtn.MouseButton1Click:Connect(toggleGuiDisplay)

bindToggleBtn.MouseButton1Click:Connect(function()
    if not isListeningForKey then
        isListeningForKey = true
        bindToggleBtn.Text = "...Press Any Key..."
        bindToggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 20)
    end
end)

userInputService.InputBegan:Connect(function(input, processed)
    if isListeningForKey and input.UserInputType == Enum.UserInputType.Keyboard then
        toggleKey = input.KeyCode
        isListeningForKey = false
        bindToggleBtn.Text = "Keybind: " .. tostring(toggleKey.Name)
        bindToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    elseif not processed and input.KeyCode == toggleKey then
        toggleGuiDisplay()
    end
end)

-- Loop Thread: Auto Teleport
local function teleportLoop()
    while isTpLooping and _G.BrainrotHubActive do
        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)
        if rootPart then
            rootPart.CFrame = CFrame.new(tpLocations[tpIndex])
            tpIndex = (tpIndex == 1) and 2 or 1
        end
        task.wait(tpSpeed)
    end
end

tpToggleBtn.MouseButton1Click:Connect(function()
    isTpLooping = not isTpLooping
    tpToggleBtn.Text = isTpLooping and "Auto TP: ON" or "Auto TP: OFF"
    tpToggleBtn.BackgroundColor3 = isTpLooping and Color3.fromRGB(40, 140, 40) or Color3.fromRGB(150, 40, 40)
    if isTpLooping then task.spawn(teleportLoop) end
end)

tpSpeedInput.FocusLost:Connect(function()
    local num = tonumber(tpSpeedInput.Text)
    if num and num >= 0 then tpSpeed = num else tpSpeedInput.Text = tostring(tpSpeed) end
end)

-- Auto Dynamic Max Bet Balance Checker
local function getLatestDropAmount()
    if isMaxBetEnabled then
        local leaderstats = player:FindFirstChild("leaderstats")
        local coins = leaderstats and leaderstats:FindFirstChild("Coins")
        if coins then
            local balance = coins.Value
            if balance > 0 then
                dropAmountInput.Text = tostring(balance)
                return balance
            end
        end
    end
    return dropAmount
end

-- Loop Thread: Auto Bet Plinko Drop
local function dropLoop()
    local remote = game:GetService("ReplicatedStorage"):WaitForChild("BrainrotPlinkoDrop", 5)
    while isDropLooping and _G.BrainrotHubActive and remote do
        local activeBet = getLatestDropAmount()
        remote:FireServer(activeBet)
        task.wait(dropSpeed)
    end
end

dropToggleBtn.MouseButton1Click:Connect(function()
    isDropLooping = not isDropLooping
    dropToggleBtn.Text = isDropLooping and "Auto Bet: ON" or "Auto Bet: OFF"
    dropToggleBtn.BackgroundColor3 = isDropLooping and Color3.fromRGB(40, 140, 40) or Color3.fromRGB(150, 40, 40)
    if isDropLooping then task.spawn(dropLoop) end
end)

maxBetToggleBtn.MouseButton1Click:Connect(function()
    isMaxBetEnabled = not isMaxBetEnabled
    maxBetToggleBtn.Text = isMaxBetEnabled and "Auto Max Bet: ON" or "Auto Max Bet: OFF"
    maxBetToggleBtn.BackgroundColor3 = isMaxBetEnabled and Color3.fromRGB(40, 140, 40) or Color3.fromRGB(150, 40, 40)
    if isMaxBetEnabled then getLatestDropAmount() end
end)

dropAmountInput.FocusLost:Connect(function()
    local num = tonumber(dropAmountInput.Text)
    if num then dropAmount = num else dropAmountInput.Text = tostring(dropAmount) end
end)

-- Always Win Expansion Platform Module
winToggleBtn.MouseButton1Click:Connect(function()
    local targetPad = workspace:FindFirstChild("BrainrotPlinkoBoard") and workspace.BrainrotPlinkoBoard:FindFirstChild("BinPad1")
    if not targetPad then
        winToggleBtn.Text = "Error: BinPad1 Missing!"
        return
    end

    isAlwaysWinEnabled = not isAlwaysWinEnabled
    if isAlwaysWinEnabled then
        originalCFrame = targetPad.CFrame
        originalSize = targetPad.Size
        targetPad.CFrame = CFrame.new(-147.938568, 24, -57.5162621, 1, 0, 0, 0, 1, 0, 0, 0, 1)
        targetPad.Size = Vector3.new(119.05000305175781, 1.2599999904632568, 9)
        winToggleBtn.Text = "Always Win: ON"
        winToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
    else
        if originalCFrame and originalSize then
            targetPad.CFrame = originalCFrame
            targetPad.Size = originalSize
        end
        winToggleBtn.Text = "Always Win: OFF"
        winToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    end
end)

-- Loop Thread: Auto Verification Rebirth
local function rebirthLoop()
    local remote = game:GetService("ReplicatedStorage"):WaitForChild("BrainrotPlinkoRebirth", 5)
    local button = playerGui:WaitForChild("PlinkoExtraControlsGui", 5):WaitForChild("RebirthButton", 5)
    local leaderstats = player:WaitForChild("leaderstats", 5)
    local coinsValue = leaderstats and leaderstats:WaitForChild("Coins", 5)
    
    while isRebirthLooping and _G.BrainrotHubActive and remote and button and coinsValue do
        local requiredMoney = parseNumber(button.Text)
        local currentMoney = coinsValue.Value
        rebirthStatusLabel.Text = string.format("Need: %s\nHave: %s", button.Text, tostring(currentMoney))
        
        if currentMoney >= requiredMoney and requiredMoney > 0 then
            remote:FireServer()
            rebirthStatusLabel.Text = "Status: Rebirth Triggered!"
            task.wait(0.5)
        end
        task.wait(rebirthDelay)
    end
end

rebirthToggleBtn.MouseButton1Click:Connect(function()
    isRebirthLooping = not isRebirthLooping
    rebirthToggleBtn.Text = isRebirthLooping and "Auto Rebirth: ON" or "Auto Rebirth: OFF"
    rebirthToggleBtn.BackgroundColor3 = isRebirthLooping and Color3.fromRGB(40, 140, 40) or Color3.fromRGB(150, 40, 40)
    if isRebirthLooping then task.spawn(rebirthLoop) else rebirthStatusLabel.Text = "Status: Waiting..." end
end)

-- Clean Script Unload Destroyer Module
unloadBtn.MouseButton1Click:Connect(function()
    _G.BrainrotHubActive = false
    isTpLooping = false
    isDropLooping = false
    isRebirthLooping = false
    
    if isAlwaysWinEnabled then
        local targetPad = workspace:FindFirstChild("BrainrotPlinkoBoard") and workspace.BrainrotPlinkoBoard:FindFirstChild("BinPad1")
        if targetPad and originalCFrame and originalSize then
            targetPad.CFrame = originalCFrame
            targetPad.Size = originalSize
        end
    end
    screenGui:Destroy()
end)
-- ========================================================
-- END OF SCRIPT FRAMEWORK
-- ========================================================
