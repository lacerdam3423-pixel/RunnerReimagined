--[[
    Criado por: MigMax ;]
    Tema: Mayura Engine / Obby Utility
    Foco: Mobile Otimizado (Sem Lag / Sem Bugs)
--]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ==========================================
-- CONFIGURAÇÕES EDITÁVEIS
-- ==========================================
local CONFIG = {
    SprintSpeed = 40,
    NormalSpeed = 16,
    CustomFOV = 111,
    DefaultFOV = 70,
    ShiftlockOffset = Vector3.new(1.7, 0, 0), -- Quão para a direita a câmera fica
}

-- ==========================================
-- CRIAÇÃO DA INTERFACE (CoreGui Seguro)
-- ==========================================
local sg = Instance.new("ScreenGui")
sg.Name = "Mayura_ObbyEngine"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Tentativa de colocar no CoreGui (se o executor permitir), senão vai para PlayerGui
local success, err = pcall(function()
    sg.Parent = game:GetService("CoreGui")
end)
if not success then
    sg.Parent = player:WaitForChild("PlayerGui")
end

-- Container no canto direito (Segura os botões)
local container = Instance.new("Frame")
container.Name = "RightContainer"
container.Size = UDim2.new(0, 70, 0, 150)
container.Position = UDim2.new(1, -80, 0.5, -75) -- Centro-direita da tela
container.BackgroundTransparency = 1
container.Parent = sg

-- Botão de Shiftlock (Estilo Obby Tradicional)
local shiftBtn = Instance.new("TextButton")
shiftBtn.Name = "ShiftlockBtn"
shiftBtn.Size = UDim2.new(0, 50, 0, 50)
shiftBtn.Position = UDim2.new(0.5, -25, 0, 10)
shiftBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
shiftBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
shiftBtn.Font = Enum.Font.SourceSansBold
shiftBtn.TextSize = 14
shiftBtn.Text = "SHIFT\nOFF"
shiftBtn.Parent = container

local shiftUICorner = Instance.new("UICorner")
shiftUICorner.CornerRadius = UDim.new(0, 12)
shiftUICorner.Parent = shiftBtn

-- Botão de Correr (Sprint Dead Rails sem Stamina)
local sprintBtn = Instance.new("TextButton")
sprintBtn.Name = "SprintBtn"
sprintBtn.Size = UDim2.new(0, 50, 0, 50)
sprintBtn.Position = UDim2.new(0.5, -25, 0, 70)
sprintBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
sprintBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sprintBtn.Font = Enum.Font.SourceSansBold
sprintBtn.TextSize = 14
sprintBtn.Text = "RUN"
sprintBtn.Parent = container

local sprintUICorner = Instance.new("UICorner")
sprintUICorner.CornerRadius = UDim.new(1, 0) -- Botão redondo
sprintUICorner.Parent = sprintBtn

-- Mira da Granny (Crosshair no centro)
local crosshair = Instance.new("ImageLabel")
crosshair.Name = "GrannyCrosshair"
crosshair.Size = UDim2.new(0, 12, 0, 12)
crosshair.Position = UDim2.new(0.5, -6, 0.5, -6)
crosshair.BackgroundTransparency = 1
crosshair.Image = "rbxassetid://625400912" -- ID clássico de mira circular (Estilo Granny)
crosshair.ImageColor3 = Color3.fromRGB(255, 255, 255)
crosshair.Visible = false -- Só aparece no Shiftlock
crosshair.Parent = sg

-- ==========================================
-- SISTEMAS E LÓGICA
-- ==========================================

local isShiftlock = false
local isSprinting = false

-- Função do Shiftlock Real
local function updateShiftlock()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChildOfClass("Humanoid") then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if isShiftlock then
            -- Força o personagem a olhar para onde a câmera aponta
            humanoid.AutoRotate = false
            local lookVector = camera.CFrame.LookVector
            local targetCFrame = CFrame.new(character.HumanoidRootPart.Position, character.HumanoidRootPart.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
            character.HumanoidRootPart.CFrame = targetCFrame
            
            -- Desvia a câmera levemente para o lado
            camera.CFrame = camera.CFrame * CFrame.new(CONFIG.ShiftlockOffset)
            
            -- Mantém o FOV ativo no Shiftlock
            camera.FieldOfView = CONFIG.CustomFOV
        else
            humanoid.AutoRotate = true
        end
    end
end

-- Alternador do Shiftlock
shiftBtn.MouseButton1Click:Connect(function()
    isShiftlock = not isShiftlock
    if isShiftlock then
        shiftBtn.Text = "SHIFT\nON"
        shiftBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0) -- Verde
        crosshair.Visible = true
    else
        shiftBtn.Text = "SHIFT\nOFF"
        shiftBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- Cinza
        crosshair.Visible = false
        camera.FieldOfView = CONFIG.DefaultFOV
    end
end)

-- Alternador do Sprint (Estilo Dead Rails)
sprintBtn.MouseButton1Click:Connect(function()
    local character = player.Character
    if character and character:FindFirstChildOfClass("Humanoid") then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        isSprinting = not isSprinting
        
        if isSprinting then
            humanoid.WalkSpeed = CONFIG.SprintSpeed
            sprintBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Verde correndo
        else
            humanoid.WalkSpeed = CONFIG.NormalSpeed
            sprintBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Vermelho normal
        end
    end
end)

-- Loop Heartbeat (Garante 0 flickers e atualização perfeita)
RunService.Heartbeat:Connect(function()
    if isShiftlock then
        updateShiftlock()
    end
end)

-- Resetador de estado ao morrer
player.CharacterAdded:Connect(function(character)
    isShiftlock = false
    isSprinting = false
    shiftBtn.Text = "SHIFT\nOFF"
    shiftBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    crosshair.Visible = false
    sprintBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.WalkSpeed = CONFIG.NormalSpeed
    end
    camera.FieldOfView = CONFIG.DefaultFOV
end)
