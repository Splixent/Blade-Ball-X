--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Shared
local Server = ServerScriptService.Server

local Events = require(Shared.Events)
local BallManager = require(Server.BallManager)

local SpawnBall = Events.SpawnBall:Server()
local RespawnBall = Events.RespawnBall:Server()

local Replication = {}

SpawnBall:On(function(Player: Player?)
    assert(Player, "Player is nil")
    assert(Player.Character, "Character is nil")
    
    local Ball = BallManager.new(Player)
    assert(Ball, "Ball does not exist")

    BallManager.Start(Ball)
end)

RespawnBall:On(function(Player: Player?)
    BallManager.Restart(BallManager.CurrentBall, Player)
end)

return Replication