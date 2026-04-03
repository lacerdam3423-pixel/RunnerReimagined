--[[
    SISTEMA ULTRA PRO: SHIFTLOCK OBBY + DEAD RAILS SPRINT + GRANNY CROSSHAIR
    Totalmente editável, otimizado e universal.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

---------------------------------------------------------
-- CONFIGURAÇÕES EDITÁVEIS (Mude como quiser)
---------------------------------------------------------
local CONFIG = {
    -- Sprint
    NormalSpeed = 16,
    SprintSpeed = 40,
    NormalFOV = 70,
    SprintFOV = 111,
    TweenTime = 0.3, -- Tempo de transição suave do FOV
    
    -- Shiftlock
    LockKey = Enum.KeyCode.Control, -- Tecla para ativar/desativar
    CameraOffset = Vector3.new(1.75, 0.5, 0), -- Posição da câmera no Shiftlock
}

---------------------------------------------------------
-- 1. CRIAÇÃO DA GUI (Otimizada e sem piscar)
---------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomCoreGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Mira da Granny (No meio da tela)
local Crosshair = Instance.new("ImageLabel")
Crosshair.Name = "GrannyCrosshair"
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
Crosshair.Size = UDim2.new(0, 32, 0, 32) -- Tamanho clássico
Crosshair.BackgroundTransparency = 1
Crosshair.Image = "rbxassetid://134433108" -- ID de mira clássica (Substitua se tiver a ID exata da Granny)
Crosshair.Parent = ScreenGui

-- Botão de Shiftlock estilo Obby Tradicional
local ShiftlockButton = Instance.new("ImageButton")
ShiftlockButton.Name = "ShiftlockButton"
ShiftlockButton.Size = UDim2.new(0, 65, 0, 65)
ShiftlockButton.Position = UDim2.new(0.1, 0, 0.7, 0)
ShiftlockButton.AnchorPoint = Vector2.new(0.5, 0.5)
ShiftlockButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ShiftlockButton.BackgroundTransparency = 0.5
ShiftlockButton.Image = "rbxassetid://12130001548" -- Ícone de cadeado do Shiftlock
ShiftlockButton.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = ShiftlockButton

---------------------------------------------------------
-- 2. SISTEMA DE SHIFTLOCK REAL (Sem bugs)
---------------------------------------------------------
local shiftLockActive = false

local function setShiftlock(active)
    shiftLockActive = active
    if active then
        ShiftlockButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Verde quando ativo
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    else
        ShiftlockButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Preto quando inativo
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end

-- Ativação pelo Botão ou pela Tecla
ShiftlockButton.MouseButton1Click:Connect(function()
    setShiftlock(not shiftLockActive)
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == CONFIG.LockKey then
        setShiftlock(not shiftLockActive)
    end
end)

-- Heartbeat ultra otimizado para prender o mouse e girar o personagem
RunService.Heartbeat:Connect(function()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and hrp then
            if shiftLockActive then
                -- Prende o mouse no meio (sem piscar)
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                
                -- Faz o personagem olhar para onde a câmera está olhando (Obby style)
                local cameraCFrame = camera.CFrame
                local lookAt = Vector3.new(cameraCFrame.LookVector.X, 0, cameraCFrame.LookVector.Z).Unit
                hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + lookAt)
                
                -- Desvia a câmera levemente para o ombro
                humanoid.CameraOffset = humanoid.CameraOffset:Lerp(CONFIG.CameraOffset, 0.2)
            else
                humanoid.CameraOffset = humanoid.CameraOffset:Lerp(Vector3.new(0,0,0), 0.2)
            end
        end
    end
end)

---------------------------------------------------------
-- 3. SISTEMA DE SPRINT (Estilo Dead Rails - Sem Stamina)
---------------------------------------------------------
local isSprinting = false

local function updateSpeedAndFOV(sprint)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local targetSpeed = sprint and CONFIG.SprintSpeed or CONFIG.NormalSpeed
    local targetFOV = sprint and CONFIG.SprintFOV or CONFIG.NormalFOV
    
    humanoid.WalkSpeed = targetSpeed
    
    -- Transição suave do FOV
    TweenService:Create(camera, TweenInfo.new(CONFIG.TweenTime, Enum.EasingStyle.Sine), {FieldOfView = targetFOV}):Play()
end

-- Ativação por teclas (Shift Esquerdo ou Botão de Sprint padrão do Roblox)
ContextActionService:BindAction("DeadRailsSprint", function(actionName, inputState, inputObject)
    if inputState == Enum.UserInputState.Begin then
        isSprinting = true
        updateSpeedAndFOV(true)
    elseif inputState == Enum.UserInputState.End then
        isSprinting = false
        updateSpeedAndFOV(false)
    end
    return Enum.ContextActionResult.Pass
end, true, Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonR2)

-- Configura o botão de celular gerado pelo ContextActionService
ContextActionService:SetTitle("DeadRailsSprint", "Sprint")
ContextActionService:SetPosition("DeadRailsSprint", UDim2.new(0.1, 0, 0.5, 0))

-- Garante que o jogador mantenha a velocidade ao renascer
player.CharacterAdded:Connect(function(char)
    setShiftlock(false) -- Reseta o shiftlock para evitar bugs de câmera ao nascer
    char:WaitForChild("Humanoid").WalkSpeed = CONFIG.NormalSpeed
end)
