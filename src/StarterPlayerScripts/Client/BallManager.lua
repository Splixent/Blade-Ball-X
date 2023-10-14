--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage.Shared
local Client = Players.LocalPlayer.PlayerScripts.Client

local Replication = require(Client.Replication)
local Fusion = require(Shared.Fusion)
local ScriptUtils = require(Shared.ScriptUtils)
local Maid = require(Shared.Maid)
local Events = require(Shared.Events)

local NewBall = Events.NewBall:Client()

local Hydrate = Fusion.Hydrate
local Computed = Fusion.Computed

export type BallManager = {
    CurrentBallMaid: any,
    CurrentClientBall: Part,
    CurrentBallSpring: any?,
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

    BallManager.CurrentBallMaid = Maid.new()
    BallManager.CurrentBallSpring = ScriptUtils.CreateSpring({
        Initial = ServerBall.CFrame,
        Speed = 100,
        Damper = 1
    })

    Hydrate(BallManager.CurrentClientBall) {
        Parent = game.Workspace.GameObjects,
        CFrame = Computed(function()
            return BallManager.CurrentBallSpring.Spring:get()
        end, Fusion.cleanup)
    }

    BallManager.CurrentBallMaid:GiveTask(RunService.RenderStepped:Connect(function(DeltaTime: number)
        BallManager.CurrentBallSpring.Value:set(ServerBall:WaitForChild("Hitbox").CFrame)
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