
require("FFSelftools/controltools")
local Resources =require("bull/Resources")
local SoundRes  = require("bull/SoundRes")

local GameCfg =require("bull/desk/public/GameCfg")
local GameDefs = require("bull/GameDefs")
local SendCMD = require("bull/SendCMD")
local CCButton = require("FFSelftools/CCButton")
local GameButtonLayer =class("GameButtonLayer", function()
        return CCLayer:create()
        end)

--BTN TAG
GameButtonLayer.BT_ROBOTCACEL=21--取消托管
GameButtonLayer.BT_ROBOT = 22 --托管
GameButtonLayer.BT_BULLYES=27--有牛
GameButtonLayer.BT_BULLNO=28--没牛

GameButtonLayer.BT_BIDYES=29 --抢庄
GameButtonLayer.BT_BIDNO=30	 -- 夺庄
GameButtonLayer.BT_1BEI=31
GameButtonLayer.BT_2BEI=32
GameButtonLayer.BT_3BEI=33
GameButtonLayer.BT_5BEI=34
GameButtonLayer.BT_10BEI=35 

GameButtonLayer.BT_AUTOSORT = 36 --提示自动组牌
GameButtonLayer.BT_MAX=37

function GameButtonLayer:onEnter()
    self:initUI()
end

function GameButtonLayer:onExit()
end

function GameButtonLayer:init(parent)
    self.m_gameScene = parent
    local function onNodeEvent(event)
       if event =="enter" then
          self:onEnter()
       elseif event =="exit" then
          self:onExit()
       end        
    end
    self:registerScriptHandler(onNodeEvent)
    self.m_nGangType=0
    self.m_nGangCard=0
 
    self.m_nEatCurrCard=0
    self.m_vEatCase={}

    self.m_vShowButtonTag={} --显示按钮Tag，不包含过按钮
    self.m_vButtonConstantXPos={}

    self.m_onBullYesCallBack = nil
    self.m_onBullNoCallBack = nil
    self.m_onBidYesCallBack = nil
    self.m_onBidNoCallBack = nil
    self.m_on1BeiCallBack = nil
    self.m_on2BeiCallBack = nil
	self.m_on3BeiCallBack = nil
    self.m_on5BeiCallBack = nil
    self.m_on10BeiCallBack = nil
end

function GameButtonLayer:initUI()
    local function onStartGame() --开始游戏
        SoundRes.playGlobalEffect(SoundRes.SOUND_PASS)
        SendCMD.sendCMD_PO_RESTART()
        self:setOneButtonIsVis(GameButtonLayer.BT_STARTGAME,false)
    end
    local function onBullYes()
        if self.m_onBullYesCallBack then
            self.m_onBullYesCallBack()
        end
    end
    local function onBullNo()
        if self.m_onBullNoCallBack then
            self.m_onBullNoCallBack()
        end
    end
    local function onAutoSort()
        if self.m_onAutoSortCallBack then
            self.m_onAutoSortCallBack()
        end
    end
    local function onBidYes()
        if self.m_onBidYesCallBack then
            self.m_onBidYesCallBack()
        end
    end
    local function onBidNo()
        if self.m_onBidNoCallBack then
            self.m_onBidNoCallBack()
        end
    end
    local function on1Bei()
        if self.m_on1BeiCallBack then
            self.m_on1BeiCallBack()
        end
    end
    local function on2Bei()
        if self.m_on2BeiCallBack then
            self.m_on2BeiCallBack()
        end
    end
	    local function on3Bei()
        if self.m_on3BeiCallBack then
            self.m_on3BeiCallBack()
        end
    end
    local function on5Bei()
        if self.m_on5BeiCallBack then
            self.m_on5BeiCallBack()
        end
    end
    local function on10Bei()
        if self.m_on10BeiCallBack then
            self.m_on10BeiCallBack()
        end
    end
    local winSize =CCDirector:sharedDirector():getWinSize()
	local nGameButtonY = 200
    local bntInfo=
    {
	--[[	{ 
            imgBg="bull/bullyes.png",armatureName=nil,tag=GameButtonLayer.BT_BULLYES,
            vis=false,pos=ccp(winSize.width - 280,115),bntCallBack = onBullYes
        },
        { 
            imgBg="bull/bullno.png",armatureName=nil,tag=GameButtonLayer.BT_BULLNO,
            vis=false,pos=ccp(winSize.width - 280,115),bntCallBack = onBullNo
        },]]
        { --自动组牌提示
            imgBg="bull/showCard.png",armatureName=nil,tag=GameButtonLayer.BT_AUTOSORT,
            vis=false,pos=ccp(winSize.width - 280,65),bntCallBack = onAutoSort
        },
        { 
            imgBg="bull/bidyes.png",armatureName=nil,tag=GameButtonLayer.BT_BIDYES,
            vis=false,pos=ccp(450,nGameButtonY),bntCallBack = onBidYes
        },
        { 
            imgBg="bull/bidno.png",armatureName=nil,tag=GameButtonLayer.BT_BIDNO,
            vis=false,pos=ccp(winSize.width - 602,nGameButtonY),bntCallBack = onBidNo
        },
        { 
            imgBg="bull/1bei.png",armatureName=nil,tag=GameButtonLayer.BT_1BEI,
            vis=false,pos=ccp(290,nGameButtonY),bntCallBack = on1Bei
        },
        { 
            imgBg="bull/2bei.png",armatureName=nil,tag=GameButtonLayer.BT_2BEI,
            vis=false,pos=ccp(470,nGameButtonY),bntCallBack = on2Bei
        },
		{ 
            imgBg="bull/3bei.png",armatureName=nil,tag=GameButtonLayer.BT_3BEI,
            vis=false,pos=ccp(650,nGameButtonY),bntCallBack = on3Bei
        },
        { 
            imgBg="bull/5bei.png",armatureName=nil,tag=GameButtonLayer.BT_5BEI,
            vis=false,pos=ccp(650,nGameButtonY),bntCallBack = on5Bei
        },
        { 
            imgBg="bull/10bei.png",armatureName=nil,tag=GameButtonLayer.BT_10BEI,
            vis=false,pos=ccp(830,nGameButtonY),bntCallBack = on10Bei
        },
    }

    local btnSize =#bntInfo
    local animationButton = nil
    for i=1,btnSize,1 do
		animationButton = CCButton.createWithFrame(bntInfo[i].imgBg,false,bntInfo[i].bntCallBack)
		--AnimationButton.create(bntTable.imgBg,bntTable.armatureName,bntTable.tag,bntTable.bntCallBack) 	
        animationButton:setAnchorPoint(ccp(0,0))
        animationButton:setPosition(bntInfo[i].pos)
        animationButton:setTag(bntInfo[i].tag)
        animationButton:setVisible(bntInfo[i].vis)
        self:addChild(animationButton)
    end
	
    --私人场语音按钮
    if  self.m_gameScene:getIsPrivateRoom() then
		self.talkButton =  require("bull/common/LayerVoice").create()
		CCDirector:sharedDirector():getRunningScene():addChild(self.talkButton,-1)
    end
	
	
    --定位
	--[[self.locationBtn = CCButton.createCCButtonByFrameName("paoHuZi/anniu_dingwei.png", 
		"paoHuZi/anniu_dingwei_dk.png", "paoHuZi/anniu_dingwei.png",function()
		local GameLibSink = require("bull/GameLibSink")
		local mySelf = GameLibSink.game_lib:getMyself()
		
		local userList = require("HallUtils").tableDup(GameLibSink:getTableUserList(mySelf._tableID))
		local users = {}
		for k, v in pairs(userList) do
			if v ~= 0 then
            table.insert(users, v)
			end
		end
		require("Lobby/Info/LayerLocation").put(self.m_gameScene, 200, 
        3, users, mySelf._chairID):show()
       end)
	self.locationBtn:setPosition(ccp(winSize.width - 50,280))
	self:addChild(self.locationBtn)
	local animFrames = CCArray:create()
    for i = 1,6 do
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(
            string.format("paoHuZi/anniu_dingwei_%d.png", i))
        animFrames:addObject(frame)
    end
    local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.1)
    local animate = CCAnimate:create(animation);
    self.locationBtn.m_normalSp:runAction(CCRepeatForever:create(animate))]]
  
	--聊天
	self.chatBtn = CCButton.createWithFrame("public/btnGameChat1.png",false,function() 
		self.m_gameScene.layerChat:show()
    end)
	self.chatBtn:setPosition(ccp(winSize.width - 50,180))
	self:addChild(self.chatBtn)
	self.m_gameScene.layerChat = require("bull/common/LayerChat").put(CCDirector:sharedDirector():getRunningScene(),20)
	self.m_gameScene.layerChat.layerShow = require("bull/common/LayerChatShow").put(CCDirector:sharedDirector():getRunningScene(),20)
	
	-- 返回大厅按钮
	self.backHomeBtn = CCButton.createCCButtonByFrameName("public/anniu_tuichu.png", 
		"public/anniu_tuichu_dk.png", "public/anniu_tuichu_dk.png",function()
		require("bull/GameLibSink"):returnToLobby()
	end)
 --   self.backHomeBtn = CCButton.createWithFrame("public/anniu_tuichu.png",false,function()
--		require("bull/GameLibSink"):returnToLobby()
--	end)
	--self.backHomeBtn:setAnchorPoint(ccp(0.5,1))
    self.backHomeBtn:setPosition(ccp(477,winSize.height - 45))
    self:addChild(self.backHomeBtn)
	
--	local layerMoreBtn = require("bull/common/LayerMoreBtn").create(self.m_gameScene,10)
--	layerMoreBtn:showLayer(not layerMoreBtn.isShow)
	--更多按钮
	 self.moreBtn =  CCButton.createWithFrame("public/btn_more1.png",false,function()
		local layerMoreBtn = require("bull/common/LayerMoreBtn").create(self,9)--self.m_gameScene
		layerMoreBtn:showLayer(not layerMoreBtn.isShow)
	end)
    self.moreBtn:setPosition(ccp(799,winSize.height - 45))
    self:addChild(self.moreBtn,10)

	--邀请微信好友
	self.inviteBtn = CCButton.createWithFrame("public/invitebtn0.png",false,function()
		if require("Lobby/FriendGame/FriendGameLogic").invite_code then
			local msg, titile, roominfo = require("bull/LayerDeskRule").getInviteMsg()
			 local url = require("AppConfig").WXMsg.App_Url..roominfo
			 
			 local now, all = self.m_gameScene:getPlayerCount()
             if now > 0 and now < all then 
                local tipMsgs = {"一", "二", "三", "四",}
               titile = titile.."，"..tipMsgs[now].."缺"..tipMsgs[(all - now)] 
             end
			cclog("%s -- %s -- %s", titile, msg, url)			
			if shareWebToWx then
				shareWebToWx(1, url, titile, msg, function() end)
			else
				CJni:shareJni():shareWxWeb(1, url, titile, msg, function() end)
			end
		end
	end)
    self.inviteBtn:setPosition(ccp(winSize.width / 2,winSize.height/2 - 50))
    self:addChild(self.inviteBtn)
	self.inviteBtn:setVisible(false)
end
function GameButtonLayer:setRobotCancelCallBack(robotCancelCallBack)
    self.m_robotCancelCallBack = robotCancelCallBack
end
function GameButtonLayer:setBullYesCallBack(bullCallBack)
    self.m_onBullYesCallBack = bullCallBack
end
function GameButtonLayer:setBullNoCallBack(bullCallBack)
    self.m_onBullNoCallBack = bullCallBack
end
function GameButtonLayer:setAutoSortCallBack(autoSortCallBack)
    self.m_onAutoSortCallBack = autoSortCallBack
end
function GameButtonLayer:setBidYesCallBack(callBack)
    self.m_onBidYesCallBack = callBack
end
function GameButtonLayer:setBidNoCallBack(callBack)
    self.m_onBidNoCallBack = callBack
end
function GameButtonLayer:set1BeiCallBack(callBack)
    self.m_on1BeiCallBack = callBack
end
function GameButtonLayer:set2BeiCallBack(callBack)
    self.m_on2BeiCallBack = callBack
end
function GameButtonLayer:set3BeiCallBack(callBack)
    self.m_on3BeiCallBack = callBack
end
function GameButtonLayer:set5BeiCallBack(callBack)
    self.m_on5BeiCallBack = callBack
end
function GameButtonLayer:set10BeiCallBack(callBack)
    self.m_on10BeiCallBack = callBack
end

function GameButtonLayer:getOneButtonIsVis(nTag)
    local button = self:getChildByTag(nTag)
    if button then
        return button:isVisible()
    end  
    return false
end
--设置某一个按钮是否可见
function GameButtonLayer:setOneButtonIsVis(nTag,bIsVisible)
    local button = self:getChildByTag(nTag)
    if button then
        if button.setBtnIsVisible~=nil then
            button:setBtnIsVisible(bIsVisible)
        else
            button:setVisible(bIsVisible)
        end
    end
end

-- 设置按钮是否能点击
function GameButtonLayer:setButtonIsEnabled(nTag,bIsEnabled)
    if self:getChildByTag(nTag) then
        self:getChildByTag(nTag):setEnabled(bIsEnabled)
    end
end
--设置所有游戏状态按钮是否可见
function GameButtonLayer:setAllGameButtonIsVis(bIsVisible)
    for i=1,GameButtonLayer.BT_MAX do
	local btn = self:getChildByTag(i)
        if btn ~= nil then
			btn:setVisible(bIsVisible)
        end
    end
end
function GameButtonLayer:setMaxStake(nMaxStake)
	local btn = self:getChildByTag(GameButtonLayer.BT_5BEI)
	if nMaxStake == 5 then		
		if btn then 
			btn:setPosition(ccp(830,200))
		end
	else
		if btn then 
			btn:setPosition(ccp(650,200))
		end
	end
end
function GameButtonLayer.createGameButtonLayer(parent)
    local gameButtonLayer = GameButtonLayer.new()
    if gameButtonLayer ==nil then
        return nil
    end
    gameButtonLayer:init(parent)
    return gameButtonLayer
end

return GameButtonLayer
