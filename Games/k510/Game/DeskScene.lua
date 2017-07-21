require("CocosAudioEngine")
require("CocosExtern")
require("FFSelftools/controltools")
local Common = require("k510/Game/Common")
local CommonInfo = require("k510/GameDefs").CommonInfo
local GameLogic = require("k510/Game/GameLogic")
local GameLibSink =require("k510/GameLibSink")
local Resources = require("k510/Resources")
local Player =require("k510/Game/Player")
local ShareFuns =require("k510/Game/Public/ShareFuns")
local ChatLayer = require("k510/Game/Public/ChatLayer")
local SetLayer = require("k510/Game/Public/SetLayer")
local ResultLayer = require("k510/Game/Public/ResultLayer")
local Particle = require("k510/Game/Public/Particle")
local UserDetailLayer = require("k510/Game/Public/UserDetailLayer")
local CountDownLayer = require("k510/Game/Public/CountDownLayer")
local ReplayLayer = require("k510/Game/Public/ReplayLayer")
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")
local SetLogic = require("Lobby/Set/SetLogic")
local EventDispatcher = require("GameLib/common/EventDispatcher")
local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
local BombStatus = {Common.BOMB_STATUS.BombStatus_Quadruple,Common.BOMB_STATUS.BombStatus_QuadrupleOne}
local StraightMax = {Common.STRAIGHT_MAX.StraightMax_KKAA,Common.STRAIGHT_MAX.StraightMax_AA22}

local DeskScene = class("DeskScene",function()
     return CCLayer:create()
end)

local winSize = CCSizeMake(CommonInfo.View_Width, CommonInfo.View_Height)

DeskScene._PlayerVec = {}

DeskScene.menuItemTag = 
{
    ReadyItemTag = 0,       --准备
    TipItemTag = 1,         --提示
    OutItemTag = 2,         --出牌
    HuifuItemTag = 3,       --恢复
    leaveRoomItemTag = 4,   --离开房间按钮
    setItemTag = 5,         --设置按钮
    dissolveItemTag = 6,    --解散房间按钮
    inviteItemTag = 7,      --邀请好友按钮
	NoOutItemTag = 8,		--不要
	ReplyYesItemTag = 9,	--打
	ReplyNoItemTag = 10,	--不打
    qie0  = 20,             --选择不切按钮
    qie1  = 21,             --选择切牌按钮
}

DeskScene.menuItemShowTag = 
{
    HideALL = -1,    --全部隐藏
    ShowOut = 0,     --显示操作按钮
    HideOut = -1,    --隐藏操作按钮
	ShowReply = 4,	 --显示问询答复按钮
    ShowQie = 5,     --显示切牌选择按钮
}

function DeskScene.create()
	local layer = DeskScene.new()
	layer:init()
	return layer
end

-- 点击开始响应
function DeskScene:onTouchBegan(x,y)
    self._startPoint = ccp(x,y)

    if GameLogic.myChair  ~= -1 then
        self._PlayerVec[GameLogic:ServerToClientSeat(GameLogic.myChair) + 1]:onTouchBegan(x,y)
    end
end

-- 移动响应
function DeskScene:onTouchMoved(x,y)
    Particle:CreateParticleTailing(self , 8 , ccp(x,y) , "k510/images/paticle.png")
    if GameLogic.myChair ~= -1 then
        self._PlayerVec[GameLogic:ServerToClientSeat(GameLogic.myChair) + 1]:onTouchMoved(x,y)
    end
end

-- 点击结束响应
function DeskScene:onTouchEnded(x,y)
    if GameLogic.myChair ~= -1 then
        self._PlayerVec[GameLogic:ServerToClientSeat(GameLogic.myChair) + 1]:onTouchEnded(x,y)
    end

    --判断是不是点在了
    for i = 1,#self._PlayerVec do
        self._PlayerVec[i]:onTouchHead(x,y)
        -- 测试动画 suitDoubleStraight suitTriAndTwo suitStraight suitBomb suitPlane suitFourAndThree
        -- self._PlayerVec[i]:playCardTypeAction(Common.SUIT_TYPE.suitTriAndTwo)
    end
    
    -- 测试单局结算
    -- self:showResultLayer()
    --[[ 测试总结算
    self:showEndResultLayer({
        [1] = {Changed = 0,FaceID = 0,RuleScoreInfo = "{\"BB\":0,\"LN\":1,\"SS\":0,\"TS\":-7,\"WN\":1,\"PS\":0}",Score = -7,Sex = 1,UserID = 10687,UserNickName = "游客",},
        [2] = {Changed = 0,FaceID = 0,RuleScoreInfo = "{\"BB\":0,\"LN\":2,\"SS\":0,\"TS\":-15,\"WN\":0,\"PS\":0}",Score = -15,Sex = 1,UserID = 10194,UserNickName = "游客",},
        [3] = {Changed = 0,FaceID = 0,RuleScoreInfo = "{\"BB\":1,\"LN\":1,\"SS\":17,\"TS\":22,\"WN\":1,\"PS\":10}",Score = 22,Sex = 0,UserID = 10776,UserNickName = "游客",},
    }) 
    -- ]]
    return false
end

-- 创建桌面
function DeskScene:init()			 
    self.isOutCard = false --表示这一轮已经出过牌了
    self.winSize = CCSizeMake(require("k510/GameDefs").CommonInfo.View_Width, require("k510/GameDefs").CommonInfo.View_Height)
    self.PlaySoundTimerId = -1
    self.unschedulerAutoId = -1
    self.unschedulerDelayGameEndId = -1
    self.unschedulerDelayShowHandsId = -1
    --排序类型
    self.cardSortWay = Common.CardSortWay.SORT_VALUE
    
    --我手牌中所有的同花顺
    self.MyAllFlushCardArray = {}
    --上一次提示的同花顺牌的索引
    self.lastFlushTipCardIndex = 0

    --上一次提示的牌
    self.lastTipCard = Common:newMyOutCard()

    local function onTouch(eventType ,x ,y)
      if eventType=="began" then
            self:onTouchBegan(x,y)
            return true
      elseif eventType=="moved" then
            self:onTouchMoved(x,y)
      elseif eventType=="ended" then
            self:onTouchEnded(x,y)
      end
    end

    self:setTouchEnabled(true)
    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,true)

    local function onMenuCallback(tag, pSender)
        if tag == self.menuItemTag.ReadyItemTag then        --准备
            GameLogic:sendStartMsg("ReadyItemTag")
        elseif tag == self.menuItemTag.TipItemTag then      --提示
            self:menuCardsTipsCallBack()
		elseif tag == self.menuItemTag.NoOutItemTag then	--不要
			self:setOutCardTip(2)
			self:menuUnOutCardsCallBack()
        elseif tag == self.menuItemTag.OutItemTag then      --出牌
             self:menuOutCardsCallBack()
        elseif tag == self.menuItemTag.HuifuItemTag then    --恢复
           self:menuHuiFuCallBack()
        elseif tag == self.menuItemTag.inviteItemTag then   --邀请好友
           self:menuInviteCallBack()
        elseif tag == self.menuItemTag.qie0 then            --选择不切牌
           GameLogic:sendQie(0)
           self:ControlBtn(self.menuItemShowTag.HideALL)
        elseif tag == self.menuItemTag.qie1 then            --选择切牌
           GameLogic:sendQie(1)
           self:ControlBtn(self.menuItemShowTag.HideALL)
		elseif tag == self.menuItemTag.ReplyYesItemTag then
			GameLogic:sendAskPlayerReplay(1)
			self:ControlBtn(self.menuItemShowTag.HideALL)
		elseif tag == self.menuItemTag.ReplyNoItemTag then 
			GameLogic:sendAskPlayerReplay(0)
			self:ControlBtn(self.menuItemShowTag.HideALL)
        end 
    end
    
    GameLogic.loadingCache()

    --界面绘制
    --背景
    local bg = loadSprite(Resources.Img_Path.."deskbg.jpg")
    self:addChild(bg)
    bg:setScale(1.25)
    bg:setPosition(ccp(self.winSize.width/2,self.winSize.height/2))
    
    --房号文字
    self.roomNoTextLabel = CCLabelTTF:create("房间号: ","Arial",30,CCSizeMake(0,0),kCCVerticalTextAlignmentCenter,kCCTextAlignmentCenter)
    self.roomNoTextLabel:setAnchorPoint(0,0.5)
    self.roomNoTextLabel:setColor(ccc3(234,255,254))
    self.roomNoTextLabel:setPosition(ccp(462, self.winSize.height - 60))
    self:addChild(self.roomNoTextLabel)

    --局数文字
    self.jushuLabel = CCLabelTTF:create("局 数：0/0","Arial",30,CCSizeMake(0,0),kCCVerticalTextAlignmentCenter,kCCTextAlignmentCenter)
    self.jushuLabel:setAnchorPoint(0,0.5)
    self.jushuLabel:setColor(ccc3(234,255,254))
    self.jushuLabel:setPosition(ccp(self.winSize.width/2 + 40, self.winSize.height - 60))
    self:addChild(self.jushuLabel)

    --规则文字
    self.ruleLabel = CCLabelTTF:create("","Arial",24,CCSizeMake(480,0),kCCVerticalTextAlignmentCenter,kCCTextAlignmentCenter);
    self.ruleLabel:setAnchorPoint(0.5,1)
    self.ruleLabel:setPosition(ccp(self.winSize.width/2, self.winSize.height - 110))
    self.ruleLabel:setColor(ccc3(255,255,255))
    self:addChild(self.ruleLabel)

    -- 实时信息
    self.realtimeInfoPanel = require(CommonInfo.Code_Path.."Game/LayerRealtimeInfo").create()
    self.realtimeInfoPanel:setPosition(self.winSize.width/2 - 50, self.winSize.height - 16)
    self:addChild(self.realtimeInfoPanel)
    
    -- 版本号
    self.versionlab = CCLabelTTF:create(tostring(require("GameConfig").getGameConfig("k510").version), AppConfig.COLOR.FONT_ARIAL, 16)      
    self.versionlab:setPosition(ccp(12, 12))
    self.versionlab:setAnchorPoint(0, 0.5)
    self.versionlab:setOpacity(150)
    self:addChild(self.versionlab)

    --设置等系列操作按钮
    --退出
    self.leaveRoomBtn = CCButton.createWithFrame("ui/leaveroombtn.png",false,function()
        GameLibSink:onLeaveGame()
    end)
    self:addChild(self.leaveRoomBtn)
	self.leaveRoomBtn:setScale(1.2)
    self.leaveRoomBtn:setPosition(ccp(55, self.winSize.height - 50))
    
    --定位
	self.locationBtn = CCButton.createWithFrame("ui/loc.png",false,function()
		GameLogic:showLocation()
	end)
	local animFrames = CCArray:create()
	for i = 1,6 do
		local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(
			string.format("ui/loc%d.png", i))
		animFrames:addObject(frame)
	end
	local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.1)
	local animate = CCAnimate:create(animation);
	self.locationBtn.m_normalSp:runAction(CCRepeatForever:create(animate))
	self:addChild(self.locationBtn)
	self.locationBtn:setScale(1.2)
	self.locationBtn:setPosition(ccp(420, self.winSize.height - 50))

    --设置
    self.setBtn = CCButton.createWithFrame("ui/setbtn.png",false,function()
        SetLayer.create(self, 1):show()
    end)
    self:addChild(self.setBtn)
	self.setBtn:setScale(1.2)
    self.setBtn:setPosition(ccp(self.winSize.width - 250, self.winSize.height - 50))
	self.setBtn:setVisible(false)

    --解散房间
    local f = require("Lobby/FriendGame/FriendGameLogic")
    self.dissolveroomBtn = CCButton.createWithFrame("ui/dissolveroombtn.png",false,function()
        if (f.game_used > 0) or (GameLibSink.game_lib:getMyDBID() == GameLogic.openTableUserid) then
            f.showDismissTipDlg(self,0,GameLibSink)
        else
            require("HallUtils").showWebTip("游戏未开始时，非房主不能解散房间")
            cclog("GameLogic.gamePhase: "..GameLogic.gamePhase)
        end
    end)
    self:addChild(self.dissolveroomBtn)
	self.dissolveroomBtn:setScale(1.2)
    self.dissolveroomBtn:setPosition(ccp(self.winSize.width - 170, self.winSize.height - 50))
    self.dissolveroomBtn:setVisible(false)
	
	--规则
    self.ruleBtn = CCButton.createWithFrame("ui/btn_rule.png",false,function()
        if not self.rule_panel then
        self.rule_panel = require("k510/LayerGameRule").put(self,100)
    end

    self.rule_panel:show()
    end)
    self:addChild(self.ruleBtn)
	self.ruleBtn:setScale(1.2)
    self.ruleBtn:setPosition(ccp(self.winSize.width - 330, self.winSize.height - 50))
	self.ruleBtn:setVisible(false)
	
	--更多
	self.moreBtn = CCButton.createWithFrame("ui/btn_more1.png",false,function()
        if self.setBtn:isVisible() then
			self.setBtn:setVisible(false)
			self.dissolveroomBtn:setVisible(false)
			self.ruleBtn:setVisible(false)
		else
			self.setBtn:setVisible(true)
			self.dissolveroomBtn:setVisible(true)
			self.ruleBtn:setVisible(true)
		end
    end)
    self:addChild(self.moreBtn)
    self.moreBtn:setPosition(ccp(870, self.winSize.height - 50))
	self.moreBtn:setScale(1.2)
    --设置等系列操作按钮结束

    --3个玩家
    self._PlayerVec = {}
	local t = {1,3,2}
    for i=1,3 do
        local player = Player:create( t[i] - 1 )
        self:addChild(player)
        player:setVisible(false)
        player:setChairIndex(t[i]-1)
		self._PlayerVec[t[i]] = player
        --table.insert(self._PlayerVec,player)
    end
    
    -- 切牌状态
    self.animateQie = CCLayer:create()
    self.animateQie:setVisible(false)
    local tipQie = loadSprite("ui/qieing.png")
    self.animateQie:addChild(tipQie)
    self:addChild(self.animateQie)
    
    -- 切牌省略号动画
    local function setPoint(sender)
        sender:setVisible(not sender:isVisible())
    end
    for i = 1, 3 do
        local spPoint = loadSprite("ui/point.png")
        spPoint:setPosition(ccp(60+i*22, -16))
        spPoint:setVisible(false)
        self.animateQie:addChild(spPoint)
        local arr = CCArray:create()
        arr:addObject(CCDelayTime:create(i*0.5))
        arr:addObject(CCCallFuncN:create(setPoint))
        arr:addObject(CCDelayTime:create(2.5-i*0.5))
        arr:addObject(CCCallFuncN:create(setPoint))
        spPoint:runAction(CCRepeatForever:create(CCSequence:create(arr)))
    end

    --邀请好友按钮
    self.inviteMenuItem = CCMenuItemSprite:create(loadSprite("ui/invitebtn0.png"),loadSprite("ui/invitebtn1.png"),nil)
    self.inviteMenuItem:setTag(self.menuItemTag.inviteItemTag)
    self.inviteMenuItem:setPosition(self.winSize.width/2,120)
    
    -- 不切牌按钮
    self.Qie0MenuItem = CCMenuItemSprite:create(loadSprite("ui/btn_nocut1.png"),loadSprite("ui/btn_nocut2.png"),nil)
    self.Qie0MenuItem:setTag(self.menuItemTag.qie0)
    self.Qie0MenuItem:setPosition(self.winSize.width/2 - 90,280)
    
    -- 切牌按钮
    self.QieMenuItem = CCMenuItemSprite:create(loadSprite("ui/btn_cut1.png"),loadSprite("ui/btn_cut2.png"),nil)
    self.QieMenuItem:setTag(self.menuItemTag.qie1)
    self.QieMenuItem:setPosition(self.winSize.width/2 + 90,280)

    self.cutBkg = loadSprite("ui/bkg_cut.png")
    self:addChild(self.cutBkg)
    self.cutBkg:setPosition(ccp(self.winSize.width/2,277))
 
	-- 询问按钮和label
	--标题
	self.tip_lab = CCLabelTTF:create("", AppConfig.COLOR.FONT_ARIAL, 35)
	self.tip_lab:setColor(ccc3(255, 255, 255))
	self.tip_lab:setPosition(ccp(self.winSize.width / 2, 370))
	self.tip_lab:setHorizontalAlignment(kCCTextAlignmentCenter)
	self:addChild(self.tip_lab)
		
	--是按钮 
	self.YesMenuItem = CCMenuItemSprite:create(loadSprite("ui/btn_agree1.png"),loadSprite("ui/btn_agree1.png"),nil)
    self.YesMenuItem:setTag(self.menuItemTag.ReplyYesItemTag)
    self.YesMenuItem:setPosition(self.winSize.width/2 + 90,280)
			
	--否按钮
	self.NoMenuItem = CCMenuItemSprite:create(loadSprite("ui/btn_refuse1.png"),loadSprite("ui/btn_refuse1.png"),nil)
    self.NoMenuItem:setTag(self.menuItemTag.ReplyNoItemTag)
    self.NoMenuItem:setPosition(self.winSize.width/2 - 90,280)
	
	self.replyBkg = loadSprite("ui/bkg_cut.png")
    self:addChild(self.replyBkg)
    self.replyBkg:setPosition(ccp(self.winSize.width/2,277))
	
    -- 提示按钮
    self.tipMenuItem = CCMenuItemSprite:create(loadSprite("ui/btn_tip.png"),nil,nil)
    self.tipMenuItem:setTag(self.menuItemTag.TipItemTag)
    self.tipMenuItem:setPosition(self.winSize.width/2,280)

	-- 不要按钮
    self.notOutMenuItem = CCMenuItemSprite:create(loadSprite("ui/btn_noout1.png"),loadSprite("ui/btn_noout2.png"),loadSprite("ui/btn_noout3.png"))
    self.notOutMenuItem:setTag(self.menuItemTag.NoOutItemTag)
    self.notOutMenuItem:setPosition(self.winSize.width/2 - 260,280)
	
    -- 出牌按钮
    self.outMenuItem = CCMenuItemSprite:create(loadSprite("ui/btn_outcard1.png"),loadSprite("ui/btn_outcard2.png"),loadSprite("ui/btn_outcard3.png"))
    self.outMenuItem:setTag(self.menuItemTag.OutItemTag)
    self.outMenuItem:setPosition(self.winSize.width/2 + 260,280)

    array = CCArray:create()
  	array:addObject(self.tipMenuItem)
    array:addObject(self.outMenuItem)
    array:addObject(self.inviteMenuItem)
    array:addObject(self.Qie0MenuItem)
    array:addObject(self.QieMenuItem)
	array:addObject(self.notOutMenuItem)
	array:addObject(self.YesMenuItem)
	array:addObject(self.NoMenuItem)

    self.tipMenuItem:registerScriptTapHandler(onMenuCallback)
    self.outMenuItem:registerScriptTapHandler(onMenuCallback)
    self.inviteMenuItem:registerScriptTapHandler(onMenuCallback)
    self.Qie0MenuItem:registerScriptTapHandler(onMenuCallback)
    self.QieMenuItem:registerScriptTapHandler(onMenuCallback)
	self.notOutMenuItem:registerScriptTapHandler(onMenuCallback)
	self.YesMenuItem:registerScriptTapHandler(onMenuCallback)
	self.NoMenuItem:registerScriptTapHandler(onMenuCallback)

	menu = CCMenu:createWithArray(array)
	self:addChild(menu)
	menu:setPosition(ccp(0,0))
    menu:setTouchEnabled(true)
    
    --- 操作按钮系列结束
    
    --等待倒计时窗
    self.countDownLayer = CountDownLayer.create()
    self:addChild(self.countDownLayer)
    self.countDownLayer:hide()

    --玩家信息框
    self.userDetails = UserDetailLayer.create()
    self:addChild(self.userDetails)
    self.userDetails:hide()

    -- 聊天按钮
    self.chatBtn = CCButton.createWithFrame("ui/weixinbtn.png",false,function()
       self.chatLayer:show()
    end)
    self:addChild(self.chatBtn)
    self.chatBtn:setPosition(ccp(self.winSize.width - 55,180))
	self.chatBtn:setScale(1.2)
    
    -- 语聊按钮
    self.voicePanel = require(CommonInfo.Code_Path.."Game/LayerVoice").create()
    self:addChild(self.voicePanel)

    --聊天框
    self.chatLayer = ChatLayer.create()
    self:addChild(self.chatLayer)
    self.chatLayer:hide()

    --结果
    self.resultLayer = ResultLayer.create()
    self:addChild(self.resultLayer,10)
    self.resultLayer:hide()
	
	--问询框
	self.askPlayerLabel = CCLabelTTF:create("", "Arial", 30)
    self.askPlayerLabel:setAnchorPoint(ccp(0.5,0.5))
	
	local winsize=CCDirector:sharedDirector():getWinSize()
    self.askPlayerBg = CCLayerColor:create(ccc4(0,0,0,100),200,40)
    pos = ccp(winsize.width / 2, winsize.height / 2)
    self.askPlayerBg:setPosition(pos)
    self.askPlayerBg:setAnchorPoint(ccp(0.5,0.5))
    self.askPlayerLabel:setPosition(ccp(self.askPlayerBg:getContentSize().width*0.5,self.askPlayerBg:getContentSize().height*0.5))
    
    self.askPlayerBg:addChild(self.askPlayerLabel)
    self:addChild(self.askPlayerBg)
	self.askPlayerBg:setVisible(false)
  
    self:setKeypadEnabled(true)
	
	self.noOutCardTip = loadSprite("ui/noOutCardTip.png");
	self.noOutCardTip:setPosition(ccp(self.winSize.width/2,40))
	self.noOutCardTip:setVisible(false)
	self:addChild(self.noOutCardTip,1)

    local function KeypadHandler(strEvent)
        if "backClicked" == strEvent then
            if self.chatLayer:isVisible() then
                self.chatLayer:hide()
                return
            end
        end
    end

    self:registerScriptKeypadHandler(KeypadHandler)

    local function RecvTableChat(arg)
        self:onRecvTableChat(arg.chat)
    end

    local function RecvDissolveRoom(args)
        GameLogic:sendDissolveRoom(args.flag)
    end

    local function RecvLeaveRoom(args)
        GameLogic:sendLeaveMsg()
    end

    local function RecvDeskRule(args)
        self:setRoomInfo()
        self:updateDeskInfo()
    end

    local function RecvShowUserDetails(args)
       local chair = args.chair
       local userInfo = GameLogic.userlist[GameLogic:ClientToServerSeat(chair) + 1]
       if userInfo ~= nil then
          self.userDetails:setUserInfo(userInfo)
       end
    end

    self:ControlBtn(self.menuItemShowTag.HideALL)

    if GameLibSink.game_lib and GameLibSink.game_lib:getMyself() then
        local function onNodeEvent(event)
            if event =="enter" then
                EventDispatcher:instance():addEvent(Resources.NOTIFICATION_RECEIVETABLECHAT,RecvTableChat)
                EventDispatcher:instance():addEvent(Resources.NOTIFYCATION_DISSOLVEROOM,RecvDissolveRoom)
                EventDispatcher:instance():addEvent(Resources.NOTIFYCATION_LEAVEROOM,RecvLeaveRoom)
                EventDispatcher:instance():addEvent(Resources.NOTIFYCATION_SHOWUSERDETAILS,RecvShowUserDetails)
                EventDispatcher:instance():addEvent(Resources.NOTIFYCATION_DESKRULE,RecvDeskRule)
                self:setRoomInfo()
                self:updateDeskInfo("enter event")
                SetLogic.playGameGroundMusic("k510/sound/room_music.mp3")
            elseif event =="exit" then
                EventDispatcher:instance():removeEvent(Resources.NOTIFICATION_RECEIVETABLECHAT,RecvTableChat)
                EventDispatcher:instance():removeEvent(Resources.NOTIFYCATION_DISSOLVEROOMBYME,RecvDissolveRoom)
                EventDispatcher:instance():removeEvent(Resources.NOTIFYCATION_LEAVEROOM,RecvLeaveRoom)
                EventDispatcher:instance():removeEvent(Resources.NOTIFYCATION_SHOWUSERDETAILS,RecvShowUserDetails)
                EventDispatcher:instance():removeEvent(Resources.NOTIFYCATION_DESKRULE,RecvDeskRule)
                self:resetTipCard(self.lastTipCard)
                require("k510/Game/GameLogic"):setStaySceneName("",nil)
                self:onExit()
            end        
        end
        
        self:registerScriptHandler(onNodeEvent)

        self:updateDeskInfo("init event")
    end

    local t = C2dxEx:getTickCount()
    --cc2file("[%s] 创建房间完成, 耗时 -> %s秒", t, tostring((t-ccTimeStart)/1000))
end

-- 刷新房间信息
function DeskScene:setRoomInfo()
    local f = require("Lobby/FriendGame/FriendGameLogic")
    local currentRule, invite_code, game_used = f.my_rule, f.invite_code, f.game_used
    
    if #currentRule > 0 then
        local msg = ""
		if currentRule[2] then
			if currentRule[2][2] == 1 then
				msg = msg.."炸弹牌型:四张，"
			else 
				msg = msg.."炸弹牌型:四带一，"
			end
		end
		
        if currentRule[3] then
			if currentRule[3][2] == 1 then
				msg = msg.."连对KKAA最大，"
			else
				msg = msg.."连对AA22最大，"
			end
        end
        if currentRule[4] then
			if currentRule[4][2] == 0 then
				msg = msg.."不显示牌数，"
			else
				msg = msg.."显示牌数，"
			end
        end
        if currentRule[5] then
			if currentRule[5][2] == 0 then
				msg = msg.."不可切牌"
			else
				msg = msg.."可切牌"
			end
        end

        self.ruleLabel:setString(msg)
        if invite_code then
            self.roomNoTextLabel:setString(string.format("房间号: %d", invite_code))
        end
        if game_used then
            self.jushuLabel:setString(string.format("局 数: %d/%d", game_used, currentRule[1][2]))
        end
    end
end

-- 刷新回放时房间信息显示
function DeskScene:setReplayRoomInfo(data)
    self.replayData = data
    self.replayIndex = 0
    local f = require("Lobby/FriendGame/FriendGameLogic")
    local cfg = data.Opening
    f.game_used = 1
    f.invite_code = 0
    f.my_rule = {
        {1,1},{2,cfg.BS},{3,cfg.SM},{4,cfg.SC},{5,0},{6,0},{7,0},{8,0}
    }
    -- 屏蔽相关按钮和界面
    self.setBtn:setVisible(false)
    self.leaveRoomBtn:setVisible(false)
    self.locationBtn:setVisible(false)
    self.dissolveroomBtn:setVisible(false)
    self.chatBtn:setVisible(false)
	self.moreBtn:setVisible(false)
    self.inviteMenuItem:setVisible(false)
    self.realtimeInfoPanel:setVisible(false)
    self.roomNoTextLabel:setVisible(false)
    self:setRoomInfo()
    self.jushuLabel:setString(string.format("五十K牌局回放\n进度:%02d/%02d", 0, data.Action.ActN))
    self.jushuLabel:setPosition(ccp(self.winSize.width/2-100,self.winSize.height-32))
    self.jushuLabel:setColor(ccc3(255,255,255))
    
    -- 设置结算界面
    local rLayer = self.resultLayer
    rLayer.singleResultLayer:setVisible(true)
    rLayer.endResultLayer:setVisible(false)
    local infoLabel = rLayer.singlePlayerInfo
	local c = CCSpriteFrameCache:sharedSpriteFrameCache()
    for i = 1, 3 do
        local u, v = data.Opening.UL[i], data.Ending.GSL[i]
        infoLabel[i].nameLabel:setString(u.UN)
        --infoLabel[i].offCardseLabel:setString(string.format("%d",v[2]))
        infoLabel[i].scoreLabel:setString(string.format("%d",v[1]))
		if v[1] > 0 then
				infoLabel[i].Mark:setDisplayFrame(c:spriteFrameByName("ui/title_win.png"))
			-- 平
			elseif v.nSetScore == 0 then
				infoLabel[i].Mark:setDisplayFrame(c:spriteFrameByName("ui/title_draw.png"))
			-- 失败
			else
				infoLabel[i].Mark:setDisplayFrame(c:spriteFrameByName("ui/title_lose.png"))
		end 
		
		local userinfo = data.Opening.UL[i]
		local headSp
		local faceSize = CCSizeMake(105,105)
		if userinfo then
			headSp = require("FFSelftools/CCUserFace").create(userinfo.DB, faceSize, userinfo.SX)
		else
			headSp = require("FFSelftools/CCUserFace").createDefault(_,faceSize)
		end
		headSp:setPosition(ccp(83,210))
		infoLabel[i].bg:addChild(headSp)
    end
    
    -- 设置玩家数据
    for i = 0, 2, 1 do
        local p = self._PlayerVec[i+1]
        p:UpdatePos(i, true)
        p:UpdateReplayInfo(i, data.Opening.UL[i+1], Common.GAME_PHRASE.enGame_InitData)
        if i == data.Opening.DD then p._IconZhuangSp:setVisible(true) end
        p:Show()
    end
    
	local msg = data.Asking.reply1 == 1 and "玩家[%s] 同意与玩家[%s] 对战" or "玩家[%s] 拒绝与玩家[%s] 对战"
	local userInfo1Name = data.Opening.UL[data.Opening.BC + 1].UN
	local userInfo2Name = data.Opening.UL[data.Opening.DD + 1].UN
	if userInfo1Name and userInfo2Name then
		require("HallUtils").showWebTip(string.format(msg, userInfo1Name, userInfo2Name),self,nil,nil,1.5)
	end
	
	local function createReplayLayer()
		for i = 0, 2, 1 do
			local p = self._PlayerVec[i+1]
			if i == data.Asking.NJP then
				p:SetCardUnTouch()
			end
		end
		-- 回放控制器
		self.replayLayer = ReplayLayer.create()
		self.replayLayer.interval = 2   -- 间隔2秒
		self.replayLayer.timer = 0
		self.replayLayer.isPlaying = true
		self:addChild(self.replayLayer,11)
		self.unschedulerReplayId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
			self.replayOnStep(self)
		end, 0.2, false)
	end
	
	local function showReply2()
		local msg = data.Asking.reply2 == 1 and "玩家[%s] 同意与玩家[%s] 对战" or "玩家[%s] 拒绝与玩家[%s] 对战"
		local userInfo1Name = data.Opening.UL[data.Opening.CC + 1].UN
		local userInfo2Name = data.Asking.reply1 == 1 and data.Opening.UL[data.Opening.BC + 1].UN or data.Opening.UL[data.Opening.DD + 1].UN
		if userInfo1Name and userInfo2Name then
			require("HallUtils").showWebTip(string.format(msg, userInfo1Name, userInfo2Name),self,nil,nil,1.5)
		end
	end
	
	local actionArray=CCArray:create()
    actionArray:addObject(CCDelayTime:create(2))
    actionArray:addObject(CCCallFuncN:create(showReply2))
    actionArray:addObject(CCDelayTime:create(2))
	actionArray:addObject(CCCallFuncN:create(createReplayLayer))
	
	self:runAction(CCSequence:create(actionArray));
end

-- 回放执行动作
function DeskScene.replayOnStep(layer, force)
    -- 如果没有暂停
    local replayer = layer.replayLayer
    if replayer.isPlaying or force then
        replayer.timer = replayer.timer + 0.2
        if replayer.timer >= replayer.interval then
            local data, idx = layer.replayData, layer.replayIndex
            local s = data.Action[string.format("NO.%d", idx)]
            
            -- 打牌阶段
            if idx < data.Action.ActN and s then
                layer.jushuLabel:setString(string.format("五十K牌局回放\n进度:%02d/%02d", idx+1, data.Action.ActN))
                local chair = s.AD--(data.Action.ActN - idx == 1) and s.AD or (s.AD == 2 and 0 or (s.AD+1))
                layer._PlayerVec[chair+1]:UpdateReplayInfo(chair, s, Common.GAME_PHRASE.enGame_OutCard)
                if s.OCD and #s.OCD > 0 then
                    if s.RD == 1 then
                        for i = 1, 3 do
                            local p = layer._PlayerVec[i]
                            p:setPlayerStatus(p.StatusShow.Show_Hide)
                        end
                    end
                    AudioEngine.playEffect(DeskScene.GetSoundByCommand(
                        layer, layer._PlayerVec[chair+1]._sex, s.ST, s.OCD[1]%13
                    ))
                else
                    AudioEngine.playEffect(DeskScene.GetSoundByCommand(
                        layer, layer._PlayerVec[chair+1]._sex, 0, 0
                    ))
                end
                layer.replayIndex = layer.replayIndex + 1
                
            -- 结算阶段
            else
                cclog("replay is over!")
                layer.resultLayer:setVisible(true)
                replayer.isPlaying = false
                replayer.game_stop:setVisible(false)
                replayer.game_play:setVisible(true)
            end
            layer.replayLayer.timer = 0
        end
    end
end

-- 回放动作
function DeskScene.replayStepBack(layer)
    local data, idx = layer.replayData, layer.replayIndex
    if idx > 1 then
        layer.replayLayer.timer = 0
        layer.resultLayer:setVisible(false)
        -- 回退前两步
        for i = 1, 2 do
            layer.replayIndex = layer.replayIndex - 1
            idx = layer.replayIndex
            layer.jushuLabel:setString(string.format("五十K牌局回放\n进度:%02d/%02d", idx+1, data.Action.ActN))
            local s = data.Action[string.format("NO.%d", idx)]
            local chair = s.AD--(data.Action.ActN - idx == 1) and s.AD or (s.AD == 2 and 0 or (s.AD + 1))
            if s.OCD and #s.OCD > 0 then
                local handCard = ShareFuns.Copy(
                    layer._PlayerVec[chair+1]._PlayCards._playerCardsValueLst)
                for k, v in pairs(s.OCD) do
                    table.insert(handCard, v)
                end
                layer._PlayerVec[chair+1]:UpdateReplayInfo(
                    chair, {HCL = ShareFuns.SortCards(handCard)}, Common.GAME_PHRASE.enGame_Replay)
            else
                layer._PlayerVec[chair+1]:UpdateReplayInfo(
                    chair, s, Common.GAME_PHRASE.enGame_Replay)
            end
        end
    end
end

function DeskScene:onRecvTableChat(chat)
    local chatChair = -1
    local gameLib = require("k510/GameLibSink").game_lib
    local tableUser = gameLib:getUser((chat._dwSpeaker % 0x10000))
    if (tableUser == nil) then
        return            --//无此用户
    end
    --//取出椅子号
    local iChair = tableUser:getUserChair()
    if (Resources.Pub_IsValidChair(iChair) == false) then
        return            --//非法椅子号
    end

    local sysHead = "--:"
    local vipHead = "v--:"
    local speakContent = chat:getChatMsg()
    local szHead = string.sub(speakContent, 1, 3)
    local szHead2 = string.sub(speakContent, 1, 4)
    local szContent = split(speakContent, "|")
    if szHead == sysHead then
        --系统表情
        self._PlayerVec[GameLogic:ServerToClientSeat(iChair) + 1]:setEmoShow(string.sub(speakContent, 4))
    elseif szHead2 == vipHead then
        --VIP表情
    elseif szContent[1] == "@QUICK" and YVIMTool._inst then
        local lan_set = AppConfig.language[SetLogic.getGameCheckByIndex(3)]
        local quickChatCfg = AppConfig.quickChat[lan_set]
        local content = quickChatCfg[tonumber(szContent[2])]
        self._PlayerVec[GameLogic:ServerToClientSeat(iChair) + 1]:setWordFrameShow(content)
        self.chatLayer:resetChatMsg(tableUser:getUserName()..string.format(":%s",content))
    elseif szContent[1] == "@VOICE" and YVIMTool._inst then
        local c = GameLogic:ServerToClientSeat(iChair)
        table.insert(YVIMTool._inst.recordList,{
            player = self._PlayerVec[c + 1],
            chair = c,
            url = szContent[2]
        })
    else
        --文字
        self._PlayerVec[GameLogic:ServerToClientSeat(iChair) + 1]:setWordFrameShow(speakContent)
        self.chatLayer:resetChatMsg(tableUser:getUserName()..string.format(":%s",speakContent))
    end
end 

--设置时间
function DeskScene:setTime(hour,min)
   self.timeLabel:setString(string.format("%02d:%02d",hour,min))
end

function DeskScene:onExit()
   CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.unschedulerAutoId)
   CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.PlaySoundTimerId)
   CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.unschedulerDelayGameEndId)
   CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.unschedulerDelayShowHandsId)
   self._DeskScene = nil
   self._PlayerVec = {}
   GameLogic:clearGameLogic()
end

function DeskScene.createScene()
  local scene=CCScene:create()
  local layer = DeskScene.create()
  layer:setTag(Resources.Tag.DESK_SCENE_LAYER_TAG)
  scene:setTag(Resources.Tag.DESK_SCENE_TAG)
  scene:addChild(layer)
  require("k510/Game/GameLogic"):setStaySceneName(Common.Scene_Name.Scene_Game,layer)
  return scene, layer
end

-- 按钮显示控制
--[[
    HideALL = -1,    --全部隐藏
    ShowOut = 0,     --显示操作按钮
    HideOut = 1,     --隐藏操作按钮
    ShowReady0 = -1, --全部隐藏
    ShowReady1 = 3,  --显示飘选择按钮1
    ShowReady2 = 4,  --显示飘选择按钮1
    ShowQie = 5,     --显示切牌选择按钮
]]
function DeskScene:ControlBtn(ShowMenuItemTag)
    -- 全部隐藏
    self.tipMenuItem:setVisible(false)
    self.outMenuItem:setVisible(false)
    self.Qie0MenuItem:setVisible(false)
    self.QieMenuItem:setVisible(false)
	self.cutBkg:setVisible(false)
	self.notOutMenuItem:setVisible(false)
	self.YesMenuItem:setVisible(false)
	self.NoMenuItem:setVisible(false)
	self.replyBkg:setVisible(false)
	self.tip_lab:setVisible(false)
    -- 根据不同设置调整按钮位置及显示状态
    if ShowMenuItemTag == self.menuItemShowTag.ShowOut then
        self.tipMenuItem:setVisible(true)
        self.outMenuItem:setVisible(true)
		self.notOutMenuItem:setVisible(true)
    elseif ShowMenuItemTag == self.menuItemShowTag.ShowReply then
        self.YesMenuItem:setVisible(true)
		self.NoMenuItem:setVisible(true)
		self.tip_lab:setVisible(true)
		self.replyBkg:setVisible(true)
    elseif ShowMenuItemTag == self.menuItemShowTag.ShowQie then
		self.tip_lab:setVisible(true)
        self.Qie0MenuItem:setVisible(true)
        self.QieMenuItem:setVisible(true)
		self.cutBkg:setVisible(true)
    end
end

-- 刷新界面
function DeskScene:updateDeskInfo(s)
    cclog("DeskScene:updateDeskInfo by "..tostring(s).." gamePhase: "..GameLogic.gamePhase)
    local f = require("Lobby/FriendGame/FriendGameLogic")
    local lan_set = AppConfig.language[SetLogic.getGameCheckByIndex(3)]
    local zSex = 1
    for i = 1, Common.PLAYER_COUNT do
        local userInfo = GameLogic:getUserInfo(i - 1)
        if userInfo ~= nil and self._PlayerVec[i] ~= nil then
            self._PlayerVec[i]:Show()
            -- 刷新庄标示
            if GameLogic.cbMingPaiCard ~= -1 and GameLogic.cbMingPaiCard == userInfo._chairID then
                userInfo:setZhuang(true)
                zSex = userInfo:getSex()
            else
                userInfo:setZhuang(false)
            end
            -- 更新用户信息
            self._PlayerVec[i]:UpdateUserInfo(userInfo,
                (userInfo._chairID == GameLogic.myChair) 
                and (#self:getMyCardsLst() > 0)
            )
        else
            self._PlayerVec[i]:Hide()
        end

        --隐藏倒计时
        self._PlayerVec[i]:setTimer(false,GameLogic:getTimeOutCounts())
		self._PlayerVec[i]:HideEffect()

        --当前操作者不处于游戏切牌或结束阶段
        if GameLogic:ServerToClientSeat(GameLogic.curActor) == (i - 1) and 
            GameLogic.gamePhase == Common.GAME_PHRASE.enGame_OutCard then
            --设置显示倒计时
            self._PlayerVec[i]:setTimer(true,GameLogic:getTimeOutCounts())
            --隐藏打出去的牌或者状态
            self._PlayerVec[i]:HideSomeIfCurActo()
        end
    end
    
    -- 重置隐藏切牌状态图示
    self.animateQie:setVisible(false)
    
    -- 根据当前游戏阶段和数据 显示相关操作按钮
    -- 切牌阶段    
    if GameLogic.gamePhase == Common.GAME_PHRASE.enGame_QiePai then
        local data = GameLogic.qieData
        local idx = GameLogic:ServerToClientSeat(data.cbChairCurQie) + 1
        cclog("切牌判定 chair: %d, able: %d, value: %d, myChair: %d   %d", data.cbChairCurQie, data.cbQieAble, data.cbQieValue, GameLogic.myChair, idx)
		
		for i = 1, Common.PLAYER_COUNT do
			local userInfo = GameLogic:getUserInfo(i - 1)
			if userInfo ~= nil then
				if data.cbLastBankerUser == userInfo._chairID then
					userInfo:setZhuang(true)
				else
					userInfo:setZhuang(false)
				end
				
				            -- 更新用户信息
            self._PlayerVec[i]:UpdateUserInfo(userInfo,
                (userInfo._chairID == GameLogic.myChair) 
                and (#self:getMyCardsLst() > 0)
            )
			end
		end
		
        if data.cbQieAble == 1 then
            -- 如果切牌人是自己则显示操作菜单
            if data.cbChairCurQie == GameLogic.myChair then
				local text = "是否要切牌?"
				self.tip_lab:setString(text)
                self:ControlBtn(self.menuItemShowTag.ShowQie)
            -- 不是自己隐藏所有操作菜单
            else
                self:ControlBtn(self.menuItemShowTag.HideALL)
            end
            -- 更新切牌图示位置及显示状态
            local pos = {ccp(self.winSize.width-280,525), ccp(255,165), ccp(255,525)}
            self.animateQie:setPosition(pos[idx])
            self.animateQie:setVisible(true)
        else
            local msg = data.cbQieValue == 1 and "[%s] 切了牌" or "[%s] 没有切牌"
            local userInfo = GameLogic.userlist[data.cbChairCurQie + 1]
            if userInfo then
                require("HallUtils").showWebTip(string.format(msg, userInfo:getUserName()),self,nil,nil,1.8)
                -- 郴州话播放切牌音效
                if lan_set == "lan_chenzhou" then
                    local uSex = (userInfo:getSex() == 1) and "man" or "woman"
                    local opration = data.cbQieValue == 1 and "qiepai" or "buqiepai"
                    local effect = string.format("k510/sound/%s/%s/%s.mp3",lan_set, uSex, opration)
                    SetLogic.playGameEffect(effect)
                end
            else
                ccerr("错误的读取数据")
            end
            self:ControlBtn(self.menuItemShowTag.HideALL)
        end
    -- 发牌阶段隐藏所有操作菜单
    elseif GameLogic.gamePhase == Common.GAME_PHRASE.enGame_InitData then
        self:ControlBtn(self.menuItemShowTag.HideALL)
	-- 问询玩家阶段
	elseif GameLogic.gamePhase == Common.GAME_PHRASE.enGame_AskPlayer then
	
		local data = GameLogic.askData
		--cclog("---------dff------------"..data.cbIsAsking)
		if data.cbIsAsking == 1 then
			if data.cbAskPlayerID == GameLogic.myChair then
				local text = "是否要与[%s] 对战?"
				local userInfo = GameLogic.userlist[data.cbToFightID + 1]
				if userInfo then
					text = string.format(text, userInfo:getUserName())
				else
					ccerr("askLayer错误的user数据")
				end
				self.tip_lab:setString(text)
				self:ControlBtn(self.menuItemShowTag.ShowReply)
			else
				local msg = "正在问询[%s] 是否与[%s] 对战"
				local userInfo1 = GameLogic.userlist[data.cbAskPlayerID + 1]
				local userInfo2 = GameLogic.userlist[data.cbToFightID + 1]
				if userInfo1 and userInfo2 then
					self.askPlayerLabel:setString(string.format(msg, userInfo1:getUserName(), userInfo2:getUserName()))
					self.askPlayerBg:changeWidthAndHeight(self.askPlayerLabel:getContentSize().width*1.1,self.askPlayerLabel:getContentSize().height*1.3)
					local winsize=CCDirector:sharedDirector():getWinSize()
					pos = ccp(winsize.width / 2 - self.askPlayerBg:getContentSize().width*0.5, winsize.height / 2 + 60)
					self.askPlayerBg:setPosition(pos)
					self.askPlayerLabel:setPosition(ccp(self.askPlayerBg:getContentSize().width*0.5,self.askPlayerBg:getContentSize().height*0.5))
					if not self.askPlayerBg:isVisible() then self.askPlayerBg:setVisible(true) end
				end
			end
		else
			self.askPlayerBg:setVisible(false)
			--cclog("---------------------gegeg")
			local tag = data.cbAskReply == 1 and Player.StatusTip.Tip_Fight or Player.StatusTip.Tip_NoFight
			for i = 1, Common.PLAYER_COUNT do
				local userInfo = GameLogic:getUserInfo(i - 1)
				if userInfo ~= nil then
					if data.cbAskPlayerID == userInfo._chairID then
					--cclog("---------------------gegeg")
						self._PlayerVec[i]:ShowTip(tag)
					end
				end
			end
		end
    -- 打牌阶段
    elseif GameLogic.gamePhase == Common.GAME_PHRASE.enGame_OutCard then
        if GameLogic.curActor == GameLogic.myChair and GameLogic.myChair ~= -1 then
            self:resetTipCard(self.lastTipCard)
            self.isOutCard = false
            self:autoOutCardsByCondition(BombStatus[FriendGameLogic.my_rule[2][2]],StraightMax[FriendGameLogic.my_rule[3][2]])
			if GameLogic.nRingCount == 0 then
				if self.notOutMenuItem:isEnabled() then self.notOutMenuItem:setEnabled(false) end
			else
				if not self.notOutMenuItem:isEnabled() then self.notOutMenuItem:setEnabled(true) end
			end
			if not self.outMenuItem:isEnabled() then self.outMenuItem:setEnabled(true) end
        else 
			self:getMyPlayer():HideEffect()
            self:ControlBtn(self.menuItemShowTag.HideOut)
        end
		if GameLogic.cbNoJoin == GameLogic.myChair then
			self:getMyPlayer():SetCardUnTouch()
		end
		
		for i = 1, Common.PLAYER_COUNT do
			local userInfo = GameLogic:getUserInfo(i - 1)
			if userInfo ~= nil then
				if GameLogic.curActor == userInfo._chairID then
					self._PlayerVec[i]:ShowEffect()
				else
					self._PlayerVec[i]:HideEffect()
				end
				
				if GameLogic.cbNoJoin == userInfo._chairID then
					self._PlayerVec[i]:ShowTip(Player.StatusTip.Tip_View)
				else
					self._PlayerVec[i]:RunTipAction()
				end
			end
		end
    -- 结束阶段
    elseif GameLogic.gamePhase == Common.GAME_PHRASE.enGame_Over then
		for i = 1, Common.PLAYER_COUNT do
			local userInfo = GameLogic:getUserInfo(i - 1)
			if userInfo ~= nil then
				self._PlayerVec[i]:HideTip()
			end
		end
        self:DelayGameEnd()
    -- 未开始阶段
    elseif GameLogic.gamePhase == Common.GAME_PHRASE.enGame_Invalid then
        self:checkReconnectUI()
    end

    if f.game_used then
        --开关邀请按钮
        ----第0局且处于未开始阶段则显示邀请按钮
        if f.game_used  == 0 and GameLogic.gamePhase == Common.GAME_PHRASE.enGame_Invalid then
            self.inviteMenuItem:setVisible(true)
        else
            self.inviteMenuItem:setVisible(false)
        end   

        --开关离开按钮
        local maxCount = f.my_rule[1] and f.my_rule[1][2] or 15
        --第0局且处于未开始阶段或最后一局处于结束阶段则显示离开按钮
        if (f.game_used  == 0 and GameLogic.gamePhase == Common.GAME_PHRASE.enGame_Invalid ) or 
            (f.game_used  == maxCount and GameLogic.gamePhase == Common.GAME_PHRASE.enGame_Over) then
                self.leaveRoomBtn:setVisible(true)
        else
            -- 第0局且处于未开始阶段且设置为郴州话播放"我出牌"音效
            if f.game_used  == 0 and GameLogic.gamePhase == Common.GAME_PHRASE.enGame_InitData and
                lan_set == "lan_chenzhou" then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.PlaySoundTimerId)
                local function PlaySoundTimer(dt)
                    local uSex = (zSex == 1) and "man" or "woman"
                    local effect = string.format("k510/sound/%s/%s/woxianchu.mp3",lan_set, uSex)
                    SetLogic.playGameEffect(effect)
                    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.PlaySoundTimerId)
                end
                self.PlaySoundTimerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(PlaySoundTimer, 0.75, false)
            end
            self.leaveRoomBtn:setVisible(false)
        end
        
        --开关定位按钮动画 第1局结束后关闭动画
        if f.game_used  > 1 then
            self.locationBtn.m_normalSp:stopAllActions()
            self.locationBtn.m_normalSp:setDisplayFrame(
                CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("ui/loc.png")
            )
        end
    end
end

-- 重回判定, 此阶段必须等到规则下发后方做判定
function DeskScene:checkReconnectUI()
    cclog("局间判定")
    local f = require("Lobby/FriendGame/FriendGameLogic")
    if GameLogic.myself and f.game_used and f.my_rule then
        -- 如果是首局
        if 0 == f.game_used then
            cclog("首局")
            -- 如果玩家没准备则帮助其自动准备
            if GameLogic.myself.gameNewStatus ~= Common.GAME_PLAYER_STATE.USER_READY_STATUS then
                GameLogic:sendStartMsg("首局自动准备")
            else
                cclog("已准备")
            end
        -- 如果非首局
        else
            cclog("非首局")
            -- 如果玩家没准备
            if GameLogic.myself.gameNewStatus ~= Common.GAME_PLAYER_STATE.USER_READY_STATUS then
                    -- 没有正在显示结算界面
                    if not self.resultLayer:isVisible() then
                        GameLogic:sendStartMsg("重回自动准备")
                    -- 正在显示结算界面，隐藏自己手牌
                    else
                        local player = self._PlayerVec[GameLogic:ServerToClientSeat(GameLogic.myChair) + 1]
                        if player then player._PlayCards:setVisible(false) end
                    end
            else
                cclog("已准备")
            end
        end
    else
        cclog("数据不全")
        print(GameLogic.myself, f.game_used, f.my_rule)
    end
end

-- 得到我的手牌
function DeskScene:getMyCardsLst()
   local handCards = {}
   if GameLogic.myChair >= 0 and GameLogic.myChair < Common.PLAYER_COUNT then
        local chair = GameLogic:ServerToClientSeat(GameLogic.myChair) + 1
        local player = self._PlayerVec[chair]
        if player ~= nil then
            handCards = player:getMyCardsLst()
        end
    end

    return handCards
end

-- 得到我的实例
function DeskScene:getMyPlayer()
   if GameLogic.myChair >= 0 and GameLogic.myChair < Common.PLAYER_COUNT then
        local chair = GameLogic:ServerToClientSeat(GameLogic.myChair) + 1
        return self._PlayerVec[chair]
    end
end

-- 恢复
function DeskScene:menuHuiFuCallBack()
    if GameLogic.myChair >= 0 and GameLogic.myChair < Common.PLAYER_COUNT then
        local player = self._PlayerVec[GameLogic:ServerToClientSeat(GameLogic.myChair) + 1]
        if player ~= nil then
            player:setHandCardsReset()
        end
    end
end

-- 邀请好友
function DeskScene:menuInviteCallBack()
    if require("Lobby/FriendGame/FriendGameLogic").invite_code then
        local msg, titile, roominfo = require("k510/LayerDeskRule").getInviteMsg()
        local url = Common.InviteInfo.wxUrl..roominfo
        cclog("%s %s %s", titile, msg, url)
        shareWebToWx(1, url, titile, msg, function() end)
    end
end

-- 不出
function DeskScene:menuUnOutCardsCallBack()
    if GameLogic.nRingCount == 0 then
        return
    end

    if self.isOutCard then
       return
    end
	
	if self.noOutCardTip:isVisible() then
		self.noOutCardTip:setVisible(false)
	end

	local player = self._PlayerVec[GameLogic:ServerToClientSeat(GameLogic.myChair) + 1]
    player._PlayCards:reset()
	
    local OutCard = Common.newMyOutCard()
    OutCard.suitType = Common.SUIT_TYPE.suitPass
    OutCard.suitLen = 0

    GameLogic:sendOutCardsMsg(OutCard)
    self:ControlBtn(self.menuItemShowTag.HideOut)
    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.unschedulerAutoId)
    GameLogic:sendOutCardSound(Common.SND_TYPE.sndPass)
    self.isOutCard = true
    cclog("menuUnOutCardsCallBack不出")
end

-- 轮到我出牌 要是要不起或者只剩下能出完的牌 自动出掉
function DeskScene:autoOutCardsByCondition(bombStatus,straightMax)
    cclog("autoOutCardsByCondition")
    -- 自动出牌时间间隔
    self.autoTime = 0.5
    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.unschedulerAutoId)
    local function updateTimer(delta)
        self.autoTime = self.autoTime - delta
        if (self.autoTime <= 0) then
            --停止倒计时
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.unschedulerAutoId)
			self:ControlBtn(self.menuItemShowTag.ShowOut)
			
			cclog("跟牌")
			local bRet = false
			local lastOutCard = {}
			bRet,lastOutCard = GameLogic:GetLastNoPassCardSuit()

			if bRet == false then
				cclog("错误！没有上家出牌")
				return
			end

			local arrayOut = {}
			local arrayHold = {}
			local selectedCardsIndex = {}
			arrayHold = ShareFuns.Copy(self:getMyCardsLst())

			if self.lastTipCard.suitType == Common.SUIT_TYPE.suitInvalid then
				bRet,arrayOut = ShareFuns.TipOutCard(lastOutCard,arrayHold,
					BombStatus[FriendGameLogic.my_rule[2][2]],StraightMax[FriendGameLogic.my_rule[3][2]])
			else
				bRet,arrayOut = ShareFuns.TipOutCard(self.lastTipCard,arrayHold,
					BombStatus[FriendGameLogic.my_rule[2][2]],StraightMax[FriendGameLogic.my_rule[3][2]])
			end

			if #arrayOut == 0 then
				if self.lastTipCard.suitType  == Common.SUIT_TYPE.suitInvalid and not self.isOutCard then
					--没有牌能大过上家
					self.outMenuItem:setEnabled(false)
					self.noOutCardTip:setVisible(true)
					return
				end
			end
        end
    end

    self.unschedulerAutoId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTimer, 0.1, false)
end

-- 提示
function DeskScene:menuCardsTipsCallBack()
    -- print("提示出牌")
    if GameLogic.myChair ~= -1 and GameLogic.myChair == GameLogic.curActor then
		if self.noOutCardTip:isVisible() then
			self.noOutCardTip:setVisible(false)
		end
	
        local myHandCards = GameLogic.userlist[GameLogic.myChair+1]:getHandCards()
        local nextHandCards = GameLogic.userlist[GameLogic:AntiClockWise(GameLogic.myChair)+1]:getHandCards()
        
        if GameLogic.nRingCount == 0 then
            local selectedCardsIndex = {}
            local arrayHold = ShareFuns.Copy(self:getMyCardsLst())
            local arrayOut = {}
            local ilen = #arrayHold
			
            if ilen > 0 then
                -- 下列牌型判定 单、双、三、大王、五十K、纯五十K
                if ilen == 1 and (ShareFuns.IsSingle(arrayHold) or ShareFuns.IsRedJoker(arrayHold))then
					arrayOut = ShareFuns.Copy(arrayHold)
				elseif ilen == 2 and ShareFuns.IsDouble(arrayHold) then
					arrayOut = ShareFuns.Copy(arrayHold)
				elseif ilen == 3 and (ShareFuns.IsTriple(arrayHold) or ShareFuns.IsFiveTenKing(arrayHold)
					or ShareFuns.IsPureFiveTenKing(arrayHold)) then
					arrayOut = ShareFuns.Copy(arrayHold)
				else -- 判定三带对、飞机、顺子、双顺、三顺、炸弹
					local bRet,outArrayTemp = ShareFuns.IsTriAndDouble(arrayHold)
					if ilen == 5 and bRet then
						arrayOut = ShareFuns.Copy(outArrayTemp)
					end

					local bRet,outArrayTemp = ShareFuns.IsPlane(arrayHold)
					if ilen >= 10 and bRet then
						arrayOut = ShareFuns.Copy(outArrayTemp)
					end

					local bRet,outArrayTemp = ShareFuns.IsStraight(arrayHold)
					if ilen >= 5 and bRet then
						arrayOut = ShareFuns.Copy(outArrayTemp)
					end
					
					local bRet,outArrayTemp = ShareFuns.IsDoubleStraight(arrayHold)
					if ilen >= 4 and bRet then
						arrayOut = ShareFuns.Copy(outArrayTemp)
					end
					
					local bRet,outArrayTemp = ShareFuns.IsTriStraight(arrayHold)
					if ilen >= 6 and bRet then
						arrayOut = ShareFuns.Copy(outArrayTemp)
					end
					
					local bRet,outArrayTemp = ShareFuns.IsBomb(arrayHold,
						BombStatus[FriendGameLogic.my_rule[2][2]])
					if ilen >= 4 and bRet then
						arrayOut = ShareFuns.Copy(outArrayTemp)
					end
					
					-- 如果选择到预置牌型
                    if #arrayOut == 0 then
						arrayOut = ShareFuns.GetFirstCards(arrayHold)
						-- if ShareFuns.NotPassBaodanJudge(myHandCards, nextHandCards, arrayOut) then
							-- arrayOut[1] = myHandCards[1]
						-- end
                    end
				end

                local myCradsLst = ShareFuns.Copy(self:getMyCardsLst())
                for i = 1,#arrayOut do
                    for j = 1,ilen do
                        if arrayOut[i] == myCradsLst[j] then
                            local bNext = false
                            for k = 1,#selectedCardsIndex do
                                if selectedCardsIndex[k] == j then
                                    bNext = true
						            break
                                end
                            end

                            if not bNext then
                                table.insert(selectedCardsIndex,j)
                                break
                            end

                        end
                    end
                end

                --把牌提起来
                --先把牌都放下
                if #selectedCardsIndex ~= 0 then
                    self:setCardsUp(selectedCardsIndex)
                end
            end
        else
            local selectedCardsIndex = {}
            --跟牌
            local bRet = false
            local lastOutCard = {}
            bRet,lastOutCard = GameLogic:GetLastNoPassCardSuit()

            if bRet == false then
               return
            end

            local arrayOut = {}
            local arrayHold = {}
            local selectedCardsIndex = {}
            arrayHold = ShareFuns.Copy(self:getMyCardsLst())

            if self.lastTipCard.suitType == Common.SUIT_TYPE.suitInvalid then
                if lastOutCard.suitType  == Common.SUIT_TYPE.suitSingle then
                   
                end

                local bRet = false
                bRet,arrayOut = ShareFuns.TipOutCard(lastOutCard,arrayHold,
				BombStatus[FriendGameLogic.my_rule[2][2]],StraightMax[FriendGameLogic.my_rule[3][2]])
            else
                local bRet = false
                bRet,arrayOut = ShareFuns.TipOutCard(self.lastTipCard,arrayHold,
				BombStatus[FriendGameLogic.my_rule[2][2]],StraightMax[FriendGameLogic.my_rule[3][2]])
            end

            if #arrayOut == 0 then
                if self.lastTipCard.suitType  == Common.SUIT_TYPE.suitInvalid then
                    self:setOutCardTip(2)   --" 您没有牌能大过上家"
                    self:menuUnOutCardsCallBack()
                    return
                else
                    local arrayOut = {}
                    self:resetTipCard(self.lastTipCard)
                    --self.lastTipCard.suitType = Common.SUIT_TYPE.suitInvalid
                    local bRet = false
                    bRet,arrayOut = ShareFuns.TipOutCard(lastOutCard,arrayHold,
					BombStatus[FriendGameLogic.my_rule[2][2]],StraightMax[FriendGameLogic.my_rule[3][2]])

                    -- if ShareFuns.NotPassBaodanJudge(myHandCards, nextHandCards, arrayOut) then
                        -- arrayOut[1] = myHandCards[1]
                    -- end

                    bRet = GameLogic:CanOutCard(arrayOut)
                    if bRet == true then
                        --arrayOut = ShareFuns.SortOutCards(arrayOut)
                        bRet,self.lastTipCard = ShareFuns.DisassembleToOutCard(arrayOut,BombStatus[FriendGameLogic.my_rule[2][2]])
                        local myCradsLst = ShareFuns.Copy(self:getMyCardsLst())
                        if bRet == true then
                            for i = 1,#arrayOut do
                                for j = 1,#myCradsLst do
                                    if arrayOut[i] == myCradsLst[j] then
                                        local bNext = false
                                        for k = 1,#selectedCardsIndex do
                                            if selectedCardsIndex[k] == j then
                                               bNext = true
                                               break
                                            end
                                        end

                                        if not bNext then
                                           table.insert(selectedCardsIndex,j)
                                           break
                                        end

                                    end
                                end
                            end

                            --把牌提起来
                            --先把牌都放下
                            if #selectedCardsIndex ~= 0 then
                                self:setCardsUp(selectedCardsIndex)
                            end
                        end
                    end
                end
            else
                -- if ShareFuns.NotPassBaodanJudge(myHandCards, nextHandCards, arrayOut) then
                    -- arrayOut[1] = myHandCards[1]
                -- end

                local bRet = GameLogic:CanOutCard(arrayOut)
                if bRet == true then
                    --arrayOut = ShareFuns.SortOutCards(arrayOut)
                    bRet,self.lastTipCard = ShareFuns.DisassembleToOutCard(arrayOut,BombStatus[FriendGameLogic.my_rule[2][2]])
                    local myCradsLst = ShareFuns.Copy(self:getMyCardsLst())
                    if bRet == true then
                        for i = 1,#arrayOut do
                            for j = 1,#myCradsLst do
                                if arrayOut[i] == myCradsLst[j] then
                                    local bNext = false
                                    for k = 1,#selectedCardsIndex do
                                        if selectedCardsIndex[k] == j then
                                            bNext = true
                                            break
                                        end
                                    end

                                    if not bNext then
                                        table.insert(selectedCardsIndex,j)
                                        break
                                    end

                                end
                            end
                        end

                        --把牌提起来
                        --先把牌都放下
                        if #selectedCardsIndex ~= 0 then
                            self:setCardsUp(selectedCardsIndex)
                        end                   
                    end
                else
                    --不能出
                    --self.lastTipCard.suitType = Common.SUIT_TYPE.suitInvalid
                    self:resetTipCard(self.lastTipCard)
                end
            end
        end
    end
end

-- 出牌
function DeskScene:menuOutCardsCallBack()
    -- print("出牌动作")
    if GameLogic.myChair ~= -1 and GameLogic.myChair == GameLogic.curActor and  not self.isOutCard then
        local selfPlayer = self:getMyPlayer()
        local myHandCards = GameLogic.userlist[GameLogic.myChair+1]:getHandCards()
        local nextHandCards = GameLogic.userlist[GameLogic:AntiClockWise(GameLogic.myChair)+1]:getHandCards()
        local cards = self:getMyChooseOutCards()
        cards = ShareFuns.SortCards(cards)
        --判断选出的牌是不是符合标准
        if #cards == 0 then
            self:setOutCardTip(0)   --请选择要出的牌!
            return
        end
        local bRet = false
        local outCards = {}
        bRet, outCards = ShareFuns.DisassembleToOutCard(cards,BombStatus[FriendGameLogic.my_rule[2][2]])
        if bRet == false then
            self:setOutCardTip(1)   --您选的牌,牌型不对!!
            return
        end
        print("GameLogic.nRingCount", GameLogic.nRingCount, outCards.suitType)
        if GameLogic.nRingCount == 0 then
            if outCards.suitType == Common.SUIT_TYPE.suitTriple 
                and (outCards.suitLen ~= #GameLogic.userlist[GameLogic.myChair + 1]:getHandCards() and GameLogic.isInFirstTurn ~= 1) then
                    self:setOutCardTip(4)   --"三张只能用于先手或者收尾!"
                return
            end
        else
            local bRet = false
            local lastOutCard = {}
            bRet, lastOutCard = GameLogic:GetLastNoPassCardSuit()
            if bRet == false then            
                return
            end
            bRet = ShareFuns.CompareTwoCardSuit(lastOutCard,outCards,StraightMax[FriendGameLogic.my_rule[3][2]])
            if bRet == false then
                self:setOutCardTip(2)
                return
            end
        end
        
        -- if ShareFuns.NotPassBaodanJudge(myHandCards, nextHandCards, outCards.cards) then
            -- self:setOutCardTip(3)   --"下家报单出单张必须出最大的"
            -- return
        -- end
        local myOutCard = Common.newMyOutCard()
        myOutCard.suitType = outCards.suitType
        myOutCard.suitLen = outCards.suitLen
        myOutCard.cards = ShareFuns.Copy(outCards.cards)

        GameLogic:sendOutCardsMsg(myOutCard)

        GameLogic:sendOutCardSound(Common.SND_TYPE.sndOutCard)
        if #self:getMyCardsLst() - myOutCard.suitLen == 1 then
            GameLogic:sendOutCardSound(Common.SND_TYPE.sndBaoDan)
        end

        self.isOutCard = true
        
        if selfPlayer then
            local arrayHold = ShareFuns.Copy(self:getMyCardsLst())
            selfPlayer:resetHandCards(ShareFuns.RemoveAryFromAry(arrayHold,myOutCard.cards))
            selfPlayer:resetOutCards(myOutCard.cards,myOutCard.suitType)
            selfPlayer:setTimer(false,0)
        end
    end
    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.unschedulerAutoId)
    self:ControlBtn(self.menuItemShowTag.HideOut)
end

-- 设置框显示
function DeskScene:menuSetShowCallBack()

end

-- 解散框显示
function DeskScene:menuDissolveBack()

end

function DeskScene:setTipDissolveLayer(msg)

end

-- 结算显示
function DeskScene:showResultLayer(myDBID)
    self.resultLayer:setOneGameInfo(myDBID)
end

-- end
function DeskScene:showEndResultLayer(args)
    self.resultLayer:setEndGameInfo(args)
end

-- 投票结果
function DeskScene:DissolveResult(result)
    
end

-- 得到选择出的牌
function DeskScene:getMyChooseOutCards()
    local outCards = {}
    if GameLogic.myChair >= 0 and GameLogic.myChair < Common.PLAYER_COUNT then
        local player = self._PlayerVec[GameLogic:ServerToClientSeat(GameLogic.myChair) + 1]
        if player ~= nil then
            outCards = player:getChooseOutCards()
        end
    end
    return outCards
end

-- 结算
function DeskScene:onGameEnd()
     
end

-- -1隐藏 0提示"请选择要出的牌" 1提示"选的牌型不对" 2提示"选的牌不能大过上家!" 3提示"下家报单出单张必须出最大的"
function DeskScene:setOutCardTip(flag)
    local strTip
    if flag == 0 then
        strTip = "请选择要出的牌!"
    elseif flag == 1 then
        strTip = "所选的牌型不对!"
    elseif flag == 2 then
        -- strTip = "选的牌不能大过上家!"
    elseif flag == 3 then
        strTip = "下家报单出单张必须出最大的!"
    elseif flag == 4 then
        strTip = "三张只能用于先手或者收尾!"
    end
    if strTip then require("HallUtils").showWebTip(strTip) end
end

-- 让牌选中
function DeskScene:setCardsUp(array)
    local player = self._PlayerVec[GameLogic:ServerToClientSeat(GameLogic.myChair) + 1]
    player._PlayCards:reset()
    for i = 1,#array do
        player._PlayCards:selectCard(array[i])
    end
end

-- 重置提示牌
function DeskScene:resetTipCard(lastTipCard)
    lastTipCard.suitType = Common.SUIT_TYPE.suitInvalid
    lastTipCard.suitLen = 0	

    lastTipCard.cards = {}
end

-- 返回到大厅
function DeskScene:backToMenuScene()
    local scene = require("k510/Game/MainScene").createScene()
    CCDirector:sharedDirector():replaceScene(scene)
end

-- 播放声音
function DeskScene:PlayRevSound(sndIdx)
    cclog("DeskScene:PlayRevSound: "..tostring(sndIdx))
    --当前玩家的上个玩家所出的牌，包括PASS
    local lastOutCard = {}
    --当前玩家的上上个玩家所出的牌，用来判断是否用"管上"音效
    --local lastlastOutCard = {}

    local userType = {}
    
    if GameLogic.curActor == -1 or GameLogic.curActor == 255 then
        return
    end

    if GameLogic.gamePhase ~= Common.GAME_PHRASE.enGame_Over  then
       lastOutCard = GameLogic.userlist[GameLogic:getPreChair(GameLogic.curActor) + 1].outCards --就是出最后一手牌的玩家
       --lastlastOutCard = GameLogic.userlist[GameLogic:getPreChair(GameLogic.curActor + 1) + 1].outCards
       userType = GameLogic.userlist[GameLogic:getPreChair(GameLogic.curActor) + 1]:getSex()
    else
       lastOutCard = GameLogic.userlist[GameLogic.curActor + 1].outCards --就是出最后一手牌的玩家
       userType = GameLogic.userlist[GameLogic.curActor + 1]:getSex()
    end

    print(lastOutCard, (lastOutCard.cards and #lastOutCard.cards), sndIdx, Common.SND_TYPE.sndPass)
    if lastOutCard ~= nil then
        if sndIdx == Common.SND_TYPE.sndPass then
            SetLogic.playGameEffect(self:GetSoundByCommand(userType,Common.SUIT_TYPE.suitPass,-1))
        elseif sndIdx == Common.SND_TYPE.sndOutCard then
			if #lastOutCard.cards == 0 then return end
            local cardValue = lastOutCard.cards[1]%13
            SetLogic.playGameEffect(self:GetSoundByCommand(userType,lastOutCard.suitType,cardValue))
			if GameLogic.gamePhase ~= Common.GAME_PHRASE.enGame_Over  then
				self._PlayerVec[GameLogic:ServerToClientSeat(GameLogic:getPreChair(GameLogic.curActor)) + 1]:playCardTypeAction(lastOutCard.suitType,lastOutCard)
			else
				self._PlayerVec[GameLogic:ServerToClientSeat(GameLogic.curActor) + 1]:playCardTypeAction(lastOutCard.suitType,lastOutCard)
			end

        elseif sndIdx == Common.SND_TYPE.sndBaoDan then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.PlaySoundTimerId)
            local function PlaySoundTimer(dt)
                SetLogic.playGameEffect(self:GetSoundByCommand(userType,Common.SUIT_TYPE.suitBaodan,-1))
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.PlaySoundTimerId)
            end
            self.PlaySoundTimerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(PlaySoundTimer, 0.7, false)
        end
    end
end

-- 获取音效路径
function DeskScene:GetSoundByCommand(utype,sType,cardValue)
    local lan_set = AppConfig.language[SetLogic.getGameCheckByIndex(3)]
    
    local suffix = ""
    local rand = math.random(0,100)

    if sType == Common.SUIT_TYPE.suitPass then
        if lan_set == "lan_chenzhou" then
            suffix = string.format("%s%d","pass",rand%3)
        else
            suffix = string.format("%s%d","pass",rand%4)
        end
    elseif sType == Common.SUIT_TYPE.suitBaodan then
        suffix = string.format("%s","baodan")
    elseif sType == Common.SUIT_TYPE.suitSingle then
        suffix = string.format("%s%d","singe",cardValue)
    elseif sType == Common.SUIT_TYPE.suitDouble then
        suffix = string.format("%s%d","double",cardValue)
    elseif sType == Common.SUIT_TYPE.suitTriple then
        if lan_set == "lan_chenzhou" then
            suffix = string.format("%s%d","Triple",cardValue)
        else
            suffix = string.format("%s","sanzhang")
        end
    elseif sType == Common.SUIT_TYPE.suitTriAndDouble then
        suffix = string.format("%s","sandaier")
    elseif sType == Common.SUIT_TYPE.suitStraight then
        suffix = string.format("%s","shunzi")
    elseif sType == Common.SUIT_TYPE.suitDoubleStraight then
        suffix = string.format("%s","liandui")
    elseif sType == Common.SUIT_TYPE.suitPlane or sType == Common.SUIT_TYPE.suitTriStraight then
        suffix = string.format("%s","feiji")
    elseif sType == Common.SUIT_TYPE.suitBomb then
        suffix = string.format("%s","zhadan")
	elseif sType == Common.SUIT_TYPE.suitRedJoker then
	cclog("-------geg")
        suffix = string.format("%s","dawang")
	elseif sType == Common.SUIT_TYPE.suitFiveTenKing or sType == Common.SUIT_TYPE.suitPureFiveTenKing then
	cclog("-------geg")
        suffix = string.format("%s","wsk")
    end

    if utype == 1 then
        suffix = string.format("k510/sound/%s/man/%s.mp3", lan_set, suffix)
    else
        suffix = string.format("k510/sound/%s/woman/%s.mp3", lan_set, suffix)
    end
    
    print(suffix)

    return suffix
end

-- 延时结算
function DeskScene:DelayGameEnd(isRefresh)
    cclog("DeskScene:DelayGameEnd")
    local myDBID = require("k510/GameLibSink").game_lib:getMyDBID()
	
	self:ControlBtn(self.menuItemShowTag.HideALL)
    -- 如果未显示结算界面
    if not self.resultLayer:isVisible() then
        --先显示手牌
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.unschedulerDelayShowHandsId)
        local function updateShowHandsTimer(delta)
            cclog("亮牌")
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.unschedulerDelayShowHandsId)
            for i = 1,3 do
                local userInfo = GameLogic:getUserInfo(i - 1)
                if userInfo ~= nil then
                    local outCards = ShareFuns.Copy(userInfo:getHandCards())
					self._PlayerVec[i]._PlayCards:resetCardsTouch()
                    self._PlayerVec[i]:resetOutCards(outCards, Common.SUIT_TYPE.suitInvalid) -- 亮牌
                    self._PlayerVec[i]._PlayCards:setVisible(false)
                end
                if not isRefresh then
                    self._PlayerVec[i]:setPlayerStatus(self._PlayerVec[i].StatusShow.Show_Hide)
                end
            end

        end
        self.unschedulerDelayShowHandsId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateShowHandsTimer, 3, false)

        --再显示结算界面
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.unschedulerDelayGameEndId)
        local function updateTimer(delta)
            cclog("显示结算 myDBID: %s", tostring(myDBID))
            self:showResultLayer(myDBID)
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.unschedulerDelayGameEndId)
            self:onGameEnd()
        end
        self.unschedulerDelayGameEndId =CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTimer, 5, false)
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.unschedulerAutoId)
    end
end

-- 发牌动画
--function DeskScene:faPaiAction()

--end

function DeskScene:Clear()
    for i = 1,#self._PlayerVec do
        self._PlayerVec[i]:Clear()
    end

    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.unschedulerAutoId)
end

return  DeskScene