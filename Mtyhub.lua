-- MTY HUB v3.2 HVH EDITION
-- Исправлено: Jump Circle (круг+затухание+цвет), Backtrack (больше кубов), Trail (больше следов)
-- Добавлено: Солнышко (бешеный спин как в Infinite Yield)

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
    SpinSpeed = 5,
    StretchValue = 0.65,
    AimbotFOV = 100,
    AimbotSmoothness = 0.3,
    HatColor = Color3.fromRGB(210, 180, 140),
    WorldColor = Color3.fromRGB(255, 0, 0),
    ParticleColor = Color3.fromRGB(255, 0, 0),
    CrosshairColor = Color3.fromRGB(0, 255, 0),
    FakeLagAmount = 5,
    AntiAimMode = "Spin",
    JumpCircleFadeTime = 1.5,
    TrailLength = 50,
    BacktrackAmount = 200,
    SunSpinSpeed = 50
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
local jumpCircleColor = Color3.fromRGB(0, 255, 0)

local trailEnabled = false
local trailParts = {}
local trailLength = 50
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

-- ===== СОЛНЫШКО (БЕШЕНЫЙ СПИН) =====
local sunSpinEnabled = false
local sunSpinConnection = nil
local sunSpinSpeed = 50

local function ToggleSunSpin()
    sunSpinEnabled = not sunSpinEnabled
    if sunSpinEnabled then
        if sunSpinConnection then sunSpinConnection:Disconnect() end
        sunSpinConnection = RunService.Heartbeat:Connect(function()
            if not sunSpinEnabled then return end
            local char = LP.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local pos = root.Position
            root.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(sunSpinSpeed), math.rad(sunSpinSpeed * 0.5))
        end)
        ShowMessage("☀️ Sun Spin ON")
    else
        if sunSpinConnection then sunSpinConnection:Disconnect() sunSpinConnection = nil end
        ShowMessage("☀️ Sun Spin OFF")
    end
end

-- ===== HvH ПЕРЕМЕННЫЕ =====
local antiAimEnabled = false
local antiAimConnection = nil
local antiAimMode = "Spin"
local fakeLagEnabled = false
local fakeLagConnection = nil
local silentAimEnabled = false
local silentAimConnection = nil
local triggerBotEnabled = false
local triggerBotConnection = nil
local doubleTapEnabled = false
local doubleTapConnection = nil
local fakeLagAmount = 5

-- ===== СТРЕЙФ =====
local strafeEnabled = false
local strafeConnection = nil

-- ===== ШЛЯПА =====
local hatEnabled = false
local currentHat = nil
local hatBrim = nil
local hatTopRing = nil
local hatTassel = nil
local hatConnection = nil

-- ===== WORLD COLOR =====
local worldColorEnabled = false
local originalAmbient = Lighting.Ambient
local originalOutdoor = Lighting.OutdoorAmbient

-- ===== ПАРТИКЛЫ =====
local particlesEnabled = false
local particlesConnection = nil

-- ===== ПРИЦЕЛ =====
local crosshairEnabled = false
local crosshairGui = nil
local crosshairColor = Color3.fromRGB(0, 255, 0)
local crosshairSize = 25
local crosshairGap = 10

-- ===== ОСТАЛЬНОЕ =====
local fullbrightEnabled = false
local nameTagsEnabled = false
local nameTagsFolder = Instance.new("Folder")
nameTagsFolder.Name = "MTY_NameTags"
nameTagsFolder.Parent = workspace
local skeletonEnabled = false
local skeletonFolder = Instance.new("Folder")
skeletonFolder.Name = "MTY_Skeleton"
skeletonFolder.Parent = workspace
local targetESPEnabled = false
local targetHighlight = nil

-- ===== NO FE =====
local cButtonEnabled = false
local cButtonGui = nil
local clemonRCLoaded = false
local r6Enabled = false

-- ===== SHIFTLOCK =====
local shiftlockActive = false
local shiftlockConnection = nil
local shiftlockButton = nil

-- ===== ФУНКЦИЯ ПОКАЗА СООБЩЕНИЙ =====
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
    if guiMainFrame then msg.Parent = guiMainFrame end
    local msgCorner = Instance.new("UICorner")
    msgCorner.CornerRadius = UDim.new(0, 8)
    msgCorner.Parent = msg
    wait(2)
    msg:Destroy()
end

-- ===== JUMP CIRCLE (КРУГ + ЗАТУХАНИЕ + ЦВЕТ) =====
local function ToggleJumpCircle()
    jumpCircleEnabled = not jumpCircleEnabled
    if jumpCircleEnabled then
        if jumpCircleConnection then jumpCircleConnection:Disconnect() end
        
        jumpCircle = Instance.new("Part")
        jumpCircle.Size = Vector3.new(6, 0.2, 6)
        jumpCircle.Anchored = true
        jumpCircle.CanCollide = false
        jumpCircle.Material = Enum.Material.Neon
        jumpCircle.BrickColor = BrickColor.new(jumpCircleColor)
        jumpCircle.Transparency = 1
        jumpCircle.Shape = Enum.PartType.Cylinder
        jumpCircle.Parent = workspace
        
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.Cylinder
        mesh.Scale = Vector3.new(1, 0.1, 1)
        mesh.Parent = jumpCircle
        
        local fadeStart = 0
        local isJumping = false
        
        jumpCircleConnection = RunService.Heartbeat:Connect(function()
            if not jumpCircleEnabled or not jumpCircle then return end
            
            local hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
            if not hum then return end
            
            local currentJumping = hum:GetState() == Enum.HumanoidStateType.Jumping
            
            if currentJumping and not isJumping then
                isJumping = true
                fadeStart = tick()
                jumpCircle.Transparency = 0.1
                jumpCircle.Size = Vector3.new(6, 0.2, 6)
                jumpCircle.Position = HRP.Position - Vector3.new(0, 3, 0)
                
            elseif not currentJumping and isJumping then
                local elapsed = tick() - fadeStart
                if elapsed < guiSettings.JumpCircleFadeTime then
                    local alpha = elapsed / guiSettings.JumpCircleFadeTime
                    jumpCircle.Transparency = 0.1 + (alpha * 0.9)
                    jumpCircle.Size = Vector3.new(6 - (alpha * 2), 0.2, 6 - (alpha * 2))
                else
                    jumpCircle.Transparency = 1
                    jumpCircle.Size = Vector3.new(0.1, 0.1, 0.1)
                    isJumping = false
                end
                
            elseif currentJumping and isJumping then
                jumpCircle.Position = HRP.Position - Vector3.new(0, 3, 0)
                jumpCircle.Transparency = 0.1
                jumpCircle.Size = Vector3.new(6, 0.2, 6)
            end
        end)
        
        ShowMessage("Jump Circle ON ⭕")
    else
        if jumpCircleConnection then jumpCircleConnection:Disconnect() jumpCircleConnection = nil end
        if jumpCircle then jumpCircle:Destroy() jumpCircle = nil end
        ShowMessage("Jump Circle OFF")
    end
end

-- ===== BACKTRACK (БОЛЬШЕ КУБОВ) =====
local function UpdateBacktrack()
    for _, v in pairs(backtrackFolder:GetChildren()) do v:Destroy() end
    if not backtrackEnabled then return end
    local now = tick()
    local count = 0
    for _, data in pairs(backtrackData) do
        if now - data.time < guiSettings.BacktrackTime then
            local part = Instance.new("Part")
            part.Size = Vector3.new(1, 1, 1)
            part.CFrame = data.cframe
            part.Anchored = true
            part.CanCollide = false
            part.Transparency = 0.5
            part.Material = Enum.Material.Neon
            part.BrickColor = BrickColor.new("Bright red")
            part.Parent = backtrackFolder
            game:GetService("Debris"):AddItem(part, 0.1)
            count = count + 1
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
                if #backtrackData > guiSettings.BacktrackAmount then table.remove(backtrackData, 1) end
                UpdateBacktrack()
            end
        end)
    else
        for _, v in pairs(backtrackFolder:GetChildren()) do v:Destroy() end
        backtrackData = {}
    end
    ShowMessage("Backtrack " .. (backtrackEnabled and "ON" or "OFF"))
end

-- ===== TRAIL (БОЛЬШЕ СЛЕДОВ) =====
local function CreateTrail()
    if not trailEnabled then return end
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local part = Instance.new("Part")
    part.Size = Vector3.new(0.3, 0.3, 0.3)
    part.CFrame = root.CFrame
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.BrickColor = BrickColor.new(guiSettings.TrailColor)
    part.Transparency = 0.6
    part.Parent = workspace
    table.insert(trailParts, part)
    if #trailParts > guiSettings.TrailLength then
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
        ShowMessage("Trail ON")
    else
        if trailConnection then trailConnection:Disconnect() trailConnection = nil end
        for _, v in pairs(trailParts) do v:Destroy() end
        trailParts = {}
        ShowMessage("Trail OFF")
    end
end

-- ===== ANTI-AIM =====
local function ToggleAntiAim()
    antiAimEnabled = not antiAimEnabled
    if antiAimEnabled then
        if antiAimConnection then antiAimConnection:Disconnect() end
        antiAimConnection = RunService.Heartbeat:Connect(function()
            if not antiAimEnabled then return end
            local char = LP.Character if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if not root or not hum then return end
            
            if antiAimMode == "Spin" then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(tick() * 200), 0)
            elseif antiAimMode == "Backwards" then
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0.1 then
                    local backwardDir = -moveDir
                    root.CFrame = CFrame.new(root.Position, root.Position + backwardDir * 10)
                else
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(180), 0)
                end
                hum.AutoRotate = false
            end
        end)
        ShowMessage("Anti-Aim ON [" .. antiAimMode .. "] 🔫")
    else
        if antiAimConnection then antiAimConnection:Disconnect() antiAimConnection = nil end
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.AutoRotate = true
        end
        ShowMessage("Anti-Aim OFF")
    end
end

local function SetAntiAimMode(mode)
    antiAimMode = mode
    if antiAimEnabled then
        ToggleAntiAim()
        wait(0.1)
        ToggleAntiAim()
    end
    ShowMessage("Anti-Aim Mode: " .. mode)
end

-- ===== FAKE LAG =====
local function ToggleFakeLag()
    fakeLagEnabled = not fakeLagEnabled
    if fakeLagEnabled then
        if fakeLagConnection then fakeLagConnection:Disconnect() end
        fakeLagConnection = RunService.Heartbeat:Connect(function()
            if not fakeLagEnabled then return end
            for i = 1, fakeLagAmount do wait(0.001) end
        end)
        ShowMessage("Fake Lag ON 📡")
    else
        if fakeLagConnection then fakeLagConnection:Disconnect() fakeLagConnection = nil end
        ShowMessage("Fake Lag OFF")
    end
end

-- ===== SILENT AIM =====
local function ToggleSilentAim()
    silentAimEnabled = not silentAimEnabled
    if silentAimEnabled then
        if silentAimConnection then silentAimConnection:Disconnect() end
        silentAimConnection = RunService.Heartbeat:Connect(function()
            if not silentAimEnabled then return end
            local target = nil
            local targetDist = math.huge
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LP and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        local pos, onScreen = Camera:WorldToScreenPoint(head.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                            if dist < guiSettings.AimbotFOV and dist < targetDist then
                                targetDist = dist
                                target = head
                            end
                        end
                    end
                end
            end
        end)
        ShowMessage("Silent Aim ON 🎯")
    else
        if silentAimConnection then silentAimConnection:Disconnect() silentAimConnection = nil end
        ShowMessage("Silent Aim OFF")
    end
end

-- ===== TRIGGER BOT =====
local function ToggleTriggerBot()
    triggerBotEnabled = not triggerBotEnabled
    if triggerBotEnabled then
        if triggerBotConnection then triggerBotConnection:Disconnect() end
        triggerBotConnection = RunService.Heartbeat:Connect(function()
            if not triggerBotEnabled then return end
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LP and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        local pos, onScreen = Camera:WorldToScreenPoint(head.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                            if dist < 50 then
                                VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, true, game, 0)
                                wait(0.05)
                                VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, false, game, 0)
                            end
                        end
                    end
                end
            end
        end)
        ShowMessage("Trigger Bot ON 🔥")
    else
        if triggerBotConnection then triggerBotConnection:Disconnect() triggerBotConnection = nil end
        ShowMessage("Trigger Bot OFF")
    end
end

-- ===== DOUBLE TAP =====
local function ToggleDoubleTap()
    doubleTapEnabled = not doubleTapEnabled
    if doubleTapEnabled then
        if doubleTapConnection then doubleTapConnection:Disconnect() end
        doubleTapConnection = RunService.Heartbeat:Connect(function()
            if not doubleTapEnabled then return end
            VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, true, game, 0)
            wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, false, game, 0)
            wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, true, game, 0)
            wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(Enum.UserInputType.MouseButton1, 0, false, game, 0)
        end)
        ShowMessage("Double Tap ON 💥")
    else
        if doubleTapConnection then doubleTapConnection:Disconnect() doubleTapConnection = nil end
        ShowMessage("Double Tap OFF")
    end
end

-- ===== КИТАЙСКАЯ ШЛЯПА =====
local function CreateChineseHat()
    if currentHat then currentHat:Destroy() currentHat = nil end
    if hatBrim then hatBrim:Destroy() hatBrim = nil end
    if hatTopRing then hatTopRing:Destroy() hatTopRing = nil end
    if hatTassel then hatTassel:Destroy() hatTassel = nil end
    
    currentHat = Instance.new("Part")
    currentHat.Size = Vector3.new(4, 0.1, 4)
    currentHat.Anchored = true
    currentHat.CanCollide = false
    currentHat.Material = Enum.Material.Neon
    currentHat.BrickColor = BrickColor.new(guiSettings.HatColor)
    currentHat.Transparency = 0.05
    currentHat.Parent = workspace
    
    local coneMesh = Instance.new("SpecialMesh")
    coneMesh.MeshType = Enum.MeshType.Cone
    coneMesh.Scale = Vector3.new(4, 2.2, 4)
    coneMesh.Parent = currentHat
    
    hatBrim = Instance.new("Part")
    hatBrim.Size = Vector3.new(4.8, 0.05, 4.8)
    hatBrim.Anchored = true
    hatBrim.CanCollide = false
    hatBrim.Material = Enum.Material.Neon
    hatBrim.BrickColor = BrickColor.new(guiSettings.HatColor)
    hatBrim.Transparency = 0.05
    hatBrim.Parent = workspace
    
    local ringMesh = Instance.new("SpecialMesh")
    ringMesh.MeshType = Enum.MeshType.Cylinder
    ringMesh.Scale = Vector3.new(1, 0.05, 1)
    ringMesh.Parent = hatBrim
    
    hatTopRing = Instance.new("Part")
    hatTopRing.Size = Vector3.new(1, 0.05, 1)
    hatTopRing.Anchored = true
    hatTopRing.CanCollide = false
    hatTopRing.Material = Enum.Material.Neon
    ha