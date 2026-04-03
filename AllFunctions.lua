-- ============================================================
--   TAF Shiftlock - Full HUD (CoreGui, Draggable, Minimizable)
--   Features: ShiftLock | RunSpeed 40 | FOV 111 | BringPlayer
--             SavePos | TeleportPos | SaveJSON | Execute Code
-- ============================================================

local CoreGui          = game:GetService("CoreGui")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local TweenService     = game:GetService("TweenService")

local Player    = Players.LocalPlayer
local Camera    = workspace.CurrentCamera

-- ============================================================
-- ESTADOS / CONSTANTES
-- ============================================================
local States = {
    Off = "rbxasset://textures/ui/mouseLock_off@2x.png",
    On  = "rbxasset://textures/ui/mouseLock_on@2x.png",
}
local MaxLength      = 900000
local EnabledOffset  = CFrame.new(1.7, 0, 0)
local DisabledOffset = CFrame.new(-1.7, 0, 0)

local shiftActive    = false
local shiftConn      = nil
local runActive      = false
local bringActive    = false
local bringConn      = nil
local savedPosition  = nil
local minimized      = false

-- ============================================================
-- FOV PERMANENTE 111
-- ============================================================
Camera.FieldOfView = 111
RunService.RenderStepped:Connect(function()
    Camera.FieldOfView = 111
end)

-- ============================================================
-- GUI PRINCIPAL
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "TAFX_HUD"
ScreenGui.Parent          = CoreGui
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn    = false
ScreenGui.DisplayOrder    = 999

-- Frame principal
local MainFrame = Instance.new("Frame")
MainFrame.Name              = "MainFrame"
MainFrame.Parent            = ScreenGui
MainFrame.Size              = UDim2.new(0, 230, 0, 320)
MainFrame.Position          = UDim2.new(0.5, -115, 0.5, -160)
MainFrame.BackgroundColor3  = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel   = 0
MainFrame.ClipsDescendants  = true
MainFrame.Active            = true

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 10)
UICornerMain.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color     = Color3.fromRGB(80, 80, 200)
UIStroke.Thickness = 1.5
UIStroke.Parent    = MainFrame

-- Barra de título (drag)
local TitleBar = Instance.new("Frame")
TitleBar.Name             = "TitleBar"
TitleBar.Parent           = MainFrame
TitleBar.Size             = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
TitleBar.BorderSizePixel  = 0
TitleBar.ZIndex           = 2

local UICornerTitle = Instance.new("UICorner")
UICornerTitle.CornerRadius = UDim.new(0, 10)
UICornerTitle.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent            = TitleBar
TitleLabel.Size              = UDim2.new(1, -60, 1, 0)
TitleLabel.Position          = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text              = "⚡ TAFX HUD"
TitleLabel.TextColor3        = Color3.fromRGB(180, 180, 255)
TitleLabel.Font              = Enum.Font.GothamBold
TitleLabel.TextSize          = 13
TitleLabel.TextXAlignment    = Enum.TextXAlignment.Left
TitleLabel.ZIndex            = 3

-- Botão minimizar
local MinBtn = Instance.new("TextButton")
MinBtn.Parent            = TitleBar
MinBtn.Size              = UDim2.new(0, 26, 0, 22)
MinBtn.Position          = UDim2.new(1, -58, 0, 5)
MinBtn.BackgroundColor3  = Color3.fromRGB(50, 50, 80)
MinBtn.Text              = "—"
MinBtn.TextColor3        = Color3.fromRGB(200, 200, 255)
MinBtn.Font              = Enum.Font.GothamBold
MinBtn.TextSize          = 12
MinBtn.BorderSizePixel   = 0
MinBtn.ZIndex            = 4

local UICornerMin = Instance.new("UICorner")
UICornerMin.CornerRadius = UDim.new(0, 5)
UICornerMin.Parent = MinBtn

-- Botão fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent           = TitleBar
CloseBtn.Size             = UDim2.new(0, 26, 0, 22)
CloseBtn.Position         = UDim2.new(1, -28, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
CloseBtn.Text             = "✕"
CloseBtn.TextColor3       = Color3.fromRGB(255, 200, 200)
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.TextSize         = 12
CloseBtn.BorderSizePixel  = 0
CloseBtn.ZIndex           = 4

local UICornerClose = Instance.new("UICorner")
UICornerClose.CornerRadius = UDim.new(0, 5)
UICornerClose.Parent = CloseBtn

-- Container dos botões (visível/oculto ao minimizar)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name              = "ContentFrame"
ContentFrame.Parent            = MainFrame
ContentFrame.Size              = UDim2.new(1, 0, 1, -32)
ContentFrame.Position          = UDim2.new(0, 0, 0, 32)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ClipsDescendants  = true

local UIList = Instance.new("UIListLayout")
UIList.Parent          = ContentFrame
UIList.Padding         = UDim.new(0, 6)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.SortOrder       = Enum.SortOrder.LayoutOrder

local UIPadding = Instance.new("UIPadding")
UIPadding.Parent       = ContentFrame
UIPadding.PaddingTop   = UDim.new(0, 8)
UIPadding.PaddingLeft  = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)

-- ============================================================
-- MIRA (pontinho central)
-- ============================================================
local Crosshair = Instance.new("Frame")
Crosshair.Name              = "TAFX_Crosshair"
Crosshair.Parent            = ScreenGui
Crosshair.Size              = UDim2.new(0, 6, 0, 6)
Crosshair.Position          = UDim2.new(0.5, -3, 0.5, -3)
Crosshair.BackgroundColor3  = Color3.fromRGB(255, 255, 255)
Crosshair.BackgroundTransparency = 0
Crosshair.BorderSizePixel   = 0
Crosshair.Visible           = false
Crosshair.ZIndex            = 10

local UICornerCross = Instance.new("UICorner")
UICornerCross.CornerRadius = UDim.new(1, 0)
UICornerCross.Parent = Crosshair

-- ============================================================
-- BOTÃO SHIFTLOCK (canto superior direito)
-- ============================================================
local ShiftLockButton = Instance.new("ImageButton")
ShiftLockButton.Parent               = ScreenGui
ShiftLockButton.BackgroundTransparency = 1
ShiftLockButton.Position             = UDim2.new(0.92, 0, 0.02, 0)
ShiftLockButton.Size                 = UDim2.new(0.0636147112, 0, 0.0661305636, 0)
ShiftLockButton.SizeConstraint       = Enum.SizeConstraint.RelativeXX
ShiftLockButton.Image                = States.Off
ShiftLockButton.ZIndex               = 10

-- ============================================================
-- HELPER: criar botão padrão
-- ============================================================
local function makeButton(text, color, order)
    local btn = Instance.new("TextButton")
    btn.Parent           = ContentFrame
    btn.Size             = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = color or Color3.fromRGB(35, 35, 60)
    btn.Text             = text
    btn.TextColor3       = Color3.fromRGB(220, 220, 255)
    btn.Font             = Enum.Font.GothamSemibold
    btn.TextSize         = 12
    btn.BorderSizePixel  = 0
    btn.LayoutOrder      = order or 0
    btn.AutoButtonColor  = false

    local uc = Instance.new("UICorner")
    uc.CornerRadius = UDim.new(0, 7)
    uc.Parent = btn

    -- hover
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 110)
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {
            BackgroundColor3 = color or Color3.fromRGB(35, 35, 60)
        }):Play()
    end)

    return btn
end

-- ============================================================
-- BOTÕES DO HUD
-- ============================================================

-- 1) RunSpeed 40
local runBtn = makeButton("🏃 Run Speed  [ OFF ]", Color3.fromRGB(30, 50, 30), 1)

-- 2) Bring Player (10s)
local bringBtn = makeButton("📍 Bring Player  [ OFF ]", Color3.fromRGB(50, 30, 30), 2)

-- 3) Salvar Posição
local savePosBtn = makeButton("💾 Salvar Posição", Color3.fromRGB(35, 35, 60), 3)

-- 4) Teleportar
local tpBtn = makeButton("🚀 Teleportar", Color3.fromRGB(35, 35, 60), 4)

-- 5) Execute Code (abre mini-editor)
local execBtn = makeButton("⚙ Executar Código", Color3.fromRGB(40, 30, 55), 5)

-- 6) Salvar em JSON
local saveJsonBtn = makeButton("📄 Salvar Config JSON", Color3.fromRGB(30, 40, 50), 6)

-- ============================================================
-- MINI EDITOR DE CÓDIGO
-- ============================================================
local EditorFrame = Instance.new("Frame")
EditorFrame.Name              = "EditorFrame"
EditorFrame.Parent            = ScreenGui
EditorFrame.Size              = UDim2.new(0, 300, 0, 200)
EditorFrame.Position          = UDim2.new(0.5, -150, 0.5, -100)
EditorFrame.BackgroundColor3  = Color3.fromRGB(10, 10, 18)
EditorFrame.BorderSizePixel   = 0
EditorFrame.Visible           = false
EditorFrame.ZIndex            = 20
EditorFrame.Active            = true

local UICornerEditor = Instance.new("UICorner")
UICornerEditor.CornerRadius = UDim.new(0, 8)
UICornerEditor.Parent = EditorFrame

local UIStrokeEditor = Instance.new("UIStroke")
UIStrokeEditor.Color     = Color3.fromRGB(80, 80, 200)
UIStrokeEditor.Thickness = 1.2
UIStrokeEditor.Parent    = EditorFrame

local EditorTitle = Instance.new("TextLabel")
EditorTitle.Parent            = EditorFrame
EditorTitle.Size              = UDim2.new(1, 0, 0, 26)
EditorTitle.BackgroundColor3  = Color3.fromRGB(20, 20, 40)
EditorTitle.Text              = "  ⚙ Execute Código"
EditorTitle.TextColor3        = Color3.fromRGB(180, 180, 255)
EditorTitle.Font              = Enum.Font.GothamBold
EditorTitle.TextSize          = 12
EditorTitle.TextXAlignment    = Enum.TextXAlignment.Left
EditorTitle.BorderSizePixel   = 0
EditorTitle.ZIndex            = 21

local UICornerEditorTitle = Instance.new("UICorner")
UICornerEditorTitle.CornerRadius = UDim.new(0, 8)
UICornerEditorTitle.Parent = EditorTitle

local CodeBox = Instance.new("TextBox")
CodeBox.Parent            = EditorFrame
CodeBox.Size              = UDim2.new(1, -16, 1, -70)
CodeBox.Position          = UDim2.new(0, 8, 0, 32)
CodeBox.BackgroundColor3  = Color3.fromRGB(20, 20, 30)
CodeBox.TextColor3        = Color3.fromRGB(180, 255, 180)
CodeBox.Font              = Enum.Font.Code
CodeBox.TextSize          = 11
CodeBox.Text              = "-- escreva seu código aqui\nprint('Hello TAFX')"
CodeBox.MultiLine         = true
CodeBox.ClearTextOnFocus  = false
CodeBox.TextXAlignment    = Enum.TextXAlignment.Left
CodeBox.TextYAlignment    = Enum.TextYAlignment.Top
CodeBox.BorderSizePixel   = 0
CodeBox.ZIndex            = 21

local UICornerCode = Instance.new("UICorner")
UICornerCode.CornerRadius = UDim.new(0, 6)
UICornerCode.Parent = CodeBox

local RunCodeBtn = Instance.new("TextButton")
RunCodeBtn.Parent           = EditorFrame
RunCodeBtn.Size             = UDim2.new(0.45, 0, 0, 28)
RunCodeBtn.Position         = UDim2.new(0.04, 0, 1, -34)
RunCodeBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
RunCodeBtn.Text             = "▶ Executar"
RunCodeBtn.TextColor3       = Color3.fromRGB(200, 255, 200)
RunCodeBtn.Font             = Enum.Font.GothamBold
RunCodeBtn.TextSize         = 12
RunCodeBtn.BorderSizePixel  = 0
RunCodeBtn.ZIndex           = 21

local UICornerRunCode = Instance.new("UICorner")
UICornerRunCode.CornerRadius = UDim.new(0, 6)
UICornerRunCode.Parent = RunCodeBtn

local CloseEditorBtn = Instance.new("TextButton")
CloseEditorBtn.Parent           = EditorFrame
CloseEditorBtn.Size             = UDim2.new(0.45, 0, 0, 28)
CloseEditorBtn.Position         = UDim2.new(0.52, 0, 1, -34)
CloseEditorBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
CloseEditorBtn.Text             = "✕ Fechar"
CloseEditorBtn.TextColor3       = Color3.fromRGB(255, 200, 200)
CloseEditorBtn.Font             = Enum.Font.GothamBold
CloseEditorBtn.TextSize         = 12
CloseEditorBtn.BorderSizePixel  = 0
CloseEditorBtn.ZIndex           = 21

local UICornerCloseEditor = Instance.new("UICorner")
UICornerCloseEditor.CornerRadius = UDim.new(0, 6)
UICornerCloseEditor.Parent = CloseEditorBtn

-- ============================================================
-- ARRASTAR (MainFrame)
-- ============================================================
do
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                         input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ============================================================
-- ARRASTAR (EditorFrame)
-- ============================================================
do
    local dragging, dragStart, startPos
    EditorTitle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = EditorFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                         input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            EditorFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ============================================================
-- MINIMIZAR
-- ============================================================
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetSize = minimized
        and UDim2.new(0, 230, 0, 32)
        or  UDim2.new(0, 230, 0, 320)
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Size = targetSize
    }):Play()
    ContentFrame.Visible = not minimized
    MinBtn.Text = minimized and "▲" or "—"
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ============================================================
-- SHIFTLOCK
-- ============================================================
local function toggleShiftLock()
    shiftActive = not shiftActive
    if shiftActive then
        Crosshair.Visible = true
        ShiftLockButton.Image = States.On
        shiftConn = RunService.RenderStepped:Connect(function()
            if not Player.Character then return end
            local hum  = Player.Character:FindFirstChild("Humanoid")
            local hrp  = Player.Character:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then return end
            hum.AutoRotate = false
            hrp.CFrame = CFrame.new(
                hrp.Position,
                Vector3.new(
                    Camera.CFrame.LookVector.X * MaxLength,
                    hrp.Position.Y,
                    Camera.CFrame.LookVector.Z * MaxLength
                )
            )
            Camera.CFrame = Camera.CFrame * EnabledOffset
            Camera.Focus  = CFrame.fromMatrix(
                Camera.Focus.Position,
                Camera.CFrame.RightVector,
                Camera.CFrame.UpVector
            ) * EnabledOffset
        end)
    else
        Crosshair.Visible = false
        ShiftLockButton.Image = States.Off
        if Player.Character then
            local hum = Player.Character:FindFirstChild("Humanoid")
            if hum then hum.AutoRotate = true end
            Camera.CFrame = Camera.CFrame * DisabledOffset
        end
        if shiftConn then shiftConn:Disconnect(); shiftConn = nil end
    end
end

ShiftLockButton.MouseButton1Click:Connect(toggleShiftLock)

-- ============================================================
-- RUN SPEED 40
-- ============================================================
local function setRunSpeed(on)
    if not Player.Character then return end
    local hum = Player.Character:FindFirstChild("Humanoid")
    if not hum then return end
    hum.WalkSpeed = on and 40 or 16
end

runBtn.MouseButton1Click:Connect(function()
    runActive = not runActive
    runBtn.Text = runActive and "🏃 Run Speed  [ ON ]" or "🏃 Run Speed  [ OFF ]"
    runBtn.BackgroundColor3 = runActive
        and Color3.fromRGB(30, 80, 30)
        or  Color3.fromRGB(30, 50, 30)
    setRunSpeed(runActive)

    -- manter ao respawn
    if runActive then
        RunService.Heartbeat:Connect(function()
            if runActive and Player.Character then
                local hum = Player.Character:FindFirstChild("Humanoid")
                if hum and hum.WalkSpeed ~= 40 then
                    hum.WalkSpeed = 40
                end
            end
        end)
    end
end)

-- ============================================================
-- BRING PLAYER (apenas nós mesmos, 10 segundos)
-- ============================================================
bringBtn.MouseButton1Click:Connect(function()
    if bringActive then
        bringActive = false
        if bringConn then bringConn:Disconnect(); bringConn = nil end
        bringBtn.Text = "📍 Bring Player  [ OFF ]"
        bringBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
        return
    end

    bringActive = true
    bringBtn.Text = "📍 Bring Player  [ ON ]"
    bringBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30)

    local elapsed = 0
    bringConn = RunService.Heartbeat:Connect(function(dt)
        elapsed = elapsed + dt
        if elapsed >= 10 then
            bringActive = false
            bringConn:Disconnect()
            bringConn = nil
            bringBtn.Text = "📍 Bring Player  [ OFF ]"
            bringBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
            return
        end
        if not Player.Character then return end
        local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        -- Traz o nosso próprio personagem para a frente da câmera
        hrp.CFrame = Camera.CFrame * CFrame.new(0, 0, -3)
    end)
end)

-- ============================================================
-- SALVAR POSIÇÃO
-- ============================================================
savePosBtn.MouseButton1Click:Connect(function()
    if not Player.Character then return end
    local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    savedPosition = hrp.CFrame
    savePosBtn.Text = "💾 Posição Salva ✓"
    task.delay(2, function()
        savePosBtn.Text = "💾 Salvar Posição"
    end)
end)

-- ============================================================
-- TELEPORTAR
-- ============================================================
tpBtn.MouseButton1Click:Connect(function()
    if not savedPosition then
        tpBtn.Text = "⚠ Nenhuma posição!"
        task.delay(2, function() tpBtn.Text = "🚀 Teleportar" end)
        return
    end
    if not Player.Character then return end
    local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = savedPosition
    tpBtn.Text = "🚀 Teleportado! ✓"
    task.delay(2, function() tpBtn.Text = "🚀 Teleportar" end)
end)

-- ============================================================
-- ABRIR EDITOR DE CÓDIGO
-- ============================================================
execBtn.MouseButton1Click:Connect(function()
    EditorFrame.Visible = not EditorFrame.Visible
end)

RunCodeBtn.MouseButton1Click:Connect(function()
    local code = CodeBox.Text
    local ok, err = pcall(loadstring(code))
    if not ok then
        warn("[TAFX Execute] Erro: " .. tostring(err))
        RunCodeBtn.Text = "❌ Erro"
        task.delay(2, function() RunCodeBtn.Text = "▶ Executar" end)
    else
        RunCodeBtn.Text = "✅ OK"
        task.delay(2, function() RunCodeBtn.Text = "▶ Executar" end)
    end
end)

CloseEditorBtn.MouseButton1Click:Connect(function()
    EditorFrame.Visible = false
end)

-- ============================================================
-- SALVAR CONFIG EM JSON
-- ============================================================
saveJsonBtn.MouseButton1Click:Connect(function()
    local config = {
        shiftlock     = shiftActive,
        runSpeed      = runActive and 40 or 16,
        fov           = 111,
        savedPosition = savedPosition and {
            x = savedPosition.X,
            y = savedPosition.Y,
            z = savedPosition.Z,
        } or nil,
        savedCode     = CodeBox.Text,
    }

    local json = HttpService:JSONEncode(config)

    -- Salva no clipboard (funciona em exploits que suportam)
    pcall(function()
        setclipboard(json)
    end)

    -- Exibe no output
    print("[TAFX Config JSON]\n" .. json)

    saveJsonBtn.Text = "📄 JSON copiado! ✓"
    task.delay(2.5, function()
        saveJsonBtn.Text = "📄 Salvar Config JSON"
    end)
end)

-- ============================================================
-- BIND TECLA SHIFT → ShiftLock
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        toggleShiftLock()
    end
end)

print("[TAFX HUD] Carregado com sucesso!")
return {}
