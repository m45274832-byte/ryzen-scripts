-- MTY HUB v4.0
-- Новая структура: UNIVERSAL (все функции) + SETTINGS (отдельно)
-- Исправлен Jump Circle, добавлен ESP V2, новый Aimbot и Tracers

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

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
    AimbotPart = "Head",
    AimbotMaxDist = 1000
}

-- ===== ВСЕ ПЕРЕМЕННЫЕ =====
local espEnabled = false
local espFolder = Instance.new("Folder")
espFolder.Name = "MTY_ESP"
espFolder.Parent = workspace

local espV2Enabled = false
local espV2Folder = Instance.new("Folder")
espV2Folder.Name = "MTY_ESP_V2"
espV2Folder.Parent = workspace

local tracersEnabled = false
local tracersFolder = Instance.new("Folder")
tracersFolder.Name = "MTY_Tracers"
tracersFolder.Parent = workspace

local chamsEnabled = false
local chamsFolder = Instance.new("Folder")
chamsFolder.Name = "MTY_Chams"
chamsFolder.Parent = workspace

local hitboxEnabled = false
local HitboxFolder = Instance.new("Folder")
HitboxFolder.Name = "MTY_Hitboxes"
HitboxFolder.Parent = workspace

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
local trailConnection = nil

local spinEnabled = false
local spinConnection = nil
local sunSpinEnabled = false
local sunSpinConnection = nil
local helicopterEnabled = false
local helicopterConnection = nil
local invisibilityEnabled = false
local noClipEnabled = false
local orbitEnabled = false
local orbitConnection = nil

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
local strafeEnabled = false
local strafeConnection = nil

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
local shiftlockActive = false
local shiftlockConnection = nil
local shiftlockButton = nil
local cButtonEnabled = false
local cButtonGui = nil
local clemonRCLoaded = false
local r6Enabled = false

local particlesEnabled = false
local particlesConnection = nil
local worldColorEnabled = false
local originalAmbient = Lighting.Ambient
local originalOutdoor = Lighting.OutdoorAmbient

local crosshairEnabled = false
local crosshairGui = nil
local crosshairColor = Color3.fromRGB(0, 255, 0)

local stretchEnabled = false
local stretchConnection = nil

local hatEnabled = false
local currentHat = nil
local hatBrim = nil
local hatTopRing = nil
local hatTassel = nil
local hatConnection = nil

local dashEnabled = false
local dashButton = nil
local teleportTool = nil
local teleportToolEnabled = false
local flyLoaded = false
local speedValue = 16
local gravityValue = workspace.Gravity

local aimbotEnabled = false
local aimbotConnection = nil
local aimbotFOVRing = Drawing.new("Circle")
aimbotFOVRing.Thickness = 1.5
aimbotFOVRing.Color = Color3.fromRGB(255, 0, 0)
aimbotFOVRing.Filled = false
aimbotFOVRing.Visible = false
aimbotFOVRing.Radius = guiSettings.AimbotFOV

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
    wait(2)
    msg:Destroy()
end

-- ===== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ =====
local function OpenTextInput(title, placeholder, default, callback)
    local s = Instance.new("ScreenGui")
    s.Name = "Input"
    s.Parent = game.CoreGui
    s.ResetOnSpawn = false
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 250, 0, 150)
    f.Position = UDim2.new(0.5, -125, 0.35, 0)
    f.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    f.BackgroundTransparency = 0.1
    f.BorderSizePixel = 0
    f.Parent = s
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = f
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 35)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = f
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.8, 0, 0, 35)
    input.Position = UDim2.new(0.1, 0, 0.3, 0)
    input.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    input.BorderSizePixel = 0
    input.Text = tostring(default)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.TextScaled = true
    input.Font = Enum.Font.Gotham
    input.PlaceholderText = placeholder
    input.Parent = f
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = input
    local apply = Instance.new("TextButton")
    apply.Size = UDim2.new(0.4, 0, 0, 30)
    apply.Position = UDim2.new(0.3, 0, 0.7, 0)
    apply.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
    apply.BorderSizePixel = 0
    apply.Text = "Apply"
    apply.TextColor3 = Color3.fromRGB(255, 255, 255)
    apply.TextSize = 16
    apply.Font = Enum.Font.Gotham
    apply.Parent = f
    local applyCorner = Instance.new("UICorner")
    applyCorner.CornerRadius = UDim.new(0, 8)
    applyCorner.Parent = apply
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -35, 0, 3)
    close.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    close.BorderSizePixel = 0
    close.Text = "X"
    close.TextColor3 = Color3.fromRGB(255, 255, 255)
    close.TextSize = 18
    close.Font = Enum.Font.GothamBold
    close.Parent = f
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = close
    apply.MouseButton1Click:Connect(function()
        local val = tonumber(input.Text)
        if val then
            callback(val)
            s:Destroy()
        else
            input.Text = "Enter number"
        end
    end)
    close.MouseButton1Click:Connect(function() s:Destroy() end)
end

local function OpenColorPicker(title, callback)
    local s = Instance.new("ScreenGui")
    s.Name = "ColorPicker"
    s.Parent = game.CoreGui
    s.ResetOnSpawn = false
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 200, 0, 300)
    f.Position = UDim2.new(0.5, -100, 0.3, 0)
    f.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    f.BackgroundTransparency = 0.1
    f.BorderSizePixel = 0
    f.Parent = s
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = f
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 35)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = f
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(0.9, 0, 0.75, 0)
    scroll.Position = UDim2.new(0.05, 0, 0.12, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.new(0, 0, 0, 300)
    scroll.ScrollBarThickness = 6
    scroll.Parent = f
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
        {"Brown", Color3.fromRGB(150, 75, 0)}
    }
    local y = 0
    for _, data in ipairs(colors) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 35)
        btn.Position = UDim2.new(0.05, 0, 0, y)
        btn.BackgroundColor3 = data[2]
        btn.BackgroundTransparency = 0.2
        btn.BorderSizePixel = 0
        btn.Text = data[1]
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 14
        btn.Font = Enum.Font.Gotham
        btn.Parent = scroll
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        btn.MouseButton1Click:Connect(function()
            callback(data[2])
            s:Destroy()
        end)
        y = y + 42
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, y + 10)
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -35, 0, 3)
    close.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    close.BorderSizePixel = 0
    close.Text = "X"
    close.TextColor3 = Color3.fromRGB(255, 255, 255)
    close.TextSize = 18
    close.Font = Enum.Font.GothamBold
    close.Parent = f
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = close
    close.MouseButton1Click:Connect(function() s:Destroy() end)
end

-- ===== НОВЫЙ АИМБОТ (EXTERNAL V6) =====
local function FindBestTarget()
    local target = nil
    local near = guiSettings.AimbotFOV
    local mid = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            local hit = player.Character:FindFirstChild(guiSettings.AimbotPart) or player.Character:FindFirstChild("Head")
            if hum and hit and hum.Health > 0 then
                local screen, visible = Camera:WorldToViewportPoint(hit.Position)
                if visible then
                    local dist = (Vector2.new(screen.X, screen.Y) - mid).Magnitude
                    local worldDist = (Camera.CFrame.Position - hit.Position).Magnitude
                    if dist < near and worldDist < guiSettings.AimbotMaxDist then
                        near = dist
                        target = hit
                    end
                end
            end
        end
    end
    return target
end

local function ToggleAimbot()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        if aimbotConnection then aimbotConnection:Disconnect() end
        aimbotConnection = RunService.RenderStepped:Connect(function()
            if not aimbotEnabled then return end
            local mid = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            aimbotFOVRing.Position = mid
            aimbotFOVRing.Radius = guiSettings.AimbotFOV
            aimbotFOVRing.Visible = true
            
            local target = FindBestTarget()
            if target then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, target.Position), guiSettings.AimbotSpeed)
            end
        end)
        ShowMessage("🎯 Aimbot ON (FOV: " .. guiSettings.AimbotFOV .. ")")
    else
        if aimbotConnection then aimbotConnection:Disconnect() aimbotConnection = nil end
        aimbotFOVRing.Visible = false
        ShowMessage("🎯 Aimbot OFF")
    end
end

-- ===== НОВЫЕ ТРЭКЕРЫ (EXTERNAL V6) =====
local function UpdateTracersV2()
    for _, v in pairs(tracersFolder:GetChildren()) do v:Destroy() end
    if not tracersEnabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                local pos, visible = Camera:WorldToViewportPoint(root.Position)
                local dist = (Camera.CFrame.Position - root.Position).Magnitude
                
                local tracer = Instance.new("Part")
                tracer.Size = Vector3.new(0.1, 0.1, 0.1)
                tracer.Anchored = true
                tracer.CanCollide = false
                tracer.Material = Enum.Material.Neon
                tracer.BrickColor = BrickColor.new(Color3.fromHSV(math.clamp(dist / 1000, 0, 0.33), 1, 1))
                tracer.Parent = tracersFolder
                
                local camPos = Camera.CFrame.Position
                local endPos = root.Position
                local midPoint = (camPos + endPos) / 2
                local distance = (endPos - camPos).Magnitude
                tracer.Size = Vector3.new(0.1, distance, 0.1)
                tracer.CFrame = CFrame.lookAt(midPoint, camPos) * CFrame.new(0, 0, -distance / 2)
                game:GetService("Debris"):AddItem(tracer, 0.1)
            end
        end
    end
end

local function ToggleTracers()
    tracersEnabled = not tracersEnabled
    if tracersEnabled then
        RunService.Heartbeat:Connect(function()
            if tracersEnabled then UpdateTracersV2() end
        end)
    else
        for _, v in pairs(tracersFolder:GetChildren()) do v:Destroy() end
    end
    ShowMessage("Tracers " .. (tracersEnabled and "ON" or "OFF"))
end

-- ===== ESP V2 (EXTERNAL V6) =====
local function UpdateESPV2()
    for _, v in pairs(espV2Folder:GetChildren()) do v:Destroy() end
    if not espV2Enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                local pos, visible = Camera:WorldToViewportPoint(root.Position)
                local dist = (Camera.CFrame.Position - root.Position).Magnitude
                local color = Color3.fromHSV(math.clamp(dist / 1000, 0, 0.33), 1, 1)
                
                if visible then
                    local size = math.clamp(2500 / dist, 5, 300)
                    local box = Instance.new("BoxHandleAdornment")
                    box.Adornee = root
                    box.Color3 = color
                    box.Transparency = 0.5
                    box.Size = Vector3.new(size / 2, size * 0.75, 1)
                    box.AlwaysOnTop = true
                    box.ZIndex = 10
                    box.Parent = espV2Folder
                end
            end
        end
    end
end

local function ToggleESPV2()
    espV2Enabled = not espV2Enabled
    if espV2Enabled then
        RunService.Heartbeat:Connect(function()
            if espV2Enabled then UpdateESPV2() end
        end)
    else
        for _, v in pairs(espV2Folder:GetChildren()) do v:Destroy() end
    end
    ShowMessage("ESP V2 " .. (espV2Enabled and "ON" or "OFF"))
end

-- ===== ИСПРАВЛЕННЫЙ JUMP CIRCLE =====
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
        mesh.Scale = Vector3.new(1, 0.05, 1)
        mesh.Parent = jumpCircle
        
        local fadeStart = 0
        local isJumping = false
        
        jumpCircleConnection = RunService.Heartbeat:Connect(function()
            if not jumpCircleEnabled or not jumpCircle then return end
            
            local hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
            if not hum then return end
            
            local jumping = hum:GetState() == Enum.HumanoidStateType.Jumping
            
            if jumping and not isJumping then
                isJumping = true
                fadeStart = tick()
                jumpCircle.Transparency = 0.1
                jumpCircle.Size = Vector3.new(6, 0.2, 6)
                jumpCircle.Position = LP.Character.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
                
            elseif not jumping and isJumping then
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
                
            elseif jumping and isJumping then
                jumpCircle.Position = LP.Character.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
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

-- ===== ВИЗУАЛЫ (ESP, CHAMS, HITBOXES, BACKTRACK, TRAIL, PARTICLES) =====
-- ESP
local function UpdateESP()
    for _, v in pairs(espFolder:GetChildren()) do v:Destroy() end
    if not espEnabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    local h = Instance.new("Highlight")
                    h.Adornee = part
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.FillColor = guiSettings.ESPColor
                    h.FillTransparency = 0.3
                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                    h.OutlineTransparency = 0.2
                    h.Parent = espFolder
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

-- CHAMS
local function UpdateChams()
    for _, v in pairs(chamsFolder:GetChildren()) do v:Destroy() end
    if not chamsEnabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    local h = Instance.new("Highlight")
                    h.Adornee = part
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.FillColor = guiSettings.ChamsColor
                    h.FillTransparency = 0.1
                    h.OutlineColor = guiSettings.ChamsColor
                    h.OutlineTransparency = 0.1
                    h.Parent = chamsFolder
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

-- HITBOXES
local function UpdateHitboxes()
    for _, v in pairs(HitboxFolder:GetChildren()) do v:Destroy() end
    if not hitboxEnabled then return end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Parent and v.Parent:FindFirstChild("Humanoid") then
            local box = Instance.new("BoxHandleAdornment")
            box.Adornee = v
            box.Color3 = guiSettings.HitboxColor
            box.Transparency = 0.5
            box.Size = v.Size
            box.AlwaysOnTop = true
            box.ZIndex = 10
            box.Parent = HitboxFolder
        end
    end
end

local function ToggleHitboxes()
    hitboxEnabled = not hitboxEnabled
    UpdateHitboxes()
    ShowMessage("Hitboxes " .. (hitboxEnabled and "ON" or "OFF"))
end

-- BACKTRACK
local function UpdateBacktrack()
    for _, v in pairs(backtrackFolder:GetChildren()) do v:Destroy() end
    if not backtrackEnabled then return end
    local now = tick()
    for _, data in pairs(backtrackData) do
        if now - data.time < 0.5 then
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
                table.insert(backtrackData, {time = tick(), cframe = LP.Character.HumanoidRootPart.CFrame})
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

-- TRAIL
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
    else
        if trailConnection then trailConnection:Disconnect() trailConnection = nil end
        for _, v in pairs(trailParts) do v:Destroy() end
        trailParts = {}
    end
    ShowMessage("Trail " .. (trailEnabled and "ON" or "OFF"))
end

-- PARTICLES
local function ToggleParticles()
    particlesEnabled = not particlesEnabled
    if particlesEnabled then
        if particlesConnection then particlesConnection:Disconnect() end
        particlesConnection = RunService.Heartbeat:Connect(function()
            if not particlesEnabled then return end
            local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local part = Instance.new("Part")
            part.Size = Vector3.new(0.3, 0.3, 0.3)
            part.CFrame = root.CFrame * CFrame.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
            part.Anchored = true
            part.CanCollide = false
            part.Material = Enum.Material.Neon
            part.BrickColor = BrickColor.new(guiSettings.ParticleColor)
            part.Parent = workspace
            game:GetService("Debris"):AddItem(part, 0.5)
        end)
        ShowMessage("Particles ON")
    else
        if particlesConnection then particlesConnection:Disconnect() particlesConnection = nil end
        ShowMessage("Particles OFF")
    end
end

-- ===== КИТАЙСКАЯ ШЛЯПА + ПРИЦЕЛ =====
-- CHINESE HAT
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
    
    local cone = Instance.new("SpecialMesh")
    cone.MeshType = Enum.MeshType.Cone
    cone.Scale = Vector3.new(4, 2.2, 4)
    cone.Parent = currentHat
    
    hatBrim = Instance.new("Part")
    hatBrim.Size = Vector3.new(4.8, 0.05, 4.8)
    hatBrim.Anchored = true
    hatBrim.CanCollide = false
    hatBrim.Material = Enum.Material.Neon
    hatBrim.BrickColor = BrickColor.new(guiSettings.HatColor)
    hatBrim.Transparency = 0.05
    hatBrim.Parent = workspace
    
    local ring = Instance.new("SpecialMesh")
    ring.MeshType = Enum.MeshType.Cylinder
    ring.Scale = Vector3.new(1, 0.05, 1)
    ring.Parent = hatBrim
    
    hatTopRing = Instance.new("Part")
    hatTopRing.Size = Vector3.new(1, 0.05, 1)
    hatTopRing.Anchored = true
    hatTopRing.CanCollide = false
    hatTopRing.Material = Enum.Material.Neon
    hatTopRing.BrickColor = BrickColor.new(guiSettings.HatColor)
    hatTopRing.Transparency = 0.05
    hatTopRing.Parent = workspace
    
    local topRing = Instance.new("SpecialMesh")
    topRing.MeshType = Enum.MeshType.Cylinder
    topRing.Scale = Vector3.new(1, 0.05, 1)
    topRing.Parent = hatTopRing
    
    hatTassel = Instance.new("Part")
    hatTassel.Size = Vector3.new(0.3, 1.5, 0.3)
    hatTassel.Anchored = true
    hatTassel.CanCollide = false
    hatTassel.Material = Enum.Material.Neon
    hatTassel.BrickColor = BrickColor.new(Color3.fromRGB(255, 50, 50))
    hatTassel.Transparency = 0.1
    hatTassel.Parent = workspace
    
    local tasselMesh = Instance.new("SpecialMesh")
    tasselMesh.MeshType = Enum.MeshType.Sphere
    tasselMesh.Scale = Vector3.new(1, 1, 1)
    tasselMesh.Parent = hatTassel
    
    if hatConnection then hatConnection:Disconnect() end
    hatConnection = RunService.Heartbeat:Connect(function()
        if currentHat and hatBrim and hatTopRing and hatTassel and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local root = LP.Character.HumanoidRootPart
            local pos = root.CFrame * CFrame.new(0, 3.0, 0)
            currentHat.CFrame = pos
            hatBrim.CFrame = pos * CFrame.new(0, -1.0, 0)
            hatTopRing.CFrame = pos * CFrame.new(0, 1.0, 0)
            hatTassel.CFrame = pos * CFrame.new(0, 1.6, 0)
        end
    end)
end

local function ToggleChineseHat()
    hatEnabled = not hatEnabled
    if hatEnabled then
        CreateChineseHat()
        ShowMessage("Chinese Hat ON 🎩")
    else
        if currentHat then currentHat:Destroy() currentHat = nil end
        if hatBrim then hatBrim:Destroy() hatBrim = nil end
        if hatTopRing then hatTopRing:Destroy() hatTopRing = nil end
        if hatTassel then hatTassel:Destroy() hatTassel = nil end
        if hatConnection then hatConnection:Disconnect() hatConnection = nil end
        ShowMessage("Chinese Hat OFF")
    end
end

-- CROSSHAIR
local function CreateCrosshair()
    if crosshairGui then crosshairGui:Destroy() end
    crosshairGui = Instance.new("ScreenGui")
    crosshairGui.Name = "MTY_Crosshair"
    crosshairGui.Parent = game.CoreGui
    crosshairGui.ResetOnSpawn = false
    
    local size = 25
    local gap = 10
    local color = crosshairColor
    local thick = 2
    
    local top = Instance.new("Frame")
    top.Size = UDim2.new(0, thick, 0, size)
    top.Position = UDim2.new(0.5, -thick / 2, 0.5, -gap - size)
    top.BackgroundColor3 = color
    top.BorderSizePixel = 0
    top.Parent = crosshairGui
    
    local bottom = Instance.new("Frame")
    bottom.Size = UDim2.new(0, thick, 0, size)
    bottom.Position = UDim2.new(0.5, -thick / 2, 0.5, gap)
    bottom.BackgroundColor3 = color
    bottom.BorderSizePixel = 0
    bottom.Parent = crosshairGui
    
    local left = Instance.new("Frame")
    left.Size = UDim2.new(0, size, 0, thick)
    left.Position = UDim2.new(0.5, -gap - size, 0.5, -thick / 2)
    left.BackgroundColor3 = color
    left.BorderSizePixel = 0
    left.Parent = crosshairGui
    
    local right = Instance.new("Frame")
    right.Size = UDim2.new(0, size, 0, thick)
    right.Position = UDim2.new(0.5, gap, 0.5, -thick / 2)
    right.BackgroundColor3 = color
    right.BorderSizePixel = 0
    right.Parent = crosshairGui
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 3, 0, 3)
    dot.Position = UDim2.new(0.5, -1.5, 0.5, -1.5)
    dot.BackgroundColor3 = color
    dot.BorderSizePixel = 0
    dot.Parent = crosshairGui
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

-- ===== SHIFTLOCK + C BUTTON + R6 АНИМАЦИИ =====
-- SHIFTLOCK
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
    btn.MouseButton1Click:Connect(function() ToggleShiftlock() end)
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
                local look = Camera.CFrame.LookVector
                local pos = root.Position
                root.CFrame = CFrame.new(pos, Vector3.new(look.X * 99999, pos.Y, look.Z * 99999))
            end
        end)
        if shiftlockButton then shiftlockButton.Image = "rbxasset://textures/ui/mouseLock_on@2x.png" end
        ShowMessage("Shiftlock ON 🔒")
    else
        if shiftlockConnection then shiftlockConnection:Disconnect() shiftlockConnection = nil end
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.AutoRotate = true
        end
        if shiftlockButton then shiftlockButton.Image = "rbxasset://textures/ui/mouseLock_off@2x.png" end
        ShowMessage("Shiftlock OFF 🔓")
    end
end

-- C BUTTON
local function CreateCButton()
    if cButtonGui then cButtonGui:Destroy() cButtonGui = nil end
    cButtonGui = Instance.new("ScreenGui")
    cButtonGui.Name = "MTY_CButton"
    cButtonGui.Parent = game.CoreGui
    cButtonGui.ResetOnSpawn = false
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 58, 0, 58)
    btn.Position = UDim2.new(0.9, 0, 0.8, 0)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = "C"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = cButtonGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 3
    stroke.Color = Color3.fromRGB(80, 180, 255)
    stroke.Parent = btn
    
    local origPos = btn.Position
    
    local function setPressed(p)
        if p then
            btn.BackgroundColor3 = Color3.fromRGB(0, 100, 220)
            btn.TextColor3 = Color3.fromRGB(255, 255, 100)
            btn.Position = origPos + UDim2.new(0, 0, 0, 4)
        else
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Position = origPos
        end
    end
    
    btn.MouseButton1Down:Connect(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game)
        setPressed(true)
    end)
    btn.MouseButton1Up:Connect(function()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game)
        setPressed(false)
    end)
    
    local drag = false
    local dStart, sPos
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            dStart = input.Position
            sPos = btn.Position
            origPos = btn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dStart
            btn.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
            origPos = btn.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = false
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

-- R6 ANIMATIONS
local function RunCustomAnimation(Char)
    if Char:WaitForChild("Humanoid").RigType == Enum.HumanoidRigType.R6 then return end
    if Char:FindFirstChild("Animate") then Char.Animate.Disabled = true end
    for _, v in next, Char.Humanoid:GetPlayingAnimationTracks() do v:Stop() end
    
    local Humanoid = Char:WaitForChild("Humanoid")
    local animTable = {}
    local animNames = {
        idle = {{id = "http://www.roblox.com/asset/?id=12521158637", weight = 9}, {id = "http://www.roblox.com/asset/?id=12521162526", weight = 1}},
        walk = {{id = "http://www.roblox.com/asset/?id=12518152696", weight = 10}},
        run = {{id = "http://www.roblox.com/asset/?id=12518152696", weight = 10}},
        jump = {{id = "http://www.roblox.com/asset/?id=12520880485", weight = 10}},
        fall = {{id = "http://www.roblox.com/asset/?id=12520972571", weight = 10}},
        climb = {{id = "http://www.roblox.com/asset/?id=12520982150", weight = 10}},
        sit = {{id = "http://www.roblox.com/asset/?id=12520993168", weight = 10}}
    }
    
    for name, list in pairs(animNames) do
        animTable[name] = {}
        for idx, anim in pairs(list) do
            animTable[name][idx] = {anim = Instance.new("Animation"), weight = anim.weight}
            animTable[name][idx].anim.AnimationId = anim.id
            animTable[name][idx].anim.Name = name
        end
    end
    
    local currentTrack = nil
    
    local function playAnimation(name, time)
        local roll = math.random(1, 10)
        local idx = 1
        local total = 0
        for i, v in pairs(animTable[name]) do total = total + v.weight end
        while roll > 0 do
            roll = roll - animTable[name][idx].weight
            if roll <= 0 then break end
            idx = idx + 1
        end
        local anim = animTable[name][idx].anim
        if currentTrack then currentTrack:Stop(time) currentTrack:Destroy() end
        currentTrack = Humanoid:LoadAnimation(anim)
        currentTrack:Play(time)
    end
    
    Humanoid.Running:Connect(function(speed)
        if speed > 0.75 then playAnimation("walk", 0.2) else playAnimation("idle", 0.2) end
    end)
    Humanoid.Jumping:Connect(function() playAnimation("jump", 0.1) end)
    Humanoid.FreeFalling:Connect(function() playAnimation("fall", 0.2) end)
    Humanoid.Seated:Connect(function() playAnimation("sit", 0.5) end)
    playAnimation("idle", 0.1)
end

local function ToggleR6Animations()
    if not r6Enabled then
        RunCustomAnimation(LP.Character)
        LP.CharacterAdded:Connect(function(char) RunCustomAnimation(char) end)
        r6Enabled = true
        ShowMessage("R6 Animations ON 🕺")
    else
        ShowMessage("R6 Animations already ON")
    end
end

-- ===== ФУНКЦИИ PLAYER =====
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

local function ToggleNameTags()
    nameTagsEnabled = not nameTagsEnabled
    if nameTagsEnabled then
        local function UpdateNameTags()
            for _, v in pairs(nameTagsFolder:GetChildren()) do v:Destroy() end
            if not nameTagsEnabled then return end
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local bill = Instance.new("BillboardGui")
                    bill.Size = UDim2.new(0, 200, 0, 40)
                    bill.Adornee = player.Character.HumanoidRootPart
                    bill.Parent = nameTagsFolder
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = player.Name
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    label.TextScaled = true
                    label.Font = Enum.Font.GothamBold
                    label.Parent = bill
                end
            end
        end
        UpdateNameTags()
        RunService.Heartbeat:Connect(function()
            if nameTagsEnabled then UpdateNameTags() end
        end)
    else
        for _, v in pairs(nameTagsFolder:GetChildren()) do v:Destroy() end
    end
    ShowMessage("NameTags " .. (nameTagsEnabled and "ON" or "OFF"))
end

local function ToggleSkeleton()
    skeletonEnabled = not skeletonEnabled
    if skeletonEnabled then
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
        UpdateSkeleton()
        RunService.Heartbeat:Connect(function()
            if skeletonEnabled then UpdateSkeleton() end
        end)
    else
        for _, v in pairs(skeletonFolder:GetChildren()) do v:Destroy() end
    end
    ShowMessage("Skeleton " .. (skeletonEnabled and "ON" or "OFF"))
end

local function ToggleTargetESP()
    targetESPEnabled = not targetESPEnabled
    if targetESPEnabled then
        RunService.Heartbeat:Connect(function()
            if targetESPEnabled then
                if targetHighlight then targetHighlight:Destroy() end
                local mousePos = LP:GetMouse().UnitRay
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
    else
        if targetHighlight then targetHighlight:Destroy() end
    end
    ShowMessage("Target ESP " .. (targetESPEnabled and "ON" or "OFF"))
end

local function ToggleWorldColor()
    worldColorEnabled = not worldColorEnabled
    if worldColorEnabled then
        Lighting.Ambient = guiSettings.WorldColor
        Lighting.OutdoorAmbient = guiSettings.WorldColor
        ShowMessage("World Color ON 🌍")
    else
        Lighting.Ambient = originalAmbient
        Lighting.OutdoorAmbient = originalOutdoor
        ShowMessage("World Color OFF")
    end
end

local function ToggleSpin()
    spinEnabled = not spinEnabled
    if spinEnabled then
        if spinConnection then spinConnection:Disconnect() end
        spinConnection = RunService.Heartbeat:Connect(function()
            if spinEnabled and LP.Character then
                local root = LP.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local pos = root.Position
                    root.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(guiSettings.SpinSpeed), 0)
                end
            end
        end)
        ShowMessage("Spin ON 🌀")
    else
        if spinConnection then spinConnection:Disconnect() spinConnection = nil end
        ShowMessage("Spin OFF")
    end
end

local function ToggleSunSpin()
    sunSpinEnabled = not sunSpinEnabled
    if sunSpinEnabled then
        if sunSpinConnection then sunSpinConnection:Disconnect() end
        sunSpinConnection = RunService.Heartbeat:Connect(function()
            if sunSpinEnabled and LP.Character then
                local root = LP.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local pos = root.Position
                    root.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(guiSettings.SunSpinSpeed), math.rad(guiSettings.SunSpinSpeed * 0.5))
                end
            end
        end)
        ShowMessage("☀️ Sun Spin ON")
    else
        if sunSpinConnection then sunSpinConnection:Disconnect() sunSpinConnection = nil end
        ShowMessage("☀️ Sun Spin OFF")
    end
end

local function ToggleHelicopter()
    helicopterEnabled = not helicopterEnabled
    if helicopterEnabled then
        if helicopterConnection then helicopterConnection:Disconnect() end
        helicopterConnection = RunService.Heartbeat:Connect(function()
            if helicopterEnabled and LP.Character then
                local root = LP.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(50), 0)
                    root.Velocity = Vector3.new(0, 20, 0)
                end
            end
        end)
        ShowMessage("Helicopter ON 🚁")
    else
        if helicopterConnection then helicopterConnection:Disconnect() helicopterConnection = nil end
        if LP.Character then
            local root = LP.Character:FindFirstChild("HumanoidRootPart")
            if root then root.Velocity = Vector3.new(0, 0, 0) end
        end
        ShowMessage("Helicopter OFF")
    end
end

local function ToggleInvisibility()
    invisibilityEnabled = not invisibilityEnabled
    local char = LP.Character or LP.CharacterAdded:Wait()
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Transparency = invisibilityEnabled and 0.99 or 0
        end
    end
    ShowMessage("Invisibility " .. (invisibilityEnabled and "ON" or "OFF"))
end

local function ToggleDash()
    dashEnabled = not dashEnabled
    if dashEnabled then
        if dashButton then return end
        local sg = Instance.new("ScreenGui")
        sg.Name = "MTY_Dash"
        sg.Parent = game.CoreGui
        sg.ResetOnSpawn = false
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 60, 0, 60)
        btn.Position = UDim2.new(0.9, -70, 0.5, -30)
        btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        btn.BorderSizePixel = 0
        btn.Text = "⚡"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 30
        btn.Font = Enum.Font.GothamBold
        btn.Parent = sg
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
    else
        if dashButton then dashButton.Parent:Destroy() dashButton = nil end
    end
    ShowMessage("Dash " .. (dashEnabled and "ON" or "OFF"))
end

local function ToggleFly()
    if not flyLoaded then
        pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/dUJkcGde"))()
        end)
        flyLoaded = true
        ShowMessage("Fly started")
    else
        ShowMessage("Fly already loaded")
    end
end

local function ToggleTeleportTool()
    teleportToolEnabled = not teleportToolEnabled
    if teleportToolEnabled then
        if teleportTool then return end
        teleportTool = Instance.new("Tool")
        teleportTool.RequiresHandle = false
        teleportTool.Name = "MTY Teleport"
        teleportTool.Activated:Connect(function()
            local pos = LP:GetMouse() and LP:GetMouse().Hit + Vector3.new(0, 2.5, 0) or Vector3.new(0, 10, 0)
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.CFrame = CFrame.new(pos.X, pos.Y, pos.Z)
            end
        end)
        teleportTool.Parent = LP.Backpack
        ShowMessage("Teleport Tool ON")
    else
        if teleportTool then teleportTool:Destroy() teleportTool = nil end
        ShowMessage("Teleport Tool OFF")
    end
end

local function ToggleNoClip()
    noClipEnabled = not noClipEnabled
    if noClipEnabled then
        if LP.Character then
            for _, v in pairs(LP.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    else
        if LP.Character then
            for _, v in pairs(LP.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end
    ShowMessage("NoClip " .. (noClipEnabled and "ON" or "OFF"))
end

local function ToggleStrafe()
    strafeEnabled = not strafeEnabled
    if strafeEnabled then
        if strafeConnection then strafeConnection:Disconnect() end
        strafeConnection = RunService.Heartbeat:Connect(function()
            if not strafeEnabled then return end
            local char = LP.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if not root or not hum then return end
            if hum:GetState() == Enum.HumanoidStateType.Landed then
                if UserInputService:IsKeyDown(Enum.KeyCode.W) or
                    UserInputService:IsKeyDown(Enum.KeyCode.A) or
                    UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    hum.Jump = true
                end
            end
            if hum:GetState() == Enum.HumanoidStateType.Jumping or
                hum:GetState() == Enum.HumanoidStateType.Freefall then
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0.1 then
                    local boost = moveDir * 8
                    root.Velocity = root.Velocity + boost
                end
            end
        end)
        ShowMessage("Strafe ON 🏃")
    else
        if strafeConnection then strafeConnection:Disconnect() strafeConnection = nil end
        ShowMessage("Strafe OFF")
    end
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
                    local dist = (LP.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
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
                LP.Character.HumanoidRootPart.CFrame = CFrame.new(x, LP.Character.HumanoidRootPart.Position.Y, z) * CFrame.lookAt(Vector3.new(x, LP.Character.HumanoidRootPart.Position.Y, z), targetPos)
            end
        end)
        ShowMessage("🌀 Orbit ON")
    else
        if orbitConnection then orbitConnection:Disconnect() orbitConnection = nil end
        ShowMessage("🌀 Orbit OFF")
    end
end

-- ===== ФУНКЦИИ COMBAT =====
local function ToggleAntiAim()
    antiAimEnabled = not antiAimEnabled
    if antiAimEnabled then
        if antiAimConnection then antiAimConnection:Disconnect() end
        antiAimConnection = RunService.Heartbeat:Connect(function()
            if not antiAimEnabled then return end
            local char = LP.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            if antiAimMode == "Spin" then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(tick() * 200), 0)
            elseif antiAimMode == "Backwards" then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    local moveDir = hum.MoveDirection
                    if moveDir.Magnitude > 0.1 then
                        local backwardDir = -moveDir
                        root.CFrame = CFrame.new(root.Position, root.Position + backwardDir * 10)
                    else
                        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(180), 0)
                    end
                    hum.AutoRotate = false
                end
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

local function ToggleFakeLag()
    fakeLagEnabled = not fakeLagEnabled
    if fakeLagEnabled then
        if fakeLagConnection then fakeLagConnection:Disconnect() end
        fakeLagConnection = RunService.Heartbeat:Connect(function()
            if not fakeLagEnabled then return end
            for i = 1, guiSettings.FakeLagAmount do wait(0.001) end
        end)
        ShowMessage("Fake Lag ON 📡")
    else
        if fakeLagConnection then fakeLagConnection:Disconnect() fakeLagConnection = nil end
        ShowMessage("Fake Lag OFF")
    end
end

local function ToggleSilentAim()
    silentAimEnabled = not silentAimEnabled
    ShowMessage("Silent Aim " .. (silentAimEnabled and "ON" or "OFF"))
end

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
                        if onScreen then                            local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(LP:GetMouse().X, LP:GetMouse().Y)).Magnitude
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

local function LoadClemonRC()
    if clemonRCLoaded then
        ShowMessage("ClemonRC already loaded")
    else
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/clemonlang/clemon_roclothes/refs/heads/main/ClemonRC.lua"))()
            clemonRCLoaded = true
            ShowMessage("ClemonRC Loaded 👕")
        end)
    end
end

-- ===== STRETCH + СТИЛЬ =====
local function ToggleStretch()
    stretchEnabled = not stretchEnabled
    if stretchEnabled then
        if stretchConnection then stretchConnection:Disconnect() end
        stretchConnection = RunService.RenderStepped:Connect(function()
            if not stretchEnabled then return end
            Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, guiSettings.StretchValue, 0, 0, 0, 1)
        end)
        ShowMessage("Stretch ON")
    else
        if stretchConnection then stretchConnection:Disconnect() stretchConnection = nil end
        ShowMessage("Stretch OFF")
    end
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
-- ===== ГЛАВНОЕ МЕНЮ =====
local function CreateMenu()
    -- ... (весь код меню из предыдущего сообщения)
end

CreateMenu()
print("MTY HUB v4.0 LOADED! 🔥")