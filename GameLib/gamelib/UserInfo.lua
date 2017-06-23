require("GameLib/common/common")

local UserInfo = {}
UserInfo.__index = UserInfo

function UserInfo:new()
	local self = {
	_faceID = 0,
	_userDBID = 0,
	_userLevel = 0,
	_groupID = 0,
	_name = "",
	_maxim = "",
	_age = 0,
	_sex = 0,
	_fame = 0,
	_fameLevel = 0,
	_bankValue = 0,
	_tableID = 0,
	_chairID = 0,
	_status = 0,		
	_userIndex = 0,
	_userRountIC = 0,
	_score = 0,
	_scoreBuf ,
	_scoreBufLen = 0,
	m_cbFaceChagneIndex = 0,
	m_cbVipLevel = 0,
	_longitude = 0,
	_latitude = 0,
	}
	setmetatable(self,UserInfo)
	return self
end

function UserInfo:getMaxim()
	return self._maxim
end

function UserInfo:getUserID()
	return self._userIndex
end

function UserInfo:getUserChair()
	return self._chairID
end

function UserInfo:getUserDBID()
	return self._userDBID
end

function UserInfo:getUserName()
	return self._name
end

function UserInfo:getUserTableID()
	return self._tableID
end

function UserInfo:getUserStatus()
	return self._status
end

function UserInfo:getFace()
	return self._faceID
end

function UserInfo:isPlayer()
	return self._status >= gamelibcommon.USER_SIT_TABLE and self._status < gamelibcommon.USER_WATCH_GAME
end


function UserInfo:isValidPlayer()
	return self:isPlayer()
end

function UserInfo:getGold()
	return self:getScoreField(gamelibcommon.enScore_Gold)
end

function UserInfo:getScore()
	return self:getScoreField(gamelibcommon.enScore_Score)
end

function UserInfo:getSex()
	return self._sex
end



function UserInfo:getScoreField(nField)
	return require("GameLib/common/ScoreParser"):instance():GetScoreField(self._scoreBuf,self._scoreBufLen, nField)
end



function UserInfo:getAge()
	return self._age
end


function UserInfo:getGameTitleScore()
	return self._fame
end

function UserInfo:getGameTitleLevel()
	return self._fameLevel
end

function UserInfo:getUserFaceChangeIndex()
	return self.m_cbFaceChagneIndex
end

function UserInfo:getVIPLevel()
	return self.m_cbVipLevel
end

function UserInfo:getBankAmount()
	return self._bankValue
end

function UserInfo:setBankAmount(amount)
	self._bankValue = amount
end

return UserInfo