

-- struct tagGameStation
-- {
-- 	int dwParentID;						//鎸傛帴鍙风爜
-- 	int dwStationID;					//绔欑偣鍙风爜
-- 	char szStationName[GAME_STATION_LEN];//绔欑偣鍚嶇О

-- 	tagGameStation()
-- 	{
-- 		memset(this,0,sizeof(tagGameStation));
-- 	}
-- };

tagGameStation = {dwParentID , dwStationID , szStationName = {}}
tagGameStation.__index = tagGameStation

function tagGameStation:new(buffer, nLen)
	

	local self = {
		dwParentID = 0,
		dwStationID = 0,
		szStationName = "szStationName"
	}

	setmetatable(self, tagGameStation)

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self.dwParentID = ba:readInt()
	self.dwStationID = ba:readInt()
	self.szStationName = ba:readStringSubZero(32)

	return self
end

function tagGameStation:getLen()
	return 4 + 4 + 32
end

-- struct tagGameStationEx : tagGameStation
-- {
-- 	DWORD dwMinGold;
-- 	DWORD dwRuleID;
-- 	int nTableGold;	// 台费
-- 	int nBaseGold;	// 底分
-- 	tagGameStationEx()
-- 	{
-- 		memset(this,0,sizeof(tagGameStationEx));
-- 	}
-- };
tagGameStationEx = {dwMinGold , dwRuleID, nTableGold, nBaseGold}
setmetatable(tagGameStationEx, tagGameStation)
tagGameStationEx.__index = tagGameStationEx

function tagGameStationEx:new(buffer, nLen)
	local self = {
		dwMinGold = 0,
		dwRuleID = 0,
		nTableGold = 0,
		nBaseGold = 0
	}

	--setmetatable(self, tagGameStationEx)

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self = tagGameStation:new(buffer, nLen)
	if nLen > tagGameStation:getLen() then
		ba:setPos(self.GameStation:getLen() + 1)
		self.dwMinGold = ba:readUInt()
		self.dwRuleID = ba:readUInt()
		self.nTableGold = ba:readInt()
		self.nBaseGold = ba:readInt()
    else
        self.dwMinGold = 0
		self.dwRuleID = 0
		self.nTableGold = 0
		self.nBaseGold = 0
	end

	return self
end

function tagGameStationEx:getLen()
	return tagGameStation:getLen() + 16
end

-- struct tagGameServer
-- {
-- 	int dwServerIP;						//鎴块棿鍦板潃
-- 	int dwServerID;						//鎴块棿鍙风爜
-- 	int dwKindID;						//鍚嶇О鍙风爜
-- 	int dwStationID;					//绔欑偣鍙风爜
-- 	WORD wOnLineCount;					//鍦ㄧ嚎浜烘暟
-- 	WORD wMaxOnLineCount;				//鏈€澶у閲?
-- 	int uServerPort;					//鎴块棿绔彛
-- 	char szGameRoomName[GAME_ROOM_LEN];	//鎴块棿鍚嶇О
-- 	tagGameServer()
-- 	{
-- 		memset(this,0,sizeof(tagGameServer));
-- 	}
-- };
tagGameServer = {dwServerIP , dwServerID , dwKindID , dwStationID , wOnLineCount , wMaxOnLineCount , uServerPort , szGameRoomName = {}}
tagGameServer.__index = tagGameServer

function tagGameServer:new(buffer, nLen)
	
	local self = {
		dwServerIP = 0,
		dwServerID = 0,
		dwKindID = 0,
		dwStationID = 0,
		wOnLineCount = 0,
		wMaxOnLineCount = 0,
		uServerPort = 0,
		szGameRoomName = "szGameRoomName"
	}

	setmetatable(self, tagGameServer)

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self.dwServerIP = ba:readInt()
	self.dwServerID = ba:readInt()
	self.dwKindID = ba:readInt()
	self.dwStationID = ba:readInt()
	self.wOnLineCount = ba:readShort()
	self.wMaxOnLineCount = ba:readShort()
	self.uServerPort = ba:readInt()
	self.szGameRoomName = ba:readStringSubZero(32)

	return self
end

function tagGameServer:getLen()
	return 4 + 4 + 4 + 4 + 2 + 2 +4 + 32
end

-- struct tagGameServerEx:tagGameServer
-- {
-- 	DWORD dwRuleID;
-- 	DWORD dwMinGold;
-- 	DWORD dwMaxGold;	//  杩涙埧闂存渶澶ф渶灏忛噾甯侊紝0琛ㄧず涓嶉檺鍒?
-- 	BYTE  cbMinVipNeed;					// 进入所需VIP等级
-- 	BYTE  cbPrivateRoom;					// 是否私人房间，看不见
-- 	BYTE  cbMinCreateTableVIP;			// 创建桌子所需VIP

-- 	tagGameServerEx()
-- 	{
-- 		dwRuleID = 0xFFFFFFFF;
-- 		dwMinGold = 0;
-- 		dwMaxGold = 0;
-- 		cbMinVipNeed = 0;
-- 		cbPrivateRoom = 0;
-- 		cbMinCreateTableVIP = 0;
-- 	}
-- };
tagGameServerEx = {dwRuleID , dwMinGold, dwMaxGold, cbMinVipNeed, cbPrivateRoom, cbMinCreateTableVIP}
setmetatable(tagGameServerEx, tagGameServer)
tagGameServerEx.__index = tagGameServerEx

function tagGameServerEx:new(buffer, nLen)
	
	local self = {
		--GameServer = tagGameServer:new(),
		dwRuleID = 0,
		dwMinGold = 0,
		dwMaxGold = 0,
		cbMinVipNeed = 0,
		cbPrivateRoom = 0,
		cbMinCreateTableVIP = 0
	}

	--setmetatable(self, tagGameServerEx)

	if (buffer == nil) then
		return self
	end

	
	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)
	self = tagGameServer:new(buffer, nLen)
	ba:setPos(tagGameServer:getLen() + 1)
	self.dwRuleID = ba:readUInt()
	self.dwMinGold = ba:readUInt()
	self.dwMaxGold = ba:readUInt()
	self.cbMinVipNeed = ba:readByte()
	self.cbPrivateRoom = ba:readByte()
	self.cbMinCreateTableVIP = ba:readByte()

	return self
end

function tagGameServerEx:getLen()
	return tagGameServer:getLen() + 15
end

-- struct tagGameServerExtraInfo
-- {
-- 	int nServerID;	// 服务器ID
-- 	int nTableGold;	// 台费
-- 	int nBaseGold;	// 底分
-- 	tagGameServerExtraInfo()
-- 	{
-- 		memset(this,0,sizeof(tagGameServerExtraInfo));
-- 	}
-- };
tagGameServerExtraInfo = {nServerID , nTableGold , nBaseGold}
tagGameServerExtraInfo.__index = tagGameServerExtraInfo

function tagGameServerExtraInfo:new(buffer, nLen)
	
	local self = {
		nServerID = 0,
		nTableGold = 0,
		nBaseGold = 0
	}

	setmetatable(self, tagGameServerExtraInfo)

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self.nServerID = ba:readInt()
	self.nTableGold = ba:readInt()
	self.nBaseGold = ba:readInt()

	return self
end

function tagGameServerExtraInfo:getLen()
	return 4 + 4 + 4
end

-- struct tagClientInfo
-- {
-- 	int dwComputerID[3];	
-- 	int dwSystemVer[2];
-- 	char szComputerName[12];
-- 	tagClientInfo()
-- 	{
-- 		memset(this,0,sizeof(tagClientInfo));
-- 	}
-- };

tagClientInfo = {dwComputerID ={},dwSystemVer={},szComputerName}
tagClientInfo.__index = tagClientInfo
 

-- new 一个对象或者从buffer中解析一个对象
function tagClientInfo:new(buffer,nLen)
	local self = {
		dwComputerID ={3,2,1},
		dwSystemVer = {0,0},
		szComputerName = "computername"
	}
	setmetatable(self,tagClientInfo)
	--self.__index = self

	if(buffer == nil)	then-- 新建一个对象
		return self
	end
	-- 从buffer中解析
	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)
	for i=1,3 do
		self.dwComputerID[i] = ba:readInt()
	end
	for i=1,2 do
		self.dwSystemVer[i] = ba:readInt()
	end
	--for i=1,12 do
	self.szComputerName = ba:readStringSubZero(12)
	cclog("tagClientInfo:new " .. self.szComputerName)
	--end
	return self
end

--序列化
function tagClientInfo:Serialize()
	local ba = require("ByteArray").new()
	for i=1,3 do
		--dwComputerID[i] = ba:readInt()
		ba:writeUInt(self.dwComputerID[i])
	end
	for i=1,2 do
		--dwSystemVer[i] = ba:readInt()
		ba:writeUInt(self.dwSystemVer[i])
	end
	--for i=1,12 do
		--szComputerName[i] = ba:readUByte()
	self.szComputerName = string.sub(self.szComputerName,1,11)
	ba:writeString(self.szComputerName)
	--cclog("tagClientInfo:writeString " .. self.szComputerName)
	--end
	for i=string.len(self.szComputerName) + 1,12 do
		ba:writeByte(0)
	end
	ba:setPos(1)
	return ba
end

--获取长度
function tagClientInfo:getLen()
	return 32
end

--struct tagConnectInfo
--{
--	unsigned short wSize;		    		//淇℃伅闀垮害
--	int dwGameInstallVer;		//瀹夎鐗堟湰
--	int dwGameBuildVer;			//绋嬪簭鐗堟湰
--	int dwConnectDelay;			//杩炴帴寤舵椂
--	tagConnectInfo()
--	{
--		memset(this,0,sizeof(tagConnectInfo));
--	}
--};

tagConnectInfo = {wSize,dwGameInstallVer,dwGameBuildVer,dwConnectDelay}
tagConnectInfo.__index = tagConnectInfo

function tagConnectInfo:new(buffer, nLen)
	local self = {
		wSize = 0,
		dwGameInstallVer = 0,
		dwGameBuildVer = 0,
		dwConnectDelay = 0
	}
	setmetatable(self,tagConnectInfo)

	if(buffer == nil)	then-- 新建一个对象
		return self
	end
	-- 从buffer中解析
	local ba = require("ByteArray").new()

	ba:writeBuf(buffer)
	ba:setPos(1)

	self.wSize = ba:readUShort()
	self.dwGameInstallVer = ba:readInt()
	self.dwGameBuildVer = ba:readInt()
	self.dwConnectDelay = ba:readInt()

	return self
end

function tagConnectInfo:Serialize()
	local ba = require("ByteArray").new()

	ba:writeUShort(self.wSize)
	ba:writeUInt(self.dwGameInstallVer)
	ba:writeUInt(self.dwGameBuildVer)
	ba:writeUInt(self.dwConnectDelay)

	ba:setPos(1)

	return ba
end

function tagConnectInfo:getLen()
	return 14
end

--struct tagVersionInfo
--{
--	DWORD					dwInstallVer;			//瀹夎鐗堟湰
--	DWORD					dwBuildVer;				//缂栬瘧鐗堟湰
--	DWORD					dwSubBuildVer;			//瀛愮増鏈彿
--};
tagVersionInfo = {dwInstallVer,dwBuildVer,dwSubBuildVer}
tagVersionInfo.__index = tagVersionInfo

function tagVersionInfo:new(buffer, nLen)
	local self = {
		dwInstallVer = 0,
		dwBuildVer = 0,
	  	dwSubBuildVer = 0
	}

	setmetatable(self, tagVersionInfo)

	local ba = require("ByteArray").new()

	if (buffer == nil) then
		return self
	end

	ba:writeBuf(buffer)
	ba:setPos(1)

	self.dwInstallVer = ba:readUInt()
	self.dwBuildVer = ba:readUInt()
	self.dwSubBuildVer = ba:readUInt()

	return self
end

function tagVersionInfo:Serialize()
	local ba = require("ByteArray").new()

	ba:writeUInt(self.dwInstallVer)
	ba:writeUInt(self.dwBuildVer)
	ba:writeUInt(self.dwSubBuildVer)

	ba:setPos(1)

	return ba
end

function tagVersionInfo:getLen()
	return 6
end