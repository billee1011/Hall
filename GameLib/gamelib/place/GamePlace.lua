require("GameLib/common/common")
require("GameLib/common/PlazaInfo")
require("GameLib/common/CMD_GP_Logon_Success_Ex")
require("GameLib/common/ContinueAwardInfo")
local json = require("CocosJson")


local GamePlace = { }
GamePlace.__index = GamePlace

local PlazaCmds = require("GameLib/gamelib/place/PlazaCmds")

function GamePlace:new(gameLib)
	local self = {
		-- 变量
		_socket = nil,
		m_szIMEI = "",
		m_szDeviceName = "",
		_sink = nil;
		_strName = "",
		_strPass = "",
		_serverIP = "zjhhall.ss2007.com",
	    _port = 8100,
	    _loginType,
		_dwLoginUserID,
		_arTypeList = {},
		_arKindList = {},
		_arStationList = {},
		_arGameServerList = {},
		_dwGameID,
		_dwTypeID,
		_userLogonInfo = CMD_GP_LogonSuccess_Ex2:new(),
		m_nBroadcastID = 0,
		m_changeInfo = CMD_GP_ChangeWord:new(),
		m_szWebRoot = "http://zjh.ss2007.com",
		m_szPlatFormRoot = "http://platform.ss2007.com",
		m_pGameLib = self:getGameLib(),
		m_szGameName = "",
		m_szAppleReceipt = "",
		m_vipList = {},
		m_vipListWakeng = {},
		m_propertyList = {},
		m_taskList = {},
		--m_chargeInfoList = {},
		m_gameTitleList = {},
		--m_nMoneyExchangeRatio = 10000,
		m_friendList = {},
	 	m_mailList = {},
		m_bCashedMailList = {},
		m_nRecommendType = 3,
		m_nPayAmount = 0,
		m_nPartnerID = 0,
		m_nFreeSpeakerLeft = 0,
		m_bAllInAction = false,
		m_dwLastCheckNewTime  = getTickCount(),
		m_bNewMailNotice = false,
		m_dwChargePollStart = 0,
		m_bActive = true,
		m_vGetFaceList = {},
		m_bInReview = false,
		m_bIsShowAD = false,
		m_bIsSnow = false,
		m_dwGetServerList = 0,
		m_bRefreshServerList = false,
		--m_dwLastAppleCharge = 0,
		m_gameLib = gameLib
	}
	setmetatable(self,GamePlace)
	self.m_publicUserInfo = self.m_gameLib:getPublicUserInfo()
    --self.m_publicUserInfo = require("HallControl"):instance().publicUserInfo
    -- print("--------------------------------------")
    --print(self.m_publicUserInfo)

	return self
end

GamePlace.TIME_CHECK_NEWSTATUS 	= 5
GamePlace.TIME_CLOSE_SOCKET 		= 5
GamePlace.TIMER_CLOSE_SOCKET = nil
GamePlace.TIMER_CHECK_NEWSTATUS = nil
GamePlace.TIMER_CHARGE_POLL = nil
GamePlace.TIME_CHARGE_POLL =	3
GamePlace.TIMER_RESIGN_ACTIVE =	nil
GamePlace.TIME_RESIGN_ACTIVE  =	20
GamePlace.ID = 0
GamePlace.NAME = 1
GamePlace.GAME189 = 2
GamePlace.TOKEN = 3
GamePlace.REGISTER = 4
GamePlace.NORMAL_REGISTER = 5
GamePlace.IMEI = 6
GamePlace.EMAIL = 7
GamePlace.BIND_EMAIL = 8
GamePlace.GET_AWARD = 9
GamePlace.CHANGE_USER_INFO = 10
GamePlace.GET_FACE = 11
GamePlace.APPLE_CHARGE = 12
GamePlace.REQUEST_SERVERLIST = 13
GamePlace.GET_GAMEINFO = 14
GamePlace.WAKENG_AWARD_WEEK	=	0
GamePlace.WAKENG_AWARD_MONTH =	1
GamePlace.WAKENG_AWARD_CONTINUE	=2

function GamePlace:getGameLib()
	require("GameLib/gamelib/CGameLib")
	return self.m_gameLib
end

function GamePlace:release()
	if self.TIMER_CHECK_NEWSTATUS ~= nil then		
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.TIMER_CHECK_NEWSTATUS)
		self.TIMER_CHECK_NEWSTATUS = nil
	end
	if self.TIMER_RESIGN_ACTIVE ~= nil then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.TIMER_RESIGN_ACTIVE)
		self.TIMER_RESIGN_ACTIVE = nil
	end	
	if self.TIMER_CHARGE_POLL ~= nil then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.TIMER_CHARGE_POLL)
		self.TIMER_CHARGE_POLL = nil
	end	
	if self.TIMER_CLOSE_SOCKET ~= nil then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.TIMER_CLOSE_SOCKET)
		self.TIMER_CLOSE_SOCKET = nil
	end

	if self._socket then
		self._socket:Release()
	end
	self._socket = nil	
end


function GamePlace:delayCloseConnect()
	if self.TIMER_CLOSE_SOCKET ~= nil then 
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.TIMER_CLOSE_SOCKET)
		self.TIMER_CLOSE_SOCKET = nil
	end

	--local gamePlace = self
    
    local function onDelayCloseConnect()
    	cclog("onDelayCloseConnect")
		if self.TIMER_CLOSE_SOCKET ~= nil then 
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.TIMER_CLOSE_SOCKET)
			self.TIMER_CLOSE_SOCKET = nil
		end    	
        if(self._socket ~= nil) then self._socket:closeconnect() end
    end

    self.TIMER_CLOSE_SOCKET = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(
    	onDelayCloseConnect,self.TIME_CLOSE_SOCKET,false)

    --[[local function onCheckNewStatus()
    	self:checkNewStatus()
    end
    if(self.TIMER_CHECK_NEWSTATUS == nil) then
    	self.TIMER_CHECK_NEWSTATUS = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(
    		onCheckNewStatus,1,false)
    end]]
	--GameLibTimer:getInstance():setTimer(TIMER_CLOSE_SOCKET,TIME_CLOSE_SOCKET,this,0)
 	--GameLibTimer:getInstance():setTimer(TIMER_CHECK_NEWSTATUS,TIME_CHECK_NEWSTATUS,this,0xFFFF)
end

function GamePlace:sendGetGameInfo()
	local l = CMD_GP_GetGameInfo:new()
	l.nUserDBID = self.m_publicUserInfo.UserID
	l.nPartnerID = self.m_gameLib:getPartnerID()
	l.nVersionCode = self.m_gameLib:getVersionCode()
	l.ClientInfo = self.m_gameLib:getClientInfo()
	l.VersionInfo = self.m_gameLib:getVersionInfo()
	l.szPassword = self.m_publicUserInfo.EPassword
	local ba = l:Serialize()
	self:sendGameCmd(PlazaCmds.MAIN_GP_LOGON, PlazaCmds.SUB_GP_GET_GAMEINFO_EX, 0, ba:getBuf(),ba:getLen())
end

function GamePlace:sendImeiLoginCmd()
	local login = CMD_GP_Logon_ByIMEI:new()
	login.wGameID = self:getGameLib():getGameID()
	login.szIMEI = self.m_szIMEI
	login.szDeviceName = self.m_szDeviceName
	login.ClientInfo = self:getGameLib():getClientInfo()
	login.VersionInfo = self:getGameLib():getVersionInfo()
	local ba = login:Serialize()
	self:sendGameCmd(PlazaCmds.MAIN_GP_LOGON, PlazaCmds.SUB_GP_LOGON_BY_IMEI, 0, ba:getBuf(),ba:getLen())
end

function GamePlace:sendEmailLoginCmd()
	local login = CMD_GP_Logon_ByEMAIL:new()
	login.wGameID = self:getGameLib():getGameID()
	login.szEMAIL = self._strName
	login.szPass = self._strPass
	login.szIMEI = self.m_szIMEI
	login.szDeviceName = self.m_szDeviceName
	login.ClientInfo = self:getGameLib():getClientInfo()
	login.VersionInfo = self:getGameLib():getVersionInfo()
	local ba = login:Serialize()
	self:sendGameCmd(PlazaCmds.MAIN_GP_LOGON, PlazaCmds.SUB_GP_LOGON_BY_EMAIL, 0, ba:getBuf(),ba:getLen())
end

function GamePlace:onConnect()
	if(self._loginType == GamePlace.ID) then
		--sendIDLoginCmd()
	elseif(self._loginType == GamePlace.NAME) then
		--sendNameLoginCmd()
	elseif(self._loginType == GamePlace.GAME189) then
		--sendGame189Login()
	elseif(self._loginType == GamePlace.TOKEN) then
		
	elseif(self._loginType == GamePlace.REGISTER) then
		--sendRegister()
	elseif(self._loginType == GamePlace.NORMAL_REGISTER) then
		--sendNormalRegister()
	elseif(self._loginType == GamePlace.IMEI) then
		self:sendImeiLoginCmd()
	elseif(self._loginType == GamePlace.EMAIL) then
		self:sendEmailLoginCmd()
	elseif(self._loginType == GamePlace.BIND_EMAIL) then
		self:sendBindEMail()
	elseif(self._loginType == GamePlace.GET_AWARD) then
		self:sendGetAward()
	elseif(self._loginType == GamePlace.CHANGE_USER_INFO) then
		self:sendChangeUserInfo()
	elseif(self._loginType == GamePlace.GET_FACE) then
		self:sendGetFace()	
	elseif(self._loginType == GamePlace.REQUEST_SERVERLIST) then
		self:sendServerListCmd()
	elseif self._loginType == GamePlace.GET_GAMEINFO then
		self:sendGetGameInfo()
	end
end

function GamePlace:onConnectFailed()
	if (self:getGameLib():getGameLibSink() ~= nil) then
		self:getGameLib():getGameLibSink():onLogonFailed("网络连接失败，请检查网络后重新连接！",1)
	end
end

function GamePlace:sendGameCmd(cbMainCmd, cbSubCmd, t, buff, buffLen)
    cclog("GamePlace:send cbMainCmd:%d, cbSubCmd:%d", cbMainCmd, cbSubCmd)
    self._socket:sendGameCmd(cbMainCmd, cbSubCmd, t, buff, buffLen)
end

function GamePlace:onRecv(buf,nLen)
	local cbMainCmd = string.byte(buf)
	if (nLen < 2) then
		return
	end

	--for i = 1,nLen - 1 do
	--	cclog("onRecv " .. i .. ":" .. string.byte(string.sub(buf,i)))
	--end

	local cbSubCmd = string.byte(string.sub(buf,2))
	local nRealDataLen = nLen - 4
    
	cclog("GamePlace:onRecv len = %d, string.len = %d, cbMainCmd = %d, cbSubCmd = %d", nLen, string.len(buf), cbMainCmd, cbSubCmd)
	
	--有网络交互，触发刷新状态
	self:SetActive()

	if (nRealDataLen <= 0) then
		if (nLen < 3) then
			return
		end
		self:recvData(cbMainCmd, cbSubCmd, string.sub(buf,3),nil,0)
		return
	end
	self:recvData(cbMainCmd, cbSubCmd, string.byte(string.sub(buf,3)), string.sub(buf,5),nLen - 4)
end

function GamePlace:onConnectClose(data,len)
	--cclog("GamePlace.onConnectClose()")
end

function GamePlace:pulse()
	if self._socket == nil then
		return
	end	
	while(1)
	do
		if self._socket == nil then
			return
		end
		local response = self._socket:getResponse()
		if (response == nil) then return end
		--cclog("&&&&&&&&&&GamePlace:pulse type = " .. response.nCmd)
		if response.nCmd == gamelibcommon.CONNECT_OK_RES then
			self:onConnect()
		end
		if response.nCmd == gamelibcommon.CONNECT_ERROR_RES then
			self:onConnectFailed()
		end
		if response.nCmd == gamelibcommon.RECV_DATA_OK_RES then
			self:onRecv(response.pData,response.nLen)
			response:release()
			return
		end
		if response.nCmd == gamelibcommon.DISCONNECT_RES then
			self:onConnectClose()
		end
		response:release()
	end		
end

function GamePlace:sendBindEMail()
	local login = CMD_BIND_EMAIL:new()
	login.szEmail = _self._strName
	login.szPassword = _self._strPass
	login.dwDBID = self.m_publicUserInfo.UserID
	local ba = login:Serialize()
	self:sendGameCmd(PlazaCmds.MAIN_GP_CONFIG, PlazaCmds.SUB_GP_BIND_EMAIL, 0, ba:getBuf(),ba:getLen())
end

function GamePlace:sendGetAward()
	local login = CMD_GP_GET_AWARD:new() 
	login.dwDBID = self.m_publicUserInfo.UserID
	login.wGameID = self._dwGameID
	login.cbVIP = self.m_cbVIPAward
	local ba = login:Serialize()
	self:sendGameCmd(PlazaCmds.MAIN_GP_CONFIG, PlazaCmds.SUB_GP_GET_AWARD, 0, ba:getBuf(),ba:getLen())
end

function GamePlace:sendGetFace()
	if(#self.m_vGetFaceList <= 0) then
		return
	end
	local dwUserID = self.m_vGetFaceList[1]
	table.remove(self.m_vGetFaceList,1)
	local ba = require("ByteArray").new()
	ba:writeInt(dwUserID)
	self:sendGameCmd(PlazaCmds.MAIN_GP_CONFIG, PlazaCmds.SUB_GP_GET_FACE, 0, ba:getBuf(),ba:getLen())
end

function GamePlace:sendChangeUserInfo()
	local ba = self.m_changeInfo:Serialize()
	self:sendGameCmd(PlazaCmds.MAIN_GP_CONFIG, PlazaCmds.SUB_GP_CHANGE_USERWORD, 0, ba:getBuf(),ba:getLen())
end


function GamePlace:clearServerList()
	self._arTypeList = {}
	self._arKindList = {}
	self._arStationList = {}
	self._arGameServerList = {}
end

function GamePlace:getVIPInfo(nLevel)
	if(self._dwGameID == gamelibcommon.GAMEID_WAKENG) then
		return nil
	end
	for i=1,#self.m_vipList do
		if (self.m_vipList[i].nLevel == nLevel)	then
			return self.m_vipList[i]
		end
	end
	return nil
end

function GamePlace:getVIPInfoWakeng(nLevel)
	if(self._dwGameID ~= gamelibcommon.GAMEID_WAKENG) then
		return nil
	end
	for i=1,#self.m_vipListWakeng do
		if (self.m_vipListWakeng[i].nLevel == nLevel)	then
			return self.m_vipListWakeng[i]
		end
	end
	return nil
end

function GamePlace:recvData(cbMainCmd,cbSubCmd,cbHandleCode,buf,nLen)	
	if cbMainCmd == PlazaCmds.MAIN_GP_LOGON then
		return self:onMainLogonMessage(cbSubCmd, cbHandleCode, buf,nLen)
	end

	if cbMainCmd == PlazaCmds.MAIN_GP_SERVER_LIST then	
		return self:onMainServerListMessage(cbSubCmd, cbHandleCode, buf,nLen)
	end

	if cbMainCmd == PlazaCmds.MAIN_CM_SERVICE then	
		return self:onMainSystemMessage(cbSubCmd, cbHandleCode, buf,nLen)
	end
	
	if cbMainCmd == PlazaCmds.MAIN_GP_CONFIG then
		return self:onMainConfig(cbSubCmd, cbHandleCode, buf,nLen)
	end
		
	cclog("onrecv main = %d,sub = %d,len = %d",cbMainCmd,cbSubCmd,nLen)
	
	return true
end

function GamePlace:onMainLogonMessage(cbSubCmd, cbHandleCode,cbBuffer,nLen)	
	if cbSubCmd == PlazaCmds.SUB_GP_LOGON_SUCCESS then
		-- 没有使用
		return true
	end

	if cbSubCmd == PlazaCmds.SUB_GP_GAMEINFO then
		cclog("SUB_GP_GAMEINFO")
		self._userLogonInfo = CMD_GP_LogonSuccess_Ex2:new(cbBuffer)	
		self.m_bCashedMailList = false
		--self:getUserGameInfo()
		--self:getWebChargeInfo(self.m_nPartnerID,self:getGameLib():getVersionInfo().dwBuildVer)
		return true
	end

	if cbSubCmd == PlazaCmds.SUB_GP_VIP_INFO then
		local ba = require("ByteArray").new()
		ba:initBuf(cbBuffer)
		self._userLogonInfo.nVIPLevel = ba:readInt()
		self._userLogonInfo.cbGameTitleLevel = ba:readUByte()
		self._userLogonInfo.nGameTitleScore = ba:readInt()		
		--memcpy(_userLogonInfo.cbFaceData,cbBuffer,nLen)
		cclog("SUB_GP_VIP_INFO %d",nLen)
		return true
	end
	if cbSubCmd == PlazaCmds.SUB_GP_SCORE_EX then
		local ba = require("ByteArray").new()
		ba:initBuf(cbBuffer)
		cclog("SUB_GP_SCORE_EX len = " .. nLen .. ",ba:getLen = " .. ba:getLen())
		self._userLogonInfo.nWeekWinAmount = ba:readInt()
		self._userLogonInfo.nMaxWinAmount = ba:readInt()
		self._userLogonInfo.nGuessWin = ba:readInt()
		return true
	end	
	return true
end

local function roomSort(taskinfo1,taskinfo2)
    if taskinfo1.dwMinGold == taskinfo2.dwMinGold then
        return taskinfo1.wOnLineCount < taskinfo2.wOnLineCount
    else
        return taskinfo1.dwMinGold < taskinfo2.dwMinGold
    end
end

local function stationSort(taskinfo1,taskinfo2)
    return taskinfo1.dwMinGold < taskinfo2.dwMinGold
end

function GamePlace:onMainServerListMessage(cbSubCmd, cbHandleCode, cbBuffer,nLen)
	local wDataSize = nLen

	if cbSubCmd == PlazaCmds.SUB_GP_SERVER_LIST_TYPE_V1 then	
		local nTypeCount = wDataSize / tagGameTypeV1:getLen()
		for i=1,nTypeCount do
			local gameType =  tagGameTypeV1:new(string.sub(cbBuffer,(i - 1) * tagGameTypeV1:getLen()),tagGameTypeV1:getLen())
			cclog("GameType %s",getUtf8(gameType.szTypeName))
			self._arTypeList[#self._arTypeList + 1] = gameType
		end
		
		return true
	end

	if cbSubCmd == PlazaCmds.SUB_GP_SERVER_LIST_KIND then
		cclog("SUB_GP_SERVER_LIST_KIND %d/%d",wDataSize , tagGameKind:getLen())	
		local nKindCount = wDataSize / tagGameKind:getLen()
		for i=1,nKindCount do
		
			local gameKind =  tagGameKind:new(string.sub(cbBuffer,(i - 1) * tagGameKind:getLen()),tagGameKind:getLen())
	
			self._arKindList[#self._arKindList + 1] = gameKind
            cclog("GameKind %s(%d) self.gameid = %d nKindCount = %d",
            	getUtf8(gameKind.szKindName),gameKind.dwKindID,self._dwGameID,nKindCount)
			if(gameKind.dwKindID == self._dwGameID) then			
				self._dwTypeID = gameKind.dwTypeID
				self.m_szGameName = gameKind.szKindName
            cclog("GameKind %s(%d) self.gameid = %d",
            	getUtf8(gameKind.szKindName),gameKind.dwKindID,self._dwGameID)				
			end
		end

		if (cbHandleCode == 0) then		
			self.m_bRefreshServerList = false
			self:sendServerListCmd()
		end
		return true
	end

	if cbSubCmd == PlazaCmds.SUB_GP_SERVER_LIST_STATION then	
		local nStationLen = wDataSize / tagGameStation:getLen()
		for i= 1,nStationLen do		
            local gameStation = tagGameStationEx:new(string.sub(cbBuffer,(i - 1) * tagGameStation:getLen() + 1),tagGameStation:getLen())
			cclog("station %s[%d],minmax=(%d),ruleID=%d",
				getUtf8(gameStation.szStationName),gameStation.dwStationID,gameStation.dwMinGold,gameStation.dwRuleID)
			if(gameStation.dwParentID == self._dwGameID) then			
				self:addGameStation(gameStation)
			end
		end
		return true
	end
	if cbSubCmd == PlazaCmds.SUB_GP_SERVER_LIST_ROOM then
		nGameServerLen = tagGameServerEx:getLen()
		local nStationLen = wDataSize / nGameServerLen
		cclog("SUB_GP_SERVER_LIST_ROOM cbHandleCode = %s, wDataSize = %d(%d), nStationLen = %d", cbHandleCode, wDataSize, nGameServerLen, nStationLen)
		for i= 1,nStationLen do		
			local gameServer = tagGameServerEx:new(string.sub(cbBuffer,(i - 1) * nGameServerLen + 1),nGameServerLen)
			gameServer = self:addGameServer(gameServer)
			local pStation = self:getGameStation(gameServer.dwStationID)
			if(pStation ~= nil) then			
				pStation.dwMinGold = gameServer.dwMinGold
				pStation.dwRuleID = gameServer.dwRuleID
			end
			cclog("GamePlace(%d) %s (%d/%d),(%d,%d,%d),RuleID = %d(%d),online=%d", gameServer.dwServerID,
				getUtf8(gameServer.szGameRoomName),gameServer.dwMinGold,gameServer.dwMaxGold,
				gameServer.cbPrivateRoom,gameServer.cbMinVipNeed,gameServer.cbMinCreateTableVIP,
				gameServer.dwRuleID,gameServer.dwStationID,gameServer.wOnLineCount)
		end
		if (cbHandleCode == 0) then
		
		end
		return true
	end
	if cbSubCmd == PlazaCmds.SUB_GP_SERVER_LIST_ROOM_EX then		
		local nGameServerLen = tagGameServerExtraInfo:getLen()
		nStationLen = wDataSize / nGameServerLen
		if nStationLen == 0 then return true end
		for i = 1,nStationLen do			
			local gameServer = tagGameServerExtraInfo:new(string.sub(cbBuffer,(i - 1) * nGameServerLen + 1),nGameServerLen)			
			cclog("SUB_GP_SERVER_LIST_ROOM_EX %d: %d,%d,%d",
				i,gameServer.nBaseGold,gameServer.nServerID,gameServer.nTableGold)
			local pServer = self:getGameServer(gameServer.nServerID)
			if pServer ~= nil  then				
				local pStation = self:getGameStation(pServer.dwStationID)
				if pStation ~= nil then
					pStation.nTableGold = gameServer.nTableGold
					pStation.nBaseGold = gameServer.nBaseGold
				end				
			end
		end
		
		if (cbHandleCode == 0) then		
			self:delayCloseConnect()
			-- 对房间列表进行排序
			table.sort(self._arGameServerList,roomSort)
			table.sort(self._arStationList,stationSort)
			if(not self.m_bRefreshServerList) then
				self._sink:onLogonFinished()
			end
		end
		return true
	end	
	return true
end

function GamePlace:onMainConfig(cbSubCmd, cbHandleCode, cbBuffer,nLen)
	local ba = require("ByteArray").new()
	if(nLen > 0) then
		ba:initBuf(cbBuffer)
	end
	
	if cbSubCmd == PlazaCmds.SUB_GP_GET_FACE then	
		local pDBID = ba:readInt()
		self._sink:onGetFaceDataRet(pDBID,ba:readUByte(),nLen - 5,string.sub(cbBuffer,6))
		--m_nGetFaceCount--
		--if(m_nGetFaceCount < 0)
		--	m_nGetFaceCount = 0
		if(#self.m_vGetFaceList > 0) then
			self:sendGetFace()
		else
			self:delayCloseConnect()
		end
		return true
	end
	
	if cbSubCmd == PlazaCmds.SUB_GP_CHANGE_USERWORD then
		if(string.byte(cbBuffer) == 1) then			
			self._userLogonInfo.szLeaveWord = self.m_changeInfo.szDescrie	
		end
		self._sink:onChangeUserInfoRet(string.byte(cbBuffer))
		self:delayCloseConnect()
		return true
	end
	return true
end

function GamePlace:onMainSystemMessage(cbSubCmd, cbHandleCode, cbBuffer,nLen)
	if cbSubCmd == PlazaCmds.SUB_CM_MESSAGE then
		require("GameLib/gamelib/room/GameCmds")
		local pSystemMessage = CMD_CM_SysteMessage:new(cbBuffer,nLen)
		if (pSystemMessage.bCloseLine) then		
			cclog("SUB_CM_MESSAGE closeconnect %d",getTickCount())
			self._socket:closeconnect()
		end

		if (pSystemMessage.wMessageLen > 0) then		
			self._sink:onLogonFailed(pSystemMessage.szMessage,2)
		end
		return true
	end	
	return true
end

function GamePlace:requestServerList()
	if(self.m_dwGetServerList ~= 0) then	
		if(getTickCount() - self.m_dwGetServerList < 600000) then
			return
		end
	end	
	self.m_bRefreshServerList = true
	if(not self:isServicing()) then	
		if(self._socket == nil) then		
			self._socket = CCSocket:createCCSocket()
			self._socket:init()
		end
		self._loginType = GamePlace.REQUEST_SERVERLIST
		self._socket:connect(self._serverIP,self._port)
		return
	end
	self:sendServerListCmd()
end

function GamePlace:sendServerListCmd()
	if(not self.m_bRefreshServerList) then
		self:clearServerList()
	end
	local GetServer = CMD_GP_GetServer:new()	
	GetServer.dwTypeID = self._dwTypeID or 0
	GetServer.dwKindID = self._dwGameID or 0
	GetServer.VersionInfo = self:getGameLib():getVersionInfo()

	self.m_dwGetServerList = getTickCount()
	local ba = GetServer:Serialize()
	self:sendGameCmd(PlazaCmds.MAIN_GP_SERVER_LIST, PlazaCmds.SUB_GP_GET_SERVER_LIST, 0, ba:getBuf(),ba:getLen())
end

function GamePlace:setSink(sink)
	self._sink = sink
end

function GamePlace:setGameID(gameid)
	self._dwGameID = gameid
end

function GamePlace:setServerIP(serverIP)
	self._serverIP = serverIP
end

function GamePlace:setPort(port)
	self._port = port
end

function GamePlace:getUserLoginInfo()
	--cclog("getUserLoginInfo dbid = %d,name = %s",_userLogonInfo.lUserDBID,_userLogonInfo.szNickName)
	return self._userLogonInfo
end


function GamePlace:getGameStation(stationID)
	for i = 1,#self._arStationList do	
		if (self._arStationList[i].dwStationID == stationID) then
			return self._arStationList[i]
		end
	end
	return nil
end

function GamePlace:getGameStationByName(szName)
	for i = 1,#self._arStationList do	
		local station = self._arStationList[i]
		if (station.szStationName == szName) then
			return station
		end
	end
	return nil
end

function GamePlace:getGameServer(nServerID)
	for i = 1, #self._arGameServerList do	
		local station = self._arGameServerList[i]
		if (station.dwServerID == nServerID) then	
			return station
		end
	end
	return nil
end

function GamePlace:getStationList()
	return self._arStationList
end

function GamePlace:getGameServerList(stationID)
	local ret = {}
	for i = 1, #self._arGameServerList do		
		local station = self._arGameServerList[i]
		if (station ~= nil and station.dwStationID == stationID) then	
			ret[#ret + 1] = station
		end
	end
	return ret
end

function GamePlace:getAllGameServerList()
	return self._arGameServerList
end

function GamePlace:getAutoEnterRoom(lpszStation)
	-- 如果是断线续玩
	local pDefault = CCUserDefault:sharedUserDefault()
	local lastRoom = pDefault:getStringForKey("LastRoom")
	if(string.len(lastRoom) > 0) then	
		for i = 1,#self._arGameServerList do		
			if lastRoom == getUtf8(self._arGameServerList[i].szGameRoomName) then			
				cclog("断线续玩 %s" , lastRoom)
				return self._arGameServerList[i]
			end
		end
	end

	
	local server = nil
	local full = 0xFFFF

	local minServer = nil

	local dwFocusStationID = -1
	-- 优先进入更大额房间
	local nMinGold = 0
	for i = 1,#self._arStationList do
		local gameStation = self._arStationList[i] 
		if(lpszStation ~= nil and string.len(lpszStation) > 0) then		
			if(string.find((gameStation.szStationName),lpszStation) ~= nil) then			
				dwFocusStationID = gameStation.dwStationID
				break
			end
		end
	end

	for i = 1,#self._arGameServerList do	
		while true do
			local room = self._arGameServerList[i]
			if(dwFocusStationID ~= -1) then		
				if(room.dwStationID ~= dwFocusStationID) then
					break
				end
			end
			if minServer == nil then
				minServer = room
			else
				if minServer.dwMinGold > room.dwMinGold then
					minServer = room	
				end
			end
			-- 增加一个金额判断
			if(room.dwMaxGold ~= 0 and room.dwMaxGold < self._userLogonInfo.dwGold ) then
				break
			end
			if(room.dwMinGold ~= 0 and room.dwMinGold > self._userLogonInfo.dwGold ) then
				break
			end
			
			tempFull = room.wMaxOnLineCount * 4 / 5 - room.wOnLineCount
			if(tempFull <= 0) then
				break
			end
			if(server == nil) then
				server = room
			end

			local nTempMinGold = room.dwMinGold
			if(nTempMinGold > nMinGold) then			
				nMinGold = nTempMinGold
				server = room
			end
			break
		end
	end
	return server or minServer
end

function GamePlace:isServicing()
	if(self._socket == nil) then
		return false
	end
	return self._socket:isConnected() or self._socket:isConnecting()
end

function GamePlace:getGameInfo()
	if(self._socket == nil) then	
		self._socket = CCSocket:createCCSocket()
		self._socket:init()
	end
	self._loginType = GamePlace.GET_GAMEINFO
	if(self._socket:isConnected()) then	
		if self.TIMER_CLOSE_SOCKET ~= nil then
			cclog("TIMER_CLOSE_SOCKET")
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.TIMER_CLOSE_SOCKET)
			self.TIMER_CLOSE_SOCKET = nil
		end
		if self.TIMER_CHECK_NEWSTATUS ~= nil then
			cclog("TIMER_CHECK_NEWSTATUS")
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.TIMER_CHECK_NEWSTATUS)
			self.TIMER_CHECK_NEWSTATUS = nil
		end
	end
	--cclog("GamePlace:getGameInfo connect to server %s:%d",self._serverIP,self._port)
	self._socket:connect(self._serverIP,self._port)
	return true
end

function GamePlace:loginByIMEI(lpszIMEI,lpszDeviceName)
	if(self._socket == nil) then	
		self._socket = CCSocket:createCCSocket()
		self._socket:init()
	end
	self._loginType = GamePlace.IMEI
	self.m_szIMEI = lpszIMEI
	self.m_szDeviceName = lpszDeviceName
	if(self._socket:isConnected()) then	
		if self.TIMER_CLOSE_SOCKET ~= nil then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.TIMER_CLOSE_SOCKET)
			self.TIMER_CLOSE_SOCKET = nil
		end
		if self.TIMER_CHECK_NEWSTATUS ~= nil then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.TIMER_CHECK_NEWSTATUS)
			self.TIMER_CHECK_NEWSTATUS = nil
		end
	end
	cclog("GamePlace:loginByIMEI connect to server %s:%d",self._serverIP,self._port)
	self._socket:connect(self._serverIP,self._port)
	return true
end

function GamePlace:loginByEMAIL(lpszEMAIL,lpszPassword,lpszIMEI)
	if(self._socket == nil) then	
		self._socket = CCSocket:createCCSocket()
		self._socket:init()
	end
	self._loginType = GamePlace.EMAIL
	self._strName = lpszEMAIL
	self.m_szIMEI = lpszIMEI
	self._strPass = lpszPassword

	if(self._socket:isConnected()) then	
		if self.TIMER_CLOSE_SOCKET ~= nil then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.TIMER_CLOSE_SOCKET)
		end
		if self.TIMER_CHECK_NEWSTATUS ~= nil then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.TIMER_CHECK_NEWSTATUS)
		end
	end

	self._socket:connect(self._serverIP,self._port)
	return true
end

function GamePlace:bindEmail(lpszEMAIL,lpszPassword)
	self._strPass = lpszPassword
	self._strName = lpszEMAIL
	if(not self:isServicing()) then
		if(self._socket == nil) then	
			self._socket = CCSocket:createCCSocket()
			self._socket:init()
		end
		self._loginType = GamePlace.BIND_EMAIL
		self._socket:connect(self._serverIP,self._port)
		return
	else	
		if self.TIMER_CLOSE_SOCKET ~= nil then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.TIMER_CLOSE_SOCKET)
		end
		self:sendBindEMail()
	end
end

function GamePlace:changeUserInfo(lpszUserWord)
    self.m_changeInfo = CMD_GP_ChangeWord:new()
	
	self.m_changeInfo.szDescrie = lpszUserWord
    self.m_changeInfo.dwUserDBID = self.m_publicUserInfo.UserID	
   
	if(not self:isServicing()) then	
		if(self._socket == nil) then	
			self._socket = CCSocket:createCCSocket()
			self._socket:init()
		end
		self._loginType = GamePlace.CHANGE_USER_INFO
		self._socket:connect(self._serverIP,self._port)
		return
	else	
		if self.TIMER_CLOSE_SOCKET ~= nil then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.TIMER_CLOSE_SOCKET)
		end
		self:sendChangeUserInfo()
	end
end


function GamePlace:getUserFaceData(dwUserDBID)
	self.m_vGetFaceList[#self.m_vGetFaceList + 1] = dwUserDBID
	if(not self:isServicing()) then	
		if(self._socket == nil) then	
			self._socket = CCSocket:createCCSocket()
			self._socket:init()
		end
		self._loginType = GamePlace.GET_FACE
		self._socket:connect(self._serverIP,self._port)
		return	
	elseif(self.m_vGetFaceList and #self.m_vGetFaceList == 1) then	
		if self.TIMER_CLOSE_SOCKET ~= nil then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.TIMER_CLOSE_SOCKET)
		end
		self:sendGetFace()
	end
end

function GamePlace:setWebRoot(lpszRoot)
	self.m_szWebRoot = lpszRoot
	if string.find(lpszRoot,"test") then
		self.m_szPlatFormRoot = require("Domain").TestWebRoot
	else
		self.m_szPlatFormRoot = require("Domain").WebRoot
	end
	cclog("%s,%s",self.m_szWebRoot,self.m_szPlatFormRoot)
	self:getWebRecommendPlayType()	
	self.m_bInReview = self.m_gameLib:isInReview()
	self:getGameTitleList()
	self:getVipInfoList()
	self:getPropertyInfoList()
	cclog("setWebRoot")
end

function GamePlace:getOneGameServerInStation(nStationID)
	for i = 1,#self._arGameServerList do	
		local pServer = self._arGameServerList[i]
		if(pServer.dwStationID == nStationID) then
			return pServer
		end
	end
	return nil
end

function GamePlace:getStationOnlineCount(nStationID)
	local nRet = 0
	for i = 1, #self._arGameServerList do	
		local pServer = self._arGameServerList[i]
		if(nStationID ~= -1 and pServer.dwStationID == nStationID) then
			nRet = nRet + pServer.wOnLineCount
		end
	end
	return nRet
end

function GamePlace:getAutoEnterRoomByStationID(nStationID)
	-- 如果是断线续玩
	local nRoomID = 0
	local nFull = 0xFFFF
	for i = 1,#self._arGameServerList do
		while true 	do
			local pServer = self._arGameServerList[i]
			if(pServer.dwStationID ~= nStationID) then
				break
			end
			if(nRoomID == 0) then
				nRoomID = pServer.dwServerID
			end
			local tempFull = pServer.wMaxOnLineCount * 4 / 5 - pServer.wOnLineCount
			if(tempFull <= 0) then
				break
			end
			if(nFull > tempFull) then
			
				nFull = tempFull
				nRoomID = pServer.dwServerID
			end
		end
	end
	return nRoomID
end

function GamePlace:getSystemProperties()
	return self.m_propertyList
end

function GamePlace:enterGameRoomByType(nRoomType,nPlayType)
	cclog("GamePlace:enterGameRoomByType %d,%d",nRoomType,nPlayType)
	local pServer = nil
	-- 组合出ruleid
	local nRuleID = nRoomType	
	if nPlayType == 2 then	-- 全下
		nRuleID  = nRuleID + 100
	end
	if nPlayType == 3 then	-- 全下
		nRuleID  = nRuleID + 110
	end
	cclog("enterGameRoomByType ruleid = " .. nRuleID)
	for i = 1,#self._arGameServerList do
		while true do
			local room = self._arGameServerList[i]
			if((room.dwRuleID % 1000) ~= nRuleID) then
				break
			end
		
			-- 增加一个金额判断
			if(room.dwMaxGold ~= 0 and room.dwMaxGold < self._userLogonInfo.dwGold ) then
				break
			end
			if(room.dwMinGold ~= 0 and room.dwMinGold > self._userLogonInfo.dwGold ) then
				break
			end

			local tempFull = room.wMaxOnLineCount * 4 / 5 - room.wOnLineCount
			if(tempFull <= 0) then
				break
			end
			if(pServer == nil) then
				pServer = room
			end
			break
		end			
	end
	return pServer	
end

function GamePlace:getRecommendPlayType()
	return self.m_nRecommendType
end

function GamePlace:GetPayAmount()
	return self.m_nPayAmount
end

-- 输出三个数据bool,rEnterVipLevelNeeded,rCreateTableVIPLevelNeeded,rMinGoldNeeded
function GamePlace:hasPrivateRoom()
	local pPrivateRoom = self:getPrivateRoom()
	if(pPrivateRoom == nil) then 
		return false,0,0,0
	end
	
	return true,pPrivateRoom.cbMinVipNeed,pPrivateRoom.cbMinCreateTableVIP,pPrivateRoom.dwMinGold	
end

function GamePlace:getAllRoomByJudge(judgefunc)
	local pServers = {}

	for i = 1,#self._arGameServerList do	
		if(judgefunc(self._arGameServerList[i])) then
			table.insert(pServers, getUtf8(self._arGameServerList[i].szGameRoomName))
		end
	end

	return pServers	
end

function GamePlace:getPrivateRoom(serverName, forbidName)
    print("getPrivateRoom", serverName, forbidName)
	local pServer = nil
	local myVip = 0--require("Lobby/Login/LoginLogic").UserInfo.VIPLevel

	for i = 1,#self._arGameServerList do	
		if(self._arGameServerList[i].cbPrivateRoom ~= 0) then
			pServer = self._arGameServerList[i]
			if serverName then
                print(serverName, " <--> ", getUtf8(pServer.szGameRoomName))
				if serverName == getUtf8(pServer.szGameRoomName) then
					break
				end
				pServer = nil
			elseif forbidName then
				if forbidName ~= getUtf8(pServer.szGameRoomName) then
					break
				end		
			else
                print(myVip, " <--> ", pServer.cbMinCreateTableVIP)
				--新增停服VIP判断
				if pServer.cbMinCreateTableVIP > myVip then
					pServer = nil
				else
					local tempFull = pServer.wMaxOnLineCount * 4 / 5 - pServer.wOnLineCount
					if(tempFull > 0) then
						break
					end
				end	
			end
		end
	end

	return pServer
end

function GamePlace:searchRoomByName(serverName)
	local pServer = nil
	for i = 1,#self._arGameServerList do	
		local tempServer = self._arGameServerList[i]
		if string.find(getUtf8(tempServer.szGameRoomName), serverName) then
			pServer = tempServer
			local tempFull = pServer.wMaxOnLineCount * 4 / 5 - pServer.wOnLineCount
			if(tempFull > 0) then
				break
			end			
		end
	end

	return pServer
end

function GamePlace:SetPartnerID(nPartnerID)
	self.m_nPartnerID = nPartnerID
end

function GamePlace:getFreeSpeakerLeft()
	return self.m_nFreeSpeakerLeft
end

function GamePlace:isMyFriend(nUserDBID)
	for i = 1,#self.m_friendList do	
		if(self.m_friendList[i].nUserID == nUserDBID) then
			return true
		end
	end
	return false
end

function GamePlace:getBankruptCount()
	return self.m_nBankruptCount
end

function GamePlace:getWebRoot()
	return self.m_szWebRoot
end

function GamePlace:isInReview()
	return self.m_bInReview
end

function GamePlace:isShowAD()
	return self.m_bIsShowAD
end
function GamePlace:isSnow()
	return self.m_bIsSnow
end

function GamePlace:SetActive()
	self.m_bActive = true
	local gamePlace = self
    local function onResignActive()
    	cclog("onResignActive %d",getTickCount())
    	self.m_bActive = false
    	if(self.TIMER_RESIGN_ACTIVE ~= nil) then
    		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.TIMER_RESIGN_ACTIVE)
        	self.TIMER_RESIGN_ACTIVE = nil
    	end
    end

    if(self.TIMER_RESIGN_ACTIVE ~= nil) then
    	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.TIMER_RESIGN_ACTIVE)
        self.TIMER_RESIGN_ACTIVE = nil
    end
    self.TIMER_RESIGN_ACTIVE = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(
    		onResignActive,self.TIME_RESIGN_ACTIVE,false)
end

function GamePlace:addGameStation(pStation)
	-- 先看是否存在
	local pExist = self:getGameStationByName(pStation.szStationName)
	if(pExist == nil) then	
		self._arStationList[#self._arStationList + 1] = pStation
		return pStation
	end
	-- 直接赋值
	pExist = pStation
	return pExist
end

function GamePlace:addGameServer(pGameServer)
	-- 先看是否存在
	local pExist = self:getGameServer(pGameServer.dwServerID)
	if(pExist == nil) then
		self._arGameServerList[#self._arGameServerList + 1] = pGameServer
		return pGameServer
	end
	-- 直接赋值
	pExist = pGameServer
	return pExist
end

require("GameLib/common/ChargeInfo")
require("GameLib/common/PropertyInfo")
require("GameLib/common/TaskInfo")
GamePlace.MIN_CHECK_NEW_ACTIVE 		= 3000
GamePlace.MIN_CHECK_NEW_DEACTIVE 	= 60000


GamePlace.WebOperationTypeEnum = 
{
	"REQUEST_SPEAKER", 
	"SEND_SPEAKER",
	-- 获取用户基本信息
	"GET_GAME_INFO",
	"--GET_FREE_SPEAKER",
	-- 任务
	"GET_TASK_LIST",		
	"TASK_GIFT",
	-- 破产保护
	"bankrupt_PROCTECT",
	"GET_VIP_LIST",
	-- 邮件相关
	"GET_MAIL_LIST",
	"READ_MAIL",
	"DELETE_MAIL",
	"SEND_MAIL",

	-- n状态通知
	"CHECK_NEW",
	-- 道具及元宝
-- 	"GET_YUANBAO",
-- 	"GET_FRAG",
 	"YUANBAO_BUY_GOLD",
	"BUY_PROPERTY",
	"SYSTEM_PROPERTIES",
	"GET_USER_PROPERTIES",
	"USE_PROPERTY",
	"GET_USER_PROPERTY_FLAG",
	-- lua转发
	"LUA_WEB_REQUEST",
	-- 好友相关
	"GET_FRIEND_LIST",
	"GET_FRIEND_APPLY_LIST",
	"APPLY_ADD_FRIEND",
	"AGREE_ADD_FRIEND",
	"DELETE_FRIEND",
	"GET_FRIEND_INFO",
	"GET_FRIEND_INFO_BY_NAME",
	"REFUSE_ADD_FRIEND",

	-- 保险柜
	"CHANGE_BANK_PASSWORD",
	"BANK_IN",
	"BANK_OUT",
	"GET_BANK_INFO",
-- 	"GET_PAY_AMOUNT",
	-- 获取默认类型
	"RECOMMEND_PLAYTYPE",
	"FINISH_TASK",
	"GET_CHARGE_INFO",
	-- 是否启用短代
-- 	"IS_USE_EPAY_SDK",
	-- 奖励相关
	"GET_MEMBER_INFO",
	"GET_CONTINUE_AWARD_INFO",
	-- 查询是否审核
	"IS_IN_REVIEW",
	-- 领取登陆奖励
	"GET_LOGIN_AWARD",
	"GET_VIP_UPGRADE_AWARD",
	"GET_GAME_TITLE_LIST",
}

GamePlace.WebOperationTypeEnum = CreatEnumTable(GamePlace.WebOperationTypeEnum)

function GamePlace:allInAction()
	if(self.m_bAllInAction) then
		return
	end
	self.m_bAllInAction = true;
	self:finishTask(110)
end

local WebRequest = require("GameLib/common/WebRequest")
local SAFEATOI = WebRequest.SAFEATOI
local SAFEATOI64 = WebRequest.SAFEATOI64
local SAFESTRING = WebRequest.SAFESTRING

function GamePlace:getData(callback,url,data,tag,post)
	if tag ~= GamePlace.WebOperationTypeEnum.CHECK_NEW and tag ~= GamePlace.WebOperationTypeEnum.REQUEST_SPEAKER then
		self:SetActive()
	end

	WebRequest.getData(callback,url,data,tag,post)
end

function GamePlace:getAddress(lpszPage)
	if string.find(lpszPage,"http://") then
		return lpszPage
	end
	return self.m_szWebRoot .. "/" .. lpszPage
end

function GamePlace:getPlatformAddress(lpszPage)
	if string.find(lpszPage,"http://") then
		return lpszPage
	end
	return self.m_szPlatFormRoot .. "/" .. lpszPage
end

function GamePlace.getRootAndResult(data)
	local xml = tinyxml:new()
	xml:LoadMemory(data)
	--cclog("xml new tag = " .. string.sub(data,1,100))
	local root = xml:FirstChildElement("root")
	if root == nil then 
		return nil,nil,nil
	end
	local result = root:FirstChildElement("result")
	local nResult = 11
	if(result ~= nil) then
		nResult = result:QueryInt("result")
	else
		if(root and root:QueryInt("result")) then
			nResult = root:QueryInt("result")
		end
	end
	return root,result,nResult
end

function GamePlace:getTaskList()
	local szData = string.format("UserID=%d&GameID=%d&version=21",self.m_publicUserInfo.UserID,self._dwGameID)	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:getTaskList() failed") return end
		--cclog(data)
		local root,result,nResult = GamePlace.getRootAndResult(data)
		--cclog("create task")
		local pTask = root and root:FirstChildElement("people") or nil	
		self.m_taskList = {}
		while pTask do		
			local p = TaskInfo:new()
			p.nTaskID = SAFEATOI(pTask:QueryInt("TaskID"))
			p.szTaskName = SAFESTRING(pTask:QueryString("TaskName"))
			p.szTaskDesc = SAFESTRING(pTask:QueryString("TaskDesc"))
			p.nTaskType = SAFEATOI(pTask:QueryInt("TaskType"))
			p.nToolNum = SAFEATOI(pTask:QueryInt("ToolNum"))
			p.nToolType = SAFEATOI(pTask:QueryInt("ToolTypeID"))
			p.nTaskStatus = SAFEATOI(pTask:QueryInt("TaskStatus"))
			p.nTaskSchedule = SAFEATOI(pTask:QueryInt("TaskSchedule"))
			p.nTaskTarget = SAFEATOI(pTask:QueryInt("TaskTarget"))
			pushTable(self.m_taskList,p)
			--cclog("taskName = %s,taskid = %d",p.szTaskName,p.nTaskID)
			pTask = pTask:NextSiblingElement()
		end
		self._sink:onTaskInfo(nResult,self.m_taskList)
	end

	self:getData(httpCallback,self:getAddress("GetTaskList.aspx"),szData,GamePlace.WebOperationTypeEnum.GET_TASK_LIST)
end

function GamePlace:getVipInfoList()	
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:getVipInfoList() failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		local pTask = root and root:FirstChildElement("VIPInfo") or nil
		self.m_vipList = {}
		self.m_vipListWakeng = {}
		while pTask do
			if(self._dwGameID == gamelibcommon.GAMEID_WAKENG) then
				local p = require("GameLib/common/VIPInfoWakeng"):new()
				p.nLevel = SAFEATOI(pTask:QueryInt("VIPLevel"))
				p.nNeedPayMoney = SAFEATOI(pTask:QueryInt("NeedPayMoney"))
				p.nIsBigTmp = SAFEATOI(pTask:QueryInt("IsBigTmp"))	
				p.nPaySendRatio = SAFEATOI(pTask:QueryInt("PaySendRatio"))
				p.szMemo = SAFESTRING(pTask:QueryString("Memo"))
				p.nHelpSendAmount = SAFEATOI(pTask:QueryInt("HelpSendAmount"))
				p.nSignSendAmount = SAFEATOI(pTask:QueryInt("SignSendAmount"))
				p.nWinCount = SAFEATOI(pTask:QueryInt("WinCount"))
				p.nPlayCount = SAFEATOI(pTask:QueryInt("PlayCount"))
				pushTable(self.m_vipListWakeng,p)
			else
				local p = require("GameLib/common/VIPInfo"):new()
				p.nLevel = SAFEATOI(pTask:QueryInt("VIPLevel"))
				p.nNeedPayMoney = SAFEATOI(pTask:QueryInt("NeedPayMoney"))
				p.nPaySendRatio = SAFEATOI(pTask:QueryInt("PaySendRatio"))
				p.nNameColor = SAFEATOI(pTask:QueryInt("ColorValue"))
				p.nFreeSpeaker = SAFEATOI(pTask:QueryInt("FreeSpeaks"))
				p.nFriendLimit = SAFEATOI(pTask:QueryInt("MaxFriendsCount"))
				p.nBankLimit = SAFEATOI64(pTask:QueryString("MaxBankCount"))
				p.nSendAmount = SAFEATOI(pTask:QueryInt("SendAmount"))
				p.szColorName = SAFESTRING(pTask:QueryString("ColorName"))
				p.szUpgradeTools = SAFESTRING(pTask:QueryString("UpgradeTools"))
				p.szLoginTools = SAFESTRING(pTask:QueryString("LoginTools"))
                p.szMemo = SAFESTRING(pTask:QueryString("Memo"))
                p.nPlayCount = SAFEATOI64(pTask:QueryInt("PlayCount"))
				p.nWinCount = SAFEATOI(pTask:QueryInt("WinCount"))
				pushTable(self.m_vipList,p)
				--cclog("vipinfo: level = " .. p.nLevel ..",ut = " .. p.szUpgradeTools .. ",lt = " .. p.szLoginTools)
			end
			pTask = pTask:NextSiblingElement()
		end
	end
	self:getData(httpCallback,self:getAddress("GetVIPList.aspx"),nil,GamePlace.WebOperationTypeEnum.GET_VIP_LIST)
end

function GamePlace:taskGift(nTaskID)
	local szData = string.format("UserID=%d&GameID=%d&TaskID=%d&EPassword=%s",
		self.m_publicUserInfo.UserID,self._dwGameID,nTaskID,self.m_publicUserInfo.EPassword)
	--cclog(string.format("taskGifg %s",szData))
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:taskGift() failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		local pTask = root and root:FirstChildElement("people") or nil
		local nTaskID = 0
		if(pTask ~= nil) then
			nTaskID = SAFEATOI(pTask:QueryInt("TaskID"))
		end		
		if(nResult == 1) then
			-- 刷新金币
			local task = self:getTask(nTaskID)
			if(task) then
				if(task.nToolType == 1) then
					self._userLogonInfo.dwGold = self._userLogonInfo.dwGold + task.nToolNum
					self:getGameLib():refreshGold()
				end
				if(task.nToolType == 2) then
					self._userLogonInfo.nFrag = self._userLogonInfo.nFrag + task.nToolNum
					local pMyself = self:getGameLib():getMyself()
					if(pMyself) then
						self._sink:onRoomUserInfoUpdated(pMyself:getUserID())
					end
				end
			end
			self:getTaskList()
		end
		self._sink:onTaskGift(nTaskID,nResult)
	end
	self:getData(httpCallback,self:getAddress("TaskGift.aspx"),szData,GamePlace.WebOperationTypeEnum.TASK_GIFT)
end

function GamePlace:getBankruptProtect()
	return
end

function GamePlace:getMailList()
	if(self.m_bCashedMailList) then
		self._sink:onMailList(1,self.m_mailList)
		return
	end
	local szData = string.format("UserID=%d&GameID=%d&pwd=%s",self.m_publicUserInfo.UserID,self._dwGameID,
		self.m_publicUserInfo.EPassword)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:getMailList() failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		nResult = 1
		local pTask = root and root:FirstChildElement("MailInfo") or nil
		--vector<MailInfo> maillist
		self.m_mailList = {}
		while pTask do
			local p = require("GameLib/common/MailInfo"):new()
			p.nMailID = SAFEATOI(pTask:QueryInt("UserMailID"))
			p.nFromUserID = SAFEATOI(pTask:QueryInt("FromUserID"))
			p.nUserID = SAFEATOI(pTask:QueryInt("UserID"))
			--strcpyn(p.szFromUserName,pTask->Attribute("FromUserName"),sizeof(p.szFromUserName))
			p.szRecvTime = SAFESTRING(pTask:QueryString("SendTime"))
			p.szContent = SAFESTRING(pTask:QueryString("Contnet"))
			p.cbRead = SAFEATOI(pTask:QueryInt("IsRead"))
			-- 自己的邮件，默认为已读
			if(p.nFromUserID == self.m_publicUserInfo.UserID) then
				p.cbRead = 1
			end
			-- 				readMail(p.nMailID)
			pushTable(self.m_mailList,p)
			pTask = pTask:NextSiblingElement()
		end
		
		self.m_bCashedMailList = true
		self._sink:onMailList(nResult,self.m_mailList)
	end
	self:getData(httpCallback,self:getAddress("GetMailList.aspx"),szData,GamePlace.WebOperationTypeEnum.GET_MAIL_LIST)

	cclog(" GamePlace::getMailList() ------ ")
end

function GamePlace:readMail(nUserMailID)
	for i = 1, #self.m_mailList do
		if(self.m_mailList[i].nMailID == nUserMailID) then
			self.m_mailList[i].cbRead = 1
		end
	end
	local szData = string.format("UserID=%d&UserMailID=%d",self.m_publicUserInfo.UserID,nUserMailID)
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:readMail() failed") return end
	end
	self:getData(httpCallback,self:getAddress("ReadMail.aspx"),szData,GamePlace.WebOperationTypeEnum.READ_MAIL)
end

function GamePlace:deleteMail(nUserMailID)
	for i = 1,#self.m_mailList do	
		if(self.m_mailList[i].nMailID == nUserMailID) then			
			table.remove(self.m_mailList,i)
			break
		end
	end
	local szData = string.format("UserID=%d&UserMailID=%d",self.m_publicUserInfo.UserID,nUserMailID)
	cclog("deleteMail %s",szData)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:deleteMail() failed") return end
	end
	self:getData(httpCallback,self:getAddress("DeleteMail.aspx"),szData,GamePlace.WebOperationTypeEnum.DELETE_MAIL)
end

function GamePlace:deleteMails(szMails)
	if(szMails == nil or string.len(szMails) == 0) then return end
	while true do
		local found = false
		for i = 1,#self.m_mailList do
			local szMailID = string.format("%d",self.m_mailList[i].nMailID)
			if(string.find(szMails,szMailID) ~= nil) then
				table.remove(self.m_mailList,i)
				found = true
				break
			end
		end
		if not found then break end
	end	

	local szData = string.format("UserID=%d&UserMailID=%s",self.m_publicUserInfo.UserID,szMails)
	cclog("deleteMails %s",szData)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:deleteMails(...) failed") return end
	end
	self:getData(httpCallback,self:getAddress("DeleteMail.aspx"),szData,GamePlace.WebOperationTypeEnum.DELETE_MAIL)
end

function GamePlace:sendMail(nToUserID,szContent)
	local szData = string.format("UserID=%d&ToUserID=%d&Content=%s&GameID=%d",self.m_publicUserInfo.UserID,nToUserID,
		szContent,self._dwGameID)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:sendMail(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		self.m_bCashedMailList = false
		self:getMailList()
		self._sink:onSendMailRet(nResult)
	end
	self:getData(httpCallback,self:getAddress("SendMail.aspx"),szData,GamePlace.WebOperationTypeEnum.SEND_MAIL)
end

function GamePlace:checkNewStatus()

	local dwLast = getTickCount() - self.m_dwLastCheckNewTime

	if(dwLast < (self.m_bActive and GamePlace.MIN_CHECK_NEW_ACTIVE or GamePlace.MIN_CHECK_NEW_DEACTIVE)) then
		return
	end
	--cclog("checkNewStatus() %d,active = %d",getTickCount(),self.m_bActive and 1 or 0)
	self:requestServerList()		
	
	local szData = string.format("UserID=%d&GameID=%d&Pay=%d",self.m_publicUserInfo.UserID,self._dwGameID,math.max(self.m_nPayAmount,0))
	
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:checkNewStatus(...) failed") return end
		--local root,result,nResult = GamePlace.getRootAndResult(data)
		--[[local root = txml.getRoot(data)
		if(root == nil) then
			return
		end
		
		local nNewMissionDone = SAFEATOI(root.xarg["NewMissionDone"])
		local nNewMail = SAFEATOI(root.xarg["NewMail"])
		local nNewActivity = SAFEATOI(root.xarg["NewActivity"])
		local nNewFriend = SAFEATOI(root.xarg["NewFriend"])
		local nNewPayment = SAFEATOI(root.xarg["NewPayment"])

		if(nNewMissionDone + nNewActivity + nNewFriend + nNewMail > 0 or self._userLogonInfo.bIsLoginGift == 0) then
			self._sink:onNewStatus(nNewMissionDone,nNewMail,nNewActivity,nNewFriend,self._userLogonInfo.bIsLoginGift == 0)
		end
		if(nNewMail > 0) then
			self.m_bCashedMailList = false
		end
		-- 挖坑
		local nPay = SAFEATOI(root.xarg["PayRankTip"])
		local nPlay = SAFEATOI(root.xarg["PlayRankTip"])
		local nWinAmount = SAFEATOI(root.xarg["WinAmountRankTip"])
		local nWinCount = SAFEATOI(root.xarg["WinCountRankTip"])
		local nGuess = SAFEATOI(root.xarg["FragWinRankTip"])
		local nServiceTip = SAFEATOI(root.xarg["ServiceMessageTip"])
		--if(nGuess + nPlay + nWinCount + nWinAmount + nPay + nServiceTip > 0) then
			self._sink:onRankTip(nPay,nPlay,nWinAmount,nWinCount,nGuess,nServiceTip)
		--end]]
	end
	--if self._dwGameID ~= 25 then 
		self:getData(httpCallback,self:getAddress("CheckNewStatus.aspx"),szData,GamePlace.WebOperationTypeEnum.CHECK_NEW)
	--end

	self:getSpeaker()

	self.m_dwLastCheckNewTime = getTickCount()
end

function GamePlace:sendSpeaker(lpszContent)
	local szData = string.format("UserID=%d&Msg=%s:%s&EPassword=%s&GameID=%d",
		self.m_publicUserInfo.UserID,
		self.m_publicUserInfo.NewNickName,
		lpszContent,
		self.m_publicUserInfo.EPassword,
		self._dwGameID)
		-- cclog(szData)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:sendSpeaker(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		cclog("sendSpeaker")
		if(nResult == 1) then
			self:getGameLib():refreshGold()
		end
		
		self.m_nFreeSpeakerLeft = result and SAFEATOI(result:QueryInt("FreeCountLeft")) or 0
		self._sink:onSendSpeakerRet(nResult)
		cclog("sendSpeaker finished")
	end
	self:getData(httpCallback,self:getAddress("SendBroadcast.aspx"),szData,GamePlace.WebOperationTypeEnum.SEND_SPEAKER)
	return true
end

function GamePlace:getSpeaker()
	local szData = string.format("BroadcastID=%d&GameID=%d",self.m_nBroadcastID,self._dwGameID)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:getSpeaker(...) failed") return end
		--local root,result,nResult = GamePlace.getRootAndResult(data)		
		--[[local root = txml.getRoot(data)
		local index,pMsg = txml.FirstChildElement(root,"people")
		while pMsg do
			self._sink:onSpeaker(pMsg["Msg"],SAFEATOI(pMsg["Priority"]))
			self.m_nBroadcastID = SAFEATOI(pMsg["BroadcastID"])
			cclog("GamePlace:getSpeaerk %s,%d,%d",pMsg["Msg"],SAFEATOI(pMsg["Priority"]),self.m_nBroadcastID)
			index,pMsg = txml.NextChildElement(index,root,"people")
		end]]
	end
	self:getData(httpCallback,self:getAddress("GetBroadcastList.aspx"),szData,GamePlace.WebOperationTypeEnum.REQUEST_SPEAKER)
end

function GamePlace:yuanbaoBuyGold(nYuanbao)		
	local szData = string.format("UserID=%d&Diamond=%d&GoldMoney=%d",self.m_publicUserInfo.UserID,nYuanbao,nYuanbao * self.m_nMoneyExchangeRatio)
	--cclog("request speaker %s",szData)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:yuanbaoBuyGold(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		local nGold = SAFEATOI(root:QueryInt("NewGoldMoney"))
		local nYb = SAFEATOI(root:QueryInt("NewDiamond"))
		self.m_publicUserInfo.nDiamond = nYb
		self._userLogonInfo.dwGold = nGold
		require("Lobby/Login/LoginLogic").UserInfo.Money = self._userLogonInfo.dwGold
		self._sink:onYuanbaoBuyGoldRet(nResult,nGold,nYb)
	end
	self:getData(httpCallback,self:getAddress("DiamondToGoldMoney.aspx"),szData,GamePlace.WebOperationTypeEnum.YUANBAO_BUY_GOLD)
end

function GamePlace:BuyProperty(nPropertyID)	
	local szData = string.format("UserID=%d&GameID=%d&ToolID=%d",self.m_publicUserInfo.UserID,self._dwGameID,nPropertyID)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:BuyProperty(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		self._sink:onBuyPropertyRet(nResult,SAFEATOI(root:QueryInt("PropertyID")))
	end
	self:getData(httpCallback,self:getAddress("BuyTools.aspx"),szData,GamePlace.WebOperationTypeEnum.BUY_PROPERTY)
end

function GamePlace:getPropertyInfoList()
	local szData = string.format("GameID=%d",self._dwGameID)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:getPropertyInfoList(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		local pTask = root and root:FirstChildElement("property") or nil
		self.m_propertyList = {}
		while pTask do
			local p = PropertyInfo:new()
			p.nPropertyID = SAFEATOI(pTask:QueryInt("id"))
			p.nGroup = SAFEATOI(pTask:QueryInt("group"))
			p.nPrice = SAFEATOI(pTask:QueryInt("price"))
			p.szName = SAFESTRING(pTask:QueryString("name"))
			p.szDesc = SAFESTRING(pTask:QueryString("desc"))
			pushTable(self.m_propertyList,p)
			pTask = pTask:NextSiblingElement()
			--cclog("next=%d",pTask)
		end
	end
	self:getData(httpCallback,self:getAddress("GetSysToolsList.aspx"),szData,GamePlace.WebOperationTypeEnum.SYSTEM_PROPERTIES)
end

function GamePlace:getUserProperties()
	local szData = string.format("UserID=%d&GameID=%d",self.m_publicUserInfo.UserID,self._dwGameID)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:getUserProperties(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		nResult = 1;
		local pTask = root and root:FirstChildElement("property") or nil
		local userProperties = {}
		while pTask do
			local p = UserProperty:new()
			p.nPropertyID = SAFEATOI(pTask:QueryInt("id"))
			p.nFlag = SAFEATOI(pTask:QueryInt("Flag"))
			pushTable(userProperties,p)
			pTask = pTask:NextSiblingElement()
		end
		self._sink:onGetUserPropertiesRet(userProperties)
	end
	self:getData(httpCallback,self:getAddress("GetUserToolsList.aspx"),szData,GamePlace.WebOperationTypeEnum.GET_USER_PROPERTIES)
end

function GamePlace:useProperty(nPropertyID,nCount,nToUserID)
	local szData = string.format("UserID=%d&PropertyID=%d",self.m_publicUserInfo.UserID,nPropertyID)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:useProperty(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		self._sink:onUsePropertyRet(nResult,
			SAFEATOI(root:QueryInt("PropertyID")),
			SAFEATOI(root:QueryInt("count")),
			SAFEATOI(root:QureyInt("param")))
	end
	self:getData(httpCallback,self:getAddress("UseProperty.aspx"),szData,GamePlace.WebOperationTypeEnum.USE_PROPERTY)
	return true
end

function GamePlace:getProperty(nPropertyID)
	for i = 1,#self.m_propertyList do		
		rProperty = self.m_propertyList[i]
		if(rProperty.nPropertyID == nPropertyID) then
			return rProperty
		end
	end
	return nil
end

function GamePlace:getTask(nTaskID)
	for i = 1, #self.m_taskList do
		rTask = self.m_taskList[i]        
		if(rTask.nTaskID == nTaskID) then
			return rTask
		end		
	end
	return nil
end

function GamePlace:getUserPropertyFlag(nToUserID)
	local szData = string.format("UserID=%d&GameID=%d",nToUserID,self._dwGameID)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:getUserPropertyFlag(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		if  not root then return end	
		local nToUserID = SAFEATOI(root:QueryInt("UserID"))
		local vList = {}
		local pTask = root and root:FirstChildElement("property") or nil
		while pTask do
			pushTable(vList,SAFEATOI(pTask:QueryInt("id")))
			pTask = pTask:NextSiblingElement()
		end
		self._sink:onGetUserPropertyFlagRet(nToUserID,vList)
	end
	self:getData(httpCallback,self:getAddress("GetUserProperty.aspx"),szData,GamePlace.WebOperationTypeEnum.GET_USER_PROPERTY_FLAG)
end


function GamePlace:getFriendList()
	local szData = string.format("UserID=%d&GameID=%d&pwd=%s",self.m_publicUserInfo.UserID,self._dwGameID,
		self.m_publicUserInfo.EPassword)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:getFriendList(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		local pTask = root and root:FirstChildElement("user") or nil
		self.m_friendList = {}
		while pTask do			
			local p = require("GameLib/common/FriendInfo"):new()
			p.nUserID = SAFEATOI(pTask:QueryInt("userid"))
			p.nFaceID = SAFEATOI(pTask:QueryInt("faceid"))
			p.nGold = SAFEATOI(pTask:QueryInt("gold"))
			p.nVipLevel = SAFEATOI(pTask:QueryInt("viplevel"))
			p.cbFaceChangeIndex = SAFEATOI(pTask:QueryInt("Changed"))
			p.bMale = SAFEATOI(pTask:QueryInt("Sex")) == 1
			p.szNickName = SAFESTRING(pTask:QueryString("nickname"))
			p.szRoomName = SAFESTRING(pTask:QueryString("roomname"))
			p.nWinRate = SAFEATOI(pTask:QueryInt("WinRate"))
			p.szUserWord = SAFESTRING(pTask:QueryString("UserWord"))
			p.nTotalCount = SAFEATOI(pTask:QueryInt("TotalCount"))
			p.nExps = SAFEATOI(pTask:QueryInt("Exps"))
			p.nGrade = SAFEATOI(pTask:QueryInt("nGrade"))
			pushTable(self.m_friendList,p)
			pTask = pTask:NextSiblingElement()
		end
		self._sink:onFriendList(self.m_friendList)
	end
	self:getData(httpCallback,self:getPlatformAddress("GetFriendsList.aspx"),szData,GamePlace.WebOperationTypeEnum.GET_FRIEND_LIST)
end

function GamePlace:getFriendApplyList()
	local szData = string.format("UserID=%d&GameID=%d",self.m_publicUserInfo.UserID,self._dwGameID)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:getFriendApplyList(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		local pTask = root and root:FirstChildElement("user") or nil
		local userProperties = {}
		while pTask do			
			local p = require("GameLib/common/FriendInfo"):new()
			p.nUserID = SAFEATOI(pTask:QueryInt("userid"))
			p.nFaceID = SAFEATOI(pTask:QueryInt("faceid"))
			p.nGold = SAFEATOI(pTask:QueryInt("gold"))
			p.nVipLevel = SAFEATOI(pTask:QueryInt("viplevel"))
			p.cbFaceChangeIndex = SAFEATOI(pTask:QueryInt("Changed"))
			p.bMale = SAFEATOI(pTask:QueryInt("Sex")) == 1
			p.szNickName = SAFESTRING(pTask:QueryString("nickname"))
			p.szRoomName = SAFESTRING(pTask:QueryString("roomname"))
			p.nWinRate = SAFEATOI(pTask:QueryInt("WinRate"))
			p.szUserWord = SAFESTRING(pTask:QueryString("UserWord"))
			p.szApplyTime = SAFESTRING(pTask:QueryString("applytime"))
			p.nTotalCount = SAFEATOI(pTask:QueryInt("TotalCount"))
			p.nExps = SAFEATOI(pTask:QueryInt("Exps"))
			p.nGrade = SAFEATOI(pTask:QueryInt("nGrade"))
			pushTable(userProperties,p)
			pTask = pTask:NextSiblingElement()
		end
		self._sink:onFriendApplyList(userProperties)
	end
	self:getData(httpCallback,self:getPlatformAddress("GetFriendApplyList.aspx"),szData,GamePlace.WebOperationTypeEnum.GET_FRIEND_APPLY_LIST)
end


function GamePlace:ApplyAddFriend(nToUserID)
	local szData = string.format("UserID=%d&GameID=%d&toUserID=%d",self.m_publicUserInfo.UserID,self._dwGameID,nToUserID)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:ApplyAddFriend(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		self._sink:onApplyFriend(nResult)
		if(nResult == 1) then
			self:getFriendApplyList()
			self:getFriendList()
		end
	end
	self:getData(httpCallback,self:getPlatformAddress("FriendApply.aspx"),szData,GamePlace.WebOperationTypeEnum.APPLY_ADD_FRIEND)
end

function GamePlace:DeleteFriend(nToUserID)
	local szData = string.format("UserID=%d&GameID=%d&toUserID=%d",self.m_publicUserInfo.UserID,self._dwGameID,nToUserID)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:DeleteFriend(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		if(nResult == 1) then
			self:getFriendList()
		end
	end
	self:getData(httpCallback,self:getPlatformAddress("FriendDelete.aspx"),szData,GamePlace.WebOperationTypeEnum.DELETE_FRIEND)
end

function GamePlace:AgreeAddFriend(nToUserID)
	local szData = string.format("UserID=%d&GameID=%d&toUserID=%d",self.m_publicUserInfo.UserID,self._dwGameID,nToUserID)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:AgreeAddFriend(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		if(nResult == 1) then
			self:getFriendList()
		end
	end
	self:getData(httpCallback,self:getPlatformAddress("FriendAgree.aspx"),szData,GamePlace.WebOperationTypeEnum.AGREE_ADD_FRIEND)
end

function GamePlace:refuseAddFriend(nToUserID)
	local szData = string.format("UserID=%d&GameID=%d&toUserID=%d",self.m_publicUserInfo.UserID,self._dwGameID,nToUserID)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:refuseAddFriend(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		if(nResult == 1) then
			self:getFriendApplyList()
		end
	end
	self:getData(httpCallback,self:getPlatformAddress("FriendRefuse.aspx"),szData,GamePlace.WebOperationTypeEnum.REFUSE_ADD_FRIEND)
end

function GamePlace:getFriendInfo(nToUserID,handle)
	local szData = string.format("UserID=%d&GameID=%d",nToUserID,self._dwGameID)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then 
			cclog("GamePlace:getFriendInfo(...) failed") 
			if handle then handle(nil) end
			return 
		end		
		local root,result,nResult = GamePlace.getRootAndResult(data)
		local pTask = root and root:FirstChildElement("user") or nil
		local p  = require("GameLib/common/FriendInfo"):new()
		if pTask then
			p.nUserID = SAFEATOI(pTask:QueryInt("userid"))
			p.nFaceID = SAFEATOI(pTask:QueryInt("faceid"))
			p.nGold = SAFEATOI(pTask:QueryInt("Gold"))
			p.nVipLevel = SAFEATOI(pTask:QueryInt("viplevel"))
			p.bMale = SAFEATOI(pTask:QueryInt("Sex")) == 1
			p.cbFaceChangeIndex = SAFEATOI(pTask:QueryInt("Changed"))
			p.szNickName = SAFESTRING(pTask:QueryString("nickname"))
			p.szRoomName = SAFESTRING(pTask:QueryString("roomname"))
			p.nWinRate = SAFEATOI(pTask:QueryInt("WinRate"))
			p.szUserWord = SAFESTRING(pTask:QueryString("UserWord"))
			p.nWeekWinAmount = SAFEATOI(pTask:QueryInt("weekWinAmount"))
			p.nMaxWinAmount = SAFEATOI(pTask:QueryInt("maxWinAmount"))
			p.nGuess = SAFEATOI(pTask:QueryInt("guess"))
			p.nTotalCount = SAFEATOI(pTask:QueryInt("TotalCount"))			
			p.nExps = SAFEATOI(pTask:QueryInt("Exps"))
			p.nGrade = SAFEATOI(pTask:QueryInt("nGrade"))
		end
		self._sink:onFriendInfo(p)
		if handle then handle(p) end
	end
	self:getData(httpCallback,self:getAddress("GetApplyFriendUserInfo.aspx"),szData,GamePlace.WebOperationTypeEnum.GET_FRIEND_INFO)
end

function GamePlace:getFriendInfoByName(szName,handle)
	if(not szName) then return end
	if(string.len(szName) < 1) then return end
	local szData = string.format("NickName=%s",szName)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:getFriendInfoByName(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		local pTask = root and root:FirstChildElement("user") or nil
		local userProperties = {}
		while pTask do
			local p = require("GameLib/common/FriendInfo"):new()
			p.nUserID = SAFEATOI(pTask:QueryInt("userid"))
			p.nFaceID = SAFEATOI(pTask:QueryInt("faceid"))
			p.nGold = SAFEATOI(pTask:QueryInt("gold"))
			p.nVipLevel = SAFEATOI(pTask:QueryInt("viplevel"))
			p.cbFaceChangeIndex = SAFEATOI(pTask:QueryInt("Changed"))
			p.bMale = SAFEATOI(pTask:QueryInt("Sex")) == 1
			p.szNickName = SAFESTRING(pTask:QueryString("nickname"))
			p.szRoomName = SAFESTRING(pTask:QueryString("roomname"))
			p.nWinRate = SAFEATOI(pTask:QueryInt("WinRate"))
			p.szUserWord = SAFESTRING(pTask:QueryString("UserWord"))
			p.nTotalCount = SAFEATOI(pTask:QueryInt("TotalCount"))
			p.nExps = SAFEATOI(pTask:QueryInt("Exps"))
			p.nGrade = SAFEATOI(pTask:QueryInt("nGrade"))
			pushTable(userProperties,p)
			pTask = pTask:NextSiblingElement()
		end
		self._sink:onGetFriendInfoByNameRet(userProperties)
		if handle then handle(userProperties) end
	end
	self:getData(httpCallback,self:getAddress("GetApplyFriendByName.aspx"),szData,GamePlace.WebOperationTypeEnum.GET_FRIEND_INFO_BY_NAME)
end

function GamePlace:getBankInfo()
	local szData = string.format("UserID=%d&GameID=%d&psw=%s",
		self.m_publicUserInfo.UserID,self._dwGameID,self.m_publicUserInfo.EPassword)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:getBankInfo(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		if root == nil then return end
		local nBankAmount =SAFEATOI(root:QueryString("BankAmount"))
		self._userLogonInfo.lBankAmount = nBankAmount
		local info = self:getVIPInfo(self._userLogonInfo.nVIPLevel,info)
		self._sink:onBankInfo(nBankAmount,info and info.nBankLimit or 0)
	end
	self:getData(httpCallback,self:getPlatformAddress("GetBankInfo.aspx"),szData,GamePlace.WebOperationTypeEnum.GET_BANK_INFO)
end

-- 修改密码
function GamePlace:changeBankPassword(lpszOldPassword,lpszNewPassword)	
	local szData = string.format("UserID=%d&GameID=%d&OldPass=%s&NewPass=%s&psw=%s",
		self.m_publicUserInfo.UserID,self._dwGameID,lpszOldPassword,lpszNewPassword,self.m_publicUserInfo.EPassword)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:changeBankPassword(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		self._sink:onChangeBankPasswordRet(nResult)
	end
	self:getData(httpCallback,self:getPlatformAddress("ChangeBankPassword.aspx"),szData,GamePlace.WebOperationTypeEnum.CHANGE_BANK_PASSWORD)
end
-- 存
function GamePlace:bankIn(nGold)
	local szData = string.format("UserID=%d&GameID=%d&gold=%d&psw=%s",
		self.m_publicUserInfo.UserID,self._dwGameID,nGold,self.m_publicUserInfo.EPassword)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:bankIn(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		if root == nil then return end
		local nGold = SAFEATOI(root:QueryInt("gold"))
		local nBankAmount = SAFEATOI(root:QueryString("bank")) 
		if nResult == 1 then		
			self._userLogonInfo.dwGold = nGold
			require("Lobby/Login/LoginLogic").UserInfo.Money = self._userLogonInfo.dwGold
			self._userLogonInfo.lBankAmount = nBankAmount	
		end	
		self._sink:onBankInRet(nResult,self._userLogonInfo.dwGold,self._userLogonInfo.lBankAmount)
	end
	self:getData(httpCallback,self:getPlatformAddress("BankIn.aspx"),szData,GamePlace.WebOperationTypeEnum.BANK_IN)
end

-- 取
function GamePlace:bankOut(nGold,lpszPassword)
	local szData = string.format("UserID=%d&GameID=%d&gold=%d&BankPass=%s&psw=%s",
		self.m_publicUserInfo.UserID,self._dwGameID,nGold,lpszPassword,self.m_publicUserInfo.EPassword)	
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:bankOut(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		if root == nil then return end
		if(nResult == 1) then		
			local nGold = SAFEATOI(root:QueryInt("gold"))
			local nBankAmount = SAFEATOI(root:QueryString("bank"))
			self._userLogonInfo.dwGold = nGold
			require("Lobby/Login/LoginLogic").UserInfo.Money = self._userLogonInfo.dwGold
			self._userLogonInfo.lBankAmount = nBankAmount
		end
		self._sink:onBankOutRet(nResult,self._userLogonInfo.dwGold,self._userLogonInfo.lBankAmount)
	end
	self:getData(httpCallback,self:getPlatformAddress("BankOut.aspx"),szData,GamePlace.WebOperationTypeEnum.BANK_OUT)
end

function GamePlace:getWebRecommendPlayType()
	local szData = string.format("GameID=%d",self._dwGameID)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:getWebRecommendPlayType(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		self.m_nRecommendType = SAFEATOI(root:QueryInt("PlayType"))
		if(self.m_nRecommendType == 0) then
			self.m_nRecommendType = 3
		end
		self.m_bIsShowAD = SAFEATOI(root:QueryInt("AdStatus"))
		self.m_bIsSnow = SAFEATOI(root:QueryInt("IsSnow"))
	end
	self:getData(httpCallback,self:getAddress("GetRecommendPlayType.aspx"),szData,GamePlace.WebOperationTypeEnum.RECOMMEND_PLAYTYPE)
end

function GamePlace:getUserGameInfo()
	self.m_nFreeSpeakerLeft = 0	
	local szData = string.format("UserID=%d",self.m_publicUserInfo.UserID)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		if root == nil then return end
		local pNode = root:FirstChildElement("StillFreeSpeaks")
		if pNode then
			self.m_nFreeSpeakerLeft = SAFEATOI(pNode:QueryInt("param"))
		end
		pNode = root:FirstChildElement("FragNum")
		if pNode then
			self._userLogonInfo.nFrag = SAFEATOI(pNode:QueryInt("param"))
		end
		pNode = root:FirstChildElement("PayMoney")
		if pNode then
			self.m_nPayAmount = SAFEATOI(pNode:QueryInt("param"))
		end
		
		pNode = root:FirstChildElement("BankruptCount")
		if pNode then
			self.m_nBankruptCount = SAFEATOI(pNode:QueryInt("param"))
		end
		pNode = root:FirstChildElement("BankAmount")
		if pNode then
			self._userLogonInfo.lBankAmount = tonumber(SAFESTRING(pNode:QueryString("param")))
			cclog("self._userLogonInfo.lBankAmount = " .. self._userLogonInfo.lBankAmount)
		end
		pNode = root:FirstChildElement("Amount")
		if pNode then
			self._userLogonInfo.dwGold = SAFEATOI(pNode:QueryInt("param"))
			self.m_gameLib:getPublicUserInfo().nGold = self._userLogonInfo.dwGold			
			self._sink:onPlazaGoldChanged()
		end
		pNode = root:FirstChildElement("WeekFlag")
		if pNode then
			if(SAFEATOI(pNode:QueryInt("param")) > 0) then
				self._sink:onWakengAward(GamePlace.WAKENG_AWARD_WEEK)
			end
		end
		pNode = root:FirstChildElement("MonthFlag")
		if pNode then
			if(SAFEATOI(pNode:QueryInt("param")) > 0) then
				self._sink:onWakengAward(GamePlace.WAKENG_AWARD_MONTH)
			end
		end
		pNode = root:FirstChildElement("ContinueFlag")
		if pNode then
			if(SAFEATOI(pNode:QueryInt("param")) > 0) then
				--self._sink:onWakengAward(GamePlace.WAKENG_AWARD_CONTINUE)
			end
		end
		pNode = root:FirstChildElement("IsLoginGift")
		if pNode then
			self._userLogonInfo.bIsLoginGift = SAFEATOI(pNode:QueryInt("param"))
		end
		pNode = root:FirstChildElement("GiftVIPLevel")
		if pNode then
			self._userLogonInfo.nGiftVIPLevel = SAFEATOI(pNode:QueryInt("param"))
		end
		pNode = root:FirstChildElement("Diamond")
		if pNode then
			self.m_publicUserInfo.nDiamond = SAFEATOI(pNode:QueryInt("param"))
		end
		pNode = root:FirstChildElement("VIPLevel")
		if pNode then
			local nOldLevel = self._userLogonInfo.nVIPLevel
			self._userLogonInfo.nVIPLevel = SAFEATOI(pNode:QueryInt("param"))
			if(nOldLevel ~= self._userLogonInfo.nVIPLevel) then
				self._sink:onVIPLevelChanged(nOldLevel,self._userLogonInfo.nVIPLevel)
			end
		end
		self._sink:onRefreshUserInfo()
	end
	self:getData(httpCallback,self:getAddress("GetGameUserInfo.aspx"),szData,GamePlace.WebOperationTypeEnum.GET_GAME_INFO)
end

function GamePlace:httpRequest(szFileName,szData,szTag,callback,bPlatform)
    local address = bPlatform and self:getPlatformAddress(szFileName) or self:getAddress(szFileName)
    cclog("GamePlace:httpRequest %s",address)
	self:getData(callback,
		address,
		szData,szTag)
	-- 有网络交互，触发一次刷新
	self:SetActive()
end

function GamePlace:finishTask(nTaskID)
	local szData = string.format("TaskID=%d&UserID=%d",nTaskID,self.m_publicUserInfo.UserID)
	
	local function httpCallback(isSucceed,tag,data)
	end
	self:getData(httpCallback,self:getAddress("UpdateTask.aspx"),szData,GamePlace.WebOperationTypeEnum.FINISH_TASK)
end

function GamePlace:getContinueAwardInfo()
	local szData = string.format("UserID=%d",self.m_publicUserInfo.UserID)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:getContinueAwardInfo(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		if root == nil then return end
		local pTask = root and root:FirstChildElement("ChargeInfo") or nil
		local info = {}
		local nCurrentTime = SAFEATOI(root:QueryInt("ContinueTimes"))
		local nContinueFlag = SAFEATOI(root:QueryInt("ContinueFlag"))
		while pTask do
			local p = ContinueAwardInfo:new()
			p.nAwardAmount = SAFEATOI(pTask:QueryInt("AwardMoney"))
			p.nContinueTime = SAFEATOI(pTask:QueryInt("ContinueTimes"))
			pushTable(info,p)
			if(p.nContinueTime == nCurrentTime and nContinueFlag == 1) then
			-- 更新金币
				self._userLogonInfo.dwGold = self._userLogonInfo.dwGold + p.nAwardAmount
				self.m_gameLib:getPublicUserInfo().nGold = self._userLogonInfo.dwGold
				self:getGameLib():refreshGold()
			end
            pTask = pTask:NextSiblingElement()
		end
		self._sink:onGetContinueAwardInfoRet(nCurrentTime,nContinueFlag,info)
	end	
	
	self:getData(httpCallback,self:getAddress("GetContinueAwardList.aspx"),szData,GamePlace.WebOperationTypeEnum.GET_CONTINUE_AWARD_INFO)
end



function GamePlace:getLoginAward()
	local szData = string.format("UserID=%d",self.m_publicUserInfo.UserID)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:getLoginAward(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		if root == nil then return end
		self._sink:onLoginAwardRet(SAFEATOI(root:QueryInt("result")))
	end
	self:getData(httpCallback,self:getAddress("LoginAward.aspx"),szData,GamePlace.WebOperationTypeEnum.GET_LOGIN_AWARD)
end

function GamePlace:getVIPUpgradeAward()
	local szData = string.format("UserID=%d",self.m_publicUserInfo.UserID)
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:getVIPUpgradeAward(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		if root == nil then return end
		self._sink:onGetVipUpgradeAwardRet(SAFEATOI(root:QueryInt("result")))
	end
	self:getData(httpCallback,self:getAddress("UpgradeAward.aspx"),szData,GamePlace.WebOperationTypeEnum.GET_VIP_UPGRADE_AWARD)
end

function GamePlace:getGameTitleInfoList()
	return self.m_gameTitleList
end

function GamePlace:getGameTitleList()
	cclog("GamePlace:getGameTitleList()")
	
	local function httpCallback(isSucceed,tag,data)
		if(not isSucceed) then cclog("GamePlace:getGameTitleList(...) failed") return end
		local root,result,nResult = GamePlace.getRootAndResult(data)
		--cclog("create game title %s",data)
		if root == nil then return end
		self.m_gameTitleList = {}
		local pTask = root and root:FirstChildElement("GradeInfo") or nil
		while pTask do
			local p = require("GameLib/common/GameTitleInfo"):new()
			p.nLevel = SAFEATOI(pTask:QueryInt("Grade"))
			p.nImageID = SAFEATOI(pTask:QueryInt("ImageID"))
			p.nNeedExp = SAFEATOI(pTask:QueryInt("NeedExps"))
			p.szTitle = SAFESTRING(pTask:QueryString("GradeName"))
			pushTable(self.m_gameTitleList,p)
			pTask = pTask:NextSiblingElement()
		end		
	end
	self:getData(httpCallback,self:getAddress("GetGradeList.aspx"),nil,GamePlace.WebOperationTypeEnum.GET_GAME_TITLE_LIST)
end

function GamePlace:getServerByIPAndPort(ipaddress,port)
	for i=1,#self._arGameServerList do		
		if changeIP(self._arGameServerList[i].dwServerIP) == ipaddress
			and self._arGameServerList[i].uServerPort == port then
			return self._arGameServerList[i]
		end
	end
	return nil
end

return GamePlace