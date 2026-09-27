--[[
	TAS RECORDER v17 — PATH EDITOR + SMART TRAJECTORY
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

-- ===================== PATH EDITOR =====================
local PATH_ENABLED = false
local PATH_WALKING = false
local pathWaypoints = {}
local pathParts = {}
local pathPointParts = {}
local pathWalkThread = nil
local PATH_COLOR = Color3.fromRGB(0, 255, 150)
local PATH_POINT_COLOR = Color3.fromRGB(255, 220, 0)
local PATH_THICKNESS = 0.25
local PATH_POINT_SIZE = 0.8
local WALK_SPEED = 18
local WALK_REACH = 2.5
local PATH_JUMP_CHECK_DIST = 3
local PATH_FILE = "path_data.json"

-- Freecam
local freecamActive = false
local freecamConn = nil
local freecamMouseConn = nil
local freecamPos = Vector3.new(0, 0, 0)
local freecamRot = CFrame.new()
local freecamSpeed = 1.0
local freecamOldCamType = nil

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
TitleLabel.Text = "TAS Recorder v17"
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

makeLabel(LeftScroll, "PATH EDITOR", C_TEXT, 16, 12)
local PathBtn = makeBtn(LeftScroll, "OPEN EDITOR", 24, C_ELEM)
local PathSaveBtn = makeBtn(LeftScroll, "SAVE PATH", 22, C_ELEM)
local PathLoadBtn = makeBtn(LeftScroll, "LOAD PATH", 22, C_ELEM)
local PathClearBtn = makeBtn(LeftScroll, "CLEAR PATH", 22, C_ELEM)
local PathWalkBtn = makeBtn(LeftScroll, "WALK PATH", 22, C_ELEM)
makeLabel(LeftScroll, "E=point | RMB=look", C_TEXT_D, 14, 9)

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

-- ===================== PATH EDITOR FUNCTIONS =====================

local function clearPathVisual()
	for _, p in ipairs(pathParts) do if p and p.Parent then p:Destroy() end end
	for _, p in ipairs(pathPointParts) do if p and p.Parent then p:Destroy() end end
	pathParts = {}
	pathPointParts = {}
end

local function drawPathPoint(pos)
	local p = Instance.new("Part")
	p.Shape = Enum.PartType.Ball
	p.Size = Vector3.new(PATH_POINT_SIZE, PATH_POINT_SIZE, PATH_POINT_SIZE)
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Material = Enum.Material.Neon
	p.Color = PATH_POINT_COLOR
	p.Position = pos
	p.Parent = workspace
	table.insert(pathPointParts, p)
end

local function drawPathSegment(from, to)
	local delta = to - from
	local len = delta.Magnitude
	if len < 0.01 then return end
	local part = Instance.new("Part")
	part.Size = Vector3.new(PATH_THICKNESS, PATH_THICKNESS, len)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Material = Enum.Material.Neon
	part.Color = PATH_COLOR
	part.Transparency = 0.2
	part.CFrame = CFrame.new(from + delta * 0.5, to)
	part.Parent = workspace
	table.insert(pathParts, part)
end

local function redrawPath()
	clearPathVisual()
	if #pathWaypoints == 0 then return end
	for _, wp in ipairs(pathWaypoints) do
		drawPathPoint(wp)
	end
	for i = 1, #pathWaypoints - 1 do
		drawPathSegment(pathWaypoints[i], pathWaypoints[i + 1])
	end
end

local function startFreecam()
	if freecamActive then return end
	local cam = workspace.CurrentCamera
	if not cam then return end
	freecamActive = true
	freecamPos = cam.CFrame.Position
	freecamRot = cam.CFrame
	freecamOldCamType = cam.CameraType
	cam.CameraType = Enum.CameraType.Scriptable

	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hum then
		hum.WalkSpeed = 0
		hum.JumpPower = 0
	end
	if hrp then hrp.Anchored = true end

	freecamConn = RunService.RenderStepped:Connect(function(dt)
		if not freecamActive then return end
		local c = workspace.CurrentCamera
		if not c then return end

		local speed = freecamSpeed * 50 * dt
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then speed = speed * 3 end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then speed = speed * 0.3 end

		local move = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + freecamRot.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - freecamRot.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - freecamRot.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + freecamRot.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then move = move - Vector3.new(0, 1, 0) end

		if move.Magnitude > 0 then
			freecamPos = freecamPos + move.Unit * speed
		end

		c.CFrame = CFrame.new(freecamPos) * (freecamRot - freecamRot.Position)
	end)

	freecamMouseConn = UserInputService.InputChanged:Connect(function(input)
		if not freecamActive then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			local dx = input.Delta.X
			local dy = input.Delta.Y
			freecamRot = freecamRot * CFrame.Angles(math.rad(-dy * 0.3), math.rad(-dx * 0.3), 0)
		end
	end)
end

local function stopFreecam()
	if not freecamActive then return end
	freecamActive = false
	if freecamConn then freecamConn:Disconnect() freecamConn = nil end
	if freecamMouseConn then freecamMouseConn:Disconnect() freecamMouseConn = nil end
	local cam = workspace.CurrentCamera
	if cam and freecamOldCamType then cam.CameraType = freecamOldCamType end

	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hum then
		hum.WalkSpeed = DEFAULT_WALKSPEED
		hum.JumpPower = DEFAULT_JUMPPOWER
	end
	if hrp then hrp.Anchored = false end
end

local function addPathPoint()
	local pos
	if freecamActive then
		local mouse = LocalPlayer:GetMouse()
		if mouse and mouse.Hit then
			pos = mouse.Hit.Position
		else
			local cam = workspace.CurrentCamera
			pos = cam.CFrame.Position + cam.CFrame.LookVector * 20
		end
	else
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then pos = hrp.Position end
	end
	if not pos then return end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ignore = {}
	if LocalPlayer.Character then table.insert(ignore, LocalPlayer.Character) end
	for _, p in ipairs(pathPointParts) do table.insert(ignore, p) end
	for _, p in ipairs(pathParts) do table.insert(ignore, p) end
	params.FilterDescendantsInstances = ignore

	local down = workspace:Raycast(pos + Vector3.new(0, 10, 0), Vector3.new(0, -40, 0), params)
	if down then
		pos = down.Position + Vector3.new(0, 2, 0)
	end
	table.insert(pathWaypoints, pos)
	redrawPath()
end

local function stopPathWalk()
	PATH_WALKING = false
	if pathWalkThread then
		pcall(task.cancel, pathWalkThread)
		pathWalkThread = nil
	end
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hum and hrp then hum:MoveTo(hrp.Position) end
end

local function walkPath()
	if PATH_WALKING then stopPathWalk() return end
	if #pathWaypoints < 1 then return end
	PATH_WALKING = true

	pathWalkThread = task.spawn(function()
		local char = LocalPlayer.Character
		if not char then PATH_WALKING = false return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hum or not hrp then PATH_WALKING = false return end

		local oldSpeed = hum.WalkSpeed
		hum.WalkSpeed = WALK_SPEED

		for i, point in ipairs(pathWaypoints) do
			if not PATH_WALKING then break end
			hum:MoveTo(point)

			local timeout = tick() + 10
			local stuckTime = tick()
			local lastPos = hrp.Position

			while PATH_WALKING do
				task.wait(0.05)
				local root = char:FindFirstChild("HumanoidRootPart")
				if not root then break end
				local horizDist = (Vector3.new(root.Position.X, 0, root.Position.Z) - Vector3.new(point.X, 0, point.Z)).Magnitude
				if horizDist < WALK_REACH then break end
				if tick() > timeout then break end

				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Exclude
				params.FilterDescendantsInstances = {char}
				local fwd = hum.MoveDirection
				if fwd.Magnitude > 0.1 then
					local r = workspace:Raycast(root.Position, fwd.Unit * PATH_JUMP_CHECK_DIST, params)
					if r then hum.Jump = true end
				end

				local moved = (root.Position - lastPos).Magnitude
				if moved < 0.05 then
					if tick() - stuckTime > 0.5 then
						hum.Jump = true
						stuckTime = tick()
					end
				else
					lastPos = root.Position
					stuckTime = tick()
				end
			end
		end

		if char then
			local h = char:FindFirstChildOfClass("Humanoid")
			if h then
				local r = char:FindFirstChild("HumanoidRootPart")
				if r then h:MoveTo(r.Position) end
				h.WalkSpeed = oldSpeed
			end
		end
		PATH_WALKING = false
	end)
end

local function savePathFile()
	if typeof(writefile) ~= "function" then
		warn("[Path] Нет file API")
		return
	end
	local data = { waypoints = {} }
	for _, wp in ipairs(pathWaypoints) do
		table.insert(data.waypoints, {wp.X, wp.Y, wp.Z})
	end
	local ok = pcall(writefile, PATH_FILE, HttpService:JSONEncode(data))
	if ok then print("[Path] Сохранено в " .. PATH_FILE) end
end

local function loadPathFile()
	if typeof(readfile) ~= "function" then
		warn("[Path] Нет file API")
		return
	end
	if typeof(isfile) == "function" and not isfile(PATH_FILE) then
		warn("[Path] Файл не найден")
		return
	end
	local ok, raw = pcall(readfile, PATH_FILE)
	if not ok or not raw then return end
	local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
	if not ok2 or not data then return end
	pathWaypoints = {}
	for _, item in ipairs(data.waypoints or {}) do
		table.insert(pathWaypoints, Vector3.new(item[1], item[2], item[3]))
	end
	redrawPath()
	print("[Path] Загружено " .. #pathWaypoints .. " точек")
end

-- ===================== PATH EDITOR BUTTONS =====================

PathBtn.MouseButton1Click:Connect(function()
	PATH_ENABLED = not PATH_ENABLED
	if PATH_ENABLED then
		PathBtn.Text = "CLOSE EDITOR"
		PathBtn.BackgroundColor3 = C_ELEM_H
		startFreecam()
		redrawPath()
	else
		PathBtn.Text = "OPEN EDITOR"
		PathBtn.BackgroundColor3 = C_ELEM
		stopFreecam()
	end
end)

PathSaveBtn.MouseButton1Click:Connect(function()
	savePathFile()
	PathSaveBtn.Text = "SAVED!"
	task.delay(1.2, function() PathSaveBtn.Text = "SAVE PATH" end)
end)

PathLoadBtn.MouseButton1Click:Connect(function()
	loadPathFile()
	PathLoadBtn.Text = "LOADED!"
	task.delay(1.2, function() PathLoadBtn.Text = "LOAD PATH" end)
end)

PathClearBtn.MouseButton1Click:Connect(function()
	pathWaypoints = {}
	clearPathVisual()
end)

PathWalkBtn.MouseButton1Click:Connect(function()
	if not PATH_WALKING then
		if freecamActive then
			stopFreecam()
			PATH_ENABLED = false
			PathBtn.Text = "OPEN EDITOR"
			PathBtn.BackgroundColor3 = C_ELEM
		end
	end
	walkPath()
	if PATH_WALKING then
		PathWalkBtn.Text = "STOP WALK"
		PathWalkBtn.BackgroundColor3 = C_ELEM_H
	else
		PathWalkBtn.Text = "WALK PATH"
		PathWalkBtn.BackgroundColor3 = C_ELEM
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.E and PATH_ENABLED then
		addPathPoint()
	end
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
print("[TAS Recorder v17] loaded — с Path Editor.")