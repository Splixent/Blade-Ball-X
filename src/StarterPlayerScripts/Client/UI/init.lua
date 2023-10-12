local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Client = Players.LocalPlayer.PlayerScripts.Client

local Fusion = require(Shared.Fusion)

local New = Fusion.New
local Children = Fusion.Children

local Player = Players.LocalPlayer

local UI = {}

for i, Component in ipairs (script.Components:GetChildren()) do
    table.insert(UI, require(Component))
end 

New "ScreenGui" {
    Name = "UI",
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = Player.PlayerGui,
    IgnoreGuiInset = true,

    [Children] = {
        UI
    }
}

return nil