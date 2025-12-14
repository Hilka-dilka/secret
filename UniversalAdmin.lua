local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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
        return
    end
    
    local name = string.match(playerName, "^;goto%s+(.+)$")
    
    if not name or name == "" then
        return
    end
    
    name = name:match("^%s*(.-)%s*$")
    
    local targetPlayer = findPlayerByName(name)
    
    if not targetPlayer then
        return
    end
    
    if targetPlayer == LocalPlayer then
        return
    end
    
    local character = LocalPlayer.Character
    if not character then
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return
    end
    
    local targetCharacter = targetPlayer.Character
    if not targetCharacter then
        return
    end
    
    local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not targetRootPart then
        local torso = targetCharacter:FindFirstChild("Torso") or targetCharacter:FindFirstChild("UpperTorso")
        if not torso then
            return
        end
        targetRootPart = torso
    end
    
    pcall(function()
        local offset = Vector3.new(0, 3, 0)
        humanoidRootPart.CFrame = targetRootPart.CFrame + offset
    end)
end

local function teleportToCamera()
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return end
    
    local Camera = workspace.CurrentCamera
    if not Camera then return end
    
    local camCFrame = Camera.CFrame
    local camPosition = camCFrame.Position
    local lookVector = camCFrame.LookVector
    
    local teleportPosition = camPosition + (lookVector * 3)
    
    HumanoidRootPart.CFrame = CFrame.new(teleportPosition, teleportPosition + lookVector)
end

local function setGravity(value)
    local num = tonumber(value)
    if not num then
        return
    end
    
    if num < 0 or num > 1000 then
        return
    end
    
    workspace.Gravity = num
end

local function setSpeed(value)
    local num = tonumber(value)
    if not num then
        return
    end
    
    if num < 0 or num > 500 then
        return
    end
    
    local character = LocalPlayer.Character
    if not character then
        return
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end
    
    humanoid.WalkSpeed = num
end

local function setJump(value)
    local num = tonumber(value)
    if not num then
        return
    end
    
    if num < 0 or num > 500 then
        return
    end
    
    local character = LocalPlayer.Character
    if not character then
        return
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end
    
    humanoid.JumpPower = num
end

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local IsInvisible = false
local OriginalTransparency = {}
local OriginalFace = nil
local OriginalTexture = nil

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

LocalPlayer.Chatted:Connect(function(message)
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

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    wait(0.5)
    if IsInvisible then
        wait(1)
        makeInvisible()
    end
    if IsNoclipping then
        wait(0.3)
        enableNoclip()
    end
end)

_G.noclip = enableNoclip
_G.clip = disableNoclip
_G.togglenoclip = toggleNoclip

print("Commands: ;goto player_name, ;gotocam, ;gravity number, ;speed number, ;jump number, ;invis, ;vis, ;toggleinvis, ;noclip, ;clip, ;toggle")
