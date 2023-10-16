--Strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Shared
local Server = ServerScriptService.Server

require(Server.Datastore)
require(Server.Datastore.DataObject)
require(Server.SyncedTime)
require(Server.Replication)
require(Server.DeflectManager)

local PlayerEntityManager = require(Server.PlayerEntityManager)
local Events = require(Shared.Events)

local InGame = Events.InGame:Server()

InGame:On(function(Player: Player?)
    local PlayerEntity = PlayerEntityManager.new(Player)

    assert(Player, "Player is nil")
    assert(PlayerEntity, "PlayerEntity is nil")

    PlayerEntity:SetValue({"InGame"}, true)
end)