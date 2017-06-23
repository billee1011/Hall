ContinueAwardInfo = {}
ContinueAwardInfo.__index = ContinueAwardInfo

function ContinueAwardInfo:new()
	--int nContinueTime;
	--int nAwardAmount;
	local self = {
		nContinueTime = 0,
		nAwardAmount = 0
	}

	setmetatable(self, ContinueAwardInfo)

	return self
end