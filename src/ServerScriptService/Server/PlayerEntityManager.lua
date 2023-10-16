--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Shared
local Server = ServerScriptService.Server

local ReplicaService = require(Server.ReplicaService)
local Constants = require(Server.Constants)
local ScriptUtils = require(Shared.ScriptUtils)
local Maid = require(Shared.Maid)
local SharedTypes = require(Shared.SharedTypes)

local PlayerEntityManager = {}

function PlayerEntityManager.new(Player: Player?, ExtraInfo: boolean?): SharedTypes.Replica | { Replica: SharedTypes.Replica } | nil
    assert(Player, "Player is nil")
    if PlayerEntityManager[Player] == nil then
        local PlayerEntityInfo = {}
        PlayerEntityInfo.Replica = ReplicaService.NewReplica({
            ClassToken = ReplicaService.NewClassToken("States"..Player.UserId),
            Data = ScriptUtils.DeepCopy(Constants.States),
            Replication = Player,
        })
        PlayerEntityManager[Player] = PlayerEntityInfo
    end
    return if ExtraInfo then PlayerEntityManager[Player] else PlayerEntityManager[Player].Replica
end

function PlayerEntityManager.SetupCharacter(Player: Player?)
    assert(Player, "Player is nil")
    Player:LoadCharacter()

    local DiedMaid = Maid.new()
    local Character: Model = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid: Humanoid = Character:WaitForChild("Humanoid"):: Humanoid

    Humanoid.WalkSpeed = 40
    Humanoid.Health = 100

    DiedMaid:GiveTask(Humanoid.Died:Connect(function()
        PlayerEntityManager.OnDied(Player)
        DiedMaid:Destroy() 
    end))
end

function PlayerEntityManager.OnDied(Player: Player?)
    PlayerEntityManager.SetupCharacter(Player)
end

Players.PlayerRemoving:Connect(function(Player: Player?)
    local Replica = PlayerEntityManager.new(Player)

    assert(Player, "Player is nil")
    assert(Replica, "PlayerEntity is nil")

    Replica:Destroy()
    if PlayerEntityManager[Player] ~= nil then
        PlayerEntityManager[Player] = nil
    end
end)

return PlayerEntityManager