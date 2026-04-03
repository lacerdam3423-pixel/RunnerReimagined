-- SERVIÇOS DO ROBLOX
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- CONFIGURAÇÕES EDITÁVEIS (Mude como quiser!)
local WALK_SPEED = 16
local SPRINT_SPEED = 40
local NORMAL_FOV = 70
local SPRINT_FOV = 111
local SHIFTLOCK_OFFSET = Vector3.new(1.7, 0, 0) -- Um pouco para a esquerda, sem ser longe

-- Estado das variáveis
local isSprinting = false
local shiftLockEnabled = false

-----------------------------------------
-- 1. CRIAÇÃO DA INTERFACE (GUI)
-----------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ObbyProSystem"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Mira da Granny (Crosshair)
local crosshair = Instance.new("ImageLabel")
crosshair.Name = "GrannyCrosshair"
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshair.Size = UDim2.new(0, 15, 0, 15) -- Tamanho pequeno clássico
crosshair.BackgroundTransparency = 1
crosshair.Image = "rbxassetid://526436814" -- ID clássico de ponto/mira (pode trocar se preferir)
crosshair.Visible = false
crosshair.Parent = screenGui

-- Botão de Sprint (Estilo Dead Rails)
local sprintBtn = Instance.new("TextButton")
sprintBtn.Name = "SprintButton"
sprintBtn.Size = UDim2.new(0, 100, 0, 50)
sprintBtn.Position = UDim2.new(1, -120, 1, -120) -- Canto inferior direito
sprintBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
sprintBtn.BackgroundTransparency = 0.3
sprintBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sprintBtn.Font = Enum.Font.GothamBold
sprintBtn.TextSize = 18
sprintBtn.Text = "CORRER"
sprintBtn.Parent = screenGui

-- Arredondar botão
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = sprintBtn

-- Botão de Shiftlock (Estilo Obby Tradicional)
local shiftlockBtn = Instance.new("ImageButton")
shiftlockBtn.Name = "ShiftLockButton"
shiftlockBtn.Size = UDim2.new(0, 50, 0, 50)
shiftlockBtn.Position = UDim2.new(1, -120, 1, -180) -- Acima do botão de correr
shiftlockBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
shiftlockBtn.BackgroundTransparency = 0.3
shiftlockBtn.Image = "rbxassetid://11419713319" -- Ícone de trava clássico
shiftlockBtn.Parent = screenGui

local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(0, 8)
uiCorner2.Parent = shiftlockBtn

-----------------------------------------
-- 2. SISTEMA DE SPRINT (Dead Rails Style)
-----------------------------------------
local function updateSprint(enable)
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local camera = workspace.CurrentCamera
	
	if not humanoid or not camera then return end
	
	isSprinting = enable
	
	-- Efeitos de Transição (Smooth/Sem piscar)
	local targetSpeed = enable and SPRINT_SPEED or WALK_SPEED
	local targetFOV = enable and SPRINT_FOV or NORMAL_FOV
	
	humanoid.WalkSpeed = targetSpeed
	
	TweenService:Create(camera, TweenInfo.new(0.3), {FieldOfView = targetFOV}):Play()
	
	-- Feedback visual no botão
	TweenService:Create(sprintBtn, TweenInfo.new(0.2), {
		BackgroundColor3 = enable and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(30, 30, 30)
	}):Play()
end

-- Ativação por clique/toque
sprintBtn.MouseButton1Click:Connect(function()
	updateSprint(not isSprinting)
end)

-- Ativação pelo teclado (Shift Esquerdo)
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.LeftShift then
		updateSprint(true)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		updateSprint(false)
	end
end)

-----------------------------------------
-- 3. SISTEMA DE SHIFTLOCK REAL
-----------------------------------------
local function setShiftLock(enable)
	shiftLockEnabled = enable
	crosshair.Visible = enable
	
	-- Feedback visual no botão de Shiftlock
	TweenService:Create(shiftlockBtn, TweenInfo.new(0.2), {
		BackgroundColor3 = enable and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(30, 30, 30)
	}):Play()
	
	if enable then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	else
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end

-- Clique no botão de Shiftlock
shiftlockBtn.MouseButton1Click:Connect(function()
	setShiftLock(not shiftLockEnabled)
end)

-- Tecla 'Control' ou 'Shift' trava (Opcional, mude se quiser)
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.LeftControl then
		setShiftLock(not shiftLockEnabled)
	end
end)

-- LOOP PRINCIPAL (RenderStepped - Super liso, sem travar nem piscar)
RunService.RenderStepped:Connect(function()
	local character = player.Character
	if character and shiftLockEnabled then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local hrp = character:FindFirstChild("HumanoidRootPart")
		local camera = workspace.CurrentCamera
		
		if humanoid and hrp and camera then
			-- Trava o mouse no centro
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			
			-- Faz o personagem olhar para onde a câmera aponta
			local lookAt = camera.CFrame.LookVector
			hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(lookAt.X, 0, lookAt.Z))
			
			-- Aplica o Offset da câmera para a esquerda (Estilo Obby clássico)
			camera.CFrame = camera.CFrame * CFrame.new(SHIFTLOCK_OFFSET)
			humanoid.CameraOffset = SHIFTLOCK_OFFSET
		end
	else
		-- Reseta o offset quando desligado
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.CameraOffset = Vector3.new(0, 0, 0)
			end
		end
	end
end)
