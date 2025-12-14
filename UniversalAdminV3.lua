local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ===== FULLBRIGHT =====
if not _G.FullBrightExecuted then
    _G.FullBrightEnabled = false
    _G.NormalLightingSettings = {
        Brightness = game:GetService("Lighting").Brightness,
        ClockTime = game:GetService("Lighting").ClockTime,
        FogEnd = game:GetService("Lighting").FogEnd,
        GlobalShadows = game:GetService("Lighting").GlobalShadows,
        Ambient = game:GetService("Lighting").Ambient
    }

    game:GetService("Lighting"):GetPropertyChangedSignal("Brightness"):Connect(function()
        if game:GetService("Lighting").Brightness ~= 1 and game:GetService("Lighting").Brightness ~= _G.NormalLightingSettings.Brightness then
            _G.NormalLightingSettings.Brightness = game:GetService("Lighting").Brightness
            if not _G.FullBrightEnabled then
                repeat wait() until _G.FullBrightEnabled
            end
            game:GetService("Lighting").Brightness = 1
        end
    end)

    game:GetService("Lighting"):GetPropertyChangedSignal("ClockTime"):Connect(function()
        if game:GetService("Lighting").ClockTime ~= 12 and game:GetService("Lighting").ClockTime ~= _G.NormalLightingSettings.ClockTime then
            _G.NormalLightingSettings.ClockTime = game:GetService("Lighting").ClockTime
            if not _G.FullBrightEnabled then
                repeat wait() until _G.FullBrightEnabled
            end
            game:GetService("Lighting").ClockTime = 12
        end
    end)

    game:GetService("Lighting"):GetPropertyChangedSignal("FogEnd"):Connect(function()
        if game:GetService("Lighting").FogEnd ~= 786543 and game:GetService("Lighting").FogEnd ~= _G.NormalLightingSettings.FogEnd then
            _G.NormalLightingSettings.FogEnd = game:GetService("Lighting").FogEnd
            if not _G.FullBrightEnabled then
                repeat wait() until _G.FullBrightEnabled
            end
            game:GetService("Lighting").FogEnd = 786543
        end
    end)

    game:GetService("Lighting"):GetPropertyChangedSignal("GlobalShadows"):Connect(function()
        if game:GetService("Lighting").GlobalShadows ~= false and game:GetService("Lighting").GlobalShadows ~= _G.NormalLightingSettings.GlobalShadows then
            _G.NormalLightingSettings.GlobalShadows = game:GetService("Lighting").GlobalShadows
            if not _G.FullBrightEnabled then
                repeat wait() until _G.FullBrightEnabled
            end
            game:GetService("Lighting").GlobalShadows = false
        end
    end)

    game:GetService("Lighting"):GetPropertyChangedSignal("Ambient"):Connect(function()
        if game:GetService("Lighting").Ambient ~= Color3.fromRGB(178, 178, 178) and game:GetService("Lighting").Ambient ~= _G.NormalLightingSettings.Ambient then
            _G.NormalLightingSettings.Ambient = game:GetService("Lighting").Ambient
            if not _G.FullBrightEnabled then
                repeat wait() until _G.FullBrightEnabled
            end
            game:GetService("Lighting").Ambient = Color3.fromRGB(178, 178, 178)
        end
    end)

    game:GetService("Lighting").Brightness = 1
    game:GetService("Lighting").ClockTime = 12
    game:GetService("Lighting").FogEnd = 786543
    game:GetService("Lighting").GlobalShadows = false
    game:GetService("Lighting").Ambient = Color3.fromRGB(178, 178, 178)

    local LatestValue = true
    spawn(function()
        repeat wait() until _G.FullBrightEnabled
        while wait() do
            if _G.FullBrightEnabled ~= LatestValue then
                if not _G.FullBrightEnabled then
                    game:GetService("Lighting").Brightness = _G.NormalLightingSettings.Brightness
                    game:GetService("Lighting").ClockTime = _G.NormalLightingSettings.ClockTime
                    game:GetService("Lighting").FogEnd = _G.NormalLightingSettings.FogEnd
                    game:GetService("Lighting").GlobalShadows = _G.NormalLightingSettings.GlobalShadows
                    game:GetService("Lighting").Ambient = _G.NormalLightingSettings.Ambient
                else
                    game:GetService("Lighting").Brightness = 1
                    game:GetService("Lighting").ClockTime = 12
                    game:GetService("Lighting").FogEnd = 786543
                    game:GetService("Lighting").GlobalShadows = false
                    game:GetService("Lighting").Ambient = Color3.fromRGB(178, 178, 178)
                end
                LatestValue = not LatestValue
            end
        end
    end)
end
_G.FullBrightExecuted = true
_G.FullBrightEnabled = true

-- ===== FREECAM (автоматически включается) =====
do
    local pi    = math.pi
    local abs   = math.abs
    local clamp = math.clamp
    local exp   = math.exp
    local rad   = math.rad
    local sign  = math.sign
    local sqrt  = math.sqrt
    local tan   = math.tan

    local ContextActionService = game:GetService("ContextActionService")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")

    local Camera = Workspace.CurrentCamera
    Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        local newCamera = Workspace.CurrentCamera
        if newCamera then
            Camera = newCamera
        end
    end)

    local TOGGLE_INPUT_PRIORITY = Enum.ContextActionPriority.Low.Value
    local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value
    local FREECAM_MACRO_KB = {Enum.KeyCode.LeftShift, Enum.KeyCode.P}

    local NAV_GAIN = Vector3.new(1, 1, 1)*128
    local PAN_GAIN = Vector2.new(0.75, 1)*8
    local FOV_GAIN = 600

    local PITCH_LIMIT = rad(90)

    local VEL_STIFFNESS = 1.5
    local PAN_STIFFNESS = 1.0
    local FOV_STIFFNESS = 4.0

    local Spring = {} do
        Spring.__index = Spring
        function Spring.new(freq, pos)
            local self = setmetatable({}, Spring)
            self.f = freq
            self.p = pos
            self.v = pos*0
            return self
        end
        function Spring:Update(dt, goal)
            local f = self.f*2*pi
            local p0 = self.p
            local v0 = self.v
            local offset = goal - p0
            local decay = exp(-f*dt)
            local p1 = goal + (v0*dt - offset*(f*dt + 1))*decay
            local v1 = (f*dt*(offset*f - v0) + v0)*decay
            self.p = p1
            self.v = v1
            return p1
        end
        function Spring:Reset(pos)
            self.p = pos
            self.v = pos*0
        end
    end

    local cameraPos = Vector3.new()
    local cameraRot = Vector2.new()
    local cameraFov = 0
    local velSpring = Spring.new(VEL_STIFFNESS, Vector3.new())
    local panSpring = Spring.new(PAN_STIFFNESS, Vector2.new())
    local fovSpring = Spring.new(FOV_STIFFNESS, 0)

    local Input = {} do
        local thumbstickCurve do
            local K_CURVATURE = 2.0
            local K_DEADZONE = 0.15
            local function fCurve(x)
                return (exp(K_CURVATURE*x) - 1)/(exp(K_CURVATURE) - 1)
            end
            local function fDeadzone(x)
                return fCurve((x - K_DEADZONE)/(1 - K_DEADZONE))
            end
            function thumbstickCurve(x)
                return sign(x)*clamp(fDeadzone(abs(x)), 0, 1)
            end
        end

        local gamepad = {
            ButtonX = 0,
            ButtonY = 0,
            DPadDown = 0,
            DPadUp = 0,
            ButtonL2 = 0,
            ButtonR2 = 0,
            Thumbstick1 = Vector2.new(),
            Thumbstick2 = Vector2.new(),
        }

        local keyboard = {
            W = 0,
            A = 0,
            S = 0,
            D = 0,
            E = 0,
            Q = 0,
            U = 0,
            H = 0,
            J = 0,
            K = 0,
            I = 0,
            Y = 0,
            Up = 0,
            Down = 0,
            LeftShift = 0,
            RightShift = 0,
        }

        local mouse = {
            Delta = Vector2.new(),
            MouseWheel = 0,
        }

        local NAV_GAMEPAD_SPEED  = Vector3.new(2, 2, 2)
        local NAV_KEYBOARD_SPEED = Vector3.new(2, 2, 2)
        local PAN_MOUSE_SPEED    = Vector2.new(2, 2)*(pi/64)
        local PAN_GAMEPAD_SPEED  = Vector2.new(2, 2)*(pi/8)
        local FOV_WHEEL_SPEED    = 2.0
        local FOV_GAMEPAD_SPEED  = 0.5
        local NAV_ADJ_SPEED      = 1.5
        local NAV_SHIFT_MUL      = 0.5
        local navSpeed = 1

        function Input.Vel(dt)
            navSpeed = clamp(navSpeed + dt*(keyboard.Up - keyboard.Down)*NAV_ADJ_SPEED, 0.01, 8)
            local kGamepad = Vector3.new(
                thumbstickCurve(gamepad.Thumbstick1.x),
                thumbstickCurve(gamepad.ButtonR2) - thumbstickCurve(gamepad.ButtonL2),
                thumbstickCurve(-gamepad.Thumbstick1.y)
            )*NAV_GAMEPAD_SPEED
            local kKeyboard = Vector3.new(
                keyboard.D - keyboard.A + keyboard.K - keyboard.H,
                keyboard.E - keyboard.Q + keyboard.I - keyboard.Y,
                keyboard.S - keyboard.W + keyboard.J - keyboard.U
            )*NAV_KEYBOARD_SPEED
            local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
            return (kGamepad + kKeyboard)*(navSpeed*(shift and NAV_SHIFT_MUL or 1))
        end

        function Input.Pan(dt)
            local kGamepad = Vector2.new(
                thumbstickCurve(gamepad.Thumbstick2.y),
                thumbstickCurve(-gamepad.Thumbstick2.x)
            )*PAN_GAMEPAD_SPEED
            local kMouse = mouse.Delta*PAN_MOUSE_SPEED
            mouse.Delta = Vector2.new()
            return kGamepad + kMouse
        end

        function Input.Fov(dt)
            local kGamepad = (gamepad.ButtonX - gamepad.ButtonY)*FOV_GAMEPAD_SPEED
            local kMouse = mouse.MouseWheel*FOV_WHEEL_SPEED
            mouse.MouseWheel = 0
            return kGamepad + kMouse
        end

        do
            local function Keypress(action, state, input)
                keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
                return Enum.ContextActionResult.Sink
            end
            local function GpButton(action, state, input)
                gamepad[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
                return Enum.ContextActionResult.Sink
            end
            local function MousePan(action, state, input)
                local delta = input.Delta
                mouse.Delta = Vector2.new(-delta.y, -delta.x)
                return Enum.ContextActionResult.Sink
            end
            local function Thumb(action, state, input)
                gamepad[input.KeyCode.Name] = input.Position
                return Enum.ContextActionResult.Sink
            end
            local function Trigger(action, state, input)
                gamepad[input.KeyCode.Name] = input.Position.z
                return Enum.ContextActionResult.Sink
            end
            local function MouseWheel(action, state, input)
                mouse[input.UserInputType.Name] = -input.Position.z
                return Enum.ContextActionResult.Sink
            end
            local function Zero(t)
                for k, v in pairs(t) do
                    t[k] = v*0
                end
            end
            function Input.StartCapture()
                ContextActionService:BindActionAtPriority("FreecamKeyboard", Keypress, false, INPUT_PRIORITY,
                    Enum.KeyCode.W, Enum.KeyCode.U,
                    Enum.KeyCode.A, Enum.KeyCode.H,
                    Enum.KeyCode.S, Enum.KeyCode.J,
                    Enum.KeyCode.D, Enum.KeyCode.K,
                    Enum.KeyCode.E, Enum.KeyCode.I,
                    Enum.KeyCode.Q, Enum.KeyCode.Y,
                    Enum.KeyCode.Up, Enum.KeyCode.Down
                )
                ContextActionService:BindActionAtPriority("FreecamMousePan",          MousePan,   false, INPUT_PRIORITY, Enum.UserInputType.MouseMovement)
                ContextActionService:BindActionAtPriority("FreecamMouseWheel",        MouseWheel, false, INPUT_PRIORITY, Enum.UserInputType.MouseWheel)
                ContextActionService:BindActionAtPriority("FreecamGamepadButton",     GpButton,   false, INPUT_PRIORITY, Enum.KeyCode.ButtonX, Enum.KeyCode.ButtonY)
                ContextActionService:BindActionAtPriority("FreecamGamepadTrigger",    Trigger,    false, INPUT_PRIORITY, Enum.KeyCode.ButtonR2, Enum.KeyCode.ButtonL2)
                ContextActionService:BindActionAtPriority("FreecamGamepadThumbstick", Thumb,      false, INPUT_PRIORITY, Enum.KeyCode.Thumbstick1, Enum.KeyCode.Thumbstick2)
            end
            function Input.StopCapture()
                navSpeed = 1
                Zero(gamepad)
                Zero(keyboard)
                Zero(mouse)
                ContextActionService:UnbindAction("FreecamKeyboard")
                ContextActionService:UnbindAction("FreecamMousePan")
                ContextActionService:UnbindAction("FreecamMouseWheel")
                ContextActionService:UnbindAction("FreecamGamepadButton")
                ContextActionService:UnbindAction("FreecamGamepadTrigger")
                ContextActionService:UnbindAction("FreecamGamepadThumbstick")
            end
        end
    end

    local function GetFocusDistance(cameraFrame)
        local znear = 0.1
        local viewport = Camera.ViewportSize
        local projy = 2*tan(cameraFov/2)
        local projx = viewport.x/viewport.y*projy
        local fx = cameraFrame.rightVector
        local fy = cameraFrame.upVector
        local fz = cameraFrame.lookVector
        local minVect = Vector3.new()
        local minDist = 512
        for x = 0, 1, 0.5 do
            for y = 0, 1, 0.5 do
                local cx = (x - 0.5)*projx
                local cy = (y - 0.5)*projy
                local offset = fx*cx - fy*cy + fz
                local origin = cameraFrame.p + offset*znear
                local _, hit = Workspace:FindPartOnRay(Ray.new(origin, offset.unit*minDist))
                local dist = (hit - origin).magnitude
                if minDist > dist then
                    minDist = dist
                    minVect = offset.unit
                end
            end
        end
        return fz:Dot(minVect)*minDist
    end

    local function StepFreecam(dt)
        local vel = velSpring:Update(dt, Input.Vel(dt))
        local pan = panSpring:Update(dt, Input.Pan(dt))
        local fov = fovSpring:Update(dt, Input.Fov(dt))
        local zoomFactor = sqrt(tan(rad(70/2))/tan(rad(cameraFov/2)))
        cameraFov = clamp(cameraFov + fov*FOV_GAIN*(dt/zoomFactor), 1, 120)
        cameraRot = cameraRot + pan*PAN_GAIN*(dt/zoomFactor)
        cameraRot = Vector2.new(clamp(cameraRot.x, -PITCH_LIMIT, PITCH_LIMIT), cameraRot.y%(2*pi))
        local cameraCFrame = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)*CFrame.new(vel*NAV_GAIN*dt)
        cameraPos = cameraCFrame.p
        Camera.CFrame = cameraCFrame
        Camera.Focus = cameraCFrame*CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
        Camera.FieldOfView = cameraFov
    end

    local PlayerState = {} do
        local mouseBehavior
        local mouseIconEnabled
        local cameraType
        local cameraFocus
        local cameraCFrame
        local cameraFieldOfView
        local screenGuis = {}
        local coreGuis = {
            Backpack = true,
            Chat = false,
            Health = true,
            PlayerList = true,
        }
        local setCores = {
            BadgesNotificationsActive = true,
            PointsNotificationsActive = true,
        }
        function PlayerState.Push()
            for name in pairs(coreGuis) do
                coreGuis[name] = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType[name])
                if name ~= "Chat" then
                    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[name], false)
                end
            end
            for name in pairs(setCores) do
                setCores[name] = StarterGui:GetCore(name)
                StarterGui:SetCore(name, false)
            end
            local playergui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if playergui then
                for _, gui in pairs(playergui:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Enabled then
                        if gui.Name:find("Chat", 1, true) or gui.Name:find("чат", 1, true) then
                        else
                            screenGuis[#screenGuis + 1] = gui
                            gui.Enabled = false
                        end
                    end
                end
            end
            cameraFieldOfView = Camera.FieldOfView
            Camera.FieldOfView = 70
            cameraType = Camera.CameraType
            Camera.CameraType = Enum.CameraType.Custom
            cameraCFrame = Camera.CFrame
            cameraFocus = Camera.Focus
            mouseIconEnabled = UserInputService.MouseIconEnabled
            UserInputService.MouseIconEnabled = true
            mouseBehavior = UserInputService.MouseBehavior
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
        function PlayerState.Pop()
            for name, isEnabled in pairs(coreGuis) do
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[name], isEnabled)
            end
            for name, isEnabled in pairs(setCores) do
                StarterGui:SetCore(name, isEnabled)
            end
            for _, gui in pairs(screenGuis) do
                if gui.Parent then
                    gui.Enabled = true
                end
            end
            Camera.FieldOfView = cameraFieldOfView
            cameraFieldOfView = nil
            Camera.CameraType = cameraType
            cameraType = nil
            Camera.CFrame = cameraCFrame
            cameraCFrame = nil
            Camera.Focus = cameraFocus
            cameraFocus = nil
            UserInputService.MouseIconEnabled = mouseIconEnabled
            mouseIconEnabled = nil
            UserInputService.MouseBehavior = mouseBehavior
            mouseBehavior = nil
        end
    end

    local function StartFreecam()
        local cameraCFrame = Camera.CFrame
        cameraRot = Vector2.new(cameraCFrame:toEulerAnglesYXZ())
        cameraPos = cameraCFrame.p
        cameraFov = Camera.FieldOfView
        velSpring:Reset(Vector3.new())
        panSpring:Reset(Vector2.new())
        fovSpring:Reset(0)
        PlayerState.Push()
        RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
        Input.StartCapture()
    end

    local function StopFreecam()
        Input.StopCapture()
        RunService:UnbindFromRenderStep("Freecam")
        PlayerState.Pop()
    end

    do
        local freecamEnabled = false
        local function ToggleFreecam()
            if freecamEnabled then
                StopFreecam()
            else
                StartFreecam()
            end
            freecamEnabled = not freecamEnabled
        end
        local function CheckMacro(macro)
            for i = 1, #macro - 1 do
                if not UserInputService:IsKeyDown(macro[i]) then
                    return
                end
            end
            ToggleFreecam()
        end
        local function HandleActivationInput(action, state, input)
            if state == Enum.UserInputState.Begin then
                if input.KeyCode == FREECAM_MACRO_KB[#FREECAM_MACRO_KB] then
                    CheckMacro(FREECAM_MACRO_KB)
                end
            end
            return Enum.ContextActionResult.Pass
        end
        ContextActionService:BindActionAtPriority("FreecamToggle", HandleActivationInput, false, TOGGLE_INPUT_PRIORITY, FREECAM_MACRO_KB[#FREECAM_MACRO_KB])
        
        -- Автоматически включаем Freecam при запуске
        task.wait(1)
        StartFreecam()
        freecamEnabled = true
    end
end

-- ===== ОРИГИНАЛЬНЫЕ КОМАНДЫ =====
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

-- ===== ;GOTOCAM (ВАША ВЕРСИЯ) =====
local function teleportToCamera()
    local Character = Player.Character
    if not Character then return end
    
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return end
    
    local Camera = workspace.CurrentCamera
    if not Camera then return end
    
    -- Получаем позицию и направление камеры
    local camCFrame = Camera.CFrame
    local camPosition = camCFrame.Position
    local lookVector = camCFrame.LookVector
    
    -- Телепортируемся немного вперед от камеры, чтобы не застрять в объектах
    local teleportPosition = camPosition + (lookVector * 3)
    
    -- Устанавливаем новую позицию
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

    elseif cleanMsg == ";tptocam" or cleanMsg == ";tocam" then
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
print("Fullbright: Automatically enabled")
print("Freecam: Automatically enabled (Shift+P to toggle)")
