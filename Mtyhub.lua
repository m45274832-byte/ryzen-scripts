-- MTY HUB v1.0 ULTIMATE
-- Администраторская панель с полным функционалом
-- Включает: VISUAL, PLAYER, COMBAT, NO FE, SETTINGS

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Mouse = LP:GetMouse()
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- ===== НАСТРОЙКИ =====
local guiSettings = {
    BackgroundColor = Color3.fromRGB(0, 0, 0),
    BorderColor = Color3.fromRGB(255, 0, 0),
    TextColor = Color3.fromRGB(255, 255, 255),
    Transparency = 0.05,
    BlurEnabled = true,
    BlurSize = 12,
    ESPColor = Color3.fromRGB(255, 0, 0),
    HitboxColor = Color3.fromRGB(255, 0, 0),
    ChamsColor = Color3.fromRGB(0, 255, 255),
    TracerColor = Color3.fromRGB(255, 255, 255),
    JumpCircleColor = Color3.fromRGB(0, 255, 0),
    TrailColor = Color3.fromRGB(0, 255, 255),
    HitboxMultiplier = 1,
    HitboxExpanded = false,
    BacktrackTime = 0.5,
    SpinSpeed = 1,
    StretchValue = 0.65,
    AimbotFOV = 100,
    AimbotSmoothness = 0.3,
    HatColor = Color3.fromRGB(210, 180, 140)
}

-- ===== ПЕРЕМЕННЫЕ =====
local guiMainFrame = nil
local guiBorder = nil
local guiTitle = nil
local blurEffect = nil
local screenGui = nil

local espEnabled = false
local espFolder = Instance.new("Folder")
espFolder.Name = "MTY_ESP"
espFolder.Parent = workspace

local hitboxEnabled = false
local HitboxFolder = Instance.new("Folder")
HitboxFolder.Name = "MTY_Hitboxes"
HitboxFolder.Parent = workspace

local chamsEnabled = false
local chamsFolder = Instance.new("Folder")
chamsFolder.Name = "MTY_Chams"
chamsFolder.Parent = workspace

local tracersEnabled = false
local tracersFolder = Instance.new("Folder")
tracersFolder.Name = "MTY_Tracers"
tracersFolder.Parent = workspace

local backtrackEnabled = false
local backtrackFolder = Instance.new("Folder")
backtrackFolder.Name = "MTY_Backtrack"
backtrackFolder.Parent = workspace
local backtrackData = {}

local jumpCircleEnabled = false
local jumpCircle = nil
local jumpCircleConnection = nil

local trailEnabled = false
local trailParts = {}
local trailLength = 20
local trailConnection = nil

local spinEnabled = false
local spinConnection = nil
local helicopterEnabled = false
local helicopterConnection = nil
local invisibilityEnabled = false
local stretchEnabled = false
local stretchConnection = nil
local dashEnabled = false
local dashButton = nil
local teleportTool = nil
local teleportToolEnabled = false

local noClipEnabled = false
local orbitEnabled = false
local orbitButton = nil
local orbitConnection = nil
local aimbotEnabled = false
local aimbotConnection = nil

-- ===== КОСМЕТИКА =====
local hatEnabled = false
local currentHat = nil
local hatBrim = nil
local hatTopRing = nil
local hatConnection = nil
local particlesEnabled = false
local particlesConnection = nil
local fullbrightEnabled = false
local nameTagsEnabled = false
local nameTagsFolder = Instance.new("Folder")
nameTagsFolder.Name = "MTY_NameTags"
nameTagsFolder.Parent = workspace
local skeletonEnabled = false
local skeletonFolder = Instance.new("Folder")
skeletonFolder.Name = "MTY_Skeleton"
skeletonFolder.Parent = workspace

-- ===== NO FE ПЕРЕМЕННЫЕ =====
local cButtonEnabled = false
local cButtonGui = nil
local clemonRCLoaded = false

-- ===== ASIAN CONICAL HAT =====
local function CreateHat()
    if currentHat then currentHat:Destroy() currentHat = nil end
    if hatBrim then hatBrim:Destroy() hatBrim = nil end
    if hatTopRing then hatTopRing:Destroy() hatTopRing = nil end
    
    currentHat = Instance.new("Part")
    currentHat.Size = Vector3.new(3, 0.1, 3)
    currentHat.Anchored = true
    currentHat.CanCollide = false
    currentHat.Material = Enum.Material.Neon
    currentHat.BrickColor = BrickColor.new(guiSettings.HatColor)
    currentHat.Transparency = 0.1
    currentHat.Parent = workspace
    
    local coneMesh = Instance.new("SpecialMesh")
    coneMesh.MeshType = Enum.MeshType.Cone
    coneMesh.Scale = Vector3.new(3, 1.8, 3)
    coneMesh.Parent = currentHat
    
    hatBrim = Instance.new("Part")
    hatBrim.Size = Vector3.new(3.8, 0.05, 3.8)
    hatBrim.Anchored = true
    hatBrim.CanCollide = false
    hatBrim.Material = Enum.Material.Neon
    hatBrim.BrickColor = BrickColor.new(guiSettings.HatColor)
    hatBrim.Transparency = 0.1
    hatBrim.Parent = workspace
    
    local ringMesh = Instance.new("SpecialMesh")
    ringMesh.MeshType = Enum.MeshType.Cylinder
    ringMesh.Scale = Vector3.new(1, 0.05, 1)
    ringMesh.Parent = hatBrim
    
    hatTopRing = Instance.new("Part")
    hatTopRing.Size = Vector3.new(0.8, 0.05, 0.8)
    hatTopRing.Anchored = true
    hatTopRing.CanCollide = false
    hatTopRing.Material = Enum.Material.Neon
    hatTopRing.BrickColor = BrickColor.new(guiSettings.HatColor)
    hatTopRing.Transparency = 0.1
    hatTopRing.Parent = workspace
    
    local topRingMesh = Instance.new("SpecialMesh")
    topRingMesh.MeshType = Enum.MeshType.Cylinder
    topRingMesh.Scale = Vector3.new(1, 0.05, 1)
    topRingMesh.Parent = hatTopRing
    
    if hatConnection then hatConnection:Disconnect() end
    hatConnection = RunService.Heartbeat:Connect(function()
        if currentHat and hatBrim and hatTopRing and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local root = LP.Character.HumanoidRootPart
            local hatPos = root.CFrame * CFrame.new(0, 2.8, 0)
            currentHat.CFrame = hatPos
            hatBrim.CFrame = hatPos * CFrame.new(0, -0.9, 0)
            hatTopRing.CFrame = hatPos * CFrame.new(0, 0.9, 0)
        end
    end)
end

local function ToggleHat()
    hatEnabled = not hatEnabled
    if hatEnabled then
        CreateHat()
        ShowMessage("Asian Hat ON 🎩")
    else
        if currentHat then currentHat:Destroy() currentHat = nil end
        if hatBrim then hatBrim:Destroy() hatBrim = nil end
        if hatTopRing then hatTopRing:Destroy() hatTopRing = nil end
        if hatConnection then hatConnection:Disconnect() hatConnection = nil end
        ShowMessage("Asian Hat OFF")
    end
end

-- ===== SHIFTLOCK =====
local shiftlockActive = false
local shiftlockConnection = nil
local shiftlockButton = nil

local function CreateShiftlockButton()
    if shiftlockButton then return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "MTY_Shiftlock"
    sg.Parent = game.CoreGui
    sg.ResetOnSpawn = false
    
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = UDim2.new(0.92, 0, 0.55, 0)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 1
    btn.Image = "http://www.roblox.com/asset/?id=182223762"
    btn.Parent = sg
    btn.Draggable = true
    
    shiftlockButton = btn
    
    btn.MouseButton1Click:Connect(function()
        ToggleShiftlock()
    end)
end

local function ToggleShiftlock()
    shiftlockActive = not shiftlockActive
    
    if shiftlockActive then
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.AutoRotate = false
        end
        if shiftlockConnection then shiftlockConnection:Disconnect() end
        shiftlockConnection = RunService.RenderStepped:Connect(function()
            if not shiftlockActive then return end
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                local root = LP.Character.HumanoidRootPart
                local cam = workspace.CurrentCamera
                local lookVec = cam.CFrame.LookVector
                local pos = root.Position
                root.CFrame = CFrame.new(pos, Vector3.new(lookVec.X * 99999, pos.Y, lookVec.Z * 99999))
            end
        end)
        if shiftlockButton then
            shiftlockButton.Image = "rbxasset://textures/ui/mouseLock_on@2x.png"
        end
        ShowMessage("Shiftlock ON 🔒")
    else
        if shiftlockConnection then
            shiftlockConnection:Disconnect()
            shiftlockConnection = nil
        end
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.AutoRotate = true
        end
        if shiftlockButton then
            shiftlockButton.Image = "rbxasset://textures/ui/mouseLock_off@2x.png"
        end
        ShowMessage("Shiftlock OFF 🔓")
    end
end

-- ===== NO FE: C BUTTON =====
local function CreateCButton()
    if cButtonGui then cButtonGui:Destroy() cButtonGui = nil end
    
    cButtonGui = Instance.new("ScreenGui")
    cButtonGui.Name = "MTY_CButton"
    cButtonGui.Parent = game.CoreGui
    cButtonGui.ResetOnSpawn = false
    cButtonGui.IgnoreGuiInset = true
    cButtonGui.DisplayOrder = 999
    
    local button = Instance.new("TextButton")
    button.Name = "CButton"
    button.Size = UDim2.new(0, 58, 0, 58)
    button.Position = UDim2.new(0.9, 0, 0.8, 0)
    button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    button.Text = "C"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 0
    button.Active = true
    button.Parent = cButtonGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 3
    stroke.Color = Color3.fromRGB(80, 180, 255)
    stroke.Parent = button
    
    local originalPos = button.Position
    
    local function setPressed(pressed)
        if pressed then
            button.BackgroundColor3 = Color3.fromRGB(0, 100, 220)
            button.TextColor3 = Color3.fromRGB(255, 255, 100)
            button.Position = originalPos + UDim2.new(0, 0, 0, 4)
        else
            button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.Position = originalPos
        end
    end
    
    button.MouseButton1Down:Connect(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game)
        setPressed(true)
    end)
    
    button.MouseButton1Up:Connect(function()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game)
        setPressed(false)
    end)
    
    local dragging = false
    local dragStart, startPos
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
            originalPos = button.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            originalPos = button.Position
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.C then setPressed(true) end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.C then setPressed(false) end
    end)
end

local function ToggleCButton()
    cButtonEnabled = not cButtonEnabled
    if cButtonEnabled then
        CreateCButton()
        ShowMessage("C Button ON ⌨️")
    else
        if cButtonGui then cButtonGui:Destroy() cButtonGui = nil end
        ShowMessage("C Button OFF")
    end
end

-- ===== NO FE: CLEMON RC (ОДЕЖДА) =====
local function LoadClemonRC()
    if clemonRCLoaded then
        ShowMessage("ClemonRC already loaded")
        return
    end
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/clemonlang/clemon_roclothes/refs/heads/main/ClemonRC.lua"))()
        clemonRCLoaded = true
        ShowMessage("ClemonRC Loaded 👕")
    end)
end

-- ===== R6 ANIMATIONS =====
local function RunCustomAnimation(Char)
    if Char:WaitForChild("Humanoid").RigType == Enum.HumanoidRigType.R6 then return end
    if Char:WaitForChild("Animate") ~= nil then Char.Animate.Disabled = true end
    for i,v in next, Char.Humanoid:GetPlayingAnimationTracks() do v:Stop() end
    
    local Character = Char
    local Humanoid = Character:WaitForChild("Humanoid")
    local pose = "Standing"
    local UserGameSettings = UserSettings():GetService("UserGameSettings")
    local AnimationSpeedDampeningObject = script:FindFirstChild("ScaleDampeningPercent")
    local HumanoidHipHeight = 2
    local humanoidSpeed = 0
    local cachedRunningSpeed = 0
    local cachedLocalDirection = {x=0.0, y=0.0}
    local smallButNotZero = 0.0001
    local runBlendtime = 0.2
    local lastLookVector = Vector3.new(0.0, 0.0, 0.0)
    local lastBlendTime = 0
    local WALK_SPEED = 6.4
    local RUN_SPEED = 12.8
    local EMOTE_TRANSITION_TIME = 0.1
    local currentAnim = ""
    local currentAnimInstance = nil
    local currentAnimTrack = nil
    local currentAnimKeyframeHandler = nil
    local currentAnimSpeed = 1.0
    local PreloadedAnims = {}
    local animTable = {}
    local animNames = {
        idle = {{id = "http://www.roblox.com/asset/?id=12521158637", weight = 9},{id = "http://www.roblox.com/asset/?id=12521162526", weight = 1}},
        walk = {{id = "http://www.roblox.com/asset/?id=12518152696", weight = 10}},
        run = {{id = "http://www.roblox.com/asset/?id=12518152696", weight = 10}},
        jump = {{id = "http://www.roblox.com/asset/?id=12520880485", weight = 10}},
        fall = {{id = "http://www.roblox.com/asset/?id=12520972571", weight = 10}},
        climb = {{id = "http://www.roblox.com/asset/?id=12520982150", weight = 10}},
        sit = {{id = "http://www.roblox.com/asset/?id=12520993168", weight = 10}},
        toolnone = {{id = "http://www.roblox.com/asset/?id=12520996634", weight = 10}},
        toolslash = {{id = "http://www.roblox.com/asset/?id=12520999032", weight = 10}},
        toollunge = {{id = "http://www.roblox.com/asset/?id=12521002003", weight = 10}},
        wave = {{id = "http://www.roblox.com/asset/?id=12521004586", weight = 10}},
        point = {{id = "http://www.roblox.com/asset/?id=12521007694", weight = 10}},
        dance = {{id = "http://www.roblox.com/asset/?id=12521009666", weight = 10},{id = "http://www.roblox.com/asset/?id=12521151637", weight = 10},{id = "http://www.roblox.com/asset/?id=12521015053", weight = 10}},
        dance2 = {{id = "http://www.roblox.com/asset/?id=12521169800", weight = 10},{id = "http://www.roblox.com/asset/?id=12521173533", weight = 10},{id = "http://www.roblox.com/asset/?id=12521027874", weight = 10}},
        dance3 = {{id = "http://www.roblox.com/asset/?id=12521178362", weight = 10},{id = "http://www.roblox.com/asset/?id=12521181508", weight = 10},{id = "http://www.roblox.com/asset/?id=12521184133", weight = 10}},
        laugh = {{id = "http://www.roblox.com/asset/?id=12521018724", weight = 10}},
        cheer = {{id = "http://www.roblox.com/asset/?id=12521021991", weight = 10}},
    }
    local strafingLocomotionMap = {}
    local fallbackLocomotionMap = {}
    local locomotionMap = strafingLocomotionMap
    local emoteNames = {wave = false, point = false, dance = true, dance2 = true, dance3 = true, laugh = false, cheer = false}
    math.randomseed(tick())
    
    function configureAnimationSet(name, fileList)
        if (animTable[name] ~= nil) then
            for _, connection in pairs(animTable[name].connections) do connection:disconnect() end
        end
        animTable[name] = {}
        animTable[name].count = 0
        animTable[name].totalWeight = 0
        animTable[name].connections = {}
        if name == "run" or name == "walk" then
            local speed = name == "run" and RUN_SPEED or WALK_SPEED
            fallbackLocomotionMap[name] = {lv=Vector2.new(0.0, speed), speed = speed}
            locomotionMap = fallbackLocomotionMap
        end
        if (animTable[name].count <= 0) then
            for idx, anim in pairs(fileList) do
                animTable[name][idx] = {}
                animTable[name][idx].anim = Instance.new("Animation")
                animTable[name][idx].anim.Name = name
                animTable[name][idx].anim.AnimationId = anim.id
                animTable[name][idx].weight = anim.weight
                animTable[name].count = animTable[name].count + 1
                animTable[name].totalWeight = animTable[name].totalWeight + anim.weight
            end
        end
        for i, animType in pairs(animTable) do
            for idx = 1, animType.count, 1 do
                if PreloadedAnims[animType[idx].anim.AnimationId] == nil then
                    Humanoid:LoadAnimation(animType[idx].anim)
                    PreloadedAnims[animType[idx].anim.AnimationId] = true
                end
            end
        end
    end
    
    for name, fileList in pairs(animNames) do configureAnimationSet(name, fileList) end
    
    function getHeightScale()
        if Humanoid then
            if not Humanoid.AutomaticScalingEnabled then return 1 end
            local scale = Humanoid.HipHeight / HumanoidHipHeight
            if AnimationSpeedDampeningObject == nil then
                AnimationSpeedDampeningObject = script:FindFirstChild("ScaleDampeningPercent")
            end
            if AnimationSpeedDampeningObject ~= nil then
                scale = 1 + (Humanoid.HipHeight - HumanoidHipHeight) * AnimationSpeedDampeningObject.Value / HumanoidHipHeight
            end
            return scale
        end
        return 1
    end
    
    function playAnimation(animName, transitionTime, humanoid)
        local roll = math.random(1, animTable[animName].totalWeight)
        local idx = 1
        while (roll > animTable[animName][idx].weight) do
            roll = roll - animTable[animName][idx].weight
            idx = idx + 1
        end
        local anim = animTable[animName][idx].anim
        if (currentAnimTrack ~= nil) then
            currentAnimTrack:Stop(transitionTime)
            currentAnimTrack:Destroy()
        end
        if (currentAnimKeyframeHandler ~= nil) then
            currentAnimKeyframeHandler:disconnect()
        end
        currentAnimSpeed = 1.0
        currentAnim = animName
        currentAnimInstance = anim
        currentAnimTrack = humanoid:LoadAnimation(anim)
        currentAnimTrack.Priority = Enum.AnimationPriority.Core
        currentAnimTrack:Play(transitionTime)
    end
    
    function onRunning(speed)
        humanoidSpeed = speed
        if speed > 0.75 then
            playAnimation("walk", 0.2, Humanoid)
            if pose ~= "Running" then pose = "Running" end
        else
            if emoteNames[currentAnim] == nil then
                playAnimation("idle", 0.2, Humanoid)
                pose = "Standing"
            end
        end
    end
    
    function onJumping()
        playAnimation("jump", 0.1, Humanoid)
        pose = "Jumping"
    end
    
    function onClimbing(speed)
        local scale = 5.0
        playAnimation("climb", 0.1, Humanoid)
        if currentAnimTrack then
            currentAnimTrack:AdjustSpeed(speed / scale)
        end
        pose = "Climbing"
    end
    
    function onFreeFall()
        playAnimation("fall", 0.2, Humanoid)
        pose = "FreeFall"
    end
    
    function onSeated()
        playAnimation("sit", 0.5, Humanoid)
        pose = "Seated"
    end
    
    Humanoid.Died:connect(function() pose = "Dead" end)
    Humanoid.Running:connect(onRunning)
    Humanoid.Jumping:connect(onJumping)
    Humanoid.Climbing:connect(onClimbing)
    Humanoid.FreeFalling:connect(onFreeFall)
    Humanoid.Seated:connect(onSeated)
    
    if Character.Parent ~= nil then
        playAnimation("idle", 0.1, Humanoid)
        pose = "Standing"
    end
end

local function ToggleR6Animations()
    if not r6Enabled then
        RunCustomAnimation(LP.Character)
        LP.CharacterAdded:Connect(function(Char) RunCustomAnimation(Char) end)
        r6Enabled = true
        ShowMessage("R6 Animations ON 🕺")
    else
        ShowMessage("R6 Animations already ON")
    end
end

-- ===== ФУНКЦИИ =====
local function ShowMessage(text)
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(0.5, 0, 0.08, 0)
    msg.Position = UDim2.new(0.25, 0, 0.88, 0)
    msg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    msg.BackgroundTransparency = 0.3
    msg.Text = text
    msg.TextColor3 = Color3.fromRGB(255, 255, 255)
    msg.TextScaled = true
    msg.Font = Enum.Font.GothamBold
    msg.Parent = guiMainFrame
    local msgCorner = Instance.new("UICorner")
    msgCorner.CornerRadius = UDim.new(0, 8)
    msgCorner.Parent = msg
    wait(2)
    msg:Destroy()
end

local function OpenTextInputMenu(titleText, placeholderText, defaultValue, callback)
    local screen = Instance.new("ScreenGui")
    screen.Name = "TextInputMenu"
    screen.Parent = game.CoreGui
    screen.ResetOnSpawn = false
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 180)
    frame.Position = UDim2.new(0.5, -150, 0.35, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = screen
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = frame
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.8, 0, 0, 40)
    input.Position = UDim2.new(0.1, 0, 0.35, 0)
    input.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    input.BorderSizePixel = 0
    input.Text = tostring(defaultValue)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.TextScaled = true
    input.Font = Enum.Font.Gotham
    input.PlaceholderText = placeholderText
    input.Parent = frame
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 10)
    inputCorner.Parent = input
    local applyBtn = Instance.new("TextButton")
    applyBtn.Size = UDim2.new(0.4, 0, 0, 35)
    applyBtn.Position = UDim2.new(0.3, 0, 0.7, 0)
    applyBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
    applyBtn.BorderSizePixel = 0
    applyBtn.Text = "Apply"
    applyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    applyBtn.TextSize = 18
    applyBtn.Font = Enum.Font.Gotham
    applyBtn.Parent = frame
    local applyCorner = Instance.new("UICorner")
    applyCorner.CornerRadius = UDim.new(0, 10)
    applyCorner.Parent = applyBtn
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = frame
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    applyBtn.MouseButton1Click:Connect(function()
        local val = tonumber(input.Text)
        if val then
            callback(val)
            screen:Destroy()
        else
            input.Text = "Enter a number"
        end
    end)
    closeBtn.MouseButton1Click:Connect(function()
        screen:Destroy()
    end)
end

local function OpenColorPicker(titleText, callback)
    local screen = Instance.new("ScreenGui")
    screen.Name = "ColorPicker"
    screen.Parent = game.CoreGui
    screen.ResetOnSpawn = false
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 300)
    frame.Position = UDim2.new(0.5, -100, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = screen
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = frame
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(0.9, 0, 0.7, 0)
    scroll.Position = UDim2.new(0.05, 0, 0.15, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.new(0, 0, 0, 300)
    scroll.ScrollBarThickness = 8
    scroll.Parent = frame
    local colors = {
        {"Red", Color3.fromRGB(255, 0, 0)},
        {"Green", Color3.fromRGB(0, 255, 0)},
        {"Blue", Color3.fromRGB(0, 0, 255)},
        {"Yellow", Color3.fromRGB(255, 255, 0)},
        {"Purple", Color3.fromRGB(150, 0, 255)},
        {"Orange", Color3.fromRGB(255, 150, 0)},
        {"White", Color3.fromRGB(255, 255, 255)},
        {"Black", Color3.fromRGB(20, 20, 20)},
        {"Cyan", Color3.fromRGB(0, 255, 255)},
        {"Pink", Color3.fromRGB(255, 100, 200)},
        {"Brown", Color3.fromRGB(150, 75, 0)},
        {"Random", Color3.new(math.random(), math.random(), math.random())}
    }
    local y = 0
    for i, data in ipairs(colors) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 40)
        btn.Position = UDim2.new(0.05, 0, 0, y)
        btn.BackgroundColor3 = data[2]
        btn.BackgroundTransparency = 0.2
        btn.BorderSizePixel = 0
        btn.Text = data[1]
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 16
        btn.Font = Enum.Font.Gotham
        btn.Parent = scroll
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn
        btn.MouseButton1Click:Connect(function()
            callback(data[2])
            screen:Destroy()
        end)
        y = y + 50
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, y + 20)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = frame
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    closeBtn.MouseButton1Click:Connect(function()
        screen:Destroy()
    end)
end

local function UpdateGUIStyle()
    if guiMainFrame then
        guiMainFrame.BackgroundColor3 = guiSettings.BackgroundColor
        guiMainFrame.BackgroundTransparency = guiSettings.Transparency
    end
    if guiBorder then
        guiBorder.BorderColor3 = guiSettings.BorderColor
    end
    if guiTitle then
        guiTitle.TextColor3 = guiSettings.TextColor
    end
    if blurEffect then
        blurEffect.Enabled = guiSettings.BlurEnabled
        blurEffect.Size = guiSettings.BlurSize
    end
end

-- ===== ESP =====
local function UpdateESP()
    for _, v in pairs(espFolder:GetChildren()) do v:Destroy() end
    if not espEnabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = part
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillColor = guiSettings.ESPColor
                    highlight.FillTransparency = 0.3
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.OutlineTransparency = 0.2
                    highlight.Parent = espFolder
                end
            end
        end
    end
end

local function ToggleESP()
    espEnabled = not espEnabled
    UpdateESP()
    ShowMessage("ESP " .. (espEnabled and "ON" or "OFF"))
end

-- ===== HITBOX =====
local function CreateHitbox(part)
    if not part:IsA("BasePart") then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = part
    box.Color3 = guiSettings.HitboxColor
    box.Transparency = 0.5
    box.Size = guiSettings.HitboxExpanded and part.Size * guiSettings.HitboxMultiplier or part.Size
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Parent = HitboxFolder
end

local function UpdateHitboxes()
    for _, v in pairs(HitboxFolder:GetChildren()) do v:Destroy() end
    if not hitboxEnabled then return end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Parent and v.Parent:FindFirstChild("Humanoid") then
            CreateHitbox(v)
        end
    end
end

local function ToggleHitboxes()
    hitboxEnabled = not hitboxEnabled
    UpdateHitboxes()
    ShowMessage("Hitbox " .. (hitboxEnabled and "ON" or "OFF"))
end

-- ===== CHAMS =====
local function UpdateChams()
    for _, v in pairs(chamsFolder:GetChildren()) do v:Destroy() end
    if not chamsEnabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = part
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillColor = guiSettings.ChamsColor
                    highlight.FillTransparency = 0.1
                    highlight.OutlineColor = guiSettings.ChamsColor
                    highlight.OutlineTransparency = 0.1
                    highlight.Parent = chamsFolder
                end
            end
        end
    end
end

local function ToggleChams()
    chamsEnabled = not chamsEnabled
    UpdateChams()
    ShowMessage("Chams " .. (chamsEnabled and "ON" or "OFF"))
end

-- ===== TRACERS =====
local function UpdateTracers()
    for _, v in pairs(tracersFolder:GetChildren()) do v:Destroy() end
    if not tracersEnabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local tracer = Instance.new("Part")
            tracer.Size = Vector3.new(0.1, 0.1, 0.1)
            tracer.Anchored = true
            tracer.CanCollide = false
            tracer.Material = Enum.Material.Neon
            tracer.BrickColor = BrickColor.new(guiSettings.TracerColor)
            tracer.Parent = tracersFolder
            local position = player.Character.HumanoidRootPart.Position
            local cameraPos = Camera.CFrame.Position
            local distance = (position - cameraPos).Magnitude
            local midPoint = (cameraPos + position) / 2
            tracer.Size = Vector3.new(0.1, distance, 0.1)
            tracer.CFrame = CFrame.lookAt(midPoint, cameraPos) * CFrame.new(0, 0, -distance/2)
            game:GetService("Debris"):AddItem(tracer, 0.1)
        end
    end
end

local function ToggleTracers()
    tracersEnabled = not tracersEnabled
    if tracersEnabled then
        RunService.Heartbeat:Connect(function()
            if tracersEnabled then UpdateTracers() end
        end)
    else
        for _, v in pairs(tracersFolder:GetChildren()) do v:Destroy() end
    end
    ShowMessage("Tracers " .. (tracersEnabled and "ON" or "OFF"))
end

-- ===== BACKTRACK =====
local function UpdateBacktrack()
    for _, v in pairs(backtrackFolder:GetChildren()) do v:Destroy() end
    if not backtrackEnabled then return end
    local now = tick()
    for _, data in pairs(backtrackData) do
        if now - data.time < guiSettings.BacktrackTime then
            local part = Instance.new("Part")
            part.Size = Vector3.new(1, 1, 1)
            part.CFrame = data.cframe
            part.Anchored = true
            part.CanCollide = false
            part.Transparency = 0.7
            part.Material = Enum.Material.Neon
            part.BrickColor = BrickColor.new("Bright red")
            part.Parent = backtrackFolder
            game:GetService("Debris"):AddItem(part, 0.1)
        end
    end
end

local function ToggleBacktrack()
    backtrackEnabled = not backtrackEnabled
    if backtrackEnabled then
        backtrackData = {}
        RunService.Heartbeat:Connect(function()
            if not backtrackEnabled then return end
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(backtrackData, {
                    time = tick(),
                    cframe = LP.Character.HumanoidRootPart.CFrame
                })
                if #backtrackData > 100 then table.remove(backtrackData, 1) end
                UpdateBacktrack()
            end
        end)
    else
        for _, v in pairs(backtrackFolder:GetChildren()) do v:Destroy() end
        backtrackData = {}
    end
    ShowMessage("Backtrack " .. (backtrackEnabled and "ON" or "OFF"))
end

-- ===== JUMP CIRCLE =====
local function ToggleJumpCircle()
    jumpCircleEnabled = not jumpCircleEnabled
    if jumpCircleEnabled then
        if jumpCircleConnection then jumpCircleConnection:Disconnect() end
        jumpCircle = Instance.new("Part")
        jumpCircle.Size = Vector3.new(6, 0.2, 6)
        jumpCircle.Anchored = true
        jumpCircle.CanCollide = false
        jumpCircle.Material = Enum.Material.Neon
        jumpCircle.BrickColor = BrickColor.new(guiSettings.JumpCircleColor)
        jumpCircle.Transparency = 1
        jumpCircle.Parent = workspace
        jumpCircleConnection = RunService.Heartbeat:Connect(function()
            if not jumpCircleEnabled then return end
            local hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
            if hum and hum:GetState() == Enum.HumanoidStateType.Jumping then
                jumpCircle.Position = HRP.Position - Vector3.new(0, 3, 0)
                jumpCircle.Transparency = 0.2
                jumpCircle.Size = Vector3.new(6, 0.2, 6)
            else
                jumpCircle.Transparency = 1
                jumpCircle.Size = Vector3.new(0.1, 0.1, 0.1)
            end
        end)
    else
        if jumpCircleConnection then jumpCircleConnection:Disconnect()
        jumpCircleConnection = nil end
        if jumpCircle then
            jumpCircle:Destroy()
            jumpCircle = nil
        end
    end
    ShowMessage("Jump Circle " .. (jumpCircleEnabled and "ON" or "OFF"))
end

-- ===== TRAIL =====
local function CreateTrail()
    if not trailEnabled then return end
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local part = Instance.new("Part")
    part.Size = Vector3.new(0.2, 0.2, 0.2)
    part.CFrame = root.CFrame
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.BrickColor = BrickColor.new(guiSettings.TrailColor)
    part.Transparency = 0.6
    part.Parent = workspace
    table.insert(trailParts, part)
    if #trailParts > trailLength then
        local old = table.remove(trailParts, 1)
        old:Destroy()
    end
end

local function ToggleTrail()
    trailEnabled = not trailEnabled
    if trailEnabled then
        for _, v in pairs(trailParts) do v:Destroy() end
        trailParts = {}
        trailConnection = RunService.Heartbeat:Connect(function()
            if trailEnabled then CreateTrail() end
        end)
    else
        if trailConnection then trailConnection:Disconnect()
        trailConnection = nil end
        for _, v in pairs(trailParts) do v:Destroy() end
        trailParts = {}
    end
    ShowMessage("Trail " .. (trailEnabled and "ON" or "OFF"))
end

-- ===== КОСМЕТИКА =====
local function ToggleParticles()
    particlesEnabled = not particlesEnabled
    if particlesEnabled then
        if particlesConnection then particlesConnection:Disconnect() end
        particlesConnection = RunService.Heartbeat:Connect(function()
            if not particlesEnabled then return end
            local part = Instance.new("Part")
            part.Size = Vector3.new(0.3, 0.3, 0.3)
            part.CFrame = HRP.CFrame * CFrame.new(math.random(-5,5), math.random(-5,5), math.random(-5,5))
            part.Anchored = true
            part.CanCollide = false
            part.Material = Enum.Material.Neon
            part.BrickColor = BrickColor.new("Bright red")
            part.Parent = workspace
            game:GetService("Debris"):AddItem(part, 0.5)
        end)
    else
        if particlesConnection then particlesConnection:Disconnect() end
    end
    ShowMessage("Particles " .. (particlesEnabled and "ON" or "OFF"))
end

local function ToggleFullbright()
    fullbrightEnabled = not fullbrightEnabled
    if fullbrightEnabled then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
    end
    ShowMessage("Fullbright " .. (fullbrightEnabled and "ON" or "OFF"))
end

local function UpdateNameTags()
    for _, v in pairs(nameTagsFolder:GetChildren()) do v:Destroy() end
    if not nameTagsEnabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 200, 0, 40)
            billboard.Adornee = player.Character.HumanoidRootPart
            billboard.Parent = nameTagsFolder
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = player.Name
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextScaled = true
            label.Font = Enum.Font.GothamBold
            label.Parent = billboard
        end
    end
end

local function ToggleNameTags()
    nameTagsEnabled = not nameTagsEnabled
    if nameTagsEnabled then
        UpdateNameTags()
        RunService.Heartbeat:Connect(function()
            if nameTagsEnabled then UpdateNameTags() end
        end)
    else
        for _, v in pairs(nameTagsFolder:GetChildren()) do v:Destroy() end
    end
    ShowMessage("NameTags " .. (nameTagsEnabled and "ON" or "OFF"))
end

local function UpdateSkeleton()
    for _, v in pairs(skeletonFolder:GetChildren()) do v:Destroy() end
    if not skeletonEnabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local sphere = Instance.new("Part")
                        sphere.Size = Vector3.new(0.3, 0.3, 0.3)
                        sphere.CFrame = part.CFrame
                        sphere.Anchored = true
                        sphere.CanCollide = false
                        sphere.Material = Enum.Material.Neon
                        sphere.BrickColor = BrickColor.new("Bright red")
                        sphere.Parent = skeletonFolder
                        game:GetService("Debris"):AddItem(sphere, 0.1)
                    end
                end
            end
        end
    end
end

local function ToggleSkeleton()
    skeletonEnabled = not skeletonEnabled
    if skeletonEnabled then
        UpdateSkeleton()
        RunService.Heartbeat:Connect(function()
            if skeletonEnabled then UpdateSkeleton() end
        end)
    else
        for _, v in pairs(skeletonFolder:GetChildren()) do v:Destroy() end
    end
    ShowMessage("Skeleton " .. (skeletonEnabled and "ON" or "OFF"))
end

-- ===== PLAYER FUNCTIONS =====
local function SetSpeed(value)
    local hum = LP.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = math.clamp(value, 0, 99999) end
end

local function SetGravity(value)
    workspace.Gravity = math.clamp(value, -1000, 10000)
end

local function ToggleSpin()
    spinEnabled = not spinEnabled
    if spinEnabled then
        if spinConnection then spinConnection:Disconnect() end
        spinConnection = RunService.Heartbeat:Connect(function()
            if spinEnabled then 
                local pos = HRP.Position
                HRP.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(guiSettings.SpinSpeed), 0)
            end
        end)
    else
        if spinConnection then spinConnection:Disconnect()
        spinConnection = nil end
    end
    ShowMessage("Spin " .. (spinEnabled and "ON" or "OFF"))
end

local function ToggleHelicopter()
    helicopterEnabled = not helicopterEnabled
    if helicopterEnabled then
        if helicopterConnection then helicopterConnection:Disconnect() end
        helicopterConnection = RunService.Heartbeat:Connect(function()
            if helicopterEnabled then
                HRP.CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(50), 0)
                HRP.Velocity = Vector3.new(0, 20, 0)
            end
        end)
    else
        if helicopterConnection then helicopterConnection:Disconnect()
        helicopterConnection = nil end
        HRP.Velocity = Vector3.new(0, 0, 0)
    end
    ShowMessage("Helicopter " .. (helicopterEnabled and "ON" or "OFF"))
end

local function ToggleInvisibility()
    invisibilityEnabled = not invisibilityEnabled
    if invisibilityEnabled then
        Char = LP.Character or LP.CharacterAdded:Wait()
        for _, v in pairs(Char:GetDescendants()) do
            if v:IsA("BasePart") then v.Transparency = 0.99 end
        end
    else
        Char = LP.Character or LP.CharacterAdded:Wait()
        for _, v in pairs(Char:GetDescendants()) do
            if v:IsA("BasePart") then v.Transparency = 0 end
        end
    end
    ShowMessage("Invisibility " .. (invisibilityEnabled and "ON" or "OFF"))
end

local function CreateDashButton()
    if dashButton then return end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MTY_Dash"
    screenGui.Parent = game.CoreGui
    screenGui.ResetOnSpawn = false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = UDim2.new(0.9, -70, 0.5, -30)
    btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    btn.BorderSizePixel = 0
    btn.Text = "⚡"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 30
    btn.Font = Enum.Font.GothamBold
    btn.Parent = screenGui
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 12)
    btnCorner.Parent = btn
    btn.Draggable = true
    dashButton = btn
    btn.MouseButton1Down:Connect(function()
        local hum = LP.Character:FindFirstChild("Humanoid")
        local root = LP.Character:FindFirstChild("HumanoidRootPart")
        if hum and root then
            hum.Jump = true
            local forward = root.CFrame.LookVector
            root.Velocity = Vector3.new(forward.X * 50, root.Velocity.Y + 10, forward.Z * 50)
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(5), 0)
        end
    end)
end

local function ToggleDash()
    dashEnabled = not dashEnabled
    if dashEnabled then
        CreateDashButton()
    else
        if dashButton then dashButton.Parent:Destroy()
        dashButton = nil end
    end
    ShowMessage("Dash " .. (dashEnabled and "ON" or "OFF"))
end

local function CreateTeleportTool()
    if teleportTool then return end
    teleportTool = Instance.new("Tool")
    teleportTool.RequiresHandle = false
    teleportTool.Name = "MTY Teleport"
    teleportTool.Activated:Connect(function()
        local pos = Mouse.Hit + Vector3.new(0, 2.5, 0)
        pos = CFrame.new(pos.X, pos.Y, pos.Z)
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame = pos
        end
    end)
end

local function ToggleTeleportTool()
    teleportToolEnabled = not teleportToolEnabled
    if teleportToolEnabled then
        CreateTeleportTool()
        if teleportTool then
            teleportTool.Parent = LP.Backpack
        end
        ShowMessage("Teleport Tool ON (in inventory)")
    else
        if teleportTool then
            teleportTool:Destroy()
            teleportTool = nil
        end
        ShowMessage("Teleport Tool OFF")
    end
end

local function ToggleFly()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
    end)
    ShowMessage("Fly started")
end

local function ToggleNoClip()
    noClipEnabled = not noClipEnabled
    if noClipEnabled then
        if LP.Character then
            for _, v in pairs(LP.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
        LP.CharacterAdded:Connect(function()
            if noClipEnabled then
                wait(0.5)
                for _, v in pairs(LP.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)
    else
        if LP.Character then
            for _, v in pairs(LP.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
    end
    ShowMessage("NoClip " .. (noClipEnabled and "ON" or "OFF"))
end

-- ===== ORBIT =====
local function CreateOrbitButton()
    if orbitButton then return end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MTY_Orbit"
    screenGui.Parent = game.CoreGui
    screenGui.ResetOnSpawn = false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = UDim2.new(0.1, 10, 0.5, -30)
    btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    btn.BorderSizePixel = 0
    btn.Text = "🌀"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 30
    btn.Font = Enum.Font.GothamBold
    btn.Parent = screenGui
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 12)
    btnCorner.Parent = btn
    btn.Draggable = true
    orbitButton = btn
    btn.MouseButton1Down:Connect(function()
        ToggleOrbit()
    end)
end

local function ToggleOrbit()
    orbitEnabled = not orbitEnabled
    if orbitEnabled then
        if orbitConnection then orbitConnection:Disconnect() end
        orbitConnection = RunService.Heartbeat:Connect(function()
            if not orbitEnabled then return end
            local closest = nil
            local closestDist = math.huge
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (HRP.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist < closestDist and dist < 20 then
                        closestDist = dist
                        closest = player
                    end
                end
            end
            if closest then
                local targetPos = closest.Character.HumanoidRootPart.Position
                local radius = 5
                local angle = tick() * 2
                local x = targetPos.X + radius * math.cos(angle)
                local z = targetPos.Z + radius * math.sin(angle)
                HRP.CFrame = CFrame.new(x, HRP.Position.Y, z) * CFrame.lookAt(Vector3.new(x, HRP.Position.Y, z), targetPos)
            end
        end)
        ShowMessage("🌀 Orbit ON")
    else
        if orbitConnection then orbitConnection:Disconnect()
        orbitConnection = nil end
        ShowMessage("🌀 Orbit OFF")
    end
end

-- ===== AIMBOT =====
local function ToggleAimbot()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        if aimbotConnection then aimbotConnection:Disconnect() end
        aimbotConnection = RunService.Heartbeat:Connect(function()
            if not aimbotEnabled then return end
            local target = nil
            local targetDist = math.huge
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local root = player.Character.HumanoidRootPart
                    local pos, onScreen = Camera:WorldToScreenPoint(root.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                        if dist < guiSettings.AimbotFOV and dist < targetDist then
                            targetDist = dist
                            target = root
                        end
                    end
                end
            end
            if target then
                local targetPos = target.Position
                local lookAt = CFrame.new(Camera.CFrame.Position, targetPos)
                Camera.CFrame = Camera.CFrame:Lerp(lookAt, guiSettings.AimbotSmoothness)
            end
        end)
        ShowMessage("🎯 Aimbot ON")
    else
        if aimbotConnection then aimbotConnection:Disconnect()
        aimbotConnection = nil end
        ShowMessage("🎯 Aimbot OFF")
    end
end

-- ===== GUI SETTINGS =====
local function SetGUIColor(color)
    guiSettings.BackgroundColor = color
    UpdateGUIStyle()
end

local function SetBorderColor(color)
    guiSettings.BorderColor = color
    UpdateGUIStyle()
end

local function SetTextColor(color)
    guiSettings.TextColor = color
    UpdateGUIStyle()
end

local function SetStyle(style)
    if style == "MTY Dark" then
        guiSettings.BackgroundColor = Color3.fromRGB(0, 0, 0)
        guiSettings.BorderColor = Color3.fromRGB(255, 0, 0)
        guiSettings.TextColor = Color3.fromRGB(255, 255, 255)
        guiSettings.Transparency = 0.05
    elseif style == "MTY Neon" then
        guiSettings.BackgroundColor = Color3.fromRGB(10, 0, 20)
        guiSettings.BorderColor = Color3.fromRGB(255, 0, 200)
        guiSettings.TextColor = Color3.fromRGB(255, 0, 200)
        guiSettings.Transparency = 0.1
    elseif style == "MTY Glass" then
        guiSettings.BackgroundColor = Color3.fromRGB(255, 255, 255)
        guiSettings.BorderColor = Color3.fromRGB(255, 255, 255)
        guiSettings.TextColor = Color3.fromRGB(0, 0, 0)
        guiSettings.Transparency = 0.3
    end
    UpdateGUIStyle()
    ShowMessage("Style: " .. style)
end

local function ToggleBlur()
    guiSettings.BlurEnabled = not guiSettings.BlurEnabled
    UpdateGUIStyle()
    ShowMessage("Blur " .. (guiSettings.BlurEnabled and "ON" or "OFF"))
end

local function SetBlurSize(value)
    guiSettings.BlurSize = math.clamp(value, 1, 30)
    UpdateGUIStyle()
    ShowMessage("Blur Size: " .. guiSettings.BlurSize)
end

local function SetTransparency(value)
    guiSettings.Transparency = math.clamp(value, 0, 0.8)
    UpdateGUIStyle()
    ShowMessage("Transparency: " .. guiSettings.Transparency)
end

local function SetSpinSpeed(value)
    guiSettings.SpinSpeed = math.clamp(value, 0.1, 99999)
    ShowMessage("Spin Speed: " .. guiSettings.SpinSpeed)
end

local function SetStretchValue(value)
    guiSettings.StretchValue = math.clamp(value, 0.1, 2.0)
    ShowMessage("Stretch Value: " .. guiSettings.StretchValue)
end

local function ToggleStretch()
    stretchEnabled = not stretchEnabled
    if stretchEnabled then
        if stretchConnection then stretchConnection:Disconnect() end
        stretchConnection = RunService.RenderStepped:Connect(function()
            if not stretchEnabled then return end
            Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, guiSettings.StretchValue, 0, 0, 0, 1)
        end)
        ShowMessage("Stretch ON (" .. guiSettings.StretchValue .. ")")
    else
        if stretchConnection then
            stretchConnection:Disconnect()
            stretchConnection = nil
        end
        ShowMessage("Stretch OFF")
    end
end

local function OptimizeTextures()
    for _, v in pairs(game:GetDescendants()) do
        pcall(function()
            if v:IsA("Texture") or v:IsA("Decal") then v.Texture = "rbxassetid://4322737890"
            elseif v:IsA("Part") or v:IsA("MeshPart") then v.Material = Enum.Material.Plastic
                v.Reflectance = 0
            elseif v:IsA("Terrain") then v.WaterWaveSize = 0
                v.WaterReflectance = 0
                v.WaterTransparency = 1 end
        end)
    end
    Lighting.GlobalShadows = false
    Lighting.Brightness = 1
    Lighting.ClockTime = 14
    ShowMessage("Textures Optimized")
end

-- ===== TARGET ESP =====
local targetESPEnabled = false
local targetHighlight = nil

local function ToggleTargetESP()
    targetESPEnabled = not targetESPEnabled
    ShowMessage("Target ESP " .. (targetESPEnabled and "ON" or "OFF"))
end

RunService.Heartbeat:Connect(function()
    if targetESPEnabled then
        if targetHighlight then targetHighlight:Destroy() end
        local mousePos = Mouse.UnitRay
        local hit = workspace:FindPartOnRay(Ray.new(Camera.CFrame.Position, mousePos.Direction * 500))
        if hit and hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
            local player = Players:GetPlayerFromCharacter(hit.Parent)
            if player and player ~= LP then
                targetHighlight = Instance.new("Highlight")
                targetHighlight.Adornee = hit.Parent
                targetHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                targetHighlight.FillColor = Color3.fromRGB(255, 255, 0)
                targetHighlight.FillTransparency = 0.2
                targetHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                targetHighlight.OutlineTransparency = 0.1
                targetHighlight.Parent = workspace
            end
        end
    else
        if targetHighlight then targetHighlight:Destroy() end
    end
end)

-- ===== ВКЛАДКА NO FE =====
local r6Enabled = false

-- ===== ОСНОВНОЕ МЕНЮ =====
local function CreateMenu()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MTY_HUB"
    screenGui.Parent = game.CoreGui
    screenGui.ResetOnSpawn = false

    guiMainFrame = Instance.new("Frame")
    guiMainFrame.Size = UDim2.new(0, 520, 0, 450)
    guiMainFrame.Position = UDim2.new(0.5, -260, 0.5, -225)
    guiMainFrame.BackgroundColor3 = guiSettings.BackgroundColor
    guiMainFrame.BackgroundTransparency = guiSettings.Transparency
    guiMainFrame.BorderSizePixel = 0
    guiMainFrame.Active = true
    guiMainFrame.Draggable = true
    guiMainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 18)
    corner.Parent = guiMainFrame

    guiBorder = Instance.new("Frame")
    guiBorder.Size = UDim2.new(1, 0, 1, 0)
    guiBorder.BackgroundTransparency = 1
    guiBorder.BorderSizePixel = 2
    guiBorder.BorderColor3 = guiSettings.BorderColor
    guiBorder.Parent = guiMainFrame
    local borderCorner = Instance.new("UICorner")
    borderCorner.CornerRadius = UDim.new(0, 18)
    borderCorner.Parent = guiBorder

    guiTitle = Instance.new("TextLabel")
    guiTitle.Size = UDim2.new(0.7, 0, 0, 40)
    guiTitle.Position = UDim2.new(0.05, 0, 0.015, 0)
    guiTitle.BackgroundTransparency = 1
    guiTitle.Text = "MTY HUB v1.0 🚀"
    guiTitle.TextColor3 = guiSettings.TextColor
    guiTitle.TextScaled = true
    guiTitle.Font = Enum.Font.GothamBold
    guiTitle.Parent = guiMainFrame

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 36, 0, 36)
    minimizeBtn.Position = UDim2.new(1, -80, 0, 8)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextSize = 24
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = guiMainFrame
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 10)
    minCorner.Parent = minimizeBtn

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 36, 0, 36)
    closeBtn.Position = UDim2.new(1, -40, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 22
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = guiMainFrame
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 10)
    closeCorner.Parent = closeBtn

    blurEffect = Instance.new("BlurEffect")
    blurEffect.Enabled = guiSettings.BlurEnabled
    blurEffect.Size = guiSettings.BlurSize
    blurEffect.Parent = Lighting

    local leftPanel = Instance.new("Frame")
    leftPanel.Size = UDim2.new(0, 120, 0, 320)
    leftPanel.Position = UDim2.new(0.02, 0, 0.15, 0)
    leftPanel.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
    leftPanel.BackgroundTransparency = 0.3
    leftPanel.BorderSizePixel = 0
    leftPanel.Parent = guiMainFrame
    local leftCorner = Instance.new("UICorner")
    leftCorner.CornerRadius = UDim.new(0, 12)
    leftCorner.Parent = leftPanel

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(0.7, 0, 0, 30)
    searchBox.Position = UDim2.new(0.27, 0, 0.09, 0)
    searchBox.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
    searchBox.BorderSizePixel = 0
    searchBox.Text = ""
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.TextScaled = true
    searchBox.Font = Enum.Font.Gotham
    searchBox.PlaceholderText = "Search..."
    searchBox.Parent = guiMainFrame
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 8)
    searchCorner.Parent = searchBox

    local contentArea = Instance.new("ScrollingFrame")
    contentArea.Size = UDim2.new(0.7, 0, 0.6, 0)
    contentArea.Position = UDim2.new(0.27, 0, 0.17, 0)
    contentArea.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
    contentArea.BackgroundTransparency = 0.2
    contentArea.BorderSizePixel = 0
    contentArea.ScrollBarThickness = 8
    contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentArea.Parent = guiMainFrame
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 12)
    contentCorner.Parent = contentArea

    local categories = {"VISUAL", "PLAYER", "COMBAT", "NO FE", "SETTINGS"}
    local categoryButtons = {}
    local allSubs = {}
    local currentCategory = ""

    for i, cat in ipairs(categories) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 36)
        btn.Position = UDim2.new(0.05, 0, 0.05 + (i-1)*0.18, 0)
        btn.BackgroundColor3 = Color3.fromRGB(60, 15, 15)
        btn.BorderSizePixel = 0
        btn.Text = cat
        btn.TextColor3 = Color3.fromRGB(255, 150, 150)
        btn.TextSize = 15
        btn.Font = Enum.Font.Gotham
        btn.Parent = leftPanel
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        categoryButtons[cat] = btn

        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(60, 15, 15)
        end)

        btn.MouseButton1Click:Connect(function()
            currentCategory = cat
            local subs = {}
            if cat == "VISUAL" then
                subs = {
                    "Toggle ESP", "Toggle Hitboxes", "Toggle Chams",
                    "Toggle Tracers", "Toggle Backtrack", "Toggle JumpCircle",
                    "Toggle Trail", "Toggle Particles",
                    "Toggle Fullbright", "Toggle NameTags", "Toggle Skeleton",
                    "Toggle Asian Hat", "Hat Color", "Toggle Target ESP"
                }
            elseif cat == "PLAYER" then
                subs = {
                    "Speed", "Gravity", "Spin", "Spin Speed",
                    "Helicopter", "Invisibility", "Dash", "Fly",
                    "Teleport Tool", "NoClip", "Toggle Shiftlock"
                }
            elseif cat == "COMBAT" then
                subs = {
                    "Orbit", "Aimbot", "Aimbot FOV", "Aimbot Smoothness"
                }
            elseif cat == "NO FE" then
                subs = {
                    "Toggle C Button", "Load ClemonRC", "Toggle R6 Animations"
                }
            elseif cat == "SETTINGS" then
                subs = {
                    "Style MTY Dark", "Style MTY Neon", "Style MTY Glass",
                    "Background Color", "Border Color", "Text Color",
                    "Transparency", "Blur", "Blur Size",
                    "Stretch", "Stretch Value", "Optimize Textures"
                }
            end
            allSubs = subs
            RenderSubs(subs)
        end)
    end

    function RenderSubs(subs)
        for _, v in pairs(contentArea:GetChildren()) do v:Destroy() end
        local grid = Instance.new("Frame")
        grid.Size = UDim2.new(0.95, 0, 0.95, 0)
        grid.Position = UDim2.new(0.025, 0, 0.025, 0)
        grid.BackgroundTransparency = 1
        grid.Parent = contentArea

        local searchText = searchBox.Text:lower()
        local filtered = {}
        for _, name in ipairs(subs) do
            if searchText == "" or name:lower():find(searchText) then
                table.insert(filtered, name)
            end
        end

        for i, name in ipairs(filtered) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 22)
            row.Position = UDim2.new(0, 0, 0.03 + (i-1)*0.07, 0)
            row.BackgroundTransparency = 1
            row.Parent = grid

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.8, 0, 1, 0)
            btn.Position = UDim2.new(0, 0, 0, 0)
            btn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
            btn.BorderSizePixel = 0
            btn.Text = name
            btn.TextColor3 = Color3.fromRGB(255, 200, 200)
            btn.TextSize = 11
            btn.Font = Enum.Font.Gotham
            btn.Parent = row
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn
            btn.MouseEnter:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
            end)
            btn.MouseLeave:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
            end)

            btn.MouseButton1Click:Connect(function()
                if name == "Toggle ESP" then ToggleESP()
                elseif name == "Toggle Hitboxes" then ToggleHitboxes()
                elseif name == "Toggle Chams" then ToggleChams()
                elseif name == "Toggle Tracers" then ToggleTracers()
                elseif name == "Toggle Backtrack" then ToggleBacktrack()
                elseif name == "Toggle JumpCircle" then ToggleJumpCircle()
                elseif name == "Toggle Trail" then ToggleTrail()
                elseif name == "Toggle Particles" then ToggleParticles()
                elseif name == "Toggle Fullbright" then ToggleFullbright()
                elseif name == "Toggle NameTags" then ToggleNameTags()
                elseif name == "Toggle Skeleton" then ToggleSkeleton()
                elseif name == "Toggle Asian Hat" then ToggleHat()
                elseif name == "Hat Color" then
                    OpenColorPicker("Hat Color", function(c) 
                        guiSettings.HatColor = c
                        if currentHat then currentHat.BrickColor = BrickColor.new(c) end
                        if hatBrim then hatBrim.BrickColor = BrickColor.new(c) end
                        if hatTopRing then hatTopRing.BrickColor = BrickColor.new(c) end
                    end)
                elseif name == "Toggle Target ESP" then ToggleTargetESP()
                elseif name == "Speed" then
                    local hum = LP.Character:FindFirstChild("Humanoid")
                    OpenTextInputMenu("Speed", "0 - 99999", hum and hum.WalkSpeed or 16, function(v) SetSpeed(v) end)
                elseif name == "Gravity" then
                    OpenTextInputMenu("Gravity", "-1000 - 10000", workspace.Gravity, function(v) SetGravity(v) end)
                elseif name == "Spin" then ToggleSpin()
                elseif name == "Spin Speed" then
                    OpenTextInputMenu("Spin Speed", "0.1 - 99999", guiSettings.SpinSpeed, function(v) SetSpinSpeed(v) end)
                elseif name == "Helicopter" then ToggleHelicopter()
                elseif name == "Invisibility" then ToggleInvisibility()
                elseif name == "Dash" then ToggleDash()
                elseif name == "Fly" then ToggleFly()
                elseif name == "Teleport Tool" then ToggleTeleportTool()
                elseif name == "NoClip" then ToggleNoClip()
                elseif name == "Toggle Shiftlock" then 
                    if not shiftlockButton then CreateShiftlockButton() end
                    ToggleShiftlock()
                elseif name == "Orbit" then CreateOrbitButton(); ToggleOrbit()
                elseif name == "Aimbot" then ToggleAimbot()
                elseif name == "Aimbot FOV" then
                    OpenTextInputMenu("Aimbot FOV", "1 - 1000", guiSettings.AimbotFOV, function(v) guiSettings.AimbotFOV = v end)
                elseif name == "Aimbot Smoothness" then
                    OpenTextInputMenu("Aimbot Smoothness", "0.1 - 1.0", guiSettings.AimbotSmoothness, function(v) guiSettings.AimbotSmoothness = v end)
                elseif name == "Toggle C Button" then ToggleCButton()
                elseif name == "Load ClemonRC" then LoadClemonRC()
                elseif name == "Toggle R6 Animations" then ToggleR6Animations()
                elseif name == "Style MTY Dark" then SetStyle("MTY Dark")
                elseif name == "Style MTY Neon" then SetStyle("MTY Neon")
                elseif name == "Style MTY Glass" then SetStyle("MTY Glass")
                elseif name == "Background Color" then OpenColorPicker("Background Color", function(c) SetGUIColor(c) end)
                elseif name == "Border Color" then OpenColorPicker("Border Color", function(c) SetBorderColor(c) end)
                elseif name == "Text Color" then OpenColorPicker("Text Color", function(c) SetTextColor(c) end)
                elseif name == "Transparency" then OpenTextInputMenu("Transparency", "0 - 0.8", guiSettings.Transparency, function(v) SetTransparency(v) end)
                elseif name == "Blur" then ToggleBlur()
                elseif name == "Blur Size" then OpenTextInputMenu("Blur Size", "1 - 30", guiSettings.BlurSize, function(v) SetBlurSize(v) end)
                elseif name == "Stretch" then ToggleStretch()
                elseif name == "Stretch Value" then OpenTextInputMenu("Stretch Value", "0.1 - 2.0", guiSettings.StretchValue, function(v) SetStretchValue(v) end)
                elseif name == "Optimize Textures" then OptimizeTextures()
                end
            end)
        end
        contentArea.CanvasSize = UDim2.new(0, 0, 0, #filtered * 28 + 20)
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if currentCategory ~= "" then RenderSubs(allSubs) end
    end)

    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            guiMainFrame.Size = UDim2.new(0, 60, 0, 60)
            guiMainFrame.Position = UDim2.new(1, -70, 0, 10)
            leftPanel.Visible = false
            contentArea.Visible = false
            searchBox.Visible = false
            guiTitle.Visible = false
            minimizeBtn.Text = "+"
            closeBtn.Position = UDim2.new(1, -35, 0, 8)
        else
            guiMainFrame.Size = UDim2.new(0, 520, 0, 450)
            guiMainFrame.Position = UDim2.new(0.5, -260, 0.5, -225)
            leftPanel.Visible = true
            contentArea.Visible = true
            searchBox.Visible = true
            guiTitle.Visible = true
            minimizeBtn.Text = "-"
            closeBtn.Position = UDim2.new(1, -80, 0, 8)
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        if blurEffect then blurEffect:Destroy() end
    end)

    categoryButtons["VISUAL"].MouseButton1Click:Connect(function() end)
    categoryButtons["VISUAL"].MouseButton1Click:Fire()
end

CreateMenu()
print("MTY HUB v1.0 ULTIMATE LOADED! 🚀")
