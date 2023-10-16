--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage.Shared
local Client = Players.LocalPlayer.PlayerScripts.Client

local Replication = require(Client.Replication)
local Maid = require(Shared.Maid)
local Events = require(Shared.Events)

local NewBall = Events.NewBall:Client()

export type BallManager = {
    CurrentBallMaid: any,
    CurrentClientBall: Part,
    SetupClientBall: any
}

local BallManager: BallManager = {
    CurrentBallMaid = nil,
    CurrentClientBall = ReplicatedStorage.Assets.ClientBall:Clone(),
    CurrentBallSpring = nil,
}

function BallManager.SetupClientBall(ServerBall)
    if game.Workspace.GameObjects:FindFirstChild("ClientBall") then
        BallManager.CurrentBallMaid:Destroy()
        BallManager.CurrentClientBall:Destroy()
    end
    
    local Hitbox = ServerBall:WaitForChild("Hitbox")

    BallManager.CurrentBallMaid = Maid.new()

    BallManager.CurrentClientBall.Parent = game.Workspace.GameObjects
    
    BallManager.CurrentBallMaid:GiveTask(RunService.Stepped:Connect(function(Time, DeltaTime: number)
        BallManager.CurrentClientBall.Position =  BallManager.CurrentClientBall.Position:Lerp(Hitbox.Position, DeltaTime * 20)
    end))
end

task.spawn(function()
    repeat task.wait() until Replication:GetInfo("States") and Replication:GetInfo("States").InGame ~= nil

    if game.Workspace.GameObjects:FindFirstChild("ServerBall") then
        BallManager.SetupClientBall(game.Workspace.GameObjects.ServerBall)
    end
    
    NewBall:On(function()
        BallManager.SetupClientBall(game.Workspace.GameObjects:WaitForChild("ServerBall"))
    end)
   
end)

return BallManager