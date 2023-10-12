local Shared = game:GetService("ReplicatedStorage").Shared

local Maid = require(Shared.Maid)

local SoundService = game:GetService("SoundService")

local SoundManager = {}

function SoundManager.new(Properties: any): Sound
    local Sound = Instance.new("Sound")
    for PropertyName, PropertyValue in pairs (Properties) do
        if PropertyName == "SoundGroup" then
            Sound[PropertyName] = SoundService[PropertyValue]
        elseif PropertyName == "Parent" then
            if typeof(PropertyValue) == "string" then
                Sound[PropertyName] = SoundService[PropertyValue]
            else
                Sound[PropertyName] = PropertyValue
            end
        else
            Sound[PropertyName] = PropertyValue
        end
    end

    return Sound
end

function SoundManager.CreatePlayDestroy(Properties: any)
    local Sound = SoundManager.new(Properties)
    local SoundMaid = Maid.new()

    Sound:Play()

    SoundMaid:GiveTask(Sound.Ended:Connect(function()
        Sound:Destroy()
        SoundMaid:Destroy()
    end))
end

return SoundManager