--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")

local Shared = ReplicatedStorage.Shared
local Client = Players.LocalPlayer.PlayerScripts.Client

local Replication = require(Client.Replication)
local Events = require(Shared.Events)

local Deflect = Events.Deflect:Client()
local GetDirection = Events.GetDirection:Client()
local SetDirection = Events.SetDirection:Client()

local DeflectManager = {}

function DeflectManager.Deflect(ActionName, InputState, IsTyping)
    if InputState == Enum.UserInputState.Begin then
        local PlayerEntity = Replication:GetInfo("States")

        if PlayerEntity.Playing == true and PlayerEntity.Deflecting == false then
            Deflect:Fire()
        end
    end
end

repeat task.wait() until Replication:GetInfo("States") and Replication:GetInfo("States").InGame ~= nil

ContextActionService:BindAction("Deflect", DeflectManager.Deflect, true, Enum.KeyCode.F, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)

GetDirection:On(function()
    local Camera = game.Workspace.CurrentCamera
    local LookVector = Camera.CFrame.LookVector

    SetDirection:Fire(LookVector)
end)

return DeflectManager