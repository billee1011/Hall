require("CocosExtern")
require("GameLib/gamelib/UserInfo")

local GameLogic=class("GameLogic")
local GameDefs = require("k510/GameDefs") 
local Common = require("k510/Game/Common")
local Resources = require("k510/Resources")
local ScoreParser = require("GameLib/common/ScoreParser")

--规则 1钱 2局数(10，20) 3 炸弹类型 4最大连对 5切牌是否

local GameLogic = 
{
    StaySceneName = "",     --我现在处在的Scene名字
    StaySceneLayer = "",    --我现在处在的场景实例
    isPrivateRoom = false,  --是不是私人房
	serverId = -1,
    tableId = -1,           --桌子号
	serVerName = "",
	curActor = -1,
    lastActor = -1,
    nRingCount = -1,
    myChair = -1,
    gamePhase = Common.GAME_PHRASE.enGame_Invalid,
    cbMingPaiCard = -1,     --明牌
    autoOutCardTime = -1,   --出牌等待时间
    openTableUserid = 0,    --开桌人的ID
    curjushu = -1,          --当前局数
    totaljushu = -1,        --一共多少局
    userlist = {},
    gameEnded = false,
    m_SetScores = nil,       --单局结算信息
    gameendlistinfo = nil,   --最终总结算信息
    checkLocation = false,   --是否查看过定位信息
}

function GameLogic:new()
    local store = nil
    return function(self)
        if store then return store end
        local o =  {}
        setmetatable(o, self)
        self.__index = self
        store = o
        return o
    end
end

GameLogic.instance = GameLogic:new()

function GameLogic:refreshGameLogic()
	self.curActor = -1
    self.lastActor = -1
    self.nRingCount = -1
    self.m_SetScores = nil
    self.gameendlistinfo = nil
    self.gamePhase = Common.GAME_PHRASE.enGame_Invalid
    for i = 1 ,#self.userlist do
        if self.userlist[i]~= nil then
           self.userlist[i]:refresh()
        end
    end
end

function GameLogic:clearGameLogic()
	self.curActor = -1
    self.lastActor = -1
    self.nRingCount = -1
    self.gamePhase = Common.GAME_PHRASE.enGame_Invalid
    self.myChair = -1
    self.userlist = {}
    self.gameEnded = false
    self.m_SetScores = nil
    self.gameendlistinfo = nil
end

function GameLogic:setTableId(tableId)
	self.tableId = tableId
end

function GameLogic:setChairId(chairId)
	self.myChair = chairId
end

function GameLogic:setIsPrivateRoom(private)
    self.isPrivateRoom = private
end

function GameLogic:getIsPrivateRoom()
    return self.isPrivateRoom
end

--座位号转换 客户端到服务端 
--我的椅子号和需要转换的椅子号
function GameLogic:ClientToServerSeat(index)
	if self.myChair ~= -1 and index >= 0 and index < Common.PLAYER_COUNT then
		local plusNum = math.floor(Common.PLAYER_COUNT / 2)
		local returnNum = (index + self.myChair - plusNum + Common.PLAYER_COUNT) % Common.PLAYER_COUNT
		return returnNum
	end
    return index
end

--座位号转换 服务端到客户端
--我的椅子号和需要转换的椅子号

function GameLogic:ServerToClientSeat(index)
	if self.myChair ~= -1 and index >= 0 and index < Common.PLAYER_COUNT then
		local plusNum = math.floor(Common.PLAYER_COUNT / 2)
		local returnNum = (index - self.myChair + plusNum + Common.PLAYER_COUNT) % Common.PLAYER_COUNT
		return returnNum
	end
    return index
end

function GameLogic:addUser(gameuser)
    cclog("userlist addUser %d", gameuser:getChairID())
    self.userlist[gameuser:getChairID()] = gameuser
end

function GameLogic:clearUser(chair)
    if chair < 0 or char >= self:getMaxChairCount() then
        return
    else
        self.userlist[chair] = nil
        cclog("userlist clearUser %d", chair)
    end
end

function GameLogic:getTimeOutCounts()
    return self.autoOutCardTime
end

-- 有玩家进入
function GameLogic:onUserEnterTable(nChair,wUserID,bIsPlayer)
    cclog("玩家进入 = %d (%s)",nChair+1, tostring(self.getGameLib():getUser(wUserID)))
    if nChair >=0 and nChair < Common.PLAYER_COUNT then
        local userInfo =  self.getGameLib():getUser(wUserID)
        if userInfo ~= nil then
            local gameUserInfo = require("k510/Game/GameUser"):new()
            gameUserInfo._faceID = userInfo:getFace()
            gameUserInfo._userDBID = userInfo:getUserDBID()
            gameUserInfo._userLevel = userInfo._userLevel
	        gameUserInfo._userIP = userInfo._userIP
	        gameUserInfo._groupID = userInfo._groupID
	        gameUserInfo._name = userInfo:getUserName()
	        gameUserInfo._maxim = userInfo:getMaxim()
	        gameUserInfo._age = userInfo:getAge()
	        gameUserInfo._sex = userInfo:getSex()
	        gameUserInfo._fame = userInfo:getGameTitleScore()
	        gameUserInfo._fameLevel = userInfo:getGameTitleLevel()
	        gameUserInfo._bankValue = userInfo:getBankAmount()
	        gameUserInfo._tableID = userInfo:getUserTableID()
	        gameUserInfo._chairID = userInfo:getUserChair()
	        gameUserInfo._status = userInfo:getUserStatus()	
	        gameUserInfo._userIndex = userInfo:getUserID()
	        gameUserInfo._scoreBuf = userInfo._scoreBuf
	        gameUserInfo._scoreBufLen = userInfo._scoreBufLen
	        gameUserInfo.m_cbFaceChagneIndex = userInfo:getUserFaceChangeIndex()
	        gameUserInfo.m_cbVipLevel = userInfo:getVIPLevel()
            cclog("有玩家进入->创建玩家数据\n编号:%d    椅子:%d    姓名:%s\n状态:%d    分数:%d    IP:%s",
                gameUserInfo._userDBID, nChair, gameUserInfo._name,
                gameUserInfo._status,
                ScoreParser:instance():GetScoreField(
                    gameUserInfo._scoreBuf,gameUserInfo._scoreBufLen, 0),
                gameUserInfo._userIP
            )
            self.userlist[nChair + 1] =  gameUserInfo
            self.userlist[nChair + 1]:setGameNewStatus(gameUserInfo._status)
            self.userlist[nChair + 1]:setScores(ScoreParser:instance():GetScoreField(
                    gameUserInfo._scoreBuf,gameUserInfo._scoreBufLen, 0))
            
            local s = self:getGameLib():getMyDBID()
            if s and s == gameUserInfo._userDBID then 
                self.myChair = nChair
                self.myself = self.userlist[nChair + 1]
            end
            
        end
    end
    
    --刷新界面
    if self.StaySceneName == Common.Scene_Name.Scene_Game then
        self.StaySceneLayer:updateDeskInfo("onUserEnterTable")
    end
end

-- 同IP检测
function GameLogic:checkIP()
    cclog("同IP检测")
    local sameIPRecorder = { count=0 }
    local userList = self:getGameLib():getUserList()
    for i, j in pairs(userList) do
        for k, v in pairs(userList) do
            if k ~= i and v._userIP == j._userIP and (not sameIPRecorder[v._userDBID]) then
                sameIPRecorder[v._userDBID] = {name = v._name, ip = v._userIP}
                sameIPRecorder.count = sameIPRecorder.count + 1
            end
        end
    end
    
    if sameIPRecorder.count > 0 then
        local tips = string.format("请注意, 场内%d位玩家有相同IP地址!", sameIPRecorder.count)
        for i, j in pairs(sameIPRecorder) do
            if i ~= "count" then
                tips = string.format("%s\n%s (%s)", tips, j.name, j.ip)
            end
        end
        require("HallUtils").showWebTip(tips, nil, nil, ccp(GameDefs.CommonInfo.View_Width / 2, 450), 6)
    end
end

-- 显示定位信息
function GameLogic:showLocation()
    if self.StaySceneLayer and self.userlist then
        self.StaySceneLayer.locationBtn.m_normalSp:stopAllActions()
        self.StaySceneLayer.locationBtn.m_normalSp:setDisplayFrame(
            CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("czpdk/loc.png")
        )
        self.checkLocation = true
        require("Lobby/Info/LayerLocation").put(self.StaySceneLayer, 10, 3, self:getGameLib():getUserList(), self.myChair):show()
    end
end

-- 玩家退出
function GameLogic:onUserExitTable(nChair,UserID,isPlayer)
    if nChair >=0 and nChair < Common.PLAYER_COUNT then
        if self.gamePhase == Common.GAME_PHRASE.enGame_Invalid and require("Lobby/FriendGame/FriendGameLogic").game_used  == 0 then
            --更新IP记录
            if UserID then
                local user = self:getGameLib():getUser(UserID)
                if user then self.IPRecorder[user._userDBID] = nil end
            end
            
            self.userlist[nChair + 1] = nil
            cclog("userlist remove %d by onUserExitTable", nChair)
        end
    end

    --刷新界面
    if self.StaySceneName == Common.Scene_Name.Scene_Game then
        self.StaySceneLayer:updateDeskInfo("onUserExitTable")
    end
end

-- 设置玩家状态
function GameLogic:setUserGameStatus(chair,oldState,newState)
    if chair >=0 and chair < Common.PLAYER_COUNT then
        self.userlist[chair + 1]:setGameOldStatus(oldState)
        self.userlist[chair + 1]:setGameNewStatus(newState)
        cclog("更新玩家状态  ->更新玩家状态\n编号:%d    椅子:%d    姓名:%s\n状态:%d    分数:%d",
            self.userlist[chair + 1]._userDBID, chair, self.userlist[chair + 1]._name,
            self.userlist[chair + 1]._status,
            ScoreParser:instance():GetScoreField(
                self.userlist[chair + 1]._scoreBuf,self.userlist[chair + 1]._scoreBufLen, 0)
        )
        --刷新界面
        self.StaySceneLayer:updateDeskInfo("setUserGameStatus")
    end
end

-- 游戏开始
function GameLogic:onGameStart()
    cclog("GameLogic:onGameStart()")
    local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
    FriendGameLogic.game_used = FriendGameLogic.game_used + 1
    if FriendGameLogic.game_used >= FriendGameLogic.my_rule[1][2] then
        FriendGameLogic.game_used = FriendGameLogic.my_rule[1][2]
    end
    self.m_SetScores = nil
    self.gameendlistinfo = nil
    self.StaySceneLayer:Clear()
    self.StaySceneLayer:setRoomInfo()
    -- 检测同IP
    --self:checkIP()
end

-- 游戏结束
function GameLogic:onGameEnd()
    cclog("GameLogic:onGameEnd")
    if self.StaySceneName == Common.Scene_Name.Scene_Game then
        self.StaySceneLayer:DelayGameEnd()
    end
end

-- 离开游戏
function GameLogic:onLeaveGameView()
    if self.gamePhase == Common.GAME_PHRASE.enGame_Invalid then
        require("HallUtils").showWebTip("房主已解散房间，将自动返回大厅")
        require("k510/GameLibSink"):onLeaveGame()
    end
end

-- 场景变化
function GameLogic:onSceneChanged(pData,nLen)
    cclog("GameLogic:onSceneChanged")

    local gameSceneData = Common.newGameScene(pData, self.myChair+1)

    if gameSceneData then
    
        -- 结算数据记录在本地
        if gameSceneData.m_SetScores then
            cclog("单局结算数据已更新！")
            self.m_SetScores = gameSceneData.m_SetScores
        end

        self.gamePhase = gameSceneData.cbSystemPhase
        
        -- 切牌阶段
        if self.gamePhase == Common.GAME_PHRASE.enGame_QiePai then
            -- 写入切牌数据
            self.qieData = {
                cbChairCurQie = gameSceneData.cbChairCurQie,
                cbQieAble     = gameSceneData.cbQieAble,
                cbQieValue    = gameSceneData.cbQieValue
            }
        -- 其它阶段
        else
            -- 清空切牌数据
            self.qieData = nil
            
            -- 当前操作者
            self.curActor = gameSceneData.cbChairCurPlayer

            self.nRingCount = gameSceneData.cbRingCount

            -- 庄椅子号
            self.cbMingPaiCard = gameSceneData.cbMingPaiCard

            -- 出牌等待时间	
            self.autoOutCardTime = gameSceneData.cbAutoOutCardTime
            
            for i = 1, Common.PLAYER_COUNT do
                if self.userlist[i] ~= nil then
                     --玩家手牌
                    self.userlist[i]:setHandCards(gameSceneData.m_handCards[i])

                    --玩家打出去的牌
                    self.userlist[i]:setOutCardStruct(gameSceneData.m_outCards[i])

                    --当局分数
                    if gameSceneData.m_SetScores and #gameSceneData.m_SetScores == Common.PLAYER_COUNT then
                        self.userlist[i]:setCurrentScore(gameSceneData.m_SetScores[i].nSetScore)
                        self.userlist[i]:setLeftCardNum(gameSceneData.m_SetScores[i].cbLeftCardNum)
                    end              
                end
            end
        end
        
        self.StaySceneLayer:updateDeskInfo("onSceneChanged")
    end
end

-- 玩家信息变化
function GameLogic:updateUserInfo(updateUserInfo)
    local chair = updateUserInfo:getUserChair()
    if self.userlist and self.userlist[chair + 1] and self.StaySceneName == Common.Scene_Name.Scene_Game then
        local udata = self.userlist[chair + 1]
        udata._scoreBuf = updateUserInfo._scoreBuf
        udata._scoreBufLen = updateUserInfo._scoreBufLen
        udata._status = updateUserInfo._status
        udata:setGameNewStatus(updateUserInfo._status)
        udata:setScores(ScoreParser:instance():GetScoreField(
                updateUserInfo._scoreBuf,updateUserInfo._scoreBufLen, 0))
        cclog("有玩家变化->更新玩家数据\n编号:%d    椅子:%d    姓名:%s\n状态:%d    分数:%d",
            udata._userDBID, chair, udata._name,
            udata._status,
            require("GameLib/common/ScoreParser"):instance():GetScoreField(
                udata._scoreBuf,udata._scoreBufLen, 0)
        )
        self.StaySceneLayer:updateDeskInfo("updateUserInfo")
    end
end

-- 发送准备协议
function GameLogic:sendStartMsg(s)
    cclog("GameLogic:sendStartMsg by "..tostring(s))
    if self.myChair >=0 and self.myChair < Common.PLAYER_COUNT then
        local userInfo = self.userlist[self.myChair + 1]
        if userInfo ~= nil and userInfo._status ~= Common.GAME_PLAYER_STATE.USER_READY_STATUS and userInfo._status ~= Common.GAME_PLAYER_STATE.USER_PLAY_GAME then
            cclog("准备指令发送成功")
            GameLogic.getGameLib():sendReadyCmd()
        end
    end
end

-- 发送离开协议
function GameLogic:sendLeaveMsg()
   GameLogic.getGameLib():leaveGameRoom()
end

-- 出牌
function GameLogic:sendOutCardsMsg(cardArray)
     local ba = Common.newOutCardSerialize(cardArray)
     GameLogic.getGameLib():sendOldGameCmd(Common.GAME_PotoCoL_MessAge.CMD_C_OUT_CARD,ba:getBuf(),ba:getLen())
end

-- 发送声音
function GameLogic:sendOutCardSound(sndIndex)
    local ba = require("ByteArray").new()
    ba:writeByte(sndIndex)
    ba:setPos(1)
    GameLogic.getGameLib():sendOldGameCmd(Common.GAME_PotoCoL_MessAge.CMD_Out_CardSound,ba:getBuf(),ba:getLen())
end

-- 得到之前的椅子号
function GameLogic:getPreChair(chair)
    local nChair
    nChair = (chair + 1) % Common.PLAYER_COUNT

	return nChair
end

-- 解散房间
function GameLogic:sendDissolveRoom(isDissolve)
    local ba = require("ByteArray").new()
    ba:writeByte(isDissolve)
    GameLogic.getGameLib():sendOldGameCmd(Common.GAME_PotoCoL_MessAge.CMD_DISSOLVE_ROOM,ba:getBuf(),ba:getLen())
end

-- 根据客户端显示的椅子号得到逻辑UserInfo
function GameLogic:getUserInfo(nChair)
   if nChair >=0 and nChair < Common.PLAYER_COUNT then
        local chair = self:ClientToServerSeat(nChair) + 1
        return self.userlist[chair]
   end

   return nil
end

-- 逆时针椅子号
function GameLogic:AntiClockWise(chair)
    local nChair = (chair + Common.PLAYER_COUNT - 1)%Common.PLAYER_COUNT
	return nChair;
end


-- 顺时针椅子号
function GameLogic:ClockWise(chair)
    local nChair = (chair + 1)%Common.PLAYER_COUNT
	return nChair;
end


-- 私人房相关
function GameLogic:PrivateInfo(chair,cbCmdID,data,nLen)
    --[[
    if cbCmdID == Common.GAME_PotoCoL_MessAge.CMD_S_PRIVATEROOM_INFO then
        local privateRoomInfo = Common.newPrivateRoomInfo(data)
    elseif cbCmdID == Common.GAME_PotoCoL_MessAge.CMD_S_SEND_SET_SCORE_INFO then
        local scoreInfo = Common.newSetScoreInfo(data)
        if self.StaySceneName == Common.Scene_Name.Scene_Game then
            self.StaySceneLayer:showResultLayer(scoreInfo)
        end
    elseif cbCmdID == Common.GAME_PotoCoL_MessAge.CMD_S_TOTAL_SCORE_INFO then
        local scoreInfo = Common.newTotalScoreInfo(data)
        if self.StaySceneName == Common.Scene_Name.Scene_Game then
            self.StaySceneLayer:showEndResultLayer(scoreInfo)
        end
    end
    ]]
end

-- 收到消息处理
function GameLogic:OnGameMessage(chair,cbCmdID,data,nLen)
    cclog("GameLogic:OnGameMessage cmd: %d,  chair: %d,  nLen: %d", cbCmdID, chair, nLen)
    if cbCmdID == Common.GAME_PotoCoL_MessAge.CMD_Out_CardSound then
        if self.StaySceneName == Common.Scene_Name.Scene_Game then
            local ba = require("ByteArray").new()
            ba:writeBuf(data)
	        ba:setPos(1)

            local sndIndex = ba:readByte()
            self.StaySceneLayer:PlayRevSound(sndIndex)
        end
    elseif cbCmdID == Common.GAME_PotoCoL_MessAge.CMD_Out_Qie then
        self:onRecvQie(data)
    end
end

-- 发送切牌指令
function GameLogic:sendQie(value)
    cclog("发送切牌指令: %d", value)
    local ba = require("ByteArray").new()
    ba:writeUByte(value)
    ba:setPos(1)
    GameLogic.getGameLib():sendOldGameCmd(Common.GAME_PotoCoL_MessAge.CMD_Send_Qie, ba:getBuf(), ba:getLen())
end

-- 收到切牌广播
function GameLogic:onRecvQie(data)
    if self.StaySceneName == Common.Scene_Name.Scene_Game then
        local ba = require("ByteArray").new()
        ba:writeBuf(data);ba:setPos(1)

        local nChair = ba:readUShort()      -- 玩家椅子ID
        local bQie = ba:readUByte()        -- 能否选择切牌
        local bValue = ba:readUByte()       -- 切牌值 0不切 1切
        
        if debugMode then cc2file(string.format(
            "\n更新玩家切牌数据  -> 椅子:%d,  可切:%d,  切值:%d\n",
            nChair, bQie, bValue
        )) end
        
        local uData = self.userlist[nChair + 1]
        if uData then
            -- uData:setPiao(bPiao, bScore)
            -- local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
        end
    end
end

function GameLogic:CanOutCard(array)
    local selCards  ={}
    selCards = require("k510/Game/Public/ShareFuns").Copy(array)
    if #selCards == 0 then
       return false
    end

    selCards = require("k510/Game/Public/ShareFuns").SortCards(selCards)

    local bRet = false
    local outCard = {}
    bRet,outCard = require("k510/Game/Public/ShareFuns").DisassembleToOutCard(selCards)
    if bRet == false then
       return false
    end

    if self.nRingCount == 0 then
        return true
    else
        local bRet = false
        local lastOutCard = {}
        bRet,lastOutCard = self:GetLastNoPassCardSuit()
        if bRet == false then
           return false
        end

        bRet = require("k510/Game/Public/ShareFuns").CompareTwoCardSuit(lastOutCard,outCard)
        if bRet == false then
           return false
        end
    end

    return true
end

function GameLogic:GetLastNoPassCardSuit()
    local OutCard = Common.newMyOutCard()
    if self.nRingCount == 0 then
        return false, OutCard
    end

    local chair = GameLogic:ClockWise(self.myChair)
    
    local lastUser = self.userlist[chair + 1]
    if lastUser ~= nil and lastUser.outCards then
       if lastUser.outCards.suitType ~= Common.SUIT_TYPE.suitPass then
          OutCard.suitType = lastUser.outCards.suitType
          OutCard.suitLen = lastUser.outCards.suitLen
          OutCard.cards = require("k510/Game/Public/ShareFuns").Copy(lastUser.outCards.cards)
          return true,OutCard
       end
    end

    chair = GameLogic:ClockWise(chair)
    lastUser = self.userlist[chair + 1]
    
    if lastUser ~= nil then
       if lastUser.outCards.suitType ~= Common.SUIT_TYPE.suitPass then
          OutCard.suitType = lastUser.outCards.suitType
          OutCard.suitLen = lastUser.outCards.suitLen
          OutCard.cards = require("k510/Game/Public/ShareFuns").Copy(lastUser.outCards.cards)
          return true,OutCard
       end
    end

    chair = GameLogic:ClockWise(chair)
    lastUser = self.userlist[chair + 1]
    
    if lastUser ~= nil then
       if lastUser.outCards.suitType ~= Common.SUIT_TYPE.suitPass then
          OutCard.suitType = lastUser.outCards.suitType
          OutCard.suitLen = lastUser.outCards.suitLen
          OutCard.cards = require("k510/Game/Public/ShareFuns").Copy(lastUser.outCards.cards)
          return true,OutCard
       end
    end

    return false,OutCard
end

-- 更新游戏场景
function GameLogic:replaceMainScence()
    -- cclog("GameLogic:replaceMainScence")
    if self.StaySceneName ~= Common.Scene_Name.Scene_Game then
        local scene, layer = require("k510/Game/DeskScene").createScene()
        CCDirector:sharedDirector():replaceScene(scene)
        SchemeURLQuery = nil
        require("LobbyControl").gameLogic = self
        require("LobbyControl").removeHallCache()
        if debugMode then Cache.log("进入游戏房间后材质使用内存状况") end
    end
end

-- 收到游戏规则消息
function GameLogic:onFriendRuleMessage(userID, exprireTime, validTime)
    cclog("收到游戏规则")
    self.openTableUserid = userID
    self.exprireTime = exprireTime
    self.validTime = validTime
    self.StaySceneLayer:setRoomInfo()
    self.StaySceneLayer:updateDeskInfo("onFriendRuleMessage")
    -- table.print(require("Lobby/FriendGame/FriendGameLogic").my_rule)
end

function GameLogic:onDismissTableNoticeMessage(userID)

end

function GameLogic:onFriendTableVoteMessage(userID,cbIsAgree)

end

function GameLogic:onFriendGameEnd(infoList)
    cclog("GameLogic:onFriendGameEnd")
    self.gameEnded = true
    if self.StaySceneName == Common.Scene_Name.Scene_Game then
        self.StaySceneLayer.gameendlistinfo = infoList
        self.StaySceneLayer:DelayGameEnd()
    end
end

function GameLogic:setStaySceneName(name,layer)
   self.StaySceneName = name
   self.main_layer = layer
   self.StaySceneLayer = layer
end

function GameLogic:getStaySceneName()
   return self.StaySceneName
end

function GameLogic.getGameLib()
    local GameLibSink =require("k510/GameLibSink")
    local gamelib = GameLibSink.game_lib
    return gamelib
end

function GameLogic.removeCache()
    local path = Resources.Img_Path
    Cache.removePlist{path.."czpdkanimate", path.."czpdk", path.."czpdkpai", path.."czpdkreplay", "emote"}
    Cache.removeTexture{path.."deskbg.jpg", "lobby_message_tip_bg"}
end

function GameLogic.loadingCache()
    local path = Resources.Img_Path
    -- 加载游戏资源 应按从大到小顺序加载避免峰值过高
    Cache.add{path.."czpdkanimate", path.."czpdk", path.."czpdkpai", path.."czpdkreplay", "emote"}
end

return GameLogic