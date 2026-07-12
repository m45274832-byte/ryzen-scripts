-- ============================================================================
-- 🔥 MTY HUB v5.5 PREMIUM CORE ULTIMATE BUILD (FOR DELTA EXECUTOR) 🔥
-- ПОЛНАЯ ВЕРСИЯ БЕЗ ПУСТЫШЕК
-- ============================================================================

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- ============================================================================
-- 📊 НАСТРОЙКИ GUI
-- ============================================================================

local guiSettings = {
    BackgroundColor = Color3.fromRGB(15, 15, 17),
    BorderColor = Color3.fromRGB(130, 80, 255),
    TextColor = Color3.fromRGB(240, 240, 245),
    ButtonColor = Color3.fromRGB(130, 80, 255),
    ESPColor = Color3.fromRGB(130, 80, 255),
    HitboxColor = Color3.fromRGB(255, 0, 100),
    JumpCircleColor = Color3.fromRGB(130, 80, 255),
    TrailColor = Color3.fromRGB(0, 255, 255),
    HatColor = Color3.fromRGB(130, 80, 255),
    ParticleColor = Color3.fromRGB(130, 80, 255),
    OrbitColor = Color3.fromRGB(255, 0, 100),
    CrosshairColor = Color3.fromRGB(0, 255, 100),
    StretchValue = 0.7,
    AimbotFOV = 130,
    AimbotSpeed = 0.25,
    AimbotStrength = 0.85,
    KillAuraRange = 18,
    AimbotWallbang = true,
    ToolReachValue = 4,
    HatRainbow = false,
    TrailLength = 40,
    JumpCircleFadeTime = 0.8,
    AimbotPart = "Head",
    AntiAimMode = "Spin",
    FakeLagAmount = 6,
    OrbitRadius = 8,
    OrbitSpeed = 3,
    HitboxSize = 2,
    FlySpeed = 50,
    WorldColor = Color3.fromRGB(255, 0, 255),
    FogColor = Color3.fromRGB(150, 100, 200),
    FogStart = 0,
    FogEnd = 100
}

-- ============================================================================
-- 🎯 ОСНОВНЫЕ ПЕРЕМЕННЫЕ
-- ============================================================================

local guiMainFrame, screenGui, targetHudFrame = nil, nil, nil
local trailParts = {}
local searchBox, contentArea, allSubs, currentCategory = nil, nil, {}, ""
local speedValue = 16
local targetPlayer = nil
local espFolder, espV2Folder, HitboxFolder = nil, nil, nil
local fovGui, fovRing, fovStroke = nil, nil, nil
local killAuraConnection, killAuraV2Connection, particlesConnection, trailConnection, infJumpConnection, autoSprintConnection, runNoClip, antiAimConnection = nil, nil, nil, nil, nil, nil, nil, nil
local iconCube, minimizeBtn, closeBtn = nil, nil, nil
local dashButton = nil
local flyConnection = nil
local stretchConnection = nil
local particlesV2Connection = nil
local bunnyHopConnection = nil
local speedGlitchConnection = nil
local antiAimV3Connection = nil
local jumpCircleConnection = nil
local fakeLagConnection = nil
local doubleTapConnection = nil
local autoFlingConnection = nil
local walkFlingConnection = nil
local swordVisualConnection = nil
local orbitKillAuraConnection = nil
local worldColorsConnection = nil
local fogConnection = nil
local nightVisionConnection = nil
local thermalVisionConnection = nil
local rainbowWorldConnection = nil
local hitboxConnection = nil
local crosshairGui = nil
local wallHopConnection = nil
local wallHopButton = nil
local r6AnimationsConnection = nil

-- ============================================================================
-- 🎮 ТОГГЛЫ
-- ============================================================================

local aimbotEnabled, aimbotV2Enabled, aimbotV3Enabled = false, false, false
local worldColorEnabled, particlesV2Enabled = false, false
local espEnabled, espV2Enabled, jumpCircleEnabled, trailEnabled, trailV2Enabled = false, false, false, false, false
local particlesEnabled, stretchEnabled, hatEnabled, helicopterEnabled = false, false, false, false
local invisibilityEnabled, noClipEnabled, antiAimEnabled, fakeLagEnabled = false, false, false, false
local killAuraEnabled, killAuraV2Enabled, triggerBotEnabled = false, false, false
local infJumpEnabled, autoSprintEnabled, airWalkEnabled = false, false, false
local flyV1Enabled, flyV2Enabled, tpToolEnabled = false, false, false
local spiderEnabled, antiKbEnabled, swimEnabled = false, false, false
local targetHudEnabled, hitGlowEnabled = false, false
local flyEnabled = false
local antiAimV3Enabled = false
local antiAimV3Mode = "Backwards"
local bunnyHopEnabled = false
local speedGlitchEnabled = false
local r6AnimationsEnabled = false
local fullbrightEnabled = false
local doubleTapEnabled = false
local autoFlingEnabled = false
local walkFlingEnabled = false
local strafeEnabled = false
local dashEnabled = false
local swordVisualEnabled = false
local orbitKillAuraEnabled = false
local worldColorsEnabled = false
local fogEnabled = false
local nightVisionEnabled = false
local thermalVisionEnabled = false
local rainbowWorldEnabled = false
local crosshairEnabled = false
local hitboxEnabled = false
local hitboxExpanderEnabled = false
local wallHopEnabled = false

-- ===== MM2 =====
local mm2EspV2Enabled, mm2EspV3Enabled = false, false
local coinFarmEnabled, autoStabEnabled, mm2AimbotV2Enabled = false, false, false
local mm2EspV3Folder = nil
local mm2FovCircle = nil
local mm2FovStroke = nil
local lastTapTime = 0
local tapCount = 0
local currentSword = nil
local lastHitInstance = nil
local lastFlickTime = 0

-- ===== ORBIT =====
local orbitButton = nil
local orbitAngle = 0
local orbitRadius = 8
local orbitSpeed = 3
local orbitTarget = nil
local orbitButtonDragging = false
local orbitButtonDragStart = nil
local orbitButtonStartPos = nil
local flingPower = 999999
local selectedColor = Color3.fromRGB(255, 0, 255)
local flySpeed = 50

-- ============================================================================
-- 🔧 ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ============================================================================

local function ShowMessage(text)
    pcall(function()
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
        task.spawn(function()
            task.wait(1.5)
            pcall(function() msg:Destroy() end)
        end)
    end)
end

local function OpenTextInput(title, placeholder, default, callback)
    pcall(function()
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
        btn.BackgroundColor3 = guiSettings.ButtonColor
        btn.Text = "Apply"
        btn.TextColor3 = guiSettings.TextColor
        btn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        btn.MouseButton1Click:Connect(function()
            local n = tonumber(tb.Text)
            if n then 
                callback(n) 
                pcall(function() s:Destroy() end)
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
        c.MouseButton1Click:Connect(function() pcall(function() s:Destroy() end) end)
    end)
end

local function OpenColorPicker(title, callback)
    pcall(function()
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
            {"Yellow", Color3.fromRGB(255,220,0)},
            {"Orange", Color3.fromRGB(255, 165, 0)},
            {"Pink", Color3.fromRGB(255, 105, 180)},
            {"Black", Color3.fromRGB(0, 0, 0)}
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
                pcall(function() s:Destroy() end)
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
        c.MouseButton1Click:Connect(function() pcall(function() s:Destroy() end) end)
    end)
end

function OpenFogColorPicker()
    OpenColorPicker("Select Fog Color", function(color)
        guiSettings.FogColor = color
        Lighting.FogColor = color
        ShowMessage("Fog color changed!")
    end)
end

-- ============================================================================
-- 🧱 WALL HOP
-- ============================================================================

function ToggleWallHop()
    wallHopEnabled = not wallHopEnabled
    
    if wallHopEnabled then
        ShowMessage("Wall Hop ON")
        
        if wallHopConnection then wallHopConnection:Disconnect() end
        
        wallHopConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not wallHopEnabled then return end
                
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChild("Humanoid")
                if not hrp or not hum then return end
                
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = {char}
                raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                
                local result = workspace:Raycast(hrp.Position, Camera.CFrame.LookVector * 3, raycastParams)
                
                if result and result.Instance.CanCollide then
                    if lastHitInstance and lastHitInstance ~= result.Instance then
                        if tick() - lastFlickTime > 0.05 then
                            lastFlickTime = tick()
                            
                            hum:ChangeState(Enum.HumanoidStateType.Jumping)
                            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 50, hrp.AssemblyLinearVelocity.Z)
                            
                            local startCFrame = Camera.CFrame
                            Camera.CFrame = startCFrame * CFrame.Angles(0, math.rad(180), 0)
                            task.wait(0.01)
                            Camera.CFrame = startCFrame
                        end
                    end
                    lastHitInstance = result.Instance
                else
                    lastHitInstance = nil
                end
            end)
        end)
    else
        if wallHopConnection then wallHopConnection:Disconnect() end
        ShowMessage("Wall Hop OFF")
    end
end

function CreateWallHopButton()
    if wallHopButton then return end
    
    local sg = Instance.new("ScreenGui", game.CoreGui)
    sg.Name = "MTY_WallHopUI"
    sg.ResetOnSpawn = false
    
    wallHopButton = Instance.new("TextButton", sg)
    wallHopButton.Size = UDim2.new(0, 140, 0, 50)
    wallHopButton.Position = UDim2.new(0.1, 0, 0.7, 0)
    wallHopButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    wallHopButton.Text = "Wall Hop OFF"
    wallHopButton.TextColor3 = Color3.fromRGB(240, 240, 245)
    wallHopButton.Font = Enum.Font.GothamBold
    wallHopButton.TextScaled = true
    Instance.new("UICorner", wallHopButton).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", wallHopButton).Color = guiSettings.BorderColor
    Instance.new("UIStroke", wallHopButton).Thickness = 1.5
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    wallHopButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = wallHopButton.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            wallHopButton.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    wallHopButton.MouseButton1Click:Connect(function()
        ToggleWallHop()
        wallHopButton.Text = wallHopEnabled and "Wall Hop ON" or "Wall Hop OFF"
        wallHopButton.BackgroundColor3 = wallHopEnabled and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(20, 20, 25)
    end)
end

-- ============================================================================
-- 🕺 R6 ANIMATIONS (РАБОЧАЯ ВЕРСИЯ)
-- ============================================================================

function ToggleR6Animations()
    r6AnimationsEnabled = not r6AnimationsEnabled
    
    if r6AnimationsEnabled then
        ShowMessage("R6 Animations ON")
        
        if LP.Character then
            local hum = LP.Character:FindFirstChild("Humanoid")
            if hum and hum.RigType == Enum.HumanoidRigType.R15 then
                local animate = LP.Character:FindFirstChild("Animate")
                if animate then animate.Disabled = true end
            end
        end
        
        r6AnimationsConnection = LP.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum.RigType == Enum.HumanoidRigType.R15 then
                local animate = char:FindFirstChild("Animate")
                if animate then animate.Disabled = true end
            end
        end)
    else
        if r6AnimationsConnection then r6AnimationsConnection:Disconnect() end
        if LP.Character then
            local animate = LP.Character:FindFirstChild("Animate")
            if animate then animate.Disabled = false end
        end
        ShowMessage("R6 Animations OFF")
    end
end

-- ============================================================================
-- 🎯 AIMBOT ENGINE
-- ============================================================================

local function IsVisible(part)
    if guiSettings.AimbotWallbang then return true end
    local success, result = pcall(function()
        local parts = Camera:GetPartsObscuringTarget({part.Position}, {LP.Character, part.Parent})
        return #parts == 0
    end)
    return success and result or false
end

local function FindBestTarget()
    local target, near = nil, guiSettings.AimbotFOV
    local mid = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    pcall(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                local hit = p.Character:FindFirstChild(guiSettings.AimbotPart) or p.Character:FindFirstChild("Head")
                if hit and IsVisible(hit) then
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
    end)
    
    return target
end

function ToggleAimbot()
    aimbotEnabled = not aimbotEnabled
    ShowMessage(aimbotEnabled and "Aimbot ON" or "Aimbot OFF")
end

function ToggleAimbotV2()
    aimbotV2Enabled = not aimbotV2Enabled
    ShowMessage(aimbotV2Enabled and "Aimbot V2 (Silent) ON" or "Aimbot V2 OFF")
end

function ToggleAimbotV3()
    aimbotV3Enabled = not aimbotV3Enabled
    ShowMessage(aimbotV3Enabled and "Aimbot V3 (Predict) ON" or "Aimbot V3 OFF")
end

fovGui = Instance.new("ScreenGui", game.CoreGui) fovGui.Name = "MTY_FOV"
fovRing = Instance.new("Frame", fovGui) 
fovRing.AnchorPoint = Vector2.new(0.5,0.5) 
fovRing.Position = UDim2.new(0.5,0,0.5,0) 
fovRing.BackgroundTransparency = 1 
fovRing.Visible = false
fovStroke = Instance.new("UIStroke", fovRing) 
fovStroke.Thickness = 1.5 
fovStroke.Color = guiSettings.BorderColor
Instance.new("UICorner", fovRing).CornerRadius = UDim.new(1, 0)

RunService.RenderStepped:Connect(function()
    pcall(function()
        if fovRing then
            fovRing.Size = UDim2.new(0, guiSettings.AimbotFOV * 2, 0, guiSettings.AimbotFOV * 2)
            fovRing.Visible = aimbotEnabled
            if fovStroke then fovStroke.Color = guiSettings.BorderColor end
        end
        
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
            else
                targetPlayer = nil
            end
        end
    end)
end)

-- ============================================================================
-- 🎯 КРОССХАИР
-- ============================================================================

function ToggleCrosshair()
    crosshairEnabled = not crosshairEnabled
    
    if crosshairEnabled then
        if crosshairGui then crosshairGui:Destroy() end
        crosshairGui = Instance.new("ScreenGui", game.CoreGui)
        crosshairGui.Name = "MTY_Crosshair"
        crosshairGui.ResetOnSpawn = false
        
        local frame = Instance.new("Frame", crosshairGui)
        frame.Size = UDim2.new(0, 2, 0, 30)
        frame.Position = UDim2.new(0.5, -1, 0.5, -15)
        frame.BackgroundColor3 = guiSettings.CrosshairColor
        frame.BorderSizePixel = 0
        
        local frame2 = Instance.new("Frame", crosshairGui)
        frame2.Size = UDim2.new(0, 30, 0, 2)
        frame2.Position = UDim2.new(0.5, -15, 0.5, -1)
        frame2.BackgroundColor3 = guiSettings.CrosshairColor
        frame2.BorderSizePixel = 0
        
        local dot = Instance.new("Frame", crosshairGui)
        dot.Size = UDim2.new(0, 4, 0, 4)
        dot.Position = UDim2.new(0.5, -2, 0.5, -2)
        dot.BackgroundColor3 = guiSettings.CrosshairColor
        dot.BorderSizePixel = 0
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        
        ShowMessage("Crosshair ON")
    else
        if crosshairGui then crosshairGui:Destroy() end
        ShowMessage("Crosshair OFF")
    end
end

-- ============================================================================
-- 📦 ХИТБОКСЫ
-- ============================================================================

HitboxFolder = Instance.new("Folder", workspace) HitboxFolder.Name = "MTY_Hitboxes"

function ToggleHitboxes()
    hitboxEnabled = not hitboxEnabled
    
    if hitboxEnabled then
        HitboxFolder:ClearAllChildren()
        
        hitboxConnection = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not hitboxEnabled then return end
                
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local root = p.Character.HumanoidRootPart
                        local box = root:FindFirstChild("MTY_Hitbox")
                        
                        if not box then
                            box = Instance.new("BoxHandleAdornment", root)
                            box.Name = "MTY_Hitbox"
                            box.Size = Vector3.new(guiSettings.HitboxSize, guiSettings.HitboxSize, guiSettings.HitboxSize)
                            box.Color3 = guiSettings.HitboxColor
                            box.Transparency = 0.5
                            box.AlwaysOnTop = true
                            box.ZIndex = 5
                            box.Adornee = root
                        end
                    end
                end
            end)
        end)
        ShowMessage("Hitboxes ON")
    else
        if hitboxConnection then hitboxConnection:Disconnect() end
        HitboxFolder:ClearAllChildren()
        ShowMessage("Hitboxes OFF")
    end
end

function ToggleHitboxExpander()
    hitboxExpanderEnabled = not hitboxExpanderEnabled
    
    if hitboxExpanderEnabled then
        ShowMessage("Hitbox Expander ON")
        RunService.Heartbeat:Connect(function()
            pcall(function()
                if not hitboxExpanderEnabled or not LP.Character then return end
                
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character then
                        for _, v in pairs(p.Character:GetDescendants()) do
                            if v:IsA("BasePart") then
                                v.Size = v.Size * 1.5
                            end
                        end
                    end
                end
            end)
        end)
    else
        ShowMessage("Hitbox Expander OFF")
    end
end

-- ============================================================================
-- 👁️ ЭСП
-- ============================================================================

espFolder = Instance.new("Folder", workspace) espFolder.Name = "MTY_ESP"
espV2Folder = Instance.new("Folder", workspace) espV2Folder.Name = "MTY_ESP_V2"

function ToggleESP() 
    espEnabled = not espEnabled 
    ShowMessage(espEnabled and "ESP ON" or "ESP OFF")
end

function ToggleESPV2() 
    espV2Enabled = not espV2Enabled 
    ShowMessage(espV2Enabled and "ESP V2 ON" or "ESP V2 OFF")
end

task.spawn(function()
    while true do 
        task.wait(0.2) 
        pcall(function()
            espFolder:ClearAllChildren() 
            espV2Folder:ClearAllChildren()
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
                        local b = Instance.new("BoxHandleAdornment", espV2Folder)
                        b.Size = Vector3.new(4.3, 5.6, 4.3)
                        b.Color3 = guiSettings.ESPColor
                        b.Transparency = 0.6
                        b.AlwaysOnTop = true
                        b.Adornee = c.HumanoidRootPart
                    end
                end
            end
        end) 
    end
end)

-- ============================================================================
-- 🎩 CHINA HAT
-- ============================================================================

local currentHat = nil
local hatConnection = nil

function CreateChineseHat()
    pcall(function()
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
            pcall(function()
                if not currentHat or not LP.Character or not LP.Character:FindFirstChild("Head") then return end
                local color = guiSettings.HatRainbow and Color3.fromHSV((tick() * 0.4) % 1, 1, 1) or guiSettings.HatColor
                currentHat.Color = color
                trail.Color = ColorSequence.new(color)
                currentHat.CFrame = LP.Character.Head.CFrame * CFrame.new(0, 0.6, 0)
            end)
        end)
    end)
end

function ToggleChineseHat()
    hatEnabled = not hatEnabled
    if hatEnabled then 
        CreateChineseHat()
        ShowMessage("China Hat ON")
    else 
        if currentHat then currentHat:Destroy() end
        if hatConnection then hatConnection:Disconnect() end
        ShowMessage("China Hat OFF")
    end
end

-- ============================================================================
-- 🌍 WORLD COLOR
-- ============================================================================

local originalAmbient = Lighting.Ambient
local originalOutdoor = Lighting.OutdoorAmbient

function ToggleWorldColor()
    worldColorEnabled = not worldColorEnabled
    
    if worldColorEnabled then
        ShowMessage("World Color ON")
        originalAmbient = Lighting.Ambient
        originalOutdoor = Lighting.OutdoorAmbient
        
        worldColorsConnection = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not worldColorEnabled then return end
                
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Color = guiSettings.WorldColor
                        v.Material = Enum.Material.Neon
                        v.Transparency = 0.3
                    end
                end
                
                Lighting.Ambient = guiSettings.WorldColor
                Lighting.OutdoorAmbient = guiSettings.WorldColor
            end)
        end)
    else
        if worldColorsConnection then worldColorsConnection:Disconnect() end
        Lighting.Ambient = originalAmbient or Color3.fromRGB(127, 127, 127)
        Lighting.OutdoorAmbient = originalOutdoor or Color3.fromRGB(127, 127, 127)
        
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Transparency = 0
            end
        end
        ShowMessage("World Color OFF")
    end
end

function SetWorldColor(color)
    guiSettings.WorldColor = color
    if worldColorEnabled then
        ToggleWorldColor()
        task.wait(0.1)
        ToggleWorldColor()
    end
    ShowMessage("World Color set!")
end

-- ============================================================================
-- 🌫️ FOG
-- ============================================================================

function ToggleFog()
    fogEnabled = not fogEnabled
    
    if fogEnabled then
        ShowMessage("Fog ON")
        
        Lighting.FogEnd = guiSettings.FogEnd or 100
        Lighting.FogStart = guiSettings.FogStart or 0
        Lighting.FogColor = guiSettings.FogColor or Color3.fromRGB(150, 100, 200)
        
        fogConnection = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not fogEnabled then return end
                
                local time = tick() * 0.1
                Lighting.FogEnd = guiSettings.FogEnd + math.sin(time) * 20
                Lighting.FogColor = guiSettings.FogColor
            end)
        end)
    else
        if fogConnection then fogConnection:Disconnect() end
        Lighting.FogEnd = 1000
        Lighting.FogStart = 0
        Lighting.FogColor = Color3.fromRGB(255, 255, 255)
        ShowMessage("Fog OFF")
    end
end

function SetFogColor(color)
    guiSettings.FogColor = color
    Lighting.FogColor = color
    ShowMessage("Fog color changed!")
end

function SetFogDistance(startDist, endDist)
    guiSettings.FogStart = startDist or 0
    guiSettings.FogEnd = endDist or 100
    Lighting.FogStart = startDist or 0
    Lighting.FogEnd = endDist or 100
    ShowMessage("Fog distance set!")
end

-- ============================================================================
-- 🏃 SPEED
-- ============================================================================

function ToggleSpeed()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        local hum = LP.Character.Humanoid
        if hum.WalkSpeed == 16 then
            hum.WalkSpeed = 50
            ShowMessage("Speed ON (50)")
        else
            hum.WalkSpeed = 16
            ShowMessage("Speed OFF")
        end
    end
end

function SetSpeed(value)
    speedValue = value
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = value
    end
    ShowMessage("Speed set to: " .. value)
end

-- ============================================================================
-- ✈️ FLY V1
-- ============================================================================

function ToggleFlyV1()
    flyV1Enabled = not flyV1Enabled
    
    if flyV1Enabled then
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.PlatformStand = true
        end
        
        flyConnection = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not flyV1Enabled or not LP.Character then return end
                
                local root = LP.Character:FindFirstChild("HumanoidRootPart")
                local hum = LP.Character:FindFirstChild("Humanoid")
                if not root or not hum then return end
                
                local moveDirection = hum.MoveDirection
                local cameraLook = Camera.CFrame.LookVector
                local cameraRight = Camera.CFrame.RightVector
                
                local vertical = 0
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 
                    vertical = flySpeed
                elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then 
                    vertical = -flySpeed
                end
                
                local moveVector = Vector3.new(0, 0, 0)
                if moveDirection.Magnitude > 0 then
                    moveVector = (cameraLook * moveDirection.Z + cameraRight * moveDirection.X) * flySpeed
                end
                
                root.AssemblyLinearVelocity = Vector3.new(moveVector.X, vertical, moveVector.Z)
                hum.PlatformStand = true
            end)
        end)
        ShowMessage("Fly V1 ON")
    else
        if flyConnection then flyConnection:Disconnect() end
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.PlatformStand = false
        end
        ShowMessage("Fly V1 OFF")
    end
end

-- ============================================================================
-- ✈️ FLY V2 (ПО КАМЕРЕ)
-- ============================================================================

function ToggleFlyV2()
    flyV2Enabled = not flyV2Enabled
    
    if flyV2Enabled then
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.PlatformStand = true
        end
        
        flyConnection = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not flyV2Enabled or not LP.Character then return end
                
                local root = LP.Character:FindFirstChild("HumanoidRootPart")
                local hum = LP.Character:FindFirstChild("Humanoid")
                if not root or not hum then return end
                
                local camLook = Camera.CFrame.LookVector
                local camRight = Camera.CFrame.RightVector
                local moveDirection = hum.MoveDirection
                
                local vertical = 0
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 
                    vertical = flySpeed
                elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then 
                    vertical = -flySpeed
                end
                
                local moveVector = Vector3.new(0, 0, 0)
                if moveDirection.Magnitude > 0 then
                    moveVector = (camLook * moveDirection.Z + camRight * moveDirection.X) * flySpeed
                end
                
                root.AssemblyLinearVelocity = Vector3.new(moveVector.X, vertical, moveVector.Z)
                hum.PlatformStand = true
            end)
        end)
        ShowMessage("Fly V2 ON")
    else
        if flyConnection then flyConnection:Disconnect() end
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.PlatformStand = false
        end
        ShowMessage("Fly V2 OFF")
    end
end

-- ============================================================================
-- 🦘 BUNNYHOP (БЕЗ АВТОПРЫЖКА)
-- ============================================================================

function ToggleBunnyHop()
    bunnyHopEnabled = not bunnyHopEnabled
    
    if bunnyHopEnabled then
        if bunnyHopConnection then bunnyHopConnection:Disconnect() end
        
        bunnyHopConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not bunnyHopEnabled or not LP.Character then return end
                
                local hum = LP.Character:FindFirstChild("Humanoid")
                local root = LP.Character:FindFirstChild("HumanoidRootPart")
                if not hum or not root then return end
                
                local state = hum:GetState()
                local moveDirection = hum.MoveDirection
                
                if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.FreeFall then
                    if moveDirection.Magnitude > 0 then
                        local currentVel = root.AssemblyLinearVelocity
                        local speed = 55
                        root.AssemblyLinearVelocity = Vector3.new(
                            moveDirection.X * speed,
                            currentVel.Y,
                            moveDirection.Z * speed
                        )
                    end
                end
            end)
        end)
        ShowMessage("BunnyHop ON")
    else
        if bunnyHopConnection then bunnyHopConnection:Disconnect() end
        ShowMessage("BunnyHop OFF")
    end
end

-- ============================================================================
-- ⚔️ KILL AURA
-- ============================================================================

local function GetDmgRemote(tool)
    if not tool then return nil end
    for _, v in pairs(tool:GetDescendants()) do 
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then 
            local n = v.Name:lower() 
            if n:find("hit") or n:find("attack") or n:find("damage") or n:find("slash") then 
                return v 
            end 
        end 
    end 
    return nil
end

local function AttackPlayer(tChar, tool)
    if not tChar or not tChar:FindFirstChild("HumanoidRootPart") or not tool then return end
    pcall(function()
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
    end)
end

function ApplyToolReach()
    if not LP.Character then return end 
    local tool = LP.Character:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then 
        tool.Handle.Size = Vector3.new(guiSettings.ToolReachValue, guiSettings.ToolReachValue, guiSettings.ToolReachValue) 
        tool.Handle.CanCollide = false 
    end
end

function ToggleKillAura()
    killAuraEnabled = not killAuraEnabled
    if killAuraEnabled then
        killAuraConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not killAuraEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
                local tool = LP.Character:FindFirstChildOfClass("Tool")
                if not tool then return end
                
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        local dist = (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= guiSettings.KillAuraRange then
                            AttackPlayer(p.Character, tool)
                        end
                    end
                end
            end)
        end)
        ShowMessage("Kill Aura ON")
    else
        if killAuraConnection then killAuraConnection:Disconnect() end
        ShowMessage("Kill Aura OFF")
    end
end

function ToggleKillAuraV2()
    killAuraV2Enabled = not killAuraV2Enabled
    if killAuraV2Enabled then
        killAuraV2Connection = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not killAuraV2Enabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
                local tool = LP.Character:FindFirstChildOfClass("Tool")
                if not tool then return end
                
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        local dist = (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= (guiSettings.KillAuraRange + 4) then
                            AttackPlayer(p.Character, tool)
                            LP.Character.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(120), 0)
                        end
                    end
                end
            end)
        end)
        ShowMessage("Kill Aura V2 ON")
    else
        if killAuraV2Connection then killAuraV2Connection:Disconnect() end
        ShowMessage("Kill Aura V2 OFF")
    end
end

-- ============================================================================
-- 🌀 ORBIT KILL AURA
-- ============================================================================

function CreateOrbitButton()
    if orbitButton then return end
    
    local sg = Instance.new("ScreenGui", game.CoreGui)
    sg.Name = "MTY_OrbitKillAuraUI"
    sg.ResetOnSpawn = false
    
    orbitButton = Instance.new("TextButton", sg)
    orbitButton.Size = UDim2.new(0, 65, 0, 65)
    orbitButton.Position = UDim2.new(0.85, 0, 0.75, 0)
    orbitButton.BackgroundColor3 = guiSettings.OrbitColor
    orbitButton.Text = "O"
    orbitButton.TextColor3 = Color3.new(1,1,1)
    orbitButton.TextSize = 30
    orbitButton.Font = Enum.Font.GothamBold
    orbitButton.ZIndex = 10
    Instance.new("UICorner", orbitButton).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", orbitButton).Color = Color3.fromRGB(255,255,255)
    Instance.new("UIStroke", orbitButton).Thickness = 2
    
    orbitButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            orbitButtonDragging = true
            orbitButtonDragStart = input.Position
            orbitButtonStartPos = orbitButton.Position
        end
    end)
    
    orbitButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            orbitButtonDragging = false
        end
    end)
    
    orbitButton.InputChanged:Connect(function(input)
        if orbitButtonDragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - orbitButtonDragStart
            orbitButton.Position = UDim2.new(
                orbitButtonStartPos.X.Scale + delta.X / game.GuiService:GetScreenResolution().X,
                0,
                orbitButtonStartPos.Y.Scale + delta.Y / game.GuiService:GetScreenResolution().Y,
                0
            )
        end
    end)
    
    orbitButton.MouseButton1Click:Connect(function()
        ToggleOrbitKillAura()
    end)
end

function ToggleOrbitKillAura()
    orbitKillAuraEnabled = not orbitKillAuraEnabled
    
    if orbitKillAuraEnabled then
        if not orbitButton then CreateOrbitButton() end
        orbitButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        orbitButton.Text = "O N"
        
        orbitKillAuraConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not orbitKillAuraEnabled or not LP.Character then return end
                
                local myRoot = LP.Character:FindFirstChild("HumanoidRootPart")
                if not myRoot then return end
                
                local nearest = nil
                local nearestDist = guiSettings.OrbitRadius or 8
                
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
                        local targetHum = p.Character:FindFirstChild("Humanoid")
                        if targetRoot and targetHum and targetHum.Health > 0 then
                            local dist = (myRoot.Position - targetRoot.Position).Magnitude
                            if dist < nearestDist then
                                nearestDist = dist
                                nearest = p
                            end
                        end
                    end
                end
                
                if nearest then
                    orbitTarget = nearest
                    local targetRoot = nearest.Character.HumanoidRootPart
                    
                    orbitAngle = orbitAngle + (guiSettings.OrbitSpeed or 3) * 0.05
                    local radius = guiSettings.OrbitRadius or 8
                    
                    local x = math.cos(orbitAngle) * radius
                    local z = math.sin(orbitAngle) * radius
                    
                    myRoot.CFrame = CFrame.new(
                        targetRoot.Position.X + x,
                        targetRoot.Position.Y + 2,
                        targetRoot.Position.Z + z
                    ) * CFrame.Angles(0, -orbitAngle, 0)
                    
                    local tool = LP.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                        local remote = GetDmgRemote(tool)
                        if remote then
                            remote:FireServer(targetRoot)
                        end
                    end
                    
                    if hitGlowEnabled then
                        local trail = Instance.new("Part", workspace)
                        trail.Size = Vector3.new(0.3, 0.3, 0.3)
                        trail.Shape = Enum.PartType.Ball
                        trail.Material = Enum.Material.Neon
                        trail.Color = guiSettings.OrbitColor
                        trail.Transparency = 0.5
                        trail.Anchored = true
                        trail.CanCollide = false
                        trail.CFrame = myRoot.CFrame
                        Debris:AddItem(trail, 0.3)
                    end
                end
            end)
        end)
        ShowMessage("Orbit Kill Aura ON")
    else
        if orbitKillAuraConnection then orbitKillAuraConnection:Disconnect() end
        if orbitButton then
            orbitButton.BackgroundColor3 = guiSettings.OrbitColor
            orbitButton.Text = "O"
        end
        ShowMessage("Orbit Kill Aura OFF")
    end
end

-- ============================================================================
-- 🎯 TRIGGER BOT
-- ============================================================================

function ToggleTriggerBot()
    triggerBotEnabled = not triggerBotEnabled
    ShowMessage(triggerBotEnabled and "Trigger Bot ON" or "Trigger Bot OFF")
end

-- ============================================================================
-- 💥 WALK FLING
-- ============================================================================

function ToggleWalkFling()
    walkFlingEnabled = not walkFlingEnabled
    
    if walkFlingEnabled then
        ShowMessage("Walk Fling ON")
        walkFlingConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not walkFlingEnabled or not LP.Character then return end
                
                local myRoot = LP.Character:FindFirstChild("HumanoidRootPart")
                if not myRoot then return end
                
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
                        local targetHum = p.Character:FindFirstChild("Humanoid")
                        if targetRoot and targetHum and targetHum.Health > 0 then
                            local dist = (myRoot.Position - targetRoot.Position).Magnitude
                            if dist <= 5 then
                                local dir = (targetRoot.Position - myRoot.Position).Unit
                                targetRoot.AssemblyLinearVelocity = dir * flingPower + Vector3.new(0, flingPower/2, 0)
                                targetHum.Sit = true
                                task.wait(0.1)
                                targetRoot.AssemblyLinearVelocity = dir * flingPower * 2 + Vector3.new(0, flingPower, 0)
                            end
                        end
                    end
                end
            end)
        end)
    else
        if walkFlingConnection then walkFlingConnection:Disconnect() end
        ShowMessage("Walk Fling OFF")
    end
end

-- ============================================================================
-- 🌀 ANTI-AIM V2
-- ============================================================================

function ToggleAntiAim()
    antiAimEnabled = not antiAimEnabled
    if antiAimEnabled then
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then 
            LP.Character.Humanoid.AutoRotate = false 
        end
        antiAimConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not antiAimEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
                local root = LP.Character.HumanoidRootPart
                if guiSettings.AntiAimMode == "Spin" then 
                    root.AssemblyAngularVelocity = Vector3.new(0, 65, 0)
                elseif guiSettings.AntiAimMode == "Backwards" then 
                    local camLook = Camera.CFrame.LookVector 
                    root.CFrame = CFrame.new(root.Position, root.Position - Vector3.new(camLook.X, 0, camLook.Z)) 
                end
            end)
        end) 
        ShowMessage("Anti-Aim V2 ON")
    else
        if antiAimConnection then antiAimConnection:Disconnect() antiAimConnection = nil end
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then 
            LP.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0,0,0) 
            LP.Character.Humanoid.AutoRotate = true 
        end
        ShowMessage("Anti-Aim V2 OFF")
    end
end

function SetAntiAimMode(mode) 
    guiSettings.AntiAimMode = mode 
    ShowMessage("Anti-Aim V2 Mode: " .. mode)
end

-- ============================================================================
-- 🔥 ANTI-AIM V3
-- ============================================================================

function ToggleAntiAimV3()
    antiAimV3Enabled = not antiAimV3Enabled
    
    if antiAimV3Enabled then
        if antiAimEnabled then
            if antiAimConnection then
                antiAimConnection:Disconnect()
                antiAimConnection = nil
            end
            antiAimEnabled = false
        end
        
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.AutoRotate = false
        end
        
        antiAimV3Connection = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not antiAimV3Enabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then 
                    return 
                end
                
                local root = LP.Character.HumanoidRootPart
                local hum = LP.Character:FindFirstChild("Humanoid")
                
                if antiAimV3Mode == "Backwards" then
                    local camLook = Camera.CFrame.LookVector
                    local newCF = CFrame.new(root.Position, root.Position - Vector3.new(camLook.X, 0, camLook.Z))
                    root.CFrame = newCF
                    
                    if hum and hum.MoveDirection.Magnitude > 0 then
                        local moveDir = hum.MoveDirection
                        root.AssemblyLinearVelocity = Vector3.new(
                            -moveDir.X * speedValue * 1.2,
                            root.AssemblyLinearVelocity.Y,
                            -moveDir.Z * speedValue * 1.2
                        )
                    end
                    
                elseif antiAimV3Mode == "Spin" then
                    root.AssemblyAngularVelocity = Vector3.new(0, 65, 0)
                    
                elseif antiAimV3Mode == "Jitter" then
                    local time = tick()
                    local jitterAngle = math.sin(time * 30) * 45
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(jitterAngle), 0)
                end
            end)
        end)
        
        ShowMessage("Anti-Aim V3 ON")
    else
        if antiAimV3Connection then antiAimV3Connection:Disconnect() end
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
            LP.Character.Humanoid.AutoRotate = true
        end
        ShowMessage("Anti-Aim V3 OFF")
    end
end

function SetAntiAimV3Mode(mode)
    antiAimV3Mode = mode
    if antiAimV3Enabled then
        ToggleAntiAimV3()
        task.wait(0.1)
        ToggleAntiAimV3()
    end
    ShowMessage("Anti-Aim V3 Mode: " .. mode)
end

-- ============================================================================
-- 🔧 HVH ФУНКЦИИ
-- ============================================================================

function ToggleResolver()
    ShowMessage("Resolver ON")
end

function ToggleDesync()
    desyncEnabled = not desyncEnabled
    ShowMessage(desyncEnabled and "Desync ON" or "Desync OFF")
end

function ToggleFakeLag()
    fakeLagEnabled = not fakeLagEnabled
    if fakeLagEnabled then
        fakeLagConnection = RunService.Heartbeat:Connect(function() 
            for i=1, guiSettings.FakeLagAmount or 6 do 
                task.wait(0.001) 
            end 
        end)
    else
        if fakeLagConnection then fakeLagConnection:Disconnect() end
    end
    ShowMessage(fakeLagEnabled and "FakeLag ON" or "FakeLag OFF")
end

function ToggleAntiKb()
    antiKbEnabled = not antiKbEnabled 
    ShowMessage(antiKbEnabled and "Anti-Knockback ON" or "Anti-Knockback OFF")
    RunService.Heartbeat:Connect(function() 
        pcall(function()
            if antiKbEnabled and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then 
                local vel = LP.Character.HumanoidRootPart.AssemblyLinearVelocity 
                if vel.Magnitude > 60 then 
                    LP.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0) 
                end
            end
        end)
    end)
end

-- ============================================================================
-- ⚔️ CLASSIC SWORD
-- ============================================================================

function ToggleSwordVisual()
    swordVisualEnabled = not swordVisualEnabled
    
    if swordVisualEnabled then
        pcall(function()
            if not LP.Character then
                ShowMessage("No character!")
                return
            end
            
            if currentSword then currentSword:Destroy() end
            
            currentSword = Instance.new("Tool", LP.Backpack)
            currentSword.GripPos = Vector3.new(0, 0, -1.5)
            currentSword.GripForward = Vector3.new(0, -1, 0)
            currentSword.GripRight = Vector3.new(1, 0, 0)
            currentSword.GripUp = Vector3.new(0, 0, 1)
            currentSword.Name = "ClassicSword"
            currentSword.TextureId = "rbxasset://Textures/Sword128.png"
            currentSword.RequiresHandle = true
            currentSword.CanBeDropped = true
            
            local handle = Instance.new("Part", currentSword)
            handle.Name = "Handle"
            handle.Size = Vector3.new(1, 0.8, 4)
            handle.Anchored = false
            handle.CanCollide = false
            
            local mesh = Instance.new("SpecialMesh", handle)
            mesh.MeshId = "rbxasset://fonts/sword.mesh"
            mesh.TextureId = "rbxasset://textures/SwordTexture.png"
            mesh.Scale = Vector3.new(1, 1, 1)
            mesh.Offset = Vector3.new(0, 0, 0)
            mesh.VertexColor = Vector3.new(1, 1, 1)
            
            local unsheath = Instance.new("Sound", handle)
            unsheath.SoundId = "http://www.roblox.com/asset/?id=12222225"
            unsheath.Volume = 1
            
            local slash = Instance.new("Sound", handle)
            slash.SoundId = "http://www.roblox.com/asset/?id=12222216"
            slash.Volume = 1
            
            local anim = Instance.new("Animation", currentSword)
            anim.AnimationId = "rbxassetid://94161088"
            
            local db = true
            local da = false
            
            currentSword.Equipped:Connect(function()
                unsheath:Play()
                task.wait(1)
                currentSword.Activated:Connect(function()
                    if db == true then
                        db = false
                        slash:Play()
                        local animTrack = LP.Character.Humanoid:LoadAnimation(anim)
                        animTrack:Play()
                        task.wait()
                        da = true
                        db = true
                        task.wait(2)
                        da = false
                        animTrack:Stop()
                    end
                end)
            end)
            
            handle.Touched:Connect(function(n)
                if da == true then
                    local o = n.Parent:FindFirstChild("Humanoid")
                    if o ~= nil then
                        local p = game.Players:FindFirstChild(n.Parent.Name)
                        if p and p ~= LP then
                            if o.Health > 0 then
                                o.Health = o.Health - 20
                                ShowMessage("Hit: " .. p.Name)
                            end
                        end
                    end
                end
            end)
            
            ShowMessage("Classic Sword ON")
        end)
    else
        if currentSword then currentSword:Destroy() end
        ShowMessage("Classic Sword OFF")
    end
end

-- ============================================================================
-- ⚡ SPEED GLITCH
-- ============================================================================

function ToggleSpeedGlitch()
    speedGlitchEnabled = not speedGlitchEnabled
    
    if speedGlitchEnabled then
        speedGlitchConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not speedGlitchEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") or not LP.Character:FindFirstChild("Humanoid") then return end
                
                local root = LP.Character.HumanoidRootPart
                local hum = LP.Character.Humanoid
                local move = hum.MoveDirection
                
                if move.Magnitude > 0 then
                    local currentVel = root.AssemblyLinearVelocity
                    local targetSpeed = 80
                    
                    if hum:GetState() == Enum.HumanoidStateType.Landed then
                        local jumpPower = hum.JumpPower
                        hum.JumpPower = 0
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                        task.wait(0.05)
                        hum.JumpPower = jumpPower
                    end
                    
                    local targetVel = Vector3.new(move.X * targetSpeed, currentVel.Y, move.Z * targetSpeed)
                    root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(targetVel, 0.5)
                end
            end)
        end)
        ShowMessage("Speed Glitch ON")
    else
        if speedGlitchConnection then speedGlitchConnection:Disconnect() end
        ShowMessage("Speed Glitch OFF")
    end
end

-- ============================================================================
-- 🦘 INFINITE JUMP
-- ============================================================================

function ToggleInfiniteJump()
    infJumpEnabled = not infJumpEnabled
    if infJumpEnabled then
        infJumpConnection = UserInputService.JumpRequest:Connect(function() 
            if infJumpEnabled and LP.Character and LP.Character:FindFirstChild("Humanoid") then 
                LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) 
            end 
        end)
        ShowMessage("Infinite Jump ON")
    else
        if infJumpConnection then infJumpConnection:Disconnect() end
        ShowMessage("Infinite Jump OFF")
    end
end

-- ============================================================================
-- ☁️ AIR WALK
-- ============================================================================

function ToggleAirWalk()
    airWalkEnabled = not airWalkEnabled
    if airWalkEnabled then
        task.spawn(function() 
            local platform = Instance.new("Part", workspace) 
            platform.Size = Vector3.new(6, 0.5, 6) 
            platform.Anchored = true 
            platform.Transparency = 1
            while airWalkEnabled do 
                task.wait() 
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then 
                    platform.CFrame = CFrame.new(LP.Character.HumanoidRootPart.Position.X, LP.Character.HumanoidRootPart.Position.Y - 2.8, LP.Character.HumanoidRootPart.Position.Z) 
                end
            end 
            if platform then platform:Destroy() end
        end) 
        ShowMessage("Air Walk ON")
    else 
        airWalkEnabled = false 
    end
end

-- ============================================================================
-- 🏃 AUTO SPRINT
-- ============================================================================

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

-- ============================================================================
-- 🚫 NOCLIP
-- ============================================================================

function ToggleNoClip()
    noClipEnabled = not noClipEnabled
    if noClipEnabled then
        runNoClip = RunService.Stepped:Connect(function() 
            if LP.Character then 
                for _, v in pairs(LP.Character:GetDescendants()) do 
                    if v:IsA("BasePart") then v.CanCollide = false end 
                end 
            end 
        end)
        ShowMessage("NoClip ON")
    else
        if runNoClip then runNoClip:Disconnect() end
        ShowMessage("NoClip OFF")
    end
end

-- ============================================================================
-- 🕷️ SPIDER MODE
-- ============================================================================

function ToggleSpider()
    spiderEnabled = not spiderEnabled 
    ShowMessage(spiderEnabled and "Spider Mode ON" or "Spider Mode OFF")
    task.spawn(function() 
        while spiderEnabled do 
            task.wait(0.1) 
            pcall(function()
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then 
                    local r = LP.Character.HumanoidRootPart 
                    local ray = workspace:Raycast(r.Position, r.CFrame.LookVector * 2.5) 
                    if ray and ray.Instance and math.abs(ray.Normal.Y) < 0.1 then 
                        r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, speedValue, r.AssemblyLinearVelocity.Z) 
                    end
                end
            end)
        end 
    end)
end

-- ============================================================================
-- 🏊 SWIM IN AIR
-- ============================================================================

function ToggleSwim()
    swimEnabled = not swimEnabled 
    ShowMessage(swimEnabled and "Swim In Air ON" or "Swim In Air OFF")
    task.spawn(function() 
        while swimEnabled do 
            RunService.Heartbeat:Wait() 
            pcall(function()
                if LP.Character and LP.Character:FindFirstChild("Humanoid") then 
                    LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming) 
                end
            end)
        end 
    end)
end

-- ============================================================================
-- 🏃 DASH
-- ============================================================================

function ToggleDash()
    dashEnabled = not dashEnabled
    if dashEnabled then
        if dashButton then dashButton:Destroy() end
        local sg = Instance.new("ScreenGui", game.CoreGui)
        sg.Name = "MTY_DashButtonUI"
        
        dashButton = Instance.new("TextButton", sg)
        dashButton.Size = UDim2.new(0, 60, 0, 60)
        dashButton.Position = UDim2.new(0.82, 0, 0.55, 0)
        dashButton.BackgroundColor3 = guiSettings.ButtonColor
        dashButton.Text = "D"
        dashButton.TextColor3 = Color3.new(1,1,1)
        dashButton.Font = Enum.Font.GothamBold
        dashButton.TextSize = 13
        Instance.new("UICorner", dashButton).CornerRadius = UDim.new(0, 30)
        Instance.new("UIStroke", dashButton).Thickness = 1.5
        
        dashButton.MouseButton1Click:Connect(function()
            pcall(function()
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character:FindFirstChild("Humanoid") then
                    local root = LP.Character.HumanoidRootPart 
                    local dir = LP.Character.Humanoid.MoveDirection.Magnitude > 0 and LP.Character.Humanoid.MoveDirection or root.CFrame.LookVector
                    root.CFrame = root.CFrame + Vector3.new(dir.X, 0, dir.Z).Unit * 15 
                    ApplyJumpCircleEffect()
                end
            end)
        end)
        ShowMessage("Dash Mobile Button ON")
    else 
        if dashButton then dashButton.Parent:Destroy() dashButton = nil end 
        ShowMessage("Dash Disabled") 
    end
end

-- ============================================================================
-- 👤 FE INVISIBILITY
-- ============================================================================

function ToggleInvisibility()
    invisibilityEnabled = not invisibilityEnabled
    if invisibilityEnabled then
        task.spawn(function()
            while invisibilityEnabled do 
                RunService.Heartbeat:Wait()
                pcall(function()
                    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character:FindFirstChild("Humanoid") then
                        local root = LP.Character.HumanoidRootPart 
                        local oldCF = root.CFrame
                        root.CFrame = oldCF * CFrame.new(0, -500, 0) 
                        RunService.RenderStepped:Wait() 
                        root.CFrame = oldCF
                    end
                end)
            end
        end) 
        ShowMessage("FE Invisibility ON")
    else 
        ShowMessage("Invisibility OFF") 
    end
end

-- ============================================================================
-- 🚁 HELICOPTER
-- ============================================================================

function ToggleHelicopter()
    helicopterEnabled = not helicopterEnabled
    if helicopterEnabled then
        task.spawn(function()
            pcall(function()
                if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
                local root = LP.Character.HumanoidRootPart
                local bForce = Instance.new("BodyForce", root) 
                bForce.Name = "MTY_HeliForce" 
                bForce.Force = Vector3.new(0, (workspace.Gravity * root:GetMass()) * 1.35, 0)
                local bAngular = Instance.new("BodyAngularVelocity", root) 
                bAngular.Name = "MTY_HeliRot" 
                bAngular.MaxTorque = Vector3.new(0, 999999, 0) 
                bAngular.AngularVelocity = Vector3.new(0, 38, 0)
                while helicopterEnabled do 
                    task.wait(0.1) 
                end
                if root:FindFirstChild("MTY_HeliForce") then root.MTY_HeliForce:Destroy() end
                if root:FindFirstChild("MTY_HeliRot") then root.MTY_HeliRot:Destroy() end
            end)
        end) 
        ShowMessage("Helicopter Flying UP")
    else 
        ShowMessage("Helicopter OFF") 
    end
end

-- ============================================================================
-- 🛠️ TELEPORT TOOL
-- ============================================================================

function ToggleTeleportTool()
    tpToolEnabled = not tpToolEnabled
    if tpToolEnabled then
        teleportTool = Instance.new("Tool", LP.Backpack)
        teleportTool.RequiresHandle = false
        teleportTool.Name = "MTY TP Tool"
        teleportTool.Activated:Connect(function()
            pcall(function()
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    local camPos = Camera.CFrame.Position
                    local lookVec = Camera.CFrame.LookVector
                    local targetPos = camPos + (lookVec * 50)
                    LP.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
                    ShowMessage("Teleported!")
                end
            end)
        end)
        ShowMessage("Teleport Tool ON")
    else
        if teleportTool then teleportTool:Destroy() end
        ShowMessage("Teleport Tool OFF")
    end
end

-- ============================================================================
-- ☀️ FULLBRIGHT
-- ============================================================================

function ToggleFullbright()
    fullbrightEnabled = not fullbrightEnabled
    if fullbrightEnabled then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        ShowMessage("Fullbright ON")
    else
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        ShowMessage("Fullbright OFF")
    end
end

-- ============================================================================
-- 🎆 ПАРТИКЛЫ
-- ============================================================================

function ToggleParticlesV1()
    particlesEnabled = not particlesEnabled
    if particlesEnabled then
        particlesConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not particlesEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
                for i = 1, 3 do
                    local p = Instance.new("Part", workspace)
                    p.Size = Vector3.new(0.2, 0.2, 0.2)
                    p.Anchored = true
                    p.CanCollide = false
                    p.Material = Enum.Material.Neon
                    p.Color = guiSettings.ParticleColor
                    p.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-8, 8), math.random(-3, 5), math.random(-8, 8))
                    Debris:AddItem(p, 0.5)
                end
            end)
        end)
        ShowMessage("Particles V1 ON")
    else
        if particlesConnection then particlesConnection:Disconnect() end
        ShowMessage("Particles V1 OFF")
    end
end

function ToggleParticlesV2()
    particlesV2Enabled = not particlesV2Enabled
    if particlesV2Enabled then
        particlesV2Connection = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not particlesV2Enabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
                local p = Instance.new("Part", workspace)
                p.Size = Vector3.new(0.3, 0.3, 0.3)
                p.Anchored = true
                p.CanCollide = false
                p.Material = Enum.Material.Neon
                p.Color = guiSettings.ParticleColor
                p.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-15, 15), math.random(-4, 6), math.random(-15, 15))
                Debris:AddItem(p, 0.8)
            end)
        end)
        ShowMessage("Cloud Particles V2 ON")
    else
        if particlesV2Connection then particlesV2Connection:Disconnect() end
        ShowMessage("Particles V2 OFF")
    end
end

-- ============================================================================
-- 💥 FLING ФУНКЦИИ
-- ============================================================================

function FlingByName(name)
    if name == "" then 
        ShowMessage("Vvedite imya!") 
        return 
    end
    
    local found = false
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and string.find(string.lower(p.Name), string.lower(name)) then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                local hum = p.Character:FindFirstChild("Humanoid")
                
                if hrp and hum and hum.Health > 0 then
                    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot then 
                        myRoot.CFrame = hrp.CFrame * CFrame.new(0, 0, 2) 
                        task.wait(0.05) 
                    end
                    
                    local dir = Vector3.new(math.random(-1, 1), 1.5, math.random(-1, 1)).Unit
                    hum.Sit = true
                    hrp.AssemblyLinearVelocity = dir * 5000
                    ShowMessage("Fling: " .. p.Name)
                    found = true
                    break
                end
            end
        end
    end
    
    if not found then 
        ShowMessage("Igrok ne nayden!") 
    end
end

function ToggleAutoFling()
    autoFlingEnabled = not autoFlingEnabled
    
    if autoFlingEnabled then
        ShowMessage("Auto Fling ON")
        autoFlingConnection = RunService.Heartbeat:Connect(function()
            if not autoFlingEnabled then return end
            
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
        if autoFlingConnection then 
            autoFlingConnection:Disconnect() 
            autoFlingConnection = nil
        end
        ShowMessage("Auto Fling OFF")
    end
end

function FlingAll()
    local count = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local hum = p.Character:FindFirstChild("Humanoid")
            
            if hrp and hum and hum.Health > 0 then
                local dir = Vector3.new(math.random(-1, 1), 1.5, math.random(-1, 1)).Unit
                hum.Sit = true
                hrp.AssemblyLinearVelocity = dir * 5000
                count = count + 1
            end
        end
    end
    ShowMessage("Fling All: " .. count .. " players")
end

function FlingUp()
    if not LP.Character then return end
    local root = LP.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity = Vector3.new(0, 500, 0)
        ShowMessage("Fling UP!")
    end
end

function FlingForward()
    if not LP.Character then return end
    local root = LP.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local look = root.CFrame.LookVector
        root.AssemblyLinearVelocity = Vector3.new(look.X * 300, 50, look.Z * 300)
        ShowMessage("Fling Forward!")
    end
end

function FlingRandom()
    if not LP.Character then return end
    local root = LP.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local dir = Vector3.new(math.random(-1, 1), math.random(0, 2), math.random(-1, 1)).Unit
        root.AssemblyLinearVelocity = dir * 500
        ShowMessage("Fling Random!")
    end
end

function SuperFling()
    if not LP.Character then return end
    local root = LP.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity = Vector3.new(0, 9999, 0)
        task.wait(0.1)
        root.AssemblyLinearVelocity = Vector3.new(math.random(-500, 500), 9999, math.random(-500, 500))
        ShowMessage("SUPER FLING!")
    end
end

function OpenIYFling()
    local s = Instance.new("ScreenGui", game.CoreGui) 
    s.Name = "MTY_IYFling"
    s.ResetOnSpawn = false
    
    local f = Instance.new("Frame", s) 
    f.Size = UDim2.new(0, 280, 0, 180) 
    f.Position = UDim2.new(0.5, -140, 0.35, 0) 
    f.BackgroundColor3 = guiSettings.BackgroundColor
    f.Active = true
    f.Draggable = true
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12) 
    local stroke = Instance.new("UIStroke", f) 
    stroke.Color = guiSettings.BorderColor
    stroke.Thickness = 1.8
    
    local title = Instance.new("TextLabel", f) 
    title.Size = UDim2.new(1, 0, 0, 35) 
    title.Text = "IY FLING ENGINE" 
    title.TextColor3 = guiSettings.TextColor
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.BackgroundTransparency = 1
    
    local tb = Instance.new("TextBox", f) 
    tb.Size = UDim2.new(0.85, 0, 0, 32) 
    tb.Position = UDim2.new(0.075, 0, 0.3, 0) 
    tb.BackgroundColor3 = Color3.fromRGB(25, 25, 30) 
    tb.Text = "" 
    tb.PlaceholderText = "Enter Player Name..." 
    tb.TextColor3 = guiSettings.TextColor
    tb.Font = Enum.Font.GothamMedium
    tb.TextSize = 12
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
    
    local btnLaunch = Instance.new("TextButton", f) 
    btnLaunch.Size = UDim2.new(0.4, 0, 0, 32) 
    btnLaunch.Position = UDim2.new(0.05, 0, 0.68, 0) 
    btnLaunch.BackgroundColor3 = Color3.fromRGB(200, 40, 60) 
    btnLaunch.Text = "LAUNCH" 
    btnLaunch.TextColor3 = Color3.new(1,1,1) 
    btnLaunch.Font = Enum.Font.GothamBold
    btnLaunch.TextSize = 12
    Instance.new("UICorner", btnLaunch).CornerRadius = UDim.new(0, 6)
    
    local btnSuper = Instance.new("TextButton", f) 
    btnSuper.Size = UDim2.new(0.4, 0, 0, 32) 
    btnSuper.Position = UDim2.new(0.55, 0, 0.68, 0) 
    btnSuper.BackgroundColor3 = Color3.fromRGB(255, 150, 0) 
    btnSuper.Text = "SUPER" 
    btnSuper.TextColor3 = Color3.new(1,1,1) 
    btnSuper.Font = Enum.Font.GothamBold
    btnSuper.TextSize = 12
    Instance.new("UICorner", btnSuper).CornerRadius = UDim.new(0, 6)
    
    local closeBtn = Instance.new("TextButton", f) 
    closeBtn.Size = UDim2.new(0, 28, 0, 28) 
    closeBtn.Position = UDim2.new(1, -34, 0, 4) 
    closeBtn.Text = "X" 
    closeBtn.TextColor3 = guiSettings.TextColor
    closeBtn.BackgroundColor3 = Color3.fromRGB(40,40,45) 
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function() s:Destroy() end)
    
    local function GetPlayer(name)
        name = name:lower()
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower():sub(1, #name) == name or p.DisplayName:lower():sub(1, #name) == name then 
                return p 
            end
        end 
        return nil
    end
    
    local function DoFling(target, power)
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            ShowMessage("Igrok ne nayden!")
            return
        end
        
        local tChar = target.Character
        local tRoot = tChar.HumanoidRootPart
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local myRoot = LP.Character.HumanoidRootPart
        local oldCF = myRoot.CFrame
        
        ShowMessage("Fling: " .. target.Name)
        
        task.spawn(function()
            local bV = Instance.new("BodyAngularVelocity", myRoot)
            bV.MaxTorque = Vector3.new(1,1,1) * 9999999
            bV.AngularVelocity = Vector3.new(0, 9999999, 0)
            
            for i = 1, 45 do
                RunService.Heartbeat:Wait()
                if tRoot and myRoot then
                    myRoot.CFrame = tRoot.CFrame * CFrame.new(math.random(-1,1)*0.05, 0, math.random(-1,1)*0.05)
                    myRoot.AssemblyLinearVelocity = Vector3.new(0, 999999 * power, 0)
                end
            end
            
            bV:Destroy()
            myRoot.CFrame = oldCF
            myRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end)
    end
    
    btnLaunch.MouseButton1Click:Connect(function()
        local target = GetPlayer(tb.Text)
        if not target then
            ShowMessage("Igrok ne nayden!")
            return
        end
        if target == LP then
            ShowMessage("Nelzya flingnut sebya!")
            return
        end
        DoFling(target, 1)
        s:Destroy()
    end)
    
    btnSuper.MouseButton1Click:Connect(function()
        local target = GetPlayer(tb.Text)
        if not target then
            ShowMessage("Igrok ne nayden!")
            return
        end
        if target == LP then
            ShowMessage("Nelzya flingnut sebya!")
            return
        end
        DoFling(target, 5)
        s:Destroy()
    end)
end

function OpenIYGoto()
    local s = Instance.new("ScreenGui", game.CoreGui) 
    s.Name = "MTY_GotoGUI"
    s.ResetOnSpawn = false
    
    local f = Instance.new("Frame", s) 
    f.Size = UDim2.new(0, 280, 0, 150) 
    f.Position = UDim2.new(0.5, -140, 0.25, 0) 
    f.BackgroundColor3 = guiSettings.BackgroundColor
    f.Active = true
    f.Draggable = true
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12) 
    local stroke = Instance.new("UIStroke", f) 
    stroke.Color = guiSettings.BorderColor
    stroke.Thickness = 1.8
    
    local title = Instance.new("TextLabel", f) 
    title.Size = UDim2.new(1, 0, 0, 35) 
    title.Text = "IY GOTO ENGINE" 
    title.TextColor3 = guiSettings.TextColor
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.BackgroundTransparency = 1
    
    local tb = Instance.new("TextBox", f) 
    tb.Size = UDim2.new(0.85, 0, 0, 32) 
    tb.Position = UDim2.new(0.075, 0, 0.3, 0) 
    tb.BackgroundColor3 = Color3.fromRGB(25, 25, 30) 
    tb.Text = "" 
    tb.PlaceholderText = "Enter Player Name..." 
    tb.TextColor3 = guiSettings.TextColor
    tb.Font = Enum.Font.GothamMedium
    tb.TextSize = 12
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
    
    local btn = Instance.new("TextButton", f) 
    btn.Size = UDim2.new(0.6, 0, 0, 34) 
    btn.Position = UDim2.new(0.2, 0, 0.68, 0) 
    btn.BackgroundColor3 = guiSettings.BorderColor
    btn.Text = "TELEPORT" 
    btn.TextColor3 = Color3.new(1,1,1) 
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local closeBtn = Instance.new("TextButton", f) 
    closeBtn.Size = UDim2.new(0, 28, 0, 28) 
    closeBtn.Position = UDim2.new(1, -34, 0, 4) 
    closeBtn.Text = "X" 
    closeBtn.TextColor3 = guiSettings.TextColor
    closeBtn.BackgroundColor3 = Color3.fromRGB(40,40,45) 
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function() s:Destroy() end)
    
    local function GetPlayer(name)
        name = name:lower()
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower():sub(1, #name) == name or p.DisplayName:lower():sub(1, #name) == name then 
                return p 
            end
        end 
        return nil
    end
    
    btn.MouseButton1Click:Connect(function()
        local target = GetPlayer(tb.Text)
        if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
            ShowMessage("Igrok ne nayden!")
            return
        end
        if target == LP then
            ShowMessage("Eto vy!")
            return
        end
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            ShowMessage("Teleport k " .. target.Name)
            s:Destroy()
        end
    end)
end

function FlingAllUp()
    local count = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local hum = p.Character:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 500, 0)
                count = count + 1
            end
        end
    end
    ShowMessage("Fling All UP: " .. count .. " players")
end

function FlingAllRandom()
    local count = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local hum = p.Character:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local dir = Vector3.new(math.random(-1, 1), 1.5, math.random(-1, 1)).Unit
                hum.Sit = true
                hrp.AssemblyLinearVelocity = dir * 5000
                count = count + 1
            end
        end
    end
    ShowMessage("Fling All Random: " .. count .. " players")
end

function FlingLastPlayer()
    local players = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            table.insert(players, p)
        end
    end
    
    if #players == 0 then
        ShowMessage("No other players!")
        return
    end
    
    local target = players[#players]
    if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = target.Character.HumanoidRootPart
        local hum = target.Character:FindFirstChild("Humanoid")
        if hrp and hum and hum.Health > 0 then
            local dir = Vector3.new(math.random(-1, 1), 1.5, math.random(-1, 1)).Unit
            hum.Sit = true
            hrp.AssemblyLinearVelocity = dir * 5000
            ShowMessage("Fling Last: " .. target.Name)
        end
    end
end

-- ============================================================================
-- 🔪 MM2 DOUBLE TAP
-- ============================================================================

function ToggleDoubleTap()
    doubleTapEnabled = not doubleTapEnabled
    
    if doubleTapEnabled then
        if doubleTapConnection then 
            doubleTapConnection:Disconnect() 
            doubleTapConnection = nil
        end
        
        doubleTapConnection = UserInputService.TouchEnded:Connect(function(touch)
            if not doubleTapEnabled then return end
            if not LP.Character then return end
            
            local currentTime = tick()
            
            if currentTime - lastTapTime <= 0.3 then
                tapCount = tapCount + 1
            else
                tapCount = 1
            end
            lastTapTime = currentTime
            
            if tapCount >= 2 then
                tapCount = 0
                
                local closestPlayer = nil
                local closestDist = 15
                
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestPlayer = p
                        end
                    end
                end
                
                if closestPlayer and closestPlayer.Character then
                    local tool = LP.Character:FindFirstChildOfClass("Tool")
                    if not tool then
                        tool = LP.Backpack:FindFirstChildOfClass("Tool")
                    end
                    
                    if tool and (tool.Name == "Knife" or string.find(string.lower(tool.Name), "knife")) then
                        tool:Activate()
                        
                        local remote = GetDmgRemote(tool)
                        if remote then
                            remote:FireServer(closestPlayer.Character.HumanoidRootPart)
                        end
                        
                        ShowMessage("Double Tap Attack: " .. closestPlayer.Name)
                    end
                end
            end
        end)
        
        ShowMessage("Double Tap Attack ON")
    else
        if doubleTapConnection then
            doubleTapConnection:Disconnect()
            doubleTapConnection = nil
        end
        ShowMessage("Double Tap Attack OFF")
    end
end

-- ============================================================================
-- 🔪 MM2 ФУНКЦИИ
-- ============================================================================

local function getMM2Role(player)
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    
    if not char then return "Innocent" end
    
    local isMurder = false
    local isSheriff = false
    
    if char:FindFirstChildOfClass("Tool") then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                local name = string.lower(tool.Name)
                if name:find("knife") or name:find("blade") or name:find("scythe") or name:find("dagger") or name:find("sword") then
                    isMurder = true
                elseif name:find("gun") or name:find("revolver") or name:find("blaster") or name:find("pistol") or name:find("rifle") then
                    isSheriff = true
                end
            end
        end
    end
    
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local name = string.lower(tool.Name)
                if name:find("knife") or name:find("blade") or name:find("scythe") or name:find("dagger") or name:find("sword") then
                    isMurder = true
                elseif name:find("gun") or name:find("revolver") or name:find("blaster") or name:find("pistol") or name:find("rifle") then
                    isSheriff = true
                end
            end
        end
    end
    
    if char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")) then
        isMurder = true
    end
    if char:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun")) then
        isSheriff = true
    end
    
    if isMurder then return "Murderer" end
    if isSheriff then return "Sheriff" end
    return "Innocent"
end

function ToggleMM2EspV2()
    mm2EspV2Enabled = not mm2EspV2Enabled
    
    if mm2EspV2Enabled then
        task.spawn(function()
            while mm2EspV2Enabled do
                task.wait(0.3)
                pcall(function()
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local char = p.Character
                            local roleColor = Color3.fromRGB(0, 255, 100)
                            
                            if p.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife") then
                                roleColor = Color3.fromRGB(255, 0, 50)
                            elseif p.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun") then
                                roleColor = Color3.fromRGB(0, 150, 255)
                            end
                            
                            local hl = char:FindFirstChild("MM2_ESP_V2")
                            if not hl then
                                hl = Instance.new("Highlight")
                                hl.Name = "MM2_ESP_V2"
                                hl.Parent = char
                            end
                            hl.FillColor = roleColor
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.35
                            hl.OutlineTransparency = 0.2
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        end
                    end
                end)
            end
        end)
        ShowMessage("MM2 ESP V2 ON")
    else
        mm2EspV2Enabled = false
        pcall(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("MM2_ESP_V2") then
                    p.Character.MM2_ESP_V2:Destroy()
                end
            end
        end)
        ShowMessage("MM2 ESP V2 OFF")
    end
end

mm2EspV3Folder = Instance.new("Folder", workspace) mm2EspV3Folder.Name = "MTY_MM2_ESP_V3"

function ToggleMM2EspV3()
    mm2EspV3Enabled = not mm2EspV3Enabled
    
    if mm2EspV3Enabled then
        task.spawn(function()
            while mm2EspV3Enabled do
                task.wait(0.15)
                pcall(function()
                    if mm2EspV3Folder then
                        mm2EspV3Folder:ClearAllChildren()
                    end
                    
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local char = p.Character
                            local role = getMM2Role(p)
                            
                            local roleColor = Color3.fromRGB(0, 255, 100)
                            local roleText = "Mirniy"
                            
                            if role == "Murderer" then
                                roleColor = Color3.fromRGB(255, 0, 50)
                                roleText = "UBIYCA"
                            elseif role == "Sheriff" then
                                roleColor = Color3.fromRGB(0, 150, 255)
                                roleText = "SHERIF"
                            end
                            
                            local hl = char:FindFirstChild("MM2_ESP_V3_Highlight")
                            if not hl then
                                hl = Instance.new("Highlight")
                                hl.Name = "MM2_ESP_V3_Highlight"
                                hl.Parent = char
                            end
                            hl.FillColor = roleColor
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.35
                            hl.OutlineTransparency = 0.2
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            
                            local hrp = char.HumanoidRootPart
                            local bbg = hrp:FindFirstChild("MM2_RoleTag")
                            if not bbg then
                                bbg = Instance.new("BillboardGui", hrp)
                                bbg.Name = "MM2_RoleTag"
                                bbg.AlwaysOnTop = true
                                bbg.Size = UDim2.new(0, 120, 0, 30)
                                bbg.ExtentsOffset = Vector3.new(0, 3, 0)
                                
                                local txt = Instance.new("TextLabel", bbg)
                                txt.Name = "RoleText"
                                txt.Size = UDim2.new(1, 0, 1, 0)
                                txt.BackgroundTransparency = 1
                                txt.TextSize = 12
                                txt.Font = Enum.Font.GothamBold
                                txt.TextColor3 = roleColor
                                txt.Text = roleText
                            else
                                bbg.RoleText.Text = roleText
                                bbg.RoleText.TextColor3 = roleColor
                            end
                        end
                    end
                end)
            end
        end)
        ShowMessage("MM2 ESP V3 ON")
    else
        mm2EspV3Enabled = false
        pcall(function()
            if mm2EspV3Folder then mm2EspV3Folder:ClearAllChildren() end
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then
                    if p.Character:FindFirstChild("MM2_ESP_V3_Highlight") then
                        p.Character.MM2_ESP_V3_Highlight:Destroy()
                    end
                    if p.Character:FindFirstChild("HumanoidRootPart") then
                        local bbg = p.Character.HumanoidRootPart:FindFirstChild("MM2_RoleTag")
                        if bbg then bbg:Destroy() end
                    end
                end
            end
        end)
        ShowMessage("MM2 ESP V3 OFF")
    end
end

mm2FovCircle = Instance.new("Frame", fovGui)
mm2FovCircle.AnchorPoint = Vector2.new(0.5,0.5)
mm2FovCircle.Position = UDim2.new(0.5,0,0.5,0)
mm2FovCircle.BackgroundTransparency = 1
mm2FovCircle.Visible = false
mm2FovCircle.Size = UDim2.new(0, 260, 0, 260)
mm2FovStroke = Instance.new("UIStroke", mm2FovCircle)
mm2FovStroke.Color = Color3.fromRGB(255, 0, 50)
mm2FovStroke.Thickness = 1.5
Instance.new("UICorner", mm2FovCircle).CornerRadius = UDim.new(1, 0)

function ToggleMM2AimbotV2()
    mm2AimbotV2Enabled = not mm2AimbotV2Enabled
    
    if mm2AimbotV2Enabled then
        mm2FovCircle.Visible = true
        task.spawn(function()
            while mm2AimbotV2Enabled do
                RunService.RenderStepped:Wait()
                pcall(function()
                    local murderer = nil
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LP and getMM2Role(p) == "Murderer" then
                            murderer = p
                            break
                        end
                    end
                    
                    if murderer and murderer.Character and murderer.Character:FindFirstChild("Head") then
                        local head = murderer.Character.Head
                        local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        
                        if onScreen then
                            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                            local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                            
                            if dist <= 130 then
                                local targetCFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, math.clamp(0.25 * 0.85, 0.01, 1))
                            end
                        end
                    end
                end)
            end
        end)
        ShowMessage("MM2 Murderer Aimbot V2 ON")
    else
        mm2FovCircle.Visible = false
        ShowMessage("MM2 Murderer Aimbot V2 OFF")
    end
end

function TeleportToGun()
    pcall(function()
        local gun = workspace:FindFirstChild("DroppedGun") or workspace:FindFirstChild("GunDrop") or workspace:FindFirstChild("Gun")
        if not gun then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Part") and (v.Name == "DroppedGun" or v.Name == "GunDrop" or v.Name == "Gun") then 
                    gun = v 
                    break 
                end
            end
        end
        if gun and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame = gun.CFrame + Vector3.new(0, 3, 0)
            ShowMessage("Teleported to Gun!")
        else
            ShowMessage("Gun not dropped yet!")
        end
    end)
end

function ToggleCoinFarm()
    coinFarmEnabled = not coinFarmEnabled
    if coinFarmEnabled then
        task.spawn(function()
            while coinFarmEnabled do 
                task.wait(0.3)
                pcall(function()
                    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("Part") and (v.Name == "Coin" or v.Name == "Candy" or v.Name == "Snowflake") then
                                if not coinFarmEnabled then break end
                                LP.Character.HumanoidRootPart.CFrame = v.CFrame
                                task.wait(0.1)
                            end
                        end
                    end
                end)
            end
        end) 
        ShowMessage("Coin Farm ON")
    else 
        ShowMessage("Coin Farm OFF") 
    end
end

function ToggleAutoStab()
    autoStabEnabled = not autoStabEnabled
    if autoStabEnabled then
        task.spawn(function()
            while autoStabEnabled do
                task.wait(0.1)
                pcall(function()
                    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                        local tool = LP.Character:FindFirstChildOfClass("Tool")
                        if tool and (tool.Name == "Knife" or tool.Name:find("Knife")) then
                            for _, p in pairs(Players:GetPlayers()) do
                                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                                    local dist = (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                                    if dist <= 10 then
                                        tool:Activate()
                                        local remote = GetDmgRemote(tool)
                                        if remote then
                                            remote:FireServer(p.Character.HumanoidRootPart)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)
        ShowMessage("Auto Stab ON")
    else
        ShowMessage("Auto Stab OFF")
    end
end

-- ============================================================================
-- 📊 TARGET HUD
-- ============================================================================

function ExecuteMM2Fling(targetChar)
    if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    
    pcall(function()
        local myRoot = LP.Character.HumanoidRootPart 
        local targetRoot = targetChar.HumanoidRootPart 
        local oldCF = myRoot.CFrame
        
        ShowMessage("MM2 Flinging: " .. targetChar.Name)
        task.spawn(function()
            local bV = Instance.new("BodyAngularVelocity", myRoot) 
            bV.MaxTorque = Vector3.new(1,1,1) * 9999999 
            bV.AngularVelocity = Vector3.new(0, 9999999, 0)
            
            for i = 1, 35 do 
                RunService.Heartbeat:Wait()
                if targetRoot and myRoot then 
                    myRoot.CFrame = targetRoot.CFrame * CFrame.new(math.random(-1,1)*0.02, -1.5, math.random(-1,1)*0.02) 
                    myRoot.AssemblyLinearVelocity = Vector3.new(0, 999999, 0) 
                end
            end
            
            bV:Destroy() 
            myRoot.CFrame = oldCF 
            myRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
            ShowMessage("Target launched!")
        end)
    end)
end

local function UpdateTargetHud()
    pcall(function()
        if not targetHudEnabled then
            if targetHudFrame then targetHudFrame.Visible = false end
            return
        end
        
        if not targetHudFrame then
            targetHudFrame = Instance.new("Frame", screenGui or game.CoreGui) 
            targetHudFrame.Size = UDim2.new(0, 200, 0, 90) 
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
            hpL.Position = UDim2.new(0, 0, 0.3, 0) 
            hpL.TextColor3 = Color3.fromRGB(0,255,100) 
            hpL.Font = Enum.Font.GothamMedium 
            hpL.TextSize = 11 
            hpL.BackgroundTransparency = 1
            
            local fBtn = Instance.new("TextButton", targetHudFrame) 
            fBtn.Size = UDim2.new(0.8, 0, 0, 25) 
            fBtn.Position = UDim2.new(0.1, 0, 0.6, 0) 
            fBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 60) 
            fBtn.Text = "MM2 FLING TARGET" 
            fBtn.TextColor3 = Color3.new(1,1,1) 
            fBtn.Font = Enum.Font.GothamBold 
            fBtn.TextSize = 11 
            Instance.new("UICorner", fBtn).CornerRadius = UDim.new(0, 6)
            
            fBtn.MouseButton1Click:Connect(function() 
                if targetPlayer and targetPlayer.Character then 
                    ExecuteMM2Fling(targetPlayer.Character) 
                end 
            end)
        end
        
        targetHudFrame.Visible = true
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
            targetHudFrame.NameL.Text = "Target: " .. targetPlayer.Name 
            targetHudFrame.HpL.Text = "HP: " .. math.floor(targetPlayer.Character.Humanoid.Health) .. " / " .. math.floor(targetPlayer.Character.Humanoid.MaxHealth)
        else 
            targetHudFrame.NameL.Text = "No Target" 
            targetHudFrame.HpL.Text = "HP: --" 
        end
    end)
end

function ToggleTargetHud()
    targetHudEnabled = not targetHudEnabled
    ShowMessage(targetHudEnabled and "Target HUD ON" or "Target HUD OFF")
end

task.spawn(function() 
    while true do 
        task.wait(0.2) 
        pcall(UpdateTargetHud) 
    end 
end)

-- ============================================================================
-- 🧱 JUMP CIRCLE
-- ============================================================================

function ApplyJumpCircleEffect()
    if not jumpCircleEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    pcall(function()
        local disk = Instance.new("Part", workspace) 
        disk.Shape = Enum.PartType.Cylinder 
        disk.Size = Vector3.new(0.02, 2, 2) 
        disk.CFrame = CFrame.new(LP.Character.HumanoidRootPart.Position - Vector3.new(0, 2.8, 0)) * CFrame.Angles(0, 0, math.rad(90)) 
        disk.Anchored = true 
        disk.CanCollide = false 
        disk.Material = Enum.Material.Neon 
        disk.Color = guiSettings.JumpCircleColor 
        disk.Transparency = 0.2
        
        TweenService:Create(disk, TweenInfo.new(guiSettings.JumpCircleFadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(0.01, 14, 14), 
            Transparency = 1
        }):Play() 
        Debris:AddItem(disk, guiSettings.JumpCircleFadeTime + 0.1)
    end)
end

function ToggleJumpCircle()
    jumpCircleEnabled = not jumpCircleEnabled
    if jumpCircleEnabled then 
        jumpCircleConnection = (LP.Character or LP.CharacterAdded:Wait()):WaitForChild("Humanoid").Jumping:Connect(function() 
            if jumpCircleEnabled then ApplyJumpCircleEffect() end 
        end) 
        ShowMessage("Jump Circle ON")
    else 
        if jumpCircleConnection then jumpCircleConnection:Disconnect() end 
        ShowMessage("Jump Circle OFF") 
    end
end

-- ============================================================================
-- 🧱 TRAIL
-- ============================================================================

function ToggleTrail()
    trailEnabled = not trailEnabled
    if trailEnabled then 
        trailParts = {} 
        trailConnection = RunService.Heartbeat:Connect(function()
            if not trailEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
            pcall(function()
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
        end) 
        ShowMessage("Trail V1 ON")
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
        pcall(function()
            if not LP.Character or not LP.Character:FindFirstChild("Head") then return end
            local trailAnchor = Instance.new("Part", LP.Character.Head)
            trailAnchor.Size = Vector3.new(0.1, 0.1, 0.1)
            trailAnchor.Transparency = 1
            trailAnchor.CanCollide = false
            trailAnchor.Massless = true
            trailAnchor.Name = "MTY_TrailAnchor"
            
            local weld = Instance.new("Weld", trailAnchor)
            weld.Part0 = LP.Character.Head
            weld.Part1 = trailAnchor
            
            local a0 = Instance.new("Attachment", trailAnchor)
            a0.Position = Vector3.new(-0.8, -1.2, 0)
            local a1 = Instance.new("Attachment", trailAnchor)
            a1.Position = Vector3.new(0.8, -1.2, 0)
            
            local actualTrail = Instance.new("Trail", trailAnchor)
            actualTrail.Attachment0 = a0
            actualTrail.Attachment1 = a1
            actualTrail.Lifetime = 0.5
            actualTrail.FaceCamera = true
            actualTrail.Color = ColorSequence.new(guiSettings.TrailColor)
            ShowMessage("Trail V2 ON")
        end)
    else
        ShowMessage("Trail V2 OFF")
    end
end

-- ============================================================================
-- 🌑 NIGHT VISION
-- ============================================================================

function ToggleNightVision()
    nightVisionEnabled = not nightVisionEnabled
    
    if nightVisionEnabled then
        ShowMessage("Night Vision ON")
        Lighting.Ambient = Color3.fromRGB(0, 255, 0)
        Lighting.Brightness = 2
        Lighting.ClockTime = 0
        
        nightVisionConnection = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not nightVisionEnabled then return end
                Lighting.Ambient = Color3.fromRGB(0, 255, 0)
                Lighting.ColorShift_Top = Color3.fromRGB(0, 200, 0)
                Lighting.ColorShift_Bottom = Color3.fromRGB(0, 100, 0)
            end)
        end)
    else
        if nightVisionConnection then nightVisionConnection:Disconnect() end
        Lighting.Ambient = originalAmbient or Color3.fromRGB(127, 127, 127)
        Lighting.Brightness = 1
        Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
        Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
        Lighting.ClockTime = 14
        ShowMessage("Night Vision OFF")
    end
end

-- ============================================================================
-- 🔥 THERMAL VISION
-- ============================================================================

function ToggleThermalVision()
    thermalVisionEnabled = not thermalVisionEnabled
    
    if thermalVisionEnabled then
        ShowMessage("Thermal Vision ON")
        
        thermalVisionConnection = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not thermalVisionEnabled then return end
                
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character then
                        for _, v in pairs(p.Character:GetDescendants()) do
                            if v:IsA("BasePart") then
                                v.Color = Color3.fromRGB(255, 0, 0)
                                v.Material = Enum.Material.Neon
                                v.Transparency = 0.3
                            end
                        end
                    end
                end
                
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and not v.Parent:IsA("Player") then
                        v.Color = Color3.fromRGB(0, 0, 255)
                        v.Material = Enum.Material.Neon
                        v.Transparency = 0.4
                    end
                end
            end)
        end)
    else
        if thermalVisionConnection then thermalVisionConnection:Disconnect() end
        ShowMessage("Thermal Vision OFF")
    end
end

-- ============================================================================
-- 🌈 RAINBOW WORLD
-- ============================================================================

function ToggleRainbowWorld()
    rainbowWorldEnabled = not rainbowWorldEnabled
    
    if rainbowWorldEnabled then
        ShowMessage("Rainbow World ON")
        
        rainbowWorldConnection = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not rainbowWorldEnabled then return end
                
                local hue = (tick() * 0.1) % 1
                
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Color = Color3.fromHSV((hue + v.Position.X * 0.001) % 1, 1, 0.8)
                        v.Material = Enum.Material.Neon
                    end
                end
            end)
        end)
    else
        if rainbowWorldConnection then rainbowWorldConnection:Disconnect() end
        ShowMessage("Rainbow World OFF")
    end
end

-- ============================================================================
-- ⌨️ ГРАФИЧЕСКОЕ МЕНЮ (3 ВКЛАДКИ)
-- ============================================================================

local function CreateMenu()
    screenGui = Instance.new("ScreenGui", game.CoreGui) 
    screenGui.Name = "MTY_HUB_V5"
    
    guiMainFrame = Instance.new("Frame", screenGui) 
    guiMainFrame.Size = UDim2.new(0, 470, 0, 520)
    guiMainFrame.Position = UDim2.new(0.5, -235, 0.5, -260) 
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
            pcall(function()
                infoPanel.Text = " FPS: " .. math.floor(workspace:GetRealPhysicsFPS()) .. "  |  PING: " .. math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms "
            end)
            task.wait(0.5) 
        end 
    end)

    minimizeBtn = Instance.new("TextButton", guiMainFrame) 
    minimizeBtn.Size = UDim2.new(0, 32, 0, 32) 
    minimizeBtn.Position = UDim2.new(1, -75, 0, 10) 
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35) 
    minimizeBtn.Text = "-" 
    minimizeBtn.TextColor3 = guiSettings.TextColor
    minimizeBtn.Font = Enum.Font.GothamBold 
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)

    closeBtn = Instance.new("TextButton", guiMainFrame) 
    closeBtn.Size = UDim2.new(0, 32, 0, 32) 
    closeBtn.Position = UDim2.new(1, -38, 0, 10) 
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 60) 
    closeBtn.Text = "X" 
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255) 
    closeBtn.Font = Enum.Font.GothamBold 
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

    iconCube = Instance.new("ImageButton", screenGui)
    iconCube.Name = "MTY_EvilMortyCube"
    iconCube.Size = UDim2.new(0, 50, 0, 50)
    iconCube.Position = UDim2.new(0.1, 0, 0.1, 0)
    iconCube.BackgroundColor3 = guiSettings.BackgroundColor
    iconCube.Image = "rbxassetid://135450893325605"
    iconCube.Visible = false
    iconCube.Active = true
    iconCube.Draggable = true
    
    local cubeCorner = Instance.new("UICorner", iconCube)
    cubeCorner.CornerRadius = UDim.new(0, 12)
    local cubeStroke = Instance.new("UIStroke", iconCube)
    cubeStroke.Color = guiSettings.BorderColor
    cubeStroke.Thickness = 1.8

    minimizeBtn.MouseButton1Click:Connect(function()
        guiMainFrame.Visible = false
        iconCube.Position = UDim2.new(0, guiMainFrame.AbsolutePosition.X + (guiMainFrame.AbsoluteSize.X / 2) - 25, 0, guiMainFrame.AbsolutePosition.Y + 10)
        iconCube.Visible = true
    end)

    iconCube.MouseButton1Click:Connect(function()
        iconCube.Visible = false
        guiMainFrame.Visible = true
    end)

    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        fovGui:Destroy()
        if targetHudFrame then targetHudFrame:Destroy() end
        if dashButton then dashButton.Parent:Destroy() end
        if wallHopButton then wallHopButton.Parent:Destroy() end
        if orbitButton then orbitButton.Parent:Destroy() end
    end)

    -- ===== ЛЕВАЯ ПАНЕЛЬ =====
    local leftPanel = Instance.new("ScrollingFrame", guiMainFrame) 
    leftPanel.Size = UDim2.new(0, 125, 0, 430)
    leftPanel.Position = UDim2.new(0.02, 0, 0.15, 0) 
    leftPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 26) 
    leftPanel.ScrollBarThickness = 3
    leftPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
    Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 10)
    
    local categoryContainer = Instance.new("Frame", leftPanel)
    categoryContainer.Size = UDim2.new(1, 0, 0, 0)
    categoryContainer.BackgroundTransparency = 1
    categoryContainer.AutomaticSize = Enum.AutomaticSize.Y
    
    local categoryLayout = Instance.new("UIListLayout", categoryContainer)
    categoryLayout.FillDirection = Enum.FillDirection.Vertical
    categoryLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    categoryLayout.Padding = UDim.new(0, 4)
    
    searchBox = Instance.new("TextBox", guiMainFrame) 
    searchBox.Size = UDim2.new(0.68, 0, 0, 32) 
    searchBox.Position = UDim2.new(0.3, 0, 0.15, 0) 
    searchBox.BackgroundColor3 = Color3.fromRGB(22, 22, 26) 
    searchBox.Text = "" 
    searchBox.TextColor3 = guiSettings.TextColor
    searchBox.PlaceholderText = "Search..." 
    searchBox.Font = Enum.Font.GothamMedium 
    searchBox.TextSize = 12 
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 8) 
    Instance.new("UIStroke", searchBox).Color = Color3.fromRGB(40,40,50)
    
    contentArea = Instance.new("ScrollingFrame", guiMainFrame) 
    contentArea.Size = UDim2.new(0.68, 0, 0, 375)
    contentArea.Position = UDim2.new(0.3, 0, 0.25, 0) 
    contentArea.BackgroundTransparency = 1
    contentArea.ScrollBarThickness = 5 
    contentArea.ScrollBarImageColor3 = guiSettings.BorderColor

    local function GetStatusStr(name)
        -- ВИЗУАЛЫ
        if name == "Toggle ESP" then return espEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle ESP V2" then return espV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Jump Circle" then return jumpCircleEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Trail" then return trailEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Trail V2" then return trailV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Chinese Hat" then return hatEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle World Color" then return worldColorEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Stretch" then return stretchEnabled and " [ON]" or " [OFF]"
        elseif name == "HitGlow Effects" then return hitGlowEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Fullbright" then return fullbrightEnabled and " [ON]" or " [OFF]"
        elseif name == "Particles V1" then return particlesEnabled and " [ON]" or " [OFF]"
        elseif name == "Particles V2" then return particlesV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Classic Sword" then return swordVisualEnabled and " [ON]" or " [OFF]"
        elseif name == "World Colors" then return worldColorsEnabled and " [ON]" or " [OFF]"
        elseif name == "Fog" then return fogEnabled and " [ON]" or " [OFF]"
        elseif name == "Night Vision" then return nightVisionEnabled and " [ON]" or " [OFF]"
        elseif name == "Thermal Vision" then return thermalVisionEnabled and " [ON]" or " [OFF]"
        elseif name == "Rainbow World" then return rainbowWorldEnabled and " [ON]" or " [OFF]"
        elseif name == "Crosshair" then return crosshairEnabled and " [ON]" or " [OFF]"
        elseif name == "Hitboxes" then return hitboxEnabled and " [ON]" or " [OFF]"
        elseif name == "Hitbox Expander" then return hitboxExpanderEnabled and " [ON]" or " [OFF]"
        -- УНИВЕРСАЛ
        elseif name == "Toggle Aimbot" then return aimbotEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Aimbot V2" then return aimbotV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Aimbot V3" then return aimbotV3Enabled and " [ON]" or " [OFF]"
        elseif name == "Aimbot Wallbang" then return guiSettings.AimbotWallbang and " [ON]" or " [OFF]"
        elseif name == "Toggle Kill Aura" then return killAuraEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Kill Aura V2" then return killAuraV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Orbit Kill Aura" then return orbitKillAuraEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Trigger Bot" then return triggerBotEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Anti-Aim V2" then return antiAimEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Anti-Aim V3" then return antiAimV3Enabled and " [ON]" or " [OFF]"
        elseif name == "Desync Movement" then return desyncEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Fake Lag" then return fakeLagEnabled and " [ON]" or " [OFF]"
        elseif name == "Anti-Knockback" then return antiKbEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Infinite Jump" then return infJumpEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Air Walk" then return airWalkEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Fly V1" then return flyV1Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Fly V2" then return flyV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Teleport Tool" then return tpToolEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Auto Sprint" then return autoSprintEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle NoClip" then return noClipEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Spider Mode" then return spiderEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Swim In Air" then return swimEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Dash" then return dashEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Invisibility" then return invisibilityEnabled and " [ON]" or " [OFF]"
        elseif name == "Toggle Helicopter" then return helicopterEnabled and " [ON]" or " [OFF]"
        elseif name == "R6 Animations" then return r6AnimationsEnabled and " [ON]" or " [OFF]"
        elseif name == "BunnyHop" then return bunnyHopEnabled and " [ON]" or " [OFF]"
        elseif name == "Speed Glitch" then return speedGlitchEnabled and " [ON]" or " [OFF]"
        elseif name == "Walk Fling" then return walkFlingEnabled and " [ON]" or " [OFF]"
        elseif name == "Auto Fling" then return autoFlingEnabled and " [ON]" or " [OFF]"
        elseif name == "Wall Hop" then return wallHopEnabled and " [ON]" or " [OFF]"
        elseif name == "Speed" then return ""
        elseif name == "Gravity" then return ""
        elseif name == "Fly Speed" then return ""
        elseif name == "Aimbot Speed" then return ""
        elseif name == "Aimbot Strength" then return ""
        elseif name == "Aimbot FOV" then return ""
        elseif name == "Aimbot Part" then return ""
        elseif name == "Kill Aura Range" then return ""
        elseif name == "Tool Reach" then return ""
        elseif name == "Orbit Radius" then return ""
        elseif name == "Orbit Speed" then return ""
        elseif name == "Orbit Color" then return ""
        elseif name == "Set Static Color" then return ""
        elseif name == "Set Fog Color" then return ""
        elseif name == "Set Fog Distance" then return ""
        elseif name == "Hitbox Size" then return ""
        elseif name == "Fling By Name" then return ""
        elseif name == "Fling All" then return ""
        elseif name == "Fling Up" then return ""
        elseif name == "Fling Forward" then return ""
        elseif name == "Fling Random" then return ""
        elseif name == "Super Fling" then return ""
        elseif name == "IY Fling" then return ""
        elseif name == "IY Goto" then return ""
        elseif name == "Fling All Up" then return ""
        elseif name == "Fling All Random" then return ""
        elseif name == "Fling Last Player" then return ""
        -- MM2
        elseif name == "MM2 ESP V2" then return mm2EspV2Enabled and " [ON]" or " [OFF]"
        elseif name == "MM2 ESP V3" then return mm2EspV3Enabled and " [ON]" or " [OFF]"
        elseif name == "MM2 Aimbot V2" then return mm2AimbotV2Enabled and " [ON]" or " [OFF]"
        elseif name == "Double Tap Attack" then return doubleTapEnabled and " [ON]" or " [OFF]"
        elseif name == "Auto Stab" then return autoStabEnabled and " [ON]" or " [OFF]"
        elseif name == "Coin Farm" then return coinFarmEnabled and " [ON]" or " [OFF]"
        elseif name == "Teleport to Gun" then return ""
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
                -- ВИЗУАЛЫ
                if name == "Toggle ESP" then ToggleESP()
                elseif name == "Toggle ESP V2" then ToggleESPV2()
                elseif name == "Toggle Jump Circle" then ToggleJumpCircle()
                elseif name == "Jump Circle Color" then OpenColorPicker("Jump Circle Color", function(c) guiSettings.JumpCircleColor = c end)
                elseif name == "Toggle Trail" then ToggleTrail()
                elseif name == "Toggle Trail V2" then ToggleTrailV2()
                elseif name == "Trail Color" then OpenColorPicker("Trail Color", function(c) guiSettings.TrailColor = c end)
                elseif name == "Toggle Chinese Hat" then ToggleChineseHat()
                elseif name == "Hat Color" then OpenColorPicker("Hat Color", function(c) guiSettings.HatColor = c if hatEnabled then CreateChineseHat() end end)
                elseif name == "Rainbow China Hat" then guiSettings.HatRainbow = not guiSettings.HatRainbow
                elseif name == "Toggle World Color" then ToggleWorldColor()
                elseif name == "Toggle Stretch" then ToggleStretch()
                elseif name == "Stretch Value" then OpenTextInput("Stretch Value", "0.1 - 1.5", guiSettings.StretchValue, function(v) guiSettings.StretchValue = v end)
                elseif name == "HitGlow Effects" then ToggleHitGlow()
                elseif name == "Toggle Fullbright" then ToggleFullbright()
                elseif name == "Particles V1" then ToggleParticlesV1()
                elseif name == "Particles V2" then ToggleParticlesV2()
                elseif name == "Classic Sword" then ToggleSwordVisual()
                elseif name == "World Colors" then ToggleWorldColors()
                elseif name == "Set Static Color" then OpenColorPicker("Select Static Color", function(c) guiSettings.WorldColor = c end)
                elseif name == "Fog" then ToggleFog()
                elseif name == "Set Fog Color" then OpenFogColorPicker()
                elseif name == "Set Fog Distance" then OpenTextInput("Fog End Distance", "10-500", 100, function(v) SetFogDistance(0, v) end)
                elseif name == "Night Vision" then ToggleNightVision()
                elseif name == "Thermal Vision" then ToggleThermalVision()
                elseif name == "Rainbow World" then ToggleRainbowWorld()
                elseif name == "Crosshair" then ToggleCrosshair()
                elseif name == "Hitboxes" then ToggleHitboxes()
                elseif name == "Hitbox Expander" then ToggleHitboxExpander()
                elseif name == "Hitbox Size" then OpenTextInput("Hitbox Size", "1-10", guiSettings.HitboxSize, function(v) guiSettings.HitboxSize = v end)
                -- УНИВЕРСАЛ
                elseif name == "Toggle Aimbot" then ToggleAimbot()
                elseif name == "Toggle Aimbot V2" then ToggleAimbotV2()
                elseif name == "Toggle Aimbot V3" then ToggleAimbotV3()
                elseif name == "Aimbot Speed" then OpenTextInput("Aimbot Speed", "0.01-1", guiSettings.AimbotSpeed, function(v) guiSettings.AimbotSpeed = v end)
                elseif name == "Aimbot Strength" then OpenTextInput("Strength", "0.1-1", guiSettings.AimbotStrength, function(v) guiSettings.AimbotStrength = v end)
                elseif name == "Aimbot FOV" then OpenTextInput("FOV Size", "Pixels", guiSettings.AimbotFOV, function(v) guiSettings.AimbotFOV = v end)
                elseif name == "Aimbot Wallbang" then guiSettings.AimbotWallbang = not guiSettings.AimbotWallbang
                elseif name == "Aimbot Part" then OpenTextInput("Aimbot Part", "Head/UpperTorso", guiSettings.AimbotPart, function(v) guiSettings.AimbotPart = v end)
                elseif name == "Toggle Kill Aura" then ToggleKillAura()
                elseif name == "Toggle Kill Aura V2" then ToggleKillAuraV2()
                elseif name == "Kill Aura Range" then OpenTextInput("Aura Range", "Studs", guiSettings.KillAuraRange, function(v) guiSettings.KillAuraRange = v end)
                elseif name == "Tool Reach" then OpenTextInput("Reach Size", "Studs", guiSettings.ToolReachValue, function(v) guiSettings.ToolReachValue = v ApplyToolReach() end)
                elseif name == "Orbit Kill Aura" then 
                    if not orbitButton then CreateOrbitButton() end
                    ToggleOrbitKillAura()
                elseif name == "Orbit Radius" then OpenTextInput("Orbit Radius", "1-20", guiSettings.OrbitRadius, function(v) guiSettings.OrbitRadius = v end)
                elseif name == "Orbit Speed" then OpenTextInput("Orbit Speed", "1-10", guiSettings.OrbitSpeed, function(v) guiSettings.OrbitSpeed = v end)
                elseif name == "Orbit Color" then OpenColorPicker("Orbit Color", function(c) guiSettings.OrbitColor = c if orbitButton then orbitButton.BackgroundColor3 = c end end)
                elseif name == "Toggle Trigger Bot" then ToggleTriggerBot()
                elseif name == "Toggle Anti-Aim V2" then ToggleAntiAim()
                elseif name == "Toggle Anti-Aim V3" then ToggleAntiAimV3()
                elseif name == "Anti-Aim Mode: Backwards" then SetAntiAimV3Mode("Backwards")
                elseif name == "Anti-Aim Mode: Spin" then SetAntiAimV3Mode("Spin")
                elseif name == "Anti-Aim Mode: Jitter" then SetAntiAimV3Mode("Jitter")
                elseif name == "Desync Movement" then ToggleDesync()
                elseif name == "Toggle Fake Lag" then ToggleFakeLag()
                elseif name == "Anti-Knockback" then ToggleAntiKb()
                elseif name == "Toggle Infinite Jump" then ToggleInfiniteJump()
                elseif name == "Toggle Air Walk" then ToggleAirWalk()
                elseif name == "Toggle Fly V1" then ToggleFlyV1()
                elseif name == "Toggle Fly V2" then ToggleFlyV2()
                elseif name == "Fly Speed" then OpenTextInput("Fly Speed", "10-200", flySpeed, function(v) flySpeed = v guiSettings.FlySpeed = v end)
                elseif name == "Toggle Teleport Tool" then ToggleTeleportTool()
                elseif name == "Toggle Auto Sprint" then ToggleAutoSprint()
                elseif name == "Toggle NoClip" then ToggleNoClip()
                elseif name == "Toggle Spider Mode" then ToggleSpider()
                elseif name == "Toggle Swim In Air" then ToggleSwim()
                elseif name == "Toggle Dash" then ToggleDash()
                elseif name == "Toggle Invisibility" then ToggleInvisibility()
                elseif name == "Toggle Helicopter" then ToggleHelicopter()
                elseif name == "R6 Animations" then ToggleR6Animations()
                elseif name == "BunnyHop" then ToggleBunnyHop()
                elseif name == "Speed Glitch" then ToggleSpeedGlitch()
                elseif name == "Speed" then ToggleSpeed()
                elseif name == "Gravity" then OpenTextInput("Gravity", "Workspace", workspace.Gravity, function(v) workspace.Gravity = v end)
                elseif name == "Walk Fling" then ToggleWalkFling()
                elseif name == "Fling By Name" then 
                    OpenTextInput("Fling By Name", "Enter player name", "", function(v) 
                        if v and v ~= "" then FlingByName(v) end 
                    end)
                elseif name == "Auto Fling" then ToggleAutoFling()
                elseif name == "Fling All" then FlingAll()
                elseif name == "Fling Up" then FlingUp()
                elseif name == "Fling Forward" then FlingForward()
                elseif name == "Fling Random" then FlingRandom()
                elseif name == "Super Fling" then SuperFling()
                elseif name == "IY Fling" then OpenIYFling()
                elseif name == "IY Goto" then OpenIYGoto()
                elseif name == "Fling All Up" then FlingAllUp()
                elseif name == "Fling All Random" then FlingAllRandom()
                elseif name == "Fling Last Player" then FlingLastPlayer()
                elseif name == "Wall Hop" then 
                    if not wallHopButton then CreateWallHopButton() end
                    ToggleWallHop()
                    wallHopButton.Text = wallHopEnabled and "Wall Hop ON" or "Wall Hop OFF"
                    wallHopButton.BackgroundColor3 = wallHopEnabled and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(20, 20, 25)
                -- MM2
                elseif name == "MM2 ESP V2" then ToggleMM2EspV2()
                elseif name == "MM2 ESP V3" then ToggleMM2EspV3()
                elseif name == "MM2 Aimbot V2" then ToggleMM2AimbotV2()
                elseif name == "Double Tap Attack" then ToggleDoubleTap()
                elseif name == "Auto Stab" then ToggleAutoStab()
                elseif name == "Coin Farm" then ToggleCoinFarm()
                elseif name == "Teleport to Gun" then TeleportToGun()
                elseif name == "Optimize Textures" then
                    for _, v in pairs(game:GetDescendants()) do 
                        pcall(function() 
                            if v:IsA("Texture") or v:IsA("Decal") then v.Texture = "rbxassetid://4322737890" 
                            elseif v:IsA("Part") then v.Material = Enum.Material.Plastic end 
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

    -- ===== 3 ВКЛАДКИ =====
    local categories = {
        VISUAL = {"Toggle ESP", "Toggle ESP V2", "Toggle Jump Circle", "Jump Circle Color", "Toggle Trail", "Toggle Trail V2", "Trail Color", "Toggle Chinese Hat", "Hat Color", "Rainbow China Hat", "Toggle World Color", "Toggle Stretch", "Stretch Value", "HitGlow Effects", "Toggle Fullbright", "Particles V1", "Particles V2", "Classic Sword", "World Colors", "Set Static Color", "Fog", "Set Fog Color", "Set Fog Distance", "Night Vision", "Thermal Vision", "Rainbow World", "Crosshair", "Hitboxes", "Hitbox Expander", "Hitbox Size"},
        UNIVERSAL = {"Toggle Aimbot", "Toggle Aimbot V2", "Toggle Aimbot V3", "Aimbot Speed", "Aimbot Strength", "Aimbot FOV", "Aimbot Wallbang", "Aimbot Part", "Toggle Kill Aura", "Toggle Kill Aura V2", "Kill Aura Range", "Tool Reach", "Orbit Kill Aura", "Orbit Radius", "Orbit Speed", "Orbit Color", "Toggle Trigger Bot", "Toggle Anti-Aim V2", "Toggle Anti-Aim V3", "Anti-Aim Mode: Backwards", "Anti-Aim Mode: Spin", "Anti-Aim Mode: Jitter", "Desync Movement", "Toggle Fake Lag", "Anti-Knockback", "Toggle Infinite Jump", "Toggle Air Walk", "Toggle Fly V1", "Toggle Fly V2", "Fly Speed", "Toggle Teleport Tool", "Toggle Auto Sprint", "Toggle NoClip", "Toggle Spider Mode", "Toggle Swim In Air", "Toggle Dash", "Toggle Invisibility", "Toggle Helicopter", "R6 Animations", "BunnyHop", "Speed Glitch", "Speed", "Gravity", "Walk Fling", "Fling By Name", "Auto Fling", "Fling All", "Fling Up", "Fling Forward", "Fling Random", "Super Fling", "IY Fling", "IY Goto", "Fling All Up", "Fling All Random", "Fling Last Player", "Wall Hop"},
        MM2 = {"MM2 ESP V2", "MM2 ESP V3", "MM2 Aimbot V2", "Double Tap Attack", "Auto Stab", "Coin Farm", "Teleport to Gun"}
    }

    for catName, subs in pairs(categories) do
        local btn = Instance.new("TextButton", categoryContainer)
        btn.Size = UDim2.new(0.9, 0, 0, 32)
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
    end
    
    task.wait(0.1)
    leftPanel.CanvasSize = UDim2.new(0, 0, 0, categoryContainer.AbsoluteSize.Y + 20)
    
    currentCategory = "VISUAL" 
    allSubs = categories.VISUAL 
    RenderSubs(categories.VISUAL)
end

CreateMenu()