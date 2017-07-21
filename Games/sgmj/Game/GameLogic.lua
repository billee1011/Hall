--GameLogic.lua

local SOCKET_TYPE_SCENE                 = 1  --场景信息
local SOCKET_TYPE_GAME                  = 2  --游戏消息
local SOCKET_TYPE_USEREXIT              = 3  --玩家退出
local SOCKET_TYPE_FRIENDRULE            = 4  --好友桌规则
local SOCKET_TYPE_LEAVETABLE            = 5  --玩家离开
local SOCKET_TYPE_FRIENDABLED           = 6  --好友桌加入
local SOCKET_TYPE_FRIENDEND             = 7  --好友桌结束
local SOCKET_TYPE_USERSTATUS            = 8  --玩家状态
local SOCKET_TYPE_REPLACE               = 9  --替换场景

local GameLogic = {
    cbPlayerNum = nil,
    cbGameCardCount = nil,

    cbSiceData = nil,       --骰子
    cbCardData = nil,       --手牌
    cdDownPengCard = nil,
    cdDownCard = nil,

    wBankerUser = nil,      --庄家椅子
    wLastChair = nil,       --打牌玩家椅子
    wChair = nil,           --当前玩家

    bBanker = nil,          --是否为庄家
    bSender = nil,          --是否可以出牌
    bTrustee = nil,         --是否托管
    bOperated = nil,        --是否完成操作

    bIsPiao = nil,         --是否托管
    cbBird = nil,
    cbValidBird = nil,
    nHuRight = {},

    bGameEnd = nil,         --单局游戏是否结束
    bFriendEnd = nil,       --总结算

    cbOperateCode = nil,    --当前操作码
    cbOperateCard = nil,    --当前操作牌值

    messageBack_funcs = nil,     --消息回调函数
    operatorBack_funcs = nil,    --操作广播
    socketBack_funcs              = nil,

    bPiaoType = nil,            --飘的类型

    main_layer = nil,

    startStatus                    = 0,
    bGameEndState                  = 0,  

    user_list                     = {},
	
	visibleCardSpList			  = {{{},{},{},{}},{}}--可见的牌，包括打出的牌和吃碰的牌，选牌提示的时候有用
} 

GameLogic.message_data                   = {}
GameLogic.bGetGameRule = false
GameLogic.temp_data                      = {} 

local GameDefs = require("sgmj/GameDefs") 
local CmdInfo = require("sgmj/GameDefs").CmdInfo
local AppConfig = require("AppConfig")
local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")

local GameLibSink = require(GameDefs.CommonInfo.GameLib_File)
local instance = nil

require("sgmj/Game/TutorialLogic")

function GameLogic:new(o)  
    o = o or {}  
    setmetatable(o,self)  
    self.__index = self 
	--instance = o
    return o  
end  

function GameLogic.removeCache()
    local path = GameDefs.CommonInfo.Mj_Path
    Cache.removePlist{"sgmj/images/sgmj","sgmj/images/czmjtutorial",path.."mjcard", "emote", path.."mjresult", path.."mjanima", path.."mjdesk"}
    Cache.removeTexture{path.."MJDeskBg.jpg", "lobby_message_tip_bg.png"}

    if instance then 
        instance:dispose() 
    end 
end

function GameLogic.loadingCache()
    local path = GameDefs.CommonInfo.Mj_Path
    -- 加载游戏资源 应按从大到小顺序加载避免峰值过高path.."mjcard", 
    Cache.add{"emote","sgmj/images/sgmj","sgmj/images/czmjtutorial",path.."mjcard", path.."mjresult", path.."mjanima", path.."mjdesk"}
end

function GameLogic.isLogicExist()
    return instance ~= nil
end

function GameLogic:getInstance()  
    if instance == nil then  
        instance = self:new()
        instance:init()
        instance:registGameBack()
    end  
    return instance  
end 

function GameLogic:init()  
    self.cbPlayerNum = 4
    if FriendGameLogic.game_id == 23 then
        self.cbPlayerNum = 3
    end

    self.cbGameCardCount = 108  --一共多少张牌

    self.messageBack_funcs = {}     --消息回调函数
    self.operatorBack_funcs = {}   --操作广播
    self.socketBack_funcs   = {}	--

    self.bIsPiao = {}
end

--初始化游戏信息
function GameLogic:initGameData()
    self.cbSiceData = {}	--骰子
    self.cbBird = {}		--鸟
    self.cbValidBird = {}
    self.nHuRight = {}		--胡牌类型

    self.cdDownPengCard = {{}, {}, {}, {}}
    self.cdDownCard = {{}, {}, {}, {}}

    self.cbCardData = {{}, {}, {}, {}}

    self.bTrustee = {}

    self.bGameEnd = false
    self.bFriendEnd = false

    self.startStatus                    = 0
    self.bGameEndState                  = 0
	
	self.cbMagicCardData = 0 --鬼牌
	
	self.visibleCardSpList = {{{},{},{},{}},{}}
end

function GameLogic:dispose() 
    if not instance then
        return
    end

    instance:clearSecesTimerScript()

    if instance.main_layer then
        instance.main_layer = nil
    end

    GameLogic.message_data                   = {}
    GameLogic.bGetGameRule = false
    GameLogic.temp_data                      = {}  

    instance = nil
end

------------------------------公共方法-----------------------------------
--自动坐桌准备
function GameLogic:onAutoRealy()
    if GameLibSink.game_lib then
        GameLibSink.game_lib:sendReadyCmd()
    end
end

--自动坐桌准备
function GameLogic:onRealy()
    if GameLibSink.game_lib then
        GameLibSink.game_lib:autoSit()
    end
end

function GameLogic:onEnterGameView()
    if GameLibSink.game_lib then
        GameLibSink.game_lib:sendReadyCmd()
    end
end

function GameLogic:returnToLobby()
    GameLibSink:exit()
    require("LobbyControl").backToHall()
end

--托管
function GameLogic:sendTrustee()
    if GameLibSink.game_lib then
        local index = self.bTrustee[self.wChair + 1]
        if index == 1 then
            index = 0
        else
            index = 1
        end

        local ba = require("ByteArray").new()
        ba:writeUByte(index)
        ba:setPos(1)
        GameLibSink.game_lib:sendOldGameCmd(GameDefs.CmdInfo.Trustee_Game, ba:getBuf(), ba:getLen())  

        self.bTrustee[self.wChair + 1] = index
    end
end

-- 癞子判定
function GameLogic:isSpecialCard(cbCardData)
	--无鬼牌
	if self.magicCardType == nil or Bit:_and(self.magicCardType,0x000000FF) == 1 then
		return false
	end
    if cbCardData == self.cbMagicCardData then
        return true
    end
    return false
end

--出牌
function GameLogic:sendOutCard(index)
    if GameLibSink.game_lib then
        local cbCardData = self.cbCardData[self.wChair + 1][index]
        if self:mineIsSender() then
            --if not self:isSpecialCard(cbCardData) then --韶关麻将癞子牌也能打出
                local ba = require("ByteArray").new()
                ba:writeUByte(cbCardData)
                ba:setPos(1)
                GameLibSink.game_lib:sendOldGameCmd(GameDefs.CmdInfo.Out_Card, ba:getBuf(), ba:getLen()) 
                cclog("GameLogic:sendOutCard "..cbCardData..";"..index)  

                --逻辑检测
                self:onSelfOutCard(cbCardData)
                self:onPlayerOutCard(self.wChair, cbCardData)
                return true
           -- else
           --    require("HallUtils").showWebTip("赖子牌不能打出")
           -- end
        end
	end
	return false
end

--nOperateCode   int    操作代码
--cbOperateCard   BYTE    操作扑克
--操作牌
function GameLogic:sendOperateCard(cmd)
    if GameLibSink.game_lib then
        if self.cbOperateCard and Bit:_and(cmd, self.cbOperateCode) == cmd then
            local ba = require("ByteArray").new()
            ba:writeInt(cmd)
            ba:writeUByte(self.cbOperateCard)
            ba:setPos(1)
            GameLibSink.game_lib:sendOldGameCmd(GameDefs.CmdInfo.Operate_Card, ba:getBuf(), ba:getLen()) 

            --过操作不收到回复消息
            if cmd > GameDefs.OperateCmd.No then
                if self.bSender then
                    --自己摸牌
                    local wProvideUser = self.wChair
                    if cmd == GameDefs.OperateCmd.Gang and self:getMineCardCount(self.cbOperateCard) < 2 then
                        --判断是否暗杠
                        wProvideUser = wProvideUser + self.cbPlayerNum
                    end

                   -- self:onPlayerOperateResultMessage(self.wChair, wProvideUser, cmd, self.cbOperateCard,0)
                   -- self.bOperated = true
                end

                self.bSender = false --等待操作通知
            end
        end
    end
end

--操作飘
function GameLogic:sendPiao(bpiao, score)
    if GameLibSink.game_lib then
        local ba = require("ByteArray").new()
        ba:writeUByte(bpiao)
        ba:writeUByte(score)
        
        ba:setPos(1)
        GameLibSink.game_lib:sendOldGameCmd(GameDefs.CmdInfo.C_PiaoStatus, ba:getBuf(), ba:getLen()) 
    end 
end

function GameLogic:clearSecesTimerScript()
    if self.realy_timer ~= nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.realy_timer)
        self.realy_timer = nil       
    end  
end

function GameLogic:OnReadyGame()
    --轮询准备，防止准备失败
    local pDirector = CCDirector:sharedDirector()
    self.realy_timer = self.realy_timer or pDirector:getScheduler():scheduleScriptFunc(
    function() 
        if self and self.realy_timer then
            self:onGetSocketData() 
        end
    end,0.01,false)
end

function GameLogic:onRecveSocketData(socketdata)
    local data = require("HallUtils").tableDup(socketdata)

    cclog("onRecveSocketData xxxxxxxxxxxxxxxxxxxxxxxxxxxxx "..data[1]..";"..#GameLogic.message_data)
    if data[1] == SOCKET_TYPE_REPLACE then
        --等待规则消息标识
        GameLogic.bGetGameRule = false
        GameLogic.message_data                      = {}
        GameLogic.temp_data                         = {}

        --重回标识
        self.startStatus = 0        
        if self.main_layer then self.startStatus = 1 end  
        table.insert(GameLogic.message_data, data)
        --self:replaceMainScence(socketdata[2])
        return
    end

    if not GameLogic.bGetGameRule then
        cclog("xxxxxxxxxxxxxxxxxxxxxxx onRecveSocketData xxxxxxxxxxxxxxxxxxxxxxx 111")
        --尚未收到游戏规则、处理收到消息顺序
        if data[1] == SOCKET_TYPE_FRIENDRULE then
            cclog("xxxxxxxxxxxxxxxxxxxxxxx onRecveSocketData xxxxxxxxxxxxxxxxxxxxxxx 222")
            self.bShowEnd = false
            table.insert(GameLogic.message_data, 1, data)

            for i,v in ipairs(GameLogic.temp_data) do
                table.insert(GameLogic.message_data, 1, v)

                --判断是否为重回显示结算界面
                if v[1] == SOCKET_TYPE_GAME and v[2][2] == GameDefs.CmdInfo.S_Game_End then
                    self.bShowEnd = true
                end
            end

            GameLogic.temp_data                      = {}
            GameLogic.bGetGameRule = true
        else
            --断线重回
            if self.startStatus == 1 and self.bGameEndState > 0 then
                cclog("xxxxxxxxxxxxxxxxxxxxxxx onRecveSocketData  333 "..data[1])
                --忽略场景、抓鸟、单局结算
                if not (data[1] == SOCKET_TYPE_SCENE or 
                    (data[1] == SOCKET_TYPE_GAME and 
                     (data[2][2] == GameDefs.CmdInfo.S_ChoosePiao or data[2][2] == GameDefs.CmdInfo.S_Game_End))) then
                    cclog("xxxxxxxxxxxxxxxxxxxxxxx onRecveSocketData xxxxxxxxxxxxxxxxxxxxxxx 444")
                    table.insert(GameLogic.temp_data, data)
                end
            else
                cclog("xxxxxxxxxxxxxxxxxxxxxxx onRecveSocketData 555 "..data[1]..";"..self.startStatus..";"..self.bGameEndState)
                table.insert(GameLogic.temp_data, data)
            end
        end
    else
        cclog("xxxxxxxxxxxxxxxxxxxxxxx onRecveSocketData xxxxxxxxxxxxxxxxxxxxxxx 666")
        table.insert(GameLogic.message_data, 1, data)
    end
end

function GameLogic:onGetSocketData()
    local count = #GameLogic.message_data
    
    if count > 0 then        
        local data = require("HallUtils").tableDup(GameLogic.message_data[count])
        table.remove(GameLogic.message_data)

        local tag = data[1]
        --cclog("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx onGetSocketData "..count..";"..tag)
        if self.socketBack_funcs[tag] then
            self.socketBack_funcs[tag](data[2])
        end
    end
end

function GameLogic:setIfGetSocketData(bvalue)
    if bvalue then
        cclog("GameLogic:setIfGetSocketData startTimer")
        --GameLibSink.game_lib:startTimer()
        self:OnReadyGame()
    else
        cclog("GameLogic:setIfGetSocketData releaseTimer")
        --GameLibSink.game_lib:releaseTimer()        
        self:clearSecesTimerScript()
    end
end


function GameLogic:isPlayingGame()
    return self:GetMeStatus() > 4
end

function GameLogic:onFriendRuleMessage(marstID, exprireTime, validTime)--好友桌规则消息
	cclog("GameLogic:onFriendRuleMessage"..FriendGameLogic.game_used)

    local bInit = self.main_layer:initFriendGameUI() 
    
    if self.main_layer.game_dismiss and FriendGameLogic.game_abled then
        self.main_layer.game_dismiss:setVisible(true)
    else
        self.main_layer:addFriendInviteUI()
        if self.main_layer.game_dismiss and marstID == self:GetMeDBID() then
            self.main_layer.game_dismiss:setVisible(true)
        end
    end

    if not FriendGameLogic.game_abled and validTime and validTime > 0 then
        self.main_layer:addFriendTableTime(exprireTime, validTime)
        self:resetGameConfig()
    end
	
    --判断牌数,目前写死
	self.cbGameCardCount = 108
	if Bit:_and(FriendGameLogic.getRuleValueByIndex(8),0x00000800) == 0 then
		self.cbGameCardCount = 100
		cclog("不带19万")
	end
	--鬼牌类型
	self.magicCardType = FriendGameLogic.getRuleValueByIndex(4)
	--马牌数量
	self.horseCardCount = FriendGameLogic.getRuleValueByIndex(5)
	
    self:checkGameReturnStatus() 

	self.initGameRule  = true --已经收到游戏规则数据
	--测试代码
--	self:TestFun()
end

function GameLogic:checkGameReturnStatus()
    --检查回放结果
    if (not self.bShowEnd) and self.bGameEndState == 0 then
        self.bIsPiao = {}

        --自动准备
        if self:GetMeStatus() < 4 and 
            (not FriendGameLogic.isRulevalid(100) or FriendGameLogic.game_used < 1) then  
            cclog("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx "..FriendGameLogic.game_used)          
            --不需要等待飘界面
            self.main_layer:waitForPiao(0)
        end        
    end

    self.bShowEnd = false
end

function GameLogic:onFriendTabledAbled()
	cclog("onFriendTabledAbled : "..FriendGameLogic.game_used)
    --self.main_layer:updataFriendGameUI(0)
end

function GameLogic:onDismissTableNoticeMessage(userID)
    local msg = "玩家："..self:GetUserName(userID)
    msg = msg.."\n发起解散请求，您是否同意？"
    FriendGameLogic.showDismissTipDlg(
                    self, self.panle_zIndex, require(CommonInfo.GameLib_File))
end

function GameLogic:onFriendTableVoteMessage(userID, cbIsAgree)
    local msg = "玩家："..self:GetUserName(userID)
    if cbIsAgree ~= 0 then
        msg = msg.." 同意解散游戏"
    else
        msg = msg.." 拒绝解散游戏"
    end
    
    require("HallUtils").showWebTip(msg)
end

--cbGameStatus    BYTE    游戏状态
--cbMagicData  byte    万能牌
--wSiceCount  WORD    骰子点数
--wBankerUser WORD    庄家用户
--wCurrentUser    WORD    当前用户
--cbActionCard    BYTE    动作扑克
--cbActionMask    int    动作掩码
--cbHearStatus    BYTE[2] 听牌状态
--cbLeftCardCount BYTE    剩余数目
--bTrustee    Bool[2] 是否托管
--wOutCardUser    WORD    出牌用户
--cbOutCardData   BYTE    出牌扑克
--cbDiscardCount  BYTE[2] 丢弃数目
--cbDiscardCard   BYTE[2][60] 丢弃记录
--cbCardCount BYTE    扑克数目
--cbCardData  BYTE[2] 扑克列表
--cbSendCardData  BYTE    发送扑克
--cbWeaveCount    BYTE[2] 组合数目
--WeaveItemArray  CMD_WeaveItem[2][4] 组合扑克

------------------------------游戏方法-----------------------------------
function GameLogic:onSceneChanged(pData, nLen)
    local ba = require("ByteArray").new()
    ba:writeBuf(pData)
    ba:setPos(1)

    self:initGameData()
    self.bSender = false
    self.main_layer:resetGameDesk()

    local cbGameStatus = ba:readByte()
    --[[if cbGameStatus == 1 then
        --空闲状态
        return
    end]]

    --确定玩家椅子
    local playChair = 1
    if self.wChair == 1 then
        playChair = 0
    end

    self.cbMagicCardData = ba:readByte() --万能牌
    for i=1,2 do
        --骰子点数
        table.insert(self.cbSiceData, ba:readUByte())    
    end      
    self.wBankerUser = ba:readUShort() --庄家用户
    local wCurrentUser = ba:readShort() --当前用户
    local cbActionCard = ba:readUByte() --动作扑克
    local cbActionMask = ba:readInt() --动作掩码
    local bIsQiangGang = false --ba:readUByte() --是否抢杠
    
	cclog("cbActionCard"..cbActionCard)
	cclog("cbActionMask"..cbActionMask)
	cclog("wCurrentUser"..wCurrentUser)
	local cbLeftCardCount = ba:readUByte() --剩余数目
	cclog("剩余数目 "..cbLeftCardCount)
    local cbHearStatus = {}    
    for i=1,self.cbPlayerNum do
        --听牌状态
        table.insert(cbHearStatus, ba:readUByte())    
    end
	local cbJianRenStatus = {}    
    for i=1,self.cbPlayerNum do
        --煎人状态
        table.insert(cbJianRenStatus, ba:readInt())    
    end
	
    for i=1,self.cbPlayerNum do
        --是否托管
        table.insert(self.bTrustee, 0)--ba:readUByte())    
    end

    local wOutCardUser = ba:readShort()         --出牌用户
    local cbOutCardData = ba:readUByte()        --出牌扑克
	cclog("wOutCardUser "..wOutCardUser)
	cclog("cbOutCardData "..cbOutCardData)

    if wOutCardUser > -1 then
        self.wLastChair = wOutCardUser
    else
        self.wLastChair = self.wChair
    end

    local cbDiscardCount, cbDiscardCard = {}, {{}, {}, {}, {}} --丢弃数目
    for i=1,self.cbPlayerNum do
        table.insert(cbDiscardCount, ba:readUByte())    
    end    
    for j=1,self.cbPlayerNum do
        for i=1,37 do
            local card = ba:readUByte()
            if cbDiscardCount[j] >= i then
                table.insert(cbDiscardCard[j], card)  
            end
        end
    end

    local cbCardCount = {}--扑克数目
    for i=1,self.cbPlayerNum do
        table.insert(cbCardCount, ba:readUByte())
    end    
    for i=1,14 do
        --扑克列表
        local card = ba:readUByte()
        if cbCardCount[self.wChair + 1] >= i then
            table.insert(self.cbCardData[self.wChair + 1], card) 
        end
    end

    local cbSendCardData = ba:readUByte()         --发送扑克
    self.visibleCardSpList[1] = self.main_layer:addPlayerStaticDiscardCard(self.wChair, self.wBankerUser, cbDiscardCard, cbGameStatus ~= 1)
    for i=1,self.cbPlayerNum do
        local chair, bScore = i - 1, ba:readUByte()
        if bScore > 0 then
            table.insert(self.bIsPiao, {chair, bScore})
        end
    end
    self.main_layer:addPiaoMark()

	
    --解析吃碰杠
    local weaveFuncs = {}
    weaveFuncs[GameDefs.OperateCmd.Peng] = function(card, public, index, provide,wSpecialMark)
        local downcard = {card, card, card}
        local dirct = self:getProvideDirct(index - 1, provide)
        local uis, pos, dirction = self.main_layer.player_panel[index]:addPengWeave(downcard, dirct)

        table.insert(self.cdDownCard[index], downcard)
        table.insert(self.cdDownPengCard[index], card)
        table.insert(self.cdDownPengCard[index], uis[dirction]) 
		
		for i = 1,#uis do
			table.insert(self.visibleCardSpList[2],{card,uis[i]})
		end
		self:addDirectIcon("Peng",uis[dirction],index - 1,provide)
    end
    local gangNum = 0
    weaveFuncs[GameDefs.OperateCmd.Gang] = function(card, public, index, provide,wSpecialMark)
        local downcard = {card, card, card, card,provide}
        if public == 0 then
            --暗杠
            downcard[1], downcard[2], downcard[3] = 0, 0, 0
            local uis =  self.main_layer.player_panel[index]:addAnGangWeave(card)
			
			if  Bit:_and(wSpecialMark,0x0004) ~= 0 then --杠上杠
			  self:addDirectIcon("AnGang",uis[2],index - 1,provide)
			end
        elseif provide >= self.cbPlayerNum then
			local dirct = self:getProvideDirct(index - 1, provide - self.cbPlayerNum)
            --碰杠      
            local uis,  pos, dirction = self.main_layer.player_panel[index]:addPengWeave(downcard, dirct)
			
            local spriteCard = self.main_layer.player_panel[index]:addGangCard(uis[dirction])
			
			if Bit:_and(wSpecialMark,0x0004) ~= 0 then  --杠上杠
				downcard[5] = downcard[5]%self.cbPlayerNum
				self:addDirectIcon("PengGang",spriteCard,index - 1,provide%self.cbPlayerNum)
			end	
        else
            --杠
            local dirct = self:getProvideDirct(index - 1, provide)
            local uis,dirction= self.main_layer.player_panel[index]:addGangWeave(downcard, dirct)
			self:addDirectIcon("Gang",uis[dirction],index - 1,provide)
        end

        table.insert(self.cdDownCard[index], downcard)
        gangNum = gangNum + 1
    end

    local cbWeaveCount = {}                     --组合数目
    for i=1,self.cbPlayerNum do
        table.insert(cbWeaveCount, ba:readUByte())  
    end    

    local WeaveItemArray = {{}, {}, {}, {}}      --组合扑克
    for j=1,self.cbPlayerNum do
        for i=1,4 do
            local cbWeaveKind = ba:readUByte() --组合类型
            local cbCenterCard = ba:readUByte() --中心扑克
            local cbPublicCard = ba:readUByte() --公开标志
            local wProvideUser = ba:readShort() --供应用户
			local wSpecialMark = ba:readShort() --特殊标识
			for k = 1,4 do --后面多了4个字节
				ba:readByte()
			end
            if cbWeaveCount[j] >= i and weaveFuncs[cbWeaveKind] ~= nil then
               --解析数据 
               weaveFuncs[cbWeaveKind](cbCenterCard, cbPublicCard, j, wProvideUser,wSpecialMark)
            end
        end
    end

    function addCardPanel()
        --杠牌，取后面
        cbLeftCardCount = cbLeftCardCount + gangNum

        self.main_layer:addPlayerStaticPanel(self.wChair, self.cbCardData[self.wChair + 1], cbCardCount)
                    :getGameCardAnima(self.cbGameCardCount - cbLeftCardCount)

        for i=1,gangNum do
            self.main_layer:setCardDirct(1)
            self.main_layer:getGameCardAnima(1)
        end
    end
    local function addCardTip(func)
        if wOutCardUser >= 0 and wOutCardUser ~= wCurrentUser then
            self.main_layer.player_panel[wOutCardUser + 1]:addStaticPassedWithTip(cbActionCard, func)
        else
            func()
        end
    end
    if self.wChair == wCurrentUser then
        --自己摸到新牌
        local handcard = self.cbCardData[self.wChair + 1]
        local card = handcard[#handcard]
        table.remove(handcard)

        cbLeftCardCount = cbLeftCardCount + 1
        addCardPanel()
        self.main_layer:playTimerAnima(wCurrentUser)
           
        addCardTip(function()
            self.main_layer.player_panel[wCurrentUser + 1]:getCardAnima(card,
                function() self:onSelfSendCard(cbActionMask, card) end)
        end)        
    else
        if cbActionMask > 0 then
            --自己吃碰杠
            self.cbOperateCard = cbActionCard
            addCardPanel()
            addCardTip(function()
                    self:onOperateNotify(cbActionMask, self.wChair)
                    self.main_layer:playTimerAnima(wOutCardUser) end)
        elseif wCurrentUser >= 0 then
            --玩家摸牌
            cbLeftCardCount = cbLeftCardCount + 1
            cbCardCount[wCurrentUser + 1] = cbCardCount[wCurrentUser + 1] - 1
            addCardPanel()
            addCardTip(function()
                self.main_layer.player_panel[wCurrentUser + 1]:getCardAnima() 
                self.main_layer:playTimerAnima(wCurrentUser)
                end)
        else
            --玩家吃碰杠
            addCardPanel()
            addCardTip(function() self.main_layer:playTimerAnima(wOutCardUser) end)            
        end
    end
    self.main_layer:addMagicCard(self.cbMagicCardData) --添加鬼牌
	self.main_layer:addJianRenMark(cbJianRenStatus) --煎人标识 
	
    self:setIfGetSocketData(false)
    self.main_layer:gameStart(self.wChair, function()
        self:setIfGetSocketData(true)
    end)
end --end onSceneChanged

function GameLogic:onUserExit(chair, bself)
    self.user_list[chair] = 0

    if not self.main_layer.playerLogo_panel then
        return
    end

    --离开
    if bself then
        self.main_layer.playerLogo_panel:clearAllPlayer()
        self.main_layer:playGameRealyAnima()
    else
        self.main_layer.playerLogo_panel:clearPlayerByInfo(chair)
        self.main_layer:playGameRealyAnima(false, chair)
    end
end

function GameLogic:onLeaveTable()
    --离开
    if not self.bGameEnd then
        --单局未结束，提示玩家房间已解散
        self.main_layer:delayExitGame()
    end
end

function GameLogic:onUserStatus(info, myinfo)
    if not self.main_layer or not myinfo then
        return
    end

    local chair = info._chairID
    local status = info._status
    self.user_list[chair] = require("HallUtils").tableDup(info)

    --进入
    self.main_layer.playerLogo_panel:addPlayerLogo(info)
    if status == 4 and not self:isPlayingGame() then 
        if chair == self.myChair then 
            self.bGameEndState = 0 
        end
        
        self.main_layer:playGameRealyAnima(true, chair)
    end

    --断线，等待续玩
    self.main_layer.playerLogo_panel:updataPlayerOffLine(chair, status == 6)
    if status == 5 then
        self:checkPlayersIsSameIP()
    end
end

function GameLogic:onUserEnterRoom(pMyInfo)
    self.user_list                     = {}

    local tableID = pMyInfo:getUserTableID()

    if tableID >= 0 then
        --自己坐桌，初始化玩家界面
        local user = GameLibSink:getTableUserList(tableID)
        for i,v in ipairs(user) do
            v._score = v:getScore()
            self:onUserStatus(v, pMyInfo)
        end
    end

end

function GameLogic:onGameMessage(chair, cbCmdID, data, nLen)
    if self.messageBack_funcs[cbCmdID] then
        self.messageBack_funcs[cbCmdID](chair, data, nLen)
    end
end

--wSiceCount  WORD    骰子点数
--wBankerUser WORD    庄家用户
--wCurrentUser    WORD    当前用户
--cbUserAction    int    用户动作
--cbMagicCardData	  byte	万能牌
--cbCardData  BYTE[14]    扑克列表
--bTrustee    Bool[2] 是否托管
function GameLogic:onGameStartMessage(chair, data, nLen)
    if (nLen < (2 + 2 + 2 + 1 + 14 + 2)) then
        return
    end
	cclog("onGameStartMessage : "..FriendGameLogic.game_used)
    local ba = require("ByteArray").new()
    ba:writeBuf(data)
    ba:setPos(1)

    self:initGameData()

    for i=1,2 do
        table.insert(self.cbSiceData, ba:readUByte())    
    end
    self.wBankerUser = ba:readShort()
    local wCurrentUser = ba:readShort()
    self.cbOperateCode = ba:readInt()
	self.cbMagicCardData = ba:readUByte()
	self.cbGameCardCount = ba:readShort()
	
    self.wLastChair = self.wBankerUser
    
    self.bBanker = self.wBankerUser == self.wChair  
    for i=1,14 do
        table.insert(self.cbCardData[self.wChair + 1], ba:readUByte())    
    end
    if self:cardNotAble(self.cbCardData[self.wChair + 1][14]) then
        --无效值
        table.remove(self.cbCardData[self.wChair + 1])
    end
    self.bSender = self.bBanker

    for i=1,self.cbPlayerNum do
        --table.insert(self.bTrustee, ba:readUByte()) 
		table.insert(self.bTrustee, 0)		
    end

	cclog("鬼牌："..self.cbMagicCardData)
    --显示牌墙
    self:setIfGetSocketData(false)
    local sameIPs = self:checkPlayersIsSameIP()
    self.main_layer:addPlayerPanel(chair, self.wBankerUser, sameIPs,self.cbMagicCardData, function()
        self:onHandOperateNotify(self.cbOperateCode)        

        self:setIfGetSocketData(true)       
    end)

    --刷新游戏次数
    FriendGameLogic.game_abled = true
    FriendGameLogic.game_used = FriendGameLogic.game_used + 1
    self.main_layer:updataFriendGameUI()

    --重置玩家分数
    self:checkPlayersScore()
end

function GameLogic:checkPlayersScore()
    --校准游戏开始分数，重置为0
    if FriendGameLogic.game_type == 0 and FriendGameLogic.game_used == 0 then
        for i=1,self.cbPlayerNum do
            self.main_layer.playerLogo_panel:updataPlayerGold(i - 1, 0)
        end
    end
end

--初始化游戏本地配置信息
function GameLogic:resetGameConfig()
    --相同ip
    CCUserDefault:sharedUserDefault():setStringForKey("same_ip12", "")
end

--检查是否相同ip
function GameLogic:checkPlayersIsSameIP()
    local sameIPRecorder = { count=0 }

    --同桌好友信息
    local info = self:GetMyInfo()
    if not info or info == 0 then return end

    local userList = require("HallUtils").tableDup(self.user_list)
    for i, j in pairs(userList) do
        for k, v in pairs(userList) do
            if v and j and v~=0 and j~=0 then
                if k ~= i and v._userIP == j._userIP and (not sameIPRecorder[v._chairID]) then
                    sameIPRecorder[v._chairID] = {name = v._name, ip = v._userIP}
                    sameIPRecorder.count = sameIPRecorder.count + 1
                end
            end
        end
    end
    
    if sameIPRecorder.count > 0 then
        --保存相同Ip到本地
        local sameips = require("cjson").encode(sameIPRecorder)
        CCUserDefault:sharedUserDefault():setStringForKey("same_ip12", sameips) 

        return sameIPRecorder
    end    

    return nil
end

--wOutCardUser    WORD    出牌用户
--cbOutCardData   BYTE    出牌扑克
function GameLogic:onOutCardMessage(chair, data, nLen)
    if (nLen < (2 + 1)) then
        return
    end

    local ba = require("ByteArray").new()
    ba:writeBuf(data)
    ba:setPos(1)

    local wOutCardUser = ba:readShort()
    local cbOutCardData = ba:readUByte()
    
    if self.wChair ~= wOutCardUser then
        self:onPlayerOutCard(wOutCardUser, cbOutCardData)
	else --自己出牌要把这张牌设置为非选中状态
		self:onCardStateChange(0,cbOutCardData)
    end
    self.wLastChair = wOutCardUser
end

function GameLogic:onPlayerOutCard(wOutCardUser, cbOutCardData)
    for i=1,self.cbPlayerNum do
        self.main_layer.player_panel[i]:addCardArrowAnima(false, ccp(-100, -100))
    end

    self.main_layer.playerLogo_panel:playCardVoice(wOutCardUser, cbOutCardData)
    self.main_layer.playerLogo_panel:updataPlayerOperator(wOutCardUser, false)

    cclog("GameLogic:onOutCardMessage "..wOutCardUser..";"..self.wChair..";"..cbOutCardData)
    --出牌动画
    local cardSp = self.main_layer.player_panel[wOutCardUser + 1]:sendCardAnima(cbOutCardData)
	
	table.insert(self.visibleCardSpList[1][wOutCardUser + 1],{cbOutCardData,cardSp})
end

--自己打牌处理
function GameLogic:onSelfOutCard(card)
    self.bSender = false

    local panel = self.main_layer.player_panel[self.wChair + 1]
    --防止空值
    panel.card_index = panel.card_index or #self.cbCardData[self.wChair + 1]

    local index = panel.card_uis[panel.card_index].carddata_index
    if index and self.cbCardData[self.wChair + 1][index] == card then
        --卡牌存在
        table.remove(self.cbCardData[self.wChair + 1], index)
    else
        --查找值为card的坐标
        local cardIndex = self:getMineCardIndex(card)
        if cardIndex then
            panel.card_index = cardIndex
            table.remove(self.cbCardData[self.wChair + 1], cardIndex)
        end
    end
        
end

--cbCardData  BYTE    扑克数据
--nActionMask    int    动作掩码
--wCurrentUser    WORD    当前用户
function GameLogic:onSendCardMessage(chair, data, nLen) --用户抓牌
    if (nLen < (2 + 1)) then
        return
    end

    local ba = require("ByteArray").new()
    ba:writeBuf(data)
    ba:setPos(1)

    local cbCardData = ba:readUByte()
    local nActionMask = ba:readInt()
    local wOutCardUser = ba:readShort()
 
    self.main_layer:playTimerAnima(wOutCardUser)    

    --抓牌动画
    self.main_layer.player_panel[wOutCardUser + 1]:getCardAnima(cbCardData,
        function() self:onSelfSendCard(nActionMask, cbCardData) end)
    
end

--自己抓牌处理
function GameLogic:onSelfSendCard(mark, card)
    table.insert(self.cbCardData[self.wChair + 1], card)
    self.bSender = true
    self:onHandOperateNotify(mark)
end

--wResumeUser WORD    还原用户
--nActionMask    int    动作掩码
--cbActionCard    BYTE    动作扑克
function GameLogic:onOperateNotifyMessage(chair, data, nLen)--用户的操作提示
    if (nLen < (2 + 1 + 1)) then
        return
    end

    local ba = require("ByteArray").new()
    ba:writeBuf(data)
    ba:setPos(1)

    local wResumeUser = ba:readShort()
    local nActionMask = ba:readUInt()
    self.cbOperateCard = ba:readUByte()

    self.main_layer.player_panel[self.wChair + 1]:startOperatorTimer()
    --是否为自己操作
    if not self.bSender then
        self:onOperateNotify(nActionMask) --被动操作
    else
        self:onHandOperateNotify(nActionMask) -- 自己主动操作
    end
end

function GameLogic:onOperateNotify(cbActionMask) --被动操做
    if cbActionMask > 0 then
		self:printAction(cbActionMask)
        -- 震动
        local SetLogic = require("Lobby/Set/SetLogic")
        SetLogic.playGameShake(100)
        SetLogic.playGameEffect(AppConfig.SoundFilePathName.."operatorcard_effect"..AppConfig.SoundFileExtName)
        

        --判断是否能过
        if self:mineIsGuo() then
            self.main_layer.player_panel[self.wChair + 1]:addOperatorBtn("guo", function()
                self:sendOperateCard(GameDefs.OperateCmd.No)
                self.main_layer.player_panel[self.wChair + 1]:clearOperatorBtn()
                self.cbOperateCard = nil
            end)
        end

        --吃牌
		self:onCheckChiNotify(cbActionMask)

        --杠牌、碰牌
        self:onCheckPengNotify(cbActionMask)

        --[[听牌
        if Bit:_and(GameDefs.OperateCmd.Ting, cbActionMask) ~= 0 then
            self.main_layer.player_panel[self.wChair + 1]:addOperatorBtn("ting", function()
               self:sendTingCard()
            end)
        end]]

        --吃胡
        self:onCheckHuNotify(cbActionMask, false)

        self.cbOperateCode = cbActionMask                
    end
end
function GameLogic:printAction(cbActionMask) --输出玩家能进行哪些操作
	if cbActionMask == 0 then return end
	local msg = "玩家能进行 "
	if  Bit:_and(GameDefs.OperateCmd.Left_Chi, cbActionMask) ~= 0  or 
		Bit:_and(GameDefs.OperateCmd.Middle_Chi, cbActionMask) ~= 0 or
		Bit:_and(GameDefs.OperateCmd.Right_Chi, cbActionMask) ~= 0 then
		msg = msg.."吃 "
	end
	if Bit:_and(GameDefs.OperateCmd.Peng, cbActionMask) ~= 0 then
		msg = msg.."碰 "
	end
	if Bit:_and(GameDefs.OperateCmd.Gang, cbActionMask) ~= 0 then
		msg = msg.."杠 "
	end
		if Bit:_and(GameDefs.OperateCmd.Ting, cbActionMask) ~= 0 then
		msg = msg.."听 "
	end
		if Bit:_and(GameDefs.OperateCmd.Chi_Hu, cbActionMask) ~= 0 then
		msg = msg.."胡牌 "
	end
	cclog(msg)
end
function GameLogic:onHandOperateNotify(cbActionMask)--自己抓牌时，判断能进行哪些操作
    self.cbOperateCard = nil
	
    if cbActionMask > 0 then
		self:printAction(cbActionMask)
        -- 震动
        local SetLogic = require("Lobby/Set/SetLogic")
        SetLogic.playGameShake(100)
        SetLogic.playGameEffect(AppConfig.SoundFilePathName.."operatorcard_effect"..AppConfig.SoundFileExtName)

		cclog("能进行的操作:"..cbActionMask)
        self.main_layer.player_panel[self.wChair + 1]:addOperatorBtn("guo", function()
            --self:sendOperateCard(GameDefs.OperateCmd.No)
            self.main_layer.player_panel[self.wChair + 1]:clearOperatorBtn()
        end)

        if Bit:_and(GameDefs.OperateCmd.Gang, cbActionMask) ~= 0 then
            --手牌数据
            local count, gangs = #self.cbCardData[self.wChair + 1], {}
            local cards = require("HallUtils").tableDup(self.cbCardData[self.wChair + 1])
            table.sort(cards)
            
            for i=1,count do
                --手牌杠
                if  not self:isSpecialCard(cards[i]) and i < count - 2 and cards[i] == cards[i + 3] 
                    and  cards[i] == cards[i + 2] then
                    table.insert(gangs, cards[i])
                    i = i + 3
                end

                for j,v in ipairs(self.cdDownPengCard[self.wChair + 1]) do
                    if j % 2 ~= 0 and v == cards[i] then
                        --由碰转杠
                        table.insert(gangs, v)
                    end
                end
            end

            --杠牌
            self.main_layer.player_panel[self.wChair + 1]:addGangBtn(gangs)
        end

        --吃胡
        self:onCheckHuNotify(cbActionMask, true)
        self.cbOperateCode = cbActionMask              
    end
end

--吃牌
function GameLogic:onCheckChiNotify(cbActionMask)
    if Bit:_and(0x07, cbActionMask) ~= 0 then
        --吃牌
        local bChi = {false, false, false}
        for i=0,2 do
            if Bit:_and(cbActionMask, math.pow(2,i)) ~= 0 then
                bChi[i + 1] = true
            end
        end

        self.main_layer.player_panel[self.wChair + 1]:addChiBtn(bChi, self.cbOperateCard)            
    end
end

--杠牌、碰牌
function GameLogic:onCheckPengNotify(cbActionMask)
    if Bit:_and(GameDefs.OperateCmd.Peng, cbActionMask) ~= 0 then
        --碰牌
        self.main_layer.player_panel[self.wChair + 1]:addOperatorBtn("peng", function()
           self:sendOperateCard(GameDefs.OperateCmd.Peng)
        end)         
    end 

        if Bit:_and(GameDefs.OperateCmd.Gang, cbActionMask) ~= 0 then
            --杠牌
            self.main_layer.player_panel[self.wChair + 1]:addOperatorBtn("gang", function()
               self:sendOperateCard(GameDefs.OperateCmd.Gang)
            end)
        end       
end

--胡牌
function GameLogic:onCheckHuNotify(cbActionMask, isSelf)
    if Bit:_and(GameDefs.OperateCmd.Chi_Hu, cbActionMask) ~= 0 then
        local img = "hu"
        if isSelf then
            img = "zimo"
            self.main_layer.player_panel[self.wChair + 1]:addOperatorBtn(img, function()
                self.cbOperateCard = self.cbCardData[self.wChair + 1][#self.cbCardData[self.wChair + 1]]
                self:sendOperateCard(GameDefs.OperateCmd.Chi_Hu)
            end)
            return
        end

        self.main_layer.player_panel[self.wChair + 1]:addOperatorBtn(img, function()
           self:sendOperateCard(GameDefs.OperateCmd.Chi_Hu)
        end)

        return true
    end

    return false
end

--wOperateUser    WORD    操作用户
--wProvideUser    WORD    供应用户
--nActionMask     int    动作掩码
--cbActionCard    BYTE    动作扑克
function GameLogic:onOperateResultMessage(chair, data, nLen)
    if (nLen < (2 + 2 + 1 + 1)) then
        return
    end

    local ba = require("ByteArray").new()
    ba:writeBuf(data)
    ba:setPos(1)

    local wOperateUser = ba:readShort()
    local wProvideUser = ba:readShort()
    local nActionMask = ba:readInt()
    local cbActionCard = ba:readUByte()
	local nSpecialMark = ba:readInt() -- 特殊标识
	
	cclog("nSpecialMark = "..nSpecialMark)
    self.bSender = false
    if self.wChair == wOperateUser then
        --杠牌等待摸到手牌才能操作
        self.bSender = nActionMask ~= GameDefs.OperateCmd.Gang
    end

 --   if not self.bOperated then
        --其他人操作
        self:onPlayerOperateResultMessage(wOperateUser, wProvideUser, nActionMask, cbActionCard,nSpecialMark)
  --  end
  --  self.bOperated = false
	
	if wSpecialMark  and wSpecialMark ~= 0 then
		
	end
end

function GameLogic:onPlayerOperateResultMessage(wOperateUser, wProvideUser, cbActionMask, cbActionCard,nSpecialMark)
   
   if cbActionMask == GameDefs.OperateCmd.Chi_Hu then
		if wOperateUser == self.wChair then--可以多人胡牌，除非是自己胡牌，否则不清除操作按钮
			self.main_layer.player_panel[self.wChair + 1]:clearOperatorBtn()
		end	
	else
		self.main_layer.player_panel[self.wChair + 1]:clearOperatorBtn()
		self.main_layer:playTimerAnima(wOperateUser)
	end


    --去掉打出的牌
    cclog("GameLogic:onOperateResultMessage "..cbActionCard..";"..cbActionMask)
    

    if self.operatorBack_funcs[cbActionMask] then
        self.operatorBack_funcs[cbActionMask](wOperateUser, cbActionCard, wProvideUser,nSpecialMark)
    end
end

function GameLogic:onGetBirdMessage(chair, data, nLen)
    if (nLen < 6) then        
        return 
    end

    local ba = require("ByteArray").new()
    ba:writeBuf(data)
    ba:setPos(1)

    for i=1,10 do
        local card = ba:readUByte()
        if not self:cardNotAble(card) then
            table.insert(self.cbBird, card)
        end
    end
    --抓中的鸟
    for i=1,10 do
        local card = ba:readUByte()
        if self:cardNotAble(card) then
            break
        end
        table.insert(self.cbValidBird, card)  
    end 
end

function GameLogic:onChoosePiaoMessage(chair, data, nLen)
    --[[if (nLen < 4) then        
        return 
    end

    local ba = require("ByteArray").new()
    ba:writeBuf(data)
    ba:setPos(1)
    local nPiaoCellScor = ba:readInt()

    self.main_layer:addPiaoPanel(nPiaoCellScor)]]
end

function GameLogic:onPiaoStatusMessage(chair, data, nLen)
    if (nLen < 4) then        
        return 
    end

    local ba = require("ByteArray").new()
    ba:writeBuf(data)
    ba:setPos(1)

    local pchair = ba:readUShort()
    local bPiao = ba:readUByte()
    local bScore = ba:readUByte()
    self.bPiaoType = ba:readUByte()

    if bScore > 0 then
        table.insert(self.bIsPiao, {pchair, bScore})
        self.main_layer:addPiaoMark()
    end

    if self.wChair == pchair then
        if bPiao == 1 then
            self.main_layer:addPiaoPanel(5)   
        elseif self:GetMeStatus() < 4 then
            self.main_layer:waitForPiao(0)
        end 
    end    
end

--allPayUser    WORD    游戏税收
--wProvideUser    WORD    供应用户
--cbProvideCard   BYTE    供应扑克
--cbWinUser   WORD    胡牌用户
--cbBankerUser   WORD    庄家用户
--cbCardCount BYTE[4] 玩家扑克数目
--cbCardData  BYTE[4][14] 玩家扑克数据
--UserScoreList   Struct[4]   游戏积分
--UserScore->nTotoalScore int 玩家总积分
--UserScore-> nHuScore    int 胡牌积分
--UserScore-> nGangScore  int 杠牌积分
--UserScore-> nBirdScore  int 抓鸟积分
function GameLogic:onGameEndMessage(chair, data, nLen) --135 73
	
	self.main_layer.player_panel[self.wChair + 1]:clearOperatorBtn()
	
    if (nLen < 70) then        
        return 
    end
    self.bGameEnd = true
    
    local ba = require("ByteArray").new()
    ba:writeBuf(data)
    ba:setPos(1)

    local endInfo = {}

    endInfo.allPayUser = ba:readUShort() --全赔用户
    endInfo.wProvideUser = ba:readUShort()
    endInfo.cbProvideCard = ba:readUByte()

	local cbBankerUser = ba:readUShort()    --庄家用户
	
   -- endInfo.cbWinUser = ba:readUShort()       --胡牌用户
    endInfo.cbWinUser = {}
	for j=1,self.cbPlayerNum do
		endInfo.cbWinUser[j] = ba:readByte()
	end
    
    local cbCardCount = {}                  --玩家扑克数目
    for i=1,self.cbPlayerNum do
        table.insert(cbCardCount, ba:readUByte())  
    end    
    endInfo.cbCardData = {{}, {}, {}, {}}             --玩家扑克数目
    for j=1,self.cbPlayerNum do
        for i=1,14 do
            local card = ba:readUByte()
            if cbCardCount[j] >= i then
                table.insert(endInfo.cbCardData[j], card)  
            end
        end
    end

    endInfo.UserScoreList, endInfo.gameScores = {}, {} --游戏积分       
    for i=1,self.cbPlayerNum do
        local score = {nTotoalScore = ba:readInt(), nHuScore = ba:readInt(), nGangScore = ba:readInt(), 
                nHorseScore = ba:readInt(), nHorseFollowGangScore = ba:readInt(),nPiaoScore = ba:readInt(),nCallBankerScore = ba:readInt()}
        table.insert(endInfo.UserScoreList, score)

        table.insert(endInfo.gameScores, score.nTotoalScore - score.nHorseScore - score.nHorseFollowGangScore)-- 
    end
    local bIsDaHu = false--ba:readUByte() --是否大胡
	
   -- self.nHuRight = ba:readInt() --胡牌权限
	for j=1,self.cbPlayerNum do
		self.nHuRight[j] = ba:readInt()
	end
	
    --玩家信息
    local TempUser = {}
    TempUser.nUserID={}
    for i=1,self.cbPlayerNum do
        table.insert(TempUser.nUserID, ba:readInt())
    end

    TempUser.cbSex={}
    for i=1,self.cbPlayerNum do
        table.insert(TempUser.cbSex, ba:readUByte())
    end

    TempUser.szUserName={}
    for i=1,self.cbPlayerNum do
        table.insert(TempUser.szUserName, getUtf8(ba:readStringSubZero(32)))
    end

    local userInfos = {}
    for i=1,self.cbPlayerNum do
        local info = {_name = TempUser.szUserName[i], _userDBID = TempUser.nUserID[i], 
                    _sex = TempUser.cbSex[i], _faceID = 1, m_cbFaceChagneIndex = 0, 
                    _userIP = "127.0.0.1", _score = 0}
        table.insert(userInfos, info)
    end
------------------------------------------------------------------------------------------------
    self:playGameEndAnim(endInfo, userInfos,cbBankerUser)

    self.bIsPiao = {}
end

function GameLogic:playGameEndAnim(endInfo, userInfos,cbBankerUser) 
    --设置玩家头像
    local exitPlyer = {}
    if userInfos then
        for i,v in ipairs(userInfos) do
            local index = i - 1
            if not self.main_layer.playerLogo_panel.logo_table[i] then
                local chair = self:getRelativeChair(index)
                self.main_layer.playerLogo_panel:addCommonPlayer(v, index, chair, v._score)      
                table.insert(exitPlyer, index)      
            end
        end
    end
	
    self:setIfGetSocketData(false)
    local function showBack()
        --清空不存在玩家头像
        for i,v in ipairs(exitPlyer) do
            self:onUserExit(v, false)
        end

        self:setIfGetSocketData(true)
    end
	
    --取消牌局操作
    self.main_layer:stopGameOperator()

    local cbWinUser, cbCardData, wProvideUser = endInfo.cbWinUser, endInfo.cbCardData, endInfo.wProvideUser
    local cbProvideCard, UserScoreList, gameScores = endInfo.cbProvideCard, endInfo.UserScoreList, endInfo.gameScores
	
	--统计赢家数量，也就是有多少个人胡牌
	local winCount = 0
	local ctype = 2 -- 自己赢了还是输了
	for j = 1,#cbWinUser do
		if cbWinUser[j] == 1 then
			winCount = winCount + 1
			if j - 1 == self.wChair then
				ctype = 1 
			end
		end
	end
	if winCount == 0 then ctype  = 3 end
	if true then --流局和正常结束都要显示结算界面
	    self.main_layer:addResultPanel(ctype)		
        local function showGameResult()      
			--播放胡牌类型语言
            require("Lobby/Set/SetLogic").playGameEffect(AppConfig.SoundFilePathName.."gamend"..ctype..AppConfig.SoundFileExtName)
			self.main_layer.result_panel:addBirdMark(self.cbBird, self.cbValidBird)
			self.main_layer.result_panel:addResultInfo(self.cbPlayerNum,
				UserScoreList, self.cdDownCard, cbCardData, cbProvideCard, cbBankerUser, 
				cbWinUser, wProvideUser, self.wChair, self.nHuRight,endInfo.allPayUser)
			
            self.main_layer:gameEnd()
            self.main_layer.result_panel:show(showBack)                        
        end 
		--设置回调函数
		local array = CCArray:create()
		array:addObject(CCDelayTime:create(1.5))
		array:addObject(CCCallFunc:create(function()
			self:playEndSeriesAnima(gameScores, showGameResult)
		end))
        self.main_layer:runAction(CCSequence:create(array))  
	end
end

--[[  
[1] = {
         Changed = 0,
         FaceID = 0,
         RuleScoreInfo = "",
         Score = -4,
         Sex = 0,
         UserID = 10015,
         UserNickName = "猜猜我少",
	}
]]
function GameLogic:onFriendTableEndMessage(infoList)

	tablePrint(infoList)
	
    self.bGameEnd = true
    self.bFriendEnd = true
    self.main_layer:addFriendResultPanel(infoList)
	
    --离开游戏
    FriendGameLogic.onFriendGameOver()

    if require("LobbyControl").gameSink ~= nil then
        require("LobbyControl").gameSink = nil
        GameLibSink.game_lib:leaveGameRoom()
        GameLibSink.game_lib:release()
        GameLibSink.game_lib = nil
    end  

    GameLogic.message_data = {}
    self:clearSecesTimerScript()    
end

function GameLogic:playEndSeriesAnima(scores, func)
    self.main_layer:addGoldResult(scores, function()
        --飞鸟
        if #self.cbBird > 0 then
            self.main_layer:addHorsePanel(self.cbBird, self.cbValidBird, function()
                if func then func() end
             end)
        else
              --  require("HallUtils").showWebTip("本局游戏由于剩余牌数为空无法抓鸟")
            if func then func() end
        end 
    end, function() end)       
end

--庄家是否为自己
function GameLogic:mineIsBanker()
    return self.bBanker
end

--获取在线玩家、总玩家
function GameLogic:getPlayeCount()
    local count = 0
    for i=1,self.cbPlayerNum do
        if self.user_list[i - 1] and self.user_list[i - 1]~=0 then
            count = count + 1
        end
    end

    return count, self.cbPlayerNum
end

function GameLogic:getUserByChair(chair)
    return self.user_list[chair]
end

function GameLogic:getProvideDirct(obtain, provide)
    local obtainChair = self:getRelativeChair(obtain)
    local provideChair = self:getRelativeChair(provide)
    local chair = (provideChair - obtainChair + 4) % 4

    return chair    
end

function GameLogic:getAbsolutelyChair(pos)--绝对椅子号
    local chair = (pos - 1 + self.wChair) % 4

    if self.cbPlayerNum == 3 then
        if self.wChair == 0 then
            --东方
            local chairs = {0, 1, 3, 2}
            return chairs[pos]            
        elseif self.wChair == 2 then
            --西方
            local chairs = {2, 0, 3, 1}
            return chairs[pos]             
        end
    end

    return chair    
end

function GameLogic:getRelativeChair(playerchair)
    cclog("getRelativeChair "..tostring(playerchair))
	playerchair = playerchair % self.cbPlayerNum
    if self.cbPlayerNum == 3 then
        if self.wChair == 0 then
            --东方
            local chairs = {1, 2, 4}
            return chairs[playerchair + 1]                       
        elseif self.wChair == 2 then
            --西方
            local chairs = {2, 4, 1}
            return chairs[playerchair + 1]             
        end
    end

    local pos = (playerchair + 4 - self.wChair) % 4
    return pos + 1    
end

--相对位置三人椅子转换
function GameLogic:getThreeRelativeChair(chair)
    if self.wChair == 0 then
        return (chair + 1) % 3
    elseif self.wChair == 2 then
        return (chair + 2) % 3
    end

    return chair
end


function GameLogic:getMyPanel()
    local myChair = self.wChair
    if self.main_layer and self.main_layer.player_panel then
        return self.main_layer.player_panel[myChair + 1]
    end
end

function GameLogic:getMyDownCard()
    local myChair = self.wChair
    if self.cdDownCard then
        return self.cdDownCard[myChair + 1]
    end
end

--判断是否为有效牌值
function GameLogic:cardNotAble(card)
    if not card or card == 0 then
        return true
    end

    return false
end

function GameLogic:setCardIndex(chair, card) 
    local cout = #self.cbCardData[chair + 1]
    for i = cout, 1, -1 do
        cclog("setCardIndex "..self.cbCardData[chair + 1][i]..";"..card)
        if self.cbCardData[chair + 1][i] == card then
            self.main_layer.player_panel[chair + 1]:setCardIndex(i)
            return
        end
    end

end

 --删除手牌
function GameLogic:removeMineCards(removeCard)
    return self:removePlayerCards(self.wChair, removeCard)
end

 --删除椅子手牌
function GameLogic:removeCardsByChair(cardDatas, removeCard, chair)
    local cards = cardDatas[chair + 1]
    table.sort(cards)
    table.sort(removeCard)

    local indexTable = {}
    local j = #removeCard
    for i=#cards, 1, -1 do 
        if cards[i] == removeCard[j] then 
            j = j - 1
            table.insert(indexTable, i)
            table.remove(cards, i) 

            if j < 1 then
                break
            end
        end 
    end

    return indexTable, cardDatas
end

function GameLogic:removePlayerCards(chair, removeCard)
    local cards = self.cbCardData[chair + 1]

    local indexTable = {}
    local j = #removeCard
    for i=#cards, 1, -1 do 
        if cards[i] == removeCard[j] then 
            j = j - 1
            table.insert(indexTable, i)
            table.remove(cards, i) 

            if j < 1 then
                break
            end
        end 
    end

    return indexTable, cards
end

--替换手牌
function GameLogic:replaceMineCards(cards, repcard)
    local replaceIndexs = {}    --替换数据下标
    local handcard = self.cbCardData[self.wChair + 1]

    for i,v in ipairs(cards) do
        if self:cardNotAble(v) then
            break
        end
        
        for j=#handcard, 1, -1 do 
            if handcard[j] == v then 
                handcard[j] = repcard[i]
                table.insert(replaceIndexs, j)
            end 
        end
    end

    return replaceIndexs
end

--获取上家玩家UI
function GameLogic:getLastPlayerPanle()
    cclog("getLastPlayerPanle "..self.wLastChair)
    return self.main_layer.player_panel[self.wLastChair + 1]
end

--整理手牌
function GameLogic:sortMineCards()
    local t = self.cbCardData[self.wChair + 1]
    -- 从小到大排序, 并强制癞子在左侧
    table.sort(t, function(a, b)
        if self:isSpecialCard(a) then
            if self:isSpecialCard(b) then
                return false
            else
                return true
            end
        else
            if self:isSpecialCard(b) then
                return false
            else
                return a < b
            end
        end
    end)
    return t
end

function GameLogic:mineIsGuo()
    for i,v in ipairs(self.cbCardData[self.wChair + 1]) do
--        if v ~= 0x35 then
		if not self:isSpecialCard(cbCardData) then
            return true
        end
    end

    return false
end

--获取手牌
function GameLogic:getMineCards(chair)
    chair = chair or self.wChair
    return self.cbCardData[chair + 1]
end

--获取手牌坐标
function GameLogic:getMineCardIndex(card)
    local cout = #self.cbCardData[self.wChair + 1]
    for i = cout, 1, -1 do
        if self.cbCardData[self.wChair + 1][i] == card then
            return i
        end
    end
    return nil
end

--获取手牌个数
function GameLogic:getMineCardCount(card)
    local cout, inum = #self.cbCardData[self.wChair + 1], 0
    for i = cout, 1, -1 do
        if self.cbCardData[self.wChair + 1][i] == card then
            inum = inum + 1
        end
    end
    return inum
end

--获取手牌根据坐标
function GameLogic:getMineCardFromIndex(index)
    local cout = #self.cbCardData[self.wChair + 1]
    if index>=1 and index<=cout then
        return self.cbCardData[self.wChair + 1][index]
    end

    return nil
end

--自己是否可以打牌
function GameLogic:mineIsSender()
    return self.bSender
end

function GameLogic:GetMyInfo()
    return self.user_list[self.wChair]
end

function GameLogic:GetMeStatus()
    if self.user_list[self.wChair] and self.user_list[self.wChair] ~= 0 then
        return self.user_list[self.wChair]._status
    end

    return 0
end

function GameLogic:GetMeDBID()
    if self.user_list[self.wChair] and self.user_list[self.wChair] ~= 0 then
        return self.user_list[self.wChair]._userDBID
    end

    return 0
end

function GameLogic:GetUserName(userID)
    for k,v in pairs(self.user_list) do
        if v ~= 0 and v._userDBID ==  userID then
            return v._name
        end
    end

    return ""
end

--替换到登录主界面
function GameLogic:replaceMainScence(pMyInfo)
    pMyInfo = pMyInfo or GameLibSink:getMyInfo()

    GameLibSink.game_lib:startCheckPing()
    FriendGameLogic.enterGameRoomSuccess()
    
    local LayerGame = require(GameDefs.CommonInfo.Code_Path.."Game/LayerGame")
    if self.main_layer then
        --断线重回
        if self.bGameEndState > 0 then
            --重置玩家头像
            self:onUserExit(0, true)            
        else
            --游戏界面重置
            self.main_layer:removeFromParentAndCleanup(true)
            self:initGameData()

            local scence = CCDirector:sharedDirector():getRunningScene()
            self.main_layer = LayerGame.create(self.cbPlayerNum,self)
            self.main_layer:initGameUI()

            self.main_layer:setTimerDirct(self.wChair)

            scence:addChild(self.main_layer)
        end
    else
        self:initGameData()
        self.wChair = pMyInfo:getUserChair()

        local scence, layer = LayerGame.createScene(self.cbPlayerNum,self)
        LayerGame.checkLocation = false --初始化定位变量

        CCDirector:sharedDirector():replaceScene(scence)
        layer:initGameUI()

        layer:setTimerDirct(self.wChair)

        require("LobbyControl").gameLogic = self
        require("LobbyControl").removeHallCache()

        --设置当前操作UI
        self.main_layer = layer        
    end

    self:onUserEnterRoom(pMyInfo)

    GameLibSink:onEnterGameView()    
end

--设置广播回调
function GameLogic:registGameBack()
    self.socketBack_funcs[SOCKET_TYPE_SCENE] = function(sockData)
        self:onSceneChanged(sockData[1], sockData[2])
    end

    self.socketBack_funcs[SOCKET_TYPE_GAME] = function(sockData)
        self:onGameMessage(sockData[1], sockData[2], sockData[3], sockData[4])
    end

    self.socketBack_funcs[SOCKET_TYPE_USEREXIT] = function(sockData)
        self:onUserExit(sockData[1], sockData[2])
    end    

    self.socketBack_funcs[SOCKET_TYPE_FRIENDRULE] = function(sockData)
        self:onFriendRuleMessage(sockData[1], sockData[2], sockData[3])
    end 

    self.socketBack_funcs[SOCKET_TYPE_LEAVETABLE] = function(sockData)
        self:onLeaveTable()
    end 

    self.socketBack_funcs[SOCKET_TYPE_FRIENDABLED] = function(sockData)
        self:onFriendTabledAbled()
    end

    self.socketBack_funcs[SOCKET_TYPE_FRIENDEND] = function(sockData)
        self:onFriendTableEndMessage(sockData[1])
    end

    self.socketBack_funcs[SOCKET_TYPE_USERSTATUS] = function(sockData)
        self:onUserStatus(sockData[1], sockData[2])
    end

    self.socketBack_funcs[SOCKET_TYPE_REPLACE] = function(sockData)
        self:replaceMainScence()
    end

    --游戏开始
    self.messageBack_funcs[GameDefs.CmdInfo.S_Game_Start] = function(chair, data, nLen)
        self:onGameStartMessage(chair, data, nLen)
    end

    --玩家出牌
    self.messageBack_funcs[GameDefs.CmdInfo.S_Out_Card] = function(chair, data, nLen)
        self:onOutCardMessage(chair, data, nLen)
    end

    --玩家摸牌
    self.messageBack_funcs[GameDefs.CmdInfo.S_Send_Card] = function(chair, data, nLen)
        self:onSendCardMessage(chair, data, nLen)
    end

    --玩家操作提示  
    self.messageBack_funcs[GameDefs.CmdInfo.S_Operate_Notify] = function(chair, data, nLen)
        self:onOperateNotifyMessage(chair, data, nLen)
    end

    --玩家操作结果  
    self.messageBack_funcs[GameDefs.CmdInfo.S_Operate_Result] = function(chair, data, nLen)
        self:onOperateResultMessage(chair, data, nLen)
    end

    --抓鸟
    self.messageBack_funcs[GameDefs.CmdInfo.S_Get_Bird] = function(chair, data, nLen)
        self:onGetBirdMessage(chair, data, nLen)
    end

    --飘通知
    self.messageBack_funcs[GameDefs.CmdInfo.S_ChoosePiao] = function(chair, data, nLen)
        self:onChoosePiaoMessage(chair, data, nLen)
    end

    --飘广播
    self.messageBack_funcs[GameDefs.CmdInfo.S_UserPiaoStatus] = function(chair, data, nLen)   
        self:onPiaoStatusMessage(chair, data, nLen)
    end

    --游戏结束  
    self.messageBack_funcs[GameDefs.CmdInfo.S_Game_End] = function(chair, data, nLen)
        self.bGameEndState = 1

        self:onGameEndMessage(chair, data, nLen)
    end

    self:registOperatorBack()

    self:OnReadyGame()
end

--设置操作牌广播回调
function GameLogic:registOperatorBack()
    self.operatorBack_funcs[GameDefs.OperateCmd.Peng] = function(chair, card, provide,nSpecialMark)
        local downcard = {card, card, card}
        local removeCard = {card, card}

        self.main_layer:playOperatorAnima("peng", chair)
        self.main_layer.playerLogo_panel:playOperatorVoice(chair, 0x8)
        
        table.insert(self.cdDownCard[chair + 1], downcard)
        local uis,dirction = self.main_layer.player_panel[chair + 1]:onChiPengAnima(downcard, removeCard, 
                                                            self:getProvideDirct(chair, provide))

        table.insert(self.cdDownPengCard[chair + 1], card)
        table.insert(self.cdDownPengCard[chair + 1], uis[dirction]) 
		
		for i = 1,#uis do--保存扑克精灵,用户选择牌提示的时候需要用到
			table.insert(self.visibleCardSpList[2],{card,uis[i]})
		end
		for i = #self.visibleCardSpList[1][provide+1],1,-1 do -- 删除打出去的牌
			if card == self.visibleCardSpList[1][provide+1][i][1] then
				self.visibleCardSpList[1][provide+1][i][1] = 0
				self.visibleCardSpList[1][provide+1][i][2] = nil
			end
		end
		self:addDirectIcon("Peng",uis[dirction],chair,provide)
		
		if Bit:_and(nSpecialMark,0x0001) == 1 then  --煎人
			cclog("煎人:"..nSpecialMark)
			self.main_layer:addJianRenMark({provide})
		end
        return removeCard
    end

    self.operatorBack_funcs[GameDefs.OperateCmd.Gang] = function(chair, card, provide,nSpecialMark)
        local downcard = {card, card, card, card,provide}
        local removeCard = {card, card, card}

        self.main_layer:setCardDirct(1)
        self.main_layer:playOperatorAnima("gang", chair)
        local ctype = 2
		--杠上杠的暗杠provide 和 chair 不相等
		local bAnGang = provide == chair or (Bit:_and(nSpecialMark,0x0008) ~= 0)
        if bAnGang then
            --暗杠
            removeCard = {card, card, card, card}
            downcard = {0, 0, 0, card,provide}
            table.insert(self.cdDownCard[chair + 1], downcard)
            local uis = self.main_layer.player_panel[chair + 1]:onAnGangAnima(removeCard, removeCard)
            ctype = 1
			
			if provide ~= chair then --这是杠上杠
				self:addDirectIcon("AnGang",uis[2],chair,provide)
			end
        elseif provide >= self.cbPlayerNum then
            --碰杠
			local cardSp = nil
            for i,v in ipairs(self.cdDownPengCard[chair + 1]) do
                if i % 2 ~= 0 and v == card then
                    --删除碰
                    for i,v in ipairs(self.cdDownCard[chair + 1]) do
                        if v[1] == card then
                            table.remove(self.cdDownCard[chair + 1], i)
                            break
                        end
                    end
                    table.insert(self.cdDownCard[chair + 1], downcard)
                    
					if self.cdDownPengCard[chair + 1][i + 1].directArrowSp then self.cdDownPengCard[chair + 1][i + 1].directArrowSp:setVisible(false) end
                    --由碰转杠
                    cardSp = self.main_layer.player_panel[chair + 1]:onPengGangAnima({card}, self.cdDownPengCard[chair + 1][i + 1])
                end
				
            end 
			if Bit:_and(nSpecialMark,0x0004) ~= 0 then  --杠上杠
				downcard[5] = downcard[5]%self.cbPlayerNum
				self:addDirectIcon("PengGang",cardSp,chair,provide%self.cbPlayerNum)
			end	
			for i = 1,#self.visibleCardSpList[2] do --删除碰的牌
				if card == self.visibleCardSpList[2][i][1] then
					self.visibleCardSpList[2][i][1] = 0
					self.visibleCardSpList[2][i][2] = nil
				end
			end		
        else
            table.insert(self.cdDownCard[chair + 1], downcard)
			local dirct = self:getProvideDirct(chair, provide)
            local uis,dirction=  self.main_layer.player_panel[chair + 1]:onGangAnima(downcard, removeCard, dirct)
			
			self:addDirectIcon("Gang",uis[dirction],chair,provide)--添加放杠者标识
			
			for i = #self.visibleCardSpList[1][provide+1],1,-1 do -- 删除打出去的牌
				if card == self.visibleCardSpList[1][provide+1][i][1] then
					self.visibleCardSpList[1][provide+1][i][1] = 0
					self.visibleCardSpList[1][provide+1][i][2] = nil
				end
			end
        end
		if Bit:_and(nSpecialMark,0x0001) == 1 then  --煎牌
			cclog("煎人:"..nSpecialMark)
			self.main_layer:addJianRenMark({provide})
		end
        self.main_layer.playerLogo_panel:playOperatorVoice(chair, 0x10, ctype)

        return removeCard
    end

    self.operatorBack_funcs[GameDefs.OperateCmd.Ting] = function(chair)
        self.main_layer.playerLogo_panel:playOperatorVoice(chair, 0x20)
    end

    self.operatorBack_funcs[GameDefs.OperateCmd.Chi_Hu] = function(chair, card, provide,nSpecialMark)
		cclog("玩家胡牌"..nSpecialMark)
		local imgHu = "zimo" 
		if provide ~= chair then
			self.main_layer.playerLogo_panel:playOperatorVoice(chair, 0x40, 1)
			self:getLastPlayerPanle():removeCardAnima()
			imgHu = "hu"
			--点炮
			self.main_layer:playOperatorAnima("dianpao", provide)
		else
			local ctype = nil
			--if hucard == 0x35 then
			if self:isSpecialCard(cbCardData) then
				ctype = 3
				if require("Lobby/Set/SetLogic").getGameCheckByIndex(3) == 1 then
					--普通话缺少音效
					ctype = 2
				end
			end
			self.main_layer.playerLogo_panel:playOperatorVoice(chair, 0x42, ctype)
		end
		
		local HuType = require("sgmj/GameDefs").HuType
		local huImg = nil
		local bPengPengHu = Bit:_and(nSpecialMark, HuType.PENG_PENG) == HuType.PENG_PENG
		if bPengPengHu then huImg = "sgmj/huAnim_8.png" end
		nSpecialMark = Bit:_and(nSpecialMark, 0xFFFFFFF0)--屏蔽掉前四位
		for k,v in pairs(HuType) do
			if  Bit:_and(nSpecialMark, v) == v then
				if (v == HuType.QING_YI_SE  or v == HUN_YI_SE) and bPengPengHu then
					huImg = string.format("sgmj/huAnim_%x.png", v + HuType.PENG_PENG)
				else
					huImg = string.format("sgmj/huAnim_%x.png", v)
				end
			end
		end
		self.main_layer:playOperatorAnima(imgHu, chair, function()
			if huImg ~= nil then --播放胡牌特殊牌型动画				
				self.main_layer:playHuTypeAnima(chair,huImg,function() end)
			end
		end)
    end
end
function GameLogic:addDirectIcon(szType,cardSp,chair,provide)
	if cardSp == nil then return end
	local base_size = cardSp.card_bg:getContentSize() 
	--if szType == "Peng" or szType == "PengGang" or szType == "Gang" then
		--先确定操作人的位置是左右还是上下
		local nPos = self:getRelativeChair(chair)
		local dirct = self:getProvideDirct(chair, provide) -- 提供人相对于操作人的方位
		if dirct > 3 or dirct < 1 then return end
		local poes = {ccp(base_size.width/2 , base_size.height + 10),
					ccp(0, base_size.height/2),
					ccp(base_size.width/2 , -5),
					ccp(base_size.width, base_size.height/2)}
					
		if nPos == 2 or nPos == 4 then --左右的位置
			cardSp.directArrowSp = loadSprite(dirct == 2 and "sgmj/HDirect_Right.png" or "sgmj/VDirect_Right.png")
			cardSp.card_bg:addChild(cardSp.directArrowSp)
			cardSp.directArrowSp:setPosition(poes[nPos])
			
			if nPos == 4 then 
				cardSp.directArrowSp:setFlipX(true)
			end
			if (nPos == 2 and dirct == 3) or (nPos == 4 and dirct == 1) then
				cardSp.directArrowSp:setRotation(180)
			end
		else -- 上下位置
			local rotation = {{89,-10,-90},{},{-90,185,90}}
			cardSp.directArrowSp = loadSprite("sgmj/DirectArrow.png")
			cardSp.card_bg:addChild(cardSp.directArrowSp)
			cardSp.directArrowSp:setPosition(poes[nPos])
			cardSp.directArrowSp:setRotation(rotation[nPos][dirct])
		end
		
	--elseif szType == "AnGang" then
		
	--end
end
function GameLogic:onCardStateChange(cardState,carData)
	cclog("onCardStateChange"..cardState..":"..carData)
	for i = 1, #self.visibleCardSpList[1] do --打在桌子上的牌
		for j = 1,#self.visibleCardSpList[1][i] do
			if carData == self.visibleCardSpList[1][i][j][1] then
				local cardBk = self.visibleCardSpList[1][i][j][2].card_bg--:getChildByTag(10)
				if cardState == 1 then 
					if cardBk then -- ccc3(0x27,0xff,0xd4)
						cardBk:setColor(ccc3(0xff,0xfc,0x00))
						cardBk:setOpacity(153)
					end
				else
					if cardBk then
						cardBk:setColor(ccc3(0xff,0xff,0xff))
						cardBk:setOpacity(255)
					end
				end
			end
		end
	end
	cclog(#self.visibleCardSpList[2])
	for i = 1, #self.visibleCardSpList[2] do -- 吃碰的牌
		cclog("carData"..self.visibleCardSpList[2][i][1])
		if carData == self.visibleCardSpList[2][i][1] and self.visibleCardSpList[2][i][2] ~= nil then
			local cardBk = self.visibleCardSpList[2][i][2].card_bg
			if cardState == 1 then 
				if cardBk then
					cardBk:setColor(ccc3(0xff,0xfc,0x00))
					cardBk:setOpacity(153)
				end
			else
				if cardBk then
					cardBk:setColor(ccc3(0xff,0xff,0xff))
					cardBk:setOpacity(255)
				end
			end
		end
	end
end
function GameLogic:TestFun()
	local card = { 0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,
				 0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,
				 0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,
				 0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09
			}
	self.cardLayer1 = require("sgmj/Game/LayerMyCard").put(self.main_layer, self.main_layer.downcard_zIndex + 4)
	self.cardLayer2 = require("sgmj/Game/LayerSouthCard").put(self.main_layer, self.main_layer.downcard_zIndex)
	self.cardLayer3 = require("sgmj/Game/LayerNorthCard").put(self.main_layer, self.main_layer.downcard_zIndex)
	self.cardLayer4 = require("sgmj/Game/LayerWestCard").put(self.main_layer, self.main_layer.downcard_zIndex)
	local uis = self.cardLayer1:addCardWall(14)
	uis[1]:getParent():setVisible(false)
	uis = self.cardLayer2:addCardWall(14)
	uis[1]:getParent():setVisible(false)
	uis = self.cardLayer3:addCardWall(14)
	uis[1]:getParent():setVisible(false)
	uis = self.cardLayer4:addCardWall(14)
	uis[1]:getParent():setVisible(false)
	
	local poses = {}
	for i = 1,18 do
		self.cardLayer1:addStaticPassed(card[i])
		--item:setSkewX(-10)
		self.cardLayer2:addStaticPassed(card[i])
		self.cardLayer3:addStaticPassed(card[i])
		local item ,pos = self.cardLayer4:addStaticPassed(card[i])
	--	table.insert(poses,{pos.x,pos.y})
	end
	--tablePrint(poses)
	--[[local birds = {0x12,0x22,0x32,0x12,0x12,0x12}
	local valids = {0x12,0x12,0x12,0x12,0x12,0x12}
	
	local sp = require("sgmj/Game/VerticalShare").create()
	sp:setRotation(-90)
	self.main_layer:addChild(sp,10)
	sp:setPosition(ccp(1280/2,360))
	local info = {}
	info[1] = {UserID = 10687,Sex = 1,UserNickName = "ZHANGSAN",UserIP = "127.0.0.1",Score = 1000}
	info[2] = {UserID = 10012,Sex = 2,UserNickName = "ZHANGSAN",UserIP = "127.0.0.1",Score = -653}
	info[3] = {UserID = 10012,Sex = 2,UserNickName = "ZHANGSAN",UserIP = "127.0.0.1",Score = -235}
	info[4] = {UserID = 10012,Sex = 1,UserNickName = "ZHANGSAN",UserIP = "127.0.0.1",Score = 999}
	for index = 1,#info do
	 sp:createInfoItem(info[index],index)
	 sp:addMarks(index,index%2+1)
	end
	sp:addGameRuleText()
	--self.main_layer:addJianRenMark({0})
	--self.main_layer:playHuTypeAnima("sgmj/huAnim_100.png",0,function() end)]]
--[[	local SpriteWestCard = require("sgmj/Game/SpriteWestCard")
	local pos = ccp(220,230)
	for i = 1,14 do
		local sprite,spaces, zIndex = SpriteWestCard.createVerticalBack(i)
		self.main_layer:addChild(sprite,zIndex)
		sprite:setPosition(pos)
		pos.x = pos.x + spaces.x
        pos.y = pos.y + spaces.y 
	end]]

end
-- 判定玩家震动
function GameLogic:shake(t, special)
    if self.bSender or special then
        require("Lobby/Set/SetLogic").playGameShake(t)
    end
end

return GameLogic
