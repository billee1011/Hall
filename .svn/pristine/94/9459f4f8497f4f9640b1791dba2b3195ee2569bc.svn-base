require("CocosExtern")

require("FFSelftools/controltools")
local AnimationBaseLayer = require("FFSelftools/AnimationBaseLayer")
local Resources = require("bull/Resources")
local GameButton = require("bull/public/GameButton")

local NotEnoughGoldDialog = class("NotEnoughGoldDialog", function()
	return AnimationBaseLayer.create(ccc4(0,0,0,200))
end)

NotEnoughGoldDialog.TYPE_GOLD = 1
NotEnoughGoldDialog.TYPE_DIAMOND = 2
NotEnoughGoldDialog.TYPE_ROOMCARD = 5

function NotEnoughGoldDialog:onTouchBegan(x,y)   
    local touchPoint = ccp(x,y)
    if (self.m_pBG:boundingBox():containsPoint(touchPoint) == false) then
		self:hide(self.m_pBG)
		return true;
	end
	return true;
end

function NotEnoughGoldDialog:onTouchEnd(x,y)
end

function NotEnoughGoldDialog:onTouchMoved(x,y)
   
end

function NotEnoughGoldDialog:onTouch(eventType, x, y)
    if eventType == "began" then   
        return self:onTouchBegan(x, y)
    elseif eventType == "moved" then
        self:onTouchMoved(x, y)
    else
        self:onTouchEnd(x, y)
    end
end

function NotEnoughGoldDialog:init(nType, onDismissCallback)
	local function onTouch(eventType, x, y)
        return self:onTouch(eventType, x, y)
    end

    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,true)
    self:setTouchEnabled(true)

    self.m_nType = nType or NotEnoughGoldDialog.TYPE_GOLD

    self.m_onDismissCallback = onDismissCallback

	local winsize = CCDirector:sharedDirector():getWinSize()

	self.m_pBG = CCSprite:create(Resources.Resources_Head_Url .. "dialog_bg.png")
	self.m_pBG:setPosition(ccp(winsize.width / 2, winsize.height / 2))
	self:addChild(self.m_pBG)

	local contentSize = self.m_pBG:getContentSize()

	local pTitle = nil
	if (self.m_nType == NotEnoughGoldDialog.TYPE_GOLD) then
		pTitle = CCSprite:create(Resources.Resources_Head_Url .. "title_notenough.png")
	elseif (self.m_nType == NotEnoughGoldDialog.TYPE_ROOMCARD) then
        pTitle = CCSprite:create(Resources.Resources_Head_Url .. "title_notenoughroomcard.png")
	else
		pTitle = CCSprite:create(Resources.Resources_Head_Url .. "title_notenoughdiamond.png")
	end
	pTitle:setPosition(ccp(contentSize.width / 2, contentSize.height - pTitle:getContentSize().height * 1))
	self.m_pBG:addChild(pTitle)

	local pLabelTips = nil
	if (self.m_nType == NotEnoughGoldDialog.TYPE_GOLD) then
		pLabelTips = CCLabelTTF:create("您的金币太少了,补充点金币再来吧", Resources.FONT_BLACK, 30)
	elseif (self.m_nType == NotEnoughGoldDialog.TYPE_ROOMCARD) then
        pLabelTips = CCLabelTTF:create("您的房卡太少了,补充点房卡再来吧", Resources.FONT_BLACK, 30)
	else
		pLabelTips = CCLabelTTF:create("您的钻石太少了,补充点钻石再来吧", Resources.FONT_BLACK, 30)
	end
	pLabelTips:setColor(ccc3(104,33,0))
	pLabelTips:setPosition(ccp(contentSize.width / 2, contentSize.height * 0.65))
	self.m_pBG:addChild(pLabelTips)

	local pGoldIcon = nil
	if (self.m_nType == NotEnoughGoldDialog.TYPE_GOLD) then
		pGoldIcon = CCSprite:create(Resources.Resources_Head_Url .. "goldimg.png")
		pGoldIcon:setPosition(ccp(contentSize.width / 2, contentSize.height * 0.4))
	elseif (nType == NotEnoughGoldDialog.TYPE_ROOMCARD) then
        pGoldIcon = CCSprite:create("resources/new/fangkaLargh.png")
        pGoldIcon:setPosition(ccp(contentSize.width / 2, contentSize.height * 0.45))
	else
		pGoldIcon = CCSprite:create(Resources.Resources_Head_Url .. "diamondimg.png")
		pGoldIcon:setPosition(ccp(contentSize.width / 2, contentSize.height * 0.4))
	end
	
	self.m_pBG:addChild(pGoldIcon)

	local function onBtnCancleClickCallback(tag, target)
		self:hide(self.m_pBG)
	end
	local function onBtnCommitClickCallback(tag, target)
		self:hide(self.m_pBG, self.m_onDismissCallback(self.m_nType))
	end
	local pBtnCancle = GameButton.create(Resources.Resources_Head_Url .. "btn_bg1.png", Resources.Resources_Head_Url .. "text_cancle.png", 0, onBtnCancleClickCallback)
	local pBtnCommit = GameButton.create(Resources.Resources_Head_Url .. "btn_bg3.png", Resources.Resources_Head_Url .. "text_commit.png", 0, onBtnCommitClickCallback)

	local x = (contentSize.width - pBtnCancle:getContentSize().width - pBtnCommit:getContentSize().width - 40) / 2
	local y = contentSize.height * 0.175
	pBtnCancle:setPosition(ccp(x + pBtnCancle:getContentSize().width / 2, y))
	x = x + pBtnCancle:getContentSize().width + 40
	pBtnCommit:setPosition(ccp(x + pBtnCommit:getContentSize().width / 2, y))
	self.m_pBG:addChild(pBtnCancle)
	self.m_pBG:addChild(pBtnCommit)

	self:show(self.m_pBG, nil, 0.01)
end

function NotEnoughGoldDialog.create(nType, onDismissCallback)
	local pDialog = NotEnoughGoldDialog.new()
	pDialog:init(nType, onDismissCallback)
	return pDialog
end

return NotEnoughGoldDialog