--Strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Client = Players.LocalPlayer.PlayerScripts.Client

local Replication = require(Client.Replication)
local Red = require(Shared.Red)
local UI = require(Client.UI)

local Net = Red.Client("Network")

task.spawn(function()
    if game:IsLoaded() == false then
        game.Loaded:Wait()
    end

    repeat task.wait() until Replication:GetInfo("States")

    if Replication:GetInfo("States").Loaded == false then
        Replication:LoadedChanged(function(NewValue)
            if NewValue == true then
                Net:Fire("InGame")
            end
        end)
    elseif Replication:GetInfo("States").Loaded == true then
        Net:Fire("InGame")
    end
end)