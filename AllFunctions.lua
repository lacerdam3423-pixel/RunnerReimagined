local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local States = {
    Off = "rbxasset://textures/ui/mouseLock_off@2x.png",
    On  = "rbxasset://textures/ui/mouseLock_on@2x.png",
}

local MaxLength      = 900000
local EnabledOffset  = CFrame.new(1.7, 0, 0)
local DisabledOffset = CFrame.new(-1.7, 0, 0)

local shiftActive   = false
local shiftConn     = nil
local runActive     = false
local bringActive   = false
local bringConn     = nil
local savedPosition = nil
local minimized     = false
local savedScripts  = {}

Camera.FieldOfView = 111
RunService.RenderStepped:Connect(function()
    Camera.FieldOfView = 111
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "TAFX_HUD"
ScreenGui.Parent         = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn   = false
ScreenGui.DisplayOrder   = 999

local MainFrame = Instance.new("Frame")
MainFrame.Name             = "MainFrame"
MainFrame.Parent           = ScreenGui
MainFrame.Size             = UDim2.new(0, 230, 0, 370)
MainFrame.Position         = UDim2.new(0.5, -115, 0.5, -185)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel  = 0
MainFrame.ClipsDescendants = true
MainFrame.Active           = true

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 10)
UICornerMain.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color     = Color3.fromRGB(80, 80, 200)
UIStroke.Thickness = 1.5
UIStroke.Parent    = MainFrame

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
TitleLabel.Parent                 = TitleBar
TitleLabel.Size                   = UDim2.new(1, -60, 1, 0)
TitleLabel.Position               = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text                   = "⚡ TAFX HUD"
TitleLabel.TextColor3             = Color3.fromRGB(180, 180, 255)
TitleLabel.Font                   = Enum.Font.GothamBold
TitleLabel.TextSize               = 13
TitleLabel.TextXAlignment         = Enum.TextXAlignment.Left
TitleLabel.ZIndex                 = 3

local MinBtn = Instance.new("TextButton")
MinBtn.Parent           = TitleBar
MinBtn.Size             = UDim2.new(0, 26, 0, 22)
MinBtn.Position         = UDim2.new(1, -58, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
MinBtn.Text             = "—"
MinBtn.TextColor3       = Color3.fromRGB(200, 200, 255)
MinBtn.Font             = Enum.Font.GothamBold
MinBtn.TextSize         = 12
MinBtn.BorderSizePixel  = 0
MinBtn.ZIndex           = 4

local UICornerMin = Instance.new("UICorner")
UICornerMin.CornerRadius = UDim.new(0, 5)
UICornerMin.Parent = MinBtn

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

local ContentFrame = Instance.new("Frame")
ContentFrame.Name                   = "ContentFrame"
ContentFrame.Parent                 = MainFrame
ContentFrame.Size                   = UDim2.new(1, 0, 1, -32)
ContentFrame.Position               = UDim2.new(0, 0, 0, 32)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ClipsDescendants       = true

local UIList = Instance.new("UIListLayout")
UIList.Parent              = ContentFrame
UIList.Padding             = UDim.new(0, 6)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.SortOrder           = Enum.SortOrder.LayoutOrder

local UIPadding = Instance.new("UIPadding")
UIPadding.Parent       = ContentFrame
UIPadding.PaddingTop   = UDim.new(0, 8)
UIPadding.PaddingLeft  = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)

local Crosshair = Instance.new("Frame")
Crosshair.Name                   = "TAFX_Crosshair"
Crosshair.Parent                 = ScreenGui
Crosshair.Size                   = UDim2.new(0, 6, 0, 6)
Crosshair.Position               = UDim2.new(0.5, -3, 0.5, -3)
Crosshair.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
Crosshair.BackgroundTransparency = 0
Crosshair.BorderSizePixel        = 0
Crosshair.Visible                = false
Crosshair.ZIndex                 = 10

local UICornerCross = Instance.new("UICorner")
UICornerCross.CornerRadius = UDim.new(1, 0)
UICornerCross.Parent = Crosshair

local ShiftLockButton = Instance.new("ImageButton")
ShiftLockButton.Parent                 = ScreenGui
ShiftLockButton.BackgroundTransparency = 1
ShiftLockButton.Position               = UDim2.new(0.92, 0, 0.02, 0)
ShiftLockButton.Size                   = UDim2.new(0.0636147112, 0, 0.0661305636, 0)
ShiftLockButton.SizeConstraint         = Enum.SizeConstraint.RelativeXX
ShiftLockButton.Image                  = States.Off
ShiftLockButton.ZIndex                 = 10

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

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(60, 60, 110) }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = color or Color3.fromRGB(35, 35, 60) }):Play()
    end)

    return btn
end

local runBtn      = makeButton("🏃 Run Speed  [ OFF ]", Color3.fromRGB(30, 50, 30), 1)
local bringBtn    = makeButton("📍 Bring Player  [ OFF ]", Color3.fromRGB(50, 30, 30), 2)
local savePosBtn  = makeButton("💾 Salvar Posição", Color3.fromRGB(35, 35, 60), 3)
local tpBtn       = makeButton("🚀 Teleportar", Color3.fromRGB(35, 35, 60), 4)
local execBtn     = makeButton("⚙ Auto Execução", Color3.fromRGB(40, 30, 55), 5)
local saveJsonBtn = makeButton("📄 Salvar Config JSON", Color3.fromRGB(30, 40, 50), 6)

local EditorFrame = Instance.new("Frame")
EditorFrame.Name             = "EditorFrame"
EditorFrame.Parent           = ScreenGui
EditorFrame.Size             = UDim2.new(0, 320, 0, 360)
EditorFrame.Position         = UDim2.new(0.5, -160, 0.5, -180)
EditorFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
EditorFrame.BorderSizePixel  = 0
EditorFrame.Visible          = false
EditorFrame.ZIndex           = 20
EditorFrame.Active           = true

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
EditorTitle.Text              = "  ⚙ Auto Execução"
EditorTitle.TextColor3        = Color3.fromRGB(180, 180, 255)
EditorTitle.Font              = Enum.Font.GothamBold
EditorTitle.TextSize          = 12
EditorTitle.TextXAlignment    = Enum.TextXAlignment.Left
EditorTitle.BorderSizePixel   = 0
EditorTitle.ZIndex            = 21

local UICornerEditorTitle = Instance.new("UICorner")
UICornerEditorTitle.CornerRadius = UDim.new(0, 8)
UICornerEditorTitle.Parent = EditorTitle

local NameBox = Instance.new("TextBox")
NameBox.Parent           = EditorFrame
NameBox.Size             = UDim2.new(1, -16, 0, 26)
NameBox.Position         = UDim2.new(0, 8, 0, 32)
NameBox.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
NameBox.TextColor3       = Color3.fromRGB(200, 200, 255)
NameBox.Font             = Enum.Font.Gotham
NameBox.TextSize         = 11
NameBox.Text             = "Nome do script..."
NameBox.ClearTextOnFocus = true
NameBox.TextXAlignment   = Enum.TextXAlignment.Left
NameBox.BorderSizePixel  = 0
NameBox.ZIndex           = 21

local UICornerName = Instance.new("UICorner")
UICornerName.CornerRadius = UDim.new(0, 5)
UICornerName.Parent = NameBox

local CodeBox = Instance.new("TextBox")
CodeBox.Parent           = EditorFrame
CodeBox.Size             = UDim2.new(1, -16, 0, 130)
CodeBox.Position         = UDim2.new(0, 8, 0, 64)
CodeBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
CodeBox.TextColor3       = Color3.fromRGB(180, 255, 180)
CodeBox.Font             = Enum.Font.Code
CodeBox.TextSize         = 11
CodeBox.Text             = "print('Hello TAFX')"
CodeBox.MultiLine        = true
CodeBox.ClearTextOnFocus = false
CodeBox.TextXAlignment   = Enum.TextXAlignment.Left
CodeBox.TextYAlignment   = Enum.TextYAlignment.Top
CodeBox.BorderSizePixel  = 0
CodeBox.ZIndex           = 21

local UICornerCode = Instance.new("UICorner")
UICornerCode.CornerRadius = UDim.new(0, 6)
UICornerCode.Parent = CodeBox

local SaveScriptBtn = Instance.new("TextButton")
SaveScriptBtn.Parent           = EditorFrame
SaveScriptBtn.Size             = UDim2.new(0.45, 0, 0, 28)
SaveScriptBtn.Position         = UDim2.new(0.04, 0, 0, 202)
SaveScriptBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 100)
SaveScriptBtn.Text             = "💾 Salvar Script"
SaveScriptBtn.TextColor3       = Color3.fromRGB(200, 220, 255)
SaveScriptBtn.Font             = Enum.Font.GothamBold
SaveScriptBtn.TextSize         = 11
SaveScriptBtn.BorderSizePixel  = 0
SaveScriptBtn.ZIndex           = 21

local UICornerSaveScript = Instance.new("UICorner")
UICornerSaveScript.CornerRadius = UDim.new(0, 6)
UICornerSaveScript.Parent = SaveScriptBtn

local RunCodeBtn = Instance.new("TextButton")
RunCodeBtn.Parent           = EditorFrame
RunCodeBtn.Size             = UDim2.new(0.45, 0, 0, 28)
RunCodeBtn.Position         = UDim2.new(0.52, 0, 0, 202)
RunCodeBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
RunCodeBtn.Text             = "▶ Executar"
RunCodeBtn.TextColor3       = Color3.fromRGB(200, 255, 200)
RunCodeBtn.Font             = Enum.Font.GothamBold
RunCodeBtn.TextSize         = 11
RunCodeBtn.BorderSizePixel  = 0
RunCodeBtn.ZIndex           = 21

local UICornerRunCode = Instance.new("UICorner")
UICornerRunCode.CornerRadius = UDim.new(0, 6)
UICornerRunCode.Parent = RunCodeBtn

local ListTitle = Instance.new("TextLabel")
ListTitle.Parent                 = EditorFrame
ListTitle.Size                   = UDim2.new(1, -16, 0, 20)
ListTitle.Position               = UDim2.new(0, 8, 0, 238)
ListTitle.BackgroundTransparency = 1
ListTitle.Text                   = "Scripts Salvos:"
ListTitle.TextColor3             = Color3.fromRGB(160, 160, 220)
ListTitle.Font                   = Enum.Font.GothamBold
ListTitle.TextSize               = 11
ListTitle.TextXAlignment         = Enum.TextXAlignment.Left
ListTitle.ZIndex                 = 21

local ScriptListFrame = Instance.new("ScrollingFrame")
ScriptListFrame.Parent             = EditorFrame
ScriptListFrame.Size               = UDim2.new(1, -16, 0, 68)
ScriptListFrame.Position           = UDim2.new(0, 8, 0, 260)
ScriptListFrame.BackgroundColor3   = Color3.fromRGB(18, 18, 28)
ScriptListFrame.BorderSizePixel    = 0
ScriptListFrame.ScrollBarThickness = 4
ScriptListFrame.CanvasSize         = UDim2.new(0, 0, 0, 0)
ScriptListFrame.ZIndex             = 21

local UICornerList = Instance.new("UICorner")
UICornerList.CornerRadius = UDim.new(0, 5)
UICornerList.Parent = ScriptListFrame

local ScriptListLayout = Instance.new("UIListLayout")
ScriptListLayout.Parent    = ScriptListFrame
ScriptListLayout.Padding   = UDim.new(0, 3)
ScriptListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local CloseEditorBtn = Instance.new("TextButton")
CloseEditorBtn.Parent           = EditorFrame
CloseEditorBtn.Size             = UDim2.new(1, -16, 0, 24)
CloseEditorBtn.Position         = UDim2.new(0, 8, 1, -30)
CloseEditorBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
CloseEditorBtn.Text             = "✕ Fechar"
CloseEditorBtn.TextColor3       = Color3.fromRGB(255, 200, 200)
CloseEditorBtn.Font             = Enum.Font.GothamBold
CloseEditorBtn.TextSize         = 11
CloseEditorBtn.BorderSizePixel  = 0
CloseEditorBtn.ZIndex           = 21

local UICornerCloseEditor = Instance.new("UICorner")
UICornerCloseEditor.CornerRadius = UDim.new(0, 6)
UICornerCloseEditor.Parent = CloseEditorBtn

local function refreshScriptList()
    for _, child in ipairs(ScriptListFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local total = 0
    for _, entry in ipairs(savedScripts) do
        total = total + 1

        local row = Instance.new("Frame")
        row.Parent           = ScriptListFrame
        row.Size             = UDim2.new(1, 0, 0, 26)
        row.BackgroundColor3 = Color3.fromRGB(28, 28, 45)
        row.BorderSizePixel  = 0
        row.LayoutOrder      = total

        local UICornerRow = Instance.new("UICorner")
        UICornerRow.CornerRadius = UDim.new(0, 4)
        UICornerRow.Parent = row

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent                 = row
        nameLabel.Size                   = UDim2.new(1, -80, 1, 0)
        nameLabel.Position               = UDim2.new(0, 6, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text                   = entry.name
        nameLabel.TextColor3             = Color3.fromRGB(200, 200, 255)
        nameLabel.Font                   = Enum.Font.Gotham
        nameLabel.TextSize               = 10
        nameLabel.TextXAlignment         = Enum.TextXAlignment.Left
        nameLabel.ZIndex                 = 22

        local runRowBtn = Instance.new("TextButton")
        runRowBtn.Parent           = row
        runRowBtn.Size             = UDim2.new(0, 34, 0, 20)
        runRowBtn.Position         = UDim2.new(1, -76, 0, 3)
        runRowBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 30)
        runRowBtn.Text             = "▶"
        runRowBtn.TextColor3       = Color3.fromRGB(180, 255, 180)
        runRowBtn.Font             = Enum.Font.GothamBold
        runRowBtn.TextSize         = 10
        runRowBtn.BorderSizePixel  = 0
        runRowBtn.ZIndex           = 22

        local UICornerRunRow = Instance.new("UICorner")
        UICornerRunRow.CornerRadius = UDim.new(0, 4)
        UICornerRunRow.Parent = runRowBtn

        local delRowBtn = Instance.new("TextButton")
        delRowBtn.Parent           = row
        delRowBtn.Size             = UDim2.new(0, 34, 0, 20)
        delRowBtn.Position         = UDim2.new(1, -38, 0, 3)
        delRowBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
        delRowBtn.Text             = "🗑"
        delRowBtn.TextColor3       = Color3.fromRGB(255, 180, 180)
        delRowBtn.Font             = Enum.Font.GothamBold
        delRowBtn.TextSize         = 10
        delRowBtn.BorderSizePixel  = 0
        delRowBtn.ZIndex           = 22

        local UICornerDelRow = Instance.new("UICorner")
        UICornerDelRow.CornerRadius = UDim.new(0, 4)
        UICornerDelRow.Parent = delRowBtn

        local capturedEntry = entry
        runRowBtn.MouseButton1Click:Connect(function()
            pcall(loadstring(capturedEntry.code))
        end)
        delRowBtn.MouseButton1Click:Connect(function()
            for i, s in ipairs(savedScripts) do
                if s == capturedEntry then
                    table.remove(savedScripts, i)
                    break
                end
            end
            refreshScriptList()
        end)
    end

    ScriptListFrame.CanvasSize = UDim2.new(0, 0, 0, total * 29)
end

do
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

do
    local dragging, dragStart, startPos
    EditorTitle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = EditorFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            EditorFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetSize = minimized and UDim2.new(0, 230, 0, 32) or UDim2.new(0, 230, 0, 370)
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Size = targetSize }):Play()
    ContentFrame.Visible = not minimized
    MinBtn.Text = minimized and "▲" or "—"
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local function toggleShiftLock()
    shiftActive = not shiftActive
    if shiftActive then
        Crosshair.Visible     = true
        ShiftLockButton.Image = States.On
        shiftConn = RunService.RenderStepped:Connect(function()
            if not Player.Character then return end
            local hum = Player.Character:FindFirstChild("Humanoid")
            local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then return end
            hum.AutoRotate = false
            hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(
                Camera.CFrame.LookVector.X * MaxLength,
                hrp.Position.Y,
                Camera.CFrame.LookVector.Z * MaxLength
            ))
            Camera.CFrame = Camera.CFrame * EnabledOffset
            Camera.Focus  = CFrame.fromMatrix(Camera.Focus.Position, Camera.CFrame.RightVector, Camera.CFrame.UpVector) * EnabledOffset
        end)
    else
        Crosshair.Visible     = false
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

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then toggleShiftLock() end
end)

runBtn.MouseButton1Click:Connect(function()
    runActive = not runActive
    runBtn.Text             = runActive and "🏃 Run Speed  [ ON ]" or "🏃 Run Speed  [ OFF ]"
    runBtn.BackgroundColor3 = runActive and Color3.fromRGB(30, 80, 30) or Color3.fromRGB(30, 50, 30)
    if runActive then
        RunService.Heartbeat:Connect(function()
            if runActive and Player.Character then
                local hum = Player.Character:FindFirstChild("Humanoid")
                if hum and hum.WalkSpeed ~= 40 then hum.WalkSpeed = 40 end
            end
        end)
    else
        if Player.Character then
            local hum = Player.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end
end)

bringBtn.MouseButton1Click:Connect(function()
    if bringActive then
        bringActive = false
        if bringConn then bringConn:Disconnect(); bringConn = nil end
        bringBtn.Text             = "📍 Bring Player  [ OFF ]"
        bringBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
        return
    end
    bringActive = true
    bringBtn.Text             = "📍 Bring Player  [ ON ]"
    bringBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
    local elapsed = 0
    bringConn = RunService.Heartbeat:Connect(function(dt)
        elapsed = elapsed + dt
        if elapsed >= 10 then
            bringActive = false
            bringConn:Disconnect()
            bringConn = nil
            bringBtn.Text             = "📍 Bring Player  [ OFF ]"
            bringBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
            return
        end
        if not Player.Character then return end
        local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = Camera.CFrame * CFrame.new(0, 0, -3) end
    end)
end)

savePosBtn.MouseButton1Click:Connect(function()
    if not Player.Character then return end
    local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    savedPosition   = hrp.CFrame
    savePosBtn.Text = "💾 Posição Salva ✓"
    task.delay(2, function() savePosBtn.Text = "💾 Salvar Posição" end)
end)

tpBtn.MouseButton1Click:Connect(function()
    if not savedPosition then
        tpBtn.Text = "⚠ Nenhuma posição!"
        task.delay(2, function() tpBtn.Text = "🚀 Teleportar" end)
        return
    end
    if not Player.Character then return end
    local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = savedPosition end
    tpBtn.Text = "🚀 Teleportado! ✓"
    task.delay(2, function() tpBtn.Text = "🚀 Teleportar" end)
end)

execBtn.MouseButton1Click:Connect(function()
    EditorFrame.Visible = not EditorFrame.Visible
    if EditorFrame.Visible then refreshScriptList() end
end)

SaveScriptBtn.MouseButton1Click:Connect(function()
    local name = NameBox.Text
    local code = CodeBox.Text
    if name == "" or name == "Nome do script..." or code == "" then
        SaveScriptBtn.Text = "⚠ Preencha tudo"
        task.delay(2, function() SaveScriptBtn.Text = "💾 Salvar Script" end)
        return
    end
    table.insert(savedScripts, { name = name, code = code })
    refreshScriptList()
    SaveScriptBtn.Text = "✅ Salvo!"
    task.delay(2, function() SaveScriptBtn.Text = "💾 Salvar Script" end)
end)

RunCodeBtn.MouseButton1Click:Connect(function()
    local ok, err = pcall(loadstring(CodeBox.Text))
    if not ok then
        warn("[TAFX] Erro: " .. tostring(err))
        RunCodeBtn.Text = "❌ Erro"
    else
        RunCodeBtn.Text = "✅ OK"
    end
    task.delay(2, function() RunCodeBtn.Text = "▶ Executar" end)
end)

CloseEditorBtn.MouseButton1Click:Connect(function()
    EditorFrame.Visible = false
end)

saveJsonBtn.MouseButton1Click:Connect(function()
    local scripts = {}
    for _, s in ipairs(savedScripts) do
        table.insert(scripts, { name = s.name, code = s.code })
    end
    local config = {
        shiftlock     = shiftActive,
        runSpeed      = runActive and 40 or 16,
        fov           = 111,
        savedPosition = savedPosition and { x = savedPosition.X, y = savedPosition.Y, z = savedPosition.Z } or nil,
        savedScripts  = scripts,
    }
    local json = HttpService:JSONEncode(config)
    pcall(function() setclipboard(json) end)
    print("[TAFX Config JSON]\n" .. json)
    saveJsonBtn.Text = "📄 JSON copiado! ✓"
    task.delay(2.5, function() saveJsonBtn.Text = "📄 Salvar Config JSON" end)
end)
