local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService") -- Adicionado para o Heartbeat

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local normalSpeed
local normalFOV

local isSprinting = false

-- Ajustes solicitados
local SPRINT_SPEED = 40 -- Velocidade exata de 40
local SPRINT_FOV = 120 -- FOV exato de 120

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeadRailsSprintGui"
screenGui.ResetOnSpawn = false -- Garante que a interface não suma ao morrer

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

-- Função para capturar os valores originais do jogo
local function getSpeedAndFov()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    -- Só salva a velocidade normal se ela não for a velocidade de sprint
    if humanoid.WalkSpeed ~= SPRINT_SPEED then
        normalSpeed = humanoid.WalkSpeed
    end
    
    -- Só salva o FOV normal se ele não for o de sprint
    if camera.FieldOfView ~= SPRINT_FOV then
        normalFOV = camera.FieldOfView
    end
end

player.CharacterAdded:Connect(getSpeedAndFov)
getSpeedAndFov()

-- LOGICA DO HEARTBEAT: Trava o FOV sem piscar enquanto estiver correndo
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

    -- Se desativar, puxa o padrão do jogo novamente caso tenha mudado
    if not active then
        getSpeedAndFov()
    end

    local targetSpeed = active and SPRINT_SPEED or normalSpeed
    local targetStrokeColor = active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

    humanoid.WalkSpeed = targetSpeed

    -- Se não estiver correndo, faz a transição suave de volta para o FOV original
    if not active then
        TweenService:Create(camera, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {FieldOfView = normalFOV}):Play()
    end
    
    TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Color = targetStrokeColor}):Play()
    TweenService:Create(mainButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {BackgroundTransparency = active and 0.2 or 0.4}):Play()
end

-- Mobile
mainButton.MouseButton1Down:Connect(function()
    applySprint(not isSprinting)
end)

-- PC (Shift ativa/desativa como alternador para combinar com o botão mobile)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        applySprint(not isSprinting)
    end
end)
