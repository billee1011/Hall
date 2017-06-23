require("CocosExtern")

require("FFSelftools/controltools")
local AnimationBaseLayer = require("FFSelftools/AnimationBaseLayer")
local Resources = require("bull/Resources")
local GameLibSink = require("bull/GameLibSink")
local HallControl = require("HallControl"):instance()
local GameButton = require("bull/public/GameButton")
local CCUserFace = require("FFSelftools/CCUserFace")

local InviteOnlineFriendDialog = class("InviteOnlineFriendDialog", function()
	return AnimationBaseLayer.create(ccc4(0,0,0,200))
end)

function InviteOnlineFriendDialog:onTouchBegan(x,y)   
    local touchPoint = ccp(x,y)
    if (self.m_pBG:boundingBox():containsPoint(touchPoint) == false) then
		self:hide(self.m_pBG)
		return true;
	end
	return true;
end

function InviteOnlineFriendDialog:onTouchEnd(x,y)
end

function InviteOnlineFriendDialog:onTouchMoved(x,y)
   
end

function InviteOnlineFriendDialog:onTouch(eventType, x, y)
    if eventType == "began" then   
        return self:onTouchBegan(x, y)
    elseif eventType == "moved" then
        self:onTouchMoved(x, y)
    else
        self:onTouchEnd(x, y)
    end
end

function InviteOnlineFriendDialog:tableCellAtIndex(t, i)
	local cell = t:dequeueCell()

    if(nil == cell) then
        cell = CCTableViewCell:new()
	else
		cell:removeAllChildrenWithCleanup(true)
    end

    local stFriendInfo = nil--self.m_vRankInfos[i + 1]
    local pBG = CCSprite:create(Resources.Resources_Head_Url .. "invitefriend/inviteitem_bg.png")
    pBG:setAnchorPoint(ccp(0,0))
    --pBG:setPosition(ccp(pBG:getContentSize().width / 2, pBG:getContentSize().height / 2))
    cell:addChild(pBG)

    local gameLib = GameLibSink.m_gameLib

    local publicUserInfo = HallControl:getPublicUserInfo()

	local pUserFace = nil
    if (publicUserInfo ~= nil) then
        pUserFace = CCUserFace.create(publicUserInfo.userDBID, publicUserInfo.sex, 
            publicUserInfo.nFaceID, 0, "resources/personalinf", CCSizeMake(70,70) , gameLib)
    else
        pUserFace = CCUserFace.createDefault("resources/personalinf", CCSizeMake(70,70))
    end
	local pHead = Resources.drawNodeRoundRect(pUserFace, CCRectMake(0,0,70,70), 0, 10, ccc4f(1,0,0,1), ccc4f(1,0,0,1))
	pHead:setPosition(ccp(35, 30 + 70))
	pBG:addChild(pHead)

	local pLabelName = CCLabelTTF:create(publicUserInfo.nickName, Resources.FONT_BLACK, 30)
	pLabelName:setColor(ccc3(104,33,0))
	pBG:addChild(pLabelName)
	pLabelName:setHorizontalAlignment(kCCTextAlignmentLeft)
	pLabelName:setAnchorPoint(ccp(0,0.5))
	pLabelName:setPosition(ccp(110, pBG:getContentSize().height / 2))

	local function onBtnInviteClickCallback(tag, target)

	end
	local pBtnInvite = GameButton.create(Resources.Resources_Head_Url .. "btn_bg5.png", Resources.Resources_Head_Url .. "invitefriend/text_invite.png", 0, onBtnInviteClickCallback)
	pBtnInvite:setPosition(ccp(pBG:getContentSize().width - pBtnInvite:getContentSize().width / 2 - 10, pBG:getContentSize().height / 2))
	pBG:addChild(pBtnInvite)

    return cell
end

function InviteOnlineFriendDialog:init()
	local function onTouch(eventType, x, y)
        return self:onTouch(eventType, x, y)
    end

    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,true)
    self:setTouchEnabled(true)

	local winsize = CCDirector:sharedDirector():getWinSize()

	self.m_pBG = CCSprite:create(Resources.Resources_Head_Url .. "invitefriend/invite_bg.png")
	self.m_pBG:setPosition(ccp(winsize.width / 2, winsize.height / 2))
	self:addChild(self.m_pBG)

	local contentSize = self.m_pBG:getContentSize()

	local pTitle = CCSprite:create(Resources.Resources_Head_Url .. "invitefriend/title_inviteonlinefriend.png")
	pTitle:setPosition(ccp(contentSize.width / 2, contentSize.height - pTitle:getContentSize().height * 0.75))
	self.m_pBG:addChild(pTitle)

    local function onBtnBackClickCallback(first, target, event)
        self:hide(self.m_pBG)
    end
    local pBtnBack = createButtonWithFilePath(Resources.Resources_Head_Url .. "guanbi.png", 0, onBtnBackClickCallback)
    pBtnBack:setPosition(ccp(contentSize.width - pBtnBack:getContentSize().width / 4, contentSize.height - pBtnBack:getContentSize().height * 0.75))
    self.m_pBG:addChild(pBtnBack)

    local function onBtnClickCallback(...)

    end
    local pBtnInviteWeixin = createButtonWithSingleFile(Resources.Resources_Head_Url .. "invitefriend/btn_inviteweixin.png", 2, 0, onBtnClickCallback)
    pBtnInviteWeixin:setPosition(ccp(contentSize.width / 2, 40))
    self.m_pBG:addChild(pBtnInviteWeixin)

    local pItemBG = CCSprite:create(Resources.Resources_Head_Url .. "invitefriend/inviteitem_bg.png")
	self.m_itemSize = pItemBG:getContentSize()
	self.m_pTableView = CCTableView:create(CCSizeMake(self.m_itemSize.width, 450))
    self.m_pBG:addChild(self.m_pTableView)
    self.m_pTableView:setVerticalFillOrder(kCCTableViewFillTopDown) 
    self.m_pTableView:setAnchorPoint(ccp(0, 0))
    self.m_pTableView:setPosition(ccp(45, 100))
    self.m_pTableView:setTouchPriority(kCCMenuHandlerPriority)

    local function cellSizeForTable(t,idx)
    	--cclog("111111111111111111111111")
        return self.m_itemSize.height - 5, self.m_itemSize.width
    end

    local function numberOfCellsInTableView()
        --return #self.m_vRankInfos
        --cclog("22222222222222222222")
        return 10
    end

    local function tableCellAtIndex(t, i)
    	--cclog("33333333333333333333333333")
        return self:tableCellAtIndex(t, i)
    end 

    self.m_pTableView:registerScriptHandler(cellSizeForTable, CCTableView.kTableCellSizeForIndex)
    self.m_pTableView:registerScriptHandler(tableCellAtIndex, CCTableView.kTableCellSizeAtIndex)
    self.m_pTableView:registerScriptHandler(numberOfCellsInTableView, CCTableView.kNumberOfCellsInTableView)
    self.m_pTableView:reloadData() 

    self:show(self.m_pBG, nil, 0.01)
end

function InviteOnlineFriendDialog.create()
	local pDialog = InviteOnlineFriendDialog.new()
	pDialog:init()
	return pDialog
end

return InviteOnlineFriendDialog