local Shared = game:GetService("ReplicatedStorage").Shared

local Red = require(Shared.Red)
local Guard = require(Shared.Guard)

function CheckTargets(Targets)
    Guard.Any(Targets)

    for TargetName, ScreenPoint in pairs (Targets) do
        Guard.String(TargetName)
        Guard.Vector2(ScreenPoint)
    end

    return Targets
end

function IsUnit(Vector3)
    assert(Vector3.magnitude >= -1.7320507764816284 and Vector3.magnitude <= 1.7320507764816284, "Not in Units")
    return Vector3
end

return Red.Event("Deflect", function(Targets, ScreenCenter, LookDirection)

    return CheckTargets(Targets), Guard.Vector2(ScreenCenter), IsUnit(LookDirection)
end)