local PlazaCmds = {}
PlazaCmds.PORT_PLAZA_LOGON = 8000			--

--------------------------------------------------------------------------

PlazaCmds.MAIN_GP_LOGON = 100				--登录主命令

PlazaCmds.SUB_GP_LOGON_RIGISTER = 1				--
PlazaCmds.SUB_GP_LOGON_BY_NAME = 2				--
PlazaCmds.SUB_GP_LOGON_BY_USERID = 3				--
PlazaCmds.SUB_GP_LOGON_BY_VNET = 4				--
PlazaCmds.SUB_GP_LOGON_BY_VNET_TOKEN = 5				--	--add by mxs 2006-3
PlazaCmds.SUB_GP_LOGON_BY_VNET_TOKEN_V1 = 6				----add by mxs nedu
PlazaCmds.SUB_GP_LOGON_BY_VNET_CMD = 7				--	--add by mxs e8
PlazaCmds.SUB_GP_LOGON_BY_IMEI = 8
PlazaCmds.SUB_GP_LOGON_BY_EMAIL = 9
PlazaCmds.SUB_GP_GET_GAMEINFO = 10
PlazaCmds.SUB_GP_GET_GAMEINFO_EX = 11 			--获取用户信息


PlazaCmds.SUB_GP_LOGON_SUCCESS = 50				--
PlazaCmds.SUB_GP_LOGON_SUCCESS_EX = 51				--
PlazaCmds.SUB_GP_LOGON_RIGISTER_EX = 52				--
PlazaCmds.SUB_GP_GET_OPEN_PLATFORM_TOKEN = 53				--					--add by mxs 2006-8-8
PlazaCmds.SUB_GP_OPEN_PLATFORM_GETTOKEN = 54				--							--add by mxs 2006-8-8
PlazaCmds.SUB_GP_LOGON_SUCCESS_VNET = 55				--	--add by mxs vnetpass	2007-2-27
PlazaCmds.SUB_GP_LOGON_RIGISTER_V1 = 56				--								--add by mxs fcm
PlazaCmds.SUB_GP_PSW_CARD_COORD = 57				--				--add by mxs mmk
PlazaCmds.SUB_GP_PSW_CARD_USER_NUM = 58				--			--add by mxs mmk
PlazaCmds.SUB_GP_GET_OPEN_PLATFORM_TOKEN_VNET = 64				--		--add by mxs nedu
PlazaCmds.SUB_GP_OPEN_PLATFORM_GETTOKEN_VNET = 65				--					--add by mxs nedu
PlazaCmds.SUB_GP_LOGON_REG_RESULT = 66				--				--add by mxs nplaza
PlazaCmds.SUB_GP_LOGON_AVATAR_URL = 67				--								--add by mxs atr
PlazaCmds.SUB_GP_LOGON_FACEDATA = 68				-- 
PlazaCmds.SUB_GP_VIP_INFO = 69				-- 用户vip等级
-- int nVIPLevel;int nVIPScore;
PlazaCmds.SUB_GP_SCORE_EX = 70				-- 分数补充
-- int nWeekWinAmount;int nMaxWinAmount
-- PlazaCmds.SUB_GP_LOGON_AWARD_BASE = 71				-- 每日登陆奖励基数
PlazaCmds.SUB_GP_GAMEINFO	=				72			--下发用户信息


--一些锟斤拷锟斤拷锟斤拷锟?
PlazaCmds.SUB_GP_TRANSFER = 60				--转锟斤拷									--add by mxs 2006-3
PlazaCmds.SUB_GP_SAFEBOX = 61				--锟斤拷锟秸癸拷								--add by mxs 2006-3
PlazaCmds.SUB_GP_SEND_LOGON_TIME = 62				--锟斤拷锟酵碉拷陆时锟斤拷							--add by mxs tel
PlazaCmds.SUB_GP_VNET_RT_URL = 63				--锟斤拷取锟斤拷锟斤拷Vnet锟斤拷陆锟斤拷URL					--add by mxs nedu
PlazaCmds.SUB_GP_GUEST = 64
PlazaCmds.SUB_GP_LOGON_BY_TOKEN = 65



--------------------------------------------------------------------------

PlazaCmds.MAIN_GP_SERVER_LIST = 101				--服务器列表

PlazaCmds.SUB_GP_SERVER_LIST_Web = 12				--
PlazaCmds.SUB_GP_SERVER_LIST_TYPE = 1				--
PlazaCmds.SUB_GP_SERVER_LIST_KIND = 2				--游戏名字列表
PlazaCmds.SUB_GP_SERVER_LIST_STATION = 3				--
PlazaCmds.SUB_GP_SERVER_LIST_ROOM = 4				--游戏房间信息
PlazaCmds.SUB_GP_SERVER_LIST_ROOM_EX = 5				--游戏房间扩展
PlazaCmds.SUB_GP_SERVER_LIST_ITEM = 6				--
PlazaCmds.SUB_GP_SERVER_LIST_MODE = 9				--获取房间
PlazaCmds.SUB_GP_SERVER_LIST_SUBSTATION_ROOM = 10				--
PlazaCmds.SUB_GP_SERVER_LIST_EDU_ITEM = 21				--		--add by mxs edu
PlazaCmds.SUB_GP_SERVER_LIST_SUBSTATION_KIND = 22				--			--add by mxs nedu
PlazaCmds.SUB_GP_SERVER_LIST_TYPE_V1 = 23				--游戏类型					--add by mxs sc

PlazaCmds.SUB_GP_SERVER_WEB_COUNT = 13				--WEB锟节碉拷锟斤拷锟斤拷
PlazaCmds.SUB_GP_SERVER_KIND_COUNT = 7				--锟斤拷锟斤拷锟斤拷锟斤拷
PlazaCmds.SUB_GP_SERVER_ROOM_COUNT = 8				--锟斤拷锟斤拷锟斤拷锟斤拷
PlazaCmds.SUB_GP_SERVER_SUBSTATION_COUNT = 11				--锟斤拷站锟斤拷锟斤拷

PlazaCmds.SUB_GP_GET_SERVER_LIST = 9				--锟斤拷取锟斤拷锟斤拷
PlazaCmds.SUB_GR_GET_COLLECTION_SERVER = 51				--锟斤拷取锟斤拷锟矫凤拷锟斤拷锟斤拷
PlazaCmds.SUB_GR_GET_COLLECTION_SERVER_EX = 53				--锟斤拷取锟斤拷锟矫凤拷锟斤拷锟斤拷
PlazaCmds.SUB_GP_GET_SUBSTATION_SERVER_LIST = 54				--锟斤拷站锟斤拷锟斤拷锟叫憋拷
PlazaCmds.SUB_GP_GET_EDU_SERVER_LIST = 59				--锟斤拷取锟斤拷锟斤拷锟斤拷平台锟斤拷戏锟叫憋拷	--add by mxs edu

PlazaCmds.SUB_GP_GET_ONLINE_COUNT = 52				--锟斤拷取锟斤拷锟斤拷锟斤拷锟斤拷
PlazaCmds.SUB_GP_GET_SUBSTATION_ONLINE_COUNT = 55				--锟斤拷取锟斤拷站锟斤拷锟斤拷


--锟借单锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷戏锟斤拷锟斤拷
PlazaCmds.SUB_GP_SERVER_LIST_SPECIAL_KIND = 56				--锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷
PlazaCmds.SUB_GP_SERVER_LIST_WEB_KIND = 57				--web锟斤拷锟斤拷
PlazaCmds.SUB_GP_SERVER_LIST_OPENPLATFORM_KIND = 58				--锟斤拷锟斤拷平锟斤拷戏	add by mxs 2006-8-8
--------------------------------------------------------------------------

PlazaCmds.MAIN_GP_CONFIG = 102				--锟斤拷锟斤拷锟斤拷息

PlazaCmds.SUB_GP_BBRING_IP = 1				--寻锟斤拷锟斤拷址
PlazaCmds.SUB_GP_USER_INFO = 2				--锟矫伙拷锟斤拷锟斤拷
PlazaCmds.SUB_GP_MASTER_IP = 3				--锟斤拷艿锟街?
PlazaCmds.SUB_GP_CHANGE_INFO = 50				--锟斤拷锟斤拷锟斤拷锟?
PlazaCmds.SUB_GP_AD_INFO = 51				--锟斤拷锟斤拷锟较?
PlazaCmds.SUB_GP_BIND_EMAIL = 52
PlazaCmds.SUB_GP_GET_AWARD = 53				-- 鑾峰彇濂栧姳
PlazaCmds.SUB_GP_GET_FACE = 54				-- 鑾峰彇澶村儚
PlazaCmds.SUB_GP_APPLE_CHARGE = 55				-- 苹果充值
PlazaCmds.SUB_GP_CHANGE_USERWORD	=		56				-- 修改签名


PlazaCmds.MAIN_CM_SERVICE  =200
PlazaCmds.SUB_CM_MESSAGE = 1
PlazaCmds.SUB_CM_MESSAGE_EX = 2
PlazaCmds.SUB_CM_MESSAGE_EX_2 = 3
--------------------------------------------------------------------------

--锟斤拷效锟斤拷锟斤拷 ID
PlazaCmds.ERROR_KIND_ID = 0xFFFF

require("GameLib/common/PlazaInfo")

--struct CMD_GP_Logon_ByIMEI
--{
--	WORD 					wGameID;
--	char					szIMEI[32];				--锟矫伙拷锟斤拷锟斤拷
--	tagClientInfo			ClientInfo;						--锟酵伙拷锟斤拷锟斤拷息
--	tagVersionInfo			VersionInfo;					--锟芥本锟斤拷息
--	char					szDeviceName[32];
--	CMD_GP_Logon_ByIMEI()
--	{
--		memset(this,0,sizeof(CMD_GP_Logon_ByIMEI));
--	}
--};
CMD_GP_Logon_ByIMEI = {wGameID,szIMEI = {},ClientInfo = {},VersionInfo = {},szDeviceName = {}}
CMD_GP_Logon_ByIMEI.__index = CMD_GP_Logon_ByIMEI

function CMD_GP_Logon_ByIMEI:new(buffer, nLen)
	local self = {
		wGameID = 0,
		szIMEI = "szIMEI",
		ClientInfo = tagClientInfo.new(),
		VersionInfo = tagVersionInfo.new(),
		szDeviceName = "szDeviceName"
	}
	setmetatable(self,CMD_GP_Logon_ByIMEI)

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()

	ba:writeBuf(buffer)
	ba:setPos(1)

	self.wGameID = ba:readShort()
	self.szIMEI = ba:readString(32)
	self.ClientInfo = tagClientInfo:new(ba:getBuf(), tagClientInfo:getLen())
	self.VersionInfo = tagVersionInfo:new(ba:getBuf(), tagVersionInfo:getLen())
	self.szDeviceName = ba:readString(32)

	return self
end

function CMD_GP_Logon_ByIMEI:Serialize()
	local ba = require("ByteArray").new()

	ba:writeShort(self.wGameID)
	self.szIMEI = string.sub(self.szIMEI,1,31)
	ba:writeString(self.szIMEI)
	for i=string.len(self.szIMEI) + 1,32 do
		ba:writeByte(0)
	end
	
	ba:writeByteArray(self.ClientInfo:Serialize())

	ba:writeByteArray(self.VersionInfo:Serialize())
	
	ba:writeString(self.szDeviceName)
	for i=string.len(self.szDeviceName) + 1,32 do
		ba:writeByte(0)
	end

	ba:setPos(1)
	
	return ba
end

function CMD_GP_Logon_ByIMEI:getLen()
	return 2 + 32 + self.ClientInfo:getLen() + self.VersionInfo:getLen() + 32
end

-- struct tagGameType
-- {
-- 	DWORD					dwTypeID;						//锟斤拷戏锟斤拷锟斤拷 ID 锟斤拷锟斤拷
-- 	char					szTypeName[GAME_TYPE_LEN];		//锟斤拷戏锟斤拷锟斤拷锟斤拷锟斤拷
-- };
tagGameType = {dwTypeID , szTypeName = {}}
tagGameType.__index = tagGameType

function tagGameType:new(buffer, nLen)
	local self = {
		dwTypeID = 0,
		szTypeName = "szTypeName"
	}

	setmetatable(self, tagGameType)

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self.dwTypeID = ba:readUInt()
	self.szTypeName = ba:readString(16)

	return self
end

function tagGameType:getLen()
	return 4 + 16
end

-- struct tagGameTypeV1		//add by mxs sc
-- {
-- 	DWORD					dwTypeID;						//锟斤拷戏锟斤拷锟斤拷 ID 锟斤拷锟斤拷
-- 	char					szTypeName[GAME_TYPE_LEN];		//锟斤拷戏锟斤拷锟斤拷锟斤拷锟斤拷
-- 	BYTE					bShowOnlineCount;				//锟角凤拷锟斤拷示锟斤拷锟斤拷锟斤拷锟斤拷
-- };
tagGameTypeV1 = {dwTypeID , szTypeName = {}, bShowOnlineCount}
tagGameTypeV1.__index = tagGameTypeV1

function tagGameTypeV1:new(buffer, nLen)
	local self = {
		dwTypeID = 0,
		szTypeName = "szTypeName",
		bShowOnlineCount = 0
	}

	setmetatable(self, tagGameTypeV1)

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self.dwTypeID = ba:readInt()
	self.szTypeName = ba:readStringSubZero(16)
	self.bShowOnlineCount = ba:readByte()

	return self
end

function tagGameTypeV1:getLen()
	return 4 + 16 + 1
end

-- struct tagGameKind
-- {
-- 	DWORD					dwMaxVersion;					//锟斤拷锟铰版本
-- 	DWORD					dwOnLineCount;					//锟斤拷锟斤拷锟斤拷锟斤拷
-- 	DWORD					dwTypeID;						//锟斤拷锟酵猴拷锟斤拷
-- 	DWORD					dwKindID;						//锟斤拷坪锟斤拷锟?
-- 	char					szKindName[GAME_KIND_LEN];		//锟斤拷戏锟斤拷锟?
-- 	char					szProcess[GAME_MODULE_LEN];		//锟斤拷戏锟斤拷锟斤拷锟?
-- };
tagGameKind = {dwMaxVersion , dwOnLineCount , dwTypeID , dwKindID , szKindName = {}, szProcess = {}}
tagGameKind.__index = tagGameKind
function tagGameKind:new(buffer, nLen)
	local self = {
		dwMaxVersion = 0,
		dwOnLineCount = 0,
		dwTypeID = 0,
		dwKindID = 0,
		szKindName = "szTypeName",
		szProcess = "szProcess"
	}

	setmetatable(self, tagGameKind)

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self.dwMaxVersion = ba:readInt()
	self.dwOnLineCount = ba:readInt()
	self.dwTypeID = ba:readInt()
	self.dwKindID = ba:readInt()
	self.szKindName = ba:readStringSubZero(16)
	self.szProcess = ba:readStringSubZero(16)

	return self
end

function tagGameKind:getLen()
	return 4 + 4 + 4 + 4 + 16 + 16
end

-- struct tagGameServerExtend
-- {
-- 	tagGameServer			Info;							//锟斤拷锟斤拷息
-- 	DWORD					dwMaxVersion;					//锟斤拷锟铰版本锟斤拷
-- 	char					szGameProcess[GAME_MODULE_LEN];	//锟斤拷戏锟斤拷锟斤拷锟?
-- };
tagGameServerExtend = {Info = {}, dwMaxVersion , szGameProcess = {}}
tagGameServerExtend.__index = tagGameServerExtend
function tagGameServerExtend:new(buffer , nLen)
	local self = {
		Info = tagGameServer:new(),
		dwMaxVersion = 0,
		szGameProcess = "szGameProcess"
	}

	setmetatable(self, tagGameServerExtend)

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self.Info = tagGameServer:new(buffer, nLen)
	ba:setPos(self.Info:getLen() + 1)
	self.dwMaxVersion = ba:readUInt()
	self.szGameProcess = ba:readStringSubZero(16)

	return self
end

function tagGameServerExtend:getLen()
	return self.Info:getLen() + 4 + 16
end

-- struct CMD_GP_GetServer
-- {
-- 	DWORD					dwTypeID;						//锟斤拷锟酵猴拷锟斤拷
-- 	DWORD					dwKindID;						//锟斤拷戏锟斤拷锟斤拷
-- 	tagVersionInfo			VersionInfo;					//锟芥本锟斤拷息
-- };
CMD_GP_GetServer = {}
CMD_GP_GetServer.__index = CMD_GP_GetServer
function CMD_GP_GetServer:new()
	local self = {
		dwTypeID = 0,
		dwKindID = 0,
		VersionInfo = tagVersionInfo:new()
	}

	setmetatable(self, CMD_GP_GetServer)
	return self
end

function CMD_GP_GetServer:Serialize()
	local ba = require("ByteArray").new()
	--cclog("CMD_GP_GetServer:Serialize " .. self.dwTypeID)
	ba:writeUInt(self.dwTypeID)
	ba:writeUInt(self.dwKindID)
	ba:writeByteArray(self.VersionInfo:Serialize())
	return ba
end

function CMD_GP_GetServer:getLen()
	return 4 + 4 + self.VersionInfo:getLen()
end

--[[struct CMD_GP_Logon_Rigister
-- {
-- 	char					szName[NAME_LEN];				//锟矫伙拷锟斤拷锟斤拷
-- 	char					szPass[PASS_LEN];				//锟矫伙拷锟斤拷锟斤拷
-- 	char					szEmail[EMAIL_LEN];				//锟绞硷拷锟斤拷址
-- 	char 					szProvince[PROVINCE_LEN];		//锟矫伙拷省锟斤拷
-- 	char 					szCity[CITY_LEN];				//锟矫伙拷锟斤拷锟斤拷
-- 	char 					szArea[AREA_LEN];				//锟矫伙拷锟斤拷锟斤拷
-- 	BYTE					cbSex;							//锟矫伙拷锟皆憋拷
-- 	BYTE					cbUserAge;						//锟斤拷锟斤拷锟斤拷锟?
-- 	WORD					wFaceID;						//头锟斤拷锟斤拷锟?
-- 	tagClientInfo			ClientInfo;						//锟酵伙拷锟斤拷锟斤拷息
-- 	tagVersionInfo			VersionInfo;					//锟芥本锟斤拷息
-- };
CMD_GP_Logon_Rigister = {szName = {}, szPass = {}, szEmail = {}, szProvince = {}, szCity = {}, szArea = {}, cbSex, cbUserAge, wFaceID, ClientInfo = {}, VersionInfo = {}}
CMD_GP_Logon_Rigister.__index = CMD_GP_Logon_Rigister
function CMD_GP_Logon_Rigister:new(buffer, nLen)
	local self = {
		szName = "szName",
		szPass = "szPass",
		szEmail = "szEmail",
		szProvince = "szProvince",
		szCity = "szCity",
		szArea = "szArea",
		cbSex = 0,
		cbUserAge = 0,
		wFaceID = 0,
		ClientInfo = tagClientInfo:new(),
		VersionInfo = tagVersionInfo:new()
	}

	setmetatable(self, CMD_GP_Logon_Rigister)

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self.szName = ba:readString(32)
	self.szPass = ba:readString(16)
	self.szEmail = ba:readString(32)
	self.szProvince = ba:readString(16)
	self.szCity = ba:readString(16)
	self.szArea = ba:readString(16)
	self.cbSex = ba:readByte()
	self.cbUserAge = ba:readByte()
	self.wFaceID = ba:readShort()
	local content = ba:getBytes(ba:getPos(), self.ClientInfo:getLen())
	local len = self.ClientInfo:getLen()
	self.ClientInfo = tagClientInfo:new(content, len)
	ba:setPos(ba:getPos() + self.ClientInfo:getLen())

	local content2 = ba:getBytes(ba:getPos(), self.VersionInfo:getLen())
	local len2 = self.VersionInfo:getLen()
	self.VersionInfo = tagVersionInfo:new(content2, len2)

	return self
end

function CMD_GP_Logon_Rigister:getLen()
	return 32 + 16 + 32 + 16 + 16 + 16 + 1 + 1 + 2 + self.ClientInfo:getLen() + self.VersionInfo:getLen()
end

-- struct CMD_GP_Logon_Rigister_V1
-- {
-- 	char					szName[NAME_LEN];				//鐢ㄦ埛鍚嶅瓧
-- 	char					szPass[PASS_LEN];				//鐢ㄦ埛瀵嗙爜
-- 	char					szEmail[EMAIL_LEN];				//閭欢鍦板潃
-- 	char 					szProvince[PROVINCE_LEN];		//鐢ㄦ埛鐪佷唤
-- 	char 					szCity[CITY_LEN];				//鐢ㄦ埛鍩庡競
-- 	char 					szArea[AREA_LEN];				//鐢ㄦ埛鍦板尯
-- 	char					szRealName[16];		//鐢ㄦ埛鐪熷悕
-- 	char					szRealID[32];			//鐢ㄦ埛韬唤璇?
-- 	BYTE					cbSex;							//鐢ㄦ埛鎬у埆
-- 	BYTE					cbUserAge;						//鐜╁骞撮緞
-- 	WORD					wFaceID;						//澶村儚鍙风爜
-- 	tagClientInfo			ClientInfo;						//瀹㈡埛绔俊鎭?
-- 	tagVersionInfo			VersionInfo;					//鐗堟湰淇℃伅
-- 	DWORD					dwSubStationId;					//鍒嗙珯ID
-- };
CMD_GP_Logon_Rigister_V1 = {szName = {}, szPass = {}, szEmail = {}, szProvince = {}, szCity = {}, szArea = {}, szRealName = {}, szRealID = {}, cbSex, cbUserAge, wFaceID, ClientInfo = {}, VersionInfo = {}, dwSubStationId}
CMD_GP_Logon_Rigister_V1.__index = CMD_GP_Logon_Rigister_V1
function CMD_GP_Logon_Rigister_V1:new(buffer, nLen)
	local self = {
		szName = "szName",
		szPass = "szPass",
		szEmail = "szEmail",
		szProvince = "szProvince",
		szCity = "szCity",
		szArea = "szArea",
		szRealName = "szRealName",
		szRealID = "szRealID",
		cbSex = 0,
		cbUserAge = 0,
		wFaceID = 0,
		ClientInfo = tagClientInfo:new(),
		VersionInfo = tagVersionInfo:new(),
		dwSubStationId = 0
	}

	setmetatable(self, CMD_GP_Logon_Rigister_V1)

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self.szName = ba:readString(32)
	self.szPass = ba:readString(16)
	self.szEmail = ba:readString(32)
	self.szProvince = ba:readString(16)
	self.szCity = ba:readString(16)
	self.szArea = ba:readString(16)
	self.szRealName = ba:readString(16)
	self.szRealID = ba:readString(32)
	self.cbSex = ba:readByte()
	self.cbUserAge = ba:readByte()
	self.wFaceID = ba:readShort()
	local content = ba:getBytes(ba:getPos(), self.ClientInfo:getLen())
	local len = self.ClientInfo:getLen()
	self.ClientInfo = tagClientInfo:new(content, len)
	ba:setPos(ba:getPos() + self.ClientInfo:getLen())

	local content2 = ba:getBytes(ba:getPos(), self.VersionInfo:getLen())
	local len2 = self.VersionInfo:getLen()
	self.VersionInfo = tagVersionInfo:new(content2, len2)
	ba:setPos(ba:getPos() + self.VersionInfo:getLen())

	self.dwSubStationId = ba:readUInt()

	return self
end

function CMD_GP_Logon_Rigister_V1:getLen()
	return 32 + 16 + 32 + 16 + 16 + 16 + 16 + 32 + 1 + 1 + 2 + self.ClientInfo:getLen() + self.VersionInfo:getLen() + 4
end

-- struct CMD_GP_Logon_Rigister_Result							//add by mxs nplaza
-- {
-- 	bool					bSuccess;						//锟角凤拷注锟斤拷晒锟?
-- 	char					szSuggesName[NAME_LEN];			//锟斤拷锟斤拷锟斤拷没锟斤拷锟?
-- 	char					szMsg[REG_RESULT_LEN];			//锟斤拷锟截碉拷锟斤拷息
-- };
CMD_GP_Logon_Rigister_Result = {bSuccess , szSuggesName = {}, szMsg = {}}
CMD_GP_Logon_Rigister_Result.__index = CMD_GP_Logon_Rigister_Result
function CMD_GP_Logon_Rigister_Result:new(buffer , nLen)
	local self = {
		bSuccess = 0,
		szSuggesName = "szSuggesName",
		szMsg = "szMsg";
	}

	setmetatable(self, CMD_GP_Logon_Rigister_Result)

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self.bSuccess = ba:readBool()
	self.szSuggesName = ba:readString(32)
	self.szMsg = ba:readString(256)

	return self
end

function CMD_GP_Logon_Rigister_Result:getLen()
	return 1 + 32 + 256
end

-- struct CMD_GP_Logon_ByName
-- {
-- 	char					szName[NAME_LEN];				//锟矫伙拷锟斤拷锟斤拷
-- 	char					szPass[PASS_LEN];				//锟矫伙拷锟斤拷锟斤拷
-- 	tagClientInfo			ClientInfo;						//锟酵伙拷锟斤拷锟斤拷息
-- 	tagVersionInfo			VersionInfo;					//锟芥本锟斤拷息
-- };
CMD_GP_Logon_ByName = {szName = {}, szPass = {}, ClientInfo = {}, VersionInfo = {}}
CMD_GP_Logon_ByName.__index = CMD_GP_Logon_ByName
function CMD_GP_Logon_ByName:new()
	local self = {
		szName = "szName",
		szPass = "szPass",
		ClientInfo = tagClientInfo:new(),
		VersionInfo = tagVersionInfo:new()
	}

	setmetatable(self, CMD_GP_Logon_ByName)

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self.szName = ba:readString(32)
	self.szPass = ba:readString(16)

	local content = ba:getBytes(ba:getPos(), self.ClientInfo:getLen())
	local len = self.ClientInfo:getLen()
	self.ClientInfo = tagClientInfo:new(content, len)
	ba:setPos(ba:getPos() + self.ClientInfo:getLen())

	local content2 = ba:getBytes(ba:getPos(), self.VersionInfo:getLen())
	local len2 = self.VersionInfo:getLen()
	self.VersionInfo = tagVersionInfo:new(content2, len2)
	ba:setPos(ba:getPos() + self.VersionInfo:getLen())

	return self
end

function CMD_GP_Logon_ByName:getLen()
	return 32 + 16 + self.ClientInfo:getLen() + self.VersionInfo:getLen()
end

-- struct CMD_GP_Logon_ByUserID
-- {
-- 	DWORD					dwUserID;						//锟矫伙拷 ID
-- 	char					szPass[PASS_LEN];				//锟矫伙拷锟斤拷锟斤拷
-- 	tagClientInfo			ClientInfo;						//锟酵伙拷锟斤拷锟斤拷息
-- 	tagVersionInfo			VersionInfo;					//锟芥本锟斤拷息
-- };
CMD_GP_Logon_ByUserID = {dwUserID, szPass = {}, ClientInfo = {}, VersionInfo = {}}
CMD_GP_Logon_ByUserID.__index = CMD_GP_Logon_ByUserID
function CMD_GP_Logon_ByUserID:new()
	local self = {
		dwUserID = 0,
		szPass = "szPass",
		ClientInfo = tagClientInfo:new(),
		VersionInfo = tagVersionInfo:new()
	}

	setmetatable(self, CMD_GP_Logon_ByUserID)

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self.dwUserID = ba:readUInt()
	self.szPass = ba:readString(16)

	local content = ba:getBytes(ba:getPos(), self.ClientInfo:getLen())
	local len = self.ClientInfo:getLen()
	self.ClientInfo = tagClientInfo:new(content, len)
	ba:setPos(ba:getPos() + self.ClientInfo:getLen())

	local content2 = ba:getBytes(ba:getPos(), self.VersionInfo:getLen())
	local len2 = self.VersionInfo:getLen()
	self.VersionInfo = tagVersionInfo:new(content2, len2)
	ba:setPos(ba:getPos() + self.VersionInfo:getLen())

	return self
end

function CMD_GP_Logon_ByUserID:getLen()
	return 2 + 16 + self.ClientInfo:getLen() + self.VersionInfo:getLen()
end

-- struct CMD_GP_Logon_ByEMAIL
-- {
-- 	WORD 					wGameID;
-- 	char					szIMEI[32];
-- 	char					szEMAIL[NAME_LEN];				//锟矫伙拷锟斤拷锟斤拷
-- 	char					szPass[PASS_LEN];				//锟矫伙拷锟斤拷锟斤拷
-- 	tagClientInfo			ClientInfo;						//锟酵伙拷锟斤拷锟斤拷息
-- 	tagVersionInfo			VersionInfo;					//锟芥本锟斤拷息
-- }
CMD_GP_Logon_ByEMAIL = {wGameID, szIMEI, szEMAIL, szPass, ClientInfo, VersionInfo}
CMD_GP_Logon_ByEMAIL.__index = CMD_GP_Logon_ByEMAIL
function CMD_GP_Logon_ByEMAIL:new()
	local self = {
		wGameID = 0,
		szIMEI = "szIMEI",
		szEMAIL = "szEMAIL",
		szPass = "szPass",
		ClientInfo = tagClientInfo:new(),
		VersionInfo = tagVersionInfo:new()
	}

	setmetatable(self, CMD_GP_Logon_ByEMAIL)

	return self
end

function CMD_GP_Logon_ByEMAIL:Serialize()
	local ba = require("ByteArray").new()

	ba:writeShort(self.wGameID)
	self.szIMEI = string.sub(self.szIMEI,1,31)
	self.szPass = string.sub(self.szPass,1,15)
	self.szEMAIL = string.sub(self.szEMAIL,1,31)
	ba:writeString(self.szIMEI)
	for i=string.len(self.szIMEI) + 1,32 do
		ba:writeByte(0)
	end
	ba:writeString(self.szEMAIL)
	for i=string.len(self.szEMAIL) + 1,32 do
		ba:writeByte(0)
	end
	ba:writeString(self.szPass)
	for i=string.len(self.szPass) + 1,16 do
		ba:writeByte(0)
	end
	
	ba:writeByteArray(self.ClientInfo:Serialize())

	ba:writeByteArray(self.VersionInfo:Serialize())
	
	ba:writeString(self.szDeviceName)
	for i=string.len(self.szDeviceName) + 1,32 do
		ba:writeByte(0)
	end

	ba:setPos(1)
	
	return ba
end

-- struct CMD_GP_Logon_Success
-- {
-- 	int					lUserDBID;							//锟斤拷菘锟?IDv
-- 	WORD					wFaceID;						//头锟斤拷锟斤拷锟?
-- 	BYTE					cbSex;							//锟矫伙拷锟皆憋拷
-- 	char					szName[NAME_LEN];				//锟矫伙拷锟斤拷锟斤拷
-- 	char					szEmail[EMAIL_LEN];				//锟绞硷拷锟斤拷址
-- 	char					szProvince[PROVINCE_LEN];		//锟矫伙拷省锟斤拷
-- 	char					szCity[CITY_LEN];				//锟矫伙拷锟斤拷锟斤拷
-- 	char					szArea[AREA_LEN];				//锟矫伙拷锟斤拷锟斤拷
-- 	DWORD					dwConnectIP;					//锟斤拷锟接碉拷址
-- };
CMD_GP_Logon_Success = {lUserDBID, wFaceID , cbSex , szName, szEmail, szProvince, szCity, szArea,dwConnectIP}
CMD_GP_Logon_Success.__index = CMD_GP_Logon_Success
function CMD_GP_Logon_Success:new(buffer, nLen)
	local self = {
		lUserDBID = 0,
		wFaceID = 0,
		cbSex = 0,
		szName = "szName",
		szEmail = "szEmail",
		szProvince = "szProvince",
		szCity = "szCity",
		szArea = "szArea",
		dwConnectIP = 0
	}

	setmetatable(self, CMD_GP_Logon_Success)

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self.lUserDBID = ba:readInt()
	self.wFaceID = ba:readShort()
	self.cbSex = ba:readByte()
	self.szName = ba:readString(32)
	self.szEmail = ba:readString(32)
	self.szProvince = ba:readString(16)
	self.szCity = ba:readString(16)
	self.szArea = ba:readString(16)
	self.dwConnectIP = ba:readUInt()

	return self
end

function CMD_GP_Logon_Success:getLen()
	return 4 + 2 + 1 + 32 + 32 + 16 + 16 + 16 + 4
end]]

--[[struct CMD_GP_GetGameInfo
{
	int nUserDBID;
	int nPartnerID;
	int nVersionCode;
	tagClientInfo			ClientInfo;						//????????
	tagVersionInfo			VersionInfo;					//?汾???
	CMD_GP_GetGameInfo()
	{
		memset(this,0,sizeof(CMD_GP_GetGameInfo));
	}
};
]]

CMD_GP_GetGameInfo = {}
CMD_GP_GetGameInfo.__index = CMD_GP_GetGameInfo
function CMD_GP_GetGameInfo:new()
	local self = {
		nUserDBID = 0,
		nPartnerID = 0,
		nVersionCode = 0,
		ClientInfo = tagClientInfo:new(),
		VersionInfo = tagVersionInfo:new(),
		szPassword = ""
	}

	setmetatable(self, CMD_GP_GetGameInfo)

	return self
end

function CMD_GP_GetGameInfo:Serialize()
	local ba = require("ByteArray").new()

	ba:writeInt(self.nUserDBID)
	ba:writeInt(self.nPartnerID)
	ba:writeInt(self.nVersionCode)	
	ba:writeByteArray(self.ClientInfo:Serialize())
	ba:writeByteArray(self.VersionInfo:Serialize())
	ba:writeString(self.szPassword)
	for i=string.len(self.szPassword) + 1,64 do
		ba:writeByte(0)
	end
	ba:setPos(1)
	
	return ba
end

-- struct CMD_GP_ChangeInfo
-- {
-- 	DWORD					dwUserDBID;						//鏁版嵁搴?ID
-- 	BYTE					cbSex;
-- 	char					szNickName[NAME_LEN];			//鏄电О
-- 	char					szDescrie[DESCRIBE_LEN];		//鐢ㄦ埛鎻忚堪
-- 	WORD					wFaceID;
-- 	char					szQQ[32];
-- 	char					szLocation[64];
-- 	int						nFaceDataLen;
-- 	BYTE					cbFaceData[15000];
-- }
CMD_GP_ChangeWord = {}
CMD_GP_ChangeWord.__index = CMD_GP_ChangeWord
function CMD_GP_ChangeWord:new()
	local self = {
		dwUserDBID = 0,
		szDescrie = "szDescrie"
	}

	setmetatable(self, CMD_GP_ChangeWord)

	return self
end

function CMD_GP_ChangeWord:Serialize()
	local ba = require("ByteArray").new()

	ba:writeUInt(self.dwUserDBID)
	ba:writeString(self.szDescrie)
	ba:writeByte(0)
	return ba
end


-- struct CMD_BIND_EMAIL
-- {
-- 	DWORD dwDBID;
-- 	char szEmail[32];
-- 	char szPassword[32];
-- 	CMD_BIND_EMAIL()
-- 	{
-- 		memset(this,0,sizeof(CMD_BIND_EMAIL));
-- 	}
-- };
CMD_BIND_EMAIL = {--dwDBID , szEmail = {}, szPassword = {}
}
CMD_BIND_EMAIL.__index = CMD_BIND_EMAIL
function CMD_BIND_EMAIL:new(buffer, nLen)
	local self = {
		dwDBID = 0,
		szEmail = "szEmail",
		szPassword = "szPassword"
	}

	setmetatable(self, CMD_BIND_EMAIL)

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self.dwDBID = ba:readUInt()
	self.szEmail = ba:readString(32)
	self.szPassword = ba:readString(32)

	return self
end

function CMD_BIND_EMAIL:Serialize()
	local ba = require("ByteArray").new()

	ba:writeUInt(self.dwDBID)
	ba:writeString(self.szEmail)
	ba:writeString(self.szPassword)

	return ba
end

function CMD_BIND_EMAIL:getLen()
	return 4 + 32 + 32
end

-- struct CMD_GP_GET_AWARD	//SUB_GP_GET_AWARD
-- {
-- 	DWORD dwDBID;
-- 	WORD wGameID;
-- 	BYTE cbVIP;
-- 	CMD_GP_GET_AWARD()
-- 	{
-- 		cbVIP = 0;
-- 	}
-- };
CMD_GP_GET_AWARD = {--dwDBID , wGameID, cbVIP
}
CMD_GP_GET_AWARD.__index = CMD_GP_GET_AWARD
function CMD_GP_GET_AWARD:new(buffer, nLen)
	local self = {
		dwDBID = 0,
		wGameID = 0,
		cbVIP = 0
	}

	setmetatable(self, CMD_GP_GET_AWARD)

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self.dwDBID = ba:readUInt()
	self.wGameID = ba:readShort()
	self.cbVIP = ba:readByte()

	return self
end

function CMD_GP_GET_AWARD:Serialize()
	local ba = require("ByteArray").new()

	ba:writeUInt(self.dwDBID)
	ba:writeShort(self.wGameID)
	ba:writeByte(self.cbVIP)

	return ba
end

function CMD_GP_GET_AWARD:getLen()
	return 4 + 2 + 1
end

return PlazaCmds