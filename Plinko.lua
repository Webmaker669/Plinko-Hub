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
    tpLocations = { Vector3.new(-38, 19, 51), Vector3.new(222, 46, 52)},
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
mainFrame.Size = UDim2.new(0, 440, 0, 310)
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
-- [PART 3]: AUTOMATION LOOPS, MATHEMATICS & CLEAN UNLOADER
-- ========================================================
local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local state = _G.HubState
local ui = _G.HubElements

-- FIXED Parsing Engine: Handles sudden large jumps, scientific notations, decimals, and abbreviations safely
local function parseRawValue(val)
    if type(val) == "number" then return val end
    if type(val) ~= "string" then return 0 end
    
    -- Strip whitespaces and formatting commas
    local cleaned = val:gsub("[%s%,]", ""):upper()
    
    -- Detect standard letter multiplier endings
    local suffix = cleaned:sub(-1)
    local multiplier = 1
    
    if suffix == "K" then 
        multiplier = 1000
        cleaned = cleaned:sub(1, -2)
    elseif suffix == "M" then 
        multiplier = 1000000
        cleaned = cleaned:sub(1, -2)
    elseif suffix == "B" then 
        multiplier = 1000000000 
        cleaned = cleaned:sub(1, -2)
    elseif suffix == "T" then
        multiplier = 1000000000000
        cleaned = cleaned:sub(1, -2)
    end
    
    -- Handles raw numbers, decimals, or scientific notation strings perfectly
    local baseNumber = tonumber(cleaned)
    if not baseNumber then
        -- Fallback recovery search if unexpected text is combined
        local match = cleaned:match("[%d%.e%+%-]+")
        baseNumber = tonumber(match) or 0
    end
    
    return math.floor(baseNumber * multiplier)
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
    return parseRawValue(state.dropAmount)
end

-- Loop Thread: Auto Bet
local function dropLoop()
    local remote = game:GetService("ReplicatedStorage"):WaitForChild("BrainrotPlinkoDrop", 5)
    while state.isDropLooping and _G.BrainrotHubActive and remote do
        local activeBet = getLatestDropAmount()
        local args = { activeBet }
        remote:FireServer(unpack(args))
        task.wait(state.dropSpeed)
    end
end

-- Helper structure to force safety updates on UI Buttons
local function updateBetButtonsUI()
    ui.DropToggleBtn.Text = state.isDropLooping and "Auto Bet: ON" or "Auto Bet: OFF"
    ui.DropToggleBtn.BackgroundColor3 = state.isDropLooping and Color3.fromRGB(40, 140, 40) or Color3.fromRGB(150, 40, 40)
    
    ui.MaxBetToggleBtn.Text = state.isMaxBetEnabled and "Auto Max Bet: ON" or "Auto Max Bet: OFF"
    ui.MaxBetToggleBtn.BackgroundColor3 = state.isMaxBetEnabled and Color3.fromRGB(40, 140, 40) or Color3.fromRGB(150, 40, 40)
end

ui.DropToggleBtn.MouseButton1Click:Connect(function()
    -- Turning on Auto Bet turns off Max Bet to prevent conflicts
    if not state.isDropLooping then
        state.isMaxBetEnabled = false
    end
    
    state.isDropLooping = not state.isDropLooping
    updateBetButtonsUI()
    if state.isDropLooping then task.spawn(dropLoop) end
end)

-- ANTI-CONFUSION UI: Forces Auto Bet off if Max Bet is clicked/toggled on
ui.MaxBetToggleBtn.MouseButton1Click:Connect(function()
    if not state.isMaxBetEnabled then
        state.isDropLooping = false -- Turns off standard custom auto-betting
    end
    
    state.isMaxBetEnabled = not state.isMaxBetEnabled
    updateBetButtonsUI()
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

-- Loop Thread: Auto Rebirth Thread
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
