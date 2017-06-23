
--[[struct CMD_GP_GAMEINFO
{
	int						nUserDBID;
	DWORD					dwGold;
	int						nScore;
	int						nWin;
	int						nLose;
	int						nDraw;
	int						nFlee;
	char					szLeaveWord[128];
	CMD_GP_GAMEINFO()
	{
		memset(this,0,sizeof(CMD_GP_GAMEINFO));
	}
};]]

CMD_GP_GAMEINFO = {}
CMD_GP_GAMEINFO.__index = CMD_GP_GAMEINFO

function CMD_GP_GAMEINFO:new(buffer)
local self = {
		nUserDBID = 0,
		dwGold = 0,
		nScore = 0,
		nWin = 0,
		nLose = 0,
		nDraw = 0,
		nFlee = 0,
		szLeaveWord = ""
	}

	setmetatable(self, CMD_GP_GAMEINFO)

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:initBuf(buffer)

	self.nUserDBID = ba:readInt()
	self.dwGold = ba:readUInt()
	self.nScore = ba:readInt()
	self.nWin = ba:readInt()
	self.nLose = ba:readInt()
	self.nDraw = ba:readInt()
	self.nFlee = ba:readInt()
	self.szLeaveWord = ba:readStringSubZero(128)
	--self.szLeaveWord = ba:stringSubZero(self.szLeaveWord)
    --local len = string.len(self.szLeaveWord)
	return self
end

function CMD_GP_GAMEINFO:getLen()
	return 156
end

CMD_GP_LogonSuccess_Ex2 = {}
setmetatable(CMD_GP_LogonSuccess_Ex2, CMD_GP_GAMEINFO)
CMD_GP_LogonSuccess_Ex2.__index = CMD_GP_LogonSuccess_Ex2

function CMD_GP_LogonSuccess_Ex2:new(buffer)
	local self = {}

	if buffer == nil then return self end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self = CMD_GP_GAMEINFO:new(buffer)  

	self.nVIPLevel = 0
	self.cbGameTitleLevel = 0
	self.nGameTitleScore = 0
	self.nFrag = 0
	self.lBankAmount = 0
	self.nWeekWinAmount = 0
	self.nMaxWinAmount = 0
	self.nGuessWin = 0
	self.nGiftVIPLevel = 0
	self.bIsLoginGift = 0		
	return self
end

function CMD_GP_LogonSuccess_Ex2:GetGuessType()
	return self.nGuessWin % 0x10
end

function CMD_GP_LogonSuccess_Ex2:GetGuessWinAmount()
	return self.nGuessWin / 0x10
end
