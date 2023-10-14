--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage.Shared

local Events = require(Shared.Events)

local NewBall = Events.NewBall:Server()

export type BallManager = {
    CurrentBall: Part?,
    Debug: boolean,
    MaxBallVelocity: number,
    BallInfo: any,
    new: any,
    Start: any,
    GetHumanoidRootPart: any,
    Restart: any

}

local BallManager: BallManager = {
    CurrentBall = nil,
    Debug = true,

    BallInfo = {
        Position = game.Workspace.GameObjects.SpawnLocation.Attachment.WorldCFrame.Position,
        PreviousPosition = Vector3.new(),
        BallVelocity = 15,
        Direction = Vector3.new(),
    },

    MaxBallVelocity = 1000
}

function BallManager.new(TargetPlayer: Player): Part | nil
    if BallManager.CurrentBall ~= nil then return nil end

    local Ball: Part = ReplicatedStorage.Assets.ServerBall:Clone()
    Ball.Parent = game.Workspace.GameObjects
    Ball.CFrame = game.Workspace.GameObjects.SpawnLocation.Attachment.WorldCFrame

    local BallHitbox: Part = Ball:WaitForChild("Hitbox"):: Part
    BallHitbox.CFrame = game.Workspace.GameObjects.SpawnLocation.Attachment.WorldCFrame

    Ball:SetAttribute("TargetPlayer", TargetPlayer.Name)

    BallManager.CurrentBall = Ball

    NewBall:FireAll(Ball)

    return Ball
end

function BallManager.Start(Ball: Part)
    RunService.Stepped:Connect(function(Time: number, DeltaTime: number)
        local HumanoidRootPart = BallManager.GetHumanoidRootPart(Ball:GetAttribute("TargetPlayer"))

        if HumanoidRootPart then

            --------------------------> Movement

            local BallHitbox: Part = Ball:WaitForChild("Hitbox"):: Part

            local Position = BallManager.BallInfo.Position
            local Direction = BallManager.BallInfo.Direction
            local BallVelocity = BallManager.BallInfo.BallVelocity

            BallManager.BallInfo.PreviousPosition = Position

            Direction = CFrame.lookAt(Ball.Position, HumanoidRootPart.Position).LookVector
            Position = Position + Direction * BallVelocity

            BallManager.BallInfo.Position = Position
            BallManager.BallInfo.Direction = Direction

            --------------------------> Collisions

            local CollisionParams = RaycastParams.new()
            CollisionParams.FilterDescendantsInstances = {game.Workspace.Map}
            CollisionParams.FilterType = Enum.RaycastFilterType.Include

            local RaycastResult = workspace:Spherecast(Ball.Position - (Ball.CFrame.LookVector * Ball.Size.X * 2), Ball.Size.X, Ball.CFrame.LookVector * Ball.Size.X * 2, CollisionParams)
            if RaycastResult then
                local Part: Part = Instance.new("Part")::Part

                Part.Size = Vector3.one
                Part.Material = Enum.Material.Neon
                Part.Color = Color3.fromRGB(255, 255, 255)

                Part.Anchored = true
                Part.CanCollide = false
                Part.Position = RaycastResult.Position
                Part.Parent = game.Workspace

                task.spawn(function()
                    task.wait(1)
                    Part:Destroy()
                end)

                BallManager.BallInfo.PreviousPosition = Position

                Direction = RaycastResult.Normal * BallVelocity
                Position = Position + Direction * BallVelocity

                BallManager.BallInfo.Direction = Direction
                BallManager.BallInfo.Position = Position
            end

            Ball.CFrame = CFrame.lookAt(Ball.Position, BallManager.BallInfo.Position)
            Ball.Position = Ball.Position.Lerp(Ball.Position, BallManager.BallInfo.Position, DeltaTime)

            BallHitbox.Position = BallHitbox.Position.Lerp(BallHitbox.Position, BallManager.BallInfo.Position, DeltaTime * 1.07)

        else
            print(Ball:GetAttribute("TargetPlayer").." left the game")
        end
    end)

    Ball.Touched:Connect(function()
    
    end)
end

function BallManager.GetHumanoidRootPart(PlayerName): Part | nil
    if Players:FindFirstChild(PlayerName) == nil then
        return nil
    end

    local Player = Players[PlayerName]

    if Player == nil then
        return nil
    end

    return Player.Character.HumanoidRootPart
end

function BallManager.Restart(Ball: Part | nil, TargetPlayer: Player)
    if Ball == nil then return end
    local BallHitbox: Part = Ball:WaitForChild("Hitbox"):: Part

    BallManager.BallInfo.Position = game.Workspace.GameObjects.SpawnLocation.Attachment.WorldCFrame.Position
    BallManager.BallInfo.Direction = Vector3.new()
    Ball:SetAttribute("TargetPlayer", TargetPlayer.Name)

    Ball.Position = game.Workspace.GameObjects.SpawnLocation.Attachment.WorldCFrame.Position
    BallHitbox.Position = game.Workspace.GameObjects.SpawnLocation.Attachment.WorldCFrame.Position
end

return BallManager