-- Garante que o script rode apenas no cliente (LocalScript)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera

-- ==========================================
-- 1. CRIAÇÃO DA INTERFACE (CORE GUI STYLE)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
-- Tenta colocar no CoreGui se o executor permitir, senão vai para PlayerGui
local success, err = pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not success then
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
end
ScreenGui.Name = "Mayura_ObbyCore"
ScreenGui.ResetOnSpawn = false

-- Mira da Granny (Crosshair)
local Crosshair = Instance.new("ImageLabel")
Crosshair.Name = "GrannyCrosshair"
Crosshair.Parent = ScreenGui
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
Crosshair.Size = UDim2.new(0, 32, 0, 32) -- Tamanho ideal para a mira
Crosshair.BackgroundTransparency = 1
-- Usando uma textura padrão que lembra a mira clássica de jogos de terror
Crosshair.Image = "rbxassetid://138075303" 
Crosshair.ImageColor3 = Color3.fromRGB(255, 255, 255)

-- Botão de Sprint (Estilo Dead Rails)
local SprintButton = Instance.new("TextButton")
SprintButton.Name = "SprintButton"
SprintButton.Parent = ScreenGui
SprintButton.Position = UDim2.new(0.85, 0, 0.7, 0)
SprintButton.Size = UDim2.new(0, 65, 0, 65)
SprintButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SprintButton.BackgroundTransparency = 0.3
SprintButton.Text = "RUN"
SprintButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SprintButton.Font = Enum.Font.GothamBold
SprintButton.TextSize = 18

-- Arredondando o botão
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = SprintButton

-- ==========================================
-- 2. CONFIGURAÇÕES E FUNÇÕES
-- ==========================================
local FOV_ALVO = 111
local VELOCIDADE_NORMAL = 16
local VELOCIDADE_SPRINT = 40

local shiftLockAtivo = false
local correndo = false

-- Forçar o FOV para 111 sem oscilar (usando RenderStepped para estabilidade)
RunService.RenderStepped:Connect(function()
    camera.FieldOfView = FOV_ALVO
end)

-- Função do Shift Lock para Obby
local function alternarShiftLock()
    shiftLockAtivo = not shiftLockAtivo
    
    if shiftLockAtivo then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        -- Faz o personagem virar para onde a câmera aponta
        humanoid.AutoRotate = false
        
        RunService:BindToRenderStep("ShiftLockRef", Enum.RenderPriority.Character.Value, function()
            if character and humanoid then
                local cameraCFrame = camera.CFrame
                local lookVector = cameraCFrame.LookVector
                local targetCFrame = CFrame.new(character.PrimaryPart.Position, character.PrimaryPart.Position + Vector2.new(lookVector.X, 0, lookVector.Z))
                character:SetPrimaryPartCFrame(targetCFrame)
            end
        end)
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        humanoid.AutoRotate = true
        RunService:UnbindFromRenderStep("ShiftLockRef")
    end
end

-- Ativa o ShiftLock ao clicar na mira (comum em jogos Mobile de Obby)
Crosshair.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        alternarShiftLock()
    end
end)

-- Função de Sprint (Sem Stamina)
local function alternarCorrida()
    correndo = not correndo
    
    if correndo then
        humanoid.WalkSpeed = VELOCIDADE_SPRINT
        SprintButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40) -- Fica vermelho ao correr
        SprintButton.Text = "FAST"
    else
        humanoid.WalkSpeed = VELOCIDADE_NORMAL
        SprintButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        SprintButton.Text = "RUN"
    end
end

SprintButton.MouseButton1Click:Connect(alternarCorrida)

-- Atualiza as variáveis quando o jogador morre e renasce
player.CharacterAdded:Connect(function(novoCharacter)
    character = novoCharacter
    humanoid = novoCharacter:WaitForChild("Humanoid")
    
    -- Mantém as configurações mesmo após resetar
    humanoid.WalkSpeed = correndo and VELOCIDADE_SPRINT or VELOCIDADE_NORMAL
    if shiftLockAtivo then
        humanoid.AutoRotate = false
    end
end)
