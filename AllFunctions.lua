--[[
    Criado por: MigMax ;]
    Tema: Mayura Engine (Edição Especial)
    Descrição: Shiftlock + Crosshair Granny + Sprint Dead Rails
    Totalmente editável e otimizado para não causar lag.
--]]

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Proteção para garantir que o personagem carregou
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Tenta colocar no CoreGui, se não conseguir vai para PlayerGui
local parentGui
local success, err = pcall(function()
    parentGui = game:GetService("CoreGui")
end)
if not success then
    parentGui = player:WaitForChild("PlayerGui")
end

-----------------------------------------------------------
-- [CONFIGURAÇÃO EDITÁVEL]
-----------------------------------------------------------
local CONFIG = {
    VelocidadeNormal = 16,
    VelocidadeSprint = 40,
    FovNormal = 70,
    FovSprint = 111,
    SensibilidadeShiftlock = 0.5,
    OffsetCamera = Vector3.new(1.7, 1.5, 0) -- Posição de ombro clássica do Obby
}

-----------------------------------------------------------
-- [CRIAÇÃO DA INTERFACE]
-----------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Mayura_Shiftlock_Sprint"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = parentGui

-- 1. Crosshair da Granny (Centro da Tela)
local Crosshair = Instance.new("Frame")
Crosshair.Name = "GrannyCrosshair"
Crosshair.Size = UDim2.new(0, 8, 0, 8)
Crosshair.Position = UDim2.new(0.5, -4, 0.5, -4)
Crosshair.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Vermelho Granny
Crosshair.BorderSizePixel = 0
Crosshair.ZIndex = 10
Crosshair.Parent = ScreenGui

local UICorner_Cross = Instance.new("UICorner")
UICorner_Cross.CornerRadius = UDim.new(1, 0) -- Torna o frame um círculo
UICorner_Cross.Parent = Crosshair

-- 2. Botão de Shiftlock (Canto Esquerdo)
local ShiftlockBtn = Instance.new("ImageButton")
ShiftlockBtn.Name = "ShiftlockButton"
ShiftlockBtn.Size = UDim2.new(0, 50, 0, 50)
ShiftlockBtn.Position = UDim2.new(0.1, 0, 0.5, -25) -- Não muito longe, à esquerda
ShiftlockBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ShiftlockBtn.Image = "rbxassetid://14459618035" -- Ícone de trava (Substitua se preferir outro)
ShiftlockBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
ShiftlockBtn.Parent = ScreenGui

local UICorner_SL = Instance.new("UICorner")
UICorner_SL.CornerRadius = UDim.new(0.3, 0)
UICorner_SL.Parent = ShiftlockBtn

-- 3. Botão de Sprint (Canto Direito - Pequeno)
local SprintBtn = Instance.new("TextButton")
SprintBtn.Name = "SprintButton"
SprintBtn.Size = UDim2.new(0, 45, 0, 45) -- Pequeno
SprintBtn.Position = UDim2.new(0.85, 0, 0.5, -22) -- Canto direito
SprintBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SprintBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SprintBtn.Text = "RUN"
SprintBtn.Font = Enum.Font.GothamBold
SprintBtn.TextSize = 12
SprintBtn.Parent = ScreenGui

local UICorner_Sp = Instance.new("UICorner")
UICorner_Sp.CornerRadius = UDim.new(0.5, 0) -- Redondo
UICorner_Sp.Parent = SprintBtn

-----------------------------------------------------------
-- [LÓGICA DAS FUNÇÕES]
-----------------------------------------------------------
local shiftLockAtivado = false
local correndo = false

-- Atualização contínua via Heartbeat (Zero Lag e Sem Piscar)
RunService.Heartbeat:Connect(function()
    if shiftLockAtivado and character and humanoid and humanoid.Health > 0 then
        -- Mantém o mouse travado no centro
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        
        -- Faz o personagem olhar para onde a câmera está apontando
        local cameraCFrame = camera.CFrame
        local lookVector = cameraCFrame.LookVector
        humanoid.AutoRotate = false
        character.HumanoidRootPart.CFrame = CFrame.new(
            character.HumanoidRootPart.Position, 
            character.HumanoidRootPart.Position + Vector3.new(lookVector.X, 0, lookVector.Z)
        )
        
        -- Aplica o Offset de ombro clássico
        camera.HumanoidCameraOffset = CONFIG.OffsetCamera
    else
        -- Restaura as configurações normais
        if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
        humanoid.AutoRotate = true
        camera.HumanoidCameraOffset = Vector3.new(0, 0, 0)
    end
end)

-- Ativa/Desativa o Shiftlock
ShiftlockBtn.MouseButton1Click:Connect(function()
    shiftLockAtivado = not shiftLockAtivado
    
    -- Efeito visual de botão ativado
    if shiftLockAtivado then
        ShiftlockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100) -- Verde
    else
        ShiftlockBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Padrão
    end
end)

-- Função de Correr (Dead Rails Style)
local function alternarSprint()
    correndo = not correndo
    
    if correndo then
        humanoid.WalkSpeed = CONFIG.VelocidadeSprint
        TweenService:Create(camera, TweenInfo.new(0.3), {FieldOfView = CONFIG.FovSprint}):Play()
        SprintBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Vermelho alerta
    else
        humanoid.WalkSpeed = CONFIG.VelocidadeNormal
        TweenService:Create(camera, TweenInfo.new(0.3), {FieldOfView = CONFIG.FovNormal}):Play()
        SprintBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Padrão
    end
end

SprintBtn.MouseButton1Click:Connect(alternarSprint)

-- Resetar variáveis ao morrer para evitar quebras
player.CharacterAdded:Connect(function(novoChar)
    character = novoChar
    humanoid = novoChar:WaitForChild("Humanoid")
    correndo = false
    shiftLockAtivado = false
    ShiftlockBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SprintBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    camera.FieldOfView = CONFIG.FovNormal
end)
