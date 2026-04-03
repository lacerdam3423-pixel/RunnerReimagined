local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local normalSpeed
-- Forçamos o FOV base para 120
local BASE_FOV = 120 
-- Definimos para quanto o FOV vai quando estiver correndo (ex: 135)
local SPRINT_FOV = 135 

local isSprinting = false
local SPEED_MULTIPLIER = 1.6

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeadRailsSprintGui"

-- [AVISO]: Se você estiver usando isso em um jogo próprio publicado no Roblox,
-- mude para: screenGui.Parent = player:WaitForChild("PlayerGui")
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

-- Função para pegar a velocidade e setar o FOV inicial em 120
local function getSpeedAndFov()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    normalSpeed = humanoid.WalkSpeed
    
    -- Aplica o FOV de 120 logo de início
    camera.FieldOfView = BASE_FOV
end

player.CharacterAdded:Connect(getSpeedAndFov)
getSpeedAndFov()

-- Lógica de Correr / Não Correr
local function applySprint(active)
    isSprinting = active

    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    -- Se ativo, multiplica a velocidade. Se não, volta ao normal.
    local targetSpeed = active and (normalSpeed * SPEED_MULTIPLIER) or normalSpeed
    -- Se ativo, vai para o FOV de corrida. Se não, volta para o base (120).
    local targetFOV = active and SPRINT_FOV or BASE_FOV
    local targetStrokeColor = active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

    humanoid.WalkSpeed = targetSpeed

    TweenService:Create(camera, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {FieldOfView = targetFOV}):Play()
    TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Color = targetStrokeColor}):Play()
    TweenService:Create(mainButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {BackgroundTransparency = active and 0.2 or 0.4}):Play()
end

-- Clique no botão da tela (Inverte o estado atual)
mainButton.MouseButton1Down:Connect(function()
    applySprint(not isSprinting)
end)

-- Clique no teclado (Shift Esquerdo agora alterna igual ao botão)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        applySprint(not isSprinting) -- Agora ele alterna! Se tava correndo, para.
    end
end)

-- Removida a função InputEnded para o Shift não fazer o boneco parar de correr ao soltar a tecla.
