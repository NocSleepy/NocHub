-----------------------
-- UI LIBRARY --
-----------------------
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-----------------------
-- SERVICES --
-----------------------
local RunService = cloneref(game:GetService('RunService'))
local HttpService = cloneref(game:GetService('HttpService'))

-----------------------
-- VARIABLES --
-----------------------

-- @AUTO FARM
local AutoFarmState = {}
local AutoFarmConfig = {
    AUTO_FARM_TYPE = "",
    TWEEN_SPEED = 0 -- for now
}

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

    Raid = FeatureSection:Tab({
        Title = "Raid", Icon = 'door-open'
    }),

    Sea = FeatureSection:Tab({
        Title = "Sea", Icon = 'door-open'
    }),

    Player = FeatureSection:Tab({
        Title = "Oyuncu", Icon = 'door-open'
    }),
}

-----------------------
-- AUTO FARM SECTION --
-----------------------
local StartAutoFarm = TABS.Main:Button({
    Title = "Auto Farm'ı Başlat!",
    Desc = "AUTO FARMI BAŞLATIR",

    Callback = function()
        print('AUTO FARM BAŞLATILIYOR!')
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
local MevlanaSpinSpeed = TABS.Player:Button({
    Title = "Mevlana Spin'i başlat!",
})

local MevlanaSpinSpeedConfiguration = TABS.Player:Slider({
    Title = "Mevlana Spin Speed",
    Desc = "Mevlana Spin'in hızını ayarlayabilirsin!",

    IsToolTip = true,
    IsTextbox = true,
    Width = 200,
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

TABS.About:Select()
