--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Shared
local Server = ServerScriptService.Server

local Signal = require(Shared.Signal)
local ReplicaService = require(Server.ReplicaService)
local SharedTypes = require(Shared.SharedTypes)

local DataObject = {}

function DataObject.new(Player: Player?, LoadedData: any, ExtraInfo: boolean?): SharedTypes.Replica? | { Replica: SharedTypes.Replica, Signal: SharedTypes.Signal}?
    assert(Player, "Player is nil")
    if LoadedData == nil then
        repeat
            task.wait()
        until 
        DataObject[Player] ~= nil

        return DataObject[Player]
    end

    if DataObject[Player] == nil then
        DataObject[Player] = {}
        DataObject[Player].Replica = ReplicaService.NewReplica({
            ClassToken = ReplicaService.NewClassToken("DataKey"..Player.UserId),
            Data = LoadedData,
            Replication = Player,
        })
        DataObject[Player].Changed = Signal.new()
    end
    return if ExtraInfo then DataObject[Player] else DataObject[Player].Replica
end

function DataObject.SetData(Player: Player?, Path: any, NewData: any): boolean?
    assert(Player, "Player is nil")
    if typeof(NewData) == "function" then
        NewData = NewData(DataObject[Player].Replica.Data) 
        if NewData == nil then
            return false
        end
    end
    
    DataObject[Player].Replica:SetValues(Path, NewData[2])
    DataObject[Player].Changed:Fire(Player, NewData[1])
    return true
end

Players.PlayerRemoving:Connect(function(Player: Player?)
    local Replica = DataObject.new(Player)
    
    assert(Player, "Player is nil")
    assert(Replica, "PlayerData is nil")

    Replica:Destroy()
    if DataObject[Player] ~= nil then
        DataObject[Player] = nil
    end
end)

return DataObject