require("GameLib/common/common")
require("FFSelftools/SqliteHelper")

local GameDefs = require("gdmj/GameDefs")

local GameLibSink = { }
GameLibSink.__index = GameLibSink
GameLibSink.lobby_control = nil
GameLibSink.server_name = nil
GameLibSink.game_type = nil --默认为好友模式、1为练习模式

GameLibSink.game_lib = nil
GameLibSink.client_sink = nil

function GameLibSink:new(hallControl)
  local self = {}
  setmetatable(self,GameLibSink)  
  self.lobby_control = hallControl
  return self
end

function GameLibSink:run(logonIP,logonPort,webRoot,gametype)
	GameDefs.CommonInfo.Game_ID = require("Lobby/FriendGame/FriendGameLogic").game_id
	cclog("create game id :"..GameDefs.CommonInfo.Game_ID)
  	-- 创建gamelib
  	self.game_lib = CGameLibLua:new()
  	GameLibSink.game_lib = self.game_lib
  	self.client_sink = require(GameDefs.CommonInfo.ClientFrame_File):new()
  	self.game_lib:createGamelib(GameDefs.CommonInfo.Game_ID, GameDefs.CommonInfo.Game_Version,
  	 	self, self.client_sink, require("AppConfig").CONFINFO.PartnerID, require("GameConfig").getGameVer("gdmj"),
  		logonIP, logonPort, webRoot)

  	self.game_type = gametype or 0
  	GameLibSink.game_type = self.game_type

  	self.forbid_server = {}
  	--[[local currentScene = CCDirector:sharedDirector():getRunningScene()
  	local WelcomeLayer = require(GameDefs.CommonInfo.Code_Path.."Start/WelcomeLayer")
  	local pScene = WelcomeLayer.createScene()
  	if (currentScene ~= nil) then
		    CCDirector:sharedDirector():replaceScene(pScene)
  	else
        CCDirector:sharedDirector():runWithScene(pScene)
    end]]
end

function GameLibSink:getTableUserList(tableID)
    local users = {}
    for i,v in ipairs(self.game_lib._gameRoom.m_userManager.m_userList) do
    	if v:getUserTableID() == tableID then
    		table.insert(users, v)
    	end
    end

    return users
end

function GameLibSink:getMyInfo()
    return GameLibSink.game_lib._gameRoom.m_mySelf
end

function GameLibSink:exit()
	if require("LobbyControl").gameSink ~= nil then
		require(GameDefs.CommonInfo.Code_Path.."Game/GameLogic"):dispose()	
		require("LobbyControl").gameSink = nil
		self.game_lib:leaveGameRoom()
	   	self.game_lib:release()
	    self.game_lib = nil
	end
end

function GameLibSink:onLogonFinished(lUserDBID,szName,szPass)
	local serverName = nil
	if self.game_type == 1 then
		serverName = self.game_lib:autoEnterRoomByName("练习场")
	else
		self.server_name = self.game_lib:autoEnterFriendRoom(require("Lobby/FriendGame/FriendGameLogic").server_name)
		serverName = self.server_name
	end
	if not serverName then
		local tipmsg = self:getErrorAlertMsg("游戏尚未开放，请稍后再试")
		if require("LobbyControl").gameLogic then
			require("LobbyControl").backToLogon(tipmsg)
		else
			require("Lobby/FriendGame/FriendGameLogic").enterGameRoomFail(tipmsg)
		end
	end
end

function GameLibSink:onPlazaGoldChanged()
	cclog("onPlazaGoldChanged")
    --CCNotificationCenter:sharedNotificationCenter():postNotification(FruitDefs.NOTIFICATION_UPDATEMYINFO)
end

function GameLibSink:onRefreshUserInfo()
	cclog("onRefreshUserInfo")
    --CCNotificationCenter:sharedNotificationCenter():postNotification(FruitDefs.NOTIFICATION_UPDATEMYINFO)
end

function GameLibSink:onChargeInfoRefeshRet(result)
  	local logonInfo = self.game_lib:getUserLogonInfo()
  		if (logonInfo ~= nil) then
    	local pScene = CCDirector:sharedDirector():getRunningScene()
        if (pScene == nil) then
            return
        end
  	end
end

-- 	// 登陆失败
-- 	// nFailType:1 = 网络错误，2 = 服务器提示失败 3 = 开放平台登陆失败
function GameLibSink:onLogonFailed(errorStr,nFaileType)
	cclog("onLogonFailed "..nFaileType..";"..errorStr)

	if require("LobbyControl").gameLogic then
		require("LobbyControl").backToLogon(errorStr)
	else
		require("Lobby/FriendGame/FriendGameLogic").enterGameRoomFail(errorStr)
	end	
end

--进入房间成功
function GameLibSink:onEnteredGameRoom(tableCount,chairCount)
  	local pServer = self.game_lib:getCurrentServer()
  	if (pServer == nil) then
    	return
  	end

  	local tableID, myself = -1, self:getMyInfo()
  	if myself then tableID = myself:getUserTableID() end

	if self.game_type == 1 then
		self:onEnteredTrainingRoom(tableID)
	else
		self:onEnteredFriendRoom(tableID)
  	end

end

function GameLibSink:onEnteredTrainingRoom(tableID)
	--设置游戏规则 练习场定死
	local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
	FriendGameLogic.my_rule = {}
	FriendGameLogic.game_used = 1

	if tableID < 0 then
		self.game_lib:autoSit()
		FriendGameLogic.game_used = 0
	end
	
	FriendGameLogic.game_abled = FriendGameLogic.game_used > 0
	FriendGameLogic.invite_code = 666666

	--局数
	table.insert(FriendGameLogic.my_rule, {2, 1})
	--番型
	table.insert(FriendGameLogic.my_rule, {3, 1})
	--红中赖子
	table.insert(FriendGameLogic.my_rule, {4, 2})
	--大胡
	table.insert(FriendGameLogic.my_rule, {5, 1})	
end

function GameLibSink:onEnteredFriendRoom(tableID)
	local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
  	if tableID >= 0 or FriendGameLogic.game_over then
  		--断线重回
  	else
  		if FriendGameLogic.server_name then
  			--重回好友桌
  			cclog("重回好友桌"..FriendGameLogic.friend_tableID..";"..FriendGameLogic.invite_code)
  			self.game_lib:returnFriendTable(FriendGameLogic.friend_tableID, FriendGameLogic.invite_code)
  		else
  			--创建好友桌
  			local mode, number, options = FriendGameLogic.getGameRule()	 		
	  		if not self.game_lib:createFriendTable(require("AppConfig").CONFINFO.PartnerID, mode, number, options) then
		  		--失败
		  		self:onCreateFriendTableFailed()
	  		end  			
  		end		
  	end
end

function GameLibSink:onCreateFriendTableFailed(errorCode)
	if errorCode == 0x05010100 then
		local myVip = 0--require("Lobby/Login/LoginLogic").UserInfo.VIPLevel
		table.insert(self.forbid_server, self.server_name)
		local servers = self.game_lib:getAllRoomByJudge(function(server)
			return server.cbPrivateRoom ~= 0 and server.cbMinCreateTableVIP <= myVip
		end)
		
		local function findServer(s)
			local server = nil
			for j,w in ipairs(self.forbid_server) do
				if s ~= w then
					server = s
				else
					server = nil
					break
				end
			end

			return server
		end
		local serverName = nil
		for i,v in ipairs(servers) do
			serverName = findServer(v)
			if serverName then
				break
			end
		end

		if serverName then
			self.server_name = self.game_lib:autoEnterFriendRoom(serverName)
			return
		end
	end

	local tipmsg = self:getErrorAlertMsg("好友桌已满，请稍后再试")
	if require("LobbyControl").gameLogic then
		require("LobbyControl").backToLogon(tipmsg)
	else
		require("Lobby/FriendGame/FriendGameLogic").enterGameRoomFail(tipmsg)
	end
end

function GameLibSink:onCreateFriendTableSuccend(exprireTime, validTime)
	--创建成功，已经坐桌
	require("Lobby/FriendGame/FriendGameLogic").server_name = self.server_name
	require(GameDefs.CommonInfo.Code_Path.."Game/GameLogic"):getInstance():onRecveSocketData({4, {self:getMyInfo():getUserDBID(), exprireTime, validTime}})
end

--房主解散通知
function GameLibSink:onDismissFriendTableMessage()
	require("Lobby/FriendGame/FriendGameLogic").onDismissBack()

	if not require("Lobby/FriendGame/FriendGameLogic").game_abled then
		--没有开始游戏
		

		require(GameDefs.CommonInfo.Code_Path.."Game/GameLogic"):getInstance():onRecveSocketData({5, {}})
	end
end

--解散投票通知
function GameLibSink:onDismissTableNoticeMessage(userID, cbWaitTime)
	local player = "玩家"..self.game_lib:getUserByDBID(userID):getUserName()
    
    local super = require(GameDefs.CommonInfo.Code_Path.."Game/GameLogic"):getInstance().main_layer
    require("Lobby/FriendGame/FriendGameLogic").showFriendVoteDlg(
                    super, super.tipdlg_zIndex, player, cbWaitTime, self)
end

--解散投票结果广播
function GameLibSink:onFriendTableVoteMessage(master, masterid, bfinish, bsuccend, voteinfo, cbWaitTime)
    local super = require(GameDefs.CommonInfo.Code_Path.."Game/GameLogic"):getInstance().main_layer
    require("Lobby/FriendGame/FriendGameLogic").addVoteResultDlg(
                    super, super.tipdlg_zIndex, master, masterid, voteinfo, cbWaitTime, self)
    
    if bfinish ~= 0 then
	    require("Lobby/FriendGame/FriendGameLogic").showVoteResult(
	                    super, super.tipdlg_zIndex, bsuccend, self, voteinfo) 
	    --设置游戏结束标示
		require(GameDefs.CommonInfo.Code_Path.."Game/GameLogic"):getInstance().bGameEnd = (bsuccend ~= 0)                       	
    end
end

function GameLibSink:onFriendTableAddFailed()
	cclog("onFriendTableAddFailed ")
	local tipmsg = self:getErrorAlertMsg("加入好友桌失败")
	if require("LobbyControl").gameLogic then
		require("LobbyControl").backToLogon(tipmsg)
	else
		require("Lobby/FriendGame/FriendGameLogic").enterGameRoomFail(tipmsg)
	end	
end

function GameLibSink:onFriendTableAddSuccend()
	--创建成功，已经坐桌	
end

function GameLibSink:onFriendTableRuleMessage(gamenum, options, cbMasterUserDBID, exprireTime, validTime, bAbled)
	local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
	cclog("GameLibSink:onFriendTableRuleMessage "..gamenum)

	FriendGameLogic.my_rule = {}
	--局数
	table.insert(FriendGameLogic.my_rule, {2, gamenum})
	--番型
	--table.insert(FriendGameLogic.my_rule, {3, options[1][2]})

    --其他规则
    for i=1,#options do
        if options[i][2] >= 0 then
            table.insert(FriendGameLogic.my_rule, {options[i][1], options[i][2]})
        end
    end

    require(GameDefs.CommonInfo.Code_Path.."Game/GameLogic"):getInstance():onRecveSocketData({4, {cbMasterUserDBID, exprireTime, validTime}})
end

function GameLibSink:onFriendTableAbledMessage()
	if require("Lobby/FriendGame/FriendGameLogic").game_used < 1 then
		require(GameDefs.CommonInfo.Code_Path.."Game/GameLogic"):getInstance():onRecveSocketData({6, {}})
	end
end

function GameLibSink:onFriendTableEndMessage(infoList)
	require(GameDefs.CommonInfo.Code_Path.."Game/GameLogic"):getInstance():onRecveSocketData({7, {infoList}})
end

-- 	// 进入房间失败
function GameLibSink:onEnterGameRoomFailed(errorStr)
	if require("LobbyControl").gameLogic then
		require("LobbyControl").backToLogon(errorStr)
	else
		require("Lobby/FriendGame/FriendGameLogic").enterGameRoomFail(errorStr)			
	end
end

-- 	// 房间连接断开了
function GameLibSink:onRoomConnectClosed()
	cclog("GameLibSink:onRoomConnectClosed")
	local errorStr = self:getErrorAlertMsg("房间连接断开了")
	if require("LobbyControl").gameLogic then
		require("LobbyControl").backToLogon(errorStr)
	else
		require("Lobby/FriendGame/FriendGameLogic").enterGameRoomFail(errorStr)		
	end
end

-- 	//坐下桌子
function GameLibSink:onSitTable(tableID, cbChair)
	cclog("onSitTable ")
	self.game_lib:autoSit()
end

-- 	// 进入桌子
function GameLibSink:onEnterGameView()
	if self.game_type == 1 then
		require(GameDefs.CommonInfo.Code_Path.."Game/GameLogic"):getInstance():onRecveSocketData({4, {}})
  	end
end

-- 	// 离开桌子
function GameLibSink:onLeaveGameView()
	cclog("onLeaveGameView")
	require(GameDefs.CommonInfo.Code_Path.."Game/GameLogic"):getInstance():onRecveSocketData({5, {}})
	--require("LobbyControl").backToHall()
end

-- 	// 用户进入消息
function GameLibSink:onRoomUserEnter(userID)
	cclog("onRoomUserEnter "..userID)
end

-- 	// 用户离开消息
function GameLibSink:onRoomUserExit(userID)
	cclog("onRoomUserExit")
end

-- 	// 用户信息更新，通常触发分数、金币、VIP等消息更新dengxia
function GameLibSink:onRoomUserInfoUpdated(userID)
	--cclog("onRoomUserInfoUpdated")
    local pMyself = self:getMyInfo()
	if (pMyself == nil) or pMyself:getUserChair() < 0 then
		return
    end
	--自己的信息被改变，进行信息更改(此处在SIT_TABLE时才更新信息)
	if (userID == pMyself:getUserID()) then
		local logonInfo = self.game_lib:getUserLogonInfo()
		logonInfo.dwGold = pMyself:getGold()
		logonInfo.nScore = pMyself:getScoreField(gamelibcommon.enScore_Score)
		logonInfo.nWin = pMyself:getScoreField(gamelibcommon.enScore_Win)
		logonInfo.nLose = pMyself:getScoreField(gamelibcommon.enScore_Loss)
		logonInfo.nFlee = pMyself:getScoreField(gamelibcommon.enScore_Flee)
		logonInfo.nDraw = pMyself:getScoreField(gamelibcommon.enScore_Draw)
		logonInfo.nVIPLevel = pMyself:getVIPLevel()
	end

	local userInfo = self.game_lib:getUser(userID)
	local GameLogic = require(GameDefs.CommonInfo.Code_Path.."Game/GameLogic")

	if userInfo:isPlayer() and  userInfo:getUserChair() >= 0 
		and pMyself:getUserTableID() == userInfo:getUserTableID()  and
		GameLogic.isLogicExist() and GameLogic:getInstance().main_layer then
		userInfo._score = userInfo:getScore()
		GameLogic:getInstance():onRecveSocketData({8, {userInfo, pMyself}})
	end
	

end

-- 	// 桌子状态发生改变消息
function GameLibSink:onTableInfoChanged(tableID)
	--cclog("onTableInfoChanged")
end

-- 	// 收到大厅聊天，目前不会收到
function GameLibSink:onRecvHallChat(chat)
	cclog("onRecvHallChat")
end
-- 	// 收到游戏内聊天消息
function GameLibSink:onRecvTableChat(chat)
	if not require(GameDefs.CommonInfo.Code_Path.."Game/GameLogic"):getInstance().main_layer then
		return
	end

    local uid = self.game_lib:getUser(chat._dwSpeaker):getUserID()
    local c = split(chat:getChatMsg(), "|")
	cclog("[onRecvTableChat] speaker:%s tag:%s msg:%s",uid, c[1], c[2])
    -- 语音处理
    if c[1] == "@VOICE" and YVIMTool._inst then
        table.insert(YVIMTool._inst.recordList, 1, {[uid]=c[2]})
    -- 表情处理
    elseif c[1] == "@EMOTE" then
        if layerChat then table.insert(layerChat.chatList[1],{[uid]=c[2]}) end
    -- 快捷处理
    elseif c[1] == "@QUICK" then
        if layerChat then table.insert(layerChat.chatList[2],{[uid]=c[2]}) end
    -- 文字处理
    elseif c[1] == "@TEXTC" then
        if layerChat then
            table.insert(layerChat.chatList[3],{[uid]=c[2]})
            table.insert(layerChat.chatHistory,{[uid]=c[2]})
            if #layerChat.chatHistory > 10 then table.remove(layerChat.chatHistory, 1) end
        end
    end
    --[[
	cclog("onRecvTableChat" .. chat:getChatMsg())
    local pScene = CCDirector:sharedDirector():getRunningScene()
	if (pScene:getTag() == FruitDefs.FRUITMACHINE_SCENE_TAG) then
		if (pScene:getChildByTag(FruitDefs.FRUITMACHINE_SCENE_LAYER_TAG) ~= nil) then
			local pFruitMachineLayer = pScene:getChildByTag(FruitDefs.FRUITMACHINE_SCENE_LAYER_TAG)
			pFruitMachineLayer:onRecvTableChat(chat)
		end
	end
    ]]
end

-- 	// 显示游戏内系统消息
function GameLibSink:onShowGameSystemMsg(msg)
	cclog("onShowGameSystemMsg" .. msg)
	require("HallUtils").showWebTip(msg)
end

-- 	// 显示弹出消息
function GameLibSink:onShowAlertMsg(msg)
	cclog("onShowAlertMsg" .. msg)    

    self.error_msg = nil
    if string.find(msg, "error:") then
    	msg = string.gsub(msg,"error:", "")
    	self.error_msg = msg
    end

    require("HallUtils").showWebTip(msg)
end

-- 	// 显示弹出消息
function GameLibSink:getErrorAlertMsg(msg)
	local tipmsg = self.error_msg or msg
	self.error_msg = nil
	return tipmsg
end

-- 	// 登陆房间成功
function GameLibSink:onLogonGameRoomSucceeded()
	cclog("onLogonGameRoomSucceeded")
end

function GameLibSink:onGetDeviceID()
	cclog("onGetDeviceID")
end

-- 	// 坐下失败
function GameLibSink:onSitFailed(msg)
	cclog("onSitFailed")
end

-- 	//--操作结果描述：1=操作成功  11=该账号已经绑定邮箱  12=存在相同邮箱
function GameLibSink:onBindEmailRet(cbRetCode)
	cclog("onBindEmailRet")
end

-- 	// 有大喇叭消息
-- 	// nPriorty 优先级，数字越小优先级越高
function GameLibSink:onSpeaker(lpszMsg,nPriorty)
	cclog("onSpeaker")
    local curscene = CCDirector:sharedDirector():getRunningScene()
    local tag = curscene:getTag()
	if (tag == FruitDefs.FRUITMACHINE_SCENE_TAG) then
        local layer = curscene:getChildByTag(FruitDefs.FRUITMACHINE_SCENE_LAYER_TAG)
		if (layer ~= nil) then
			local pSpeaker = layer:getChildByTag(FruitDefs.SPEAKER_NODE_TAG)
            pSpeaker:setVisible(true);
			pSpeaker:speak(lpszMsg, nPriorty)
		end
    end
end

-- 	// 修改资料返回通知
-- 	//--操作结果描述： 1=操作成功  其他：失败
function GameLibSink:onChangeUserInfoRet(cbRetCode)
	cclog("onChangeUserInfoRet")
end

-- 	// 获取头像数据返回
function GameLibSink:onGetFaceDataRet(dwDBID,cbFaceIndex,nFaceDataLen,pData)
	cclog("onGetFaceDataRet xxx "..nFaceDataLen..";"..dwDBID..";"..string.len(pData)..";"..pData)
    if (nFaceDataLen > 0) then
        require("FFSelftools/CCUserFace").update(nil, dwDBID)
        require("GameLib/common/EventDispatcher"):instance():dispatchEvent(
            require("FFSelftools/CCUserFace").RECEIVENEWFACE, {dbid = dwDBID}
        )
	end
end

-- 	// 获取任务列表返回 1=操作成功 11=传入参数错误n
function GameLibSink:onTaskInfo(cbRetCode,pTaskList)
	cclog("onTaskInfo-----------------------")
end

-- 	// 领取任务返回  1=操作成功  11=没有领取的任务  12=传入参数错误
function GameLibSink:onTaskGift(nTaskID,cbRetCode)
	cclog("onTaskGift")
end

-- 	// 破产保护返回 1 = 操作成功，11=今日已领取完 12 = 金币过多  13=链接超时
--nGold/*领取金币数量*/
--nLeftTime/*剩余次数*/
function GameLibSink:onBankruptProtect(cbRetCode,nGold,nLeftTime)
	cclog("onBankruptProtect")
end

-- 	// 苹果充值回调,如果成功，lpszError可能为NULL,充值成功注意刷新金币的显示
function GameLibSink:onAppleChargeRet(bSucceeded,lpszError)
	cclog("onAppleChargeRet")
    FruitDefs.HideLoadingLayer();
	CCNotificationCenter:sharedNotificationCenter():postNotification(FruitDefs.NOTIFICATION_UPDATEMYINFO)
end

-- 	// 称号消息变化通知
function GameLibSink:onGameTitleChanged(nOldScore,nNewScore,nOldLevel,nNewLevel)
	cclog("onGameTitleChanged")
end

-- 	// 邮件列表
function GameLibSink:onMailList(cbRetCode,pMailList)
	cclog("onMailList %d,%d",cbRetCode,#pMailList)      
end

-- 	// 有新任务，或者邮件等标志
-- 	// bLoginGift == true表示有登陆奖励未领取
function GameLibSink:onNewStatus(nNewMissionDone,nNewMail,nNewActivity,nNewFriend,bLoginGift)
	cclog("onNewStatus")
end

-- 	// 元宝购买金币返回
-- 	// cbRet:1表示成功，11表示元宝不足，nGold:购买获得金豆数量,nYuanbao:现有元宝
function GameLibSink:onYuanbaoBuyGoldRet(cbRet,nGold,nYuanbao)
	cclog("onYuanbaoBuyGoldRet")
    --cbRet:1表示成功，11表示元宝不足，nGold:购买获得金豆数量,nYuanbao:现有元宝
end

-- 	// 购买道具返回
-- 	// cbRet: 11=存在服务器里没有退出(金币锁)  12=不存在这个道具  13=金币不足  14=已经拥有该道具,无须购买
function GameLibSink:onBuyPropertyRet(cbRet,nPropertyID)
	cclog("onBuyPropertyRet")
end

-- 	// 获取用户道具返回
function GameLibSink:onGetUserPropertiesRet(vUserProperties)
	cclog("onGetUserPropertiesRet")
end

-- 	// 使用道具返回
-- 	// cbRet:1表示成功，11：没有该道具或属性
-- 	// nPropertyID，nCount:使用的道具ID和数量
-- 	// nParam，使用参数，目前为nToUserID
function GameLibSink:onUsePropertyRet(cbRet,nPropertyID,nCount,nParam)
	cclog("onUsePropertyRet")
end

-- 	// 查询用户属性返回
-- 	// nToUserID,被查询的用户DBID
-- 	// vActivedProperties，该用户所有已启用的属性，包括头像和背景等
function GameLibSink:onGetUserPropertyFlagRet(nToUserID,vActivedProperties)
	cclog("onGetUserPropertyFlagRet")
end

-- 	// C++未实现的命令
function GameLibSink:onUnHandledNetCommand(szBuffer, nLen)
	cclog("onUnHandledNetCommand")
end

-- 	// lua请求的web回调
function GameLibSink:onLuaWebRequest(szBuffer)
	cclog("onLuaWebRequest")
end

-- 	/////////////////////////////////////////////////////////////////////
-- 	// 好友相关
-- 	// 获取好友列表
function GameLibSink:onFriendList(friendList)
	cclog("onFriendList")
end

-- 	// 获取申请好友列表
function GameLibSink:onFriendApplyList(friendList)
	cclog("onFriendApplyList")
end

-- 	// 申请好友返回	1=成功，11=已经是好友  12=已发出申请  13=不能邀请自己为好友
function GameLibSink:onApplyFriend(cbRetCode)
	cclog("onApplyFriend")
end

-- 	// 同意好友返回	1=操作成功   11=已经是好友  12=您好友已满  13=对方好友已满  14=不能加自己为好友
function GameLibSink:onAgreeFriend(cbRetCode)
	cclog("onAgreeFriend")
end

-- 	// 获取好友信息
function GameLibSink:onFriendInfo(friendInfo)
	cclog("onFriendInfo")
end

-- 	// 模糊查询返回
function GameLibSink:onGetFriendInfoByNameRet(friendList)
end

-- 	///////////////////////////////////////////////////////////////////////
-- 	// 保险柜相关
-- 	// 我的保险柜数量及上限
function GameLibSink:onBankInfo(nBankAmount,nBankCapacity)
	cclog("onBankInfo")
    FruitDefs.HideLoadingLayer()
	--CCLog(CCString::createWithFormat("onBankInfo:%d", nBankAmount)->getCString());
	if (FruitDefs.sFruitMachineLayer ~= nil) then
		FruitDefs.sFruitMachineLayer:onBankRet(nBankAmount,nBankCapacity)
	end
end

-- 	// 修改密码返回	1=成功，11=失败，校验密码失败
function GameLibSink:onChangeBankPasswordRet(nRetCode)
	   cclog("onChangeBankPasswordRet")
end

-- 	// 存入返回 1=成功，11=现金不足 12=超过上限
function GameLibSink:onBankInRet(nRetCode,nCurGold,nCurBankAmount)
	cclog("onBankInRet")
end

-- 	// 取出返回 1=成功，11=密码错误  12=保险柜余额不足
function GameLibSink:onBankOutRet(nRetCode,nCurGold,nCurBankAmount)
	cclog("onBankOutRet")
end

-- // 	// 查询我的充值额度，单位为分
function GameLibSink:onGetPayAmountRet(nPayAmount)
	cclog("onGetPayAmountRet")
end

-- 	// 发送邮件返回，1=操作成功  11=对方不是你的好友
function GameLibSink:onSendMailRet(nResult)
	cclog("onSendMailRet %d",nResult)
end

-- 	// 密码桌回调
function GameLibSink:onCreatePrivateTableFailed(lpszErrorMsg)
	cclog("onCreatePrivateTableFailed")
end

function GameLibSink:onEnterPrivateTableFailed(lpszErrorMsg)
	cclog("onEnterPrivateTableFailed")
end

-- 	// 有登陆奖励领取：0表示周卡领取，1表示月卡领取，2表示连续登陆领取
-- #define WAKENG_AWARD_WEEK		0
-- #define WAKENG_AWARD_MONTH		1
-- #define WAKENG_AWARD_CONTINUE	2
-- 	virtual void onWakengAward(unsigned char cbType) = 0;

-- 	// 获取我的会员奖励返回
--nWeekAwardAmount--[[*周卡奖励*/]]
--nWeekStillDays--[[周卡还可领取天数]]
--nMonthAwardAmount--[[月卡奖励]]
--nMonthStillDays--[[月卡还可领取天数]]
function GameLibSink:onGetMyMemberInfoRet(nWeekAwardAmount,nWeekStillDays,nMonthAwardAmount,nMonthStillDays)
	cclog("onGetMyMemberInfoRet")
end

-- 	// 获取连续登陆奖励返回
--nCurrentTime/*当前已连续天数*/
--nContinueFlat/*领取标志*/
function GameLibSink:onGetContinueAwardInfoRet(nCurrentTime,nContinueFlat,continueAwardList)
	cclog("onGetContinueAwardInfoRet")
end

-- 	// 挖坑排行榜相关奖励通知
-- 	// nPay:土豪提醒,nPlay:战斗榜，nWinAmount：赚金，nWinAmount:杀手，nGuess：猜坑,nNewServiceTip:客服留言
function GameLibSink:onRankTip(nPay,nPlay,nWinAmount,nWinCount,nGuess,nNewServiceTip)

end

-- 	// 道具卡信息
-- 	// 此处为服务器使用道具卡后刷新的数据信息
-- 	// ToolCardCount{int nToolCardIDint nCount}
-- 	// {ToolCardCount};
-- 	// 如果nLen为0，可能所有的道具卡都消耗完毕
-- 	/*
-- 		int nCount = nLen / (ToolCardCount);
-- 		for(int i = 0i < nCounti++)
-- 		{
-- 			ToolCardCount* pCount = (ToolCardCount*)(szBuf + i * sizeof(ToolCardCound));
-- 		}
-- 	*/
function GameLibSink:onToolCardInfo(szBuf,nLen)
	
end

-- 	// 登陆奖励领取返回
function GameLibSink:onLoginAwardRet(cbRet)
	cclog("onLoginAwardRet")
end

-- 	// 领取VIP升级礼包返回
function GameLibSink:onGetVipUpgradeAwardRet(cbRet)
	cclog("onGetVipUpgradeAwardRet")
end

-- 	// 充值成功
function GameLibSink:onChargeFinished()
	cclog("onChargeFinished")
    FruitDefs.ShowMessage(("恭喜，您的充值已到帐，祝游戏愉快！"));
end

function GameLibSink:onVIPLevelChanged(nOldLevel, nNewLevel)
	cclog("onVIPLevelChanged")
end

function GameLibSink:onGameBankOpeReturn(succeeded,gold,bank)
	FruitDefs.HideLoadingLayer()
  	if (succeeded == 1) then
        FruitDefs.ShowMessage(("操作成功"))
    	if (FruitDefs.sFruitMachineLayer ~= nil) then
    		FruitDefs.sFruitMachineLayer:onBankRet(gold,bank)
    	end
  	else
  	    FruitDefs.ShowMessage(("操作失败"))
    end
end

return GameLibSink