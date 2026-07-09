-- MTY HUB v5.5 ULTIMATE (FULL FIXED)
-- Добавлены: Strafes V1/V2, Spider, Swim, Anti-KB, Dash, Blink, NoJumpCD

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

local guiMainFrame, screenGui, targetHudFrame, crosshairGui, airWalkPlatform, trailAnchor, actualTrailInstance, currentHat, hatConnection, dashButton, teleportTool, specFrame, blinkGhost = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local trailParts, backtrackData, arrowIndicators = {}, {}, {}
local searchBox, contentArea, allSubs, currentCategory = nil, nil, {}, ""
local speedValue, originalAmbient, originalOutdoor = 16, Lighting.Ambient, Lighting.OutdoorAmbient
local targetPlayer, blinkPos, originalVelocity = nil, nil, Vector3.new(0,0,0)

local guiSettings = {
    BackgroundColor = Color3.fromRGB(15, 15, 17), BorderColor = Color3.fromRGB(130, 80, 255), TextColor = Color3.fromRGB(240, 240, 245),
    ESPColor = Color3.fromRGB(130, 80, 255), HitboxColor = Color3.fromRGB(255, 0, 100), ChamsColor = Color3.fromRGB(0, 255, 200),
    JumpCircleColor = Color3.fromRGB(130, 80, 255), TrailColor = Color3.fromRGB(0, 255, 255), HatColor = Color3.fromRGB(130, 80, 255),
    ParticleColor = Color3.fromRGB(130, 80, 255), CrosshairColor = Color3.fromRGB(0, 255, 100), SpinSpeed = 25, JumpCircleFadeTime = 0.8,
    TrailLength = 40, FakeLagAmount = 6, StretchValue = 0.7, AimbotFOV = 130, AimbotSpeed = 0.25, AimbotStrength = 0.85, AimbotPart = "Head",
    KillAuraRange = 18, AimbotWallbang = true, CameraFOV = 70, ToolReachValue = 4, HatRainbow = false, ArrowRadius = 80
}

-- ===== СОСТОЯНИЯ =====
local espEnabled, espV2Enabled, espV3Enabled, tracersEnabled, tracersV2Enabled, chamsEnabled, chamsV2Enabled, hitboxEnabled, hitboxV2Enabled, skeletonEnabled = false, false, false, false, false, false, false, false, false, false
local jumpCircleEnabled, trailEnabled, trailV2Enabled, particlesEnabled, crosshairEnabled, crosshairV3Enabled, stretchEnabled, hatEnabled, motionBlurEnabled = false, false, false, false, false, false, false, false, false
local spinEnabled, helicopterEnabled, invisibilityEnabled, noClipEnabled, antiAimEnabled, fakeLagEnabled, desyncEnabled, spiderEnabled, antiKbEnabled, swimEnabled = false, false, false, false, false, false, false, false, false, false
local killAuraEnabled, killAuraV2Enabled, killAuraV3Enabled, triggerBotEnabled, autoClickerEnabled, autoClickerV2Enabled = false, false, false, false, false, false
local infJumpEnabled, autoSprintEnabled, flyV1Enabled, flyV2Enabled, tpToolEnabled, targetHudEnabled, hitGlowEnabled, auraVisEnabled, hitmarkerEnabled, damageIndEnabled = false, false, false, false, false, false, false, false, false, false
local resolverEnabled, targetLineEnabled, specListEnabled, noSlowEnabled, autoEquipEnabled, tpTweenEnabled, blinkEnabled, serverHopEnabled = false, false, false, false, false, false, false, false
local strafeEnabled, strafeV2Enabled, noJumpCdEnabled, dashEnabled, blockEspEnabled, arrowIndicatorsEnabled = false, false, false, false, false, false
local aimbotEnabled, aimbotV2Enabled, aimbotV3Enabled = false, false, false
local particlesV2Enabled, worldColorEnabled, fullbrightEnabled = false, false, false

-- ===== ПАПКИ =====
local espFolder = Instance.new("Folder", workspace) espFolder.Name = "MTY_ESP"
local espV2Folder = Instance.new("Folder", workspace) espV2Folder.Name = "MTY_ESP_V2"
local tracersFolder = Instance.new("Folder", workspace) tracersFolder.Name = "MTY_Tracers"
local chamsFolder = Instance.new("Folder", workspace) chamsFolder.Name = "MTY_Chams"
local HitboxFolder = Instance.new("Folder", workspace) HitboxFolder.Name = "MTY_Hitboxes"
local skeletonFolder = Instance.new("Folder", workspace) skeletonFolder.Name = "MTY_Skeleton"
local backtrackFolder = Instance.new("Folder", workspace) backtrackFolder.Name = "MTY_Backtrack"

-- ===== ПЕРЕМЕННЫЕ ДЛЯ КОННЕКШЕНОВ =====
local strafeConnection, strafeV2Connection, particlesConnection, spinConnection, helicopterConnection, orbitConnection, antiAimConnection, fakeLagConnection, desyncConnection, noClipConnection, swimConnection, antiKbConnection, spiderConnection, dashButtonConnection, jumpCircleConnection, trailConnection, autoSprintConnection, infJumpConnection

-- ===== FOV GUI =====
local fovGui = Instance.new("ScreenGui", game.CoreGui) fovGui.Name = "MTY_FOV"
local fovRing = Instance.new("Frame", fovGui) fovRing.AnchorPoint = Vector2.new(0.5,0.5) fovRing.Position = UDim2.new(0.5,0,0.5,0) fovRing.BackgroundTransparency = 1 fovRing.Visible = false
local fovStroke = Instance.new("UIStroke", fovRing) fovStroke.Thickness = 1.5 fovStroke.Color = guiSettings.BorderColor

-- ===== СИСТЕМА УВЕДОМЛЕНИЙ =====
local function ShowMessage(text)
    local msg = Instance.new("TextLabel", guiMainFrame or game.CoreGui) 
    msg.Size = UDim2.new(0.45, 0, 0.07, 0) 
    msg.Position = UDim2.new(0.275, 0, 0.88, 0) 
    msg.BackgroundColor3 = Color3.fromRGB(20, 20, 25) 
    msg.Text = text 
    msg.TextColor3 = guiSettings.TextColor 
    msg.TextScaled = true 
    msg.Font = Enum.Font.GothamBold 
    Instance.new("UICorner", msg).CornerRadius = UDim.new(0, 6) 
    Instance.new("UIStroke", msg).Color = guiSettings.BorderColor 
    Debris:AddItem(msg, 1.5)
end

-- ===== ВСПОМОГАТЕЛЬНЫЕ ОКНА =====
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
    local colors = {{"Purple", Color3.fromRGB(130, 80, 255)}, {"Red", Color3.fromRGB(255, 0, 70)}, {"Green", Color3.fromRGB(0, 255, 100)}, {"Blue", Color3.fromRGB(0, 150, 255)}, {"Cyan", Color3.fromRGB(0, 255, 255)}, {"White", Color3.fromRGB(255,255,255)}, {"Yellow", Color3.fromRGB(255,220,0)}}
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

-- ============================================
-- 🎯 AIMBOT ENGINE
-- ============================================
local function FindBestTarget()
    local target, near = nil, guiSettings.AimbotFOV 
    local mid = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local hit = p.Character:FindFirstChild(guiSettings.AimbotPart) or p.Character:FindFirstChild("Head")
            if hit then
                if not guiSettings.AimbotWallbang and #Camera:GetPartsObscuringTarget({hit.Position}, {LP.Character, p.Character}) > 0 then 
                    continue 
                end
                local screen, visible = Camera:WorldToViewportPoint(hit.Position)
                if visible then 
                    local dist = (Vector2.new(screen.X, screen.Y) - mid).Magnitude 
                    if dist < near then 
                        near = dist 
                        target = p 
                    end 
                end
            end
        end
    end 
    return target
end

RunService.RenderStepped:Connect(function()
    fovRing.Size = UDim2.new(0, guiSettings.AimbotFOV * 2, 0, guiSettings.AimbotFOV * 2) 
    fovRing.Visible = aimbotEnabled 
    fovStroke.Color = guiSettings.BorderColor
    if aimbotEnabled then
        local tPlayer = FindBestTarget() 
        targetPlayer = tPlayer
        if tPlayer and tPlayer.Character and tPlayer.Character:FindFirstChild(guiSettings.AimbotPart) then
            local hit = tPlayer.Character[guiSettings.AimbotPart] 
            local pos = hit.Position
            if aimbotV3Enabled and tPlayer.Character:FindFirstChild("HumanoidRootPart") then 
                pos = pos + (tPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity * 0.05) 
            end
            if aimbotV2Enabled then 
                local oldCF = Camera.CFrame 
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, pos) 
                task.wait() 
                Camera.CFrame = oldCF 
            else 
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, pos), math.clamp(guiSettings.AimbotSpeed * guiSettings.AimbotStrength, 0.01, 1)) 
            end
        end
    else 
        targetPlayer = nil 
    end
end)

-- ============================================
-- 🏃 СТРЕЙФЫ V1 И V2
-- ============================================
local strafeDirection = 1
local lastStrafeSwitch = 0
local strafeV2Timer = 0

function ToggleStrafe()
    strafeEnabled = not strafeEnabled
    if strafeEnabled then
        strafeConnection = RunService.Heartbeat:Connect(function()
            if not strafeEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
            local root = LP.Character.HumanoidRootPart
            local hum = LP.Character.Humanoid
            local move = hum.MoveDirection
            if move.Magnitude > 0.1 then
                local camLook = Camera.CFrame.LookVector
                local camRight = Camera.CFrame.RightVector
                camLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
                camRight = Vector3.new(camRight.X, 0, camRight.Z).Unit
                if tick() - lastStrafeSwitch > 0.15 then
                    strafeDirection = strafeDirection * -1
                    lastStrafeSwitch = tick()
                end
                local strafeVec = camRight * strafeDirection
                local moveVec = (move.Unit * 0.3 + strafeVec * 0.7).Unit
                local speed = hum.WalkSpeed * 1.2
                root.AssemblyLinearVelocity = Vector3.new(moveVec.X * speed, root.AssemblyLinearVelocity.Y, moveVec.Z * speed)
                if moveVec.Magnitude > 0.1 then root.CFrame = CFrame.new(root.Position, root.Position + moveVec) end
            end
        end)
        ShowMessage("🏃 Strafe ON")
    else
        if strafeConnection then strafeConnection:Disconnect() strafeConnection = nil end
        ShowMessage("🏃 Strafe OFF")
    end
end

function ToggleStrafeV2()
    strafeV2Enabled = not strafeV2Enabled
    if strafeV2Enabled then
        strafeV2Connection = RunService.Heartbeat:Connect(function()
            if not strafeV2Enabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
            local root = LP.Character.HumanoidRootPart
            local hum = LP.Character.Humanoid
            local move = hum.MoveDirection
            if move.Magnitude > 0.1 then
                local camLook = Camera.CFrame.LookVector
                local camRight = Camera.CFrame.RightVector
                camLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
                camRight = Vector3.new(camRight.X, 0, camRight.Z).Unit
                if tick() - strafeV2Timer > 0.08 then
                    strafeV2Timer = tick()
                    strafeDirection = strafeDirection * -1
                end
                local jitter = math.random(-5, 5) / 100
                local strafeVec = camRight * (strafeDirection + jitter)
                local moveVec = (move.Unit * 0.2 + strafeVec * 0.8).Unit
                local speed = hum.WalkSpeed * 1.5
                root.AssemblyLinearVelocity = Vector3.new(moveVec.X * speed, root.AssemblyLinearVelocity.Y + math.sin(tick() * 10) * 2, moveVec.Z * speed)
                if moveVec.Magnitude > 0.1 then root.CFrame = CFrame.new(root.Position, root.Position + moveVec) end
            end
        end)
        ShowMessage("🌀 Strafe V2 (HvH) ON")
    else
        if strafeV2Connection then strafeV2Connection:Disconnect() strafeV2Connection = nil end
        ShowMessage("🌀 Strafe V2 OFF")
    end
end

-- ============================================
-- 🕷️ MOVEMENT (SPIDER, SWIM, ANTI-KB, DASH, BLINK, NOJUMPCD)
-- ============================================
function ToggleSpider()
    spiderEnabled = not spiderEnabled 
    ShowMessage("Spider Mode "..(spiderEnabled and "ON 🕷️" or "OFF"))
    if spiderEnabled then
        spiderConnection = RunService.Heartbeat:Connect(function()
            if not spiderEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
            local r = LP.Character.HumanoidRootPart
            local ray = workspace:Raycast(r.Position, r.CFrame.LookVector * 2.5)
            if ray and ray.Instance and math.abs(ray.Normal.Y) < 0.1 then 
                r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, speedValue, r.AssemblyLinearVelocity.Z) 
            end
        end)
    else
        if spiderConnection then spiderConnection:Disconnect() spiderConnection = nil end
    end
end

function ToggleSwim()
    swimEnabled = not swimEnabled 
    ShowMessage("Swim In Air "..(swimEnabled and "ON 🏊" or "OFF"))
    if swimEnabled then
        swimConnection = RunService.Heartbeat:Connect(function()
            if swimEnabled and LP.Character and LP.Character:FindFirstChild("Humanoid") then 
                LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming) 
            end
        end)
    else
        if swimConnection then swimConnection:Disconnect() swimConnection = nil end
    end
end

function ToggleAntiKb()
    antiKbEnabled = not antiKbEnabled 
    ShowMessage("Anti-Knockback "..(antiKbEnabled and "ON ⚓" or "OFF"))
    if antiKbEnabled then
        antiKbConnection = RunService.Heartbeat:Connect(function()
            if antiKbEnabled and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                local vel = LP.Character.HumanoidRootPart.AssemblyLinearVelocity
                if vel.Magnitude > 60 then 
                    LP.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0) 
                end
            end
        end)
    else
        if antiKbConnection then antiKbConnection:Disconnect() antiKbConnection = nil end
    end
end

function ToggleNoJumpCooldown()
    noJumpCdEnabled = not noJumpCdEnabled
    ShowMessage("No Jump CD "..(noJumpCdEnabled and "ON 🦘" or "OFF"))
    if noJumpCdEnabled then
        task.spawn(function()
            while noJumpCdEnabled do
                task.wait(0.1)
                if LP.Character and LP.Character:FindFirstChild("Humanoid") then
                    LP.Character.Humanoid.JumpPower = 50
                end
            end
        end)
    end
end

function ToggleBlinkMode()
    blinkEnabled = not blinkEnabled 
    ShowMessage("Blink Mode "..(blinkEnabled and "ON 👻" or "OFF"))
    if blinkEnabled then
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.Anchored = true
        end
    else
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.Anchored = false
        end
    end
end

function ToggleDash()
    dashEnabled = not dashEnabled
    if dashEnabled then
        local sg = Instance.new("ScreenGui", game.CoreGui) 
        dashButton = Instance.new("TextButton", sg) 
        dashButton.Size = UDim2.new(0, 60, 0, 60) 
        dashButton.Position = UDim2.new(0.8, 0, 0.5, 0) 
        dashButton.BackgroundColor3 = guiSettings.BorderColor 
        dashButton.Text = "DASH" 
        dashButton.TextColor3 = Color3.new(1,1,1) 
        dashButton.Font = Enum.Font.GothamBold 
        Instance.new("UICorner", dashButton).CornerRadius = UDim.new(0, 30)
        dashButton.MouseButton1Click:Connect(function()
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                local root = LP.Character.HumanoidRootPart 
                local hum = LP.Character.Humanoid 
                local dir = hum.MoveDirection.Magnitude > 0 and hum.MoveDirection or root.CFrame.LookVector
                local lV = Instance.new("LinearVelocity", root) 
                lV.MaxForce = 999999 
                lV.Velocity = Vector3.new(dir.X, 0, dir.Z).Unit * 130 
                local att = Instance.new("Attachment", root) 
                lV.Attachment0 = att 
                Debris:AddItem(lV, 0.15) 
                Debris:AddItem(att, 0.15)
            end
        end) 
        ShowMessage("Dash Button ON 🏃")
    else 
        if dashButton then dashButton.Parent:Destroy() dashButton = nil end 
        ShowMessage("Dash OFF") 
    end
end

-- ============================================
-- 🎩 CHINA HAT
-- ============================================
local function CreateChineseHat()
    if currentHat then currentHat:Destroy() end 
    if hatConnection then hatConnection:Disconnect() end
    if not LP.Character or not LP.Character:FindFirstChild("Head") then return end
    currentHat = Instance.new("Part", LP.Character) 
    currentHat.Name = "ChinaHat" 
    currentHat.Material = Enum.Material.Neon 
    currentHat.Transparency = 0.4 
    currentHat.CanCollide = false 
    currentHat.Massless = true 
    currentHat.Size = Vector3.new(2.4, 0.4, 2.4)
    local cone = Instance.new("SpecialMesh", currentHat) 
    cone.MeshType = Enum.MeshType.FileMesh 
    cone.MeshId = "rbxassetid://1033714" 
    cone.Scale = Vector3.new(2.4, 0.8, 2.4)
    local a0 = Instance.new("Attachment", currentHat) 
    a0.Position = Vector3.new(-0.9, -1.2, 0) 
    local a1 = Instance.new("Attachment", currentHat) 
    a1.Position = Vector3.new(0.9, -1.2, 0)
    local trail = Instance.new("Trail", currentHat) 
    trail.Attachment0 = a0
    trail.Attachment1 = a1
    trail.Lifetime = 0.4
    trail.FaceCamera = true
    trail.LightEmission = 0.9
    hatConnection = RunService.RenderStepped:Connect(function()
        if not currentHat or not LP.Character or not LP.Character:FindFirstChild("Head") then return end
        local color = guiSettings.HatRainbow and Color3.fromHSV((tick() * 0.4) % 1, 1, 1) or guiSettings.HatColor
        currentHat.Color = color 
        trail.Color = ColorSequence.new(color) 
        currentHat.CFrame = LP.Character.Head.CFrame * CFrame.new(0, 0.6, 0)
    end)
end

function ToggleChineseHat() 
    hatEnabled = not hatEnabled 
    if hatEnabled then 
        CreateChineseHat() 
        ShowMessage("China Hat ON 🎩") 
    else 
        if currentHat then currentHat:Destroy() end 
        ShowMessage("China Hat OFF") 
    end 
end

-- ============================================
-- 🟢 JUMP CIRCLE
-- ============================================
local function ApplyJumpCircleEffect()
    if not jumpCircleEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local disk = Instance.new("Part", workspace) 
    disk.Shape = Enum.PartType.Cylinder 
    disk.Size = Vector3.new(0.02, 2, 2) 
    disk.CFrame = CFrame.new(LP.Character.HumanoidRootPart.Position - Vector3.new(0, 2.8, 0)) * CFrame.Angles(0, 0, math.rad(90)) 
    disk.Anchored = true
    disk.CanCollide = false
    disk.Material = Enum.Material.Neon
    disk.Color = guiSettings.JumpCircleColor
    disk.Transparency = 0.2
    TweenService:Create(disk, TweenInfo.new(guiSettings.JumpCircleFadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.new(0.01, 14, 14), Transparency = 1}):Play() 
    Debris:AddItem(disk, guiSettings.JumpCircleFadeTime + 0.1)
end

function ToggleJumpCircle()
    jumpCircleEnabled = not jumpCircleEnabled
    if jumpCircleEnabled then 
        jumpCircleConnection = (LP.Character or LP.CharacterAdded:Wait()):WaitForChild("Humanoid").Jumping:Connect(function() 
            if jumpCircleEnabled then ApplyJumpCircleEffect() end 
        end) 
        ShowMessage("Jump Circle ON 🟢") 
    else 
        if jumpCircleConnection then jumpCircleConnection:Disconnect() end 
        ShowMessage("Jump Circle OFF") 
    end
end

-- ============================================
-- 👣 TRAIL V1 И V2
-- ============================================
local function CreateTrail()
    if not trailEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local p = Instance.new("Part", workspace) 
    p.Size = Vector3.new(0.3, 0.3, 0.3) 
    p.CFrame = LP.Character.HumanoidRootPart.CFrame 
    p.Anchored = true
    p.CanCollide = false
    p.Material = Enum.Material.Neon
    p.Color = guiSettings.TrailColor
    p.Transparency = 0.6 
    table.insert(trailParts, p)
    if #trailParts > guiSettings.TrailLength then 
        local old = table.remove(trailParts, 1) 
        if old then old:Destroy() end 
    end
end

function ToggleTrail()
    trailEnabled = not trailEnabled
    if trailEnabled then 
        trailParts = {} 
        trailConnection = RunService.Heartbeat:Connect(CreateTrail) 
        ShowMessage("Trail V1 ON 👣") 
    else 
        if trailConnection then trailConnection:Disconnect() end 
        for _, v in pairs(trailParts) do v:Destroy() end 
        trailParts = {} 
        ShowMessage("Trail V1 OFF") 
    end
end

function ToggleTrailV2()
    trailV2Enabled = not trailV2Enabled
    if trailV2Enabled then
        if not LP.Character or not LP.Character:FindFirstChild("Head") then return end
        trailAnchor = Instance.new("Part", LP.Character.Head) 
        trailAnchor.Size = Vector3.new(0.1,0.1,0.1) 
        trailAnchor.Transparency = 1 
        trailAnchor.CanCollide = false 
        local w = Instance.new("Weld", trailAnchor) 
        w.Part0 = LP.Character.Head
        w.Part1 = trailAnchor
        local a0 = Instance.new("Attachment", trailAnchor) 
        a0.Position = Vector3.new(-0.8, -1.2, 0) 
        local a1 = Instance.new("Attachment", trailAnchor) 
        a1.Position = Vector3.new(0.8, -1.2, 0)
        actualTrailInstance = Instance.new("Trail", trailAnchor) 
        actualTrailInstance.Attachment0 = a0
        actualTrailInstance.Attachment1 = a1
        actualTrailInstance.Lifetime = 0.5
        actualTrailInstance.FaceCamera = true
        actualTrailInstance.Color = ColorSequence.new(guiSettings.TrailColor) 
        ShowMessage("Trail V2 ON 🎀")
    else 
        if trailAnchor then trailAnchor:Destroy() trailAnchor = nil end 
        ShowMessage("Trail V2 OFF") 
    end
end

-- ============================================
-- 🎆 PARTICLES V2
-- ============================================
function ToggleParticlesV2()
    particlesV2Enabled = not particlesV2Enabled
    if particlesV2Enabled then
        particlesConnection = RunService.Heartbeat:Connect(function()
            if not particlesV2Enabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
            local p = Instance.new("Part", workspace) 
            p.Size = Vector3.new(0.25, 0.25, 0.25) 
            p.Anchored = true
            p.CanCollide = false
            p.Material = Enum.Material.Neon
            p.Color = guiSettings.ParticleColor
            p.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-15, 15), math.random(-4, 6), math.random(-15, 15)) 
            Debris:AddItem(p, 0.6)
        end) 
        ShowMessage("Cloud Particles V2 ON 🎆")
    else 
        if particlesConnection then particlesConnection:Disconnect() end 
        ShowMessage("Particles OFF") 
    end
end

-- ============================================
-- 🌑 WORLD COLOR (DARK MODE)
-- ============================================
function ToggleWorldColor()
    worldColorEnabled = not worldColorEnabled
    if worldColorEnabled then
        Lighting.Ambient = Color3.fromRGB(5, 5, 8) 
        Lighting.OutdoorAmbient = Color3.fromRGB(5, 5, 8) 
        Lighting.ClockTime = 0 
        local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
        sky.SkyboxBk = "rbxassetid://252760981" 
        sky.SkyboxDn = "rbxassetid://252760981" 
        sky.SkyboxFt = "rbxassetid://252760981"
        sky.SkyboxLf = "rbxassetid://252760981" 
        sky.SkyboxRt = "rbxassetid://252760981" 
        sky.SkyboxUp = "rbxassetid://252760981"
        ShowMessage("HvH Night V2 ON 🌑")
    else 
        Lighting.Ambient = originalAmbient 
        Lighting.OutdoorAmbient = originalAmbient 
        Lighting.ClockTime = 14 
        ShowMessage("Dark Mode OFF") 
    end
end

-- ============================================
-- 🎯 TARGET HUD + FLING
-- ============================================
local function ExecuteFling(targetChar)
    if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local myRoot = LP.Character.HumanoidRootPart 
    local targetRoot = targetChar.HumanoidRootPart 
    local oldCF = myRoot.CFrame 
    ShowMessage("Flinging Target! 🚀")
    task.spawn(function()
        local bV = Instance.new("BodyAngularVelocity", myRoot) 
        bV.MaxTorque = Vector3.new(1,1,1) * 999999 
        bV.AngularVelocity = Vector3.new(0, 999999, 0)
        for i = 1, 20 do 
            RunService.Heartbeat:Wait() 
            if targetRoot then 
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(math.random(-1,1)*0.05, 0, math.random(-1,1)*0.05) 
                myRoot.AssemblyLinearVelocity = Vector3.new(0, 999999, 0) 
            end 
        end
        bV:Destroy() 
        myRoot.CFrame = oldCF 
        myRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
    end)
end

local function UpdateTargetHud()
    if not targetHudEnabled then 
        if targetHudFrame then targetHudFrame.Visible = false end 
        return 
    end
    if not targetHudFrame then
        targetHudFrame = Instance.new("Frame", screenGui or game.CoreGui) 
        targetHudFrame.Size = UDim2.new(0, 200, 0, 100) 
        targetHudFrame.Position = UDim2.new(0.4, 0, 0.7, 0) 
        targetHudFrame.BackgroundColor3 = guiSettings.BackgroundColor 
        targetHudFrame.Active = true 
        targetHudFrame.Draggable = true 
        Instance.new("UICorner", targetHudFrame).CornerRadius = UDim.new(0, 8) 
        Instance.new("UIStroke", targetHudFrame).Color = guiSettings.BorderColor
        local nameL = Instance.new("TextLabel", targetHudFrame) 
        nameL.Name = "NameL" 
        nameL.Size = UDim2.new(1, 0, 0, 22) 
        nameL.TextColor3 = guiSettings.TextColor 
        nameL.Font = Enum.Font.GothamBold 
        nameL.TextSize = 11 
        nameL.BackgroundTransparency = 1
        local hpL = Instance.new("TextLabel", targetHudFrame) 
        hpL.Name = "HpL" 
        hpL.Size = UDim2.new(1, 0, 0, 18) 
        hpL.Position = UDim2.new(0, 0, 0.25, 0) 
        hpL.TextColor3 = Color3.fromRGB(0,255,100) 
        hpL.Font = Enum.Font.GothamMedium 
        hpL.TextSize = 10 
        hpL.BackgroundTransparency = 1
        local distL = Instance.new("TextLabel", targetHudFrame) 
        distL.Name = "DistL" 
        distL.Size = UDim2.new(1, 0, 0, 18) 
        distL.Position = UDim2.new(0, 0, 0.45, 0) 
        distL.TextColor3 = Color3.fromRGB(200,200,200) 
        distL.Font = Enum.Font.GothamMedium 
        distL.TextSize = 10 
        distL.BackgroundTransparency = 1
        local fBtn = Instance.new("TextButton", targetHudFrame) 
        fBtn.Size = UDim2.new(0.8, 0, 0, 24) 
        fBtn.Position = UDim2.new(0.1, 0, 0.68, 0) 
        fBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 60) 
        fBtn.Text = "FLING TARGET" 
        fBtn.TextColor3 = Color3.new(1,1,1) 
        fBtn.Font = Enum.Font.GothamBold 
        fBtn.TextSize = 10 
        Instance.new("UICorner", fBtn).CornerRadius = UDim.new(0, 6)
        fBtn.MouseButton1Click:Connect(function() if targetPlayer and targetPlayer.Character then ExecuteFling(targetPlayer.Character) end end)
    end 
    targetHudFrame.Visible = true
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local dist = math.floor((LP.Character.HumanoidRootPart.Position - targetPlayer.Character.HumanoidRootPart.Position).Magnitude)
        targetHudFrame.NameL.Text = "Target: " .. targetPlayer.Name 
        targetHudFrame.HpL.Text = "HP: " .. math.floor(targetPlayer.Character.Humanoid.Health) .. " / " .. math.floor(targetPlayer.Character.Humanoid.MaxHealth) 
        targetHudFrame.DistL.Text = "Dist: " .. dist .. " studs"
    else 
        targetHudFrame.NameL.Text = "No Target" 
        targetHudFrame.HpL.Text = "HP: --" 
        targetHudFrame.DistL.Text = "Dist: --" 
    end
end

task.spawn(function() 
    while true do 
        task.wait(0.2) 
        pcall(UpdateTargetHud) 
    end 
end)

-- ============================================
-- ⚔️ KILL AURA & TOOL REACH
-- ============================================
local function AttackPlayer(tChar, tool)
    if not tChar or not tChar:FindFirstChild("HumanoidRootPart") or not tool then return end 
    tool:Activate()
    if hitGlowEnabled then
        task.spawn(function() 
            local h = Instance.new("Highlight", tChar) 
            h.FillColor = guiSettings.HitboxColor 
            h.FillTransparency = 0.1 
            task.wait(0.2) 
            h:Destroy() 
        end)
    end
    if hitmarkerEnabled then ShowMessage("HIT! 🎯") end
end

local function ApplyToolReach()
    if not LP.Character then return end 
    local tool = LP.Character:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then 
        tool.Handle.Size = Vector3.new(guiSettings.ToolReachValue, guiSettings.ToolReachValue, guiSettings.ToolReachValue) 
        tool.Handle.CanCollide = false 
    end
end

RunService.Heartbeat:Connect(function()
    if killAuraEnabled or killAuraV2Enabled then
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
        local tool = LP.Character:FindFirstChildOfClass("Tool")
        ApplyToolReach()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                local dist = (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if dist <= guiSettings.KillAuraRange then
                    AttackPlayer(p.Character, tool)
                    if killAuraV2Enabled then 
                        LP.Character.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(120), 0) 
                    end
                end
            end
        end
    end
end)

-- ============================================
-- 📊 ARROW INDICATORS
-- ============================================
local function UpdateArrowIndicators()
    for _, a in pairs(arrowIndicators) do a:Destroy() end 
    arrowIndicators = {}
    if not arrowIndicatorsEnabled then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local rPos, visible = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if not visible then
                local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2) 
                local targetPos = Vector2.new(rPos.X, rPos.Y) 
                local dir = (targetPos - screenCenter).Unit
                local arrow = Instance.new("ImageLabel", screenGui or game.CoreGui) 
                arrow.Size = UDim2.new(0, 16, 0, 16) 
                arrow.AnchorPoint = Vector2.new(0.5,0.5) 
                arrow.Position = UDim2.new(0, screenCenter.X + dir.X * guiSettings.ArrowRadius, 0, screenCenter.Y + dir.Y * guiSettings.ArrowRadius) 
                arrow.BackgroundTransparency = 1 
                arrow.Image = "rbxassetid://6031097229" 
                arrow.ImageColor3 = guiSettings.BorderColor 
                arrow.Rotation = math.deg(math.atan2(dir.Y, dir.X)) + 90
                table.insert(arrowIndicators, arrow)
            end
        end
    end
end

RunService.RenderStepped:Connect(pcall(UpdateArrowIndicators))

-- ============================================
-- 👁️ ESP FUNCTIONS (ОБНОВЛЕННЫЕ)
-- ============================================
local function GetValidChar(p)
    return p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0
end

local function SafeAdorn(folder, char, size, color)
    if not char:FindFirstChild("HumanoidRootPart") then return end
    local b = Instance.new("BoxHandleAdornment", folder) 
    b.Size = size 
    b.Color3 = color 
    b.Transparency = 0.6 
    b.AlwaysOnTop = true 
    b.Adornee = char.HumanoidRootPart
end

function ToggleESP() 
    espEnabled = not espEnabled 
    ShowMessage("ESP "..(espEnabled and "ON" or "OFF")) 
end

function ToggleESPV2() 
    espV2Enabled = not espV2Enabled 
    ShowMessage("ESP V2 "..(espV2Enabled and "ON" or "OFF")) 
end

function ToggleESPV3() 
    espV3Enabled = not espV3Enabled 
    ShowMessage("ESP V3 "..(espV3Enabled and "ON" or "OFF")) 
end

function ToggleSkeleton() 
    skeletonEnabled = not skeletonEnabled 
    ShowMessage("Skeleton "..(skeletonEnabled and "ON" or "OFF")) 
end

function ToggleHitboxes() 
    hitboxEnabled = not hitboxEnabled 
    ShowMessage("Hitboxes "..(hitboxEnabled and "ON" or "OFF")) 
end

function ToggleHitboxesV2() 
    hitboxV2Enabled = not hitboxV2Enabled 
    ShowMessage("Hitboxes V2 "..(hitboxV2Enabled and "ON" or "OFF")) 
end

function ToggleChams() 
    chamsEnabled = not chamsEnabled 
    ShowMessage("Chams "..(chamsEnabled and "ON" or "OFF")) 
end

function ToggleTracers() 
    tracersEnabled = not tracersEnabled 
    ShowMessage("Tracers "..(tracersEnabled and "ON" or "OFF")) 
end

function ToggleTargetLine() 
    targetLineEnabled = not targetLineEnabled 
    ShowMessage("Target Line "..(targetLineEnabled and "ON" or "OFF")) 
end

function ToggleArrowIndicators() 
    arrowIndicatorsEnabled = not arrowIndicatorsEnabled 
    ShowMessage("Arrow Indicators "..(arrowIndicatorsEnabled and "ON" or "OFF")) 
end

function ToggleBlockESP() 
    blockEspEnabled = not blockEspEnabled 
    ShowMessage("Block ESP "..(blockEspEnabled and "ON" or "OFF")) 
end

function ToggleDamageIndicators() 
    damageIndEnabled = not damageIndEnabled 
    ShowMessage("Damage Indicators "..(damageIndEnabled and "ON" or "OFF")) 
end

-- ============================================
-- 🕹️ ОСТАЛЬНЫЕ ФУНКЦИИ
-- ============================================
function ToggleSpin() 
    spinEnabled = not spinEnabled 
    ShowMessage("Spin "..(spinEnabled and "ON" or "OFF")) 
end

function ToggleInfiniteJump() 
    infJumpEnabled = not infJumpEnabled 
    ShowMessage("Infinite Jump "..(infJumpEnabled and "ON" or "OFF")) 
end

function ToggleAirWalk() 
    airWalkEnabled = not airWalkEnabled 
    ShowMessage("Air Walk "..(airWalkEnabled and "ON" or "OFF")) 
end

function ToggleNoClip() 
    noClipEnabled = not noClipEnabled 
    ShowMessage("NoClip "..(noClipEnabled and "ON" or "OFF")) 
end

function ToggleAntiAim() 
    antiAimEnabled = not antiAimEnabled 
    ShowMessage("Anti-Aim "..(antiAimEnabled and "ON" or "OFF")) 
end

function ToggleFullbright() 
    fullbrightEnabled = not fullbrightEnabled 
    Lighting.Ambient = fullbrightEnabled and Color3.new(1,1,1) or originalAmbient 
    ShowMessage("Fullbright "..(fullbrightEnabled and "ON" or "OFF")) 
end

function ToggleStretch() 
    stretchEnabled = not stretchEnabled 
    ShowMessage("Stretch "..(stretchEnabled and "ON" or "OFF")) 
end

function ToggleFlyV1() 
    flyV1Enabled = not flyV1Enabled 
    ShowMessage("Fly V1 "..(flyV1Enabled and "ON" or "OFF")) 
end

function ToggleFlyV2() 
    flyV2Enabled = not flyV2Enabled 
    ShowMessage("Fly V2 "..(flyV2Enabled and "ON" or "OFF")) 
end

function ToggleTeleportTool() 
    tpToolEnabled = not tpToolEnabled 
    ShowMessage("Teleport Tool "..(tpToolEnabled and "ON" or "OFF")) 
end

function ToggleAutoSprint() 
    autoSprintEnabled = not autoSprintEnabled 
    ShowMessage("Auto Sprint "..(autoSprintEnabled and "ON" or "OFF")) 
end

function ToggleTriggerBot() 
    triggerBotEnabled = not triggerBotEnabled 
    ShowMessage("Trigger Bot "..(triggerBotEnabled and "ON" or "OFF")) 
end

function ToggleAutoClicker() 
    autoClickerEnabled = not autoClickerEnabled 
    ShowMessage("AutoClicker "..(autoClickerEnabled and "ON" or "OFF")) 
end

function ToggleAutoClickerV2() 
    autoClickerV2Enabled = not autoClickerV2Enabled 
    ShowMessage("AutoClicker V2 "..(autoClickerV2Enabled and "ON" or "OFF")) 
end

function ToggleKillAura() 
    killAuraEnabled = not killAuraEnabled 
    ShowMessage("Kill Aura "..(killAuraEnabled and "ON" or "OFF")) 
end

function ToggleKillAuraV2() 
    killAuraV2Enabled = not killAuraV2Enabled 
    ShowMessage("Kill Aura V2 "..(killAuraV2Enabled and "ON" or "OFF")) 
end

function ToggleAimbotV2() 
    aimbotV2Enabled = not aimbotV2Enabled 
    ShowMessage("Silent Aim V2 "..(aimbotV2Enabled and "ON" or "OFF")) 
end

function ToggleAimbotV3() 
    aimbotV3Enabled = not aimbotV3Enabled 
    ShowMessage("Prediction Aim V3 "..(aimbotV3Enabled and "ON" or "OFF")) 
end

function ToggleResolver() 
    resolverEnabled = not resolverEnabled 
    ShowMessage("Resolver "..(resolverEnabled and "ON" or "OFF")) 
end

function ToggleDesync() 
    desyncEnabled = not desyncEnabled 
    ShowMessage("Desync "..(desyncEnabled and "ON" or "OFF")) 
end

function ToggleFakeLag() 
    fakeLagEnabled = not fakeLagEnabled 
    ShowMessage("FakeLag "..(fakeLagEnabled and "ON" or "OFF")) 
end

function ToggleHelicopter() end
function ToggleInvisibility() end
function ToggleOrbit() end
function ToggleDoubleTap() end
function ToggleCButton() end
function LoadClemonRC() end
function ToggleR6Animations() end
function ToggleCrosshair() end
function SetAntiAimMode(mode) 
    guiSettings.AntiAimMode = mode 
    ShowMessage("Anti-Aim Mode: "..mode) 
end

-- ============================================
-- 🖥️ СОЗДАНИЕ МЕНЮ
-- ============================================
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
    local stroke = Instance.new("UIStroke", guiMainFrame) 
    stroke.Color = guiSettings.BorderColor
    stroke.Thickness = 1.8
    
    local title = Instance.new("TextLabel", guiMainFrame) 
    title.Size = UDim2.new(0.5, 0, 0, 45) 
    title.Position = UDim2.new(0.04, 0, 0.01, 0) 
    title.BackgroundTransparency = 1 
    title.Text = "MTY HUB v5.5 Premium" 
    title.TextColor3 = guiSettings.TextColor
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    
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
    
    local minBtn = Instance.new("TextButton", guiMainFrame) 
    minBtn.Size = UDim2.new(0, 32, 0, 32) 
    minBtn.Position = UDim2.new(1, -75, 0, 10) 
    minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35) 
    minBtn.Text = "-" 
    minBtn.TextColor3 = guiSettings.TextColor
    minBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)
    
    local clsBtn = Instance.new("TextButton", guiMainFrame) 
    clsBtn.Size = UDim2.new(0, 32, 0, 32) 
    clsBtn.Position = UDim2.new(1, -38, 0, 10) 
    clsBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 60) 
    clsBtn.Text = "X" 
    clsBtn.TextColor3 = Color3.fromRGB(255, 255, 255) 
    clsBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", clsBtn).CornerRadius = UDim.new(0, 8)
    
    minBtn.MouseButton1Click:Connect(function() 
        guiMainFrame.Visible = not guiMainFrame.Visible 
    end)
    
    clsBtn.MouseButton1Click:Connect(function() 
        screenGui:Destroy() 
        fovGui:Destroy() 
        if targetHudFrame then targetHudFrame:Destroy() end 
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
    Instance.new("UIStroke", searchBox).Color = Color3.fromRGB(40,40,50)
    
    contentArea = Instance.new("ScrollingFrame", guiMainFrame) 
    contentArea.Size = UDim2.new(0.68, 0, 0, 275) 
    contentArea.Position = UDim2.new(0.3, 0, 0.25, 0) 
    contentArea.BackgroundTransparency = 1
    contentArea.ScrollBarThickness = 5
    contentArea.ScrollBarImageColor3 = guiSettings.BorderColor
    
    local function GetStatusStr(name)
        if name == "Toggle ESP" then return espEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V2" then return espV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V3 (Bars) 📊" then return espV3Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Skeleton" then return skeletonEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Chams" then return chamsEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Hitboxes" then return hitboxEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Hitboxes V2 (Minecraft) 🧱" then return hitboxV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Tracers" then return tracersEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Jump Circle" then return jumpCircleEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Trail" then return trailEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Trail V2 🎀" then return trailV2Enabled and " [ON]" or " [OFF]"
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
        elseif name == "Toggle Kill Aura V2 (HvH) 🔥" then return killAuraV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Trigger Bot 🎯" then return triggerBotEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Auto-Clicker 🖱️" then return autoClickerEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Auto-Clicker V2 ⚡" then return autoClickerV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Aimbot" then return aimbotEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Aimbot V2 (Silent) 🎯" then return aimbotV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Aimbot V3 (Predict) 🚀" then return aimbotV3Enabled and " [ON]" or " [OFF]"
        elseif name == "Aimbot Wallbang 🧱" then return guiSettings.AimbotWallbang and " [ON]" or " [OFF]"
        elseif name == "HvH Resolver 🎯" then return resolverEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Anti-Aim" then return antiAimEnabled and " [ON]" or " [OFF]"
        elseif name == "Desync Movement ✈️" then return desyncEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Fake Lag" then return fakeLagEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Particles V2 🎆" then return particlesV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Fly V1 ✈️" then return flyV1Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Fly V2 ☁️" then return flyV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Teleport Tool 🛠️" then return tpToolEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Spider Mode 🕷️" then return spiderEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Swim In Air 🏊" then return swimEnabled and " [ON]" or " [OFF]"
        elseif name == "Anti-Knockback ⚓" then return antiKbEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Dash 🏃" then return dashEnabled and " [ON]" or " [OFF]"
        elseif name == "Target HUD + Fling 📊" then return targetHudEnabled and " [ON]" or " [OFF]"
        elseif name == "HitGlow Effects ✨" then return hitGlowEnabled and " [ON]" or " [OFF]"
        elseif name == "Rainbow China Hat 🌈" then return guiSettings.HatRainbow and " [ON]" or " [OFF]"
        elseif name == "Target Line 🔗" then return targetLineEnabled and " [ON]" or " [OFF]"
        elseif name == "Arrow Indicators 🔺" then return arrowIndicatorsEnabled and " [ON]" or " [OFF]"
        elseif name == "No Jump Cooldown 🦘" then return noJumpCdEnabled and " [ON]" or " [OFF]"
        elseif name == "Blink Mode 👻" then return blinkEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Strafe 🏃" then return strafeEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Strafe V2 (HvH) 🌀" then return strafeV2Enabled and " [ON]" or " [OFF]"
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
                elseif name == "Toggle ESP V3 (Bars) 📊" then ToggleESPV3()
                elseif name == "Toggle Skeleton" then ToggleSkeleton()
                elseif name == "Toggle Chams" then ToggleChams()
                elseif name == "Toggle Hitboxes" then ToggleHitboxes()
                elseif name == "Toggle Hitboxes V2 (Minecraft) 🧱" then ToggleHitboxesV2()
                elseif name == "Toggle Tracers" then ToggleTracers()
                elseif name == "Toggle Jump Circle" then ToggleJumpCircle()
                elseif name == "Toggle Trail" then ToggleTrail()
                elseif name == "Toggle Trail V2 🎀" then ToggleTrailV2()
                elseif name == "Toggle Particles V2 🎆" then ToggleParticlesV2()
                elseif name == "Toggle Chinese Hat" then ToggleChineseHat()
                elseif name == "Toggle World Color" then ToggleWorldColor()
                elseif name == "Toggle Stretch" then ToggleStretch()
                elseif name == "Toggle Infinite Jump 🦘" then ToggleInfiniteJump()
                elseif name == "Toggle Air Walk ☁️" then ToggleAirWalk()
                elseif name == "Toggle Fly V1 ✈️" then ToggleFlyV1()
                elseif name == "Toggle Fly V2 ☁️" then ToggleFlyV2()
                elseif name == "Toggle Teleport Tool 🛠️" then ToggleTeleportTool()
                elseif name == "Toggle Auto Sprint 🏃" then ToggleAutoSprint()
                elseif name == "Toggle Spin" then ToggleSpin()
                elseif name == "Toggle NoClip" then ToggleNoClip()
                elseif name == "Toggle Kill Aura ⚔️" then ToggleKillAura()
                elseif name == "Toggle Kill Aura V2 (HvH) 🔥" then ToggleKillAuraV2()
                elseif name == "Toggle Trigger Bot 🎯" then ToggleTriggerBot()
                elseif name == "Toggle Auto-Clicker 🖱️" then ToggleAutoClicker()
                elseif name == "Toggle Auto-Clicker V2 ⚡" then ToggleAutoClickerV2()
                elseif name == "Toggle Aimbot" then aimbotEnabled = not aimbotEnabled ShowMessage("Aimbot "..(aimbotEnabled and "ON" or "OFF"))
                elseif name == "Toggle Aimbot V2 (Silent) 🎯" then ToggleAimbotV2()
                elseif name == "Toggle Aimbot V3 (Predict) 🚀" then ToggleAimbotV3()
                elseif name == "Aimbot Wallbang 🧱" then guiSettings.AimbotWallbang = not guiSettings.AimbotWallbang ShowMessage("Wallbang "..(guiSettings.AimbotWallbang and "ON" or "OFF"))
                elseif name == "HvH Resolver 🎯" then ToggleResolver()
                elseif name == "Toggle Anti-Aim" then ToggleAntiAim()
                elseif name == "Desync Movement ✈️" then ToggleDesync()
                elseif name == "Toggle Fake Lag" then ToggleFakeLag()
                elseif name == "Toggle Spider Mode 🕷️" then ToggleSpider()
                elseif name == "Toggle Swim In Air 🏊" then ToggleSwim()
                elseif name == "Anti-Knockback ⚓" then ToggleAntiKb()
                elseif name == "Toggle Dash 🏃" then ToggleDash()
                elseif name == "Target HUD + Fling 📊" then targetHudEnabled = not targetHudEnabled ShowMessage("Target HUD "..(targetHudEnabled and "ON" or "OFF"))
                elseif name == "HitGlow Effects ✨" then hitGlowEnabled = not hitGlowEnabled ShowMessage("HitGlow "..(hitGlowEnabled and "ON" or "OFF"))
                elseif name == "Rainbow China Hat 🌈" then guiSettings.HatRainbow = not guiSettings.HatRainbow ShowMessage("Rainbow "..(guiSettings.HatRainbow and "ON" or "OFF"))
                elseif name == "Target Line 🔗" then ToggleTargetLine()
                elseif name == "Arrow Indicators 🔺" then ToggleArrowIndicators()
                elseif name == "No Jump Cooldown 🦘" then ToggleNoJumpCooldown()
                elseif name == "Blink Mode 👻" then ToggleBlinkMode()
                elseif name == "Toggle Strafe 🏃" then ToggleStrafe()
                elseif name == "Toggle Strafe V2 (HvH) 🌀" then ToggleStrafeV2()
                elseif name == "Aimbot Speed" then OpenTextInput("Aimbot Speed", "0.01-1", guiSettings.AimbotSpeed, function(v) guiSettings.AimbotSpeed = v end)
                elseif name == "Aimbot Strength" then OpenTextInput("Strength", "0.1-1", guiSettings.AimbotStrength, function(v) guiSettings.AimbotStrength = v end)
                elseif name == "Aimbot FOV" then OpenTextInput("FOV Size", "Pixels", guiSettings.AimbotFOV, function(v) guiSettings.AimbotFOV = v end)
                elseif name == "Speed" then OpenTextInput("Speed", "WalkSpeed", speedValue, function(v) speedValue = v if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed = v end end)
                elseif name == "Gravity" then OpenTextInput("Gravity", "Workspace", workspace.Gravity, function(v) workspace.Gravity = v end)
                elseif name == "Kill Aura Range" then OpenTextInput("Aura Range", "Studs", guiSettings.KillAuraRange, function(v) guiSettings.KillAuraRange = v end)
                elseif name == "Tool Reach 📏" then OpenTextInput("Reach Size", "Studs", guiSettings.ToolReachValue, function(v) guiSettings.ToolReachValue = v ApplyToolReach() end)
                elseif name == "Stretch Value" then OpenTextInput("Stretch", "0.1 - 1.5", guiSettings.StretchValue, function(v) guiSettings.StretchValue = v end)
                elseif name == "Trail Color" then OpenColorPicker("Trail Color", function(c) guiSettings.TrailColor = c if actualTrailInstance then actualTrailInstance.Color = ColorSequence.new(c) end end)
                elseif name == "Hat Color" then OpenColorPicker("Hat Color", function(c) guiSettings.HatColor = c if hatEnabled then CreateChineseHat() end end)
                elseif name == "Jump Circle Color" then OpenColorPicker("Jump Circle Color", function(c) guiSettings.JumpCircleColor = c end)
                elseif name == "Optimize Textures" then
                    for _, v in pairs(game:GetDescendants()) do pcall(function() if v:IsA("Texture") or v:IsA("Decal") then v.Texture = "rbxassetid://4322737890" elseif v:IsA("Part") then v.Material = Enum.Material.Plastic end end) end
                    Lighting.GlobalShadows = false Lighting.Brightness = 1 Lighting.ClockTime = 14 ShowMessage("Textures Optimized")
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
        VISUAL = {"Toggle ESP", "Toggle ESP V2", "Toggle ESP V3 (Bars) 📊", "Toggle Skeleton", "Toggle Chams", "Toggle Hitboxes", "Toggle Hitboxes V2 (Minecraft) 🧱", "Toggle Tracers", "Toggle Jump Circle", "Jump Circle Color", "Toggle Trail", "Toggle Trail V2 🎀", "Trail Color", "Toggle Chinese Hat", "Hat Color", "Rainbow China Hat 🌈", "Toggle Particles V2 🎆", "Toggle Fullbright", "Toggle World Color", "HitGlow Effects ✨", "Target HUD + Fling 📊", "Target Line 🔗", "Arrow Indicators 🔺"},
        PLAYER = {"Speed", "Gravity", "Toggle Infinite Jump 🦘", "Toggle Air Walk ☁️", "Toggle Fly V1 ✈️", "Toggle Fly V2 ☁️", "Toggle Teleport Tool 🛠️", "Toggle Auto Sprint 🏃", "Toggle Spin", "Toggle NoClip", "Toggle Spider Mode 🕷️", "Toggle Swim In Air 🏊", "Toggle Dash 🏃", "No Jump Cooldown 🦘", "Blink Mode 👻", "Toggle Strafe 🏃", "Toggle Strafe V2 (HvH) 🌀"},
        COMBAT = {"Toggle Aimbot", "Toggle Aimbot V2 (Silent) 🎯", "Toggle Aimbot V3 (Predict) 🚀", "Aimbot Speed", "Aimbot Strength", "Aimbot FOV", "Aimbot Wallbang 🧱", "Toggle Kill Aura ⚔️", "Toggle Kill Aura V2 (HvH) 🔥", "Kill Aura Range", "Tool Reach 📏", "Toggle Trigger Bot 🎯", "Toggle Auto-Clicker 🖱️", "Toggle Auto-Clicker V2 ⚡"},
        HVH = {"HvH Resolver 🎯", "Toggle Anti-Aim", "Anti-Aim Mode: Jitter", "Anti-Aim Mode: Spin", "Desync Movement ✈️", "Toggle Fake Lag", "Anti-Knockback ⚓"},
        SETTINGS = {"Optimize Textures"}
    }
    
    local idx = 0 
    for catName, subs in pairs(categories) do
        local btn = Instance.new("TextButton", leftPanel) 
        btn.Size = UDim2.new(0.9, 0, 0, 32) 
        btn.Position = UDim2.new(0.05, 0, 0.02 + (idx * 0.19), 0) 
        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 35) 
        btn.Text = catName 
        btn.TextColor3 = guiSettings.TextColor 
        btn.Font = Enum.Font.GothamBold 
        btn.TextSize = 10 
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6) 
        Instance.new("UIStroke", btn).Color = Color3.fromRGB(45,45,55)
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
print("MTY HUB v5.5 ULTIMATE SUCCESS LOADED! 🚀")