
require("AudioEngine")
require("CocosExtern")
require("bull/bit")
require("FFSelftools/controltools")

local Resources = require("bull/Resources")
local SoundRes = require("bull/SoundRes")
local GameCfg =require("bull/desk/public/GameCfg")
local Player =require("bull/desk/Player")
local CS_Message =require("bull/desk/public/CS_Message")
local Timer =require("bull/desk/Timer")

local HtmlChat =require("GameLib/common/HtmlChat")
local BaseDialog = require("bull/public/BaseDialog")

local GameSpeaker =require("bull/desk/GameSpeaker")
local PropertyAnimationLayer = require("bull/desk/PropertyAnimationLayer")

local GameButtonLayer = require("bull/desk/GameButtonLayer")

local GameDefs = require("bull/GameDefs")
local GlobalMsg = require("bull/public/GlobalMsg")

local SendCMD = require("bull/SendCMD")

local AppConfig = require("AppConfig")

local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
local DeskScene=class("DeskScene",function()
               return CCLayer:create()
            end)
DeskScene.POPMESSAGETAG=100

DeskScene.DIRECTION_TAG=150

DeskScene.GAMETIMER_COUNT=15

DeskScene.ROBOT_MAX_NUM = 3

function DeskScene:InitPlayers()
    for i =1, GameDefs.PLAYER_COUNT do
        self.m_aclsPlayer[i] = Player.createPlayer(i,self)
        self.m_aclsPlayer[i]:setAnchorPoint(ccp(0,0))
        self.m_aclsPlayer[i]:setPosition(ccp(0,0))
        self.m_aclsPlayer[i]:setVisible(true)
        if i==1 then
            self:addChild(self.m_aclsPlayer[i],1)
        else
            self:addChild(self.m_aclsPlayer[i],1)
        end
    end
end

function DeskScene:init()
	
	self:loadingCache() --加载资源
	
    self.m_backgroundSp=nil -- 背景
    self.m_aclsPlayer={}	--全部玩家
    self.m_cbMyChair=-1		--我的椅子号
    self.m_pMyself=nil		--我自己
    self.m_stSceneData = {}	--场景数据
    self.m_stSaveSceneData = {}	--上一个场景数据
    self.m_vBidPlayers={}	--抢庄玩家
    self.m_dealNetPause=false
    self.m_pTimer =nil
    self.m_bIsRobot =false
    self.m_bKickOut = false
    self.m_isGameStart = false
    self.m_isGameStarting = false
    self.m_isDissolve = false		-- 是否解散
    self.m_nCurrentOverTimeTimes = 0 --当前超时次数
    self.m_nMaxOverTimeTimes = 2 --最大超时次数
	
	self.winCount = 0 --赢的次数
	self.loseCount = 0 --输的次数
    local function onNodeEvent(event)
        if event == "enter" then	
            self:onEnter()
        elseif event =="exit" then
            self:onExit() 
        end 
    end

    local function onTouch(eventType ,x ,y)
        if eventType=="began" then
            return self:onTouchBegan(x,y)
        elseif eventType=="moved" then
           self:onMoved(x,y)
        elseif eventType=="ended" then
          self:onEnded(x,y)
        end
    end
   
    local function KeypadHandler(strEvent)
        self:keyPadClick(strEvent)
    end

    self:registerScriptHandler(onNodeEvent)
    self:setTouchEnabled(true)
    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,false)
    self:setKeypadEnabled(true)
    self:registerScriptKeypadHandler(KeypadHandler)

    self:initUI()
end

function DeskScene:initUI()
    cclog("DeskScene:initUI()= ===============================================")
    
    local winSize = CCDirector:sharedDirector():getWinSize()

    self.m_roomNeedminGold=0

    local strBgImg="bull/images/bg.png"
    self.m_backgroundSp = loadSprite(strBgImg)
	self.m_backgroundSp:setScale(1.25)
    self.m_backgroundSp:setAnchorPoint(ccp(0,0))
    self.m_backgroundSp:setPosition(0,0)
 --   self.m_backgroundSp:setAnchorPoint(ccp(0.5,0.5))
  --  self.m_backgroundSp:setPosition(ccp(self.m_backgroundSp:getContentSize().width/2,self.m_backgroundSp:getContentSize().height/2))
    self:addChild(self.m_backgroundSp)
    
--	if true then  return end
    self:InitPlayers()
	
--m_gameSpeaker这个还不能删掉，删掉会报错，待查	
    self.m_gameSpeaker =GameSpeaker.createGameSpeaker()
    self:addChild(self.m_gameSpeaker,4)

	--按钮层
    self.m_gameButtonLayer=GameButtonLayer.createGameButtonLayer(self)
    self:addChild(self.m_gameButtonLayer,3)

    local function _onBullYesClick()
        self:onBullYesClick()
    end
    self.m_gameButtonLayer:setBullYesCallBack(_onBullYesClick)
    local function _onBullNoClick()
        self:onBullNoClick()
    end
    self.m_gameButtonLayer:setBullNoCallBack(_onBullNoClick)

    local function _onBidYesClick() --抢庄回调
        self:onBidYesClick()
    end
    self.m_gameButtonLayer:setBidYesCallBack(_onBidYesClick)
    local function _onBidNoClick() --不抢
        self:onBidNoClick()
    end
    self.m_gameButtonLayer:setBidNoCallBack(_onBidNoClick)
    local function _on1BeiClick()
        self:on1BeiClick()
    end
    self.m_gameButtonLayer:set1BeiCallBack(_on1BeiClick)
    local function _on2BeiClick()
        self:on2BeiClick()
    end
    self.m_gameButtonLayer:set2BeiCallBack(_on2BeiClick)
	
	local function _on3BeiClick()
        self:on3BeiClick()
    end
	self.m_gameButtonLayer:set3BeiCallBack(_on3BeiClick)
	
    local function _on5BeiClick()
        self:on5BeiClick()
    end
    self.m_gameButtonLayer:set5BeiCallBack(_on5BeiClick)
    local function _on10BeiClick()
        self:on10BeiClick()
    end
    self.m_gameButtonLayer:set10BeiCallBack(_on10BeiClick)

    local function editBoxTextEventHandle(strEventName,pSender)
        local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
        local gameLib = DeskScene.getGameLib()
        local edit = tolua.cast(pSender,"CCEditBox")
        local strFmt 
        if strEventName == "began" then
            local nleftLaba = gameLib:getFreeSpeakerLeft()
            if (nleftLaba ~= 0) then
                edit:setPlaceHolder(string.format(Resources.DESC_FREESPEAKER_NUM , nleftLaba))
            else
                edit:setPlaceHolder(StringRes.DESC_SPEAKER_SENDTIPS)
            end
        elseif strEventName == "ended" then
            edit:setPlaceHolder("")
        elseif strEventName == "return" then
            local szContent = edit:getText()
            if (string.len(szContent) > 0) then
                --//发送大喇叭
                if (gameLib:sendSpeaker(szContent) == false) then
                    cclog("111111")
                end
            end
            edit:setText("")
            edit:setPlaceHolder("")
        elseif strEventName == "changed" then
        end
    end
   
    local size = CCSizeMake(0,0)
   
    self.m_pEbSpeaker = CCEditBox:create(size, CCScale9Sprite:create())
    self.m_pEbSpeaker:setReturnType(kKeyboardReturnTypeSend)
    self.m_pEbSpeaker:registerScriptEditBoxHandler(editBoxTextEventHandle)
    self.m_pEbSpeaker:setPosition(ccp(-100, -100))
    self.m_pEbSpeaker:setMaxLength(40)
    self.m_pEbSpeaker:setAnchorPoint(ccp(0.5, 0.5))
    self.m_pEbSpeaker:setEnabled(false)
    self:addChild(self.m_pEbSpeaker)

	--显示房间信息的背景
--[[	self.roomInfoBk = loadSprite("bull/roomInfo.png") 
	self.roomInfoBk:setAnchorPoint(ccp(0,1))
	self.roomInfoBk:setPosition(ccp(95,winSize.height - 15))
	self:addChild(self.roomInfoBk)]]
 	
    -- 实时信息
    self.realtimeInfoPanel = require("bull/common/LayerRealtimeInfo").create()
    self.realtimeInfoPanel:setPosition(winSize.width / 2 - 45, winSize.height - 19)
    self:addChild(self.realtimeInfoPanel)
	
    --倒计时
    self.m_pTimer = Timer.createTimer()
    self.m_pTimer:setAnchorPoint(ccp(0,0))
    self.m_pTimer:setPosition(ccp(winSize.width*0.5-80,winSize.height*0.5-20))
    self.m_pTimer:Stop()
    self:addChild(self.m_pTimer,4)

    self.m_roomRuleLabel=CCLabelTTF:create("", Resources.FONT_BLACK, Resources.FONT_SIZE26, CCSizeMake(500, 60), kCCTextAlignmentCenter)
    self.m_roomRuleLabel:setDimensions(CCSizeMake(500, 0))
    self.m_roomRuleLabel:setAnchorPoint(ccp(0.5,0))
    self.m_roomRuleLabel:setPosition(ccp(winSize.width*0.5,winSize.height*0.5-110))
    self.m_roomRuleLabel:setColor(ccc3(255,255,255))
    self.m_roomRuleLabel:setVisible(false)
    self:addChild(self.m_roomRuleLabel,2)

	--等待下注
    self.m_spWaitStake = loadSprite("bull/waitstake.png")
    self.m_spWaitStake:setAnchorPoint(ccp(0.5,0))
    self.m_spWaitStake:setPosition(ccp(winSize.width*0.5,winSize.height*0.3+20))
    self.m_spWaitStake:setVisible(false)
    self:addChild(self.m_spWaitStake,5)
	--下注完成
    self.m_spStakeOver = loadSprite("bull/stakeover.png")
    self.m_spStakeOver:setAnchorPoint(ccp(0.5,0))
    self.m_spStakeOver:setPosition(ccp(winSize.width*0.5,winSize.height*0.3))
    self.m_spStakeOver:setVisible(false)
    self:addChild(self.m_spStakeOver,5)
	
	--下注背景
    self.m_spStakeBg = loadSprite("bull/stakebg.png")
    self.m_spStakeBg:setAnchorPoint(ccp(0.5,0))
    self.m_spStakeBg:setPosition(ccp(winSize.width*0.5,winSize.height*0.3-20))
    self.m_spStakeBg:setVisible(false)
    self:addChild(self.m_spStakeBg,2)

	--有牛提示
    self.m_spHaveNiu = loadSprite("bull/haveniu.png")
    self.m_spHaveNiu:setAnchorPoint(ccp(0.5,0))
    self.m_spHaveNiu:setPosition(ccp(winSize.width*0.5,winSize.height*0.5))
    self.m_spHaveNiu:setVisible(false)
    self:addChild(self.m_spHaveNiu,10)

	--组牌显示框
    self.m_spSort = loadSprite("bull/sort.png")
    self.m_spSort:setAnchorPoint(ccp(0.5,0.5))
    self.m_spSort:setPosition(ccp(winSize.width*0.5,winSize.height*0.4))
   -- self.m_spSort:setContentSize(CCSize(544, 110))
    self.m_spSort:setVisible(false)
    self:addChild(self.m_spSort,5)
    self.m_vSelectCardShow = {}--组牌数字
    for i=1,4 do
        self.m_vSelectCardShow[i] = CCLabelBMFont:create("","bull/images/number/sortnum.fnt")
        self.m_vSelectCardShow[i]:setAnchorPoint(ccp(0.5, 0.5))
        self.m_vSelectCardShow[i]:setScale(0.9)
        self.m_vSelectCardShow[i]:setPosition(ccp((i-1) * 92 + 90,self.m_spSort:getContentSize().height/2 + 12))
        self.m_spSort:addChild(self.m_vSelectCardShow[i])
    end	
	require("bull/GameLibSink").sDeskLayer = self
	require("LobbyControl").gameLogic = self
    require("LobbyControl").removeHallCache()
end
function DeskScene:getIsSeeCardBeforeStake()--在下注之前能不能看到牌
	return (self.m_nGameType == 1 and self.bNotBanker == false)
end
function DeskScene:getIsSystemSetBanker()--系统确定庄家
--这类型的玩法有牛牛坐庄、轮流坐庄、牌大坐庄，房主霸王庄
	return (self.m_nGameType == 3) or (self.m_nGameType == 4) or (self.m_nGameType == 5) or (self.m_nGameType == 7)
end
function DeskScene:onBullYesClick()
    if self:getGameSection() ~= GameDefs.emGameSection.GAME_SECTION_CARD_SORT then
        return
    end
    SoundRes.playGlobalEffect(SoundRes.SOUND_PASS)

	--检查特殊牌型
	if self:checkSpecialNiuType() then
		return
    end
    local stMsg = CS_Message.ST_MSG_SHOW:new()
    stMsg.cbChair = self.m_cbMyChair
    stMsg.stCards = GameDefs.stCardGroup:new()
    local vSelectCards = self.m_aclsPlayer[1]:getPlayerCardLayer():getSelectCards()
    for i=1,#vSelectCards do
		cclog("vSelectCards_%d ： %d",i,vSelectCards[i].m_byCardPoint)
        table.insert(stMsg.stCards.m_arrCard, vSelectCards[i])
    end
    local vUnSelectCards = self.m_aclsPlayer[1]:getPlayerCardLayer():getUnSelectCards()
    for i=1,#vUnSelectCards do
		cclog("vUnSelectCards%d ： %d",i,vUnSelectCards[i].m_byCardPoint)
        table.insert(stMsg.stCards.m_arrCard, vUnSelectCards[i])
    end
    stMsg.stCards.m_nCurCardCount = #stMsg.stCards.m_arrCard
    stMsg.stCards.m_bIsSort = 1

    local calcValue = 0
    for i=4,5 do
        local nValue = stMsg.stCards.m_arrCard[i].m_byCardPoint
        if nValue >= 10 then
            nValue = 0
        end
        calcValue = calcValue + nValue
    end
    calcValue = calcValue % 10
    if calcValue == 0 then
        calcValue = GameDefs.emBullType.BULL_TYPE_10
    else
        calcValue = GameDefs.emBullType.BULL_TYPE_NULL + calcValue
    end
	cclog("calcValue == %d",calcValue)
    stMsg.stCards.m_stMaxRullData = GameDefs.stBullData:new()
    stMsg.stCards.m_stMaxRullData.m_byBullType = calcValue

    local ba = stMsg:Serialize()
    require("bull/GameLibSink").game_lib:sendOldGameCmd(GameDefs.emClientToServerGameMsg.CS_GAMEMSG_SHOW,ba:getBuf(),ba:getLen())
end

function DeskScene:onBullNoClick()
    if self:getGameSection() ~= GameDefs.emGameSection.GAME_SECTION_CARD_SORT then
        return
    end
    SoundRes.playGlobalEffect(SoundRes.SOUND_PASS)
	--检查特殊牌型
	if self:checkSpecialNiuType() then
		return
    end
	if self:checkHaveNiu() then
        self.m_spHaveNiu:setVisible(true)
        return
    end
    local stMsg = CS_Message.ST_MSG_SHOW:new()
    stMsg.cbChair = self.m_cbMyChair
    stMsg.stCards = GameDefs.stCardGroup:new()
    local vCards = self.m_aclsPlayer[1]:getPlayerCardLayer():getGroupCards()
    for i=1,#vCards do
        table.insert(stMsg.stCards.m_arrCard, vCards[i])
    end
    stMsg.stCards.m_nCurCardCount = #stMsg.stCards.m_arrCard
    stMsg.stCards.m_bIsSort = 0
    stMsg.stCards.m_stMaxRullData = GameDefs.stBullData:new()
    stMsg.stCards.m_stMaxRullData.m_byBullType = GameDefs.emBullType.BULL_TYPE_NULL

    local ba = stMsg:Serialize()
    require("bull/GameLibSink").game_lib:sendOldGameCmd(GameDefs.emClientToServerGameMsg.CS_GAMEMSG_SHOW,ba:getBuf(),ba:getLen())
end
function DeskScene:checkSpecialNiuType()--检查是不是特殊牌型
	local vCards = self.m_aclsPlayer[1]:getPlayerCardLayer():getGroupCards()
 
	local nUnequalCnt = 0; --判断不相等的次数，用来判断是否是4炸
	local Isbomb = true;--四炸
	local IsfiveJQK = true;--5花牛
	local IsminFive = true;--五小牛
	local nTotal = 0; --5张牌的总大小  用来判断是否是5小牛
	
	for i =1,5 do
		if vCards[i].m_byCardPoint >= 5 then
			IsminFive = false;
		end
		if vCards[i].m_byCardPoint <= 10 then
			IsfiveJQK = false;
		end
		if vCards[i].m_byCardPoint ~= vCards[1].m_byCardPoint then
			nUnequalCnt = nUnequalCnt + 1
		end
		if vCards[i].m_byCardPoint > 10 then
			nTotal = nTotal + 10
		else
			nTotal = nTotal + vCards[i].m_byCardPoint
		end
	end
	if nUnequalCnt == 1 or (nUnequalCnt == 4 and  vCards[2].m_byCardPoint == vCards[3].m_byCardPoint
		and vCards[3].m_byCardPoint == vCards[4].m_byCardPoint and vCards[4].m_byCardPoint == vCards[5].m_byCardPoint) then
		Isbomb = true
	else
		Isbomb = false
	end
	if nTotal >= 10 then IsminFive = false end
	if Isbomb or IsfiveJQK  or IsminFive then
		local stMsg = CS_Message.ST_MSG_SHOW:new()
		stMsg.cbChair = self.m_cbMyChair
		stMsg.stCards = GameDefs.stCardGroup:new()		
		local vSelectCards = self.m_aclsPlayer[1]:getPlayerCardLayer():getGroupCards()
		for i=1,#vSelectCards do
			table.insert(stMsg.stCards.m_arrCard, vSelectCards[i])
		end
		stMsg.stCards.m_nCurCardCount = #stMsg.stCards.m_arrCard
		stMsg.stCards.m_bIsSort = 1
		
		local calcValue = 0
		if IsminFive then
			calcValue = GameDefs.emBullType.BULL_TYPE_5_MIN
		elseif IsfiveJQK then
			calcValue = GameDefs.emBullType.BULL_TYPE_5_JQK
		else
			calcValue = GameDefs.emBullType.BULL_TYPE_BOMB
		end
		stMsg.stCards.m_stMaxRullData = GameDefs.stBullData:new()
		stMsg.stCards.m_stMaxRullData.m_byBullType = calcValue

		local ba = stMsg:Serialize()
		require("bull/GameLibSink").game_lib:sendOldGameCmd(GameDefs.emClientToServerGameMsg.CS_GAMEMSG_SHOW,ba:getBuf(),ba:getLen())
        return
    end
	cclog(Isbomb and "Isbomb == true" or "Isbomb == false")
	cclog(IsfiveJQK and "IsfiveJQK == true" or "IsfiveJQK == false")
	cclog(IsminFive and "IsminFive == true" or "IsminFive == false")
	return Isbomb == true or IsfiveJQK == true or IsminFive == true
end
function DeskScene:checkHaveNiu()
    local vCards = self.m_aclsPlayer[1]:getPlayerCardLayer():getGroupCards()
    local nCount = #vCards
	
    for i=1,nCount do
        local cardOne = vCards[i]
        for j=1,nCount do
            if j ~= i then
                local cardTwo = vCards[j]
                for k=1,nCount do
                    if k ~= j and k ~= i then
                        local cardThree = vCards[k]

                        local nTotalValue = 0
                        local vSelectCards = {}
                        table.insert(vSelectCards, cardOne)
                        table.insert(vSelectCards, cardTwo)
                        table.insert(vSelectCards, cardThree)
                        for x=1,#vSelectCards do
                            local nValue = vSelectCards[x].m_byCardPoint
                            if nValue > 10 then
                                nValue = 10
                            end
                            nTotalValue = nTotalValue + nValue
                        end
                        if nTotalValue > 0 and nTotalValue % 10 == 0 then
                            --Resources.ShowToast(string.format("have: %d, %d, %d", vSelectCards[1].m_byCardPoint, vSelectCards[2].m_byCardPoint, vSelectCards[3].m_byCardPoint))
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

function DeskScene:onBidYesClick()
    SoundRes.playGlobalEffect(SoundRes.SOUND_PASS)
    local stBankerBid = CS_Message.ST_MSG_BANKER_BID:new()
    stBankerBid.cbChair = self.m_cbMyChair
    stBankerBid.cbWant = GameDefs.EN_BANKER_BID.EN_BANKER_BID_WANT
    local ba = stBankerBid:Serialize()
    require("bull/GameLibSink").game_lib:sendOldGameCmd(GameDefs.emClientToServerGameMsg.CS_GAMEMSG_BID,ba:getBuf(),ba:getLen())
end

function DeskScene:onBidNoClick()
    SoundRes.playGlobalEffect(SoundRes.SOUND_PASS)
    local stBankerBid = CS_Message.ST_MSG_BANKER_BID:new()
    stBankerBid.cbChair = self.m_cbMyChair
    stBankerBid.cbWant = GameDefs.EN_BANKER_BID.EN_BANKER_BID_WONT
    local ba = stBankerBid:Serialize()
    require("bull/GameLibSink").game_lib:sendOldGameCmd(GameDefs.emClientToServerGameMsg.CS_GAMEMSG_BID,ba:getBuf(),ba:getLen())
end
function DeskScene:playerBet(lStake)--用户下注
	cclog("用户下注："..lStake)
	local stStake = CS_Message.ST_MSG_STAKE:new()
    stStake.cbChair = self.m_cbMyChair
    stStake.lStake = lStake
    local ba = stStake:Serialize()
    require("bull/GameLibSink").game_lib:sendOldGameCmd(GameDefs.emClientToServerGameMsg.CS_GAMEMSG_STAKE,ba:getBuf(),ba:getLen())
end
function DeskScene:on1BeiClick()
    SoundRes.playGlobalEffect(SoundRes.SOUND_PASS)
	self:playerBet(1)
end

function DeskScene:on2BeiClick()
    SoundRes.playGlobalEffect(SoundRes.SOUND_PASS)
    self:playerBet(2)
end
function DeskScene:on3BeiClick()
    SoundRes.playGlobalEffect(SoundRes.SOUND_PASS)
    self:playerBet(3)
end
function DeskScene:on5BeiClick()
    SoundRes.playGlobalEffect(SoundRes.SOUND_PASS)
    self:playerBet(5)
end

function DeskScene:on10BeiClick()
    SoundRes.playGlobalEffect(SoundRes.SOUND_PASS)
	self:playerBet(10)
end

function DeskScene:onEnter()
    SoundRes.playMusic(SoundRes.MUSIC_DESK)
    self:GetMyInfo()  
	math.randomseed(os.time())
end

function DeskScene:onExit()
    self:unscheduleUpdate()
    CCNotificationCenter:sharedNotificationCenter():removeAllObservers(self)

    if self.m_systemTimeTimer then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_systemTimeTimer)
        self.m_systemTimeTimer = nil
    end

    if self.m_signalTimerId then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_signalTimerId)
        self.m_signalTimerId = nil
    end
	self:clearFriendValidTimerUI()
	require("bull/GameLibSink").sDeskLayer = nil
    AudioEngine.stopMusic(true)
end

function DeskScene:onGameStart()
    for i = 1, GameDefs.PLAYER_COUNT do
        self.m_aclsPlayer[i]:GameStart()
    end
end

function DeskScene:onGameEnd(data,  nLen)
    cclog("====DeskScene:onGameEnd====nLen ="..nLen)
end

function DeskScene:onLeaveGameView()
    for nPos=1,GameDefs.PLAYER_COUNT do
        self.m_aclsPlayer[nPos]:getPlayerCardLayer():gameOver()
    end
    self.m_pTimer:Stop()
	self:delayExitGame()
end

function DeskScene:onUserEnterTable(nChair,wUserID,bIsPlayer)
	cclog("onUserEnterTable111,%d,%d",nChair,wUserID)
	
    if (bIsPlayer==false) then
        cclog("bIsPlayer==false return ")
        return
    end
    if not self:GetMyInfo() then
		cclog("myself is invalid ")
	   return
	end

    local userInfo =  DeskScene.getGameLib():getUser(wUserID)
    if (userInfo==false) then
        return
    end

    SoundRes.playGlobalEffect(SoundRes.SOUND_ENTERTABLE)

    cclog(" >>>>> OnUserEnter nChair =%d,self.m_cbMyChair=%d,userName==%s,wUserID=%d",nChair,self.m_cbMyChair,userInfo:getUserName(),wUserID)
    
    if (nChair == self.m_cbMyChair) then
        if self:getGameSection() == GameDefs.emGameSection.GAME_SECTION_INVALID then
            
        end
        cclog("self:MyState()=="..self:MyState())
        if self:MyState() == gamelibcommon.USER_SIT_TABLE then

        elseif self:MyState() == gamelibcommon.USER_PLAY_GAME or self:MyState() == gamelibcommon.USER_OFF_LINE then
            if self.m_gameButtonLayer then
               -- self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_WEIXININVITE,false)
            end
            self.m_bIsOffLine = true
        end
    end

    local nPos = self:PosFromChair(nChair)
    if (self.m_aclsPlayer[nPos]:IsValid() and self.m_aclsPlayer[nPos].m_nUserID == wUserID) then
        return
    end

    if userInfo:getUserStatus() == gamelibcommon.USER_READY_STATUS then
        self.m_aclsPlayer[nPos]:setIsReady(true)

        for i=1,GameDefs.PLAYER_COUNT do
            if self.m_aclsPlayer[i] then
                self.m_aclsPlayer[i]:resetShow()
            end
        end
    else
        self.m_aclsPlayer[nPos]:setIsReady(false)
    end
	cclog("onUserEnterTable")
    self.m_aclsPlayer[nPos]:Come(wUserID)

end

function DeskScene:onUserExitTable(nChair, wUserID, bIsPlayer)

    if (bIsPlayer==false) then
        return
    end

    local nPos = self:PosFromChair(nChair)
        
    SoundRes.playGlobalEffect(SoundRes.SOUND_EXITTABLE)

    cclog(">>>>>>>>>>>>-------->onUserExitTable nChair="..nChair.."    nPos="..nPos.."  self.m_cbMyChair="..self.m_cbMyChair)
    
    self.m_aclsPlayer[nPos]:Leave()

    if (nChair == self.m_cbMyChair) then
        for  i = 1,GameDefs.PLAYER_COUNT, 1 do
            self.m_aclsPlayer[i]:Leave()
        end    
    end
	if(self.gameOverDlg ~= nil) then--用户离开把分数给隐藏掉
		self.gameOverDlg:hideScore(nPos)
	end
end

--绝对椅子号到相对椅子号
function  DeskScene:PosFromChair(cbChair)
	if cbChair < 0 or cbChair >= 5 then
		return 255
	end
	if(self.m_cbMyChair < 0 or self.m_cbMyChair > 5) then
		if not self:GetMyInfo() then
			return 255
		end
	end
	return ((cbChair + 5 - self.m_cbMyChair) % 5) + 1
end
--相对椅子号到绝对椅子号
function DeskScene:ChairFromPos(nPos)
  -- local gamelib = DeskScene.getGameLib()
   -- return gamelib:getRealChair(nPos)
   	if cbChair < 0 or cbChair >= 5 then
		return -1
	end
	return (nPos + self.m_cbMyChair) % 5
end

function DeskScene:MyGold()    
  return self.m_pMyself:getGold()
end

function  DeskScene:MyState()   
    if (self.m_pMyself == nil) then
      return gamelibcommon.USER_NO_STATUS
    end  
    return self.m_pMyself:getUserStatus()
end

function  DeskScene:isWatch()   
    if (self.m_pMyself == nil) then
      return true
    end  
    return (self:MyState() == gamelibcommon.USER_WATCH_GAME)
end

function DeskScene:GetMyInfo()
    self.m_pMyself = require("bull/GameLibSink"):getMyInfo()
    if (self.m_pMyself~= nil) then
        self.m_cbMyChair = self.m_pMyself:getUserChair()
    else
        self.m_cbMyChair = -1
    end
	return self.m_pMyself and self:isValidChair(self.m_cbMyChair)
end



function DeskScene:getGameSection()
    if self.m_stSceneData then
        return self.m_stSceneData.m_cbGameSection
    end
    return GameDefs.emGameSection.GAME_SECTION_INVALID
end

function DeskScene:isSectionChanged()
    if self.m_stSaveSceneData and self.m_stSceneData then
        if self.m_stSceneData.m_cbGameSection ~= self.m_stSaveSceneData.m_cbGameSection then
            return true
        end
    end
    return false
end

function DeskScene:onSceneChanged(lpData, nSize)
    cclog("======onSceneChanged nSize=%d",nSize)
	if self.m_gameButtonLayer.inviteBtn ~= nil then
		self.m_gameButtonLayer.inviteBtn:setVisible(false)
	end
	
    self.m_stSaveSceneData = self.m_stSceneData

    local ba = require("ByteArray").new()
    ba:writeBuf(lpData)
    ba:setPos(1)
    self.m_stSceneData = GameDefs.GameScene(ba)
	self.m_gameButtonLayer:setAllGameButtonIsVis(false)
	
	--这里是一局结束后玩家再回来回放数据
	if( self.m_stSceneData.m_cbCommand == GameDefs.emCmdType.CMD_TYPE_REVERT and self.m_stSceneData.m_cbActionChair == GameDefs.PLAYER_COUNT) then
		self.m_stSceneData.m_cbCommand = GameDefs.emCmdType.CMD_TYPE_INVALID		
	end
    cclog("======onSceneChanged m_GamePhase="..self:getGameSection().." m_cbActionChair=="..self.m_stSceneData.m_cbActionChair)
    cclog("======onSceneChanged self.m_cbMyChair="..self.m_cbMyChair.." m_cbBanker=="..self.m_stSceneData.m_cbBanker.." m_lParam="..self.m_stSceneData.m_lParam)

    local bIsReturn = false
    
    for cbChair=0,GameDefs.PLAYER_COUNT-1 do
        local nPos = self:PosFromChair(cbChair)
        if self.bNotBanker == false  and (self.m_nGameType == 1 or  self.m_nGameType == 6)then -- 看牌抢庄
            if self:getGameSection() ~= GameDefs.emGameSection.GAME_SECTION_BANKER_BID then
                if self.m_isSetMaster == true then
                    self.m_vBidPlayers = {}
                    if cbChair == self.m_stSceneData.m_cbBanker then
                        self.m_aclsPlayer[nPos]:setMaster(true)
                    else
                        self.m_aclsPlayer[nPos]:setMaster(false)
                    end
                else
                    bIsReturn = true
                    if #self.m_vBidPlayers <= 0 then
                        --[[
                        self.m_isSetMaster = true
                        if cbChair == self.m_stSceneData.m_cbBanker then
                            SoundRes.playGlobalEffect(SoundRes.SOUND_MASTER)
                            self.m_aclsPlayer[nPos]:setMaster(true)
                        else
                            self.m_aclsPlayer[nPos]:setMaster(false)
                        end
                        ]]
                        for i=1,self.realPlayerCnt do
							table.insert(self.m_vBidPlayers, i)
                        end
						
                    end
                    if self.m_isBidShowing ~= true then
                        self.m_isBidShowing = true
                        local nShowIndex = 1
                        local function delayShowCallBack()
							if nShowIndex > #self.m_vBidPlayers then nShowIndex = 1 end
							for j=1,#self.m_vBidPlayers do								
								self.m_aclsPlayer[self.m_vBidPlayers[j]]:setCircleShow(
								nShowIndex == j)								
							end
							SoundRes.playGlobalEffect(SoundRes.SOUND_DIDI)
							nShowIndex  = nShowIndex + 1
                        end
						local function setBankerCallBack()
							    self.m_isSetMaster = true
                                self.m_isBidShowing = false
                                for x=0,GameDefs.PLAYER_COUNT-1 do
                                    local nTmpPos = self:PosFromChair(x)
                                    if x == self.m_stSceneData.m_cbBanker then
                                        SoundRes.playGlobalEffect(SoundRes.SOUND_MASTER)
                                        self.m_aclsPlayer[nTmpPos]:setMaster(true)

                                        self:onSceneChanged(lpData, nSize)
                                    else
                                        self.m_aclsPlayer[nTmpPos]:setMaster(false)
                                    end
                                end
						end

						if #self.m_vBidPlayers > 1 then
							local arrayAction = CCArray:create()
							for j=1,2*(#self.m_vBidPlayers) do
								arrayAction:addObject(CCDelayTime:create(0.15))
								arrayAction:addObject(CCCallFunc:create(delayShowCallBack))
							end
							arrayAction:addObject(CCDelayTime:create(0.15))
							arrayAction:addObject(CCCallFunc:create(setBankerCallBack))
                            self:runAction(CCSequence:create(arrayAction))
						else
							setBankerCallBack()
						end
						
                        local nHideIndex = 1
                        local function delayHideCallBack()
                            self.m_aclsPlayer[self.m_vBidPlayers[nHideIndex]]:setCircleShow(false)
                            nHideIndex = nHideIndex + 1
                            if nHideIndex > #self.m_vBidPlayers then
                                self.m_isSetMaster = true
                                self.m_isBidShowing = false
                                for x=0,GameDefs.PLAYER_COUNT-1 do
                                    local nTmpPos = self:PosFromChair(x)
                                    if x == self.m_stSceneData.m_cbBanker then
                                        SoundRes.playGlobalEffect(SoundRes.SOUND_MASTER)
                                        self.m_aclsPlayer[nTmpPos]:setMaster(true)

                                        self:onSceneChanged(lpData, nSize)
                                    else
                                        self.m_aclsPlayer[nTmpPos]:setMaster(false)
                                    end
                                end
                            end
                        end
                        for j=1,#self.m_vBidPlayers do
                            local arrayAction = CCArray:create()
                            arrayAction:addObject(CCDelayTime:create(j*0.3))
                            arrayAction:addObject(CCCallFunc:create(delayHideCallBack))
                        --    self:runAction(CCSequence:create(arrayAction))
                        end
                    end
                end
            else
                self.m_isSetMaster = false
            end
        end
        --准备
        self.m_aclsPlayer[nPos]:setIsReady(false)
        --托管信息
        self.m_aclsPlayer[nPos]:setIsRobot(false)
        if cbChair == self.m_cbMyChair then
            self.m_bIsRobot = false
            self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_ROBOTCACEL,false)
        end
    end

    if self:getGameSection() ~= GameDefs.emGameSection.GAME_SECTION_BANKER_BID and 
	self:getGameSection() ~= GameDefs.emGameSection.GAME_SECTION_CARD_SORT  and 
	self:getGameSection() ~= GameDefs.emGameSection.GAME_SECTION_FIRST_STAKE then
        for i=1,GameDefs.PLAYER_COUNT do
            local cbChair = i - 1;
            local nPos = self:PosFromChair(cbChair)
            self.m_aclsPlayer[nPos]:getPlayerCardLayer():setGroupCards(self.m_stSceneData.m_allPlayerCard[i].m_arrCard)
        end
    end

    self:resetSceneShow()

    if bIsReturn then
        if(self:getGameSection() == GameDefs.emGameSection.GAME_SECTION_FIRST_STAKE) then
            if self:isSectionChanged() then
                self.m_pTimer:Start(self:getSceneSectionTime(), 13)
                self.m_pTimer:setVisible(false)
            end
        end
        return
    end
   
    --游戏状态
    if(self:getGameSection() == GameDefs.emGameSection.GAME_SECTION_READY) then
        if self:isSectionChanged() then
            self.m_pTimer:Start(self:getSceneSectionTime(), 13)
        end

    elseif(self:getGameSection() == GameDefs.emGameSection.GAME_SECTION_BANKER_BID) then
        if self:isSectionChanged() then
            self.m_pTimer:Start(self:getSceneSectionTime(), 13)
            self.m_pTimer:setVisible(false)
        end
        self:showBankerBid()

    elseif(self:getGameSection() == GameDefs.emGameSection.GAME_SECTION_FIRST_STAKE) then
        if self:isSectionChanged() then
            self.m_pTimer:Start(self:getSceneSectionTime(), 13)
			if not (self.m_nGameType == 1 or  self.m_nGameType == 6) then --非抢庄类型
				self.m_pTimer:setVisible(false)
			end
        else
            self.m_pTimer:setVisible(true)
        end
        if self.m_stSceneData.m_cbBanker == self.m_cbMyChair then
            self:showWaitStake()
        else
            self:showPlayerStake()
        end

    elseif (self:getGameSection() == GameDefs.emGameSection.GAME_SECTION_SECOND_STAKE) then
        
    elseif (self:getGameSection() == GameDefs.emGameSection.GAME_SECTION_THIRD_STAKE) then

    elseif (self:getGameSection() == GameDefs.emGameSection.GAME_SECTION_CARD_SORT) then
        if self:isSectionChanged() then
            local nOffset = 0
            if self.m_isGameStart == false then
                nOffset = 2
            end
            self.m_pTimer:Start(self:getSceneSectionTime() + nOffset, 13)
            self.m_pTimer:setVisible(false)
        end
        self:showSortCard()

    elseif (self:getGameSection() == GameDefs.emGameSection.GAME_SECTION_CHECK_OUT) then
        if self:isSectionChanged() then
            --self.m_pTimer:Start(self:getSceneSectionTime(), 13)
        end
        self.m_stGameEnd = GameDefs.ST_GameEnd(ba)
        self:showGameCheck()

    end

	if(self.m_stSceneData.m_cbActionChair == GameDefs.PLAYER_COUNT and 
			self.m_stSceneData.m_cbCommand == GameDefs.emCmdType.CMD_TYPE_INVALID) then --这个时候是断线重连
		self.m_isGameStart = true
	end
end

function DeskScene:resetSceneShow()
    if self:isSectionChanged() then
        self.m_pTimer:Stop()
    end
    self:hideSortCard()
    self:hideBankerBid()
    self:hideWaitStake()
    self:hidePlayerStake()
end

function DeskScene:showGameStart(callBack)
    self.m_isCloseGameOver = false
	self:clearFriendValidTimerUI()
	if self.m_gameButtonLayer.backHomeBtn ~= nil  then --游戏开始后禁用掉返回大厅的按钮
		self.m_gameButtonLayer.backHomeBtn:setEnabled(false)
		--self.roomInfoBk:setPosition(ccp(15,705))
	end
	
	if self.gameOverDlg ~= nil then
		self.gameOverDlg:showDlg(false)
	end	
    if not self.m_isGameStart and not self.m_isGameStarting then
        self.m_isGameStarting = true

        self:showIsHaveEqualsIp()
        SoundRes.playGlobalEffect(SoundRes.SOUND_STARTGAME)
        
        local  function kaiShiArmatureFinshCallBack()
            for i=1,GameDefs.PLAYER_COUNT do
                local cbChair = i - 1;
                local nPos = self:PosFromChair(cbChair)
                self.m_aclsPlayer[nPos]:getPlayerCardLayer():setGroupCards(self.m_stSceneData.m_allPlayerCard[i].m_arrCard)
            end
            if callBack then
                local function bidCallback()
                    self.m_isGameStarting = false
                    self.m_isGameStart = true
                    callBack()
                end
                local arrayAction = CCArray:create()
                arrayAction:addObject(CCDelayTime:create(1))
                arrayAction:addObject(CCCallFunc:create(bidCallback))
                self:runAction(CCSequence:create(arrayAction))
            end
        end

        local BaseArmatureLayer = require("bull/desk/BaseArmatureLayer")
        local baseArmatureLayer = BaseArmatureLayer.create("GameStar", 0, kaiShiArmatureFinshCallBack, nil)
        self:addChild(baseArmatureLayer,10)
    end
end

function DeskScene:showBankerBid()
    local function gameStartCallBack()
        self.m_pTimer:setVisible(true)
        for i=1,GameDefs.PLAYER_COUNT do
            local cbChair = i - 1;
            local nPos = self:PosFromChair(cbChair)
            self.m_aclsPlayer[nPos]:getPlayerCardLayer():setGroupCards(self.m_stSceneData.m_allPlayerCard[i].m_arrCard)
        end

        for i=1,GameDefs.PLAYER_COUNT do
            self.m_aclsPlayer[i]:resetState()
        end
		local nCmd ,nPos
		if(self.m_stSceneData.m_cbActionChair == GameDefs.PLAYER_COUNT and 
			self.m_stSceneData.m_cbCommand == GameDefs.emCmdType.CMD_TYPE_INVALID) then --这个时候是断线重连
			for i=1,GameDefs.PLAYER_COUNT do
				nCmd = self.m_stSceneData.m_acbBankerBid[i]
				nPos = self:PosFromChair(i - 1)
				if nCmd == GameDefs.EN_BANKER_BID.EN_BANKER_BID_NONE then
				
				elseif nCmd == GameDefs.EN_BANKER_BID.EN_BANKER_BID_WANT then
					self.m_aclsPlayer[nPos]:setBid(true)
					table.insert(self.m_vBidPlayers, nPos)
				elseif nCmd == GameDefs.EN_BANKER_BID.EN_BANKER_BID_WONT then
					self.m_aclsPlayer[nPos]:setBid(false)
				elseif nCmd == GameDefs.EN_BANKER_BID.EN_BANKER_BID_MUST then

				end
			end
		else
		    local cbChair = self.m_stSceneData.m_cbActionChair
			nCmd = self.m_stSceneData.m_acbBankerBid[cbChair+1]
			nPos = self:PosFromChair(cbChair)
			if nCmd == GameDefs.EN_BANKER_BID.EN_BANKER_BID_NONE then
			elseif nCmd == GameDefs.EN_BANKER_BID.EN_BANKER_BID_WANT then
				self.m_aclsPlayer[nPos]:setBid(true)
				table.insert(self.m_vBidPlayers, nPos)
				if nPos == 1 then
					local musicName = string.format("qiangzhuang%d.mp3",math.random(2))
					SoundRes.playEffectEx(musicName,self.m_aclsPlayer[nPos].m_nSex)
				end
			elseif nCmd == GameDefs.EN_BANKER_BID.EN_BANKER_BID_WONT then
				cclog(" BU QIANG ZHUANG")
				self.m_aclsPlayer[nPos]:setBid(false)
			elseif nCmd == GameDefs.EN_BANKER_BID.EN_BANKER_BID_MUST then

			end
		end


        if self.m_aclsPlayer[1]:getBid() == nil then
            self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_BIDYES,true)
            self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_BIDNO,true)
        else
            self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_BIDYES,false)
            self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_BIDNO,false)
        end
    end

    if self.m_isGameStart == false then
        self:showGameStart(gameStartCallBack)
    else
        gameStartCallBack()
    end
end

function DeskScene:hideBankerBid()
    if self:getGameSection() ~= GameDefs.emGameSection.GAME_SECTION_BANKER_BID then
        self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_BIDYES,false)
        self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_BIDNO,false)
    end
end

function DeskScene:showWaitStake()
	local function gameStartCallBack()
		for i=1,GameDefs.PLAYER_COUNT do
			self.m_aclsPlayer[i]:resetBid()
		end
		--if self.m_bAdvanceDealCard == false and self.bNotBanker == false then --经典牛牛
		if self:getIsSystemSetBanker() then -- 系统确定庄家的玩法
			for i=1,GameDefs.PLAYER_COUNT do		
				local cbChair = i - 1;			
				local nPos = self:PosFromChair(cbChair)
				self.m_aclsPlayer[nPos]:setMaster(cbChair == self.m_stSceneData.m_cbBanker)
				self.m_aclsPlayer[nPos]:getPlayerCardLayer():setGroupCards(self.m_stSceneData.m_allPlayerCard[i].m_arrCard)
			end
			self:showChangeBankerTip()
			self.m_pTimer:setVisible(true)
		end
		self.m_spWaitStake:setVisible(true)
		if(self.m_stSceneData.m_cbActionChair == GameDefs.PLAYER_COUNT and 
				self.m_stSceneData.m_cbCommand == GameDefs.emCmdType.CMD_TYPE_INVALID) then --这个时候是断线重连
			for i = 1,GameDefs.PLAYER_COUNT do 
				local nBeiShu = self.m_stSceneData.m_alStake[i]
				local nPos = self:PosFromChair(i - 1)
				if nPos <= GameDefs.PLAYER_COUNT and nBeiShu ~= 0 then
					self.m_aclsPlayer[nPos]:setBeiShu(nBeiShu)
				end
			end
		else
			local cbChair = self.m_stSceneData.m_cbActionChair
			local nBeiShu = self.m_stSceneData.m_alStake[cbChair+1]
			local nPos = self:PosFromChair(cbChair)
			if nPos <= GameDefs.PLAYER_COUNT then
				self.m_aclsPlayer[nPos]:setBeiShu(nBeiShu)
			end
		end
	end
	if self.m_isGameStart == false then
        self:showGameStart(gameStartCallBack)
    else
        gameStartCallBack()
    end
end

function DeskScene:hideWaitStake()
    if self:getGameSection() ~= GameDefs.emGameSection.GAME_SECTION_FIRST_STAKE then
        self.m_spWaitStake:setVisible(false)
    end
end

function DeskScene:showPlayerStake()
	local function gameStartCallBack()
		for i=1,GameDefs.PLAYER_COUNT do
			self.m_aclsPlayer[i]:resetBid()
		end
		--if self.m_bAdvanceDealCard == false and self.bNotBanker == false then --经典牛牛
		if self:getIsSystemSetBanker() then -- 系统确定庄家的玩法
			for i=1,GameDefs.PLAYER_COUNT do		
				local cbChair = i - 1;			
				local nPos = self:PosFromChair(cbChair)
				self.m_aclsPlayer[nPos]:setMaster(cbChair == self.m_stSceneData.m_cbBanker)
				self.m_aclsPlayer[nPos]:getPlayerCardLayer():setGroupCards(self.m_stSceneData.m_allPlayerCard[i].m_arrCard)
			end
			self.m_spWaitStake:setVisible(false)	
			self.m_pTimer:setVisible(true)
			self:showChangeBankerTip()
		end
		if(self.m_stSceneData.m_cbActionChair == GameDefs.PLAYER_COUNT and 
				self.m_stSceneData.m_cbCommand == GameDefs.emCmdType.CMD_TYPE_INVALID) then --这个时候是断线重连
			for i = 1,GameDefs.PLAYER_COUNT do 
				local nBeiShu = self.m_stSceneData.m_alStake[i]
				local nPos = self:PosFromChair(i - 1)
				if nPos <= GameDefs.PLAYER_COUNT and nBeiShu ~= 0 then
					self.m_aclsPlayer[nPos]:setBeiShu(nBeiShu)
				end
			end
		else
			local cbChair = self.m_stSceneData.m_cbActionChair
			local nBeiShu = self.m_stSceneData.m_alStake[cbChair+1]
			local nPos = self:PosFromChair(cbChair)
			if nPos <= GameDefs.PLAYER_COUNT then
				self.m_aclsPlayer[nPos]:setBeiShu(nBeiShu)
				if nPos == 1 then
					local musicName = string.format(nBeiShu > 1 and "jiabei%d.mp3" or "bujiabei%d.mp3",math.random(2))		
					SoundRes.playEffectEx(musicName,self.m_aclsPlayer[nPos].m_nSex)
				end
			end
		end
		if self.m_aclsPlayer[1]:getBeiShu() == nil then
			self.m_spStakeBg:setVisible(true)
			self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_1BEI,true)
			self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_2BEI,true)
			self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_5BEI,true)
			
			self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_3BEI,self.nMaxStake == 5)
			self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_10BEI,self.nMaxStake == 10)
		else
			self.m_spStakeBg:setVisible(false)
			self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_1BEI,false)
			self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_2BEI,false)
			self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_3BEI,false)
			self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_5BEI,false)
			self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_10BEI,false)
		end
	end	
	if self.m_isGameStart == false then
        self:showGameStart(gameStartCallBack)
    else
        gameStartCallBack()
    end
end

function DeskScene:hidePlayerStake()
    if self:getGameSection() ~= GameDefs.emGameSection.GAME_SECTION_FIRST_STAKE then
        self.m_spStakeBg:setVisible(false)
        self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_1BEI,false)
        self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_2BEI,false)
		self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_3BEI,false)
        self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_5BEI,false)
        self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_10BEI,false)
    end
end

function DeskScene:showNiuMark(nPos, nNiuType)
    if self.m_aclsPlayer[nPos]:getNiuType() == nil then
        self.m_aclsPlayer[nPos]:setNiuType(nNiuType)

        if nNiuType == GameDefs.emBullType.BULL_TYPE_INVALID then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_MeiNiu)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_NULL then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_MeiNiu)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_1 then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_Niu1)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_2 then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_Niu2)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_3 then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_Niu3)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_4 then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_Niu4)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_5 then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_Niu5)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_6 then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_Niu6)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_7 then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_Niu7)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_8 then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_Niu8)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_9 then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_Niu9)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_10 then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_NiuNiu)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_BOMB then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_SiZha)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_5_JQK then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_WuHuaNiu)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_5_MIN then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_WuXiaoNiu)
        end

        local strFormat = string.format("niu%s.mp3", nNiuType-1)
		
        SoundRes.playEffectEx(strFormat,self.m_aclsPlayer[nPos].m_nSex)
    end
end

function DeskScene:showSortCard()
    local function gameSortCallBack()
        self.m_pTimer:setVisible(true)
        for i=1,GameDefs.PLAYER_COUNT do
            local cbChair = i - 1;
            local nPos = self:PosFromChair(cbChair)
            self.m_aclsPlayer[nPos]:getPlayerCardLayer():setGroupCards(self.m_stSceneData.m_allPlayerCard[i].m_arrCard)
        end

        for i=1,GameDefs.PLAYER_COUNT do
            self.m_aclsPlayer[i]:resetBid()
        end
		if(self.m_stSceneData.m_cbActionChair == GameDefs.PLAYER_COUNT and 
			self.m_stSceneData.m_cbCommand == GameDefs.emCmdType.CMD_TYPE_INVALID) then --这个时候是断线重连
			for i = 1,GameDefs.PLAYER_COUNT do 
				local nBeiShu = self.m_stSceneData.m_alStake[i]
				local nPos = self:PosFromChair(i - 1)
				if nPos <= GameDefs.PLAYER_COUNT and nBeiShu ~= 0 then
					self.m_aclsPlayer[nPos]:setBeiShu(nBeiShu)
				end
			end
			if self.m_bAdvanceDealCard == false and self.bNotBanker == false then --经典牛牛断线重回设置庄家
				for i=1,GameDefs.PLAYER_COUNT do		
					local cbChair = i - 1;			
					local nPos = self:PosFromChair(cbChair)
					self.m_aclsPlayer[nPos]:setMaster(cbChair == self.m_stSceneData.m_cbBanker)
				end
			end
			for i = 1,GameDefs.PLAYER_COUNT do
				if(self.m_stSceneData.m_isShow[i] ~= 0) then --已经组牌
					local nNiuType = self.m_stSceneData.m_allPlayerCard[i].m_stMaxRullData.m_byBullType
					local nPos = self:PosFromChair(i - 1)
					self:showNiuMark(nPos, nNiuType)
				end
			end
			if self.m_aclsPlayer[1]:getNiuType() == nil then --自己的牌没组，显示组牌框
				self.m_spSort:setVisible(true)
				self:onNotifyListenCard()
			else
				self.m_spSort:setVisible(false)
				self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_BULLYES,false)
				self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_BULLNO,false)
			end
		else
			if self.m_stSceneData.m_cbActionChair < GameDefs.PLAYER_COUNT then
				local nPos = self:PosFromChair(self.m_stSceneData.m_cbActionChair)
				local nNiuType = self.m_stSceneData.m_allPlayerCard[self.m_stSceneData.m_cbActionChair+1].m_stMaxRullData.m_byBullType
				if self.m_stSceneData.m_cbActionChair == self.m_cbMyChair then
					self.m_spSort:setVisible(false)
					self.m_spHaveNiu:setVisible(false)
					self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_BULLYES,false)
					self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_BULLNO,false)
					for i=1,4 do
						self.m_vSelectCardShow[i]:setString("")
					end
				else
					if self.m_aclsPlayer[1]:getNiuType() == nil then
						self.m_spSort:setVisible(true)
						self:onNotifyListenCard()
					end
				end
				self:showNiuMark(nPos, nNiuType)
			else
				if self.m_aclsPlayer[1]:getNiuType() == nil then
					self.m_spSort:setVisible(true)
					self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_BULLNO,true)
				end
			end
		end

    end

    if self.m_isGameStart == false then
        self:showGameStart(gameSortCallBack)
    else
        gameSortCallBack()
    end
end

function DeskScene:hideSortCard()
    if self:getGameSection() ~= GameDefs.emGameSection.GAME_SECTION_CARD_SORT then
        self.m_spSort:setVisible(false)
        self.m_spHaveNiu:setVisible(false)
        self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_BULLYES,false)
        self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_BULLNO,false)
        for i=1,4 do
            self.m_vSelectCardShow[i]:setString("")
        end
    end
end

function DeskScene:showGameCheck() -- 显示一小局的结算分数
    
	if self.showTotalScore == true then return end
    cclog("DeskScene:showGameCheck()=======================================================")
    self.m_gameButtonLayer:setAllGameButtonIsVis(false)
    self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_ROBOTCACEL,false)

    for cbChair=0,GameDefs.PLAYER_COUNT-1 do
        local nPos = self:PosFromChair(cbChair)
        local nNiuType = self.m_stSceneData.m_allPlayerCard[cbChair+1].m_stMaxRullData.m_byBullType
        self:showNiuMark(nPos, nNiuType)

        --self.m_aclsPlayer[nPos]:resetBeiShu()
    end
	local reconnect = false
 	if(self.m_stSceneData.m_cbActionChair == GameDefs.PLAYER_COUNT and 
			self.m_stSceneData.m_cbCommand == GameDefs.emCmdType.CMD_TYPE_INVALID) then --这个时候是断线重连
		reconnect = true
	end
	if reconnect and self.m_bAdvanceDealCard == false and self.bNotBanker == false then --经典牛牛断线重回设置庄家
		for i=1,GameDefs.PLAYER_COUNT do		
			local cbChair = i - 1;			
			local nPos = self:PosFromChair(cbChair)
			self.m_aclsPlayer[nPos]:setMaster(cbChair == self.m_stSceneData.m_cbBanker)
		end
	end
	if reconnect and self.bNotBanker == false then
		for i = 1,GameDefs.PLAYER_COUNT do 
			local nBeiShu = self.m_stSceneData.m_alStake[i]
			local nPos = self:PosFromChair(i - 1)
			if nPos <= GameDefs.PLAYER_COUNT and nBeiShu ~= 0 then
				self.m_aclsPlayer[nPos]:setBeiShu(nBeiShu)
			end
		end
	end
    local function gameOverCallBack()
        self.m_isGameStart = false
		if self.showTotalScore == true then return end
        for i=1,GameDefs.PLAYER_COUNT do
            self.m_aclsPlayer[i]:turnToOutPlayCardIsVis(false)
           -- self.m_aclsPlayer[i]:cleanAllPlayerCardLayerMj()
            self.m_aclsPlayer[i]:GameOver()
            self.m_aclsPlayer[i]:resetNiuType()
        end

        self.m_pTimer:Stop()
     
        local vPlayersName = {}
        for cbChair=0,GameDefs.PLAYER_COUNT-1 do
            local nPos = self:PosFromChair(cbChair)
            local userName = self.m_aclsPlayer[nPos]:getUserName()
            table.insert(vPlayersName, userName)
        end
		
		if(self.gameOverDlg == nil) then
			local GameOverDialog = require("bull/desk/gameover/GameOverDialog")
			self.gameOverDlg = GameOverDialog.create(self)
			--CCDirector:sharedDirector():getRunningScene():addChild(self.gameOverDlg,6)
			self:addChild(self.gameOverDlg,20)
			self.gameOverDlg:setPlayerData(self.m_stGameEnd,self.m_aclsPlayer,self.realPlayerCnt)
			self.gameOverDlg:showDlg(true)
		else
			self.gameOverDlg:setPlayerData(self.m_stGameEnd,self.m_aclsPlayer,self.realPlayerCnt)
			self.gameOverDlg:showDlg(true)
		end
		tablePrint(self.readyTable)
		if reconnect and  self.readyTable ~= nil then
			for i = 0, #self.readyTable do
				if self.readyTable[i] then
					self:playerReady(i)
				end
			end
			self.readyTable = nil
		end	
		self.showCheckInfo = false 	
    end

    local function delayCallBack()
        for i=1,GameDefs.PLAYER_COUNT do
            self.m_aclsPlayer[i]:resetNiuType()
        end
        local nMyScore = self.m_stGameEnd.nScore[self.m_cbMyChair + 1]
 --[[       for i=0,GameDefs.PLAYER_COUNT-1 do
            local nPos = self:PosFromChair(i)
            if nPos == 1 then
                nMyScore = self.m_stGameEnd.nScore[i+1]
            end
        end]]
        if nMyScore > 0 then
            SoundRes.playGlobalEffect(SoundRes.SOUND_WIN)
            local BaseArmatureLayer = require("bull/desk/BaseArmatureLayer")
            local baseArmatureLayer = BaseArmatureLayer.create("shegnlishibai", 0, gameOverCallBack, nil)
            self:addChild(baseArmatureLayer,105)

            self.m_aclsPlayer[1]:winPlayingState()
			
			
			if not reconnect then self.winCount = self.winCount + 1 end	
			self.loseCount = 0
			SoundRes.playEffectEx(self.winCount > 1 and "youyingle.mp3" or "yingle.mp3",self.m_aclsPlayer[1].m_nSex)
        elseif nMyScore < 0 then
            SoundRes.playGlobalEffect(SoundRes.SOUND_LOSE)
            local BaseArmatureLayer = require("bull/desk/BaseArmatureLayer")
            local baseArmatureLayer = BaseArmatureLayer.create("shegnlishibai", 1, gameOverCallBack, nil)
            self:addChild(baseArmatureLayer,105)
			
			if not reconnect then self.loseCount = self.loseCount + 1 end	
			self.winCount = 0
			
			SoundRes.playEffectEx(self.loseCount > 1 and "youshule.mp3" or "shule.mp3",self.m_aclsPlayer[1].m_nSex)
        else
            gameOverCallBack()
        end
    end

    --停留2秒再播放结束
    local arrayAction = CCArray:create()
    arrayAction:addObject(CCDelayTime:create(1.2))
    arrayAction:addObject(CCCallFunc:create(delayCallBack))
    self:runAction(CCSequence:create(arrayAction))
end

function DeskScene:getGameSceneData()
    return self.m_stSceneData
end

function DeskScene:getGameScenePlayers()
    return self.m_aclsPlayer
end

function DeskScene:getSceneSectionTime()
    if self.m_gameRule then
        if(self:getGameSection() == GameDefs.emGameSection.GAME_SECTION_READY) then
            return self.m_gameRule.m_anTime[1]

        elseif(self:getGameSection() == GameDefs.emGameSection.GAME_SECTION_BANKER_BID) then
            return self.m_gameRule.m_anTime[2]

        elseif(self:getGameSection() == GameDefs.emGameSection.GAME_SECTION_FIRST_STAKE) then
            return self.m_gameRule.m_anTime[3]

        elseif (self:getGameSection() == GameDefs.emGameSection.GAME_SECTION_SECOND_STAKE) then
            return self.m_gameRule.m_anTime[3]

        elseif (self:getGameSection() == GameDefs.emGameSection.GAME_SECTION_THIRD_STAKE) then
            return self.m_gameRule.m_anTime[3]

        elseif (self:getGameSection() == GameDefs.emGameSection.GAME_SECTION_CARD_SORT) then
            return self.m_gameRule.m_anTime[4] - 2

        elseif (self:getGameSection() == GameDefs.emGameSection.GAME_SECTION_CHECK_OUT) then
            return self.m_gameRule.m_anTime[5]

        end
    end
    return 10
end
function DeskScene:onGameMessage(chair,  cCmdID,  lpBuf,  nLen)
    cclog("DeskScene  onGameMessage: nChair ="..chair.."   Cmd="..cCmdID.."    nLen=="..nLen)
--[[    if nLen<=0 then
        cclog("onGameMessage nLen<=0 return ")
        return 
    end]]

    if cCmdID == CS_Message.SC_GAMEMSG_GAMERULE then
        self.m_gameRule = CS_Message.stGameRuleBase:new(lpBuf)
		self.bNotBanker = self.m_gameRule.m_bNotBanker ~= 0
		self.realPlayerCnt = self.m_gameRule.m_nPlayerCount
		
		if self.m_gameRule.m_nGameType == 0 then --兼容旧版本
			self.m_nGameType = self.bNotBanker and 2 or 3
		else
			self.m_nGameType = self.m_gameRule.m_nGameType
		end
		self.nMaxStake = self.m_gameRule.m_nMaxStake
		if self.m_gameButtonLayer then
			self.m_gameButtonLayer:setMaxStake(self.nMaxStake)
		end
		cclog("最大下注msg:"..self.nMaxStake)
		for pos = 1,5 do
			self.m_aclsPlayer[pos]:initPossition(self.realPlayerCnt)
		end
		if self.m_gameButtonLayer.talkButton ~= nil then
			self.m_gameButtonLayer.talkButton:setPlayerPos()
		end
    end
	if(cCmdID == CS_Message.SC_GAMEMSG_READY) then--玩家准备
		local ba = require("ByteArray").new()
        ba:initBuf(lpBuf)
		local nChairID = ba:readInt()
		
		if nChairID == self.m_cbMyChair and self.gameOverDlg ~= nil then
			self.showCheckInfo = false
		end	
		if self.showCheckInfo then --正在显示断线重连的结算信息
			if self.readyTable == nil then self.readyTable = {} end
			self.readyTable[nChairID] = true
			return
		end
		self:playerReady(nChairID)
	end
	if(cCmdID == CS_Message.SC_GAMEMSG_SCENE) then  --一局结束后的场景数据
		local ba = require("ByteArray").new()
		ba:writeBuf(lpBuf)
		ba:setPos(1)
		local sceneData = GameDefs.GameScene(ba)
		
		if( sceneData.m_cbCommand == GameDefs.emCmdType.CMD_TYPE_REVERT and sceneData.m_cbActionChair == GameDefs.PLAYER_COUNT) then
			   self.m_stSceneData = {}	--场景数据
			   self.m_stSaveSceneData = {}	--上一个场景数据
			if self.gameOverDlg ~= nil then
				self.gameOverDlg:showDlg(false)
			end
			self.showCheckInfo = true  --显示结算信息
			self:onSceneChanged(lpBuf,nLen)	
		end
	end
	if( cCmdID == CS_Message.SC_GAMEMSG_START) then
		cclog("game start !!!")
		if self.curSet ~= nil and self.totalSet ~= nil then --每局游戏开始更新下当前局数
			self.curSet = self.curSet + 1
			if self.curSet > self.totalSet then self.curSet = self.totalSet end
			self:addPrivateRoomNumUI() --更新房间信息
			
			FriendGameLogic.game_abled = true
			FriendGameLogic.game_used = self.curSet
		end
		if nLen > 0 then
			local ba = require("ByteArray").new()
			ba:initBuf(lpBuf)
			self.lastBanker = ba:readInt() -- 上一局的庄家
			cclog(" lastBanker"..self.lastBanker)
		end
	end
	
end -- end onGameMessage
function DeskScene:playerReady(nChairID)
    self.m_aclsPlayer[self:PosFromChair(nChairID)]:setIsReady(true)		
	if nChairID == self.m_cbMyChair and self.gameOverDlg ~= nil then
			self.gameOverDlg:showDlg(false)
	end	
    for i=1,GameDefs.PLAYER_COUNT do
		if(nChairID == self.m_cbMyChair and self.m_aclsPlayer[i]) then --准备的时候清掉手里的牌		
            self.m_aclsPlayer[i]:resetShow()
			self.m_aclsPlayer[i]:cleanAllPlayerCardLayerMj()
			self.m_aclsPlayer[i]:setMaster(false)
		end
    end
end
function DeskScene:showTotalSettle(bShow,infoList) -- 显示总结算
 --[[   if self.m_vDissmissTable == nil then
        return
    end]]
	self.showTotalScore = true
	
	if(self.gameOverDlg ~= nil) then
		self.gameOverDlg:showDlg(false)
		self.gameOverDlg:removeFromParentAndCleanup(true)
		self.gameOverDlg = nil
	end
    local PrivateRoomTotalSettleDialog = require("bull/desk/totalsettle/PrivateRoomTotalSettleDialog")
	--在这里需要构造结算需要的数据
	self.m_pTotalSettleDialog = PrivateRoomTotalSettleDialog.create(self.realPlayerCnt,self.marstID,FriendGameLogic.invite_code,
		self.m_cbMyChair,self.curSet,self.totalSet,infoList,300)
    self.m_pTotalSettleDialog:setTag(Resources.TOTAL_SETTLE)
 
    self.m_pTotalSettleDialog:setVisible(true)
	--CCDirector:sharedDirector():getRunningScene()
    CCDirector:sharedDirector():getRunningScene():addChild(self.m_pTotalSettleDialog,300)
end

function DeskScene:onPlayerStateChanged(nChair, nOldState, nNewState)

    if nChair >= GameDefs.PLAYER_COUNT or nChair < 0 then
        return
    end
    cclog("onPlayerStateChanged Player nChair="..nChair.."   nOldState="..nOldState.."   nNewState="..nNewState)
	local pos = self:PosFromChair(nChair)
	if pos <= 0 and pos > 5 then
		return
	end
    if (nNewState == gamelibcommon.USER_OFF_LINE) then
        self.m_aclsPlayer[pos]:setIsOffLine(true)
    else
        self.m_aclsPlayer[pos]:setIsOffLine(false)
    end
    if (nNewState==gamelibcommon.USER_PLAY_GAME) then
        for chair = 0, GameDefs.PLAYER_COUNT-1 do 
            self.m_aclsPlayer[self:PosFromChair(chair)]:setIsReady(false)
        end
    end
    self:selfNoReadyDownTime(nNewState)
end
function DeskScene:selfNoReadyDownTime(nNewState)
    local function stopDelayTimer()
        if self.m_DelaypTimer then
            self.m_DelaypTimer:Stop()
            self.m_DelaypTimer = nil
        end
    end

    if nNewState == gamelibcommon.USER_PLAY_GAME then
       stopDelayTimer()
       return
    end

    if self.m_gameButtonLayer then
       -- local bIsVis = self.m_gameButtonLayer:getOneButtonIsVis(GameButtonLayer.BT_STARTGAME)
        if not bIsVis then --开始游戏按钮是否显示
            stopDelayTimer()
            return
        end
    else
        return
    end
    
    local nCount =0
    for nChair=0, GameDefs.PLAYER_COUNT-1 do
        if(nChair == self.m_cbMyChair) then
            if(self.m_aclsPlayer[self:PosFromChair(nChair)].m_cbReady) then
                nCount =0
                stopDelayTimer()
                break
            end
        else
            if(self.m_aclsPlayer[self:PosFromChair(nChair)].m_cbReady) then
                nCount=nCount+1
            end
        end   
    end
    
    if(nCount >= GameDefs.PLAYER_COUNT-1) then--//这个处理是三家都准备的情况下，自己还没有准备，倒计时15秒踢出房间
        stopDelayTimer()
        local function timerFinshCallBack()
            self:leaveGameCallBack()
        end
        local winSize = CCDirector:sharedDirector():getWinSize()
        self.m_DelaypTimer = Timer.createTimer(timerFinshCallBack)
        self.m_DelaypTimer:setAnchorPoint(ccp(0,0))
        self.m_DelaypTimer:setPosition(ccp(winSize.width/2-60, winSize.height/2-20))
        self.m_DelaypTimer:Start(15,13)
        self:addChild(self.m_DelaypTimer,2)
    end
end

function DeskScene:isValidChair(nChair)
    if nChair == GameCfg.INVALID_CHAIR_NO then
        return false
    end
    return true
end
--更新用户信息，这里主要是更新金币
function DeskScene:updateUserInfo(user)
    if user~=nil then
		
        self.m_pMyself =DeskScene.getGameLib():getMyself()
        if (self.m_pMyself and user:getUserDBID() == self.m_pMyself:getUserDBID()) then
            self.m_aclsPlayer[1]:RefreshGold(user:getScore())
            return
        end
 
        local cbChair = user:getUserChair()
        if (self:isValidChair(cbChair)) then
            self.m_aclsPlayer[self:PosFromChair(cbChair)]:RefreshGold(user:getScore())
        end 
    end
end

--为了抓码再刷新金币
function DeskScene:updateUserGold()
    for nPos=1, GameDefs.PLAYER_COUNT do
        local player = self.m_aclsPlayer[nPos]
        local pUser = require("bull/GameLibSink").game_lib:getUser(player.m_nUserID)
        if pUser then
            player:RefreshGold(pUser:getGold())
        end
    end
end

--是否是私人场
function DeskScene:getIsPrivateRoom()
    local gamelib = DeskScene.getGameLib()
    return gamelib:isInPrivateRoom()
end
function  DeskScene:onNotifiRobot(obj)
    if self:getGameSection() and self:getGameSection() ~= GameDefs.emGameSection.GAME_SECTION_CHECK_OUT  then
        SendCMD.sendCMD_PO_ROBOTPLAYSTART() 
    else
        Resources.ShowToast("游戏还没有开始不能托管!")
    end
end

function DeskScene:onNotifyListenCard()
    if self:getGameSection() ~= GameDefs.emGameSection.GAME_SECTION_CARD_SORT then
        return
    end
    self.m_spHaveNiu:setVisible(false)
    for i=1,4 do
        self.m_vSelectCardShow[i]:setString("")
    end
    local vSelectCards = self.m_aclsPlayer[1]:getPlayerCardLayer():getSelectCards()
    --Resources.ShowToast(string.format("select:%d", #vSelectCards))
    local nTotalValue = 0
    local nCount = #vSelectCards
    for i=1,nCount do
        local nValue = vSelectCards[i].m_byCardPoint
        if nValue > 10 then
            nValue = 10
        end
        nTotalValue = nTotalValue + nValue
        self.m_vSelectCardShow[i]:setString(string.format("%d", nValue))
    end
    if nTotalValue > 0 then
        self.m_vSelectCardShow[4]:setString(string.format("%d", nTotalValue))
        if nCount == 3 and nTotalValue % 10 == 0 then
            self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_BULLYES,true)
            self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_BULLNO,false)
        else
            self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_BULLYES,false)
            self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_BULLNO,true)
        end
    else
        self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_BULLYES,false)
        self.m_gameButtonLayer:setOneButtonIsVis(GameButtonLayer.BT_BULLNO,true)
    end
end
function DeskScene:onNotifiBroadCast(obj)

    local winSize = CCDirector:sharedDirector():getWinSize()
    local gameLib = DeskScene.getGameLib()
	if AppConfig.ISIOS then
 --   if require("HallControl"):instance():isIOS() then
        
        local function onSendSpeaker(content)
            gameLib:sendSpeaker(content)
        end
        local placeHolder = Resources.DESC_SPEAKER_SENDTIPS
        local nleftLaba = gameLib:getFreeSpeakerLeft()
        if (nleftLaba ~= 0) then
            placeHolder = string.format(Resources.DESC_FREESPEAKER_NUM, nleftLaba)
        end
        self:addChild(require("bull/Public/SendSpeaker").create(ccp(winSize.width/2,300),placeHolder,onSendSpeaker))
    else
        self.m_pEbSpeaker:setEnabled(true)
        self.m_pEbSpeaker:setVisible(false)                
        local nleftLaba = gameLib:getFreeSpeakerLeft()
        if (nleftLaba ~= 0) then
            self.m_pEbSpeaker:setPlaceHolder(string.format(Resources.DESC_FREESPEAKER_NUM, nleftLaba))
        else
            self.m_pEbSpeaker:setPlaceHolder(Resources.DESC_SPEAKER_SENDTIPS)
        end
        self.m_pEbSpeaker:setPlaceholderFontSize(Resources.FONT_SIZE20)
        self.m_pEbSpeaker:setPlaceholderFontColor(ccc3(255, 255, 255))          
        self.m_pEbSpeaker:setText("")
        self.m_pEbSpeaker:touchDownAction(self, CCControlEventTouchUpInside)
    end     
end

function DeskScene:onNotifiLeaveGameRoom(name,obj)
    local function onDialogControlCallback(first, target, event)
        self:leaveGameCallBack()
    end
    if  self:MyState() ~= gamelibcommon.USER_PLAY_GAME then
        if self:getIsPrivateRoom() then
   --[[         local function privateConfirmClickCallback()
                onDialogControlCallback("", nil, "")
            end
            local TipsDialog = require("bull/public/TipsDialog")
            local leaveStr = "是否离开房间?(如果10分钟内没有正式开始游戏,系统将会自动解散房间并退回房卡)"
            local tipsDialog = TipsDialog.create("bull/bullResources/DeskScene/title_leave.png", leaveStr, privateConfirmClickCallback, true, nil, nil)
            tipsDialog:setTag(Resources.MSG_BOX_TAG)
            CCDirector:sharedDirector():getRunningScene():addChild(tipsDialog,5)]]
        else
            onDialogControlCallback("", nil, "")
        end
        return
    end

    -- local dialog = BaseDialog.create("现在离开将会由笨笨的机器人帮您代打哦,确定离开吗?", nil, nil, nil, nil, onDialogControlCallback)
    -- dialog:setTag(Resources.MSG_BOX_TAG)
    -- CCDirector:sharedDirector():getRunningScene():addChild(dialog)
end

function DeskScene:onNotifiRobotReplaceOutCard()
    
end

function DeskScene:_TimeOut(nFlag)
    cclog("!!DeskScene._TimeOut!!!!!!!=====")

    if not self:getIsPrivateRoom() then
        if self.m_cbMyChair == self.m_stSceneData.cbWhosTurn then
            self.m_nCurrentOverTimeTimes = self.m_nCurrentOverTimeTimes + 1
            if  self.m_nCurrentOverTimeTimes >= self.m_nMaxOverTimeTimes then
                self:onNotifiRobot()
            end
        end
    end
end

function DeskScene:leaveGameCallBack()
	local GameLibSink = require("bull/GameLibSink")
	GameLibSink.returnToLobby()
end

function DeskScene:getGameStation()
    local gamelib = DeskScene.getGameLib()
    local pRoomServerList =gamelib:getAllGameServerList()
    local room = gamelib:getCurrentGameRoom()
    if(room == nil) then
      return nil
    end  
    local nStationId=room.dwStationID
    return gamelib:getGameStation(nStationId)
end
function DeskScene:addRoomRuleLabel()
	local winSize = CCDirector:sharedDirector():getWinSize()
	local ruleText = require("bull/LayerDeskRule").getRuleText()
	self.m_roomRule=CCLabelTTF:create(ruleText, Resources.FONT_BLACK, Resources.FONT_SIZE24)
    self.m_roomRule:setPosition(ccp(winSize.width*0.5,winSize.height - 130))
    self.m_roomRule:setColor(ccc3(255, 255, 255))
    self:addChild(self.m_roomRule)
    self.m_roomRule:setVisible(true)
	
	--添加版本号
	local verText = require("bull/GameVersion").new().version
	self.verText=CCLabelTTF:create(verText, Resources.FONT_BLACK, 20)
	self.verText:setAnchorPoint(0,0)
    self.verText:setPosition(5,5)
    self.verText:setColor(ccc3(15,15,15))
    self:addChild(self.verText)
    self.verText:setVisible(true)
end

function DeskScene:addPrivateRoomNumUI()
    if self:getIsPrivateRoom() then
        local strJuShu = ""..self.curSet.."/"..self.totalSet

        local strRoomNum = "000000"
		if(FriendGameLogic.invite_code ~= nil) then
			strRoomNum = ""..FriendGameLogic.invite_code
		end
		if self.m_privateJuShuLabel ~= nil then
            self.m_privateJuShuLabel:setString(strJuShu)
		else
			self.m_privateJuShuLabel=CCLabelTTF:create(strJuShu, Resources.FONT_BLACK,23)
			self.m_privateJuShuLabel:setAnchorPoint(ccp(0,1))
			self.m_privateJuShuLabel:setPosition(ccp(637,655))
			self.m_privateJuShuLabel:setColor(ccc3(255, 255, 255))
			self:addChild(self.m_privateJuShuLabel,5)
		end
        if self.m_privatePoomNumLabel ~= nil then
            self.m_privatePoomNumLabel:setString(strRoomNum)
        else
		     self.m_privatePoomNumLabel=CCLabelTTF:create(strRoomNum, Resources.FONT_BLACK, 23)
			self.m_privatePoomNumLabel:setAnchorPoint(ccp(0,1))
			self.m_privatePoomNumLabel:setPosition(ccp(637,682))
			self.m_privatePoomNumLabel:setColor(ccc3(255, 255, 255))
			self:addChild(self.m_privatePoomNumLabel,5)
		end
    end
end

function DeskScene:showIsHaveEqualsIp()
	if(true) then return end
    if self.m_ipToastTextBgSp then
        return
    end
    local bIsHaveIp = false
    for nPos = 1,GameDefs.PLAYER_COUNT do
        local strIp = self.m_aclsPlayer[nPos]:getStrLocationIp()
        if strIp~="" then
            for i=nPos+1,GameDefs.PLAYER_COUNT do
                local strIp2 = self.m_aclsPlayer[i]:getStrLocationIp()
                if strIp2~="" and strIp == strIp2 then
                    self.m_aclsPlayer[nPos]:setIsToastIp(true)
                    self.m_aclsPlayer[i]:setIsToastIp(true)
                    bIsHaveIp = true
                end
            end
        end
    end

    if not bIsHaveIp then
        return
    end

    local winSize = CCDirector:sharedDirector():getWinSize()
    self.m_ipToastTextBgSp = loadSprite("bull/ipToastTextBg.png")
    local ipToastSpContentSize = self.m_ipToastTextBgSp:getContentSize()
    self.m_ipToastTextBgSp:setAnchorPoint(ccp(0.5,0))
    self.m_ipToastTextBgSp:setPosition(ccp(winSize.width/2,winSize.height*0.7))
    self:addChild(self.m_ipToastTextBgSp)

    local ipTextLabel  = CCLabelTTF:create("场内有玩家相同的IP地址请注意",Resources.FONT_BLACK,Resources.FONT_SIZE30)
    ipTextLabel:setAnchorPoint(ccp(0.5,0.5))
    ipTextLabel:setPosition(ccp(ipToastSpContentSize.width/2 + 10,ipToastSpContentSize.height/2))
    ipTextLabel:setDimensions(CCSize(ipToastSpContentSize.width-20, ipToastSpContentSize.height-20))
    ipTextLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
    self.m_ipToastTextBgSp:addChild(ipTextLabel)

    local function callback()
        self.m_ipToastTextBgSp:removeFromParentAndCleanup(true)
    end
    performWithDelay(self, callback, 5)
      
end

function DeskScene:popMessageSp(nType)
	cclog("popMessageSp")
end

function DeskScene:removeMessageSp(nType)
    if self:getChildByTag(DeskScene.POPMESSAGETAG) then
        self:getChildByTag(DeskScene.POPMESSAGETAG):removeFromParentAndCleanup(true)
    end
end
function DeskScene.getGameLib()
    return require("bull/GameLibSink").game_lib
end

function DeskScene:keyPadClick(strEvent)
    if "backClicked" == strEvent then
		if  not FriendGameLogic.game_abled == true then --游戏没开始才能返回大厅
			require("bull/GameLibSink"):returnToLobby()
		end
		
    elseif "menuClicked" == strEvent then
    end
end

function DeskScene:getMasterPos()
    local nBankerChair = 0
    if self.m_stSceneData then
        nBankerChair = self.m_stSceneData.cbBanker
    end
    return self:PosFromChair(nBankerChair)
end

function DeskScene:onTouchBegan(x,y)
    cclog("DeskScene:onTouchBegan(x,y)==")
    self.touchStartPoint = ccp(x,y)
    return true
end

function DeskScene:onMoved(x,y)
    
end

function DeskScene:onEnded(x,y)
    
end
--lsk add
function DeskScene.removeCache()
	--清除缓存资源
	Cache.removePlist({"emote","bull/images/bull"})
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("bull/images/card.plist")
    CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("bull/images/armature/kaishi/GameStar.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("bull/images/armature/tesupaixing/tesupaixing.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("bull/images/armature/win/SLTX_shuchu.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("bull/images/armature/touXiang/touxianTX.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("bull/images/armature/touxiangkuang/touxiangkuang.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("bull/images/armature/result/shegnlishibai.ExportJson")
end
function DeskScene:loadingCache()
    -- 加载游戏资源 应按从大到小顺序加载避免峰值过高
	Cache.add({"emote","bull/images/bull"})
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("bull/images/card.plist")
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("bull/images/armature/kaishi/GameStar.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("bull/images/armature/tesupaixing/tesupaixing.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("bull/images/armature/win/SLTX_shuchu.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("bull/images/armature/touXiang/touxianTX.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("bull/images/armature/touxiangkuang/touxiangkuang.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("bull/images/armature/result/shegnlishibai.ExportJson")
end
--显示解散倒计时
function DeskScene:addFriendTableTime(exprireTime, validTime) 
    if not FriendGameLogic.game_abled then
        self:clearFriendValidTimerUI()

        --尚未开始有效时间
        local tipbg =  loadSprite("lobby_message_tip_bg.png")
        tipbg:setPosition(ccp(AppConfig.SCREEN.CONFIG_WIDTH / 2, AppConfig.SCREEN.CONFIG_HEIGHT / 2 + 110)) 
        self:addChild(tipbg)--, self.voice_zIndex)   
        local bgsz = tipbg:getContentSize()

        local msgs, posy = {"30分钟未开始游戏，系统自动解散房间", string.format("%02d:%02d", 
                    math.floor(validTime % 86400 % 3600 / 60), validTime % 86400 % 3600 % 60)}, {bgsz.height / 2 + 26, bgsz.height / 2 - 26}
        local ftsz, tempLab = {26, 40}
        for i,v in ipairs(ftsz) do
            tempLab = CCLabelTTF:create(msgs[i], AppConfig.COLOR.FONT_ARIAL, v)
            tempLab:setPosition(ccp(bgsz.width / 2, posy[i]))
            tempLab:setDimensions(CCSizeMake(bgsz.width, 0))
            tempLab:setHorizontalAlignment(kCCTextAlignmentCenter)
            tipbg:addChild(tempLab)
        end 

        self.friendValid_timerBg = tipbg
        self.friendValid_timer = self:setTimerFunc(tempLab, "", validTime, function()
            if self.friendValid_timer ~= nil then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.friendValid_timer)
                self.friendValid_timer = nil       
            end
        end, 1)
    end
end
--解散倒计时回调
function DeskScene:setTimerFunc(labttf, msg, timeSeces, clearFunc, ctype)

    local pDirector, secesTimer = CCDirector:sharedDirector()
    local function timerFunc()
        if secesTimer == nil then
            return
        end

        local temp = "00:00:00"
        timeSeces = timeSeces - 1
        if timeSeces > 0 then
            temp = string.format("%02d:%02d:%02d", 
                math.floor(timeSeces % 86400 / 3600), math.floor(timeSeces % 86400 % 3600 / 60), timeSeces % 86400 % 3600 % 60)
        end
        if ctype then
            temp = string.sub(temp,4,-1)
        end
        labttf:setString(msg..temp)


        if timeSeces < 0 then
            clearFunc()
        end
    end
    secesTimer = pDirector:getScheduler():scheduleScriptFunc(timerFunc,1,false)
    return secesTimer
end
function DeskScene:clearFriendValidTimerUI()--清掉解散倒计时
    if self.friendValid_timerBg ~= nil then
        self.friendValid_timerBg:removeFromParentAndCleanup(true)
        self.friendValid_timerBg = nil       
    end
    if self.friendValid_timer ~= nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.friendValid_timer)
        self.friendValid_timer = nil       
    end

end
--好友桌规则数据
function DeskScene:onFriendRuleMessage(marstID, exprireTime, validTime)
    --local bInit = self.main_layer:initFriendGameUI() 
	cclog("onFriendRuleMessage")
	self.marstID = marstID	--房主ID
	self.bNotBanker = FriendGameLogic.my_rule[2][2]	== 2 --游戏类型 等于2是世界大战
	self.m_nGameType = FriendGameLogic.my_rule[2][2]--游戏类型
	self.realPlayerCnt = FriendGameLogic.my_rule[3][2] -- 开桌人数
	self.curSet = FriendGameLogic.game_used --当前局数
	self.totalSet = FriendGameLogic.my_rule[1][2] -- 总局数
	
	self.nMaxStake = FriendGameLogic.getRuleValueByIndex(4) -- 最大下注
	cclog("最大下注:"..self.nMaxStake)
	if self.m_gameButtonLayer then 
		self.m_gameButtonLayer:setMaxStake(self.nMaxStake)
	end
	
	
	self:clearFriendValidTimerUI()
    if not FriendGameLogic.game_abled and validTime and validTime > 0 then
        self:addFriendTableTime(exprireTime, validTime)
    end
	if(self.m_gameButtonLayer.inviteBtn ~= nil) then
		self.m_gameButtonLayer.inviteBtn:setVisible(not require("AppConfig").ISAPPLE and not FriendGameLogic.game_abled and FriendGameLogic.game_type == 0)
	end
	--游戏开始后禁用掉返回大厅的按钮
	if  FriendGameLogic.game_abled and self.m_gameButtonLayer.backHomeBtn ~= nil then
		self.m_gameButtonLayer.backHomeBtn:setEnabled(false)
	--	self.roomInfoBk:setPosition(ccp(15,705))
	end
	if not FriendGameLogic.game_abled then --游戏没开始的时候自动准备
		SendCMD.sendCMD_PO_RESTART()
	end
	self:addPrivateRoomNumUI()
	self:addRoomRuleLabel()
	--检查用户信息表是否有数据，有数据就更新
	--这里主要解决用户重进分数显示不对的问题
	 local userInfo = require("bull/GameLibSink").userInfoTable
	 cclog(#userInfo)
	 if userInfo ~= nil then
		for i,v in ipairs(userInfo) do
			self:updateUserInfo(v)
		end
	 end
	 require("bull/GameLibSink").userInfoTable = {}
	 
	 --更新用户数据end
end
function DeskScene:onFriendTableEndMessage(infoList)
	--游戏结算的信息
	local ccJson = require("CocosJson") --.decode(infoList[1].RuleScoreInfo)
	for i = 1,#infoList do
		infoList[i].RuleScoreInfo = ccJson.decode(infoList[i].RuleScoreInfo)
	end
	cclog("--------------------------------")
	tablePrint(infoList)
	
	if self.curSet == self.totalSet then  --正常结束
		self.totalScoreInfo = infoList	
	else
		local array = CCArray:create()
		array:addObject(CCDelayTime:create(2))
		array:addObject(CCCallFunc:create(function()
				self:showTotalSettle(true,infoList)
		end))
		self:runAction(CCSequence:create(array)) 
	end
end
--延时退出房间
function DeskScene:delayExitGame() 
    self:clearFriendValidTimerUI()
    local array = CCArray:create()
    array:addObject(CCDelayTime:create(2))
    array:addObject(CCCallFunc:create(function()
            require("bull/GameLibSink"):returnToLobby()
    end))
    self:runAction(CCSequence:create(array))  
end
function DeskScene:showChangeBankerTip()
	if self.m_nGameType == 3 or self.m_nGameType == 4 or self.m_nGameType == 5 then
		if self.lastBanker ~= nil and self.lastBanker ~= self.m_stSceneData.m_cbBanker then
			self.lastBanker = self.m_stSceneData.m_cbBanker --防止重复显示
			local userInfo = require("bull/GameLibSink").game_lib:getUserByChair(self.m_stSceneData.m_cbBanker)				
			if userInfo ~= nil then
				local tipMsg = {" 牛牛换庄"," 坐庄"," 牌大换庄"}
				local msg = "【"..userInfo._name.."】"..tipMsg[self.m_nGameType - 2]
				require("HallUtils").showWebTip(msg,nil,nil,ccp(640,520),2)					
			end
		end
	end
end
function DeskScene:getMyPanel()--在后台切换的时候回调用这个，不写回报错
	return nil
end
function DeskScene:getPlayerCount()
	local userList = DeskScene.getGameLib():getUserList()
	return #userList,self.realPlayerCnt
end
function DeskScene.createDeskLayer()
    local deskSceneLayer = DeskScene.new()
    if deskSceneLayer==nil then
        return nil
    end
    require("bull/GameLibSink").sDeskLayer = nil
    deskSceneLayer:init()
    return deskSceneLayer
end

function DeskScene.createDeskScene()
  local scene=CCScene:create()
  local layer = DeskScene.createDeskLayer()
  layer:setTag(Resources.DESK_SCENE_LAYER_TAG)
  scene:setTag(Resources.DESK_SCENE_TAG)
  scene:addChild(layer,-10)
  return scene
end

return  DeskScene