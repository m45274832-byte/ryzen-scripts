-- ============================================================================
-- 🎮 MTY HUB CLONE + OBSIDIAN (ОБЪЕДИНЕНИЕ)
-- ============================================================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Teams = game:GetService("Teams")
local PathfindingService = game:GetService("PathfindingService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- ============================================================================
-- 📦 GUI (НЕ ПРОПАДАЕТ ПОСЛЕ СМЕРТИ)
-- ============================================================================

local gui = Instance.new("ScreenGui")
gui.Name = "MtyHubClone"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- ============================================================================
-- 📦 ПЕРЕМЕННЫЕ
-- ============================================================================

local cubeDragging = false
local cubeDragStart = nil
local cubeStartPos = nil
local uiVisible = true

local guiSettings = {
    BorderColor = Color3.fromRGB(150, 0, 255),
    TextColor = Color3.fromRGB(240, 240, 245),
    OnColor = Color3.fromRGB(150, 0, 255),
    OffColor = Color3.fromRGB(30, 30, 35),
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
    FogEnd = 100,
    -- OBSIDIAN НАСТРОЙКИ
    ObsidianSpeedValue = 16,
    ObsidianJumpValue = 50,
    ObsidianFlySpeed = 50,
    ObsidianCPS = 10,
    ObsidianACKey = "E",
    ObsidianACMode = "Left Click",
    ObsidianAutoTpDelay = 2,
    ObsidianOffsetX = 0,
    ObsidianOffsetY = 0,
    ObsidianOffsetZ = 0,
    ObsidianTpRange = 1000,
    ObsidianHipHeight = 0,
    ObsidianGroupColor = Color3.fromRGB(0, 170, 255),
    ObsidianTracerOrigin = "Default",
}

-- ============================================================================
-- 🎮 ТОГГЛЫ (ТВОИ ОРИГИНАЛЬНЫЕ + OBSIDIAN)
-- ============================================================================

local toggles = {
    -- ТВОИ ОРИГИНАЛЬНЫЕ ТОГГЛЫ
    esp = false,
    espV2 = false,
    jumpCircle = false,
    trail = false,
    trailV2 = false,
    chinaHat = false,
    worldColor = false,
    stretch = false,
    stretchV2 = false,
    hitGlow = false,
    fullbright = false,
    particlesV1 = false,
    particlesV2 = false,
    classicSword = false,
    worldColors = false,
    fog = false,
    nightVision = false,
    thermalVision = false,
    rainbowWorld = false,
    crosshair = false,
    hitboxes = false,
    hitboxExpander = false,
    aimbot = false,
    aimbotV2 = false,
    aimbotV3 = false,
    killAura = false,
    killAuraV2 = false,
    orbitKillAura = false,
    triggerBot = false,
    antiAim = false,
    antiAimV3 = false,
    desync = false,
    fakeLag = false,
    antiKb = false,
    speed = false,
    infiniteJump = false,
    airWalk = false,
    flyV1 = false,
    flyV2 = false,
    teleportTool = false,
    autoSprint = false,
    noClip = false,
    spider = false,
    swim = false,
    dash = false,
    invisibility = false,
    helicopter = false,
    r6Animations = false,
    bunnyHop = false,
    speedGlitch = false,
    wallHop = false,
    walkFling = false,
    autoFling = false,
    mm2EspV2 = false,
    mm2EspV3 = false,
    mm2AimbotV2 = false,
    doubleTap = false,
    autoStab = false,
    coinFarm = false,
    -- OBSIDIAN ТОГГЛЫ
    obsidianSpeed = false,
    obsidianJump = false,
    obsidianFly = false,
    obsidianFlyAnim = false,
    obsidianNoclip = false,
    obsidianEspMaster = false,
    obsidianTracers = false,
    obsidianHealthBar = false,
    obsidianBoxEsp = false,
    obsidianSkeleton = false,
    obsidianWaypointEsp = false,
    obsidianUseGroupTp = false,
    obsidianAutoTp = false,
    obsidianUsePathfinding = false,
    obsidianLoopPlayerTp = false,
    obsidianAutoTpNext = false,
    obsidianAcToggle = false,
    obsidianFbMaster = false,
    obsidianAutoFb = false,
    obsidianNoShadows = false,
    obsidianNoFog = false,
    obsidianWalkfling = false,
    obsidianNoVoid = false,
    obsidianGodMode = false,
    obsidianNoPromptCooldown = false,
}

local speedValue = 16
local flySpeed = 50
local flingPower = 999999
local targetPlayer = nil
local trailParts = {}
local espFolder, espV2Folder, HitboxFolder = nil, nil, nil
local fovGui, fovRing, fovStroke = nil, nil, nil
local mm2FovCircle, mm2FovStroke = nil, nil
local orbitButton = nil
local dashButton = nil
local wallHopButton = nil
local currentHat = nil
local hatConnection = nil
local currentSword = nil
local orbitAngle = 0
local crosshairGui = nil
local originalAmbient = Lighting.Ambient
local originalOutdoor = Lighting.OutdoorAmbient
local lastTapTime = 0
local tapCount = 0
local lastHitInstance = nil
local lastFlickTime = 0
local mm2EspV3Folder = nil
local antiAimV3Mode = "Backwards"

-- OBSIDIAN ПЕРЕМЕННЫЕ
local obsidianData = {
    waypointGroups = { ["Default"] = { color = Color3.fromRGB(0, 170, 255), waypoints = {} } },
    waypointIndex = 1,
    pathfindingActive = false,
    currentPathThread = nil,
    isFlinging = false,
    voidPart = nil,
    godModeFirstRun = true,
    defaultHipHeight = 0,
    flyAnimTrack = nil,
    isFlying = false,
    lockedMousePos = nil,
    acEnabledTime = 0,
    actualAutoClicks = 0,
    teamSettings = {},
    playerDrawingData = {},
    selectedGroup = "Default",
    currentAllTarget = nil,
    espObsFolder = nil,
    selectedPlayer = "All",
}

-- КОННЕКТЫ
local connections = {}

-- ============================================================================
-- 🔧 ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ (ТВОИ)
-- ============================================================================

local function roundCorner(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = obj
end

local function ShowMessage(text)
    pcall(function()
        local msg = Instance.new("TextLabel", gui)
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
        s.ResetOnSpawn = false
        local f = Instance.new("Frame", s)
        f.Size = UDim2.new(0, 230, 0, 130)
        f.Position = UDim2.new(0.5, -115, 0.35, 0)
        f.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
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
        btn.BackgroundColor3 = guiSettings.OnColor
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
        s.ResetOnSpawn = false
        local f = Instance.new("Frame", s)
        f.Size = UDim2.new(0, 190, 0, 260)
        f.Position = UDim2.new(0.5, -95, 0.3, 0)
        f.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
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
-- 🔧 OBSIDIAN ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ============================================================================

local function getRoot(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function createMarker(pos, color)
    local p = Instance.new("Part")
    p.Shape = Enum.PartType.Ball
    p.Size = Vector3.new(2, 2, 2)
    p.Anchored = true
    p.CanCollide = false
    p.Material = Enum.Material.Neon
    p.Color = color
    p.Position = pos + Vector3.new(0, 2, 0)
    p.Parent = workspace
    return p
end

local function getRobustKeyCode(keyString)
    if type(keyString) ~= "string" or keyString == "" then return nil end
    local searchStr = keyString:gsub("%s+", ""):lower()
    for _, key in pairs(Enum.KeyCode:GetEnumItems()) do
        if key.Name:lower() == searchStr then return key end
    end
    return nil
end

local function isPlayerValid(plr)
    if not plr or plr == player or not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    local root = getRoot(plr.Character)
    if not hum or hum.Health <= 0 or not root then return false end
    return true
end

local function getNextValidPlayer(ignorePlr)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr ~= ignorePlr and isPlayerValid(plr) then
            return plr
        end
    end
    return nil
end

local function getActiveWaypoints()
    if toggles.obsidianUseGroupTp then
        local selGroup = obsidianData.selectedGroup or "Default"
        return obsidianData.waypointGroups[selGroup] and obsidianData.waypointGroups[selGroup].waypoints or {}
    else
        local allWps = {}
        for _, groupData in pairs(obsidianData.waypointGroups) do
            for _, wp in ipairs(groupData.waypoints) do
                table.insert(allWps, wp)
            end
        end
        return allWps
    end
end

local function stopPathfinding()
    obsidianData.pathfindingActive = false
    if obsidianData.currentPathThread then
        task.cancel(obsidianData.currentPathThread)
        obsidianData.currentPathThread = nil
    end
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = getRoot(char)
    if hum and root then hum:MoveTo(root.Position) end
end

local function walkToPosition(targetPos)
    stopPathfinding()
    obsidianData.pathfindingActive = true
    obsidianData.currentPathThread = task.spawn(function()
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = getRoot(char)
        if not hum or not root then obsidianData.pathfindingActive = false return end
        
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {char, workspace.CurrentCamera}

        while obsidianData.pathfindingActive do
            local distToTarget = (root.Position * Vector3.new(1,0,1) - targetPos * Vector3.new(1,0,1)).Magnitude
            if distToTarget < 2 then break end
            
            local path = PathfindingService:CreatePath({
                AgentRadius = 2,
                AgentHeight = 5,
                AgentCanJump = true,
                AgentWalkableClimb = 3
            })
            local success = pcall(function() path:ComputeAsync(root.Position, targetPos) end)
            local waypointsToFollow = {}
            if success and path.Status == Enum.PathStatus.Success then
                waypointsToFollow = path:GetWaypoints()
            else
                waypointsToFollow = {
                    {Position = root.Position, Action = Enum.PathWaypointAction.Walk},
                    {Position = targetPos, Action = Enum.PathWaypointAction.Walk}
                }
            end

            local isStuck = false
            for i = 2, #waypointsToFollow do
                if not obsidianData.pathfindingActive then break end
                local wp = waypointsToFollow[i]
                hum:MoveTo(wp.Position)
                if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end

                local startTime = tick()
                while obsidianData.pathfindingActive do
                    task.wait(0.05)
                    if (root.Position * Vector3.new(1,0,1) - wp.Position * Vector3.new(1,0,1)).Magnitude < 2 then break end
                    local fwd = hum.MoveDirection
                    if fwd.Magnitude > 0 then
                        local lookAhead = root.Position + (fwd * 4.5)
                        local rayDown = workspace:Raycast(lookAhead, Vector3.new(0, -15, 0), rayParams)
                        if not rayDown then hum.Jump = true end
                        if workspace:Raycast(root.Position, fwd * 3, rayParams) then hum.Jump = true end
                    end
                    if tick() - startTime > 2.5 then isStuck = true break end
                end
                if isStuck then break end
            end
            if isStuck and obsidianData.pathfindingActive then
                hum.Jump = true
                task.wait(0.5)
            end
        end
        obsidianData.pathfindingActive = false
    end)
end

local function moveToTarget(targetPos)
    if toggles.obsidianUsePathfinding then
        walkToPosition(targetPos)
    else
        stopPathfinding()
        local root = getRoot(player.Character)
        if root then root.CFrame = CFrame.new(targetPos) end
    end
end

-- ============================================================================
-- 🎯 ЯДРО ФУНКЦИЙ (ТВОИ ОРИГИНАЛЬНЫЕ)
-- ============================================================================

local function IsVisible(part)
    if guiSettings.AimbotWallbang then return true end
    local success, result = pcall(function()
        local parts = Camera:GetPartsObscuringTarget({part.Position}, {player.Character, part.Parent})
        return #parts == 0
    end)
    return success and result or false
end

local function FindBestTarget()
    local target, near = nil, guiSettings.AimbotFOV
    local mid = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    pcall(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
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

local function GetDmgRemote(tool)
    if not tool then return nil end
    for _, v in pairs(tool:GetDescendants()) do 
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then 
            local n = v.Name:lower() 
            if n:find("hit") or n:find("attack") or n:find("damage") or n:find("slash") or n:find("click") or n:find("fire") then 
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
        if toggles.hitGlow then 
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
    if not player.Character then return end 
    local tool = player.Character:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then 
        tool.Handle.Size = Vector3.new(guiSettings.ToolReachValue, guiSettings.ToolReachValue, guiSettings.ToolReachValue) 
        tool.Handle.CanCollide = false 
    end
end

local function getMM2Role(p)
    local char = p.Character
    local backpack = p:FindFirstChild("Backpack")
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
    
    if char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")) then isMurder = true end
    if char:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun")) then isSheriff = true end
    
    if isMurder then return "Murderer" end
    if isSheriff then return "Sheriff" end
    return "Innocent"
end

-- ============================================================================
-- 📋 ВСЕ ТВОИ ФУНКЦИИ MTY (БЕЗ ИЗМЕНЕНИЙ)
-- ============================================================================

-- [ВСТАВЬ СЮДА ВЕСЬ ТВОЙ ОРИГИНАЛЬНЫЙ КОД - от ToggleESP до TeleportToGun]
-- Я не буду его трогать, он полностью твой

-- ============================================================================
-- 📋 OBSIDIAN ФУНКЦИИ (ДЛЯ ВКЛАДКИ GG)
-- ============================================================================

function ToggleObsidianSpeed()
    toggles.obsidianSpeed = not toggles.obsidianSpeed
    if toggles.obsidianSpeed then
        ShowMessage("Obsidian Speed ON")
        if connections.obsidianSpeed then connections.obsidianSpeed:Disconnect() end
        connections.obsidianSpeed = RunService.RenderStepped:Connect(function()
            if toggles.obsidianSpeed and player.Character then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    local speed = tonumber(guiSettings.ObsidianSpeedValue) or 16
                    if hum.WalkSpeed ~= speed then hum.WalkSpeed = speed end
                end
            end
        end)
    else
        if connections.obsidianSpeed then connections.obsidianSpeed:Disconnect() end
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= 16 then hum.WalkSpeed = 16 end
        end
        ShowMessage("Obsidian Speed OFF")
    end
end

function ToggleObsidianJump()
    toggles.obsidianJump = not toggles.obsidianJump
    if toggles.obsidianJump then
        ShowMessage("Obsidian Jump ON")
        if connections.obsidianJump then connections.obsidianJump:Disconnect() end
        connections.obsidianJump = RunService.RenderStepped:Connect(function()
            if toggles.obsidianJump and player.Character then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    local jumpPower = tonumber(guiSettings.ObsidianJumpValue) or 50
                    hum.UseJumpPower = true
                    if hum.JumpPower ~= jumpPower then hum.JumpPower = jumpPower end
                end
            end
        end)
    else
        if connections.obsidianJump then connections.obsidianJump:Disconnect() end
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.JumpPower ~= 50 then hum.JumpPower = 50 end
        end
        ShowMessage("Obsidian Jump OFF")
    end
end

function ToggleObsidianFly()
    toggles.obsidianFly = not toggles.obsidianFly
    if toggles.obsidianFly then
        ShowMessage("Obsidian Fly ON")
        if connections.obsidianFly then connections.obsidianFly:Disconnect() end
        obsidianData.isFlying = true
        connections.obsidianFly = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not toggles.obsidianFly or not player.Character then
                    obsidianData.isFlying = false
                    return
                end
                local char = player.Character
                local root = getRoot(char)
                local hum = char:FindFirstChildOfClass("Humanoid")
                local cam = workspace.CurrentCamera
                if not root or not hum then return end
                
                local speed = tonumber(guiSettings.ObsidianFlySpeed) or 50
                local moveModule = require(player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
                local move = moveModule:GetMoveVector()
                local dir = cam.CFrame.RightVector * move.X - cam.CFrame.LookVector * move.Z
                if dir.Magnitude > 0 then dir = dir.Unit * speed end
                
                if not root:FindFirstChild("ObsidianFlyBV") then
                    local bv = Instance.new("BodyVelocity", root)
                    bv.Name = "ObsidianFlyBV"
                    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    local bg = Instance.new("BodyGyro", root)
                    bg.Name = "ObsidianFlyBG"
                    bg.P = 9e4
                    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                end
                root.ObsidianFlyBV.Velocity = dir
                root.ObsidianFlyBG.CFrame = cam.CFrame
                hum.PlatformStand = true
                
                if toggles.obsidianFlyAnim and hum then
                    local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
                    if not obsidianData.flyAnimTrack then
                        local fallAnim = char:WaitForChild("Animate"):WaitForChild("fall"):WaitForChild("FallAnim")
                        obsidianData.flyAnimTrack = animator:LoadAnimation(fallAnim)
                        obsidianData.flyAnimTrack.Priority = Enum.AnimationPriority.Action
                    end
                    if not obsidianData.flyAnimTrack.IsPlaying then
                        obsidianData.flyAnimTrack:Play()
                    end
                end
            end)
        end)
    else
        if connections.obsidianFly then connections.obsidianFly:Disconnect() end
        obsidianData.isFlying = false
        if player.Character then
            local root = getRoot(player.Character)
            if root then
                if root:FindFirstChild("ObsidianFlyBV") then root.ObsidianFlyBV:Destroy() end
                if root:FindFirstChild("ObsidianFlyBG") then root.ObsidianFlyBG:Destroy() end
            end
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
        if obsidianData.flyAnimTrack then
            obsidianData.flyAnimTrack:Stop()
            obsidianData.flyAnimTrack = nil
        end
        ShowMessage("Obsidian Fly OFF")
    end
end

function ToggleObsidianFlyAnim()
    toggles.obsidianFlyAnim = not toggles.obsidianFlyAnim
    if not toggles.obsidianFlyAnim and obsidianData.flyAnimTrack then
        obsidianData.flyAnimTrack:Stop()
        obsidianData.flyAnimTrack = nil
    end
    ShowMessage(toggles.obsidianFlyAnim and "Fly Animation ON" or "Fly Animation OFF")
end

function ToggleObsidianNoclip()
    toggles.obsidianNoclip = not toggles.obsidianNoclip
    if toggles.obsidianNoclip then
        ShowMessage("Obsidian Noclip ON")
        if connections.obsidianNoclip then connections.obsidianNoclip:Disconnect() end
        connections.obsidianNoclip = RunService.Stepped:Connect(function()
            if toggles.obsidianNoclip and player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if connections.obsidianNoclip then connections.obsidianNoclip:Disconnect() end
        ShowMessage("Obsidian Noclip OFF")
    end
end

function ToggleObsidianEsp()
    toggles.obsidianEspMaster = not toggles.obsidianEspMaster
    if toggles.obsidianEspMaster then
        ShowMessage("Obsidian ESP ON")
        if not obsidianData.espObsFolder then
            obsidianData.espObsFolder = Instance.new("Folder", workspace)
            obsidianData.espObsFolder.Name = "MTY_ObsidianESP"
        end
        obsidianData.teamSettings["ALL"] = { enabled = true, color = Color3.fromRGB(255, 0, 0) }
        for _, t in pairs(Teams:GetTeams()) do
            obsidianData.teamSettings[t.Name] = { enabled = true, color = Color3.fromRGB(255, 0, 0) }
        end
        task.spawn(function()
            while toggles.obsidianEspMaster do
                task.wait(0.2)
                pcall(function()
                    if obsidianData.espObsFolder then obsidianData.espObsFolder:ClearAllChildren() end
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= player and p.Character then
                            local team = p.Team and p.Team.Name or "ALL"
                            local color = obsidianData.teamSettings[team] and obsidianData.teamSettings[team].color or Color3.fromRGB(255,0,0)
                            if obsidianData.teamSettings[team] and obsidianData.teamSettings[team].enabled then
                                local h = Instance.new("Highlight", obsidianData.espObsFolder)
                                h.Adornee = p.Character
                                h.FillColor = color
                                h.OutlineColor = color
                                h.FillTransparency = 0.5
                                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            end
                        end
                    end
                end)
            end
        end)
    else
        if obsidianData.espObsFolder then obsidianData.espObsFolder:ClearAllChildren() end
        ShowMessage("Obsidian ESP OFF")
    end
end

function ToggleObsidianTracers()
    toggles.obsidianTracers = not toggles.obsidianTracers
    ShowMessage(toggles.obsidianTracers and "Tracers ON" or "Tracers OFF")
end

function ToggleObsidianHealthBar()
    toggles.obsidianHealthBar = not toggles.obsidianHealthBar
    ShowMessage(toggles.obsidianHealthBar and "Health Bar ON" or "Health Bar OFF")
end

function ToggleObsidianBoxEsp()
    toggles.obsidianBoxEsp = not toggles.obsidianBoxEsp
    ShowMessage(toggles.obsidianBoxEsp and "Box ESP ON" or "Box ESP OFF")
end

function ToggleObsidianSkeleton()
    toggles.obsidianSkeleton = not toggles.obsidianSkeleton
    ShowMessage(toggles.obsidianSkeleton and "Skeleton ON" or "Skeleton OFF")
end

-- Рендер для OBSIDIAN визуалов
local function clearObsidianDrawings()
    for plr, data in pairs(obsidianData.playerDrawingData) do
        if data.tracer then data.tracer:Remove() end
        if data.box then data.box:Remove() end
        if data.healthOutline then data.healthOutline:Remove() end
        if data.healthBar then data.healthBar:Remove() end
        if data.skeleton then
            for _, line in ipairs(data.skeleton) do line:Remove() end
        end
    end
    obsidianData.playerDrawingData = {}
end

local function createObsidianDrawings(plr)
    if obsidianData.playerDrawingData[plr] then return obsidianData.playerDrawingData[plr] end
    local data = {
        tracer = Drawing.new("Line"),
        box = Drawing.new("Square"),
        healthOutline = Drawing.new("Square"),
        healthBar = Drawing.new("Square"),
        skeleton = {
            Drawing.new("Line"), Drawing.new("Line"), 
            Drawing.new("Line"), Drawing.new("Line"), Drawing.new("Line")
        }
    }
    data.tracer.Thickness = 2
    data.box.Thickness = 1
    data.box.Filled = false
    data.healthOutline.Filled = true
    data.healthOutline.Thickness = 0
    data.healthOutline.ZIndex = 1
    data.healthBar.Filled = true
    data.healthBar.Thickness = 0
    data.healthBar.ZIndex = 2
    for _, line in ipairs(data.skeleton) do line.Thickness = 1.5 end
    obsidianData.playerDrawingData[plr] = data
    return data
end

RunService.RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera
    local tracerEsp = toggles.obsidianTracers
    local boxEsp = toggles.obsidianBoxEsp
    local healthEsp = toggles.obsidianHealthBar
    local skeletonEsp = toggles.obsidianSkeleton
    
    if not (tracerEsp or boxEsp or healthEsp or skeletonEsp) then
        for plr, data in pairs(obsidianData.playerDrawingData) do
            if data.tracer then data.tracer.Visible = false end
            if data.box then data.box.Visible = false end
            if data.healthOutline then data.healthOutline.Visible = false end
            if data.healthBar then data.healthBar.Visible = false end
            if data.skeleton then
                for _, l in ipairs(data.skeleton) do l.Visible = false end
            end
        end
        return
    end

    local viewX, viewY = camera.ViewportSize.X, camera.ViewportSize.Y
    local screenCenter = Vector2.new(viewX / 2, viewY / 2)
    local originMode = guiSettings.ObsidianTracerOrigin or "Default"
    local startX, startY
    
    if originMode == "Bottom" then
        startX = viewX / 2; startY = viewY
    elseif originMode == "Bottom Right" then
        startX = viewX; startY = viewY
    else
        startX = viewX / 2; startY = viewY - 120
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local myRootPos, myCharOnScreen = camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if myCharOnScreen then startX = myRootPos.X; startY = myRootPos.Y end
        end
    end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local team = plr.Team and plr.Team.Name or "ALL"
            local teamData = obsidianData.teamSettings[team]
            
            if root and hum and teamData and teamData.enabled then
                local data = createObsidianDrawings(plr)
                local enemyPos, onScreen = camera:WorldToViewportPoint(root.Position)
                local color = teamData.color
                
                if onScreen then
                    local topPos = camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
                    local bottomPos = camera:WorldToViewportPoint(root.Position + Vector3.new(0, -3.5, 0))
                    local boxHeight = math.abs(topPos.Y - bottomPos.Y)
                    local boxWidth = boxHeight * 0.6
                    local boxX = enemyPos.X - (boxWidth / 2)
                    local boxY = topPos.Y
                    
                    if boxEsp then
                        data.box.Position = Vector2.new(boxX, boxY)
                        data.box.Size = Vector2.new(boxWidth, boxHeight)
                        data.box.Color = color
                        data.box.Visible = true
                    else data.box.Visible = false end
                    
                    if healthEsp then
                        local maxHealth = (hum.MaxHealth > 0) and hum.MaxHealth or 100
                        local healthPct = math.clamp(hum.Health / maxHealth, 0, 1)
                        local barHeight = math.floor(boxHeight * healthPct)
                        data.healthOutline.Position = Vector2.new(boxX - 6, boxY - 1)
                        data.healthOutline.Size = Vector2.new(3, boxHeight + 2)
                        data.healthOutline.Color = Color3.fromRGB(0, 0, 0)
                        data.healthOutline.Visible = true
                        data.healthBar.Position = Vector2.new(boxX - 5, boxY + (boxHeight - barHeight))
                        data.healthBar.Size = Vector2.new(1, barHeight)
                        data.healthBar.Color = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), healthPct)
                        data.healthBar.Visible = true
                    else data.healthOutline.Visible = false; data.healthBar.Visible = false end

                    if skeletonEsp then
                        local joints = {
                            Head = char:FindFirstChild("Head"),
                            Torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"),
                            LeftArm = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm"),
                            RightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm"),
                            LeftLeg = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftUpperLeg"),
                            RightLeg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightUpperLeg")
                        }
                        local connectionsList = {
                            {joints.Head, joints.Torso},
                            {joints.Torso, joints.LeftArm},
                            {joints.Torso, joints.RightArm},
                            {joints.Torso, joints.LeftLeg},
                            {joints.Torso, joints.RightLeg}
                        }
                        for idx, conn in ipairs(connectionsList) do
                            local p1, p2 = conn[1], conn[2]
                            local line = data.skeleton[idx]
                            if p1 and p2 then
                                local pos1, os1 = camera:WorldToViewportPoint(p1.Position)
                                local pos2, os2 = camera:WorldToViewportPoint(p2.Position)
                                if os1 or os2 then
                                    line.From = Vector2.new(pos1.X, pos1.Y)
                                    line.To = Vector2.new(pos2.X, pos2.Y)
                                    line.Color = color
                                    line.Visible = true
                                else line.Visible = false end
                            else line.Visible = false end
                        end
                    else for _, l in ipairs(data.skeleton) do l.Visible = false end end

                    if tracerEsp then
                        data.tracer.From = Vector2.new(startX, startY)
                        data.tracer.To = Vector2.new(enemyPos.X, enemyPos.Y)
                        data.tracer.Color = color
                        data.tracer.Visible = true
                    else data.tracer.Visible = false end
                else
                    if data.box then data.box.Visible = false end
                    if data.healthOutline then data.healthOutline.Visible = false end
                    if data.healthBar then data.healthBar.Visible = false end
                    if data.skeleton then for _, l in ipairs(data.skeleton) do l.Visible = false end end
                    if tracerEsp then
                        local targetPos = Vector2.new(enemyPos.X, enemyPos.Y)
                        if enemyPos.Z < 0 then targetPos = screenCenter + (screenCenter - targetPos) end
                        local direction = (targetPos - screenCenter).Unit
                        local tMaxX = direction.X > 0 and (viewX - screenCenter.X) / direction.X or (0 - screenCenter.X) / direction.X
                        local tMaxY = direction.Y > 0 and (viewY - screenCenter.Y) / direction.Y or (0 - screenCenter.Y) / direction.Y
                        local tMin = math.min(math.abs(tMaxX), math.abs(tMaxY))
                        local edgePos = screenCenter + direction * tMin
                        data.tracer.From = Vector2.new(startX, startY)
                        data.tracer.To = Vector2.new(edgePos.X, edgePos.Y)
                        data.tracer.Color = color
                        data.tracer.Visible = true
                    else data.tracer.Visible = false end
                end
            end
        end
    end
end)

function ToggleObsidianWaypointEsp()
    toggles.obsidianWaypointEsp = not toggles.obsidianWaypointEsp
    if toggles.obsidianWaypointEsp then
        for groupName, groupData in pairs(obsidianData.waypointGroups) do
            for _, wp in ipairs(groupData.waypoints) do
                if wp.marker then
                    local h = Instance.new("Highlight", wp.marker)
                    h.Name = "WpHighlight"
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.FillTransparency = 0.4
                    h.OutlineTransparency = 0
                    h.FillColor = groupData.color
                    h.OutlineColor = groupData.color
                end
            end
        end
        ShowMessage("Waypoint ESP ON")
    else
        for _, groupData in pairs(obsidianData.waypointGroups) do
            for _, wp in ipairs(groupData.waypoints) do
                if wp.marker then
                    local h = wp.marker:FindFirstChild("WpHighlight")
                    if h then h:Destroy() end
                end
            end
        end
        ShowMessage("Waypoint ESP OFF")
    end
end

function AddObsidianWaypoint()
    local root = getRoot(player.Character)
    if not root then return end
    local selGroup = obsidianData.selectedGroup or "Default"
    local group = obsidianData.waypointGroups[selGroup]
    if not group then return end
    local name = "Waypoint " .. (#group.waypoints + 1)
    local marker = createMarker(root.Position, group.color)
    table.insert(group.waypoints, {name = name, pos = root.Position, marker = marker})
    if toggles.obsidianWaypointEsp then
        local h = Instance.new("Highlight", marker)
        h.Name = "WpHighlight"
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.FillTransparency = 0.4
        h.OutlineTransparency = 0
        h.FillColor = group.color
        h.OutlineColor = group.color
    end
    ShowMessage("Waypoint added to " .. selGroup)
end

function DeleteObsidianWaypoint()
    local selGroup = obsidianData.selectedGroup or "Default"
    local group = obsidianData.waypointGroups[selGroup]
    if not group or #group.waypoints == 0 then return end
    local last = group.waypoints[#group.waypoints]
    if last.marker then last.marker:Destroy() end
    table.remove(group.waypoints)
    if obsidianData.waypointIndex > #group.waypoints then obsidianData.waypointIndex = 1 end
    ShowMessage("Last waypoint deleted")
end

function TeleportToSelectedWaypoint()
    local selGroup = obsidianData.selectedGroup or "Default"
    local group = obsidianData.waypointGroups[selGroup]
    if not group or #group.waypoints == 0 then return end
    local target = group.waypoints[1]
    moveToTarget(target.pos)
end

function ToggleObsidianAutoTp()
    toggles.obsidianAutoTp = not toggles.obsidianAutoTp
    if not toggles.obsidianAutoTp then stopPathfinding() end
    ShowMessage(toggles.obsidianAutoTp and "Auto TP ON" or "Auto TP OFF")
end

function ToggleObsidianUsePathfinding()
    toggles.obsidianUsePathfinding = not toggles.obsidianUsePathfinding
    if not toggles.obsidianUsePathfinding then stopPathfinding() end
    ShowMessage(toggles.obsidianUsePathfinding and "Pathfinding ON" or "Pathfinding OFF")
end

function TeleportToPlayer()
    local targetName = obsidianData.selectedPlayer or "All"
    local targetPlr = nil
    if targetName == "All" then
        targetPlr = getNextValidPlayer()
    else
        targetPlr = Players:FindFirstChild(targetName)
    end
    if targetPlr and isPlayerValid(targetPlr) then
        local targetRoot = getRoot(targetPlr.Character)
        local myRoot = getRoot(player.Character)
        if myRoot and targetRoot then
            local oX = guiSettings.ObsidianOffsetX or 0
            local oY = guiSettings.ObsidianOffsetY or 0
            local oZ = guiSettings.ObsidianOffsetZ or 0
            myRoot.CFrame = targetRoot.CFrame * CFrame.new(oX, oY, oZ)
        end
    end
end

function ToggleObsidianLoopPlayerTp()
    toggles.obsidianLoopPlayerTp = not toggles.obsidianLoopPlayerTp
    ShowMessage(toggles.obsidianLoopPlayerTp and "Loop Player TP ON" or "Loop Player TP OFF")
end

function ToggleObsidianAutoTpNext()
    toggles.obsidianAutoTpNext = not toggles.obsidianAutoTpNext
    ShowMessage(toggles.obsidianAutoTpNext and "Auto Next ON" or "Auto Next OFF")
end

RunService.RenderStepped:Connect(function()
    if toggles.obsidianLoopPlayerTp then
        local targetName = obsidianData.selectedPlayer or "All"
        local targetPlr = nil
        if targetName == "All" then
            if not isPlayerValid(obsidianData.currentAllTarget) then
                obsidianData.currentAllTarget = getNextValidPlayer()
            end
            targetPlr = obsidianData.currentAllTarget
        else
            targetPlr = Players:FindFirstChild(targetName)
            if toggles.obsidianAutoTpNext and not isPlayerValid(targetPlr) then
                local nextPlr = getNextValidPlayer(targetPlr)
                if nextPlr then
                    obsidianData.selectedPlayer = nextPlr.Name
                    targetPlr = nextPlr
                end
            end
        end
        if targetPlr and isPlayerValid(targetPlr) then
            local targetRoot = getRoot(targetPlr.Character)
            local myRoot = getRoot(player.Character)
            if myRoot and targetRoot then
                myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                local oX = guiSettings.ObsidianOffsetX or 0
                local oY = guiSettings.ObsidianOffsetY or 0
                local oZ = guiSettings.ObsidianOffsetZ or 0
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(oX, oY, oZ)
            end
        end
    end
end)

function ToggleObsidianAC()
    toggles.obsidianAcToggle = not toggles.obsidianAcToggle
    if toggles.obsidianAcToggle then
        obsidianData.acEnabledTime = tick()
        ShowMessage("Auto Clicker ON")
    else
        obsidianData.lockedMousePos = nil
        ShowMessage("Auto Clicker OFF")
    end
end

task.spawn(function()
    while true do
        local targetCps = tonumber(guiSettings.ObsidianCPS) or 10
        if targetCps <= 60 then task.wait(1 / targetCps) else task.wait() end
        if toggles.obsidianAcToggle then
            if tick() - obsidianData.acEnabledTime >= 1 then
                if not obsidianData.lockedMousePos then
                    obsidianData.lockedMousePos = UserInputService:GetMouseLocation()
                end
                local mode = guiSettings.ObsidianACMode or "Left Click"
                local clicksThisFrame = targetCps <= 60 and 1 or math.floor(targetCps / 60)
                for i = 1, clicksThisFrame do
                    if mode == "Left Click" then
                        VirtualInputManager:SendMouseButtonEvent(obsidianData.lockedMousePos.X, obsidianData.lockedMousePos.Y, 0, true, game, 0)
                        VirtualInputManager:SendMouseButtonEvent(obsidianData.lockedMousePos.X, obsidianData.lockedMousePos.Y, 0, false, game, 0)
                    elseif mode == "Right Click" then
                        VirtualInputManager:SendMouseButtonEvent(obsidianData.lockedMousePos.X, obsidianData.lockedMousePos.Y, 1, true, game, 0)
                        VirtualInputManager:SendMouseButtonEvent(obsidianData.lockedMousePos.X, obsidianData.lockedMousePos.Y, 1, false, game, 0)
                    elseif mode == "Keyboard Key" then
                        local keyCode = getRobustKeyCode(guiSettings.ObsidianACKey or "E")
                        if keyCode then
                            VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
                            if targetCps <= 60 then task.wait(0.01) end
                            VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
                        end
                    end
                    obsidianData.actualAutoClicks = obsidianData.actualAutoClicks + 1
                end
            end
        else
            obsidianData.lockedMousePos = nil
        end
    end
end)

function ToggleObsidianFb()
    toggles.obsidianFbMaster = not toggles.obsidianFbMaster
    ShowMessage(toggles.obsidianFbMaster and "Fullbright ON" or "Fullbright OFF")
end

RunService.RenderStepped:Connect(function()
    if toggles.obsidianFbMaster then
        Lighting.Brightness = 3
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.ClockTime = 14
    elseif toggles.obsidianAutoFb then
        if Lighting.ClockTime <= 6 or Lighting.ClockTime >= 18 then
            Lighting.Brightness = 3
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        end
    end
    if toggles.obsidianNoShadows then
        Lighting.GlobalShadows = false
    end
    if toggles.obsidianNoFog then
        Lighting.FogEnd = 100000
    end
end)

function ToggleObsidianAutoFb()
    toggles.obsidianAutoFb = not toggles.obsidianAutoFb
    ShowMessage(toggles.obsidianAutoFb and "Auto Fullbright ON" or "Auto Fullbright OFF")
end

function ToggleObsidianNoShadows()
    toggles.obsidianNoShadows = not toggles.obsidianNoShadows
    ShowMessage(toggles.obsidianNoShadows and "No Shadows ON" or "No Shadows OFF")
end

function ToggleObsidianNoFog()
    toggles.obsidianNoFog = not toggles.obsidianNoFog
    ShowMessage(toggles.obsidianNoFog and "No Fog ON" or "No Fog OFF")
end

function ToggleObsidianWalkfling()
    toggles.obsidianWalkfling = not toggles.obsidianWalkfling
    if toggles.obsidianWalkfling then
        ShowMessage("Walkfling ON")
        obsidianData.isFlinging = true
        task.spawn(function()
            local movel = 0.1
            while obsidianData.isFlinging and toggles.obsidianWalkfling do
                RunService.Heartbeat:Wait()
                local c = player.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local vel = hrp.Velocity
                    hrp.Velocity = Vector3.new(0, 10000, 0) * 100
                    RunService.RenderStepped:Wait()
                    hrp.Velocity = vel
                    RunService.Stepped:Wait()
                    hrp.Velocity = vel + Vector3.new(0, movel, 0)
                    movel = -movel
                end
            end
        end)
    else
        obsidianData.isFlinging = false
        ShowMessage("Walkfling OFF")
    end
end

function ToggleObsidianNoVoid()
    toggles.obsidianNoVoid = not toggles.obsidianNoVoid
    if toggles.obsidianNoVoid then
        if not obsidianData.voidPart then
            obsidianData.voidPart = Instance.new("Part")
            obsidianData.voidPart.Name = "MTY_NoVoid"
            obsidianData.voidPart.Anchored = true
            obsidianData.voidPart.CanCollide = true
            obsidianData.voidPart.Transparency = 1
            obsidianData.voidPart.Size = Vector3.new(100000, 5, 100000)
            local destroyHeight = workspace.FallenPartsDestroyHeight
            obsidianData.voidPart.Position = Vector3.new(0, destroyHeight + 50, 0)
            obsidianData.voidPart.Parent = workspace
        end
        ShowMessage("No Void ON")
    else
        if obsidianData.voidPart then
            obsidianData.voidPart:Destroy()
            obsidianData.voidPart = nil
        end
        ShowMessage("No Void OFF")
    end
end

function ToggleObsidianGodMode()
    toggles.obsidianGodMode = not toggles.obsidianGodMode
    if toggles.obsidianGodMode then
        if obsidianData.godModeFirstRun then
            guiSettings.ObsidianHipHeight = 2
            obsidianData.godModeFirstRun = false
        end
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            end
        end
        ShowMessage("God Mode ON")
    else
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                if obsidianData.defaultHipHeight > 0 then
                    hum.HipHeight = obsidianData.defaultHipHeight
                end
            end
        end
        ShowMessage("God Mode OFF")
    end
end

RunService.RenderStepped:Connect(function()
    if toggles.obsidianGodMode then
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            if guiSettings.ObsidianHipHeight then
                hum.HipHeight = guiSettings.ObsidianHipHeight
            end
        end
    end
end)

function ToggleObsidianNoPromptCooldown()
    toggles.obsidianNoPromptCooldown = not toggles.obsidianNoPromptCooldown
    ShowMessage(toggles.obsidianNoPromptCooldown and "No Prompt Cooldown ON" or "No Prompt Cooldown OFF")
end

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    if toggles.obsidianNoPromptCooldown then
        prompt.HoldDuration = 0
    end
end)

task.spawn(function()
    while true do
        task.wait(tonumber(guiSettings.ObsidianAutoTpDelay) or 2)
        if toggles.obsidianAutoTp then
            local activeWps = getActiveWaypoints()
            if #activeWps > 0 then
                if toggles.obsidianUsePathfinding then
                    if not obsidianData.pathfindingActive then
                        if obsidianData.waypointIndex > #activeWps then obsidianData.waypointIndex = 1 end
                        local target = activeWps[obsidianData.waypointIndex]
                        moveToTarget(target.pos)
                        obsidianData.waypointIndex = obsidianData.waypointIndex + 1
                        if obsidianData.waypointIndex > #activeWps then obsidianData.waypointIndex = 1 end
                    end
                else
                    if obsidianData.waypointIndex > #activeWps then obsidianData.waypointIndex = 1 end
                    local target = activeWps[obsidianData.waypointIndex]
                    moveToTarget(target.pos)
                    obsidianData.waypointIndex = obsidianData.waypointIndex + 1
                    if obsidianData.waypointIndex > #activeWps then obsidianData.waypointIndex = 1 end
                end
            end
        end
    end
end)

-- ============================================================================
-- 🏗️ ПОСТРОЕНИЕ GUI (ТВОЙ ОРИГИНАЛЬНЫЙ + 5-я ВКЛАДКА GG)
-- ============================================================================

-- [ВСТАВЬ СЮДА ВЕСЬ ТВОЙ ОРИГИНАЛЬНЫЙ КОД ПОСТРОЕНИЯ GUI]
-- Он начинается с "local function roundCorner" и до конца
-- НО с изменением: добавить 5-ю вкладку "GG"

-- Я даю тебе ОСНОВНУЮ ЧАСТЬ, а ты просто вставь свои кнопки в 4 вкладки

-- ОСНОВНАЯ РАМКА
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 233, 0, 167)
mainFrame.Position = UDim2.new(0.5, -117, 0.5, -84)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = guiSettings.BorderColor
mainFrame.Parent = gui
roundCorner(mainFrame, 8)

-- РАМКА ДЛЯ НАЗВАНИЯ
local titleFrame = Instance.new("Frame")
titleFrame.Size = UDim2.new(0, 70, 0, 18)
titleFrame.Position = UDim2.new(0, 5, 0, 4)
titleFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
titleFrame.BorderSizePixel = 1
titleFrame.BorderColor3 = guiSettings.BorderColor
titleFrame.Parent = mainFrame
roundCorner(titleFrame, 4)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 70, 0, 18)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "мти хаб"
title.TextColor3 = Color3.fromRGB(200, 200, 200)
title.TextSize = 8
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = titleFrame

-- ВКЛАДКИ (ТЕПЕРЬ 5! VIS, CMB, MOV, MM2, GG)
local tabs = {}
local tabNames = {"VIS", "CMB", "MOV", "MM2", "GG"}
for i = 1, 5 do
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(0, 34, 0, 18)
    tab.Position = UDim2.new(0, 5, 0, 28 + (i-1) * 22)
    tab.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    tab.BorderSizePixel = 1
    tab.BorderColor3 = guiSettings.BorderColor
    tab.Text = tabNames[i]
    tab.TextColor3 = Color3.fromRGB(180, 180, 180)
    tab.TextSize = 5
    tab.Font = Enum.Font.Gotham
    tab.AutoButtonColor = false
    tab.Parent = mainFrame
    roundCorner(tab, 4)
    tabs[i] = tab
end

-- SCROLLINGFRAME
local function createScrollingFrame(parent, posX, posY, width, height)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(0, width, 0, height)
    scrollFrame.Position = UDim2.new(0, posX, 0, posY)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
    scrollFrame.BorderSizePixel = 1
    scrollFrame.BorderColor3 = guiSettings.BorderColor
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = guiSettings.BorderColor
    scrollFrame.ScrollBarImageTransparency = 0.2
    scrollFrame.Parent = parent
    roundCorner(scrollFrame, 4)
    return scrollFrame
end

local scrolls = {}
for i = 1, 5 do
    local sc = createScrollingFrame(mainFrame, 50, 28, 173, 118)
    if i > 1 then sc.Visible = false end
    scrolls[i] = sc
end

-- ===== ФУНКЦИЯ СОЗДАНИЯ КНОПКИ С ПЕРЕКЛЮЧАТЕЛЕМ =====
local function createToggleButton(parent, text, toggleFunc, x, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 73, 0, 27)
    btn.Position = UDim2.new(0, x or 5, 0, y or 5)
    btn.BackgroundColor3 = guiSettings.OffColor
    btn.BorderSizePixel = 1
    btn.BorderColor3 = guiSettings.BorderColor
    btn.Text = text .. " OFF"
    btn.TextColor3 = guiSettings.TextColor
    btn.TextSize = 6
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = parent
    roundCorner(btn, 4)
    
    btn.MouseButton1Click:Connect(function()
        toggleFunc()
        if toggles[text:gsub(" ", ""):lower()] then
            btn.BackgroundColor3 = guiSettings.OnColor
            btn.Text = text .. " ON"
        else
            btn.BackgroundColor3 = guiSettings.OffColor
            btn.Text = text .. " OFF"
        end
    end)
    
    return btn
end

-- ===== ДОБАВЛЯЕМ КНОПКИ =====
local function addButtons(scrollFrame, buttons, startX, startY)
    local yOffset = startY or 5
    local btnWidth = 73
    local btnHeight = 27
    local spacingX = 8
    local spacingY = 6
    local cols = 2
    local xOffset = startX or 5
    
    for i, data in ipairs(buttons) do
        local col = (i-1) % cols
        local row = math.floor((i-1) / cols)
        local x = xOffset + col * (btnWidth + spacingX)
        local y = yOffset + row * (btnHeight + spacingY)
        
        if data.isToggle then
            createToggleButton(scrollFrame, data.text, data.func, x, y)
        else
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, btnWidth, 0, btnHeight)
            btn.Position = UDim2.new(0, x, 0, y)
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            btn.BorderSizePixel = 1
            btn.BorderColor3 = guiSettings.BorderColor
            btn.Text = data.text
            btn.TextColor3 = guiSettings.TextColor
            btn.TextSize = 6
            btn.Font = Enum.Font.GothamBold
            btn.AutoButtonColor = false
            roundCorner(btn, 4)
            btn.MouseButton1Click:Connect(data.func)
            btn.Parent = scrollFrame
        end
    end
    
    local totalRows = math.ceil(#buttons / cols)
    local totalHeight = yOffset + totalRows * (btnHeight + spacingY) + 5
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

-- ===== КАТЕГОРИИ (ТВОИ 4 + GG) =====
local categories = {
    -- VISUAL (ТВОИ КНОПКИ - вставь свои)
    {
        {text = "ESP", func = ToggleESP, isToggle = true},
        {text = "ESP V2", func = ToggleESPV2, isToggle = true},
        {text = "Jump Circle", func = ToggleJumpCircle, isToggle = true},
        {text = "Trail", func = ToggleTrail, isToggle = true},
        {text = "Trail V2", func = ToggleTrailV2, isToggle = true},
        {text = "China Hat", func = ToggleChineseHat, isToggle = true},
        {text = "World Color", func = ToggleWorldColor, isToggle = true},
        {text = "Stretch", func = ToggleStretch, isToggle = true},
        {text = "Stretch V2", func = ToggleStretchV2, isToggle = true},
        {text = "HitGlow", func = ToggleHitGlow, isToggle = true},
        {text = "Fullbright", func = ToggleFullbright, isToggle = true},
        {text = "Particles V1", func = ToggleParticlesV1, isToggle = true},
        {text = "Particles V2", func = ToggleParticlesV2, isToggle = true},
        {text = "Classic Sword", func = ToggleClassicSword, isToggle = true},
        {text = "World Colors", func = ToggleWorldColors, isToggle = true},
        {text = "Fog", func = ToggleFog, isToggle = true},
        {text = "Night Vision", func = ToggleNightVision, isToggle = true},
        {text = "Thermal Vision", func = ToggleThermalVision, isToggle = true},
        {text = "Rainbow World", func = ToggleRainbowWorld, isToggle = true},
        {text = "Crosshair", func = ToggleCrosshair, isToggle = true},
        {text = "Hitboxes", func = ToggleHitboxes, isToggle = true},
        {text = "Hitbox Expander", func = ToggleHitboxExpander, isToggle = true},
    },
    -- COMBAT (ТВОИ КНОПКИ - вставь свои)
    {
        {text = "Aimbot", func = ToggleAimbot, isToggle = true},
        {text = "Aimbot V2", func = ToggleAimbotV2, isToggle = true},
        {text = "Aimbot V3", func = ToggleAimbotV3, isToggle = true},
        {text = "Kill Aura", func = ToggleKillAura, isToggle = true},
        {text = "Kill Aura V2", func = ToggleKillAuraV2, isToggle = true},
        {text = "Orbit Kill Aura", func = ToggleOrbitKillAura, isToggle = true},
        {text = "Trigger Bot", func = ToggleTriggerBot, isToggle = true},
        {text = "Anti-Aim V2", func = ToggleAntiAim, isToggle = true},
        {text = "Anti-Aim V3", func = ToggleAntiAimV3, isToggle = true},
        {text = "Desync", func = ToggleDesync, isToggle = true},
        {text = "Fake Lag", func = ToggleFakeLag, isToggle = true},
        {text = "Anti-Knockback", func = ToggleAntiKb, isToggle = true},
    },
    -- MOVEMENT (ТВОИ КНОПКИ - вставь свои)
    {
        {text = "Speed", func = ToggleSpeed, isToggle = true},
        {text = "Set Speed", func = function() OpenTextInput("Speed", "16-200", speedValue, function(v) speedValue = v if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = v end end) end, isToggle = false},
        {text = "Gravity", func = function() OpenTextInput("Gravity", "Workspace", workspace.Gravity, function(v) workspace.Gravity = v end) end, isToggle = false},
        {text = "Fly Speed", func = function() OpenTextInput("Fly Speed", "10-200", flySpeed, function(v) flySpeed = v end) end, isToggle = false},
        {text = "Infinite Jump", func = ToggleInfiniteJump, isToggle = true},
        {text = "Air Walk", func = ToggleAirWalk, isToggle = true},
        {text = "Fly V1", func = ToggleFlyV1, isToggle = true},
        {text = "Fly V2", func = ToggleFlyV2, isToggle = true},
        {text = "Teleport Tool", func = ToggleTeleportTool, isToggle = true},
        {text = "Auto Sprint", func = ToggleAutoSprint, isToggle = true},
        {text = "NoClip", func = ToggleNoClip, isToggle = true},
        {text = "Spider Mode", func = ToggleSpider, isToggle = true},
        {text = "Swim In Air", func = ToggleSwim, isToggle = true},
        {text = "Dash", func = ToggleDash, isToggle = true},
        {text = "Invisibility", func = ToggleInvisibility, isToggle = true},
        {text = "Helicopter", func = ToggleHelicopter, isToggle = true},
        {text = "R6 Animations", func = ToggleR6Animations, isToggle = true},
        {text = "BunnyHop", func = ToggleBunnyHop, isToggle = true},
        {text = "Speed Glitch", func = ToggleSpeedGlitch, isToggle = true},
        {text = "Wall Hop", func = function() if not wallHopButton then CreateWallHopButton() end ToggleWallHop() if wallHopButton then wallHopButton.BackgroundColor3 = toggles.wallHop and guiSettings.OnColor or guiSettings.OffColor end end, isToggle = true},
        {text = "Walk Fling", func = ToggleWalkFling, isToggle = true},
        {text = "Auto Fling", func = ToggleAutoFling, isToggle = true},
        {text = "Fling By Name", func = function() OpenTextInput("Fling By Name", "Enter name", "", FlingByName) end, isToggle = false},
        {text = "Fling All", func = FlingAll, isToggle = false},
        {text = "Fling Up", func = FlingUp, isToggle = false},
        {text = "Fling Forward", func = FlingForward, isToggle = false},
        {text = "Fling Random", func = FlingRandom, isToggle = false},
        {text = "Super Fling", func = SuperFling, isToggle = false},
        {text = "IY Fling", func = OpenIYFling, isToggle = false},
        {text = "IY Goto", func = OpenIYGoto, isToggle = false},
        {text = "Fling All Up", func = FlingAllUp, isToggle = false},
        {text = "Fling All Random", func = FlingAllRandom, isToggle = false},
        {text = "Fling Last", func = FlingLastPlayer, isToggle = false},
    },
    -- MM2 (ТВОИ КНОПКИ - вставь свои)
    {
        {text = "MM2 ESP V2", func = ToggleMM2EspV2, isToggle = true},
        {text = "MM2 ESP V3", func = ToggleMM2EspV3, isToggle = true},
        {text = "MM2 Aimbot V2", func = ToggleMM2AimbotV2, isToggle = true},
        {text = "Double Tap", func = ToggleDoubleTap, isToggle = true},
        {text = "Auto Stab", func = ToggleAutoStab, isToggle = true},
        {text = "Coin Farm", func = ToggleCoinFarm, isToggle = true},
        {text = "Teleport Gun", func = TeleportToGun, isToggle = false},
    },
    -- GG (OBSIDIAN - ВСЕ ФУНКЦИИ)
    {
        {text = "Speed", func = ToggleObsidianSpeed, isToggle = true},
        {text = "Jump", func = ToggleObsidianJump, isToggle = true},
        {text = "Fly", func = ToggleObsidianFly, isToggle = true},
        {text = "Fly Anim", func = ToggleObsidianFlyAnim, isToggle = true},
        {text = "Noclip", func = ToggleObsidianNoclip, isToggle = true},
        {text = "ESP", func = ToggleObsidianEsp, isToggle = true},
        {text = "Tracers", func = ToggleObsidianTracers, isToggle = true},
        {text = "Health Bar", func = ToggleObsidianHealthBar, isToggle = true},
        {text = "Box ESP", func = ToggleObsidianBoxEsp, isToggle = true},
        {text = "Skeleton", func = ToggleObsidianSkeleton, isToggle = true},
        {text = "Waypoint ESP", func = ToggleObsidianWaypointEsp, isToggle = true},
        {text = "Add Waypoint", func = AddObsidianWaypoint, isToggle = false},
        {text = "Delete Last", func = DeleteObsidianWaypoint, isToggle = false},
        {text = "TP to Sel", func = TeleportToSelectedWaypoint, isToggle = false},
        {text = "Auto TP", func = ToggleObsidianAutoTp, isToggle = true},
        {text = "Pathfinding", func = ToggleObsidianUsePathfinding, isToggle = true},
        {text = "TP to Player", func = TeleportToPlayer, isToggle = false},
        {text = "Loop TP", func = ToggleObsidianLoopPlayerTp, isToggle = true},
        {text = "Auto Next", func = ToggleObsidianAutoTpNext, isToggle = true},
        {text = "Auto Clicker", func = ToggleObsidianAC, isToggle = true},
        {text = "Fullbright", func = ToggleObsidianFb, isToggle = true},
        {text = "Auto FB", func = ToggleObsidianAutoFb, isToggle = true},
        {text = "No Shadows", func = ToggleObsidianNoShadows, isToggle = true},
        {text = "No Fog", func = ToggleObsidianNoFog, isToggle = true},
        {text = "Walkfling", func = ToggleObsidianWalkfling, isToggle = true},
        {text = "No Void", func = ToggleObsidianNoVoid, isToggle = true},
        {text = "God Mode", func = ToggleObsidianGodMode, isToggle = true},
        {text = "No Prompt CD", func = ToggleObsidianNoPromptCooldown, isToggle = true},
        {text = "Speed Val", func = function() OpenTextInput("Speed Value", "16-500", guiSettings.ObsidianSpeedValue, function(v) guiSettings.ObsidianSpeedValue = v end) end, isToggle = false},
        {text = "Jump Val", func = function() OpenTextInput("Jump Value", "50-500", guiSettings.ObsidianJumpValue, function(v) guiSettings.ObsidianJumpValue = v end) end, isToggle = false},
        {text = "Fly Val", func = function() OpenTextInput("Fly Value", "10-300", guiSettings.ObsidianFlySpeed, function(v) guiSettings.ObsidianFlySpeed = v end) end, isToggle = false},
        {text = "CPS", func = function() OpenTextInput("CPS", "1-1000", guiSettings.ObsidianCPS, function(v) guiSettings.ObsidianCPS = v end) end, isToggle = false},
        {text = "AC Key", func = function() OpenTextInput("AC Key", "E, Space...", guiSettings.ObsidianACKey, function(v) guiSettings.ObsidianACKey = v end) end, isToggle = false},
        {text = "TP Delay", func = function() OpenTextInput("TP Delay", "1-10", guiSettings.ObsidianAutoTpDelay, function(v) guiSettings.ObsidianAutoTpDelay = v end) end, isToggle = false},
        {text = "Hip Height", func = function() OpenTextInput("Hip Height", "0-50", guiSettings.ObsidianHipHeight, function(v) guiSettings.ObsidianHipHeight = v end) end, isToggle = false},
        {text = "Offset X", func = function() OpenTextInput("Offset X", "-50 to 50", guiSettings.ObsidianOffsetX, function(v) guiSettings.ObsidianOffsetX = v end) end, isToggle = false},
        {text = "Offset Y", func = function() OpenTextInput("Offset Y", "-50 to 50", guiSettings.ObsidianOffsetY, function(v) guiSettings.ObsidianOffsetY = v end) end, isToggle = false},
        {text = "Offset Z", func = function() OpenTextInput("Offset Z", "-50 to 50", guiSettings.ObsidianOffsetZ, function(v) guiSettings.ObsidianOffsetZ = v end) end, isToggle = false},
        {text = "Tracer Orig", func = function() 
            local modes = {"Default", "Bottom", "Bottom Right"}
            local current = guiSettings.ObsidianTracerOrigin or "Default"
            local idx = 1
            for i, v in ipairs(modes) do if v == current then idx = i break end end
            local nextIdx = idx % #modes + 1
            guiSettings.ObsidianTracerOrigin = modes[nextIdx]
            ShowMessage("Tracer Origin: " .. modes[nextIdx])
        end, isToggle = false},
    }
}

for i, cat in ipairs(categories) do
    addButtons(scrolls[i], cat, 5, 5)
end

-- ПЕРЕКЛЮЧЕНИЕ ВКЛАДОК
for i, tab in ipairs(tabs) do
    tab.MouseButton1Click:Connect(function()
        for j = 1, 5 do
            scrolls[j].Visible = (j == i)
        end
    end)
end

-- ===== НИЖНЯЯ ЧАСТЬ =====
local playerName = player.Name

local nameFrame = Instance.new("Frame")
nameFrame.Size = UDim2.new(0, 70, 0, 15)
nameFrame.Position = UDim2.new(0, 5, 0, 147)
nameFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
nameFrame.BorderSizePixel = 1
nameFrame.BorderColor3 = guiSettings.BorderColor
nameFrame.Parent = mainFrame
roundCorner(nameFrame, 3)

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(0, 70, 0, 15)
nameLabel.Position = UDim2.new(0, 0, 0, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = playerName
nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
nameLabel.TextSize = 7
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextXAlignment = Enum.TextXAlignment.Center
nameLabel.Parent = nameFrame

local skinFrame = Instance.new("Frame")
skinFrame.Size = UDim2.new(0, 15, 0, 15)
skinFrame.Position = UDim2.new(0, 80, 0, 147)
skinFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
skinFrame.BorderSizePixel = 1
skinFrame.BorderColor3 = guiSettings.BorderColor
skinFrame.Parent = mainFrame
roundCorner(skinFrame, 3)

local avatarImage = Instance.new("ImageLabel")
avatarImage.Size = UDim2.new(0, 15, 0, 15)
avatarImage.Position = UDim2.new(0, 0, 0, 0)
avatarImage.BackgroundTransparency = 1
avatarImage.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size60x60)
avatarImage.Parent = skinFrame
roundCorner(avatarImage, 3)

-- ===== КНОПКА СКРЫТЬ =====
local hideButton = Instance.new("TextButton")
hideButton.Size = UDim2.new(0, 50, 0, 15)
hideButton.Position = UDim2.new(1, -55, 0, 147)
hideButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
hideButton.BorderSizePixel = 1
hideButton.BorderColor3 = guiSettings.BorderColor
hideButton.Text = "СКРЫТЬ"
hideButton.TextColor3 = Color3.fromRGB(200, 200, 200)
hideButton.TextSize = 5
hideButton.Font = Enum.Font.GothamBold
hideButton.AutoButtonColor = false
hideButton.Parent = mainFrame
roundCorner(hideButton, 3)

-- ===== КУБИК =====
local cubeButton = Instance.new("TextButton")
cubeButton.Size = UDim2.new(0, 50, 0, 50)
cubeButton.Position = UDim2.new(0.5, -25, 0.5, -25)
cubeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
cubeButton.BorderSizePixel = 2
cubeButton.BorderColor3 = guiSettings.BorderColor
cubeButton.Text = "M"
cubeButton.TextColor3 = guiSettings.BorderColor
cubeButton.TextSize = 30
cubeButton.Font = Enum.Font.GothamBold
cubeButton.AutoButtonColor = false
cubeButton.Visible = false
cubeButton.ZIndex = 10
cubeButton.Parent = gui
roundCorner(cubeButton, 10)

cubeButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        cubeDragging = true
        cubeDragStart = input.Position
        cubeStartPos = cubeButton.Position
    end
end)

cubeButton.InputChanged:Connect(function(input)
    if cubeDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - cubeDragStart
        local screenSize = gui.AbsoluteSize
        local newX = cubeStartPos.X.Scale + (delta.X / screenSize.X)
        local newY = cubeStartPos.Y.Scale + (delta.Y / screenSize.Y)
        local maxX = 1 - (cubeButton.Size.X.Scale + 0.05)
        local maxY = 1 - (cubeButton.Size.Y.Scale + 0.05)
        newX = math.clamp(newX, 0.02, maxX)
        newY = math.clamp(newY, 0.02, maxY)
        cubeButton.Position = UDim2.new(newX, 0, newY, 0)
    end
end)

cubeButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        cubeDragging = false
    end
end)

cubeButton.MouseButton1Click:Connect(function()
    if not uiVisible then
        uiVisible = true
        mainFrame.Visible = true
        cubeButton.Visible = false
        hideButton.Text = "СКРЫТЬ"
    end
end)

local function toggleUI()
    uiVisible = not uiVisible
    mainFrame.Visible = uiVisible
    cubeButton.Visible = not uiVisible
    hideButton.Text = uiVisible and "СКРЫТЬ" or "ПОКАЗАТЬ"
end

hideButton.MouseButton1Click:Connect(toggleUI)

-- ЦИФРЫ
local nums = {"14.0", "100", "14.0", "5", "G"}
for i = 1, 5 do
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 20, 0, 11)
    lbl.Position = UDim2.new(1, -(5 + (i-1) * 22), 0, 149)
    lbl.BackgroundTransparency = 1
    lbl.Text = nums[i]
    lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    lbl.TextSize = 6
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Right
    lbl.Parent = mainFrame
end

print("✅ MTY HUB + OBSIDIAN (GG) ЗАГРУЖЕН!")
print("✅ 5 вкладок: VIS | CMB | MOV | MM2 | GG")
print("✅ Вкладка GG содержит ВСЕ функции из Obsidian!")
print("✅ Все ТВОИ функции работают без изменений!")
print("✅ GUI не пропадает после смерти!")
print("✅ Кубик можно двигать мышкой!")
--[[
	TAS RECORDER v16
	Установка: LocalScript или executor
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ===================== КОНСТАНТЫ =====================

local DEFAULT_GRAVITY   = 196.2
local DEFAULT_WALKSPEED = 16
local DEFAULT_JUMPPOWER = 50
local SLOW_JUMP_BOOST   = 1.10
local RECORD_FPS        = 60
local PLAYBACK_SPEED    = 1.5
local SLOW_SCALE = 0.3

local BOOST_WALK_ADD = 30
local BOOST_JUMP_ADD = 30
local BOOST_DURATION = 3

local WALLHOP_ENABLED = false
local WALLHOP_COOLDOWN = 0.15
local lastWallhopTime = 0

-- Траектория
local TRAJECTORY_ENABLED = true
local trajectoryParts = {}
local TRAJ_COLOR = Color3.fromRGB(255, 255, 255)
local TRAJ_THICKNESS = 0.15
local GROUND_LENGTH = 50
local GROUND_HEIGHT_OFFSET = 0.1
local GROUND_STEP = 0.8
local AIR_STEPS = 60
local AIR_STEP_TIME = 0.05

-- ===================== ЧЁРНАЯ ТЕМА =====================

local C_BG     = Color3.fromRGB(0, 0, 0)
local C_PANEL  = Color3.fromRGB(10, 10, 10)
local C_ELEM   = Color3.fromRGB(18, 18, 18)
local C_ELEM_H = Color3.fromRGB(28, 28, 28)
local C_TEXT   = Color3.fromRGB(240, 240, 240)
local C_TEXT_D = Color3.fromRGB(150, 150, 150)
local C_BORDER = Color3.fromRGB(60, 60, 60)

-- ===================== FILE API =====================

local hasFileAPI = (typeof(writefile) == "function") and (typeof(readfile) == "function")
local FOLDER = "TAS_Runs"

local function ensureFolder()
	if hasFileAPI and typeof(isfolder) == "function" and not isfolder(FOLDER) then
		makefolder(FOLDER)
	end
end
local function safeWrite(path, data)
	if not hasFileAPI then return false end
	return (pcall(writefile, path, data))
end
local function safeRead(path)
	if not hasFileAPI then return nil end
	if typeof(isfile) == "function" and not isfile(path) then return nil end
	local ok, data = pcall(readfile, path)
	if ok then return data end
	return nil
end
local function safeList()
	if not hasFileAPI or typeof(listfiles) ~= "function" then return {} end
	local ok, files = pcall(listfiles, FOLDER)
	if ok and type(files) == "table" then return files end
	return {}
end
local function safeDelete(path)
	if not hasFileAPI or typeof(delfile) ~= "function" then return false end
	return (pcall(delfile, path))
end

-- ===================== STATE =====================

local recording = false
local playing = false
local isPaused = false
local collapsed = false
local frames = {}
local currentFrame = 1
local loopConnection = nil
local steppingBack = false
local steppingForward = false
local sessionWasSlowRecorded = true
local lastTrajUpdate = 0

-- ===================== AUTJUMP OFF =====================

local function disableAutoJump(char)
	local hum = char:WaitForChild("Humanoid", 5)
	if hum then hum.AutoJumpEnabled = false end
end
if LocalPlayer.Character then disableAutoJump(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(disableAutoJump)

-- ===================== DRAG =====================

local function makeTopOnlyDraggable(targetFrame, dragBar)
	local dragging = false
	local dragInput, dragStart, startPos
	dragBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = targetFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	dragBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			targetFrame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- ===================== GUI ROOT =====================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TAS_Recorder_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local okgui = pcall(function()
	if gethui then ScreenGui.Parent = gethui()
	else ScreenGui.Parent = game:GetService("CoreGui") end
end)
if not okgui or not ScreenGui.Parent then
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local CountdownFrame = Instance.new("Frame")
CountdownFrame.Size = UDim2.new(0, 140, 0, 140)
CountdownFrame.Position = UDim2.new(0.5, -70, 0.5, -70)
CountdownFrame.BackgroundColor3 = C_BG
CountdownFrame.BackgroundTransparency = 0.2
CountdownFrame.BorderSizePixel = 0
CountdownFrame.Visible = false
CountdownFrame.ZIndex = 50
CountdownFrame.Parent = ScreenGui
Instance.new("UICorner", CountdownFrame).CornerRadius = UDim.new(0, 12)

local CountdownText = Instance.new("TextLabel")
CountdownText.Size = UDim2.new(1, 0, 1, 0)
CountdownText.BackgroundTransparency = 1
CountdownText.TextColor3 = C_TEXT
CountdownText.Font = Enum.Font.Code
CountdownText.TextSize = 72
CountdownText.ZIndex = 51
CountdownText.Parent = CountdownFrame

local function runCountdown(callback)
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then hrp.Anchored = true end
	CountdownFrame.Visible = true
	for i = 3, 1, -1 do
		CountdownText.Text = tostring(i)
		task.wait(0.5)
	end
	CountdownText.Text = "GO!"
	if hrp then hrp.Anchored = false end
	task.wait(0.25)
	CountdownFrame.Visible = false
	callback()
end

local EXPANDED_SIZE  = UDim2.new(0.95, 0, 0.9, 0)
local EXPANDED_POS   = UDim2.new(0.025, 0, 0.05, 0)
local COLLAPSED_SIZE = UDim2.new(0, 56, 0, 56)
local COLLAPSED_POS  = UDim2.new(0.02, 0, 0.10, 0)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = EXPANDED_SIZE
MainFrame.Position = EXPANDED_POS
MainFrame.BackgroundColor3 = C_BG
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", MainFrame)
stroke.Color = C_BORDER
stroke.Thickness = 1.5

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundTransparency = 1
TopBar.Active = true
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.02, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "TAS Recorder v16"
TitleLabel.TextColor3 = C_TEXT
TitleLabel.Font = Enum.Font.Code
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

makeTopOnlyDraggable(MainFrame, TopBar)

local ToggleGuiBtn = Instance.new("TextButton")
ToggleGuiBtn.Size = UDim2.new(0, 60, 0, 20)
ToggleGuiBtn.Position = UDim2.new(1, -66, 0, 5)
ToggleGuiBtn.Text = "HIDE"
ToggleGuiBtn.BackgroundColor3 = C_ELEM
ToggleGuiBtn.TextColor3 = C_TEXT
ToggleGuiBtn.Font = Enum.Font.Code
ToggleGuiBtn.TextSize = 11
ToggleGuiBtn.BorderSizePixel = 0
ToggleGuiBtn.Parent = TopBar
Instance.new("UICorner", ToggleGuiBtn).CornerRadius = UDim.new(0, 6)

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -16, 1, -44)
ContentContainer.Position = UDim2.new(0, 8, 0, 36)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local LeftCol = Instance.new("Frame")
LeftCol.Size = UDim2.new(0.32, -4, 1, 0)
LeftCol.BackgroundTransparency = 1
LeftCol.Parent = ContentContainer

local MidCol = Instance.new("Frame")
MidCol.Size = UDim2.new(0.34, -4, 1, 0)
MidCol.Position = UDim2.new(0.32, 4, 0, 0)
MidCol.BackgroundTransparency = 1
MidCol.Parent = ContentContainer

local RightCol = Instance.new("Frame")
RightCol.Size = UDim2.new(0.34, -4, 1, 0)
RightCol.Position = UDim2.new(0.66, 4, 0, 0)
RightCol.BackgroundTransparency = 1
RightCol.Parent = ContentContainer

local function makeScroll(parent)
	local s = Instance.new("ScrollingFrame")
	s.Size = UDim2.new(1, 0, 1, 0)
	s.BackgroundTransparency = 1
	s.BorderSizePixel = 0
	s.ScrollBarThickness = 4
	s.ScrollBarImageColor3 = C_BORDER
	s.CanvasSize = UDim2.new(0, 0, 0, 0)
	s.AutomaticCanvasSize = Enum.AutomaticSize.Y
	s.Parent = parent
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0, 5)
	l.Parent = s
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, 2); p.PaddingBottom = UDim.new(0, 4)
	p.PaddingLeft = UDim.new(0, 2); p.PaddingRight = UDim.new(0, 4)
	p.Parent = s
	return s
end

local LeftScroll  = makeScroll(LeftCol)
local MidScroll   = makeScroll(MidCol)
local RightScroll = makeScroll(RightCol)

local CollapsedIcon = Instance.new("TextLabel")
CollapsedIcon.Size = UDim2.new(1, 0, 1, 0)
CollapsedIcon.BackgroundTransparency = 1
CollapsedIcon.Text = "TAS"
CollapsedIcon.TextColor3 = C_TEXT
CollapsedIcon.Font = Enum.Font.Code
CollapsedIcon.TextSize = 16
CollapsedIcon.Visible = false
CollapsedIcon.Parent = MainFrame

local function setCollapsed(state)
	collapsed = state
	ContentContainer.Visible = not state
	TitleLabel.Visible = not state
	ToggleGuiBtn.Visible = not state
	CollapsedIcon.Visible = state
	if state then
		MainFrame.Size = COLLAPSED_SIZE
		MainFrame.Position = COLLAPSED_POS
		MainFrame.BackgroundColor3 = C_ELEM
	else
		MainFrame.Size = EXPANDED_SIZE
		MainFrame.Position = EXPANDED_POS
		MainFrame.BackgroundColor3 = C_BG
	end
end
MainFrame.InputBegan:Connect(function(input)
	if collapsed and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
		setCollapsed(false)
	end
end)
ToggleGuiBtn.MouseButton1Click:Connect(function() setCollapsed(true) end)

-- ===================== UI HELPERS =====================

local function makeBtn(parent, text, height, color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, height or 24)
	b.Text = text
	b.BackgroundColor3 = color or C_ELEM
	b.TextColor3 = C_TEXT
	b.Font = Enum.Font.Code
	b.TextSize = 11
	b.BorderSizePixel = 0
	b.Parent = parent
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
	return b
end
local function makeLabel(parent, text, color, height, ts)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, height or 16)
	l.Text = text
	l.TextColor3 = color or C_TEXT
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.Code
	l.TextSize = ts or 11
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end
local function makeRow(parent, height)
	local r = Instance.new("Frame")
	r.Size = UDim2.new(1, 0, 0, height or 24)
	r.BackgroundTransparency = 1
	r.Parent = parent
	local l = Instance.new("UIListLayout")
	l.FillDirection = Enum.FillDirection.Horizontal
	l.Padding = UDim.new(0, 4)
	l.Parent = r
	return r
end
local function makeRowBtn(parent, text, w, color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(w, -2, 1, 0)
	b.Text = text
	b.BackgroundColor3 = color or C_ELEM
	b.TextColor3 = C_TEXT
	b.Font = Enum.Font.Code
	b.TextSize = 11
	b.BorderSizePixel = 0
	b.Parent = parent
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
	return b
end
local function makeTextBox(parent, placeholder, default)
	local b = Instance.new("TextBox")
	b.Size = UDim2.new(1, 0, 0, 24)
	b.Text = default or ""
	b.PlaceholderText = placeholder or ""
	b.BackgroundColor3 = C_ELEM
	b.TextColor3 = C_TEXT
	b.PlaceholderColor3 = C_TEXT_D
	b.Font = Enum.Font.Code
	b.TextSize = 11
	b.BorderSizePixel = 0
	b.ClearTextOnFocus = false
	b.Parent = parent
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
	return b
end

-- ===================== LEFT: RECORDER =====================

makeLabel(LeftScroll, "RECORDER", C_TEXT, 16, 12)

local FrameCounter = makeLabel(LeftScroll, "FRAME: 0/0", C_TEXT, 18, 12)
local function updateFrameCounter()
	FrameCounter.Text = string.format("FRAME: %d / %d", math.floor(currentFrame), #frames)
end

makeLabel(LeftScroll, "RECORD SPEED (0.1-1)", C_TEXT, 14, 10)
local RecordSpeedBox = makeTextBox(LeftScroll, "0.3", tostring(SLOW_SCALE))
RecordSpeedBox.FocusLost:Connect(function()
	local v = tonumber(RecordSpeedBox.Text)
	if v and v > 0 and v <= 1 then SLOW_SCALE = v else RecordSpeedBox.Text = tostring(SLOW_SCALE) end
end)

makeLabel(LeftScroll, "PLAYBACK SPEED (0.5-3)", C_TEXT, 14, 10)
local PlaybackSpeedBox = makeTextBox(LeftScroll, "1.5", tostring(PLAYBACK_SPEED))
PlaybackSpeedBox.FocusLost:Connect(function()
	local v = tonumber(PlaybackSpeedBox.Text)
	if v and v > 0 and v <= 5 then PLAYBACK_SPEED = v
	else PlaybackSpeedBox.Text = tostring(PLAYBACK_SPEED) end
end)

local recRow = makeRow(LeftScroll, 28)
local RecBtn = makeRowBtn(recRow, "RECORD", 0.5, C_ELEM)
local PlaybackBtn = makeRowBtn(recRow, "PLAYBACK", 0.5, C_ELEM)

local pauseRow = makeRow(LeftScroll, 26)
local PauseBtn = makeRowBtn(pauseRow, "PAUSE", 0.5, C_ELEM)
local ResumeBtn = makeRowBtn(pauseRow, "RESUME", 0.5, C_ELEM)

local stepRow = makeRow(LeftScroll, 24)
local StepBackBtn = makeRowBtn(stepRow, "<< STEP", 0.5, C_ELEM)
local StepForwardBtn = makeRowBtn(stepRow, "STEP >>", 0.5, C_ELEM)

local ClearBtn = makeBtn(LeftScroll, "CLEAR", 22, C_ELEM)

makeLabel(LeftScroll, "FILES (" .. FOLDER .. ")", C_TEXT, 14, 10)
local SaveNameBox = makeTextBox(LeftScroll, "имя...")
local fileRow = makeRow(LeftScroll, 24)
local SaveBtn = makeRowBtn(fileRow, "SAVE", 0.5, C_ELEM)
local RefreshBtn = makeRowBtn(fileRow, "REFRESH", 0.5, C_ELEM)

local FileList = Instance.new("Frame")
FileList.Size = UDim2.new(1, 0, 0, 130)
FileList.BackgroundColor3 = C_PANEL
FileList.BorderSizePixel = 1
FileList.BorderColor3 = C_BORDER
FileList.Parent = LeftScroll
Instance.new("UICorner", FileList).CornerRadius = UDim.new(0, 6)

local FileListScroll = Instance.new("ScrollingFrame")
FileListScroll.Size = UDim2.new(1, -6, 1, -6)
FileListScroll.Position = UDim2.new(0, 3, 0, 3)
FileListScroll.BackgroundTransparency = 1
FileListScroll.BorderSizePixel = 0
FileListScroll.ScrollBarThickness = 3
FileListScroll.ScrollBarImageColor3 = C_BORDER
FileListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
FileListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
FileListScroll.Parent = FileList
local FileListLayout = Instance.new("UIListLayout")
FileListLayout.Padding = UDim.new(0, 3)
FileListLayout.Parent = FileListScroll

local function clearFileList()
	for _, ch in ipairs(FileListScroll:GetChildren()) do
		if ch:IsA("TextButton") or ch:IsA("Frame") then ch:Destroy() end
	end
end

local function refreshFileList()
	clearFileList()
	local files = safeList()
	if #files == 0 then
		local e = Instance.new("TextLabel")
		e.Size = UDim2.new(1, 0, 0, 18)
		e.BackgroundTransparency = 1
		e.Text = hasFileAPI and "(empty)" or "(no file api)"
		e.TextColor3 = C_TEXT_D
		e.Font = Enum.Font.Code
		e.TextSize = 10
		e.Parent = FileListScroll
		return
	end
	for _, path in ipairs(files) do
		local fname = path:match("([^/\\]+)$") or path
		if fname:sub(-4) == ".tas" then
			local display = fname:sub(1, -5)
			local entry = Instance.new("Frame")
			entry.Size = UDim2.new(1, -4, 0, 24)
			entry.BackgroundColor3 = C_ELEM
			entry.BorderSizePixel = 0
			entry.Parent = FileListScroll
			Instance.new("UICorner", entry).CornerRadius = UDim.new(0, 4)
			local nl = Instance.new("TextLabel")
			nl.Size = UDim2.new(0.5, 0, 1, 0)
			nl.Position = UDim2.new(0, 6, 0, 0)
			nl.BackgroundTransparency = 1
			nl.Text = display
			nl.TextColor3 = C_TEXT
			nl.Font = Enum.Font.Code
			nl.TextSize = 10
			nl.TextXAlignment = Enum.TextXAlignment.Left
			nl.TextTruncate = Enum.TextTruncate.AtEnd
			nl.Parent = entry
			local lb = Instance.new("TextButton")
			lb.Size = UDim2.new(0, 42, 1, -4)
			lb.Position = UDim2.new(1, -92, 0, 2)
			lb.Text = "LOAD"
			lb.BackgroundColor3 = C_ELEM_H
			lb.TextColor3 = C_TEXT
			lb.Font = Enum.Font.Code
			lb.TextSize = 10
			lb.BorderSizePixel = 0
			lb.Parent = entry
			Instance.new("UICorner", lb).CornerRadius = UDim.new(0, 4)
			local db = Instance.new("TextButton")
			db.Size = UDim2.new(0, 42, 1, -4)
			db.Position = UDim2.new(1, -46, 0, 2)
			db.Text = "DEL"
			db.BackgroundColor3 = C_ELEM_H
			db.TextColor3 = C_TEXT
			db.Font = Enum.Font.Code
			db.TextSize = 10
			db.BorderSizePixel = 0
			db.Parent = entry
			Instance.new("UICorner", db).CornerRadius = UDim.new(0, 4)

			lb.MouseButton1Click:Connect(function()
				if recording then return end
				local raw = safeRead(path)
				if not raw then return end
				local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
				if not ok or not data then return end
				frames = {}
				sessionWasSlowRecorded = data.wasSlow ~= nil and data.wasSlow or true
				if data.slowScale then SLOW_SCALE = data.slowScale end
				local list = data.framesData or data
				for _, item in ipairs(list) do
					table.insert(frames, {
						cframe = CFrame.new(unpack(item.cf)),
						velocity = Vector3.new(unpack(item.v)),
						rotVelocity = Vector3.new(unpack(item.rv)),
					})
				end
				currentFrame = 1
				updateFrameCounter()
				SaveNameBox.Text = display
				RecordSpeedBox.Text = tostring(SLOW_SCALE)
			end)
			db.MouseButton1Click:Connect(function()
				if recording then return end
				safeDelete(path)
				refreshFileList()
			end)
		end
	end
end

SaveBtn.MouseButton1Click:Connect(function()
	if recording or #frames == 0 then return end
	if not hasFileAPI then
		SaveBtn.Text = "NO API"
		task.delay(1.2, function() SaveBtn.Text = "SAVE" end)
		return
	end
	ensureFolder()
	local name = SaveNameBox.Text
	if name == "" then name = "run_" .. os.time() end
	name = name:gsub("[^%w_%-]", "_")
	local path = FOLDER .. "/" .. name .. ".tas"
	local export = { wasSlow = sessionWasSlowRecorded, slowScale = SLOW_SCALE, framesData = {} }
	for _, f in ipairs(frames) do
		table.insert(export.framesData, {
			cf = {f.cframe:GetComponents()},
			v = {f.velocity.X, f.velocity.Y, f.velocity.Z},
			rv = {f.rotVelocity.X, f.rotVelocity.Y, f.rotVelocity.Z},
		})
	end
	local ok = safeWrite(path, HttpService:JSONEncode(export))
	if ok then SaveBtn.Text = "SAVED" refreshFileList() else SaveBtn.Text = "FAIL" end
	task.delay(1.2, function() SaveBtn.Text = "SAVE" end)
end)
RefreshBtn.MouseButton1Click:Connect(function()
	refreshFileList()
	RefreshBtn.Text = "..."
	task.delay(0.4, function() RefreshBtn.Text = "REFRESH" end)
end)
refreshFileList()

-- ===================== MID: MACROS =====================

makeLabel(MidScroll, "MACROS", C_TEXT, 16, 12)

local BoostBtn = makeBtn(MidScroll, "BOOST (SPEED + JUMP)", 26, C_ELEM)
local WallhopBtn = makeBtn(MidScroll, "WALLHOP: OFF", 26, C_ELEM)
local TrajectoryBtn = makeBtn(MidScroll, "TRAJECTORY: ON", 26, C_ELEM_H)

local BoostLabel = makeLabel(MidScroll, "Walk +" .. BOOST_WALK_ADD .. " / Jump +" .. BOOST_JUMP_ADD, C_TEXT_D, 14, 10)

local boostActive = false
local boostEndTime = 0
BoostBtn.MouseButton1Click:Connect(function()
	if boostActive then return end
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	boostActive = true
	boostEndTime = os.clock() + BOOST_DURATION
	local baseWalk = hum.WalkSpeed
	local baseJump = hum.JumpPower
	hum.WalkSpeed = baseWalk + BOOST_WALK_ADD
	hum.JumpPower = baseJump + BOOST_JUMP_ADD
	BoostBtn.Text = "BOOST ACTIVE..."
	task.spawn(function()
		while os.clock() < boostEndTime do
			BoostLabel.Text = string.format("Boost: %.1fs", boostEndTime - os.clock())
			task.wait(0.05)
		end
		if hum.Parent then
			hum.WalkSpeed = baseWalk
			hum.JumpPower = baseJump
		end
		boostActive = false
		BoostBtn.Text = "BOOST (SPEED + JUMP)"
		BoostLabel.Text = "Walk +" .. BOOST_WALK_ADD .. " / Jump +" .. BOOST_JUMP_ADD
	end)
end)

WallhopBtn.MouseButton1Click:Connect(function()
	WALLHOP_ENABLED = not WALLHOP_ENABLED
	WallhopBtn.Text = WALLHOP_ENABLED and "WALLHOP: ON" or "WALLHOP: OFF"
	WallhopBtn.BackgroundColor3 = WALLHOP_ENABLED and C_ELEM_H or C_ELEM
end)

UserInputService.JumpRequest:Connect(function()
	if not WALLHOP_ENABLED then return end
	if os.clock() - lastWallhopTime < WALLHOP_COOLDOWN then return end
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not (hum and hrp) then return end
	local dirs = {Vector3.new(3,0,0), Vector3.new(-3,0,0), Vector3.new(0,0,3), Vector3.new(0,0,-3)}
	local hit = nil
	for _, d in ipairs(dirs) do
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {char}
		local r = workspace:Raycast(hrp.Position, d, params)
		if r then hit = r break end
	end
	if hit then
		lastWallhopTime = os.clock()
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0, -1, 0)
		task.wait(0.15)
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 1, 0)
	end
end)

TrajectoryBtn.MouseButton1Click:Connect(function()
	TRAJECTORY_ENABLED = not TRAJECTORY_ENABLED
	TrajectoryBtn.Text = TRAJECTORY_ENABLED and "TRAJECTORY: ON" or "TRAJECTORY: OFF"
	TrajectoryBtn.BackgroundColor3 = TRAJECTORY_ENABLED and C_ELEM_H or C_ELEM
	if not TRAJECTORY_ENABLED then
		for _, p in ipairs(trajectoryParts) do if p and p.Parent then p:Destroy() end end
		trajectoryParts = {}
	end
end)

-- ===================== DEBUG =====================

makeLabel(MidScroll, "DEBUG", C_TEXT, 16, 12)

local DbgBox = Instance.new("Frame")
DbgBox.Size = UDim2.new(1, 0, 0, 200)
DbgBox.BackgroundColor3 = C_PANEL
DbgBox.BorderSizePixel = 1
DbgBox.BorderColor3 = C_BORDER
DbgBox.Parent = MidScroll
Instance.new("UICorner", DbgBox).CornerRadius = UDim.new(0, 6)
local DbgLayout = Instance.new("UIListLayout")
DbgLayout.Padding = UDim.new(0, 2)
DbgLayout.Parent = DbgBox
local DbgPad = Instance.new("UIPadding")
DbgPad.PaddingTop = UDim.new(0, 8); DbgPad.PaddingBottom = UDim.new(0, 8)
DbgPad.PaddingLeft = UDim.new(0, 8); DbgPad.PaddingRight = UDim.new(0, 6)
DbgPad.Parent = DbgBox

local function makeDbg(name, color)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, 16)
	l.BackgroundTransparency = 1
	l.Text = name .. ": -"
	l.TextColor3 = color or C_TEXT
	l.Font = Enum.Font.Code
	l.TextSize = 11
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = DbgBox
	return l
end

local dbgFrameTime = makeDbg("Frame Time")
local dbgRootPos   = makeDbg("Root Position")
local dbgRootRot   = makeDbg("Root Rotation")
local dbgLinVel    = makeDbg("Linear Velocity")
local dbgAngVel    = makeDbg("Angular Velocity")
local dbgCamRot    = makeDbg("Camera Rotation")
local dbgHumState  = makeDbg("Humanoid State")
local dbgZoom      = makeDbg("Zoom")

local function fmt(n) return string.format("%.3f", n) end
local function fmtVec(v) return string.format("%s,%s,%s", fmt(v.X), fmt(v.Y), fmt(v.Z)) end

-- ===================== BUG HELPER =====================

makeLabel(MidScroll, "BUG HELPER", C_TEXT, 16, 12)

local BugBox = Instance.new("Frame")
BugBox.Size = UDim2.new(1, 0, 0, 110)
BugBox.BackgroundColor3 = C_PANEL
BugBox.BorderSizePixel = 1
BugBox.BorderColor3 = C_BORDER
BugBox.Parent = MidScroll
Instance.new("UICorner", BugBox).CornerRadius = UDim.new(0, 6)
local BugLayout = Instance.new("UIListLayout")
BugLayout.Padding = UDim.new(0, 2)
BugLayout.Parent = BugBox
local BugPad = Instance.new("UIPadding")
BugPad.PaddingTop = UDim.new(0, 8); BugPad.PaddingBottom = UDim.new(0, 8)
BugPad.PaddingLeft = UDim.new(0, 8); BugPad.PaddingRight = UDim.new(0, 6)
BugPad.Parent = BugBox

local bugState     = makeDbg("State", Color3.fromRGB(120, 220, 255))
local bugAirTime   = makeDbg("Air Time")
local bugFallSpeed = makeDbg("Fall Speed")
local bugVelSpike  = makeDbg("Vel Spike", Color3.fromRGB(255, 200, 120))
local bugLastEvent = makeDbg("Last", Color3.fromRGB(255, 120, 120))

local EventList = Instance.new("ScrollingFrame")
EventList.Size = UDim2.new(1, 0, 0, 70)
EventList.BackgroundColor3 = C_PANEL
EventList.BorderSizePixel = 1
EventList.BorderColor3 = C_BORDER
EventList.ScrollBarThickness = 3
EventList.ScrollBarImageColor3 = C_BORDER
EventList.CanvasSize = UDim2.new(0, 0, 0, 0)
EventList.AutomaticCanvasSize = Enum.AutomaticSize.Y
EventList.Parent = MidScroll
Instance.new("UICorner", EventList).CornerRadius = UDim.new(0, 5)
local EventLayout = Instance.new("UIListLayout")
EventLayout.Padding = UDim.new(0, 2)
EventLayout.Parent = EventList
local EventPad = Instance.new("UIPadding")
EventPad.PaddingTop = UDim.new(0, 4); EventPad.PaddingLeft = UDim.new(0, 6); EventPad.PaddingRight = UDim.new(0, 4)
EventPad.Parent = EventList

local eventHistory = {}
local MAX_EVENTS = 8
local function pushEvent(text, color)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -4, 0, 14)
	lbl.BackgroundTransparency = 1
	lbl.Text = os.date("%H:%M:%S") .. " " .. text
	lbl.TextColor3 = color or C_TEXT
	lbl.Font = Enum.Font.Code
	lbl.TextSize = 10
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = EventList
	table.insert(eventHistory, lbl)
	if #eventHistory > MAX_EVENTS then
		local old = table.remove(eventHistory, 1)
		if old then old:Destroy() end
	end
	bugLastEvent.Text = "Last: " .. text
end

-- ===================== RIGHT: MOVEMENT + ROTATOR =====================

makeLabel(RightScroll, "MOVEMENT HELPER", C_TEXT, 16, 12)

local MoveBox = Instance.new("Frame")
MoveBox.Size = UDim2.new(1, 0, 0, 200)
MoveBox.BackgroundColor3 = C_PANEL
MoveBox.BorderSizePixel = 1
MoveBox.BorderColor3 = C_BORDER
MoveBox.Parent = RightScroll
Instance.new("UICorner", MoveBox).CornerRadius = UDim.new(0, 6)
local MoveLayout = Instance.new("UIListLayout")
MoveLayout.Padding = UDim.new(0, 3)
MoveLayout.Parent = MoveBox
local MovePad = Instance.new("UIPadding")
MovePad.PaddingTop = UDim.new(0, 8); MovePad.PaddingBottom = UDim.new(0, 8)
MovePad.PaddingLeft = UDim.new(0, 8); MovePad.PaddingRight = UDim.new(0, 6)
MovePad.Parent = MoveBox

local function makeMoveLine(name, color)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, 15)
	l.BackgroundTransparency = 1
	l.Text = name .. ": -"
	l.TextColor3 = color or C_TEXT
	l.Font = Enum.Font.Code
	l.TextSize = 10
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = MoveBox
	return l
end

local mvBhop      = makeMoveLine("Bhop", Color3.fromRGB(120, 255, 160))
local mvStrafe    = makeMoveLine("Strafe", Color3.fromRGB(120, 220, 255))
local mvAirStrafe = makeMoveLine("Air-Strafe", Color3.fromRGB(200, 200, 255))
local mvWallrun   = makeMoveLine("Wallrun", Color3.fromRGB(255, 200, 120))
local mvSpeed     = makeMoveLine("Speed", C_TEXT)
local mvGround    = makeMoveLine("Ground", C_TEXT_D)
local mvSlide     = makeMoveLine("Slide", Color3.fromRGB(255, 180, 255))
local mvJumpWin   = makeMoveLine("Jump Window", Color3.fromRGB(255, 255, 100))

makeLabel(RightScroll, "ROTATOR", C_TEXT, 16, 12)

local RotBox = Instance.new("Frame")
RotBox.Size = UDim2.new(1, 0, 0, 170)
RotBox.BackgroundColor3 = C_PANEL
RotBox.BorderSizePixel = 1
RotBox.BorderColor3 = C_BORDER
RotBox.Parent = RightScroll
Instance.new("UICorner", RotBox).CornerRadius = UDim.new(0, 6)
local RotLayout = Instance.new("UIListLayout")
RotLayout.Padding = UDim.new(0, 4)
RotLayout.Parent = RotBox
local RotPad = Instance.new("UIPadding")
RotPad.PaddingTop = UDim.new(0, 8); RotPad.PaddingBottom = UDim.new(0, 8)
RotPad.PaddingLeft = UDim.new(0, 8); RotPad.PaddingRight = UDim.new(0, 6)
RotPad.Parent = RotBox

local RotAngleBox = makeTextBox(RotBox, "угол°", "90")
local RotSpeedBox = makeTextBox(RotBox, "время (сек)", "0.3")

local rotRow1 = makeRow(RotBox, 22)
local Rot45  = makeRowBtn(rotRow1, "45°", 1/3, C_ELEM)
local Rot90  = makeRowBtn(rotRow1, "90°", 1/3, C_ELEM)
local Rot180 = makeRowBtn(rotRow1, "180°", 1/3, C_ELEM)

local rotRow2 = makeRow(RotBox, 22)
local RotL = makeRowBtn(rotRow2, "LEFT", 0.5, C_ELEM)
local RotR = makeRowBtn(rotRow2, "RIGHT", 0.5, C_ELEM)

local function rotateCamera(degrees, duration)
	local cam = workspace.CurrentCamera
	if not cam then return end
	local startCf = cam.CFrame
	local targetCf = startCf * CFrame.Angles(0, math.rad(degrees), 0)
	local t0 = os.clock()
	task.spawn(function()
		while true do
			local a = (os.clock() - t0) / duration
			if a >= 1 then cam.CFrame = targetCf break end
			cam.CFrame = startCf:Lerp(targetCf, a)
			task.wait()
		end
	end)
end
Rot45.MouseButton1Click:Connect(function() rotateCamera(45, tonumber(RotSpeedBox.Text) or 0.3) end)
Rot90.MouseButton1Click:Connect(function() rotateCamera(90, tonumber(RotSpeedBox.Text) or 0.3) end)
Rot180.MouseButton1Click:Connect(function() rotateCamera(180, tonumber(RotSpeedBox.Text) or 0.3) end)
RotL.MouseButton1Click:Connect(function() rotateCamera(-(tonumber(RotAngleBox.Text) or 90), tonumber(RotSpeedBox.Text) or 0.3) end)
RotR.MouseButton1Click:Connect(function() rotateCamera(tonumber(RotAngleBox.Text) or 90, tonumber(RotSpeedBox.Text) or 0.3) end)

-- ===================== ФИЗИКА =====================

local function applySlowmoPhysics(enable)
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if enable then
		workspace.Gravity = DEFAULT_GRAVITY * (SLOW_SCALE * SLOW_SCALE) / SLOW_JUMP_BOOST
		if hum then
			hum.WalkSpeed = DEFAULT_WALKSPEED * SLOW_SCALE
			hum.JumpPower = DEFAULT_JUMPPOWER * SLOW_SCALE * SLOW_JUMP_BOOST
		end
	else
		workspace.Gravity = DEFAULT_GRAVITY
		if hum then
			hum.WalkSpeed = DEFAULT_WALKSPEED
			hum.JumpPower = DEFAULT_JUMPPOWER
		end
	end
end

local function setAnimSpeed(speed)
	local char = LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local anim = hum:FindFirstChildOfClass("Animator")
	if anim then
		for _, track in ipairs(anim:GetPlayingAnimationTracks()) do
			track:AdjustSpeed(speed)
		end
	end
end

-- ===================== PLAYBACK =====================

local function applyFrame(idx)
	if #frames == 0 then return end
	idx = math.clamp(idx, 1, #frames)
	currentFrame = idx
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		local hrp = char.HumanoidRootPart
		local hum = char:FindFirstChildOfClass("Humanoid")
		local data = frames[idx]
		hrp.CFrame = data.cframe
		hrp.AssemblyLinearVelocity = data.velocity
		hrp.AssemblyAngularVelocity = data.rotVelocity
		if hum then
			hum.WalkSpeed = DEFAULT_WALKSPEED
			if math.abs(data.velocity.Y) > 2 then
				hum:ChangeState(Enum.HumanoidStateType.Freefall)
			elseif Vector3.new(data.velocity.X, 0, data.velocity.Z).Magnitude > 0.5 then
				hum:ChangeState(Enum.HumanoidStateType.Running)
			else
				hum:ChangeState(Enum.HumanoidStateType.Landed)
			end
		end
	end
	updateFrameCounter()
end

local function forceUnpause()
	isPaused = false
	PauseBtn.Text = "PAUSE"
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		char.HumanoidRootPart.Anchored = false
	end
end
local function forcePause()
	if not isPaused then
		isPaused = true
		PauseBtn.Text = "UNPAUSE"
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.Anchored = true
		end
	end
end
local function truncateFutureFrames()
	if currentFrame < #frames then
		for i = #frames, currentFrame + 1, -1 do
			table.remove(frames, i)
		end
	end
end

local function startRecordingLoop()
	if loopConnection then loopConnection:Disconnect() end
	loopConnection = RunService.Heartbeat:Connect(function()
		if not isPaused and recording then
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local hrp = char.HumanoidRootPart
				table.insert(frames, {
					cframe = hrp.CFrame,
					velocity = hrp.AssemblyLinearVelocity,
					rotVelocity = hrp.AssemblyAngularVelocity,
				})
				currentFrame = #frames
				updateFrameCounter()
			end
		end
	end)
end

local function startPlaybackLoop()
	if recording or #frames == 0 then return end
	if loopConnection then loopConnection:Disconnect() end
	playing = true
	currentFrame = 1
	PlaybackBtn.Text = "STOP PLAY"
	applySlowmoPhysics(false)
	forceUnpause()
	local slowCompensation = sessionWasSlowRecorded and (1 / SLOW_SCALE) or 1
	loopConnection = RunService.Heartbeat:Connect(function(dt)
		if not isPaused then
			local step = (RECORD_FPS * dt * slowCompensation) / PLAYBACK_SPEED
			local idx = math.floor(currentFrame)
			if idx <= #frames then
				applyFrame(idx)
				setAnimSpeed(1)
				currentFrame = currentFrame + step
			else
				playing = false
				setAnimSpeed(1)
				PlaybackBtn.Text = "PLAYBACK"
				if loopConnection then loopConnection:Disconnect() end
			end
		end
	end)
end

-- ===================== BUTTONS =====================

PauseBtn.MouseButton1Click:Connect(function()
	if recording then return end
	isPaused = not isPaused
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if isPaused then
		PauseBtn.Text = "UNPAUSE"
		if hrp then hrp.Anchored = true end
	else
		PauseBtn.Text = "PAUSE"
		if hrp then hrp.Anchored = false end
		if recording then
			truncateFutureFrames()
			applySlowmoPhysics(true)
			startRecordingLoop()
		end
	end
end)

StepBackBtn.InputBegan:Connect(function(input)
	if recording then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if playing or #frames == 0 then return end
		forcePause()
		steppingBack = true
		task.spawn(function()
			while steppingBack and currentFrame > 1 do
				applyFrame(currentFrame - 1)
				task.wait(0.05)
			end
		end)
	end
end)
StepBackBtn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		steppingBack = false
	end
end)

StepForwardBtn.InputBegan:Connect(function(input)
	if recording then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if playing or #frames == 0 then return end
		forcePause()
		steppingForward = true
		task.spawn(function()
			while steppingForward and currentFrame < #frames do
				applyFrame(currentFrame + 1)
				task.wait(0.05)
			end
		end)
	end
end)
StepForwardBtn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		steppingForward = false
	end
end)

RecBtn.MouseButton1Click:Connect(function()
	if playing then return end
	if not recording then
		runCountdown(function()
			recording = true
			sessionWasSlowRecorded = true
			frames = {}
			currentFrame = 1
			updateFrameCounter()
			RecBtn.Text = "STOP REC"
			forceUnpause()
			applySlowmoPhysics(true)
			startRecordingLoop()
		end)
	else
		recording = false
		RecBtn.Text = "RECORD"
		applySlowmoPhysics(false)
		if loopConnection then loopConnection:Disconnect() end
	end
end)

ResumeBtn.MouseButton1Click:Connect(function()
	if playing then
		playing = false
		if loopConnection then loopConnection:Disconnect() end
		setAnimSpeed(1)
		PlaybackBtn.Text = "PLAYBACK"
	end
	if not recording then
		recording = true
		sessionWasSlowRecorded = true
		truncateFutureFrames()
		ResumeBtn.Text = "RESUMING..."
		forceUnpause()
		applySlowmoPhysics(true)
		startRecordingLoop()
	else
		recording = false
		ResumeBtn.Text = "RESUME"
		applySlowmoPhysics(false)
		if loopConnection then loopConnection:Disconnect() end
	end
end)

PlaybackBtn.MouseButton1Click:Connect(function()
	if recording or #frames == 0 then return end
	if playing then
		playing = false
		setAnimSpeed(1)
		PlaybackBtn.Text = "PLAYBACK"
		if loopConnection then loopConnection:Disconnect() end
	else
		startPlaybackLoop()
	end
end)

ClearBtn.MouseButton1Click:Connect(function()
	if recording or playing then return end
	frames = {}
	currentFrame = 1
	updateFrameCounter()
end)

-- ===================== SMART TRAJECTORY =====================

local function clearTrajectory()
	for _, p in ipairs(trajectoryParts) do
		if p and p.Parent then p:Destroy() end
	end
	trajectoryParts = {}
end

local function makeTrajSegment(from, to, transparency)
	local delta = to - from
	local len = delta.Magnitude
	if len < 0.001 then return end
	local part = Instance.new("Part")
	part.Size = Vector3.new(TRAJ_THICKNESS, TRAJ_THICKNESS, len)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Material = Enum.Material.Neon
	part.Color = TRAJ_COLOR
	part.Transparency = transparency
	part.CFrame = CFrame.new(from + delta * 0.5, to)
	part.Parent = workspace
	table.insert(trajectoryParts, part)
end

local function makeTrajDot(pos, size)
	local dot = Instance.new("Part")
	dot.Shape = Enum.PartType.Ball
	dot.Size = Vector3.new(size, size, size)
	dot.Anchored = true
	dot.CanCollide = false
	dot.CanQuery = false
	dot.CanTouch = false
	dot.Material = Enum.Material.Neon
	dot.Color = TRAJ_COLOR
	dot.Transparency = 0.05
	dot.CFrame = CFrame.new(pos)
	dot.Parent = workspace
	table.insert(trajectoryParts, dot)
end

local function renderGroundLine(char, hrp, hum)
	local moveDir = hum.MoveDirection
	if moveDir.Magnitude < 0.05 then
		moveDir = hrp.CFrame.LookVector
	end
	local dir = Vector3.new(moveDir.X, 0, moveDir.Z)
	if dir.Magnitude < 0.001 then return end
	dir = dir.Unit

	local origin = hrp.Position
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {char}

	local steps = math.floor(GROUND_LENGTH / GROUND_STEP)
	local prev = origin
	local lastValid = nil
	local segments = {}

	for i = 1, steps do
		local nextPoint = origin + dir * (i * GROUND_STEP)
		local down = workspace:Raycast(nextPoint + Vector3.new(0, 5, 0), Vector3.new(0, -20, 0), params)
		if down then
			nextPoint = down.Position + Vector3.new(0, GROUND_HEIGHT_OFFSET, 0)
			local rayToNext = nextPoint - prev
			local wall = workspace:Raycast(prev + Vector3.new(0, GROUND_HEIGHT_OFFSET, 0), rayToNext, params)
			if wall then break end
			if lastValid then
				local dy = math.abs(nextPoint.Y - lastValid.Y)
				if dy > 3 then break end
			end
			table.insert(segments, {from = prev, to = nextPoint})
			prev = nextPoint
			lastValid = nextPoint
		else
			break
		end
	end

	local total = #segments
	for i, seg in ipairs(segments) do
		makeTrajSegment(seg.from, seg.to, 0.1 + (i / total) * 0.65)
	end
	if lastValid then
		makeTrajDot(lastValid, TRAJ_THICKNESS * 2.5)
	end
end

local function renderAirParabola(char, hrp)
	local pos = hrp.Position
	local vel = hrp.AssemblyLinearVelocity
	local gravity = workspace.Gravity

	local prev = pos
	local t = 0
	local hitGround = false
	local groundPoint = nil

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {char}

	for i = 1, AIR_STEPS do
		local t1 = t + AIR_STEP_TIME
		local x = pos.X + vel.X * t1
		local y = pos.Y + vel.Y * t1 - 0.5 * gravity * t1 * t1
		local z = pos.Z + vel.Z * t1
		local cur = Vector3.new(x, y, z)

		local seg = cur - prev
		local len = seg.Magnitude
		if len > 0.001 then
			local r = workspace:Raycast(prev, seg, params)
			if r then
				cur = r.Position
				groundPoint = cur
				hitGround = true
				seg = cur - prev
				len = seg.Magnitude
			end
		end

		if len > 0.001 then
			makeTrajSegment(prev, cur, 0.1 + (i / AIR_STEPS) * 0.6)
		end

		if i % 10 == 0 and not hitGround then
			makeTrajDot(cur, TRAJ_THICKNESS * 2.2)
		end

		prev = cur
		t = t1
		if hitGround then break end
		if cur.Y < pos.Y - 1000 then break end
	end

	if groundPoint then
		local marker = Instance.new("Part")
		marker.Shape = Enum.PartType.Cylinder
		marker.Size = Vector3.new(0.05, 2.2, 2.2)
		marker.Anchored = true
		marker.CanCollide = false
		marker.CanQuery = false
		marker.CanTouch = false
		marker.Material = Enum.Material.Neon
		marker.Color = TRAJ_COLOR
		marker.Transparency = 0.4
		marker.CFrame = CFrame.new(groundPoint + Vector3.new(0, 0.05, 0)) * CFrame.Angles(0, 0, math.rad(90))
		marker.Parent = workspace
		table.insert(trajectoryParts, marker)
	end
end

local function renderTrajectory()
	if not TRAJECTORY_ENABLED then clearTrajectory() return end
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not (hrp and hum) then return end

	clearTrajectory()

	local isGrounded = hum.FloorMaterial ~= Enum.Material.Air
	if isGrounded then
		renderGroundLine(char, hrp, hum)
	else
		renderAirParabola(char, hrp)
	end
end

-- ===================== MAIN LOOP =====================

local prevVel = Vector3.zero
local prevPos = nil
local airStartTime = nil
local lastCeilingHit, lastWallHit, lastFlingTime, lastWallClipTime = 0,0,0,0
local lastSlopeBoostTime, lastCornerBoostTime, lastTrimpTime, lastOnGroundTime = 0,0,0,0
local CEILING_CD, WALL_CD, FLING_CD, WALLCLIP_CD, SLOPE_CD, CORNER_CD, TRIMP_CD = 0.4,0.4,0.6,0.8,0.8,0.8,0.8
local VEL_SPIKE_TH, FLING_TH, WALLCLIP_VEL_TH, SLOPE_ANGLE_TH, TRIMP_VEL_UP_TH, BHOP_WINDOW = 80,150,25,30,60,0.15

local function raycast(origin, dir, ignore)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = ignore
	return workspace:Raycast(origin, dir, params)
end

RunService.Heartbeat:Connect(function(dt)
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local cam = workspace.CurrentCamera

	if TRAJECTORY_ENABLED and os.clock() - lastTrajUpdate > 0.04 then
		lastTrajUpdate = os.clock()
		renderTrajectory()
	end

	dbgFrameTime.Text = "Frame Time: " .. string.format("%.6f", dt)
	if hrp then
		dbgRootPos.Text = "Root Position: " .. fmtVec(hrp.Position)
		local rx, ry, rz = hrp.CFrame:ToOrientation()
		dbgRootRot.Text = string.format("Root Rotation: %s,%s,%s", fmt(math.deg(rx)), fmt(math.deg(ry)), fmt(math.deg(rz)))
		dbgLinVel.Text = "Linear Velocity: " .. fmtVec(hrp.AssemblyLinearVelocity)
		dbgAngVel.Text = "Angular Velocity: " .. fmtVec(hrp.AssemblyAngularVelocity)
	else
		dbgRootPos.Text = "Root Position: -"
		dbgRootRot.Text = "Root Rotation: -"
		dbgLinVel.Text = "Linear Velocity: -"
		dbgAngVel.Text = "Angular Velocity: -"
	end
	dbgHumState.Text = "Humanoid State: " .. (hum and hum:GetState().Name or "-")
	if cam and hrp then
		local cx, cy, cz = cam.CFrame:ToOrientation()
		dbgCamRot.Text = string.format("Camera Rotation: %s,%s,%s", fmt(math.deg(cx)), fmt(math.deg(cy)), fmt(math.deg(cz)))
		dbgZoom.Text = "Zoom: " .. string.format("%.3f", (cam.CFrame.Position - hrp.Position).Magnitude)
	end
	if not (hrp and hum) then return end
	local vel = hrp.AssemblyLinearVelocity
	local pos = hrp.Position
	local ignore = {char}
	if hum.FloorMaterial == Enum.Material.Air then
		if not airStartTime then airStartTime = os.clock() end
		bugAirTime.Text = string.format("Air Time: %.2fs", os.clock() - airStartTime)
	else
		airStartTime = nil
		lastOnGroundTime = os.clock()
		bugAirTime.Text = "Air Time: ground"
	end
	local fall = -vel.Y
	bugFallSpeed.Text = fall > 0 and string.format("Fall Speed: %.1f", fall) or "Fall Speed: -"
	local delta = (vel - prevVel).Magnitude
	bugVelSpike.Text = string.format("Vel Spike: %.1f", delta)
	if vel.Magnitude > FLING_TH and (os.clock() - lastFlingTime) > FLING_CD then
		lastFlingTime = os.clock()
		pushEvent(string.format("FLING %.0f", vel.Magnitude), Color3.fromRGB(255, 100, 100))
	end
	if delta > VEL_SPIKE_TH then
		pushEvent(string.format("VEL SPIKE +%.0f", delta), Color3.fromRGB(255, 200, 120))
	end
	local upRay = raycast(pos, Vector3.new(0, 4, 0), ignore)
	if upRay and vel.Y > 5 and (os.clock() - lastCeilingHit) > CEILING_CD then
		lastCeilingHit = os.clock()
		pushEvent("CEILING HIT", Color3.fromRGB(255, 180, 80))
	end
	if (os.clock() - lastWallHit) > WALL_CD then
		local dirs = {Vector3.new(3,0,0), Vector3.new(-3,0,0), Vector3.new(0,0,3), Vector3.new(0,0,-3)}
		for _, d in ipairs(dirs) do
			local r = raycast(pos, d, ignore)
			if r then
				local velDir = Vector3.new(vel.X, 0, vel.Z)
				if velDir.Magnitude > 20 and velDir.Unit:Dot(d.Unit) > 0.6 then
					lastWallHit = os.clock()
					pushEvent(string.format("WALL HIT %.0f", velDir.Magnitude), Color3.fromRGB(120, 200, 255))
				end
				break
			end
		end
	end
	if prevPos and (os.clock() - lastWallClipTime) > WALLCLIP_CD then
		local horiz = Vector3.new(vel.X, 0, vel.Z).Magnitude
		local moved = (pos - prevPos)
		local movedHoriz = Vector3.new(moved.X, 0, moved.Z).Magnitude
		if horiz > WALLCLIP_VEL_TH and movedHoriz < 0.05 and delta > 30 then
			lastWallClipTime = os.clock()
			pushEvent(string.format("WALL CLIP v=%.0f", horiz), Color3.fromRGB(255, 120, 200))
		end
	end
	if hum.FloorMaterial ~= Enum.Material.Air and (os.clock() - lastSlopeBoostTime) > SLOPE_CD then
		local downRay = raycast(pos, Vector3.new(0, -6, 0), ignore)
		if downRay then
			local n = downRay.Normal
			local angle = math.deg(math.acos(math.clamp(n.Y, -1, 1)))
			local horiz = Vector3.new(vel.X, 0, vel.Z).Magnitude
			if angle > SLOPE_ANGLE_TH and horiz > 25 then
				lastSlopeBoostTime = os.clock()
				pushEvent(string.format("SLOPE %.0f", angle), Color3.fromRGB(160, 255, 160))
			end
		end
	end
	if (os.clock() - lastCornerBoostTime) > CORNER_CD and delta > 60 then
		local d1 = raycast(pos, Vector3.new(3,0,0), ignore)
		local d2 = raycast(pos, Vector3.new(0,0,3), ignore)
		local d3 = raycast(pos, Vector3.new(-3,0,0), ignore)
		local d4 = raycast(pos, Vector3.new(0,0,-3), ignore)
		local count = (d1 and 1 or 0) + (d2 and 1 or 0) + (d3 and 1 or 0) + (d4 and 1 or 0)
		if count >= 2 then
			lastCornerBoostTime = os.clock()
			pushEvent(string.format("CORNER +%.0f", delta), Color3.fromRGB(255, 160, 255))
		end
	end
	if (os.clock() - lastTrimpTime) > TRIMP_CD then
		local sinceGround = os.clock() - lastOnGroundTime
		if vel.Y > TRIMP_VEL_UP_TH and sinceGround < 0.2 then
			lastTrimpTime = os.clock()
			pushEvent(string.format("TRIMP %.0f", vel.Y), Color3.fromRGB(180, 255, 180))
		end
	end
	prevVel = vel
	prevPos = pos
	local horiz = Vector3.new(vel.X, 0, vel.Z).Magnitude
	local bhopWindow = os.clock() - lastOnGroundTime
	if hum.FloorMaterial ~= Enum.Material.Air and bhopWindow < BHOP_WINDOW then
		mvBhop.Text = string.format("Bhop: ready %.0fms", bhopWindow * 1000)
	else
		mvBhop.Text = "Bhop: -"
	end
	local strafeDot = 0
	if horiz > 0.5 then
		local moveDir = Vector3.new(vel.X, 0, vel.Z).Unit
		local camLook = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z).Unit
		strafeDot = moveDir:Dot(camLook)
	end
	mvStrafe.Text = string.format("Strafe: %.2f", strafeDot)
	if hum.FloorMaterial == Enum.Material.Air and horiz > 5 then
		mvAirStrafe.Text = string.format("Air-Strafe: v=%.0f", horiz)
	else
		mvAirStrafe.Text = "Air-Strafe: -"
	end
	local nearWall = nil
	if hum.FloorMaterial == Enum.Material.Air then
		for _, d in ipairs({Vector3.new(3,0,0), Vector3.new(-3,0,0), Vector3.new(0,0,3), Vector3.new(0,0,-3)}) do
			local r = raycast(pos, d, ignore)
			if r then nearWall = r break end
		end
	end
	mvWallrun.Text = nearWall and string.format("Wallrun: v=%.0f", horiz) or "Wallrun: -"
	mvSpeed.Text = string.format("Speed: %.1f", vel.Magnitude)
	mvGround.Text = "Ground: " .. tostring(hum.FloorMaterial)
	if horiz > 20 and hum.FloorMaterial ~= Enum.Material.Air then
		mvSlide.Text = string.format("Slide?: v=%.0f", horiz)
	else
		mvSlide.Text = "Slide: -"
	end
	if hum.FloorMaterial == Enum.Material.Air and vel.Y < 0 then
		local timeToGround = -pos.Y / math.min(vel.Y, -0.1)
		mvJumpWin.Text = string.format("Jump Win: %.2fs", math.max(timeToGround, 0))
	else
		mvJumpWin.Text = "Jump Win: -"
	end
end)

updateFrameCounter()
print("[TAS Recorder v16] loaded.")