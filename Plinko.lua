-- ========================================================
-- [PART 1]: ENGINE STATE CONFIG & UI ARCHITECTURE
-- ========================================================

-- Configuration and States
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

local isRebirthLooping = false
local rebirthDelay = 1.0

-- Create ScreenGui Container
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotHubGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Create Main Window Window Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 250)
mainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- Left Navigation Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 100, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 8)
sidebarCorner.Parent = sidebar

-- Sidebar Buttons
local tpTabBtn = Instance.new("TextButton")
tpTabBtn.Size = UDim2.new(1, -10, 0, 40)
tpTabBtn.Position = UDim2.new(0, 5, 0, 10)
tpTabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
tpTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpTabBtn.Font = Enum.Font.SourceSansBold
tpTabBtn.TextSize = 14
tpTabBtn.Text = "Auto TP"
tpTabBtn.Parent = sidebar

local dropTabBtn = Instance.new("TextButton")
dropTabBtn.Size = UDim2.new(1, -10, 0, 40)
dropTabBtn.Position = UDim2.new(0, 5, 0, 55)
dropTabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
dropTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
dropTabBtn.Font = Enum.Font.SourceSansBold
dropTabBtn.TextSize = 14
dropTabBtn.Text = "Auto Bet"
dropTabBtn.Parent = sidebar

local rebirthTabBtn = Instance.new("TextButton")
rebirthTabBtn.Size = UDim2.new(1, -10, 0, 40)
rebirthTabBtn.Position = UDim2.new(0, 5, 0, 100)
rebirthTabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
rebirthTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
rebirthTabBtn.Font = Enum.Font.SourceSansBold
rebirthTabBtn.TextSize = 14
rebirthTabBtn.Text = "Auto Rebirth"
rebirthTabBtn.Parent = sidebar

-- Right Content Panel Frame
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -110, 1, -10)
contentContainer.Position = UDim2.new(0, 105, 0, 5)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

-- Page 1: Teleport Layout Elements
local tpPage = Instance.new("Frame")
tpPage.Size = UDim2.new(1, 0, 1, 0)
tpPage.BackgroundTransparency = 1
tpPage.Visible = true
tpPage.Parent = contentContainer

local tpToggleBtn = Instance.new("TextButton")
tpToggleBtn.Size = UDim2.new(1, -10, 0, 40)
tpToggleBtn.Position = UDim2.new(0, 5, 0, 10)
tpToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
tpToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpToggleBtn.Font = Enum.Font.SourceSansBold
tpToggleBtn.TextSize = 16
tpToggleBtn.Text = "Auto TP: OFF"
tpToggleBtn.Parent = tpPage

local tpToggleCorner = Instance.new("UICorner")
tpToggleCorner.CornerRadius = UDim.new(0, 6)
tpToggleCorner.Parent = tpToggleBtn

local tpSpeedLabel = Instance.new("TextLabel")
tpSpeedLabel.Size = UDim2.new(1, -10, 0, 20)
tpSpeedLabel.Position = UDim2.new(0, 5, 0, 65)
tpSpeedLabel.BackgroundTransparency = 1
tpSpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
tpSpeedLabel.Font = Enum.Font.SourceSans
tpSpeedLabel.TextSize = 14
tpSpeedLabel.Text = "TP Delay (seconds):"
tpSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
tpSpeedLabel.Parent = tpPage

local tpSpeedInput = Instance.new("TextBox")
tpSpeedInput.Size = UDim2.new(1, -10, 0, 35)
tpSpeedInput.Position = UDim2.new(0, 5, 0, 90)
tpSpeedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
tpSpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
tpSpeedInput.Font = Enum.Font.SourceSans
tpSpeedInput.TextSize = 16
tpSpeedInput.Text = tostring(tpSpeed)
tpSpeedInput.ClearTextOnFocus = false
tpSpeedInput.Parent = tpPage

local tpInputCorner = Instance.new("UICorner")
inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = tpSpeedInput

-- ========================================================
-- END OF PART 1 | STARTING PART 2 BELOW
-- ========================================================
-- ========================================================
-- [PART 2]: TARGET CONTENT PAGES & FUNCTIONAL LOOPS
-- ========================================================

-- Page 2: Drop / Bet Layout Elements
local dropPage = Instance.new("Frame")
dropPage.Size = UDim2.new(1, 0, 1, 0)
dropPage.BackgroundTransparency = 1
dropPage.Visible = false
dropPage.Parent = contentContainer

local dropToggleBtn = Instance.new("TextButton")
dropToggleBtn.Size = UDim2.new(1, -10, 0, 40)
dropToggleBtn.Position = UDim2.new(0, 5, 0, 10)
dropToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
dropToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dropToggleBtn.Font = Enum.Font.SourceSansBold
dropToggleBtn.TextSize = 16
dropToggleBtn.Text = "Auto Bet: OFF"
dropToggleBtn.Parent = dropPage

local dropToggleCorner = Instance.new("UICorner")
dropToggleCorner.CornerRadius = UDim.new(0, 6)
dropToggleCorner.Parent = dropToggleBtn

local dropAmountLabel = Instance.new("TextLabel")
dropAmountLabel.Size = UDim2.new(1, -10, 0, 20)
dropAmountLabel.Position = UDim2.new(0, 5, 0, 65)
dropAmountLabel.BackgroundTransparency = 1
dropAmountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
dropAmountLabel.Font = Enum.Font.SourceSans
dropAmountLabel.TextSize = 14
dropAmountLabel.Text = "Bet Amount:"
dropAmountLabel.TextXAlignment = Enum.TextXAlignment.Left
dropAmountLabel.Parent = dropPage

local dropAmountInput = Instance.new("TextBox")
dropAmountInput.Size = UDim2.new(1, -10, 0, 35)
dropAmountInput.Position = UDim2.new(0, 5, 0, 90)
dropAmountInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropAmountInput.TextColor3 = Color3.fromRGB(255, 255, 255)
dropAmountInput.Font = Enum.Font.SourceSans
dropAmountInput.TextSize = 16
dropAmountInput.Text = tostring(dropAmount)
dropAmountInput.ClearTextOnFocus = false
dropAmountInput.Parent = dropPage

local dropAmountCorner = Instance.new("UICorner")
dropAmountCorner.CornerRadius = UDim.new(0, 6)
dropAmountCorner.Parent = dropAmountInput

-- Page 3: Rebirth Layout Elements
local rebirthPage = Instance.new("Frame")
rebirthPage.Size = UDim2.new(1, 0, 1, 0)
rebirthPage.BackgroundTransparency = 1
rebirthPage.Visible = false
rebirthPage.Parent = contentContainer

local rebirthToggleBtn = Instance.new("TextButton")
rebirthToggleBtn.Size = UDim2.new(1, -10, 0, 40)
rebirthToggleBtn.Position = UDim2.new(0, 5, 0, 10)
rebirthToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
rebirthToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rebirthToggleBtn.Font = Enum.Font.SourceSansBold
rebirthToggleBtn.TextSize = 16
rebirthToggleBtn.Text = "Auto Rebirth: OFF"
rebirthToggleBtn.Parent = rebirthPage

local rebirthToggleCorner = Instance.new("UICorner")
rebirthToggleCorner.CornerRadius = UDim.new(0, 6)
rebirthToggleCorner.Parent = rebirthToggleBtn

local rebirthStatusLabel = Instance.new("TextLabel")
rebirthStatusLabel.Size = UDim2.new(1, -10, 0, 60)
rebirthStatusLabel.Position = UDim2.new(0, 5, 0, 65)
rebirthStatusLabel.BackgroundTransparency = 1
rebirthStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
rebirthStatusLabel.Font = Enum.Font.SourceSans
rebirthStatusLabel.TextSize = 14
rebirthStatusLabel.Text = "Status: Waiting..."
rebirthStatusLabel.TextWrapped = true
rebirthStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
rebirthStatusLabel.TextYAlignment = Enum.TextYAlignment.Top
rebirthStatusLabel.Parent = rebirthPage

-- Tab Switching Logic Engine
local function updateTabs(activeBtn, activePage)
    tpPage.Visible = false
    dropPage.Visible = false
    rebirthPage.Visible = false
    
    tpTabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    tpTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    dropTabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    dropTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    rebirthTabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    rebirthTabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    
    activePage.Visible = true
    activeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    activeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

tpTabBtn.MouseButton1Click:Connect(function() updateTabs(tpTabBtn, tpPage) end)
dropTabBtn.MouseButton1Click:Connect(function() updateTabs(dropTabBtn, dropPage) end)
rebirthTabBtn.MouseButton1Click:Connect(function() updateTabs(rebirthTabBtn, rebirthPage) end)

-- Loop System: Auto Teleport Thread
local function teleportLoop()
    while isTpLooping do
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
    if isTpLooping then
        tpToggleBtn.Text = "Auto TP: ON"
        tpToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        task.spawn(teleportLoop)
    else
        tpToggleBtn.Text = "Auto TP: OFF"
        tpToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

tpSpeedInput.FocusLost:Connect(function()
    local num = tonumber(tpSpeedInput.Text)
    if num and num >= 0 then tpSpeed = num else tpSpeedInput.Text = tostring(tpSpeed) end
end)

-- Loop System: Auto Bet Plinko Remote Drop
local function dropLoop()
    local remote = game:GetService("ReplicatedStorage"):WaitForChild("BrainrotPlinkoDrop", 5)
    if not remote then return end
    while isDropLooping do
        remote:FireServer(dropAmount)
        task.wait(dropSpeed)
    end
end

dropToggleBtn.MouseButton1Click:Connect(function()
    isDropLooping = not isDropLooping
    if isDropLooping then
        dropToggleBtn.Text = "Auto Bet: ON"
        dropToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        task.spawn(dropLoop)
    else
        dropToggleBtn.Text = "Auto Bet: OFF"
        dropToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

dropAmountInput.FocusLost:Connect(function()
    local num = tonumber(dropAmountInput.Text)
    if num then dropAmount = num else dropAmountInput.Text = tostring(dropAmount) end
end)

-- String Multiplier Target Extractor
local function parseNumber(str)
    local cleaned = str:gsub("[%,%s]", ""):upper()
    local suffix = cleaned:sub(-1)
    if suffix == "K" then
        return (tonumber(cleaned:sub(1, -2)) or 0) * 1000
    elseif suffix == "M" then
        return (tonumber(cleaned:sub(1, -2)) or 0) * 1000000
    elseif suffix == "B" then
        return (tonumber(cleaned:sub(1, -2)) or 0) * 1000000000
    end
    return tonumber(cleaned) or tonumber(cleaned:match("%d+")) or 0
end

-- Loop System: Auto Validation Rebirth Thread
local function rebirthLoop()
    local remote = game:GetService("ReplicatedStorage"):WaitForChild("BrainrotPlinkoRebirth", 5)
    local button = playerGui:WaitForChild("PlinkoExtraControlsGui", 5):WaitForChild("RebirthButton", 5)
    local leaderstats = player:WaitForChild("leaderstats", 5)
    local coinsValue = leaderstats and leaderstats:WaitForChild("Coins", 5)
    
    if not remote or not button or not coinsValue then
        rebirthStatusLabel.Text = "Status: Error finding items. Check UI elements paths."
        isRebirthLooping = false
        rebirthToggleBtn.Text = "Auto Rebirth: OFF"
        rebirthToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        return
    end

    while isRebirthLooping do
        local requiredMoney = parseNumber(button.Text)
        local currentMoney = coinsValue.Value
        
        rebirthStatusLabel.Text = string.format("Need: %s\nHave: %s", button.Text, tostring(currentMoney))
        
        if currentMoney >= requiredMoney and requiredMoney > 0 then
            remote:FireServer()
            rebirthStatusLabel.Text = "Status: Rebirth triggered!"
            task.wait(0.5)
        end
        task.wait(rebirthDelay)
    end
end

rebirthToggleBtn.MouseButton1Click:Connect(function()
    isRebirthLooping = not isRebirthLooping
    if isRebirthLooping then
        rebirthToggleBtn.Text = "Auto Rebirth: ON"
        rebirthToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        task.spawn(rebirthLoop)
    else
        rebirthToggleBtn.Text = "Auto Rebirth: OFF"
        rebirthToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        rebirthStatusLabel.Text = "Status: Waiting..."
    end
end)
-- ========================================================
-- END OF SCRIPT FRAMEWORK
-- ========================================================
