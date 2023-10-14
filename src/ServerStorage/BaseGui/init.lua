--local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
--local Client = Players.LocalPlayer.PlayerScripts.Client

local Fusion = require(Shared.Fusion)
local Functions = require(script.Functions)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

return New "ScreenGui" {
    Name = "ScreenGui",
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

    [Children] = {
        New "ImageButton" {
            Name = "ImageButton",
            Image = "rbxassetid://15043829202",
            ScaleType = Enum.ScaleType.Fit,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(0.133, 0.237),

            [OnEvent "MouseButton1Click"] = Functions.Print
        },
    }
}