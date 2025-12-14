local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local IS_SERVER = RunService:IsServer()
local IS_CLIENT = RunService:IsClient()

if IS_SERVER then
    warn("This script should only run on client (LocalScript)")
    return
end

local function showSystemMessage(text, color)
    local success, errorMessage = pcall(function()
        game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
            Text = text,
            Color = color or Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.SourceSansBold,
            TextSize = 18
        })
    end)
    
    if not success then
        warn("Failed to show system message:", errorMessage)
    end
end

local function findPlayerByName(name)
    if not name or type(name) ~= "string" then
        return nil
    end
    
    local nameLower = string.lower(name:gsub("%s+", ""))
    local players = Players:GetPlayers()
    
    if #nameLower == 0 then
        return nil
    end
    
    if #nameLower <= 4 then
        for _, player in ipairs(players) do
            local playerNameLower = string.lower(player.Name)
            if string.sub(playerNameLower, 1, #nameLower) == nameLower then
                return player
            end
        end
    else
        for _, player in ipairs(players) do
            if string.lower(player.Name) == nameLower then
                return player
            end
        end
        
        for _, player in ipairs(players) do
            if string.find(string.lower(player.Name), nameLower, 1, true) then
                return player
            end
        end
    end
    
    return nil
end

local function teleportToPlayer(playerName)
    if not playerName or type(playerName) ~= "string" then
        showSystemMessage("Invalid name format", Color3.fromRGB(255, 0, 0))
        return
    end
    
    local name = string.match(playerName, "^;goto%s+(.+)$")
    
    if not name or name == "" then
        showSystemMessage("Usage: ;goto player_name", Color3.fromRGB(255, 0, 0))
        return
    end
    
    name = name:match("^%s*(.-)%s*$")
    
    local targetPlayer = findPlayerByName(name)
    
    if not targetPlayer then
        showSystemMessage("Player '" .. name .. "' not found", Color3.fromRGB(255, 0, 0))
        return
    end
    
    if targetPlayer == LocalPlayer then
        showSystemMessage("You can't teleport to yourself", Color3.fromRGB(255, 0, 0))
        return
    end
    
    local character = LocalPlayer.Character
    if not character then
        showSystemMessage("You don't have a character", Color3.fromRGB(255, 0, 0))
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        showSystemMessage("Your character doesn't have HumanoidRootPart", Color3.fromRGB(255, 0, 0))
        return
    end
    
    local targetCharacter = targetPlayer.Character
    if not targetCharacter then
        showSystemMessage("Player '" .. targetPlayer.Name .. "' doesn't have a character", Color3.fromRGB(255, 0, 0))
        return
    end
    
    local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not targetRootPart then
        local torso = targetCharacter:FindFirstChild("Torso") or targetCharacter:FindFirstChild("UpperTorso")
        if not torso then
            showSystemMessage("Can't find teleport point for player '" .. targetPlayer.Name .. "'", Color3.fromRGB(255, 0, 0))
            return
        end
        targetRootPart = torso
    end
    
    local success, errorMessage = pcall(function()
        local offset = Vector3.new(0, 3, 0)
        humanoidRootPart.CFrame = targetRootPart.CFrame + offset
        
        local distance = (humanoidRootPart.Position - targetRootPart.Position).Magnitude
        if distance > 50 then
            error("Teleport failed - distance too large")
        end
    end)
    
    if success then
        showSystemMessage("Teleported to player: " .. targetPlayer.Name, Color3.fromRGB(0, 255, 0))
    else
        showSystemMessage("Teleport error: " .. tostring(errorMessage), Color3.fromRGB(255, 0, 0))
    end
end

local function teleportToCamera()
    local Character = LocalPlayer.Character
    if not Character then
        showSystemMessage("You don't have a character", Color3.fromRGB(255, 0, 0))
        return
    end
    
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then
        showSystemMessage("Your character doesn't have HumanoidRootPart", Color3.fromRGB(255, 0, 0))
        return
    end
    
    local Camera = workspace.CurrentCamera
    if not Camera then
        showSystemMessage("Camera not found", Color3.fromRGB(255, 0, 0))
        return
    end
    
    local camCFrame = Camera.CFrame
    local camPosition = camCFrame.Position
    local lookVector = camCFrame.LookVector
    
    local teleportPosition = camPosition + (lookVector * 3)
    
    local success, errorMessage = pcall(function()
        HumanoidRootPart.CFrame = CFrame.new(teleportPosition, teleportPosition + lookVector)
    end)
    
    if success then
        showSystemMessage("Teleported to camera position", Color3.fromRGB(0, 255, 0))
    else
        showSystemMessage("Teleport error: " .. tostring(errorMessage), Color3.fromRGB(255, 0, 0))
    end
end

local function setGravity(value)
    local num = tonumber(value)
    if not num then
        showSystemMessage("Usage: ;gravity number (default is 196.2)", Color3.fromRGB(255, 0, 0))
        return
    end
    
    if num < 0 or num > 1000 then
        showSystemMessage("Gravity must be between 0 and 1000", Color3.fromRGB(255, 0, 0))
        return
    end
    
    workspace.Gravity = num
    showSystemMessage("Gravity set to: " .. num, Color3.fromRGB(0, 255, 0))
end

local function setSpeed(value)
    local num = tonumber(value)
    if not num then
        showSystemMessage("Usage: ;speed number (default is 16)", Color3.fromRGB(255, 0, 0))
        return
    end
    
    if num < 0 or num > 500 then
        showSystemMessage("Speed must be between 0 and 500", Color3.fromRGB(255, 0, 0))
        return
    end
    
    local character = LocalPlayer.Character
    if not character then
        showSystemMessage("You don't have a character", Color3.fromRGB(255, 0, 0))
        return
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        showSystemMessage("Your character doesn't have Humanoid", Color3.fromRGB(255, 0, 0))
        return
    end
    
    humanoid.WalkSpeed = num
    showSystemMessage("Speed set to: " .. num, Color3.fromRGB(0, 255, 0))
end

local function setJump(value)
    local num = tonumber(value)
    if not num then
        showSystemMessage("Usage: ;jump number (default is 50)", Color3.fromRGB(255, 0, 0))
        return
    end
    
    if num < 0 or num > 500 then
        showSystemMessage("Jump power must be between 0 and 500", Color3.fromRGB(255, 0, 0))
        return
    end
    
    local character = LocalPlayer.Character
    if not character then
        showSystemMessage("You don't have a character", Color3.fromRGB(255, 0, 0))
        return
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        showSystemMessage("Your character doesn't have Humanoid", Color3.fromRGB(255, 0, 0))
        return
    end
    
    humanoid.JumpPower = num
    showSystemMessage("Jump power set to: " .. num, Color3.fromRGB(0, 255, 0))
end

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local IsInvisible = false
local OriginalTransparency = {}
local OriginalFace = nil
local OriginalTexture = nil

local function createChatBillboard()
    if not Character:FindFirstChild("Head") then return end
    if Character.Head:FindFirstChild("ChatBillboard") then
        Character.Head.ChatBillboard:Destroy()
    end
    local BillboardGui = Instance.new("BillboardGui")
    BillboardGui.Name = "ChatBillboard"
    BillboardGui.Size = UDim2.new(0, 100, 0, 50)
    BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
    BillboardGui.AlwaysOnTop = true
    BillboardGui.MaxDistance = 100
    BillboardGui.Parent = Character.Head
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Name = "ChatText"
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = ""
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.TextStrokeTransparency = 0
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextSize = 14
    TextLabel.TextWrapped = true
    TextLabel.Parent = BillboardGui
    return TextLabel
end

local function showChatMessage(message)
    if not Character or not Character:FindFirstChild("Head") then return end
    local chatText = Character.Head:FindFirstChild("ChatBillboard")
    if not chatText then
        chatText = createChatBillboard()
    end
    if chatText and chatText:FindFirstChild("ChatText") then
        chatText.ChatText.Text = message
        wait(5)
        if chatText and chatText:FindFirstChild("ChatText") then
            chatText.ChatText.Text = ""
        end
    end
end

local function makeInvisible()
    if IsInvisible then return end
    IsInvisible = true
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            OriginalTransparency[part] = part.Transparency
            part.Transparency = 1
            part.CanCollide = false
        elseif part:IsA("Decal") then
            OriginalFace = part.Texture
            part.Transparency = 1
        elseif part:IsA("SpecialMesh") then
            OriginalTexture = part.TextureId
            part.Transparency = 1
        end
    end
    for _, accessory in pairs(Character:GetChildren()) do
        if accessory:IsA("Accessory") then
            for _, part in pairs(accessory:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("SpecialMesh") then
                    part.Transparency = 1
                end
            end
        end
    end
    local shadow = Character:FindFirstChild("Body Colors") or Character:FindFirstChild("Shirt") or Character:FindFirstChild("Pants")
    if shadow then
        shadow:Destroy()
    end
end

local function makeVisible()
    if not IsInvisible then return end
    IsInvisible = false
    for part, transparency in pairs(OriginalTransparency) do
        if part and part.Parent then
            part.Transparency = transparency
            part.CanCollide = true
        end
    end
    if Character:FindFirstChild("Head") then
        local face = Character.Head:FindFirstChildWhichIsA("Decal")
        if face and OriginalFace then
            face.Texture = OriginalFace
            face.Transparency = 0
        end
    end
    for _, mesh in pairs(Character:GetDescendants()) do
        if mesh:IsA("SpecialMesh") and OriginalTexture then
            mesh.TextureId = OriginalTexture
            mesh.Transparency = 0
        end
    end
    for _, accessory in pairs(Character:GetChildren()) do
        if accessory:IsA("Accessory") then
            for _, part in pairs(accessory:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                elseif part:IsA("Decal") or part:IsA("SpecialMesh") then
                    part.Transparency = 0
                end
            end
        end
    end
    for _, part in pairs(Character:GetDescendants()) do
        if part.Name == "InvisEffect" then
            part:Destroy()
        end
    end
    OriginalTransparency = {}
    OriginalFace = nil
    OriginalTexture = nil
end

local function sendVisibleMessage(message)
    if not IsInvisible then
        game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(message, "All")
    else
        showChatMessage(LocalPlayer.Name .. ": " .. message)
    end
end

local NoclipConnection = nil
local IsNoclipping = false

local function enableNoclip()
    if IsNoclipping then return end
    IsNoclipping = true
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    local function noclipLoop()
        if not IsNoclipping or not LocalPlayer.Character then 
            if NoclipConnection then
                NoclipConnection:Disconnect()
                NoclipConnection = nil
            end
            return 
        end
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    NoclipConnection = game:GetService("RunService").Stepped:Connect(noclipLoop)
end

local function disableNoclip()
    if not IsNoclipping then return end
    IsNoclipping = false
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

local function toggleNoclip()
    if IsNoclipping then
        disableNoclip()
    else
        enableNoclip()
    end
end

local function setupCommandHandlers()
    local chattedConnection
    chattedConnection = LocalPlayer.Chatted:Connect(function(message)
        local cleanMsg = string.lower(message)
        
        if string.sub(cleanMsg, 1, 5) == ";goto" then
            teleportToPlayer(message)
        
        elseif cleanMsg == ";gotocam" or cleanMsg == ";gotocamera" or cleanMsg == ";gotocampos" then
            teleportToCamera()
            
        elseif string.sub(cleanMsg, 1, 9) == ";gravity " then
            local value = string.sub(message, 10)
            setGravity(value)
        
        elseif string.sub(cleanMsg, 1, 7) == ";speed " then
            local value = string.sub(message, 8)
            setSpeed(value)
            
        elseif string.sub(cleanMsg, 1, 6) == ";jump " then
            local value = string.sub(message, 7)
            setJump(value)
            
        elseif cleanMsg == ";invis" then
            makeInvisible()
        elseif cleanMsg == ";vis" or cleanMsg == ";visible" then
            makeVisible()
        elseif string.sub(cleanMsg, 1, 11) == ";invischat " then
            local chatMessage = string.sub(message, 12)
            sendVisibleMessage(chatMessage)
        elseif cleanMsg == ";toggleinvis" then
            if IsInvisible then
                makeVisible()
            else
                makeInvisible()
            end
            
        elseif cleanMsg == ";noclip" then
            enableNoclip()
        elseif cleanMsg == ";clip" then
            disableNoclip()
        elseif cleanMsg == ";toggle" then
            toggleNoclip()
        end
    end)
    
    if game:GetService("TextChatService") then
        local TextChatService = game:GetService("TextChatService")
        local textChatConnection
        
        if TextChatService:FindFirstChild("TextChannels") then
            local rbxtsChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if rbxtsChannel then
                textChatConnection = rbxtsChannel.OnMessageReceived:Connect(function(message)
                    if message.TextSource and message.TextSource.UserId == LocalPlayer.UserId then
                        local msgText = string.sub(message.Text or "", 1, 100)
                        local cleanMsg = string.lower(msgText)
                        
                        if string.sub(cleanMsg, 1, 5) == ";goto" then
                            teleportToPlayer(msgText)
                        elseif cleanMsg == ";gotocam" or cleanMsg == ";gotocamera" or cleanMsg == ";gotocampos" then
                            teleportToCamera()
                        elseif string.sub(cleanMsg, 1, 9) == ";gravity " then
                            local value = string.sub(msgText, 10)
                            setGravity(value)
                        elseif string.sub(cleanMsg, 1, 7) == ";speed " then
                            local value = string.sub(msgText, 8)
                            setSpeed(value)
                        elseif string.sub(cleanMsg, 1, 6) == ";jump " then
                            local value = string.sub(msgText, 7)
                            setJump(value)
                        end
                    end
                end)
            end
        end
    end
    
    _G.GotoPlayer = function(playerName)
        if type(playerName) == "string" then
            teleportToPlayer(";goto " .. playerName)
        end
    end
    
    _G.GotoCamera = teleportToCamera
    _G.SetGravity = setGravity
    _G.SetSpeed = setSpeed
    _G.SetJump = setJump
    
    _G.noclip = enableNoclip
    _G.clip = disableNoclip
    _G.togglenoclip = toggleNoclip
    
    task.delay(1, function()
        showSystemMessage("Command system loaded!", Color3.fromRGB(0, 150, 255))
    end)
    
    return {
        Disconnect = function()
            if chattedConnection then
                chattedConnection:Disconnect()
            end
        end
    }
end

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    task.wait(0.5)
    if IsInvisible then
        task.wait(1)
        makeInvisible()
    end
    if IsNoclipping then
        task.wait(0.3)
        enableNoclip()
    end
    createChatBillboard()
end)

local handlers = setupCommandHandlers()
createChatBillboard()

game:GetService("UserInputService").WindowFocusReleased:Connect(function()
    if handlers then
        handlers:Disconnect()
    end
end)

print("Commands: ;goto player_name, ;gotocam, ;gravity number, ;speed number, ;jump number, ;invis, ;vis, ;invischat text, ;toggleinvis, ;noclip, ;clip, ;toggle")
