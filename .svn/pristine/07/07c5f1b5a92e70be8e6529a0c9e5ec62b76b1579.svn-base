
local Table = {_chairCount , _tableID,_isPlaying,_isLock,_chairs={}}
Table.__index = Table

Table.TABLE_PLAYING = 2
Table.TABLE_LOCKED  = 1

function Table:new(chairCount,tableID)
	local self = {
		_chairCount = chairCount, 
		_tableID = tableID,
		_isPlaying = false,
		_isLock=false,
		_chairs={}
	}
	for i=1,chairCount do
		self._chairs[i] = require("GameLib/gamelib/Chair"):new()
	end

	setmetatable(self,Table)
	return self
end

-- 这里chairID为0开始
function Table:getChair(chairID)
	if chairID < 0 or chairID > self._chairCount then
		return nil
	end
	return self._chairs[chairID + 1]
end

function Table:getEmptyChairCount()
	local count = 0
	--for(int i = 0;i < _chairCount;i++)
	for i=1,self._chairCount do
		local chair = self._chairs[i]
		if chair:isEmpty() then
			count = count + 1
		end
	end
	return count
end

function Table:getPlayerCount()
	return self._chairCount - self:getEmptyChairCount()
end

function Table:setTableBuf(buf)
	self.m_TableBuf = buf
end

function Table:getTableBuf()
	return self.m_TableBuf
end

function Table:dump()	
	for i=1,self._chairCount do
		local chair = self._chairs[i]
		cclog("chair %d %s",i,chair:isEmpty() and "empty" or "taken")
	end
end

return Table