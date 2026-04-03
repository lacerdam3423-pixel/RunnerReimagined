local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local isSprinting = false
local shiftLockActive = false

-- Configurações pedidas
local SPRINT_FOV = 120
local SPRINT_SPEED = 40

-- Guardam os valores originais dinamicamente
local originalSpeed = 16
local originalFOV = 70

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomSprintAndLockGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui 

-----------------------------------------
-- 1. CROSSHAIR (MIRA NO MEIO DA TELA) --
-----------------------------------------
local crosshair = Instance.new("Frame")
crosshair.Name = "GrannyDot"
crosshair.Size = UDim2.new(0, 4, 0, 4) -- Pontinho pequeno estilo Granny
crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
crosshair.BorderSizePixel = 0
crosshair.Parent = screenGui

local chCorner = Instance.new("UICorner")
chCorner.CornerRadius = UDim.new(1, 0)
chCorner.Parent = crosshair

-----------------------------------------
-- 2. BOTÃO DE CORRER (SPRINT) --------
-----------------------------------------
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

-----------------------------------------
-- 3. BOTÃO DE CADEADO (SHIFTLOCK) ----
-----------------------------------------
local lockButton = Instance.new("ImageButton")
lockButton.Name = "ShiftLockButton"
lockButton.Size = UDim2.new(0, 35, 0, 35) -- Botão pequeno
lockButton.AnchorPoint = Vector2.new(1, 1)
-- Posicionado um pouco acima do botão de sprint
lockButton.Position = UDim2.new(0.83, 0, 0.73, 0) 
lockButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
lockButton.BackgroundTransparency = 0.4
lockButton.Image = "rbxassetid://5400181533" -- Ícone de cadeado
lockButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
lockButton.Parent = screenGui

local lockCorner = Instance.new("UICorner")
lockCorner.CornerRadius = UDim.new(1, 0)
lockCorner.Parent = lockButton

local lockStroke = Instance.new("UIStroke")
lockStroke.Color = Color3.fromRGB(255, 255, 255)
lockStroke.Thickness = 1.5
lockStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
lockStroke.Transparency = 0.3
lockStroke.Parent = lockButton

-----------------------------------------
-- 4. LÓGICA DE VELOCIDADE E FOV --------
-----------------------------------------

-- Pega os valores reais do jogo dinamicamente
local function updateOriginalValues()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    if not isSprinting then
        originalSpeed = humanoid.WalkSpeed
        originalFOV = camera.FieldOfView
    end
end

-- Hook para atualizar sempre que o personagem spawnar
player.CharacterAdded:Connect(function()
    task.wait(1)
    updateOriginalValues()
end)
updateOriginalValues()

-- Aplica a corrida
local function applySprint(active)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    isSprinting = active

    if active then
        -- Salva o atual antes de mudar para garantir que sabemos o padrão do jogo
        originalSpeed = humanoid.WalkSpeed
        humanoid.WalkSpeed = SPRINT_SPEED
        
        TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Color = Color3.fromRGB(0, 255, 0)}):Play()
        TweenService:Create(mainButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.2}):Play()
    else
        humanoid.WalkSpeed = originalSpeed
        
        TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Color = Color3.fromRGB(255, 0, 0)}):Play()
        TweenService:Create(mainButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.4}):Play()
    end
end

-- EXECUÇÃO EM HEARTBEAT (Não deixa o FOV piscar nem voltar)
RunService.RenderStepped:Connect(function()
    if isSprinting then
        camera.FieldOfView = SPRINT_FOV
    end
end)

-- Controles de clique e teclado para Sprint
mainButton.MouseButton1Down:Connect(function()
    applySprint(not isSprinting)
end)

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

-----------------------------------------
-- 5. LÓGICA DO SHIFTLOCK (OBBY REAL) ---
-----------------------------------------

local function setShiftLock(active)
    shiftLockActive = active
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    
    if active then
        -- Câmera para a DIREITA, Jogador para a ESQUERDA (Offset)
        humanoid.CameraOffset = Vector3.new(2.5, 0.5, 0)
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        lockButton.ImageColor3 = Color3.fromRGB(0, 255, 0) -- Verde ativo
    else
        humanoid.CameraOffset = Vector3.new(0, 0, 0)
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        lockButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
    end
end

-- Botão Mobile/Clique
lockButton.MouseButton1Down:Connect(function()
    setShiftLock(not shiftLockActive)
end)

-- Tecla Shift Direito ou Control para travar no PC
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightShift then
        setShiftLock(not shiftLockActive)
    end
end)

-- Mantém o ShiftLock ativo forçadamente a cada frame
RunService.RenderStepped:Connect(function()
    if shiftLockActive then
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            
            -- Faz o personagem olhar para onde a câmera aponta (Shiftlock real de Obby)
            local lookVector = camera.CFrame.LookVector
            local rootPart = character.HumanoidRootPart
            rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
        end
    end
end)
