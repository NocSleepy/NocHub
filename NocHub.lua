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
-- SOME VARIABLES AND PATHS ABOUT GAME
local Characters = workspace:FindFirstChild('Characters')
local Enemies = workspace:FindFirstChild('Enemies')

-- @SOME ANTI CHEAT BYPASS STUFF
local index
local newindex
local namecall

local ToHook = {
	["walkspeed"] = hum.WalkSpeed,
	["jumppower"] = hum.JumpPower
}

local LoadedCharacters = {}
local LoadedEnemies = {}

-- @CONNECTIONS
local _connectionOfCharFAdded = Characters.ChildAdded:Connect(function(addedInstance)
    if (addedInstance:IsA('Model')) and LoadedCharacters[addedInstance] == nil then
        local targetHRP = addedInstance:FindFirstChild('HumanoidRootPart')

        LoadedCharacters[addedInstance] = {
            defaultHitboxSize = targetHRP.Size
        }
    end
end)

local _connectionOfCharFRemoved = Characters.ChildRemoved:Connect(function(removedInstance)
    if (removedInstance:IsA('Model')) and LoadedCharacters[removedInstance] ~= nil then
        LoadedCharacters[removedInstance] = nil
    end
end)

local _connectionOfEnemiesFAdded = Enemies.ChildAdded:Connect(function(addedInstance)
    if (addedInstance:IsA('Model')) and LoadedEnemies[addedInstance] == nil then
        local targetHRP = addedInstance:FindFirstChild('HumanoidRootPart')

        LoadedEnemies[addedInstance] = {
            defaultHitboxSize = targetHRP.Size
        }
    end
end)

local _connectionOfEnemiesFRemoved = Enemies.ChildRemoved:Connect(function(removedInstance)
    if (removedInstance:IsA('Model')) and LoadedEnemies[removedInstance] ~= nil then
       LoadedEnemies[removedInstance] = nil
    end
end)


-- @TABLES
local FastAttackAPI = {}


-- @SPIN STUFF
local SECONDS_PER_ROTATION = 3 -- 1 full rotation in 3 5seconds since we chose 1.5

-- @HITBOX STUFF
local HitboxConfig = {
    PlayerHitboxSize = nil,
    NPCHitboxSize = nil
}

-- @AUTO FARM
local AutoFarmState = {}
local AutoFarmConfig = {
    AUTO_FARM_TYPE = "",
    TWEEN_SPEED = "" -- for now
}

-----------------------
-- FUNCTIONS --
------------------------
function PlayerSpeedController(val)
    if typeof(val) ~= 'number' then
        return false
    end

    char:SetAttribute('SpeedMultiplier', val)
end

function MevlanaSpinController(val)
    if not rotateCharacter or rotateCharacter == nil and val then
        rotateCharacter = RunService.RenderStepped:Connect(function(dt)
            if char then
                local rotation = (360 / SECONDS_PER_ROTATION)

                hrp.CFrame *= CFrame.Angles(0, math.rad(rotation), 0)
            end
        end)
    end
    
    if not val and rotateCharacter then
        rotateCharacter:Disconnect()
        rotateCharacter = nil
    end
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
        if doWillShowESP then
            for charInstance, _ in pairs(LoadedCharacters) do
                if charInstance:IsA('Model') then
                    local targetHRP = charInstance:FindFirstChild('HumanoidRootPart')
                    
                    if (targetHRP) and targetHRP.Size == LoadedCharacters[charInstance].defaultHitboxSize or targetHRP.Transparency == 1 then
                        targetHRP.Transparency = 0.75
                        targetHRP.Size = HitboxConfig.PlayerHitboxSize
                        targetHRP.Color =  Color3.fromHex('#ff0000')
                    end
                end
            end
        end
        
        if not doWillShowESP then
            for charInstance, _ in pairs(LoadedCharacters) do
                if charInstance:IsA('Model') then
                    local targetHRP = charInstance:FindFirstChild('HumanoidRootPart')
                    
                    if (targetHRP) and targetHRP.Transparency ~= 1 then
                        targetHRP.Transparency = 1
                        targetHRP.Size = LoadedCharacters[charInstance].defaultHitboxSize
                    end
                end
            end
        end
    end
    
    if param:lower() == 'npcs' then
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

char:GetAttributeChangedSignal('PlayerHitboxESPOn'):Connect(function()
    local newValue = char:GetAttribute('PlayerHitboxESPOn')
end)

char:GetAttributeChangedSignal('NPCHitboxESPOn'):Connect(function()
    local newValue = char:GetAttribute('NPCHitboxESPOn')
end)

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

    Callback = function(selectedValue)
        MevlanaSpinController(selectedValue)
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
        Default = SECONDS_PER_ROTATION
    },

    Callback = function(sliderValue)
        SECONDS_PER_ROTATION = sliderValue
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
        char:SetAttribute('PlayerHitboxESPOn', selectedValue)

        HitboxController('players', selectedValue)
    end,
})

local NPCHitboxESP = TABS.Other:Toggle({
    Title = "NPC Hitbox ESP",
    Desc = "Shows the hitboxes of the npcs",

    Callback = function(selectedValue)
        char:SetAttribute('NPCHitboxESPOn', selectedValue)

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
