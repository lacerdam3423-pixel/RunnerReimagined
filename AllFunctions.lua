-- TAF Shiftlock --

local ShiftLockScreenGui = Instance.new("ScreenGui")
local ShiftLockButton = Instance.new("ImageButton")
local ShiftlockCursor = Instance.new("Frame") -- Mudado para Frame (pontinho)
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local States = {
    Off = "rbxasset://textures/ui/mouseLock_off@2x.png",
    On = "rbxasset://textures/ui/mouseLock_on@2x.png",
}
local MaxLength = 900000
local EnabledOffset = CFrame.new(1.7, 0, 0)
local DisabledOffset = CFrame.new(-1.7, 0, 0)
local Active

ShiftLockScreenGui.Name = "TAFX Shiftlock (CoreGui)"
ShiftLockScreenGui.Parent = CoreGui
ShiftLockScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ShiftLockScreenGui.ResetOnSpawn = false

-- Botão no canto superior direito
ShiftLockButton.Parent = ShiftLockScreenGui
ShiftLockButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ShiftLockButton.BackgroundTransparency = 1.000
ShiftLockButton.Position = UDim2.new(0.92, 0, 0.02, 0) -- ← superior direito
ShiftLockButton.Size = UDim2.new(0.0636147112, 0, 0.0661305636, 0)
ShiftLockButton.SizeConstraint = Enum.SizeConstraint.RelativeXX
ShiftLockButton.Image = States.Off

-- Mira: pontinho no centro
ShiftlockCursor.Name = "TAFX Cursor"
ShiftlockCursor.Parent = ShiftLockScreenGui
ShiftlockCursor.Size = UDim2.new(0, 6, 0, 6) -- 6x6 pixels
ShiftlockCursor.Position = UDim2.new(0.5, -3, 0.5, -3) -- centralizado
ShiftlockCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ShiftlockCursor.BackgroundTransparency = 0
ShiftlockCursor.BorderSizePixel = 0
ShiftlockCursor.Visible = false

-- Deixa o pontinho redondo
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = ShiftlockCursor

ShiftLockButton.MouseButton1Click:Connect(
    function()
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
    end
)

local ShiftLockAction = ContextActionService:BindAction("TAFX Lock", ShiftLock, false, "On")
ContextActionService:SetPosition("TAFX Lock", UDim2.new(0.8, 0, 0.8, 0))

return {} and ShiftLockAction
