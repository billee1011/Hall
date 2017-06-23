require("CocosExtern")

local AnimationBaseLayer = require("FFSelftools/AnimationBaseLayer")
local Resources = require("bull/Resources")
local GameButton = require("bull/public/GameButton")

local TipsDialog = class("TipsDialog", function()
	return AnimationBaseLayer.create(ccc4(0,0,0,220))
end)

function TipsDialog:onTouchBegan(x,y)   
    local touchPoint = ccp(x,y)
    if (self.m_pBG:boundingBox():containsPoint(touchPoint) == false) then
		self:hide(self.m_pBG, self.m_touchOutsizeDismissCallback)
		return true
	end
	return true
end

function TipsDialog:onTouchEnd(x,y)
end

function TipsDialog:onTouchMoved(x,y)
   
end

function TipsDialog:onTouch(eventType, x, y)
    if eventType == "began" then   
        return self:onTouchBegan(x, y)
    elseif eventType == "moved" then
        self:onTouchMoved(x, y)
    else
        self:onTouchEnd(x, y)
    end
end

function TipsDialog:setSaveData(nData)
    self.m_nSave = nData
end

function TipsDialog:getSaveData()
    return self.m_nSave
end

function TipsDialog:addObject(pObject, pos)

end

function TipsDialog:init(szTitlePath, szTipsContent, onConfirmClickCallback, bIsShowCancle, szTextConfirmPath, szTextCanclePath, touchOutsizeDismissCallback)
	local function onTouch(eventType, x, y)
        return self:onTouch(eventType, x, y)
    end

    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority-1,true)
    self:setTouchEnabled(true)

    self.m_onConfirmClickCallback = onConfirmClickCallback
    bIsShowCancle = bIsShowCancle or false
    self.m_nSave = -1
    self.m_touchOutsizeDismissCallback = touchOutsizeDismissCallback

    local winsize = CCDirector:sharedDirector():getWinSize()
	self.m_pBG = CCSprite:create(Resources.Resources_Head_Url .. "dialog_bg.png")
	self.m_pBG:setPosition(ccp(winsize.width / 2, winsize.height / 2))
	self:addChild(self.m_pBG)

	local contentSize = self.m_pBG:getContentSize()

    if (szTitlePath ~= nil) then
    	local pTitle = CCSprite:create(szTitlePath)
    	pTitle:setPosition(ccp(contentSize.width / 2, contentSize.height - pTitle:getContentSize().height * 1))
    	self.m_pBG:addChild(pTitle)
        pTitle:setZOrder(1)
    end

    local ccLabelColor1 = ccc3(97,69,53)
    local pLabelContent = CCLabelTTF:create(szTipsContent, Resources.FONT_BLACK, 30)
    pLabelContent:setPosition(ccp(contentSize.width / 2, contentSize.height * 0.5))
    pLabelContent:setDimensions(CCSizeMake(contentSize.width * 0.75, 0))
    self.m_pBG:addChild(pLabelContent)
    pLabelContent:setColor(ccLabelColor1)

    local function onBtnConfirmClickCallback(tag, target)
    	self:hide(self.m_pBG, self.m_onConfirmClickCallback)
    end
    local pBtnConfirm = nil
    if (szTextConfirmPath ~= nil) then
        pBtnConfirm = GameButton.create(Resources.Resources_Head_Url .. "btn_bg3.png", szTextConfirmPath, 0, onBtnConfirmClickCallback)
    else
        pBtnConfirm = GameButton.create(Resources.Resources_Head_Url .. "btn_bg3.png", Resources.Resources_Head_Url .. "text_commit.png", 0, onBtnConfirmClickCallback)
    end
    self.m_pBG:addChild(pBtnConfirm)
    if (bIsShowCancle == false) then
        pBtnConfirm:setPosition(ccp(contentSize.width / 2, contentSize.height * 0.15))
    else
        local function onBtnCancleClickCallback(tag, target)
            self:hide(self.m_pBG)
        end
        local pBtnCancle = nil
        if (szTextCanclePath ~= nil) then
            pBtnCancle = GameButton.create(Resources.Resources_Head_Url .. "btn_bg1.png", szTextCanclePath, 0, onBtnCancleClickCallback)
        else
            pBtnCancle = GameButton.create(Resources.Resources_Head_Url .. "btn_bg1.png", Resources.Resources_Head_Url .. "text_cancle.png", 0, onBtnCancleClickCallback)
        end
        self.m_pBG:addChild(pBtnCancle)

        local y = contentSize.height * 0.2
        local x = (contentSize.width - pBtnConfirm:getContentSize().width - pBtnCancle:getContentSize().width - 40) / 2
        pBtnCancle:setPosition(ccp(x + pBtnCancle:getContentSize().width / 2, y))
        x = x + pBtnConfirm:getContentSize().width + 40
        pBtnConfirm:setPosition(ccp(x + pBtnConfirm:getContentSize().width / 2, y))
    end

    self:show(self.m_pBG, nil, 0.01)
end

function TipsDialog.create(szTitlePath, szTipsContent, onConfirmClickCallback, bIsShowCancle, szTextConfirmPath, szTextCanclePath, touchOutsizeDismissCallback)
	local pDialog = TipsDialog.new()
	pDialog:init(szTitlePath, szTipsContent, onConfirmClickCallback, bIsShowCancle, szTextConfirmPath, szTextCanclePath, touchOutsizeDismissCallback)
	return pDialog
end

return TipsDialog