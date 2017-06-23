require("CocosExtern")

require("FFSelftools/controltools")
local AnimationBaseLayer = require("FFSelftools/AnimationBaseLayer")

local InviteFriendDialog = class("InviteOnlineFriendDialog", function()
	return AnimationBaseLayer.create(ccc4(0,0,0,200))
end)

function InviteFriendDialog:onTouchBegan(x,y)   
    local touchPoint = ccp(x,y)
    if (self.m_pBG:boundingBox():containsPoint(touchPoint) == false) then
		self:hide(self.m_pBG)
		return true;
	end
	return true;
end

function InviteFriendDialog:onTouchEnd(x,y)
end

function InviteFriendDialog:onTouchMoved(x,y)
   
end

function InviteFriendDialog:onTouch(eventType, x, y)
    if eventType == "began" then   
        return self:onTouchBegan(x, y)
    elseif eventType == "moved" then
        self:onTouchMoved(x, y)
    else
        self:onTouchEnd(x, y)
    end
end

function InviteFriendDialog:init(szDownloadPath, szInviteGameName, szInviteTitle, szInviteContent, szDialogBGPath, szBtnHaoyouPath, szBtnPengyouPath, szTitlePath, szBtnClosePath)
	local function onTouch(eventType, x, y)
        return self:onTouch(eventType, x, y)
    end

    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,true)
    self:setTouchEnabled(true)

	local winsize = CCDirector:sharedDirector():getWinSize()

	self.m_pBG = nil
    if (szDialogBGPath ~= nil) then
        self.m_pBG = CCSprite:create(szDialogBGPath)
    else
        self.m_pBG = CCSprite:create("resources/new/small_bg.png")
    end
	self.m_pBG:setPosition(ccp(winsize.width / 2, winsize.height / 2))
	self:addChild(self.m_pBG)

	local contentSize = self.m_pBG:getContentSize()

	local pTitle = nil
    if (szTitlePath ~= nil) then
        pTitle = CCSprite:create(szTitlePath)
    else
        pTitle = CCSprite:create("resources/new/share/title_share.png")
    end
	pTitle:setPosition(ccp(contentSize.width / 2, contentSize.height - pTitle:getContentSize().height * 0.75))
	self.m_pBG:addChild(pTitle)

    local function onBtnBackClickCallback(first, target, event)
        self:hide(self.m_pBG)
    end
    local pBtnBack = nil
    if (szBtnClosePath ~= nil) then
        pBtnBack = createButtonWithFilePath(szBtnClosePath, 0, onBtnBackClickCallback)
    else
        pBtnBack = createButtonWithFilePath("resources/new/guanbi_1.png", 0, onBtnBackClickCallback)
    end
    pBtnBack:setPosition(ccp(contentSize.width - pBtnBack:getContentSize().width / 4, contentSize.height - pBtnBack:getContentSize().height * 0.85))
    self.m_pBG:addChild(pBtnBack)

    local function onBtnClickCallback(first, target, event)
        --scene : 0表示分享给好友，1表示分享至朋友圈
        local tag = target:getTag()
        CJni:shareJni():shareWeixin(tag,2,nil,0,string.format("%s?game=%s&roomid=%d", szDownloadPath, szInviteGameName, -1),szInviteTitle,szInviteContent)
    end
    local pBtnInviteHY = nil
    if (szBtnHaoyouPath ~= nil) then
        pBtnInviteHY = createButtonWithFilePath(szBtnHaoyouPath, 0, onBtnClickCallback)
    else
        pBtnInviteHY = createButtonWithFilePath("resources/new/share/hy.png", 0, onBtnClickCallback)
    end
    self.m_pBG:addChild(pBtnInviteHY)

    if (szBtnPengyouPath ~= nil) then
        pBtnInvitePY = createButtonWithFilePath(szBtnPengyouPath, 0, onBtnClickCallback)
    else
        pBtnInvitePY = createButtonWithFilePath("resources/new/share/py.png", 1, onBtnClickCallback)
    end
    self.m_pBG:addChild(pBtnInvitePY)

    local x = (contentSize.width - pBtnInviteHY:getContentSize().width - pBtnInvitePY:getContentSize().width - 100) / 2
    local y = contentSize.height * 0.4

    pBtnInviteHY:setPosition(ccp(x + pBtnInviteHY:getContentSize().width / 2, y))
    x = x + pBtnInviteHY:getContentSize().width + 100
    pBtnInvitePY:setPosition(ccp(x + pBtnInvitePY:getContentSize().width / 2, y))

    self:show(self.m_pBG, nil, 0.01)
end

function InviteFriendDialog.create(szDownloadPath, szInviteGameName, szInviteTitle, szInviteContent, szDialogBGPath, szBtnHaoyouPath, szBtnPengyouPath, szTitlePath, szBtnClosePath)
	local pDialog = InviteFriendDialog.new()
	pDialog:init(szDownloadPath, szInviteGameName, szInviteTitle, szInviteContent, szDialogBGPath, szBtnHaoyouPath, szBtnPengyouPath, szTitlePath, szBtnClosePath)
	return pDialog
end

return InviteFriendDialog