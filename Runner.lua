local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local normalSpeed
local normalFOV

local isSprinting = false

local SPEED_MULTIPLIER = 1.6
local FOV_MULTIPLIER = 1.15

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeadRailsSprintGui"
screenGui.Parent = CoreGui

local mainButton = Instance.new("ImageButton")
mainButton.Name = "SprintButton"
mainButton.Size = UDim2.new(0, 45, 0, 45)
mainButton.Position = UDim2.new(0.5, -22.5, 1, -80)
mainButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainButton.BackgroundTransparency = 0.4
mainButton.Image = "rbxassetid://12809185125"
mainButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
mainButton.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = mainButton

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 0, 0)
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Transparency = 0.2
stroke.Parent = mainButton

local function getSpeedAndFov()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    normalSpeed = humanoid.WalkSpeed
    normalFOV = camera.FieldOfView
end

player.CharacterAdded:Connect(getSpeedAndFov)
getSpeedAndFov()

local function applySprint(active)
    isSprinting = active

    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    local targetSpeed = active and (normalSpeed * SPEED_MULTIPLIER) or normalSpeed
    local targetFOV = active and (normalFOV * FOV_MULTIPLIER) or normalFOV
    local targetStrokeColor = active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

    humanoid.WalkSpeed = targetSpeed

    TweenService:Create(camera, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {FieldOfView = targetFOV}):Play()
    TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Color = targetStrokeColor}):Play()
    TweenService:Create(mainButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {BackgroundTransparency = active and 0.2 or 0.4}):Play()
end

mainButton.MouseButton1Down:Connect(function()
    applySprint(not isSprinting)
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        applySprint(true)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        applySprint(false)
    end
end)
