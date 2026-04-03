local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local defaultSpeed = humanoid.WalkSpeed
local defaultFOV = workspace.CurrentCamera.FieldOfView

local targetSpeed = defaultSpeed * 1.6
local targetFOV = defaultFOV + 15

local isSprinting = false
local currentTweenSpeed = nil
local currentTweenFOV = nil

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeadRailsSprintGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local sprintButton = Instance.new("TextButton")
sprintButton.Name = "SprintButton"
sprintButton.Size = UDim2.new(0, 45, 0, 45)
sprintButton.Position = UDim2.new(1, -110, 1, -110)
sprintButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
sprintButton.BackgroundTransparency = 0.4
sprintButton.Text = "RUN"
sprintButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sprintButton.Font = Enum.Font.GothamBold
sprintButton.TextSize = 12

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = sprintButton

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(255, 255, 255)
uiStroke.Thickness = 2
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiStroke.Parent = sprintButton

sprintButton.Parent = screenGui

if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    screenGui.Parent = player:WaitForChild("PlayerGui")
else
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

local function applyState(active)
    if not humanoid or humanoid.Health <= 0 then return end
    
    local speedValue = active and targetSpeed or defaultSpeed
    local fovValue = active and targetFOV or defaultFOV
    
    if currentTweenSpeed then currentTweenSpeed:Cancel() end
    if currentTweenFOV then currentTweenFOV:Cancel() end
    
    currentTweenSpeed = TweenService:Create(humanoid, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {WalkSpeed = speedValue})
    currentTweenFOV = TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {FieldOfView = fovValue})
    
    currentTweenSpeed:Play()
    currentTweenFOV:Play()
    
    TweenService:Create(sprintButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = active and 0.1 or 0.4,
        BackgroundColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(30, 30, 30),
        TextColor3 = active and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(255, 255, 255)
    }):Play()
end

local function toggleSprint()
    isSprinting = not isSprinting
    applyState(isSprinting)
end

sprintButton.Activated:Connect(function()
    toggleSprint()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        isSprinting = true
        applyState(true)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        isSprinting = false
        applyState(false)
    end
end)

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    
    task.wait(1)
    defaultSpeed = humanoid.WalkSpeed
    defaultFOV = workspace.CurrentCamera.FieldOfView
    targetSpeed = defaultSpeed * 1.6
    targetFOV = defaultFOV + 15
    
    isSprinting = false
    applyState(false)
end)

RunService.RenderStepped:Connect(function()
    if humanoid and humanoid.Health > 0 then
        if humanoid.MoveDirection.Magnitude > 0 and isSprinting then
            if humanoid.WalkSpeed ~= targetSpeed and (not currentTweenSpeed or currentTweenSpeed.PlaybackState ~= Enum.PlaybackState.Playing) then
                humanoid.WalkSpeed = targetSpeed
            end
        elseif not isSprinting then
            if humanoid.WalkSpeed ~= defaultSpeed and (not currentTweenSpeed or currentTweenSpeed.PlaybackState ~= Enum.PlaybackState.Playing) then
                humanoid.WalkSpeed = defaultSpeed
            end
        end
    end
end)
