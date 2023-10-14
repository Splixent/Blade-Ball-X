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

SpawnBall:On(function(Player)
    local Ball = BallManager.new(Player)

    if Ball then
        BallManager.Start(Ball)
    else
        print("Ball already exists.")
    end
end)

RespawnBall:On(function(Player)
    BallManager.Restart(BallManager.CurrentBall, Player)
end)


return Replication