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
local ScriptUtils = require(Shared.ScriptUtils)

local Deflect = Events.Deflect:Server()

local DeflectManager = {}

function DeflectManager.GetNearestTarget(Targets: any, ScreenCenter: Vector2): string
    local Nearest = {Name = "", Distance = math.huge}

    for TargetName, ScreenPoint in pairs (Targets) do
        local DistanceFromCenter = (ScreenPoint - ScreenCenter).Magnitude

        if DistanceFromCenter < Nearest.Distance then
            Nearest.Distance = DistanceFromCenter
            Nearest.Name = TargetName
        end
    end

    return Nearest.Name
end

Deflect:On(function(Player: Player?, Targets: any, ScreenCenter: Vector2, LookDireciton: Vector2)
    if Player then
        local PlayerEntity = PlayerEntityManager.new(Player)
        local Ping = Player:GetNetworkPing()
        
        assert(PlayerEntity, "PlayerEntity is nil")
    
        if PlayerEntity.Data.InGame == true and PlayerEntity.Data.Deflecting == false then
            PlayerEntity:SetValue({"Deflecting"}, true)
            local DeflectMaid = Maid.new()

            DeflectManager[Player] = {}
            DeflectManager[Player].Nearest = DeflectManager.GetNearestTarget(Targets, ScreenCenter)
    
            DeflectMaid:GiveTask(RunService.Stepped:Connect(function(DeltaTime)
                local DistanceFromHead = BallManager.GetDistanceFromHead(Player.Name)
    
                if DistanceFromHead == nil then
                    DeflectMaid:Destroy()
                    DeflectMaid = nil
                end
    
                if BallManager.CurrentBall and BallManager.CurrentBall:GetAttribute("TargetPlayer") == Player.Name and DistanceFromHead <= ScriptUtils.dubinvlerp(BallManager.BallInfo.BallVelocity, 0, BallManager.BallSettings.MaxVelocity, BallManager.BallSettings.MaxDistance, BallManager.BallSettings.MaxDistance * 3) and DistanceFromHead > BallManager.BallSettings.MinDistance then
                    local Target = DeflectManager[Player].Nearest
                    if Target == nil then
                        Target = BallManager.ChooseRandomPlayingPlayer(Player.Name)
                    end
                
                    BallManager.Deflect(LookDireciton, Target)
                    PlayerEntity:SetValue({"Deflecting"}, false)

                    DeflectMaid:Destroy()
                    DeflectMaid = nil
                end
            end))
    
            task.wait(0.3 + Ping)
            PlayerEntity = PlayerEntityManager.new(Player)
            
            assert(PlayerEntity, "PlayerEntity is nil")

            if DeflectMaid ~= nil then
                DeflectMaid:Destroy()
                DeflectMaid = nil
            end
            
            if PlayerEntity.Data.Deflecting == true then
                PlayerEntity:SetValue({"Deflecting"}, false)
            end
        else
    
        end
    end
end)

return DeflectManager