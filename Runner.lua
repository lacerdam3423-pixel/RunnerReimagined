local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera

local isSprinting = false
local normalSpeed = humanoid.WalkSpeed
local sprintSpeed = normalSpeed * 1.6
local normalFOV = camera.FieldOfView
local sprintFOV = normalFOV + 15

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    normalSpeed = humanoid.WalkSpeed
    sprintSpeed = normalSpeed * 1.6
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SprintGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local sprintButton = Instance.new("TextButton")
sprintButton.Name = "SprintButton"
sprintButton.Size = UDim2.new(0, 50, 0, 50)
sprintButton.Position = UDim2.new(1, -120, 1, -110)
sprintButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
sprintButton.BackgroundTransparency = 0.4
sprintButton.Text = "Sprint"
sprintButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sprintButton.Font = Enum.Font.GothamBold
sprintButton.TextSize = 12
sprintButton.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim2.new(0, 8)
uiCorner.Parent = sprintButton

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(255, 255, 255)
uiStroke.Thickness = 1.5
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiStroke.Parent = sprintButton

local function setSprint(active)
    isSprinting = active
    local targetSpeed = active and sprintSpeed or normalSpeed
    local targetFOV = active and sprintFOV or normalFOV
    
    humanoid.WalkSpeed = targetSpeed
    
    TweenService:Create(camera, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {FieldOfView = targetFOV}):Play()
    
    TweenService:Create(sprintButton, TweenInfo.new(0.2), {
        BackgroundTransparency = active and 0.1 or 0.4,
        TextColor3 = active and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 255, 255)
    }):Play()
end

sprintButton.MouseButton1Down:Connect(function()
    setSprint(not isSprinting)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        setSprint(true)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        setSprint(false)
    end
end)

RunService.Heartbeat:Connect(function()
    if humanoid and humanoid.Parent then
        normalSpeed = humanoid.WalkSpeed / (isSprinting and 1.6 or 1)
        sprintSpeed = normalSpeed * 1.6
        
        if isSprinting then
            humanoid.WalkSpeed = sprintSpeed
        end
        
        if humanoid.MoveDirection.Magnitude == 0 and isSprinting then
            setSprint(false)
        end
    end
end)
