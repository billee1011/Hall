require("CocosExtern")

local AnimationBaseLayer = require("FFSelftools/AnimationBaseLayer")
local Resources = require("bull/Resources")
local GameButton = require("bull/public/GameButton")
local CS_Message = require("bull/desk/public/CS_Message")

local DissolveDeskDialog = class("DissolveDeskDialog", function()
	return AnimationBaseLayer.create(ccc4(0,0,0,220))
end)

function DissolveDeskDialog:onTouchBegan(x,y)   
    --[[local touchPoint = ccp(x,y)
    if (self.m_pBG:boundingBox():containsPoint(touchPoint) == false) then
		self:hide(self.m_pBG)
		return true;
	end]]
	return true
end

function DissolveDeskDialog:onTouchEnd(x,y)
end

function DissolveDeskDialog:onTouchMoved(x,y)
   
end

function DissolveDeskDialog:onTouch(eventType, x, y)
    if eventType == "began" then   
        return self:onTouchBegan(x, y)
    elseif eventType == "moved" then
        self:onTouchMoved(x, y)
    else
        self:onTouchEnd(x, y)
    end
end

function DissolveDeskDialog:getDownTimeString(fDownTime)
	local nMins = math.floor(fDownTime / 60)
	local nMis = math.floor(fDownTime % 60)
	return string.format("%d:%d", nMins, nMis)
end

function DissolveDeskDialog:init(szDissolveName, vChoicePlayerNames, onBtnConfirmClickCallback, onBtnCancleClickCallback, szConfirmTextPath, szCancleTextPath)
	local function onTouch(eventType, x, y)
        return self:onTouch(eventType, x, y)
    end

    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,true)
    self:setTouchEnabled(true)

    self.m_onBtnConfirmClickCallback = onBtnConfirmClickCallback
    self.m_onBtnCancleClickCallback = onBtnCancleClickCallback

    local winsize = CCDirector:sharedDirector():getWinSize()

	self.m_pBG = CCSprite:create(Resources.Resources_Head_Url .. "dialog_bg.png")
	self.m_pBG:setPosition(ccp(winsize.width / 2, winsize.height / 2))
	self:addChild(self.m_pBG)

	local contentSize = self.m_pBG:getContentSize()

	local pTitle = CCSprite:create(Resources.Resources_Head_Url .. "DeskScene/title_disslovedesk.png")
	pTitle:setPosition(ccp(contentSize.width / 2, contentSize.height - pTitle:getContentSize().height * 1))
	self.m_pBG:addChild(pTitle)

	local ccColor = ccc3(104,33,0)
	local nFontSize = 26

	local pLabelTips = CCLabelTTF:create(string.format(Resources.DESC_DISSOLVECONTENT, szDissolveName), Resources.FONT_BLACK, nFontSize)
	pLabelTips:setColor(ccColor)
	pLabelTips:setPosition(ccp(55 + pLabelTips:getContentSize().width / 2, 295 + pLabelTips:getContentSize().height / 2))
	pLabelTips:setHorizontalAlignment(kCCTextAlignmentLeft)
	self.m_pBG:addChild(pLabelTips)

	local x = 60
	local y = 252
	local ySpace = 35
	local nMaxWid = 140
	for i = 1, #vChoicePlayerNames do
		local szName = Resources.cutString(vChoicePlayerNames[i], nMaxWid, Resources.FONT_BLACK, nFontSize)
		local pLabel = CCLabelTTF:create(string.format(Resources.DESC_PLAYERWAITCHOICE, szName), Resources.FONT_BLACK, nFontSize)
		pLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
		pLabel:setPosition(ccp(x + pLabel:getContentSize().width / 2, y + pLabel:getContentSize().height / 2))
		self.m_pBG:addChild(pLabel)
		pLabel:setColor(ccColor)
		y = y - ySpace
	end

	--[[local function onBtnCancleClickCallback(tag, target)
		local function sendDisAgree()
		end
		self:hide(self.m_pBG, sendDisAgree)
	end]]
	self.m_pBtnCancle = nil
	local function onCancleClickCallback()
		if (self.m_onBtnCancleClickCallback ~= nil) then
			self.m_onBtnCancleClickCallback()
		end
        if (szCancleTextPath ~= nil) then
		    --需要显示已拒绝
		    self.m_pBtnCancle2:setVisible(true)
		    --隐藏拒绝
		    self.m_pBtnCancle:setVisible(false)
		    --把同意置灰
		    self.m_pBtnConfirm:setEnabled(false)
        end
	end
	if (szCancleTextPath == nil) then
		self.m_pBtnCancle = GameButton.create(Resources.Resources_Head_Url .. "btn_bg1.png", Resources.Resources_Head_Url .. "text_cancle.png", 0, onCancleClickCallback)
	else
		self.m_pBtnCancle = GameButton.create(Resources.Resources_Head_Url .. "btn_bg1.png", szCancleTextPath, 0, onCancleClickCallback)
	end
	self.m_pBtnCancle2 = GameButton.create(Resources.Resources_Head_Url .. "btn_bg1.png", Resources.Resources_Head_Url .. "DeskScene/button/refuseText2.png", 0, nil)
	local function onConfirmClickCallback()
		-- body
		if (self.m_onBtnConfirmClickCallback ~= nil) then
			self.m_onBtnConfirmClickCallback()
		end
		--需要显示已同意
		self.m_pBtnConfirm2:setVisible(true)
		--隐藏同意
		self.m_pBtnConfirm:setVisible(false)
		--把拒绝置灰
		self.m_pBtnCancle:setEnabled(false)
	end
	self.m_pBtnConfirm = nil
	if (szConfirmTextPath == nil) then
		self.m_pBtnConfirm = GameButton.create(Resources.Resources_Head_Url .. "btn_bg3.png", Resources.Resources_Head_Url .. "text_commit.png", 0, onConfirmClickCallback)
	else
		self.m_pBtnConfirm = GameButton.create(Resources.Resources_Head_Url .. "btn_bg3.png", szConfirmTextPath, 0, onConfirmClickCallback)
	end
	self.m_pBtnConfirm2 = GameButton.create(Resources.Resources_Head_Url .. "btn_bg3.png", Resources.Resources_Head_Url .. "DeskScene/button/agreeText2.png", 0, nil)
	local x = (contentSize.width - self.m_pBtnCancle:getContentSize().width - self.m_pBtnConfirm:getContentSize().width - 40) / 2
	local y = 35
	self.m_pBtnCancle:setPosition(ccp(x + self.m_pBtnCancle:getContentSize().width / 2, y + self.m_pBtnCancle:getContentSize().height / 2))
	self.m_pBtnCancle2:setPosition(ccp(x + self.m_pBtnCancle2:getContentSize().width / 2, y + self.m_pBtnCancle2:getContentSize().height / 2))
	x = x + self.m_pBtnCancle:getContentSize().width * 1 + 40
	self.m_pBtnConfirm:setPosition(ccp(x + self.m_pBtnConfirm:getContentSize().width / 2, y + self.m_pBtnConfirm:getContentSize().height / 2))
	self.m_pBtnConfirm2:setPosition(ccp(x + self.m_pBtnConfirm2:getContentSize().width / 2, y + self.m_pBtnConfirm2:getContentSize().height / 2))
	self.m_pBG:addChild(self.m_pBtnCancle)
	self.m_pBG:addChild(self.m_pBtnCancle2)
	self.m_pBtnCancle2:setVisible(false)
	self.m_pBG:addChild(self.m_pBtnConfirm)
	self.m_pBG:addChild(self.m_pBtnConfirm2)
	self.m_pBtnConfirm2:setVisible(false)

	local fDownTime = 60 * 2
	self.m_pLabelDownTime = CCLabelTTF:create(self:getDownTimeString(fDownTime), Resources.FONT_BLACK, 50)
	self.m_pLabelDownTime:setColor(ccColor)
	self.m_pLabelDownTime:setHorizontalAlignment(kCCTextAlignmentLeft)
	self.m_pLabelDownTime:setPosition(ccp(450 + self.m_pLabelDownTime:getContentSize().width / 2, 205 + self.m_pLabelDownTime:getContentSize().height / 2))
	self.m_pBG:addChild(self.m_pLabelDownTime)

	local function update(dt)
		if (fDownTime > 0) then
			fDownTime = fDownTime - dt
			if (fDownTime <= 0) then
				--onBtnConfirmClickCallback()
			else
				self.m_pLabelDownTime:setString(self:getDownTimeString(fDownTime))
			end
		end
    end

    self:scheduleUpdateWithPriorityLua(update, 0)

	self:show(self.m_pBG, nil, 0.01)
end

function DissolveDeskDialog.create(szDissolveName, vChoicePlayerNames, onBtnConfirmClickCallback, onBtnCancleClickCallback, szConfirmTextPath, szCancleTextPath)
	local pDialog = DissolveDeskDialog.new()
	pDialog:init(szDissolveName, vChoicePlayerNames, onBtnConfirmClickCallback, onBtnCancleClickCallback, szConfirmTextPath, szCancleTextPath)
	return pDialog
end

return DissolveDeskDialog