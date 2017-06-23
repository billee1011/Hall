require("CocosExtern")

local Resources = require("bull/Resources")
local AnimationBaseLayer = require("FFSelftools/AnimationBaseLayer")
--local TextButton = require("FFSelftools/TextButton")
local GameButton = require("bull/public/GameButton")

local BaseDialog = class("BaseDialog", function()
	return AnimationBaseLayer.create(ccc4(0, 0, 0, 200))
end)

function BaseDialog:onTouchBegan(x,y)   
    local pTouch = ccp(x, y)
	local touchPoint = self:convertToNodeSpace(pTouch);
	if (self.m_pBG ~= nil) then
		if (self.m_pBG:boundingBox():containsPoint(touchPoint) == false) then
			self:hide(self.m_pBG)
			return true
		end
	end
    return true;
end

function BaseDialog:onTouchEnd(x,y)
end

function BaseDialog:onTouchMoved(x,y)
   
end

function BaseDialog:onTouch(eventType, x, y)
    if eventType == "began" then   
        return self:onTouchBegan(x, y)
    elseif eventType == "moved" then
        self:onTouchMoved(x, y)
    else
        self:onTouchEnd(x, y)
    end
end

function BaseDialog:init(szTipsContent, szConfirm, szCancel, onControlCallback)
	local function onTouch(eventType, x, y)
        return self:onTouch(eventType, x, y)
    end

    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,true)
    self:setTouchEnabled(true)

	local winsize = CCDirector:sharedDirector():getWinSize()

	self.m_pBG = CCSprite:create(Resources.Resources_Head_Url .. "commondialog/commondialog_bg.png")
	self.m_pBG:setPosition(ccp(winsize.width * 0.5, winsize.height * 0.5));
	self:addChild(self.m_pBG);

    local contentSize = self.m_pBG:getContentSize()

	if (szTipsContent ~= nil) then
		local pLabelTips = CCLabelTTF:create(szTipsContent, Resources.FONT_ARIAL_BOLD, 30)
		pLabelTips:setPosition(ccp(contentSize.width * 0.5, contentSize.height * 0.6))
	    pLabelTips:setDimensions(CCSizeMake(contentSize.width - 100, 0))
		pLabelTips:setColor(ccc3(194,216,253))
		self.m_pBG:addChild(pLabelTips)
	end

	if (szConfirm == nil) then
		szConfirm = Resources.DESC_CONFIRM
	end

	if (szCancel == nil) then
		szCancel = Resources.DESC_CANCEL
	end

	if (nConfirmTag == nil) then
		nConfirmTag = 0
	end

	if (nCancelTag == nil) then
		nCancelTag = 1
	end

	local textColor = ccc3(140, 75, 2)
	local function onCancelCallback(first, target, event)
		self:hide(self.m_pBG)
	end
--[[	local btnCancel = TextButton.create(Resources.Resources_Head_Url .. "btn_bg1.png", szCancel, Resources.FONT_ARIAL_BOLD, 
        30, nCancelTag, onCancelCallback)
    btnCancel:setPosition(ccp(x, y))
	self.m_pBG:addChild(btnCancel)
	btnCancel:setTouchPriority(kCCMenuHandlerPriority)
	x = x + btnCancel:getContentSize().width + 50

    local btn = TextButton.create(Resources.Resources_Head_Url .. "btn_bg3.png", szConfirm, Resources.FONT_ARIAL_BOLD,
     30, nConfirmTag, onControlCallback, ccc3(137,74,3), textColor)
    local x = (contentSize.width - btn:getContentSize().width * 2 - 50) / 2
    local y = contentSize.height * 0.15
    btn:setPosition(ccp(x, y))
	self.m_pBG:addChild(btn)
	btn:setTouchPriority(kCCMenuHandlerPriority)]]

    self:show(self.m_pBG, nil, 0.01)
end

function BaseDialog:initByTextImage(szTipsContent, szTextConfirmUrl, szTextCancelUrl, onControlCallback)
	local function onTouch(eventType, x, y)
        return self:onTouch(eventType, x, y)
    end

    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,true)
    self:setTouchEnabled(true)

	local winsize = CCDirector:sharedDirector():getWinSize()

	self.m_pBG = CCSprite:create(Resources.Resources_Head_Url .. "commondialog/commondialog_bg.png")
	self.m_pBG:setPosition(ccp(winsize.width * 0.5, winsize.height * 0.5));
	self:addChild(self.m_pBG);

    local contentSize = self.m_pBG:getContentSize()

	if (szTipsContent ~= nil) then
		local pLabelTips = CCLabelTTF:create(szTipsContent, Resources.FONT_ARIAL_BOLD, 30)
		pLabelTips:setPosition(ccp(contentSize.width * 0.5, contentSize.height * 0.6))
	    pLabelTips:setDimensions(CCSizeMake(contentSize.width - 100, 0))
		pLabelTips:setColor(ccc3(121,37,21))
		self.m_pBG:addChild(pLabelTips)
	end

	if (szConfirm == nil) then
		szConfirm = Resources.DESC_CONFIRM
	end

	if (szCancel == nil) then
		szCancel = Resources.DESC_CANCEL
	end

	if (nConfirmTag == nil) then
		nConfirmTag = 0
	end

	if (nCancelTag == nil) then
		nCancelTag = 1
	end

	local textColor = ccc3(140, 75, 2)

	local function onCancelCallback(first, target, event)
		self:hide(self.m_pBG)
	end
	local btnCancel = GameButton.create(Resources.Resources_Head_Url .. "btn_bg1.png", szTextCancelUrl, 0, onCancelCallback)
    
	local x = (contentSize.width - btnCancel:getContentSize().width * 2 - 50) / 2 + 140
    local y = contentSize.height * 0.15

    btnCancel:setPosition(ccp(x, y))
	self.m_pBG:addChild(btnCancel)
	btnCancel:setTouchPriority(kCCMenuHandlerPriority)
	x = x + btnCancel:getContentSize().width + 50

    local btn = GameButton.create(Resources.Resources_Head_Url .. "btn_bg3.png", szTextConfirmUrl, 0, onControlCallback)
    btn:setPosition(ccp(x, y))
	self.m_pBG:addChild(btn)
	btn:setTouchPriority(kCCMenuHandlerPriority)

    self:show(self.m_pBG, nil, 0.01)
end

function BaseDialog.createByTextImage(szTipsContent, szTextConfirmUrl, szTextCancelUrl, onControlCallback)
	local dialog = BaseDialog.new()
	dialog:initByTextImage(szTipsContent, szTextConfirmUrl, szTextCancelUrl, onControlCallback)
	return dialog
end

function BaseDialog.create(szTipsContent, szConfirm, szCancel, onControlCallback)
	local dialog = BaseDialog.new()
	dialog:init(szTipsContent, szConfirm, szCancel, onControlCallback)
	return dialog
end

return BaseDialog