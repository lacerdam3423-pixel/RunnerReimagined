local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService") -- Adicionado para o Heartbeat

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local normalSpeed
local normalFOV = 70 -- Valor padrão seguro caso não consiga ler a tempo

local isSprinting = false
local heartbeatConnection = nil -- Guardar a conexão para poder desligar

local SPEED_MULTIPLIER = 1.6
local SPRINT_FOV = 120 -- Definido o FOV exato que você pediu

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeadRailsSprintGui"

-- [AVISO]: Se você estiver usando isso em um jogo próprio publicado no Roblox,
-- mude para: screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.Parent = CoreGui 

local mainButton = Instance.new("ImageButton")
mainButton.Name = "SprintButton"

-- AJUSTE DE POSIÇÃO PARA FICAR AO LADO DO JUMP
mainButton.Size = UDim2.new(0, 50, 0, 50) 
mainButton.AnchorPoint = Vector2.new(1, 1) 

-- X = 83% da tela para a esquerda, Y = 83% da tela para baixo. 
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

local function getSpeedAndFov()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    normalSpeed = humanoid.WalkSpeed
    -- Salva o FOV original do jogo apenas se não estivermos correndo
    if not isSprinting then
        normalFOV = camera.FieldOfView
    end
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
    local targetStrokeColor = active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

    humanoid.WalkSpeed = targetSpeed

    -- Gerenciamento do Heartbeat para travar o FOV sem piscar
    if active then
        -- Se já houver uma conexão antiga, desliga por segurança
        if heartbeatConnection then heartbeatConnection:Disconnect() end
        
        -- Força o FOV em 120 a cada microssegundo (vence outros scripts do jogo)
        heartbeatConnection = RunService.Heartbeat:Connect(function()
            camera.FieldOfView = SPRINT_FOV
        end)
    else
        -- Quando para de correr, desliga o "forçador" de FOV
        if heartbeatConnection then
            heartbeatConnection:Disconnect()
            heartbeatConnection = nil
        end
        -- Suavemente devolve o FOV para o padrão do jogo
        TweenService:Create(camera, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {FieldOfView = normalFOV}):Play()
    end

    -- Tweens visuais do botão
    TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Color = targetStrokeColor}):Play()
    TweenService:Create(mainButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {BackgroundTransparency = active and 0.2 or 0.4}):Play()
end

-- Ativa/Desativa no clique do botão mobile
mainButton.MouseButton1Down:Connect(function()
    applySprint(not isSprinting)
end)

-- Tecla Shift (PC)
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
