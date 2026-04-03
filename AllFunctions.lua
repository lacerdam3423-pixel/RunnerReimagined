--[[
    Mayura Engine - Custom Shiftlock & Sprint System (FIXED)
    Criado para: MigMax
    Focado em: Mobile sem lag, sem bugs de camera.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Garante que vai para a CoreGui ou para onde o executor mandar
local parentGui = (gethui and gethui()) or game:GetService("CoreGui"):FindFirstChild("RobloxGui") or player:WaitForChild("PlayerGui")

-- Destrói a versão antiga para não bugar
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

-- Botão de Shiftlock (Estilo Obby - Canto Esquerdo)
local ShiftlockBtn = Instance.new("ImageButton")
ShiftlockBtn.Name = "ShiftlockButton"
ShiftlockBtn.Size = UDim2.new(0, 40, 0, 40) -- Pequeno
ShiftlockBtn.Position = UDim2.new(0, 15, 0.5, -20) -- Esquerda
ShiftlockBtn.BackgroundTransparency = 0.5
ShiftlockBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ShiftlockBtn.Image = "rbxassetid://12121703248" 
ShiftlockBtn.ScaleType = Enum.ScaleType.Fit
ShiftlockBtn.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = ShiftlockBtn

-- Botão de Correr (Canto Superior Direito)
local SprintBtn = Instance.new("TextButton")
SprintBtn.Name = "SprintButton"
SprintBtn.Size = UDim2.new(0, 45, 0, 25) -- Super pequeno
SprintBtn.Position = UDim2.new(1, -60, 0, 15) -- Superior direito
SprintBtn.BackgroundTransparency = 0.4
SprintBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SprintBtn.Text = "RUN"
SprintBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SprintBtn.Font = Enum.Font.GothamBold
SprintBtn.TextSize = 11
SprintBtn.Parent = ScreenGui

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 6)
UICorner2.Parent = SprintBtn

-- Mira da Granny (Centro da tela)
local Crosshair = Instance.new("ImageLabel")
Crosshair.Name = "GrannyCrosshair"
Crosshair.Size = UDim2.new(0, 16, 0, 16)
Crosshair.Position = UDim2.new(0.5, -8, 0.5, -8)
Crosshair.BackgroundTransparency = 1
Crosshair.Image = "rbxassetid://135417315" -- Mira clássica
Crosshair.ImageColor3 = Color3.fromRGB(255, 0, 0)
Crosshair.Visible = false
Crosshair.Parent = ScreenGui


-- ==========================================================
-- [2] CONFIGURAÇÕES EDITÁVEIS
-- ==========================================================
local CFG = {
    NormalSpeed = 16,
    SprintSpeed = 40,
    NormalFOV = 70,
    SprintFOV = 111,
}

local shiftLockAtivo = false
local correndo = false

-- ==========================================================
-- [3] SISTEMA DE SPRINT (SEM STAMINA)
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
        SprintBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Alerta de corrida
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
-- [4] SISTEMA DE SHIFTLOCK (ABSOLUTO PARA MOBILE)
-- ==========================================================
local function AlternarShiftlock(ativar)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if ativar then
        shiftLockAtivo = true
        Crosshair.Visible = true
        ShiftlockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        
        -- Modo de câmera que trava o corpo
        if humanoid then
            humanoid.AutoRotate = false -- Personagem não gira sozinho
        end
    else
        shiftLockAtivo = false
        Crosshair.Visible = false
        ShiftlockBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        
        if humanoid then
            humanoid.AutoRotate = true -- Volta ao normal
        end
    end
end

ShiftlockBtn.MouseButton1Click:Connect(function()
    AlternarShiftlock(not shiftLockAtivo)
end)

-- ==========================================================
-- [5] HEARTBEAT LOOP (O SEGREDO DO "SEM LAG" E "SEM PISCAR")
-- ==========================================================
RunService.Heartbeat:Connect(function()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera
    
    -- Ajuste constante do FOV para evitar que o jogo tente resetar
    if camera then
        if correndo and camera.FieldOfView ~= CFG.SprintFOV then
            camera.FieldOfView = CFG.SprintFOV
        elseif not correndo and camera.FieldOfView == CFG.SprintFOV then
             camera.FieldOfView = CFG.NormalFOV
        end
    end

    -- Ajuste constante da Velocidade
    if humanoid then
        if correndo and humanoid.WalkSpeed ~= CFG.SprintSpeed then
            humanoid.WalkSpeed = CFG.SprintSpeed
        elseif not correndo and humanoid.WalkSpeed == CFG.SprintSpeed then
            humanoid.WalkSpeed = CFG.NormalSpeed
        end
    end

    -- Mecânica de trava de rotação do Shiftlock
    if shiftLockAtivo and rootPart and camera then
        local lookVector = camera.CFrame.LookVector
        -- Faz o corpo acompanhar a mira horizontal perfeitamente
        local targetRotation = math.atan2(-lookVector.X, -lookVector.Z)
        rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, targetRotation, 0)
    end
end)

print("Mayura Engine atualizada e funcionando!")
