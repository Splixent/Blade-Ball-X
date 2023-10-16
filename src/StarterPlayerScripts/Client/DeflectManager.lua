--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")

local Shared = ReplicatedStorage.Shared
local Client = Players.LocalPlayer.PlayerScripts.Client

local Replication = require(Client.Replication)
local Events = require(Shared.Events)
local SoundManager = require(Shared.SoundManager)

local Deflect = Events.Deflect:Client()

local DeflectManager = {
    Debug = true
}

function DeflectManager.Deflect(ActionName, InputState, IsTyping)
    if InputState == Enum.UserInputState.Begin then
        local PlayerEntity = Replication:GetInfo("States")

        local Targets, ScreenCenter = DeflectManager.GetTargets()

        if PlayerEntity.Playing == true and PlayerEntity.Deflecting == false then
            local Camera = game.Workspace.CurrentCamera
            local LookVector = Camera.CFrame.LookVector

            SoundManager.CreatePlayDestroy({
                SoundGroup = "SFX",
                Parent = "SFX",
        
                SoundId = "rbxassetid://1837831535",
                RollOffMaxDistance = 10000,
                RollOffMinDistance = 50
            })

            Deflect:Fire(Targets, ScreenCenter, LookVector)
        end
    end
end

function DeflectManager.GetTargets(): (any, Vector2)
    local TargetInfo = {}

    local AllPlayers = Players:GetPlayers()
    local Camera = game.Workspace.CurrentCamera

    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for i, TargetPlayer in ipairs (AllPlayers) do
        if TargetPlayer ~= Players.LocalPlayer then
            local Character = TargetPlayer.Character

            if Character and Character:FindFirstChild("HumanoidRootPart") then
                local ScreenPoint = Camera:WorldToViewportPoint(Character.HumanoidRootPart.Position)
                TargetInfo[TargetPlayer.Name] = Vector2.new(ScreenPoint.X, ScreenPoint.Y)
            end
        end
    end

    if DeflectManager.Debug == true then
        local AllBots = game.Workspace.GameObjects.DeflectBots:GetChildren()

        for i, TargetBot in ipairs (AllBots) do   
            if TargetBot and TargetBot:FindFirstChild("HumanoidRootPart") then
                local ScreenPoint = Camera:WorldToViewportPoint(TargetBot.HumanoidRootPart.Position)
                TargetInfo[TargetBot.Name] = Vector2.new(ScreenPoint.X, ScreenPoint.Y)
            end
        end
    end

    return TargetInfo, ScreenCenter
end

repeat task.wait() until Replication:GetInfo("States") and Replication:GetInfo("States").InGame ~= nil

ContextActionService:BindAction("Deflect", DeflectManager.Deflect, true, Enum.KeyCode.F, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)

return DeflectManager