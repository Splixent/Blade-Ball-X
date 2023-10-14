--!strict

local HttpService = game:GetService("HttpService")

local SyncedTime = {
    MonthStrings = {
        Jan = 1,
        Feb = 2,
        Mar = 3,
        Apr = 4,
        May = 5,
        Jun = 6,
        Jul = 7,
        Aug = 8,
        Sep = 9,
        Oct = 10,
        Nov = 11,
        Dec = 12
    },

    isInited = false,
    originTime = 0,
    responseTime = 0,
    responseDelay = 0,
}

function SyncedTime:RFC2616DateStringToUnixTimestamp(DateString: string): number
    local day, MonthString, year, hour, min, sec = DateString:match(".*, (.*) (.*) (.*) (.*):(.*):(.*) .*")
	local month = self.MonthStrings[MonthString]
	local Date = {
		day = day,
		month = month,
		year = year,
		hour = hour,
		min = min,
		sec = sec
	}
	
	return os.time(Date:: any)
end

function SyncedTime.Inited(): boolean
	return SyncedTime.isInited
end

function SyncedTime.Init()
	if not SyncedTime.isInited then
		local ok = pcall(function()
			local requestTime = tick()
			local response = HttpService:RequestAsync({Url="http://google.com"}) 
			local dateStr = response.Headers.date
			SyncedTime.originTime = SyncedTime:RFC2616DateStringToUnixTimestamp(dateStr)
			SyncedTime.responseTime = tick()
			SyncedTime.responseDelay = (SyncedTime.responseTime - requestTime) / 2
		end)
		if not ok then
			warn("Cannot get time from google.com. Make sure that http requests are enabled!")
			SyncedTime.originTime = os.time()
			SyncedTime.responseTime = tick()
			SyncedTime.responseDelay = 0
		end
		
		SyncedTime.isInited = true
	end
end

function SyncedTime.Time(): number
	if not SyncedTime.isInited then
		SyncedTime.Init()
	end
	
	return SyncedTime.originTime + tick() - SyncedTime.responseTime - SyncedTime.responseDelay
end

SyncedTime.Init()

return {
	Inited = SyncedTime.Inited,
	Init = SyncedTime.Init,
	Time = SyncedTime.Time
}