-- ============================================================================
-- 🏴‍☠️ MTY GUI - ПОЛНАЯ ВЕРСИЯ (ИСПРАВЛЕННАЯ)
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
-- 🏴‍☠️ GUI
-- ============================================================================

local gui = Instance.new("ScreenGui")
gui.Name = "MTY_GUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- ============================================================================
-- 🏴‍☠️ ПЕРЕМЕННЫЕ
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
    AimbotMode = "Standard",
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
    -- CUSTOM CURSOR
    CustomCursorImage = "rbxassetid://11716557686",
    CustomCursorSize = 50,
}

-- ============================================================================
-- 🏴‍☠️ ТОГГЛЫ
-- ============================================================================

local toggles = {
    -- ТВОИ ОРИГИНАЛЬНЫЕ
    esp = false, espV2 = false, jumpCircle = false, trail = false, trailV2 = false,
    chinaHat = false, worldColor = false, stretch = false, stretchV2 = false,
    hitGlow = false, fullbright = false, particlesV1 = false, particlesV2 = false,
    classicSword = false, worldColors = false, fog = false, nightVision = false,
    thermalVision = false, rainbowWorld = false, crosshair = false, hitboxes = false,
    hitboxExpander = false, aimbot = false, aimbotV2 = false, aimbotV3 = false,
    killAura = false, killAuraV2 = false, orbitKillAura = false, triggerBot = false,
    antiAim = false, antiAimV3 = false, desync = false, fakeLag = false, antiKb = false,
    speed = false, infiniteJump = false, airWalk = false, flyV1 = false, flyV2 = false,
    teleportTool = false, autoSprint = false, noClip = false, spider = false,
    swim = false, dash = false, invisibility = false, helicopter = false,
    r6Animations = false, bunnyHop = false, speedGlitch = false, wallHop = false,
    walkFling = false, autoFling = false, mm2EspV2 = false, mm2EspV3 = false,
    mm2AimbotV2 = false, doubleTap = false, autoStab = false, coinFarm = false,
    -- OBSIDIAN
    obsidianSpeed = false, obsidianJump = false, obsidianFly = false,
    obsidianFlyAnim = false, obsidianNoclip = false, obsidianEspMaster = false,
    obsidianTracers = false, obsidianHealthBar = false, obsidianBoxEsp = false,
    obsidianSkeleton = false, obsidianWaypointEsp = false, obsidianUseGroupTp = false,
    obsidianAutoTp = false, obsidianUsePathfinding = false, obsidianLoopPlayerTp = false,
    obsidianAutoTpNext = false, obsidianAcToggle = false, obsidianFbMaster = false,
    obsidianAutoFb = false, obsidianNoShadows = false, obsidianNoFog = false,
    obsidianWalkfling = false, obsidianNoVoid = false, obsidianGodMode = false,
    obsidianNoPromptCooldown = false,
    -- НОВЫЕ
    antiFling = true,
    customCursor = false,
}

-- ОСТАЛЬНЫЕ ПЕРЕМЕННЫЕ
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

-- ANTI-FLING ПЕРЕМЕННЫЕ
local antiFlingConnections = {}

-- CUSTOM CURSOR ПЕРЕМЕННЫЕ
local cursorGui = nil
local cursorImage = nil
local cursorConnection = nil

local connections = {}

-- ============================================================================
-- 🏴‍☠️ ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
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
            if n then callback(n) pcall(function() s:Destroy() end) else tb.Text = "Error" end
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
            {"Purple", Color3.fromRGB(130, 80, 255)}, {"Red", Color3.fromRGB(255, 0, 70)},
            {"Green", Color3.fromRGB(0, 255, 100)}, {"Blue", Color3.fromRGB(0, 150, 255)},
            {"Cyan", Color3.fromRGB(0, 255, 255)}, {"White", Color3.fromRGB(255,255,255)},
            {"Yellow", Color3.fromRGB(255,220,0)}, {"Orange", Color3.fromRGB(255, 165, 0)},
            {"Pink", Color3.fromRGB(255, 105, 180)}, {"Black", Color3.fromRGB(0, 0, 0)}
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
-- 🏴‍☠️ OBSIDIAN ВСПОМОГАТЕЛЬНЫЕ
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
-- 🏴‍☠️ ЯДРО ФУНКЦИЙ
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
-- 🏴‍☠️ ANTI-AIM V2
-- ============================================================================

function ToggleAntiAim()
    toggles.antiAim = not toggles.antiAim
    if toggles.antiAim then
        if player.Character and player.Character:FindFirstChild("Humanoid") then 
            player.Character.Humanoid.AutoRotate = false 
        end
        if connections.antiAim then connections.antiAim:Disconnect() end
        connections.antiAim = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not toggles.antiAim or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
                local root = player.Character.HumanoidRootPart
                local mode = guiSettings.AntiAimMode or "Spin"
                
                if mode == "Spin" then 
                    root.AssemblyAngularVelocity = Vector3.new(0, 65, 0)
                elseif mode == "Backwards" then 
                    local camLook = Camera.CFrame.LookVector 
                    root.CFrame = CFrame.new(root.Position, root.Position - Vector3.new(camLook.X, 0, camLook.Z))
                    if player.Character.Humanoid and player.Character.Humanoid.MoveDirection.Magnitude > 0 then
                        local moveDir = player.Character.Humanoid.MoveDirection
                        root.AssemblyLinearVelocity = Vector3.new(
                            -moveDir.X * 20,
                            root.AssemblyLinearVelocity.Y,
                            -moveDir.Z * 20
                        )
                    end
                elseif mode == "Jitter" then 
                    local time = tick()
                    local jitterAngle = math.sin(time * 30) * 45
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(jitterAngle), 0)
                elseif mode == "Downwards" then 
                    root.CFrame = CFrame.new(root.Position, root.Position - Vector3.new(0, 1, 0))
                elseif mode == "Random" then 
                    local time = tick()
                    local randAngle = math.sin(time * 20) * 180
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(randAngle), 0)
                end
            end)
        end)
        ShowMessage("🏴‍☠️ Anti-Aim ON (" .. mode .. ")")
    else
        if connections.antiAim then connections.antiAim:Disconnect() end
        if player.Character and player.Character:FindFirstChild("Humanoid") then 
            player.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0,0,0) 
            player.Character.Humanoid.AutoRotate = true 
        end
        ShowMessage("🏴‍☠️ Anti-Aim OFF")
    end
end

function CycleAntiAimMode()
    local modes = {"Spin", "Backwards", "Jitter", "Downwards", "Random"}
    local current = guiSettings.AntiAimMode or "Spin"
    local idx = 1
    for i, v in ipairs(modes) do 
        if v == current then idx = i break end 
    end
    local nextIdx = idx % #modes + 1
    guiSettings.AntiAimMode = modes[nextIdx]
    ShowMessage("🏴‍☠️ Anti-Aim Mode: " .. modes[nextIdx])
end

-- ============================================================================
-- 🏴‍☠️ AIMBOT
-- ============================================================================

function ToggleAimbot()
    toggles.aimbot = not toggles.aimbot
    if toggles.aimbot then
        ShowMessage("🏴‍☠️ Aimbot ON (" .. guiSettings.AimbotMode .. ")")
        if not fovGui then fovGui = Instance.new("ScreenGui", game.CoreGui) fovGui.Name = "MTY_FOV" end
        if not fovRing then
            fovRing = Instance.new("Frame", fovGui)
            fovRing.AnchorPoint = Vector2.new(0.5,0.5)
            fovRing.Position = UDim2.new(0.5,0,0.5,0)
            fovRing.BackgroundTransparency = 1
            fovRing.Visible = false
            fovStroke = Instance.new("UIStroke", fovRing)
            fovStroke.Thickness = 1.5
            fovStroke.Color = guiSettings.BorderColor
            Instance.new("UICorner", fovRing).CornerRadius = UDim.new(1, 0)
        end
        fovRing.Visible = true
        fovRing.Size = UDim2.new(0, guiSettings.AimbotFOV * 2, 0, guiSettings.AimbotFOV * 2)
        
        task.spawn(function()
            while toggles.aimbot do
                RunService.RenderStepped:Wait()
                pcall(function()
                    if fovRing then
                        fovRing.Size = UDim2.new(0, guiSettings.AimbotFOV * 2, 0, guiSettings.AimbotFOV * 2)
                        if fovStroke then fovStroke.Color = guiSettings.BorderColor end
                    end
                    if toggles.aimbot then
                        local tPlayer = FindBestTarget()
                        targetPlayer = tPlayer
                        if tPlayer and tPlayer.Character and tPlayer.Character:FindFirstChild(guiSettings.AimbotPart) then
                            local hit = tPlayer.Character[guiSettings.AimbotPart]
                            local pos = hit.Position
                            local mode = guiSettings.AimbotMode or "Standard"
                            
                            if mode == "Prediction" or mode == "Silent" then
                                local root = tPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if root then
                                    pos = pos + (root.AssemblyLinearVelocity * 0.05)
                                end
                            end
                            
                            if mode == "Standard" then
                                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, pos), math.clamp(guiSettings.AimbotSpeed * guiSettings.AimbotStrength, 0.01, 1))
                            elseif mode == "Flick" then
                                local oldCF = Camera.CFrame
                                Camera.CFrame = CFrame.new(Camera.CFrame.Position, pos)
                                task.wait()
                                Camera.CFrame = oldCF
                            elseif mode == "Prediction" then
                                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, pos), math.clamp(guiSettings.AimbotSpeed * guiSettings.AimbotStrength * 1.2, 0.01, 1))
                            elseif mode == "Silent" then
                                local tool = player.Character:FindFirstChildOfClass("Tool")
                                if tool then
                                    local remote = GetDmgRemote(tool)
                                    if remote then
                                        remote:FireServer(hit)
                                    end
                                end
                            end                        end
                    end
                end)
            end
        end)
    else
        if fovRing then fovRing.Visible = false end
        ShowMessage("🏴‍☠️ Aimbot OFF")
    end
end

function CycleAimbotMode()
    local modes = {"Standard", "Flick", "Prediction", "Silent"}
    local current = guiSettings.AimbotMode or "Standard"
    local idx = 1
    for i, v in ipairs(modes) do 
        if v == current then idx = i break end 
    end
    local nextIdx = idx % #modes + 1
    guiSettings.AimbotMode = modes[nextIdx]
    ShowMessage("🏴‍☠️ Aimbot Mode: " .. modes[nextIdx])
end

-- ============================================================================
-- 📋 ВСЕ ТВОИ ФУНКЦИИ MTY
-- ============================================================================

-- VISUAL
function ToggleESP()
    toggles.esp = not toggles.esp
    if toggles.esp then
        ShowMessage("🏴‍☠️ ESP ON")
        task.spawn(function()
            while toggles.esp do
                task.wait(0.2)
                pcall(function()
                    if not espFolder then espFolder = Instance.new("Folder", workspace) espFolder.Name = "MTY_ESP" end
                    espFolder:ClearAllChildren()
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= player and p.Character then
                            local h = Instance.new("Highlight", espFolder)
                            h.Adornee = p.Character
                            h.FillColor = guiSettings.ESPColor
                            h.FillTransparency = 0.4
                        end
                    end
                end)
            end
        end)
    else
        if espFolder then espFolder:ClearAllChildren() end
        ShowMessage("🏴‍☠️ ESP OFF")
    end
end

function ToggleESPV2()
    toggles.espV2 = not toggles.espV2
    if toggles.espV2 then
        ShowMessage("🏴‍☠️ ESP V2 ON")
        task.spawn(function()
            while toggles.espV2 do
                task.wait(0.2)
                pcall(function()
                    if not espV2Folder then espV2Folder = Instance.new("Folder", workspace) espV2Folder.Name = "MTY_ESP_V2" end
                    espV2Folder:ClearAllChildren()
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local b = Instance.new("BoxHandleAdornment", espV2Folder)
                            b.Size = Vector3.new(4.3, 5.6, 4.3)
                            b.Color3 = guiSettings.ESPColor
                            b.Transparency = 0.6
                            b.AlwaysOnTop = true
                            b.Adornee = p.Character.HumanoidRootPart
                        end
                    end
                end)
            end
        end)
    else
        if espV2Folder then espV2Folder:ClearAllChildren() end
        ShowMessage("🏴‍☠️ ESP V2 OFF")
    end
end

function ToggleJumpCircle()
    toggles.jumpCircle = not toggles.jumpCircle
    if toggles.jumpCircle then
        if connections.jumpCircle then connections.jumpCircle:Disconnect() end
        connections.jumpCircle = (player.Character or player.CharacterAdded:Wait()):WaitForChild("Humanoid").Jumping:Connect(function()
            if toggles.jumpCircle and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    local disk = Instance.new("Part", workspace)
                    disk.Shape = Enum.PartType.Cylinder
                    disk.Size = Vector3.new(0.02, 2, 2)
                    disk.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position - Vector3.new(0, 2.8, 0)) * CFrame.Angles(0, 0, math.rad(90))
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
        end)
        ShowMessage("🏴‍☠️ Jump Circle ON")
    else
        if connections.jumpCircle then connections.jumpCircle:Disconnect() end
        ShowMessage("🏴‍☠️ Jump Circle OFF")
    end
end

function ToggleTrail()
    toggles.trail = not toggles.trail
    if toggles.trail then
        trailParts = {}
        if connections.trail then connections.trail:Disconnect() end
        connections.trail = RunService.Heartbeat:Connect(function()
            if not toggles.trail or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
            pcall(function()
                local p = Instance.new("Part", workspace)
                p.Size = Vector3.new(0.3, 0.3, 0.3)
                p.CFrame = player.Character.HumanoidRootPart.CFrame
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
        ShowMessage("🏴‍☠️ Trail ON")
    else
        if connections.trail then connections.trail:Disconnect() end
        for _, v in pairs(trailParts) do v:Destroy() end
        trailParts = {}
        ShowMessage("🏴‍☠️ Trail OFF")
    end
end

function ToggleTrailV2()
    toggles.trailV2 = not toggles.trailV2
    if toggles.trailV2 then
        pcall(function()
            if not player.Character or not player.Character:FindFirstChild("Head") then return end
            local trailAnchor = Instance.new("Part", player.Character.Head)
            trailAnchor.Size = Vector3.new(0.1, 0.1, 0.1)
            trailAnchor.Transparency = 1
            trailAnchor.CanCollide = false
            trailAnchor.Massless = true
            trailAnchor.Name = "MTY_TrailAnchor"
            local weld = Instance.new("Weld", trailAnchor)
            weld.Part0 = player.Character.Head
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
            ShowMessage("🏴‍☠️ Trail V2 ON")
        end)
    else
        if player.Character and player.Character:FindFirstChild("Head") then
            local anchor = player.Character.Head:FindFirstChild("MTY_TrailAnchor")
            if anchor then anchor:Destroy() end
        end
        ShowMessage("🏴‍☠️ Trail V2 OFF")
    end
end

function ToggleChineseHat()
    toggles.chinaHat = not toggles.chinaHat
    if toggles.chinaHat then
        pcall(function()
            if currentHat then currentHat:Destroy() end
            if hatConnection then hatConnection:Disconnect() end
            if not player.Character or not player.Character:FindFirstChild("Head") then return end
            currentHat = Instance.new("Part", player.Character)
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
                    if not currentHat or not player.Character or not player.Character:FindFirstChild("Head") then return end
                    local color = guiSettings.HatRainbow and Color3.fromHSV((tick() * 0.4) % 1, 1, 1) or guiSettings.HatColor
                    currentHat.Color = color
                    trail.Color = ColorSequence.new(color)
                    currentHat.CFrame = player.Character.Head.CFrame * CFrame.new(0, 0.6, 0)
                end)
            end)
            ShowMessage("🏴‍☠️ China Hat ON")
        end)
    else
        if currentHat then currentHat:Destroy() end
        if hatConnection then hatConnection:Disconnect() end
        ShowMessage("🏴‍☠️ China Hat OFF")
    end
end

function ToggleWorldColor()
    toggles.worldColor = not toggles.worldColor
    if toggles.worldColor then
        ShowMessage("🏴‍☠️ World Color ON")
        originalAmbient = Lighting.Ambient
        originalOutdoor = Lighting.OutdoorAmbient
        if connections.worldColors then connections.worldColors:Disconnect() end
        connections.worldColors = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not toggles.worldColor then return end
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
        if connections.worldColors then connections.worldColors:Disconnect() end
        Lighting.Ambient = originalAmbient or Color3.fromRGB(127, 127, 127)
        Lighting.OutdoorAmbient = originalOutdoor or Color3.fromRGB(127, 127, 127)
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Transparency = 0
            end
        end
        ShowMessage("🏴‍☠️ World Color OFF")
    end
end

function ToggleStretch()
    toggles.stretch = not toggles.stretch
    if toggles.stretch then
        ShowMessage("🏴‍☠️ Stretch ON")
        if connections.stretch then connections.stretch:Disconnect() end
        connections.stretch = RunService.RenderStepped:Connect(function()
            if player.Character then
                for _, v in pairs(player.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Size = v.Size * guiSettings.StretchValue
                    end
                end
            end
        end)
    else
        if connections.stretch then connections.stretch:Disconnect() end
        ShowMessage("🏴‍☠️ Stretch OFF")
    end
end

function ToggleStretchV2()
    toggles.stretchV2 = not toggles.stretchV2
    if toggles.stretchV2 then
        ShowMessage("🏴‍☠️ Stretch V2 ON")
        if connections.stretchV2 then connections.stretchV2:Disconnect() end
        connections.stretchV2 = RunService.RenderStepped:Connect(function()
            if player.Character then
                for _, v in pairs(player.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Size = v.Size * 0.5
                    end
                end
            end
        end)
    else
        if connections.stretchV2 then connections.stretchV2:Disconnect() end
        ShowMessage("🏴‍☠️ Stretch V2 OFF")
    end
end

function ToggleHitGlow()
    toggles.hitGlow = not toggles.hitGlow
    ShowMessage(toggles.hitGlow and "🏴‍☠️ HitGlow ON" or "🏴‍☠️ HitGlow OFF")
end

function ToggleFullbright()
    toggles.fullbright = not toggles.fullbright
    if toggles.fullbright then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        ShowMessage("🏴‍☠️ Fullbright ON")
    else
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        ShowMessage("🏴‍☠️ Fullbright OFF")
    end
end

function ToggleParticlesV1()
    toggles.particlesV1 = not toggles.particlesV1
    if toggles.particlesV1 then
        if connections.particles then connections.particles:Disconnect() end
        connections.particles = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not toggles.particlesV1 or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
                for i = 1, 3 do
                    local p = Instance.new("Part", workspace)
                    p.Size = Vector3.new(0.2, 0.2, 0.2)
                    p.Anchored = true
                    p.CanCollide = false
                    p.Material = Enum.Material.Neon
                    p.Color = guiSettings.ParticleColor
                    p.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-8, 8), math.random(-3, 5), math.random(-8, 8))
                    Debris:AddItem(p, 0.5)
                end
            end)
        end)
        ShowMessage("🏴‍☠️ Particles V1 ON")
    else
        if connections.particles then connections.particles:Disconnect() end
        ShowMessage("🏴‍☠️ Particles V1 OFF")
    end
end

function ToggleParticlesV2()
    toggles.particlesV2 = not toggles.particlesV2
    if toggles.particlesV2 then
        if connections.particlesV2 then connections.particlesV2:Disconnect() end
        connections.particlesV2 = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not toggles.particlesV2 or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
                local p = Instance.new("Part", workspace)
                p.Size = Vector3.new(0.3, 0.3, 0.3)
                p.Anchored = true
                p.CanCollide = false
                p.Material = Enum.Material.Neon
                p.Color = guiSettings.ParticleColor
                p.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-15, 15), math.random(-4, 6), math.random(-15, 15))
                Debris:AddItem(p, 0.8)
            end)
        end)
        ShowMessage("🏴‍☠️ Particles V2 ON")
    else
        if connections.particlesV2 then connections.particlesV2:Disconnect() end
        ShowMessage("🏴‍☠️ Particles V2 OFF")
    end
end

function ToggleClassicSword()
    toggles.classicSword = not toggles.classicSword
    if toggles.classicSword then
        pcall(function()
            if not player.Character then ShowMessage("🏴‍☠️ No character!") return end
            if currentSword then currentSword:Destroy() end
            currentSword = Instance.new("Tool", player.Backpack)
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
                        local animTrack = player.Character.Humanoid:LoadAnimation(anim)
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
                        if p and p ~= player then
                            if o.Health > 0 then
                                o.Health = o.Health - 20
                                ShowMessage("🏴‍☠️ Hit: " .. p.Name)
                            end
                        end
                    end
                end
            end)
            ShowMessage("🏴‍☠️ Classic Sword ON")
        end)
    else
        if currentSword then currentSword:Destroy() end
        ShowMessage("🏴‍☠️ Classic Sword OFF")
    end
end

function ToggleWorldColors()
    toggles.worldColors = not toggles.worldColors
    if toggles.worldColors then
        ShowMessage("🏴‍☠️ World Colors ON")
        if connections.worldColors2 then connections.worldColors2:Disconnect() end
        connections.worldColors2 = RunService.RenderStepped:Connect(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Color = guiSettings.WorldColor
                end
            end
        end)
    else
        if connections.worldColors2 then connections.worldColors2:Disconnect() end
        ShowMessage("🏴‍☠️ World Colors OFF")
    end
end

function ToggleFog()
    toggles.fog = not toggles.fog
    if toggles.fog then
        ShowMessage("🏴‍☠️ Fog ON")
        Lighting.FogEnd = guiSettings.FogEnd or 100
        Lighting.FogStart = guiSettings.FogStart or 0
        Lighting.FogColor = guiSettings.FogColor or Color3.fromRGB(150, 100, 200)
        if connections.fog then connections.fog:Disconnect() end
        connections.fog = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not toggles.fog then return end
                local time = tick() * 0.1
                Lighting.FogEnd = guiSettings.FogEnd + math.sin(time) * 20
                Lighting.FogColor = guiSettings.FogColor
            end)
        end)
    else
        if connections.fog then connections.fog:Disconnect() end
        Lighting.FogEnd = 1000
        Lighting.FogStart = 0
        Lighting.FogColor = Color3.fromRGB(255, 255, 255)
        ShowMessage("🏴‍☠️ Fog OFF")
    end
end

function ToggleNightVision()
    toggles.nightVision = not toggles.nightVision
    if toggles.nightVision then
        ShowMessage("🏴‍☠️ Night Vision ON")
        Lighting.Ambient = Color3.fromRGB(0, 255, 0)
        Lighting.Brightness = 2
        Lighting.ClockTime = 0
        if connections.nightVision then connections.nightVision:Disconnect() end
        connections.nightVision = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not toggles.nightVision then return end
                Lighting.Ambient = Color3.fromRGB(0, 255, 0)
                Lighting.ColorShift_Top = Color3.fromRGB(0, 200, 0)
                Lighting.ColorShift_Bottom = Color3.fromRGB(0, 100, 0)
            end)
        end)
    else
        if connections.nightVision then connections.nightVision:Disconnect() end
        Lighting.Ambient = originalAmbient or Color3.fromRGB(127, 127, 127)
        Lighting.Brightness = 1
        Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
        Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
        Lighting.ClockTime = 14
        ShowMessage("🏴‍☠️ Night Vision OFF")
    end
end

function ToggleThermalVision()
    toggles.thermalVision = not toggles.thermalVision
    if toggles.thermalVision then
        ShowMessage("🏴‍☠️ Thermal Vision ON")
        if connections.thermalVision then connections.thermalVision:Disconnect() end
        connections.thermalVision = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not toggles.thermalVision then return end
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character then
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
        if connections.thermalVision then connections.thermalVision:Disconnect() end
        ShowMessage("🏴‍☠️ Thermal Vision OFF")
    end
end

function ToggleRainbowWorld()
    toggles.rainbowWorld = not toggles.rainbowWorld
    if toggles.rainbowWorld then
        ShowMessage("🏴‍☠️ Rainbow World ON")
        if connections.rainbowWorld then connections.rainbowWorld:Disconnect() end
        connections.rainbowWorld = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not toggles.rainbowWorld then return end
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
        if connections.rainbowWorld then connections.rainbowWorld:Disconnect() end
        ShowMessage("🏴‍☠️ Rainbow World OFF")
    end
end

function ToggleCrosshair()
    toggles.crosshair = not toggles.crosshair
    if toggles.crosshair then
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
        ShowMessage("🏴‍☠️ Crosshair ON")
    else
        if crosshairGui then crosshairGui:Destroy() end
        ShowMessage("🏴‍☠️ Crosshair OFF")
    end
end

function ToggleHitboxes()
    toggles.hitboxes = not toggles.hitboxes
    if toggles.hitboxes then
        if not HitboxFolder then HitboxFolder = Instance.new("Folder", workspace) HitboxFolder.Name = "MTY_Hitboxes" end
        HitboxFolder:ClearAllChildren()
        if connections.hitbox then connections.hitbox:Disconnect() end
        connections.hitbox = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not toggles.hitboxes then return end
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
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
        ShowMessage("🏴‍☠️ Hitboxes ON")
    else
        if connections.hitbox then connections.hitbox:Disconnect() end
        if HitboxFolder then HitboxFolder:ClearAllChildren() end
        ShowMessage("🏴‍☠️ Hitboxes OFF")
    end
end

function ToggleHitboxExpander()
    toggles.hitboxExpander = not toggles.hitboxExpander
    if toggles.hitboxExpander then
        ShowMessage("🏴‍☠️ Hitbox Expander ON")
        RunService.Heartbeat:Connect(function()
            pcall(function()
                if not toggles.hitboxExpander or not player.Character then return end
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character then
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
        ShowMessage("🏴‍☠️ Hitbox Expander OFF")
    end
end

-- COMBAT
function ToggleKillAura()
    toggles.killAura = not toggles.killAura
    if toggles.killAura then
        if connections.killAura then connections.killAura:Disconnect() end
        connections.killAura = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not toggles.killAura or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if not tool then return end
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        local dist = (player.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= guiSettings.KillAuraRange then
                            AttackPlayer(p.Character, tool)
                        end
                    end
                end
            end)
        end)
        ShowMessage("🏴‍☠️ Kill Aura ON")
    else
        if connections.killAura then connections.killAura:Disconnect() end
        ShowMessage("🏴‍☠️ Kill Aura OFF")
    end
end

function ToggleKillAuraV2()
    toggles.killAuraV2 = not toggles.killAuraV2
    if toggles.killAuraV2 then
        if connections.killAuraV2 then connections.killAuraV2:Disconnect() end
        connections.killAuraV2 = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not toggles.killAuraV2 or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if not tool then return end
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        local dist = (player.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if dist <= (guiSettings.KillAuraRange + 4) then
                            AttackPlayer(p.Character, tool)
                            player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(120), 0)
                        end
                    end
                end
            end)
        end)
        ShowMessage("🏴‍☠️ Kill Aura V2 ON")
    else
        if connections.killAuraV2 then connections.killAuraV2:Disconnect() end
        ShowMessage("🏴‍☠️ Kill Aura V2 OFF")
    end
end

function ToggleOrbitKillAura()
    toggles.orbitKillAura = not toggles.orbitKillAura
    if toggles.orbitKillAura then
        if not orbitButton then
            orbitButton = Instance.new("TextButton", gui)
            orbitButton.Size = UDim2.new(0, 40, 0, 40)
            orbitButton.Position = UDim2.new(0.85, 0, 0.7, 0)
            orbitButton.BackgroundColor3 = guiSettings.OrbitColor
            orbitButton.Text = "O"
            orbitButton.TextColor3 = Color3.new(1,1,1)
            orbitButton.TextSize = 20
            orbitButton.Font = Enum.Font.GothamBold
            orbitButton.ZIndex = 10
            Instance.new("UICorner", orbitButton).CornerRadius = UDim.new(1, 0)
            Instance.new("UIStroke", orbitButton).Color = Color3.fromRGB(255,255,255)
            Instance.new("UIStroke", orbitButton).Thickness = 2
            orbitButton.MouseButton1Click:Connect(ToggleOrbitKillAura)
        end
        orbitButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        orbitButton.Text = "O N"
        if connections.orbitKillAura then connections.orbitKillAura:Disconnect() end
        connections.orbitKillAura = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not toggles.orbitKillAura or not player.Character then return end
                local myRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if not myRoot then return end
                local nearest = nil
                local nearestDist = guiSettings.OrbitRadius or 8
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character then
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
                    local tool = player.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                        local remote = GetDmgRemote(tool)
                        if remote then remote:FireServer(targetRoot) end
                    end
                    if toggles.hitGlow then
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
        ShowMessage("🏴‍☠️ Orbit Kill Aura ON")
    else
        if connections.orbitKillAura then connections.orbitKillAura:Disconnect() end
        if orbitButton then
            orbitButton.BackgroundColor3 = guiSettings.OrbitColor
            orbitButton.Text = "O"
        end
        ShowMessage("🏴‍☠️ Orbit Kill Aura OFF")
    end
end

function ToggleTriggerBot()
    toggles.triggerBot = not toggles.triggerBot
    ShowMessage(toggles.triggerBot and "🏴‍☠️ Trigger Bot ON" or "🏴‍☠️ Trigger Bot OFF")
end

function ToggleDesync()
    toggles.desync = not toggles.desync
    if toggles.desync then
        ShowMessage("🏴‍☠️ Desync ON")
        if connections.desync then connections.desync:Disconnect() end
        connections.desync = RunService.Heartbeat:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local root = player.Character.HumanoidRootPart
                local time = tick()
                local offset = math.sin(time * 10) * 0.5
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(offset), 0)
            end
        end)
    else
        if connections.desync then connections.desync:Disconnect() end
        ShowMessage("🏴‍☠️ Desync OFF")
    end
end

function ToggleFakeLag()
    toggles.fakeLag = not toggles.fakeLag
    if toggles.fakeLag then
        if connections.fakeLag then connections.fakeLag:Disconnect() end
        connections.fakeLag = RunService.Heartbeat:Connect(function()
            for i=1, guiSettings.FakeLagAmount or 6 do
                task.wait(0.001)
            end
        end)
        ShowMessage("🏴‍☠️ FakeLag ON")
    else
        if connections.fakeLag then connections.fakeLag:Disconnect() end
        ShowMessage("🏴‍☠️ FakeLag OFF")
    end
end

function ToggleAntiKb()
    toggles.antiKb = not toggles.antiKb
    if toggles.antiKb then
        ShowMessage("🏴‍☠️ Anti-Knockback ON")
        RunService.Heartbeat:Connect(function()
            pcall(function()
                if toggles.antiKb and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local vel = player.Character.HumanoidRootPart.AssemblyLinearVelocity
                    if vel.Magnitude > 60 then
                        player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
                    end
                end
            end)
        end)
    else
        ShowMessage("🏴‍☠️ Anti-Knockback OFF")
    end
end

-- MOVEMENT
function ToggleSpeed()
    toggles.speed = not toggles.speed
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local hum = player.Character.Humanoid
        if toggles.speed then
            hum.WalkSpeed = 50
            ShowMessage("🏴‍☠️ Speed ON (50)")
        else
            hum.WalkSpeed = 16
            ShowMessage("🏴‍☠️ Speed OFF")
        end
    end
end

function ToggleInfiniteJump()
    toggles.infiniteJump = not toggles.infiniteJump
    if toggles.infiniteJump then
        if connections.infJump then connections.infJump:Disconnect() end
        connections.infJump = UserInputService.JumpRequest:Connect(function()
            if toggles.infiniteJump and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        ShowMessage("🏴‍☠️ Infinite Jump ON")
    else
        if connections.infJump then connections.infJump:Disconnect() end
        ShowMessage("🏴‍☠️ Infinite Jump OFF")
    end
end

function ToggleAirWalk()
    toggles.airWalk = not toggles.airWalk
    if toggles.airWalk then
        task.spawn(function()
            local platform = Instance.new("Part", workspace)
            platform.Size = Vector3.new(6, 0.5, 6)
            platform.Anchored = true
            platform.Transparency = 1
            while toggles.airWalk do
                task.wait()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    platform.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position.X, player.Character.HumanoidRootPart.Position.Y - 2.8, player.Character.HumanoidRootPart.Position.Z)
                end
            end
            if platform then platform:Destroy() end
        end)
        ShowMessage("🏴‍☠️ Air Walk ON")
    else
        ShowMessage("🏴‍☠️ Air Walk OFF")
    end
end

function ToggleFlyV1()
    toggles.flyV1 = not toggles.flyV1
    if toggles.flyV1 then
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.PlatformStand = true
        end
        if connections.fly then connections.fly:Disconnect() end
        connections.fly = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not toggles.flyV1 or not player.Character then return end
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                local hum = player.Character:FindFirstChild("Humanoid")
                if not root or not hum then return end
                local moveDirection = hum.MoveDirection
                local cameraLook = Camera.CFrame.LookVector
                local cameraRight = Camera.CFrame.RightVector
                local vertical = 0
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertical = flySpeed
                elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vertical = -flySpeed end
                local moveVector = Vector3.new(0, 0, 0)
                if moveDirection.Magnitude > 0 then
                    moveVector = (cameraLook * moveDirection.Z + cameraRight * moveDirection.X) * flySpeed
                end
                root.AssemblyLinearVelocity = Vector3.new(moveVector.X, vertical, moveVector.Z)
                hum.PlatformStand = true
            end)
        end)
        ShowMessage("🏴‍☠️ Fly V1 ON")
    else
        if connections.fly then connections.fly:Disconnect() end
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.PlatformStand = false
        end
        ShowMessage("🏴‍☠️ Fly V1 OFF")
    end
end

function ToggleFlyV2()
    toggles.flyV2 = not toggles.flyV2
    if toggles.flyV2 then
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.PlatformStand = true
        end
        if connections.fly then connections.fly:Disconnect() end
        connections.fly = RunService.RenderStepped:Connect(function()
            pcall(function()
                if not toggles.flyV2 or not player.Character then return end
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                local hum = player.Character:FindFirstChild("Humanoid")
                if not root or not hum then return end
                local camLook = Camera.CFrame.LookVector
                local camRight = Camera.CFrame.RightVector
                local moveDirection = hum.MoveDirection
                local vertical = 0
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertical = flySpeed
                elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vertical = -flySpeed end
                local moveVector = Vector3.new(0, 0, 0)
                if moveDirection.Magnitude > 0 then
                    moveVector = (camLook * moveDirection.Z + camRight * moveDirection.X) * flySpeed
                end
                root.AssemblyLinearVelocity = Vector3.new(moveVector.X, vertical, moveVector.Z)
                hum.PlatformStand = true
            end)
        end)
        ShowMessage("🏴‍☠️ Fly V2 ON")
    else
        if connections.fly then connections.fly:Disconnect() end
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.PlatformStand = false
        end
        ShowMessage("🏴‍☠️ Fly V2 OFF")
    end
end

function ToggleTeleportTool()
    toggles.teleportTool = not toggles.teleportTool
    if toggles.teleportTool then
        local teleportTool = Instance.new("Tool", player.Backpack)
        teleportTool.RequiresHandle = false
        teleportTool.Name = "MTY TP Tool"
        teleportTool.Activated:Connect(function()
            pcall(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local camPos = Camera.CFrame.Position
                    local lookVec = Camera.CFrame.LookVector
                    local targetPos = camPos + (lookVec * 50)
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
                    ShowMessage("🏴‍☠️ Teleported!")
                end
            end)
        end)
        ShowMessage("🏴‍☠️ Teleport Tool ON")
    else
        local tool = player.Backpack:FindFirstChild("MTY TP Tool")
        if tool then tool:Destroy() end
        ShowMessage("🏴‍☠️ Teleport Tool OFF")
    end
end

function ToggleAutoSprint()
    toggles.autoSprint = not toggles.autoSprint
    if toggles.autoSprint then
        if connections.autoSprint then connections.autoSprint:Disconnect() end
        connections.autoSprint = RunService.Heartbeat:Connect(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = speedValue * 1.6
            end
        end)
        ShowMessage("🏴‍☠️ Auto Sprint ON")
    else
        if connections.autoSprint then connections.autoSprint:Disconnect() end
        ShowMessage("🏴‍☠️ Auto Sprint OFF")
    end
end

function ToggleNoClip()
    toggles.noClip = not toggles.noClip
    if toggles.noClip then
        if connections.noClip then connections.noClip:Disconnect() end
        connections.noClip = RunService.Stepped:Connect(function()
            if player.Character then
                for _, v in pairs(player.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
        ShowMessage("🏴‍☠️ NoClip ON")
    else
        if connections.noClip then connections.noClip:Disconnect() end
        ShowMessage("🏴‍☠️ NoClip OFF")
    end
end

function ToggleSpider()
    toggles.spider = not toggles.spider
    if toggles.spider then
        ShowMessage("🏴‍☠️ Spider Mode ON")
        task.spawn(function()
            while toggles.spider do
                task.wait(0.1)
                pcall(function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local r = player.Character.HumanoidRootPart
                        local ray = workspace:Raycast(r.Position, r.CFrame.LookVector * 2.5)
                        if ray and ray.Instance and math.abs(ray.Normal.Y) < 0.1 then
                            r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, speedValue, r.AssemblyLinearVelocity.Z)
                        end
                    end
                end)
            end
        end)
    else
        ShowMessage("🏴‍☠️ Spider Mode OFF")
    end
end

function ToggleSwim()
    toggles.swim = not toggles.swim
    if toggles.swim then
        ShowMessage("🏴‍☠️ Swim In Air ON")
        task.spawn(function()
            while toggles.swim do
                RunService.Heartbeat:Wait()
                pcall(function()
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
                    end
                end)
            end
        end)
    else
        ShowMessage("🏴‍☠️ Swim In Air OFF")
    end
end

function ToggleDash()
    toggles.dash = not toggles.dash
    if toggles.dash then
        if dashButton then dashButton:Destroy() end
        local sg = Instance.new("ScreenGui", game.CoreGui)
        sg.ResetOnSpawn = false
        sg.Name = "MTY_DashButtonUI"
        dashButton = Instance.new("TextButton", sg)
        dashButton.Size = UDim2.new(0, 60, 0, 60)
        dashButton.Position = UDim2.new(0.82, 0, 0.55, 0)
        dashButton.BackgroundColor3 = guiSettings.OnColor
        dashButton.Text = "D"
        dashButton.TextColor3 = Color3.new(1,1,1)
        dashButton.Font = Enum.Font.GothamBold
        dashButton.TextSize = 13
        Instance.new("UICorner", dashButton).CornerRadius = UDim.new(0, 30)
        Instance.new("UIStroke", dashButton).Thickness = 1.5
        dashButton.MouseButton1Click:Connect(function()
            pcall(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                    local root = player.Character.HumanoidRootPart
                    local dir = player.Character.Humanoid.MoveDirection.Magnitude > 0 and player.Character.Humanoid.MoveDirection or root.CFrame.LookVector
                    root.CFrame = root.CFrame + Vector3.new(dir.X, 0, dir.Z).Unit * 15
                end
            end)
        end)
        ShowMessage("🏴‍☠️ Dash ON")
    else
        if dashButton then dashButton.Parent:Destroy() dashButton = nil end
        ShowMessage("🏴‍☠️ Dash OFF")
    end
end

function ToggleInvisibility()
    toggles.invisibility = not toggles.invisibility
    if toggles.invisibility then
        ShowMessage("🏴‍☠️ FE Invisibility ON")
        task.spawn(function()
            while toggles.invisibility do
                RunService.Heartbeat:Wait()
                pcall(function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                        local root = player.Character.HumanoidRootPart
                        local oldCF = root.CFrame
                        root.CFrame = oldCF * CFrame.new(0, -500, 0)
                        RunService.RenderStepped:Wait()
                        root.CFrame = oldCF
                    end
                end)
            end
        end)
    else
        ShowMessage("🏴‍☠️ Invisibility OFF")
    end
end

function ToggleHelicopter()
    toggles.helicopter = not toggles.helicopter
    if toggles.helicopter then
        ShowMessage("🏴‍☠️ Helicopter ON")
        task.spawn(function()
            pcall(function()
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
                local root = player.Character.HumanoidRootPart
                local bForce = Instance.new("BodyForce", root)
                bForce.Name = "MTY_HeliForce"
                bForce.Force = Vector3.new(0, (workspace.Gravity * root:GetMass()) * 1.35, 0)
                local bAngular = Instance.new("BodyAngularVelocity", root)
                bAngular.Name = "MTY_HeliRot"
                bAngular.MaxTorque = Vector3.new(0, 999999, 0)
                bAngular.AngularVelocity = Vector3.new(0, 38, 0)
                while toggles.helicopter do
                    task.wait(0.1)
                end
                if root:FindFirstChild("MTY_HeliForce") then root.MTY_HeliForce:Destroy() end
                if root:FindFirstChild("MTY_HeliRot") then root.MTY_HeliRot:Destroy() end
            end)
        end)
    else
        ShowMessage("🏴‍☠️ Helicopter OFF")
    end
end

function ToggleR6Animations()
    toggles.r6Animations = not toggles.r6Animations
    if toggles.r6Animations then
        ShowMessage("🏴‍☠️ R6 Animations ON")
        if player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum and hum.RigType == Enum.HumanoidRigType.R15 then
                local animate = player.Character:FindFirstChild("Animate")
                if animate then animate.Disabled = true end
            end
        end
        if connections.r6Animations then connections.r6Animations:Disconnect() end
        connections.r6Animations = player.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum.RigType == Enum.HumanoidRigType.R15 then
                local animate = char:FindFirstChild("Animate")
                if animate then animate.Disabled = true end
            end
        end)
    else
        if connections.r6Animations then connections.r6Animations:Disconnect() end
        if player.Character then
            local animate = player.Character:FindFirstChild("Animate")
            if animate then animate.Disabled = false end
        end
        ShowMessage("🏴‍☠️ R6 Animations OFF")
    end
end

function ToggleBunnyHop()
    toggles.bunnyHop = not toggles.bunnyHop
    if toggles.bunnyHop then
        if connections.bunnyHop then connections.bunnyHop:Disconnect() end
        connections.bunnyHop = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not toggles.bunnyHop or not player.Character then return end
                local hum = player.Character:FindFirstChild("Humanoid")
                local root = player.Character:FindFirstChild("HumanoidRootPart")
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
        ShowMessage("🏴‍☠️ BunnyHop ON")
    else
        if connections.bunnyHop then connections.bunnyHop:Disconnect() end
        ShowMessage("🏴‍☠️ BunnyHop OFF")
    end
end

function ToggleSpeedGlitch()
    toggles.speedGlitch = not toggles.speedGlitch
    if toggles.speedGlitch then
        if connections.speedGlitch then connections.speedGlitch:Disconnect() end
        connections.speedGlitch = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not toggles.speedGlitch or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") then return end
                local root = player.Character.HumanoidRootPart
                local hum = player.Character.Humanoid
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
        ShowMessage("🏴‍☠️ Speed Glitch ON")
    else
        if connections.speedGlitch then connections.speedGlitch:Disconnect() end
        ShowMessage("🏴‍☠️ Speed Glitch OFF")
    end
end

function ToggleWallHop()
    toggles.wallHop = not toggles.wallHop
    if toggles.wallHop then
        ShowMessage("🏴‍☠️ Wall Hop ON")
        if connections.wallHop then connections.wallHop:Disconnect() end
        connections.wallHop = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not toggles.wallHop then return end
                local char = player.Character
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
        if connections.wallHop then connections.wallHop:Disconnect() end
        ShowMessage("🏴‍☠️ Wall Hop OFF")
    end
end

function CreateWallHopButton()
    if wallHopButton then return end
    wallHopButton = Instance.new("TextButton", gui)
    wallHopButton.Size = UDim2.new(0, 50, 0, 30)
    wallHopButton.Position = UDim2.new(0.8, 0, 0.5, 0)
    wallHopButton.BackgroundColor3 = guiSettings.OffColor
    wallHopButton.Text = "WH"
    wallHopButton.TextColor3 = guiSettings.TextColor
    wallHopButton.Font = Enum.Font.GothamBold
    wallHopButton.TextSize = 12
    Instance.new("UICorner", wallHopButton).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", wallHopButton).Color = guiSettings.BorderColor
    wallHopButton.MouseButton1Click:Connect(function()
        ToggleWallHop()
        wallHopButton.BackgroundColor3 = toggles.wallHop and guiSettings.OnColor or guiSettings.OffColor
    end)
end

function ToggleWalkFling()
    toggles.walkFling = not toggles.walkFling
    if toggles.walkFling then
        ShowMessage("🏴‍☠️ Walk Fling ON")
        if connections.walkFling then connections.walkFling:Disconnect() end
        connections.walkFling = RunService.Heartbeat:Connect(function()
            pcall(function()
                if not toggles.walkFling or not player.Character then return end
                local myRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if not myRoot then return end
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character then
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
        if connections.walkFling then connections.walkFling:Disconnect() end
        ShowMessage("🏴‍☠️ Walk Fling OFF")
    end
end

function ToggleAutoFling()
    toggles.autoFling = not toggles.autoFling
    if toggles.autoFling then
        ShowMessage("🏴‍☠️ Auto Fling ON")
        if connections.autoFling then connections.autoFling:Disconnect() end
        connections.autoFling = RunService.Heartbeat:Connect(function()
            if not toggles.autoFling then return end
            local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not myHrp then return end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
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
        if connections.autoFling then connections.autoFling:Disconnect() end
        ShowMessage("🏴‍☠️ Auto Fling OFF")
    end
end

-- FLING
function FlingByName(name)
    if name == "" then ShowMessage("🏴‍☠️ Enter name!") return end
    local found = false
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and string.find(string.lower(p.Name), string.lower(name)) then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                local hum = p.Character:FindFirstChild("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot then myRoot.CFrame = hrp.CFrame * CFrame.new(0, 0, 2) task.wait(0.05) end
                    local dir = Vector3.new(math.random(-1, 1), 1.5, math.random(-1, 1)).Unit
                    hum.Sit = true
                    hrp.AssemblyLinearVelocity = dir * 5000
                    ShowMessage("🏴‍☠️ Fling: " .. p.Name)
                    found = true
                    break
                end
            end
        end
    end
    if not found then ShowMessage("🏴‍☠️ Player not found!") end
end

function FlingAll()
    local count = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
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
    ShowMessage("🏴‍☠️ Fling All: " .. count .. " players")
end

function FlingUp()
    if not player.Character then return end
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity = Vector3.new(0, 500, 0)
        ShowMessage("🏴‍☠️ Fling UP!")
    end
end

function FlingForward()
    if not player.Character then return end
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local look = root.CFrame.LookVector
        root.AssemblyLinearVelocity = Vector3.new(look.X * 300, 50, look.Z * 300)
        ShowMessage("🏴‍☠️ Fling Forward!")
    end
end

function FlingRandom()
    if not player.Character then return end
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local dir = Vector3.new(math.random(-1, 1), math.random(0, 2), math.random(-1, 1)).Unit
        root.AssemblyLinearVelocity = dir * 500
        ShowMessage("🏴‍☠️ Fling Random!")
    end
end

function SuperFling()
    if not player.Character then return end
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity = Vector3.new(0, 9999, 0)
        task.wait(0.1)
        root.AssemblyLinearVelocity = Vector3.new(math.random(-500, 500), 9999, math.random(-500, 500))
        ShowMessage("🏴‍☠️ SUPER FLING!")
    end
end

function FlingAllUp()
    local count = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local hum = p.Character:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 500, 0)
                count = count + 1
            end
        end
    end
    ShowMessage("🏴‍☠️ Fling All UP: " .. count .. " players")
end

function FlingAllRandom()
    local count = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
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
    ShowMessage("🏴‍☠️ Fling All Random: " .. count .. " players")
end

function FlingLastPlayer()
    local players = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then table.insert(players, p) end
    end
    if #players == 0 then ShowMessage("🏴‍☠️ No other players!") return end
    local target = players[#players]
    if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = target.Character.HumanoidRootPart
        local hum = target.Character:FindFirstChild("Humanoid")
        if hrp and hum and hum.Health > 0 then
            local dir = Vector3.new(math.random(-1, 1), 1.5, math.random(-1, 1)).Unit
            hum.Sit = true
            hrp.AssemblyLinearVelocity = dir * 5000
            ShowMessage("🏴‍☠️ Fling Last: " .. target.Name)
        end
    end
end

function OpenIYFling() ShowMessage("🏴‍☠️ IY Fling opened") end
function OpenIYGoto() ShowMessage("🏴‍☠️ IY Goto opened") end

-- MM2
function ToggleMM2EspV2()
    toggles.mm2EspV2 = not toggles.mm2EspV2
    if toggles.mm2EspV2 then
        ShowMessage("🏴‍☠️ MM2 ESP V2 ON")
        task.spawn(function()
            while toggles.mm2EspV2 do
                task.wait(0.3)
                pcall(function()
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
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
    else
        pcall(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("MM2_ESP_V2") then
                    p.Character.MM2_ESP_V2:Destroy()
                end
            end
        end)
        ShowMessage("🏴‍☠️ MM2 ESP V2 OFF")
    end
end

function ToggleMM2EspV3()
    toggles.mm2EspV3 = not toggles.mm2EspV3
    if toggles.mm2EspV3 then
        if not mm2EspV3Folder then mm2EspV3Folder = Instance.new("Folder", workspace) mm2EspV3Folder.Name = "MTY_MM2_ESP_V3" end
        ShowMessage("🏴‍☠️ MM2 ESP V3 ON")
        task.spawn(function()
            while toggles.mm2EspV3 do
                task.wait(0.15)
                pcall(function()
                    if mm2EspV3Folder then mm2EspV3Folder:ClearAllChildren() end
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
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
    else
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
        ShowMessage("🏴‍☠️ MM2 ESP V3 OFF")
    end
end

function ToggleMM2AimbotV2()
    toggles.mm2AimbotV2 = not toggles.mm2AimbotV2
    if toggles.mm2AimbotV2 then
        if not mm2FovCircle then
            if not fovGui then fovGui = Instance.new("ScreenGui", game.CoreGui) fovGui.Name = "MTY_FOV" end
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
        end
        mm2FovCircle.Visible = true
        ShowMessage("🏴‍☠️ MM2 Aimbot V2 ON")
        task.spawn(function()
            while toggles.mm2AimbotV2 do
                RunService.RenderStepped:Wait()
                pcall(function()
                    local murderer = nil
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= player and getMM2Role(p) == "Murderer" then
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
    else
        if mm2FovCircle then mm2FovCircle.Visible = false end
        ShowMessage("🏴‍☠️ MM2 Aimbot V2 OFF")
    end
end

function ToggleDoubleTap()
    toggles.doubleTap = not toggles.doubleTap
    if toggles.doubleTap then
        if connections.doubleTap then connections.doubleTap:Disconnect() end
        connections.doubleTap = UserInputService.TouchEnded:Connect(function(touch)
            if not toggles.doubleTap or not player.Character then return end
            local currentTime = tick()
            if currentTime - lastTapTime <= 0.3 then tapCount = tapCount + 1 else tapCount = 1 end
            lastTapTime = currentTime
            if tapCount >= 2 then
                tapCount = 0
                local closestPlayer = nil
                local closestDist = 15
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (player.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestPlayer = p
                        end
                    end
                end
                if closestPlayer and closestPlayer.Character then
                    local tool = player.Character:FindFirstChildOfClass("Tool")
                    if not tool then tool = player.Backpack:FindFirstChildOfClass("Tool") end
                    if tool and (tool.Name == "Knife" or string.find(string.lower(tool.Name), "knife")) then
                        tool:Activate()
                        local remote = GetDmgRemote(tool)
                        if remote then remote:FireServer(closestPlayer.Character.HumanoidRootPart) end
                        ShowMessage("🏴‍☠️ Double Tap: " .. closestPlayer.Name)
                    end
                end
            end
        end)
        ShowMessage("🏴‍☠️ Double Tap ON")
    else
        if connections.doubleTap then connections.doubleTap:Disconnect() end
        ShowMessage("🏴‍☠️ Double Tap OFF")
    end
end

function ToggleAutoStab()
    toggles.autoStab = not toggles.autoStab
    if toggles.autoStab then
        ShowMessage("🏴‍☠️ Auto Stab ON")
        task.spawn(function()
            while toggles.autoStab do
                task.wait(0.1)
                pcall(function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local tool = player.Character:FindFirstChildOfClass("Tool")
                        if tool and (tool.Name == "Knife" or tool.Name:find("Knife")) then
                            for _, p in pairs(Players:GetPlayers()) do
                                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                                    local dist = (player.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                                    if dist <= 10 then
                                        tool:Activate()
                                        local remote = GetDmgRemote(tool)
                                        if remote then remote:FireServer(p.Character.HumanoidRootPart) end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)
    else
        ShowMessage("🏴‍☠️ Auto Stab OFF")
    end
end

function ToggleCoinFarm()
    toggles.coinFarm = not toggles.coinFarm
    if toggles.coinFarm then
        ShowMessage("🏴‍☠️ Coin Farm ON")
        task.spawn(function()
            while toggles.coinFarm do
                task.wait(0.3)
                pcall(function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("Part") and (v.Name == "Coin" or v.Name == "Candy" or v.Name == "Snowflake") then
                                if not toggles.coinFarm then break end
                                player.Character.HumanoidRootPart.CFrame = v.CFrame
                                task.wait(0.1)
                            end
                        end
                    end
                end)
            end
        end)
    else
        ShowMessage("🏴‍☠️ Coin Farm OFF")
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
        if gun and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = gun.CFrame + Vector3.new(0, 3, 0)
            ShowMessage("🏴‍☠️ Teleported to Gun!")
        else
            ShowMessage("🏴‍☠️ Gun not dropped!")
        end
    end)
end

-- ============================================================================
-- 🏴‍☠️ ANTI-FLING (ФУНКЦИЯ ДЛЯ МЕНЮ)
-- ============================================================================

local function disableCollide(part)
    if toggles.antiFling and part:IsA("BasePart") then
        part.CanCollide = false
    end
end

local function setupCharacter(char)
    if not char then return end
    
    for _, part in ipairs(char:GetChildren()) do
        disableCollide(part)
    end
    
    local childConn = char.ChildAdded:Connect(disableCollide)
    
    local steppedConn = RunService.Stepped:Connect(function()
        if toggles.antiFling and char:IsDescendantOf(workspace) then
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
    
    char.Destroying:Connect(function()
        childConn:Disconnect()
        steppedConn:Disconnect()
    end)
end

local function trackPlayer(plr)
    if plr == player then return end
    local conn = plr.CharacterAdded:Connect(setupCharacter)
    if plr.Character then
        setupCharacter(plr.Character)
    end
    antiFlingConnections[plr] = conn
end

local function untrackPlayer(plr)
    if antiFlingConnections[plr] then
        antiFlingConnections[plr]:Disconnect()
        antiFlingConnections[plr] = nil
    end
end

function ToggleAntiFling()
    toggles.antiFling = not toggles.antiFling
    
    if toggles.antiFling then
        ShowMessage("🛡️ Anti-Fling ON")
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player then
                trackPlayer(plr)
            end
        end
    else
        ShowMessage("🛡️ Anti-Fling OFF")
        for plr, conn in pairs(antiFlingConnections) do
            conn:Disconnect()
        end
        antiFlingConnections = {}
    end
end

Players.PlayerAdded:Connect(trackPlayer)
Players.PlayerRemoving:Connect(untrackPlayer)

-- АВТОЗАПУСК БЕЗ СООБЩЕНИЯ
task.spawn(function()
    wait(1)
    toggles.antiFling = true
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            trackPlayer(plr)
        end
    end
end)

-- ============================================================================
-- 🏴‍☠️ CUSTOM CURSOR
-- ============================================================================

function ToggleCustomCursor()
    toggles.customCursor = not toggles.customCursor
    
    if toggles.customCursor then
        ShowMessage("🌟 Custom Cursor ON")
        
        cursorGui = Instance.new("ScreenGui")
        cursorGui.Name = "MTY_CustomCursor"
        cursorGui.IgnoreGuiInset = true
        cursorGui.DisplayOrder = 10000000
        cursorGui.ResetOnSpawn = false
        cursorGui.Parent = player:WaitForChild("PlayerGui")
        
        cursorImage = Instance.new("ImageLabel", cursorGui)
        cursorImage.BackgroundTransparency = 1
        cursorImage.Size = UDim2.new(0, guiSettings.CustomCursorSize, 0, guiSettings.CustomCursorSize)
        cursorImage.AnchorPoint = Vector2.new(0.5, 0.5)
        cursorImage.Image = guiSettings.CustomCursorImage
        cursorImage.ZIndex = 100
        
        cursorConnection = RunService.RenderStepped:Connect(function()
            if not toggles.customCursor then return end
            local pos = UserInputService:GetMouseLocation()
            cursorImage.Position = UDim2.new(0, pos.X, 0, pos.Y)
            
            if UserInputService.MouseIconEnabled then
                UserInputService.MouseIconEnabled = false
            end
        end)
    else
        ShowMessage("🌟 Custom Cursor OFF")
        
        if cursorConnection then
            cursorConnection:Disconnect()
            cursorConnection = nil
        end
        if cursorGui then
            cursorGui:Destroy()
            cursorGui = nil
        end
        cursorImage = nil
        
        UserInputService.MouseIconEnabled = true
    end
end

game:BindToClose(function()
    if cursorConnection then
        cursorConnection:Disconnect()
    end
    UserInputService.MouseIconEnabled = true
end)

-- ============================================================================
-- 📋 OBSIDIAN ФУНКЦИИ (ВКЛАДКА GG)
-- ============================================================================

function ToggleObsidianSpeed()
    toggles.obsidianSpeed = not toggles.obsidianSpeed
    if toggles.obsidianSpeed then
        ShowMessage("🏴‍☠️ Obsidian Speed ON")
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
        ShowMessage("🏴‍☠️ Obsidian Speed OFF")
    end
end

function ToggleObsidianJump()
    toggles.obsidianJump = not toggles.obsidianJump
    if toggles.obsidianJump then
        ShowMessage("🏴‍☠️ Obsidian Jump ON")
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
        ShowMessage("🏴‍☠️ Obsidian Jump OFF")
    end
end

function ToggleObsidianFly()
    toggles.obsidianFly = not toggles.obsidianFly
    if toggles.obsidianFly then
        ShowMessage("🏴‍☠️ Obsidian Fly ON")
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
        ShowMessage("🏴‍☠️ Obsidian Fly OFF")
    end
end

function ToggleObsidianFlyAnim()
    toggles.obsidianFlyAnim = not toggles.obsidianFlyAnim
    if not toggles.obsidianFlyAnim and obsidianData.flyAnimTrack then
        obsidianData.flyAnimTrack:Stop()
        obsidianData.flyAnimTrack = nil
    end
    ShowMessage(toggles.obsidianFlyAnim and "🏴‍☠️ Fly Animation ON" or "🏴‍☠️ Fly Animation OFF")
end

function ToggleObsidianNoclip()
    toggles.obsidianNoclip = not toggles.obsidianNoclip
    if toggles.obsidianNoclip then
        ShowMessage("🏴‍☠️ Obsidian Noclip ON")
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
        ShowMessage("🏴‍☠️ Obsidian Noclip OFF")
    end
end

function ToggleObsidianEsp()
    toggles.obsidianEspMaster = not toggles.obsidianEspMaster
    if toggles.obsidianEspMaster then
        ShowMessage("🏴‍☠️ Obsidian ESP ON")
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
        ShowMessage("🏴‍☠️ Obsidian ESP OFF")
    end
end

function ToggleObsidianTracers()
    toggles.obsidianTracers = not toggles.obsidianTracers
    ShowMessage(toggles.obsidianTracers and "🏴‍☠️ Tracers ON" or "🏴‍☠️ Tracers OFF")
end

function ToggleObsidianHealthBar()
    toggles.obsidianHealthBar = not toggles.obsidianHealthBar
    ShowMessage(toggles.obsidianHealthBar and "🏴‍☠️ Health Bar ON" or "🏴‍☠️ Health Bar OFF")
end

function ToggleObsidianBoxEsp()
    toggles.obsidianBoxEsp = not toggles.obsidianBoxEsp
    ShowMessage(toggles.obsidianBoxEsp and "🏴‍☠️ Box ESP ON" or "🏴‍☠️ Box ESP OFF")
end

function ToggleObsidianSkeleton()
    toggles.obsidianSkeleton = not toggles.obsidianSkeleton
    ShowMessage(toggles.obsidianSkeleton and "🏴‍☠️ Skeleton ON" or "🏴‍☠️ Skeleton OFF")
end

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
        ShowMessage("🏴‍☠️ Waypoint ESP ON")
    else
        for _, groupData in pairs(obsidianData.waypointGroups) do
            for _, wp in ipairs(groupData.waypoints) do
                if wp.marker then
                    local h = wp.marker:FindFirstChild("WpHighlight")
                    if h then h:Destroy() end
                end
            end
        end
        ShowMessage("🏴‍☠️ Waypoint ESP OFF")
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
    ShowMessage("🏴‍☠️ Waypoint added to " .. selGroup)
end

function DeleteObsidianWaypoint()
    local selGroup = obsidianData.selectedGroup or "Default"
    local group = obsidianData.waypointGroups[selGroup]
    if not group or #group.waypoints == 0 then return end
    local last = group.waypoints[#group.waypoints]
    if last.marker then last.marker:Destroy() end
    table.remove(group.waypoints)
    if obsidianData.waypointIndex > #group.waypoints then obsidianData.waypointIndex = 1 end
    ShowMessage("🏴‍☠️ Last waypoint deleted")
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
    ShowMessage(toggles.obsidianAutoTp and "🏴‍☠️ Auto TP ON" or "🏴‍☠️ Auto TP OFF")
end

function ToggleObsidianUsePathfinding()
    toggles.obsidianUsePathfinding = not toggles.obsidianUsePathfinding
    if not toggles.obsidianUsePathfinding then stopPathfinding() end
    ShowMessage(toggles.obsidianUsePathfinding and "🏴‍☠️ Pathfinding ON" or "🏴‍☠️ Pathfinding OFF")
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
    ShowMessage(toggles.obsidianLoopPlayerTp and "🏴‍☠️ Loop Player TP ON" or "🏴‍☠️ Loop Player TP OFF")
end

function ToggleObsidianAutoTpNext()
    toggles.obsidianAutoTpNext = not toggles.obsidianAutoTpNext
    ShowMessage(toggles.obsidianAutoTpNext and "🏴‍☠️ Auto Next ON" or "🏴‍☠️ Auto Next OFF")
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
        ShowMessage("🏴‍☠️ Auto Clicker ON")
    else
        obsidianData.lockedMousePos = nil
        ShowMessage("🏴‍☠️ Auto Clicker OFF")
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
    ShowMessage(toggles.obsidianFbMaster and "🏴‍☠️ Fullbright ON" or "🏴‍☠️ Fullbright OFF")
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
    ShowMessage(toggles.obsidianAutoFb and "🏴‍☠️ Auto Fullbright ON" or "🏴‍☠️ Auto Fullbright OFF")
end

function ToggleObsidianNoShadows()
    toggles.obsidianNoShadows = not toggles.obsidianNoShadows
    ShowMessage(toggles.obsidianNoShadows and "🏴‍☠️ No Shadows ON" or "🏴‍☠️ No Shadows OFF")
end

function ToggleObsidianNoFog()
    toggles.obsidianNoFog = not toggles.obsidianNoFog
    ShowMessage(toggles.obsidianNoFog and "🏴‍☠️ No Fog ON" or "🏴‍☠️ No Fog OFF")
end

function ToggleObsidianWalkfling()
    toggles.obsidianWalkfling = not toggles.obsidianWalkfling
    if toggles.obsidianWalkfling then
        ShowMessage("🏴‍☠️ Walkfling ON")
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
        ShowMessage("🏴‍☠️ Walkfling OFF")
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
        ShowMessage("🏴‍☠️ No Void ON")
    else
        if obsidianData.voidPart then
            obsidianData.voidPart:Destroy()
            obsidianData.voidPart = nil
        end
        ShowMessage("🏴‍☠️ No Void OFF")
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
        ShowMessage("🏴‍☠️ God Mode ON")
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
        ShowMessage("🏴‍☠️ God Mode OFF")
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
    ShowMessage(toggles.obsidianNoPromptCooldown and "🏴‍☠️ No Prompt Cooldown ON" or "🏴‍☠️ No Prompt Cooldown OFF")
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
-- 🏴‍☠️ ПОСТРОЕНИЕ GUI
-- ============================================================================

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 233, 0, 167)
mainFrame.Position = UDim2.new(0.5, -117, 0.5, -84)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = guiSettings.BorderColor
mainFrame.Parent = gui
roundCorner(mainFrame, 8)

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
title.Text = "🏴‍☠️ MTY GUI"
title.TextColor3 = Color3.fromRGB(200, 200, 200)
title.TextSize = 8
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = titleFrame

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
        local key = text:gsub("%s+", ""):lower()
        if toggles[key] ~= nil then
            btn.BackgroundColor3 = toggles[key] and guiSettings.OnColor or guiSettings.OffColor
            btn.Text = text .. (toggles[key] and " ON" or " OFF")
        end
    end)
    return btn
end

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

local categories = {
    -- VIS
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
        {text = "Custom Cursor", func = ToggleCustomCursor, isToggle = true},
    },
    -- CMB
    {
        {text = "Aimbot", func = ToggleAimbot, isToggle = true},
        {text = "Aimbot Mode", func = CycleAimbotMode, isToggle = false},
        {text = "Aimbot FOV", func = function() OpenTextInput("Aimbot FOV", "10-360", guiSettings.AimbotFOV, function(v) guiSettings.AimbotFOV = v end) end, isToggle = false},
        {text = "Aimbot Speed", func = function() OpenTextInput("Aimbot Speed", "0.1-1", guiSettings.AimbotSpeed, function(v) guiSettings.AimbotSpeed = v end) end, isToggle = false},
        {text = "Aimbot Part", func = function()
            local parts = {"Head", "HumanoidRootPart", "Torso", "UpperTorso"}
            local current = guiSettings.AimbotPart or "Head"
            local idx = 1
            for i, v in ipairs(parts) do if v == current then idx = i break end end
            local nextIdx = idx % #parts + 1
            guiSettings.AimbotPart = parts[nextIdx]
            ShowMessage("🏴‍☠️ Aimbot Part: " .. parts[nextIdx])
        end, isToggle = false},
        {text = "Anti-Aim V2", func = ToggleAntiAim, isToggle = true},
        {text = "Anti-Aim Mode", func = CycleAntiAimMode, isToggle = false},
        {text = "Kill Aura", func = ToggleKillAura, isToggle = true},
        {text = "Kill Aura V2", func = ToggleKillAuraV2, isToggle = true},
        {text = "Orbit Kill Aura", func = ToggleOrbitKillAura, isToggle = true},
        {text = "Trigger Bot", func = ToggleTriggerBot, isToggle = true},
        {text = "Desync", func = ToggleDesync, isToggle = true},
        {text = "Fake Lag", func = ToggleFakeLag, isToggle = true},
        {text = "Anti-Knockback", func = ToggleAntiKb, isToggle = true},
    },
    -- MOV
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
    -- MM2
    {
        {text = "MM2 ESP V2", func = ToggleMM2EspV2, isToggle = true},
        {text = "MM2 ESP V3", func = ToggleMM2EspV3, isToggle = true},
        {text = "MM2 Aimbot V2", func = ToggleMM2AimbotV2, isToggle = true},
        {text = "Double Tap", func = ToggleDoubleTap, isToggle = true},
        {text = "Auto Stab", func = ToggleAutoStab, isToggle = true},
        {text = "Coin Farm", func = ToggleCoinFarm, isToggle = true},
        {text = "Teleport Gun", func = TeleportToGun, isToggle = false},
    },
    -- GG
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
        {text = "Anti-Fling", func = ToggleAntiFling, isToggle = true},
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
            ShowMessage("🏴‍☠️ Tracer Origin: " .. modes[nextIdx])
        end, isToggle = false},
    }
}

for i, cat in ipairs(categories) do
    addButtons(scrolls[i], cat, 5, 5)
end

for i, tab in ipairs(tabs) do
    tab.MouseButton1Click:Connect(function()
        for j = 1, 5 do
            scrolls[j].Visible = (j == i)
        end
    end)
end

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

local cubeButton = Instance.new("TextButton")
cubeButton.Size = UDim2.new(0, 50, 0, 50)
cubeButton.Position = UDim2.new(0.5, -25, 0.5, -25)
cubeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
cubeButton.BorderSizePixel = 2
cubeButton.BorderColor3 = guiSettings.BorderColor
cubeButton.Text = "🏴‍☠️"
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
    hideButton.Text = uiVisible and "СКРЫТЬ" or "🏴‍☠️"
end

hideButton.MouseButton1Click:Connect(toggleUI)

local nums = {"14.0", "100", "14.0", "5", "🏴"}
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

print("🏴‍☠️ MTY GUI - ПОЛНАЯ ВЕРСИЯ ЗАГРУЖЕНА!")
print("🏴‍☠️ 5 вкладок: VIS | CMB | MOV | MM2 | GG")
print("🏴‍☠️ Вкладка GG содержит ВСЕ функции из Obsidian!")
print("🏴‍☠️ Добавлены: Anti-Fling 🛡️ и Custom Cursor 🌟")
print("🏴‍☠️ Все ТВОИ функции работают без изменений!")
print("🏴‍☠️ Кубик с пиратом 🏴‍☠️ можно двигать!")