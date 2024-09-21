local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character
local camera = game.Workspace.CurrentCamera
local aimbotEnabled = false
local targetPlayer = nil

local function isPlayerInSight(player)
    local character = player.Character
    if character then
        local head = character:FindFirstChild("Head")
        if head then
            local ray = Ray.new(camera.CFrame.Position, (head.Position - camera.CFrame.Position).Unit * 1000)
            local hit, position = game.Workspace:Raycast(ray)
            if hit and hit.Parent == character then
                return true
            end
        end
    end
    return false
end

local function updateTarget()
    if aimbotEnabled then
        local closestPlayer = nil
        local closestDistance = math.huge
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= player and isPlayerInSight(player) then
                local distance = (camera.CFrame.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance < closestDistance then
                    closestPlayer = player
                    closestDistance = distance
                end
            end
        end
        targetPlayer = closestPlayer
    end
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightMouseButton then
        aimbotEnabled = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightMouseButton then
        aimbotEnabled = false
        targetPlayer = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if aimbotEnabled and targetPlayer then
        local character = targetPlayer.Character
        if character then
            local head = character:FindFirstChild("Head")
            if head then
                camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
            end
        end
    end
    updateTarget()
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= player then
        local character = player.Character
        if character then
            local head = character:FindFirstChild("Head")
            if head then
                local esp = Instance.new("BillboardGui")
                esp.Name = "ESP"
                esp.Adornee = head
                esp.StudsOffset = Vector3.new(0, 2, 0)
                esp.Size = UDim2.new(0, 100, 0, 20)
                esp.BackgroundTransparency = 1
                local text = Instance.new("TextLabel")
                text.Text = player.Name
                text.BackgroundTransparency = 1
                text.TextColor3 = Color3.new(1, 1, 1)
                text.Font = Enum.Font.SourceSans
                text.FontSize = Enum.FontSize.Size24
                text.Parent = esp
                esp.Parent = head
            end
        end
    end
end