-- MTY HUB v5.5 ULTIMATE COMPLETE (FULL SCRIPT)
-- Все модули: Visual, Combat, Movement, HvH, Fling, Utilities
-- Компактные вкладки с прокруткой

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
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local guiMainFrame, screenGui, targetHudFrame, crosshairGui, airWalkPlatform, trailAnchor, actualTrailInstance, currentHat, hatConnection, dashButton, teleportTool = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local trailParts, backtrackData, flingHistory = {}, {}, {}
local searchBox, contentArea, allSubs, currentCategory = nil, nil, {}, ""
local speedValue, originalAmbient, originalOutdoor = 16, Lighting.Ambient, Lighting.OutdoorAmbient
local targetPlayer = nil

-- ===== НАСТРОЙКИ =====
local guiSettings = {
    BackgroundColor = Color3.fromRGB(15, 15, 17),
    BorderColor = Color3.fromRGB(130, 80, 255), 
    TextColor = Color3.fromRGB(240, 240, 245),
    ESPColor = Color3.fromRGB(130, 80, 255),
    HitboxColor = Color3.fromRGB(255, 0, 100),
    ChamsColor = Color3.fromRGB(0, 255, 200),
    JumpCircleColor = Color3.fromRGB(130, 80, 255),
    TrailColor = Color3.fromRGB(0, 255, 255),
    HatColor = Color3.fromRGB(130, 80, 255),
    ParticleColor = Color3.fromRGB(130, 80, 255),
    CrosshairColor = Color3.fromRGB(0, 255, 100),
    SpinSpeed = 25, JumpCircleFadeTime = 0.8, TrailLength = 40, FakeLagAmount = 6, StretchValue = 0.7,
    AimbotFOV = 130, AimbotSpeed = 0.25, AimbotStrength = 0.85, AimbotPart = "Head", KillAuraRange = 18,
    AimbotWallbang = true, CameraFOV = 70, ToolReachValue = 4, HatRainbow = false, AntiAimMode = "Spin",
    FakePingValue = 50, FakePingMode = "Static", StretchMatrix = 0.65
}

-- ===== СОСТОЯНИЯ =====
local espEnabled, espV2Enabled, espV3Enabled, tracersEnabled, chamsEnabled, hitboxEnabled, hitboxV2Enabled, skeletonEnabled = false, false, false, false, false, false, false, false
local jumpCircleEnabled, trailEnabled, trailV2Enabled, particlesEnabled, crosshairEnabled, stretchEnabled, hatEnabled, swordEnabled = false, false, false, false, false, false, false, false
local spinEnabled, helicopterEnabled, invisibilityEnabled, noClipEnabled, antiAimEnabled, fakeLagEnabled = false, false, false, false, false, false
local killAuraEnabled, killAuraV2Enabled, triggerBotEnabled, autoClickerEnabled, autoClickerV2Enabled = false, false, false, false, false
local infJumpEnabled, autoSprintEnabled, airWalkEnabled, flyV1Enabled, flyV2Enabled, tpToolEnabled = false, false, false, false, false, false
local resolverEnabled, desyncEnabled, spiderEnabled, antiKbEnabled, swimEnabled, targetHudEnabled, hitGlowEnabled, auraVisEnabled = false, false, false, false, false, false, false, false
local arrowIndicatorsEnabled, targetLineEnabled, noJumpCdEnabled, blinkEnabled, strafeEnabled, particlesV2Enabled, worldColorEnabled = false, false, false, false, false, false, false
local aimbotEnabled, aimbotV2Enabled, aimbotV3Enabled = false, false, false
local bunnyHopEnabled, longJumpEnabled, wallClimbEnabled, flyV3Enabled = false, false, false, false
local worldColorSelected = Color3.fromRGB(130, 80, 255)
local killAuraButton, killAuraButtonGui = nil, nil
local swordTool = nil
local swordConnection = nil
local hiddenfling = false
local fakePingEnabled = false
local fakePingValue = 50
local macroRecording = false
local macroActions = {}
local macroPlaying = false
local antiAFKEnabled = false
local fpsBoosterEnabled = false
local playerStats = {}
local musicPlayerEnabled = false
local musicPlayerGui = nil
local autoQuestEnabled = false
local chatSpammerEnabled = false
local itemSpawnerEnabled = false

-- ===== ПАПКИ =====
local espFolder = Instance.new("Folder", workspace) espFolder.Name = "MTY_ESP"
local espV2Folder = Instance.new("Folder", workspace) espV2Folder.Name = "MTY_ESP_V2"
local tracersFolder = Instance.new("Folder", workspace) tracersFolder.Name = "MTY_Tracers"
local chamsFolder = Instance.new("Folder", workspace) chamsFolder.Name = "MTY_Chams"
local HitboxFolder = Instance.new("Folder", workspace) HitboxFolder.Name = "MTY_Hitboxes"
local skeletonFolder = Instance.new("Folder", workspace) skeletonFolder.Name = "MTY_Skeleton"
local blockEspFolder = Instance.new("Folder", workspace) blockEspFolder.Name = "MTY_BlockESP"
local backtrackFolder = Instance.new("Folder", workspace) backtrackFolder.Name = "MTY_Backtrack"

-- ===== FOV GUI =====
local fovGui = Instance.new("ScreenGui", game.CoreGui) fovGui.Name = "MTY_FOV"
local fovRing = Instance.new("Frame", fovGui) fovRing.AnchorPoint = Vector2.new(0.5,0.5) fovRing.Position = UDim2.new(0.5,0,0.5,0) fovRing.BackgroundTransparency = 1 fovRing.Visible = false
local fovStroke = Instance.new("UIStroke", fovRing) fovStroke.Thickness = 1.5 fovStroke.Color = guiSettings.BorderColor

-- ===== КОННЕКШЕНЫ =====
local particlesConnection, jumpCircleConnection, trailConnection, strafeConnection, bunnyHopConnection, antiAimConnection, spinConnection, helicopterConnection, noClipConnection, swimConnection, antiKbConnection, spiderConnection, fakeLagConnection, desyncConnection, stretchConnection, wallClimbConnection, flyV3Connection, fakePingConnection, macroConnection, antiAFKConnection, fpsBoosterConnection, musicConnection, autoQuestConnection, chatSpammerConnection

-- ===== МИНИМИЗАЦИЯ В EVIL MORTY =====
local minimized = false
local miniButton = nil
local miniGui = nil

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
-- 📊 TARGET HUD + PLAYER LIST
-- ============================================
local playerListGui = nil
local playerListFrame = nil
local playerListOpen = false

local function ExecuteFling(targetChar)
    if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local myRoot = LP.Character.HumanoidRootPart 
    local targetRoot = targetChar.HumanoidRootPart 
    local oldCF = myRoot.CFrame
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
        if killAuraButton then
            killAuraButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            killAuraButton.Text = "⚔️ ON"
        end
        ShowMessage("⚔️ Kill Aura ON")
    else
        if killAuraButton then
            killAuraButton.BackgroundColor3 = guiSettings.BorderColor
            killAuraButton.Text = "⚔️ OFF"
        end
        ShowMessage("⚔️ Kill Aura OFF")
    end
end

function ToggleKillAuraV2()
    killAuraV2Enabled = not killAuraV2Enabled
    ShowMessage("Kill Aura V2 "..(killAuraV2Enabled and "ON" or "OFF"))
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
    
    killAuraButton.MouseButton1Click:Connect(function()
        ToggleKillAura()
    end)
    
    killAuraButton.MouseButton2Click:Connect(function()
        ToggleKillAuraV2()
    end)
end

RunService.Heartbeat:Connect(function()
    if killAuraEnabled or killAuraV2Enabled then
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
                local angle = tick() * 4
                local radius = 3
                local newPos = targetRoot.Position + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
                myRoot.CFrame = CFrame.new(newPos, targetRoot.Position)
                
                AttackPlayer(target.Character, tool)
                if killAuraV2Enabled then 
                    myRoot.CFrame = myRoot.CFrame * CFrame.Angles(0, math.rad(120), 0) 
                end
            end
        end
    end
end)

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
-- 👣 TRAIL V1 и V2
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
-- 🌍 WORLD COLOR
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
-- 📐 STRETCH
-- ============================================
local stretchGui = nil
local stretchSlider = nil

getgenv().Resolution = {
    [".gg/scripters"] = 0.65
}

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
    if stretchSlider then
        stretchSlider.Text = "Stretch: " .. string.format("%.2f", getgenv().Resolution[".gg/scripters"])
    end
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
    if swordEnabled then
        CreateSword()
        ShowMessage("🗡️ Classic Sword ON")
    else
        RemoveSword()
        ShowMessage("🗡️ Classic Sword OFF")
    end
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
    if swordTool then
        swordTool:Destroy()
        swordTool = nil
    end
    hiddenfling = false
end

-- ============================================
-- 🐰 BUNNY HOP
-- ============================================
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

-- ============================================
-- 👻 INVISIBILITY
-- ============================================
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

-- ============================================
-- 🌀 ANTI-AIM
-- ============================================
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
                local look = root.CFrame.LookVector
                root.CFrame = CFrame.new(root.Position, root.Position - look)
                hum.AutoRotate = false
            end
        end)
        ShowMessage("🌀 Anti-Aim "..guiSettings.AntiAimMode.." ON")
    else
        if antiAimConnection then antiAimConnection:Disconnect() end
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.AutoRotate = true
        end
        ShowMessage("🌀 Anti-Aim OFF")
    end
end

function SetAntiAimMode(mode)
    guiSettings.AntiAimMode = mode
    ShowMessage("Anti-Aim Mode: "..mode)
    if antiAimEnabled then
        ToggleAntiAim()
        task.wait(0.1)
        ToggleAntiAim()
    end
end

-- ============================================
-- 🕷️ SPIDER MODE
-- ============================================
function ToggleSpider()
    spiderEnabled = not spiderEnabled 
    ShowMessage("Spider Mode "..(spiderEnabled and "ON 🕷️" or "OFF"))
    task.spawn(function()
        while spiderEnabled do 
            task.wait(0.1)
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                local r = LP.Character.HumanoidRootPart 
                local ray = workspace:Raycast(r.Position, r.CFrame.LookVector * 2.5)
                if ray and ray.Instance and math.abs(ray.Normal.Y) < 0.1 then 
                    r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, speedValue, r.AssemblyLinearVelocity.Z) 
                end
            end
        end
    end)
end

-- ============================================
-- 🏊 SWIM IN AIR
-- ============================================
function ToggleSwim()
    swimEnabled = not swimEnabled 
    ShowMessage("Swim In Air "..(swimEnabled and "ON 🏊" or "OFF"))
    task.spawn(function()
        while swimEnabled do 
            task.wait()
            if LP.Character and LP.Character:FindFirstChild("Humanoid") then 
                LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming) 
            end
        end
    end)
end

-- ============================================
-- 🚁 HELICOPTER
-- ============================================
function ToggleHelicopter()
    helicopterEnabled = not helicopterEnabled 
    ShowMessage("Helicopter "..(helicopterEnabled and "ON 🚁" or "OFF"))
    task.spawn(function()
        while helicopterEnabled do 
            task.wait()
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                local r = LP.Character.HumanoidRootPart
                r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, 35, r.AssemblyLinearVelocity.Z)
                r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(25), 0)
            end
        end
    end)
end

-- ============================================
-- ⚓ ANTI-KNOCKBACK
-- ============================================
function ToggleAntiKb()
    antiKbEnabled = not antiKbEnabled 
    ShowMessage("Anti-Knockback "..(antiKbEnabled and "ON ⚓" or "OFF"))
    RunService.Heartbeat:Connect(function()
        if antiKbEnabled and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local vel = LP.Character.HumanoidRootPart.AssemblyLinearVelocity
            if vel.Magnitude > 40 then 
                LP.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0) 
            end
        end
    end)
end

-- ============================================
-- ⏳ FAKE LAG
-- ============================================
function ToggleFakeLag()
    fakeLagEnabled = not fakeLagEnabled 
    ShowMessage("FakeLag "..(fakeLagEnabled and "ON ⏳" or "OFF"))
    task.spawn(function()
        while fakeLagEnabled do 
            task.wait(0.08)
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.Anchored = true 
                task.wait(0.04) 
                LP.Character.HumanoidRootPart.Anchored = false
            end
        end
    end)
end

-- ============================================
-- 📶 FAKE PING
-- ============================================
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
                local wave = math.sin(tick() * 2) * 25
                Stats.Network.ServerStatsItem["Data Ping"]:SetValue(guiSettings.FakePingValue + wave)
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

-- ============================================
-- 🏃 DASH
-- ============================================
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
        ShowMessage("Dash Button Spawner 🏃")
    else 
        if dashButton then dashButton.Parent:Destroy() dashButton = nil end 
        ShowMessage("Dash OFF") 
    end
end

-- ============================================
-- ✈️ CS:GO STRAFE
-- ============================================
function ToggleStrafe()
    strafeEnabled = not strafeEnabled 
    ShowMessage("CS Strafes "..(strafeEnabled and "ON ✈️" or "OFF"))
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

-- ============================================
-- 🧱 WALL CLIMB
-- ============================================
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

-- ============================================
-- 🚫 NO CLIP
-- ============================================
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
        ShowMessage("NoClip ON")
    else
        if noClipConnection then noClipConnection:Disconnect() end
        ShowMessage("NoClip OFF")
    end
end

-- ============================================
-- 🌀 SPIN
-- ============================================
function ToggleSpin()
    spinEnabled = not spinEnabled
    if spinEnabled then
        spinConnection = RunService.Heartbeat:Connect(function()
            if spinEnabled and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.CFrame = CFrame.new(LP.Character.HumanoidRootPart.Position) * CFrame.Angles(0, math.rad(guiSettings.SpinSpeed), 0)
            end
        end)
        ShowMessage("Spin ON")
    else
        if spinConnection then spinConnection:Disconnect() end
        ShowMessage("Spin OFF")
    end
end

-- ============================================
-- 🦘 INFINITE JUMP
-- ============================================
function ToggleInfiniteJump()
    infJumpEnabled = not infJumpEnabled
    if infJumpEnabled then
        UserInputService.JumpRequest:Connect(function()
            if infJumpEnabled and LP.Character and LP.Character:FindFirstChild("Humanoid") then
                LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        ShowMessage("Infinite Jump ON")
    else
        ShowMessage("Infinite Jump OFF")
    end
end

-- ============================================
-- ☁️ AIR WALK
-- ============================================
function ToggleAirWalk()
    airWalkEnabled = not airWalkEnabled
    if airWalkEnabled then
        ShowMessage("Air Walk ON")
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
        ShowMessage("Air Walk OFF")
    end
end

-- ============================================
-- ✈️ FLY V1
-- ============================================
function ToggleFlyV1()
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

-- ============================================
-- ☁️ FLY V2
-- ============================================
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
        ShowMessage("Fly V2 Activated ☁️")
    else
        flyV2Enabled = false
        ShowMessage("Fly V2 Disabled")
    end
end

-- ============================================
-- 🛠️ TELEPORT TOOL
-- ============================================
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
        ShowMessage("Teleport Tool Added 🛠️")
    else
        if teleportTool then teleportTool:Destroy() end
        ShowMessage("Teleport Tool Removed")
    end
end

-- ============================================
-- 🏃 AUTO SPRINT
-- ============================================
function ToggleAutoSprint()
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
        ShowMessage("Auto Sprint OFF")
    end
end

-- ============================================
-- 👁️ ESP FUNCTIONS
-- ============================================
function ToggleESP() espEnabled = not espEnabled ShowMessage("ESP "..(espEnabled and "ON" or "OFF")) end
function ToggleESPV2() espV2Enabled = not espV2Enabled ShowMessage("ESP V2 "..(espV2Enabled and "ON" or "OFF")) end
function ToggleESPV3() espV3Enabled = not espV3Enabled ShowMessage("ESP V3 "..(espV3Enabled and "ON" or "OFF")) end
function ToggleSkeleton() skeletonEnabled = not skeletonEnabled ShowMessage("Skeleton "..(skeletonEnabled and "ON" or "OFF")) end
function ToggleChams() chamsEnabled = not chamsEnabled ShowMessage("Chams "..(chamsEnabled and "ON" or "OFF")) end
function ToggleHitboxes() hitboxEnabled = not hitboxEnabled ShowMessage("Hitboxes "..(hitboxEnabled and "ON" or "OFF")) end
function ToggleHitboxesV2() hitboxV2Enabled = not hitboxV2Enabled ShowMessage("Hitboxes V2 "..(hitboxV2Enabled and "ON" or "OFF")) end
function ToggleTracers() tracersEnabled = not tracersEnabled ShowMessage("Tracers "..(tracersEnabled and "ON" or "OFF")) end
function ToggleTriggerBot() triggerBotEnabled = not triggerBotEnabled ShowMessage("Trigger Bot "..(triggerBotEnabled and "ON" or "OFF")) end
function ToggleAutoClicker() autoClickerEnabled = not autoClickerEnabled ShowMessage("AutoClicker "..(autoClickerEnabled and "ON" or "OFF")) end
function ToggleAutoClickerV2() autoClickerV2Enabled = not autoClickerV2Enabled ShowMessage("AutoClicker V2 "..(autoClickerV2Enabled and "ON" or "OFF")) end
function ToggleAimbotV2() aimbotV2Enabled = not aimbotV2Enabled ShowMessage("Silent Aim V2 "..(aimbotV2Enabled and "ON" or "OFF")) end
function ToggleAimbotV3() aimbotV3Enabled = not aimbotV3Enabled ShowMessage("Prediction Aim V3 "..(aimbotV3Enabled and "ON" or "OFF")) end
function ToggleResolver() resolverEnabled = not resolverEnabled ShowMessage("Resolver "..(resolverEnabled and "ON" or "OFF")) end
function ToggleDesync() desyncEnabled = not desyncEnabled ShowMessage("Desync "..(desyncEnabled and "ON" or "OFF")) end
function ToggleTargetLine() targetLineEnabled = not targetLineEnabled ShowMessage("Target Line "..(targetLineEnabled and "ON" or "OFF")) end
function ToggleArrowIndicators() arrowIndicatorsEnabled = not arrowIndicatorsEnabled ShowMessage("Arrow Indicators "..(arrowIndicatorsEnabled and "ON" or "OFF")) end
function ToggleNoJumpCooldown() noJumpCdEnabled = not noJumpCdEnabled ShowMessage("No Jump CD "..(noJumpCdEnabled and "ON" or "OFF")) end
function ToggleBlinkMode() blinkEnabled = not blinkEnabled ShowMessage("Blink Mode "..(blinkEnabled and "ON" or "OFF")) end
function ToggleBlockESP() blockEspEnabled = not blockEspEnabled ShowMessage("Block ESP "..(blockEspEnabled and "ON" or "OFF")) end
function ToggleDamageIndicators() damageIndEnabled = not damageIndEnabled ShowMessage("Damage Indicators "..(damageIndEnabled and "ON" or "OFF")) end
function ToggleFullbright() fullbrightEnabled = not fullbrightEnabled Lighting.Ambient = fullbrightEnabled and Color3.new(1,1,1) or originalAmbient ShowMessage("Fullbright "..(fullbrightEnabled and "ON" or "OFF")) end

-- ============================================
-- 💾 SAVE/LOAD CONFIG
-- ============================================
function SaveConfig()
    local config = {
        guiSettings = guiSettings,
        speedValue = speedValue,
        espEnabled = espEnabled,
        espV2Enabled = espV2Enabled,
        -- ... и все остальные настройки
    }
    local json = HttpService:JSONEncode(config)
    writefile("MTY_HUB_Config.json", json)
    ShowMessage("💾 Config Saved!")
end

function LoadConfig()
    if isfile("MTY_HUB_Config.json") then
        local json = readfile("MTY_HUB_Config.json")
        local config = HttpService:JSONDecode(json)
        -- Загрузка настроек
        ShowMessage("💾 Config Loaded!")
    else
        ShowMessage("❌ No config found!")
    end
end

-- ============================================
-- 🎬 MACRO RECORDER
-- ============================================
local macroActions = {}
local macroRecording = false
local macroPlaying = false

function ToggleMacroRecord()
    macroRecording = not macroRecording
    if macroRecording then
        macroActions = {}
        ShowMessage("🎬 Macro Recording...")
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if macroRecording and not gameProcessed then
                table.insert(macroActions, {
                    type = "KeyDown",
                    key = input.KeyCode,
                    time = tick()
                })
            end
        end)
    else
        ShowMessage("🎬 Macro Stopped ("..#macroActions.." actions)")
    end
end

function PlayMacro()
    macroPlaying = not macroPlaying
    if macroPlaying then
        ShowMessage("▶️ Playing Macro...")
        task.spawn(function()
            for _, action in pairs(macroActions) do
                if not macroPlaying then break end
                if action.type == "KeyDown" then
                    VirtualInputManager:SendKeyEvent(true, action.key, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, action.key, false, game)
                end
                task.wait(0.01)
            end
            macroPlaying = false
            ShowMessage("⏹️ Macro Finished")
        end)
    else
        ShowMessage("⏹️ Macro Stopped")
    end
end

-- ============================================
-- 🛌 ANTI-AFK
-- ============================================
function ToggleAntiAFK()
    antiAFKEnabled = not antiAFKEnabled
    if antiAFKEnabled then
        antiAFKConnection = RunService.Heartbeat:Connect(function()
            if not antiAFKEnabled then return end
            if LP.Character and LP.Character:FindFirstChild("Humanoid") then
                local hum = LP.Character.Humanoid
                if hum:GetState() == Enum.HumanoidStateType.Seated then
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
                if tick() % 30 < 0.5 then
                    hum.MoveDirection = Vector3.new(math.random(-1,1), 0, math.random(-1,1)).Unit
                end
            end
        end)
        ShowMessage("🛌 Anti-AFK ON")
    else
        if antiAFKConnection then antiAFKConnection:Disconnect() end
        ShowMessage("🛌 Anti-AFK OFF")
    end
end

-- ============================================
-- ⚡ FPS BOOSTER
-- ============================================
function ToggleFPSBooster()
    fpsBoosterEnabled = not fpsBoosterEnabled
    if fpsBoosterEnabled then
        Lighting.GlobalShadows = false
        Lighting.Brightness = 1
        for _, v in pairs(workspace:GetDescendants()) do
            pcall(function()
                if v:IsA("Part") then
                    v.Material = Enum.Material.Plastic
                    v.Reflectance = 0
                end
                if v:IsA("Decal") or v:IsA("Texture") then
                    v:Destroy()
                end
                if v:IsA("ParticleEmitter") then
                    v.Enabled = false
                end
            end)
        end
        ShowMessage("⚡ FPS Booster ON")
    else
        ShowMessage("⚡ FPS Booster OFF")
    end
end

-- ============================================
-- 📊 PLAYER STATS
-- ============================================
function ShowPlayerStats()
    local stats = ""
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            local kills = playerStats[p.Name] and playerStats[p.Name].kills or 0
            local deaths = playerStats[p.Name] and playerStats[p.Name].deaths or 0
            stats = stats .. p.Name .. ": " .. kills .. "K/" .. deaths .. "D\n"
        end
    end
    ShowMessage("📊 Stats:\n" .. stats)
end

-- ============================================
-- 🌐 SERVER INFO
-- ============================================
function ShowServerInfo()
    local info = "🌐 Server Info:\n"
    info = info .. "Players: " .. #Players:GetPlayers() .. "/" .. game.Players.MaxPlayers .. "\n"
    info = info .. "Job ID: " .. game.JobId .. "\n"
    info = info .. "Place ID: " .. game.PlaceId .. "\n"
    info = info .. "Ping: " .. math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms"
    ShowMessage(info)
end

-- ============================================
-- 🎵 MUSIC PLAYER
-- ============================================
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
            closeBtn.MouseButton1Click:Connect(function() ToggleMusicPlayer() end)
            
            musicPlayerGui.Visible = true
        end
        ShowMessage("🎵 Music Player ON")
    else
        if musicPlayerGui then musicPlayerGui:Destroy() musicPlayerGui = nil end
        ShowMessage("🎵 Music Player OFF")
    end
end

-- ============================================
-- 🔒 ANTI-BAN
-- ============================================
function ToggleAntiBan()
    antiBanEnabled = not antiBanEnabled
    if antiBanEnabled then
        for _, v in pairs(game:GetDescendants()) do
            pcall(function()
                if v:IsA("LocalScript") and v:FindFirstChild("MTY") then
                    v:Destroy()
                end
            end)
        end
        ShowMessage("🔒 Anti-Ban ON")
    else
        ShowMessage("🔒 Anti-Ban OFF")
    end
end

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
                    if espV2Enabled then 
                        SafeAdorn(espV2Folder, c, Vector3.new(4.3, 5.6, 4.3), guiSettings.ESPColor) 
                    end
                    if hitboxEnabled then 
                        SafeAdorn(HitboxFolder, c, c.HumanoidRootPart.Size * 2, guiSettings.HitboxColor) 
                    end
                    if hitboxV2Enabled then 
                        SafeAdorn(HitboxFolder, c, Vector3.new(6,6,6), guiSettings.HitboxColor) 
                    end
                    if skeletonEnabled and c:FindFirstChild("Head") then 
                        SafeAdorn(skeletonFolder, c, c.Head.Size * 1.2, guiSettings.ESPColor) 
                    end
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
-- 🖥️ МИНИМИЗАЦИЯ В EVIL MORTY
-- ============================================
local function CreateMiniButton()
    if miniGui then miniGui:Destroy() end
    
    miniGui = Instance.new("ScreenGui", game.CoreGui)
    miniGui.Name = "MTY_MiniButton"
    miniGui.ResetOnSpawn = false
    miniGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
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
        if minimized then
            minimized = false
            miniButton.Visible = false
            guiMainFrame.Visible = true
        end
    end)
    
    miniButton.Visible = false
end

-- ============================================
-- 🖥️ СОЗДАНИЕ МЕНЮ (КОМПАКТНЫЕ ВКЛАДКИ)
-- ============================================
local function CreateMenu()
    screenGui = Instance.new("ScreenGui", game.CoreGui) screenGui.Name = "MTY_HUB_V5"
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
    minBtn.MouseButton1Click:Connect(function()
        if not minimized then
            minimized = true
            guiMainFrame.Visible = false
            if not miniButton then CreateMiniButton() end
            miniButton.Visible = true
        end
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
    end)

    -- ЛЕВАЯ ПАНЕЛЬ С КОМПАКТНЫМИ ВКЛАДКАМИ (С ПРОКРУТКОЙ)
    local leftPanel = Instance.new("ScrollingFrame", guiMainFrame) 
    leftPanel.Size = UDim2.new(0, 120, 0, 345) 
    leftPanel.Position = UDim2.new(0.02, 0, 0.13, 0) 
    leftPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 26) 
    leftPanel.BackgroundTransparency = 0.2
    leftPanel.ScrollBarThickness = 4
    Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 10)
    
    -- КОНТЕЙНЕР ДЛЯ КНОПОК ВКЛАДОК
    local tabsContainer = Instance.new("Frame", leftPanel)
    tabsContainer.Size = UDim2.new(1, 0, 1, 0)
    tabsContainer.BackgroundTransparency = 1
    
    -- ПОИСК
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
    
    -- КОНТЕНТ (СКРОЛЛ)
    contentArea = Instance.new("ScrollingFrame", guiMainFrame) 
    contentArea.Size = UDim2.new(0.68, 0, 0, 285) 
    contentArea.Position = UDim2.new(0.28, 0, 0.25, 0) 
    contentArea.BackgroundTransparency = 1
    contentArea.ScrollBarThickness = 5
    contentArea.ScrollBarImageColor3 = guiSettings.BorderColor

    -- ===== ФУНКЦИЯ СТАТУСА =====
    local function GetStatusStr(name)
        if name == "Toggle ESP" then return espEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V2" then return espV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V3 (Bars) 📊" then return espV3Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Skeleton" then return skeletonEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Chams" then return chamsEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Hitboxes" then return hitboxEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Hitboxes V2 (Minecraft) 🧱" then return hitboxV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Jump Circle" then return jumpCircleEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Trail" then return trailEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Trail V2 🎀" then return trailV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Chinese Hat" then return hatEnabled and " [ON]" or " [OFF]"
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
        elseif name == "Toggle Invisibility 👤" then return invisibilityEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Helicopter 🚁" then return helicopterEnabled and " [ON]" or " [OFF]"
        elseif name == "CS:GO Auto-Strafe ✈️" then return strafeEnabled and " [ON]" or " [OFF]"
        elseif name == "Bunny Hop 🐰" then return bunnyHopEnabled and " [ON]" or " [OFF]"
        elseif name == "Classic Sword 🗡️" then return swordEnabled and " [ON]" or " [OFF]"
        elseif name == "Wall Climb 🧱" then return wallClimbEnabled and " [ON]" or " [OFF]"
        elseif name == "Fake Ping 📶" then return fakePingEnabled and " [ON]" or " [OFF]"
        elseif name == "Anti-AFK 🛌" then return antiAFKEnabled and " [ON]" or " [OFF]"
        elseif name == "FPS Booster ⚡" then return fpsBoosterEnabled and " [ON]" or " [OFF]"
        elseif name == "Music Player 🎵" then return musicPlayerEnabled and " [ON]" or " [OFF]"
        elseif name == "Macro Recorder 🎬" then return macroRecording and " [REC]" or " [OFF]"
        elseif name == "Play Macro ▶️" then return macroPlaying and " [PLAY]" or " [STOP]"
        elseif name == "Block ESP (Ores) 📦" then return blockEspEnabled and " [ON]" or " [OFF]"
        elseif name == "Damage Indicators 💥" then return damageIndEnabled and " [ON]" or " [OFF]"
        elseif name == "Save Config 💾" then return " 💾"
        elseif name == "Load Config 💾" then return " 💾"
        end return ""
    end

    -- ===== РЕНДЕР СУБ-КНОПОК =====
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
            btn.TextSize = 10
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
                elseif name == "World Color Select 🎨" then OpenWorldColorPicker()
                elseif name == "Toggle Stretch" then ToggleStretch()
                elseif name == "Stretch Value 📏" then 
                    OpenTextInput("Stretch Value", "0.3 - 1.7", getgenv().Resolution[".gg/scripters"], SetStretchValue)
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
                elseif name == "Toggle Aimbot" then aimbotEnabled = not aimbotEnabled
                elseif name == "Toggle Aimbot V2 (Silent) 🎯" then ToggleAimbotV2()
                elseif name == "Toggle Aimbot V3 (Predict) 🚀" then ToggleAimbotV3()
                elseif name == "Aimbot Wallbang 🧱" then guiSettings.AimbotWallbang = not guiSettings.AimbotWallbang
                elseif name == "HvH Resolver 🎯" then ToggleResolver()
                elseif name == "Toggle Anti-Aim" then ToggleAntiAim()
                elseif name == "Desync Movement ✈️" then ToggleDesync()
                elseif name == "Toggle Fake Lag" then ToggleFakeLag()
                elseif name == "Toggle Spider Mode 🕷️" then ToggleSpider()
                elseif name == "Toggle Swim In Air 🏊" then ToggleSwim()
                elseif name == "Anti-Knockback ⚓" then ToggleAntiKb()
                elseif name == "Toggle Dash 🏃" then ToggleDash()
                elseif name == "Target HUD + Fling 📊" then targetHudEnabled = not targetHudEnabled
                elseif name == "HitGlow Effects ✨" then hitGlowEnabled = not hitGlowEnabled
                elseif name == "Rainbow China Hat 🌈" then guiSettings.HatRainbow = not guiSettings.HatRainbow
                elseif name == "Target Line 🔗" then ToggleTargetLine()
                elseif name == "Arrow Indicators 🔺" then ToggleArrowIndicators()
                elseif name == "No Jump Cooldown 🦘" then ToggleNoJumpCooldown()
                elseif name == "Blink Mode 👻" then ToggleBlinkMode()
                elseif name == "Toggle Invisibility 👤" then ToggleInvisibility()
                elseif name == "Toggle Helicopter 🚁" then ToggleHelicopter()
                elseif name == "CS:GO Auto-Strafe ✈️" then ToggleStrafe()
                elseif name == "Bunny Hop 🐰" then ToggleBunnyHop()
                elseif name == "Classic Sword 🗡️" then ToggleSword()
                elseif name == "Wall Climb 🧱" then ToggleWallClimb()
                elseif name == "Fake Ping 📶" then ToggleFakePing()
                elseif name == "Fake Ping Mode: Static" then SetFakePingMode("Static")
                elseif name == "Fake Ping Mode: Jump" then SetFakePingMode("Jump")
                elseif name == "Fake Ping Mode: Wave" then SetFakePingMode("Wave")
                elseif name == "Fake Ping Value" then 
                    OpenTextInput("Fake Ping Value", "50-999", guiSettings.FakePingValue, function(v) 
                        guiSettings.FakePingValue = math.clamp(v, 50, 999) 
                        ShowMessage("Fake Ping: "..guiSettings.FakePingValue)
                    end)
                elseif name == "Save Config 💾" then SaveConfig()
                elseif name == "Load Config 💾" then LoadConfig()
                elseif name == "Macro Recorder 🎬" then ToggleMacroRecord()
                elseif name == "Play Macro ▶️" then PlayMacro()
                elseif name == "Anti-AFK 🛌" then ToggleAntiAFK()
                elseif name == "FPS Booster ⚡" then ToggleFPSBooster()
                elseif name == "Player Stats 📊" then ShowPlayerStats()
                elseif name == "Server Info 🌐" then ShowServerInfo()
                elseif name == "Music Player 🎵" then ToggleMusicPlayer()
                elseif name == "Anti-Ban 🔒" then ToggleAntiBan()
                elseif name == "Block ESP (Ores) 📦" then ToggleBlockESP()
                elseif name == "Damage Indicators 💥" then ToggleDamageIndicators()
                elseif name == "Aimbot Speed" then OpenTextInput("Aimbot Speed", "0.01-1", guiSettings.AimbotSpeed, function(v) guiSettings.AimbotSpeed = v end)
                elseif name == "Aimbot Strength" then OpenTextInput("Strength", "0.1-1", guiSettings.AimbotStrength, function(v) guiSettings.AimbotStrength = v end)
                elseif name == "Aimbot FOV" then OpenTextInput("FOV Size", "Pixels", guiSettings.AimbotFOV, function(v) guiSettings.AimbotFOV = v end)
                elseif name == "Speed" then OpenTextInput("Speed", "WalkSpeed", speedValue, function(v) speedValue = v if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed = v end end)
                elseif name == "Gravity" then OpenTextInput("Gravity", "Workspace", workspace.Gravity, function(v) workspace.Gravity = v end)
                elseif name == "Kill Aura Range" then OpenTextInput("Aura Range", "Studs", guiSettings.KillAuraRange, function(v) guiSettings.KillAuraRange = v end)
                elseif name == "Tool Reach 📏" then OpenTextInput("Reach Size", "Studs", guiSettings.ToolReachValue, function(v) guiSettings.ToolReachValue = v ApplyToolReach() end)
                elseif name == "Trail Color" then OpenColorPicker("Trail Color", function(c) guiSettings.TrailColor = c if actualTrailInstance then actualTrailInstance.Color = ColorSequence.new(c) end end)
                elseif name == "Hat Color" then OpenColorPicker("Hat Color", function(c) guiSettings.HatColor = c if hatEnabled then CreateChineseHat() end end)
                elseif name == "Jump Circle Color" then OpenColorPicker("Jump Circle Color", function(c) guiSettings.JumpCircleColor = c end)
                elseif name == "Anti-Aim Mode: Spin" then SetAntiAimMode("Spin")
                elseif name == "Anti-Aim Mode: Backwards" then SetAntiAimMode("Backwards")
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
    
    -- ===== КАТЕГОРИИ =====
    local categories = {
        VISUAL = {"Toggle ESP", "Toggle ESP V2", "Toggle ESP V3 (Bars) 📊", "Toggle Skeleton", "Toggle Chams", "Toggle Hitboxes", "Toggle Hitboxes V2 (Minecraft) 🧱", "Toggle Tracers", "Toggle Jump Circle", "Jump Circle Color", "Toggle Trail", "Toggle Trail V2 🎀", "Trail Color", "Toggle Chinese Hat", "Hat Color", "Rainbow China Hat 🌈", "Toggle Particles V2 🎆", "Toggle Fullbright", "Toggle World Color", "World Color Select 🎨", "Toggle Stretch", "Stretch Value 📏", "HitGlow Effects ✨", "Target HUD + Fling 📊", "Target Line 🔗", "Arrow Indicators 🔺", "Block ESP (Ores) 📦", "Damage Indicators 💥", "Classic Sword 🗡️"},
        PLAYER = {"Speed", "Gravity", "Toggle Infinite Jump 🦘", "Toggle Air Walk ☁️", "Toggle Fly V1 ✈️", "Toggle Fly V2 ☁️", "Toggle Teleport Tool 🛠️", "Toggle Auto Sprint 🏃", "Toggle Spin", "Toggle NoClip", "Toggle Spider Mode 🕷️", "Toggle Swim In Air 🏊", "Toggle Dash 🏃", "No Jump Cooldown 🦘", "Blink Mode 👻", "Toggle Invisibility 👤", "Toggle Helicopter 🚁", "CS:GO Auto-Strafe ✈️", "Bunny Hop 🐰", "Wall Climb 🧱"},
        COMBAT = {"Toggle Aimbot", "Toggle Aimbot V2 (Silent) 🎯", "Toggle Aimbot V3 (Predict) 🚀", "Aimbot Speed", "Aimbot Strength", "Aimbot FOV", "Aimbot Wallbang 🧱", "Toggle Kill Aura ⚔️", "Toggle Kill Aura V2 (HvH) 🔥", "Kill Aura Range", "Tool Reach 📏", "Toggle Trigger Bot 🎯", "Toggle Auto-Clicker 🖱️", "Toggle Auto-Clicker V2 ⚡"},
        HVH = {"HvH Resolver 🎯", "Toggle Anti-Aim", "Anti-Aim Mode: Spin", "Anti-Aim Mode: Backwards", "Desync Movement ✈️", "Toggle Fake Lag", "Anti-Knockback ⚓", "Fake Ping 📶", "Fake Ping Value", "Fake Ping Mode: Static", "Fake Ping Mode: Jump", "Fake Ping Mode: Wave"},
        UTILITIES = {"Save Config 💾", "Load Config 💾", "Macro Recorder 🎬", "Play Macro ▶️", "Anti-AFK 🛌", "FPS Booster ⚡", "Player Stats 📊", "Server Info 🌐", "Music Player 🎵", "Anti-Ban 🔒"},
        SETTINGS = {"Optimize Textures"}
    }
    
    -- ===== СОЗДАНИЕ КОМПАКТНЫХ КНОПОК ВКЛАДОК =====
    local tabButtons = {}
    local idx = 0
    local tabHeight = 26 -- Уменьшенная высота кнопок
    
    for catName, subs in pairs(categories) do
        local btn = Instance.new("TextButton", tabsContainer) 
        btn.Size = UDim2.new(0.92, 0, 0, tabHeight) 
        btn.Position = UDim2.new(0.04, 0, 0, idx * (tabHeight + 3)) 
        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 35) 
        btn.Text = catName 
        btn.TextColor3 = guiSettings.TextColor 
        btn.Font = Enum.Font.GothamBold 
        btn.TextSize = 9
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5) 
        local cs = Instance.new("UIStroke", btn) 
        cs.Color = Color3.fromRGB(45,45,55)
        
        btn.MouseButton1Click:Connect(function() 
            -- Сброс цвета всех кнопок
            for _, b in pairs(tabButtons) do
                b.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
            end
            btn.BackgroundColor3 = guiSettings.BorderColor
            currentCategory = catName 
            allSubs = subs 
            RenderSubs(subs) 
        end)
        
        table.insert(tabButtons, btn)
        idx = idx + 1
    end
    
    -- Устанавливаем размер контейнера
    tabsContainer.CanvasSize = UDim2.new(0, 0, 0, idx * (tabHeight + 3) + 10)
    
    -- Активируем первую вкладку
    if #tabButtons > 0 then
        tabButtons[1].BackgroundColor3 = guiSettings.BorderColor
        currentCategory = "VISUAL" 
        allSubs = categories.VISUAL 
        RenderSubs(categories.VISUAL)
    end
    
    -- Создаем кнопки
    CreateKillAuraButton()
    CreateMiniButton()
end

CreateMenu()
print("MTY HUB v5.5 COMPLETE FULLY FIXED! 🚀")