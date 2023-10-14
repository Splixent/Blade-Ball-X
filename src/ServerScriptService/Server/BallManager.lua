--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Shared
local Server = ServerScriptService.Server

local Events = require(Shared.Events)
local PlayerEntityManager = require(Server.PlayerEntityManager)
local ScriptUtils = require(Shared.ScriptUtils)

local NewBall = Events.NewBall:Server()

export type BallManager = {
    CurrentBall: Part?,
    Debug: boolean,
    MaxBallVelocity: number,
    BallInfo: any,
    new: any,
    Start: any,
    GetHead: any,
    Restart: any,
    Deflect: any,
    ChooseRandomPlayingPlayer: any

}

local BallManager: BallManager = {
    CurrentBall = nil,
    Debug = true,

    BallInfo = {
        Position = game.Workspace.GameObjects.SpawnLocation.Part.Attachment.WorldCFrame.Position,
        PreviousPosition = Vector3.new(),
        BallVelocity = 200,
        Direction = Vector3.new(),
        BallState = "Out of Range"
    },

    MaxBallVelocity = 1000
}

function BallManager.new(TargetPlayer: Player): Part | nil
    if BallManager.CurrentBall ~= nil then return nil end

    local Ball: Part = ReplicatedStorage.Assets.ServerBall:Clone():: Part
    Ball.Parent = game.Workspace.GameObjects
    Ball.CFrame = game.Workspace.GameObjects.SpawnLocation.Part.Attachment.WorldCFrame

    local BallHitbox: Part = Ball:WaitForChild("Hitbox"):: Part
    BallHitbox.CFrame = game.Workspace.GameObjects.SpawnLocation.Part.Attachment.WorldCFrame

    Ball:SetAttribute("TargetPlayer", TargetPlayer.Name)

    BallManager.CurrentBall = Ball

    NewBall:FireAll(Ball)

    return Ball
end

function BallManager.Start(Ball: Part)
    RunService.Stepped:Connect(function(Time: number, DeltaTime: number)
        local HumanoidRootPart = BallManager.GetHead(Ball:GetAttribute("TargetPlayer"))

        if HumanoidRootPart then

            --------------------------> Movement

            local BallHitbox: Part = Ball:WaitForChild("Hitbox"):: Part

            local Position = BallManager.BallInfo.Position
            local Direction = BallManager.BallInfo.Direction
            local BallVelocity = BallManager.BallInfo.BallVelocity

            Direction = Direction:Lerp(CFrame.lookAt(Ball.Position, HumanoidRootPart.Position).LookVector, DeltaTime * 9)
            Position = Position:Lerp(Position + Direction * BallVelocity, DeltaTime)

            BallManager.BallInfo.Position = Position
            BallManager.BallInfo.Direction = Direction

            --------------------------> Collisions

            local CollisionParams = RaycastParams.new()
            CollisionParams.FilterDescendantsInstances = {game.Workspace.Map}
            CollisionParams.FilterType = Enum.RaycastFilterType.Include

            local RaycastDistance = 3.5

            local Raycasts = {
                RaycastResult1 = workspace:Spherecast(Ball.Position - (Ball.CFrame.LookVector * RaycastDistance), RaycastDistance, Ball.CFrame.LookVector * RaycastDistance, CollisionParams),
                RaycastResult2 = workspace:Spherecast(Ball.Position - (-Ball.CFrame.LookVector * RaycastDistance), RaycastDistance, -Ball.CFrame.LookVector * RaycastDistance, CollisionParams),
                RaycastResult3 = workspace:Spherecast(Ball.Position - (Ball.CFrame.UpVector * RaycastDistance), RaycastDistance, Ball.CFrame.UpVector * RaycastDistance, CollisionParams),
                RaycastResult4 = workspace:Spherecast(Ball.Position - (-Ball.CFrame.UpVector * RaycastDistance), RaycastDistance, -Ball.CFrame.UpVector * RaycastDistance, CollisionParams)
            }

            for i, RaycastResult in pairs (Raycasts) do
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

                    Direction = Direction:Lerp(RaycastResult.Normal * BallVelocity * 0.1, DeltaTime)
                    Position = Position:Lerp(Position + Direction, DeltaTime)

                    BallManager.BallInfo.Direction = Direction
                    BallManager.BallInfo.Position = Position

                    break
                end
            end

            BallManager.BallInfo.PreviousPosition = Ball.Position

            Ball.CFrame = Ball.CFrame:Lerp(CFrame.lookAt(Ball.Position, BallManager.BallInfo.Position), DeltaTime)
            Ball.Position = BallManager.BallInfo.Position
            BallHitbox.Position = BallHitbox.Position:Lerp(BallManager.BallInfo.Position, 1.95)

            --------------------------> Deflection + Killing

            local Magnitude = (HumanoidRootPart.Position - Ball.Position).Magnitude

            if Magnitude > 8 then
                BallManager.BallInfo.BallState = "Out of Range"
            end

            if Magnitude <= 8 and Magnitude >= 2 then
                BallManager.BallInfo.BallState = "In Range"

                if Ball:GetAttribute("TargetPlayer") == "#" then
                    Ball:SetAttribute("TargetPlayer", BallManager.ChooseRandomPlayingPlayer().Name)
                end
            end

            if Magnitude < 2 then
                BallManager.BallInfo.BallState = "Kill"
            end


        else
            print(Ball:GetAttribute("TargetPlayer").." left the game")
        end
    end)

    Ball.Touched:Connect(function()
    
    end)
end

function BallManager.ChooseRandomPlayingPlayer()
    local AllPlayers = Players:GetPlayers()

    local ChosenPlayer = AllPlayers[math.random(1, #AllPlayers)]

    local ChosenPlayerEntity = PlayerEntityManager.new(ChosenPlayer)

    if ChosenPlayerEntity.Data.Playing == true then
        return ChosenPlayer
    end
    BallManager.ChooseRandomPlayingPlayer()
end

function BallManager.GetHead(PlayerName): Part | nil
    if PlayerName == "#" then
        return game.Workspace.GameObjects.DeflectBot.Head
    end

    if Players:FindFirstChild(PlayerName) == nil then
        return nil
    end

    local Player = Players[PlayerName]

    if Player == nil then
        return nil
    end

    return Player.Character.Head
end

function BallManager.Deflect(NewDirection)
    if BallManager.Debug == true then
        if BallManager.CurrentBall ~= nil then
            BallManager.CurrentBall:SetAttribute("TargetPlayer", "#")
            BallManager.BallInfo.Direction = BallManager.BallInfo.Direction:Lerp(NewDirection * BallManager.BallInfo.BallVelocity, 0.0166)
            BallManager.BallInfo.Position = BallManager.BallInfo.Position:Lerp(BallManager.BallInfo.Position + BallManager.BallInfo.Direction, 0.0166 * 100)

            BallManager.CurrentBall.CFrame = BallManager.CurrentBall.CFrame:Lerp(CFrame.lookAt(BallManager.CurrentBall.Position, BallManager.BallInfo.Position), 0.0166 * 100)
            BallManager.CurrentBall.Position = BallManager.BallInfo.Position

        end
    end
end

function BallManager.Restart(Ball: Part | nil, TargetPlayer: Player)
    if Ball == nil then return end
    local BallHitbox: Part = Ball:WaitForChild("Hitbox"):: Part

    BallManager.BallInfo.Position = game.Workspace.GameObjects.SpawnLocation.Part.Attachment.WorldCFrame.Position
    BallManager.BallInfo.Direction = Vector3.new()
    Ball:SetAttribute("TargetPlayer", TargetPlayer.Name)

    Ball.Position = game.Workspace.GameObjects.SpawnLocation.Part.Attachment.WorldCFrame.Position
    BallHitbox.Position = game.Workspace.GameObjects.SpawnLocation.Part.Attachment.WorldCFrame.Position
end

return BallManager