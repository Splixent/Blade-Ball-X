--Strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Shared
local Server = ServerScriptService.Server

local Red = require (Shared.Red)
local PlayerEntityManager = require(Server.PlayerEntityManager)
local Datastore = require(Server.Datastore)
local DataObject = require(Server.Datastore.DataObject)
local SyncedTime = require(Server.SyncedTime)

local Net = Red.Server("Network")

Net:On("InGame", function(Player)
    PlayerEntityManager.new(Player):SetValue({"InGame"}, true)
end)
