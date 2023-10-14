local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local Events = require(Shared.Events)

local SpawnBall = Events.SpawnBall:Client()
local RespawnBall = Events.RespawnBall:Client()

local Functions = {}

function Functions.SpawnBall()
    SpawnBall:Fire()
end

function Functions.RespawnBall()
    RespawnBall:Fire()
end

return Functions