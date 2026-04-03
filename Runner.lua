--[[
    UNIVERSAL OBBY CORE GUI
    Criado com foco em alta performance (Sem Lag, Sem Bugs)
    Funcionalidades: Shiftlock, Sprint (Dead Rails Style), Custom Crosshair e FOV.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

----------------------------------------------------------------------
-- CONFIGURAÇÕES TOTALMENTE EDITÁVEIS
----------------------------------------------------------------------
local CONFIG = {
    NormalSpeed = 16,           -- Velocidade padrão do Roblox
    SprintSpeed = 40,           -- Velocidade ao correr (Solicitado: 40)
    NormalFOV = 70,             -- FOV padrão
    SprintFOV = 111,            -- FOV ao correr (Solicitado: 111)
    CrosshairSize = 12,         -- Tamanho da mira da Granny
    CrosshairColor = Color3.fromRGB(255, 255, 255), -- Cor da mira
    SprintKey = Enum.KeyCode.LeftShift, -- Tecla para correr (PC)
}

----------------------------------------------------------------------
-- CRIAÇÃO DA INTERFACE (GUI) - Sem piscar / Sem travar
----------------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomObbyCoreGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Tenta colocar no CoreGui para maior segurança, se falhar vai para o PlayerGui
local success, err = pcall(function()
    screenGui.Parent = game:GetService("CoreGui")
end)
if not success then
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- 1. MIRA DA GRANNY (Crosshair clássico no meio da tela)
local crosshair = Instance.new("Frame")
crosshair.Name = "GrannyCrosshair"
crosshair.Size = UDim2.new(0, CONFIG.CrosshairSize, 0, CONFIG.CrosshairSize)
crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.BackgroundColor3 = CONFIG.CrosshairColor
crosshair.BorderSizePixel = 0
crosshair.Parent = screenGui

-- Deixar a mira redonda (estilo Granny)
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim2.new(1, 0)
uiCorner.Parent = crosshair

-- 2. BOTÃO DE SPRINT (Estilo Dead Rails - Para Mobile/PC)
local sprintButton = Instance.new("TextButton")
sprintButton.Name = "SprintButton"
sprintButton.Size = UDim2.new(0, 65, 0, 65)
sprintButton.Position = UDim2.new(0.85, 0, 0.7, 0) -- Posição confortável para mobile
sprintButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
sprintButton.BackgroundTransparency = 0.3
sprintButton.Text = "RUN"
sprintButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sprintButton.Font = Enum.Font.GothamBold
sprintButton.TextSize = 18
sprintButton.Parent = screenGui

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim2.new(0.5, 0) -- Botão redondo
buttonCorner.Parent = sprintButton

local buttonStroke = Instance.new("UIStroke")
buttonStroke.Color = Color3.fromRGB(255, 255, 255)
buttonStroke.Thickness = 2
buttonStroke.Parent = sprintButton

----------------------------------------------------------------------
-- LÓGICA DO SPRINT & FOV (SEM STAMINA)
----------------------------------------------------------------------
local isSprinting = false

local function setSprint(state)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    isSprinting = state
    
    if isSprinting then
        humanoid.WalkSpeed = CONFIG.SprintSpeed
        camera.FieldOfView = CONFIG.SprintFOV
        sprintButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Muda de cor ao correr
    else
        humanoid.WalkSpeed = CONFIG.NormalSpeed
        camera.FieldOfView = CONFIG.NormalFOV
        sprintButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end
end

-- Ativação por clique/toque no botão
sprintButton.MouseButton1Down:Connect(function()
    setSprint(not isSprinting)
end)

-- Ativação por teclado (Shift)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == CONFIG.SprintKey then
        setSprint(true)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == CONFIG.SprintKey then
        setSprint(false)
    end
end)

----------------------------------------------------------------------
-- LÓGICA DO SHIFTLOCK (UNIVERSAL USANDO HEARTBEAT)
----------------------------------------------------------------------
-- Bloqueia o mouse no centro e força o personagem a olhar para onde a câmera aponta
RunService.Heartbeat:Connect(function()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            -- Ativa o modo de travamento de câmera do próprio Roblox
            humanoid.CameraOffset = Vector3.new(1.7, 0.5, 0) -- Deslocamento clássico do Shiftlock
            
            -- Faz o personagem girar junto com a câmera
            local cameraCFrame = camera.CFrame
            local lookAt = Vector3.new(cameraCFrame.LookVector.X, 0, cameraCFrame.LookVector.Z).Unit
            if lookAt.Magnitude > 0 then
                rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + lookAt)
            end
            
            -- Previne bugs de física ao teleportar ou cair
            humanoid.AutoRotate = false 
        end
    end
    
    -- Mantém o mouse preso no centro da tela para PC
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
end)

-- Garante que as configurações sejam aplicadas novamente quando o personagem renascer
player.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.AutoRotate = false
    setSprint(false) -- Reseta o sprint ao morrer
end)
