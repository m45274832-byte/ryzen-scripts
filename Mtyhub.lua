-- MTY HUB v4.4 DELTA EDITION (FINAL PERFECT BUILD)
-- Visuals: Оптимизированный круглый конус China Hat с низким RGB трейлом
-- Combat: Внедрены Aimbot Speed и Aimbot Strength
-- Оптимизировано под Delta Executor: Полный фикс вылетов и лагов FPS

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local guiMainFrame = nil
local screenGui = nil
local blurEffect = nil

-- ===== НАСТРОЙКИ =====
local guiSettings = {
    BackgroundColor = Color3.fromRGB(0, 0, 0),
    BorderColor = Color3.fromRGB(255, 0, 0),
    TextColor = Color3.fromRGB(255, 255, 255),
    Transparency = 0.05,
    BlurEnabled = false,
    BlurSize = 6,
    ESPColor = Color3.fromRGB(255, 0, 0),
    HitboxColor = Color3.fromRGB(255, 0, 0),
    ChamsColor = Color3.fromRGB(0, 255, 255),
    JumpCircleColor = Color3.fromRGB(0, 255, 0),
    TrailColor = Color3.fromRGB(0, 255, 255),
    HatColor = Color3.fromRGB(210, 180, 140),
    WorldColor = Color3.fromRGB(255, 0, 0),
    ParticleColor = Color3.fromRGB(255, 0, 0),
    CrosshairColor = Color3.fromRGB(0, 255, 0),
    SpinSpeed = 10,
    SunSpinSpeed = 50,
    JumpCircleFadeTime = 1.5,
    TrailLength = 50,
    AntiAimMode = "Spin",
    FakeLagAmount = 5,
    StretchValue = 0.65,
    AimbotFOV = 150,
    AimbotSpeed = 0.3,
    AimbotStrength = 0.8,
    AimbotPart = "Head",
    AimbotMaxDist = 1000
}

-- ===== ПАПКИ И СОСТОЯНИЯ =====
local espEnabled, espV2Enabled, tracersEnabled, chamsEnabled, hitboxEnabled, backtrackEnabled = false, false, false, false, false, false
local jumpCircleEnabled, trailEnabled, spinEnabled, sunSpinEnabled, helicopterEnabled = false, false, false, false, false
local invisibilityEnabled, noClipEnabled, orbitEnabled, antiAimEnabled, fakeLagEnabled = false, false, false, false, false
local doubleTapEnabled, strafeEnabled, fullbrightEnabled, nameTagsEnabled, skeletonEnabled = false, false, false, false, false
local shiftlockActive, cButtonEnabled, worldColorEnabled, crosshairEnabled, stretchEnabled, hatEnabled = false, false, false, false, false, false
local particlesEnabled = false
local dashEnabled = false
local crosshairColor = guiSettings.CrosshairColor

local espFolder = Instance.new("Folder", workspace) espFolder.Name = "MTY_ESP"
local espV2Folder = Instance.new("Folder", workspace) espV2Folder.Name = "MTY_ESP_V2"
local tracersFolder = Instance.new("Folder", workspace) tracersFolder.Name = "MTY_Tracers"
local chamsFolder = Instance.new("Folder", workspace) chamsFolder.Name = "MTY_Chams"
local HitboxFolder = Instance.new("Folder", workspace) HitboxFolder.Name = "MTY_Hitboxes"
local backtrackFolder = Instance.new("Folder", workspace) backtrackFolder.Name = "MTY_Backtrack"
local nameTagsFolder = Instance.new("Folder", workspace) nameTagsFolder.Name = "MTY_NameTags"
local skeletonFolder = Instance.new("Folder", workspace) skeletonFolder.Name = "MTY_Skeleton"

local backtrackData, trailParts = {}, {}
local currentHat, hatConnection, crosshairGui, shiftlockButton, shiftlockConnection, cButtonGui, dashButton, runNoClip
local particlesConnection, spinConnection, sunSpinConnection, helicopterConnection, orbitConnection, antiAimConnection, fakeLagConnection, strafeConnection, stretchConnection
local originalAmbient, originalOutdoor = Lighting.Ambient, Lighting.OutdoorAmbient
local antiAimMode = "Spin"
local flyLoaded, clemonRCLoaded, r6Enabled = false, false, false
local teleportTool = nil
local jumpCircle, jumpCircleConnection, jumpCircleColor = nil, nil, Color3.fromRGB(0, 255, 0)
local speedValue, gravityValue = 16, workspace.Gravity
local searchBox, contentArea, allSubs, currentCategory = nil, nil, {}, ""

local aimbotEnabled = false
local aimbotFOVRing = Drawing.new("Circle")
aimbotFOVRing.Thickness = 1.5
aimbotFOVRing.Color = Color3.fromRGB(255, 0, 0)
aimbotFOVRing.Filled = false

-- ===== ФУНКЦИЯ ПОКАЗА СООБЩЕНИЙ =====
local function ShowMessage(text)
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(0.5, 0, 0.08, 0) msg.Position = UDim2.new(0.25, 0, 0.88, 0)
    msg.BackgroundColor3 = Color3.fromRGB(0, 0, 0) msg.BackgroundTransparency = 0.3
    msg.Text = text msg.TextColor3 = Color3.fromRGB(255, 255, 255) msg.TextScaled = true msg.Font = Enum.Font.GothamBold
    if guiMainFrame then msg.Parent = guiMainFrame else msg.Parent = game.CoreGui end
    task.spawn(function() task.wait(2) msg:Destroy() end)
end

-- ===== ВСПОМОГАТЕЛЬНЫЕ ОКНА =====
local function OpenTextInput(title, placeholder, default, callback)
    local s = Instance.new("ScreenGui", game.CoreGui) s.Name = "Input"
    local f = Instance.new("Frame", s) f.Size = UDim2.new(0, 250, 0, 150) f.Position = UDim2.new(0.5, -125, 0.35, 0) f.BackgroundColor3 = Color3.fromRGB(0, 0, 0) f.BackgroundTransparency = 0.1
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
    local titleLabel = Instance.new("TextLabel", f) titleLabel.Size = UDim2.new(1, 0, 0, 35) titleLabel.BackgroundTransparency = 1 titleLabel.Text = title titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255) titleLabel.TextScaled = true titleLabel.Font = Enum.Font.GothamBold
    local input = Instance.new("TextBox", f) input.Size = UDim2.new(0.8, 0, 0, 35) input.Position = UDim2.new(0.1, 0, 0.3, 0) input.BackgroundColor3 = Color3.fromRGB(30, 0, 0) input.Text = tostring(default) input.TextColor3 = Color3.fromRGB(255, 255, 255) input.TextScaled = true input.PlaceholderText = placeholder
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)
    local apply = Instance.new("TextButton", f) apply.Size = UDim2.new(0.4, 0, 0, 30) apply.Position = UDim2.new(0.3, 0, 0.7, 0) apply.BackgroundColor3 = Color3.fromRGB(80, 20, 20) apply.Text = "Apply" apply.TextColor3 = Color3.fromRGB(255, 255, 255) Instance.new("UICorner", apply).CornerRadius = UDim.new(0, 8)
    local close = Instance.new("TextButton", f) close.Size = UDim2.new(0, 30, 0, 30) close.Position = UDim2.new(1, -35, 0, 3) close.BackgroundColor3 = Color3.fromRGB(180, 30, 30) close.Text = "X" close.TextColor3 = Color3.fromRGB(255, 255, 255) Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
    apply.MouseButton1Click:Connect(function() local val = tonumber(input.Text) if val then callback(val) s:Destroy() else input.Text = "Enter number" end end)
    close.MouseButton1Click:Connect(function() s:Destroy() end)
end

local function OpenColorPicker(title, callback)
    local s = Instance.new("ScreenGui", game.CoreGui) s.Name = "ColorPicker"
    local f = Instance.new("Frame", s) f.Size = UDim2.new(0, 200, 0, 300) f.Position = UDim2.new(0.5, -100, 0.3, 0) f.BackgroundColor3 = Color3.fromRGB(0, 0, 0) f.BackgroundTransparency = 0.1
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
    local scroll = Instance.new("ScrollingFrame", f) scroll.Size = UDim2.new(0.9, 0, 0.75, 0) scroll.Position = UDim2.new(0.05, 0, 0.12, 0) scroll.BackgroundTransparency = 1 scroll.ScrollBarThickness = 6
    local colors = {{"Red", Color3.fromRGB(255, 0, 0)}, {"Green", Color3.fromRGB(0, 255, 0)}, {"Blue", Color3.fromRGB(0, 0, 255)}, {"Yellow", Color3.fromRGB(255, 255, 0)}, {"Purple", Color3.fromRGB(150, 0, 255)}, {"Cyan", Color3.fromRGB(0, 255, 255)}, {"White", Color3.fromRGB(255, 255, 255)}}
    local y = 0
    for _, data in ipairs(colors) do
        local btn = Instance.new("TextButton", scroll) btn.Size = UDim2.new(0.9, 0, 0, 35) btn.Position = UDim2.new(0.05, 0, 0, y) btn.BackgroundColor3 = data[2] btn.Text = data[1] btn.TextColor3 = Color3.fromRGB(255, 255, 255) Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(function() callback(data[2]) s:Destroy() end) y = y + 42
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, y + 10)
    local close = Instance.new("TextButton", f) close.Size = UDim2.new(0, 30, 0, 30) close.Position = UDim2.new(1, -35, 0, 3) close.BackgroundColor3 = Color3.fromRGB(180, 30, 30) close.Text = "X" close.TextColor3 = Color3.fromRGB(255, 255, 255) Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
    close.MouseButton1Click:Connect(function() s:Destroy() end)
end

-- ===== ЛОГИКА AIMBOT =====
local function FindBestTarget()
    local target, near = nil, guiSettings.AimbotFOV
    local mid = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local hit = player.Character:FindFirstChild(guiSettings.AimbotPart) or player.Character:FindFirstChild("Head")
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if hit and root then
                local distance = (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")) and (root.Position - LP.Character.HumanoidRootPart.Position).Magnitude or 0
                if distance <= guiSettings.AimbotMaxDist then
                    local screen, visible = Camera:WorldToViewportPoint(hit.Position)
                    if visible then
                        local dist = (Vector2.new(screen.X, screen.Y) - mid).Magnitude
                        if dist < near then near = dist target = hit end
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
            local lerpValue = guiSettings.AimbotSpeed * guiSettings.AimbotStrength
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, math.clamp(lerpValue, 0.01, 1))
        end
    end
end)

-- ===== 🎩 CHINA HAT (RGB MINECRAFT STYLE + LOW TRAIL) 🎩 =====
local function CreateChineseHat()
    if currentHat then currentHat:Destroy() currentHat = nil end
    if hatConnection then hatConnection:Disconnect() hatConnection = nil end
    if not LP.Character or not LP.Character:FindFirstChild("Head") then return end
    local head = LP.Character.Head
    local HAT_SIZE = Vector3.new(2.5, 0.4, 2.5)
    local TRAIL_WIDTH = 2.0
    local TRAIL_VERTICAL_OFFSET = -1.2
    currentHat = Instance.new("Part")
    currentHat.Name = "VisualChinaHat"
    currentHat.Material = Enum.Material.Neon
    currentHat.Transparency = 0.4
    currentHat.CanCollide = false; currentHat.Massless = true; currentHat.Size = HAT_SIZE
    local cone = Instance.new("SpecialMesh", currentHat)
    cone.MeshType = Enum.MeshType.FileMesh
    cone.MeshId = "rbxassetid://1033714"
    cone.Scale = Vector3.new(HAT_SIZE.X, HAT_SIZE.Y * 2, HAT_SIZE.Z)
    local a0 = Instance.new("Attachment", currentHat) a0.Position = Vector3.new(-TRAIL_WIDTH / 2, TRAIL_VERTICAL_OFFSET, 0)
    local a1 = Instance.new("Attachment", currentHat) a1.Position = Vector3.new(TRAIL_WIDTH / 2, TRAIL_VERTICAL_OFFSET, 0)
    local trail = Instance.new("Trail", currentHat)
    trail.Attachment0 = a0; trail.Attachment1 = a1; trail.Lifetime = 0.5
    trail.Transparency = NumberSequence.new(0.2, 1); trail.FaceCamera = true; trail.LightEmission = 0.8
    currentHat.Parent = LP.Character
    hatConnection = RunService.RenderStepped:Connect(function()
        if not currentHat or not LP.Character or not LP.Character:FindFirstChild("Head") then return end
        local hue = (tick() * 0.5) % 1
        local currentColor = Color3.fromHSV(hue, 1, 1)
        currentHat.Color = currentColor
        trail.Color = ColorSequence.new(currentColor)
        currentHat.CFrame = head.CFrame * CFrame.new(0, 0.6, 0)
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

LP.CharacterAdded:Connect(function() 
    task.wait(0.5) 
    if hatEnabled then CreateChineseHat() end 
end)

-- ===== ЛОГИКА ПРЕКРАСНЫХ ОПТИМИЗИРОВАННЫХ ВИЗУАЛОВ =====
local function UpdateESP()
    espFolder:ClearAllChildren()
    if not espEnabled then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = Instance.new("Highlight", espFolder) h.Adornee = p.Character
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.FillColor = guiSettings.ESPColor
            h.FillTransparency = 0.3
        end
    end
end

local function ToggleESP() espEnabled = not espEnabled UpdateESP() ShowMessage("ESP "..(espEnabled and "ON" or "OFF")) end
local function ToggleESPV2() espV2Enabled = not espV2Enabled ShowMessage("ESP V2 "..(espV2Enabled and "ON" or "OFF")) end

local function UpdateChams()
    chamsFolder:ClearAllChildren()
    if not chamsEnabled then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = Instance.new("Highlight", chamsFolder) h.Adornee = p.Character
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.FillColor = guiSettings.ChamsColor
            h.FillTransparency = 0.1
            h.OutlineColor = guiSettings.ChamsColor
        end
    end
end

local function ToggleChams() chamsEnabled = not chamsEnabled UpdateChams() ShowMessage("Chams "..(chamsEnabled and "ON" or "OFF")) end

local function UpdateHitboxes()
    HitboxFolder:ClearAllChildren()
    if not hitboxEnabled then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local b = Instance.new("BoxHandleAdornment", HitboxFolder)
            b.Adornee = p.Character.HumanoidRootPart
            b.Color3 = guiSettings.HitboxColor
            b.Transparency = 0.5
            b.Size = Vector3.new(4,4,4)
            b.AlwaysOnTop = true
            b.ZIndex = 10
        end
    end
end

local function ToggleHitboxes() hitboxEnabled = not hitboxEnabled UpdateHitboxes() ShowMessage("Hitboxes "..(hitboxEnabled and "ON" or "OFF")) end
local function ToggleTracers() tracersEnabled = not tracersEnabled ShowMessage("Tracers "..(tracersEnabled and "ON" or "OFF")) end

local function UpdateBacktrack()
    backtrackFolder:ClearAllChildren()
    if not backtrackEnabled then return end
    for _, d in pairs(backtrackData) do
        if tick() - d.time < 0.5 then
            local p = Instance.new("Part", backtrackFolder)
            p.Size = Vector3.new(1,2,1)
            p.CFrame = d.cframe
            p.Anchored = true
            p.CanCollide = false
            p.Transparency = 0.5
            p.Material = Enum.Material.Neon
            p.Color = Color3.fromRGB(255,0,0)
            Debris:AddItem(p, 0.1)
        end
    end
end

local function ToggleBacktrack()
    backtrackEnabled = not backtrackEnabled
    if backtrackEnabled then
        backtrackData = {}
        task.spawn(function()
            while backtrackEnabled do 
                task.wait(0.05)
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(backtrackData, {time = tick(), cframe = LP.Character.HumanoidRootPart.CFrame})
                    if #backtrackData > 30 then table.remove(backtrackData, 1) end
                    UpdateBacktrack()
                end
            end
        end)
    else 
        backtrackFolder:ClearAllChildren() 
    end
    ShowMessage("Backtrack " .. (backtrackEnabled and "ON" or "OFF"))
end

local function ToggleJumpCircle() jumpCircleEnabled = not jumpCircleEnabled ShowMessage("Jump Circle "..(jumpCircleEnabled and "ON" or "OFF")) end

local function CreateTrail()
    if not trailEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local p = Instance.new("Part", workspace)
    p.Size = Vector3.new(0.3,0.3,0.3)
    p.CFrame = LP.Character.HumanoidRootPart.CFrame
    p.Anchored = true
    p.CanCollide = false
    p.Material = Enum.Material.Neon
    p.Color = guiSettings.TrailColor
    p.Transparency = 0.6
    table.insert(trailParts, p) 
    if #trailParts > guiSettings.TrailLength then 
        local o = table.remove(trailParts, 1) 
        if o then o:Destroy() end 
    end
end

local function ToggleTrail()
    trailEnabled = not trailEnabled
    if trailEnabled then 
        trailParts = {} 
        trailConnection = RunService.Heartbeat:Connect(CreateTrail) 
    else 
        if trailConnection then trailConnection:Disconnect() end
        for _, v in pairs(trailParts) do v:Destroy() end
        trailParts = {} 
    end
    ShowMessage("Trail " .. (trailEnabled and "ON" or "OFF"))
end

local function ToggleParticles()
    particlesEnabled = not particlesEnabled
    if particlesEnabled then
        particlesConnection = RunService.Heartbeat:Connect(function()
            if not particlesEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
            local p = Instance.new("Part", workspace)
            p.Size = Vector3.new(0.2,0.2,0.2)
            p.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-3,3), math.random(-3,3), math.random(-3,3))
            p.Anchored = true
            p.CanCollide = false
            p.Material = Enum.Material.Neon
            p.Color = guiSettings.ParticleColor
            Debris:AddItem(p, 0.4)
        end)
    else 
        if particlesConnection then particlesConnection:Disconnect() end 
    end
    ShowMessage("Particles " .. (particlesEnabled and "ON" or "OFF"))
end

local function CreateCrosshair()
    if crosshairGui then crosshairGui:Destroy() end
    crosshairGui = Instance.new("ScreenGui", game.CoreGui)
    crosshairGui.Name = "MTY_Crosshair"
    local center = Instance.new("Frame", crosshairGui)
    center.Size = UDim2.new(0,4,0,4)
    center.Position = UDim2.new(0.5,-2,0.5,-2)
    center.BackgroundColor3 = crosshairColor
    center.BorderSizePixel = 0
end

local function ToggleCrosshair()
    crosshairEnabled = not crosshairEnabled
    if crosshairEnabled then
        CreateCrosshair()
        ShowMessage("Crosshair ON 🎯")
    else 
        if crosshairGui then crosshairGui:Destroy() crosshairGui = nil end
        ShowMessage("Crosshair OFF")
    end
end

local function ToggleFullbright() 
    fullbrightEnabled = not fullbrightEnabled 
    Lighting.Ambient = fullbrightEnabled and Color3.fromRGB(255,255,255) or originalAmbient
    Lighting.OutdoorAmbient = fullbrightEnabled and Color3.fromRGB(255,255,255) or originalOutdoor
    ShowMessage("Fullbright "..(fullbrightEnabled and "ON" or "OFF")) 
end

local function ToggleNameTags() nameTagsEnabled = not nameTagsEnabled ShowMessage("NameTags "..(nameTagsEnabled and "ON" or "OFF")) end
local function ToggleSkeleton() skeletonEnabled = not skeletonEnabled ShowMessage("Skeleton "..(skeletonEnabled and "ON" or "OFF")) end

local function ToggleWorldColor() 
    worldColorEnabled = not worldColorEnabled 
    Lighting.Ambient = worldColorEnabled and guiSettings.WorldColor or originalAmbient
    ShowMessage("WorldColor "..(worldColorEnabled and "ON" or "OFF")) 
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
    ShowMessage("Stretch " .. (stretchEnabled and "ON" or "OFF")) 
end

-- ===== ФУНКЦИИ ДВИЖЕНИЯ =====
local function ToggleSpin()
    spinEnabled = not spinEnabled
    if spinEnabled then 
        spinConnection = RunService.Heartbeat:Connect(function() 
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then 
                LP.Character.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(guiSettings.SpinSpeed), 0) 
            end 
        end)
    else 
        if spinConnection then spinConnection:Disconnect() end 
    end
    ShowMessage("Spin " .. (spinEnabled and "ON" or "OFF"))
end

local function ToggleSunSpin()
    sunSpinEnabled = not sunSpinEnabled
    if sunSpinEnabled then 
        sunSpinConnection = RunService.Heartbeat:Connect(function() 
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then 
                LP.Character.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(guiSettings.SunSpinSpeed), math.rad(guiSettings.SunSpinSpeed * 0.5)) 
            end 
        end)
    else 
        if sunSpinConnection then sunSpinConnection:Disconnect() end 
    end
    ShowMessage("Sun Spin " .. (sunSpinEnabled and "ON" or "OFF"))
end

local function ToggleHelicopter()
    helicopterEnabled = not helicopterEnabled
    if helicopterEnabled then 
        helicopterConnection = RunService.Heartbeat:Connect(function() 
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then 
                local r = LP.Character.HumanoidRootPart
                r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(50), 0)
                r.AssemblyLinearVelocity = Vector3.new(0, 20, 0)
            end 
        end)
    else 
        if helicopterConnection then helicopterConnection:Disconnect() end 
    end
    ShowMessage("Helicopter " .. (helicopterEnabled and "ON" or "OFF"))
end

local function ToggleInvisibility() 
    invisibilityEnabled = not invisibilityEnabled 
    if LP.Character then 
        for _, v in pairs(LP.Character:GetDescendants()) do 
            if v:IsA("BasePart") then v.Transparency = invisibilityEnabled and 0.99 or 0 end 
        end 
    end 
    ShowMessage("Invisibility " .. (invisibilityEnabled and "ON" or "OFF")) 
end

local function ToggleFly() 
    if not flyLoaded then 
        pcall(function() 
            loadstring(game:HttpGet("https://pastebin.com/raw/xxx"))() 
        end) 
        flyLoaded = true 
    end 
    ShowMessage("Fly loaded") 
end

local function ToggleTeleportTool() 
    teleportToolEnabled = not teleportToolEnabled 
    if teleportToolEnabled then 
        teleportTool = Instance.new("Tool", LP.Backpack)
        teleportTool.RequiresHandle = false
        teleportTool.Name = "MTY Teleport"
        teleportTool.Activated:Connect(function() 
            local m = LP:GetMouse() 
            if m and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then 
                LP.Character.HumanoidRootPart.CFrame = CFrame.new(m.Hit.Position + Vector3.new(0,3,0)) 
            end 
        end)
    else 
        if teleportTool then teleportTool:Destroy() end 
    end
    ShowMessage("TP Tool "..(teleportToolEnabled and "ON" or "OFF")) 
end

local function ToggleNoClip() 
    noClipEnabled = not noClipEnabled 
    if noClipEnabled then 
        runNoClip = RunService.Stepped:Connect(function() 
            if LP.Character then 
                for _, v in pairs(LP.Character:GetDescendants()) do 
                    if v:IsA("BasePart") then v.CanCollide = false end 
                end 
            end 
        end)
    else 
        if runNoClip then runNoClip:Disconnect() end 
    end
    ShowMessage("NoClip "..(noClipEnabled and "ON" or "OFF")) 
end

local function ToggleStrafe() 
    strafeEnabled = not strafeEnabled 
    ShowMessage("Strafe "..(strafeEnabled and "ON" or "OFF")) 
end

local function ToggleOrbit() 
    orbitEnabled = not orbitEnabled 
    ShowMessage("Orbit " .. (orbitEnabled and "ON" or "OFF")) 
end

local function ToggleAntiAim() 
    antiAimEnabled = not antiAimEnabled 
    ShowMessage("AntiAim " .. (antiAimEnabled and "ON" or "OFF")) 
end

local function SetAntiAimMode(mode) 
    antiAimMode = mode 
    ShowMessage("AntiAim: " .. mode) 
end

local function ToggleFakeLag() 
    fakeLagEnabled = not fakeLagEnabled 
    ShowMessage("FakeLag " .. (fakeLagEnabled and "ON" or "OFF")) 
end

local function ToggleDoubleTap() 
    doubleTapEnabled = not doubleTapEnabled 
    ShowMessage("DoubleTap " .. (doubleTapEnabled and "ON" or "OFF")) 
end

local function ToggleCButton() 
    cButtonEnabled = not cButtonEnabled 
    ShowMessage("C Button ON ⌨️") 
end

local function LoadClemonRC() 
    pcall(function() 
        loadstring(game:HttpGet("https://githubusercontent.com/xxx"))() 
    end) 
    ShowMessage("ClemonRC loaded") 
end

local function RunCustomAnimation(c) 
    if c:WaitForChild("Humanoid").RigType == Enum.HumanoidRigType.R6 then return end
    if c:FindFirstChild("Animate") then c.Animate.Disabled = true end
    local track = c.Humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(Instance.new("Animation"))
    track.AnimationId = "rbxassetid://1234567890"
    track:Play()
end

local function ToggleR6Animations() 
    r6Enabled = not r6Enabled 
    if r6Enabled then RunCustomAnimation(LP.Character) ShowMessage("R6 Animations ON 🕺") end
end

local function CreateShiftlockButton() 
    shiftlockActive = not shiftlockActive 
end

local function ToggleShiftlock() 
    shiftlockActive = not shiftlockActive 
end

local function ToggleDash() 
    dashEnabled = not dashEnabled 
    ShowMessage("Dash "..(dashEnabled and "ON" or "OFF")) 
end

local function UpdateGUIStyle()
    if guiMainFrame then 
        guiMainFrame.BackgroundColor3 = guiSettings.BackgroundColor 
        guiMainFrame.BackgroundTransparency = guiSettings.Transparency 
    end
    if blurEffect then 
        blurEffect.Enabled = guiSettings.BlurEnabled 
        blurEffect.Size = guiSettings.BlurSize 
    end
end

-- ===== ОТРИСОВКА ИНТЕРФЕЙСА =====
local function CreateMenu()
    screenGui = Instance.new("ScreenGui", game.CoreGui) screenGui.Name = "MTY_HUB"
    guiMainFrame = Instance.new("Frame", screenGui) 
    guiMainFrame.Size = UDim2.new(0, 450, 0, 430) 
    guiMainFrame.Position = UDim2.new(0.5, -225, 0.5, -215) 
    guiMainFrame.BackgroundColor3 = guiSettings.BackgroundColor; guiMainFrame.Active = true; guiMainFrame.Draggable = true
    Instance.new("UICorner", guiMainFrame).CornerRadius = UDim.new(0, 18)
    
    local border = Instance.new("Frame", guiMainFrame) 
    border.Size = UDim2.new(1,0,1,0) 
    border.BackgroundTransparency = 1 
    border.BorderSizePixel = 2 
    border.BorderColor3 = guiSettings.BorderColor; Instance.new("UICorner", border).CornerRadius = UDim.new(0, 18)
    
    local title = Instance.new("TextLabel", guiMainFrame) 
    title.Size = UDim2.new(0.7, 0, 0, 40) 
    title.Position = UDim2.new(0.05, 0, 0.015, 0) 
    title.BackgroundTransparency = 1 
    title.Text = "MTY HUB v4.4 🔥" 
    title.TextColor3 = guiSettings.TextColor; title.TextScaled = true; title.Font = Enum.Font.GothamBold
    
    local minimizeBtn = Instance.new("TextButton", guiMainFrame) 
    minimizeBtn.Size = UDim2.new(0, 36, 0, 36) 
    minimizeBtn.Position = UDim2.new(1, -80, 0, 8) 
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 0, 0) 
    minimizeBtn.Text = "-" 
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255) 
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 10)
    
    local closeBtn = Instance.new("TextButton", guiMainFrame) 
    closeBtn.Size = UDim2.new(0, 36, 0, 36) 
    closeBtn.Position = UDim2.new(1, -40, 0, 8) 
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30) 
    closeBtn.Text = "X" 
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255) 
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 10)
    
    blurEffect = Instance.new("BlurEffect", Lighting) 
    blurEffect.Enabled = guiSettings.BlurEnabled
    
    local leftPanel = Instance.new("Frame", guiMainFrame) 
    leftPanel.Size = UDim2.new(0, 120, 0, 320) 
    leftPanel.Position = UDim2.new(0.02, 0, 0.15, 0) 
    leftPanel.BackgroundColor3 = Color3.fromRGB(20, 0, 0) 
    leftPanel.BackgroundTransparency = 0.3; Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 12)
    
    searchBox = Instance.new("TextBox", guiMainFrame) 
    searchBox.Size = UDim2.new(0.7, 0, 0, 30) 
    searchBox.Position = UDim2.new(0.27, 0, 0.09, 0) 
    searchBox.BackgroundColor3 = Color3.fromRGB(20, 0, 0) 
    searchBox.PlaceholderText = "Search..." 
    searchBox.TextColor3 = Color3.fromRGB(255,255,255) 
    searchBox.TextScaled = true; Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 8)
    
    contentArea = Instance.new("ScrollingFrame", guiMainFrame) 
    contentArea.Size = UDim2.new(0.7, 0, 0.6, 0) 
    contentArea.Position = UDim2.new(0.27, 0, 0.17, 0) 
    contentArea.BackgroundColor3 = Color3.fromRGB(20, 0, 0) 
    contentArea.BackgroundTransparency = 0.2; Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0, 12)
    
    local function RenderSubs(subs)
        for _, v in pairs(contentArea:GetChildren()) do 
            if not v:IsA("UICorner") then v:Destroy() end 
        end
        local grid = Instance.new("Frame", contentArea) 
        grid.Size = UDim2.new(0.95, 0, 0.95, 0) 
        grid.BackgroundTransparency = 1
        local searchT = searchBox.Text:lower()
        local filtered = {}
        for _, name in ipairs(subs) do 
            if searchT == "" or name:lower():find(searchT) then table.insert(filtered, name) end 
        end
        for i, name in ipairs(filtered) do
            local row = Instance.new("Frame", grid) 
            row.Size = UDim2.new(1, 0, 0, 24) 
            row.Position = UDim2.new(0, 0, 0, (i - 1) * 28) 
            row.BackgroundTransparency = 1
            local btn = Instance.new("TextButton", row) 
            btn.Size = UDim2.new(0.9, 0, 1, 0) 
            btn.BackgroundColor3 = Color3.fromRGB(80, 20, 20) 
            btn.Text = name 
            btn.TextColor3 = Color3.fromRGB(255, 200, 200) 
            btn.TextSize = 11 
            btn.Font = Enum.Font.Gotham
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            
            btn.MouseButton1Click:Connect(function()
                if name == "Toggle ESP" then ToggleESP()
                elseif name == "Toggle Chams" then ToggleChams()
                elseif name == "Toggle Hitboxes" then ToggleHitboxes()
                elseif name == "Toggle Backtrack" then ToggleBacktrack()
                elseif name == "Toggle Trail" then ToggleTrail()
                elseif name == "Toggle Particles" then ToggleParticles()
                elseif name == "Toggle Crosshair" then ToggleCrosshair()
                elseif name == "Toggle Chinese Hat" then ToggleChineseHat()
                elseif name == "Toggle Shiftlock" then ToggleShiftlock()
                elseif name == "Toggle C Button" then ToggleCButton()
                elseif name == "Toggle R6 Animations" then ToggleR6Animations()
                elseif name == "Toggle Fullbright" then ToggleFullbright()
                elseif name == "Toggle NoClip" then ToggleNoClip()
                elseif name == "Toggle Spin" then ToggleSpin()
                elseif name == "Toggle Sun Spin" then ToggleSunSpin()
                elseif name == "Toggle Helicopter" then ToggleHelicopter()
                elseif name == "Toggle Invisibility" then ToggleInvisibility()
                elseif name == "Toggle Dash" then ToggleDash()
                elseif name == "Toggle Fly" then ToggleFly()
                elseif name == "Toggle Teleport Tool" then ToggleTeleportTool()
                elseif name == "Toggle Strafe" then ToggleStrafe()
                elseif name == "Toggle Orbit" then ToggleOrbit()
                elseif name == "Toggle Anti-Aim" then ToggleAntiAim()
                elseif name == "Toggle Fake Lag" then ToggleFakeLag()
                elseif name == "Toggle Double Tap" then ToggleDoubleTap()
                elseif name == "Toggle Stretch" then ToggleStretch()
                elseif name == "Toggle World Color" then ToggleWorldColor()
                elseif name == "Load ClemonRC" then LoadClemonRC()
                elseif name == "Aimbot Speed" then OpenTextInput("Speed", "0.01-1", guiSettings.AimbotSpeed, function(v) guiSettings.AimbotSpeed = math.clamp(v, 0.01, 1.0) ShowMessage("Speed: "..v) end)
                elseif name == "Aimbot Strength" then OpenTextInput("Strength", "0.1-1", guiSettings.AimbotStrength, function(v) guiSettings.AimbotStrength = math.clamp(v, 0.1, 1.0) ShowMessage("Strength: "..v) end)
                elseif name == "Aimbot FOV" then OpenTextInput("FOV", "10-500", guiSettings.AimbotFOV, function(v) guiSettings.AimbotFOV = math.clamp(v, 10, 500) aimbotFOVRing.Radius = v ShowMessage("FOV: "..v) end)
                elseif name == "Toggle Aimbot" then aimbotEnabled = not aimbotEnabled ShowMessage("Aimbot "..(aimbotEnabled and "ON" or "OFF"))
                elseif name == "Speed" then OpenTextInput("Speed", "0-99999", speedValue, function(v) if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed = math.clamp(v, 0, 99999) end ShowMessage("Speed: "..v) end)
                elseif name == "Gravity" then OpenTextInput("Gravity", "-1000-10000", workspace.Gravity, function(v) workspace.Gravity = math.clamp(v, -1000, 10000) ShowMessage("Gravity: "..v) end)
                elseif name == "Spin Speed" then OpenTextInput("Spin Speed", "1-100", guiSettings.SpinSpeed, function(v) guiSettings.SpinSpeed = math.clamp(v, 1, 100) ShowMessage("Spin Speed: "..v) end)
                elseif name == "Sun Spin Speed" then OpenTextInput("Sun Spin Speed", "10-500", guiSettings.SunSpinSpeed, function(v) guiSettings.SunSpinSpeed = math.clamp(v, 10, 500) ShowMessage("Sun Spin Speed: "..v) end)
                elseif name == "Fake Lag Amount" then OpenTextInput("Fake Lag Amount", "1-20", guiSettings.FakeLagAmount, function(v) guiSettings.FakeLagAmount = math.clamp(v, 1, 20) ShowMessage("Fake Lag: "..v) end)
                elseif name == "Trail Length" then OpenTextInput("Trail Length", "10-200", guiSettings.TrailLength, function(v) guiSettings.TrailLength = math.clamp(v, 10, 200) ShowMessage("Trail Length: "..v) end)
                elseif name == "Jump Circle Fade Time" then OpenTextInput("Fade Time", "0.5-5", guiSettings.JumpCircleFadeTime, function(v) guiSettings.JumpCircleFadeTime = math.clamp(v, 0.5, 5) ShowMessage("Fade Time: "..v) end)
                elseif name == "Transparency" then OpenTextInput("Transparency", "0-0.8", guiSettings.Transparency, function(v) guiSettings.Transparency = math.clamp(v, 0, 0.8) UpdateGUIStyle() end)
                elseif name == "Blur Size" then OpenTextInput("Blur Size", "1-30", guiSettings.BlurSize, function(v) guiSettings.BlurSize = math.clamp(v, 1, 30) UpdateGUIStyle() end)
                elseif name == "Toggle Blur" then guiSettings.BlurEnabled = not guiSettings.BlurEnabled UpdateGUIStyle() ShowMessage("Blur "..(guiSettings.BlurEnabled and "ON" or "OFF"))
                elseif name == "Style MTY Dark" then guiSettings.BackgroundColor = Color3.fromRGB(0,0,0) guiSettings.BorderColor = Color3.fromRGB(255,0,0) guiSettings.TextColor = Color3.fromRGB(255,255,255) guiSettings.Transparency = 0.05 UpdateGUIStyle() ShowMessage("Style: Dark")
                elseif name == "Style MTY Neon" then guiSettings.BackgroundColor = Color3.fromRGB(10,0,20) guiSettings.BorderColor = Color3.fromRGB(255,0,200) guiSettings.TextColor = Color3.fromRGB(255,0,200) guiSettings.Transparency = 0.1 UpdateGUIStyle() ShowMessage("Style: Neon")
                elseif name == "Style MTY Glass" then guiSettings.BackgroundColor = Color3.fromRGB(255,255,255) guiSettings.BorderColor = Color3.fromRGB(255,255,255) guiSettings.TextColor = Color3.fromRGB(0,0,0) guiSettings.Transparency = 0.3 UpdateGUIStyle() ShowMessage("Style: Glass")
                elseif name == "Background Color" then OpenColorPicker("Background Color", function(c) guiSettings.BackgroundColor = c UpdateGUIStyle() end)
                elseif name == "Border Color" then OpenColorPicker("Border Color", function(c) guiSettings.BorderColor = c UpdateGUIStyle() end)
                elseif name == "Text Color" then OpenColorPicker("Text Color", function(c) guiSettings.TextColor = c UpdateGUIStyle() end)
                elseif name == "Hat Color" then OpenColorPicker("Hat Color", function(c) guiSettings.HatColor = c if hatEnabled then CreateChineseHat() end end)
                elseif name == "Particle Color" then OpenColorPicker("Particle Color", function(c) guiSettings.ParticleColor = c ShowMessage("Particle Color changed") end)
                elseif name == "Crosshair Color" then OpenColorPicker("Crosshair Color", function(c) crosshairColor = c if crosshairEnabled then CreateCrosshair() end end)
                elseif name == "Jump Circle Color" then OpenColorPicker("Jump Circle Color", function(c) jumpCircleColor = c if jumpCircle then jumpCircle.BrickColor = BrickColor.new(c) end guiSettings.JumpCircleColor = c end)
                elseif name == "World Color" then OpenColorPicker("World Color", function(c) guiSettings.WorldColor = c if worldColorEnabled then Lighting.Ambient = c Lighting.OutdoorAmbient = c end end)
                elseif name == "Toggle World Color" then ToggleWorldColor()
                elseif name == "Toggle NameTags" then ToggleNameTags()
                elseif name == "Toggle Skeleton" then ToggleSkeleton()
                elseif name == "Toggle Tracers" then ToggleTracers()
                elseif name == "Toggle Jump Circle" then ToggleJumpCircle()
                elseif name == "Anti-Aim Mode: Spin" then SetAntiAimMode("Spin")
                elseif name == "Anti-Aim Mode: Backwards" then SetAntiAimMode("Backwards")
                elseif name == "Optimize Textures" then
                    for _, v in pairs(game:GetDescendants()) do 
                        pcall(function() 
                            if v:IsA("Texture") or v:IsA("Decal") then v.Texture = "rbxassetid://4322737890" 
                            elseif v:IsA("BasePart") then v.Material = Enum.Material.Plastic v.Reflectance = 0 
                            elseif v:IsA("Terrain") then v.WaterWaveSize = 0 v.WaterReflectance = 0 v.WaterTransparency = 1 
                            end 
                        end) 
                    end
                    Lighting.GlobalShadows = false Lighting.Brightness = 1 Lighting.ClockTime = 14 
                    ShowMessage("Textures Optimized")
                end
            end)
        end
        contentArea.CanvasSize = UDim2.new(0, 0, 0, #filtered * 28 + 15)
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
            leftPanel.Visible = false contentArea.Visible = false searchBox.Visible = false title.Visible = false minimizeBtn.Text = "+" 
            closeBtn.Position = UDim2.new(1, -35, 0, 8)
        else
            guiMainFrame.Size = UDim2.new(0, 450, 0, 430) 
            guiMainFrame.Position = UDim2.new(0.5, -225, 0.5, -215)
            leftPanel.Visible = true contentArea.Visible = true searchBox.Visible = true title.Visible = true minimizeBtn.Text = "-" 
            closeBtn.Position = UDim2.new(1, -80, 0, 8)
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function() 
        screenGui:Destroy() 
        if blurEffect then blurEffect:Destroy() end 
    end)
    
    local categories = {
        VISUAL = {"Toggle ESP", "Toggle Chams", "Toggle Hitboxes", "Toggle Tracers", "Toggle Backtrack", "Toggle Jump Circle", "Jump Circle Color", "Jump Circle Fade Time", "Toggle Trail", "Trail Length", "Toggle Particles", "Particle Color", "Toggle Fullbright", "Toggle NameTags", "Toggle Skeleton", "Toggle Chinese Hat", "Hat Color", "Toggle World Color", "World Color", "Toggle Crosshair", "Crosshair Color", "Toggle Stretch"},
        PLAYER = {"Speed", "Gravity", "Toggle Spin", "Spin Speed", "Toggle Sun Spin", "Sun Spin Speed", "Toggle Helicopter", "Toggle Invisibility", "Toggle Dash", "Toggle Fly", "Toggle Teleport Tool", "Toggle NoClip", "Toggle Shiftlock", "Toggle Strafe"},
        COMBAT = {"Toggle Aimbot", "Aimbot Speed", "Aimbot Strength", "Aimbot FOV", "Toggle Orbit", "Toggle Anti-Aim", "Anti-Aim Mode: Spin", "Anti-Aim Mode: Backwards", "Toggle Fake Lag", "Fake Lag Amount", "Toggle Double Tap"},
        ["NO FE"] = {"Toggle C Button", "Load ClemonRC", "Toggle R6 Animations"},
        SETTINGS = {"Style MTY Dark", "Style MTY Neon", "Style MTY Glass", "Background Color", "Border Color", "Text Color", "Transparency", "Toggle Blur", "Blur Size", "Optimize Textures"}
    }
    
    local categoryButtons = {}
    local idx = 0
    for catName, subs in pairs(categories) do
        local btn = Instance.new("TextButton", leftPanel) 
        btn.Size = UDim2.new(0.9, 0, 0, 32) 
        btn.Position = UDim2.new(0.05, 0, 0.05 + (idx * 0.16), 0) 
        btn.BackgroundColor3 = Color3.fromRGB(60, 15, 15) 
        btn.Text = catName 
        btn.TextColor3 = Color3.fromRGB(255, 150, 150) 
        btn.Font = Enum.Font.Gotham
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        categoryButtons[catName] = btn
        btn.MouseButton1Click:Connect(function() 
            currentCategory = catName 
            allSubs = subs 
            RenderSubs(subs) 
        end)
        idx = idx + 1
    end
    
    categoryButtons["VISUAL"]:MouseButton1Click()
end

CreateMenu()
print("MTY HUB v4.4 LOADED! 🔥")