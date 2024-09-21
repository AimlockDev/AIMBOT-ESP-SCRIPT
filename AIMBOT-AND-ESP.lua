local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
local Circle = Instance.new("Frame", ScreenGui)

-- Circle properties
local circleSize = 200 -- Circle diameter (200)
Circle.Size = UDim2.new(0, circleSize, 0, circleSize)
Circle.BackgroundColor3 = Color3.new(1, 0, 0) -- Red color
Circle.AnchorPoint = Vector2.new(0.5, 0.5) -- Anchor to center
Circle.BorderSizePixel = 0
Circle.BackgroundTransparency = 0.5 -- Make it semi-transparent
Circle.ClipsDescendants = true

-- Create a circular mask
local Mask = Instance.new("UICorner", Circle)
Mask.CornerRadius = UDim.new(1, 0)

local isLockingOn = false
local lockedPlayer = nil -- Track the currently locked player

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
        lockedPlayer = nil -- Reset locked player when mouse button is released
    end
end)

RunService.RenderStepped:Connect(function()
    -- Update the circle's position to the mouse cursor
    local mouse = LocalPlayer:GetMouse()
    Circle.Position = UDim2.new(0, mouse.X, 0, mouse.Y) -- Center the circle on the cursor

    if isLockingOn then
        if not lockedPlayer then -- Only lock onto a player if not already locked
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and isPlayerInCircle(player) then
                    lockedPlayer = player -- Lock onto this player
                    -- Lock the camera to the target player's head
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, player.Character.Head.Position)
                    break -- Lock on to the first player found within the circle
                end
            end
        else
            -- Maintain lock on the currently locked player
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, lockedPlayer.Character.Head.Position)
        end
    end
end)

-- Function to create rainbow color
local function rainbowColor()
    local time = tick() * 3
    return Color3.new(math.sin(time), math.sin(time + 2), math.sin(time + 4))
end

-- Function to create ESP outline
local function createESP(player)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.new(1, 1, 1) -- Optional: set fill color (white)
    highlight.OutlineColor = rainbowColor() -- Set outline color to rainbow
    highlight.OutlineTransparency = 0 -- Fully visible outline
    highlight.Parent = player.Character or game.Workspace

    -- Update ESP outline when character spawns
    player.CharacterAdded:Connect(function(character)
        highlight.Parent = character
    end)

    -- Update rainbow color continuously
    RunService.RenderStepped:Connect(function()
        highlight.OutlineColor = rainbowColor()
    end)
end

-- Loop through players and create ESP for each
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        createESP(player)
    end
end

-- Update ESP whenever a new player joins
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Wait() -- Wait for character to load
    createESP(player)
end)
