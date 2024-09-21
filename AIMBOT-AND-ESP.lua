local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
local Circle = Instance.new("Frame", ScreenGui)

local circleSize = 200
Circle.Size = UDim2.new(0, circleSize, 0, circleSize)
Circle.BackgroundColor3 = Color3.new(1, 0, 0)
Circle.AnchorPoint = Vector2.new(0.5, 0.5)
Circle.BorderSizePixel = 0
Circle.BackgroundTransparency = 0.5
Circle.ClipsDescendants = true

local Mask = Instance.new("UICorner", Circle)
Mask.CornerRadius = UDim.new(1, 0)

local isLockingOn = false
local lockedPlayer = nil

local function isPlayerInCircle(player)
    if player.Character and player.Character:FindFirstChild("Head") then
        local headPosition = Camera:WorldToScreenPoint(player.Character.Head.Position)
        local circlePosition = Circle.Position

        local radius = circleSize / 2
        local distance = ((headPosition.x - (circlePosition.X.Scale * Camera.ViewportSize.X + circlePosition.X.Offset)) ^ 2 + 
                          (headPosition.y - (circlePosition.Y.Scale * Camera.ViewportSize.Y + circlePosition.Y.Offset)) ^ 2) ^ 0.5
        
        return distance <= radius
    end
    return false
end

UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton2 then
        isLockingOn = true
    end
end)

UIS.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isLockingOn = false
        lockedPlayer = nil
    end
end)

RunService.RenderStepped:Connect(function()
    local mouse = LocalPlayer:GetMouse()
    Circle.Position = UDim2.new(0, mouse.X, 0, mouse.Y)

    if isLockingOn then
        if not lockedPlayer then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and isPlayerInCircle(player) then
                    lockedPlayer = player
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, player.Character.Head.Position)
                    break
                end
            end
        else
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, lockedPlayer.Character.Head.Position)
        end
    end
end)

local function rainbowColor()
    local time = tick() * 3
    return Color3.new(math.sin(time), math.sin(time + 2), math.sin(time + 4))
end

local function createESP(player)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.new(1, 1, 1)
    highlight.OutlineColor = rainbowColor()
    highlight.OutlineTransparency = 0
    highlight.Parent = player.Character or game.Workspace
    player.CharacterAdded:Connect(function(character)
        highlight.Parent = character
    end)

    RunService.RenderStepped:Connect(function()
        highlight.OutlineColor = rainbowColor()
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        createESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Wait()
    createESP(player)
end)
