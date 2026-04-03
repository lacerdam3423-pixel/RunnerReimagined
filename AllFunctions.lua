-- TAF Shiftlock --

local ShiftLockScreenGui = Instance.new("ScreenGui")
local ShiftLockButton = Instance.new("ImageButton")
local RunButton = Instance.new("TextButton")
local BringButton = Instance.new("TextButton")
local ShiftlockCursor = Instance.new("Frame")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local States = {
    Off = "rbxasset://textures/ui/mouseLock_off@2x.png",
    On  = "rbxasset://textures/ui/mouseLock_on@2x.png",
}
local MaxLength      = 900000
local EnabledOffset  = CFrame.new(1.7, 0, 0)
local DisabledOffset = CFrame.new(-1.7, 0, 0)
local Active
local RunActive   = false
local BringActive = false
local BringThread = nil

-- ══════════════════════════════════════
-- FOV PERMANENTE 111
-- ══════════════════════════════════════
workspace.CurrentCamera.FieldOfView = 111
RunService.RenderStepped:Connect(function()
    workspace.CurrentCamera.FieldOfView = 111
end)

-- ══════════════════════════════════════
-- GUI
-- ══════════════════════════════════════
ShiftLockScreenGui.Name = "TAFX Shiftlock (CoreGui)"
ShiftLockScreenGui.Parent = CoreGui
ShiftLockScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ShiftLockScreenGui.ResetOnSpawn = false

-- ── Botão ShiftLock (superior direito) ──
ShiftLockButton.Parent = ShiftLockScreenGui
ShiftLockButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ShiftLockButton.BackgroundTransparency = 1
ShiftLockButton.Position = UDim2.new(0.92, 0, 0.02, 0)
ShiftLockButton.Size = UDim2.new(0.0636147112, 0, 0.0661305636, 0)
ShiftLockButton.SizeConstraint = Enum.SizeConstraint.RelativeXX
ShiftLockButton.Image = States.Off

-- ── Botão CORRER (abaixo do ShiftLock) ──
RunButton.Name = "RunButton"
RunButton.Parent = ShiftLockScreenGui
RunButton.Size = UDim2.new(0, 90, 0, 32)
RunButton.Position = UDim2.new(0.92, 0, 0.10, 0)
RunButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
RunButton.BackgroundTransparency = 0.3
RunButton.BorderSizePixel = 0
RunButton.Text = "🏃"
RunButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RunButton.TextSize = 13
RunButton.Font = Enum.Font.GothamBold
do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = RunButton
end

-- ── Botão BRING (abaixo de CORRER) ──
BringButton.Name = "BringButton"
BringButton.Parent = ShiftLockScreenGui
BringButton.Size = UDim2.new(0, 90, 0, 32)
BringButton.Position = UDim2.new(0.92, 0, 0.16, 0)
BringButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
BringButton.BackgroundTransparency = 0.3
BringButton.BorderSizePixel = 0
BringButton.Text = "📍"
BringButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BringButton.TextSize = 13
BringButton.Font = Enum.Font.GothamBold
do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = BringButton
end

-- ── Mira: pontinho no centro ──
ShiftlockCursor.Name = "TAFX Cursor"
ShiftlockCursor.Parent = ShiftLockScreenGui
ShiftlockCursor.Size = UDim2.new(0, 6, 0, 6)
ShiftlockCursor.Position = UDim2.new(0.5, -3, 0.5, -3)
ShiftlockCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ShiftlockCursor.BackgroundTransparency = 0
ShiftlockCursor.BorderSizePixel = 0
ShiftlockCursor.Visible = false
do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = ShiftlockCursor
end

-- ══════════════════════════════════════
-- SHIFTLOCK
-- ══════════════════════════════════════
ShiftLockButton.MouseButton1Click:Connect(function()
    if not Active then
        Active = RunService.RenderStepped:Connect(function()
            Player.Character.Humanoid.AutoRotate = false
            ShiftLockButton.Image = States.On
            ShiftlockCursor.Visible = true
            Player.Character.HumanoidRootPart.CFrame =
                CFrame.new(
                    Player.Character.HumanoidRootPart.Position,
                    Vector3.new(
                        workspace.CurrentCamera.CFrame.LookVector.X * MaxLength,
                        Player.Character.HumanoidRootPart.Position.Y,
                        workspace.CurrentCamera.CFrame.LookVector.Z * MaxLength
                    )
                )
            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * EnabledOffset
            workspace.CurrentCamera.Focus =
                CFrame.fromMatrix(
                    workspace.CurrentCamera.Focus.Position,
                    workspace.CurrentCamera.CFrame.RightVector,
                    workspace.CurrentCamera.CFrame.UpVector
                ) * EnabledOffset
        end)
    else
        Player.Character.Humanoid.AutoRotate = true
        ShiftLockButton.Image = States.Off
        workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * DisabledOffset
        ShiftlockCursor.Visible = false
        pcall(function()
            Active:Disconnect()
            Active = nil
        end)
    end
end)

-- ══════════════════════════════════════
-- CORRER (WalkSpeed 40)
-- ══════════════════════════════════════
RunButton.MouseButton1Click:Connect(function()
    RunActive = not RunActive
    local char = Player.Character
    if char and char:FindFirstChild("Humanoid") then
        if RunActive then
            char.Humanoid.WalkSpeed = 40
            RunButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            RunButton.Text = "🏃"
        else
            char.Humanoid.WalkSpeed = 16
            RunButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            RunButton.Text = "✋"
        end
    end
end)

-- Mantém o speed ao trocar de personagem
Player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    if RunActive then
        char.Humanoid.WalkSpeed = 40
    end
    workspace.CurrentCamera.FieldOfView = 111
end)

-- ══════════════════════════════════════
-- BRING PLAYER (10 segundos contínuos)
-- ══════════════════════════════════════
local function startBring(targetPlayer)
    if BringThread then
        task.cancel(BringThread)
        BringThread = nil
    end
    BringThread = task.spawn(function()
        local elapsed = 0
        while elapsed < 10 do
            local myChar = Player.Character
            local targetChar = targetPlayer.Character
            if myChar and targetChar then
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                if myRoot and targetRoot then
                    targetRoot.CFrame = myRoot.CFrame + myRoot.CFrame.LookVector * 3
                end
            end
            task.wait(0.1)
            elapsed = elapsed + 0.1
        end
        BringActive = false
        BringButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        BringButton.Text = "📍"
    end)
end

BringButton.MouseButton1Click:Connect(function()
    -- Pega o player mais próximo (exceto você mesmo)
    local myChar = Player.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local closest, closestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local dist = (r.Position - myRoot.Position).Magnitude
                if dist < closestDist then
                    closest = p
                    closestDist = dist
                end
            end
        end
    end

    if closest then
        BringActive = true
        BringButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        BringButton.Text = "🚶"
        startBring(closest)
    end
end)

local ShiftLockAction = ContextActionService:BindAction("TAFX Lock", function() end, false, "On")
ContextActionService:SetPosition("TAFX Lock", UDim2.new(0.8, 0, 0.8, 0))

return {}
