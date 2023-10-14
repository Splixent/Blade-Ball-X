local Shared = game:GetService("ReplicatedStorage").Shared

local Red = require(Shared.Red)
local Guard = require(Shared.Guard)

function IsUnit(Vector3)
    assert(Vector3.magnitude >= -1.7320507764816284 and Vector3.magnitude <= 1.7320507764816284, "Not in Units")
    return Vector3
end

return Red.Event("SetDirection", function(Vector3)
    return IsUnit(Guard.Vector3(Vector3))
end)