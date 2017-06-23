local UserManager = {}
UserManager.__index = UserManager

function UserManager:new()
	local self = {
		m_dwMyUserID = 0xFFFFFFFF,
		m_dwMyDBID = 0xFFFFFFFF,
		m_userList = {}
	}
	setmetatable(self,UserManager)
	return self
end

function UserManager:getUserCount()
	return #self.m_userList
end

function UserManager:setMyUserID(myUserID)
	self.m_dwMyUserID = myUserID
end

function UserManager:getMyUserID()
	return self.m_dwMyUserID
end

function UserManager:setMyDBID(myDBID)
	self.m_dwMyDBID = myDBID
end

function UserManager:getMyDBID()
	return self.m_dwMyDBID
end

function UserManager:addUser(user)
	self.m_userList[#self.m_userList + 1] = user
end

function UserManager:removeUser(dwUserID)
	dwUserID = dwUserID % 0x10000
	for i=1,#self.m_userList do
		if dwUserID == self.m_userList[i]:getUserID() then
			table.remove(self.m_userList,i)
			return
		end
	end
end

function UserManager:getUser(dwUserID)
	dwUserID = dwUserID % 0x10000
	for i=1,#self.m_userList do
		if dwUserID == self.m_userList[i]:getUserID() then
			return self.m_userList[i]
		end
	end
	return nil
end

function UserManager:getMyInfo()
	return self:getUser(self.m_dwMyUserID)
end

function UserManager:clearAllUser()
	self.m_userList = {}
end

function UserManager:getUserByDBID(dwDBID)
	for i=1,#self.m_userList do
		if dwDBID == self.m_userList[i]:getUserDBID() then
			return self.m_userList[i]
		end
	end
	return nil
end

function UserManager:updateGameUser(user)
	for i=1,#self.m_userList do
		if user:getUserID() == self.m_userList[i]:getUserID() then
			self.m_userList[i] = user
			return true
		end
	end
	return false
end

function UserManager:updateUserScore(wUserID, bufScore,nLen)
	wUserID = wUserID % 0x10000
	local ba = require("ByteArray").new()
	ba:initBuf(bufScore)
	--cclog("updateUserScore nLen = " .. nLen .. ",ba:len = " .. ba:getLen())
	for i=1,#self.m_userList do
		if wUserID == self.m_userList[i]:getUserID() then
			self.m_userList[i]._scoreBuf = bufScore
			self.m_userList[i]._scoreBufLen = nLen
			return true
		end
	end
	return false
end

function UserManager:updateUserFame(wUserID, nFameLevel,nFameScore,cbVIPLevel)
	wUserID = wUserID % 0x10000
	for i=1,#self.m_userList do
		if wUserID == self.m_userList[i]:getUserID() then
			self.m_userList[i]._fame = nFameScore
			self.m_userList[i]._fameLevel = nFameLevel
			self.m_userList[i].m_cbVipLevel = cbVIPLevel
			return true
		end
	end
	return false
end

function UserManager:getUserByTableChair(wTableID,cbChair)
	for i=1,#self.m_userList do
		if self.m_userList[i]._tableID == wTableID 
			and self.m_userList[i]._chairID == cbChair 
			and self.m_userList[i].isPlayer() then
			return self.m_userList[i]
		end
	end
	return nil
end

function UserManager:findUserByTableIndex(wTableID)
	local list = {}
	for i=1,#self.m_userList do	
		if self.m_userList[i]._tableID == wTableID then
			list[#list + 1] = self.m_userList[i]
		end
	end
	return list
end

return UserManager