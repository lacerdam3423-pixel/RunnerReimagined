--[[
    Mayura Engine - Custom Shiftlock & Sprint System
    Criado para: MigMax
    Focado em: Alto desempenho, sem lag, sem erros.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Tenta colocar na CoreGui para não sumir ao morrer, se não conseguir vai pro PlayerGui
local parentGui = (gethui and gethui()) or game:GetService("CoreGui"):FindFirstChild("RobloxGui") or player:WaitForChild("PlayerGui")

-- DESTRUIR GUI ANTIGA SE EXISTIR (Evita acumular scripts)
if parentGui:FindFirstChild("Mayura_CustomGui") then
    parentGui["Mayura_CustomGui"]:Destroy()
end

-- ==========================================================
-- [1] CRIAÇÃO DA INTERFACE (GUI)
-- ==========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Mayura_CustomGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = parentGui

-- Botão de Shiftlock (Estilo Obby Tradicional - Canto Esquerdo)
local ShiftlockBtn = Instance.new("ImageButton")
ShiftlockBtn.Name = "ShiftlockButton"
ShiftlockBtn.Size = UDim2.new(0, 45, 0, 45) -- Pequeno
ShiftlockBtn.Position = UDim2.new(0, 15, 0.5, -22) -- Esquerda, bem posicionado
ShiftlockBtn.BackgroundTransparency = 0.5
ShiftlockBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ShiftlockBtn.Image = "rbxassetid://12121703248" -- Ícone de cadeado do Shiftlock
ShiftlockBtn.ScaleType = Enum.ScaleType.Fit
ShiftlockBtn.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = ShiftlockBtn

-- Botão de Correr (Estilo Dead Rails - Pequeno, Canto Superior Direito)
local SprintBtn = Instance.new("TextButton")
SprintBtn.Name = "SprintButton"
SprintBtn.Size = UDim2.new(0, 50, 0, 30) -- Pequeno
SprintBtn.Position = UDim2.new(1, -65, 0, 20) -- Canto superior direito
SprintBtn.BackgroundTransparency = 0.4
SprintBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SprintBtn.Text = "RUN"
SprintBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SprintBtn.Font = Enum.Font.GothamBold
SprintBtn.TextSize = 12
SprintBtn.Parent = ScreenGui

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 6)
UICorner2.Parent = SprintBtn

-- Mira da Granny (No centro exato da tela)
local Crosshair = Instance.new("ImageLabel")
Crosshair.Name = "GrannyCrosshair"
Crosshair.Size = UDim2.new(0, 16, 0, 16) -- Tamanho ideal para mira
Crosshair.Position = UDim2.new(0.5, -8, 0.5, -8) -- Centro exato
Crosshair.BackgroundTransparency = 1
Crosshair.Image = "rbxassetid://135417315" -- ID clássico de mira circular (Estilo Granny)
Crosshair.ImageColor3 = Color3.fromRGB(255, 0, 0) -- Vermelho clássico
Crosshair.Visible = false -- Só aparece quando o Shiftlock estiver ativo
Crosshair.Parent = ScreenGui


-- ==========================================================
-- [2] CONFIGURAÇÕES EDITÁVEIS
-- ==========================================================
local CFG = {
    NormalSpeed = 16,
    SprintSpeed = 40,
    NormalFOV = 70,
    SprintFOV = 111,
    ShiftlockCamOffset = Vector3.new(1.75, 2, 0) -- Posição da câmera no Shiftlock
}

local shiftLockAtivo = false
local correndo = false

-- ==========================================================
-- [3] SISTEMA DE SPRINT (SEM STAMINA - ESTILO DEAD RAILS)
-- ==========================================================
local function AlternarSprint(ativar)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local camera = workspace.CurrentCamera
    
    if not humanoid or not camera then return end
    
    if ativar then
        correndo = true
        humanoid.WalkSpeed = CFG.SprintSpeed
        camera.FieldOfView = CFG.SprintFOV
        SprintBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Fica vermelho ao correr
    else
        correndo = false
        humanoid.WalkSpeed = CFG.NormalSpeed
        camera.FieldOfView = CFG.NormalFOV
        SprintBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end
end

SprintBtn.MouseButton1Click:Connect(function()
    AlternarSprint(not correndo)
end)


-- ==========================================================
-- [4] SISTEMA DE SHIFTLOCK REAL (FOCADO EM OBBY)
-- ==========================================================
local function AlternarShiftlock(ativar)
    local camera = workspace.CurrentCamera
    
    if ativar then
        shiftLockAtivo = true
        Crosshair.Visible = true
        ShiftlockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0) -- Verde (Ativado)
        
        -- Altera o comportamento do mouse para travar no centro
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    else
        shiftLockAtivo = false
        Crosshair.Visible = false
        ShiftlockBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Preto (Desativado)
        
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        camera.CameraOffset = Vector3.new(0,0,0)
    end
end

ShiftlockBtn.MouseButton1Click:Connect(function()
    AlternarShiftlock(not shiftLockAtivo)
end)

-- ==========================================================
-- [5] LOOP HEARTBEAT (SUPER OTIMIZADO - SEM PISCAR/LAG)
-- ==========================================================
RunService.Heartbeat:Connect(function()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera
    
    if shiftLockAtivo and character and rootPart and camera then
        -- Trava o mouse no centro sem piscar
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        
        -- Afasta a câmera um pouco para o lado (Estilo Shiftlock real)
        camera.CameraOffset = camera.CameraOffset:Lerp(CFG.ShiftlockCamOffset, 0.2)
        
        -- Faz o personagem olhar para onde a câmera está apontando
        local lookVector = camera.CFrame.LookVector
        local targetRotation = math.atan2(-lookVector.X, -lookVector.Z)
        rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, targetRotation, 0)
    else
        if camera then
            camera.CameraOffset = camera.CameraOffset:Lerp(Vector3.new(0,0,0), 0.2)
        end
    end
    
    -- Mantém a velocidade ativa mesmo se o jogo tentar resetar
    if correndo and humanoid and humanoid.WalkSpeed ~= CFG.SprintSpeed then
        humanoid.WalkSpeed = CFG.SprintSpeed
    end
end)

-- Garante que o FOV não mude sozinho
workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
    local camera = workspace.CurrentCamera
    if correndo and camera.FieldOfView ~= CFG.SprintFOV then
        camera.FieldOfView = CFG.SprintFOV
    end
end)

print("Mayura Engine carregada com sucesso!")
