local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage.Shared

local Fusion = require(Shared.Fusion)
local Functions = require(script.Functions)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

if string.lower(Players.LocalPlayer.Name) == "splixent" or string.lower(Players.LocalPlayer.Name) == "player1" then
    return New "ScreenGui" {
        Name = "ScreenGui",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    
        [Children] = {
            New "TextButton" {
                Name = "TextButton",
                FontFace = Font.new(
                    "rbxasset://fonts/families/GothamSSm.json",
                    Enum.FontWeight.Bold,
                    Enum.FontStyle.Normal
                ),
                Text = "Spawn Ball",
                TextColor3 = Color3.fromRGB(104, 205, 88),
                TextSize = 30,
                BackgroundColor3 = Color3.fromRGB(90, 255, 115),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.88, 0.925),
                Size = UDim2.fromScale(0.104, 0.0463),
    
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0.2, 0),
                    },
    
                    New "UIStroke" {
                        Name = "UIStroke",
                        Color = Color3.fromRGB(29, 29, 29),
                        Thickness = 4,
                    },
    
                    New "UIStroke" {
                        Name = "UIStroke",
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Color = Color3.fromRGB(29, 29, 29),
                        Thickness = 4,
                    },
                },
    
                [OnEvent "MouseButton1Click"] = Functions.SpawnBall,
            },
    
            New "TextButton" {
                Name = "TextButton",
                FontFace = Font.new(
                    "rbxasset://fonts/families/GothamSSm.json",
                    Enum.FontWeight.Bold,
                    Enum.FontStyle.Normal
                ),
                Text = "Respawn Ball",
                TextColor3 = Color3.fromRGB(205, 88, 92),
                TextSize = 30,
                BackgroundColor3 = Color3.fromRGB(255, 109, 90),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.88, 0.866),
                Size = UDim2.fromScale(0.104, 0.0463),
            
                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0.2, 0),
                    },
            
                    New "UIStroke" {
                        Name = "UIStroke",
                        Color = Color3.fromRGB(29, 29, 29),
                        Thickness = 4,
                    },
            
                    New "UIStroke" {
                        Name = "UIStroke",
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Color = Color3.fromRGB(29, 29, 29),
                        Thickness = 4,
                    },
                },
    
                [OnEvent "MouseButton1Click"] = Functions.RespawnBall
            }
        }
    }
end

return nil