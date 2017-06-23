
local Chair = {userID , empty}
Chair.__index = Chair

function Chair:new()
	local self = {
		userID = 0xFFFF,
		empty = true
	}
	setmetatable(self,Chair)
	return self
end

function Chair:isEmpty()
	return self.empty
end

function Chair:getUserID()
	return self.userID
end

function Chair:setUserID(nUserID)
	self.userID = nUserID
	return self
end

function Chair:setEmpty(bEmpty)
	self.empty = bEmpty
	return self
end

return Chair