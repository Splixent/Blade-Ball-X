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

export type BallInfo = {
    Position: Vector3,
    BallVelocity: number,
    Direction: Vector3,
    DirectAtTargetStrength: number,
    BallState: string,
    InStateFor: number,
    DistanceFromSurface: number,
    LastNonCollidedPosition: Vector3,
}

export type BallSettings = {
    CollisionStrength: number,
    DeflectStrength: number,
    MaxDistance: number,
    MinDistance: number,
    MaxVelocity: number,
    MaxDirectStrength: number,
    VelocityIncreaseRate: number,
    DirectIncreaseRate: number
}

export type Physics = {
    Movement: any,
    Collisions: any,
    Deflection: any
}

export type BallManager = {
    CurrentBall: Part | nil,
    CurrentHighlight: Highlight | nil,
    Debug: boolean,
    BallInfo: BallInfo,
    new: any,
    Start: any,
    GetHead: any,
    Restart: any,
    Deflect: any,
    ChooseRandomPlayingPlayer: any,
    GetDistanceFromHead: any,
    Physics: Physics,

    BallSettings: BallSettings

}

local BallManager: BallManager = {
    CurrentBall = nil,
    CurrentHighlight = nil,
    Debug = true,

    BallInfo = {
        Position = game.Workspace.GameObjects.SpawnLocation.Part.Attachment.WorldCFrame.Position,
        BallVelocity = 80,
        DirectAtTargetStrength = 0.01,
        Direction = Vector3.new(),
        BallState = "Out of Range",
        InStateFor = 0,
        DistanceFromSurface = 0,
        LastNonCollidedPosition = Vector3.new()
    },

    BallSettings = {
        CollisionStrength = 0.02,
        DeflectStrength = 0.02,

        MaxDistance = 11,
        MinDistance = 6,

        MaxVelocity = 2000,
        MaxDirectStrength = 1,

        VelocityIncreaseRate = 5,

        DirectIncreaseRate = 0.6
    },

    Physics = {}

}

function BallManager.new(TargetPlayer: Player?): Part | nil
    assert(TargetPlayer, "Player is nil")
    assert(BallManager.CurrentBall == nil, "Ball is not nil")
    assert(BallManager.CurrentHighlight == nil, "CurrentHighlight is not nil")

    local Ball: Part = ReplicatedStorage.Assets.ServerBall:Clone():: Part
    Ball.Parent = game.Workspace.GameObjects
    Ball.CFrame = game.Workspace.GameObjects.SpawnLocation.Part.Attachment.WorldCFrame

    local BallHitbox: Part = Ball:WaitForChild("Hitbox"):: Part
    BallHitbox.CFrame = game.Workspace.GameObjects.SpawnLocation.Part.Attachment.WorldCFrame

    Ball:SetAttribute("TargetPlayer", TargetPlayer.Name)

    BallManager.CurrentBall = Ball
    BallManager.CurrentHighlight = ReplicatedStorage.Assets.Highlight:Clone()

    assert(BallManager.CurrentHighlight, "Highlight is nil")

    BallManager.CurrentHighlight.Parent = TargetPlayer.Character

    NewBall:FireAll(Ball)

    return Ball
end

function BallManager.Start(Ball: Part)
    RunService.Stepped:Connect(function(Time: number, DeltaTime: number)
        local BallHitbox: Part = Ball:WaitForChild("Hitbox"):: Part
        local Head = BallManager.GetHead(Ball:GetAttribute("TargetPlayer"))

        if Head and BallManager.CurrentBall then
            BallManager.Physics.Movement(DeltaTime, Head)
            BallManager.Physics.Collisions(DeltaTime, Ball, BallHitbox)
            BallManager.Physics.Deflection(DeltaTime, Ball, BallHitbox, Head)
        else
            print(Ball:GetAttribute("TargetPlayer").." left the game")
        end
    end)
end

function BallManager.Restart(Ball: Part?, TargetPlayer: Player?)
    assert(Ball, "Ball is nil")
    assert(TargetPlayer, "Player is nil")

    local BallHitbox: Part = Ball:WaitForChild("Hitbox"):: Part

    BallManager.BallInfo.BallVelocity = 80
    BallManager.BallInfo.DirectAtTargetStrength = 2

    BallManager.BallInfo.Position = game.Workspace.GameObjects.SpawnLocation.Part.Attachment.WorldCFrame.Position
    BallManager.BallInfo.Direction = Vector3.new()
    Ball:SetAttribute("TargetPlayer", TargetPlayer.Name)

    Ball.Position = game.Workspace.GameObjects.SpawnLocation.Part.Attachment.WorldCFrame.Position
    BallHitbox.Position = game.Workspace.GameObjects.SpawnLocation.Part.Attachment.WorldCFrame.Position
end


function BallManager.Physics.Movement(DeltaTime: number, Head: BasePart)
    BallManager.BallInfo.Direction = BallManager.BallInfo.Direction:Lerp(CFrame.lookAt(BallManager.BallInfo.Position, Head.Position).LookVector, BallManager.BallInfo.DirectAtTargetStrength)
    BallManager.BallInfo.Position = BallManager.BallInfo.Position:Lerp(BallManager.BallInfo.Position + BallManager.BallInfo.Direction * BallManager.BallInfo.BallVelocity, DeltaTime)
end

function BallManager.Physics.Collisions(DeltaTime: number, Ball: Part, BallHitbox: Part)
    local BoundCollisionParams = OverlapParams.new()
    BoundCollisionParams.FilterType = Enum.RaycastFilterType.Include
    BoundCollisionParams.FilterDescendantsInstances = {game.Workspace.Map}

    local NewPosition = BallManager.BallInfo.Position
    local CurrentPosition = Ball.Position

    local PartsInNewPosition = workspace:GetPartBoundsInRadius(NewPosition, Ball.Size.X / 2, BoundCollisionParams)

    if #PartsInNewPosition > 0 then
        local CollisionParams = RaycastParams.new()
        CollisionParams.FilterType = Enum.RaycastFilterType.Include
        CollisionParams.FilterDescendantsInstances = {game.Workspace.Map}

        local CurrentLookAtNew = CFrame.lookAt(CurrentPosition, NewPosition).LookVector
        local CurrentNewMagnitude = (CurrentPosition - NewPosition).Magnitude

        local RaycastResults = workspace:Spherecast(CurrentPosition, Ball.Size.X / 2, CurrentLookAtNew * CurrentNewMagnitude, CollisionParams)

        if RaycastResults then
            --[[ Visualize
                local Part = Instance.new("Part")
            Part.Size = Vector3.new(1, 1, 1)
            Part.Anchored = true
            Part.CanCollide = false
            Part.Material = Enum.Material.Neon
            Part.Color = Color3.fromRGB(255, 255, 255)

            Part.Parent = game.Workspace
            Part.Position = RaycastResults.Position
            ]]

            local ReflectedNormal = CurrentLookAtNew - (2 * CurrentLookAtNew:Dot(RaycastResults.Normal) * RaycastResults.Normal)

            BallManager.BallInfo.Direction = BallManager.BallInfo.Direction:Lerp(ReflectedNormal * BallManager.BallInfo.BallVelocity, BallManager.BallSettings.CollisionStrength)
            BallManager.BallInfo.Position = BallManager.BallInfo.Position:Lerp(BallManager.BallInfo.Position + BallManager.BallInfo.Direction, BallManager.BallSettings.CollisionStrength)
        else
            local LastLookAtNew = CFrame.lookAt(BallManager.BallInfo.LastNonCollidedPosition, NewPosition).LookVector
            local LastNewMagnitude = (NewPosition - BallManager.BallInfo.LastNonCollidedPosition).Magnitude
            
            local NewRaycastResults = workspace:Spherecast(BallManager.BallInfo.LastNonCollidedPosition, Ball.Size.X / 2, LastLookAtNew * LastNewMagnitude, CollisionParams)

            if NewRaycastResults then
                local ReflectedNormal = LastLookAtNew - (2 * LastLookAtNew:Dot(NewRaycastResults.Normal) * NewRaycastResults.Normal)

                BallManager.BallInfo.Direction = BallManager.BallInfo.Direction:Lerp(ReflectedNormal * BallManager.BallInfo.BallVelocity, BallManager.BallSettings.CollisionStrength)
                BallManager.BallInfo.Position = BallManager.BallInfo.LastNonCollidedPosition:Lerp(BallManager.BallInfo.LastNonCollidedPosition + BallManager.BallInfo.Direction, BallManager.BallSettings.CollisionStrength)
            end

        end
    else
        BallManager.BallInfo.LastNonCollidedPosition = CurrentPosition
    end

    Ball.Position = BallManager.BallInfo.Position
    BallHitbox.Position = BallHitbox.Position:Lerp(BallManager.BallInfo.Position, DeltaTime * 50)
end

function BallManager.Physics.Deflection(DeltaTime: number, Ball: Part, BallHitbox: Part, Head: BasePart)
    local Magnitude = (Head.Position - BallHitbox.Position).Magnitude

    if Magnitude > ScriptUtils.dubinvlerp(BallManager.BallInfo.BallVelocity, 0, BallManager.BallSettings.MaxVelocity, BallManager.BallSettings.MaxDistance, BallManager.BallSettings.MaxDistance * 3) then
        if BallManager.BallInfo.BallState ~= "Out of Range" then
            BallManager.BallInfo.InStateFor = os.clock()
            BallManager.BallInfo.BallState = "Out of Range"
        end
    end

    if Magnitude <= ScriptUtils.dubinvlerp(BallManager.BallInfo.BallVelocity, 0, BallManager.BallSettings.MaxVelocity, BallManager.BallSettings.MaxDistance, BallManager.BallSettings.MaxDistance * 3) and Magnitude > BallManager.BallSettings.MinDistance then
        if game.Workspace.GameObjects.DeflectBots:FindFirstChild(Ball:GetAttribute("TargetPlayer")) then
            local NewTarget = BallManager.ChooseRandomPlayingPlayer(game.Workspace.GameObjects.DeflectBots[Ball:GetAttribute("TargetPlayer")].Name)
            Head = BallManager.GetHead(NewTarget)
            Magnitude = (Head.Position - Ball.Position).Magnitude

            BallManager.Deflect(CFrame.lookAt(game.Workspace.GameObjects.DeflectBots[Ball:GetAttribute("TargetPlayer")].Head.Position, Head.Position).LookVector, NewTarget)
        end

        if BallManager.BallInfo.BallState ~= "In Range" then
            BallManager.BallInfo.InStateFor = os.clock()
            BallManager.BallInfo.BallState = "In Range"
        end
    end

    if Magnitude < BallManager.BallSettings.MinDistance then
        if game.Workspace.GameObjects.DeflectBots:FindFirstChild(Ball:GetAttribute("TargetPlayer")) then
            local NewTarget = BallManager.ChooseRandomPlayingPlayer(game.Workspace.GameObjects.DeflectBots[Ball:GetAttribute("TargetPlayer")].Name)
            Head = BallManager.GetHead(NewTarget)
            Magnitude = (Head.Position - Ball.Position).Magnitude

            BallManager.Deflect(CFrame.lookAt(game.Workspace.GameObjects.DeflectBots[Ball:GetAttribute("TargetPlayer")].Head.Position, Head.Position).LookVector, NewTarget)
        end
        
        if BallManager.BallInfo.BallState ~= "Kill" then
            BallManager.BallInfo.InStateFor = os.clock()
            BallManager.BallInfo.BallState = "Kill"
        end

        local TargetPlayer = Players:FindFirstChild(Ball:GetAttribute("TargetPlayer"))

        if TargetPlayer ~= nil then
            local Ping = TargetPlayer:GetNetworkPing()

            if os.clock() - BallManager.BallInfo.InStateFor > (0.3 + Ping) then
                local TargetCharacter = TargetPlayer.Character
                TargetCharacter.Humanoid.Health = 0
            end
        end

    end
end


function BallManager.ChooseRandomPlayingPlayer(Exclude: string): string?
    local AllPlayers = Players:GetPlayers()

    assert(BallManager.CurrentBall)
    assert(Exclude, "Exclude is nil")
    assert(#AllPlayers > 0, "No more players")

    if #AllPlayers == 1 and game.Workspace.GameObjects.DeflectBots[Exclude] == nil then
        return game.Workspace.GameObjects.DeflectBots:GetChildren()[math.random(1, #game.Workspace.GameObjects.DeflectBots:GetChildren())].Name
    end

    local ChosenPlayer = AllPlayers[math.random(1, #AllPlayers)]
    local ChosenPlayerEntity = PlayerEntityManager.new(ChosenPlayer)

    if ChosenPlayerEntity.Data.Playing == true and ChosenPlayer.Name ~= Exclude then
        return ChosenPlayer.Name
    end

    return BallManager.ChooseRandomPlayingPlayer(Exclude)
end

function BallManager.GetDistanceFromHead(PlayerName): Part?
    if game.Workspace.GameObjects.DeflectBots:FindFirstChild(PlayerName) then
        return game.Workspace.GameObjects.DeflectBots[PlayerName].Head
    end

    if Players:FindFirstChild(PlayerName) == nil then
        return nil
    end

    local Player = Players[PlayerName]

    if Player == nil then
        return nil
    end

    if BallManager.CurrentBall == nil then
        return nil
    end
    
    return (Player.Character.Head.Position - BallManager.CurrentBall.Position).Magnitude
end

function BallManager.GetHead(PlayerName: string): Part?
    if game.Workspace.GameObjects.DeflectBots:FindFirstChild(PlayerName) then
        return game.Workspace.GameObjects.DeflectBots[PlayerName].Head
    end

    assert(Players:FindFirstChild(PlayerName), "Player is nil")

    local Player = Players[PlayerName]

    if Player == nil then
        return nil
    end

    return Player.Character.Head
end

function BallManager.Deflect(NewDirection: Vector3, TargetName: string?)
    assert(BallManager.CurrentBall ~= nil, "Ball is nil")
    assert(BallManager.Debug, "Is not debug")
    assert(TargetName, "TargetName is nil")
    assert(BallManager.CurrentHighlight, "CurrentHighlight is nil")

    BallManager.CurrentBall:SetAttribute("TargetPlayer", TargetName)

    BallManager.CurrentHighlight.Parent = BallManager.GetHead(TargetName).Parent

    local BallHitbox: Part = BallManager.CurrentBall:WaitForChild("Hitbox"):: Part

    BallManager.BallInfo.Direction = BallManager.BallInfo.Direction:Lerp(NewDirection * BallManager.BallInfo.BallVelocity, BallManager.BallSettings.DeflectStrength)
    BallManager.BallInfo.Position = BallManager.BallInfo.Position:Lerp(BallManager.BallInfo.Position + BallManager.BallInfo.Direction, BallManager.BallSettings.DeflectStrength)

    BallManager.Physics.Collisions(0.016, BallManager.CurrentBall, BallHitbox)

    BallManager.CurrentBall.CFrame = BallManager.CurrentBall.CFrame:Lerp(CFrame.lookAt(BallManager.CurrentBall.Position, BallManager.BallInfo.Position), BallManager.BallSettings.DeflectStrength)
    BallManager.CurrentBall.Position = BallManager.BallInfo.Position

    BallManager.BallInfo.BallVelocity = math.clamp(BallManager.BallInfo.BallVelocity + BallManager.BallSettings.VelocityIncreaseRate, 0, BallManager.BallSettings.MaxVelocity)
    BallManager.BallInfo.DirectAtTargetStrength = math.clamp(ScriptUtils.dubinvlerp(BallManager.BallInfo.BallVelocity, 0, BallManager.BallSettings.MaxVelocity * BallManager.BallSettings.DirectIncreaseRate, 0, 1), 0, 1)

    --print("Ball Velocity: "..BallManager.BallInfo.BallVelocity)
    --print("Ball Redirect Strength: "..BallManager.BallInfo.DirectAtTargetStrength)

end



return BallManager