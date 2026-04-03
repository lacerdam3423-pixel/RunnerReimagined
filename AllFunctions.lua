--[[
    Mayura Engine - Custom Shiftlock & Sprint System (V3 - OFFSET REAL)
    Criado para: MigMax
    Focado em: Mobile sem lag, câmera travada para a esquerda.
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
ShiftlockBtn.Size = UDim2.new(0, 40, 0, 40) 
ShiftlockBtn.Position = UDim2.new(0, 15, 0.5, -20) 
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
SprintBtn.Size = UDim2.new(0, 45, 0, 25) 
SprintBtn.Position = UDim2.new(1, -60, 0, 15) 
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
Crosshair.Image = "rbxassetid://135417315" 
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
    ShiftlockOffset = Vector3.new(2.5, 1.5, 0) -- Quanto maior o primeiro número, mais pra esquerda o boneco fica.
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
        SprintBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) 
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
-- [4] SISTEMA DE SHIFTLOCK (EFEITO DE LADO - ATUALIZADO)
-- ==========================================================
local function AlternarShiftlock(ativar)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local camera = workspace.CurrentCamera
    
    if ativar then
        shiftLockAtivo = true
        Crosshair.Visible = true
        ShiftlockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        
        if humanoid then
            humanoid.AutoRotate = false -- Trava a rotação padrão
        end
    else
        shiftLockAtivo = false
        Crosshair.Visible = false
        ShiftlockBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        
        if humanoid then
            humanoid.AutoRotate = true 
        end
        if camera then
            camera.CameraOffset = Vector3.new(0,0,0) -- Reseta a câmera
        end
    end
end

ShiftlockBtn.MouseButton1Click:Connect(function()
    AlternarShiftlock(not shiftLockAtivo)
end)

-- ==========================================================
-- [5] HEARTBEAT LOOP (SEM LAG, SEM PISCAR, ULTRA OTIMIZADO)
-- ==========================================================
RunService.Heartbeat:Connect(function()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera
    
    -- Força o FOV e Velocidade (Evita que o jogo resete)
    if camera then
        if correndo and camera.FieldOfView ~= CFG.SprintFOV then
            camera.FieldOfView = CFG.SprintFOV
        elseif not correndo and camera.FieldOfView == CFG.SprintFOV then
             camera.FieldOfView = CFG.NormalFOV
        end
    end

    if humanoid then
        if correndo and humanoid.WalkSpeed ~= CFG.SprintSpeed then
            humanoid.WalkSpeed = CFG.SprintSpeed
        elseif not correndo and humanoid.WalkSpeed == CFG.SprintSpeed then
            humanoid.WalkSpeed = CFG.NormalSpeed
        end
    end

    -- Mecânica de trava de rotação e Câmera de Lado
    if shiftLockAtivo and rootPart and camera then
        -- Joga a câmera para o lado usando interpolação suave (sem piscar)
        camera.CameraOffset = camera.CameraOffset:Lerp(CFG.ShiftlockOffset, 0.2)
        
        -- Faz o corpo olhar rigorosamente para a frente da câmera
        local lookVector = camera.CFrame.LookVector
        local targetRotation = math.atan2(-lookVector.X, -lookVector.Z)
        rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, targetRotation, 0)
    end
end)

print("Mayura Engine V3 - Shiftlock de Lado Aplicado!")
