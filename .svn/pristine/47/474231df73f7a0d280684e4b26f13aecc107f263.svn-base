
local TableManager = {_tableCount , _chairCount_tables = {}}
TableManager.__index = TableManager

function TableManager:new(tableCount,chairCount)
	local self = {
		_tableCount = tableCount,
		_chairCount = chairCount,
		_tables = {}
	}
	for i=1,self._tableCount do
		self._tables[i] = require("GameLib/gamelib/Table"):new(chairCount,i - 1)
	end
	setmetatable(self,TableManager)
	return self
end

function TableManager:getTableCount()
	return self._tableCount
end

function TableManager:getChairCount()
	return self._chairCount
end

function TableManager:getTable(tableID)
	if tableID < 0 or tableID >= self._tableCount then return nil end
	return self._tables[tableID + 1]
end

function TableManager:getTableList()
	return self._tables
end

return TableManager