




local _wait = task.wait
repeat _wait() until game:IsLoaded()
local _env = getgenv and getgenv() or {}

function JoinInGame()
    for i, v in pairs(
        getconnections(
            game:GetService("Players").LocalPlayer.PlayerGui.LoadingGui:WaitForChild("PlayBackground").Play.Activated
)
    ) do
        v.Function()
    end
end


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local rs_Monsters = ReplicatedStorage:WaitForChild("MonsterSpawn")
local Modules = ReplicatedStorage:WaitForChild("ModuleScript")
local OtherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local Monsters = workspace:WaitForChild("Monster")

local MQuestSettings = require(Modules:WaitForChild("Quest_Settings"))
local MSetting = require(Modules:WaitForChild("Setting"))

local NPCs = workspace:WaitForChild("NPCs")
local Raids = workspace:WaitForChild("Raids")
local Location = workspace:WaitForChild("Location")
local Region = workspace:WaitForChild("Region")
local Island = workspace:WaitForChild("Island")

local Quests_Npc = NPCs:WaitForChild("Quests_Npc")
local EnemyLocation = Location:WaitForChild("Enemy_Location")
local QuestLocation = Location:WaitForChild("QuestLocaion")

local Items = Player:WaitForChild("Items")
local QuestFolder = Player:WaitForChild("QuestFolder")
local Ability = Player:WaitForChild("Ability")
local PlayerData = Player:WaitForChild("PlayerData")
local PlayerLevel = PlayerData:WaitForChild("Level")

local sethiddenproperty = sethiddenproperty or (function()end)

local CFrame_Angles = CFrame.Angles
local CFrame_new = CFrame.new
local Vector3_new = Vector3.new

local _huge = math.huge

--- setups
JoinInGame()


task.spawn(function()
  if not _env.LoadedHideUsername then
    _env.LoadedHideUsername = true
    local Label = Player.PlayerGui.MainGui.PlayerName
    
    local function Update()
      local Level = PlayerLevel.Value
      local IsMax = Level >= MSetting.Setting.MaxLevel
      Label.Text = ("%s • Lv. %i%s"):format("Anonymous", Level, IsMax and " (Max)" or "")
    end
    
    Label:GetPropertyChangedSignal("Text"):Connect(Update)Update()
  end
end)

local Loaded, Funcs, Folders = {}, {}, {} do
  Loaded.ItemsPrice = {
    Aura = function()
      return Funcs:GetMaterial("Meme Cube") > 0 and Funcs:GetData("Money") >= 10000000 -- 1x Meme Cube, $10.000.000
    end,
    FlashStep = function()
      return Funcs:GetData("Money") >= 100000 -- $100.000
    end,
    Instinct = function()
      return Funcs:GetData("Money") >= 2500000 -- $2.500.000
    end
  }
  Loaded.Shop = {
    {"Weapons", {
      {"Buy Katana", "$5.000 Money", {"Weapon_Seller", "Doge"}},
      {"Buy Hanger", "$25.000 Money", {"Weapon_Seller", "Hanger"}},
      {"Buy Flame Katana", "1x Cheems Cola and $50.000", {"Weapon_Seller", "Cheems"}},
      {"Buy Banana", "1x Cat Food and $350.000", {"Weapon_Seller", "Smiling Cat"}},
      {"Buy Bonk", "5x Money Bags and $1.000.000", {"Weapon_Seller", "Meme Man"}},
      {"Buy Pumpkin", "1x Nugget Man and $3.500.000", {"Weapon_Seller", "Gravestone"}},
      {"Buy Popcat", "10.000 Pops Clicker", {"Weapon_Seller", "Ohio Popcat"}}
    }},
    {"Ability", {
      {"Buy Flash Step", "$100.000 Money", {"Ability_Teacher", "Giga Chad"}},
      {"Buy Instinct", "$2.500.000 Money", {"Ability_Teacher", "Nugget Man"}},
      {"Buy Aura", "1x Meme Cube and $10.000.000", {"Ability_Teacher", "Aura Master"}}
    }},
    {"Fighting Style", {
      {"Buy Combat", "$0 Money", {"FightingStyle_Teacher", "Maxwell"}},
      {"Buy Baller", "10x Balls and $10.000.000", {"FightingStyle_Teacher", "Baller"}}
    }}
  }
  Loaded.WeaponsList = { "Fight", "Power", "Weapon" }
  Loaded.EnemeiesList = {}
  Loaded.EnemiesSpawns = {}
  Loaded.EnemiesQuests = {}
  Loaded.Islands = {}
  Loaded.Quests = {}
  
  local function RedeemCode(Code)
    return OtherEvent.MainEvents.Code:InvokeServer(Code)
  end
  
  Funcs.RAllCodes = function(self)
    if Modules:FindFirstChild("CodeList") then
      local List = require(Modules.CodeList)
      for Code, Info in pairs(type(List) == "table" and List or {}) do
        if type(Code) == "string" and type(Info) == "table" and Info.Status then RedeemCode(Code) end
      end
    end
  end
  
  Funcs.GetPlayerLevel = function(self)
    return PlayerLevel.Value
  end
  
  Funcs.GetCurrentQuest = function(self)
    for _,Quest in pairs(Loaded.Quests) do
      if Quest.Level <= self:GetPlayerLevel() and not Quest.RaidBoss and not Quest.SpecialQuest then
        return Quest
      end
    end
  end
  
  Funcs.CheckQuest = function(self)
    for _,v in ipairs(QuestFolder:GetChildren()) do
      if v.Target.Value ~= "None" then
        return v
      end
    end
  end
  
  Funcs.VerifySword = function(self, SName)
    local Swords = Items.Weapon
    return Swords:FindFirstChild(SName) and Swords[SName].Value > 0
  end
  
  Funcs.VerifyAccessory = function(self, AName)
    local Accessories = Items.Accessory
    return Accessories:FindFirstChild(AName) and Accessories[AName].Value > 0
  end
  
  Funcs.GetMaterial = function(self, MName)
    local ItemStorage = Items.ItemStorage
    return ItemStorage:FindFirstChild(MName) and ItemStorage[MName].Value or 0
  end
  
  Funcs.AbilityUnlocked = function(self, Ablt)
    return Ability:FindFirstChild(Ablt) and Ability[Ablt].Value
  end
  
  Funcs.CanBuy = function(self, Item)
    if Loaded.ItemsPrice[Item] then
      return Loaded.ItemsPrice[Item]()
    end
    return false
  end
  
  Funcs.ifSwordSelected = function(self, SName)
    local Backpack = Player.Backpack

    return Backpack:FindFirstChild(SName)
  end


Funcs.VerifyItems = function(self,IName)
    local SItems = Items.ItemStorage
    return SItems:FindFirstChild(IName).value
end

Funcs.VerifyFight = function(self,FName)
    local FS = Items.FightingStyle
    return FS:FindFirstChild(FName).value
end
  
  Funcs.GetData = function(self, Data)
    return PlayerData:FindFirstChild(Data) and PlayerData[Data].Value or 0
  end

Funcs.VerifyGamePass = function(self, GName)
    return Player.PlayerSpecial:FindFirstChild(GName).value
end



Funcs.VerifyPower = function(salf,PName)
    local FS = Items.Power
    return FS:FindFirstChild(PName).value
end
  
  for Npc,Quest in pairs(MQuestSettings) do
    if QuestLocation:FindFirstChild(Npc) then
      table.insert(Loaded.Quests, {
        RaidBoss = Quest.Raid_Boss,
        SpecialQuest = Quest.Special_Quest,
        QuestPos = QuestLocation[Npc].CFrame,
        EnemyPos = EnemyLocation[Quest.Target].CFrame,
        Level = Quest.LevelNeed,
        Enemy = Quest.Target,
        NpcName = Npc
      })
    end
  end
  
  table.sort(Loaded.Quests, function(a, b) return a.Level > b.Level end)
  for _,v in ipairs(Loaded.Quests) do
    table.insert(Loaded.EnemeiesList, v.Enemy)Loaded.EnemiesQuests[v.Enemy] = v.NpcName
  end
end

local Settings = Settings or {} do
  Settings.AutoStats_Points = 1
  Settings.BringMobs = true
  Settings.FarmDistance = 9
  Settings.ViewHitbox = false
  Settings.AntiAFK = true
  Settings.AutoHaki = true
  Settings.AutoClick = true
  Settings.ToolFarm = "Fight" -- [[ "Fight", "Power", "Weapon" ]]
  Settings.FarmCFrame = CFrame_new(0, Settings.FarmDistance, 0) * CFrame_Angles(math.rad(-90), 0, 0)
end

local function PlayerClick()
  local Char = Player.Character
  if Char then
    if Settings.AutoClick then
      VirtualUser:CaptureController()
      VirtualUser:Button1Down(Vector2.new(1e4, 1e4))
    end
    if Settings.AutoHaki and Char:FindFirstChild("AuraColor_Folder") and Funcs:AbilityUnlocked("Aura") then
      if #Char.AuraColor_Folder:GetChildren() < 1 then
        OtherEvent.MainEvents.Ability:InvokeServer("Aura")
      end
    end
  end
end

local function IsAlive(Char)
  local Hum = Char and Char:FindFirstChild("Humanoid")
  return Hum and Hum.Health > 0
end

local function GetNextEnemie(EnemieName)
  for _,v in ipairs(Monsters:GetChildren()) do
    if (not EnemieName or v.Name == EnemieName) and IsAlive(v) then
      return v
    end
  end
  return false
end

local function GoTo(CFrame, Move)
  local Char = Player.Character
  if IsAlive(Char) then
    return Move and ( Char:MoveTo(CFrame.p) or true ) or Char:SetPrimaryPartCFrame(CFrame)
  end
end

local function EquipWeapon()
  local Backpack, Char = Player:FindFirstChild("Backpack"), Player.Character
  if IsAlive(Char) and Backpack then
    for _,v in ipairs(Backpack:GetChildren()) do
      if v:IsA("Tool") and v.ToolTip:find(Settings.ToolFarm) then
        Char.Humanoid:EquipTool(v)
      end
    end
  end
end

local function BringMobsTo(_Enemie, CFrame, SBring)
  for _,v in ipairs(Monsters:GetChildren()) do
    if (SBring or v.Name == _Enemie) and IsAlive(v) then
      local PP, Hum = v.PrimaryPart, v.Humanoid
      if PP and (PP.Position - CFrame.p).Magnitude < 500 then
        Hum.WalkSpeed = 0
        Hum:ChangeState(14)
        PP.CFrame = CFrame
        PP.CanCollide = false
        PP.Transparency = Settings.ViewHitbox and 0.8 or 1
        PP.Size = Vector3.new(50, 50, 50)
      end
    end
  end
  return pcall(sethiddenproperty, Player, "SimulationRadius", _huge)
end

local function KillMonster(_Enemie, SBring)
  local Enemy = typeof(_Enemie) == "Instance" and _Enemie or GetNextEnemie(_Enemie)
  if IsAlive(Enemy) and Enemy.PrimaryPart then
    GoTo(Enemy.PrimaryPart.CFrame * Settings.FarmCFrame)EquipWeapon()
    if not Enemy:FindFirstChild("Reverse_Mark") then PlayerClick() end
    if Settings.BringMobs then BringMobsTo(_Enemie, Enemy.PrimaryPart.CFrame, SBring) end
    return true
  end
end

local function TakeQuest(QuestName, CFrame, Wait)
  local QuestGiver = Quests_Npc:FindFirstChild(QuestName)
  if QuestGiver and Player:DistanceFromCharacter(QuestGiver.WorldPivot.p) < 5 then
    return fireproximityprompt(QuestGiver.Block.QuestPrompt), _wait(Wait or 0.1)
  end
  GoTo(CFrame or QuestLocation[QuestName].CFrame)
end

local function ClearQuests(Ignore)
  for _,v in ipairs(QuestFolder:GetChildren()) do
    if v.QuestGiver.Value ~= Ignore and v.Target.Value ~= "None" then
      OtherEvent.QuestEvents.Quest:FireServer("Abandon_Quest", { QuestSlot = v.Name })
    end
  end
end

local function GetRaidEnemies()
  for _,v in ipairs(Monsters:GetChildren()) do
    if v:GetAttribute("Raid_Enemy") and IsAlive(v) then
      return v
    end
  end
end

local function GetRaidMap()
  for _,v in ipairs(Raids:GetChildren()) do
    if v.Joiners:FindFirstChild(Player.Name) then
      return v
    end
  end
end

local function VerifyQuest(QName)
  local Quest = Funcs:CheckQuest()
  return Quest and Quest.QuestGiver.Value == QName
end

_env.FarmFuncs = {
  {"_Floppa Sword", (function()
    if not Funcs:VerifySword("Floppa") then
      if VerifyQuest("Cool Floppa Quest") then
        GoTo(CFrame_new(794, -31, -440))
        fireproximityprompt(Island.FloppaIsland["Lava Floppa"].ClickPart.ProximityPrompt)
      else
        ClearQuests("Cool Floppa Quest")
        TakeQuest("Cool Floppa Quest", CFrame_new(758, -31, -424))
      end
      return true
    end
  end)},
  {"Meme Beast", (function()
    local MemeBeast = Monsters:FindFirstChild("Meme Beast") or rs_Monsters:FindFirstChild("Meme Beast")
    if MemeBeast then
      GoTo(MemeBeast.WorldPivot)EquipWeapon()PlayerClick()
      return true
    end
  end)},
  {"Lord Sus", (function()
    local LordSus = Monsters:FindFirstChild("Lord Sus") or rs_Monsters:FindFirstChild("Lord Sus")
    if LordSus then
      if not VerifyQuest("Floppa Quest 32") and Funcs:GetPlayerLevel() >= 1550 then
        ClearQuests("Floppa Quest 32")TakeQuest("Floppa Quest 32", nil, 1)
      else
        KillMonster(LordSus)
      end
      return true
    elseif Funcs:GetMaterial("Sussy Orb") > 0 then
      if Player:DistanceFromCharacter(Vector3_new(6644, -95, 4811)) < 5 then
        fireproximityprompt(Island.ForgottenIsland.Summon3.Summon.SummonPrompt)
      else GoTo(CFrame_new(6644, -95, 4811)) end
      return true
    end
  end)},
  {"Evil Noob", },
  {"Giant Pumpkin", (function()
    local Pumpkin = Monsters:FindFirstChild("Giant Pumpkin") or rs_Monsters:FindFirstChild("Giant Pumpkin")
    if Pumpkin then
      if not VerifyQuest("Floppa Quest 23") and Funcs:GetPlayerLevel() >= 1100 then
        ClearQuests("Floppa Quest 23")TakeQuest("Floppa Quest 23", nil, 1)
      else
        KillMonster(Pumpkin)
      end
      return true
    elseif Funcs:GetMaterial("Flame Orb") > 0 then
      if Player:DistanceFromCharacter(Vector3_new(-1180, -93, 1462)) < 5 then
        fireproximityprompt(Island.PumpkinIsland.Summon1.Summon.SummonPrompt)
      else GoTo(CFrame_new(-1180, -93, 1462)) end
      return true
    end
  end)},
  {"Race V2 Orb", (function()
    if Funcs:GetPlayerLevel() >= 500 then
      local Quest, Enemy = "Dancing Banana Quest", "Sogga"
      if VerifyQuest(Quest) then
        if KillMonster(Enemy) then else GoTo(EnemyLocation[Enemy].CFrame) end
      else ClearQuests(Quest)TakeQuest(Quest, CFrame_new(-2620, -80, -2001)) end
      return true
    end
  end)},
  {"Level Farm",},
  {"Raid Farm", (function()
    if Funcs:GetPlayerLevel() >= 1000 then
      local RaidMap = GetRaidMap()
      if RaidMap then
        if RaidMap:GetAttribute("Starting") ~= 0 then
          OtherEvent.MiscEvents.StartRaid:FireServer("Start")_wait(1)
        else
          local Enemie = GetRaidEnemies()
          if Enemie then KillMonster(Enemie, true) else
            local Spawn = RaidMap:FindFirstChild("Spawn_Location")
            if Spawn then GoTo(Spawn.CFrame) end
          end
        end
      else
        local Raid = Region:FindFirstChild("RaidArea")
        if Raid then GoTo(CFrame_new(Raid.Position)) end
      end
      return true
    end
  end)},
  {"FS Enemie", (function()
    local Enemy = _env.SelecetedEnemie
    local Quest = Loaded.EnemiesQuests[Enemy]
    if VerifyQuest(Quest) or not _env["FS Take Quest"] then
      if KillMonster(Enemy) then else GoTo(EnemyLocation[Enemy].CFrame) end
    else ClearQuests(Quest)TakeQuest(Quest) end
    return true
  end)},
  {"Nearest Farm", (function() return KillMonster(GetNextEnemie()) end)}
}

if not _env.LoadedFarm then
  _env.LoadedFarm = true
  task.spawn(function()
    while _wait() do
      for _,f in _env.FarmFuncs do
        if _env[f[1]] then local s,r=pcall(f[2])if s and r then break end;end
      end
    end
  end)
end

function lordSus()
    local LordSus = Monsters:FindFirstChild("Lord Sus") or rs_Monsters:FindFirstChild("Lord Sus")
    if LordSus then
      if not VerifyQuest("Floppa Quest 32") and Funcs:GetPlayerLevel() >= 1550 then
        ClearQuests("Floppa Quest 32")TakeQuest("Floppa Quest 32", nil, 1)
      else
        KillMonster(LordSus)
      end
      return true
    elseif Funcs:GetMaterial("Sussy Orb") > 0 then
      if Player:DistanceFromCharacter(Vector3_new(6644, -95, 4811)) < 5 then
        fireproximityprompt(Island.ForgottenIsland.Summon3.Summon.SummonPrompt)
      else GoTo(CFrame_new(6644, -95, 4811)) end
      return true
    end
  end
  function envilNoob()
    local EvilNoob = Monsters:FindFirstChild("Evil Noob") or rs_Monsters:FindFirstChild("Evil Noob")
    if EvilNoob then
      if not VerifyQuest("Floppa Quest 29") and Funcs:GetPlayerLevel() >= 1400 then
        ClearQuests("Floppa Quest 29")TakeQuest("Floppa Quest 29", nil, 1)
      else
        KillMonster(EvilNoob)
      end
      return true
    elseif Funcs:GetMaterial("Noob Head") > 0 then
      if Player:DistanceFromCharacter(Vector3_new(-2356, -81, 3180)) < 5 then
        fireproximityprompt(Island.MoaiIsland.Summon2.Summon.SummonPrompt)
      else GoTo(CFrame_new(-2356, -81, 3180)) end
      return true
    end
  end

  function autoFarm()
    local Quest, QuestChecker = Funcs:GetCurrentQuest(), Funcs:CheckQuest()
    if Quest then
      if QuestChecker then
        local _QuestName = QuestChecker.QuestGiver.Value
        if _QuestName == Quest.NpcName then
          if KillMonster(Quest.Enemy) then else GoTo(Quest.EnemyPos) end
        else
          if KillMonster(QuestChecker.Target.Value) then else GoTo(QuestLocation[_QuestName].CFrame) end
        end
      else TakeQuest(Quest.NpcName) end
    end
    return true
  end

  function raidFarm()
    if Funcs:GetPlayerLevel() >= 1000 then
      local RaidMap = GetRaidMap()
      if RaidMap then
        if RaidMap:GetAttribute("Starting") ~= 0 then
          OtherEvent.MiscEvents.StartRaid:FireServer("Start")_wait(1)
        else
          local Enemie = GetRaidEnemies()
          if Enemie then KillMonster(Enemie, true) else
            local Spawn = RaidMap:FindFirstChild("Spawn_Location")
            if Spawn then GoTo(Spawn.CFrame) end
          end
        end
      else
        local Raid = Region:FindFirstChild("RaidArea")
        if Raid then GoTo(CFrame_new(Raid.Position)) end
      end
      return true
    end
  end

local kaitun = {
    nullTask = "dsadadsasd",
    TASKNAME_floppaSword = "floppaSwordTask",

    onTask = ""
}

kaitun.onTask = kaitun.nullTask

function floppaSword()
    if VerifyQuest("Cool Floppa Quest") then
        GoTo(CFrame_new(794, -31, -440))
        fireproximityprompt(Island.FloppaIsland["Lava Floppa"].ClickPart.ProximityPrompt)
      else
        ClearQuests("Cool Floppa Quest")
        TakeQuest("Cool Floppa Quest", CFrame_new(758, -31, -424))
      end
    return true
end

function popCatSword()
    local clickQuants = Island.FloppaIsland.Popcat_Clickable.Part.BillboardGui.Textlabel.text
    local ClickDetector = Island.FloppaIsland.Popcat_Clickable.Part.ClickDetector
    
    if not clickQuants ~= "10,001" then
       
        
        if clickQuants == "10,000" and not Funcs:VerifySword("Popcat") then
            OtherEvent.MainEvents.Modules:FireServer("Weapon_Seller","Ohio Popcat")
        end

        local popCatX = Island.FloppaIsland.Popcat_Clickable.Part.CFrame.X
        local popCatZ = Island.FloppaIsland.Popcat_Clickable.Part.CFrame.Z
        local popCatY = Island.FloppaIsland.Popcat_Clickable.Part.CFrame.Y
    
        GoTo(CFrame_new(Vector3_new(popCatX + 20,popCatY + 10,popCatZ + 20)))
        fireclickdetector(ClickDetector)
    end
    
end

function addStats(type,amount)
    local args = {
        [1] = {
            ["Target"] = type,
            ["Action"] = "UpgradeStats",
            ["Amount"] =  amount
        }
    }
    OtherEvent:WaitForChild("MainEvents"):WaitForChild("StatsFunction"):InvokeServer(unpack(args))
end

function statsKaitun() 
    if PlayerData.SkillPoint.value == 1  then return end
    if PlayerData.SkillPoint.value == 0  then return end
    local tool = Settings.ToolFarm
    local statsModel = {
        sword = "SwordLevel",
        melee = "MeleeLevel",
        defense = "DefenseLevel"
    }

    -- pattern Stats
    if PlayerData[statsModel.defense].value + math.floor(PlayerData.SkillPoint.value / 2)  < 2400 then
        addStats(statsModel.defense,math.floor(PlayerData.SkillPoint.value / 2))
    end
    
    -- attack Stats
    if tool == "Fight" and (PlayerData[statsModel.melee].value  + math.floor(PlayerData.SkillPoint.value / 2)   < 2400) then
        addStats(statsModel.melee,math.floor(PlayerData.SkillPoint.value / 2))
    elseif tool == "Weapon" and (PlayerData[statsModel.sword].value  + math.floor(PlayerData.SkillPoint.value / 2)   < 2400) then
        addStats(statsModel.sword,math.floor(PlayerData.SkillPoint.value / 2))
    end
end

function getBestWeaponOrMelee()
    local listWeaponsAndMelee = {
        "Katana",
        "Hanger",
    
        "Banana",
    
        "Flame Katana",
    
        "Pixel Sword",
        "Pink Hammer",
        "Portal",
        "Bonk",
    
        "Floppa",
        "Yellow Blade",
        "Pumpkin",
        "Popcat",
        "Purple Katana"
    }

    local BestSword = ""

    for i = 1, #listWeaponsAndMelee do
        if Funcs:VerifySword(listWeaponsAndMelee[i]) then
            BestSword = listWeaponsAndMelee[i]
        end
    end

    if BestSword == "" then return end

    local character = Player.Character or Player.CharacterAdded:Wait()

    local backpack = Player.Backpack
    local toolEquipd = character:FindFirstChildOfClass("Tool") or backpack:FindFirstChildOfClass("Tool")
    Settings.ToolFarm = "Weapon"

    if toolEquipd.Name ~= BestSword  then
        local Backpack = Player.Backpack

        if not Backpack:FindFirstChild(BestSword) then
            local args = {
                [1] = "Weapon",
                [2] = {
                    ["SelectedItem"] = BestSword
                }
            }
                
            OtherEvent.ItemEvents.UpdateInventory:InvokeServer(unpack(args))
        end
    end
end

function gamePass(GName)
    local gamepassesValues = {
        ["DoubleMoney"] = 15000,
        ["DoubleExp"] = 15000,
        ["DoubleGem"] = 30000,
        ["DoubleDrop"] = 50000,
        ["Noob"] = 10000,
        ["Capybara"] = 10000
    }

    local gamepassesIds = {
        ["Noob"] = 830466630, 
        ["Capybara"] = 135099474, 
        ["DoubleDrop"] = 876020870,
        ["DoubleGem"] = 86944271,
        ["DoubleExp"] = 62333681,
        ["DoubleMoney"] = 62333932
    }

    if PlayerData.Gem.Value >= gamepassesValues[GName] then
        local args = {
            [1] = {
                ["Action"] = "Buy_Gamepass",
                ["GamepassId"] = gamepassesIds[GName]
            }
        }
    
        OtherEvent.BuyEvents.BuyProduct:FireServer(unpack(args))
    else
        raidFarm()
    end
end

function farmSelectedQuest(Quest, Enemy)
    if VerifyQuest(Quest) then
    if KillMonster(Enemy) then else GoTo(EnemyLocation[Enemy].CFrame) end
    else ClearQuests(Quest)TakeQuest(Quest, QuestLocation[Quest].CFrame) end
    return true
end

function ballerStyle()
    if PlayerData.Money.value <= 10000000 then
        if Funcs:GetMaterial("Sussy Orb") == 0 then
            farmSelectedQuest("Floppa Quest 30","Red Sus")
        else
            lordSus()
        end
    elseif Funcs:VerifyItems("Ball") < 10 then
        farmSelectedQuest("Floppa Quest 41","Baller")
    else
        local args = {
            [1] = "FightingStyle_Teacher",
            [2] = "Baller"
        }
        
        OtherEvent.MainEvents.Modules:FireServer(unpack(args))
    end
end

function autoPurpleKatana()
    if Funcs:GetMaterial("Sussy Orb") == 0 then
        farmSelectedQuest("Floppa Quest 30","Red Sus")
    else
        lordSus()
    end
end

function autoYellowBlade()
    if Funcs:GetMaterial("Noob Head") == 0 then
        farmSelectedQuest("Floppa Quest 28","Moai")
    else
        envilNoob()
    end
end

function autoStorePowers()
    for _,v in ipairs(Player.Backpack:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == "Power" and v:GetAttribute("Using") == nil then
            if Funcs:VerifyPower(v.Name) < 99 then
                v.Parent = Player.Character
                OtherEvent.MainEvents.Modules:FireServer("Eatable_Power", { Action = "Store", Tool = v })
            end
        end
    end
end

function rollPowers()
    if PlayerData.Money.value > 250000 then
        OtherEvent.MainEvents.Modules:FireServer("Random_Power", {
            Type = "Decuple",
            NPCName = "Floppa Gacha",
            GachaType = "Money"
        })
    end
end


function autoKaitun(onStarted)
    
    autoStorePowers()
    getBestWeaponOrMelee()
    statsKaitun()

    if onStarted then
        Funcs.RAllCodes()
    end

    -- On Start Acc
    if not Funcs:VerifySword("Popcat") then return popCatSword() end
    if not Funcs:VerifySword("Floppa") then return floppaSword() end

    if (not Funcs:VerifyGamePass("DoubleMoney")) and Funcs:GetPlayerLevel() >= 2000 then return gamePass("DoubleMoney") end

    if not Funcs:VerifyFight("Baller") and Funcs:GetPlayerLevel() >= 2100 then return ballerStyle() end

    -- farm normal
    if Funcs:GetPlayerLevel() == 2400 then 
        if not Funcs:VerifySword("Purple Katana") then return autoPurpleKatana() end

        -- get alls gamepasses
        if not Funcs:VerifyGamePass("DoubleGem") then return gamePass("DoubleGem") end
        if not Funcs:VerifyGamePass("DoubleDrop") then return gamePass("DoubleDrop") end
        if not Funcs:VerifyGamePass("DoubleExp") then return gamePass("DoubleExp") end
        if not Funcs:VerifyGamePass("Capybara") then  return gamePass("Capybara") end
        if not Funcs:VerifyGamePass("Noob") then return gamePass("Noob") end

        if not Funcs:VerifySword("Yellow Blade") then return autoYellowBlade() end
        
    end
    
    -- end-game
    rollPowers()
    autoFarm()
    -- balls script: Funcs:VerifyItems("Ball")
        



    
end

task.spawn(function()
    while _wait(60) do

        local tool 

        if Settings.ToolFarm == "Fight" then tool = "Weapon" end
        if Settings.ToolFarm == "Weapon" then tool = "Fight" end

        local Backpack, Char = Player:FindFirstChild("Backpack"), Player.Character
        if IsAlive(Char) and Backpack then
            for _,v in ipairs(Backpack:GetChildren()) do
                if v:IsA("Tool") and v.ToolTip:find(tool) then
                    print(2)
                Char.Humanoid:EquipTool(v)
                end
            end
        end
    end
end)


task.spawn(function()
        game:GetService("RunService"):Set3dRenderingEnabled(false)
    if not _env.AntiAfk then
      _env.AntiAfk = true
      
      while _wait(60*10) do
        if Settings.AntiAFK then
          VirtualUser:CaptureController()
          VirtualUser:ClickButton2(Vector2.new())
        end
      end
    end
  end)
  
function exec()
    onStarted = true
    while true do
        local Heartbeat = RunService.Heartbeat
        Heartbeat:Wait()
        autoKaitun(onStarted)
        onStarted = false
    end  
end

function pcallAndExec()
    local suc, result = pcall(exec)

    if not suc then
        print(result)
        pcallAndExec()
    end
end

pcallAndExec()



