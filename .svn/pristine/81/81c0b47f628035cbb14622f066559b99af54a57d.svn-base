require("CocosExtern")
require("FFSelftools/controltools")
require("bull/desk/PropertyTools")

local CS_Message = require("bull/desk/public/CS_Message")
local GameCfg = require("bull/desk/public/GameCfg")

local Resources = require("bull/Resources")
local CCUserFace = require("FFSelftools/CCUserFace")
local VIPCalc = require("bull/public/VIPCalc")

local AnimationBaseLayer = require("FFSelftools/AnimationBaseLayer")

local PersonInfoFrame = class("PersonInfoFrame", function()
	return AnimationBaseLayer.create(ccc4(0, 0, 0, 100))
end)

PersonInfoFrame.BTN_ADDFRIEND_TAG =10

function PersonInfoFrame:onTouchBegan(x,y)   
    local touchPoint = ccp(x,y)
	if (self.m_pBg:boundingBox():containsPoint(touchPoint) == false) then
		self:hide(self.m_pBg)
		return true
	end
	return true
end

function PersonInfoFrame:onTouchEnd(x,y)
end

function PersonInfoFrame:onTouchMoved(x,y)
   
end

function PersonInfoFrame:onTouch(eventType, x, y)
    if eventType == "began" then   
        return self:onTouchBegan(x, y)
    elseif eventType == "moved" then
        self:onTouchMoved(x, y)
    else
        self:onTouchEnd(x, y)
    end
end

function PersonInfoFrame:getUserID()
	return self.m_wUserID
end

function PersonInfoFrame:sendProperty(nPropertyID) 

    -- local stProperty=CS_Message.ST_Property:new()
    -- stProperty.nPropertyID = nPropertyID;
    -- stProperty.cbToChair = self.m_pUserInfo:getUserChair()
    --local ba =stProperty:Serialize(stProperty.nPropertyID,stProperty.cbToChair)

    local ba = CS_Message.ST_Property:write(nPropertyID,self.m_pUserInfo:getUserChair())
    local GameLibSink =require("bull/GameLibSink")
    GameLibSink.game_lib:sendGameCmd(CS_Message.CMD_PROPERTY, ba:getBuf(),ba:getLen())
    self:removeFromParentAndCleanup(true)

    --  --//测试代码
    -- local PropertyAnimationLayer = require("bull/desk/PropertyAnimationLayer")
    -- local propertyAnimationLayer = PropertyAnimationLayer.createPropertyAnimationLayerLayer()
    -- local parent = self:getParent():getParent()
    -- propertyAnimationLayer:setProperty(parent.m_aclsPlayer[1], parent.m_aclsPlayer[2], nPropertyID)
    -- CCDirector:sharedDirector():getRunningScene():addChild(propertyAnimationLayer)
    
end

function PersonInfoFrame:init(wUserID, vPropertyInfos, scene)

	local function onTouch(eventType, x, y)
        return self:onTouch(eventType, x, y)
    end

    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,true)
	self:setTouchEnabled(true)
	
	self.m_vPropertyInfos = vPropertyInfos
	self.m_wUserID = wUserID
	self.m_scene = scene
	self.sPropertyTools = PropertyTools.instance()

    --头像背景
    local isMe = false
    local gameLib = require("bull/GameLibSink").game_lib
    local pMyself = gameLib:getMyself()
    if (pMyself ~= nil) then
        if (pMyself:getUserID() == wUserID) then
            isMe = true
        end
    end

    local pUserInfo = gameLib:getUser(wUserID)
    if (pUserInfo == nil) then
        return
    end

    self.m_pUserInfo = pUserInfo

	--初始化各种信息组件
	local winsize = CCDirector:sharedDirector():getWinSize()
    local bgImgStr = "bull/bullResources/DeskScene/personalinfo/myinfo_bg.png"
    -- if isMe then
    --     bgImgStr = "bull/bullResources/DeskScene/personalinfo/myinfo_bg.png" 
    -- else
    --     bgImgStr = "bull/bullResources/DeskScene/personalinfo/otherinfo_bg.png"
    -- end
	self.m_pBg = CCSprite:create(bgImgStr)
	self.m_pBg:setPosition(ccp(winsize.width / 2, winsize.height / 2))
	self:addChild(self.m_pBg)
	local contentSize = self.m_pBg:getContentSize()
	

	local function onPropertyControlCallback(first, target, event)
		if (target == nil) then
			return
		end
		local pUserInfo = gameLib:getUser(self.m_wUserID)
		if (pUserInfo == nil) then
			return
		end
		local nChair = pUserInfo:getUserChair()
		if (GameCfg.Pub_IsValidChair(nChair) == false) then
			return
		end
		local tag = target:getTag()
		local nMyGold = 0
		local pMySelf = gameLib:getMyself()
		if (pMySelf == nil) then
			return
		end
		nMyGold = pMySelf:getGold()
		local myChair = pMySelf:getUserChair()
        self:sendProperty(tag)
	end

	local function onControlCallback(first, target, event)
		local pUser = gameLib:getUser(self.m_wUserID)
		if (pUser == nil) then
			return
		end
		local pMySelf = gameLib:getMyself()
		if (pMySelf == nil) then
			return
		end
		local tag = target:getTag()
		if (tag == self.BTN_ADDFRIEND_TAG) then
			self:removeFromParentAndCleanup(true)
			gameLib:applyFriend(pUser:getUserDBID())
		end	
	end

    local sex = pUserInfo:getSex()
    local nHeadBGX = 85
    local faceSize = CCSizeMake(100,85)
    local pHeadSp = CCControlButton:create()
    pHeadSp:setPreferredSize(faceSize)
    pHeadSp:setAnchorPoint(ccp(0.5,0.5))
    pHeadSp:setPosition(ccp(85, contentSize.height - 100))
    local function onFacePressCallback(emptyStr,target,event)
        if (pUserInfo ~= nil) then
            local ShowPicLayer = require("bull/public/ShowPicLayer")
            local layer = ShowPicLayer.create(pUserInfo:getUserDBID(), pUserInfo:getSex(), pUserInfo:getFace(), pUserInfo:getUserFaceChangeIndex())
            CCDirector:sharedDirector():getRunningScene():addChild(layer,5)
        end
    end
    pHeadSp:addHandleOfControlEvent(onFacePressCallback, CCControlEventTouchUpInside)
    pHeadSp:setTouchPriority(kCCMenuHandlerPriority)
    self.m_pBg:addChild(pHeadSp)

	--头像
  	local faceSprite = CCUserFace.create(pUserInfo:getUserDBID())--, 
	--	pUserInfo:getSex(), pUserInfo:getFace(), pUserInfo:getUserFaceChangeIndex(),"resources/personalinf" , faceSize, gameLib)
    faceSprite:setPosition(ccp(nHeadBGX, contentSize.height-faceSprite:boundingBox().size.height-20))
    self.m_pBg:addChild(faceSprite)

    local pSexIcon = nil
	if (sex == gamelibcommon.SX_BOY) then
		pSexIcon = CCSprite:create("bull/bullResources/DeskScene/personalinfo/male.png")
	else
		pSexIcon = CCSprite:create("bull/bullResources/DeskScene/personalinfo/female.png")
	end
	pSexIcon:setPosition(ccp(contentSize.width * 0.4, contentSize.height * 0.7))
	self.m_pBg:addChild(pSexIcon)

    local textColor = ccc3(126, 44, 0)
    local FONT_SIZE = 20
    
    --昵称
    local pLabelNickName = CCLabelTTF:create("昵称: ", Resources.FONT_ARIAL_BOLD, FONT_SIZE)
    pLabelNickName:setPosition(ccp(pSexIcon:getPositionX() + pSexIcon:getContentSize().width, pSexIcon:getPositionY()))
    pLabelNickName:setColor(textColor)
    pLabelNickName:setHorizontalAlignment(kCCTextAlignmentLeft)
    pLabelNickName:setAnchorPoint(ccp(0,0.5))
    self.m_pBg:addChild(pLabelNickName)

	self.m_pLabelName = CCLabelTTF:create(pUserInfo:getUserName(), Resources.FONT_ARIAL_BOLD, FONT_SIZE)
	self.m_pLabelName:setColor(textColor)
	self.m_pLabelName:setPosition(ccp(pLabelNickName:getPositionX()+pLabelNickName:getContentSize().width, pSexIcon:getPositionY()))
	self.m_pLabelName:setAnchorPoint(ccp(0, 0.5))
	self.m_pBg:addChild(self.m_pLabelName)

    local DstPosY=0
    
 --    local pLabelGoldText = CCLabelTTF:create("金币:", Resources.FONT_ARIAL_BOLD, FONT_SIZE)
 --    pLabelGoldText:setPosition(ccp(pLabelNickName:getPositionX(), self.m_pLabelName:getPositionY() - pLabelGoldText:getContentSize().height * 1.5-DstPosY))
 --    pLabelGoldText:setColor(textColor)
 --    pLabelGoldText:setHorizontalAlignment(kCCTextAlignmentLeft)
	-- pLabelGoldText:setAnchorPoint(ccp(0,0.5))
 --    self.m_pBg:addChild(pLabelGoldText)

 --    self.m_pLabelGold = CCLabelTTF:create(Resources.formatGold(pUserInfo:getGold(), true), Resources.FONT_ARIAL_BOLD, FONT_SIZE)
 --    self.m_pLabelGold:setPosition(ccp(pLabelGoldText:getPositionX() + pLabelGoldText:getContentSize().width - 5, pLabelGoldText:getPositionY()))
 --    self.m_pLabelGold:setColor(ccc3(249, 184, 0))
 --    self.m_pLabelGold:setHorizontalAlignment(kCCTextAlignmentLeft)
	-- self.m_pLabelGold:setAnchorPoint(ccp(0,0.5))
 --    self.m_pBg:addChild(self.m_pLabelGold)

	--用户ID
	local m_pID = CCLabelTTF:create(string.format("ID：%d",pUserInfo:getUserDBID()), Resources.FONT_ARIAL_BOLD, FONT_SIZE)
	m_pID:setColor(textColor)
	m_pID:setPosition(ccp(pLabelNickName:getPositionX(), pLabelNickName:getPositionY() - m_pID:getContentSize().height * 1.5 -DstPosY))
	m_pID:setAnchorPoint(ccp(0, 0.5))
	self.m_pBg:addChild(m_pID)

	self.m_pLabelIP = CCLabelTTF:create("IP: ".."pUserInfo.IPAddress", Resources.FONT_ARIAL_BOLD, FONT_SIZE)
    self.m_pLabelIP:setPosition(ccp(pLabelNickName:getPositionX(), m_pID:getPositionY() - self.m_pLabelIP:getContentSize().height * 1.5 -DstPosY))
    self.m_pLabelIP:setColor(textColor)
    self.m_pLabelIP:setHorizontalAlignment(kCCTextAlignmentLeft)
	self.m_pLabelIP:setAnchorPoint(ccp(0,0.5))
    self.m_pBg:addChild(self.m_pLabelIP)

	--胜率
	-- local winCount = pUserInfo:getScoreField(gamelibcommon.enScore_Win)
	-- local loseCount = pUserInfo:getScoreField(gamelibcommon.enScore_Loss)
	-- local totalRound = winCount + loseCount + pUserInfo:getScoreField(gamelibcommon.enScore_Draw)

 --    local pLabelTotalRound = CCLabelTTF:create(string.format("牌局：%d", totalRound), Resources.FONT_ARIAL, FONT_SIZE)
 --    pLabelTotalRound:setPosition(ccp(pLabelGoldText:getPositionX(), m_pID:getPositionY() - self.m_pLabelGold:getContentSize().height * 1.5 -DstPosY))
	-- pLabelTotalRound:setColor(textColor)
	-- pLabelTotalRound:setAnchorPoint(ccp(0, 0.5))
	-- self.m_pBg:addChild(pLabelTotalRound)

	-- local str = "胜率：0%"
	-- if (totalRound > 0) then
	-- 	str = string.format("胜率：%d%%", ((winCount * 1.0 / totalRound) * 100))
	-- end
	-- self.m_pLabelWinRate = CCLabelTTF:create(str, Resources.FONT_ARIAL, FONT_SIZE)
	-- self.m_pLabelWinRate:setPosition(
	-- 		ccp(pLabelTotalRound:getPositionX() + pLabelTotalRound:getContentSize().width * 1.5, pLabelTotalRound:getPositionY()))
	-- self.m_pLabelWinRate:setColor(textColor)
	-- self.m_pLabelWinRate:setAnchorPoint(ccp(0, 0.5))
	-- self.m_pBg:addChild(self.m_pLabelWinRate)

 
    local CCCheckbox = require("FFSelftools/CCCheckbox")
    local x = contentSize.width / 7.5-25
	if (isMe == false) then
		-- local size = #vPropertyInfos
		-- if (size >= 0) then
		-- 	for i = 1, 5 do
		-- 		--道具使用框
  --               local pTools_1 = createButtonWithFilePath(string.format("bull/bullResources/DeskScene/property/property_icon_%d.png",i),i,onPropertyControlCallback) 
	 --            pTools_1:setPosition(ccp(x + pTools_1:getContentSize().width / 2, contentSize.height * 0.2-5))
  --               pTools_1:setTag(i)
  --               pTools_1:setScale(1.3)
  --               x = x + pTools_1:getContentSize().width + 35
	 --            self.m_pBg:addChild(pTools_1)
  --               pTools_1:setTouchPriority(kCCMenuHandlerPriority)
  --               pTools_1:setEnabled(true)
		-- 	end
		-- end

  --      local TextButton = require("FFSelftools/TextButton")
        local y = faceSprite:getPositionY()
        local scale = 0.7
		local pMySelf = gameLib:getMyself()
		if (pMySelf == nil) then
			return true
		end
		local myStatus = pMySelf:getUserStatus()
		local bMePlaying = false
		if (myStatus == gamelibcommon.USER_PLAY_GAME) then
			bMePlaying = true
		end
		
  --       if (gameLib:isMyFriend(pUserInfo:getUserDBID()) == false) then
		-- 	--加为好友按钮
  --           local btn_agree = TextButton.create("bull/bullResources/DeskScene/personalinfo/btn_addfriend.png", nil, Resources.FONT_ARIAL_BOLD, 30, self.BTN_ADDFRIEND_TAG, onControlCallback)
  --           btn_agree:setPosition(ccp(contentSize.width/2-50,50))
	 --        self.m_pBg:addChild(btn_agree)
  --           btn_agree:setScale(scale)
	 --        btn_agree:setTouchPriority(kCCMenuHandlerPriority)
		-- end
	end

	self:show(self.m_pBg)
end

PersonInfoFrame.create = function(wUserID, vPropertyInfos, scene)
	local frame = PersonInfoFrame.new()
	frame:init(wUserID, vPropertyInfos, scene)
	return frame
end

return PersonInfoFrame