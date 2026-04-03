local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- CONFIGURAÇÕES EXIGIDAS
local TARGET_FOV = 120
local SPEED_MULTIPLIER = 1.6 -- Multiplicador original do seu script (Velocidade base * 1.6)

local isSprinting = false
local shiftLockActive = false

-- Interface Principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomObbyGui"
screenGui.ResetOnSpawn = false
-- Usando PlayerGui para evitar problemas de permissão, mas você pode mudar para CoreGui se for exploit.
screenGui.Parent = player:WaitForChild("PlayerGui") 

-------------------------------------------------------------------
-- 1. CROSSHAIR ESTILO GRANNY (PONTINHO NO MEIO)
-------------------------------------------------------------------
local crosshair = Instance.new("Frame")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.new(0, 5, 0, 5) -- Pontinho pequeno
crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
crosshair.BorderSizePixel = 0
crosshair.Parent = screenGui

local chCorner = Instance.new("UICorner")
chCorner.CornerRadius = UDim.new(1, 0)
chCorner.Parent = crosshair

-- Borda preta fina para dar contraste
local chStroke = Instance.new("UIStroke")
chStroke.Color = Color3.fromRGB(0, 0, 0)
chStroke.Thickness = 1
chStroke.Parent = crosshair

-------------------------------------------------------------------
-- 2. BOTÃO DE CORRER (REPOSICIONADO)
-------------------------------------------------------------------
local sprintButton = Instance.new("ImageButton")
sprintButton.Name = "SprintButton"
sprintButton.Size = UDim2.new(0, 50, 0, 50)
sprintButton.AnchorPoint = Vector2.new(1, 1)
sprintButton.Position = UDim2.new(0.83, 0, 0.83, 0) 
sprintButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
sprintButton.BackgroundTransparency = 0.4
sprintButton.Image = "rbxassetid://12809185125"
sprintButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
sprintButton.Parent = screenGui

local cornerSprint = Instance.new("UICorner")
cornerSprint.CornerRadius = UDim.new(1, 0)
cornerSprint.Parent = sprintButton

local strokeSprint = Instance.new("UIStroke")
strokeSprint.Color = Color3.fromRGB(255, 0, 0)
strokeSprint.Thickness = 2
strokeSprint.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
strokeSprint.Parent = sprintButton

-------------------------------------------------------------------
-- 3. BOTÃO DE SHIFTLOCK (CADEADO)
-------------------------------------------------------------------
local lockButton = Instance.new("ImageButton")
lockButton.Name = "ShiftLockButton"
lockButton.Size = UDim2.new(0, 40, 0, 40) -- Botão pequeno
lockButton.AnchorPoint = Vector2.new(1, 1)
lockButton.Position = UDim2.new(0.75, 0, 0.83, 0) -- Fica ao lado do botão de correr
lockButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
lockButton.BackgroundTransparency = 0.4
-- Ícone de cadeado aberto (Padrão)
lockButton.Image = "rbxassetid://5404113115" 
lockButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
lockButton.Parent = screenGui

local cornerLock = Instance.new("UICorner")
cornerLock.CornerRadius = UDim.new(1, 0)
cornerLock.Parent = lockButton

local strokeLock = Instance.new("UIStroke")
strokeLock.Color = Color3.fromRGB(255, 255, 255)
strokeLock.Thickness = 2
strokeLock.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
strokeLock.Parent = lockButton

-------------------------------------------------------------------
-- LÓGICA DO SHIFTLOCK REAL (MOBILE E PC)
-------------------------------------------------------------------
local function setShiftLock(active)
    shiftLockActive = active
    
    if active then
        lockButton.Image = "rbxassetid://5404113426" -- Cadeado Trancado
        lockButton.ImageColor3 = Color3.fromRGB(255, 0, 0)
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    else
        lockButton.Image = "rbxassetid://5404113115" -- Cadeado Aberto
        lockButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end

lockButton.MouseButton1Click:Connect(function()
    setShiftLock(not shiftLockActive)
end)

-- Tecla Shift no PC ativa o ShiftLock (Estilo Obby clássico)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        setShiftLock(not shiftLockActive)
    end
end)

-------------------------------------------------------------------
-- HEARTBEAT: FOV 120 SEM PISCAR, VELOCIDADE E SHIFTLOCK OFFSET
-------------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    
    if humanoid and hrp then
        -- 1. Forçar FOV 120 Contínuo
        camera.FieldOfView = TARGET_FOV
        
        -- 2. Lógica de Velocidade (Multiplicador do jogo do Dex)
        -- Captura a velocidade atual que o jogo quer dar ao player
        local baseSpeed = humanoid:GetAttribute("BaseSpeed") or 16 -- Fallback caso o jogo não defina
        
        if isSprinting then
            humanoid.WalkSpeed = 40 -- Sua exigência de mudar a velocidade para 40
        else
            humanoid.WalkSpeed = baseSpeed -- Volta para o padrão do jogo
        end

        -- 3. Lógica do Shiftlock Real com Trava de Câmera
        if shiftLockActive then
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            
            -- Faz o personagem olhar para onde a câmera aponta
            local lookVector = camera.CFrame.LookVector
            local targetRotation = math.atan2(-lookVector.X, -lookVector.Z)
            hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, targetRotation, 0)
            
            -- OFFSET ESTILO OBBY: Câmera vai para a DIREITA e Player vai para a ESQUERDA
            -- Movendo o foco da câmera ligeiramente para a direita
            camera.CFrame = camera.CFrame * CFrame.new(1.5, 0.5, 0) 
        end
    end
end)

-------------------------------------------------------------------
-- CONTROLE DO BOTÃO DE CORRER
-------------------------------------------------------------------
local function toggleSprint(active)
    isSprinting = active
    local targetStrokeColor = active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    
    TweenService:Create(strokeSprint, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Color = targetStrokeColor}):Play()
    TweenService:Create(sprintButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {BackgroundTransparency = active and 0.2 or 0.4}):Play()
end

sprintButton.MouseButton1Click:Connect(function()
    toggleSprint(not isSprinting)
end)
