require("CocosExtern")

local Resources = require("bull/Resources")

local RewardDialog = class("RewardDialog", function()
	return CCLayer:create()
end)

function RewardDialog:onTouchBegan(x,y)   
    local touchPoint = ccp(x,y)
    if (self.m_pBG:boundingBox():containsPoint(touchPoint) == false) then
		self:hide(self.m_pBG)
		return true
	end
	return true
end

function RewardDialog:onTouchEnd(x,y)
end

function RewardDialog:onTouchMoved(x,y)
   
end

function RewardDialog:onTouch(eventType, x, y)
    if eventType == "began" then   
        return self:onTouchBegan(x, y)
    elseif eventType == "moved" then
        self:onTouchMoved(x, y)
    else
        self:onTouchEnd(x, y)
    end
end

function RewardDialog:init(szIconPath, nAwardAmount)
	local function onTouch(eventType, x, y)
        return self:onTouch(eventType, x, y)
    end

    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,true)
    self:setTouchEnabled(true)

	local winsize = CCDirector:sharedDirector():getWinSize()

	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(Resources.Resources_Head_Url .. "public/rewardDialog/LingQu/LingQu.ExportJson")
	self.m_pBG = CCArmature:create("LingQu")
	self.m_pBG:getAnimation():playWithIndex(0) --//播放第一个动作  

	local function animationMovementEvent(armature, movementType, movementID)
        self:removeFromParentAndCleanup(true)
    end
	self.m_pBG:getAnimation():setMovementEventCallFunc(animationMovementEvent)
	self:addChild(self.m_pBG)
	self.m_pBG:setPosition(ccp(winsize.width / 2, winsize.height / 2))

	local contentSize = self.m_pBG:getContentSize()

	local pIcon = CCSprite:create(szIconPath)
	pIcon:setPosition(ccp(self:getContentSize().width / 2, self:getContentSize().height / 2))
	self:addChild(pIcon)
	pIcon:setScale(0.5)
	self:runTargetAction(pIcon)

	local pLabelAward = CCLabelBMFont:create(nAwardAmount, Resources.Resources_Head_Url .. "mall/buygold_num.fnt")
	pLabelAward:setPosition(ccp(self:getContentSize().width / 2, pIcon:getPositionY() - pIcon:getContentSize().height / 2 - 15))
	self:addChild(pLabelAward)
	pLabelAward:setScale(0.5)
	self:runTargetAction(pLabelAward)
end

function RewardDialog:runTargetAction(pTarget)
	local array = CCArray:create()
	array:addObject(CCFadeOut:create(0))
	array:addObject(CCDelayTime:create(0.2))
	array:addObject(CCFadeIn:create(0))
	array:addObject(CCScaleTo:create(0.2, 1))
	array:addObject(CCDelayTime:create(2.5))
	array:addObject(CCScaleTo:create(0.5, 0))
	pTarget:runAction(CCSequence:create(array))
end

function RewardDialog.create(szIconPath, nAwardAmount)
	local pDialog = RewardDialog.new()
	pDialog:init(szIconPath, nAwardAmount)
	return pDialog
end

return RewardDialog