
local Resources=require("bull/Resources")
local SoundRes =require("bull/SoundRes")
local GameCfg =require("bull/desk/public/GameCfg")
local PlayerCardLayer = require("bull/desk/PlayerCardLayer")
local MainPlayerCardLayer = require("bull/desk/MainPlayerCardLayer")

local Player=class("Player",function()
                      return CCLayer:create()
                      end)

Player.PLAYER_NAME_MAX_LEN =8
Player.NAMETEXTWIDTH =60

--特效文字
Player.STATE=
{
    State_Niu1 = "niu1",
    State_Niu2 = "niu2",
    State_Niu3 = "niu3",
    State_Niu4 = "niu4",
    State_Niu5 = "niu5",
    State_Niu6 = "niu6",
    State_Niu7 = "niu7",
    State_Niu8 = "niu8",
    State_Niu9 = "niu9",
    State_MeiNiu = "meiniu",
    State_NiuNiu = "niuniu",
    State_WuXiaoNiu = "wuxiaoniu",
    State_WuHuaNiu = "wuhuaniu",
    State_SiZha = "sizha",
    State_QiangZhuang = "qiangzhuang",
    State_BuQiang = "buqiang",
    State_ZhunBei = "zhunebi",
    State_DengDai = "dengdai",
    NULL=22,
}

function Player:onEnter()
end

function Player:onExit()
end

function Player:initUI(nPos)
    local winSize = CCDirector:sharedDirector():getWinSize()
    self.m_nUserID = -1
    self.m_nSex=0
    self.m_nPos=nPos
    self.m_nLastGold=0
    self.m_lGold = 0
    self.m_headImgSp=nil
    self.m_labelUsername=nil

    self.m_enState=0
    self.m_bIsMaster = false
    self.m_bIsFengHu = false
    self.m_cbReady = false

    self.m_headImgSp = nil
	self.m_headImgSp = loadSprite("bull/headbg.png")
	self.m_headImgSp:setVisible(false)
    self.m_headImgSp:setAnchorPoint(ccp(0,0))

    self.m_headCircleSp = nil
	self.m_headCircleSp = loadSprite("bull/headcircle2.png")
 
    self.m_headCircleSp:setAnchorPoint(ccp(0,0))
    self.m_headCircleSp:setPosition(ccp(-9,-9))
    self.m_headCircleSp:setVisible(false)
    self.m_headImgSp:addChild(self.m_headCircleSp)

    self.m_robotSp = loadSprite("bull/robotSp.png")
    self.m_robotSp:setAnchorPoint(ccp(0.5,0.5))
    self.m_robotSp:setVisible(false)
    self.m_robotSp:setPosition(ccp(self.m_headImgSp:getContentSize().width/2,self.m_headImgSp:getContentSize().height/2))
    self.m_headImgSp:addChild(self.m_robotSp,2)

    local headSpX = 0 
    local headSpY=0
    self.m_headOrginPos=nil
    self.m_headMovePos=nil
    self.m_playerCardLayerSendCardPos={ccp(0,0),ccp(0,0),ccp(0,0),ccp(0,0)}
    
	--牛几的特殊效果
    self.m_mature= CCArmature:create("tesupaixing")
    self:getGameSceneLayer():addChild(self.m_mature,101)
    self.m_mature:setVisible(false)
	self.m_mature:setAnchorPoint(ccp(0,0.5))

    self.m_matureBid= CCArmature:create("tesupaixing")
    self:getGameSceneLayer():addChild(self.m_matureBid,102)
    self.m_matureBid:setVisible(false)

    self.m_matureReady= CCArmature:create("tesupaixing")
    self:getGameSceneLayer():addChild(self.m_matureReady,103)
    self.m_matureReady:setVisible(false)

    self.m_matureWin= CCArmature:create("touxiangkuang")
    self.m_headImgSp:addChild(self.m_matureWin,2)
    self.m_matureWin:setPosition(ccp(self.m_headImgSp:getContentSize().width/2,self.m_headImgSp:getContentSize().height/2))
    self.m_matureWin:setVisible(false)

    self.m_matureTouXiang= CCArmature:create("touxianTX")
    self.m_headImgSp:addChild(self.m_matureTouXiang,2)
    self.m_matureTouXiang:setPosition(ccp(self.m_headImgSp:getContentSize().width/2,self.m_headImgSp:getContentSize().height/2-3))
    self.m_matureTouXiang:setVisible(false)
    self.m_matureTouXiang:getAnimation():playWithIndex(0)
	
	self:initPossition(5)
--[[  if self:IsMe() then
        self.m_headOrginPos= ccp(-self.m_headImgSp:getContentSize().width,30) --ccp(-self.m_headImgSp:getContentSize().width-20,50)
        self.m_headMovePos= ccp(160,30)--ccp(40,50)

        self.m_readySp:setPosition(ccp(self:getContentSize().width*0.5,self:getContentSize().height*0.2 + 60))
        self.m_mature:setPosition(ccp(560,self:getContentSize().height*0.3 - 10))
        self.m_matureBid:setPosition(ccp(self:getContentSize().width*0.5,self:getContentSize().height*0.3 + 30))
        --self.m_matureReady:setPosition(ccp(self:getContentSize().width*0.5,self:getContentSize().height*0.2 + 60))
		self.m_matureReady:setPosition(ccp(self:getContentSize().width*0.5,self:getContentSize().height*0.2 + 20))
    elseif self:IsRightOne() then
        self.m_headOrginPos=ccp(winSize.width + self.m_headImgSp:getContentSize().width,275)--ccp(winSize.width,winSize.height*0.5 - 100)
		self.m_headImgSp:setAnchorPoint(ccp(1,0))
		self.m_headMovePos =ccp(1228,275)--ccp(winSize.width*0.9-30,winSize.height*0.5 - 100)

        self.m_readySp:setPosition(ccp(self:getContentSize().width*0.7 + 40,self:getContentSize().height*0.5 - 40))
   --   self.m_mature:setPosition(ccp(self:getContentSize().width*0.8,self:getContentSize().height*0.5 - 80))
        self.m_matureBid:setPosition(ccp(self:getContentSize().width*0.8,self:getContentSize().height*0.5 - 40))
     --   self.m_matureReady:setPosition(ccp(self:getContentSize().width*0.7 + 40,self:getContentSize().height*0.5 - 40))
		self.m_mature:setPosition(ccp(925,self:getContentSize().height*0.5 - 50))
		self.m_matureReady:setPosition(ccp(self:getContentSize().width*0.7 + 115,self:getContentSize().height*0.5 -50))

    elseif self:IsRightTwo() then
        self.m_headOrginPos=ccp(winSize.width + self.m_headImgSp:getContentSize().width,470)--ccp(winSize.width,winSize.height*0.5 + 200)
        self.m_headImgSp:setAnchorPoint(ccp(1,0))
		self.m_headMovePos =ccp(1118,470)--ccp(winSize.width*0.8 - 270,winSize.height*0.5 + 200)

        self.m_readySp:setPosition(ccp(self:getContentSize().width*0.7 - 10,self:getContentSize().height*0.5 + 120))
        --self.m_mature:setPosition(ccp(self:getContentSize().width*0.7 - 10,self:getContentSize().height*0.5 + 70))
        self.m_matureBid:setPosition(ccp(910,self:getContentSize().height*0.5 + 150))
        --self.m_matureReady:setPosition(ccp(self:getContentSize().width*0.7 - 10,self:getContentSize().height*0.5 + 120))
        self.m_mature:setPosition(ccp(825,self:getContentSize().height*0.5 + 140))
		self.m_matureReady:setPosition(ccp(self:getContentSize().width*0.7 + 12,self:getContentSize().height*0.5 + 140))
    elseif self:IsLeftOne() then
        self.m_headOrginPos=ccp(-self.m_headImgSp:getContentSize().width-50,275)--ccp(-self.m_headImgSp:getContentSize().width-20,winSize.height*0.5 - 100)
        self.m_headMovePos =ccp(45,275)--ccp(20,winSize.height*0.5 - 100)
     
        self.m_readySp:setPosition(ccp(self:getContentSize().width*0.3 - 80,self:getContentSize().height*0.5 - 40))
        self.m_mature:setPosition(ccp(170,self:getContentSize().height*0.5 - 50))
        self.m_matureBid:setPosition(ccp(self:getContentSize().width*0.2,self:getContentSize().height*0.5 - 40))
        self.m_matureReady:setPosition(ccp(self:getContentSize().width*0.3 - 125,self:getContentSize().height*0.5 -50))

    elseif self:IsLeftTwo() then
        self.m_headOrginPos=ccp(-self.m_headImgSp:getContentSize().width-50,470)--ccp(-self.m_headImgSp:getContentSize().width-20,winSize.height*0.5 + 200)
        self.m_headMovePos =ccp(150,470)--ccp(260,winSize.height*0.5 + 200)
     
        self.m_readySp:setPosition(ccp(self:getContentSize().width*0.3 + 30,self:getContentSize().height*0.5 + 120))
        self.m_mature:setPosition(ccp(275,self:getContentSize().height*0.5 + 140))
        self.m_matureBid:setPosition(ccp(365,self:getContentSize().height*0.5 + 150))
        self.m_matureReady:setPosition(ccp(self:getContentSize().width*0.3 - 20,self:getContentSize().height*0.5 + 140))

    end]]

    self.m_headImgSp:setPosition(self.m_headOrginPos)
    self:addChild(self.m_headImgSp,2)
   
   self.cardType = {} --牛牛以上的牌型
    local function animationMovementEvent(armature, movementType, movementID)
        if movementType == 1 or movementType == 2 then
            armature:getAnimation():stop()
			
			if movementID == "niuniu" or movementID == "sizha" or
				movementID == "wuxiaoniu" or movementID == "wuhuaniu"then
				if self.cardType[movementID] == nil then
					self.cardType[movementID] = loadSprite("di.png")
					self.cardType[movementID]:setPosition(self.allPlayerPos[self.m_nPos][3])
					self.cardType[movementID]:setAnchorPoint(ccp(0.1,0.5))
					
					local cardType = loadSprite(movementID..".png")
					cardType:setScaleY(0.8)
					self.cardType[movementID]:addChild(cardType)
					cardType:setPosition(ccp(121,50))
					self:addChild(self.cardType[movementID],101)
					
				end
				self.cardType[movementID]:setVisible(true)
			end
        end
		cclog("m_mature movementType "..movementType)
		cclog("m_mature call back "..movementID)
    end
    self.m_mature:getAnimation():setMovementEventCallFunc(animationMovementEvent)

    local function animationMovementEvent2(armature, movementType, movementID)
        if movementType == 1 or movementType == 2 then
            armature:getAnimation():stop()
        end
    end
    self.m_matureBid:getAnimation():setMovementEventCallFunc(animationMovementEvent2)

    local function animationMovementEvent3(armature, movementType, movementID)
        if movementType == 1 or movementType == 2 then
            armature:getAnimation():stop()
        end
    end
    self.m_matureReady:getAnimation():setMovementEventCallFunc(animationMovementEvent3)

    local function animationMovementEvent4(armature, movementType, movementID)
        if movementType == 1 or movementType == 2 then
            armature:getAnimation():stop()
            armature:setVisible(false)
        end
    end
    self.m_matureWin:getAnimation():setMovementEventCallFunc(animationMovementEvent4)

    self.m_labelUsername = CCLabelTTF:create("", Resources.FONT_BLACK, Resources.FONT_SIZE17)
	self.m_labelUsername:setAnchorPoint(ccp(0.5,0))
    self.m_labelUsername:setPosition(ccp(self.m_headImgSp:getContentSize().width/2,40))
 --[[   if self:IsMe() or self:IsLeftTwo() or self:IsRightTwo() then
        self.m_labelUsername:setAnchorPoint(ccp(0,0))
        self.m_labelUsername:setPosition(ccp(110,80))
    else
        self.m_labelUsername:setAnchorPoint(ccp(0.5,0))
        self.m_labelUsername:setPosition(ccp(self.m_headImgSp:getContentSize().width/2,50))
    end]]
    self.m_labelUsername:setColor(ccc3(255, 255, 255))
    self.m_headImgSp:addChild(self.m_labelUsername)

    self.m_offLineSp = loadSprite("bull/offLine.png")
    self.m_offLineSp:setAnchorPoint(ccp(0.5,0.5))
	self.m_offLineSp:setScale(0.6)
    self.m_offLineSp:setPosition(ccp(self.m_headImgSp:getContentSize().width/2 + 15,self.m_headImgSp:getContentSize().height/2))
    self.m_offLineSp:setVisible(false)
    self.m_headImgSp:addChild(self.m_offLineSp,3)

    self.m_labelGoldBMFont = CCLabelBMFont:create("", "bull/images/number/coin_fnt.fnt")
	self.m_labelGoldBMFont:setAnchorPoint(ccp(0.5,0))
    self.m_labelGoldBMFont:setPosition(ccp(self.m_headImgSp:getContentSize().width/2,2))
 --[[   if self:IsMe() or self:IsLeftTwo() or self:IsRightTwo() then
        self.m_labelGoldBMFont:setAnchorPoint(ccp(0,0))
        self.m_labelGoldBMFont:setPosition(ccp(110,30))
    else
        self.m_labelGoldBMFont:setAnchorPoint(ccp(0.5,0))
        self.m_labelGoldBMFont:setPosition(ccp(self.m_headImgSp:getContentSize().width/2,10))
    end]]
    self.m_headImgSp:addChild(self.m_labelGoldBMFont)
    
	--庄家标识
    self.m_masterBMFont= loadSprite("bull/zhuangText.png")
	self.m_masterBMFont:setAnchorPoint(ccp(0.5,0.5))
    self.m_masterBMFont:setPosition(ccp(self.m_headImgSp:getContentSize().width - 10,self.m_headImgSp:getContentSize().height - 10))
  --[[  if self:IsMe() or self:IsRightTwo() or self:IsLeftTwo() then
        self.m_masterBMFont:setAnchorPoint(ccp(0.5,0.5))
        self.m_masterBMFont:setPosition(ccp(self.m_headImgSp:getContentSize().width/2+100,self.m_headImgSp:getContentSize().height/2+40))
    elseif self:IsRightOne() then
        self.m_masterBMFont:setAnchorPoint(ccp(0.5,0.5))
        self.m_masterBMFont:setPosition(ccp(self.m_headImgSp:getContentSize().width/2-70,self.m_headImgSp:getContentSize().height/2+70))
    elseif self:IsLeftOne() then
        self.m_masterBMFont:setAnchorPoint(ccp(0.5,0.5))
        self.m_masterBMFont:setPosition(ccp(self.m_headImgSp:getContentSize().width/2+70,self.m_headImgSp:getContentSize().height/2+70))
    end]]
    self.m_masterBMFont:setVisible(false)
    self.m_headImgSp:addChild(self.m_masterBMFont,2)

    self:timeProgressUI()

    if self:IsMe() then
        self.m_playerCardLayer = MainPlayerCardLayer.create(self,self.isReplay)
    else
        self.m_playerCardLayer = PlayerCardLayer.create(self,self.isReplay)
    end

    self.m_playerCardLayer:setAnchorPoint(ccp(0,0)) 
    self.m_playerCardLayer:setPosition(ccp(0,0))
    self:addChild(self.m_playerCardLayer)

    self.m_lastWinScoreBMFont = CCLabelBMFont:create("", "bull/images/number/yellow_coin.fnt")
    self.m_headImgSp:addChild(self.m_lastWinScoreBMFont,3)
    self.m_lastWinScoreBMFont:setVisible(false)

    self.m_lastLostScoreBMFont = CCLabelBMFont:create("", "bull/images/number/blue_coin.fnt")
    self.m_headImgSp:addChild(self.m_lastLostScoreBMFont,3)
    self.m_lastLostScoreBMFont:setVisible(false)

    if self:IsMe() or self:IsLeftOne() or self:IsLeftTwo() then
        self.m_lastWinScoreBMFont:setAnchorPoint(ccp(0,0))
        self.m_lastWinScoreBMFont:setPosition(ccp(self.m_headImgSp:getContentSize().width,0))
        self.m_lastLostScoreBMFont:setAnchorPoint(ccp(0,0))
        self.m_lastLostScoreBMFont:setPosition(ccp(self.m_headImgSp:getContentSize().width,0))
    else
        self.m_lastWinScoreBMFont:setAnchorPoint(ccp(1,0))
        self.m_lastWinScoreBMFont:setPosition(ccp(0,0))
        self.m_lastLostScoreBMFont:setAnchorPoint(ccp(1,0))
        self.m_lastLostScoreBMFont:setPosition(ccp(0,0))
    end

    --self.m_headImgSp:stopAllActions()
    --self.m_headImgSp:runAction(CCMoveTo:create(0.2, self.m_headMovePos))
end
function Player:initPossition(nMaxPlayer)
	
	self.allPlayerPos = {}
	local offsetY = 0;
	if nMaxPlayer == 2 or nMaxPlayer == 3 then
		offsetY = 100
	end
	--头像的初始位置、最终位置、牌型位置、抢庄位置、准备位置,牌的起始位置,分数位置
	self.allPlayerPos ={
		{ccp(-107,30),ccp(160,30),ccp(560,206),ccp(640,246),ccp(640,164),ccp(640,164),ccp(640,270)},
		{ccp(1387,275 + offsetY),ccp(1121,275 + offsetY),ccp(925,310 + offsetY),ccp(1024,320 + offsetY),ccp(1011,310 + offsetY),ccp(887,255 + offsetY),ccp(910,325 + offsetY)},
		{ccp(1387,470),ccp(1011,470),ccp(817,500),ccp(910,510),ccp(908,500),ccp(777,445),ccp(800,520)},
		{ccp(-157,470),ccp(150,470),ccp(275,500),ccp(365,510),ccp(364,500),ccp(238,445),ccp(470,520)},
		{ccp(-157,275 + offsetY),ccp(45,275 + offsetY),ccp(170,310 + offsetY),ccp(256,320 + offsetY),ccp(259,310 + offsetY),ccp(133,255 + offsetY),ccp(365,325 + offsetY)}	
	 }

	if nMaxPlayer == 3 then--4 = 2 3==5		
	self.allPlayerPos ={
		{ccp(-107,30),ccp(160,30),ccp(560,206),ccp(640,246),ccp(640,164),ccp(640,164),ccp(640,270)},
		{ccp(1387,275 + offsetY),ccp(1121,275 + offsetY),ccp(925,310 + offsetY),ccp(1024,320 + offsetY),ccp(1011,310 + offsetY),ccp(887,255 + offsetY),ccp(910,325 + offsetY)},
		{ccp(-157,275 + offsetY),ccp(45,275 + offsetY),ccp(170,310 + offsetY),ccp(256,320 + offsetY),ccp(259,310 + offsetY),ccp(133,255 + offsetY),ccp(365,325 + offsetY)},
		{ccp(1387,275 + offsetY),ccp(1121,275 + offsetY),ccp(925,310 + offsetY),ccp(1024,320 + offsetY),ccp(1011,310 + offsetY),ccp(887,255 + offsetY),ccp(910,325 + offsetY)},
		{ccp(-157,275 + offsetY),ccp(45,275 + offsetY),ccp(170,310 + offsetY),ccp(256,320 + offsetY),ccp(259,310 + offsetY),ccp(133,255 + offsetY),ccp(365,325 + offsetY)}	
	 }
	end
	self.m_headOrginPos = self.allPlayerPos[self.m_nPos][1]
	self.m_headMovePos = self.allPlayerPos[self.m_nPos][2]
	
	self.m_headImgSp:stopAllActions()
	self.m_headImgSp:setPosition(self.m_headMovePos)
	
	self.m_mature:setPosition(self.allPlayerPos[self.m_nPos][3])
	self.m_matureBid:setPosition(self.allPlayerPos[self.m_nPos][4])
	self.m_matureReady:setPosition(self.allPlayerPos[self.m_nPos][5])
end
--[[function Player:moveEnterHeadImgAction()
    local nMoveX = 0
    local nMoveY = 0
    if self:IsMe() then
        nMoveX = self.m_headMovePos.x + 250
        nMoveY = self.m_headMovePos.y
    elseif self:IsLeftOne() then
        nMoveX = self.m_headMovePos.x + 250
        nMoveY = self.m_headMovePos.y
    elseif self:IsLeftTwo() then
        nMoveX = self.m_headMovePos.x + 250
        nMoveY = self.m_headMovePos.y
    elseif self:IsRightOne() then
        nMoveX = self.m_headMovePos.x - 250
        nMoveY = self.m_headMovePos.y
    elseif self:IsRightTwo() then
        nMoveX = self.m_headMovePos.x - 250
        nMoveY = self.m_headMovePos.y
    end
    self.m_headImgSp:stopAllActions()
    self.m_headImgSp:runAction(CCMoveTo:create(0.1, ccp(nMoveX,nMoveY)))
end]]

--[[function Player:moveExitHeadImgAction()
    self.m_headImgSp:runAction(CCMoveTo:create(0.1, self.m_headMovePos))
end]]

function Player:IsValid()
	if self.isReplay then --回放所有用户都是有效的
		return true
	end
    --local GameLibSink =require("bull/GameLibSink")
   -- local user = GameLibSink.game_lib:getUser(self.m_nUserID)
    return self.m_nUserID >= 0 and self.m_nUserID < GameCfg.INVALID_USER_ID 
end

function Player:getHeadImageAbsoultPosition()
    local TempPoint = Resources.calAbsolutePostion(self.m_headImgSp)
    local point=ccp(TempPoint.x,TempPoint.y)
    return point
end

function Player:setUsername(szUsername)
    self.m_labelUsername:setString(Resources.cutString(szUsername, Player.NAMETEXTWIDTH, Resources.FONT_BLACK, Resources.FONT_SIZE14))
end

function Player:getUserName()
    if self.m_labelUsername then
        return self.m_labelUsername:getString()
    end
    return ""
end

function Player:setFaceID(nFaceId)
    local GameLibSink =require("bull/GameLibSink")
    local gamelib =GameLibSink.game_lib
    local pUserInfo=gamelib:getUser(self.m_nUserID)
    local nFaceId =0
    local nSex = 0
    local nUserDBID = 0

    if (pUserInfo==nil) then
        local publicUserInfo = require("Lobby/Login/LoginLogic").UserInfo --require("HallControl"):instance():getPublicUserInfo()
        nFaceId = publicUserInfo.nFaceID
        nSex = publicUserInfo.sex
        nUserDBID = publicUserInfo.UserID
    else
        nFaceId = pUserInfo:getFace()
        nSex = pUserInfo:getSex()
        nUserDBID = pUserInfo:getUserDBID()
    end 
    
    self.m_nSex = nSex

    if self.m_pFaceSprite then
        self.m_pFaceSprite:removeFromParentAndCleanup(true)
    end
    local CCUserFace = require("FFSelftools/CCUserFace")
 --   self.m_pFaceSprite = CCUserFace.create(nUserDBID, nSex, nFaceId,0, "resources/personalinf", CCSizeMake(90,90), GameLibSink.game_lib)
	self.m_pFaceSprite = CCUserFace.create(nUserDBID,CCSizeMake(90,90),nSex)
	--self.m_pFaceSprite = Resources.drawNodeRoundRect(self.m_pFaceSprite, CCRectMake(0,0,90,90), 0, 10, ccc4f(1,0,0,1), ccc4f(1,0,0,1))
 
    self.m_pFaceSprite:setAnchorPoint(ccp(0.5,0))
    self.m_pFaceSprite:setPosition(ccp(self.m_headImgSp:getContentSize().width/2,62))
--[[	if self:IsMe() or self:IsLeftTwo() or self:IsRightTwo() then
        self.m_pFaceSprite:setAnchorPoint(ccp(0,0.5))
        self.m_pFaceSprite:setPosition(ccp(10,self.m_headImgSp:getContentSize().height/2+90))
    else
        self.m_pFaceSprite:setAnchorPoint(ccp(0.5,0))
        self.m_pFaceSprite:setPosition(ccp(self.m_headImgSp:getContentSize().width/2,80+90))
    end]]
    self.m_headImgSp:addChild(self.m_pFaceSprite)
end

function Player:winPlayingState()
  --  self.m_matureWin:setVisible(true)
   -- self.m_matureWin:getAnimation():playWithIndex(0)
end

function Player:turnToOutPlayCardIsVis(bIsPlaying)
    if bIsPlaying then
        self.m_matureTouXiang:setVisible(true)
        self.m_matureTouXiang:getAnimation():gotoAndPlay(0)
    else
        self.m_matureTouXiang:setVisible(false)
        --self.m_matureTouXiang:getAnimation():stop()
    end
end

function Player:setState(nState)
    if not self:IsValid() then
        return
    end

    if (nState==nil) then
       return
    end

    cclog("::::old SetState self.m_enState="..self.m_enState.."    new nState="..nState)

    if (Player.STATE.NULL == nState) then
        self.m_mature:getAnimation():stop()
        self.m_mature:setVisible(false)

        self.m_enState = nState

        self.m_matureWin:getAnimation():stop()
        self.m_matureWin:setVisible(false)

        return
    end
    self.m_mature:setVisible(true)
    self.m_mature:getAnimation():play(nState)
    self.m_enState = nState
end

function Player:resetState()
    self.m_mature:getAnimation():stop()
    self.m_mature:setVisible(false)
	for k,v in pairs(self.cardType)  do
		if v ~= nil then
			v:setVisible(false)
		end
	end
end

function Player:setBid(isBid)
--抢庄和不抢庄两个动画的名字搞反了
    if self.m_isBid ~= isBid then
        if isBid then
            self.m_matureBid:setVisible(true)
			self.m_matureBid:getAnimation():play("buqiang")
           -- self.m_matureBid:getAnimation():play("qiangzhuang")
        else
            self.m_matureBid:setVisible(true)
          --  self.m_matureBid:getAnimation():play("buqiang")
			self.m_matureBid:getAnimation():play("qiangzhuang")
        end
        self.m_isBid = isBid
    end
end

function Player:resetBid()
    self.m_isBid = nil
    self.m_matureBid:setVisible(false)
    self.m_matureBid:getAnimation():stop()
end

function Player:getBid()
    return self.m_isBid
end

function Player:Come(nUserID)
    cclog("-->UserCome m_nPos=="..self.m_nPos.."  nUserID="..nUserID)
    self.m_nUserID = nUserID
    local GameLibSink =require("bull/GameLibSink")
    local gamelib =GameLibSink.game_lib
    local userInfo=gamelib:getUser(self.m_nUserID)
    if (userInfo==nil) then
        return
    end
	
	self.m_headImgSp:setPosition(self.m_headOrginPos)
    self.m_headImgSp:stopAllActions()
    self.m_headImgSp:runAction(CCMoveTo:create(0.2, self.m_headMovePos))

    self:setUsername(userInfo:getUserName())
    self:RefreshGold(userInfo:getGold())
    self:setFaceID(userInfo:getFace())

    self:setVisible(true)
    self.m_headImgSp:setVisible(true)
	
	self:setTouchEnabled(true)
end

function Player:Leave()
    cclog("-->UserLeave=="..self.m_nPos.."  m_nUserID=="..self.m_nUserID)
    self:setState(Player.STATE.NULL)
    if (self:IsMe()==true) then
        return
    end
    self.m_nUserID = -1
    self:setMaster(false)
    self:setIsReady(false)
    self:setIsRobot(false)
    self:turnToOutPlayCardIsVis(false)
    self:cleanAllPlayerCardLayerMj()
    if self.m_headImgSp then
        self.m_headImgSp:stopAllActions()
        self.m_headImgSp:runAction(CCMoveTo:create(0.2, self.m_headOrginPos))
    end
	self:setTouchEnabled(false)
end

function Player:cleanAllPlayerCardLayerMj()
    self.m_playerCardLayer:gameOver()
    self.m_lastWinScoreBMFont:setString("")
    self.m_lastLostScoreBMFont:setString("")
end

function Player:GameStart()
    self:setState(Player.STATE.NULL)
end

function Player:GameOver(overCallBack)
    --self:setMaster(false)
    self:setIsReady(false)
    self:setIsRobot(false)
    local bmFont=nil
    if self.m_lastWinScoreBMFont then
        local formatStr =""
        if self:IsMe() then
            SoundRes.playGlobalEffect(SoundRes.SOUND_COINCHANGE)
        end

        if self.m_nLastGold<0 then
            formatStr="-%d"
            bmFont = self.m_lastLostScoreBMFont
        else
            formatStr="+%d"
            bmFont = self.m_lastWinScoreBMFont
        end
        
        local nMoveX = self.m_headImgSp:getContentSize().width
        if self:IsRightOne() or self:IsRightTwo() then
            nMoveX = 0
        end
        local nMoveY = 50
        
        bmFont:setString(string.format(formatStr, math.abs(self.m_nLastGold)))
        local function moveFinshCallBack()
            if overCallBack~=nil then
                overCallBack()
            end
        end
        bmFont:stopAllActions()
        local array = CCArray:create()
        array:addObject(CCMoveTo:create(1, ccp(nMoveX,nMoveY)))
        array:addObject(CCDelayTime:create(3))
        array:addObject(CCCallFunc:create(moveFinshCallBack))
        bmFont:runAction(CCSequence:create(array))
    end
    
end

function Player:RefreshGold(lGold)
  --[[  if not self.isReplay and self.m_parent:getIsPrivateRoom() then
        local pUser = require("bull/GameLibSink").game_lib:getUser(self.m_nUserID)
        if pUser then
            self.m_lGold = pUser:getScore()--pUser:getScoreField(gamelibcommon.enScore_Score)
            cclog("private self.m_lGold="..self.m_lGold)
        end
    else
        self.m_lGold = lGold
    end]]
    self.m_lGold = lGold
    local szGold = Resources.formatGold(self.m_lGold, true)
    self.m_labelGoldBMFont:setString(szGold)
end

function Player:setRoomInfo(roomInfo)
    self.m_roomInfo = roomInfo
    self.m_playerCardLayer:setRoomInfo(self.m_roomInfo)
end

function Player:setMaster(bIsMaster)
    self.m_bIsMaster = bIsMaster
    if self.m_masterBMFont then
        --self.m_masterBMFont:setString(str)
        self.m_masterBMFont:setVisible(self.m_bIsMaster)
        self.m_headCircleSp:setVisible(self.m_bIsMaster)
    end
end

function Player:setCircleShow(bShow)
    self.m_headCircleSp:setVisible(bShow)
end

function Player:setWaveScore(nScore)
--[[    if nScore == 0 then
        return
    end
    local function moveFinshCallBack()
        self.m_isWaveScoreAction = false
        self.m_labelScore:removeFromParentAndCleanup(true)
        self.m_labelScore = nil
    end
    if not self.m_isWaveScoreAction then
        self.m_isWaveScoreAction = true
        local szFontFile = ""
        if (nScore > 0) then
            szFontFile = "bull/images/number/jiafen.fnt"
        else
            szFontFile = "bull/images/number/koufen.fnt"
        end
        local strScore = tostring(nScore)
        if (nScore > 0) then
            strScore = "+" .. strScore
        end
        self.m_labelScore = CCLabelBMFont:create(strScore, szFontFile)
        local fScale = 1.0
        local GameLibSink = require("bull/GameLibSink")
        if (GameLibSink.game_lib:isInPrivateRoom() == false) then
            fScale = 1.0
        end
        self.m_labelScore:setScale(fScale)
        self.m_labelScore:setAnchorPoint(ccp(0.5, 0.5))
        self.m_labelScore:setPosition(self.m_readySp:getPosition())
        if self:IsMe() or self:IsLeftOne() or self:IsLeftTwo() then
            self.m_labelScore:setAnchorPoint(ccp(0,0))
            self.m_labelScore:setPosition(ccp(self.m_headImgSp:getContentSize().width,0))
        else
            self.m_labelScore:setAnchorPoint(ccp(1,0))
            self.m_labelScore:setPosition(ccp(0,0))
        end
        --self:getGameSceneLayer():addChild(self.m_labelScore,80)
        self.m_headImgSp:addChild(self.m_labelScore,3)

        local array = CCArray:create()
        array:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(0.3), CCMoveBy:create(0.3, ccp(0, 50))))
        array:addObject(CCDelayTime:create(1))
        array:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.2, ccp(0, 50)), CCFadeOut:create(0.2)))
        array:addObject(CCCallFunc:create(moveFinshCallBack))
        self.m_labelScore:runAction(CCSequence:create(array))
    end]]
end

function Player:setBeiShu(nBeiShu)
    self.m_nBeiShu = nBeiShu
    if not self.m_isBeiShuAction then
        self.m_isBeiShuAction = true

        local strScore = tostring(nBeiShu)
        if (nBeiShu > 0) then
            strScore = "*" .. strScore
            self.m_labelBeiShuBMFont = CCLabelBMFont:create("", "bull/images/number/beishu2.fnt")
      
			self.m_labelBeiShuBMFont:setAnchorPoint(ccp(0.5,0))
            self.m_labelBeiShuBMFont:setPosition(ccp(self.m_headImgSp:getContentSize().width/2,self.m_headImgSp:getContentSize().height-30))
            self.m_labelBeiShuBMFont:setString(strScore)
            self.m_headImgSp:addChild(self.m_labelBeiShuBMFont,3)
            local array = CCArray:create()
            array:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(0.3), CCMoveBy:create(0.3, ccp(0, 50))))
            self.m_labelBeiShuBMFont:runAction(CCSequence:create(array))
        end
    end
end

function Player:resetBeiShu()
    self.m_nBeiShu = nil
    if self.m_isBeiShuAction then
        self.m_isBeiShuAction = false
        self.m_labelBeiShuBMFont:removeFromParentAndCleanup(true)
        self.m_labelBeiShuBMFont = nil
    end
end

function Player:getBeiShu()
    return self.m_nBeiShu
end

function Player:setNiuType(nType)
	cclog("setNiuType: "..nType)
    self.m_nNiuType = nType
    self:getPlayerCardLayer():showCards()
end

function Player:getNiuType()
    return self.m_nNiuType
end

function Player:resetNiuType()
    self.m_nNiuType = nil
end

function Player:setIsReady(bIsReady)
    self.m_cbReady = bIsReady
	if bIsReady then
       -- self:resetShow()
	   self:resetState()
	   self:resetNiuType()
       self.m_matureReady:setVisible(true)
       self.m_matureReady:getAnimation():play("zhunbei")
    else
       self.m_matureReady:setVisible(false)
       self.m_matureReady:getAnimation():stop()
    end
end

function Player:resetShow()
    self:resetState()
    self:resetBid()
    self:resetBeiShu()
    self:resetNiuType()
end

function Player:setIsRobot(bIsRobot)
    if self.m_robotSp then
        self.m_robotSp:setVisible(bIsRobot)
    end
end

function Player:setIsOffLine(bIsOffLine)
    if self.m_offLineSp then
        self.m_offLineSp:setVisible(bIsOffLine)
    end
end

function Player:getGameSceneLayer()
    return self.m_parent
end

function  Player:getPlayerCardLayer()
    return self.m_playerCardLayer
end

function Player:IsMe()
    return self.m_nPos==1
end

function Player:IsRightOne()
    return  self.m_nPos==2
end

function Player:IsRightTwo()
    return  self.m_nPos==3
end

function Player:IsLeftOne()
    return  self.m_nPos==5
end

function Player:IsLeftTwo()
    return  self.m_nPos==4
end

function Player:getStrLocationIp()
    local pUser = require("bull/GameLibSink").game_lib:getUser(self.m_nUserID)
    if pUser==nil then
        return ""
    end
    return "127.0.0.1"--pUser:getLocation()
end

function Player:setIsToastIp(bIsVis)
    if self.m_ipSp then
        self.m_ipSp:removeFromParentAndCleanup(true)
        self.m_ipSp = nil
    end
    if not bIsVis then
        return
    end
    
    self.m_ipSp = CCSprite:create("bull/ipBg.png")
    self.m_ipSp:setAnchorPoint(ccp(0,0))

    local ipSpContentSize = self.m_ipSp:getContentSize()
    if self:IsMe() or self:IsLeftOne() or self:IsLeftTwo() then
        self.m_ipSp:setPosition(ccp(0,-ipSpContentSize.height))
    elseif self:IsRightOne() or self:IsRightTwo() then
        self.m_ipSp:setPosition(ccp(-ipSpContentSize.width/2 - 10,-ipSpContentSize.height))
    end

    local ipLabel  = CCLabelTTF:create(self:getStrLocationIp(),Resources.FONT_BLACK,Resources.FONT_SIZE20)
    ipLabel:setAnchorPoint(ccp(0.5,0.5))
    ipLabel:setPosition(ccp(ipSpContentSize.width/2,ipSpContentSize.height/2))
    self.m_ipSp:addChild(ipLabel)
    self.m_headImgSp:addChild(self.m_ipSp)

    local function callback()
        if self.m_ipSp then
            self.m_ipSp:removeFromParentAndCleanup(true)
            self.m_ipSp = nil
        end
    end
    performWithDelay(self, callback, 5)
end

function Player:timeProgressUI()
    self.m_progress = CCProgressTimer:create(CCSprite:create("bull/timeprogress.png"))
    self.m_progress:setType(kCCProgressTimerTypeRadial)
    self.m_progress:setReverseDirection(true)
    self.m_progress:setPercentage(0)
    self.m_progress:setPosition(CCPointMake(self.m_headImgSp:getContentSize().width/2, self.m_headImgSp:getContentSize().height/2+4))
    self.m_headImgSp:addChild(self.m_progress)
end

function Player:startProgressTimer(nTimes,callBackHanlder)
    if (self.m_progress ~= nil) then
        self.m_progress:setPercentage(99.9)
        self.m_progress:stopAllActions()
        local progressTo = CCProgressTo:create(nTimes, 0)
        self.m_progress:runAction(progressTo)
        local array = CCArray:create()
        local function leftFiveMintueCallBack()
            if self:IsMe() then
               --[[ local GlobalMsg =require("bull/public/GlobalMsg")
                if (GlobalMsg:instance():getIsVibratorOpen() == true) then
                    local sJniSelfTools = CJni:shareJni()
                    sJniSelfTools:Vibrate()
                end]]
                SoundRes.playGlobalEffect(SoundRes.SOUND_CLOCKTIME)
            end
        end
        local seqAction= CCSequence:createWithTwoActions(CCDelayTime:create(nTimes - 5), CCCallFunc:create(leftFiveMintueCallBack))
        local spanAction = CCSpawn:createWithTwoActions(CCTintTo:create(nTimes, 255, 255, 0),seqAction)
        array:addObject(spanAction)

        if callBackHanlder then
            local function ProgressHanlder()
                callBackHanlder()
            end
            array:addObject(CCCallFunc:create(ProgressHanlder))
        end
        
        self.m_progress:runAction(CCSequence:create(array))

    end
end

function Player:stopProgressTimer()
    if (self.m_progress ~= nil) then
        self.m_progress:stopAllActions()
        self.m_progress:setPercentage(0)
    end
end

function Player:showPlayerDetail(faceSp, name, userid, ip, addInfo)
    require("Lobby/Info/LayerInfo").putPlayer(
               self.m_parent, 200, faceSp, name, userid, ip, addInfo):show() 
end
function Player:onTouchBegan(x,y)
    if self.m_headImgSp then
        if self.m_headImgSp:boundingBox():containsPoint(self.m_headImgSp:getParent():convertToNodeSpace(ccp(x,y))) then
			local gamelib =require("bull/GameLibSink").game_lib
			local userInfo = gamelib:getUser(self.m_nUserID)
			if userInfo == nil then return end
			
			cclog(self.m_nUserID)
			cclog(userInfo._maxim)
			local addInfo = {UserWords = userInfo._maxim}
			self:showPlayerDetail(self.m_pFaceSprite, userInfo._name, 
                               userInfo._userDBID, userInfo._userIP, addInfo)
			cclog("onTouchBegan")
        end
    end
   return true
end

function Player:onMoved(x,y)
   
end

function Player:onEnded(x,y)
end
function Player:getIsSeeCardBeforeStake()
	return self.m_parent:getIsSeeCardBeforeStake()
end
function Player.createPlayer(nPos,parent,isReplay)
    local playerLayer = Player.new()
    if playerLayer==nil then
        return nil
     end

    playerLayer.m_parent =parent
	playerLayer.isReplay =isReplay
	
    local function onNodeEvent(event)
        if event =="enter" then
        	playerLayer:onEnter()
        elseif event =="exit" then
        playerLayer:onExit()
        end	 	
    end

    local function onTouch(eventType ,x ,y)
        if eventType=="began" then
            return playerLayer:onTouchBegan(x,y)
        elseif eventType=="moved" then
            playerLayer:onMoved(x,y)
        elseif eventType=="ended" then
            playerLayer:onEnded(x,y)
        end
    end
  
    playerLayer:initUI(nPos)
    playerLayer:registerScriptHandler(onNodeEvent)
    playerLayer:setTouchEnabled(false)
    playerLayer:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,false)
    return playerLayer
end

return Player
