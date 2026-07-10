-- MTY HUB v6.0 DELTA FULL (ВСЁ ВЕРНУЛ + IY FLING + IY GOTO + IY FLY V3)
-- Все функции: Visual, Combat, Movement, HvH, MM2, Fling, Utilities, Extreme
-- Оригинальные функции из Infinity Yield: FLING, GOTO, FLY V3
-- Адаптировано для Delta Executor

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
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ===== ПЕРЕМЕННЫЕ GUI =====
local guiMainFrame, screenGui, targetHudFrame, crosshairGui, airWalkPlatform, trailAnchor, actualTrailInstance, currentHat, hatConnection, dashButton, teleportTool = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local trailParts = {}
local searchBox, contentArea, allSubs, currentCategory = nil, nil, {}, ""
local speedValue, originalAmbient, originalOutdoor = 16, Lighting.Ambient, Lighting.OutdoorAmbient
local targetPlayer = nil
local killAuraButton, killAuraButtonGui = nil, nil
local swordTool = nil
local hiddenfling = false
local fakePingEnabled = false
local macroRecording = false
local macroActions = {}
local macroPlaying = false
local antiAFKEnabled = false
local fpsBoosterEnabled = false
local musicPlayerEnabled = false
local musicPlayerGui = nil
local minimized = false
local miniButton = nil
local miniGui = nil
local stretchGui = nil
local stretchSlider = nil
local worldColorSelected = Color3.fromRGB(130, 80, 255)
local flingAutoEnabled = false
local flingAutoConnection = nil
local walkFlingEnabled = false
local iyFlying = false
local iyFlyConnection = nil
local iyBV, iyBGyro = nil, nil
local targetHudEnabled = false
local targetLineEnabled = false
local arrowIndicatorsEnabled = false
local hitGlowEnabled = false
local blockEspEnabled = false
local damageIndEnabled = false

-- ===== НАСТРОЙКИ =====
local guiSettings = {
    BackgroundColor = Color3.fromRGB(15, 15, 17),
    BorderColor = Color3.fromRGB(130, 80, 255), 
    TextColor = Color3.fromRGB(240, 240, 245),
    Transparency = 0.05,
    BlurEnabled = false,
    BlurSize = 6,
    ESPColor = Color3.fromRGB(130, 80, 255),
    HitboxColor = Color3.fromRGB(255, 0, 100),
    ChamsColor = Color3.fromRGB(0, 255, 200),
    JumpCircleColor = Color3.fromRGB(130, 80, 255),
    TrailColor = Color3.fromRGB(0, 255, 255),
    HatColor = Color3.fromRGB(130, 80, 255),
    ParticleColor = Color3.fromRGB(130, 80, 255),
    CrosshairColor = Color3.fromRGB(0, 255, 100),
    SpinSpeed = 25, JumpCircleFadeTime = 0.8, TrailLength = 40, FakeLagAmount = 6,
    AimbotFOV = 130, AimbotSpeed = 0.25, AimbotStrength = 0.85, AimbotPart = "Head", KillAuraRange = 18,
    AimbotWallbang = true, ToolReachValue = 4, HatRainbow = false, AntiAimMode = "Spin",
    FakePingValue = 50, FakePingMode = "Static",
    MM2FOV = 150, MM2AutoShoot = true,
    FlingPower = 500,
    IYFlySpeed = 50
}

-- ===== СОСТОЯНИЯ =====
local espEnabled, espV2Enabled, espV3Enabled, espV4Enabled, espV5Enabled = false, false, false, false, false
local espV6Enabled, espV7Enabled, espV8Enabled, espV9Enabled, espV10Enabled = false, false, false, false, false
local espV11Enabled, espV12Enabled, espV13Enabled, espV14Enabled, espV15Enabled = false, false, false, false, false
local espV16Enabled, espV17Enabled, espV18Enabled, tracersEnabled, chamsEnabled = false, false, false, false, false
local hitboxEnabled, hitboxV2Enabled, skeletonEnabled, jumpCircleEnabled, trailEnabled = false, false, false, false, false
local trailV2Enabled, particlesV2Enabled, crosshairEnabled, stretchEnabled, hatEnabled = false, false, false, false, false
local swordEnabled, skyboxEnabled, noFogEnabled, noShadowsEnabled, noGrassEnabled = false, false, false, false, false
local noTreesEnabled, noCloudsEnabled, noRainEnabled, noSnowEnabled, noWindEnabled = false, false, false, false, false
local noParticlesEnabled, noDecalsEnabled, noTexturesEnabled, lowPolyEnabled, cartoonModeEnabled = false, false, false, false, false
local nightVisionEnabled, thermalVisionEnabled, worldColorEnabled, fullbrightEnabled, spinEnabled = false, false, false, false, false
local helicopterEnabled, invisibilityEnabled, noClipEnabled, antiAimEnabled, fakeLagEnabled = false, false, false, false, false
local killAuraEnabled, killAuraV2Enabled, killAuraV3Enabled, triggerBotEnabled, autoClickerEnabled = false, false, false, false, false
local autoClickerV2Enabled, infJumpEnabled, superJumpEnabled, autoSprintEnabled, airWalkEnabled = false, false, false, false, false
local flyV1Enabled, flyV2Enabled, flyV3Enabled, flyV4Enabled, flyV5Enabled = false, false, false, false, false
local tpToolEnabled, spiderEnabled, swimEnabled, dashEnabled, noJumpCdEnabled = false, false, false, false, false
local blinkEnabled, strafeEnabled, bunnyHopEnabled, ghostModeEnabled, noGravityEnabled = false, false, false, false, false
local timeFreezeEnabled, wallJumpEnabled, wallRunEnabled, wallClimbEnabled, noFallDamageEnabled = false, false, false, false, false
local waterWalkEnabled, lavaWalkEnabled, resolverEnabled, desyncEnabled, antiKbEnabled = false, false, false, false, false
local antiKbV2Enabled, antiStunEnabled, antiFreezeEnabled, antiSlowEnabled, aimbotEnabled = false, false, false, false, false
local aimbotV2Enabled, aimbotV3Enabled, aimbotV4Enabled, aimbotV5Enabled, aimbotV6Enabled = false, false, false, false, false
local aimbotV7Enabled, aimbotV8Enabled, aimbotV9Enabled, aimbotV10Enabled = false, false, false, false, false
local rageModeEnabled, godModeEnabled, oneHitKillEnabled, infiniteHealthEnabled = false, false, false, false
local infiniteShieldEnabled, noDamageEnabled, lagSwitchEnabled = false, false, false
local teleportForwardEnabled, teleportBackEnabled, teleportUpEnabled, teleportDownEnabled = false, false, false, false
local teleportMouseEnabled, autoHealEnabled, autoParryEnabled, autoDodgeEnabled = false, false, false, false
local autoReloadEnabled, criticalHitEnabled, fastReloadEnabled, noRecoilEnabled, noSpreadEnabled = false, false, false, false, false
local infiniteAmmoEnabled, killAllEnabled, kickAllEnabled = false, false, false
local iyFlyEnabled = false

-- ===== MM2 СОСТОЯНИЯ =====
local mm2EspEnabled, mm2EspV2Enabled, mm2EspRolesEnabled = false, false, false
local mm2AimbotEnabled, mm2TriggerBotEnabled, mm2KillAuraEnabled = false, false, false
local mm2KillAuraV2Enabled, mm2SilentAimEnabled, mm2AntiKnifeEnabled = false, false, false
local mm2GrabGunEnabled, mm2GrabGunV2Enabled, mm2FlingMurdererEnabled = false, false, false
local mm2FlingSheriffEnabled, mm2AutoShootEnabled, mm2SpeedHackEnabled = false, false, false
local mm2NoRecoilEnabled, mm2NoSpreadEnabled, mm2FastReloadEnabled = false, false, false
local mm2InfiniteAmmoEnabled, mm2FOVCircle, mm2FOVRadius = false, nil, 150
local mm2ShootConnection, mm2AimbotConnection, mm2GrabGunConnection, mm2KillAuraV2Connection = nil, nil, nil, nil
local mm2AutoShootButton, mm2AutoShootGui = nil, nil
local mm2LastGunPos, mm2GrabMethod, mm2FlingPower = nil, "Teleport", 500

-- ===== ПАПКИ =====
local espFolder = Instance.new("Folder", workspace) espFolder.Name = "MTY_ESP"
local espV2Folder = Instance.new("Folder", workspace) espV2Folder.Name = "MTY_ESP_V2"
local tracersFolder = Instance.new("Folder", workspace) tracersFolder.Name = "MTY_Tracers"
local chamsFolder = Instance.new("Folder", workspace) chamsFolder.Name = "MTY_Chams"
local HitboxFolder = Instance.new("Folder", workspace) HitboxFolder.Name = "MTY_Hitboxes"
local skeletonFolder = Instance.new("Folder", workspace) skeletonFolder.Name = "MTY_Skeleton"
local blockEspFolder = Instance.new("Folder", workspace) blockEspFolder.Name = "MTY_BlockESP"

-- ===== FOV GUI =====
local fovGui = Instance.new("ScreenGui", game.CoreGui) fovGui.Name = "MTY_FOV"
local fovRing = Instance.new("Frame", fovGui) fovRing.AnchorPoint = Vector2.new(0.5,0.5) fovRing.Position = UDim2.new(0.5,0,0.5,0) fovRing.BackgroundTransparency = 1 fovRing.Visible = false
local fovStroke = Instance.new("UIStroke", fovRing) fovStroke.Thickness = 1.5 fovStroke.Color = guiSettings.BorderColor

local particlesConnection, jumpCircleConnection, trailConnection, strafeConnection, bunnyHopConnection, antiAimConnection, spinConnection, helicopterConnection, noClipConnection, swimConnection, antiKbConnection, spiderConnection, fakeLagConnection, desyncConnection, wallClimbConnection, fakePingConnection, macroConnection, antiAFKConnection, fpsBoosterConnection, musicConnection, wallJumpConnection, wallRunConnection, noGravityConnection, timeFreezeConnection, skyboxConnection, autoSprintConnection, triggerBotConnection, autoClickerConnection, autoClickerV2Connection

-- ============================================
-- СИСТЕМА УВЕДОМЛЕНИЙ
-- ============================================
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
    task.spawn(function() task.wait(1.5) msg:Destroy() end)
end

-- ============================================
-- ВСПОМОГАТЕЛЬНЫЕ ОКНА
-- ============================================
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
        if n then callback(n) s:Destroy() else tb.Text = "Error" end 
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
                        target = hit 
                    end 
                end
            end
        end
    end 
    return target
end

RunService.RenderStepped:Connect(function()
    fovRing.Size = UDim2.new(0, guiSettings.AimbotFOV * 2, 0, guiSettings.AimbotFOV * 2) 
    fovRing.Visible = aimbotEnabled or aimbotV2Enabled or aimbotV3Enabled 
    fovStroke.Color = guiSettings.BorderColor
    if aimbotEnabled or aimbotV2Enabled or aimbotV3Enabled then
        local hit = FindBestTarget() 
        if hit then
            local pos = hit.Position
            if aimbotV3Enabled and hit.Parent:FindFirstChild("HumanoidRootPart") then 
                pos = pos + (hit.Parent.HumanoidRootPart.AssemblyLinearVelocity * 0.05) 
            end
            if aimbotV2Enabled then 
                local oldCF = Camera.CFrame 
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, pos) 
                task.wait() 
                Camera.CFrame = oldCF 
            else 
                local lerpSpeed = aimbotV4Enabled and 0.3 or guiSettings.AimbotSpeed
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, pos), math.clamp(lerpSpeed * guiSettings.AimbotStrength, 0.01, 1)) 
            end
        end
    end
end)

-- ============================================
-- 📊 TARGET HUD + PLAYER LIST
-- ============================================
local playerListGui = nil
local playerListFrame = nil
local playerListOpen = false

local function ExecuteFling(targetChar)
    if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local myRoot = LP.Character.HumanoidRootPart 
    local targetRoot = targetChar.HumanoidRootPart 
    ShowMessage("Flinging: " .. targetChar.Name)
    task.spawn(function()
        local bV = Instance.new("BodyAngularVelocity", myRoot) 
        bV.MaxTorque = Vector3.new(1,1,1) * 999999 
        bV.AngularVelocity = Vector3.new(0, 999999, 0)
        for i = 1, 25 do 
            RunService.Heartbeat:Wait()
            if targetRoot then 
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(math.random(-1,1)*0.1, 0, math.random(-1,1)*0.1) 
                myRoot.AssemblyLinearVelocity = Vector3.new(0, 999999, 0) 
            end
        end
        bV:Destroy() 
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
        targetHudFrame.Size = UDim2.new(0, 220, 0, 120) 
        targetHudFrame.Position = UDim2.new(0.4, 0, 0.7, 0) 
        targetHudFrame.BackgroundColor3 = guiSettings.BackgroundColor 
        targetHudFrame.Active = true 
        targetHudFrame.Draggable = true 
        Instance.new("UICorner", targetHudFrame).CornerRadius = UDim.new(0, 8) 
        Instance.new("UIStroke", targetHudFrame).Color = guiSettings.BorderColor
        
        local nameL = Instance.new("TextLabel", targetHudFrame) 
        nameL.Name = "NameL" 
        nameL.Size = UDim2.new(1, 0, 0, 25) 
        nameL.TextColor3 = guiSettings.TextColor 
        nameL.Font = Enum.Font.GothamBold 
        nameL.TextSize = 12 
        nameL.BackgroundTransparency = 1
        
        local hpL = Instance.new("TextLabel", targetHudFrame) 
        hpL.Name = "HpL" 
        hpL.Size = UDim2.new(1, 0, 0, 20) 
        hpL.Position = UDim2.new(0, 0, 0.25, 0) 
        hpL.TextColor3 = Color3.fromRGB(0,255,100) 
        hpL.Font = Enum.Font.GothamMedium 
        hpL.TextSize = 11 
        hpL.BackgroundTransparency = 1
        
        local distL = Instance.new("TextLabel", targetHudFrame) 
        distL.Name = "DistL" 
        distL.Size = UDim2.new(1, 0, 0, 20) 
        distL.Position = UDim2.new(0, 0, 0.45, 0) 
        distL.TextColor3 = Color3.fromRGB(200,200,200) 
        distL.Font = Enum.Font.GothamMedium 
        distL.TextSize = 10 
        distL.BackgroundTransparency = 1
        
        local playerListBtn = Instance.new("TextButton", targetHudFrame) 
        playerListBtn.Size = UDim2.new(0.45, 0, 0, 22) 
        playerListBtn.Position = UDim2.new(0.03, 0, 0.7, 0) 
        playerListBtn.BackgroundColor3 = guiSettings.BorderColor 
        playerListBtn.Text = "📋 Players" 
        playerListBtn.TextColor3 = Color3.new(1,1,1) 
        playerListBtn.Font = Enum.Font.GothamBold 
        playerListBtn.TextSize = 9 
        Instance.new("UICorner", playerListBtn).CornerRadius = UDim.new(0, 6)
        playerListBtn.MouseButton1Click:Connect(TogglePlayerList)
        
        local flingBtn = Instance.new("TextButton", targetHudFrame) 
        flingBtn.Size = UDim2.new(0.45, 0, 0, 22) 
        flingBtn.Position = UDim2.new(0.52, 0, 0.7, 0) 
        flingBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 60) 
        flingBtn.Text = "💥 FLING" 
        flingBtn.TextColor3 = Color3.new(1,1,1) 
        flingBtn.Font = Enum.Font.GothamBold 
        flingBtn.TextSize = 9 
        Instance.new("UICorner", flingBtn).CornerRadius = UDim.new(0, 6)
        flingBtn.MouseButton1Click:Connect(function() 
            if targetPlayer and targetPlayer.Character then 
                ExecuteFling(targetPlayer.Character) 
            else 
                ShowMessage("❌ No target selected!") 
            end 
        end)
    end
    targetHudFrame.Visible = true
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local dist = math.floor((LP.Character.HumanoidRootPart.Position - targetPlayer.Character.HumanoidRootPart.Position).Magnitude)
        targetHudFrame.NameL.Text = "🎯 " .. targetPlayer.Name 
        targetHudFrame.HpL.Text = "HP: " .. math.floor(targetPlayer.Character.Humanoid.Health) .. " / " .. math.floor(targetPlayer.Character.Humanoid.MaxHealth)
        targetHudFrame.DistL.Text = "Dist: " .. dist .. " studs"
    else 
        targetHudFrame.NameL.Text = "🎯 No Target" 
        targetHudFrame.HpL.Text = "HP: --" 
        targetHudFrame.DistL.Text = "Dist: --" 
    end
end

local function TogglePlayerList()
    playerListOpen = not playerListOpen
    if playerListOpen then
        if playerListGui then playerListGui:Destroy() end
        playerListGui = Instance.new("ScreenGui", game.CoreGui)
        playerListGui.Name = "MTY_PlayerList"
        playerListGui.ResetOnSpawn = false
        
        playerListFrame = Instance.new("Frame", playerListGui)
        playerListFrame.Size = UDim2.new(0, 180, 0, 250)
        playerListFrame.Position = UDim2.new(0.75, 0, 0.25, 0)
        playerListFrame.BackgroundColor3 = guiSettings.BackgroundColor
        Instance.new("UICorner", playerListFrame).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", playerListFrame).Color = guiSettings.BorderColor
        
        local title = Instance.new("TextLabel", playerListFrame)
        title.Size = UDim2.new(1, 0, 0, 30)
        title.Text = "👥 Players"
        title.TextColor3 = guiSettings.TextColor
        title.Font = Enum.Font.GothamBold
        title.TextScaled = true
        title.BackgroundTransparency = 1
        
        local closeBtn = Instance.new("TextButton", playerListFrame)
        closeBtn.Size = UDim2.new(0, 25, 0, 25)
        closeBtn.Position = UDim2.new(1, -30, 0, 3)
        closeBtn.Text = "X"
        closeBtn.TextColor3 = guiSettings.TextColor
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 60)
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
        closeBtn.MouseButton1Click:Connect(function()
            playerListOpen = false
            playerListGui:Destroy()
            playerListGui = nil
        end)
        
        local scroll = Instance.new("ScrollingFrame", playerListFrame)
        scroll.Size = UDim2.new(0.95, 0, 0, 200)
        scroll.Position = UDim2.new(0.025, 0, 0.15, 0)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 4
        
        local function UpdatePlayerList()
            scroll:ClearAllChildren()
            local y = 0
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP then
                    local btn = Instance.new("TextButton", scroll)
                    btn.Size = UDim2.new(1, 0, 0, 28)
                    btn.Position = UDim2.new(0, 0, 0, y)
                    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
                    btn.Text = p.Name
                    btn.TextColor3 = guiSettings.TextColor
                    btn.Font = Enum.Font.GothamMedium
                    btn.TextSize = 10
                    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
                    btn.MouseButton1Click:Connect(function()
                        targetPlayer = p
                        ShowMessage("🎯 Target: " .. p.Name)
                        playerListOpen = false
                        playerListGui:Destroy()
                        playerListGui = nil
                    end)
                    y = y + 30
                end
            end
            scroll.CanvasSize = UDim2.new(0, 0, 0, y)
        end
        UpdatePlayerList()
    else
        if playerListGui then playerListGui:Destroy() playerListGui = nil end
    end
end

task.spawn(function() 
    while true do 
        task.wait(0.2) 
        pcall(UpdateTargetHud) 
    end 
end)

-- ============================================
-- ⚔️ KILL AURA
-- ============================================
local function GetDmgRemote(tool)
    if not tool then return nil end
    for _, v in pairs(tool:GetDescendants()) do 
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then 
            local n = v.Name:lower() 
            if n:find("hit") or n:find("attack") or n:find("damage") or n:find("slash") or n:find("event") then 
                return v 
            end 
        end 
    end 
    return nil
end

local function AttackPlayer(tChar, tool)
    if not tChar or not tChar:FindFirstChild("HumanoidRootPart") or not tool then return end
    tool:Activate() 
    local r = GetDmgRemote(tool)
    if r and r:IsA("RemoteEvent") then 
        r:FireServer(tChar.HumanoidRootPart) 
        r:FireServer(tChar.Humanoid) 
    elseif r and r:IsA("RemoteFunction") then 
        r:InvokeServer(tChar.HumanoidRootPart) 
    end
    if hitGlowEnabled then 
        task.spawn(function() 
            local h = Instance.new("Highlight", tChar) 
            h.FillColor = guiSettings.HitboxColor 
            h.FillTransparency = 0.2 
            task.wait(0.2) 
            h:Destroy() 
        end) 
    end
end

local function ApplyToolReach()
    if not LP.Character then return end 
    local tool = LP.Character:FindFirstChildOfClass("Tool") 
    if tool and tool:FindFirstChild("Handle") then 
        tool.Handle.Size = Vector3.new(guiSettings.ToolReachValue, guiSettings.ToolReachValue, guiSettings.ToolReachValue) 
        tool.Handle.CanCollide = false 
    end
end

local function FindNearestTarget()
    local nearest, minDist = nil, math.huge
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = LP.Character.HumanoidRootPart.Position
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local dist = (myPos - p.Character.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = p
            end
        end
    end
    return nearest
end

function ToggleKillAura()
    killAuraEnabled = not killAuraEnabled
    if killAuraEnabled then
        if killAuraButton then killAuraButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100) killAuraButton.Text = "⚔️ ON" end
        ShowMessage("⚔️ Kill Aura ON")
    else
        if killAuraButton then killAuraButton.BackgroundColor3 = guiSettings.BorderColor killAuraButton.Text = "⚔️ OFF" end
        ShowMessage("⚔️ Kill Aura OFF")
    end
end

function ToggleKillAuraV2()
    killAuraV2Enabled = not killAuraV2Enabled
    ShowMessage("Kill Aura V2 "..(killAuraV2Enabled and "ON" or "OFF"))
end

function ToggleKillAuraV3()
    killAuraV3Enabled = not killAuraV3Enabled
    ShowMessage("Kill Aura V3 (Teleport) "..(killAuraV3Enabled and "ON" or "OFF"))
end

local function CreateKillAuraButton()
    if killAuraButtonGui then killAuraButtonGui:Destroy() end
    killAuraButtonGui = Instance.new("ScreenGui", game.CoreGui)
    killAuraButtonGui.Name = "MTY_KillAuraButton"
    killAuraButtonGui.ResetOnSpawn = false
    killAuraButton = Instance.new("TextButton", killAuraButtonGui)
    killAuraButton.Size = UDim2.new(0, 65, 0, 65)
    killAuraButton.Position = UDim2.new(0.92, 0, 0.5, 0)
    killAuraButton.BackgroundColor3 = guiSettings.BorderColor
    killAuraButton.Text = "⚔️\nOFF"
    killAuraButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    killAuraButton.Font = Enum.Font.GothamBold
    killAuraButton.TextSize = 12
    Instance.new("UICorner", killAuraButton).CornerRadius = UDim.new(0, 30)
    Instance.new("UIStroke", killAuraButton).Color = Color3.fromRGB(255, 255, 255)
    killAuraButton.MouseButton1Click:Connect(ToggleKillAura)
    killAuraButton.MouseButton2Click:Connect(ToggleKillAuraV2)
    killAuraButton.MouseButton3Click:Connect(ToggleKillAuraV3)
end

RunService.Heartbeat:Connect(function()
    if killAuraEnabled or killAuraV2Enabled or killAuraV3Enabled then
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
        local tool = LP.Character:FindFirstChildOfClass("Tool")
        ApplyToolReach()
        local target = FindNearestTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = target.Character.HumanoidRootPart
            local myRoot = LP.Character.HumanoidRootPart
            local dist = (myRoot.Position - targetRoot.Position).Magnitude
            local range = killAuraV2Enabled and (guiSettings.KillAuraRange + 4) or guiSettings.KillAuraRange
            if dist <= range then
                if killAuraV3Enabled then myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2) end
                local angle = tick() * 4
                local radius = 3
                local newPos = targetRoot.Position + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
                myRoot.CFrame = CFrame.new(newPos, targetRoot.Position)
                AttackPlayer(target.Character, tool)
                if killAuraV2Enabled then myRoot.CFrame = myRoot.CFrame * CFrame.Angles(0, math.rad(120), 0) end
            end
        end
    end
end)

-- ============================================
-- 🎩 CHINA HAT (РАДУЖНАЯ)
-- ============================================
function ToggleChineseHat()
    hatEnabled = not hatEnabled
    if hatEnabled then
        ShowMessage("🎩 China Hat ON")
        CreateChineseHat()
    else
        if currentHat then currentHat:Destroy() currentHat = nil end
        if hatConnection then hatConnection:Disconnect() hatConnection = nil end
        ShowMessage("🎩 China Hat OFF")
    end
end

function CreateChineseHat()
    if currentHat then currentHat:Destroy() end
    if hatConnection then hatConnection:Disconnect() end
    if not LP.Character or not LP.Character:FindFirstChild("Head") then return end
    currentHat = Instance.new("Part", LP.Character)
    currentHat.Name = "ChinaHat"
    currentHat.Material = Enum.Material.Neon
    currentHat.Transparency = 0.3
    currentHat.CanCollide = false
    currentHat.Massless = true
    currentHat.Size = Vector3.new(2.5, 0.4, 2.5)
    local mesh = Instance.new("SpecialMesh", currentHat)
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://1033714"
    mesh.Scale = Vector3.new(2.5, 0.8, 2.5)
    local trail = Instance.new("Trail", currentHat)
    local a0 = Instance.new("Attachment", currentHat) a0.Position = Vector3.new(-0.9, -1.2, 0)
    local a1 = Instance.new("Attachment", currentHat) a1.Position = Vector3.new(0.9, -1.2, 0)
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

function ToggleRainbowHat()
    guiSettings.HatRainbow = not guiSettings.HatRainbow
    if guiSettings.HatRainbow then
        ShowMessage("🌈 Rainbow Hat ON")
        if hatEnabled then CreateChineseHat() end
    else
        ShowMessage("🌈 Rainbow Hat OFF")
        if hatEnabled then CreateChineseHat() end
    end
end

-- ============================================
-- 🟢 JUMP CIRCLE
-- ============================================
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

-- ============================================
-- 👣 TRAIL V1 и V2
-- ============================================
function ToggleTrail()
    trailEnabled = not trailEnabled
    if trailEnabled then 
        trailParts = {} 
        trailConnection = RunService.Heartbeat:Connect(function()
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
        end) 
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
        local a0 = Instance.new("Attachment", trailAnchor) a0.Position = Vector3.new(-0.8, -1.2, 0) 
        local a1 = Instance.new("Attachment", trailAnchor) a1.Position = Vector3.new(0.8, -1.2, 0)
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
-- ☁️ PARTICLES V2
-- ============================================
function ToggleParticlesV2()
    particlesV2Enabled = not particlesV2Enabled
    if particlesV2Enabled then
        ShowMessage("☁️ Particles V2 ON")
        particlesConnection = RunService.Heartbeat:Connect(function()
            if not particlesV2Enabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
            local p = Instance.new("Part", workspace)
            p.Size = Vector3.new(0.3, 0.3, 0.3)
            p.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.new(
                math.random(-12, 12),
                math.random(-3, 6),
                math.random(-12, 12)
            )
            p.Anchored = true
            p.CanCollide = false
            p.Material = Enum.Material.Neon
            p.Color = guiSettings.ParticleColor
            p.Transparency = 0.4
            Debris:AddItem(p, 0.5)
        end)
    else
        if particlesConnection then particlesConnection:Disconnect() end
        ShowMessage("☁️ Particles V2 OFF")
    end
end

-- ============================================
-- 🌍 WORLD COLOR + GUI СТИЛЬ
-- ============================================
function ToggleWorldColor()
    worldColorEnabled = not worldColorEnabled
    if worldColorEnabled then
        Lighting.Ambient = worldColorSelected
        Lighting.OutdoorAmbient = worldColorSelected
        ShowMessage("🌍 World Color ON")
    else
        Lighting.Ambient = originalAmbient
        Lighting.OutdoorAmbient = originalOutdoor
        ShowMessage("🌍 World Color OFF")
    end
end

function OpenWorldColorPicker()
    OpenColorPicker("🌍 World Color", function(c)
        worldColorSelected = c
        if worldColorEnabled then
            Lighting.Ambient = c
            Lighting.OutdoorAmbient = c
        end
        ShowMessage("🌍 World Color Changed!")
    end)
end

-- ============================================
-- 🎨 GUI НАСТРОЙКИ
-- ============================================
local blurEffect = nil

function SetBackgroundColor(color)
    guiSettings.BackgroundColor = color
    UpdateGUIStyle()
    ShowMessage("🎨 Background Color Changed!")
end

function SetBorderColor(color)
    guiSettings.BorderColor = color
    UpdateGUIStyle()
    ShowMessage("🎨 Border Color Changed!")
end

function SetTextColor(color)
    guiSettings.TextColor = color
    UpdateGUIStyle()
    ShowMessage("🎨 Text Color Changed!")
end

function SetTransparency(value)
    guiSettings.Transparency = math.clamp(value, 0, 0.8)
    UpdateGUIStyle()
    ShowMessage("🎨 Transparency: " .. string.format("%.2f", guiSettings.Transparency))
end

function ToggleBlur()
    guiSettings.BlurEnabled = not guiSettings.BlurEnabled
    UpdateGUIStyle()
    ShowMessage("🎨 Blur " .. (guiSettings.BlurEnabled and "ON" or "OFF"))
end

function SetBlurSize(value)
    guiSettings.BlurSize = math.clamp(value, 1, 30)
    UpdateGUIStyle()
    ShowMessage("🎨 Blur Size: " .. guiSettings.BlurSize)
end

local function UpdateGUIStyle()
    if guiMainFrame then
        guiMainFrame.BackgroundColor3 = guiSettings.BackgroundColor
        guiMainFrame.BackgroundTransparency = guiSettings.Transparency
        local stroke = guiMainFrame:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color = guiSettings.BorderColor end
        local title = guiMainFrame:FindFirstChild("TextLabel")
        if title then title.TextColor3 = guiSettings.TextColor end
    end
    if blurEffect then
        blurEffect.Enabled = guiSettings.BlurEnabled
        blurEffect.Size = guiSettings.BlurSize
    end
end

-- ============================================
-- 📐 STRETCH
-- ============================================
getgenv().Resolution = { [".gg/scripters"] = 0.65 }

function ToggleStretch()
    stretchEnabled = not stretchEnabled
    if stretchEnabled then
        if not stretchGui then CreateStretchSlider() end
        stretchGui.Visible = true
        stretchConnection = RunService.RenderStepped:Connect(function()
            if not stretchEnabled then return end
            Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, getgenv().Resolution[".gg/scripters"], 0, 0, 0, 1)
        end)
        ShowMessage("📐 Stretch ON (" .. string.format("%.2f", getgenv().Resolution[".gg/scripters"]) .. "x)")
    else
        if stretchConnection then stretchConnection:Disconnect() end
        if stretchGui then stretchGui.Visible = false end
        ShowMessage("📐 Stretch OFF")
    end
end

function SetStretchValue(val)
    getgenv().Resolution[".gg/scripters"] = math.clamp(val, 0.3, 1.7)
end

function CreateStretchSlider()
    stretchGui = Instance.new("ScreenGui", game.CoreGui)
    stretchGui.Name = "MTY_StretchSlider"
    stretchGui.ResetOnSpawn = false
    local frame = Instance.new("Frame", stretchGui)
    frame.Size = UDim2.new(0, 200, 0, 40)
    frame.Position = UDim2.new(0.5, -100, 0.85, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
    frame.BackgroundTransparency = 0.2
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", frame).Color = guiSettings.BorderColor
    stretchSlider = Instance.new("TextLabel", frame)
    stretchSlider.Size = UDim2.new(0.5, 0, 1, 0)
    stretchSlider.Position = UDim2.new(0, 0, 0, 0)
    stretchSlider.Text = "Stretch: " .. string.format("%.2f", getgenv().Resolution[".gg/scripters"])
    stretchSlider.TextColor3 = guiSettings.TextColor
    stretchSlider.Font = Enum.Font.GothamBold
    stretchSlider.TextSize = 12
    stretchSlider.BackgroundTransparency = 1
    local sliderBg = Instance.new("Frame", frame)
    sliderBg.Size = UDim2.new(0.4, 0, 0.3, 0)
    sliderBg.Position = UDim2.new(0.55, 0, 0.35, 0)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 4)
    local fill = Instance.new("Frame", sliderBg)
    fill.Size = UDim2.new(getgenv().Resolution[".gg/scripters"] / 2, 0, 1, 0)
    fill.BackgroundColor3 = guiSettings.BorderColor
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)
    local drag = Instance.new("TextButton", sliderBg)
    drag.Size = UDim2.new(0, 14, 0, 14)
    drag.Position = UDim2.new(getgenv().Resolution[".gg/scripters"] / 2 - 0.01, 0, 0.5, -7)
    drag.BackgroundColor3 = guiSettings.BorderColor
    Instance.new("UICorner", drag).CornerRadius = UDim.new(0, 7)
    drag.Text = ""
    local dragging = false
    drag.MouseButton1Down:Connect(function() dragging = true end)
    drag.MouseButton1Up:Connect(function() dragging = false end)
    drag.MouseMoved:Connect(function(x, y)
        if dragging then
            local relX = (x - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
            local val = math.clamp(relX * 2, 0.3, 1.7)
            getgenv().Resolution[".gg/scripters"] = val
            fill.Size = UDim2.new(val / 2, 0, 1, 0)
            drag.Position = UDim2.new(val / 2 - 0.01, 0, 0.5, -7)
            stretchSlider.Text = "Stretch: " .. string.format("%.2f", val)
        end
    end)
    stretchGui.Visible = false
end

-- ============================================
-- 🗡️ CLASSIC SWORD
-- ============================================
function ToggleSword()
    swordEnabled = not swordEnabled
    if swordEnabled then CreateSword() ShowMessage("🗡️ Classic Sword ON")
    else RemoveSword() ShowMessage("🗡️ Classic Sword OFF") end
end

function CreateSword()
    RemoveSword()
    local plr = game.Players.LocalPlayer
    swordTool = Instance.new("Tool", plr.Backpack)
    swordTool.GripPos = Vector3.new(0, 0, -1.5)
    swordTool.GripForward = Vector3.new(0, -1, 0)
    swordTool.GripRight = Vector3.new(1, 0, 0)
    swordTool.GripUp = Vector3.new(0, 0, 1)
    swordTool.Name = "ClassicSword"
    swordTool.TextureId = "rbxasset://Textures/Sword128.png"
    swordTool.RequiresHandle = true
    swordTool.CanBeDropped = true
    local k = Instance.new("Part", swordTool)
    k.Name = "Handle"
    k.Size = Vector3.new(1, 0.8, 4)
    k.Anchored = false
    k.CanCollide = false
    local mesh = Instance.new("SpecialMesh", k)
    mesh.MeshId = "rbxasset://fonts/sword.mesh"
    mesh.TextureId = "rbxasset://textures/SwordTexture.png" 
    mesh.Scale = Vector3.new(1, 1, 1) 
    mesh.Offset = Vector3.new(0, 0, 0)
    mesh.VertexColor = Vector3.new(1, 1, 1)
    local Unsheath = Instance.new("Sound", k)
    Unsheath.SoundId = "http://www.roblox.com/asset/?id=12222225"
    Unsheath.Volume = "1"
    Unsheath.TimePosition = 0
    local SwordSlash = Instance.new("Sound", k)
    SwordSlash.SoundId = "http://www.roblox.com/asset/?id=12222216"
    SwordSlash.Volume = "1"
    SwordSlash.TimePosition = 0
    local l = Instance.new("Animation", swordTool)
    l.AnimationId = "rbxassetid://94161088"
    local m = plr.Character.Humanoid:LoadAnimation(l)
    local db = true
    local da = false
    swordTool.Equipped:Connect(function()
        Unsheath:Play()
        wait(1)
        swordTool.Activated:Connect(function()
            if db == true then
                db = false
                SwordSlash:Play()
                m:Play()
                wait()
                da = true
                db = true
                wait(2)
                da = false
                m:Stop()
            end
        end)
    end)
    k.Touched:Connect(function(n)
        if da == true then
            local o = n.Parent:FindFirstChild("Humanoid")
            if o ~= nil then
                local p = game.Players:FindFirstChild(n.Parent.Name)
                for j = 1, 10 do
                    if p.Name ~= "FunnyVideo15" then
                        if game:GetService("ReplicatedStorage"):FindFirstChild("juisdfj0i32i0eidsuf0iok") then
                            hiddenfling = true
                        else
                            hiddenfling = true
                            local detection = Instance.new("Decal")
                            detection.Name = "juisdfj0i32i0eidsuf0iok"
                            detection.Parent = game:GetService("ReplicatedStorage")
                            local function fling()
                                local hrp, c, vel, movel = nil, nil, nil, 0.1
                                while true do
                                    game:GetService("RunService").Heartbeat:Wait()
                                    if hiddenfling then
                                        local lp = game.Players.LocalPlayer
                                        while hiddenfling and not (c and c.Parent and hrp and hrp.Parent) do
                                            game:GetService("RunService").Heartbeat:Wait()
                                            c = lp.Character
                                            hrp = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
                                        end
                                        if hiddenfling then
                                            vel = hrp.Velocity
                                            hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
                                            game:GetService("RunService").RenderStepped:Wait()
                                            if c and c.Parent and hrp and hrp.Parent then
                                                hrp.Velocity = vel
                                            end
                                            game:GetService("RunService").Stepped:Wait()
                                            if c and c.Parent and hrp and hrp.Parent then
                                                hrp.Velocity = vel + Vector3.new(0, movel, 0)
                                                movel = movel * -1
                                            end
                                        end
                                    end
                                end
                            end
                            fling()
                        end
                    end 
                end
            end 
        end
        wait(2)
        hiddenfling = false
    end)
end

function RemoveSword()
    if swordTool then swordTool:Destroy() swordTool = nil end
    hiddenfling = false
end

-- ============================================
-- 🌍 МИР И ОКРУЖЕНИЕ
-- ============================================
function ToggleSkybox()
    skyboxEnabled = not skyboxEnabled
    if skyboxEnabled then
        local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
        sky.SkyboxBk = "rbxassetid://252760981"
        sky.SkyboxDn = "rbxassetid://252760981"
        sky.SkyboxFt = "rbxassetid://252760981"
        sky.SkyboxLf = "rbxassetid://252760981"
        sky.SkyboxRt = "rbxassetid://252760981"
        sky.SkyboxUp = "rbxassetid://252760981"
        ShowMessage("🌤️ Skybox Changed")
    else
        local sky = Lighting:FindFirstChildOfClass("Sky")
        if sky then sky:Destroy() end
        ShowMessage("🌤️ Skybox Reset")
    end
end

function ToggleNoFog()
    noFogEnabled = not noFogEnabled
    Lighting.FogEnd = noFogEnabled and 999999 or 100000
    ShowMessage("🌫️ No Fog " .. (noFogEnabled and "ON" or "OFF"))
end

function ToggleNoShadows()
    noShadowsEnabled = not noShadowsEnabled
    Lighting.GlobalShadows = not noShadowsEnabled
    ShowMessage("🌑 No Shadows " .. (noShadowsEnabled and "ON" or "OFF"))
end

function ToggleNoGrass()
    noGrassEnabled = not noGrassEnabled
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Terrain") then v:ClearAllCells() end
    end
    ShowMessage("🌿 No Grass " .. (noGrassEnabled and "ON" or "OFF"))
end

function ToggleNoTrees()
    noTreesEnabled = not noTreesEnabled
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find("tree") then v:Destroy() end
    end
    ShowMessage("🌳 No Trees " .. (noTreesEnabled and "ON" or "OFF"))
end

function ToggleNoClouds()
    noCloudsEnabled = not noCloudsEnabled
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Part") and v.Name:lower():find("cloud") then v.Transparency = noCloudsEnabled and 1 or 0 end
    end
    ShowMessage("☁️ No Clouds " .. (noCloudsEnabled and "ON" or "OFF"))
end

function ToggleNoRain()
    noRainEnabled = not noRainEnabled
    Lighting.RainIntensity = noRainEnabled and 0 or 1
    ShowMessage("☔ No Rain " .. (noRainEnabled and "ON" or "OFF"))
end

function ToggleNoSnow()
    noSnowEnabled = not noSnowEnabled
    Lighting.SnowIntensity = noSnowEnabled and 0 or 1
    ShowMessage("❄️ No Snow " .. (noSnowEnabled and "ON" or "OFF"))
end

function ToggleNoWind()
    noWindEnabled = not noWindEnabled
    ShowMessage("💨 No Wind " .. (noWindEnabled and "ON" or "OFF"))
end

function ToggleNoParticles()
    noParticlesEnabled = not noParticlesEnabled
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") then v.Enabled = not noParticlesEnabled end
    end
    ShowMessage("✨ No Particles " .. (noParticlesEnabled and "ON" or "OFF"))
end

function ToggleNoDecals()
    noDecalsEnabled = not noDecalsEnabled
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Decal") then v.Transparency = noDecalsEnabled and 1 or 0 end
    end
    ShowMessage("🖼️ No Decals " .. (noDecalsEnabled and "ON" or "OFF"))
end

function ToggleNoTextures()
    noTexturesEnabled = not noTexturesEnabled
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Texture = noTexturesEnabled and "" or nil end
    end
    ShowMessage("🎨 No Textures " .. (noTexturesEnabled and "ON" or "OFF"))
end

function ToggleLowPoly()
    lowPolyEnabled = not lowPolyEnabled
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = lowPolyEnabled and Enum.Material.SmoothPlastic or Enum.Material.Plastic end
    end
    ShowMessage("📐 Low Poly " .. (lowPolyEnabled and "ON" or "OFF"))
end

function ToggleCartoonMode()
    cartoonModeEnabled = not cartoonModeEnabled
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = cartoonModeEnabled and Enum.Material.Neon or Enum.Material.Plastic end
    end
    ShowMessage("🎬 Cartoon Mode " .. (cartoonModeEnabled and "ON" or "OFF"))
end

function ToggleNightVision()
    nightVisionEnabled = not nightVisionEnabled
    if nightVisionEnabled then
        Lighting.Ambient = Color3.fromRGB(0, 50, 0)
        Lighting.Brightness = 0.1
        ShowMessage("🌙 Night Vision ON")
    else
        Lighting.Ambient = originalAmbient
        Lighting.Brightness = 1
        ShowMessage("🌙 Night Vision OFF")
    end
end

function ToggleThermalVision()
    thermalVisionEnabled = not thermalVisionEnabled
    if thermalVisionEnabled then
        Lighting.Ambient = Color3.fromRGB(255, 0, 0)
        Lighting.Brightness = 0.5
        ShowMessage("🔥 Thermal Vision ON")
    else
        Lighting.Ambient = originalAmbient
        Lighting.Brightness = 1
        ShowMessage("🔥 Thermal Vision OFF")
    end
end

function ToggleFullbright()
    fullbrightEnabled = not fullbrightEnabled
    Lighting.Ambient = fullbrightEnabled and Color3.new(1,1,1) or originalAmbient
    Lighting.OutdoorAmbient = fullbrightEnabled and Color3.new(1,1,1) or originalOutdoor
    ShowMessage("☀️ Fullbright " .. (fullbrightEnabled and "ON" or "OFF"))
end

function ToggleCrosshair()
    crosshairEnabled = not crosshairEnabled
    if crosshairEnabled then
        crosshairGui = Instance.new("ScreenGui", game.CoreGui)
        crosshairGui.Name = "MTY_Crosshair"
        local size, gap, thick = 25, 10, 2
        local function makeBar(w, h, x, y)
            local b = Instance.new("Frame", crosshairGui)
            b.Size = UDim2.new(0, w, 0, h)
            b.Position = UDim2.new(0.5, x, 0.5, y)
            b.BackgroundColor3 = guiSettings.CrosshairColor
            b.BorderSizePixel = 0
        end
        makeBar(thick, size, -thick/2, -gap - size)
        makeBar(thick, size, -thick/2, gap)
        makeBar(size, thick, -gap - size, -thick/2)
        makeBar(size, thick, gap, -thick/2)
        ShowMessage("🎯 Crosshair ON")
    else
        if crosshairGui then crosshairGui:Destroy() end
        ShowMessage("🎯 Crosshair OFF")
    end
end

-- ============================================
-- 🏃 ДВИЖЕНИЕ
-- ============================================
function SetSpeed(val)
    speedValue = val
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = val
    end
    ShowMessage("🏃 Speed: " .. val)
end

function SetGravity(val)
    workspace.Gravity = val
    ShowMessage("🌍 Gravity: " .. val)
end

function ToggleInfiniteJump()
    infJumpEnabled = not infJumpEnabled
    if infJumpEnabled then
        UserInputService.JumpRequest:Connect(function()
            if infJumpEnabled and LP.Character and LP.Character:FindFirstChild("Humanoid") then
                LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        ShowMessage("🦘 Infinite Jump ON")
    else ShowMessage("🦘 Infinite Jump OFF") end
end

function ToggleSuperJump()
    superJumpEnabled = not superJumpEnabled
    if superJumpEnabled and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.JumpPower = 150
        ShowMessage("🚀 Super Jump ON")
    else
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.JumpPower = 50
        end
        ShowMessage("🚀 Super Jump OFF")
    end
end

function ToggleAirWalk()
    airWalkEnabled = not airWalkEnabled
    if airWalkEnabled then
        ShowMessage("☁️ Air Walk ON")
        task.spawn(function()
            while airWalkEnabled do
                task.wait()
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    if not airWalkPlatform then
                        airWalkPlatform = Instance.new("Part", workspace)
                        airWalkPlatform.Size = Vector3.new(6, 0.5, 6)
                        airWalkPlatform.Anchored = true
                        airWalkPlatform.Transparency = 1
                    end
                    airWalkPlatform.CFrame = CFrame.new(
                        LP.Character.HumanoidRootPart.Position.X,
                        LP.Character.HumanoidRootPart.Position.Y - 2.8,
                        LP.Character.HumanoidRootPart.Position.Z
                    )
                end
            end
            if airWalkPlatform then airWalkPlatform:Destroy() end
        end)
    else
        if airWalkPlatform then airWalkPlatform:Destroy() end
        ShowMessage("☁️ Air Walk OFF")
    end
end

function ToggleFlyV1()
    flyV1Enabled = not flyV1Enabled
    if flyV1Enabled then
        task.spawn(function()
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e5, 135, 1e5)
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
        ShowMessage("✈️ Fly V1 Activated")
    else ShowMessage("✈️ Fly V1 Disabled") end
end

function ToggleFlyV2()
    flyV2Enabled = not flyV2Enabled
    if flyV2Enabled then
        task.spawn(function()
            while flyV2Enabled do
                task.wait()
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    local root = LP.Character.HumanoidRootPart
                    local hum = LP.Character.Humanoid
                    local move = hum.MoveDirection
                    local camLook = Camera.CFrame.LookVector
                    if move.Magnitude > 0 then
                        root.AssemblyLinearVelocity = Vector3.new(move.X * speedValue * 2, camLook.Y * speedValue * 2, move.Z * speedValue * 2)
                    else
                        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end)
        ShowMessage("☁️ Fly V2 Activated")
    else ShowMessage("☁️ Fly V2 Disabled") end
end

-- ============================================
-- ✈️ IY FLY V3 (ОРИГИНАЛЬНЫЙ ИЗ INFINITE YIELD)
-- ============================================
local iyFlyButton = nil
local iyFlyGui = nil

function ToggleIYFly()
    iyFlyEnabled = not iyFlyEnabled
    if iyFlyEnabled then
        if iyFlyGui then iyFlyGui:Destroy() end
        iyFlyGui = Instance.new("ScreenGui", game.CoreGui)
        iyFlyGui.Name = "MTY_IYFly"
        iyFlyGui.ResetOnSpawn = false
        
        iyFlyButton = Instance.new("TextButton", iyFlyGui)
        iyFlyButton.Size = UDim2.new(0, 60, 0, 60)
        iyFlyButton.Position = UDim2.new(0.82, 0, 0.4, 0)
        iyFlyButton.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
        iyFlyButton.Text = "FLY"
        iyFlyButton.TextColor3 = Color3.new(1,1,1)
        iyFlyButton.Font = Enum.Font.GothamBold
        iyFlyButton.TextSize = 14
        Instance.new("UICorner", iyFlyButton).CornerRadius = UDim.new(0, 30)
        iyFlyButton.Draggable = true
        
        iyFlyButton.MouseButton1Click:Connect(function()
            iyFlying = not iyFlying
            if iyFlying then
                iyFlyButton.Text = "FLYING"
                iyFlyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                StartIYFly()
            else
                iyFlyButton.Text = "FLY"
                iyFlyButton.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
                StopIYFly()
            end
        end)
        ShowMessage("✈️ IY Fly V3 ON")
    else
        if iyFlyGui then iyFlyGui:Destroy() iyFlyGui = nil end
        iyFlyButton = nil
        StopIYFly()
        ShowMessage("✈️ IY Fly V3 OFF")
    end
end

local function StartIYFly()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LP.Character.HumanoidRootPart
    local humanoid = LP.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid:PlatformStand(true) end
    iyBV = Instance.new("BodyVelocity", root)
    iyBV.MaxForce = Vector3.new(9e4, 9e4, 9e4)
    iyBV.Velocity = Vector3.new(0, 0, 0)
    iyBGyro = Instance.new("BodyGyro", root)
    iyBGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
    iyBGyro.CFrame = root.CFrame
    iyFlyConnection = RunService.Heartbeat:Connect(function()
        if not iyFlying or not root or not iyBV or not iyBGyro then return end
        iyBGyro.CFrame = Camera.CFrame
        local moveDir = humanoid and humanoid.MoveDirection or Vector3.new(0,0,0)
        if moveDir.Magnitude > 0 then
            local camCF = Camera.CFrame
            local flyDir = (camCF.RightVector * (moveDir:Dot(camCF.RightVector))) + (camCF.LookVector * (moveDir:Dot(camCF.LookVector)))
            if flyDir.Magnitude > 0 then flyDir = flyDir.Unit end
            iyBV.Velocity = flyDir * guiSettings.IYFlySpeed
        else
            iyBV.Velocity = Vector3.new(0, 0.1, 0)
        end
    end)
end

local function StopIYFly()
    iyFlying = false
    if iyFlyConnection then iyFlyConnection:Disconnect() iyFlyConnection = nil end
    if iyBV then iyBV:Destroy() iyBV = nil end
    if iyBGyro then iyBGyro:Destroy() iyBGyro = nil end
    if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character:FindFirstChildOfClass("Humanoid"):PlatformStand(false)
    end
end

-- ============================================
-- 🎯 IY GOTO (ОРИГИНАЛЬНЫЙ ИЗ INFINITE YIELD)
-- ============================================
function OpenIYGoto()
    local s = Instance.new("ScreenGui", game.CoreGui) s.Name = "MTY_GotoGUI"
    local f = Instance.new("Frame", s) f.Size = UDim2.new(0, 240, 0, 130) f.Position = UDim2.new(0.5, -120, 0.2, 0) f.BackgroundColor3 = Color3.fromRGB(15, 15, 17) f.Active = true f.Draggable = true
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10) 
    local stroke = Instance.new("UIStroke", f) stroke.Color = Color3.fromRGB(130, 80, 255) stroke.Thickness = 1.5

    local title = Instance.new("TextLabel", f) title.Size = UDim2.new(1, 0, 0, 30) title.Text = "IY GOTO ENGINE" title.TextColor3 = Color3.fromRGB(240, 240, 245) title.Font = Enum.Font.GothamBold title.TextSize = 12 title.BackgroundTransparency = 1
    local tb = Instance.new("TextBox", f) tb.Size = UDim2.new(0.85, 0, 0, 30) tb.Position = UDim2.new(0.075, 0, 0.35, 0) tb.BackgroundColor3 = Color3.fromRGB(25, 25, 30) tb.Text = "" tb.PlaceholderText = "Enter Player Name..." tb.TextColor3 = Color3.fromRGB(240, 240, 245) tb.Font = Enum.Font.GothamMedium tb.TextSize = 11 Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
    local btn = Instance.new("TextButton", f) btn.Size = UDim2.new(0.5, 0, 0, 30) btn.Position = UDim2.new(0.25, 0, 0.68, 0) btn.BackgroundColor3 = Color3.fromRGB(130, 80, 255) btn.Text = "TELEPORT ⚡" btn.TextColor3 = Color3.new(1,1,1) btn.Font = Enum.Font.GothamBold btn.TextSize = 11 Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local c = Instance.new("TextButton", f) c.Size = UDim2.new(0, 24, 0, 22) c.Position = UDim2.new(1, -28, 0, 4) c.Text = "X" c.TextColor3 = Color3.new(1,1,1) c.BackgroundColor3 = Color3.fromRGB(40,40,45) Instance.new("UICorner", c).CornerRadius = UDim.new(0,4)
    c.MouseButton1Click:Connect(function() s:Destroy() end)

    local function GetPlayer(name)
        name = name:lower()
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower():sub(1, #name) == name or p.DisplayName:lower():sub(1, #name) == name then return p end
        end return nil
    end

    btn.MouseButton1Click:Connect(function()
        local target = GetPlayer(tb.Text)
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then 
            btn.Text = "Not Found!" 
            task.wait(1) 
            btn.Text = "TELEPORT ⚡" 
            return 
        end
        if target == LP then 
            btn.Text = "It's you!" 
            task.wait(1) 
            btn.Text = "TELEPORT ⚡" 
            return 
        end
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            btn.Text = "SUCCESS!" 
            task.wait(0.5) 
            btn.Text = "TELEPORT ⚡"
        end
    end)
end

-- ============================================
-- 💥 IY FLING (ОРИГИНАЛЬНЫЙ ИЗ INFINITE YIELD)
-- ============================================
function OpenIYFling()
    local s = Instance.new("ScreenGui", game.CoreGui) s.Name = "MTY_IYFling"
    local f = Instance.new("Frame", s) f.Size = UDim2.new(0, 240, 0, 140) f.Position = UDim2.new(0.5, -120, 0.4, 0) f.BackgroundColor3 = Color3.fromRGB(15, 15, 17) f.Active = true f.Draggable = true
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10) 
    local stroke = Instance.new("UIStroke", f) stroke.Color = Color3.fromRGB(130, 80, 255) stroke.Thickness = 1.5
    
    local title = Instance.new("TextLabel", f) title.Size = UDim2.new(1, 0, 0, 30) title.Text = "IY FLING ENGINE" title.TextColor3 = Color3.fromRGB(240, 240, 245) title.Font = Enum.Font.GothamBold title.TextSize = 13 title.BackgroundTransparency = 1
    local tb = Instance.new("TextBox", f) tb.Size = UDim2.new(0.85, 0, 0, 30) tb.Position = UDim2.new(0.075, 0, 0.3, 0) tb.BackgroundColor3 = Color3.fromRGB(25, 25, 30) tb.Text = "" tb.PlaceholderText = "Enter Player Name..." tb.TextColor3 = Color3.fromRGB(240, 240, 245) tb.Font = Enum.Font.GothamMedium tb.TextSize = 11 Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
    local btn = Instance.new("TextButton", f) btn.Size = UDim2.new(0.5, 0, 0, 30) btn.Position = UDim2.new(0.25, 0, 0.65, 0) btn.BackgroundColor3 = Color3.fromRGB(130, 80, 255) btn.Text = "LAUNCH🚀" btn.TextColor3 = Color3.new(1,1,1) btn.Font = Enum.Font.GothamBold btn.TextSize = 12 Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local c = Instance.new("TextButton", f) c.Size = UDim2.new(0, 24, 0, 22) c.Position = UDim2.new(1, -28, 0, 4) c.Text = "X" c.TextColor3 = Color3.new(1,1,1) c.BackgroundColor3 = Color3.fromRGB(40,40,45) Instance.new("UICorner", c).CornerRadius = UDim.new(0,4)
    c.MouseButton1Click:Connect(function() s:Destroy() end)

    local function GetPlayer(name)
        name = name:lower()
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower():sub(1, #name) == name or p.DisplayName:lower():sub(1, #name) == name then return p end
        end return nil
    end

    btn.MouseButton1Click:Connect(function()
        local target = GetPlayer(tb.Text)
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then 
            btn.Text = "Not found!" 
            task.wait(1) 
            btn.Text = "LAUNCH🚀" 
            return 
        end
        if target == LP then 
            btn.Text = "Can't fling self!" 
            task.wait(1) 
            btn.Text = "LAUNCH🚀" 
            return 
        end
        
        local tChar = target.Character 
        local tRoot = tChar.HumanoidRootPart
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
        local myRoot = LP.Character.HumanoidRootPart 
        local oldCF = myRoot.CFrame
        
        btn.Text = "FLINGING..." 
        btn.BackgroundColor3 = Color3.fromRGB(200, 40, 60)
        
        task.spawn(function()
            local bV = Instance.new("BodyAngularVelocity", myRoot) 
            bV.MaxTorque = Vector3.new(1,1,1) * 9999999 
            bV.AngularVelocity = Vector3.new(0, 9999999, 0)
            for i = 1, 45 do 
                RunService.Heartbeat:Wait()
                if tRoot and myRoot then 
                    myRoot.CFrame = tRoot.CFrame * CFrame.new(math.random(-1,1)*0.05, 0, math.random(-1,1)*0.05) 
                    myRoot.AssemblyLinearVelocity = Vector3.new(0, 999999, 0) 
                end
            end
            bV:Destroy() 
            myRoot.CFrame = oldCF 
            myRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
            btn.Text = "LAUNCH🚀" 
            btn.BackgroundColor3 = Color3.fromRGB(130, 80, 255)
        end)
    end)
end

-- ============================================
-- 🏃 FLY V3 (ОСТАЛЬНЫЕ ФУНКЦИИ ДВИЖЕНИЯ)
-- ============================================
function ToggleFlyV3()
    flyV3Enabled = not flyV3Enabled
    if flyV3Enabled then
        task.spawn(function()
            while flyV3Enabled do
                task.wait()
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    local root = LP.Character.HumanoidRootPart
                    local hum = LP.Character.Humanoid
                    local move = hum.MoveDirection
                    if move.Magnitude > 0 then
                        root.AssemblyLinearVelocity = move * speedValue * 3
                    else
                        root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
                    end
                end
            end
        end)
        ShowMessage("🌊 Fly V3 (Smooth) Activated")
    else ShowMessage("🌊 Fly V3 Disabled") end
end

function ToggleFlyV4()
    flyV4Enabled = not flyV4Enabled
    if flyV4Enabled then
        noClipEnabled = true
        flyV3Enabled = true
        ToggleFlyV3()
        ShowMessage("🌀 Fly V4 (No Clip) Activated")
    else
        noClipEnabled = false
        flyV3Enabled = false
        ShowMessage("🌀 Fly V4 Disabled")
    end
end

function ToggleFlyV5()
    flyV5Enabled = not flyV5Enabled
    if flyV5Enabled then
        task.spawn(function()
            while flyV5Enabled do
                task.wait()
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    local root = LP.Character.HumanoidRootPart
                    local hum = LP.Character.Humanoid
                    local move = hum.MoveDirection
                    if move.Magnitude > 0 then
                        root.AssemblyLinearVelocity = move * speedValue * 5
                    else
                        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end)
        ShowMessage("⚡ Fly V5 (Speed) Activated")
    else ShowMessage("⚡ Fly V5 Disabled") end
end

function ToggleTeleportTool()
    tpToolEnabled = not tpToolEnabled
    if tpToolEnabled then
        teleportTool = Instance.new("Tool", LP.Backpack)
        teleportTool.RequiresHandle = false
        teleportTool.Name = "MTY TP Tool 🛠️"
        teleportTool.Activated:Connect(function()
            local m = LP:GetMouse()
            if m and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.CFrame = CFrame.new(m.Hit.Position + Vector3.new(0,3,0))
            end
        end)
        ShowMessage("🛠️ Teleport Tool Added")
    else
        if teleportTool then teleportTool:Destroy() end
        ShowMessage("🛠️ Teleport Tool Removed")
    end
end

function ToggleAutoSprint()
    autoSprintEnabled = not autoSprintEnabled
    if autoSprintEnabled then
        autoSprintConnection = RunService.Heartbeat:Connect(function()
            if LP.Character and LP.Character:FindFirstChild("Humanoid") then
                LP.Character.Humanoid.WalkSpeed = speedValue * 1.6
            end
        end)
        ShowMessage("🏃 Auto Sprint ON")
    else
        if autoSprintConnection then autoSprintConnection:Disconnect() end
        ShowMessage("🏃 Auto Sprint OFF")
    end
end

function ToggleSpin()
    spinEnabled = not spinEnabled
    if spinEnabled then
        spinConnection = RunService.Heartbeat:Connect(function()
            if spinEnabled and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.CFrame = CFrame.new(LP.Character.HumanoidRootPart.Position) * CFrame.Angles(0, math.rad(guiSettings.SpinSpeed), 0)
            end
        end)
        ShowMessage("🌀 Spin ON")
    else
        if spinConnection then spinConnection:Disconnect() end
        ShowMessage("🌀 Spin OFF")
    end
end

function ToggleNoClip()
    noClipEnabled = not noClipEnabled
    if noClipEnabled then
        noClipConnection = RunService.Stepped:Connect(function()
            if LP.Character then
                for _, v in pairs(LP.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
        ShowMessage("🚫 NoClip ON")
    else
        if noClipConnection then noClipConnection:Disconnect() end
        ShowMessage("🚫 NoClip OFF")
    end
end

function ToggleSpider()
    spiderEnabled = not spiderEnabled 
    ShowMessage("🕷️ Spider Mode "..(spiderEnabled and "ON" or "OFF"))
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
        if spiderConnection then spiderConnection:Disconnect() end
    end
end

function ToggleSwim()
    swimEnabled = not swimEnabled 
    ShowMessage("🏊 Swim In Air "..(swimEnabled and "ON" or "OFF"))
    if swimEnabled then
        swimConnection = RunService.Heartbeat:Connect(function()
            if swimEnabled and LP.Character and LP.Character:FindFirstChild("Humanoid") then 
                LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming) 
            end
        end)
    else
        if swimConnection then swimConnection:Disconnect() end
    end
end

function ToggleDash()
    dashEnabled = not dashEnabled
    if dashEnabled then
        if dashButton then dashButton.Parent:Destroy() end
        local sg = Instance.new("ScreenGui", game.CoreGui) 
        dashButton = Instance.new("TextButton", sg) 
        dashButton.Size = UDim2.new(0, 65, 0, 65) 
        dashButton.Position = UDim2.new(0.8, 0, 0.5, 0) 
        dashButton.BackgroundColor3 = guiSettings.BorderColor 
        dashButton.Text = "DASH" 
        dashButton.TextColor3 = Color3.new(1,1,1) 
        dashButton.Font = Enum.Font.GothamBold 
        Instance.new("UICorner", dashButton).CornerRadius = UDim.new(0, 35)
        dashButton.MouseButton1Click:Connect(function()
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                local root = LP.Character.HumanoidRootPart 
                local hum = LP.Character.Humanoid
                local dir = hum.MoveDirection.Magnitude > 0 and hum.MoveDirection or root.CFrame.LookVector
                root.CFrame = root.CFrame + Vector3.new(dir.X, 0, dir.Z).Unit * 15
            end
        end) 
        ShowMessage("🏃 Dash Button Spawned")
    else 
        if dashButton then dashButton.Parent:Destroy() end 
        ShowMessage("🏃 Dash Removed") 
    end
end

function ToggleNoJumpCooldown()
    noJumpCdEnabled = not noJumpCdEnabled
    ShowMessage("🦘 No Jump CD "..(noJumpCdEnabled and "ON" or "OFF"))
end

function ToggleBlinkMode()
    blinkEnabled = not blinkEnabled
    ShowMessage("👻 Blink Mode "..(blinkEnabled and "ON" or "OFF"))
end

function ToggleInvisibility()
    invisibilityEnabled = not invisibilityEnabled
    if invisibilityEnabled then
        if LP.Character then
            for _, v in pairs(LP.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.Transparency = 0.99 end
            end
            LP.Character:SetAttribute("Invisible", true)
            ShowMessage("👤 Invisibility ON")
        end
    else
        if LP.Character then
            for _, v in pairs(LP.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.Transparency = 0 end
            end
            LP.Character:SetAttribute("Invisible", false)
        end
        ShowMessage("👤 Invisibility OFF")
    end
end

LP.CharacterAdded:Connect(function()
    task.wait(0.3)
    if invisibilityEnabled then
        for _, v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.Transparency = 0.99 end
        end
    end
end)

function ToggleHelicopter()
    helicopterEnabled = not helicopterEnabled 
    ShowMessage("🚁 Helicopter "..(helicopterEnabled and "ON" or "OFF"))
    if helicopterEnabled then
        helicopterConnection = RunService.Heartbeat:Connect(function()
            if not helicopterEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
            local r = LP.Character.HumanoidRootPart
            r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, 35, r.AssemblyLinearVelocity.Z)
            r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(25), 0)
        end)
    else
        if helicopterConnection then helicopterConnection:Disconnect() end
    end
end

function ToggleStrafe()
    strafeEnabled = not strafeEnabled 
    ShowMessage("✈️ CS:GO Strafe "..(strafeEnabled and "ON" or "OFF"))
    if strafeEnabled then
        strafeConnection = RunService.Heartbeat:Connect(function()
            if not strafeEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
            local root = LP.Character.HumanoidRootPart 
            local hum = LP.Character.Humanoid 
            local move = hum.MoveDirection
            if move.Magnitude > 0 then
                local camL = Camera.CFrame.LookVector 
                local side = Vector3.new(-camL.Z, 0, camL.X).Unit 
                local dot = move:Dot(side)
                if math.abs(dot) > 0.2 then
                    local fDir = dot > 0 and side or -side
                    root.AssemblyLinearVelocity = Vector3.new(fDir.X * (speedValue * 1.5), root.AssemblyLinearVelocity.Y, fDir.Z * (speedValue * 1.5))
                end
            end
        end)
    else 
        if strafeConnection then strafeConnection:Disconnect() end 
    end
end

function ToggleBunnyHop()
    bunnyHopEnabled = not bunnyHopEnabled
    if bunnyHopEnabled then
        bunnyHopConnection = RunService.Heartbeat:Connect(function()
            if not bunnyHopEnabled or not LP.Character then return end
            local hum = LP.Character:FindFirstChild("Humanoid")
            local root = LP.Character:FindFirstChild("HumanoidRootPart")
            if not hum or not root then return end
            if hum:GetState() == Enum.HumanoidStateType.Jumping or hum:GetState() == Enum.HumanoidStateType.Freefall then
                local move = hum.MoveDirection
                if move.Magnitude > 0.1 then
                    local speed = hum.WalkSpeed * 1.8
                    root.AssemblyLinearVelocity = Vector3.new(move.X * speed, root.AssemblyLinearVelocity.Y, move.Z * speed)
                end
            end
        end)
        ShowMessage("🐰 Bunny Hop ON")
    else
        if bunnyHopConnection then bunnyHopConnection:Disconnect() end
        ShowMessage("🐰 Bunny Hop OFF")
    end
end

function ToggleGhostMode()
    ghostModeEnabled = not ghostModeEnabled
    if ghostModeEnabled then
        ToggleInvisibility()
        ToggleNoClip()
        ShowMessage("👻 Ghost Mode ON")
    else
        ToggleInvisibility()
        ToggleNoClip()
        ShowMessage("👻 Ghost Mode OFF")
    end
end

function ToggleWallClimb()
    wallClimbEnabled = not wallClimbEnabled
    if wallClimbEnabled then
        wallClimbConnection = RunService.Heartbeat:Connect(function()
            if not wallClimbEnabled or not LP.Character then return end
            local root = LP.Character:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local ray = workspace:Raycast(root.Position, root.CFrame.LookVector * 3)
            if ray and ray.Instance and math.abs(ray.Normal.Y) < 0.5 then
                local normal = ray.Normal
                root.CFrame = CFrame.new(root.Position, root.Position + normal) + normal * 0.5
                root.AssemblyLinearVelocity = Vector3.new(
                    normal.X * speedValue * 1.5,
                    UserInputService:IsKeyDown(Enum.KeyCode.Space) and 25 or -10,
                    normal.Z * speedValue * 1.5
                )
            end
        end)
        ShowMessage("🧱 Wall Climb ON")
    else
        if wallClimbConnection then wallClimbConnection:Disconnect() end
        ShowMessage("🧱 Wall Climb OFF")
    end
end

function ToggleWallJump()
    wallJumpEnabled = not wallJumpEnabled
    if wallJumpEnabled then
        wallJumpConnection = RunService.Heartbeat:Connect(function()
            if not wallJumpEnabled or not LP.Character then return end
            local root = LP.Character:FindFirstChild("HumanoidRootPart")
            local hum = LP.Character:FindFirstChild("Humanoid")
            if not root or not hum then return end
            local ray = workspace:Raycast(root.Position, root.CFrame.LookVector * 2)
            if ray and ray.Instance and math.abs(ray.Normal.Y) < 0.3 and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                root.AssemblyLinearVelocity = Vector3.new(ray.Normal.X * 30, 30, ray.Normal.Z * 30)
            end
        end)
        ShowMessage("🧱 Wall Jump ON")
    else
        if wallJumpConnection then wallJumpConnection:Disconnect() end
        ShowMessage("🧱 Wall Jump OFF")
    end
end

function ToggleWallRun()
    wallRunEnabled = not wallRunEnabled
    if wallRunEnabled then
        wallRunConnection = RunService.Heartbeat:Connect(function()
            if not wallRunEnabled or not LP.Character then return end
            local root = LP.Character:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local ray = workspace:Raycast(root.Position + Vector3.new(0, 1, 0), root.CFrame.LookVector * 3)
            if ray and ray.Instance and math.abs(ray.Normal.Y) < 0.3 then
                local normal = ray.Normal
                root.AssemblyLinearVelocity = Vector3.new(normal.X * speedValue * 2, 5, normal.Z * speedValue * 2)
                root.CFrame = CFrame.new(root.Position, root.Position + normal)
            end
        end)
        ShowMessage("🏃 Wall Run ON")
    else
        if wallRunConnection then wallRunConnection:Disconnect() end
        ShowMessage("🏃 Wall Run OFF")
    end
end

function ToggleNoFallDamage()
    noFallDamageEnabled = not noFallDamageEnabled
    ShowMessage("🪂 No Fall Damage "..(noFallDamageEnabled and "ON" or "OFF"))
end

function ToggleWaterWalk()
    waterWalkEnabled = not waterWalkEnabled
    ShowMessage("💧 Water Walk "..(waterWalkEnabled and "ON" or "OFF"))
end

function ToggleLavaWalk()
    lavaWalkEnabled = not lavaWalkEnabled
    ShowMessage("🔥 Lava Walk "..(lavaWalkEnabled and "ON" or "OFF"))
end

function ToggleNoGravity()
    noGravityEnabled = not noGravityEnabled
    workspace.Gravity = noGravityEnabled and 0 or 196.2
    ShowMessage("🌌 No Gravity "..(noGravityEnabled and "ON" or "OFF"))
end

function ToggleTimeFreeze()
    timeFreezeEnabled = not timeFreezeEnabled
    ShowMessage("⏸️ Time Freeze "..(timeFreezeEnabled and "ON" or "OFF"))
end

function ToggleWalkFling()
    walkFlingEnabled = not walkFlingEnabled
    if walkFlingEnabled then
        ShowMessage("🚶 WalkFling ON")
        task.spawn(function()
            while walkFlingEnabled do
                task.wait(0.05)
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    local root = LP.Character.HumanoidRootPart
                    local hum = LP.Character:FindFirstChild("Humanoid")
                    if hum and hum.MoveDirection.Magnitude > 0.1 then
                        root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 500, root.AssemblyLinearVelocity.Z)
                    end
                end
            end
        end)
    else ShowMessage("🚶 WalkFling OFF") end
end

-- ============================================
-- ⚔️ COMBAT (AIMBOT, KILL AURA, TRIGGER BOT)
-- ============================================
function ToggleAimbot()
    aimbotEnabled = not aimbotEnabled
    ShowMessage("🎯 Aimbot "..(aimbotEnabled and "ON" or "OFF"))
end

function ToggleAimbotV2()
    aimbotV2Enabled = not aimbotV2Enabled
    ShowMessage("🎯 Silent Aim "..(aimbotV2Enabled and "ON" or "OFF"))
end

function ToggleAimbotV3()
    aimbotV3Enabled = not aimbotV3Enabled
    ShowMessage("🎯 Prediction Aim "..(aimbotV3Enabled and "ON" or "OFF"))
end

function ToggleAimbotV4()
    aimbotV4Enabled = not aimbotV4Enabled
    ShowMessage("🎯 Smooth Aim "..(aimbotV4Enabled and "ON" or "OFF"))
end

function ToggleAimbotV5()
    aimbotV5Enabled = not aimbotV5Enabled
    ShowMessage("🎯 FOV Aim "..(aimbotV5Enabled and "ON" or "OFF"))
end

function ToggleAimbotV6()
    aimbotV6Enabled = not aimbotV6Enabled
    ShowMessage("🎯 Trigger Aim "..(aimbotV6Enabled and "ON" or "OFF"))
end

function ToggleAimbotV7()
    aimbotV7Enabled = not aimbotV7Enabled
    guiSettings.AimbotWallbang = aimbotV7Enabled
    ShowMessage("🎯 Wallbang Aim "..(aimbotV7Enabled and "ON" or "OFF"))
end

function ToggleAimbotV8()
    aimbotV8Enabled = not aimbotV8Enabled
    guiSettings.AimbotPart = aimbotV8Enabled and "Head" or "HumanoidRootPart"
    ShowMessage("🎯 Head Only "..(aimbotV8Enabled and "ON" or "OFF"))
end

function ToggleAimbotV9()
    aimbotV9Enabled = not aimbotV9Enabled
    guiSettings.AimbotPart = aimbotV9Enabled and "HumanoidRootPart" or "Head"
    ShowMessage("🎯 Body Only "..(aimbotV9Enabled and "ON" or "OFF"))
end

function ToggleAimbotV10()
    aimbotV10Enabled = not aimbotV10Enabled
    ShowMessage("🎯 Nearest Aim "..(aimbotV10Enabled and "ON" or "OFF"))
end

function SetAimbotSpeed(val)
    guiSettings.AimbotSpeed = math.clamp(val, 0.01, 1)
    ShowMessage("🎯 Aimbot Speed: " .. guiSettings.AimbotSpeed)
end

function SetAimbotStrength(val)
    guiSettings.AimbotStrength = math.clamp(val, 0.1, 1)
    ShowMessage("🎯 Aimbot Strength: " .. guiSettings.AimbotStrength)
end

function SetAimbotFOV(val)
    guiSettings.AimbotFOV = math.clamp(val, 10, 500)
    ShowMessage("🎯 Aimbot FOV: " .. guiSettings.AimbotFOV)
end

function SetKillAuraRange(val)
    guiSettings.KillAuraRange = math.clamp(val, 1, 50)
    ShowMessage("⚔️ Kill Aura Range: " .. guiSettings.KillAuraRange)
end

function SetToolReach(val)
    guiSettings.ToolReachValue = math.clamp(val, 1, 20)
    ShowMessage("📏 Tool Reach: " .. guiSettings.ToolReachValue)
end

function ToggleTriggerBot()
    triggerBotEnabled = not triggerBotEnabled
    if triggerBotEnabled then
        triggerBotConnection = RunService.RenderStepped:Connect(function()
            if not triggerBotEnabled then return end
            local mouse = LP:GetMouse()
            if mouse and mouse.Target and mouse.Target.Parent:FindFirstChild("Humanoid") then
                if Players:GetPlayerFromCharacter(mouse.Target.Parent) ~= LP then
                    VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1)
                    VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
                end
            end
        end)
        ShowMessage("🎯 Trigger Bot ON")
    else
        if triggerBotConnection then triggerBotConnection:Disconnect() end
        ShowMessage("🎯 Trigger Bot OFF")
    end
end

function ToggleAutoClicker()
    autoClickerEnabled = not autoClickerEnabled
    if autoClickerEnabled then
        autoClickerConnection = RunService.Heartbeat:Connect(function()
            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1)
            VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
        end)
        ShowMessage("🖱️ Auto-Clicker V1 ON")
    else
        if autoClickerConnection then autoClickerConnection:Disconnect() end
        ShowMessage("🖱️ Auto-Clicker V1 OFF")
    end
end

function ToggleAutoClickerV2()
    autoClickerV2Enabled = not autoClickerV2Enabled
    if autoClickerV2Enabled then
        autoClickerV2Connection = RunService.RenderStepped:Connect(function()
            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1)
            VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
            task.wait(0.005)
            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1)
            VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
        end)
        ShowMessage("⚡ Auto-Clicker V2 ON")
    else
        if autoClickerV2Connection then autoClickerV2Connection:Disconnect() end
        ShowMessage("⚡ Auto-Clicker V2 OFF")
    end
end

function ToggleAutoHeal()
    autoHealEnabled = not autoHealEnabled
    ShowMessage("❤️ Auto-Heal "..(autoHealEnabled and "ON" or "OFF"))
end

function ToggleAutoParry()
    autoParryEnabled = not autoParryEnabled
    ShowMessage("🛡️ Auto-Parry "..(autoParryEnabled and "ON" or "OFF"))
end

function ToggleAutoDodge()
    autoDodgeEnabled = not autoDodgeEnabled
    ShowMessage("💨 Auto-Dodge "..(autoDodgeEnabled and "ON" or "OFF"))
end

function ToggleAutoReload()
    autoReloadEnabled = not autoReloadEnabled
    ShowMessage("🔄 Auto-Reload "..(autoReloadEnabled and "ON" or "OFF"))
end

function ToggleCriticalHit()
    criticalHitEnabled = not criticalHitEnabled
    ShowMessage("💥 Critical Hit "..(criticalHitEnabled and "ON" or "OFF"))
end

-- ============================================
-- 🌀 HVH
-- ============================================
function ToggleResolver()
    resolverEnabled = not resolverEnabled
    ShowMessage("🎯 Resolver "..(resolverEnabled and "ON" or "OFF"))
end

function ToggleAntiAim()
    antiAimEnabled = not antiAimEnabled
    if antiAimEnabled then
        antiAimConnection = RunService.Heartbeat:Connect(function()
            if not antiAimEnabled or not LP.Character then return end
            local root = LP.Character:FindFirstChild("HumanoidRootPart")
            local hum = LP.Character:FindFirstChild("Humanoid")
            if not root or not hum then return end
            if guiSettings.AntiAimMode == "Spin" then
                root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(tick() * 500 % 360), 0)
                hum.AutoRotate = false
            elseif guiSettings.AntiAimMode == "Backwards" then
                root.CFrame = CFrame.new(root.Position, root.Position - root.CFrame.LookVector)
                hum.AutoRotate = false
            elseif guiSettings.AntiAimMode == "Jitter" then
                root.CFrame = CFrame.new(root.Position) * CFrame.Angles(math.rad(math.random(-10,10)), math.rad(tick() * 500 % 360), math.rad(math.random(-5,5)))
                hum.AutoRotate = false
            end
        end)
        ShowMessage("🌀 Anti-Aim "..guiSettings.AntiAimMode.." ON")
    else
        if antiAimConnection then antiAimConnection:Disconnect() end
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.AutoRotate = true end
        ShowMessage("🌀 Anti-Aim OFF")
    end
end

function SetAntiAimMode(mode)
    guiSettings.AntiAimMode = mode
    ShowMessage("Anti-Aim Mode: "..mode)
end

function ToggleFakeLag()
    fakeLagEnabled = not fakeLagEnabled
    if fakeLagEnabled then
        fakeLagConnection = RunService.Heartbeat:Connect(function()
            if not fakeLagEnabled then return end
            for i = 1, guiSettings.FakeLagAmount do task.wait(0.001) end
        end)
        ShowMessage("⏳ Fake Lag ON")
    else
        if fakeLagConnection then fakeLagConnection:Disconnect() end
        ShowMessage("⏳ Fake Lag OFF")
    end
end

function SetFakeLagAmount(val)
    guiSettings.FakeLagAmount = math.clamp(val, 1, 20)
    ShowMessage("⏳ Fake Lag Amount: " .. guiSettings.FakeLagAmount)
end

function ToggleAntiKb()
    antiKbEnabled = not antiKbEnabled
    if antiKbEnabled then
        antiKbConnection = RunService.Heartbeat:Connect(function()
            if antiKbEnabled and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                local vel = LP.Character.HumanoidRootPart.AssemblyLinearVelocity
                if vel.Magnitude > 40 then LP.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0) end
            end
        end)
        ShowMessage("⚓ Anti-Knockback ON")
    else
        if antiKbConnection then antiKbConnection:Disconnect() end
        ShowMessage("⚓ Anti-Knockback OFF")
    end
end

function ToggleAntiKbV2()
    antiKbV2Enabled = not antiKbV2Enabled
    if antiKbV2Enabled then
        antiKbV2Connection = RunService.Heartbeat:Connect(function()
            if antiKbV2Enabled and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end)
        ShowMessage("⚓ Anti-Knockback V2 ON")
    else
        if antiKbV2Connection then antiKbV2Connection:Disconnect() end
        ShowMessage("⚓ Anti-Knockback V2 OFF")
    end
end

function ToggleAntiStun()
    antiStunEnabled = not antiStunEnabled
    ShowMessage("⚡ Anti-Stun "..(antiStunEnabled and "ON" or "OFF"))
end

function ToggleAntiFreeze()
    antiFreezeEnabled = not antiFreezeEnabled
    ShowMessage("❄️ Anti-Freeze "..(antiFreezeEnabled and "ON" or "OFF"))
end

function ToggleAntiSlow()
    antiSlowEnabled = not antiSlowEnabled
    ShowMessage("🐢 Anti-Slow "..(antiSlowEnabled and "ON" or "OFF"))
end

function ToggleDesync()
    desyncEnabled = not desyncEnabled
    if desyncEnabled then
        desyncConnection = RunService.Heartbeat:Connect(function()
            if not desyncEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
            local root = LP.Character.HumanoidRootPart
            local cf = root.CFrame
            root.CFrame = cf * CFrame.new(math.random(-4,4)*0.2, 0, math.random(-4,4)*0.2)
            task.wait()
            root.CFrame = cf
        end)
        ShowMessage("🌀 Desync ON")
    else
        if desyncConnection then desyncConnection:Disconnect() end
        ShowMessage("🌀 Desync OFF")
    end
end

function ToggleFakePing()
    fakePingEnabled = not fakePingEnabled
    if fakePingEnabled then
        fakePingConnection = RunService.Heartbeat:Connect(function()
            if not fakePingEnabled then return end
            if guiSettings.FakePingMode == "Static" then
                Stats.Network.ServerStatsItem["Data Ping"]:SetValue(guiSettings.FakePingValue)
            elseif guiSettings.FakePingMode == "Jump" then
                local jump = math.random(-20, 20)
                Stats.Network.ServerStatsItem["Data Ping"]:SetValue(guiSettings.FakePingValue + jump)
            elseif guiSettings.FakePingMode == "Wave" then
                Stats.Network.ServerStatsItem["Data Ping"]:SetValue(guiSettings.FakePingValue + math.sin(tick() * 2) * 25)
            end
        end)
        ShowMessage("📶 Fake Ping ON ("..guiSettings.FakePingValue.."ms)")
    else
        if fakePingConnection then fakePingConnection:Disconnect() end
        ShowMessage("📶 Fake Ping OFF")
    end
end

function SetFakePingMode(mode)
    guiSettings.FakePingMode = mode
    ShowMessage("Fake Ping Mode: "..mode)
end

function SetFakePingValue(val)
    guiSettings.FakePingValue = math.clamp(val, 50, 999)
    ShowMessage("📶 Fake Ping Value: " .. guiSettings.FakePingValue)
end

-- ============================================
-- 🔪 MM2
-- ============================================
local function getMM2Role(player)
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    local isMurder, isSheriff = false, false
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                local name = string.lower(item.Name)
                if string.find(name, "knife") or string.find(name, "blade") or string.find(name, "scythe") then isMurder = true end
                if string.find(name, "gun") or string.find(name, "revolver") or string.find(name, "blaster") then isSheriff = true end
            end
        end
    end
    if char then
        for _, item in pairs(char:GetChildren()) do
            if item:IsA("Tool") then
                local name = string.lower(item.Name)
                if string.find(name, "knife") or string.find(name, "blade") or string.find(name, "scythe") then isMurder = true end
                if string.find(name, "gun") or string.find(name, "revolver") or string.find(name, "blaster") then isSheriff = true end
            end
        end
    end
    if isMurder then return "Murderer" end
    if isSheriff then return "Sheriff" end
    return "Innocent"
end

local function FindMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and getMM2Role(p) == "Murderer" then return p end
    end
    return nil
end

local function FindSheriff()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and getMM2Role(p) == "Sheriff" then return p end
    end
    return nil
end

local function ShootInMM2()
    if not LP.Character then return false end
    local gun = LP.Character:FindFirstChild("Gun")
    if not gun then
        local backpack = LP:FindFirstChild("Backpack")
        if backpack then
            for _, item in pairs(backpack:GetChildren()) do
                if item:IsA("Tool") and (item.Name == "Gun" or string.find(string.lower(item.Name), "gun")) then
                    gun = item
                    item.Parent = LP.Character
                    task.wait(0.1)
                    break
                end
            end
        end
    end
    if gun then gun:Activate() return true end
    return false
end

function ToggleMM2ESP()
    mm2EspEnabled = not mm2EspEnabled
    if mm2EspEnabled then
        ShowMessage("🔪 MM2 ESP ON")
        task.spawn(function()
            while mm2EspEnabled and task.wait(0.5) do
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local char = p.Character
                        local hrp = char.HumanoidRootPart
                        local role = getMM2Role(p)
                        local color = role == "Murderer" and Color3.fromRGB(255,0,0) or role == "Sheriff" and Color3.fromRGB(0,150,255) or Color3.fromRGB(0,255,0)
                        local roleName = role == "Murderer" and "🔪 УБИЙЦА" or role == "Sheriff" and "🔫 ШЕРИФ" or "👤 Мирный"
                        
                        local bba = hrp:FindFirstChild("MM2_RoleESP") or Instance.new("BillboardGui", hrp)
                        bba.Name = "MM2_RoleESP"
                        bba.AlwaysOnTop = true
                        bba.Size = UDim2.new(0, 100, 0, 30)
                        bba.ExtentsOffset = Vector3.new(0, 3, 0)
                        bba:ClearAllChildren()
                        local txt = Instance.new("TextLabel", bba)
                        txt.Size = UDim2.new(1,0,1,0)
                        txt.BackgroundTransparency = 1
                        txt.TextSize = 11
                        txt.Font = Enum.Font.SourceSansBold
                        txt.Text = roleName
                        txt.TextColor3 = color
                        
                        local hl = char:FindFirstChild("MM2_Highlight") or Instance.new("Highlight", char)
                        hl.Name = "MM2_Highlight"
                        hl.FillColor = color
                        hl.OutlineColor = color
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end
                end
            end
        end)
    else
        ShowMessage("🔪 MM2 ESP OFF")
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                local hl = p.Character:FindFirstChild("MM2_Highlight")
                if hl then hl:Destroy() end
                local bba = p.Character:FindFirstChild("MM2_RoleESP")
                if bba then bba:Destroy() end
            end
        end
    end
end

function ToggleMM2ESPV2()
    mm2EspV2Enabled = not mm2EspV2Enabled
    ShowMessage("🔪 MM2 ESP V2 "..(mm2EspV2Enabled and "ON" or "OFF"))
end

function ToggleMM2EspRoles()
    mm2EspRolesEnabled = not mm2EspRolesEnabled
    ShowMessage("👁️ MM2 Roles ESP "..(mm2EspRolesEnabled and "ON" or "OFF"))
end

function ToggleMM2Aimbot()
    mm2AimbotEnabled = not mm2AimbotEnabled
    if mm2AimbotEnabled then
        if mm2FOVCircle then mm2FOVCircle:Destroy() end
        mm2FOVCircle = Instance.new("Frame", fovGui)
        mm2FOVCircle.Size = UDim2.new(0, mm2FOVRadius * 2, 0, mm2FOVRadius * 2)
        mm2FOVCircle.Position = UDim2.new(0.5, -mm2FOVRadius, 0.5, -mm2FOVRadius)
        mm2FOVCircle.BackgroundTransparency = 1
        mm2FOVCircle.Visible = true
        local stroke = Instance.new("UIStroke", mm2FOVCircle)
        stroke.Color = Color3.fromRGB(255, 0, 0)
        stroke.Thickness = 1.5
        Instance.new("UICorner", mm2FOVCircle).CornerRadius = UDim.new(1, 0)
        ShowMessage("🎯 MM2 Aimbot ON")
        mm2AimbotConnection = RunService.RenderStepped:Connect(function()
            if not mm2AimbotEnabled then return end
            local murderer = FindMurderer()
            if not murderer or not murderer.Character or not murderer.Character:FindFirstChild("Head") then return end
            local hasGun = LP.Character and (LP.Character:FindFirstChild("Gun") or LP.Character:FindFirstChildOfClass("Tool"))
            if not hasGun then
                local backpack = LP:FindFirstChild("Backpack")
                if backpack then
                    for _, item in pairs(backpack:GetChildren()) do
                        if item:IsA("Tool") and (item.Name == "Gun" or string.find(string.lower(item.Name), "gun")) then
                            item.Parent = LP.Character
                            task.wait(0.1)
                            break
                        end
                    end
                end
            end
            local headPos = murderer.Character.Head.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(headPos)
            if onScreen then
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if dist <= mm2FOVRadius then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, headPos)
                    ShootInMM2()
                end
            end
        end)
    else
        if mm2AimbotConnection then mm2AimbotConnection:Disconnect() end
        if mm2FOVCircle then mm2FOVCircle:Destroy() end
        ShowMessage("🎯 MM2 Aimbot OFF")
    end
end

function ToggleMM2TriggerBot()
    mm2TriggerBotEnabled = not mm2TriggerBotEnabled
    if mm2TriggerBotEnabled then
        ShowMessage("🔫 MM2 Trigger Bot ON")
        mm2ShootConnection = RunService.RenderStepped:Connect(function()
            if not mm2TriggerBotEnabled then return end
            local murderer = FindMurderer()
            if not murderer or not murderer.Character or not murderer.Character:FindFirstChild("Head") then return end
            local screenPos, onScreen = Camera:WorldToViewportPoint(murderer.Character.Head.Position)
            if onScreen then
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if dist <= 50 then ShootInMM2() end
            end
        end)
    else
        if mm2ShootConnection then mm2ShootConnection:Disconnect() end
        ShowMessage("🔫 MM2 Trigger Bot OFF")
    end
end

function ToggleMM2KillAura()
    mm2KillAuraEnabled = not mm2KillAuraEnabled
    if mm2KillAuraEnabled then
        ShowMessage("⚔️ MM2 Kill Aura ON")
        task.spawn(function()
            while mm2KillAuraEnabled do
                task.wait(0.1)
                if not LP.Character then continue end
                local murderer = FindMurderer()
                if murderer and murderer.Character and murderer.Character:FindFirstChild("Humanoid") and murderer.Character.Humanoid.Health > 0 then
                    local myRoot = LP.Character:FindFirstChild("HumanoidRootPart")
                    local targetRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot and targetRoot then myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2) end
                    local knife = LP.Character:FindFirstChild("Knife") or LP.Character:FindFirstChildOfClass("Tool")
                    if knife then knife:Activate() end
                end
            end
        end)
    else ShowMessage("⚔️ MM2 Kill Aura OFF") end
end

function ToggleMM2KillAuraV2()
    mm2KillAuraV2Enabled = not mm2KillAuraV2Enabled
    if mm2KillAuraV2Enabled then
        ShowMessage("⚔️ MM2 Kill Aura V2 (Teleport) ON")
        mm2KillAuraV2Connection = RunService.Heartbeat:Connect(function()
            if not mm2KillAuraV2Enabled or not LP.Character then return end
            local myRoot = LP.Character:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            local targets = {}
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    table.insert(targets, p)
                end
            end
            for _, target in pairs(targets) do
                local targetRoot = target.Character.HumanoidRootPart
                if targetRoot then
                    local lookVec = targetRoot.CFrame.LookVector
                    local behindPos = targetRoot.Position - lookVec * 3
                    myRoot.CFrame = CFrame.new(behindPos, targetRoot.Position)
                    local knife = LP.Character:FindFirstChild("Knife") or LP.Character:FindFirstChildOfClass("Tool")
                    if knife then knife:Activate() end
                    task.wait(0.05)
                end
            end
        end)
    else
        if mm2KillAuraV2Connection then mm2KillAuraV2Connection:Disconnect() end
        ShowMessage("⚔️ MM2 Kill Aura V2 OFF")
    end
end

function ToggleMM2SilentAim()
    mm2SilentAimEnabled = not mm2SilentAimEnabled
    if mm2SilentAimEnabled then
        ShowMessage("🎯 MM2 Silent Aim ON")
        task.spawn(function()
            while mm2SilentAimEnabled do
                task.wait(0.05)
                local murderer = FindMurderer()
                if murderer and murderer.Character and murderer.Character:FindFirstChild("Head") then
                    local gun = LP.Character and LP.Character:FindFirstChild("Gun")
                    if gun then gun:Activate() end
                end
            end
        end)
    else ShowMessage("🎯 MM2 Silent Aim OFF") end
end

function ToggleMM2AntiKnife()
    mm2AntiKnifeEnabled = not mm2AntiKnifeEnabled
    if mm2AntiKnifeEnabled then
        ShowMessage("🛡️ MM2 Anti-Knife ON")
        task.spawn(function()
            while mm2AntiKnifeEnabled do
                task.wait(0.1)
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and getMM2Role(p) == "Murderer" and p.Character and p.Character:FindFirstChild("Knife") then
                        local myPos = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character.HumanoidRootPart.Position
                        if myPos and (myPos - p.Character.Knife.Position).Magnitude < 8 then
                            LP.Character.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -15)
                        end
                    end
                end
            end
        end)
    else ShowMessage("🛡️ MM2 Anti-Knife OFF") end
end

function ToggleMM2GrabGun()
    mm2GrabGunEnabled = not mm2GrabGunEnabled
    if mm2GrabGunEnabled then
        ShowMessage("🔫 MM2 Grab Gun ON")
        mm2GrabGunConnection = RunService.Heartbeat:Connect(function()
            if not mm2GrabGunEnabled or not LP.Character then return end
            local myRoot = LP.Character:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Tool") and (obj.Name == "Gun" or string.find(string.lower(obj.Name), "gun")) then
                    local handle = obj:FindFirstChild("Handle")
                    if handle then myRoot.CFrame = CFrame.new(handle.Position + Vector3.new(0, 3, 0)) break end
                end
            end
        end)
    else
        if mm2GrabGunConnection then mm2GrabGunConnection:Disconnect() end
        ShowMessage("🔫 MM2 Grab Gun OFF")
    end
end

function ToggleMM2GrabGunV2()
    mm2GrabGunV2Enabled = not mm2GrabGunV2Enabled
    if mm2GrabGunV2Enabled then
        ShowMessage("🔫 MM2 Grab Gun V2 ON")
        mm2GrabGunConnection = RunService.Heartbeat:Connect(function()
            if not mm2GrabGunV2Enabled or not LP.Character then return end
            local droppedGun = workspace:FindFirstChild("GunDrop")
            if droppedGun then
                local mainPart = droppedGun:FindFirstChildOfClass("Part") or droppedGun:FindFirstChildOfClass("MeshPart")
                if mainPart then
                    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and mainPart:IsA("BasePart") then
                        if mm2GrabMethod == "Teleport" then
                            hrp.CFrame = mainPart.CFrame + Vector3.new(0, 2, 0)
                        else
                            mainPart.CFrame = hrp.CFrame
                            mainPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        end
                    end
                end
            end
        end)
    else
        if mm2GrabGunConnection then mm2GrabGunConnection:Disconnect() end
        ShowMessage("🔫 MM2 Grab Gun V2 OFF")
    end
end

function SetGrabMethod(method)
    mm2GrabMethod = method
    ShowMessage("Grab Method: " .. method)
end

function ToggleMM2FlingMurderer()
    mm2FlingMurdererEnabled = not mm2FlingMurdererEnabled
    if mm2FlingMurdererEnabled then
        ShowMessage("🔪 Fling Murderer ON")
        task.spawn(function()
            while mm2FlingMurdererEnabled do
                task.wait(0.1)
                local murderer = FindMurderer()
                if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = murderer.Character.HumanoidRootPart
                    local hum = murderer.Character:FindFirstChild("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local dir = Vector3.new(math.random(-1, 1), 1.5, math.random(-1, 1)).Unit
                        hum.Sit = true
                        hrp.AssemblyLinearVelocity = dir * 5000
                        ShowMessage("💥 Fling Murderer: " .. murderer.Name)
                    end
                end
            end
        end)
    else ShowMessage("🔪 Fling Murderer OFF") end
end

function ToggleMM2FlingSheriff()
    mm2FlingSheriffEnabled = not mm2FlingSheriffEnabled
    if mm2FlingSheriffEnabled then
        ShowMessage("⭐ Fling Sheriff ON")
        task.spawn(function()
            while mm2FlingSheriffEnabled do
                task.wait(0.1)
                local sheriff = FindSheriff()
                if sheriff and sheriff.Character and sheriff.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = sheriff.Character.HumanoidRootPart
                    local hum = sheriff.Character:FindFirstChild("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local dir = Vector3.new(math.random(-1, 1), 1.5, math.random(-1, 1)).Unit
                        hum.Sit = true
                        hrp.AssemblyLinearVelocity = dir * 5000
                        ShowMessage("💥 Fling Sheriff: " .. sheriff.Name)
                    end
                end
            end
        end)
    else ShowMessage("⭐ Fling Sheriff OFF") end
end

function ToggleMM2AutoShoot()
    mm2AutoShootEnabled = not mm2AutoShootEnabled
    if mm2AutoShootEnabled then
        if mm2AutoShootGui then mm2AutoShootGui:Destroy() end
        mm2AutoShootGui = Instance.new("ScreenGui", game.CoreGui)
        mm2AutoShootGui.Name = "MTY_MM2_AutoShoot"
        mm2AutoShootGui.ResetOnSpawn = false
        mm2AutoShootButton = Instance.new("TextButton", mm2AutoShootGui)
        mm2AutoShootButton.Size = UDim2.new(0, 80, 0, 80)
        mm2AutoShootButton.Position = UDim2.new(0.85, 0, 0.5, -40)
        mm2AutoShootButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        mm2AutoShootButton.BackgroundTransparency = 0.6
        mm2AutoShootButton.BorderSizePixel = 0
        mm2AutoShootButton.Text = "🎯"
        mm2AutoShootButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        mm2AutoShootButton.TextSize = 30
        mm2AutoShootButton.Font = Enum.Font.SourceSansBold
        mm2AutoShootButton.Active = true
        mm2AutoShootButton.Draggable = true
        mm2AutoShootButton.Parent = mm2AutoShootGui
        local corner = Instance.new("UICorner", mm2AutoShootButton)
        corner.CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke", mm2AutoShootButton)
        stroke.Thickness = 2
        stroke.Color = Color3.fromRGB(130, 80, 255)
        mm2AutoShootButton.MouseButton1Click:Connect(function()
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then ShowMessage("❌ Нет персонажа!") return end
            local gun = char:FindFirstChild("Gun") or (LP:FindFirstChild("Backpack") and LP.Backpack:FindFirstChild("Gun"))
            if not gun then ShowMessage("❌ Пистолет не найден!") return end
            if gun.Parent == LP.Backpack then hum:EquipTool(gun) task.wait(0.1) end
            local murderer = FindMurderer()
            if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
                local muderHrp = murderer.Character.HumanoidRootPart
                hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(muderHrp.Position.X, hrp.Position.Y, muderHrp.Position.Z))
                gun:Activate()
                ShowMessage("🎯 Выстрелил в " .. murderer.Name)
            else ShowMessage("❌ Мардер не найден!") end
        end)
        ShowMessage("🎯 MM2 Auto Shoot ON")
    else
        if mm2AutoShootGui then mm2AutoShootGui:Destroy() end
        ShowMessage("🎯 MM2 Auto Shoot OFF")
    end
end

function ToggleMM2SpeedHack()
    mm2SpeedHackEnabled = not mm2SpeedHackEnabled
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = mm2SpeedHackEnabled and 35 or 16
        ShowMessage("⚡ MM2 Speed Hack " .. (mm2SpeedHackEnabled and "ON" or "OFF"))
    end
end

function ToggleMM2NoRecoil()
    mm2NoRecoilEnabled = not mm2NoRecoilEnabled
    ShowMessage("🔫 MM2 No Recoil "..(mm2NoRecoilEnabled and "ON" or "OFF"))
end

function ToggleMM2NoSpread()
    mm2NoSpreadEnabled = not mm2NoSpreadEnabled
    ShowMessage("🎯 MM2 No Spread "..(mm2NoSpreadEnabled and "ON" or "OFF"))
end

function ToggleMM2FastReload()
    mm2FastReloadEnabled = not mm2FastReloadEnabled
    ShowMessage("🔄 MM2 Fast Reload "..(mm2FastReloadEnabled and "ON" or "OFF"))
end

function ToggleMM2InfiniteAmmo()
    mm2InfiniteAmmoEnabled = not mm2InfiniteAmmoEnabled
    ShowMessage("♾️ MM2 Infinite Ammo "..(mm2InfiniteAmmoEnabled and "ON" or "OFF"))
end

function ToggleMM2TPtoLobby()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then ShowMessage("❌ Нет персонажа!") return end
    local lobbySpawn = workspace:FindFirstChild("Lobby") and workspace.Lobby:FindFirstChildOfClass("SpawnLocation")
    if lobbySpawn then
        hrp.CFrame = lobbySpawn.CFrame + Vector3.new(0, 3, 0)
        ShowMessage("🏰 Teleported to Lobby!")
    else
        hrp.CFrame = CFrame.new(0, 100, 0)
        ShowMessage("🏰 Teleported to Lobby (alt)!")
    end
end

-- ============================================
-- 💥 FLING (ОБЫЧНЫЙ)
-- ============================================
function FlingByName(name)
    if name == "" then ShowMessage("❌ Введите имя!") return end
    local found = false
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and string.find(string.lower(p.Name), string.lower(name)) then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                local hum = p.Character:FindFirstChild("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot then myRoot.CFrame = hrp.CFrame * CFrame.new(0, 0, 2) task.wait(0.05) end
                    local dir = Vector3.new(math.random(-1, 1), 1.5, math.random(-1, 1)).Unit
                    hum.Sit = true
                    hrp.AssemblyLinearVelocity = dir * 5000
                    ShowMessage("💥 Fling: " .. p.Name)
                    found = true
                    break
                end
            end
        end
    end
    if not found then ShowMessage("❌ Игрок не найден!") end
end

function ToggleAutoFling()
    flingAutoEnabled = not flingAutoEnabled
    if flingAutoEnabled then
        ShowMessage("🔄 Auto Fling ON")
        flingAutoConnection = RunService.Heartbeat:Connect(function()
            if not flingAutoEnabled then return end
            local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if not myHrp then return end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local targetHrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if targetHrp then
                        local dist = (myHrp.Position - targetHrp.Position).Magnitude
                        if dist <= 10 then
                            local hum = p.Character:FindFirstChild("Humanoid")
                            if hum and hum.Health > 0 then
                                local dir = Vector3.new(math.random(-1, 1), 1.5, math.random(-1, 1)).Unit
                                hum.Sit = true
                                targetHrp.AssemblyLinearVelocity = dir * 5000
                            end
                        end
                    end
                end
            end
        end)
    else
        if flingAutoConnection then flingAutoConnection:Disconnect() end
        ShowMessage("🔄 Auto Fling OFF")
    end
end

-- ============================================
-- 🛠️ UTILITIES
-- ============================================
function ToggleAntiAFK()
    antiAFKEnabled = not antiAFKEnabled
    if antiAFKEnabled then
        antiAFKConnection = RunService.Heartbeat:Connect(function()
            if not antiAFKEnabled then return end
            if LP.Character and LP.Character:FindFirstChild("Humanoid") then
                local hum = LP.Character.Humanoid
                if hum:GetState() == Enum.HumanoidStateType.Seated then hum:ChangeState(Enum.HumanoidStateType.Running) end
                if tick() % 30 < 0.5 then hum.MoveDirection = Vector3.new(math.random(-1,1), 0, math.random(-1,1)).Unit end
            end
        end)
        ShowMessage("🛌 Anti-AFK ON")
    else
        if antiAFKConnection then antiAFKConnection:Disconnect() end
        ShowMessage("🛌 Anti-AFK OFF")
    end
end

function ToggleFPSBooster()
    fpsBoosterEnabled = not fpsBoosterEnabled
    if fpsBoosterEnabled then
        Lighting.GlobalShadows = false
        Lighting.Brightness = 0.5
        Lighting.Ambient = Color3.fromRGB(50,50,50)
        for _, v in pairs(workspace:GetDescendants()) do
            pcall(function()
                if v:IsA("Part") then v.Material = Enum.Material.SmoothPlastic v.Reflectance = 0 end
                if v:IsA("ParticleEmitter") then v.Enabled = false end
            end)
        end
        ShowMessage("⚡ FPS Booster ON")
    else
        Lighting.GlobalShadows = true
        Lighting.Brightness = 1
        Lighting.Ambient = originalAmbient
        ShowMessage("⚡ FPS Booster OFF")
    end
end

function ShowPlayerStats()
    local stats = ""
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            stats = stats .. p.Name .. "\n"
        end
    end
    ShowMessage("📊 Players:\n" .. stats)
end

function ShowServerInfo()
    local info = "🌐 Server Info:\n"
    info = info .. "Players: " .. #Players:GetPlayers() .. "/" .. game.Players.MaxPlayers .. "\n"
    info = info .. "Ping: " .. math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms"
    ShowMessage(info)
end

function ToggleMusicPlayer()
    musicPlayerEnabled = not musicPlayerEnabled
    if musicPlayerEnabled then
        if not musicPlayerGui then
            musicPlayerGui = Instance.new("ScreenGui", game.CoreGui)
            musicPlayerGui.Name = "MTY_MusicPlayer"
            local frame = Instance.new("Frame", musicPlayerGui)
            frame.Size = UDim2.new(0, 200, 0, 100)
            frame.Position = UDim2.new(0.01, 0, 0.3, 0)
            frame.BackgroundColor3 = guiSettings.BackgroundColor
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
            Instance.new("UIStroke", frame).Color = guiSettings.BorderColor
            local title = Instance.new("TextLabel", frame)
            title.Size = UDim2.new(1, 0, 0, 25)
            title.Text = "🎵 Music Player"
            title.TextColor3 = guiSettings.TextColor
            title.Font = Enum.Font.GothamBold
            title.TextScaled = true
            title.BackgroundTransparency = 1
            local track = Instance.new("TextLabel", frame)
            track.Size = UDim2.new(1, 0, 0, 30)
            track.Position = UDim2.new(0, 0, 0.3, 0)
            track.Text = "Playing: None"
            track.TextColor3 = guiSettings.TextColor
            track.Font = Enum.Font.GothamMedium
            track.TextSize = 10
            track.BackgroundTransparency = 1
            local playBtn = Instance.new("TextButton", frame)
            playBtn.Size = UDim2.new(0.3, 0, 0, 25)
            playBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
            playBtn.BackgroundColor3 = guiSettings.BorderColor
            playBtn.Text = "▶"
            playBtn.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", playBtn).CornerRadius = UDim.new(0, 6)
            local stopBtn = Instance.new("TextButton", frame)
            stopBtn.Size = UDim2.new(0.3, 0, 0, 25)
            stopBtn.Position = UDim2.new(0.38, 0, 0.65, 0)
            stopBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 60)
            stopBtn.Text = "⏹"
            stopBtn.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 6)
            local closeBtn = Instance.new("TextButton", frame)
            closeBtn.Size = UDim2.new(0.3, 0, 0, 25)
            closeBtn.Position = UDim2.new(0.7, 0, 0.65, 0)
            closeBtn.BackgroundColor3 = Color3.fromRGB(40,40,45)
            closeBtn.Text = "✖"
            closeBtn.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
            closeBtn.MouseButton1Click:Connect(ToggleMusicPlayer)
            musicPlayerGui.Visible = true
        end
        ShowMessage("🎵 Music Player ON")
    else
        if musicPlayerGui then musicPlayerGui:Destroy() end
        ShowMessage("🎵 Music Player OFF")
    end
end

-- ============================================
-- 🔥 ЭКСТРИМ
-- ============================================
function ToggleRageMode()
    rageModeEnabled = not rageModeEnabled
    if rageModeEnabled then
        aimbotEnabled = true
        killAuraEnabled = true
        antiAimEnabled = true
        noGravityEnabled = true
        ShowMessage("🔥 RAGE MODE ACTIVATED!")
    else
        aimbotEnabled = false
        killAuraEnabled = false
        antiAimEnabled = false
        noGravityEnabled = false
        ShowMessage("🔥 RAGE MODE DEACTIVATED")
    end
end

function ToggleGodMode()
    godModeEnabled = not godModeEnabled
    if godModeEnabled and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.Health = LP.Character.Humanoid.MaxHealth
    end
    ShowMessage("👑 God Mode "..(godModeEnabled and "ON" or "OFF"))
end

function ToggleOneHitKill()
    oneHitKillEnabled = not oneHitKillEnabled
    ShowMessage("💀 One Hit Kill "..(oneHitKillEnabled and "ON" or "OFF"))
end

function ToggleNoDamage()
    noDamageEnabled = not noDamageEnabled
    ShowMessage("🛡️ No Damage "..(noDamageEnabled and "ON" or "OFF"))
end

function ToggleLagSwitch()
    lagSwitchEnabled = not lagSwitchEnabled
    if lagSwitchEnabled then
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.Anchored = true
        end
        ShowMessage("⏳ Lag Switch ON")
    else
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.Anchored = false
        end
        ShowMessage("⏳ Lag Switch OFF")
    end
end

-- ============================================
-- 👁️ ESP FUNCTIONS
-- ============================================
function ToggleESP() espEnabled = not espEnabled ShowMessage("👁️ ESP "..(espEnabled and "ON" or "OFF")) end
function ToggleESPV2() espV2Enabled = not espV2Enabled ShowMessage("👁️ ESP V2 "..(espV2Enabled and "ON" or "OFF")) end
function ToggleESPV3() espV3Enabled = not espV3Enabled ShowMessage("👁️ ESP V3 (Bars) "..(espV3Enabled and "ON" or "OFF")) end
function ToggleESPV4() espV4Enabled = not espV4Enabled ShowMessage("👁️ ESP V4 (3D Boxes) "..(espV4Enabled and "ON" or "OFF")) end
function ToggleESPV5() espV5Enabled = not espV5Enabled ShowMessage("👁️ ESP V5 (Skeleton) "..(espV5Enabled and "ON" or "OFF")) end
function ToggleESPV6() espV6Enabled = not espV6Enabled ShowMessage("👁️ ESP V6 (Health Bar) "..(espV6Enabled and "ON" or "OFF")) end
function ToggleESPV7() espV7Enabled = not espV7Enabled ShowMessage("👁️ ESP V7 (Name Tag) "..(espV7Enabled and "ON" or "OFF")) end
function ToggleESPV8() espV8Enabled = not espV8Enabled ShowMessage("👁️ ESP V8 (Distance) "..(espV8Enabled and "ON" or "OFF")) end
function ToggleESPV9() espV9Enabled = not espV9Enabled ShowMessage("👁️ ESP V9 (Weapon) "..(espV9Enabled and "ON" or "OFF")) end
function ToggleESPV10() espV10Enabled = not espV10Enabled ShowMessage("👁️ ESP V10 (Ammo) "..(espV10Enabled and "ON" or "OFF")) end
function ToggleESPV11() espV11Enabled = not espV11Enabled ShowMessage("👁️ ESP V11 (Box+Line) "..(espV11Enabled and "ON" or "OFF")) end
function ToggleESPV12() espV12Enabled = not espV12Enabled ShowMessage("👁️ ESP V12 (Circle) "..(espV12Enabled and "ON" or "OFF")) end
function ToggleESPV13() espV13Enabled = not espV13Enabled ShowMessage("👁️ ESP V13 (Arrow) "..(espV13Enabled and "ON" or "OFF")) end
function ToggleESPV14() espV14Enabled = not espV14Enabled ShowMessage("👁️ ESP V14 (Radar) "..(espV14Enabled and "ON" or "OFF")) end
function ToggleESPV15() espV15Enabled = not espV15Enabled ShowMessage("👁️ ESP V15 (Tracker) "..(espV15Enabled and "ON" or "OFF")) end
function ToggleESPV16() espV16Enabled = not espV16Enabled ShowMessage("👁️ ESP V16 (Item) "..(espV16Enabled and "ON" or "OFF")) end
function ToggleESPV17() espV17Enabled = not espV17Enabled ShowMessage("👁️ ESP V17 (Chest) "..(espV17Enabled and "ON" or "OFF")) end
function ToggleESPV18() espV18Enabled = not espV18Enabled ShowMessage("👁️ ESP V18 (Vehicle) "..(espV18Enabled and "ON" or "OFF")) end
function ToggleTracers() tracersEnabled = not tracersEnabled ShowMessage("📏 Tracers "..(tracersEnabled and "ON" or "OFF")) end
function ToggleChams() chamsEnabled = not chamsEnabled ShowMessage("🎨 Chams "..(chamsEnabled and "ON" or "OFF")) end
function ToggleHitboxes() hitboxEnabled = not hitboxEnabled ShowMessage("📦 Hitboxes "..(hitboxEnabled and "ON" or "OFF")) end
function ToggleHitboxesV2() hitboxV2Enabled = not hitboxV2Enabled ShowMessage("📦 Hitboxes V2 "..(hitboxV2Enabled and "ON" or "OFF")) end
function ToggleSkeleton() skeletonEnabled = not skeletonEnabled ShowMessage("💀 Skeleton "..(skeletonEnabled and "ON" or "OFF")) end
function ToggleTargetHud() targetHudEnabled = not targetHudEnabled ShowMessage("📊 Target HUD "..(targetHudEnabled and "ON" or "OFF")) end
function ToggleTargetLine() targetLineEnabled = not targetLineEnabled ShowMessage("🔗 Target Line "..(targetLineEnabled and "ON" or "OFF")) end
function ToggleArrowIndicators() arrowIndicatorsEnabled = not arrowIndicatorsEnabled ShowMessage("🔺 Arrow Indicators "..(arrowIndicatorsEnabled and "ON" or "OFF")) end
function ToggleHitGlow() hitGlowEnabled = not hitGlowEnabled ShowMessage("✨ HitGlow "..(hitGlowEnabled and "ON" or "OFF")) end
function ToggleBlockESP() blockEspEnabled = not blockEspEnabled ShowMessage("🧱 Block ESP "..(blockEspEnabled and "ON" or "OFF")) end
function ToggleDamageIndicators() damageIndEnabled = not damageIndEnabled ShowMessage("💥 Damage Indicators "..(damageIndEnabled and "ON" or "OFF")) end

-- ============================================
-- 👁️ АВТО-ОБНОВЛЕНИЕ ПРИ СМЕРТИ
-- ============================================
local function SafeAdorn(folder, char, size, color)
    if not char:FindFirstChild("HumanoidRootPart") then return end
    local b = Instance.new("BoxHandleAdornment", folder) 
    b.Size = size 
    b.Color3 = color 
    b.Transparency = 0.6 
    b.AlwaysOnTop = true 
    b.Adornee = char.HumanoidRootPart
end

task.spawn(function()
    while true do 
        task.wait(0.2) 
        pcall(function()
            espFolder:ClearAllChildren() 
            espV2Folder:ClearAllChildren() 
            skeletonFolder:ClearAllChildren() 
            HitboxFolder:ClearAllChildren()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local c = p.Character
                    if espEnabled then 
                        local h = Instance.new("Highlight", espFolder) 
                        h.Adornee = c 
                        h.FillColor = guiSettings.ESPColor 
                        h.FillTransparency = 0.4 
                    end
                    if espV2Enabled then SafeAdorn(espV2Folder, c, Vector3.new(4.3, 5.6, 4.3), guiSettings.ESPColor) end
                    if hitboxEnabled then SafeAdorn(HitboxFolder, c, c.HumanoidRootPart.Size * 2, guiSettings.HitboxColor) end
                    if hitboxV2Enabled then SafeAdorn(HitboxFolder, c, Vector3.new(6,6,6), guiSettings.HitboxColor) end
                    if skeletonEnabled and c:FindFirstChild("Head") then SafeAdorn(skeletonFolder, c, c.Head.Size * 1.2, guiSettings.ESPColor) end
                end
            end
        end) 
    end
end)

LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if hatEnabled then CreateChineseHat() end
    if trailV2Enabled then ToggleTrailV2() end
    if invisibilityEnabled then
        for _, v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.Transparency = 0.99 end
        end
    end
end)

-- ============================================
-- 🖥️ МИНИМИЗАЦИЯ
-- ============================================
local function CreateMiniButton()
    if miniGui then miniGui:Destroy() end
    miniGui = Instance.new("ScreenGui", game.CoreGui)
    miniGui.Name = "MTY_MiniButton"
    miniGui.ResetOnSpawn = false
    miniButton = Instance.new("ImageButton", miniGui)
    miniButton.Size = UDim2.new(0, 80, 0, 80)
    miniButton.Position = UDim2.new(0.01, 0, 0.85, 0)
    miniButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    miniButton.BackgroundTransparency = 0.2
    miniButton.Image = "https://i.pinimg.com/564x/02/0f/f3/020ff3b6a640ce213f7522a2a9336808.jpg"
    miniButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", miniButton).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", miniButton).Color = guiSettings.BorderColor
    miniButton.Draggable = true
    miniButton.MouseButton1Click:Connect(function()
        if minimized then minimized = false miniButton.Visible = false guiMainFrame.Visible = true end
    end)
    miniButton.Visible = false
end

-- ============================================
-- СОЗДАНИЕ МЕНЮ
-- ============================================
local function CreateMenu()
    screenGui = Instance.new("ScreenGui", game.CoreGui) screenGui.Name = "MTY_HUB_V6"
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
    title.Text = "MTY HUB v6.0 Premium" 
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
            infoPanel.Text = " FPS: " .. math.floor(workspace:GetRealPhysicsFPS()) .. "  |  PING: " .. math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms " 
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
    minBtn.MouseButton1Click:Connect(function()
        if not minimized then minimized = true guiMainFrame.Visible = false if not miniButton then CreateMiniButton() end miniButton.Visible = true end
    end)
    
    local clsBtn = Instance.new("TextButton", guiMainFrame) 
    clsBtn.Size = UDim2.new(0, 32, 0, 32) 
    clsBtn.Position = UDim2.new(1, -38, 0, 10) 
    clsBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 60) 
    clsBtn.Text = "X" 
    clsBtn.TextColor3 = Color3.fromRGB(255, 255, 255) 
    clsBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", clsBtn).CornerRadius = UDim.new(0, 8)
    clsBtn.MouseButton1Click:Connect(function() 
        screenGui:Destroy() 
        fovGui:Destroy() 
        if targetHudFrame then targetHudFrame:Destroy() end 
        if dashButton then dashButton.Parent:Destroy() end 
        if miniGui then miniGui:Destroy() end
        if musicPlayerGui then musicPlayerGui:Destroy() end
        if iyFlyGui then iyFlyGui:Destroy() end
    end)

    blurEffect = Instance.new("BlurEffect", Lighting) 
    blurEffect.Enabled = guiSettings.BlurEnabled
    blurEffect.Size = guiSettings.BlurSize

    local leftPanel = Instance.new("ScrollingFrame", guiMainFrame) 
    leftPanel.Size = UDim2.new(0, 120, 0, 345) 
    leftPanel.Position = UDim2.new(0.02, 0, 0.13, 0) 
    leftPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 26) 
    leftPanel.BackgroundTransparency = 0.2
    leftPanel.ScrollBarThickness = 4
    Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 10)
    
    local tabsContainer = Instance.new("Frame", leftPanel)
    tabsContainer.Size = UDim2.new(1, 0, 1, 0)
    tabsContainer.BackgroundTransparency = 1
    
    searchBox = Instance.new("TextBox", guiMainFrame) 
    searchBox.Size = UDim2.new(0.68, 0, 0, 32) 
    searchBox.Position = UDim2.new(0.28, 0, 0.15, 0) 
    searchBox.BackgroundColor3 = Color3.fromRGB(22, 22, 26) 
    searchBox.Text = "" 
    searchBox.TextColor3 = guiSettings.TextColor
    searchBox.PlaceholderText = "🔍 Search module..."
    searchBox.Font = Enum.Font.GothamMedium
    searchBox.TextSize = 12
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 8) 
    Instance.new("UIStroke", searchBox).Color = Color3.fromRGB(40,40,50)
    
    contentArea = Instance.new("ScrollingFrame", guiMainFrame) 
    contentArea.Size = UDim2.new(0.68, 0, 0, 285) 
    contentArea.Position = UDim2.new(0.28, 0, 0.25, 0) 
    contentArea.BackgroundTransparency = 1
    contentArea.ScrollBarThickness = 5
    contentArea.ScrollBarImageColor3 = guiSettings.BorderColor

    -- ФУНКЦИЯ СТАТУСА
    local function GetStatusStr(name)
        if name == "Toggle ESP" then return espEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V2" then return espV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V3 (Bars) 📊" then return espV3Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V4 (3D Boxes) 📦" then return espV4Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V5 (Skeleton) 💀" then return espV5Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V6 (Health Bar) ❤️" then return espV6Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V7 (Name Tag) 🏷️" then return espV7Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V8 (Distance) 📏" then return espV8Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V9 (Weapon) 🔫" then return espV9Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V10 (Ammo) 🔄" then return espV10Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V11 (Box+Line) 📦" then return espV11Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V12 (Circle) ⭕" then return espV12Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V13 (Arrow) 🔺" then return espV13Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V14 (Radar) 🗺️" then return espV14Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V15 (Tracker) 🎯" then return espV15Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V16 (Item) 📦" then return espV16Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V17 (Chest) 🎁" then return espV17Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V18 (Vehicle) 🚗" then return espV18Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Tracers" then return tracersEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Chams" then return chamsEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Hitboxes" then return hitboxEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Hitboxes V2 (Minecraft) 🧱" then return hitboxV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Skeleton" then return skeletonEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Jump Circle" then return jumpCircleEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Trail" then return trailEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Trail V2 🎀" then return trailV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Chinese Hat" then return hatEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle World Color" then return worldColorEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Stretch" then return stretchEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Infinite Jump 🦘" then return infJumpEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Super Jump 🚀" then return superJumpEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Air Walk ☁️" then return airWalkEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Fly V1 ✈️" then return flyV1Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Fly V2 ☁️" then return flyV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Fly V3 🌊" then return flyV3Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Fly V4 🌀" then return flyV4Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Fly V5 ⚡" then return flyV5Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle IY Fly ✈️" then return iyFlyEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Teleport Tool 🛠️" then return tpToolEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Auto Sprint 🏃" then return autoSprintEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Spin 🌀" then return spinEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle NoClip 🚫" then return noClipEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Spider Mode 🕷️" then return spiderEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Swim In Air 🏊" then return swimEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Dash 🏃" then return dashEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle No Jump Cooldown 🦘" then return noJumpCdEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Blink Mode 👻" then return blinkEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Invisibility 👤" then return invisibilityEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Helicopter 🚁" then return helicopterEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Strafe ✈️" then return strafeEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Bunny Hop 🐰" then return bunnyHopEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Ghost Mode 👻" then return ghostModeEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Wall Climb 🧱" then return wallClimbEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Wall Jump 🧱" then return wallJumpEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Wall Run 🏃" then return wallRunEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle No Fall Damage 🪂" then return noFallDamageEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Water Walk 💧" then return waterWalkEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Lava Walk 🔥" then return lavaWalkEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle No Gravity 🌌" then return noGravityEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Time Freeze ⏸️" then return timeFreezeEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle WalkFling 🚶" then return walkFlingEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Aimbot" then return aimbotEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Silent Aim 🎯" then return aimbotV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Prediction Aim 🚀" then return aimbotV3Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Smooth Aim 🌊" then return aimbotV4Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle FOV Aim ⭕" then return aimbotV5Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Trigger Aim 🎯" then return aimbotV6Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Wallbang Aim 🧱" then return aimbotV7Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Head Only 🎯" then return aimbotV8Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Body Only 🎯" then return aimbotV9Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Nearest Aim 🎯" then return aimbotV10Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Kill Aura ⚔️" then return killAuraEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Kill Aura V2 (HvH) 🔥" then return killAuraV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Kill Aura V3 (Teleport) ⚔️" then return killAuraV3Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Trigger Bot 🎯" then return triggerBotEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Auto-Clicker 🖱️" then return autoClickerEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Auto-Clicker V2 ⚡" then return autoClickerV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Auto-Heal ❤️" then return autoHealEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Auto-Parry 🛡️" then return autoParryEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Auto-Dodge 💨" then return autoDodgeEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Auto-Reload 🔄" then return autoReloadEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Critical Hit 💥" then return criticalHitEnabled and " [ON]" or " [OFF]"
        elseif name == "HvH Resolver 🎯" then return resolverEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Anti-Aim 🌀" then return antiAimEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Fake Lag ⏳" then return fakeLagEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Anti-Knockback ⚓" then return antiKbEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Anti-Knockback V2 ⚓" then return antiKbV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Anti-Stun ⚡" then return antiStunEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Anti-Freeze ❄️" then return antiFreezeEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Anti-Slow 🐢" then return antiSlowEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Desync 🌀" then return desyncEnabled and " [ON]" or " [OFF]"
        elseif name == "Fake Ping 📶" then return fakePingEnabled and " [ON]" or " [OFF]"
        -- MM2
        elseif name == "MM2 ESP 🔪" then return mm2EspEnabled and " [ON]" or " [OFF]"
        elseif name == "MM2 ESP V2 🔪" then return mm2EspV2Enabled and " [ON]" or " [OFF]"
        elseif name == "MM2 ESP Roles 👁️" then return mm2EspRolesEnabled and " [ON]" or " [OFF]"
        elseif name == "MM2 Aimbot 🎯" then return mm2AimbotEnabled and " [ON]" or " [OFF]"
        elseif name == "MM2 Trigger Bot 🔫" then return mm2TriggerBotEnabled and " [ON]" or " [OFF]"
        elseif name == "MM2 Kill Aura V1 ⚔️" then return mm2KillAuraEnabled and " [ON]" or " [OFF]"
        elseif name == "MM2 Kill Aura V2 (Teleport) ⚔️" then return mm2KillAuraV2Enabled and " [ON]" or " [OFF]"
        elseif name == "MM2 Silent Aim 🎯" then return mm2SilentAimEnabled and " [ON]" or " [OFF]"
        elseif name == "MM2 Anti-Knife 🛡️" then return mm2AntiKnifeEnabled and " [ON]" or " [OFF]"
        elseif name == "MM2 Grab Gun V1 🔫" then return mm2GrabGunEnabled and " [ON]" or " [OFF]"
        elseif name == "MM2 Grab Gun V2 🔫" then return mm2GrabGunV2Enabled and " [ON]" or " [OFF]"
        elseif name == "MM2 Fling Murderer 🔪" then return mm2FlingMurdererEnabled and " [ON]" or " [OFF]"
        elseif name == "MM2 Fling Sheriff ⭐" then return mm2FlingSheriffEnabled and " [ON]" or " [OFF]"
        elseif name == "MM2 Auto Shoot 🎯" then return mm2AutoShootEnabled and " [ON]" or " [OFF]"
        elseif name == "MM2 Speed Hack ⚡" then return mm2SpeedHackEnabled and " [ON]" or " [OFF]"
        elseif name == "MM2 No Recoil 🔫" then return mm2NoRecoilEnabled and " [ON]" or " [OFF]"
        elseif name == "MM2 No Spread 🎯" then return mm2NoSpreadEnabled and " [ON]" or " [OFF]"
        elseif name == "MM2 Fast Reload 🔄" then return mm2FastReloadEnabled and " [ON]" or " [OFF]"
        elseif name == "MM2 Infinite Ammo ♾️" then return mm2InfiniteAmmoEnabled and " [ON]" or " [OFF]"
        elseif name == "MM2 TP to Lobby 🏰" then return " 🏰"
        -- FLING
        elseif name == "Auto Fling 🔄" then return flingAutoEnabled and " [ON]" or " [OFF]"
        -- IY Functions
        elseif name == "IY Fling 🚀" then return " 🚀"
        elseif name == "IY Goto ⚡" then return " ⚡"
        -- UTILITIES
        elseif name == "Anti-AFK 🛌" then return antiAFKEnabled and " [ON]" or " [OFF]"
        elseif name == "FPS Booster ⚡" then return fpsBoosterEnabled and " [ON]" or " [OFF]"
        elseif name == "Music Player 🎵" then return musicPlayerEnabled and " [ON]" or " [OFF]"
        -- EXTREME
        elseif name == "Rage Mode 🔥" then return rageModeEnabled and " [ON]" or " [OFF]"
        elseif name == "God Mode 👑" then return godModeEnabled and " [ON]" or " [OFF]"
        elseif name == "One Hit Kill 💀" then return oneHitKillEnabled and " [ON]" or " [OFF]"
        elseif name == "No Damage 🛡️" then return noDamageEnabled and " [ON]" or " [OFF]"
        elseif name == "Lag Switch ⏳" then return lagSwitchEnabled and " [ON]" or " [OFF]"
        -- SETTINGS
        elseif name == "Transparency" then return " " .. string.format("%.2f", guiSettings.Transparency)
        elseif name == "Blur Size" then return " " .. guiSettings.BlurSize
        end return ""
    end

    -- РЕНДЕР КНОПОК
    local function RenderSubs(subs)
        for _, v in pairs(contentArea:GetChildren()) do if not v:IsA("UICorner") then v:Destroy() end end
        local grid = Instance.new("Frame", contentArea) 
        grid.Size = UDim2.new(0.96, 0, 1, 0) 
        grid.BackgroundTransparency = 1
        local searchT = searchBox.Text:lower()
        local filtered = {}
        for _, name in ipairs(subs) do if searchT == "" or name:lower():find(searchT) then table.insert(filtered, name) end end
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
            btn.TextSize = 10
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6) 
            local bs = Instance.new("UIStroke", btn) 
            bs.Color = Color3.fromRGB(45,45,55)
            
            btn.MouseButton1Click:Connect(function()
                if name == "Toggle ESP" then ToggleESP()
                elseif name == "Toggle ESP V2" then ToggleESPV2()
                elseif name == "Toggle ESP V3 (Bars) 📊" then ToggleESPV3()
                elseif name == "Toggle ESP V4 (3D Boxes) 📦" then ToggleESPV4()
                elseif name == "Toggle ESP V5 (Skeleton) 💀" then ToggleESPV5()
                elseif name == "Toggle ESP V6 (Health Bar) ❤️" then ToggleESPV6()
                elseif name == "Toggle ESP V7 (Name Tag) 🏷️" then ToggleESPV7()
                elseif name == "Toggle ESP V8 (Distance) 📏" then ToggleESPV8()
                elseif name == "Toggle ESP V9 (Weapon) 🔫" then ToggleESPV9()
                elseif name == "Toggle ESP V10 (Ammo) 🔄" then ToggleESPV10()
                elseif name == "Toggle ESP V11 (Box+Line) 📦" then ToggleESPV11()
                elseif name == "Toggle ESP V12 (Circle) ⭕" then ToggleESPV12()
                elseif name == "Toggle ESP V13 (Arrow) 🔺" then ToggleESPV13()
                elseif name == "Toggle ESP V14 (Radar) 🗺️" then ToggleESPV14()
                elseif name == "Toggle ESP V15 (Tracker) 🎯" then ToggleESPV15()
                elseif name == "Toggle ESP V16 (Item) 📦" then ToggleESPV16()
                elseif name == "Toggle ESP V17 (Chest) 🎁" then ToggleESPV17()
                elseif name == "Toggle ESP V18 (Vehicle) 🚗" then ToggleESPV18()
                elseif name == "Toggle Tracers" then ToggleTracers()
                elseif name == "Toggle Chams" then ToggleChams()
                elseif name == "Toggle Hitboxes" then ToggleHitboxes()
                elseif name == "Toggle Hitboxes V2 (Minecraft) 🧱" then ToggleHitboxesV2()
                elseif name == "Toggle Skeleton" then ToggleSkeleton()
                elseif name == "Toggle Jump Circle" then ToggleJumpCircle()
                elseif name == "Toggle Trail" then ToggleTrail()
                elseif name == "Toggle Trail V2 🎀" then ToggleTrailV2()
                elseif name == "Toggle Particles V2 ☁️" then ToggleParticlesV2()
                elseif name == "Particle Color 🎨" then OpenColorPicker("Particle Color", function(c) guiSettings.ParticleColor = c ShowMessage("🎨 Particle Color Changed!") end)
                elseif name == "Toggle Chinese Hat" then ToggleChineseHat()
                elseif name == "Hat Color" then OpenColorPicker("Hat Color", function(c) guiSettings.HatColor = c if hatEnabled then CreateChineseHat() end end)
                elseif name == "Rainbow China Hat 🌈" then ToggleRainbowHat()
                elseif name == "Toggle World Color" then ToggleWorldColor()
                elseif name == "World Color Select 🎨" then OpenWorldColorPicker()
                elseif name == "Toggle Stretch" then ToggleStretch()
                elseif name == "Stretch Value 📏" then OpenTextInput("Stretch Value", "0.3 - 1.7", getgenv().Resolution[".gg/scripters"], SetStretchValue)
                elseif name == "Toggle Skybox 🌤️" then ToggleSkybox()
                elseif name == "Toggle No Fog 🌫️" then ToggleNoFog()
                elseif name == "Toggle No Shadows 🌑" then ToggleNoShadows()
                elseif name == "Toggle No Grass 🌿" then ToggleNoGrass()
                elseif name == "Toggle No Trees 🌳" then ToggleNoTrees()
                elseif name == "Toggle No Clouds ☁️" then ToggleNoClouds()
                elseif name == "Toggle No Rain ☔" then ToggleNoRain()
                elseif name == "Toggle No Snow ❄️" then ToggleNoSnow()
                elseif name == "Toggle No Wind 💨" then ToggleNoWind()
                elseif name == "Toggle No Particles ✨" then ToggleNoParticles()
                elseif name == "Toggle No Decals 🖼️" then ToggleNoDecals()
                elseif name == "Toggle No Textures 🎨" then ToggleNoTextures()
                elseif name == "Toggle Low Poly 📐" then ToggleLowPoly()
                elseif name == "Toggle Cartoon Mode 🎬" then ToggleCartoonMode()
                elseif name == "Toggle Night Vision 🌙" then ToggleNightVision()
                elseif name == "Toggle Thermal Vision 🔥" then ToggleThermalVision()
                elseif name == "Toggle Fullbright ☀️" then ToggleFullbright()
                elseif name == "Toggle Crosshair 🎯" then ToggleCrosshair()
                elseif name == "Speed" then OpenTextInput("Speed", "0-99999", speedValue, SetSpeed)
                elseif name == "Gravity" then OpenTextInput("Gravity", "-1000-10000", workspace.Gravity, SetGravity)
                elseif name == "Toggle Infinite Jump 🦘" then ToggleInfiniteJump()
                elseif name == "Toggle Super Jump 🚀" then ToggleSuperJump()
                elseif name == "Toggle Air Walk ☁️" then ToggleAirWalk()
                elseif name == "Toggle Fly V1 ✈️" then ToggleFlyV1()
                elseif name == "Toggle Fly V2 ☁️" then ToggleFlyV2()
                elseif name == "Toggle Fly V3 🌊" then ToggleFlyV3()
                elseif name == "Toggle Fly V4 🌀" then ToggleFlyV4()
                elseif name == "Toggle Fly V5 ⚡" then ToggleFlyV5()
                elseif name == "Toggle IY Fly ✈️" then ToggleIYFly()
                elseif name == "Toggle Teleport Tool 🛠️" then ToggleTeleportTool()
                elseif name == "Toggle Auto Sprint 🏃" then ToggleAutoSprint()
                elseif name == "Toggle Spin 🌀" then ToggleSpin()
                elseif name == "Toggle NoClip 🚫" then ToggleNoClip()
                elseif name == "Toggle Spider Mode 🕷️" then ToggleSpider()
                elseif name == "Toggle Swim In Air 🏊" then ToggleSwim()
                elseif name == "Toggle Dash 🏃" then ToggleDash()
                elseif name == "Toggle No Jump Cooldown 🦘" then ToggleNoJumpCooldown()
                elseif name == "Toggle Blink Mode 👻" then ToggleBlinkMode()
                elseif name == "Toggle Invisibility 👤" then ToggleInvisibility()
                elseif name == "Toggle Helicopter 🚁" then ToggleHelicopter()
                elseif name == "Toggle Strafe ✈️" then ToggleStrafe()
                elseif name == "Toggle Bunny Hop 🐰" then ToggleBunnyHop()
                elseif name == "Toggle Ghost Mode 👻" then ToggleGhostMode()
                elseif name == "Toggle Wall Climb 🧱" then ToggleWallClimb()
                elseif name == "Toggle Wall Jump 🧱" then ToggleWallJump()
                elseif name == "Toggle Wall Run 🏃" then ToggleWallRun()
                elseif name == "Toggle No Fall Damage 🪂" then ToggleNoFallDamage()
                elseif name == "Toggle Water Walk 💧" then ToggleWaterWalk()
                elseif name == "Toggle Lava Walk 🔥" then ToggleLavaWalk()
                elseif name == "Toggle No Gravity 🌌" then ToggleNoGravity()
                elseif name == "Toggle Time Freeze ⏸️" then ToggleTimeFreeze()
                elseif name == "Toggle WalkFling 🚶" then ToggleWalkFling()
                elseif name == "Toggle Aimbot" then ToggleAimbot()
                elseif name == "Toggle Silent Aim 🎯" then ToggleAimbotV2()
                elseif name == "Toggle Prediction Aim 🚀" then ToggleAimbotV3()
                elseif name == "Toggle Smooth Aim 🌊" then ToggleAimbotV4()
                elseif name == "Toggle FOV Aim ⭕" then ToggleAimbotV5()
                elseif name == "Toggle Trigger Aim 🎯" then ToggleAimbotV6()
                elseif name == "Toggle Wallbang Aim 🧱" then ToggleAimbotV7()
                elseif name == "Toggle Head Only 🎯" then ToggleAimbotV8()
                elseif name == "Toggle Body Only 🎯" then ToggleAimbotV9()
                elseif name == "Toggle Nearest Aim 🎯" then ToggleAimbotV10()
                elseif name == "Aimbot Speed" then OpenTextInput("Aimbot Speed", "0.01-1", guiSettings.AimbotSpeed, SetAimbotSpeed)
                elseif name == "Aimbot Strength" then OpenTextInput("Strength", "0.1-1", guiSettings.AimbotStrength, SetAimbotStrength)
                elseif name == "Aimbot FOV" then OpenTextInput("FOV Size", "10-500", guiSettings.AimbotFOV, SetAimbotFOV)
                elseif name == "Toggle Kill Aura ⚔️" then ToggleKillAura()
                elseif name == "Toggle Kill Aura V2 (HvH) 🔥" then ToggleKillAuraV2()
                elseif name == "Toggle Kill Aura V3 (Teleport) ⚔️" then ToggleKillAuraV3()
                elseif name == "Kill Aura Range" then OpenTextInput("Aura Range", "1-50", guiSettings.KillAuraRange, SetKillAuraRange)
                elseif name == "Tool Reach 📏" then OpenTextInput("Reach Size", "1-20", guiSettings.ToolReachValue, SetToolReach)
                elseif name == "Toggle Trigger Bot 🎯" then ToggleTriggerBot()
                elseif name == "Toggle Auto-Clicker 🖱️" then ToggleAutoClicker()
                elseif name == "Toggle Auto-Clicker V2 ⚡" then ToggleAutoClickerV2()
                elseif name == "Toggle Auto-Heal ❤️" then ToggleAutoHeal()
                elseif name == "Toggle Auto-Parry 🛡️" then ToggleAutoParry()
                elseif name == "Toggle Auto-Dodge 💨" then ToggleAutoDodge()
                elseif name == "Toggle Auto-Reload 🔄" then ToggleAutoReload()
                elseif name == "Toggle Critical Hit 💥" then ToggleCriticalHit()
                elseif name == "HvH Resolver 🎯" then ToggleResolver()
                elseif name == "Toggle Anti-Aim 🌀" then ToggleAntiAim()
                elseif name == "Anti-Aim Mode: Spin" then SetAntiAimMode("Spin")
                elseif name == "Anti-Aim Mode: Backwards" then SetAntiAimMode("Backwards")
                elseif name == "Anti-Aim Mode: Jitter" then SetAntiAimMode("Jitter")
                elseif name == "Toggle Fake Lag ⏳" then ToggleFakeLag()
                elseif name == "Fake Lag Amount" then OpenTextInput("Fake Lag", "1-20", guiSettings.FakeLagAmount, SetFakeLagAmount)
                elseif name == "Toggle Anti-Knockback ⚓" then ToggleAntiKb()
                elseif name == "Toggle Anti-Knockback V2 ⚓" then ToggleAntiKbV2()
                elseif name == "Toggle Anti-Stun ⚡" then ToggleAntiStun()
                elseif name == "Toggle Anti-Freeze ❄️" then ToggleAntiFreeze()
                elseif name == "Toggle Anti-Slow 🐢" then ToggleAntiSlow()
                elseif name == "Toggle Desync 🌀" then ToggleDesync()
                elseif name == "Fake Ping 📶" then ToggleFakePing()
                elseif name == "Fake Ping Value" then OpenTextInput("Fake Ping Value", "50-999", guiSettings.FakePingValue, SetFakePingValue)
                elseif name == "Fake Ping Mode: Static" then SetFakePingMode("Static")
                elseif name == "Fake Ping Mode: Jump" then SetFakePingMode("Jump")
                elseif name == "Fake Ping Mode: Wave" then SetFakePingMode("Wave")
                -- MM2
                elseif name == "MM2 ESP 🔪" then ToggleMM2ESP()
                elseif name == "MM2 ESP V2 🔪" then ToggleMM2ESPV2()
                elseif name == "MM2 ESP Roles 👁️" then ToggleMM2EspRoles()
                elseif name == "MM2 Aimbot 🎯" then ToggleMM2Aimbot()
                elseif name == "MM2 Trigger Bot 🔫" then ToggleMM2TriggerBot()
                elseif name == "MM2 Kill Aura V1 ⚔️" then ToggleMM2KillAura()
                elseif name == "MM2 Kill Aura V2 (Teleport) ⚔️" then ToggleMM2KillAuraV2()
                elseif name == "MM2 Silent Aim 🎯" then ToggleMM2SilentAim()
                elseif name == "MM2 Anti-Knife 🛡️" then ToggleMM2AntiKnife()
                elseif name == "MM2 Grab Gun V1 🔫" then ToggleMM2GrabGun()
                elseif name == "MM2 Grab Gun V2 🔫" then ToggleMM2GrabGunV2()
                elseif name == "MM2 Grab Method: Teleport" then SetGrabMethod("Teleport")
                elseif name == "MM2 Grab Method: Bring" then SetGrabMethod("Bring")
                elseif name == "MM2 Fling Murderer 🔪" then ToggleMM2FlingMurderer()
                elseif name == "MM2 Fling Sheriff ⭐" then ToggleMM2FlingSheriff()
                elseif name == "MM2 Auto Shoot 🎯" then ToggleMM2AutoShoot()
                elseif name == "MM2 Speed Hack ⚡" then ToggleMM2SpeedHack()
                elseif name == "MM2 No Recoil 🔫" then ToggleMM2NoRecoil()
                elseif name == "MM2 No Spread 🎯" then ToggleMM2NoSpread()
                elseif name == "MM2 Fast Reload 🔄" then ToggleMM2FastReload()
                elseif name == "MM2 Infinite Ammo ♾️" then ToggleMM2InfiniteAmmo()
                elseif name == "MM2 TP to Lobby 🏰" then ToggleMM2TPtoLobby()
                -- FLING
                elseif name == "Fling by Name 📝" then OpenTextInput("🎯 Fling by Name", "Enter player name", "", FlingByName)
                elseif name == "Auto Fling 🔄" then ToggleAutoFling()
                -- IY Functions
                elseif name == "IY Fling 🚀" then OpenIYFling()
                elseif name == "IY Goto ⚡" then OpenIYGoto()
                -- UTILITIES
                elseif name == "Anti-AFK 🛌" then ToggleAntiAFK()
                elseif name == "FPS Booster ⚡" then ToggleFPSBooster()
                elseif name == "Player Stats 📊" then ShowPlayerStats()
                elseif name == "Server Info 🌐" then ShowServerInfo()
                elseif name == "Music Player 🎵" then ToggleMusicPlayer()
                -- EXTREME
                elseif name == "Rage Mode 🔥" then ToggleRageMode()
                elseif name == "God Mode 👑" then ToggleGodMode()
                elseif name == "One Hit Kill 💀" then ToggleOneHitKill()
                elseif name == "No Damage 🛡️" then ToggleNoDamage()
                elseif name == "Lag Switch ⏳" then ToggleLagSwitch()
                -- SETTINGS
                elseif name == "Background Color 🎨" then OpenColorPicker("Background Color", SetBackgroundColor)
                elseif name == "Border Color 🎨" then OpenColorPicker("Border Color", SetBorderColor)
                elseif name == "Text Color 🎨" then OpenColorPicker("Text Color", SetTextColor)
                elseif name == "Transparency" then OpenTextInput("Transparency", "0-0.8", guiSettings.Transparency, SetTransparency)
                elseif name == "Toggle Blur" then ToggleBlur()
                elseif name == "Blur Size" then OpenTextInput("Blur Size", "1-30", guiSettings.BlurSize, SetBlurSize)
                elseif name == "Trail Color" then OpenColorPicker("Trail Color", function(c) guiSettings.TrailColor = c if actualTrailInstance then actualTrailInstance.Color = ColorSequence.new(c) end end)
                elseif name == "Jump Circle Color" then OpenColorPicker("Jump Circle Color", function(c) guiSettings.JumpCircleColor = c end)
                end
                RenderSubs(subs)
            end)
        end
        contentArea.CanvasSize = UDim2.new(0, 0, 0, #filtered * 34 + 15)
    end
    
    searchBox:GetPropertyChangedSignal("Text"):Connect(function() if currentCategory ~= "" then RenderSubs(allSubs) end end)
    
    local categories = {
        VISUAL = {"Toggle ESP", "Toggle ESP V2", "Toggle ESP V3 (Bars) 📊", "Toggle ESP V4 (3D Boxes) 📦", "Toggle ESP V5 (Skeleton) 💀", "Toggle ESP V6 (Health Bar) ❤️", "Toggle ESP V7 (Name Tag) 🏷️", "Toggle ESP V8 (Distance) 📏", "Toggle ESP V9 (Weapon) 🔫", "Toggle ESP V10 (Ammo) 🔄", "Toggle ESP V11 (Box+Line) 📦", "Toggle ESP V12 (Circle) ⭕", "Toggle ESP V13 (Arrow) 🔺", "Toggle ESP V14 (Radar) 🗺️", "Toggle ESP V15 (Tracker) 🎯", "Toggle ESP V16 (Item) 📦", "Toggle ESP V17 (Chest) 🎁", "Toggle ESP V18 (Vehicle) 🚗", "Toggle Tracers", "Toggle Chams", "Toggle Hitboxes", "Toggle Hitboxes V2 (Minecraft) 🧱", "Toggle Skeleton", "Toggle Jump Circle", "Jump Circle Color", "Toggle Trail", "Toggle Trail V2 🎀", "Trail Color", "Toggle Particles V2 ☁️", "Particle Color 🎨", "Toggle Chinese Hat", "Hat Color", "Rainbow China Hat 🌈", "Toggle Fullbright ☀️", "Toggle World Color", "World Color Select 🎨", "Toggle Stretch", "Stretch Value 📏", "Toggle Crosshair 🎯", "Toggle Skybox 🌤️", "Toggle No Fog 🌫️", "Toggle No Shadows 🌑", "Toggle No Grass 🌿", "Toggle No Trees 🌳", "Toggle No Clouds ☁️", "Toggle No Rain ☔", "Toggle No Snow ❄️", "Toggle No Wind 💨", "Toggle No Particles ✨", "Toggle No Decals 🖼️", "Toggle No Textures 🎨", "Toggle Low Poly 📐", "Toggle Cartoon Mode 🎬", "Toggle Night Vision 🌙", "Toggle Thermal Vision 🔥"},
        PLAYER = {"Speed", "Gravity", "Toggle Infinite Jump 🦘", "Toggle Super Jump 🚀", "Toggle Air Walk ☁️", "Toggle Fly V1 ✈️", "Toggle Fly V2 ☁️", "Toggle Fly V3 🌊", "Toggle Fly V4 🌀", "Toggle Fly V5 ⚡", "Toggle IY Fly ✈️", "Toggle Teleport Tool 🛠️", "Toggle Auto Sprint 🏃", "Toggle Spin 🌀", "Toggle NoClip 🚫", "Toggle Spider Mode 🕷️", "Toggle Swim In Air 🏊", "Toggle Dash 🏃", "Toggle No Jump Cooldown 🦘", "Toggle Blink Mode 👻", "Toggle Invisibility 👤", "Toggle Helicopter 🚁", "Toggle Strafe ✈️", "Toggle Bunny Hop 🐰", "Toggle Ghost Mode 👻", "Toggle Wall Climb 🧱", "Toggle Wall Jump 🧱", "Toggle Wall Run 🏃", "Toggle No Fall Damage 🪂", "Toggle Water Walk 💧", "Toggle Lava Walk 🔥", "Toggle No Gravity 🌌", "Toggle Time Freeze ⏸️", "Toggle WalkFling 🚶"},
        COMBAT = {"Toggle Aimbot", "Toggle Silent Aim 🎯", "Toggle Prediction Aim 🚀", "Toggle Smooth Aim 🌊", "Toggle FOV Aim ⭕", "Toggle Trigger Aim 🎯", "Toggle Wallbang Aim 🧱", "Toggle Head Only 🎯", "Toggle Body Only 🎯", "Toggle Nearest Aim 🎯", "Aimbot Speed", "Aimbot Strength", "Aimbot FOV", "Toggle Kill Aura ⚔️", "Toggle Kill Aura V2 (HvH) 🔥", "Toggle Kill Aura V3 (Teleport) ⚔️", "Kill Aura Range", "Tool Reach 📏", "Toggle Trigger Bot 🎯", "Toggle Auto-Clicker 🖱️", "Toggle Auto-Clicker V2 ⚡", "Toggle Auto-Heal ❤️", "Toggle Auto-Parry 🛡️", "Toggle Auto-Dodge 💨", "Toggle Auto-Reload 🔄", "Toggle Critical Hit 💥"},
        HVH = {"HvH Resolver 🎯", "Toggle Anti-Aim 🌀", "Anti-Aim Mode: Spin", "Anti-Aim Mode: Backwards", "Anti-Aim Mode: Jitter", "Toggle Fake Lag ⏳", "Fake Lag Amount", "Toggle Anti-Knockback ⚓", "Toggle Anti-Knockback V2 ⚓", "Toggle Anti-Stun ⚡", "Toggle Anti-Freeze ❄️", "Toggle Anti-Slow 🐢", "Toggle Desync 🌀", "Fake Ping 📶", "Fake Ping Value", "Fake Ping Mode: Static", "Fake Ping Mode: Jump", "Fake Ping Mode: Wave"},
        MM2 = {"MM2 ESP 🔪", "MM2 ESP V2 🔪", "MM2 ESP Roles 👁️", "MM2 Aimbot 🎯", "MM2 Trigger Bot 🔫", "MM2 Kill Aura V1 ⚔️", "MM2 Kill Aura V2 (Teleport) ⚔️", "MM2 Silent Aim 🎯", "MM2 Anti-Knife 🛡️", "MM2 Grab Gun V1 🔫", "MM2 Grab Gun V2 🔫", "MM2 Grab Method: Teleport", "MM2 Grab Method: Bring", "MM2 Fling Murderer 🔪", "MM2 Fling Sheriff ⭐", "MM2 Auto Shoot 🎯", "MM2 Speed Hack ⚡", "MM2 No Recoil 🔫", "MM2 No Spread 🎯", "MM2 Fast Reload 🔄", "MM2 Infinite Ammo ♾️", "MM2 TP to Lobby 🏰"},
        FLING = {"Fling by Name 📝", "Auto Fling 🔄", "IY Fling 🚀", "IY Goto ⚡"},
        UTILITIES = {"Anti-AFK 🛌", "FPS Booster ⚡", "Player Stats 📊", "Server Info 🌐", "Music Player 🎵"},
        EXTREME = {"Rage Mode 🔥", "God Mode 👑", "One Hit Kill 💀", "No Damage 🛡️", "Lag Switch ⏳"},
        SETTINGS = {"Background Color 🎨", "Border Color 🎨", "Text Color 🎨", "Transparency", "Toggle Blur", "Blur Size"}
    }
    
    local tabButtons = {}
    local idx = 0
    local tabHeight = 23
    
    for catName, subs in pairs(categories) do
        local btn = Instance.new("TextButton", tabsContainer) 
        btn.Size = UDim2.new(0.92, 0, 0, tabHeight) 
        btn.Position = UDim2.new(0.04, 0, 0, idx * (tabHeight + 2)) 
        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 35) 
        btn.Text = catName 
        btn.TextColor3 = guiSettings.TextColor 
        btn.Font = Enum.Font.GothamBold 
        btn.TextSize = 8
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4) 
        local cs = Instance.new("UIStroke", btn) 
        cs.Color = Color3.fromRGB(45,45,55)
        btn.MouseButton1Click:Connect(function() 
            for _, b in pairs(tabButtons) do b.BackgroundColor3 = Color3.fromRGB(28, 28, 35) end
            btn.BackgroundColor3 = guiSettings.BorderColor
            currentCategory = catName 
            allSubs = subs 
            RenderSubs(subs) 
        end)
        table.insert(tabButtons, btn)
        idx = idx + 1
    end
    
    tabsContainer.CanvasSize = UDim2.new(0, 0, 0, idx * (tabHeight + 2) + 5)
    
    if #tabButtons > 0 then
        tabButtons[1].BackgroundColor3 = guiSettings.BorderColor
        currentCategory = "VISUAL" 
        allSubs = categories.VISUAL 
        RenderSubs(categories.VISUAL)
    end
    
    CreateKillAuraButton()
    CreateMiniButton()
end

-- ============================================
-- ЗАПУСК
-- ============================================
pcall(function()
    CreateMenu()
    print("MTY HUB v6.0 DELTA FULL WORKING! 🚀")
end)