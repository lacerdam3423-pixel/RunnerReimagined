local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local isSprinting = false
local normalSpeed = humanoid.WalkSpeed
local normalFOV = workspace.CurrentCamera.FieldOfView
local sprintSpeed = normalSpeed * 1.6
local sprintFOV = normalFOV + 15

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeadRailsSprintGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local sprintButton = Instance.new("ImageButton")
sprintButton.Name = "SprintButton"
sprintButton.Size = UDim2.new(0, 50, 0, 50)
sprintButton.Position = UDim2.new(1, -120, 1, -110)
sprintButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
sprintButton.BackgroundTransparency = 0.4
sprintButton.AutoButtonColor = false

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = sprintButton

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(255, 255, 255)
uiStroke.Thickness = 2
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiStroke.Parent = sprintButton

sprintButton.Parent = screenGui
screenGui.Parent = player:WaitForChild("PlayerGui")

local function updateReferences(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    
    task.defer(function()
        task.wait(0.5)
        normalSpeed = humanoid.WalkSpeed
        sprintSpeed = normalSpeed * 1.6
        normalFOV = workspace.CurrentCamera.FieldOfView
        sprintFOV = normalFOV + 15
    end)
end

player.CharacterAdded:Connect(updateReferences)

local function setSprint(active)
    if humanoid.MoveDirection.Magnitude > 0 and active then
        isSprinting = true
        humanoid.WalkSpeed = sprintSpeed
        sprintButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sprintButton.BackgroundTransparency = 0.2
        uiStroke.Color = Color3.fromRGB(0, 0, 0)
    else
        isSprinting = false
        humanoid.WalkSpeed = normalSpeed
        sprintButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        sprintButton.BackgroundTransparency = 0.4
        uiStroke.Color = Color3.fromRGB(255, 255, 255)
    end
end

sprintButton.MouseButton1Down:Connect(function()
    setSprint(not isSprinting)
end)

humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
    if humanoid.MoveDirection.Magnitude == 0 and isSprinting then
        setSprint(false)
    end
end)

RunService.RenderStepped:Connect(function(deltaTime)
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local targetFOV = isSprinting and sprintFOV or normalFOV
    if math.abs(camera.FieldOfView - targetFOV) > 0.1 then
        camera.FieldOfView = math.lerp(camera.FieldOfView, targetFOV, 1 - math.pow(0.01, deltaTime))
    end
end)
