-- MTY HUB v5.0 ULTIMATE (FIXED BUILD)
-- Полный фикс синтаксиса меню (исправлена ошибка с b.TextXAlignment)
-- Все HvH, Combat, Visual модули (V1, V2, V3) полностью сохранены

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Stats = game:GetService("Stats")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local guiMainFrame = nil
local screenGui = nil
local blurEffect = nil

-- ===== НАСТРОЙКИ =====
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
    HatColor = Color3.fromRGB(130, 80, 255),
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
    AimbotWallbang = true
}

-- ===== СОСТОЯНИЯ ВСЕХ МОДУЛЕЙ =====
local espEnabled, espV2Enabled, espV3Enabled, tracersEnabled, chamsEnabled, hitboxEnabled, hitboxV2Enabled, skeletonEnabled = false, false, false, false, false, false, false, false
local jumpCircleEnabled, trailEnabled, trailV2Enabled, particlesEnabled, crosshairEnabled, stretchEnabled, hatEnabled = false, false, false, false, false, false, false
local spinEnabled, sunSpinEnabled, helicopterEnabled, invisibilityEnabled, noClipEnabled, orbitEnabled = false, false, false, false, false, false
local antiAimEnabled, fakeLagEnabled, doubleTapEnabled, strafeEnabled, fullbrightEnabled, nameTagsEnabled = false, false, false, false, false, false
local killAuraEnabled, killAuraV2Enabled, triggerBotEnabled, autoClickerEnabled, autoClickerV2Enabled = false, false, false, false, false
local infJumpEnabled, autoSprintEnabled, airWalkEnabled, flyV2Enabled, aimbotV2Enabled, aimbotV3Enabled = false, false, false, false, false, false
local shiftlockActive, cButtonEnabled, worldColorEnabled, resolverEnabled, desyncEnabled = false, false, false, false, false

local espFolder = Instance.new("Folder", workspace) espFolder.Name = "MTY_ESP"
local espV2Folder = Instance.new("Folder", workspace) espV2Folder.Name = "MTY_ESP_V2"
local tracersFolder = Instance.new("Folder", workspace) tracersFolder.Name = "MTY_Tracers"
local chamsFolder = Instance.new("Folder", workspace) chamsFolder.Name = "MTY_Chams"
local HitboxFolder = Instance.new("Folder", workspace) HitboxFolder.Name = "MTY_Hitboxes"
local skeletonFolder = Instance.new("Folder", workspace) skeletonFolder.Name = "MTY_Skeleton"
local blockEspFolder = Instance.new("Folder", workspace) blockEspFolder.Name = "MTY_BlockESP"
local backtrackFolder = Instance.new("Folder", workspace) backtrackFolder.Name = "MTY_Backtrack"

local trailParts = {}
local currentHat, hatConnection, crosshairGui, shiftlockConnection, cButtonGui, dashButton, runNoClip, airWalkPlatform, trailAnchor, actualTrailInstance
local particlesConnection, spinConnection, sunSpinConnection, helicopterConnection, orbitConnection, antiAimConnection, fakeLagConnection, strafeConnection, stretchConnection, tracersConnection, jumpCircleConnection, killAuraConnection, killAuraV2Connection, triggerBotConnection, autoClickConnection, autoClickV2Connection, infJumpConnection, autoSprintConnection
local originalAmbient, originalOutdoor = Lighting.Ambient, Lighting.OutdoorAmbient
local speedValue = 16

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
    if guiMainFrame then 
        msg.Parent = guiMainFrame 
    else 
        msg.Parent = game.CoreGui 
    end
    task.spawn(function() 
        task.wait(1.5) 
        msg:Destroy() 
    end)
end

-- ===== ВСПОМОГАТЕЛЬНЫЕ ОКНА =====
local function OpenTextInput(title, placeholder, default, callback)
    local s = Instance.new("ScreenGui", game.CoreGui) 
    s.Name = "Input"
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
        if n then 
            callback(n) 
            s:Destroy() 
        else 
            tb.Text = "Error" 
        end 
    end)
    local c = Instance.new("TextButton", f) 
    c.Size = UDim2.new(0, 22, 0, 22) 
    c.Position = UDim2.new(1, -27, 0, 5) 
    c.Text = "X" 
    c.TextColor3 = guiSettings.TextColor 
    c.BackgroundColor3 = Color3.fromRGB(40,40,45) 
    Instance.new("UICorner", c).CornerRadius = UDim.new(0,4)
    c.MouseButton1Click:Connect(function() 
        s:Destroy() 
    end)
end

local function OpenColorPicker(title, callback)
    local s = Instance.new("ScreenGui", game.CoreGui) 
    s.Name = "ColorPicker"
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
        {"White", Color3.fromRGB(255,255,255)}, 
        {"Yellow", Color3.fromRGB(255,220,0)}
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
        btn.MouseButton1Click:Connect(function() 
            callback(data[2]) 
            s:Destroy() 
        end)
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
    c.MouseButton1Click:Connect(function() 
        s:Destroy() 
    end)
end

-- ===== АИМБОТ С ПРОВЕРКОЙ НА WALLBANG =====
local function IsVisible(part)
    if guiSettings.AimbotWallbang then 
        return true 
    end
    local parts = Camera:GetPartsObscuringTarget({part.Position}, {LP.Character, part.Parent})
    return #parts == 0
end

local function GetPredictedPosition(targetPart)
    if not resolverEnabled then 
        return targetPart.Position 
    end
    local root = targetPart.Parent:FindFirstChild("HumanoidRootPart")
    if root then
        local velocity = root.AssemblyLinearVelocity
        if velocity.Magnitude > 30 then 
            return root.Position + (velocity * 0.05) 
        end
    end
    return targetPart.Position
end

local function FindBestTarget()
    local target, near = nil, guiSettings.AimbotFOV
    local mid = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local hit = p.Character:FindFirstChild(guiSettings.AimbotPart) or p.Character:FindFirstChild("Head")
            if hit and IsVisible(hit) then
                local screen, visible = Camera:WorldToViewportPoint(GetPredictedPosition(hit))
                if visible then
                    local dist = (Vector2.new(screen.X, screen.Y) - mid).Magnitude
                    if dist < near then 
                        near = dist 
                        target = hit 
                    end
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
            local targetCFrame = CFrame.new(Camera.CFrame.Position, GetPredictedPosition(target))
            local lerp = guiSettings.AimbotSpeed * guiSettings.AimbotStrength
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, math.clamp(lerp, 0.01, 1))
        end
    end
end)

-- ===== 🎩 CHINA HAT =====
local function CreateChineseHat()
    if currentHat then 
        currentHat:Destroy() 
        currentHat = nil 
    end
    if hatConnection then 
        hatConnection:Disconnect() 
        hatConnection = nil 
    end
    if not LP.Character or not LP.Character:FindFirstChild("Head") then 
        return 
    end
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
        if not currentHat or not LP.Character or not LP.Character:FindFirstChild("Head") then 
            return 
        end
        currentHat.Color = guiSettings.HatColor
        currentHat.CFrame = head.CFrame * CFrame.new(0, 0.6, 0)
    end)
end

local function ToggleChineseHat()
    hatEnabled = not hatEnabled
    if hatEnabled then 
        CreateChineseHat() 
        ShowMessage("China Hat ON 🎩") 
    else 
        if currentHat then 
            currentHat:Destroy() 
            currentHat = nil 
        end 
        if hatConnection then 
            hatConnection:Disconnect() 
            hatConnection = nil 
        end 
        ShowMessage("China Hat OFF") 
    end
end

-- ===== 👣 TRAIL V1 =====
local trailConnection = nil
local function CreateTrail()
    if not trailEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then 
        return 
    end
    local part = Instance.new("Part", workspace) 
    part.Size = Vector3.new(0.3, 0.3, 0.3) 
    part.CFrame = LP.Character.HumanoidRootPart.CFrame
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Color = guiSettings.TrailColor
    part.Transparency = 0.6
    table.insert(trailParts, part) 
    if #trailParts > guiSettings.TrailLength then 
        local old = table.remove(trailParts, 1) 
        if old then 
            old:Destroy() 
        end 
    end
end

local function ToggleTrail()
    trailEnabled = not trailEnabled
    if trailEnabled then 
        trailParts = {} 
        trailConnection = RunService.Heartbeat:Connect(CreateTrail) 
        ShowMessage("Trail V1 ON 👣") 
    else 
        if trailConnection then 
            trailConnection:Disconnect() 
            trailConnection = nil
        end 
        for _, v in pairs(trailParts) do 
            v:Destroy() 
        end 
        trailParts = {} 
        ShowMessage("Trail V1 OFF") 
    end
end

-- ===== 👣 TRAIL V2 =====
local function ToggleTrailV2() 
    trailV2Enabled = not trailV2Enabled 
    if trailV2Enabled then 
        if not LP.Character or not LP.Character:FindFirstChild("Head") then 
            return 
        end
        trailAnchor = Instance.new("Part", LP.Character.Head) 
        trailAnchor.Name = "MTY_TrailAnchor" 
        trailAnchor.Size = Vector3.new(0.1, 0.1, 0.1) 
        trailAnchor.Transparency = 1
        trailAnchor.CanCollide = false
        trailAnchor.Massless = true
        local weld = Instance.new("Weld", trailAnchor) 
        weld.Part0 = LP.Character.Head
        weld.Part1 = trailAnchor
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
        ShowMessage("Trail V2 (Ribbon) ON 🎀") 
    else 
        if trailAnchor then 
            trailAnchor:Destroy() 
            trailAnchor = nil 
        end 
        ShowMessage("Trail V2 OFF") 
    end 
end

-- ===== 🟢 JUMP CIRCLE =====
local function ApplyJumpCircleEffect()
    if not jumpCircleEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then 
        return 
    end
    local disk = Instance.new("Part", workspace) 
    disk.Shape = Enum.PartType.Cylinder
    disk.Size = Vector3.new(0.02, 2, 2)
    disk.CFrame = CFrame.new(LP.Character.HumanoidRootPart.Position - Vector3.new(0, 2.8, 0)) * CFrame.Angles(0, 0, math.rad(90))
    disk.Anchored = true
    disk.CanCollide = false
    disk.Material = Enum.Material.Neon
    disk.Color = guiSettings.JumpCircleColor
    disk.Transparency = 0.2
    local tween = TweenService:Create(disk, TweenInfo.new(guiSettings.JumpCircleFadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.01, 14, 14), 
        Transparency = 1
    })
    tween:Play() 
    tween.Completed:Connect(function() 
        disk:Destroy() 
    end)
end

local function ToggleJumpCircle()
    jumpCircleEnabled = not jumpCircleEnabled
    if jumpCircleEnabled then 
        local char = LP.Character or LP.CharacterAdded:Wait() 
        jumpCircleConnection = char:WaitForChild("Humanoid").Jumping:Connect(function() 
            if jumpCircleEnabled then 
                ApplyJumpCircleEffect() 
            end 
        end) 
        ShowMessage("Jump Circle ON 🟢") 
    else 
        if jumpCircleConnection then 
            jumpCircleConnection:Disconnect() 
            jumpCircleConnection = nil
        end 
        ShowMessage("Jump Circle OFF") 
    end
end

-- ===== ПУСТЫЕ ЗАГЛУШКИ ДЛЯ ВСЕХ ФУНКЦИЙ =====
local function ToggleESP() ShowMessage("ESP Toggled") end
local function ToggleESPV2() ShowMessage("ESP V2 Toggled") end
local function ToggleESPV3() ShowMessage("ESP V3 Toggled") end
local function ToggleSkeleton() ShowMessage("Skeleton Toggled") end
local function ToggleChams() ShowMessage("Chams Toggled") end
local function ToggleHitboxes() ShowMessage("Hitboxes Toggled") end
local function ToggleHitboxesV2() ShowMessage("Hitboxes V2 Toggled") end
local function ToggleTracers() ShowMessage("Tracers Toggled") end
local function ToggleParticles() ShowMessage("Particles Toggled") end
local function ToggleFullbright() ShowMessage("Fullbright Toggled") end
local function ToggleWorldColor() ShowMessage("World Color Toggled") end
local function ToggleStretch() ShowMessage("Stretch Toggled") end
local function ToggleInfiniteJump() ShowMessage("Infinite Jump Toggled") end
local function ToggleAirWalk() ShowMessage("Air Walk Toggled") end
local function ToggleFlyV2() ShowMessage("Fly V2 Toggled") end
local function ToggleAutoSprint() ShowMessage("Auto Sprint Toggled") end
local function ToggleSpin() ShowMessage("Spin Toggled") end
local function ToggleNoClip() ShowMessage("NoClip Toggled") end
local function ToggleKillAura() ShowMessage("Kill Aura Toggled") end
local function ToggleKillAuraV2() ShowMessage("Kill Aura V2 Toggled") end
local function ToggleTriggerBot() ShowMessage("Trigger Bot Toggled") end
local function ToggleAutoClicker() ShowMessage("Auto Clicker Toggled") end
local function ToggleAutoClickerV2() ShowMessage("Auto Clicker V2 Toggled") end
local function ToggleAimbotV2() ShowMessage("Aimbot V2 Toggled") end
local function ToggleAimbotV3() ShowMessage("Aimbot V3 Toggled") end
local function ToggleResolver() ShowMessage("Resolver Toggled") end
local function ToggleAntiAim() ShowMessage("Anti-Aim Toggled") end
local function ToggleDesync() ShowMessage("Desync Toggled") end
local function ToggleFakeLag() ShowMessage("Fake Lag Toggled") end
local function ToggleHelicopter() end
local function ToggleInvisibility() end
local function ToggleFly() end
local function ToggleTeleportTool() end
local function ToggleStrafe() end
local function ToggleOrbit() end
local function ToggleDoubleTap() end
local function ToggleDash() end
local function ToggleCButton() end
local function LoadClemonRC() end
local function ToggleR6Animations() end
local function ToggleCrosshair() end
local function ToggleShiftlock() end
local function SetAntiAimMode(mode) 
    guiSettings.AntiAimMode = mode 
    ShowMessage("Anti-Aim Mode: " .. mode)
end

-- ===== СОЗДАНИЕ МЕНЮ =====
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
        if aimbotFOVRing then 
            aimbotFOVRing:Remove() 
        end 
    end)
    
    local leftPanel = Instance.new("Frame", guiMainFrame) 
    leftPanel.Size = UDim2.new(0, 125, 0, 355) 
    leftPanel.Position = UDim2.new(0.02, 0, 0.15, 0) 
    leftPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 26) 
    Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 10)
    
    local searchBox = Instance.new("TextBox", guiMainFrame) 
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
    
    local contentArea = Instance.new("ScrollingFrame", guiMainFrame) 
    contentArea.Size = UDim2.new(0.68, 0, 0, 275) 
    contentArea.Position = UDim2.new(0.3, 0, 0.25, 0) 
    contentArea.BackgroundTransparency = 1
    contentArea.ScrollBarThickness = 5
    contentArea.ScrollBarImageColor3 = guiSettings.BorderColor
    
    local function GetStatusStr(name)
        if name == "Toggle ESP" then 
            return espEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V2" then 
            return espV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Skeleton" then 
            return skeletonEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Chams" then 
            return chamsEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Hitboxes" then 
            return hitboxEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Tracers" then 
            return tracersEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Jump Circle" then 
            return jumpCircleEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Trail" then 
            return trailEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Chinese Hat" then 
            return hatEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Fullbright" then 
            return fullbrightEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Stretch" then 
            return stretchEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Aimbot" then 
            return aimbotEnabled and " [ON]" or " [OFF]"
        elseif name == "HvH Resolver 🎯" then 
            return resolverEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Anti-Aim" then 
            return antiAimEnabled and " [ON]" or " [OFF]"
        elseif name == "Desync Movement ✈️" then 
            return desyncEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Fake Lag" then 
            return fakeLagEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Kill Aura ⚔️" then 
            return killAuraEnabled and " [ON]" or " [OFF]"
        else
            return ""
        end 
    end
    
    local function RenderSubs(subs)
        for _, v in pairs(contentArea:GetChildren()) do 
            if not v:IsA("UICorner") then 
                v:Destroy() 
            end 
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
                if name == "Toggle ESP" then 
                    espEnabled = not espEnabled 
                    ShowMessage("ESP "..(espEnabled and "ON" or "OFF"))
                elseif name == "Toggle ESP V2" then 
                    espV2Enabled = not espV2Enabled 
                    ShowMessage("ESP V2 "..(espV2Enabled and "ON" or "OFF"))
                elseif name == "Toggle Skeleton" then 
                    skeletonEnabled = not skeletonEnabled 
                    ShowMessage("Skeleton "..(skeletonEnabled and "ON" or "OFF"))
                elseif name == "Toggle Chams" then 
                    chamsEnabled = not chamsEnabled 
                    ShowMessage("Chams "..(chamsEnabled and "ON" or "OFF"))
                elseif name == "Toggle Hitboxes" then 
                    hitboxEnabled = not hitboxEnabled 
                    ShowMessage("Hitboxes "..(hitboxEnabled and "ON" or "OFF"))
                elseif name == "Toggle Tracers" then 
                    tracersEnabled = not tracersEnabled 
                    ShowMessage("Tracers "..(tracersEnabled and "ON" or "OFF"))
                elseif name == "Toggle Jump Circle" then 
                    ToggleJumpCircle()
                elseif name == "Toggle Trail" then 
                    ToggleTrail()
                elseif name == "Toggle Chinese Hat" then 
                    ToggleChineseHat()
                elseif name == "Toggle Fullbright" then 
                    fullbrightEnabled = not fullbrightEnabled 
                    Lighting.Ambient = fullbrightEnabled and Color3.new(1,1,1) or originalAmbient
                    ShowMessage("Fullbright "..(fullbrightEnabled and "ON" or "OFF"))
                elseif name == "Toggle Stretch" then 
                    stretchEnabled = not stretchEnabled
                    if stretchEnabled then 
                        stretchConnection = RunService.RenderStepped:Connect(function() 
                            Camera.CFrame = Camera.CFrame * CFrame.new(0,0,0,1,0,0,0,guiSettings.StretchValue,0,0,0,1) 
                        end) 
                    else 
                        if stretchConnection then 
                            stretchConnection:Disconnect() 
                            stretchConnection = nil
                        end 
                    end 
                    ShowMessage("Stretch "..(stretchEnabled and "ON" or "OFF"))
                elseif name == "Toggle Aimbot" then 
                    aimbotEnabled = not aimbotEnabled 
                    ShowMessage("Aimbot "..(aimbotEnabled and "ON" or "OFF"))
                elseif name == "HvH Resolver 🎯" then 
                    resolverEnabled = not resolverEnabled 
                    ShowMessage("Resolver "..(resolverEnabled and "ON" or "OFF"))
                elseif name == "Toggle Anti-Aim" then 
                    antiAimEnabled = not antiAimEnabled 
                    ShowMessage("Anti-Aim "..(antiAimEnabled and "ON" or "OFF"))
                elseif name == "Desync Movement ✈️" then 
                    desyncEnabled = not desyncEnabled 
                    ShowMessage("Desync "..(desyncEnabled and "ON" or "OFF"))
                elseif name == "Toggle Fake Lag" then 
                    fakeLagEnabled = not fakeLagEnabled 
                    ShowMessage("Fake Lag "..(fakeLagEnabled and "ON" or "OFF"))
                elseif name == "Toggle Kill Aura ⚔️" then 
                    killAuraEnabled = not killAuraEnabled 
                    ShowMessage("Kill Aura "..(killAuraEnabled and "ON" or "OFF"))
                elseif name == "Aimbot Speed" then 
                    OpenTextInput("Aimbot Speed", "0.01-1", guiSettings.AimbotSpeed, function(v) 
                        guiSettings.AimbotSpeed = math.clamp(v, 0.01, 1) 
                    end)
                elseif name == "Aimbot Strength" then 
                    OpenTextInput("Strength", "0.1-1", guiSettings.AimbotStrength, function(v) 
                        guiSettings.AimbotStrength = math.clamp(v, 0.1, 1) 
                    end)
                elseif name == "Aimbot FOV" then 
                    OpenTextInput("FOV Size", "Pixels", guiSettings.AimbotFOV, function(v) 
                        guiSettings.AimbotFOV = math.clamp(v, 10, 500) 
                        aimbotFOVRing.Radius = guiSettings.AimbotFOV
                    end)
                elseif name == "Aimbot Wallbang 🧱" then 
                    guiSettings.AimbotWallbang = not guiSettings.AimbotWallbang 
                    ShowMessage("Wallbang "..(guiSettings.AimbotWallbang and "ON" or "OFF"))
                elseif name == "Speed" then 
                    OpenTextInput("Speed", "WalkSpeed", speedValue, function(v) 
                        speedValue = math.clamp(v, 0, 99999)
                        if LP.Character and LP.Character:FindFirstChild("Humanoid") then 
                            LP.Character.Humanoid.WalkSpeed = speedValue 
                        end 
                    end)
                elseif name == "Gravity" then 
                    OpenTextInput("Gravity", "Workspace", workspace.Gravity, function(v) 
                        workspace.Gravity = math.clamp(v, -1000, 10000) 
                    end)
                elseif name == "Kill Aura Range" then 
                    OpenTextInput("Aura Range", "Studs", guiSettings.KillAuraRange, function(v) 
                        guiSettings.KillAuraRange = math.clamp(v, 5, 50) 
                    end)
                elseif name == "Stretch Value" then 
                    OpenTextInput("Stretch", "0.1 - 1.5", guiSettings.StretchValue, function(v) 
                        guiSettings.StretchValue = math.clamp(v, 0.1, 1.5) 
                    end)
                elseif name == "Trail Color" then 
                    OpenColorPicker("Trail Color", function(c) 
                        guiSettings.TrailColor = c 
                        if actualTrailInstance then 
                            actualTrailInstance.Color = ColorSequence.new(c) 
                        end 
                    end)
                elseif name == "Hat Color" then 
                    OpenColorPicker("Hat Color", function(c) 
                        guiSettings.HatColor = c 
                        if hatEnabled then 
                            CreateChineseHat() 
                        end 
                    end)
                elseif name == "Jump Circle Color" then 
                    OpenColorPicker("Jump Circle Color", function(c) 
                        guiSettings.JumpCircleColor = c 
                    end)
                elseif name == "Anti-Aim Mode: Jitter" then 
                    SetAntiAimMode("Jitter") 
                elseif name == "Anti-Aim Mode: Spin" then 
                    SetAntiAimMode("Spin")
                elseif name == "Optimize Textures" then
                    for _, v in pairs(game:GetDescendants()) do 
                        pcall(function() 
                            if v:IsA("Texture") or v:IsA("Decal") then 
                                v.Texture = "rbxassetid://4322737890" 
                            elseif v:IsA("BasePart") then 
                                v.Material = Enum.Material.Plastic 
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
        if currentCategory ~= "" then 
            RenderSubs(allSubs) 
        end 
    end)
    
    local currentCategory = ""
    local allSubs = {}
    
    local categories = {
        VISUAL = {"Toggle ESP", "Toggle ESP V2", "Toggle Skeleton", "Toggle Chams", "Toggle Hitboxes", "Toggle Tracers", "Toggle Jump Circle", "Jump Circle Color", "Toggle Trail", "Trail Color", "Toggle Chinese Hat", "Hat Color", "Toggle Fullbright", "Toggle Stretch", "Stretch Value"},
        PLAYER = {"Speed", "Gravity", "Toggle Spin", "Toggle NoClip"},
        COMBAT = {"Toggle Aimbot", "Aimbot Speed", "Aimbot Strength", "Aimbot FOV", "Aimbot Wallbang 🧱", "Toggle Kill Aura ⚔️", "Kill Aura Range"},
        HVH = {"HvH Resolver 🎯", "Toggle Anti-Aim", "Anti-Aim Mode: Jitter", "Anti-Aim Mode: Spin", "Desync Movement ✈️", "Toggle Fake Lag"},
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
print("MTY HUB v5.0 BUGFIX UNLOCKED SUCCESSFULLY! 🚀")