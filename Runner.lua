local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera

-----------------------------------------------------------
-- PRO DEV EDITABLE SETTINGS
-----------------------------------------------------------
local SPRINT_SPEED = 28 -- Speed when sprinting
local NORMAL_SPEED = 16 -- Normal speed
local SPRINT_FOV = 90 -- FOV when sprinting
local NORMAL_FOV = 70 -- Normal FOV
local TWEEN_TIME = 0.3 -- Time in seconds for smooth transitions
local SPRINT_KEY = Enum.KeyCode.LeftShift -- Key to hold for sprint (optional, button is main focus)
-----------------------------------------------------------

local isSprinting = false

local function setSprintState(active)
	isSprinting = active
	
	local targetSpeed = active and SPRINT_SPEED or NORMAL_SPEED
	local targetFOV = active and SPRINT_FOV or NORMAL_FOV
	
	humanoid.WalkSpeed = targetSpeed
	
	-- Tweak FOV smoothly
	TweenService:Create(camera, TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Sine), {FieldOfView = targetFOV}):Play()
end

-- Function to handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = newCharacter:WaitForChild("Humanoid")
end)

-- GUI creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeadRailsSprintGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainButton = Instance.new("ImageButton")
mainButton.Name = "SprintButton"
mainButton.Size = UDim2.new(0, 45, 0, 45)

-- FIXED POSITION: Just above and to the left of the jump button (based on your image)
-- Position: 90% across, 85% down
mainButton.Position = UDim2.new(1, -90, 1, -110) 

mainButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainButton.BackgroundTransparency = 0.4
mainButton.Image = "rbxassetid://12809185125" -- A run icon (feel free to change)
mainButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
mainButton.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0) -- Circle
corner.Parent = mainButton

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = mainButton

-- Event connections
mainButton.MouseButton1Click:Connect(function()
	setSprintState(not isSprinting)
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == SPRINT_KEY then
		setSprintState(true)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == SPRINT_KEY then
		setSprintState(false)
	end
end)
