require("CocosAudioEngine")
require("FFSelftools/AMap")
require("GameLib/common/common")
require("GameLib/common/PlazaInfo")
require("GameLib/gamelib/room/GameCmds")
local AppConfig = require("AppConfig")

NETWORK_PING_INTERVAL   = 3000 -- 心跳包间隔
NETWORK_TIMEOUT         = 8000 -- 断线判定时间
NETWORK_RETRY_COUNT     = 5 -- 网络重试次数
NETWORK_RETRY_INTERVAL  = 2 -- 网络重试时间间隔

NETWORK_STATUS_UNCONNECTED  = 0  -- 未连接
NETWORK_STATUS_CONNECTED    = 1  -- 已连接(正常服务)
NETWORK_STATUS_CLOSE        = 3  -- 主动关闭
NETWORK_STATUS_RETRY        = 4  -- 重连中

local GameRoom = { }
GameRoom.__index = GameRoom

local Table = require("GameLib/gamelib/Table")

-- 创建GameRoom对象
function GameRoom:new(pGameLib)
    NETWORK_BACKTOFOREGROUND = false
	local self = {
		-- 变量
		m_socket = nil,
		m_sink,
		m_dwUserID = 0xFFFFFFFF,
		m_szPass = "",
		m_gameVersion,
		m_userManager,
		m_scoreParser,
		m_tableManager,
		m_clientFrame,
		m_mySelf = nil,
		m_wLastFindTable = 0xFFFF,
		m_loteryPool = 0,
		m_clientFrameSink = nil,
		m_cbShake = false,
		m_pGameLib = pGameLib,
		m_bIsPrivateRoom = false,
		m_szPrivateTablePassword = "",
		m_cbEnterType = 0,
		m_dwLastSendTableChat = 0,
		m_cbLastChairID = 0xFF,
		m_pGameServer = nil,
        -- 心跳及重连相关参数
        m_netStatus = 0,            -- 当前room网络状态
		m_dwLastReqTime = 0,        -- 最后发送请求时间
		m_dwLastRespTime = 0,       -- 最后收到响应时间
        m_dwRetryTimes = 0,         -- 重试次数
		m_nNetLag = 0,              -- Lag
        -- 坐标上传标示
        m_logonSuccess = false,
		m_coordinated = false,
	}
	setmetatable(self,GameRoom)
	self.m_scoreParser = require("GameLib/common/ScoreParser"):instance()
	self.m_clientFrame = require("GameLib/gamelib/frame/ClientFrame"):new(self,pGameLib)
	self.m_userManager = require("GameLib/gamelib/room/UserManager"):new()

	return self
end

-- GameRoom轮询
function GameRoom:pulse()
	if(self.m_socket == nil) then
		return
	end
    
    -- 检测上传坐标(未上传过且登陆成功)
    local coord = AMap:get()
    -- coord = {latitude = math.random(1, 179999)/1000, longitude = math.random(1,89999)/1000}
    if (not self.m_coordinated) and self.m_logonSuccess and coord then
        self:sendCoordinate(coord)
    end

	while true do
		if(self.m_socket == nil) then
			return
		end		
		local response = self.m_socket:getResponse()
		if(response == nil) then
			return
		end		
		local bExit = false
		if response.nCmd == gamelibcommon.CONNECT_OK_RES then
			self:onConnect()
		end
		if response.nCmd == gamelibcommon.CONNECT_ERROR_RES then
			bExit = true
			self:onConnectFailed()
		end
		if response.nCmd == gamelibcommon.RECV_DATA_OK_RES then
			bExit = true
			self:onRecv(response.pData,response.nLen)
		end
		if response.nCmd == gamelibcommon.DISCONNECT_RES then
			bExit = true
			self:onConnectClose()
		end
		response:release()
		if bExit then return end
	end
end

-- 设置信号
function GameRoom:setSink(sink)
	if(sink) then
		cclog("GameRoom:setSink")
	else
		cclog("GameRoom:setSink = nil")
	end

	self.m_sink = sink
end

function GameRoom:setClientFrameSink(sink)
	self.m_clientFrameSink = sink
	self.m_clientFrame:setSink(sink)
end

-- 创建连接成功回调
function GameRoom:onConnect()
    cclog("GameRoom::onConnect() statu: "..tostring(self.m_netStatus))
    self:sendLoginCmd()
end

-- 创建连接失败回调
function GameRoom:onConnectFailed()
    cclog("GameRoom::onConnectFailed() statu: "..tostring(self.m_netStatus))
	self:stopCheckPing()
    self:stopRetry()
    if self.m_netStatus == NETWORK_STATUS_UNCONNECTED then
        self.m_pGameServer = nil
        self.m_sink:onEnterGameRoomFailed("网络连接失败，请检查网络设置并重试")
    elseif self.m_netStatus == NETWORK_STATUS_RETRY then
        self.m_dwRetryTimes = self.m_dwRetryTimes + 1
        if self.m_dwRetryTimes <= NETWORK_RETRY_COUNT then
            self.RETRYCONNECT = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
                self:tryToReconnecting("onConnectFailed")
            end, NETWORK_RETRY_INTERVAL, false)
        else
            self:reconnectFail()
        end
    end
end

-- GameRoom清理释放
function GameRoom:clear()
	cclog("房间清理释放，GameRoom::clear() statu: "..tostring(self.m_netStatus))
    NETWORK_BACKTOFOREGROUND = false
	self:stopCheckPing()
    self:stopRetry()
    
	self.m_mySelf = nil
	self.m_pGameServer = nil
    self.m_netStatus = NETWORK_STATUS_CLOSE
    
	self.m_userManager:clearAllUser()
	self.m_clientFrame:clear()
    
    if self:isServicing() then
        -- cclog("GameRoom:clear m_socket:closeconnect")
        self.m_socket:closeconnect()
    end
    if self.m_socket then
		self.m_socket:Release()
        self.m_socket = nil
    end
    
	self.m_szPrivateTablePassword = ""
	self.m_cbEnterType = gamelibcommon.PRIVATE_ROOM_NONE
	self.m_cbLastChairID = 0xff
    
    local pScene = CCDirector:sharedDirector():getRunningScene()
    if pScene.retryPanel then
        pScene.retryPanel:removeFromParentAndCleanup(true)
        pScene.retryPanel = nil
    end
end

-- 连接关闭回调
function GameRoom:onConnectClose()
    self:stopCheckPing()
    self:stopRetry()
    if self.m_netStatus == NETWORK_STATUS_CONNECTED then
        cclog("房间连接异常断开，GameRoom::onConnectClose()")
        self.m_netStatus = NETWORK_STATUS_RETRY
        self.m_dwRetryTimes = 1
        self:tryToReconnecting("onConnectClose1")
    elseif self.m_netStatus == NETWORK_STATUS_RETRY then
        cclog("房间重连中异常断开，GameRoom::onConnectClose()")
        self:tryToReconnecting("onConnectClose2")
    else
        cclog("房间正常断开 statu: "..tostring(self.m_netStatus))
    end
end

-- 收到消息回调
function GameRoom:onRecv(buf,nLen)
	if(buf == nil or nLen <= 0) then
		return
	end
    
	self.m_dwLastRespTime = getTickCount()
	cbMainCmd = string.byte(buf)
	self.m_pGameLib:checkNew()
    
	if(cbMainCmd >= 100) then
		if(nLen < 4) then
			return
		end
		local cbSubCmd = string.byte(string.sub(buf,2))
		self:recvCommands(cbMainCmd, cbSubCmd, string.byte(string.sub(buf,3)), string.sub(buf,5),nLen - 4)
	else
		self:recvCommands(cbMainCmd, 0, 0, string.sub(buf,2),nLen - 1)
	end
end

-- 进入房间(数字IP方式)
function GameRoom:enterGameRoom(pGameServer,userID,password,version,cbShake,cbEnterType,szTablePass)
	if(pGameServer == nil) then
		return false
	end
    if self:isServicing() then
        -- cclog("GameRoom:enterGameRoom m_socket:closeconnect")
        self.m_netStatus = NETWORK_STATUS_UNCONNECTED
        self.m_socket:closeconnect()
    end
	if(self.m_socket == nil) then
		-- cclog("GameRoom:enterGameRoom createSocket()")
		self.m_socket = CCSocket:createCCSocket()
		self.m_socket:init()--将此注释掉，避免多线程读取数据
	end
	self.m_pGameServer = pGameServer
	self.m_dwUserID = userID
	self.m_szPass = password
	self.m_gameVersion = version
	self.m_dwServerIP = pGameServer.dwServerIP
	self.m_uPort = pGameServer.uServerPort
	self.m_strServerIP = nil
    
    if debugMode and AppConfig.testRoomServer then
        cclog("Now enter the testRoomServer ...")
        self.m_socket:connectInt(AppConfig.testRoomServer.dwServerIP, AppConfig.testRoomServer.uServerPort)
    else
        self.m_socket:connectInt(pGameServer.dwServerIP, pGameServer.uServerPort)
    end

	self.m_cbShake = cbShake
	self.m_cbEnterType = cbEnterType
	if(szTablePass) then
		self.m_szPrivateTablePassword = szTablePass
	end
	cclog("GameRoom::enterGameRoom %d,%d,%d,%s",
		pGameServer.dwServerIP,pGameServer.uServerPort,userID,password)
    cclog("server 配置(online/max): %d/%d", pGameServer.wOnLineCount, pGameServer.wMaxOnLineCount)
	return true
end

-- 进入房间(IP地址方式)
function GameRoom:enterGameRoomByIP(ipaddress,port,userID,password,version,pGameServer)
    if self:isServicing() then
        -- cclog("GameRoom:enterGameRoomByIP m_socket:closeconnect")
        self.m_netStatus = NETWORK_STATUS_UNCONNECTED
        self.m_socket:closeconnect()
    end
	if(self.m_socket == nil) then
		-- cclog("GameRoom:enterGameRoomByIP createSocket()")
		self.m_socket = CCSocket:createCCSocket()
		self.m_socket:init()--将此注释掉，避免多线程读取数据
	end
	self.m_pGameServer = pGameServer
	self.m_dwUserID = userID
	self.m_szPass = password
	self.m_gameVersion = version	
	self.m_socket:connect(ipaddress, port)
	self.m_dwServerIP = nil
	self.m_uPort = port
	self.m_strServerIP = ipaddress

	self.m_cbShake = 0
	self.m_cbEnterType = 0
	return true
end

-- 获取服务器配置
function GameRoom:getCurrentServer()
	if not self:isServicing() then return nil end
	return self.m_pGameServer
end

-- 获取GameRoom的CGameLibLua
function GameRoom:getGameLib()
	return self.m_pGameLib
end

-- 收到消息回调处理总线
function GameRoom:recvCommands(cbMainCmd, cbSubCmd, cbHandleCode, buf, nLen)
	cclog("recvCommands MainCmd = %d,SubCmd = %d", cbMainCmd, cbSubCmd)
	if cbMainCmd == GameCmds.MAIN_GR_LOGON  then
		return self:recvLogonMessage(cbSubCmd, cbHandleCode, buf, nLen)
	end

	if cbMainCmd == GameCmds.MAIN_GR_ROOM_STATUS  then
		return self:recvRoomStatus(cbSubCmd, cbHandleCode, buf, nLen)
	end

	if cbMainCmd == GameCmds.MAIN_GR_CLIENT  then
		return self:recvClientMsg(cbSubCmd, cbHandleCode, buf, nLen)
	end
	if cbMainCmd == GameCmds.MAIN_GR_MATCH then
		return self:recvMatchMsg(cbSubCmd, cbHandleCode, buf, nLen)
	end
	if cbMainCmd == GameCmds.MAIN_GR_FRIENDTABLE then
		return self:recvFriendGameMsg(cbSubCmd, cbHandleCode, buf, nLen)
	end	
	if cbMainCmd == GameCmds.MAIN_GR_CONFIG  then
		return self:recvConfigMsg(cbSubCmd, cbHandleCode, buf, nLen)
	end
	if cbMainCmd == GameCmds.MAIN_GR_USER  then
		return self:recvUserMessage(cbSubCmd, cbHandleCode, buf, nLen)
	end
	if cbMainCmd == GameCmds.CMD_HTML_HALL_CHAT  then
		return self:recvHallChat(buf, nLen)
	end
	if cbMainCmd == GameCmds.CMD_HTML_TABLE_CHAT  then
		return self:recvTableChat(buf, nLen)
	end
	if cbMainCmd == GameCmds.CMD_TABLE_CHAT  then
		return false
	end
	if cbMainCmd == GameCmds.CMD_AD  then
		return true
	end
	if cbMainCmd == GameCmds.MAIN_GR_PROPERTY  then
		return true
	end
	if cbMainCmd == GameCmds.CMD_MANAGER  then
		return self:recvManager(buf, nLen)
	end
	if cbMainCmd == GameCmds.CMD_SERVER_PING  then		
		if(self.m_socket ~= nil) then
			local ba = require("ByteArray").new()
			for i=1,4 do
				ba:writeUByte(0)
			end
			self:sendGameCmd(GameCmds.CMD_SERVER_PING, GameCmds.IDC_SP_ANWSER_PING, ba:getBuf(),ba:getLen())
		end
		return true
	end

	if cbMainCmd == GameCmds.MAIN_CM_SERVICE  then
		return self:recvCMMessage(cbSubCmd, buf, nLen)
	end

	if cbMainCmd == GameCmds.MAIN_CM_DOWN_LOAD  then
		return true
	end

	if cbMainCmd == GameCmds.CMD_GAME  then
		--cclog("GameRoom GameCmds.CMD_GAME %d",nLen))
		return self:recvGameCmd(buf, nLen)
	end

	if cbMainCmd == GameCmds.CMD_USER  then
		return self:recvUserCmd(buf, nLen)
	end
	if cbMainCmd == GameCmds.CMD_PING_USER then
		return self:recvAnswerPing()
	end

end

-- 发送坐标信息指令
function GameRoom:sendCoordinate(coord)
    -- cclog("发送坐标 longitude:%s  latitude:%s", tostring(coord.longitude), tostring(coord.latitude))
	local ba = require("ByteArray").new()
	ba:writeFloat(coord.longitude)
	ba:writeFloat(coord.latitude)
	self:sendGameCmd(GameCmds.MAIN_GR_USER, GameCmds.SUB_GR_REQ_COORDINATE, ba:getBuf(),ba:getLen())
    self.m_coordinated = true
end

-- 发送登录指令
function GameRoom:sendLoginCmd()	
	local logonByVNET = CMD_GR_Logon_ByVnet:new()
	logonByVNET.lUserDBID = self.m_dwUserID
	logonByVNET.szEncryptPass = self.m_szPass

	logonByVNET.ConnectInfo.wSize = 14

	logonByVNET.ConnectInfo.dwConnectDelay = 0
	logonByVNET.ConnectInfo.dwGameInstallVer = self.m_gameVersion
	logonByVNET.ClientInfo = self:getGameLib():getClientInfo()
	logonByVNET.VersionInfo = self:getGameLib():getVersionInfo()
    logonByVNET.cbShake = self.m_cbShake
	logonByVNET.cbEnterType = self.m_cbEnterType
	logonByVNET.szTablePass = self.m_szPrivateTablePassword
	local ba = logonByVNET:Serialize()
	self:sendGameCmd(GameCmds.MAIN_GR_LOGON, GameCmds.SUB_GR_LOGON_BY_VNET, ba:getBuf(),ba:getLen())	
end

-- 收到登录返回消息处理
function GameRoom:recvLogonMessage(cbSubCmd, cbHandleCode, buf, nLen)
    if cbSubCmd == GameCmds.SUB_GR_LOGON_SUCCESS  then
        cclog("GameCmds.SUB_GR_LOGON_SUCCESS")
        local ba = require("ByteArray").new()
        ba:initBuf(buf)
        local uUserID = ba:readInt()
        local pDeault = CCUserDefault:sharedUserDefault()
        pDeault:setStringForKey("LastRoom","")
        self.m_userManager:clearAllUser()
        self.m_userManager:setMyDBID(uUserID)
        self.m_sink:onLogonGameRoomSucceeded()			
    end
    if cbSubCmd == GameCmds.SUB_GR_LOGON_FINISH  then
        cclog("SUB_GR_LOGON_FINISH")
        local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
        local pDeault = CCUserDefault:sharedUserDefault()
        pDeault:setStringForKey("LastRoom","")
        --self:sendOptionsMessage()
        self.m_dwLastSendTableChat = 0
        self.m_logonSuccess = true
        if self.m_netStatus == NETWORK_STATUS_UNCONNECTED then
            -- 正常连接创建好友桌
            cclog("进入好友桌")
            self.m_netStatus = NETWORK_STATUS_CONNECTED
            self.m_sink:onEnteredGameRoom(self.m_tableManager:getTableCount(), self.m_tableManager:getChairCount())
        elseif self.m_netStatus == NETWORK_STATUS_RETRY then
            cclog("重连返回好友桌")
            self.m_sink:onEnteredGameRoom(self.m_tableManager:getTableCount(), self.m_tableManager:getChairCount())
            self:reconnectSuccess()
        end
    end
	return true
end

-- 收到房间状态消息处理
function GameRoom:recvRoomStatus(cbSubCmd, cbHandleCode, buf, nLen) 	
	if cbSubCmd == GameCmds.SUB_GR_BROADCAST_TABLE_STATUS  then	
		local pTableStatus = CMD_GR_BroadCast_TableStatus:new(buf,nLen)
		local t = self.m_tableManager:getTable(pTableStatus.wTableID)
		if(t == nil) then
			return false
		end
		t._isLock = (pTableStatus.cbTableStatus == Table.TABLE_LOCKED 
			or pTableStatus.cbTableStatus == Table.TABLE_LOCKED + Table.TABLE_PLAYING)
		t._isPlaying = (pTableStatus.cbTableStatus == Table.TABLE_PLAYING 
			or pTableStatus.cbTableStatus == Table.TABLE_LOCKED + Table.TABLE_PLAYING)
		self.m_sink:onTableInfoChanged(pTableStatus.wTableID)
	end
	return true
end

function GameRoom:recvClientMsg(cbSubCmd, cbHandleCode, buf, nLen)	
	return true
end

-- 收到比赛消息处理
function GameRoom:recvMatchMsg(cbSubCmd, cbHandleCode, buf, nLen)
	if cbSubCmd == GameCmds.SUB_GR_MATCH_PRIZE then
		local ba = require("ByteArray").new()
		ba:initBuf(buf)
		local nRank = ba:readInt()
		local strPrize = ba:readStringSubZero(nLen - 4)
		strPrize = strPrize or ""		
		self.m_sink:onMatchPrize(nRank,strPrize)
	end
	if cbSubCmd == GameCmds.SUB_GR_MATCH_WAIT_START then
		self.m_sink:onMatchWaitStart()
	end
	if cbSubCmd == GameCmds.SUB_GR_MATCH_ELIMINATE then		
		self.m_sink:onMatchEliminate()
	end
	if cbSubCmd == GameCmds.SUB_GR_MATCH_PROMOTE then		
		self.m_sink:onMatchPromote()
	end
	return true
end

-- 收到好友桌消息处理总线
function GameRoom:recvFriendGameMsg(cbSubCmd, cbHandleCode, buf, nLen)
	local ret = false

	if cbSubCmd == GameCmds.SUB_GR_CREATE_FRIENDTABLE_RSP  then 	--创建好友卓结果
		ret = self:onCreateFriendTableMessage(buf, nLen)
	end

	if cbSubCmd == GameCmds.SUB_GR_FRIENDTABLE_DISMISS_RSP  then 	--解散好友卓结果
		ret = self:onDismissFriendTableMessage(buf, nLen)
	end

	if cbSubCmd == GameCmds.SUB_GR_FRIENDTABLE_NOTICE_VOTE  then 	--解散好友卓广播
		ret = self:onDismissTableNoticeMessage(buf, nLen)
	end

	if cbSubCmd == GameCmds.SUB_GR_FRIENDTABLE_VOTE_RSP  then 		--解散好友桌玩家投票结果
		ret = self:onFriendTableVoteMessage(buf, nLen)
	end

	if cbSubCmd == GameCmds.SUB_GR_FRIENDTABLE_END_INFO  then 		--游戏结算结果
		ret = self:onFriendTableEndMessage(buf, nLen)
	end

	if cbSubCmd == GameCmds.SUB_GR_FRIENDTABLE_ADD_RSP  then 		--加入好友卓
		ret = self:onFriendTableAddMessage(buf, nLen)
	end

	if cbSubCmd == GameCmds.SUB_GR_FRIENDTABLE_RULE_RSP  then 		--好友卓规则
		ret = self:onFriendTableRuleMessage(buf, nLen)
	end

	if cbSubCmd == GameCmds.SUB_GR_FRIENDTABLE_ABLED  then 		--好友桌是个生效
		ret = self:onFriendTableAbledMessage(buf, nLen)
	end


	return ret
end

-- 创建好友桌
function GameRoom:createFriendTable(nPartner)
    cclog("GameRoom:createFriendTable")
	-- 这里要判断用户是否已经进入房间
	if(self:isServicing() and self:isPrivteRoom()) then
		local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
		local cbMode, nUseNum, options = FriendGameLogic.getGameRule()
        
        print(cbMode, nUseNum, options)

		local ba = require("ByteArray").new()
		ba:writeInt(nPartner)
		ba:writeByte(cbMode)
		ba:writeInt(nUseNum)

		local count = #options
		ba:writeByte(count)
		for i,v in ipairs(options) do
			ba:writeByte(v[1])
			ba:writeInt(v[2])
			cclog("GameRoom:createFriendTable "..v[1]..";"..v[2])
		end
		ba:writeInt(FriendGameLogic.pay_type)

		ba:setPos(1)
		cclog("GameRoom:createFriendTable "..count)
		self:sendGameCmd(GameCmds.MAIN_GR_FRIENDTABLE, GameCmds.SUB_GR_CREATE_FRIENDTABLE_REQ, ba:getBuf(),ba:getLen())
		return true
	end

	return false
end

-- 收到创建好友桌返回消息处理
function GameRoom:onCreateFriendTableMessage(buf, nLen)
	local ba = require("ByteArray").new()
	ba:initBuf(buf)

	local dwErrorCode = ba:readInt()
	local cbIsEnable = dwErrorCode % 256
	cclog("onCreateFriendTableMessage "..dwErrorCode.." / "..cbIsEnable)
	if cbIsEnable == 0 then
        if self:isServicing() then
            -- cclog("GameRoom:onCreateFriendTableMessage m_socket:closeconnect")
            self.m_netStatus = NETWORK_STATUS_UNCONNECTED
            self.m_socket:closeconnect()
        end
        self.m_sink:onCreateFriendTableFailed(dwErrorCode)
		return false
	end
    self:startCheckPing()

	local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
	FriendGameLogic.friend_tableID = ba:readInt()
	FriendGameLogic.invite_code = ba:readStringSubZero(16)
	local exprireTime = ba:readUInt()
	local validTime = ba:readUInt()

	FriendGameLogic.game_abled = false
	self.m_sink:onCreateFriendTableSuccend(exprireTime, validTime)
	return true
end

-- 解散好友桌
function GameRoom:dismissFriendTable()
	-- 这里要判断用户是否已经进入房间
	if(self:isServicing() and self:isPrivteRoom()) then
		local ba = require("ByteArray").new()
		ba:writeInt(require("Lobby/FriendGame/FriendGameLogic").friend_tableID)
		ba:setPos(1)
		
		self:sendGameCmd(GameCmds.MAIN_GR_FRIENDTABLE, GameCmds.SUB_GR_FRIENDTABLE_DISMISS_REQ, ba:getBuf(),ba:getLen())
		return true
	end

	return false
end

-- 收到好友桌解散返回消息处理
function GameRoom:onDismissFriendTableMessage(buf, nLen)
	local ba = require("ByteArray").new()
	ba:initBuf(buf)
	
	local dwErrorCode = ba:readUInt()
	local cbIsEnable = dwErrorCode % 256

	if dwErrorCode == 0 then
		return false
	end 

	self.m_sink:onDismissFriendTableMessage()
	cclog("xxxxxxxxxx GameRoom:onDismissFriendTableMessage")
	return true
end

-- 收到好友桌解散提醒消息处理
function GameRoom:onDismissTableNoticeMessage(buf, nLen)
	local ba = require("ByteArray").new()
	ba:initBuf(buf)


	local nFriendTableID = ba:readInt() 	--好友卓的唯一ID
	local dwUserDBID = ba:readUInt() 		--发起人
	local cbWaitTime = ba:readUByte()		--投票等待时间（单位s）

	self.m_sink:onDismissTableNoticeMessage(dwUserDBID, cbWaitTime)
	return true
end

-- 解散好友桌投票
function GameRoom:voteFriendTable(agree)
	-- 这里要判断用户是否已经进入房间
	if(self:isServicing() and self:isPrivteRoom()) then
		local ba = require("ByteArray").new()
		ba:writeInt(require("Lobby/FriendGame/FriendGameLogic").friend_tableID)
		ba:writeByte(agree)
		ba:setPos(1)

		self:sendGameCmd(GameCmds.MAIN_GR_FRIENDTABLE, GameCmds.SUB_GR_FRIENDTABLE_VOTE_REQ, ba:getBuf(),ba:getLen())
		return true
	end

	return false
end

-- 收到好友桌解散投票返回消息处理
function GameRoom:onFriendTableVoteMessage(buf, nLen)
	local ba = require("ByteArray").new()
	ba:initBuf(buf)

	local nFriendTableID = ba:readInt() 		--好友卓的唯一ID
	local bIsFinishVote = ba:readUByte()		--投票是否结束
	local bIsSucess = ba:readUByte()			--解散是否成功
	local reqUserDBID = ba:readUInt()			--发起人DBID
	local reqUserName = getUtf8(ba:readStringSubZero(32)) --发起人昵称

	local cbWaitTime = ba:readUByte()			--投票等待剩余时间（单位s）

	local nUserNum = ba:readUByte() 				--投票人个数
	local voteinfo = {}
	for i=1,nUserNum do
		local UserDBID = ba:readUInt()			--发起人DBID
		local UserNickName = getUtf8(ba:readStringSubZero(32)) 			
		local cbIsAgree = ba:readUByte()			--是否同意
		table.insert(voteinfo, {UserDBID, UserNickName, cbIsAgree})
		cclog("onFriendTableVoteMessage "..UserNickName..";"..cbIsAgree)
	end
	cclog("onFriendTableVoteMessage "..nUserNum..";"..reqUserName)


	self.m_sink:onFriendTableVoteMessage(reqUserName, reqUserDBID, bIsFinishVote, bIsSucess, voteinfo, cbWaitTime)

	return true
end

-- 收到好友桌结束消息处理
function GameRoom:onFriendTableEndMessage(buf, nLen)
	local ba = require("ByteArray").new()
	ba:initBuf(buf)

	local nFriendTableID = ba:readInt() 	--好友卓的唯一ID	
	local nUserNum = ba:readUShort()

	local infoList = {}
	for i=1,nUserNum do
		local data = {UserID = ba:readUInt(),
				Score = ba:readInt(), FaceID = ba:readInt(),
				Sex = ba:readInt(), Changed = ba:readInt(),

				UserNickName = getUtf8(ba:readStringSubZero(32)),
				RuleScoreInfo = getUtf8(ba:readStringSubZero(128))}
		table.insert(infoList, data)

		cclog("onFriendTableEndMessage "..data.RuleScoreInfo..";"..nUserNum)
	end

	self.m_sink:onFriendTableEndMessage(infoList)
	return true
end

-- 重回好友桌发送加入指令
function GameRoom:returnFriendTable(tableid, code)
	-- 这里要判断用户是否已经进入房间
	if(self:isServicing() and self:isPrivteRoom()) then
		local ba = require("ByteArray").new()
		ba:writeInt(tableid)
		ba:writeString(code)
        
		for i=string.len(code) + 1,16 do
			ba:writeByte(0)
		end

		ba:setPos(1)
        
		cclog("returnFriendTable "..tableid..";"..code)
		self:sendGameCmd(GameCmds.MAIN_GR_FRIENDTABLE, GameCmds.SUB_GR_FRIENDTABLE_ADD_REQ, ba:getBuf(),ba:getLen())
		return true
	end

	return false
end

-- 收到加入好友桌消息处理
function GameRoom:onFriendTableAddMessage(buf, nLen)
	local ba = require("ByteArray").new()
	ba:initBuf(buf)
	
	local dwErrorCode = ba:readUInt()
	local cbIsEnable = dwErrorCode % 256
	cclog("GameRoom:onFriendTableAddMessage "..dwErrorCode)
	
	if cbIsEnable == 0 then
        self:reAddFriendTableFail(dwErrorCode)
		return false
	end
    
    self:startCheckPing()
	self.m_sink:onFriendTableAddSuccend()
	return true
end

-- 收到好友桌规则消息处理
function GameRoom:onFriendTableRuleMessage(buf, nLen)
    cclog("GameRoom:onFriendTableRuleMessage")
	local ba = require("ByteArray").new()
	ba:initBuf(buf)

	local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
	local cbMasterUserDBID = ba:readUInt() 			--房主DBID
	FriendGameLogic.game_mode = ba:readUByte() 		--使用模式，10按局数；20按有效时间

	local gamenum = ba:readInt() 					--局数或者有效时间(秒)
	FriendGameLogic.game_used = ba:readInt() 		--局数或者有效时间(秒)

	local exprireTime = ba:readUInt()
	local validTime = ba:readUInt()
	
	local options = {}
	local cbRuleOptionNum = ba:readUByte() 			--规则配置参数个数
	for i=1,cbRuleOptionNum do
		local option = {ba:readUByte(), ba:readInt()}
		table.insert(options, option)
	end

	FriendGameLogic.game_abled = FriendGameLogic.game_used > 0
	self.m_sink:onFriendTableRuleMessage(gamenum, options, cbMasterUserDBID, exprireTime, validTime)

	return true
end

-- 收到好友桌可用消息处理
function GameRoom:onFriendTableAbledMessage(buf, nLen)
	require("Lobby/FriendGame/FriendGameLogic").game_abled = true
	self.m_sink:onFriendTableAbledMessage()

	return true
end

function GameRoom:recvConfigMsg(cbSubCmd, cbHandleCode, buf, nLen)	
	if cbSubCmd == GameCmds.SUB_GR_ROOM_INFO  then                         
		cclog("GameCmds.SUB_GR_ROOM_INFO")
		local pGameInfo = CMD_GR_GameInfo:new(buf,nLen)
		if(pGameInfo.OptionsBuf.cbReserveLen > 1) then
			local cbPrivate = pGameInfo.OptionsBuf.Buffer[2]
			self.m_bIsPrivateRoom = (cbPrivate > 0)
		end
		self.m_tableManager = require("GameLib/gamelib/room/TableManager"):new(pGameInfo.wTableCount, pGameInfo.cbTableUser)
		return true
	end
	if cbSubCmd == GameCmds.SUB_GR_SCORE_HEADER  then                      -- ������Ϣ
		
		local c = self.m_scoreParser:SetScoreHeader(buf, nLen)
		if(not c) then
			cclog("GameCmds.SUB_GR_SCORE_HEADER failed")
		end
		return true
	end
	if cbSubCmd == GameCmds.SUB_GR_TABLE_INFO then
		local ba = require("ByteArray").new()
		ba:initBuf(buf)
		local tableID = ba:readByte()
		local table = self.m_tableManager:getTable(tableID)
		if table then
			table:setTableBuf(ba:readBuf(nLen - 1))
		end
		return true
	end
end

-- 收到用户数据
function GameRoom:recvUserMessage(cbSubCmd, cbHandleCode, buf, nLen)
	local ret = false

	if cbSubCmd == GameCmds.SUB_GR_BROADCAST_USER_COME  then                       -- �û�����
		ret = self:onSubUserComeMessage(buf, nLen)
	end
	if cbSubCmd == GameCmds.SUB_GR_BROADCAST_USER_LEFT  then                       -- �û��뿪
		ret = self:onSubUserLeftMessage(buf, nLen)
	end
	if cbSubCmd == GameCmds.SUB_GR_BROADCAST_USER_STATUS  then                     -- �û�״̬		
		ret = self:onSubUserStatusMessage(buf, nLen)
	end
	if cbSubCmd == GameCmds.SUB_GR_BROADCAST_USER_COORDINATE  then                 -- 
		ret = self:onSubUserCoordinateMessage(buf, nLen)
	end
	if cbSubCmd == GameCmds.SUB_GR_BROADCAST_USER_SCORE  then                      -- �û�����
		ret = self:onSubUserScoreMessage(buf, nLen)
	end
	if cbSubCmd == GameCmds.SUB_GR_BROADCAST_USER_FAME_EX then
		ret = self:onSubUserFameMessage(buf, nLen)
	end
	if cbSubCmd == GameCmds.SUB_GR_CAN_SIT_TABLE_RESPONSE  then
		ret = self:onSubCanSitTable(buf, nLen)
	end		
	if cbSubCmd == GameCmds.SUB_GR_FRAG_COUNT then
		local ba = require("ByteArray").new()
		ba:initBuf(buf)
		self.m_pGameLib:updateMyFragCount(ba:readInt())
		self.m_sink:onRoomUserInfoUpdated(self.m_mySelf:getUserID())
	end
	if cbSubCmd == GameCmds.SUB_GR_TOOLCARD_INFO then
		self.m_sink:onToolCardInfo(buf,nLen)
	end
	if cbSubCmd == GameCmds.SUB_GR_CREATETABLE_FAILED then
		self.m_sink:onCreatePrivateTableFailed(buf)
	end
	if cbSubCmd == GameCmds.SUB_GR_ENTERPRIVATE_FAILED then
		self.m_sink:onEnterPrivateTableFailed(buf)
	end
	if cbSubCmd == GameCmds.SUB_GR_BANK_VALUE then 
		local ba = require("ByteArray").new()
		ba:initBuf(buf)
		self.m_mySelf:setBankAmount(ba:readInt64())
	end
	if cbSubCmd == GameCmds.SUB_GR_BANK_RETURN then
		local ba = require("ByteArray").new()
		ba:initBuf(buf)
		local succeeded = ba:readInt()
		local gold = ba:readInt()
		local bank = ba:readInt64()
		if succeeded == 1 then
			self.m_mySelf:setBankAmount(bank)
		end
		self.m_sink:onGameBankOpeReturn(succeeded,self.m_mySelf:getGold(),bank)
	end
	if cbSubCmd == SUB_GR_ROOM_TRANSFER then
		local ba = require("ByteArray").new()
		ba:initBuf(buf)
		local succeeded = ba:readInt()
		local lCash = ba:readInt()
		local szMsg = ba:readStringSubZero(nLen - 8)
		self.m_sink:onRoomTransferReturn(succeeded,lCash,szMsg)
	end
	return ret
end

function GameRoom:onSubUserComeMessage(buf, nLen)
	local user = tagUserInfoBroad:new()
	if(not user:Deserialize(buf, nLen)) then
		return false
	end
	-- user.Deserialize(buf, 0)

	-- 如果用户已存在，则不加入
	local bExist = true
	local userItem = self.m_userManager:getUser(user.wUserIndex)

	if(userItem == nil) then
		userItem = require("GameLib/gamelib/UserInfo"):new()
		bExist = false
	end

	userItem._name = getUtf8(user.szName)
	userItem._userIndex = user.wUserIndex
	userItem._userRountIC = user.wRoundCount
	userItem._faceID = user.wFaceID
	userItem._netLag = user.wNetTimelag
	userItem._tableID = user.wTableID
	userItem._chairID = user.cbChairID
	userItem._status = user.cbUserStatus
	userItem._userDBID = user.lUserDBID
	userItem._groupID = user.dwGroupID
	userItem._userLevel = user.dwUserLevel
	userItem._sex = user.cbSex
	userItem._memberClass = user.dwMemberClass
	userItem._scoreBuf = user.szScores
	userItem._scoreBufLen = user.cbScoreLen
	userItem._fame = user.dwFame
	userItem._fameLevel = user.dwFameLevel	
	userItem.m_cbFaceChagneIndex = user.cbFaceChangeIndex
	userItem._longitude = user.fLongitude
	userItem._latitude = user.fLatitude

	userItem._fame = user.dwFame
	userItem._fameLevel = user.dwFameLevel
	userItem.m_cbVipLevel = user.cbVIPLevel
	userItem._age = user.nAge
	userItem._province = getUtf8(user.szProvince)
	userItem._city = getUtf8(user.szCity)
	userItem._area = getUtf8(user.szArea)
	userItem._groupName = getUtf8(user.szGroup)
	userItem._userIP = getUtf8(user.cbUserIP)
	userItem._maxim = getUtf8(user.szDescribe)
	
	if(not bExist) then
		self.m_userManager:addUser(userItem)
	end
	cclog("onUserEnter cmd:1521 %s(%d), %d, %d", userItem._name, userItem._userDBID, userItem._chairID+1, userItem._status)
	if(userItem._userDBID == self.m_userManager:getMyDBID()) then    -- ���Լ�
		self.m_userManager:setMyUserID(userItem._userIndex)
		self.m_mySelf = self.m_userManager:getMyInfo()
		self.m_clientFrame:setMyself(self.m_mySelf)
		self.m_pGameLib:updateMyScore()
	end

	if(userItem._status > gamelibcommon.USER_WAIT_SIT and userItem._status < gamelibcommon.USER_WATCH_GAME) then		
		local t = self.m_tableManager:getTable(userItem._tableID)
		if(t ~= nil) then
			local chair = t:getChair(userItem._chairID)
			if(chair ~= nil) then
				chair.empty = false
				chair.userID = userItem._userIndex
			end
		end
	end
	if(not bExist) then
		self.m_sink:onRoomUserEnter(userItem._userIndex)
	end
	return true
end

function GameRoom:onSubUserLeftMessage(buf, nLen)
	local ba = require("ByteArray").new()
	ba:initBuf(buf)
	local dwUserDBID = ba:readInt()

	local user = self.m_userManager:getUserByDBID(dwUserDBID)

	if(user == nil) then
		--cclog("用户离开是找不到存储")
		return true
	end
	self.m_sink:onRoomUserExit(user._userIndex)
	self.m_userManager:removeUser(user._userIndex)
	return true
end

function GameRoom:isSitTable(status)
	return status >= gamelibcommon.USER_SIT_TABLE and 
        status < gamelibcommon.USER_WATCH_GAME
end

function GameRoom:onSubUserStatusMessage(buf, nLen)	
	local userstatus = CMD_GR_BroadCast_UserStatus:new(buf,nLen)
	local user = self.m_userManager:getUserByDBID(userstatus.dwUserDBID)
	if(user == nil) then
		cclog("onSubUserStatusMessage get user failed: "..userstatus.dwUserDBID)
		return true
	end
	local wNowTableID = userstatus.wTableID
	local wLastTableID = user._tableID
	local cbNowChairID = userstatus.cbChairID
	local cbLastChairID = user._chairID
	local cbNowStatus = userstatus.cbUserStatus
	local cbLastStatus = user._status
	user._tableID = wNowTableID
	user._chairID = cbNowChairID
	user._status = cbNowStatus
	user._netLag = userstatus.wNetTimelag
	local nowTable = self.m_tableManager:getTable(wNowTableID)
	local oldTable = self.m_tableManager:getTable(wLastTableID)
	local nowChair = ((nowTable ~= nil) and nowTable:getChair(cbNowChairID) or nil)
	local oldChair = ((oldTable ~= nil) and oldTable:getChair(cbLastChairID) or nil)

	local changeTableStatus = false
	if wNowTableID ~= wLastTableID then
		changeTableStatus = true
	end
	if cbNowChairID ~= cbLastChairID then
		changeTableStatus = true
	end
	if self:isSitTable(cbLastStatus) ~= self:isSitTable(cbNowStatus) then
		changeTableStatus = true
	end
	if changeTableStatus then
		if(oldTable ~= nil) then			
			if(oldChair ~= nil and self:isSitTable(cbLastStatus) and not oldChair.empty) then
				oldChair.empty = true
				self.m_sink:onTableInfoChanged(wLastTableID)
			end
		end		
		if(nowTable ~= nil) then			
			if(nowChair ~= nil and self:isSitTable(cbNowStatus) and nowChair.empty) then
				nowChair.empty = false
				nowChair.userID = user._userIndex
				self.m_sink:onTableInfoChanged(wNowTableID)
			end
		end
		
	end
	

	local wMeTableID = self.m_mySelf._tableID

	cclog("onSubUserStatusMessage 1523,userid = %d,tableid= %d,chairid = %d,status = %d,last table = %d,last chair = %d,last status = %d ",
		userstatus.dwUserDBID,userstatus.wTableID,userstatus.cbChairID,
		userstatus.cbUserStatus,
		wLastTableID,cbLastChairID,
		cbLastStatus)
	
	self.m_sink:onRoomUserInfoUpdated(user._userIndex)

	if(user._userDBID == self.m_userManager:getMyDBID()) then
		-- 保留上一次有效椅子号
		if(cbLastChairID < self.m_tableManager:getChairCount()) then
			self.m_cbLastChairID = cbLastChairID
		end
		if(cbNowChairID < self.m_tableManager:getChairCount()) then
			self.m_cbLastChairID = cbNowChairID
		end
		if(cbNowStatus >= gamelibcommon.USER_SIT_TABLE) then
			if(cbLastStatus < gamelibcommon.USER_SIT_TABLE 
				or wNowTableID ~= wLastTableID 
				or cbLastStatus == gamelibcommon.USER_OFF_LINE) then
				--self.m_clientFrame:meEnterGame(self.m_tableManager:getChairCount())
				--self.m_sink:onEnterGameView()
				cclog("onUserEnterTable,myself = %s", self.m_mySelf:getUserName())
				self.m_clientFrameSink:onUserEnterTable(cbNowChairID, self.m_mySelf._userIndex, self.m_mySelf:isPlayer())
			end
			if((wNowTableID ~= wLastTableID) or (cbLastStatus == gamelibcommon.USER_OFF_LINE)) then
				-- sendAllUserExitTableToMe(wLastTableID)
				for i = 1 , #self.m_userManager.m_userList do
					local userEnter = self.m_userManager.m_userList[i]
					if(userEnter._userIndex ~= user._userIndex) then				
						if(userEnter._tableID == wNowTableID) then
							self.m_clientFrameSink:onUserEnterTable(userEnter._chairID, userEnter._userIndex, userEnter:isPlayer())
						end
					end
				end
			end

			--if(self.m_mySelf:isPlayer())
			if self:isSitTable(cbLastStatus) or self:isSitTable(cbNowStatus) then
				self.m_clientFrameSink:onPlayerStateChanged(self.m_mySelf._chairID, cbLastStatus, cbNowStatus)
			end
		

			if(cbNowStatus == gamelibcommon.USER_PLAY_GAME) then
				local pDefault = CCUserDefault:sharedUserDefault()
				pDefault:setStringForKey("LastRoom",getUtf8(self.m_pGameServer.szGameRoomName))		
			elseif(cbNowStatus == gamelibcommon.USER_SIT_TABLE or
				cbNowStatus == gamelibcommon.USER_FREE_STATUS) then
				local pDefault = CCUserDefault:sharedUserDefault()
				pDefault:setStringForKey("LastRoom","")
			end	
			return true
		else          
			self:sendAllUserExitTableToMe(wLastTableID)
        	self.m_sink:onLeaveGameView()
        end
		return true	
	end

	-- �����û�����Ӻ�
	if(wMeTableID == gamelibcommon.INVALI_TABLE_ID) then
		return true
	end

	if(((wMeTableID == wNowTableID) or (wMeTableID == wLastTableID))) then
		if((wMeTableID == wNowTableID) and (wMeTableID ~= wLastTableID)) then		
			self.m_clientFrameSink:onUserEnterTable(user._chairID, user._userIndex, user:isPlayer())
		elseif((wMeTableID ~= wNowTableID) and (wMeTableID == wLastTableID)) then				
			self.m_clientFrameSink:onUserExitTable(cbLastChairID, user._userIndex, cbLastStatus >= gamelibcommon.USER_SIT_TABLE and cbLastStatus < gamelibcommon.USER_WATCH_GAME)
		end
		if self:isSitTable(cbLastStatus) or self:isSitTable(cbNowStatus) then
			self.m_clientFrameSink:onPlayerStateChanged(user._chairID, cbLastStatus, cbNowStatus)
            -- 如果用户状态是从游戏->坐下，表明一局结束，则发送坐标更新用户信息
            if cbLastStatus == gamelibcommon.USER_PLAY_GAME and cbNowStatus == gamelibcommon.USER_SIT_TABLE then
                local coord = AMap:get(); if coord then self:sendCoordinate(coord) end
            end
		end
	end
	return true
end

-- 收到坐标广播
function GameRoom:onSubUserCoordinateMessage(buf, nLen)
	local usercoordinate = CMD_GR_BroadCast_UserCoordinate:new(buf,nLen)
	local user = self.m_userManager:getUserByDBID(usercoordinate.dwUserDBID)
	if(user == nil) then
		cclog("onSubUserCoordinateMessage get user failed: "..usercoordinate.dwUserDBID)
		return true
	end
	user._longitude = usercoordinate.fLongitude
	user._latitude = usercoordinate.fLatitude
    -- cclog("收到坐标 longitude:%s  latitude:%s", tostring(user._longitude), tostring(user._latitude))
	return true
end

function GameRoom:onSubUserScoreMessage(buf, nLen)
	--cclog("onSubUserScoreMessage len = " .. nLen)
	local userScore = CMD_GR_BroadCast_UserScore:new(buf,nLen)
	local pUserItem = self.m_userManager:getUserByDBID(userScore.dwUserDBID)

	if(pUserItem ~= nil) then
		self.m_userManager:updateUserScore(pUserItem._userIndex, userScore.cbScoreBuf, userScore.cbScoreSize)
		self.m_sink:onRoomUserInfoUpdated(pUserItem._userIndex)
		cclog("onSubUserScoreMessage cmd:1524 (%d) %s:%d",pUserItem._userIndex,pUserItem:getUserName(),pUserItem:getScore())
		-- 如果是我自己
		if(pUserItem:getUserDBID() == self.m_mySelf:getUserDBID()) then
			self.m_pGameLib:updateMyScore()
		end
	end

	return true
end

function GameRoom:onSubUserFameMessage(buf, nLen)
	if(nLen < 12) then
		cclog("GameRoom:onSubUserFameMessage nLen = %d",nLen)
		return false
	end
	local ba = require("ByteArray").new()
	ba:initBuf(buf)
	local nUserID = ba:readInt()
	local pUserItem = self.m_userManager:getUserByDBID(nUserID)

	if(pUserItem ~= nil) then
		local nGameTitleScore = ba:readInt()
		local nGameTitleLevel = ba:readInt()
		local cbVipLevel = ba:readUByte()
		nOldLevel = pUserItem:getGameTitleLevel()
		nOldScore = pUserItem:getGameTitleScore()
		self.m_userManager:updateUserFame(pUserItem._userIndex, nGameTitleLevel,nGameTitleScore,cbVipLevel)
		self.m_sink:onRoomUserInfoUpdated(pUserItem._userIndex)

		--cclog("onSubUserScoreMessage [%s] gold = %d",getUtf8(puserItem.getUserName()),puserItem.getGold())
		-- 如果是我自己
		if(pUserItem:getUserDBID() == self.m_mySelf:getUserDBID()) then
			self.m_pGameLib:updateMyFame()
			-- 如果升级
			--if(nOldLevel < nGameTitleLevel)
			self.m_sink:onGameTitleChanged(nOldScore,nGameTitleScore,nOldLevel,nGameTitleLevel)
		end
	end
	return true
end

function GameRoom:onSubCanSitTable(buf, nLen)	
	return true
end

function GameRoom:recvHallChat(buf, nLen)
	local chat = require("GameLib/common/HtmlChat"):new(buf,nLen)
	self.m_sink:onRecvHallChat(chat)
	return true
end

function GameRoom:recvTableChat(buf, nLen)
	local chat = require("GameLib/common/HtmlChat"):new(buf,nLen)
	self.m_sink:onRecvTableChat(chat)
	return true
end

function GameRoom:recvManager(buf, nLen)
	return true
end

-- 收到系统消息
function GameRoom:recvCMMessage(cbSubCmd, buf, nLen)
	if cbSubCmd == GameCmds.SUB_CM_MESSAGE  then           
		local pSystemMessage = CMD_CM_SysteMessage:new(buf,nLen)
		if(pSystemMessage.bCloseLine ~= 0) then
            self:stopCheckPing()
            self:stopRetry()
            -- cclog("GameRoom:recvCMMessage m_socket:closeconnect")
            self.m_netStatus = NETWORK_STATUS_CLOSE
			self.m_socket:closeconnect()
		end

		if(pSystemMessage.wMessageLen > 0) then
			self.m_sink:onShowAlertMsg(getUtf8(pSystemMessage.szMessage))
		end			
		return true
	end

	if cbSubCmd == GameCmds.SUB_CM_MESSAGE_EX  then
		local sm = CMD_CM_SysteMessageEx:new(buf,nLen)
		if(sm.bCloseLine ~= 0) then
            self:stopCheckPing()
            self:stopRetry()
            -- cclog("GameRoom:recvCMMessage2 m_socket:closeconnect")
            self.m_netStatus = NETWORK_STATUS_CLOSE
			self.m_socket:closeconnect()
		end
		if(sm.wMessageLen > 0) then
			self.m_sink:onShowAlertMsg(getUtf8(sm.szMessage))
		end
		return true
	end
end

function GameRoom:recvGameCmd(buf, nLen)
	return self.m_clientFrame:recvGameCmd(buf, nLen)
end

function GameRoom:recvUserCmd(buf, nLen)
	local cbSubCmd = string.byte(buf)	
	if cbSubCmd == GameCmds.IDS_USER_ANS_SIT_DOWN  then
		local bEnable = (string.byte(string.sub(buf,2)) ~= 0)
		if(not bEnable) then
			self.m_sink:onShowAlertMsg("坐下失败")
		end
	end
	return true
end

function GameRoom:enterTable(wTable, cbChair)
	if not self:isServicing() then return false end

	local t = self.m_tableManager:getTable(wTable)
	if(t == nil) then
		cclog("cant find table : %d", wTable)
		return false
	end
	local chair = t:getChair(cbChair)
	if(chair == nil) then
		cclog("cant find chair : %d", cbChair)
		return false
	end
	if(t._isPlaying) then
		cclog("table is playing!")
		--self:sendWatchMessage(wTable, cbChair)
		--return true
	end
	if(not chair:isEmpty()) then
		cclog("chair is empty")
		return false
	end
	self:sendSitMessage(wTable, cbChair, nil,false)
	return true
end

-- 主动离开房间
function GameRoom:leftRoom()
	cclog("主动离开房间 leftRoom()")
    self:stopCheckPing()
    self:stopRetry()
    if self:isServicing() then
        -- cclog("GameRoom:leftRoom m_socket:closeconnect")
        self.m_netStatus = NETWORK_STATUS_CLOSE
        self.m_socket:closeconnect()
    end
end

function GameRoom:standup()
	local ba = require("ByteArray").new()
	ba:writeUByte(GameCmds.IDC_USER_STAND_UP)
	self:sendOldGameCmd(GameCmds.CMD_USER,ba:getBuf(),1)
end

-- 发送入座指令
function GameRoom:sendSitMessage(wTableIndex, cbChairID, szTablePass,bCreateTable)
	if not self:isServicing() then return false end
	local RegSit = CMD_GR_Req_UserSit:new()
	RegSit.wNetSpeed = 0
	RegSit.wTableID = wTableIndex
	RegSit.cbChairID = cbChairID
	RegSit.cbCreateTable = bCreateTable and 1 or 0
	RegSit.szTablePass = szTablePass
	cclog("socket sendSitMessage!wTableIndex:%d,cbChairID:%d,szTablePass:%s", wTableIndex, cbChairID, RegSit.szTablePass)
	local ba = RegSit:Serialize()
	self:sendGameCmd(GameCmds.MAIN_GR_USER, GameCmds.SUB_GR_REQ_SIT_TABLE, ba:getBuf(),ba:getLen())   -- sizeof(RegSit)
	return true
end

function GameRoom:sendWatchMessage(wTableIndex, cbChairID)
	cclog("sendWatchMessage "..wTableIndex..";"..cbChairID)
	if not self:isServicing() then return false end

	local RegLonkOn = CMD_GR_Req_UserLookOn:new()
	RegLonkOn.wNetSpeed = 0
	RegLonkOn.wTableID = wTableIndex
	RegLonkOn.cbChairID = cbChairID
	RegLonkOn.cbPassLen = 0
	local ba = RegLonkOn:Serialize()
	self:sendGameCmd(GameCmds.MAIN_GR_USER, GameCmds.SUB_GR_REQ_LOOK_ON_TABLE, ba:getBuf(), ba:getLen())
	return true
end

-- 发送游戏指令(旧协议)
function GameRoom:sendOldGameCmd(cmdID, buf, nLen, CMD)
    cclog("GameRoom:sendOldGameCmd")
	if not self:isServicing() then return false end
    cclog("sending....")
	local ba = require("ByteArray").new()
	ba:writeByte(cmdID)
	if buf ~= nil then 
		ba:writeBuf(buf)
	end
    local cmd = CMD or GameCmds.CMD_GAME
	self.m_socket:sendOldGameCmd(cmd, ba:getBuf(), nLen + 1)
    self.m_dwLastReqTime = getTickCount()
	return true
end

-- 发送指令(旧协议)
function GameRoom:sendOldCmd(cmdID, buf, nLen)
    cclog("GameRoom:sendOldCmd")
	if not self:isServicing() then return false end
    cclog("sending....")
	self.m_socket:sendOldGameCmd(cmdID, buf, nLen)
    self.m_dwLastReqTime = getTickCount()
	return true
end

-- 发送游戏指令(新协议)
function GameRoom:sendGameCmd(mainCmd, subCmd, buf, nLen)
    cclog("GameRoom:sendGameCmd")
	if not self:isServicing() then return false end
    cclog("sending....")
    print(mainCmd, subCmd, 0, buf, nLen)
	self.m_socket:sendGameCmd(mainCmd, subCmd, 0, buf, nLen)
    self.m_dwLastReqTime = getTickCount()
	return true
end

-- 软准备
function GameRoom:sendSoftReady()
	if not self:isServicing() then return false end
	require("GameLib/gamelib/frame/FrameCmds")
	self:sendOldCmd(FrameCmds.CLIENTSITE_SOFT_READY, nil, 0)
end

function GameRoom:sendReady()
	if not self:isServicing() then return false end

	if(self.m_mySelf == nil) then
		return false
	end
	if(self.m_mySelf._status == gamelibcommon.USER_PLAY_GAME) then
		self:sendSoftReady()
		return true
	end
	if(self.m_mySelf._status == gamelibcommon.USER_SIT_TABLE) then
		local ba = require("ByteArray").new()
		ba:writeByte(GameCmds.IDC_USER_AGREE_START)
		self.m_socket:sendOldGameCmd(GameCmds.CMD_USER, ba:getBuf(),ba:getLen())
		return true
	end
	return false
end

function GameRoom:sendOptionsMessage()
	local RoomOption = CMD_GR_RoomOption:new()
	local ba = RoomOption:Serialize()
	self:sendGameCmd(GameCmds.MAIN_GR_CONFIG, GameCmds.SUB_GR_ROOM_OPTION, ba:getBuf(),ba:getLen())
	return true
end

function GameRoom:SendChatMsg(objChatContent)
	local ba = objChatContent:Serialize()
	self.m_socket:sendOldGameCmd(GameCmds.CMD_HTML_HALL_CHAT, ba:getBuf(), ba:getLen())
end

function GameRoom:GetUserName(wUserID)
	local user = self.m_userManager:getUser(wUserID)
	if(user == nil) then
		return ""
	end
	return user._name
end

function GameRoom:GetMyID()
	return self.m_userManager:getMyUserID()
end

function GameRoom:autoSit()
	if((not self:isServicing())) then
		return false
	end
	if(self.m_mySelf == nil) then
		return false
	end
	local cbUserStatus = self.m_mySelf._status

	if(cbUserStatus == gamelibcommon.USER_PLAY_GAME) then
		return false
	end

	local tableID = 0xFFFF
	local chairID = 0xFF - 1
	self:sendSitMessage(tableID, chairID, "",false)	
	return true
end

function GameRoom:getTable(tableID)
	if((not self:isServicing())) then
		return nil
	end
	return self.m_tableManager:getTable(tableID)
end

function GameRoom:getTableList()
	if((not self:isServicing())) then
		return {}
	end
	return self.m_tableManager:getTableList()
end

function GameRoom:getUserByChair(chair)
	if((not self:isServicing())) then
		return nil
	end
	if(self.m_mySelf == nil) then
		return nil
	end
	if(chair >= self.m_tableManager:getChairCount()) then
		return nil
	end
	if(self.m_mySelf._tableID >= self.m_tableManager:getTableCount()) then
		return nil
	end
	for i = 1,self.m_userManager:getUserCount() do
		while true do		
			local user = self.m_userManager.m_userList[i]
			if(user._tableID ~= self.m_mySelf._tableID) then
				break
			end
			if(user._chairID ~= chair) then
				break
			end
			if(user._status >= gamelibcommon.USER_SIT_TABLE and user._status < gamelibcommon.USER_WATCH_GAME) then
				return user
			end
			break
		end
	end
	return nil
end

function GameRoom:getMyself()
	if(self:isServicing()) then
		return self.m_mySelf
	end
	return nil
end

function GameRoom:getMyDBID()
	if(self:isServicing()) then
		return self.m_userManager:getMyDBID()
	end
	return nil
end

function GameRoom:getUser(userindex)
	return self.m_userManager:getUser(userindex)
end

function GameRoom:getUserByDBID(DBID)
	return self.m_userManager:getUserByDBID(DBID)
end

function GameRoom:sendAllUserEnterTableToMe(tableID)
	for i = 1,#self.m_userManager.m_userList do
		local user = self.m_userManager.m_userList[i]
		if(user._tableID == tableID) then
			self.m_clientFrameSink:onUserEnterTable(user._chairID, user._userIndex, user:isPlayer())
		end
	end
end

function GameRoom:sendAllUserExitTableToMe(tableID)
	for i = 1,#self.m_userManager.m_userList do
		local user = self.m_userManager.m_userList[i]
		if(user._tableID == tableID) then
			self.m_clientFrameSink:onUserExitTable(user._chairID, user._userIndex, user:isPlayer())
		end
	end
end

function GameRoom:bindEmail(lpszEMAIL,lpszPassword)
	return false
end

function GameRoom:refreshGold()
	if not self:isServicing() then return end
	cclog("GameRoom:refreshGold()")
	self:sendGameCmd(GameCmds.MAIN_GR_USER,GameCmds.SUB_GR_QUERY_GOLD,nil,0)
end

function GameRoom:sendHallChat(lpszMsg)
	return self:sendChat(lpszMsg,true)
end

function GameRoom:sendTableChat(lpszMsg)
	return self:sendChat(lpszMsg,false)
end

-- 发送聊天
function GameRoom:sendChat(lpszMsg,isHall)
	if not self:isServicing() then return GameCmds.SEND_TABLE_CHAT_OFFLINE end
	if lpszMsg == nil then
		return GameCmds.SEND_TABLE_CHAT_NNULL_CONTENT
	end
	local msg = getGBK(lpszMsg)
	nLen = string.len(msg)
	if(nLen == 0) then
		return GameCmds.SEND_TABLE_CHAT_NULL_CONTENT
	end
-- 是否太频繁
	local nMinTime = 500
	local dwNow = getTickCount()
	if(self.m_dwLastSendTableChat ~= 0 and dwNow - self.m_dwLastSendTableChat < nMinTime) then
		return GameCmds.SEND_TABLE_CHAT_BUSY
	end
	self.m_dwLastSendTableChat = dwNow
	local chat = require("GameLib/common/HtmlChat"):new()
	chat._dwSpeaker = self.m_mySelf:getUserID()
	chat._dwListener = 0xFFFFFFFF
	chat._dwSubCode = 0
	chat._dwChannelIDLength = 4
	chat:setChatMsg(msg)
	local ba = chat:Serialize()
	local cmd = (isHall and  GameCmds.CMD_HTML_HALL_CHAT or GameCmds.CMD_HTML_TABLE_CHAT)
    cclog("GameRoom:sendChat cmd:%x  speaker:%s  msg:%s",cmd, self.m_mySelf:getUserID(), msg)
	self:sendOldCmd(cmd, ba:getBuf(),ba:getLen())
	return GameCmds.SEND_TABLE_CHAT_OK
end

function GameRoom:getRelativePos(cbChair)
	if(cbChair == 255) then
		return 0
	end
	if(cbChair >= self.m_tableManager:getChairCount()) then
		return cbChair
	end
	if(self.m_mySelf == nil) then
		return cbChair
	end
	local cbMyChair = self.m_mySelf:getUserChair()
	if(cbMyChair >= self.m_tableManager:getChairCount()) then
		cbMyChair = self.m_cbLastChairID
	end

	if(cbMyChair < 0 or cbMyChair >= self.m_tableManager:getChairCount()) then
		return cbChair
	end
	return (cbChair + self.m_tableManager:getChairCount() - cbMyChair) % self.m_tableManager:getChairCount()	
end

function GameRoom:getRealChair(cbPos)
	if(cbPos >= self.m_tableManager:getChairCount()) then
		return cbPos
	end
	if(self.m_mySelf == nil) then
		return cbPos
	end
	local cbMyChair = self.m_mySelf:getUserChair()
	if(cbMyChair >= self.m_tableManager:getChairCount()) then
		cbMyChair = self.m_cbLastChairID
	end
	if(cbMyChair < 0 or cbMyChair >= self.m_tableManager:getChairCount()) then
		return cbPos
	end
	return (cbPos + cbMyChair) % self.m_tableManager:getChairCount()
end

function GameRoom:useProperty(nPropertyID,nCount,nToUserID)
	return true
end

function GameRoom:isPrivteRoom()
	return self.m_bIsPrivateRoom
end

function GameRoom:createPrivateTable(pServer,userID,password,version,lpszPassword)

	-- 这里要判断用户是否已经进入房间
	if(self:isServicing() and self:isPrivteRoom()) then
		local tableID = 0xFFFF
		local chairID = 0xFF
		self:sendSitMessage(tableID, chairID, lpszPassword,true)
		return true
	end

	if(lpszPassword == nil or string.len(lpszPassword) == 0) then
		return false
	end

	return self:enterGameRoom(pServer,userID,password,version,0,gamelibcommon.PRIVATE_ROOM_CREATE,lpszPassword)
end

function GameRoom:enterPrivateTable(pServer,userID,password,version,lpszPassword)
	-- 这里要判断用户是否已经进入房间
	if(self:isServicing() and self:isPrivteRoom()) then
		local tableID = 0xFFFF
		local chairID = 0xFF
		self:sendSitMessage(tableID, chairID, lpszPassword,false)
		return true
	end
	self.m_szPrivateTablePassword = lpszPassword

	return self:enterGameRoom(pServer,userID,password,version,0,gamelibcommon.PRIVATE_ROOM_ENTER,lpszPassword)
end

function GameRoom:kickUserOutOfTable(wUserID)
	if((not self:isServicing())) then
		return false
	end
	if(self.m_mySelf == nil) then
		return false
	end

	if(self.m_mySelf:getUserStatus() < gamelibcommon.USER_SIT_TABLE) then
		cclog("kickUserOutOfTable self.m_mySelf:getUserStatus() < USER_SIT_TABLE")
		return false
	end
	local userItem = self.m_userManager:getUser(wUserID)
	if(userItem == nil) then
		cclog("kickUserOutOfTable userItem == nil")
		return false
	end
	if(userItem.getUserStatus() == gamelibcommon.USER_PLAY_GAME 
		or userItem.getUserStatus() == gamelibcommon.USER_OFF_LINE) then
		cclog("userItem.getUserStatus() == USER_PLAY_GAME or userItem.getUserStatus() == USER_OFF_LINE")
		return false
	end
	
	-- 发送命令
	local ba = require("ByteArray").new()
	ba:writeShort(wUserID)
	sendOldGameCmd(FrameCmds.CLIENTSITE_MASTER_KICK,ba:getBuf(),2)
	return true
end

function GameRoom:amITableOP()
	if not self:isServicing() then return false end 
	if(self.m_mySelf == nil) then
		return false
	end
	if(self.m_mySelf:getUserStatus() < gamelibcommon.USER_SIT_TABLE) then
		return false
	end
	if(not self:isPrivteRoom()) then
		return false
	end
	if(self.m_cbEnterType ~= gamelibcommon.PRIVATE_ROOM_CREATE) then
		return false
	end
	if(self.m_mySelf:getUserChair() ~= 0) then
		return false
	end
	return true
end					

function GameRoom:sendSoundToTableUser(pBuf,nLen)
	if not self:isServicing() then return false end
	if(self.m_mySelf == nil) then
		return false
	end
	if(self.m_mySelf:getUserStatus() < gamelibcommon.USER_SIT_TABLE) then
		return false
	end
	self:sendOldGameCmd(FrameCmds.CLIENTSITE_SEND_SOUND,pBuf,nLen)
	return true
end

function GameRoom:gameBankIn(nGold)
	if not self:isServicing() then return false end
	-- 判断我的vip是否可以存这么多
	local vipInfo = self.m_pGameLib:getVIPInfo(self.m_pGameLib:getUserLogonInfo().nVIPLevel)
	if vipInfo == nil then return false end

	if vipInfo.nBankLimit < nGold + self.m_mySelf:getBankAmount() then return false end

	local s = SBankOperation:new()
	s.cbOperation = 1
	s.nGold = nGold
	local ba = s:Serialize()
	self:sendGameCmd(GameCmds.MAIN_GR_USER, GameCmds.SUB_GR_BANK, ba:getBuf(),ba:getLen())
	return true
end

function GameRoom:gameBankOut(nGold,szPassword)
	if not self:isServicing() then return end
	if nGold > self.m_mySelf:getBankAmount() then return false end
	local s = SBankOperation:new()
	s.cbOperation = 0
	s.nGold = nGold
	s.szPsw = szPassword
	local ba = s:Serialize()	
	self:sendGameCmd(GameCmds.MAIN_GR_USER, GameCmds.SUB_GR_BANK, ba:getBuf(),ba:getLen())
end

function GameRoom:transfer(toUserDBID,amount,szPassword)
	if not self:isServicing() then return end
	if nGold > self.m_mySelf:getGold() then return false end
	local ba = require("ByteArray").new()
	ba:writeInt(toUserDBID)
	ba:writeInt(amount)
	ba:writeString(szPassword)
	for i = 1,16 - string.len(szPassword) do
		ba:writeByte(0)
	end
	self:sendGameCmd(GameCmds.MAIN_GR_USER, GameCmds.SUB_GR_ROOM_TRANSFER, ba:getBuf(),ba:getLen())
	return true
end

-- 房间网络服务状态
function GameRoom:isServicing()
	if(self.m_socket == nil) then
		return false
	end
	return self.m_socket:isConnected()
end

-- 发送Ping指令
function GameRoom:sendPingCmd()
	-- cclog("sendPingCmd ")
	local ba = require("ByteArray").new()
	ba:writeUByte(GameCmds.IDC_PING_ME)
	ba:writeUInt(getTickCount())
	self.m_socket:sendOldGameCmd(GameCmds.CMD_PING_USER,ba:getBuf(),ba:getLen())
    self.m_dwLastReqTime = getTickCount()
end

-- 收到Pong
function GameRoom:recvAnswerPing()
	self.m_nNetLag = getTickCount() - self.m_dwLastReqTime
	-- cclog("recv Ping LAG: " .. self.m_nNetLag)
	return true
end

-- 开始checkPing轮询
function GameRoom:startCheckPing()
    cclog("GameRoom:startCheckPing()")
	if self.CHECK_PING ~= nil then
		return
	end
	self.CHECK_PING = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
        self:checkNetWork()
    end, 0.2, false)
end

-- 停止checkPing轮询
function GameRoom:stopCheckPing()
    cclog("GameRoom:stopCheckPing()")
	if self.CHECK_PING == nil then
		return
	end
	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.CHECK_PING)
	self.CHECK_PING = nil
    self:stopRetry()
end

-- gameRoom checkNetWork 轮询
function GameRoom:checkNetWork()
    -- cclog("GameRoom:checkNetWork()")
    local now = getTickCount()
    -- 第一次从后台切至前台时, 仅重发Ping指令
    if NETWORK_BACKTOFOREGROUND then
        NETWORK_BACKTOFOREGROUND = nil
        self.m_dwLastRespTime = now
        self:sendPingCmd()
    -- 时间戳检查
    else
        -- 仅在网络正常工作状态中检查
        if self.m_netStatus == NETWORK_STATUS_CONNECTED then
            -- 如果上次收到消息的时间小于断线时长
            if now - self.m_dwLastRespTime < NETWORK_TIMEOUT and self:isServicing() then
                -- 如果上次发送消息的时间大于心跳间隔，则发送心跳
                if now - self.m_dwLastReqTime >= NETWORK_PING_INTERVAL then
                    self:sendPingCmd()
                end
            -- LAG超时则进行重连
            else
                self:stopCheckPing()
                self.m_netStatus = NETWORK_STATUS_RETRY
                self.m_dwRetryTimes = 1
                self:tryToReconnecting("checkNetWork")
            end
        else
            ccerr("wrong checkNetWork been called. statu: " .. tostring(self.m_netStatus))
        end
    end
end

-- gameRoom tryToReconnecting 轮询
function GameRoom:tryToReconnecting(s)
    cclog("GameRoom:tryToReconnecting() by "..tostring(s))
    self:stopRetry()
    local pScene = CCDirector:sharedDirector():getRunningScene()
    if not pScene.retryPanel then
        pScene.retryPanel = require("Lobby/Common/LobbySecondDlg").putTip(
            pScene, 9999, string.format("您当前的网络状况不太稳定\n正在第 %d 次重连...", self.m_dwRetryTimes), 
            function()
                self.m_dwRetryTimes = 1
                self:stopCheckPing()
                self:tryToReconnecting("btn rerty")
                for i = 1, 2 do pScene.retryPanel["btnItem"..i]:setVisible(false) end
                pScene.retryPanel:show()
            end,
            function()
                self:clear()
                if require("LobbyControl").gameLogic then
                    AudioEngine.stopMusic(true)
                    require("LobbyControl").backToLogon()
                else
                    require("Lobby/FriendGame/FriendGameLogic").enterGameRoomFail()		
                end
            end,
            kCCTextAlignmentCenter)
        pScene.retryPanel.tip_lab:setDimensions(CCSizeMake(pScene.retryPanel.bg_sz.width - 80, 90))
        for i = 1, 2 do pScene.retryPanel["btnItem"..i]:setVisible(false) end
        pScene.retryPanel:show()
    else
        pScene.retryPanel.tip_lab:setString(
            string.format("您当前的网络状况不太稳定\n正在第 %d 次重连...", self.m_dwRetryTimes))
        pScene.retryPanel.tip_lab:setDimensions(CCSizeMake(pScene.retryPanel.bg_sz.width - 80, 90))
    end
    self:reconnect()
end

-- gameRoom 重新创建Scocket并连接服务器
function GameRoom:reconnect()
    cclog("GameRoom:reconnect()")
	if self.m_uPort == nil then
		return
	end
	if self.m_dwServerIP == nil and self.m_strServerIP == nil then
		return
	end
	if(self:isServicing()) then
        -- cclog("GameRoom:reconnect m_socket:closeconnect")
		self.m_socket:closeconnect()
	end
    if self.m_socket then
		self.m_socket:Release()
        self.m_socket = nil
    end
	if(self.m_socket == nil) then
		self.m_socket = CCSocket:createCCSocket()
		self.m_socket:init()
	end
	if self.m_strServerIP then
		self.m_socket:connect(self.m_strServerIP,self.m_uPort)
	else
		self.m_socket:connectInt(self.m_dwServerIP,self.m_uPort)
	end
end

-- gameRoom 停止重试队列
function GameRoom:stopRetry()
    cclog("GameRoom:stopRetry()")
    if self.RETRYCONNECT then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.RETRYCONNECT)
        self.RETRYCONNECT = nil
    end
end

-- gameRoom 重连接成功回调
function GameRoom:reconnectSuccess()
    cclog("GameRoom:reconnectSuccess()")
    self:stopRetry()
    self.m_dwLastRespTime = getTickCount()
    self.m_dwRetryTimes = 1
    self.m_netStatus = NETWORK_STATUS_CONNECTED
    local pScene = CCDirector:sharedDirector():getRunningScene()
    if pScene.retryPanel then
        pScene.retryPanel.tip_lab:setString("重连成功! 所有数据校验正常")
        pScene.retryPanel.tip_lab:setDimensions(CCSizeMake(pScene.retryPanel.bg_sz.width - 80, 30))
        pScene.retryPanel:runAction(CCSequence:createWithTwoActions(
            CCDelayTime:create(1),
            CCCallFuncN:create(function(sender)
                sender:removeFromParentAndCleanup(true)
                pScene.retryPanel = nil
            end)
        ))
    end
    self:startCheckPing()
end

-- gameRoom 重连接失败回调
function GameRoom:reconnectFail()
    cclog("GameRoom:reconnectFail()")
    self:stopRetry()
    self.m_dwRetryTimes = 1
    local pScene = CCDirector:sharedDirector():getRunningScene()
    if pScene.retryPanel then
        pScene.retryPanel.tip_lab:setString("连接失败，需要继续尝试重连吗?")
        pScene.retryPanel.tip_lab:setDimensions(CCSizeMake(pScene.retryPanel.bg_sz.width - 80, 30))
        for i = 1, 2 do pScene.retryPanel["btnItem"..i]:setVisible(true) end
    else
        self:clear()
        self.m_sink:onRoomConnectClosed()
    end
end

-- gameRoom 重连时加入好友桌失败回调
function GameRoom:reAddFriendTableFail(errCode)
    cclog("GameRoom:reAddFriendTableFail()")
    local msg = self.m_sink and self.m_sink.error_msg or "加入好友桌失败"
    
    -- 关闭房间连接
    self:clear()
    
    -- 返回处理
    local function callback()
        if require("LobbyControl").gameLogic then
            AudioEngine.stopMusic(true)
            require("LobbyControl").backToLogon()
        else
            require("Lobby/FriendGame/FriendGameLogic").enterGameRoomFail()
        end
    end
    
	if require("LobbyControl").gameLogic then
        if errCode == 0x05020100 then       -- RET_ADD_FRIEND_TABLE_NONEXISTENT
            msg = "由于您长时间未进行操作\n当前好友桌已结束或解散\n请返回大厅重新加入其他房间"
        elseif errCode == 0x05020200 then   -- RET_ADD_FRIEND_TABLE_FULL
            msg = "由于您长时间未进行操作\n当前好友桌已开局\n请返回大厅重新加入其他房间"
        end
        local pScene = CCDirector:sharedDirector():getRunningScene()
        if pScene.retryPanel then
            pScene.retryPanel:stopAllActions()
            pScene.retryPanel.confrim_func = callback
            pScene.retryPanel.tip_lab:setString(msg)
            pScene.retryPanel.tip_lab:setDimensions(CCSizeMake(pScene.retryPanel.bg_sz.width - 80, 120))
            pScene.retryPanel["btnItem1"]:setVisible(false)
            pScene.retryPanel["btnItem2"]:setPosition(ccp(pScene.retryPanel.bg_sz.width/2, 68))
            pScene.retryPanel["btnItem2"]:setVisible(true)
            pScene.retryPanel:show()
        else
            pScene.retryPanel = require("Lobby/Common/LobbySecondDlg").putTip(
                pScene, 9999, msg, callback, function() end, kCCTextAlignmentCenter)
            pScene.retryPanel.tip_lab:setDimensions(CCSizeMake(pScene.retryPanel.bg_sz.width - 80, 120))
            pScene.retryPanel["btnItem1"]:setVisible(false)
            pScene.retryPanel["btnItem2"]:setPosition(ccp(pScene.retryPanel.bg_sz.width/2, 68))
            pScene.retryPanel["btnItem2"]:setVisible(true)
            pScene.retryPanel:show()
        end
	else
		require("Lobby/FriendGame/FriendGameLogic").enterGameRoomFail(msg)
	end
end

-- gameRoom 创建好友桌失败回调
function GameRoom:onCreateFriendTableFail(dwErrorCode)
    cclog("GameRoom:onCreateFriendTableFail(): "..tostring(dwErrorCode))
    self:stopRetry()
    self.m_netStatus = NETWORK_STATUS_UNCONNECTED
    if pScene.retryPanel then
        pScene.retryPanel:removeFromParentAndCleanup(true)
        pScene.retryPanel = nil
    end
    self.m_sink:onCreateFriendTableFailed(dwErrorCode)
end

function GameRoom:showErrMsg(msg)

end

function GameRoom:getNetLag()
	if not self:isServicing() then
		return 0
	end
	return self.m_nNetLag
end

function GameRoom:getUserList()
	if not self:isServicing() then
		return {}
	end
	return self.m_userManager.m_userList
end


return GameRoom