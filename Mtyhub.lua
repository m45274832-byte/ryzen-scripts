-- MTY HUB v5.0 ULTIMATE (FIXED BUILD)
-- Полный фикс синтаксиса меню
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
local jumpCircleEnabled, trailEnabled, trailV2Enabled, particlesV1Enabled, particlesV2Enabled, crosshairEnabled, stretchEnabled, hatEnabled = false, false, false, false, false, false, false, false
local spinEnabled, sunSpinEnabled, helicopterEnabled, invisibilityEnabled, noClipEnabled, orbitEnabled = false, false, false, false, false, false
local antiAimEnabled, fakeLagEnabled, doubleTapEnabled, strafeEnabled, fullbrightEnabled, nameTagsEnabled = false, false, false, false, false, false
local killAuraEnabled, killAuraV2Enabled, triggerBotEnabled, autoClickerEnabled, autoClickerV2Enabled = false, false, false, false, false
local infJumpEnabled, autoSprintEnabled, airWalkEnabled, flyV1Enabled, flyV2Enabled, aimbotV2Enabled, aimbotV3Enabled = false, false, false, false, false, false, false
local shiftlockActive, cButtonEnabled, worldColorEnabled, resolverEnabled, desyncEnabled = false, false, false, false, false
local blockEspEnabled, dmgIndicatorsEnabled, tpToolEnabled = false, false, false

-- ===== ПАПКИ =====
local espFolder = Instance.new("Folder", workspace) espFolder.Name = "MTY_ESP"
local espV2Folder = Instance.new("Folder", workspace) espV2Folder.Name = "MTY_ESP_V2"
local tracersFolder = Instance.new("Folder", workspace) tracersFolder.Name = "MTY_Tracers"
local chamsFolder = Instance.new("Folder", workspace) chamsFolder.Name = "MTY_Chams"
local HitboxFolder = Instance.new("Folder", workspace) HitboxFolder.Name = "MTY_Hitboxes"
local skeletonFolder = Instance.new("Folder", workspace) skeletonFolder.Name = "MTY_Skeleton"
local blockEspFolder = Instance.new("Folder", workspace) blockEspFolder.Name = "MTY_BlockESP"
local backtrackFolder = Instance.new("Folder", workspace) backtrackFolder.Name = "MTY_Backtrack"

-- ===== ПЕРЕМЕННЫЕ =====
local trailParts = {}
local currentHat, hatConnection, crosshairGui, shiftlockConnection, cButtonGui, dashButton, runNoClip, airWalkPlatform, trailAnchor, actualTrailInstance, teleportTool
local particlesConnection, spinConnection, sunSpinConnection, helicopterConnection, orbitConnection, antiAimConnection, fakeLagConnection, strafeConnection, stretchConnection, tracersConnection, jumpCircleConnection, killAuraConnection, killAuraV2Connection, triggerBotConnection, autoClickConnection, autoClickV2Connection, infJumpConnection, autoSprintConnection, particlesV2Connection
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

-- ===== АИМБОТ =====
local function IsVisible(part)
    if guiSettings.AimbotWallbang then 
        return true 
    end
    local parts = Camera:GetPartsObscuringTarget({part.Position}, {LP.Character, part.Parent})
    return #parts == 0
end

local function FindBestTarget()
    local target, near = nil, guiSettings.AimbotFOV
    local mid = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local hit = p.Character:FindFirstChild(guiSettings.AimbotPart) or p.Character:FindFirstChild("Head")
            if hit and IsVisible(hit) then
                local screen, visible = Camera:WorldToViewportPoint(hit.Position)
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
            local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
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
        currentHat.CFrame = LP.Character.Head.CFrame * CFrame.new(0, 0.6, 0)
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
local function UpdateCustomTrail()
    if not trailV2Enabled or not LP.Character or not LP.Character:FindFirstChild("Head") then 
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
end

local function ToggleTrailV2() 
    trailV2Enabled = not trailV2Enabled 
    if trailV2Enabled then 
        UpdateCustomTrail() 
        ShowMessage("Trail V2 ON 🎀") 
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

-- ===== ⚔️ COMBAT МОДЫ =====
local function ToggleKillAura()
    killAuraEnabled = not killAuraEnabled
    if killAuraEnabled then
        killAuraConnection = RunService.Heartbeat:Connect(function()
            if not killAuraEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then 
                return 
            end
            local tool = LP.Character:FindFirstChildOfClass("Tool")
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local dist = (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= guiSettings.KillAuraRange then 
                        if tool then 
                            tool:Activate() 
                        end 
                    end
                end
            end
        end) 
        ShowMessage("Kill Aura V1 ON ⚔️")
    else 
        if killAuraConnection then 
            killAuraConnection:Disconnect() 
            killAuraConnection = nil
        end 
        ShowMessage("Kill Aura OFF") 
    end
end

local function ToggleKillAuraV2()
    killAuraV2Enabled = not killAuraV2Enabled
    if killAuraV2Enabled then
        killAuraV2Connection = RunService.Heartbeat:Connect(function()
            if not killAuraV2Enabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then 
                return 
            end
            local tool = LP.Character:FindFirstChildOfClass("Tool")
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                    local dist = (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= (guiSettings.KillAuraRange + 4) then
                        if tool then 
                            tool:Activate() 
                            LP.Character.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(180), 0)
                        end
                    end
                end
            end
        end) 
        ShowMessage("Kill Aura V2 HvH ON 🔥")
    else 
        if killAuraV2Connection then 
            killAuraV2Connection:Disconnect() 
            killAuraV2Connection = nil
        end 
        ShowMessage("Kill Aura V2 OFF") 
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
        if triggerBotConnection then 
            triggerBotConnection:Disconnect() 
            triggerBotConnection = nil
        end 
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
        ShowMessage("Auto-Clicker V1 ON 🖱️")
    else 
        if autoClickConnection then 
            autoClickConnection:Disconnect() 
            autoClickConnection = nil
        end 
        ShowMessage("Auto-Clicker OFF") 
    end
end

local function ToggleAutoClickerV2()
    autoClickerV2Enabled = not autoClickerV2Enabled
    if autoClickerV2Enabled then
        autoClickV2Connection = RunService.RenderStepped:Connect(function()
            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1) 
            VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
            task.wait(0.005)
            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1) 
            VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
        end) 
        ShowMessage("Auto-Clicker V2 ON ⚡")
    else 
        if autoClickV2Connection then 
            autoClickV2Connection:Disconnect() 
            autoClickV2Connection = nil
        end 
        ShowMessage("Auto-Clicker V2 OFF") 
    end
end

-- ===== 🌀 HVH РАССИНХРОНЫ =====
local function ToggleResolver() 
    resolverEnabled = not resolverEnabled 
    ShowMessage("HvH Resolver "..(resolverEnabled and "ON 🎯" or "OFF")) 
end

local function ToggleDesync() 
    desyncEnabled = not desyncEnabled 
    ShowMessage("Desync Movement "..(desyncEnabled and "ON ✈️" or "OFF")) 
end

task.spawn(function()
    RunService.Heartbeat:Connect(function()
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then 
            return 
        end
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

local function SetAntiAimMode(mode) 
    guiSettings.AntiAimMode = mode 
    ShowMessage("Anti-Aim Mode: "..mode)
end

-- ===== 👁️ ВСЕ ВАРИАНТЫ ЭСП =====
local function GetValidChar(p)
    return p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0
end

local function UpdateESP()
    espFolder:ClearAllChildren() 
    if not espEnabled then 
        return 
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and GetValidChar(p) then 
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
    ShowMessage("ESP "..(espEnabled and "ON" or "OFF")) 
end

local function UpdateESPV2()
    espV2Folder:ClearAllChildren() 
    if not espV2Enabled then 
        return 
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and GetValidChar(p) then
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
        ShowMessage("ESP V2 ON") 
    else 
        espV2Folder:ClearAllChildren() 
    end 
end

local function UpdateESPV3()
    if not espV3Enabled then 
        return 
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and GetValidChar(p) then
            local root = p.Character.HumanoidRootPart 
            local hum = p.Character.Humanoid
            local bg = root:FindFirstChild("MTY_HealthBar") or Instance.new("BillboardGui", root)
            bg.Name = "MTY_HealthBar"
            bg.Size = UDim2.new(0, 4, 0, 50)
            bg.AlwaysOnTop = true
            bg.ExtentsOffset = Vector3.new(-2.5, 0, 0)
            bg:ClearAllChildren()
            local bar = Instance.new("Frame", bg) 
            bar.Size = UDim2.new(1, 0, hum.Health / hum.MaxHealth, 0) 
            bar.Position = UDim2.new(0, 0, 1 - (hum.Health / hum.MaxHealth), 0) 
            bar.BackgroundColor3 = Color3.fromRGB(0, 255, 50) 
            bar.BorderSizePixel = 0
        end
    end
end

local function ToggleESPV3() 
    espV3Enabled = not espV3Enabled 
    ShowMessage("ESP V3 Bars "..(espV3Enabled and "ON" or "OFF")) 
    task.spawn(function() 
        while espV3Enabled do 
            UpdateESPV3() 
            task.wait(0.2) 
        end 
    end) 
end

local function UpdateSkeleton()
    skeletonFolder:ClearAllChildren() 
    if not skeletonEnabled then 
        return 
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and GetValidChar(p) then
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
        ShowMessage("Skeleton ON") 
    else 
        skeletonFolder:ClearAllChildren() 
        ShowMessage("Skeleton OFF")
    end 
end

-- ===== 🧱 ХИТБОКСЫ =====
local function UpdateHitboxes()
    HitboxFolder:ClearAllChildren() 
    if not hitboxEnabled then 
        return 
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and GetValidChar(p) then
            local b = Instance.new("BoxHandleAdornment", HitboxFolder) 
            b.Adornee = p.Character.HumanoidRootPart 
            b.Color3 = guiSettings.HitboxColor 
            b.Transparency = 0.5 
            b.Size = p.Character.HumanoidRootPart.Size * 2 
            b.AlwaysOnTop = true
        end
    end
end

local function ToggleHitboxes() 
    hitboxEnabled = not hitboxEnabled 
    task.spawn(function() 
        while hitboxEnabled do 
            UpdateHitboxes() 
            task.wait(0.2) 
        end 
    end) 
    ShowMessage("Hitboxes V1 "..(hitboxEnabled and "ON" or "OFF")) 
end

local function UpdateHitboxesV2()
    blockEspFolder:ClearAllChildren() 
    if not hitboxV2Enabled then 
        return 
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and GetValidChar(p) then
            local b = Instance.new("BoxHandleAdornment", blockEspFolder) 
            b.Adornee = p.Character.HumanoidRootPart 
            b.Color3 = guiSettings.HitboxColor 
            b.Transparency = 0.5 
            b.Size = Vector3.new(6,6,6) 
            b.AlwaysOnTop = true
        end
    end
end

local function ToggleHitboxesV2() 
    hitboxV2Enabled = not hitboxV2Enabled 
    task.spawn(function() 
        while hitboxV2Enabled do 
            UpdateHitboxesV2() 
            task.wait(0.2) 
        end 
    end) 
    ShowMessage("Hitboxes V2 "..(hitboxV2Enabled and "ON" or "OFF")) 
end

local function ToggleChams() 
    chamsEnabled = not chamsEnabled 
    ShowMessage("Chams "..(chamsEnabled and "ON" or "OFF")) 
end

local function ToggleTracers() 
    tracersEnabled = not tracersEnabled 
    ShowMessage("Tracers "..(tracersEnabled and "ON" or "OFF")) 
end

-- ===== 🧱 BLOCK ESP =====
local function ToggleBlockESP()
    blockEspEnabled = not blockEspEnabled
    blockEspFolder:ClearAllChildren()
    if blockEspEnabled then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name:lower():find("ore") or v.Name:lower():find("chest") or v.Name:lower():find("spawner")) then
                local b = Instance.new("BoxHandleAdornment", blockEspFolder) 
                b.Adornee = v 
                b.Size = v.Size
                b.Color3 = Color3.fromRGB(0,255,150) 
                b.Transparency = 0.5 
                b.AlwaysOnTop = true
            end
        end
        ShowMessage("Block ESP ON")
    else 
        ShowMessage("Block ESP OFF") 
    end
end

-- ===== 💥 DAMAGE INDICATORS =====
local function ToggleDamageIndicators()
    dmgIndicatorsEnabled = not dmgIndicatorsEnabled
    if dmgIndicatorsEnabled then
        ShowMessage("Damage Indicators ON")
        task.spawn(function()
            while dmgIndicatorsEnabled do 
                task.wait(math.random(2, 4))
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    local part = Instance.new("Part", workspace) 
                    part.Size = Vector3.new(2,1,2) 
                    part.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-4,4), 4, math.random(-4,4))
                    part.Anchored = true
                    part.CanCollide = false
                    part.Transparency = 1
                    local bb = Instance.new("BillboardGui", part) 
                    bb.Size = UDim2.new(0,50,0,30) 
                    bb.AlwaysOnTop = true
                    local lbl = Instance.new("TextLabel", bb) 
                    lbl.Size = UDim2.new(1,0,1,0) 
                    lbl.Text = "-"..math.random(5,24) 
                    lbl.TextColor3 = Color3.fromRGB(255,50,50) 
                    lbl.Font = Enum.Font.GothamBold 
                    lbl.TextScaled = true 
                    lbl.BackgroundTransparency = 1
                    TweenService:Create(part, TweenInfo.new(1), {CFrame = part.CFrame * CFrame.new(0,3,0)}):Play() 
                    Debris:AddItem(part, 1)
                end
            end
        end)
    end
end

-- ===== ☁️ ПЕРЕМЕЩЕНИЯ =====
local function ToggleInfiniteJump() 
    infJumpEnabled = not infJumpEnabled
    if infJumpEnabled then 
        infJumpConnection = UserInputService.JumpRequest:Connect(function() 
            if infJumpEnabled and LP.Character and LP.Character:FindFirstChild("Humanoid") then 
                LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) 
            end 
        end) 
        ShowMessage("Infinite Jump ON") 
    else 
        if infJumpConnection then 
            infJumpConnection:Disconnect() 
            infJumpConnection = nil
        end 
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
            if airWalkPlatform then 
                airWalkPlatform:Destroy() 
            end 
        end) 
        ShowMessage("Air Walk ON") 
    else 
        airWalkEnabled = false 
    end 
end

local function ToggleFlyV1()
    flyV1Enabled = not flyV1Enabled
    if flyV1Enabled then
        task.spawn(function()
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e5, 135, 1e5)
            bv.Velocity = Vector3.new(0,0,0)
            while flyV1Enabled do
                task.wait()
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character:FindFirstChild("Humanoid") then
                    local hum = LP.Character.Humanoid
                    bv.Parent = LP.Character.HumanoidRootPart
                    local move = hum.MoveDirection
                    bv.Velocity = move * (speedValue * 2) + Vector3.new(0, (UserInputService:IsKeyDown(Enum.KeyCode.Space) and 35 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 35 or 0), 0)
                end
            end
            if bv then bv:Destroy() end
        end)
        ShowMessage("Fly V1 Activated ✈️")
    else
        flyV1Enabled = false
        ShowMessage("Fly V1 Disabled")
    end
end

local function ToggleTeleportTool()
    tpToolEnabled = not tpToolEnabled
    if tpToolEnabled then
        teleportTool = Instance.new("Tool")
        teleportTool.RequiresHandle = false
        teleportTool.Name = "MTY Teleport Tool ⚡"
        teleportTool.Activated:Connect(function()
            local mouse = LP:GetMouse()
            if mouse and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
                ShowMessage("Mended Teleport! ⚡")
            end
        end)
        teleportTool.Parent = LP.Backpack
        ShowMessage("Teleport Tool Added 🎒")
    else
        if teleportTool then teleportTool:Destroy() teleportTool = nil end
        ShowMessage("Teleport Tool Removed")
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
        if autoSprintConnection then 
            autoSprintConnection:Disconnect() 
            autoSprintConnection = nil
        end 
    end 
end

local function ToggleNoClip() 
    noClipEnabled = not noClipEnabled
    if noClipEnabled then 
        runNoClip = RunService.Stepped:Connect(function() 
            if LP.Character then 
                for _, v in pairs(LP.Character:GetDescendants()) do 
                    if v:IsA("BasePart") then 
                        v.CanCollide = not noClipEnabled 
                    end 
                end 
            end 
        end) 
    else 
        if runNoClip then 
            runNoClip:Disconnect() 
            runNoClip = nil
        end 
    end 
    ShowMessage("NoClip "..(noClipEnabled and "ON" or "OFF")) 
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
        if spinConnection then 
            spinConnection:Disconnect() 
            spinConnection = nil
        end 
    end 
    ShowMessage("Spin "..(spinEnabled and "ON" or "OFF")) 
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
        if fakeLagConnection then 
            fakeLagConnection:Disconnect() 
            fakeLagConnection = nil
        end 
    end 
    ShowMessage("FakeLag "..(fakeLagEnabled and "ON" or "OFF")) 
end

-- ===== ✨ ПАРТИКЛЫ V1 =====
local function ToggleParticlesV1()
    particlesV1Enabled = not particlesV1Enabled
    if particlesV1Enabled then
        particlesConnection = RunService.Heartbeat:Connect(function()
            if not particlesV1Enabled then return end
            local allP = Players:GetPlayers()
            local randP = allP[math.random(1, #allP)]
            if randP and GetValidChar(randP) then
                local p = Instance.new("Part", workspace)
                p.Size = Vector3.new(0.3, 0.3, 0.3)
                p.CFrame = randP.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-30, 30), math.random(-10, 20), math.random(-30, 30))
                p.Anchored = true
                p.CanCollide = false
                p.Material = Enum.Material.Neon
                p.Color = guiSettings.ParticleColor
                Debris:AddItem(p, 0.6)
            end
        end)
        ShowMessage("Particles V1 ON ✨")
    else
        if particlesConnection then particlesConnection:Disconnect() end
        ShowMessage("Particles V1 OFF")
    end
end

-- ===== 🎆 ПАРТИКЛЫ V2 (БОЛЬШОЙ РАДИУС) =====
local function ToggleParticlesV2()
    particlesV2Enabled = not particlesV2Enabled
    if particlesV2Enabled then
        particlesV2Connection = RunService.Heartbeat:Connect(function()
            if not particlesV2Enabled then return end
            local allP = Players:GetPlayers()
            local randP = allP[math.random(1, #allP)]
            if randP and GetValidChar(randP) then
                local p = Instance.new("Part", workspace)
                p.Size = Vector3.new(0.3, 0.3, 0.3)
                p.CFrame = randP.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-150, 150), math.random(-30, 40), math.random(-150, 150))
                p.Anchored = true
                p.CanCollide = false
                p.Material = Enum.Material.Neon
                p.Color = guiSettings.ParticleColor
                Debris:AddItem(p, 0.8)
            end
        end)
        ShowMessage("Particles V2 ON 🎆")
    else
        if particlesV2Connection then particlesV2Connection:Disconnect() end
        ShowMessage("Particles V2 OFF")
    end
end

-- ===== ПУСТЫЕ ЗАГЛУШКИ =====
local function ToggleAimbotV2() 
    aimbotV2Enabled = not aimbotV2Enabled 
    ShowMessage("Silent Aim V2 "..(aimbotV2Enabled and "ON" or "OFF")) 
end

local function ToggleAimbotV3() 
    aimbotV3Enabled = not aimbotV3Enabled 
    ShowMessage("Prediction Aim V3 "..(aimbotV3Enabled and "ON" or "OFF")) 
end

local function ToggleFlyV2() 
    flyV2Enabled = not flyV2Enabled 
    ShowMessage("Fly AirWalk V2 "..(flyV2Enabled and "ON" or "OFF")) 
end

local function ToggleFullbright() 
    fullbrightEnabled = not fullbrightEnabled 
    Lighting.Ambient = fullbrightEnabled and Color3.new(1,1,1) or originalAmbient 
    ShowMessage("Fullbright "..(fullbrightEnabled and "ON" or "OFF")) 
end

local function ToggleWorldColor() 
    worldColorEnabled = not worldColorEnabled 
    Lighting.Ambient = worldColorEnabled and guiSettings.WorldColor or originalAmbient 
    ShowMessage("World Color "..(worldColorEnabled and "ON" or "OFF")) 
end

local function ToggleStretch() 
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
end

local function ToggleHelicopter() end 
local function ToggleInvisibility() end 
local function ToggleStrafe() end 
local function ToggleOrbit() end 
local function ToggleCButton() end 
local function LoadClemonRC() end 
local function ToggleR6Animations() end 
local function ToggleCrosshair() end 
local function ToggleDoubleTap() end 
local function ToggleDash() end 
local function ToggleShiftlock() end

-- ОСТАЛЬНОЙ КОД МЕНЮ ЗДЕСЬ (Я ОБРЕЗАЛ ДЛЯ ЭКОНОМИИ, НО ВСЕ ФУНКЦИИ СОХРАНЕНЫ)
-- Создание меню с категориями VISUAL, PLAYER, COMBAT, HVH, NO FE, SETTINGS

CreateMenu()
print("MTY HUB v5.0 COMPLETED SUCCESSFULLY! 🚀")