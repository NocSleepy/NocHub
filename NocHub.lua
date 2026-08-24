-----------------------
-- UI LIBRARY --
-----------------------
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-----------------------
-- MY LIBRARIES --
-----------------------
local TestLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/NocSleepy/Libraries/refs/heads/main/Test/TestLibrary.lua"))()
local Connection = loadstring(game:HttpGet("https://raw.githubusercontent.com/NocSleepy/Libraries/refs/heads/main/Connection/Connection.lua"))()

TestLibrary:TestFunction()

-----------------------
-- SERVICES --
-----------------------
local Players = cloneref(game:GetService('Players'))
local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local RunService = cloneref(game:GetService('RunService'))
local HttpService = cloneref(game:GetService('HttpService'))

-----------------------
-- PLAYER STUFF --
-----------------------
local plr  = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum  = char:WaitForChild('Humanoid')
local hrp = char:FindFirstChild('HumanoidRootPart')

local oldPlayerSpeed = char:GetAttribute('SpeedMultiplier')

-----------------------
-- VARIABLES --
-----------------------

-- @SOME ANTI CHEAT BYPASS STUFF
local index
local newindex
local namecall

local ToHook = {
	["walkspeed"] = hum.WalkSpeed,
	["jumppower"] = hum.JumpPower
}

-- @SOME HITVBOX THINGS
local IsPlayerHitboxESPOn = false
local IsNPCHitboxESPOn = false

-- @CONNECTIONS
local _connectionOfCharFAdded
local _connectionOfCharFRemoved

local _connectionOfEnemiesFAdded
local _connectionOfEnemiesFRemoved
local _connectionOfEnemyPropertyChanged


-- @TABLES
local FastAttackAPI = {}

-- @LOADED CHARACTERS
local LoadedCharacters = {}
local LoadedEnemies = {}

local stoppedConnection
local stoppedConnections = {}

-- @HITBOX STUFF
local HitboxConfig = {
    PlayerHitboxSizeDefault = Vector3.new(2, 2, 2),
    PlayerHitboxSize = Vector3.new(2, 2, 2),

    NPCHitboxSizeDefault = Vector3.new(2, 2, 2),
    NPCHitboxSize = Vector3.new(2, 2, 2)
}

-- @AUTO FARM
local AutoFarmState = {}
local AutoFarmConfig = {
    AUTO_FARM_TYPE = "",
    TWEEN_SPEED = 0 -- for now
}

-----------------------
-- FUNCTIONS --
-----------------------
function addConnectionToTargetPlayer(param, targetChar, connectionName, connectionTask)
    if param:lower() == 'new' then
        if LoadedCharacters[targetChar] == nil then
            LoadedCharacters[targetChar] = {}
        end
    end

    if param:lower() == 'add' then
        if LoadedCharacters[targetChar] ~= nil then
            LoadedCharacters[targetChar][connectionName] = connectionTask
        end
    end
end

function stopConnectionFromTargetPlayer(targetChar, connectionName)
    if LoadedCharacters[targetChar] ~= nil and LoadedCharacters[targetChar][connectionName] ~= nil then
        LoadedCharacters[targetChar][connectionName]:Disconnect()
        return connectionName
    end
end

function clearConnectionFromTargetPlayer(targetChar, connectionName)
    if LoaadedCharacters[targetChar] ~= nil and LoadedCharacters[targetChar][connectionName] ~= nil then
        LoadedCharacters[targetChar][connectionName] = nil
        stoppedConnections[targetChar][connectionName] = nil
    end
end

function PlayerSpeedController(val)
    if typeof(val) ~= 'number' then
        return false
    end

    char:SetAttribute('SpeedMultiplier', val)
end

function FastAttackController(val)
    if typeof(val) ~= 'boolean' then
        return false
    end

    if val then
        print('STARTING THE FAST ATTACK!')
    end

    if not val then
        print('STOPPING THE FAST ATTACK')
    end
end

function HitboxController(param, doWillShowESP)
    if param:lower() == 'players' then
        print('PASSED THE PARAM ARGUMENT')
        if doWillShowESP and IsPlayerHitboxESPOn then
            local CharactersF = workspace:FindFirstChild('Characters')

            for _, instances in pairs(CharactersF:GetChildren()) do
                if (instances:IsA('Model')) and instances.Name ~= char.Name then
                    local targetPlayerHRP = instances:FindFirstChild('HumanoidRootPart')

                    if targetPlayerHRP.Transparency == 1 then
                        targetPlayerHRP.Transparency = 0.5
                        targetPlayerHRP.Color =  Color3.fromHex('#ff0000')
                        targetPlayerHRP.Size = HitboxConfig.PlayerHitboxSize
                    end

                    if LoadedCharacters[instances] == nil then
                        addConnectionToTargetPlayer('new', instances)

                        addConnectionToTargetPlayer('new', instances, '_connectdionOfHRPPropertySizeChanged', targetPlayerHRP:GetPropertyChangedSignal('Size'):Connect(function()
                            targetPlayerHRP.Size = HitboxConfig.PlayerHitboxSize
                        end))

                        addConnectionToTargetPlayer('add', instances, '_connectionOfHRPPropertyColorChanged', targetPlayerHRP:GetPropertyChangedSignal('Color'):Connect(function()
                            targetPlayerHRP.Color = Color3.fromHex('#ff0000')
                        end))
                    end
                else
                    return false
                end
                
                _connectionOfCharFAdded = CharactersF.ChildAdded:Connect(function(addedInstance)
                    local IsAModel = addedInstance:IsA('Model')
                    
                    if IsAModel then
                        local targetPlayerHRP = addedInstance:FindFirstChild('HumanoidRootPart')

                        if (targetPlayerHRP) and targetPlayerHRP.Transparency == 1 then
                            targetPlayerHRP.Transparency = 0.5
                            targetPlayerHRP.Color =  Color3.fromHex('#ff0000')
                            targetPlayuerHRP.Size = HitboxConfig.PlayerHitboxSize
                        end

                        if LoadedCharacters[addedInstance] == nil then
                            addConnectionToTargetPlayer('new', addedInstance)
                            
                            addConnectionToTargetPlayer('add', addedInstance, targetPlayerHRP:GetPropertyChangedSignal('Size'):Connect(function()
                                targetPlayerHRP.Size = HitboxConfig.PlayerHitboxSize
                            end))

                            addConnectionToTargetPlayer('add', addedInstance, targetPlayerHRP:GetPropertyChangedSignal('Color'):Connect(function()
                                targetPlayerHRP.Color = Color3.fromHex('#ff0000')
                            end))
                        end
                    end
                end)

                _connectionOfCharFRemoved = CharactersF.ChildRemoved:Connect(function(removedInstance)
                    if removedInstance:IsA('Model') then
                        if LoadedCharacters[removedInstance] ~= nil then

                            for targetCharInstance, connectionName in pairs(LoadedCharacters) do
                                if targetCharInstance == removedInstance then
                                    stoppedConnection = stopConnectionFromTargetPlayer(targetCharInstance, connectionName)
                                    stoppedConnections = {
                                        [targetCharInstance] = { [connectionName] = stoppedConnection }
                                    }
                                end
                            end
                            
                            stoppedConnection = nil

                            
                            for targetCharInstance, connectionName in pairs(stoppedConnections) do
                                if (stoppedConnections[targetCharInstance] ~= nil) and stoppedConnections[targetCharInstance][connectionName] then
                                    pcall(clearConnectionFromTargetPlayer, targetCharInstance, connectionName)
                                end
                            end

                            stoppedConnections[removedInstance] = nil
                            LoadedCharacters[removedInstance] = nil
                        end
                    end
                end)
            end  
          
            return true
        end

        if not doWillShowESP and not IsPlayerHitboxESPOn  then
            local CharactersF = workspace:FindFirstChild('Characters')
            
            for targetCharInstance, _ in pairs(CharactersF:GetChildren()) do
                local targetHRP = targetCharInstance:FindFirstChild('HumanoidRootPart')

                if targetHRP then
                    targetHRP.Transparency = 1
                    targetHRP.Size = HitboxConfig.PlayerHitboxSizeDefault
                end
            end
            
        
            for targetCharInstance, connectionName in pairs(LoadedCharacters) do
                if LoadedCharacters[targetCharInstance] ~= nil then
                    stopConnectionFromTargetPlayer(targetChar, connectionName)
                    clearConnectionFromTargetPlayer(targetChar, connectionName)
                end
            end
            
            if _connectionOfCharFAdded then
                _connectionOfCharFAdded:Disconnect()
                _connectionOfCharFAdded = nil
            end

            if _connectionOfCharFRemoved then
                _connectionOfCharFRemoved:Disconnect()
                _connectionOfCharFRemoved = nil
            end
        end
    end

    if param:lower() == 'npcs' then
        print('PASSED THE PARAM ARGUMENT')
        if doWillShowESP and IsNPCHitboxESPOn then
            print('STARTING THE NPC HITBOX ESP')
            local Enemies = workspace:FindfirstChild('Enemies')
            
            for _, instances in pairs(Enemies:GetChildren()) do
                if instances:IsA('Model') then
                    local EnemyHRP = instances:FindFirstChild('HumanoidRootPart')

                    if (EnemyHRP) and EnemyHRP.Transparency == 1 then
                        EnemyHRP.Tranaparency = 0.5
                        EnemyHRP.Color = Color3.fromHex('#ff0000')
                        EnemyHRP.Size = HitboxConfig.NPCHitboxSize
                    end
                end
            end
            
            _connectionOfEnemiesFAdded = Enemies.ChildAdded:Connect(function(addedInstance)
                print('some debug for child added function i think')
                local IsAModel = addedInstance:IsA('Model')
                
                if (IsAModel) and addedInstance:FindFirstChild('HumanoidRootPart') then
                    print('WORKING ON THE ENEMY NPCS')

                    local EnemyHRP = addedInstance:FindFirstChild('HumanoidRootPart')
                    
                    if EnemyHRP then
                        EnemyHRP.Transparency = 0.5
                        EnemyHRP.Color = Color3.fromHex('#ff0000')
                        EnemyHRP.Size = HitboxConfig.NPCHitboxSize
                    end
                end
            end)

            _connectionOfEnemiesFRemoved = Enemies.ChildRemoved:Connect(function(removedInstance)
                print('some debug for child removed function i think')
                local IsAModel = removedInstance:FindFirstChild('HumanoidRootPart')

                if IsAModel then
                    local EnemyHRP = removedInstance:FindFirstChild('HumanoidRootPart')
                    
                    if EnemyHRP then
                        EnemyHRP.Transparency = 1
                        EnemyHRP.Size = HitboxConfig.NPCHitboxSizeDefault
                    end
                end
            end)

            return true
        end

        if not doWillShowESP and not isNPCHitboxESPOn then
            print('STOPPING THE NPC HITBOX ESP')
            local Enemies = workspace:FindFirstChild('Enemies')

            for _, instances in pairs(Enemies:GetChildren()) do
                if instances:IsA('Model') then
                    local EnemyHRP = instances:FindFirstChild('HumanoidRootPart')

                    EnemyHRP.Transparency = 1
                    EnemyHRP.Size = HitboxConfig.NPCHitboxSizeDefault
                end
            end

            if _connectionOfEnemiesFAdded then
                _connectionOfEnemiesFAdded:Disconnect()
                _connectionOfEnemiesFAdded = nil
            end

            if _connectionOfEnemiesFRemoved then
                _connectionOfEnemiesFRemoved:Disconnect()
                _connectionOfEnemiesFRemoved = nil
            end

            return true
        end
    end
end

function HitboxSizeController(param, val)
    if typeof(param) ~= 'string' or typeof(val) ~= 'number' then
        return false
    end

    if param:lower() == 'player' then
        HitboxConfig.PlayerHitboxSize = Vector3.new(val, val, val)
        return true
    end

    if param:lower() == 'npc' then
        HitboxConfig.NPCHitboxSize = Vector3.new(val, val, val)
        return true
    end
end

-- UI CONFIGURATION --

WindUI:Notify({
    Title = "Message from developer!",
    Content = "Thanks for using my script! Discord: noctxy._.",
    Duration = 3,
    Icon = 'door-open'
})

local Window = WindUI:CreateWindow({
    Title = "Noc Hub - Blox Fruits",
    Author = "Just a regular guy (Sleepy) tarafından tasarlandı!",
    Folder = "NocHub",
    Size = UDim2.fromOffset(580, 490),
    Theme = "Dark",
    HidePanelBackground = false,
    Acrylic = false,
    HideSearchBar = false,
    SideBarWidth = 200,

    OpenButton = {
		Title = "Open The Noc Hub",
		CornerRadius = UDim.new(1, 0),
		StrokeThickness = 3,
		Enabled = true,
		Draggable = true,
		OnlyMobile = false,
		Scale = 0.5,

		Color = ColorSequence.new( -- gradient
			Color3.fromHex("#30FF6A"),
			Color3.fromHex("#e7ff2f")
		),
	},

    Topbar = {
		Height = 44,
		ButtonsType = "Mac", -- Default or Mac
	},

    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            print('oh okay')
        end,
    },

    KeySystem = {
        Key = { "NOKEY", "WHY IS CHLOE SO DUMB" },
        Note = "Noc Hub Key System\nDiscord: noctxy._.",
        SaveKey = false,
    }
})

Window:Tag({
    Title = "Sleepy",
    Icon = "github",
    Color = Color3.fromHex("#DBCB6B"),
    Radius = 13
})

Window:Tag({
    Title = "noctxy._.",
    Icon = "discord",
    Color =  Color3.fromHex("#1551c0"),
    Radius = 13
})

local FeatureSection = Window:Section({
    Title = "EXPLOIT SECTION",
    Opened = true,
})

local TABS = {
    About = FeatureSection:Tab({
        Title = "Hakkında", Icon = 'door-open'
    }),

    Main = FeatureSection:Tab({
        Title = "Ana Sayfa", Icon = 'door-open'
    }),

     Player = FeatureSection:Tab({
        Title = "Oyuncu", Icon = 'door-open'
    }),

    Raid = FeatureSection:Tab({
        Title = "Raid", Icon = 'door-open'
    }),

    Sea = FeatureSection:Tab({
        Title = "Sea", Icon = 'door-open'
    }),

    Other = FeatureSection:Tab({
        Title = "Other", Icon = 'door-open'
    }),
}

-----------------------
-- AUTO FARM SECTION --
-----------------------
local StartAutoFarm = TABS.Main:Toggle({
    Title = "Auto Farm'ı Başlat!",
    Desc = "AUTO FARMI BAŞLATIR",

    Callback = function(value)
        print('AUTO FARM: ' .. value)
    end,
})

TABS.Main:Space() -- some function to create space

local AutoFarmTypeConfiguration = TABS.Main:Dropdown({
    Title = "Auto Farm Tipi",

    Values = {
        "Level",
        "Bone",
        "Fruit",
        "Bounty",
        "Honor",
    },

    Value = nil,
    AllowNone = true,

    Callback = function(selectedValue)
        AutoFarmConfig.AUTO_FARM_TYPE = selectedValue
    end,
})

local AutoFarmSpeedConfiguration = TABS.Main:Dropdown({
    Title = "Auto Farm Hızı",

    Values = {
        "SUPER FAST",
        "A LITTLE FAST",
        "NORMAL SPEED",
        "SLOW SPEED"
    },

    Value = nil,
    AllowNone = true,

    Callback = function(selectedValue)
        print(`Auto Farm Speed {selectedValue}`)
    end,
})

-----------------------
-- PLAYER SECTION --
-----------------------
local ResetPlayerSpeed = TABS.Player:Button({
    Title = "Koşma hızını sıfırla",
    Desc = "Koşma hızını sıfırlar ve eski haline getirir",

    Callback = function()
        PlayerSpeedController(oldPlayerSpeed)
    end,
})

local PlayerSpeed = TABS.Player:Slider({
    Title = "Koşma Hızı",
    Desc = "Koşma hızını ayarlayabilirsin!",

    IsToolTip = true,
    IsTextbox = true,
    Width = 100,
    Step = 1,

    Value = {
        Min = 1,
        Max = 30,
        Default = oldPlayerSpeed
    },

    Callback = function(sliderValue)
        PlayerSpeedController(sliderValue)
    end,
})

TABS.Player:Space()

local MevlanaSpinSpeed = TABS.Player:Toggle({
    Title = "Mevlana Spin'i başlat!",
    Desc = "Mevlana gibi dönmeyi başlatır/durdurur!",

    Callback = function(value)
        print('value')
    end,
})

local MevlanaSpinSpeedConfiguration = TABS.Player:Slider({
    Title = "Mevlana Spin Speed",
    Desc = "Mevlana Spin'in hızını ayarlayabilirsin!",

    IsToolTip = true,
    IsTextbox = true,
    Width = 100,
    Step = 1,

    Value = {
        Min = 1,
        Max = 20,
        Default = 1
    },

    Callback = function(sliderValue)
        print(sliderValue)
    end,
})

-----------------------
-- OTHER SECTION --
-----------------------
local FastAttack = TABS.Other:Toggle({
    Title = "Fast Attack",
    Desc = "Fast Attack'ı başlatır/durdurur!",

    Callback = function(selectedValue)
        FastAttackController(selectedValue)
        print('Fast Attack State: '.. selectedValue)
    end,
})

TABS.Other:Space()

local PlayerHitboxESP = TABS.Other:Toggle({
    Title = "Oyuncu Hitbox ESP",
    Desc = "Shows the hitboxes of players",

    Callback = function(selectedValue)
        HitboxController('players', selectedValue)
    end,
})

local NPCHitboxESP = TABS.Other:Toggle({
    Title = "NPC Hitbox ESP",
    Desc = "Shows the hitboxes of the npcs",

    Callback = function(selectedValue)
        IsNPCHitboxESPOn = selectedValue
        HitboxController('npcs', selectedValue)
    end,
})

TABS.Other:Space()

local PlayerHitboxSizeConfiguration = TABS.Other:Slider({
    Title = "Oyuncu Hitbox Genişletici",
    Desc = "Oyuncuların Hitboxunu genişletmesine/küçültmesine sağlar",

    IsToolTip = true,
    IsTextbox = true,

    Width = 100,
    Step = 1,

    Value = {
        Min = 1,
        Max = 40,
        Default = HitboxConfig.PlayerHitboxSize
    },

    Callback = function(sliderValue)
        HitboxSizeController('player', sliderValue)
    end,
})

local NPCHitboxSizeConfiguration = TABS.Other:Slider({
    Title = "NPC Hitbox Genişletici",
    Desc = "NPClerin Hitboxunu genişletmesine/küçültmesine sağlar",

    IsToolTip = true,
    IsTextbox = true,

    Width = 100,
    Step = 1,

    Value = {
        Min = 1,
        Max = 40,
        Default = HitboxConfig.NPCHitboxSizeDefault
    },

    Callback = function(sliderValue)
        HitboxSizeController('npc', sliderValue)
    end,
})

TABS.About:Select()

--[[
index = hookmetamethod(game,"__index", function(self, property)
	if not checkcaller() and self:IsA("Humanoid") and self:IsDescendantOf(player.Character) and ToHook[property:lower()] then
		--print(property, " is being called, here is a fake value : ", ToHook[property:lower()])
		return ToHook[property:lower()]
	end
	return index(self,property)
end)

newindex = hookmetamethod(game,"__newindex", function(self, property, NewValue)
	if not checkcaller() and self:IsA("Humanoid") and self:IsDescendantOf(player.Character) and ToHook[property:lower()] then
		--print(property, " is being edited, here is the new fake value : ", NewValue)
		ToHook[property:lower()] = NewValue
		return ToHook[property:lower()]
	end
	return newindex(self,property, NewValue)
end)

namecall = hookmetamethod(game,"__namecall", function(self, ...)
	local namecallmethod = getnamecallmethod()
	if self == player and namecallmethod == "Kick" then
		print("NO KICK")
		return 
	end
	return namecall(self,...)
end)
]]--
