--!strict


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.Shared
local Server = ServerScriptService.Server

local Events = require(Shared.Events)
local PlayerEntityManager = require(Server.PlayerEntityManager)
local BallManager = require(Server.BallManager)
local Maid = require(Shared.Maid)

local Deflect = Events.Deflect:Server()
local GetDirection = Events.GetDirection:Server()
local SetDirection = Events.SetDirection:Server()

local DeflectManager = {}

Deflect:On(function(Player)
    local PlayerEntity = PlayerEntityManager.new(Player)
    DeflectManager[Player] = {}

    if PlayerEntity.Data.InGame == true and PlayerEntity.Data.Deflecting == false then
        PlayerEntity:SetValue({"Deflecting"}, true)
        local DeflectMaid = Maid.new()

        DeflectMaid:GiveTask(RunService.Stepped:Connect(function(DeltaTime)
            if BallManager.BallInfo.BallState == "In Range" then
                GetDirection:Fire(Player)
                DeflectMaid:Destroy()
            end

            if BallManager.BallInfo.BallState == "Kill" then

            end
        end))

        task.wait(0.3)
        if DeflectMaid ~= nil then
            DeflectMaid:Destroy()
        end
        if PlayerEntity.Data.Deflecting == true then
            PlayerEntity:SetValue({"Deflecting"}, false)
        end
    end
end)

SetDirection:On(function(Player, NewDirection)
    if  BallManager.BallInfo.BallState == "In Range" then
        local PlayerEntity = PlayerEntityManager.new(Player)
        BallManager.Deflect(NewDirection)
        PlayerEntity:SetValue({"Deflecting"}, false)
    end
end)

return DeflectManager