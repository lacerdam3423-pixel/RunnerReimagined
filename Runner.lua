-- Serviços do Roblox
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Variáveis do Jogador
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Configurações do Sprint
local VELOCIDADE_SPRINT = 40
local TECLA_SPRINT = Enum.KeyCode.LeftShift

-- Configuração do Tween para uma transição suave de câmera (Field of View)
local camera = workspace.CurrentCamera
local fovSprint = 85
local tempoTransicao = 0.3

local function alterarFOV(novoFOV)
	local tweenInfo = TweenInfo.new(tempoTransicao, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(camera, tweenInfo, {FieldOfView = novoFOV})
	tween:Play()
end

-- Função que ativa o Sprint
local function iniciarSprint(input, processed)
	-- O "processed" evita que o boneco corra enquanto você digita no chat
	if processed then return end
	
	if input.KeyCode == TECLA_SPRINT then
		humanoid.WalkSpeed = VELOCIDADE_SPRINT
		alterarFOV(fovSprint)
	end
end

-- Função que desativa o Sprint
local function pararSprint(input, processed)
	if input.KeyCode == TECLA_SPRINT then
		humanoid.WalkSpeed = VELOCIDADE_PADRAO
		alterarFOV(fovPadrao)
	end
end

-- Conectando os eventos de teclado/controle
UserInputService.InputBegan:Connect(iniciarSprint)
UserInputService.InputEnded:Connect(pararSprint)

-- Garante que o script continue funcionando se o personagem morrer e renascer
player.CharacterAdded:Connect(function(novoCharacter)
	character = novoCharacter
	humanoid = novoCharacter:WaitForChild("Humanoid")
end)
