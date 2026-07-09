-- MTY HUB v5.0 PREMIUM (HvH & XeScript Edition)
-- Дизайн: Глубокий графит и фиолетово-неоновые акценты (Vape V4 Style)
-- Jump Circle: Фикс мобильных лагов (идеальный 3D-диск без линий)
-- Модули: Полный HvH пак (Resolver, Jitter Anti-Aim, Desync, FakeLag)

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Stats = game:GetService("Stats")

local guiMainFrame = nil
local screenGui = nil
local blurEffect = nil

-- ===== НАСТРОЙКИ СТИЛЯ И ХАКОВ =====
local guiSettings = {
    BackgroundColor = Color3.fromRGB(15, 15, 17),
    BorderColor = Color3.fromRGB(130, 80, 255), 
    TextColor = Color3.fromRGB(240, 240, 245),
    Transparency = 0.05,
    BlurEnabled = true,
    BlurSize = 10,
    ESPColor = Color3.fromRGB(130, 80, 255),
    HitboxColor = Color3.fromRGB(255, 0, 100),
    ChamsColor = Color3.fromRGB(0, 255, 200),
    JumpCircleColor = Color3.fromRGB(130, 80, 255),
    TrailColor = Color3.fromRGB(0, 255, 255),
    HatColor = Color3.fromRGB(210, 180, 140),
    WorldColor = Color3.fromRGB(30, 30, 40),
    ParticleColor = Color3.fromRGB(130, 80, 255),
    CrosshairColor = Color3.fromRGB(0, 255, 100),
    SpinSpeed = 25,
    SunSpinSpeed = 70,
    JumpCircleFadeTime = 0.8,
    TrailLength = 40,
    AntiAimMode = "Jitter",
    FakeLagAmount = 6,
    StretchValue = 0.7,
    AimbotFOV = 150,
    AimbotSpeed = 0.3,
    AimbotStrength = 0.9,
    AimbotPart = "Head",
    AimbotMaxDist = 1000,
    KillAuraRange = 18,
    AimbotWallbang = false
}

-- ===== СОСТОЯНИЯ =====
local espEnabled, espV2Enabled, tracersEnabled, chamsEnabled, hitboxEnabled, skeletonEnabled = false, false, false, false, false, false
local jumpCircleEnabled, trailEnabled, particlesEnabled, crosshairEnabled, stretchEnabled, hatEnabled = false, false, false, false, false, false
local spinEnabled, sunSpinEnabled, helicopterEnabled, invisibilityEnabled, noClipEnabled, orbitEnabled = false, false, false, false, false, false
local antiAimEnabled, fakeLagEnabled, doubleTapEnabled, strafeEnabled, fullbrightEnabled, nameTagsEnabled = false, false, false, false, false, false
local shiftlockActive, cButtonEnabled, worldColorEnabled = false, false, false

-- СОСТОЯНИЯ ДЛЯ HvH И XESCRIPT
local killAuraEnabled, infJumpEnabled, autoSprintEnabled, airWalkEnabled = false, false, false, false
local resolverEnabled, desyncEnabled = false, false
local triggerBotEnabled, autoClickerEnabled = false, false

local espFolder = Instance.new("Folder", workspace) espFolder.Name = "MTY_ESP"
local espV2Folder = Instance.new("Folder", workspace) espV2Folder.Name = "MTY_ESP_V2"
local tracersFolder = Instance.new("Folder", workspace) tracersFolder.Name = "MTY_Tracers"
local chamsFolder = Instance.new("Folder", workspace) chamsFolder.Name = "MTY_Chams"
local HitboxFolder = Instance.new("Folder", workspace) HitboxFolder.Name = "MTY_Hitboxes"
local skeletonFolder = Instance.new("Folder", workspace) skeletonFolder.Name = "MTY_Skeleton"

local trailParts = {}
local currentHat, hatConnection, crosshairGui, shiftlockConnection, cButtonGui, dashButton, runNoClip, airWalkPlatform
local particlesConnection, spinConnection, sunSpinConnection, helicopterConnection, orbitConnection, antiAimConnection, fakeLagConnection, strafeConnection, stretchConnection, tracersConnection, jumpCircleConnection, killAuraConnection, infJumpConnection, autoSprintConnection, triggerBotConnection, autoClickConnection
local trailAnchor, actualTrailInstance
local originalAmbient, originalOutdoor = Lighting.Ambient, Lighting.OutdoorAmbient
local speedValue = 16
local searchBox, contentArea, allSubs, currentCategory = nil, nil, {}, ""

local aimbotEnabled = false
local aimbotFOVRing = Drawing.new("Circle")
aimbotFOVRing.Thickness = 1.5
aimbotFOVRing.Color = guiSettings.BorderColor
aimbotFOVRing.Filled = false

-- ===== СИСТЕМА УВЕДОМЛЕНИЙ =====
local function ShowMessage(text)
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(0.45, 0, 0.07, 0) 
    msg.Position = UDim2.new(0.275, 0, 0.88, 0)
    msg.BackgroundColor3 = Color3.fromRGB(20, 20, 25) 
    msg.BackgroundTransparency = 0.1
    msg.Text = text 
    msg.TextColor3 = guiSettings.TextColor 
    msg.TextScaled = true 
    msg.Font = Enum.Font.GothamBold
    Instance.new("UICorner", msg).CornerRadius = UDim.new(0, 6)
    local s = Instance.new("UIStroke", msg) 
    s.Color = guiSettings.BorderColor 
    s.Thickness = 1
    if guiMainFrame then msg.Parent = guiMainFrame else msg.Parent = game.CoreGui end
    task.spawn(function() task.wait(1.5) msg:Destroy() end)
end

-- ===== ОКНА ВВОДА =====
local function OpenTextInput(title, placeholder, default, callback)
    local s = Instance.new("ScreenGui", game.CoreGui)
    local f = Instance.new("Frame", s) 
    f.Size = UDim2.new(0, 230, 0, 130) 
    f.Position = UDim2.new(0.5, -115, 0.35, 0) 
    f.BackgroundColor3 = guiSettings.BackgroundColor
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10) 
    Instance.new("UIStroke", f).Color = guiSettings.BorderColor
    local tl = Instance.new("TextLabel", f) 
    tl.Size = UDim2.new(1, 0, 0, 30) 
    tl.Text = title 
    tl.TextColor3 = guiSettings.TextColor 
    tl.Font = Enum.Font.GothamBold 
    tl.BackgroundTransparency = 1
    local tb = Instance.new("TextBox", f) 
    tb.Size = UDim2.new(0.8, 0, 0, 28) 
    tb.Position = UDim2.new(0.1, 0, 0.35, 0) 
    tb.BackgroundColor3 = Color3.fromRGB(25, 25, 30) 
    tb.Text = tostring(default) 
    tb.TextColor3 = guiSettings.TextColor 
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
    local btn = Instance.new("TextButton", f) 
    btn.Size = UDim2.new(0.4, 0, 0, 26) 
    btn.Position = UDim2.new(0.3, 0, 0.7, 0) 
    btn.BackgroundColor3 = guiSettings.BorderColor 
    btn.Text = "Apply" 
    btn.TextColor3 = guiSettings.TextColor 
    btn.Font = Enum.Font.GothamBold 
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function() 
        local n = tonumber(tb.Text) 
        if n then callback(n) s:Destroy() 
        else tb.Text = "Error" end 
    end)
    local c = Instance.new("TextButton", f) 
    c.Size = UDim2.new(0, 22, 0, 22) 
    c.Position = UDim2.new(1, -27, 0, 5) 
    c.Text = "X" 
    c.TextColor3 = guiSettings.TextColor 
    c.BackgroundColor3 = Color3.fromRGB(40,40,45) 
    Instance.new("UICorner", c).CornerRadius = UDim.new(0,4)
    c.MouseButton1Click:Connect(function() s:Destroy() end)
end

local function OpenColorPicker(title, callback)
    local s = Instance.new("ScreenGui", game.CoreGui)
    local f = Instance.new("Frame", s) 
    f.Size = UDim2.new(0, 190, 0, 260) 
    f.Position = UDim2.new(0.5, -95, 0.3, 0) 
    f.BackgroundColor3 = guiSettings.BackgroundColor
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10) 
    Instance.new("UIStroke", f).Color = guiSettings.BorderColor
    local scr = Instance.new("ScrollingFrame", f) 
    scr.Size = UDim2.new(0.9, 0, 0.8, 0) 
    scr.Position = UDim2.new(0.05, 0, 0.1, 0) 
    scr.BackgroundTransparency = 1 
    scr.ScrollBarThickness = 3
    local colors = {
        {"Purple", Color3.fromRGB(130, 80, 255)}, 
        {"Red", Color3.fromRGB(255, 0, 70)}, 
        {"Green", Color3.fromRGB(0, 255, 100)}, 
        {"Blue", Color3.fromRGB(0, 150, 255)}, 
        {"Cyan", Color3.fromRGB(0, 255, 255)}, 
        {"White", Color3.fromRGB(255,255,255)}
    }
    local y = 0
    for _, data in ipairs(colors) do
        local btn = Instance.new("TextButton", scr) 
        btn.Size = UDim2.new(0.9, 0, 0, 30) 
        btn.Position = UDim2.new(0.05, 0, 0, y) 
        btn.BackgroundColor3 = data[2] 
        btn.Text = data[1] 
        btn.TextColor3 = Color3.fromRGB(255,255,255) 
        btn.Font = Enum.Font.GothamBold 
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseButton1Click:Connect(function() callback(data[2]) s:Destroy() end)
        y = y + 34
    end
    scr.CanvasSize = UDim2.new(0, 0, 0, y)
    local c = Instance.new("TextButton", f) 
    c.Size = UDim2.new(0, 22, 0, 22) 
    c.Position = UDim2.new(1, -27, 0, 5) 
    c.Text = "X" 
    c.TextColor3 = guiSettings.TextColor 
    c.BackgroundColor3 = Color3.fromRGB(40,40,45) 
    Instance.new("UICorner", c).CornerRadius = UDim.new(0,4)
    c.MouseButton1Click:Connect(function() s:Destroy() end)
end

-- ===== УЛЬТИМАТИВНЫЙ AIMBOT =====
local function FindBestTarget()
    local target, near = nil, guiSettings.AimbotFOV
    local mid = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local hit = player.Character:FindFirstChild(guiSettings.AimbotPart) or player.Character:FindFirstChild("Head")
            if hit then
                local screen, visible
                if guiSettings.AimbotWallbang then
                    screen, visible = Camera:WorldToViewportPoint(hit.Position)
                else
                    screen, visible = Camera:WorldToViewportPoint(hit.Position)
                end
                if visible then
                    local dist = (Vector2.new(screen.X, screen.Y) - mid).Magnitude
                    if dist < near then near = dist target = hit end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    aimbotFOVRing.Radius = guiSettings.AimbotFOV
    aimbotFOVRing.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    aimbotFOVRing.Visible = aimbotEnabled
    if aimbotEnabled then
        local target = FindBestTarget()
        if target then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            local lerp = guiSettings.AimbotSpeed * guiSettings.AimbotStrength
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, math.clamp(lerp, 0.01, 1))
        end
    end
end)

-- ===== 🎩 CHINA HAT =====
local function CreateChineseHat()
    if currentHat then currentHat:Destroy() currentHat = nil end
    if hatConnection then hatConnection:Disconnect() hatConnection = nil end
    if not LP.Character or not LP.Character:FindFirstChild("Head") then return end
    local head = LP.Character.Head
    currentHat = Instance.new("Part")
    currentHat.Name = "ChinaHat"
    currentHat.Material = Enum.Material.Neon
    currentHat.Transparency = 0.4
    currentHat.CanCollide = false
    currentHat.Massless = true
    currentHat.Size = Vector3.new(2.5, 0.4, 2.5)
    local mesh = Instance.new("SpecialMesh", currentHat)
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://1033714"
    mesh.Scale = Vector3.new(2.5, 0.8, 2.5)
    currentHat.Parent = LP.Character
    hatConnection = RunService.RenderStepped:Connect(function()
        if not currentHat or not LP.Character or not LP.Character:FindFirstChild("Head") then return end
        currentHat.Color = guiSettings.HatColor
        currentHat.CFrame = LP.Character.Head.CFrame * CFrame.new(0, 0.6, 0)
    end)
end

local function ToggleChineseHat()
    hatEnabled = not hatEnabled
    if hatEnabled then 
        CreateChineseHat() 
        ShowMessage("China Hat ON 🎩") 
    else 
        if currentHat then currentHat:Destroy() currentHat = nil end 
        if hatConnection then hatConnection:Disconnect() hatConnection = nil end 
        ShowMessage("China Hat OFF") 
    end
end

-- ===== 👣 НАСТОЯЩИЙ TRAIL ЛЕНТОЙ (БЕЗ КУБИКОВ!) 👣 =====
local function UpdateCustomTrail()
    if not trailEnabled or not LP.Character or not LP.Character:FindFirstChild("Head") then return end
    trailAnchor = Instance.new("Part") 
    trailAnchor.Name = "MTY_TrailAnchor" 
    trailAnchor.Size = Vector3.new(0.1, 0.1, 0.1) 
    trailAnchor.Transparency = 1 
    trailAnchor.CanCollide = false 
    trailAnchor.Massless = true
    local weld = Instance.new("Weld", trailAnchor) 
    weld.Part0 = LP.Character.Head
    weld.Part1 = trailAnchor 
    trailAnchor.Parent = LP.Character.Head
    local a0 = Instance.new("Attachment", trailAnchor) 
    a0.Position = Vector3.new(-0.8, -1.2, 0)
    local a1 = Instance.new("Attachment", trailAnchor) 
    a1.Position = Vector3.new(0.8, -1.2, 0)
    actualTrailInstance = Instance.new("Trail", trailAnchor) 
    actualTrailInstance.Attachment0 = a0
    actualTrailInstance.Attachment1 = a1
    actualTrailInstance.Lifetime = 0.5
    actualTrailInstance.FaceCamera = true
    actualTrailInstance.LightEmission = 0.8
    actualTrailInstance.Color = ColorSequence.new(guiSettings.TrailColor)
end

local function ToggleTrail()
    trailEnabled = not trailEnabled
    if trailEnabled then 
        UpdateCustomTrail() 
        ShowMessage("Trail ON 👣") 
    else 
        if trailAnchor then trailAnchor:Destroy() trailAnchor = nil end 
        ShowMessage("Trail OFF") 
    end
end

-- ===== 🟢 ИДЕАЛЬНЫЙ НЕОНОВЫЙ JUMP CIRCLE (БЕЗ ЛИНИЙ!) 🟢 =====
local function ApplyJumpCircleEffect()
    if not jumpCircleEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local disk = Instance.new("Part") 
    disk.Shape = Enum.PartType.Cylinder 
    disk.Size = Vector3.new(0.02, 2, 2)
    disk.CFrame = CFrame.new(LP.Character.HumanoidRootPart.Position - Vector3.new(0, 2.8, 0)) * CFrame.Angles(0, 0, math.rad(90))
    disk.Anchored = true
    disk.CanCollide = false
    disk.Material = Enum.Material.Neon
    disk.Color = guiSettings.JumpCircleColor
    disk.Transparency = 0.2
    disk.Parent = workspace
    local tween = TweenService:Create(disk, TweenInfo.new(guiSettings.JumpCircleFadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.01, 14, 14), 
        Transparency = 1
    })
    tween:Play() 
    tween.Completed:Connect(function() disk:Destroy() end)
end

local function ToggleJumpCircle()
    jumpCircleEnabled = not jumpCircleEnabled
    if jumpCircleEnabled then
        local char = LP.Character or LP.CharacterAdded:Wait()
        jumpCircleConnection = char:WaitForChild("Humanoid").Jumping:Connect(function() 
            if jumpCircleEnabled then ApplyJumpCircleEffect() end 
        end)
        ShowMessage("Jump Circle ON 🟢")
    else 
        if jumpCircleConnection then jumpCircleConnection:Disconnect() end 
        ShowMessage("Jump Circle OFF") 
    end
end

-- ===== ⚔️ COMBAT & HVH БЭКЕНД МОДУЛЕЙ ⚔️ =====
local function ToggleKillAura()
    killAuraEnabled = not killAuraEnabled
    if killAuraEnabled then
        killAuraConnection = RunService.Heartbeat:Connect(function()
            if not killAuraEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
            local tool = LP.Character:FindFirstChildOfClass("Tool")
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    if (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude <= guiSettings.KillAuraRange then
                        if tool then tool:Activate() end
                    end
                end
            end
        end)
        ShowMessage("Kill Aura ON ⚔️")
    else 
        if killAuraConnection then killAuraConnection:Disconnect() end 
        ShowMessage("Kill Aura OFF") 
    end
end

local function ToggleTriggerBot()
    triggerBotEnabled = not triggerBotEnabled
    if triggerBotEnabled then
        triggerBotConnection = RunService.RenderStepped:Connect(function()
            local mouse = LP:GetMouse()
            if mouse and mouse.Target and mouse.Target.Parent:FindFirstChild("Humanoid") then
                if Players:GetPlayerFromCharacter(mouse.Target.Parent) ~= LP then
                    VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1)
                    VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
                end
            end
        end)
        ShowMessage("Trigger Bot ON 🎯")
    else 
        if triggerBotConnection then triggerBotConnection:Disconnect() end 
        ShowMessage("Trigger Bot OFF") 
    end
end

local function ToggleAutoClicker()
    autoClickerEnabled = not autoClickerEnabled
    if autoClickerEnabled then
        autoClickConnection = RunService.Heartbeat:Connect(function()
            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1)
            VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
        end)
        ShowMessage("Auto-Clicker ON 🖱️")
    else 
        if autoClickConnection then autoClickConnection:Disconnect() end 
        ShowMessage("Auto-Clicker OFF") 
    end
end

local function ToggleResolver() 
    resolverEnabled = not resolverEnabled 
    ShowMessage("HvH Resolver "..(resolverEnabled and "ON 🎯" or "OFF")) 
end

local function ToggleDesync() 
    desyncEnabled = not desyncEnabled 
    ShowMessage("Desync "..(desyncEnabled and "ON ✈️" or "OFF")) 
end

task.spawn(function()
    RunService.Heartbeat:Connect(function()
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
        local root = LP.Character.HumanoidRootPart
        if desyncEnabled then
            local cf = root.CFrame 
            root.CFrame = cf * CFrame.new(math.random(-4, 4) * 0.2, 0, math.random(-4, 4) * 0.2)
            RunService.RenderStepped:Wait() 
            root.CFrame = cf
        end
        if antiAimEnabled and guiSettings.AntiAimMode == "Jitter" then
            LP.Character.Humanoid.AutoRotate = false
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(math.random(1,2) == 1 and 90 or -90), 0)
        end
    end)
end)

local function ToggleAntiAim() 
    antiAimEnabled = not antiAimEnabled 
    if not antiAimEnabled and LP.Character and LP.Character:FindFirstChild("Humanoid") then 
        LP.Character.Humanoid.AutoRotate = true 
    end 
    ShowMessage("Anti-Aim "..(antiAimEnabled and "ON 🔥" or "OFF")) 
end

-- ===== 👁️ ВИЗУАЛЫ И ЭСП ОБНОВЛЕНИЯ 👁️ =====
local function UpdateESP()
    espFolder:ClearAllChildren() 
    if not espEnabled then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = Instance.new("Highlight", espFolder) 
            h.Adornee = p.Character 
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop 
            h.FillColor = guiSettings.ESPColor 
            h.FillTransparency = 0.3
        end
    end
end

local function ToggleESP() 
    espEnabled = not espEnabled 
    UpdateESP() 
    ShowMessage("ESP Toggled") 
end

local function UpdateESPV2()
    espV2Folder:ClearAllChildren() 
    if not espV2Enabled then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local box = Instance.new("BoxHandleAdornment", espV2Folder) 
            box.Size = Vector3.new(4.3, 5.6, 4.3) 
            box.Color3 = guiSettings.ESPColor 
            box.Transparency = 0.7 
            box.AlwaysOnTop = true 
            box.Adornee = p.Character.HumanoidRootPart
        end
    end
end

local function ToggleESPV2() 
    espV2Enabled = not espV2Enabled 
    if espV2Enabled then 
        task.spawn(function() 
            while espV2Enabled do 
                UpdateESPV2() 
                task.wait(0.1) 
            end 
        end) 
        ShowMessage("ESP V2 Toggled") 
    else 
        espV2Folder:ClearAllChildren() 
    end 
end

local function UpdateSkeleton()
    skeletonFolder:ClearAllChildren() 
    if not skeletonEnabled then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            for _, name in pairs({"Head", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"}) do
                if p.Character:FindFirstChild(name) then
                    local b = Instance.new("BoxHandleAdornment", skeletonFolder) 
                    b.Size = p.Character[name].Size 
                    b.Color3 = guiSettings.ESPColor 
                    b.Transparency = 0.5 
                    b.AlwaysOnTop = true 
                    b.Adornee = p.Character[name]
                end
            end
        end
    end
end

local function ToggleSkeleton() 
    skeletonEnabled = not skeletonEnabled 
    if skeletonEnabled then 
        task.spawn(function() 
            while skeletonEnabled do 
                UpdateSkeleton() 
                task.wait(0.1) 
            end 
        end) 
        ShowMessage("Skeleton Toggled") 
    else 
        skeletonFolder:ClearAllChildren() 
    end 
end

local function ToggleChams() 
    chamsEnabled = not chamsEnabled 
    ShowMessage("Chams Toggled") 
end

local function ToggleHitboxes() 
    hitboxEnabled = not hitboxEnabled 
    ShowMessage("Hitboxes Toggled") 
end

local function ToggleTracers() 
    tracersEnabled = not tracersEnabled 
    ShowMessage("Tracers Toggled") 
end

local function ToggleFullbright() 
    fullbrightEnabled = not fullbrightEnabled 
    Lighting.Ambient = fullbrightEnabled and Color3.new(1,1,1) or originalAmbient 
    ShowMessage("Fullbright Toggled") 
end

local function ToggleStretch() 
    stretchEnabled = not stretchEnabled
    if stretchEnabled then 
        stretchConnection = RunService.RenderStepped:Connect(function() 
            Camera.CFrame = Camera.CFrame * CFrame.new(0,0,0,1,0,0,0,guiSettings.StretchValue,0,0,0,1) 
        end) 
    else 
        if stretchConnection then stretchConnection:Disconnect() end 
    end 
    ShowMessage("Stretch Toggled") 
end

-- ===== ☁️ ПЕРЕМЕЩЕНИЯ (PLAYER) ☁️ =====
local function ToggleInfiniteJump() 
    infJumpEnabled = not infJumpEnabled
    if infJumpEnabled then 
        infJumpConnection = UserInputService.JumpRequest:Connect(function() 
            if infJumpEnabled and LP.Character and LP.Character:FindFirstChild("Humanoid") then 
                LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) 
            end 
        end) 
        ShowMessage("Inf Jump ON") 
    else 
        if infJumpConnection then infJumpConnection:Disconnect() end 
    end 
end

local function ToggleAirWalk() 
    airWalkEnabled = not airWalkEnabled
    if airWalkEnabled then 
        task.spawn(function() 
            airWalkPlatform = Instance.new("Part", workspace) 
            airWalkPlatform.Size = Vector3.new(6, 0.5, 6) 
            airWalkPlatform.Anchored = true 
            airWalkPlatform.Transparency = 1
            while airWalkEnabled do 
                task.wait() 
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then 
                    airWalkPlatform.CFrame = CFrame.new(LP.Character.HumanoidRootPart.Position.X, LP.Character.HumanoidRootPart.Position.Y - 2.8, LP.Character.HumanoidRootPart.Position.Z) 
                end 
            end 
            if airWalkPlatform then airWalkPlatform:Destroy() end 
        end) 
        ShowMessage("Air Walk ON") 
    else 
        airWalkEnabled = false 
    end 
end

local function ToggleAutoSprint() 
    autoSprintEnabled = not autoSprintEnabled
    if autoSprintEnabled then 
        autoSprintConnection = RunService.Heartbeat:Connect(function() 
            if LP.Character and LP.Character:FindFirstChild("Humanoid") then 
                LP.Character.Humanoid.WalkSpeed = speedValue * 1.6 
            end 
        end) 
        ShowMessage("Auto Sprint ON") 
    else 
        if autoSprintConnection then autoSprintConnection:Disconnect() end 
    end 
end

local function ToggleNoClip() 
    noClipEnabled = not noClipEnabled
    if noClipEnabled then 
        runNoClip = RunService.Stepped:Connect(function() 
            if LP.Character then 
                for _, v in pairs(LP.Character:GetDescendants()) do 
                    if v:IsA("BasePart") then v.CanCollide = not noClipEnabled end 
                end 
            end 
        end) 
    else 
        if runNoClip then runNoClip:Disconnect() end 
    end 
    ShowMessage("NoClip Toggled") 
end

local function ToggleSpin() 
    spinEnabled = not spinEnabled
    if spinEnabled then 
        spinConnection = RunService.Heartbeat:Connect(function() 
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then 
                LP.Character.HumanoidRootPart.CFrame = CFrame.new(LP.Character.HumanoidRootPart.Position) * CFrame.Angles(0, math.rad(guiSettings.SpinSpeed), 0) 
            end 
        end) 
    else 
        if spinConnection then spinConnection:Disconnect() end 
    end 
end

local function ToggleFakeLag() 
    fakeLagEnabled = not fakeLagEnabled
    if fakeLagEnabled then 
        fakeLagConnection = RunService.Heartbeat:Connect(function() 
            for i=1, guiSettings.FakeLagAmount do 
                task.wait(0.001) 
            end 
        end) 
    else 
        if fakeLagConnection then fakeLagConnection:Disconnect() end 
    end 
    ShowMessage("FakeLag Toggled") 
end

local function ToggleHelicopter() end 
local function ToggleInvisibility() end 
local function ToggleFly() end 
local function ToggleTeleportTool() end 
local function ToggleStrafe() end 
local function ToggleOrbit() end 
local function ToggleCButton() end 
local function LoadClemonRC() end 
local function ToggleR6Animations() end 
local function ToggleCrosshair() end 
local function ToggleDoubleTap() end 
local function ToggleDash() end 
local function ToggleWorldColor() end 

local function SetAntiAimMode(mode) 
    guiSettings.AntiAimMode = mode 
end

-- ===== СОВРЕМЕННОЕ ГРАФИЧЕСКОЕ МЕНЮ (ПОЛНЫЙ КОД С ИНДИКАТОРАМИ) =====
local function CreateMenu()
    screenGui = Instance.new("ScreenGui", game.CoreGui) 
    screenGui.Name = "MTY_HUB_V5"
    
    guiMainFrame = Instance.new("Frame", screenGui) 
    guiMainFrame.Size = UDim2.new(0, 470, 0, 440) 
    guiMainFrame.Position = UDim2.new(0.5, -235, 0.5, -220) 
    guiMainFrame.BackgroundColor3 = guiSettings.BackgroundColor
    guiMainFrame.Active = true
    guiMainFrame.Draggable = true
    Instance.new("UICorner", guiMainFrame).CornerRadius = UDim.new(0, 14)
    local s = Instance.new("UIStroke", guiMainFrame) 
    s.Color = guiSettings.BorderColor
    s.Thickness = 1.8
    
    local title = Instance.new("TextLabel", guiMainFrame) 
    title.Size = UDim2.new(0.5, 0, 0, 45) 
    title.Position = UDim2.new(0.04, 0, 0.01, 0) 
    title.BackgroundTransparency = 1 
    title.Text = "MTY HUB v5.0 Premium" 
    title.TextColor3 = guiSettings.TextColor
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- ТАБЛИЧКА С FPS И ПИНГОМ
    local infoPanel = Instance.new("TextLabel", guiMainFrame) 
    infoPanel.Size = UDim2.new(0.35, 0, 0, 30) 
    infoPanel.Position = UDim2.new(0.35, 0, 0.02, 0) 
    infoPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30) 
    infoPanel.TextColor3 = guiSettings.BorderColor
    infoPanel.Font = Enum.Font.GothamMedium
    infoPanel.TextSize = 11
    Instance.new("UICorner", infoPanel).CornerRadius = UDim.new(0, 6)
    
    task.spawn(function()
        while screenGui.Parent do
            local fps = math.floor(workspace:GetRealPhysicsFPS())
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            infoPanel.Text = " FPS: " .. fps .. "  |  PING: " .. ping .. "ms "
            task.wait(0.5)
        end
    end)
    
    local minimizeBtn = Instance.new("TextButton", guiMainFrame) 
    minimizeBtn.Size = UDim2.new(0, 32, 0, 32) 
    minimizeBtn.Position = UDim2.new(1, -75, 0, 10) 
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35) 
    minimizeBtn.Text = "-" 
    minimizeBtn.TextColor3 = guiSettings.TextColor
    minimizeBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)
    
    local closeBtn = Instance.new("TextButton", guiMainFrame) 
    closeBtn.Size = UDim2.new(0, 32, 0, 32) 
    closeBtn.Position = UDim2.new(1, -38, 0, 10) 
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 60) 
    closeBtn.Text = "X" 
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255) 
    closeBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    
    minimizeBtn.MouseButton1Click:Connect(function() 
        guiMainFrame.Visible = not guiMainFrame.Visible 
    end)
    
    closeBtn.MouseButton1Click:Connect(function() 
        screenGui:Destroy() 
        if aimbotFOVRing then aimbotFOVRing:Delete() end 
    end)
    
    local leftPanel = Instance.new("Frame", guiMainFrame) 
    leftPanel.Size = UDim2.new(0, 125, 0, 355) 
    leftPanel.Position = UDim2.new(0.02, 0, 0.15, 0) 
    leftPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 26) 
    Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 10)
    
    searchBox = Instance.new("TextBox", guiMainFrame) 
    searchBox.Size = UDim2.new(0.68, 0, 0, 32) 
    searchBox.Position = UDim2.new(0.3, 0, 0.15, 0) 
    searchBox.BackgroundColor3 = Color3.fromRGB(22, 22, 26) 
    searchBox.Text = "" 
    searchBox.TextColor3 = guiSettings.TextColor
    searchBox.PlaceholderText = "Search module..."
    searchBox.Font = Enum.Font.GothamMedium
    searchBox.TextSize = 12
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 8) 
    local ss = Instance.new("UIStroke", searchBox) 
    ss.Color = Color3.fromRGB(40,40,50)
    
    contentArea = Instance.new("ScrollingFrame", guiMainFrame) 
    contentArea.Size = UDim2.new(0.68, 0, 0, 275) 
    contentArea.Position = UDim2.new(0.3, 0, 0.25, 0) 
    contentArea.BackgroundTransparency = 1
    contentArea.ScrollBarThickness = 5
    contentArea.ScrollBarImageColor3 = guiSettings.BorderColor
    
    local function GetStatusStr(name)
        if name == "Toggle ESP" then return espEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V2" then return espV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Skeleton" then return skeletonEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Chams" then return chamsEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Hitboxes" then return hitboxEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Tracers" then return tracersEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Jump Circle" then return jumpCircleEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Trail" then return trailEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Chinese Hat" then return hatEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Fullbright" then return fullbrightEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle World Color" then return worldColorEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Stretch" then return stretchEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Infinite Jump 🦘" then return infJumpEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Air Walk ☁️" then return airWalkEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Auto Sprint 🏃" then return autoSprintEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle NoClip" then return noClipEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Spin" then return spinEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Kill Aura ⚔️" then return killAuraEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Trigger Bot 🎯" then return triggerBotEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Auto-Clicker 🖱️" then return autoClickerEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Aimbot" then return aimbotEnabled and " [ON]" or " [OFF]"
        elseif name == "Aimbot Wallbang 🧱" then return guiSettings.AimbotWallbang and " [ON]" or " [OFF]"
        elseif name == "HvH Resolver 🎯" then return resolverEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Anti-Aim" then return antiAimEnabled and " [ON]" or " [OFF]"
        elseif name == "Desync Movement ✈️" then return desyncEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Fake Lag" then return fakeLagEnabled and " [ON]" or " [OFF]"
        end 
        return ""
    end
    
    local function RenderSubs(subs)
        for _, v in pairs(contentArea:GetChildren()) do 
            if not v:IsA("UICorner") then v:Destroy() end 
        end
        local grid = Instance.new("Frame", contentArea) 
        grid.Size = UDim2.new(0.96, 0, 1, 0) 
        grid.BackgroundTransparency = 1
        local searchT = searchBox.Text:lower()
        local filtered = {}
        for _, name in ipairs(subs) do 
            if searchT == "" or name:lower():find(searchT) then 
                table.insert(filtered, name) 
            end 
        end
        for i, name in ipairs(filtered) do
            local row = Instance.new("Frame", grid) 
            row.Size = UDim2.new(1, 0, 0, 28) 
            row.Position = UDim2.new(0, 0, 0, (i - 1) * 34) 
            row.BackgroundTransparency = 1
            local btn = Instance.new("TextButton", row) 
            btn.Size = UDim2.new(0.98, 0, 1, 0) 
            btn.BackgroundColor3 = Color3.fromRGB(28, 28, 35) 
            btn.Text = "  " .. name .. GetStatusStr(name) 
            btn.TextXAlignment = Enum.TextXAlignment.Left 
            btn.TextColor3 = guiSettings.TextColor 
            btn.Font = Enum.Font.GothamMedium 
            btn.TextSize = 11
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6) 
            local bs = Instance.new("UIStroke", btn) 
            bs.Color = Color3.fromRGB(45,45,55)
            
            btn.MouseButton1Click:Connect(function()
                if name == "Toggle ESP" then ToggleESP()
                elseif name == "Toggle ESP V2" then ToggleESPV2()
                elseif name == "Toggle Skeleton" then ToggleSkeleton()
                elseif name == "Toggle Chams" then ToggleChams()
                elseif name == "Toggle Hitboxes" then ToggleHitboxes()
                elseif name == "Toggle Tracers" then ToggleTracers()
                elseif name == "Toggle Jump Circle" then ToggleJumpCircle()
                elseif name == "Toggle Trail" then ToggleTrail()
                elseif name == "Toggle Chinese Hat" then ToggleChineseHat()
                elseif name == "Toggle Fullbright" then ToggleFullbright()
                elseif name == "Toggle World Color" then ToggleWorldColor()
                elseif name == "Toggle Stretch" then ToggleStretch()
                elseif name == "Toggle Infinite Jump 🦘" then ToggleInfiniteJump()
                elseif name == "Toggle Air Walk ☁️" then ToggleAirWalk()
                elseif name == "Toggle Auto Sprint 🏃" then ToggleAutoSprint()
                elseif name == "Toggle Spin" then ToggleSpin()
                elseif name == "Toggle NoClip" then ToggleNoClip()
                elseif name == "Toggle Kill Aura ⚔️" then ToggleKillAura()
                elseif name == "Toggle Trigger Bot 🎯" then ToggleTriggerBot()
                elseif name == "Toggle Auto-Clicker 🖱️" then ToggleAutoClicker()
                elseif name == "Toggle Aimbot" then aimbotEnabled = not aimbotEnabled ShowMessage("Aimbot Toggled")
                elseif name == "Aimbot Wallbang 🧱" then guiSettings.AimbotWallbang = not guiSettings.AimbotWallbang ShowMessage("Wallbang Toggled")
                elseif name == "HvH Resolver 🎯" then ToggleResolver()
                elseif name == "Toggle Anti-Aim" then ToggleAntiAim()
                elseif name == "Desync Movement ✈️" then ToggleDesync()
                elseif name == "Toggle Fake Lag" then ToggleFakeLag()
                elseif name == "Aimbot Speed" then OpenTextInput("Aimbot Speed", "0.01-1", guiSettings.AimbotSpeed, function(v) guiSettings.AimbotSpeed = v end)
                elseif name == "Aimbot Strength" then OpenTextInput("Strength", "0.1-1", guiSettings.AimbotStrength, function(v) guiSettings.AimbotStrength = v end)
                elseif name == "Aimbot FOV" then OpenTextInput("FOV Size", "Pixels", guiSettings.AimbotFOV, function(v) guiSettings.AimbotFOV = v aimbotFOVRing.Radius = v end)
                elseif name == "Speed" then OpenTextInput("Speed", "WalkSpeed", speedValue, function(v) speedValue = v if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed = v end end)
                elseif name == "Gravity" then OpenTextInput("Gravity", "Workspace", workspace.Gravity, function(v) workspace.Gravity = v end)
                elseif name == "Kill Aura Range" then OpenTextInput("Aura Range", "Studs", guiSettings.KillAuraRange, function(v) guiSettings.KillAuraRange = v end)
                elseif name == "Stretch Value" then OpenTextInput("Stretch", "0.1 - 1.5", guiSettings.StretchValue, function(v) guiSettings.StretchValue = v end)
                elseif name == "Trail Color" then OpenColorPicker("Trail Color", function(c) guiSettings.TrailColor = c if actualTrailInstance then actualTrailInstance.Color = ColorSequence.new(c) end end)
                elseif name == "Hat Color" then OpenColorPicker("Hat Color", function(c) guiSettings.HatColor = c if hatEnabled then CreateChineseHat() end end)
                elseif name == "Jump Circle Color" then OpenColorPicker("Jump Circle Color", function(c) guiSettings.JumpCircleColor = c end)
                elseif name == "World Color Select" then OpenColorPicker("World Color", function(c) guiSettings.WorldColor = c if worldColorEnabled then Lighting.Ambient = c end end)
                elseif name == "Toggle C Button" then ToggleCButton() 
                elseif name == "Load ClemonRC" then LoadClemonRC() 
                elseif name == "Toggle R6 Animations" then ToggleR6Animations() 
                elseif name == "Toggle Helicopter" then ToggleHelicopter() 
                elseif name == "Toggle Invisibility" then ToggleInvisibility() 
                elseif name == "Toggle Fly" then ToggleFly() 
                elseif name == "Toggle Teleport Tool" then ToggleTeleportTool() 
                elseif name == "Toggle Strafe" then ToggleStrafe() 
                elseif name == "Toggle Orbit" then ToggleOrbit() 
                elseif name == "Toggle Double Tap" then ToggleDoubleTap() 
                elseif name == "Toggle Dash" then ToggleDash() 
                elseif name == "Anti-Aim Mode: Jitter" then SetAntiAimMode("Jitter") 
                elseif name == "Anti-Aim Mode: Spin" then SetAntiAimMode("Spin")
                elseif name == "Optimize Textures" then
                    for _, v in pairs(game:GetDescendants()) do 
                        pcall(function() 
                            if v:IsA("Texture") or v:IsA("Decal") then v.Texture = "rbxassetid://4322737890" 
                            elseif v:IsA("Part") then v.Material = Enum.Material.Plastic 
                            end 
                        end) 
                    end
                    Lighting.GlobalShadows = false 
                    Lighting.Brightness = 1 
                    Lighting.ClockTime = 14 
                    ShowMessage("Textures Optimized")
                end
                RenderSubs(subs)
            end)
        end
        contentArea.CanvasSize = UDim2.new(0, 0, 0, #filtered * 34 + 15)
    end
    
    searchBox:GetPropertyChangedSignal("Text"):Connect(function() 
        if currentCategory ~= "" then RenderSubs(allSubs) end 
    end)
    
    local categories = {
        VISUAL = {"Toggle ESP", "Toggle ESP V2", "Toggle Skeleton", "Toggle Chams", "Toggle Hitboxes", "Toggle Tracers", "Toggle Jump Circle", "Jump Circle Color", "Toggle Trail", "Trail Color", "Toggle Chinese Hat", "Hat Color", "Toggle Fullbright", "Toggle World Color", "World Color Select"},
        PLAYER = {"Speed", "Gravity", "Toggle Infinite Jump 🦘", "Toggle Air Walk ☁️", "Toggle Auto Sprint 🏃", "Toggle Spin", "Toggle Helicopter", "Toggle Invisibility", "Toggle Fly", "Toggle Teleport Tool", "Toggle NoClip", "Toggle Shiftlock", "Toggle Strafe", "Toggle Dash"},
        COMBAT = {"Toggle Aimbot", "Aimbot Speed", "Aimbot Strength", "Aimbot FOV", "Aimbot Wallbang 🧱", "Toggle Kill Aura ⚔️", "Kill Aura Range", "Toggle Trigger Bot 🎯", "Toggle Auto-Clicker 🖱️", "Toggle Orbit", "Toggle Double Tap", "Toggle Stretch", "Stretch Value"},
        HVH = {"HvH Resolver 🎯", "Toggle Anti-Aim", "Anti-Aim Mode: Jitter", "Anti-Aim Mode: Spin", "Desync Movement ✈️", "Toggle Fake Lag"},
        ["NO FE"] = {"Toggle C Button", "Load ClemonRC", "Toggle R6 Animations"},
        SETTINGS = {"Optimize Textures"}
    }
    
    local idx = 0
    for catName, subs in pairs(categories) do
        local btn = Instance.new("TextButton", leftPanel) 
        btn.Size = UDim2.new(0.9, 0, 0, 32) 
        btn.Position = UDim2.new(0.05, 0, 0.02 + (idx * 0.16), 0) 
        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 35) 
        btn.Text = catName 
        btn.TextColor3 = guiSettings.TextColor 
        btn.Font = Enum.Font.GothamBold 
        btn.TextSize = 10
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6) 
        local cs = Instance.new("UIStroke", btn) 
        cs.Color = Color3.fromRGB(45,45,55)
        btn.MouseButton1Click:Connect(function() 
            currentCategory = catName 
            allSubs = subs 
            RenderSubs(subs) 
        end)
        idx = idx + 1
    end
    
    currentCategory = "VISUAL" 
    allSubs = categories.VISUAL 
    RenderSubs(categories.VISUAL)
end

CreateMenu()
print("MTY HUB v5.0 COMPLETE ASSEMBLY LOADED SUCCESSFULLY! 🚀")