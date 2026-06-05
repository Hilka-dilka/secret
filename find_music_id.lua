--[[
    Скрипт для отслеживания играющих звуков
    Показывает:
    - Названия звуков которые играют прямо сейчас
    - Их ID
    - Громкость
    - Время проигрывания
    - Откуда звук (путь)
    - Кнопка остановки каждого звука
]]

-- Переменные
local screenGui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")
local title = Instance.new("TextLabel")
local playingList = Instance.new("ScrollingFrame")
local listLayout = Instance.new("UIListLayout")
local statusLabel = Instance.new("TextLabel")
local refreshButton = Instance.new("TextButton")
local stopAllButton = Instance.new("TextButton")
local closeButton = Instance.new("TextButton")
local autoRefreshToggle = Instance.new("TextButton")
local refreshTimer = Instance.new("TextLabel")

-- Настройка GUI
screenGui.Name = "PlayingSoundsTracker"
screenGui.Parent = game.CoreGui
screenGui.ResetOnSpawn = false

-- Основное окно
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
mainFrame.Size = UDim2.new(0, 500, 0, 600)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true

-- Заголовок
title.Name = "Title"
title.Parent = mainFrame
title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
title.BorderSizePixel = 0
title.Size = UDim2.new(1, 0, 0, 40)
title.Font = Enum.Font.GothamBold
title.Text = "🎵 Сейчас играет"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20

-- Статус
statusLabel.Name = "StatusLabel"
statusLabel.Parent = mainFrame
statusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
statusLabel.BorderSizePixel = 0
statusLabel.Position = UDim2.new(0, 10, 0, 50)
statusLabel.Size = UDim2.new(0, 300, 0, 30)
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "Поиск играющих звуков..."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 14
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Таймер обновления
refreshTimer.Name = "RefreshTimer"
refreshTimer.Parent = mainFrame
refreshTimer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
refreshTimer.BorderSizePixel = 0
refreshTimer.Position = UDim2.new(0, 320, 0, 50)
refreshTimer.Size = UDim2.new(0, 160, 0, 30)
refreshTimer.Font = Enum.Font.Gotham
refreshTimer.Text = "🔄 Обновление: вкл"
refreshTimer.TextColor3 = Color3.fromRGB(100, 255, 100)
refreshTimer.TextSize = 14
refreshTimer.TextXAlignment = Enum.TextXAlignment.Right

-- Список играющих звуков
playingList.Name = "PlayingList"
playingList.Parent = mainFrame
playingList.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
playingList.BorderSizePixel = 0
playingList.Position = UDim2.new(0, 10, 0, 90)
playingList.Size = UDim2.new(0, 480, 0, 400)
playingList.CanvasSize = UDim2.new(0, 0, 0, 0)
playingList.ScrollBarThickness = 8
playingList.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 100)

-- Расположение элементов в списке
listLayout.Parent = playingList
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)

-- Кнопка обновления
refreshButton.Name = "RefreshButton"
refreshButton.Parent = mainFrame
refreshButton.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
refreshButton.BorderSizePixel = 0
refreshButton.Position = UDim2.new(0, 10, 1, -80)
refreshButton.Size = UDim2.new(0, 110, 0, 35)
refreshButton.Font = Enum.Font.GothamBold
refreshButton.Text = "🔄 Обновить"
refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshButton.TextSize = 14

-- Кнопка автообновления
autoRefreshToggle.Name = "AutoRefreshToggle"
autoRefreshToggle.Parent = mainFrame
autoRefreshToggle.BackgroundColor3 = Color3.fromRGB(60, 160, 80)
autoRefreshToggle.BorderSizePixel = 0
autoRefreshToggle.Position = UDim2.new(0, 130, 1, -80)
autoRefreshToggle.Size = UDim2.new(0, 110, 0, 35)
autoRefreshToggle.Font = Enum.Font.GothamBold
autoRefreshToggle.Text = "⏸ Авто: вкл"
autoRefreshToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoRefreshToggle.TextSize = 14

-- Кнопка остановки всех
stopAllButton.Name = "StopAllButton"
stopAllButton.Parent = mainFrame
stopAllButton.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
stopAllButton.BorderSizePixel = 0
stopAllButton.Position = UDim2.new(0, 250, 1, -80)
stopAllButton.Size = UDim2.new(0, 110, 0, 35)
stopAllButton.Font = Enum.Font.GothamBold
stopAllButton.Text = "⏹ Стоп все"
stopAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopAllButton.TextSize = 14

-- Кнопка закрытия
closeButton.Name = "CloseButton"
closeButton.Parent = mainFrame
closeButton.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
closeButton.BorderSizePixel = 0
closeButton.Position = UDim2.new(0, 370, 1, -80)
closeButton.Size = UDim2.new(0, 110, 0, 35)
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "✕ Закрыть"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14

-- Переменные
local playingSounds = {} -- Текущие играющие звуки
local autoRefresh = true
var
local refreshConnection = nil
local lastUpdateTime = 0

-- Функция форматирования времени
local function formatTime(seconds)
    if not seconds or seconds < 0 then return "0:00" end
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%d:%02d", mins, secs)
end

-- Функция получения пути к объекту
local function getObjectPath(obj)
    if not obj then return "Unknown" end
    
    local path = {}
    local current = obj
    
    while current and current ~= game do
        table.insert(path, 1, current.Name or "?")
        current = current.Parent
    end
    
    if current == game then
        table.insert(path, 1, "Game")
    end
    
    return table.concat(path, ".")
end

-- Функция создания элемента для играющего звука
local function createPlayingSoundItem(sound, soundInfo)
    local itemFrame = Instance.new("Frame")
    local nameLabel = Instance.new("TextLabel")
    local idLabel = Instance.new("TextLabel")
    local timeLabel = Instance.new("TextLabel")
    local volumeLabel = Instance.new("TextLabel")
    local pathLabel = Instance.new("TextLabel")
    local stopBtn = Instance.new("TextButton")
    local copyBtn = Instance.new("TextButton")
    local progressBar = Instance.new("Frame")
    local progressFill = Instance.new("Frame")
    
    itemFrame.Name = "PlayingSoundItem"
    itemFrame.Parent = playingList
    itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    itemFrame.BorderSizePixel = 0
    itemFrame.Size = UDim2.new(1, -10, 0, 100)
    itemFrame.ClipsDescendants = true
    
    -- Индикатор "Сейчас играет" (анимированная полоска)
    local playingIndicator = Instance.new("Frame")
    playingIndicator.Name = "PlayingIndicator"
    playingIndicator.Parent = itemFrame
    playingIndicator.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    playingIndicator.BorderSizePixel = 0
    playingIndicator.Position = UDim2.new(0, 0, 0, 0)
    playingIndicator.Size = UDim2.new(0, 5, 1, 0)
    
    -- Название звука
    nameLabel.Name = "NameLabel"
    nameLabel.Parent = itemFrame
    nameLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Position = UDim2.new(0, 15, 0, 5)
    nameLabel.Size = UDim2.new(0, 300, 0, 20)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = "🎵 " .. (soundInfo.name or "Без названия")
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 16
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    
    -- ID звука
    idLabel.Name = "IDLabel"
    idLabel.Parent = itemFrame
    idLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    idLabel.BackgroundTransparency = 1
    idLabel.Position = UDim2.new(0, 15, 0, 28)
    idLabel.Size = UDim2.new(0, 200, 0, 18)
    idLabel.Font = Enum.Font.Gotham
    idLabel.Text = "ID: " .. (soundInfo.id or "N/A")
    idLabel.TextColor3 = Color3.fromRGB(180, 180, 255)
    idLabel.TextSize = 12
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Время
    timeLabel.Name = "TimeLabel"
    timeLabel.Parent = itemFrame
    timeLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Position = UDim2.new(0, 15, 0, 48)
    timeLabel.Size = UDim2.new(0, 150, 0, 18)
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.Text = "⏱ " .. formatTime(soundInfo.time) .. " / " .. formatTime(soundInfo.length)
    timeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    timeLabel.TextSize = 12
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Громкость
    volumeLabel.Name = "VolumeLabel"
    volumeLabel.Parent = itemFrame
    volumeLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    volumeLabel.BackgroundTransparency = 1
    volumeLabel.Position = UDim2.new(0, 180, 0, 48)
    volumeLabel.Size = UDim2.new(0, 100, 0, 18)
    volumeLabel.Font = Enum.Font.Gotham
    volumeLabel.Text = "🔊 " .. math.floor((soundInfo.volume or 0) * 100) .. "%"
    volumeLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
    volumeLabel.TextSize = 12
    volumeLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Путь
    pathLabel.Name = "PathLabel"
    pathLabel.Parent = itemFrame
    pathLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    pathLabel.BackgroundTransparency = 1
    pathLabel.Position = UDim2.new(0, 15, 0, 68)
    pathLabel.Size = UDim2.new(0, 350, 0, 18)
    pathLabel.Font = Enum.Font.Gotham
    pathLabel.Text = "📁 " .. (soundInfo.path or "Unknown")
    pathLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    pathLabel.TextSize = 11
    pathLabel.TextXAlignment = Enum.TextXAlignment.Left
    pathLabel.TextTruncate = Enum.TextTruncate.AtEnd
    
    -- Прогресс бар (фон)
    progressBar.Name = "ProgressBar"
    progressBar.Parent = itemFrame
    progressBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    progressBar.BorderSizePixel = 0
    progressBar.Position = UDim2.new(0, 15, 1, -25)
    progressBar.Size = UDim2.new(0, 360, 0, 8)
    
    -- Прогресс (заполнение)
    progressFill.Name = "ProgressFill"
    progressFill.Parent = progressBar
    progressFill.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    progressFill.BorderSizePixel = 0
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    
    -- Кнопка стоп
    stopBtn.Name = "StopBtn"
    stopBtn.Parent = itemFrame
    stopBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
    stopBtn.BorderSizePixel = 0
    stopBtn.Position = UDim2.new(1, -120, 0, 30)
    stopBtn.Size = UDim2.new(0, 50, 0, 30)
    stopBtn.Font = Enum.Font.GothamBold
    stopBtn.Text = "⏹"
    stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopBtn.TextSize = 20
    
    -- Кнопка копировать ID
    copyBtn.Name = "CopyBtn"
    copyBtn.Parent = itemFrame
    copyBtn.BackgroundColor3 = Color3.fromRGB(60, 160, 80)
    copyBtn.BorderSizePixel = 0
    copyBtn.Position = UDim2.new(1, -60, 0, 30)
    copyBtn.Size = UDim2.new(0, 50, 0, 30)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.Text = "📋"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.TextSize = 20
    
    -- Обработчик стопа
    stopBtn.MouseButton1Click:Connect(function()
        pcall(function()
            sound:Stop()
            statusLabel.Text = "⏹ Остановлен: " .. soundInfo.name
        end)
    end)
    
    -- Обработчик копирования
    copyBtn.MouseButton1Click:Connect(function()
        local success = pcall(function()
            setclipboard(soundInfo.id)
        end)
        if success then
            statusLabel.Text = "✅ ID скопирован: " .. soundInfo.id
            wait(1.5)
            statusLabel.Text = "Слежу за звуками..."
        end
    end)
    
    -- Функция обновления прогресса
    local function updateProgress()
        if not sound or not sound.Parent then return end
        
        local success, time = pcall(function()
            return sound.TimePosition
        end)
        
        if success and time then
            local progress = (time / soundInfo.length) * 360
            if progress > 0 and progress <= 360 then
                progressFill.Size = UDim2.new(0, progress, 1, 0)
            end
            timeLabel.Text = "⏱ " .. formatTime(time) .. " / " .. formatTime(soundInfo.length)
        end
    end
    
    -- Обновляем прогресс каждые 0.5 секунды
    local progressConnection
    progressConnection = game:GetService("RunService").Stepped:Connect(function()
        if sound and sound.Parent and sound.Playing then
            updateProgress()
        else
            if progressConnection then
                progressConnection:Disconnect()
            end
        end
    end)
    
    return itemFrame, progressConnection
end

-- Функция поиска всех играющих звуков
local function findPlayingSounds()
    local foundSounds = {}
    
    -- Функция рекурсивного поиска звуков
    local function searchInContainer(container)
        if not container then return end
        
        local success, children = pcall(function()
            return container:GetChildren()
        end)
        
        if not success or not children then return end
        
        for _, obj in ipairs(children) do
            if not obj then continue end
            
            -- Проверяем является ли звуком
            local isSound = pcall(function() return obj:IsA("Sound") end)
            if isSound and obj:IsA("Sound") then
                -- Проверяем играет ли
                local isPlaying = pcall(function() return obj.Playing end)
                if isPlaying and obj.Playing then
                    local soundInfo = {
                        object = obj,
                        name = obj.Name,
                        id = tostring(obj.SoundId):gsub("rbxassetid://", ""),
                        volume = obj.Volume,
                        time = obj.TimePosition,
                        length = obj.TimeLength,
                        path = getObjectPath(obj),
                        playing = true
                    }
                    table.insert(foundSounds, soundInfo)
                end
            end
            
            -- Рекурсивно ищем в папках и моделях
            local isFolder = pcall(function() return obj:IsA("Folder") end)
            local isModel = pcall(function() return obj:IsA("Model") end)
            local isTool = pcall(function() return obj:IsA("Tool") end)
            
            if isFolder or isModel or isTool then
                searchInContainer(obj)
            end
        end
    end
    
    -- Ищем во всех сервисах
    local services = {
        workspace, game:GetService("ReplicatedStorage"),
        game:GetService("ServerStorage"), game:GetService("Players"),
        game:GetService("Lighting"), game
    }
    
    for _, service in ipairs(services) do
        if service then
            pcall(function() searchInContainer(service) end)
        end
    end
    
    return foundSounds
end

-- Функция обновления списка
local function refreshList()
    -- Очищаем список
    for _, child in ipairs(playingList:GetChildren()) do
        if child:IsA("Frame") and child.Name == "PlayingSoundItem" then
            child:Destroy()
        end
    end
    
    -- Ищем играющие звуки
    local currentSounds = findPlayingSounds()
    
    -- Создаем элементы для каждого звука
    for _, soundInfo in ipairs(currentSounds) do
        local item, connection = createPlayingSoundItem(soundInfo.object, soundInfo)
        -- Сохраняем соединение для очистки
        table.insert(playingSounds, {item = item, connection = connection})
    end
    
    -- Обновляем размер Canvas
    playingList.CanvasSize = UDim2.new(0, 0, 0, #currentSounds * 105)
    
    -- Обновляем статус
    local count = #currentSounds
    if count > 0 then
        statusLabel.Text = "🎵 Играет звуков: " .. count
        stopAllButton.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
    else
        statusLabel.Text = "⏸ Нет играющих звуков"
        stopAllButton.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    end
    
    lastUpdateTime = tick()
end

-- Функция остановки всех звуков
local function stopAllPlayingSounds()
    local stopped = 0
    
    -- Ищем все играющие звуки и останавливаем
    local function stopInContainer(container)
        if not container then return end
        
        local success, children = pcall(function()
            return container:GetChildren()
        end)
        
        if not success or not children then return end
        
        for _, obj in ipairs(children) do
            if not obj then continue end
            
            local isSound = pcall(function() return obj:IsA("Sound") end)
            if isSound and obj:IsA("Sound") then
                local isPlaying = pcall(function() return obj.Playing end)
                if isPlaying and obj.Playing then
                    pcall(function()
                        obj:Stop()
                        stopped = stopped + 1
                    end)
                end
            end
            
            local isFolder = pcall(function() return obj:IsA("Folder") end)
            local isModel = pcall(function() return obj:IsA("Model") end)
            
            if isFolder or isModel then
                stopInContainer(obj)
            end
        end
    end
    
    local services = {workspace, game:GetService("ReplicatedStorage"), game:GetService("ServerStorage"), game}
    
    for _, service in ipairs(services) do
        if service then
            pcall(function() stopInContainer(service) end)
        end
    end
    
    statusLabel.Text = "⏹ Остановлено звуков: " .. stopped
    refreshList()
end

-- Функция автообновления
local function toggleAutoRefresh()
    autoRefresh = not autoRefresh
    
    if autoRefresh then
        autoRefreshToggle.Text = "⏸ Авто: вкл"
        autoRefreshToggle.BackgroundColor3 = Color3.fromRGB(60, 160, 80)
        refreshTimer.Text = "🔄 Обновление: вкл"
        refreshTimer.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        -- Запускаем автообновление
        if refreshConnection then
            refreshConnection:Disconnect()
        end
        
        refreshConnection = game:GetService("RunService").Stepped:Connect(function()
            if autoRefresh and tick() - lastUpdateTime > 1 then -- Обновляем каждую секунду
                refreshList()
            end
        end)
    else
        autoRefreshToggle.Text = "▶ Авто: выкл"
        autoRefreshToggle.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        refreshTimer.Text = "🔄 Обновление: выкл"
        refreshTimer.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        if refreshConnection then
            refreshConnection:Disconnect()
            refreshConnection = nil
        end
    end
end

-- Обработчики кнопок
refreshButton.MouseButton1Click:Connect(function()
    pcall(refreshList)
end)

stopAllButton.MouseButton1Click:Connect(function()
    pcall(stopAllPlayingSounds)
end)

closeButton.MouseButton1Click:Connect(function()
    -- Очищаем все соединения
    if refreshConnection then
        refreshConnection:Disconnect()
    end
    
    for _, soundData in ipairs(playingSounds) do
        if soundData.connection then
            soundData.connection:Disconnect()
        end
    end
    
    pcall(function()
        screenGui:Destroy()
    end)
end)

autoRefreshToggle.MouseButton1Click:Connect(function()
    pcall(toggleAutoRefresh)
end)

-- Запускаем автообновление по умолчанию
toggleAutoRefresh()

-- Эффекты при наведении
local function addHoverEffect(button, normalColor, hoverColor)
    if not button then return end
    button.MouseEnter:Connect(function()
        pcall(function() button.BackgroundColor3 = hoverColor end)
    end)
    button.MouseLeave:Connect(function()
        pcall(function() button.BackgroundColor3 = normalColor end)
    end)
end

addHoverEffect(refreshButton, Color3.fromRGB(65, 105, 225), Color3.fromRGB(85, 125, 245))
addHoverEffect(stopAllButton, Color3.fromRGB(220, 80, 80), Color3.fromRGB(240, 100, 100))
addHoverEffect(closeButton, Color3.fromRGB(150, 150, 150), Color3.fromRGB(170, 170, 170))
addHoverEffect(autoRefreshToggle, autoRefresh and Color3.fromRGB(60, 160, 80) or Color3.fromRGB(150, 150, 150), 
               autoRefresh and Color3.fromRGB(80, 180, 100) or Color3.fromRGB(170, 170, 170))

print("✅ Трекер играющих звуков загружен!")
