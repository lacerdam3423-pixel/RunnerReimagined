-- SERVIÇOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- CONFIGURAÇÕES TOTALMENTE EDITÁVEIS
local CONFIG = {
	NormalSpeed = 16,
	SprintSpeed = 40,
	NormalFOV = 70,
	SprintFOV = 111,
	ShiftLockOffset = Vector3.new(1.75, 2, 10), -- Posição da câmera no Shiftlock
}

-- CRIAÇÃO DA GUI (Substituindo CoreGui por PlayerGui para funcionar)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ObbyProSystem"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

---------------------------------------------------------
-- 1. CROSSHAIR DA GRANNY (Mira no centro da tela)
---------------------------------------------------------
local crosshair = Instance.new("ImageLabel")
crosshair.Name = "GrannyCrosshair"
crosshair.Size = UDim2.new(0, 30, 0, 30)
crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.BackgroundTransparency = 1
-- Usando uma textura circular/mira clássica estilo Granny
crosshair.Image = "rbxassetid://13110515152" 
crosshair.ImageColor3 = Color3.fromRGB(255, 0, 0) -- Vermelho clássico
crosshair.Parent = screenGui

---------------------------------------------------------
-- 2. BOTÃO DE SPRINT (Estilo Dead Rails - Sem Stamina)
---------------------------------------------------------
local sprintBtn = Instance.new("TextButton")
sprintBtn.Name = "SprintButton"
sprintBtn.Size = UDim2.new(0, 120, 0, 50)
sprintBtn.Position = UDim2.new(1, -150, 1, -150)
sprintBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
sprintBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sprintBtn.Text = "SPRINT"
sprintBtn.Font = Enum.Font.GothamBold
sprintBtn.TextSize = 18
sprintBtn.Parent = screenGui

local cornerSprint = Instance.new("UICorner")
cornerSprint.CornerRadius = UDim.new(0, 8)
cornerSprint.Parent = sprintBtn

local strokeSprint = Instance.new("UIStroke")
strokeSprint.Color = Color3.fromRGB(255, 0, 0)
strokeSprint.Thickness = 2
strokeSprint.Parent = sprintBtn

---------------------------------------------------------
-- 3. BOTÃO DE SHIFTLOCK (Estilo Obby Tradicional)
---------------------------------------------------------
local shiftLockBtn = Instance.new("TextButton")
shiftLockBtn.Name = "ShiftLockButton"
shiftLockBtn.Size = UDim2.new(0, 60, 0, 60)
shiftLockBtn.Position = UDim2.new(1, -80, 1, -230)
shiftLockBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
shiftLockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
shiftLockBtn.Text = "🔒"
shiftLockBtn.Font = Enum.Font.GothamBold
shiftLockBtn.TextSize = 25
shiftLockBtn.Parent = screenGui

local cornerSL = Instance.new("UICorner")
cornerSL.CornerRadius = UDim.new(1, 0) -- Redondo estilo clássico
cornerSL.Parent = shiftLockBtn

---------------------------------------------------------
-- LÓGICA DO SPRINT & FOV
---------------------------------------------------------
local isSprinting = false

local function setSprint(state)
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	
	isSprinting = state
	
	-- Efeitos visuais e velocidade
	local targetSpeed = state and CONFIG.SprintSpeed or CONFIG.NormalSpeed
	local targetFOV = state and CONFIG.SprintFOV or CONFIG.NormalFOV
	
	humanoid.WalkSpeed = targetSpeed
	
	-- Transição suave de FOV sem travar e sem piscar
	TweenService:Create(camera, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {FieldOfView = targetFOV}):Play()
	
	-- Feedback visual no botão
	TweenService:Create(sprintBtn, TweenInfo.new(0.2), {
		BackgroundColor3 = state and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(30, 30, 30)
	}):Play()
end

sprintBtn.MouseButton1Click:Connect(function()
	setSprint(not isSprinting)
end)

---------------------------------------------------------
-- LÓGICA DO SHIFTLOCK REAL (Ultra sem lag / sem piscar)
---------------------------------------------------------
local shiftLockEnabled = false

local function setShiftLock(state)
	shiftLockEnabled = state
	
	if shiftLockEnabled then
		shiftLockBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	else
		shiftLockBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end

shiftLockBtn.MouseButton1Click:Connect(function()
	setShiftLock(not shiftLockEnabled)
end)

-- Sistema de Heartbeat (RenderStepped) para manter o Shiftlock ativo e liso
RunService.RenderStepped:Connect(function()
	local character = player.Character
	if character and shiftLockEnabled then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		
		if humanoidRootPart and humanoid and humanoid.Health > 0 then
			-- Trava o mouse no centro
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			
			-- Faz o personagem rodar com a câmera (Shiftlock Real)
			local lookVector = camera.CFrame.LookVector
			local targetCFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
			humanoidRootPart.CFrame = targetCFrame
			
			-- Ajusta o foco da câmera para o ombro (Estilo Shiftlock Oficial)
			humanoid.CameraOffset = humanoid.CameraOffset:Lerp(CONFIG.ShiftLockOffset, 0.2)
		end
	else
		-- Volta a câmera ao normal quando desligado
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.CameraOffset = humanoid.CameraOffset:Lerp(Vector3.new(0,0,0), 0.2)
			end
		end
	end
end)

-- Suporte para teclado (Shift para Shiftlock / Ctrl para Sprint)
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	
	if input.KeyCode == Enum.KeyCode.LeftShift then
		setShiftLock(not shiftLockEnabled)
	elseif input.KeyCode == Enum.KeyCode.LeftControl then
		setSprint(not isSprinting)
	end
end)

-- Garante que resete ao morrer para não bugar
player.CharacterAdded:Connect(function()
	setShiftLock(false)
	setSprint(false)
end)
