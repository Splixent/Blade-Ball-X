--!strict

local Shared = game:GetService("ReplicatedStorage").Shared

local Fusion = require(Shared.Fusion)
local PubTypes = require(Shared.Fusion.PubTypes)

local Spring = Fusion.Spring
local Value = Fusion.Value

local ScriptUtils = {
	DaySeedOffset = 2
}

function ScriptUtils.Lerp(Min: number, Max: number, Alpha: number): number
    return Min + ((Max - Min) * Alpha)
end

function ScriptUtils.InverseLerp(value: number, min: number, max: number): number
	return (value / 100) * (max - min) + min
end

function ScriptUtils.DoubleInverseLinearInterpolation(value: number, min: number, max: number, mintwo: number, maxtwo: number): number
	return (value - min) / (max - min) * (maxtwo - mintwo) + mintwo
end

function ScriptUtils.dubinvlerp(value: number, min: number, max: number, mintwo: number, maxtwo: number): number
	return (value - min) / (max - min) * (maxtwo - mintwo) + mintwo
end

function ScriptUtils.HMSFormat(Int: number): string
	return string.format("%02i", Int)
end

function ScriptUtils.CreateSpring<T>(Properties: { Initial: PubTypes.Spring<T>, Speed: number, Damper: number }): { Value: PubTypes.Value<any>, Spring: PubTypes.Spring<T>}
    local SetValue = Value(Properties.Initial)
    local SetSpring = Spring(SetValue, Properties.Speed, Properties.Damper)

    return {
        Value = SetValue,
        Spring = SetSpring,
    }
end

function ScriptUtils.ConvertToDHMS(Seconds: number): string
	return string.format("%02i:%02i:%02i:%02i", Seconds / (60^2 * 24), (Seconds % (60^2 * 24)) / (60^2), (Seconds % (60^2)) / 60, Seconds % 60)
end

function ScriptUtils.ConvertToDHMSPlus(Seconds: number): string
	return string.format("%02id:%02ih:%02im:%02is", Seconds / (60^2 * 24), (Seconds % (60^2 * 24)) / (60^2), (Seconds % (60^2)) / 60, Seconds % 60)
end

function ScriptUtils.ConvertToHMS(Seconds: number): string
	return string.format("%02i:%02i:%02i", Seconds/60^2, Seconds/60%60, Seconds%60)
end

function ScriptUtils.ConvertToMS(Seconds: number): string
	return string.format("%02i:%02i", Seconds/60%60, Seconds%60)
end

function ScriptUtils.WeightedRandom(Dictionary: { Initial: any, Speed: number, Damper: number }, RandomSeed: Random?, ReturnObject: boolean?): any | boolean?
	local TotalWeight = 0
	for _, ChanceInfo in pairs(Dictionary) do
		TotalWeight = TotalWeight + ChanceInfo.Weight
	end

	local RandomNumber = if RandomSeed ~= nil then RandomSeed:NextNumber() * TotalWeight else math.random() * TotalWeight

	for Index, ChanceInfo in pairs(Dictionary) do
		if  RandomNumber <= ChanceInfo.Weight then
			ChanceInfo.Chance = ChanceInfo.Weight / TotalWeight
			ChanceInfo.Index = Index
			if ReturnObject == nil then
				return ChanceInfo.Object
			else
				return ChanceInfo
			end
		else
			RandomNumber = RandomNumber - ChanceInfo.Weight
		end
	end
end

function ScriptUtils.DeepCompare(t1: any, t2: any, ignore_mt: boolean?)
    local ty1 = type(t1)
    local ty2 = type(t2)
    if ty1 ~= ty2 then return false end
    -- non-table types can be directly compared
    if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
    -- as well as tables which have the metamethod __eq
    local mt = getmetatable(t1)
    if not ignore_mt and mt and mt.__eq then return t1 == t2 end
    for k1, v1 in pairs(t1) do
        local v2 = t2[k1]
        if v2 == nil or not ScriptUtils.DeepCompare(v1, v2) then return false end
    end
    for k2, v2 in pairs(t2) do
        local v1 = t1[k2]
        if v1 == nil or not ScriptUtils.DeepCompare(v1, v2) then return false end
    end
    return true
end

function ScriptUtils.DeepCopy(original: any): any
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = ScriptUtils.DeepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

function ScriptUtils.NumberIsEvenOdd(Number: number): boolean
	if Number % 2 == 0 then
		return true
	else
		return false
	end
end

function ScriptUtils.MergeTables(t1: any, t2: any): any
	local Result = {}

	for key, value in pairs(t1) do
		Result[key] = value
	end

	for key, value in pairs(t2) do
		Result[key] = value
	end
  
	return Result
end

function ScriptUtils.StringToBool(str: string): boolean
	return string.lower(str or "") == "true"
end

function ScriptUtils.CommaValue(amount: number): string
	local formatted = tostring(amount)
	local k
	while true do  
	  formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
	  if (k==0) then
		break
	  end
	end
	return formatted
end

function ScriptUtils.GetSourceModule(): string
	return string.split(debug.info(2, "s"), ".")[#string.split(debug.info(2, "s"), ".")]
end

function ScriptUtils.GetOffset(): number
	return ScriptUtils.DaySeedOffset
end

return ScriptUtils