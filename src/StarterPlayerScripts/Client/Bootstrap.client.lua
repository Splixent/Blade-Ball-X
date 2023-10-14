--Strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Client = Players.LocalPlayer.PlayerScripts.Client

require(Client.UI)
require(Client.BallManager)
require(Client.DeflectManager)

local Replication = require(Client.Replication)
local Events = require(Shared.Events)

local InGame = Events.InGame:Client()

task.spawn(function()
    if game:IsLoaded() == false then
        game.Loaded:Wait()
    end

    repeat task.wait() until Replication:GetInfo("States")

    if Replication:GetInfo("States").Loaded == false then
        Replication:LoadedChanged(function(NewValue)
            if NewValue == true then
                InGame:Fire()
            end
        end)
    elseif Replication:GetInfo("States").Loaded == true then
        InGame:Fire()
    end
end)