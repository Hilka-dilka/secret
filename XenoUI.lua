-- XENO DARK V17 [ULTIMATE FULL VERSION]
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local cam = workspace.CurrentCamera
local Players = game:GetService("Players")
local mouse = player:GetMouse()

local settings = {
    fly = false, flySpeed = 0.8,
    walkBoost = false, walkPower = 0.5,
    jumpBoost = false, jumpPower = 3.5,
    noJumpCooldown = false,
    esp = false,
    fullbright = false,
    noclip = false,
    hitbox = false,
    hitboxSize = 5,
    freecam = false,
    aimbot = false,           -- Включение аимбота
    aimbotFov = 90,           -- FOV для аима
    aimbotSmoothness = 5,     -- Плавность (1-10, где 1 - мгновенно, 10 - очень плавно)
    aimPart = "Head",         -- Часть тела для наведения
    showFovCircle = false,
    aimOnKey = true,  
    wallCheck = false,
    aimKey = Enum.KeyCode.LeftAlt -- Левый альт
}

------------------------------------------------------------------------
-- ПЛАВНЫЙ АИМБОТ
-- ПЛАВНЫЙ АИМБОТ С ТОЧКОЙ НА ЦЕЛИ И ФИКСАЦИЕЙ
------------------------------------------------------------------------
-- ПЛАВНЫЙ АИМБОТ С ТОЧКОЙ НА ЦЕЛИ И ФИКСАЦИЕЙ И ПРОВЕРКОЙ СТЕН
------------------------------------------------------------------------
local Drawing = Drawing or {}
local fovCircle = Drawing.new("Circle")
if fovCircle then
    fovCircle.Thickness = 1
    fovCircle.NumSides = 64
    fovCircle.Radius = settings.aimbotFov
    fovCircle.Filled = false
    fovCircle.Visible = false
    fovCircle.Color = Color3.new(1, 0, 0)
    fovCircle.Transparency = 0.5
end

-- Создаем точку для отображения цели
local targetDot = Drawing.new("Circle")
if targetDot then
    targetDot.Thickness = 2
    targetDot.NumSides = 32
    targetDot.Radius = 6
    targetDot.Filled = true
    targetDot.Color = Color3.new(1, 1, 1) -- Белый цвет
    targetDot.Transparency = 0.3
    targetDot.Visible = false
end

-- Создаем обводку для точки
local targetDotOutline = Drawing.new("Circle")
if targetDotOutline then
    targetDotOutline.Thickness = 1
    targetDotOutline.NumSides = 32
    targetDotOutline.Radius = 8
    targetDotOutline.Filled = false
    targetDotOutline.Color = Color3.new(0, 0, 0)
    targetDotOutline.Transparency = 0.5
    targetDotOutline.Visible = false
end

-- Точка для цели за стеной (красная)
local targetDotWall = Drawing.new("Circle")
if targetDotWall then
    targetDotWall.Thickness = 2
    targetDotWall.NumSides = 32
    targetDotWall.Radius = 6
    targetDotWall.Filled = true
    targetDotWall.Color = Color3.new(1, 0, 0) -- Красный цвет
    targetDotWall.Transparency = 0.3
    targetDotWall.Visible = false
end

local currentTarget = nil
local targetPart = nil
local lockedPart = nil
local isAiming = false
local targetVisible = false

-- Функция проверки видимости через стену
local function isTargetVisible(targetPos)
    if not player.Character or not player.Character:FindFirstChild("Head") then return false end
    
    local origin = cam.CFrame.Position
    local direction = (targetPos - origin).Unit
    local ray = Ray.new(origin, direction * 1000)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {player.Character})
    
    if hit then
        -- Проверяем, является ли то, во что мы попали, целью или её частью
        if targetPart and (hit:IsDescendantOf(targetPart.Parent) or hit == targetPart) then
            return true
        end
        return false
    end
    return true
end

-- Функция получения ближайшей цели в FOV
local function getClosestTarget()
    if not settings.aimbot then return nil, nil end
    
    local center = Vector2.new(mouse.X, mouse.Y + 60)
    local closestDist = settings.aimbotFov
    local closestPlayer = nil
    local closestPart = nil
    local bestScore = math.huge
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local char = p.Character
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                -- Проверяем разные части тела
                local parts = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso"}
                for _, partName in pairs(parts) do
                    local part = char:FindFirstChild(partName)
                    if part then
                        local pos, onScreen = cam:WorldToViewportPoint(part.Position)
                        if onScreen then
                            -- Расстояние до прицела
                            local aimDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                            
                            -- Расстояние до игрока
                            local playerDist = 0
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local myPos = player.Character.HumanoidRootPart.Position
                                playerDist = (part.Position - myPos).Magnitude
                            end
                            
                            -- Проверка видимости (если включена)
                            -- Проверка видимости (если включена)
-- Проверка видимости (если включена)
local visible = true
if settings.wallCheck then
    visible = isTargetVisible(part.Position)
end

-- Если wallCheck включен и цель невидима - пропускаем её
if settings.wallCheck and not visible then
    continue
end

-- Комбинированный score
local score = (aimDist * 0.7) + (playerDist * 0.3)

if aimDist < closestDist and score < bestScore then
    bestScore = score
    closestPlayer = p
    closestPart = part
end
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer, closestPart
end

-- Функция плавного поворота камеры
local function smoothAim(targetPos, smoothness)
    local currentLook = cam.CFrame.LookVector
    local targetLook = (targetPos - cam.CFrame.Position).Unit
    
    local smoothFactor = math.min(1, smoothness * 0.1)
    local newLook = currentLook:Lerp(targetLook, smoothFactor)
    
    local newCF = CFrame.lookAt(cam.CFrame.Position, cam.CFrame.Position + newLook)
    cam.CFrame = newCF
end

-- Отслеживаем нажатие ЛКМ
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- При нажатии ЛКМ фиксируем текущую цель и часть тела
        if settings.aimbot and currentTarget and targetPart then
            -- Проверяем видимость если включена
            if settings.wallCheck then
                if targetVisible then
                    lockedPart = targetPart
                    isAiming = true
                end
            else
                lockedPart = targetPart
                isAiming = true
            end
        end
    end
end)

UIS.InputEnded:Connect(function(input, gp)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- При отпускании ЛКМ сбрасываем фиксацию
        isAiming = false
        lockedPart = nil
    end
end)

-- Основной цикл аима
RunService.RenderStepped:Connect(function()
    -- Обновляем FOV круг
    if settings.showFovCircle and settings.aimbot and fovCircle then
        fovCircle.Position = Vector2.new(mouse.X, mouse.Y + 60)
        fovCircle.Radius = settings.aimbotFov
        fovCircle.Visible = true
    elseif fovCircle then
        fovCircle.Visible = false
    end
    
    -- Получаем цель (только если не в процессе аима)
    if not isAiming then
        local target, part = getClosestTarget()
        currentTarget = target
        targetPart = part
        
        -- Проверяем видимость цели
        if targetPart and settings.wallCheck then
            targetVisible = isTargetVisible(targetPart.Position)
        else
            targetVisible = true
        end
    else
        -- Проверяем видимость зафиксированной цели
        if lockedPart and settings.wallCheck then
            targetVisible = isTargetVisible(lockedPart.Position)
        end
    end
    
    -- Показываем точку на цели
    local showPart = isAiming and lockedPart or targetPart
    if settings.aimbot and showPart and settings.showFovCircle then
        local pos, onScreen = cam:WorldToViewportPoint(showPart.Position)
        if onScreen then
            local dotPos = Vector2.new(pos.X, pos.Y)
            
            -- Выбираем цвет точки в зависимости от видимости
            if settings.wallCheck and not targetVisible then
                -- Цель за стеной - красная точка
                if targetDot then targetDot.Visible = false end
                if targetDotOutline then targetDotOutline.Visible = false end
                if targetDotWall then
                    targetDotWall.Position = dotPos
                    targetDotWall.Visible = true
                end
            else
                -- Цель видна - белая точка с обводкой
                if targetDot then
                    targetDot.Position = dotPos
                    targetDot.Visible = true
                end
                if targetDotOutline then
                    targetDotOutline.Position = dotPos
                    targetDotOutline.Visible = true
                end
                if targetDotWall then targetDotWall.Visible = false end
            end
        else
            if targetDot then targetDot.Visible = false end
            if targetDotOutline then targetDotOutline.Visible = false end
            if targetDotWall then targetDotWall.Visible = false end
        end
    else
        if targetDot then targetDot.Visible = false end
        if targetDotOutline then targetDotOutline.Visible = false end
        if targetDotWall then targetDotWall.Visible = false end
    end
    
    -- Аим при зажатой кнопке
    if settings.aimbot then
        local shouldAim = false
        
        if settings.aimOnKey then
    if settings.aimKey == Enum.UserInputType.MouseButton2 then
        shouldAim = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    elseif settings.aimKey == Enum.UserInputType.MouseButton1 then
        shouldAim = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    elseif settings.aimKey == Enum.KeyCode.LeftAlt then
        shouldAim = UIS:IsKeyDown(Enum.KeyCode.LeftAlt)
    else
        shouldAim = UIS:IsKeyDown(settings.aimKey)
    end
else
    shouldAim = true
end
        
        if shouldAim and (targetPart or lockedPart) then
    local aimAt = lockedPart or targetPart
    
    -- Проверяем видимость для зафиксированной цели
    local canAim = true
    if settings.wallCheck and lockedPart then
        canAim = isTargetVisible(aimAt.Position)
    end
    
    if canAim and aimAt then
        local smoothness = 11 - settings.aimbotSmoothness
        smoothAim(aimAt.Position, smoothness)
    end
elseif not shouldAim then
    isAiming = false
    lockedPart = nil
end
    end
end)


------------------------------------------------------------------------
-- ПОЛНОЦЕННЫЙ FREECAM (С ПРУЖИНАМИ)
------------------------------------------------------------------------
local pi, rad, clamp, exp = math.pi, math.rad, math.clamp, math.exp
local NAV_GAIN = Vector3.new(1, 1, 1)*64
local PAN_GAIN = Vector2.new(0.75, 1)*2.5
local FOV_GAIN = 300
local PITCH_LIMIT = rad(90)

local Spring = {}
Spring.__index = Spring
function Spring.new(freq, pos) 
    return setmetatable({f = freq, p = pos, v = pos*0}, Spring) 
end

function Spring:Update(dt, goal)
    local f = self.f*2*pi
    local offset = goal - self.p
    local decay = exp(-f*dt)
    local p1 = goal + (self.v*dt - offset*(f*dt + 1))*decay
    local v1 = (f*dt*(offset*f - self.v) + self.v)*decay
    self.p, self.v = p1, v1
    return p1
end

function Spring:Reset(pos) 
    self.p = pos
    self.v = pos*0 
end

local cameraPos, cameraRot, cameraFov = Vector3.new(), Vector2.new(), 70
local velSpring, panSpring, fovSpring = Spring.new(1.5, Vector3.new()), Spring.new(1.0, Vector2.new()), Spring.new(4.0, 0)
local InputMap = {keys = {W=0,A=0,S=0,D=0,E=0,Q=0}, mouse = {Delta = Vector2.new(), Wheel = 0}}
local freecamActive = false
local rightMousePressed = false

local function StepFreecam(dt)
    if not freecamActive or not rightMousePressed then 
        if not rightMousePressed and freecamActive then
            local vel = velSpring:Update(dt, Vector3.new(InputMap.keys.D - InputMap.keys.A, InputMap.keys.E - InputMap.keys.Q, InputMap.keys.S - InputMap.keys.W) * (UIS:IsKeyDown(Enum.KeyCode.LeftShift) and 0.25 or 1))
            local fov = fovSpring:Update(dt, InputMap.mouse.Wheel)
            InputMap.mouse.Wheel = 0
            cameraFov = clamp(cameraFov + fov*FOV_GAIN*dt, 1, 120)
            cameraPos = cameraPos + vel*NAV_GAIN*dt
            local cf = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)
            cam.CFrame, cam.Focus, cam.FieldOfView = cf, cf, cameraFov
        end
        return 
    end
    
    local vel = velSpring:Update(dt, Vector3.new(InputMap.keys.D - InputMap.keys.A, InputMap.keys.E - InputMap.keys.Q, InputMap.keys.S - InputMap.keys.W) * (UIS:IsKeyDown(Enum.KeyCode.LeftShift) and 0.25 or 1))
    local pan = panSpring:Update(dt, InputMap.mouse.Delta)
    InputMap.mouse.Delta = Vector2.new()
    local fov = fovSpring:Update(dt, InputMap.mouse.Wheel)
    InputMap.mouse.Wheel = 0
    cameraFov = clamp(cameraFov + fov*FOV_GAIN*dt, 1, 120)
    cameraRot = cameraRot + pan*PAN_GAIN*dt
    cameraRot = Vector2.new(clamp(cameraRot.x, -PITCH_LIMIT, PITCH_LIMIT), cameraRot.y%(2*pi))
    local cf = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)*CFrame.new(vel*NAV_GAIN*dt)
    cameraPos, cam.CFrame, cam.Focus, cam.FieldOfView = cf.p, cf, cf, cameraFov
end

local function ToggleFreecam(state)
    if state then
        local cf = cam.CFrame
        cameraRot, cameraPos, cameraFov = Vector2.new(cf:toEulerAnglesYXZ()), cf.p, cam.FieldOfView
        velSpring:Reset(Vector3.new())
        panSpring:Reset(Vector2.new())
        fovSpring:Reset(0)
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Anchored = true
        end
        RunService:BindToRenderStep("Freecam", 201, StepFreecam)
        freecamActive = true
        UIS.MouseBehavior = Enum.MouseBehavior.Default
    else
        RunService:UnbindFromRenderStep("Freecam")
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Anchored = false
        end
        cam.CameraType = Enum.CameraType.Custom
        freecamActive = false
        rightMousePressed = false
        UIS.MouseBehavior = Enum.MouseBehavior.Default
    end
end

-- Обработка ПКМ для freecam
UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and settings.freecam and freecamActive then
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            rightMousePressed = true
            UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
        end
    end
end)

UIS.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if settings.freecam and freecamActive then
            rightMousePressed = false
            UIS.MouseBehavior = Enum.MouseBehavior.Default
        end
    end
end)

UIS.InputChanged:Connect(function(input)
    if settings.freecam and freecamActive and rightMousePressed then
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            InputMap.mouse.Delta = Vector2.new(-input.Delta.y, -input.Delta.x)
        end
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            InputMap.mouse.Wheel = -input.Position.z
        end
    end
end)

-- Клавиши движения
UIS.InputBegan:Connect(function(i)
    if i.KeyCode and i.KeyCode.Name:len() == 1 then
        InputMap.keys[i.KeyCode.Name] = 1
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.KeyCode and i.KeyCode.Name:len() == 1 then
        InputMap.keys[i.KeyCode.Name] = 0
    end
end)

------------------------------------------------------------------------
-- ИНТЕРФЕЙС
------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui"))
ScreenGui.Name = "XenoDark_V17"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 650)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(0, 60, 150)
UIStroke.Thickness = 1

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "XENO DARK V17"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true

local OpenMiscBtn = Instance.new("TextButton", MainFrame)
OpenMiscBtn.Size = UDim2.new(0, 30, 0, 30)
OpenMiscBtn.Position = UDim2.new(1, -35, 0, 5)
OpenMiscBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
OpenMiscBtn.Text = ">"
OpenMiscBtn.TextColor3 = Color3.new(1,1,1)
OpenMiscBtn.TextScaled = true

local MiscFrame = Instance.new("Frame", ScreenGui)
MiscFrame.Size = UDim2.new(0, 200, 0, 300)
MiscFrame.Position = MainFrame.Position + UDim2.new(0, 310, 0, 0)
MiscFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MiscFrame.Visible = false
MiscFrame.Active = true

local MiscStroke = Instance.new("UIStroke", MiscFrame)
MiscStroke.Color = Color3.fromRGB(0, 60, 150)
MiscStroke.Thickness = 1

OpenMiscBtn.MouseButton1Click:Connect(function() 
    MiscFrame.Visible = not MiscFrame.Visible
    OpenMiscBtn.Text = MiscFrame.Visible and "<" or ">"
end)

local function NewToggle(parent, text, pos, key)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, pos)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    btn.Text = text .. ": OFF"
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.TextScaled = true
    
    btn.MouseButton1Click:Connect(function()
        settings[key] = not settings[key]
        btn.TextColor3 = settings[key] and Color3.fromRGB(0, 180, 255) or Color3.new(0.7, 0.7, 0.7)
        btn.Text = text .. ": " .. (settings[key] and "ON" or "OFF")
        
        if key == "freecam" then 
            ToggleFreecam(settings.freecam) 
        end
    end)
end

local function NewSlider(parent, text, pos, min, max, default, key)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(0.9, 0, 0, 20)
    label.Position = UDim2.new(0.05, 0, 0, pos)
    label.Text = text .. ": " .. default
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0, 150, 255)
    label.TextSize = 12
    
    local sliderBg = Instance.new("Frame", parent)
    sliderBg.Size = UDim2.new(0.9, 0, 0, 6)
    sliderBg.Position = UDim2.new(0.05, 0, 0, pos + 22)
    sliderBg.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    
    local fill = Instance.new("Frame", sliderBg)
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 60, 150)
    fill.BorderSizePixel = 0
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local con
            con = RunService.RenderStepped:Connect(function()
                if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    con:Disconnect()
                else
                    local rel = math.clamp((UIS:GetMouseLocation().X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    local val = math.floor((min + (max - min) * rel) * 10) / 10
                    label.Text = text .. ": " .. val
                    settings[key] = val
                    
                    if key == "aimbotFov" and fovCircle then
                        fovCircle.Radius = val
                    end
                end
            end)
        end
    end)
end

-- Основные функции
NewToggle(MainFrame, "Fly (Q)", 50, "fly")
NewSlider(MainFrame, "Fly Speed", 85, 0.1, 5, 0.8, "flySpeed")
NewToggle(MainFrame, "Walk TP", 130, "walkBoost")
NewSlider(MainFrame, "Walk Power", 165, 0.1, 3, 0.5, "walkPower")
NewToggle(MainFrame, "Jump TP", 210, "jumpBoost")
NewSlider(MainFrame, "Jump Power", 245, 1, 15, 3.5, "jumpPower")
NewToggle(MainFrame, "Hitbox", 290, "hitbox")
NewSlider(MainFrame, "Size", 325, 1, 20, 5, "hitboxSize")
NewToggle(MainFrame, "ESP FULL", 370, "esp")

-- AIMBOT секция
NewToggle(MainFrame, "Aimbot", 410, "aimbot")
NewSlider(MainFrame, "FOV", 445, 10, 360, 90, "aimbotFov")
NewSlider(MainFrame, "Smoothness", 480, 1, 10, 5, "aimbotSmoothness")
NewToggle(MainFrame, "Show FOV Circle", 515, "showFovCircle")
NewToggle(MainFrame, "Aim on Key (PKM)", 550, "aimOnKey")
NewToggle(MainFrame, "Wall Check", 585, "wallCheck")

NewToggle(MiscFrame, "FullBright", 40, "fullbright")
NewToggle(MiscFrame, "NoClip", 80, "noclip")
NewToggle(MiscFrame, "No Jump Cooldown", 120, "noJumpCooldown")
NewToggle(MiscFrame, "Freecam (Sh+P)", 160, "freecam")

------------------------------------------------------------------------
-- ОСНОВНОЙ ЛУП
------------------------------------------------------------------------
local lastESPUpdate = 0

RunService.RenderStepped:Connect(function(dt)
    local char = player.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if hrp and hum and not settings.freecam then
        -- No jump cooldown
        if settings.noJumpCooldown and UIS:IsKeyDown(Enum.KeyCode.Space) then
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            hum.Jump = true
        end
        
        -- Fly
        if settings.fly then
            hrp.Velocity = Vector3.zero
            local move = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
            if move.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + move.Unit * settings.flySpeed
            end
        end
        
        -- Walk boost
        if settings.walkBoost and hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + hum.MoveDirection * settings.walkPower
        end
    end
    
    -- Fullbright
    if settings.fullbright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
    end
    
    -- ESP
    if tick() - lastESPUpdate > 0.3 then
        lastESPUpdate = tick()
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local c = p.Character
                
                if settings.esp then
                    if not c:FindFirstChild("XenoESP_Highlight") then
                        local h = Instance.new("Highlight", c)
                        h.Name = "XenoESP_Highlight"
                        h.FillColor = Color3.fromRGB(0, 60, 150)
                        h.FillTransparency = 0.5
                        h.OutlineColor = Color3.new(1, 1, 1)
                        h.OutlineTransparency = 0
                    end
                    
                    if not c:FindFirstChild("XenoESP_Name") then
                        local root = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")
                        if root then
                            local bg = Instance.new("BillboardGui", c)
                            bg.Name = "XenoESP_Name"
                            bg.Size = UDim2.new(0, 100, 0, 30)
                            bg.StudsOffset = Vector3.new(0, 3, 0)
                            bg.AlwaysOnTop = true
                            
                            local name = Instance.new("TextLabel", bg)
                            name.Size = UDim2.new(1, 0, 1, 0)
                            name.BackgroundTransparency = 1
                            name.Text = p.Name
                            name.TextColor3 = Color3.new(1, 1, 1)
                            name.TextStrokeColor3 = Color3.new(0, 0, 0)
                            name.TextStrokeTransparency = 0
                            name.Font = Enum.Font.GothamBold
                            name.TextSize = 13
                        end
                    end
                    
                    if not c:FindFirstChild("XenoESP_Box") then
                        local root = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")
                        if root then
                            local box = Instance.new("BillboardGui", root)
                            box.Name = "XenoESP_Box"
                            box.Size = UDim2.new(4, 0, 6, 0)
                            box.AlwaysOnTop = true
                            
                            local frame = Instance.new("Frame", box)
                            frame.Size = UDim2.new(1, 0, 1, 0)
                            frame.BackgroundTransparency = 1
                            
                            local stroke = Instance.new("UIStroke", frame)
                            stroke.Color = Color3.new(1, 1, 1)
                            stroke.Thickness = 1
                        end
                    end
                else
                    if c:FindFirstChild("XenoESP_Highlight") then
                        c.XenoESP_Highlight:Destroy()
                    end
                    if c:FindFirstChild("XenoESP_Name") then
                        c.XenoESP_Name:Destroy()
                    end
                    local root = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")
                    if root and root:FindFirstChild("XenoESP_Box") then
                        root.XenoESP_Box:Destroy()
                    end
                end
            end
        end
    end
    
    -- Hitbox
    if settings.hitbox then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                p.Character.Head.Size = Vector3.new(settings.hitboxSize, settings.hitboxSize, settings.hitboxSize)
                p.Character.Head.Transparency = 0.5
                p.Character.Head.CanCollide = false
            end
        end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if settings.noclip and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Jump boost и hotkeys
UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    
    if i.KeyCode == Enum.KeyCode.Q then
        settings.fly = not settings.fly
    end
    
    if i.KeyCode == Enum.KeyCode.P and UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
        settings.freecam = not settings.freecam
        ToggleFreecam(settings.freecam)
    end
    
    if i.KeyCode == Enum.KeyCode.Space and settings.jumpBoost and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame + Vector3.new(0, settings.jumpPower, 0)
        end
    end
end)

-- Drag GUI
local dragging, dragStart, startPos

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        MiscFrame.Position = MainFrame.Position + UDim2.new(0, 310, 0, 0)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("XenoDark V17 [AIMBOT] Loaded! Плавный аим с регулировкой скорости")
