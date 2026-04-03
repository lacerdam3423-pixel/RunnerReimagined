local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService") -- Adicionado para o Heartbeat

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local normalSpeed
local normalFOV = 60 -- Padrão do Roblox (será atualizado)

local isSprinting = false

local SPEED_MULTIPLIER = 1.6
local SPRINT_FOV = 120 -- FOV que você pediu quando estiver correndo

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeadRailsSprintGui"
screenGui.Parent = CoreGui 

local mainButton = Instance.new("ImageButton")
mainButton.Name = "SprintButton"
mainButton.Size = UDim2.new(0, 50, 0, 50) 
mainButton.AnchorPoint = Vector2.new(1, 1) 
mainButton.Position = UDim2.new(0.83, 0, 0.83, 0) 
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

-- Função para pegar a velocidade e FOV base
local function getSpeedAndFov()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    normalSpeed = humanoid.WalkSpeed
    normalFOV = camera.FieldOfView
end

player.CharacterAdded:Connect(getSpeedAndFov)
getSpeedAndFov()

-- ESSA É A MÁGICA DO HEARTBEAT: Força o FOV a não piscar!
RunService.Heartbeat:Connect(function()
    if isSprinting then
        camera.FieldOfView = SPRINT_FOV
    end
end)

local function applySprint(active)
    isSprinting = active

    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    local targetSpeed = active and (normalSpeed * SPEED_MULTIPLIER) or normalSpeed
    local targetFOV = active and SPRINT_FOV or normalFOV
    local targetStrokeColor = active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

    humanoid.WalkSpeed = targetSpeed

    -- Suaviza a transição do FOV
    TweenService:Create(camera, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {FieldOfView = targetFOV}):Play()
    TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Color = targetStrokeColor}):Play()
    TweenService:Create(mainButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {BackgroundTransparency = active and 0.2 or 0.4}):Play()
end

-- Lógica de clique no Botão da Tela (Alterna entre correr e não correr)
mainButton.MouseButton1Down:Connect(function()
    applySprint(not isSprinting)
end)

-- Lógica do Teclado (Shift Esquerdo)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        applySprint(not isSprinting) -- Agora o shift também alterna (clica corre, clica de novo para)
    end
end)
