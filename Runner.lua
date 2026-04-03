local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local isSprinting = false
local isShiftLocked = false

-- Valores fixados conforme pedido
local SPRINT_SPEED = 40
local SPRINT_FOV = 120

-- GUI Principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomMovementAndCombatGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui 

---------------------------------------------------------
-- 1. CROSSHAIR (Estilo Granny - Pontinho no meio)
---------------------------------------------------------
local crosshair = Instance.new("Frame")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.new(0, 5, 0, 5)
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

---------------------------------------------------------
-- 2. BOTÃO DE SPRINT
---------------------------------------------------------
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

---------------------------------------------------------
-- 3. BOTÃO DE SHIFTLOCK (Cadeado pequeno)
---------------------------------------------------------
local lockButton = Instance.new("ImageButton")
lockButton.Name = "LockButton"
lockButton.Size = UDim2.new(0, 35, 0, 35)
lockButton.AnchorPoint = Vector2.new(1, 1)
-- Posicionado um pouco acima e para a esquerda do botão de sprint
lockButton.Position = UDim2.new(0.77, 0, 0.83, 0) 
lockButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
lockButton.BackgroundTransparency = 0.4
lockButton.Image = "rbxassetid://5434251214" -- Ícone de cadeado
lockButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
lockButton.Parent = screenGui

local lockCorner = Instance.new("UICorner")
lockCorner.CornerRadius = UDim.new(1, 0)
lockCorner.Parent = lockButton

local lockStroke = Instance.new("UIStroke")
lockStroke.Color = Color3.fromRGB(255, 255, 255)
lockStroke.Thickness = 1.5
lockStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
lockStroke.Parent = lockButton

---------------------------------------------------------
-- LÓGICA DE CORRER E FOV (Sem Piscar / Heartbeat)
---------------------------------------------------------

-- Função para detectar a velocidade base do jogo dinamicamente (Dex)
local function getNormalSpeed()
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			-- Se não estiver correndo, lê a velocidade atual definida pelo jogo
			return humanoid.WalkSpeed
		end
	end
	return 16 -- Valor padrão caso não encontre
end

local function applySprint(active)
	isSprinting = active

	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	local targetStrokeColor = active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

	if active then
		humanoid.WalkSpeed = SPRINT_SPEED
	else
		-- Quando desliga, ele volta para a velocidade padrão que o jogo setou no Dex
		humanoid.WalkSpeed = getNormalSpeed()
	end

	TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Color = targetStrokeColor}):Play()
	TweenService:Create(mainButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {BackgroundTransparency = active and 0.2 or 0.4}):Play()
end

-- LOOP HEARTBEAT PARA O FOV (Força os 120 cravados sem tremer)
RunService.RenderStepped:Connect(function()
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	if isSprinting then
		-- Força o FOV em 120 e garante a velocidade em 40
		camera.FieldOfView = SPRINT_FOV
		humanoid.WalkSpeed = SPRINT_SPEED
	else
		-- Se não estiver correndo, permite que o FOV volte ao normal suavemente se alterado
		if math.abs(camera.FieldOfView - 70) > 0.5 then
			camera.FieldOfView = math.lerp(camera.FieldOfView, 70, 0.1)
		end
	end
end)

-- Controles de clique e toque do botão de Sprint
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

---------------------------------------------------------
-- LÓGICA DE SHIFT LOCK REAL (Câmera para a direita)
---------------------------------------------------------
local function setShiftLock(active)
	isShiftLocked = active
	
	if active then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		lockStroke.Color = Color3.fromRGB(0, 255, 0)
		-- Desloca a câmera levemente para a direita (Estilo Obby/Ombro)
		camera.SocketOffset = Vector3.new(1.75, 0, 0) 
	else
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		lockStroke.Color = Color3.fromRGB(255, 255, 255)
		camera.SocketOffset = Vector3.new(0, 0, 0)
	end
end

-- Alterna o ShiftLock no clique
lockButton.MouseButton1Down:Connect(function()
	setShiftLock(not isShiftLocked)
end)

-- Shift Lock por Teclado no PC (Control ou Alt como é comum em Obby)
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
		setShiftLock(not isShiftLocked)
	end
end)

-- Mantém o mouse preso no centro se o ShiftLock estiver ativo
RunService.RenderStepped:Connect(function()
	if isShiftLocked then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		
		-- Faz o personagem virar para onde a câmera está apontando
		local character = player.Character
		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart then
				local lookVector = camera.CFrame.LookVector
				humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
			end
		end
	end
end)
