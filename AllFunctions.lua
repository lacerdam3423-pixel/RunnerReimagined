-- TAF Shiftlock --

local ShiftLockScreenGui = Instance.new("ScreenGui")
local ShiftLockButton = Instance.new("ImageButton")
local ShiftlockCursor = Instance.new("Frame")
local RunButton = Instance.new("TextButton")
local BringButton = Instance.new("TextButton")
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
local BringConnection = nil

-- ── FOV permanente 111 ──────────────────────────────────────────────
workspace.CurrentCamera.FieldOfView = 111
RunService.RenderStepped:Connect(function()
    workspace.CurrentCamera.FieldOfView = 111
end)

-- ── ScreenGui ───────────────────────────────────────────────────────
ShiftLockScreenGui.Name            = "TAFX Shiftlock (CoreGui)"
ShiftLockScreenGui.Parent          = CoreGui
ShiftLockScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ShiftLockScreenGui.ResetOnSpawn    = false

-- ── Botão ShiftLock (canto superior direito) ────────────────────────
ShiftLockButton.Parent                = ShiftLockScreenGui
ShiftLockButton.BackgroundColor3      = Color3.fromRGB(255, 255, 255)
ShiftLockButton.BackgroundTransparency = 1
ShiftLockButton.Position              = UDim2.new(0.92, 0, 0.02, 0)
ShiftLockButton.Size                  = UDim2.new(0.0636147112, 0, 0.0661305636, 0)
ShiftLockButton.SizeConstraint        = Enum.SizeConstraint.RelativeXX
ShiftLockButton.Image                 = States.Off

-- ── Mira: pontinho branco 6×6 no centro ────────────────────────────
ShiftlockCursor.Name                 = "TAFX Cursor"
ShiftlockCursor.Parent               = ShiftLockScreenGui
ShiftlockCursor.Size                 = UDim2.new(0, 6, 0, 6)
ShiftlockCursor.Position             = UDim2.new(0.5, -3, 0.5, -3)
ShiftlockCursor.BackgroundColor3     = Color3.fromRGB(255, 255, 255)
ShiftlockCursor.BackgroundTransparency = 0
ShiftlockCursor.BorderSizePixel      = 0
ShiftlockCursor.Visible              = false
local UICorner1 = Instance.new("UICorner")
UICorner1.CornerRadius = UDim.new(1, 0)
UICorner1.Parent = ShiftlockCursor

-- ── Botão CORRER (logo abaixo do ShiftLock) ─────────────────────────
RunButton.Name                    = "RunButton"
RunButton.Parent                  = ShiftLockScreenGui
RunButton.Size                    = UDim2.new(0.0636147112, 0, 0.0661305636, 0)
RunButton.SizeConstraint          = Enum.SizeConstraint.RelativeXX
RunButton.Position                = UDim2.new(0.92, 0, 0.09, 0)  -- abaixo do shiftlock
RunButton.BackgroundColor3        = Color3.fromRGB(30, 30, 30)
RunButton.BackgroundTransparency  = 0.3
RunButton.BorderSizePixel         = 0
RunButton.Text                    = "RUN"
RunButton.TextColor3              = Color3.fromRGB(255, 255, 255)
RunButton.TextScaled              = true
RunButton.Font                    = Enum.Font.GothamBold
local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0.2, 0)
UICorner2.Parent = RunButton

RunButton.MouseButton1Click:Connect(function()
    RunActive = not RunActive
    local char = Player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if RunActive then
        hum.WalkSpeed             = 40
        RunButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        RunButton.Text             = "RUN ✓"
    else
        hum.WalkSpeed             = 16
        RunButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        RunButton.Text             = "RUN"
    end
end)

-- mantém speed ao trocar de personagem
Player.CharacterAdded:Connect(function(char)
    if RunActive then
        local hum = char:WaitForChild("Humanoid")
        hum.WalkSpeed = 40
    end
end)

-- ── Botão BRING (abaixo do RUN) ──────────────────────────────────────
BringButton.Name                    = "BringButton"
BringButton.Parent                  = ShiftLockScreenGui
BringButton.Size                    = UDim2.new(0.0636147112, 0, 0.0661305636, 0)
BringButton.SizeConstraint          = Enum.SizeConstraint.RelativeXX
BringButton.Position                = UDim2.new(0.92, 0, 0.16, 0)  -- abaixo do RUN
BringButton.BackgroundColor3        = Color3.fromRGB(30, 30, 30)
BringButton.BackgroundTransparency  = 0.3
BringButton.BorderSizePixel         = 0
BringButton.Text                    = "BRING"
BringButton.TextColor3              = Color3.fromRGB(255, 255, 255)
BringButton.TextScaled              = true
BringButton.Font                    = Enum.Font.GothamBold
local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(0.2, 0)
UICorner3.Parent = BringButton

BringButton.MouseButton1Click:Connect(function()
    if BringActive then return end  -- ignora clique duplo durante os 10s
    BringActive = true
    BringButton.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    BringButton.Text             = "BRING ✓"

    -- puxa o nosso próprio personagem para a câmera durante 10 segundos
    local elapsed = 0
    BringConnection = RunService.RenderStepped:Connect(function(dt)
        elapsed = elapsed + dt
        local char = Player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local camCF = workspace.CurrentCamera.CFrame
                -- traz o personagem para 5 studs à frente da câmera
                hrp.CFrame = CFrame.new(camCF.Position + camCF.LookVector * 5)
            end
        end
        if elapsed >= 10 then
            BringConnection:Disconnect()
            BringConnection = nil
            BringActive = false
            BringButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            BringButton.Text             = "BRING"
        end
    end)
end)

-- ── ShiftLock lógica ────────────────────────────────────────────────
ShiftLockButton.MouseButton1Click:Connect(function()
    if not Active then
        Active = RunService.RenderStepped:Connect(function()
            Player.Character.Humanoid.AutoRotate = false
            ShiftLockButton.Image   = States.On
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
            workspace.CurrentCamera.CFrame =
                workspace.CurrentCamera.CFrame * EnabledOffset
            workspace.CurrentCamera.Focus =
                CFrame.fromMatrix(
                    workspace.CurrentCamera.Focus.Position,
                    workspace.CurrentCamera.CFrame.RightVector,
                    workspace.CurrentCamera.CFrame.UpVector
                ) * EnabledOffset
        end)
    else
        Player.Character.Humanoid.AutoRotate = true
        ShiftLockButton.Image   = States.Off
        workspace.CurrentCamera.CFrame =
            workspace.CurrentCamera.CFrame * DisabledOffset
        ShiftlockCursor.Visible = false
        pcall(function()
            Active:Disconnect()
            Active = nil
        end)
    end
end)

local ShiftLockAction = ContextActionService:BindAction("TAFX Lock", ShiftLock, false, "On")
ContextActionService:SetPosition("TAFX Lock", UDim2.new(0.8, 0, 0.8, 0))

return {} and ShiftLockAction
