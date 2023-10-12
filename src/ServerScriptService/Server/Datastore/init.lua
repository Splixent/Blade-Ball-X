--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Shared
local Server = ServerScriptService.Server

local ProfileService = require(Server.ProfileService)
local Constants = require(Server.Constants)
local DataObject = require(script.DataObject)
local PlayerEntityManager = require(Server.PlayerEntityManager)
local ScriptUtils = require(Shared.ScriptUtils)

local Datastore = {}
local Profiles = {}

local GameProfileStore = ProfileService.GetProfileStore(
    "Default",
    ScriptUtils.DeepCopy(Constants.ProfileSettings.ProfileTemplate)
).Mock


function Datastore:PlayerAdded(Player: Player)
    local Profile = GameProfileStore:LoadProfileAsync("DataKey"..Player.UserId)
    if Profile ~= nil then
        Profile:AddUserId(Player.UserId)
        Profile:Reconcile()
        Profile:ListenToRelease(function()
            Profiles[Player] = nil
            Player:Kick()
        end)

        if Player:IsDescendantOf(Players) == true then
            Profiles[Player] = Profile

            Datastore:LoadData(Player)
            Datastore:SaveData(Player)
        else
            Profile:Release()
        end
    else
        Player:Kick()
    end
end

function Datastore:LoadData(Player: Player)
    if Profiles[Player].Data.LoginInfo.TotalLogins < 1 then
        self:SetupData(Profiles[Player])
    end

    Profiles[Player].Data.LoginInfo.TotalLogins += 1
    Profiles[Player].Data.LoginInfo.LastLogin = os.time()
    
    Datastore[Player].DataObject = DataObject.new(Player, Profiles[Player].Data, true)
    Datastore[Player].PlayerEntity = PlayerEntityManager.new(Player)

    PlayerEntityManager.SetupCharacter(Player)

    Datastore[Player].PlayerEntity:SetValue({"Loaded"}, true)
end

function Datastore:SaveData(Player: Player)
    Datastore[Player].DataObject.Changed:Connect(function(Player, UpdatedData)
        Profiles[Player].Data = UpdatedData
    end)
end

function Datastore:SetupData(Profile: any)
    Profile.Data.Save = ScriptUtils.DeepCopy(Constants.ProfileSettings.SaveTemplate)
end

for _, Player in ipairs (Players:GetPlayers()) do
    task.spawn(function()
        Datastore[Player] = {}
        Datastore:PlayerAdded(Player)
    end)
end

Players.PlayerAdded:Connect(function(Player: Player)
    Datastore[Player] = {}
    Datastore:PlayerAdded(Player)
end)

Players.PlayerRemoving:Connect(function(Player: Player)
    local Profile = Profiles[Player]
    DataObject[Player] = nil

    if Profile then
        Profile.Data.LoginInfo.TotalPlaytime += (os.time() -  Profile.Data.LoginInfo.LastLogin) 
    end

    if Profile ~= nil then
        Profile:Release()
    end
end)

return Datastore