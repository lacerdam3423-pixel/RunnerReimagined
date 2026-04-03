-- Mayura Engine: Mobile Obby Shiftlock & Sprint
-- Criado por MigMax ;]
-- Super otimizado, sem lag e sem bugs.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Aguarda o personagem carregar
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
end)

-- Criação da GUI Principal (CoreGui falsa para evitar cliques acidentais)
local sg = Instance.new("ScreenGui")
sg.Name = "Mayura_ObbyEngine"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
-- Tenta colocar no CoreGui, se não conseguir vai para o PlayerGui
local success, err = pcall(function()
	sg.Parent = game:GetService("CoreGui")
end)
if not success then sg.Parent = player:WaitForChild("PlayerGui") end

---------------------------------------------------------
-- 1. CROSSHAIR DA GRANNY (No centro da tela)
---------------------------------------------------------
local crosshair = Instance.new("ImageLabel")
crosshair.Name = "GrannyCrosshair"
crosshair.BackgroundTransparency = 1
crosshair.Position = UDim2.new(0.5, -10, 0.5, -10) -- Perfeitamente centralizado
crosshair.Size = UDim2.new(0, 20, 0, 20) -- Tamanho pequeno
crosshair.Image = "rbxassetid://6341257965" -- ID clássico do ponto da Granny
crosshair.ImageColor3 = Color3.fromRGB(255, 255, 255)
crosshair.Visible = false
crosshair.Parent = sg

---------------------------------------------------------
-- CONTÊINER DOS BOTÕES (Canto direito superior, pequenos)
---------------------------------------------------------
local buttonContainer = Instance.new("Frame")
buttonContainer.Name = "ControlContainer"
buttonContainer.BackgroundTransparency = 1
buttonContainer.Position = UDim2.new(1, -120, 0, 40) -- Canto superior direito
buttonContainer.Size = UDim2.new(0, 100, 0, 100)
buttonContainer.Parent = sg

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Padding = UDim.new(0, 5)
layout.Parent = buttonContainer

local function createMiniButton(name, text, color)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0, 70, 0, 30) -- Pequeno
	btn.BackgroundColor3 = color
	btn.BackgroundTransparency = 0.3
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.AutoButtonColor = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = 0.5
	stroke.Parent = btn

	return btn
end

---------------------------------------------------------
-- 2. SISTEMA DE SHIFTLOCK (Obby Estilo)
---------------------------------------------------------
local lockBtn = createMiniButton("ShiftlockBtn", "LOCK: OFF", Color3.fromRGB(200, 50, 50))
lockBtn.Parent = buttonContainer

local isLocked = false
local defaultFov = 70
local shiftlockFov = 111 -- Seu FOV desejado

local function toggleShiftlock()
	isLocked = not isLocked
	crosshair.Visible = isLocked
	
	if isLocked then
		lockBtn.Text = "LOCK: ON"
		lockBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		camera.FieldOfView = shiftlockFov
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	else
		lockBtn.Text = "LOCK: OFF"
		lockBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		camera.FieldOfView = defaultFov
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end

lockBtn.MouseButton1Click:Connect(toggleShiftlock)

-- Heartbeat ultra rápido e sem piscar para travar a câmera e o corpo
RunService.Heartbeat:Connect(function()
	if isLocked and character and humanoid and humanoid.Health > 0 then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			-- Faz o personagem olhar para onde a câmera aponta (Shiftlock real)
			local lookAt = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
			if lookAt.Magnitude > 0 then
				hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + lookAt)
			end
			-- Garante que o mouse continue preso para não bugar
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		end
	end
end)

---------------------------------------------------------
-- 3. SISTEMA DE SPRINT (Dead Rails Style - Sem Stamina)
---------------------------------------------------------
local sprintBtn = createMiniButton("SprintBtn", "WALK", Color3.fromRGB(100, 100, 100))
sprintBtn.Parent = buttonContainer

local isSprinting = false
local normalSpeed = 16
local sprintSpeed = 40

local function toggleSprint()
	isSprinting = not isSprinting
	if humanoid then
		if isSprinting then
			humanoid.WalkSpeed = sprintSpeed
			sprintBtn.Text = "RUNNING"
			sprintBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
		else
			humanoid.WalkSpeed = normalSpeed
			sprintBtn.Text = "WALK"
			sprintBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		end
	end
end

sprintBtn.MouseButton1Click:Connect(toggleSprint)

-- Reseta velocidade ao morrer para evitar bugs
player.CharacterAdded:Connect(function()
	isSprinting = false
	sprintBtn.Text = "WALK"
	sprintBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	if isLocked then toggleShiftlock() end -- Reseta o lock ao morrer
end)
