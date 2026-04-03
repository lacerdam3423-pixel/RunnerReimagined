local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SprintSystem"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local sprintBtn = Instance.new("TextButton")
sprintBtn.Name = "SprintButton"
sprintBtn.Size = UDim2.new(0, 50, 0, 50)
sprintBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
sprintBtn.BackgroundTransparency = 0.3
sprintBtn.Text = "RUN"
sprintBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sprintBtn.Font = Enum.Font.GothamBold
sprintBtn.TextSize = 14

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = sprintBtn

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = sprintBtn

local pinIcon = Instance.new("TextLabel")
pinIcon.Name = "Pin"
pinIcon.Size = UDim2.new(0, 15, 0, 15)
pinIcon.Position = UDim2.new(0.7, 0, 0, -5)
pinIcon.BackgroundTransparency = 1
pinIcon.Text = "📌"
pinIcon.TextSize = 12
pinIcon.Visible = false
pinIcon.Parent = sprintBtn

sprintBtn.Parent = screenGui

local function loadPosition()
	local success, result = pcall(function()
		if readfile and writefile then
			if isfile("sprint_pos.json") then
				return HttpService:JSONDecode(readfile("sprint_pos.json"))
			end
		end
		return nil
	end)
	
	if success and result then
		sprintBtn.Position = UDim2.new(result.X.Scale, result.X.Offset, result.Y.Scale, result.Y.Offset)
	else
		sprintBtn.Position = UDim2.new(0.65, 0, 0.75, 0)
	end
end

local function savePosition()
	local pos = sprintBtn.Position
	local data = {
		X = {Scale = pos.X.Scale, Offset = pos.X.Offset},
		Y = {Scale = pos.Y.Scale, Offset = pos.Y.Offset}
	}
	pcall(function()
		if writefile then
			writefile("sprint_pos.json", HttpService:JSONEncode(data))
		end
	end)
	
	pinIcon.Visible = true
	task.delay(1, function()
		pinIcon.Visible = false
	end)
end

loadPosition()

local dragging = false
local dragInput, dragStart, startPos

sprintBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = sprintBtn.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

sprintBtn.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		sprintBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local clickCount = 0
local lastClick = 0

sprintBtn.Activated:Connect(function()
	local now = tick()
	if now - lastClick < 0.5 then
		clickCount = clickCount + 1
	else
		clickCount = 1
	end
	lastClick = now
	
	if clickCount >= 3 then
		savePosition()
		clickCount = 0
	end
end)

local isSprinting = false
local originalSpeed = humanoid.WalkSpeed
local originalFOV = camera.FieldOfView

local function updateOriginals()
	if not isSprinting then
		originalSpeed = humanoid.WalkSpeed
		originalFOV = camera.FieldOfView
	end
end

humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(updateOriginals)

local function toggleSprint(state)
	isSprinting = state
	local targetSpeed = state and (originalSpeed * 1.6) or originalSpeed
	local targetFOV = state and (originalFOV + 15) or originalFOV
	
	TweenService:Create(humanoid, TweenInfo.new(0.3), {WalkSpeed = targetSpeed}):Play()
	TweenService:Create(camera, TweenInfo.new(0.3), {FieldOfView = targetFOV}):Play()
	
	TweenService:Create(sprintBtn, TweenInfo.new(0.2), {
		BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(20, 20, 20),
		TextColor3 = state and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(255, 255, 255)
	}):Play()
end

sprintBtn.MouseButton1Down:Connect(function()
	toggleSprint(true)
end)

sprintBtn.MouseButton1Up:Connect(function()
	toggleSprint(false)
end)

player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	updateOriginals()
	humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(updateOriginals)
end)
