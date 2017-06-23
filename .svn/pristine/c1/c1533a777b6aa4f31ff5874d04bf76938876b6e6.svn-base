require("CocosExtern")

local SpeakerLabel = require("FFSelftools/SpeakerLabel")
local Resources = require("bull/Resources")

local SpeakerHistoryNode = class("SpeakerHistoryNode",function()
    return CCNode:create()
end)

function SpeakerHistoryNode:setSpeakerHistrory(historyString)	
    self.m_pDataList = historyString
	self.m_pTableView:reloadData()
	self:setVisible(true)
	--下拉效果
	self:setScaleX(1)
	self:setScaleY(0.01)
	self:runAction(CCScaleTo:create(0.3, 1, 1))
end

function SpeakerHistoryNode:initData()
    self.m_pTableView = nil
    self.m_pDataList = nil
    self.m_pBackground = nil
    self.m_rectSize = nil
    self.m_fXPrecent = 0
    self.m_fXhalfPrecent = 0
end

function SpeakerHistoryNode:getContentSize()
    if (self.m_pBackground ~= nil) then
        return self.m_pBackground:getContentSize()
    else
        return CCSizeMake(0,0)
    end
end

function SpeakerHistoryNode:boundingBox()
    return self.m_pBackground:boundingBox()
end

function SpeakerHistoryNode:scrollViewDidScroll(view)
    print("scrollViewDidScroll")
end

function SpeakerHistoryNode:scrollViewDidZoom(view)
    print("scrollViewDidZoom")
end

function SpeakerHistoryNode:tableCellTouched(t,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function SpeakerHistoryNode:cellSizeForTable(t,idx) 
    local visibSize = CCDirector:sharedDirector():getVisibleSize()
    local FONT_SIZE = 22
    local FONT_ARIAL = "Arial"
    local tmpLabel = CCLabelTTF:create(self.m_pDataList[idx + 1],FONT_ARIAL, FONT_SIZE)
	local backgroundSize = self.m_pBackground:getContentSize()
	tmpLabel:setDimensions(CCSizeMake(backgroundSize.width * self.m_fXPrecent,0))
	--CCLog("tableCellSizeForIndex %d:%f,%f",idx,tmpLabel->getContentSize().width,tmpLabel->getContentSize().height);
	return tmpLabel:getContentSize().height, tmpLabel:getContentSize().width
end

function SpeakerHistoryNode:tableCellAtIndex(t, idx)
    local cell = CCTableViewCell:new()
	local backgroundSize = self.m_pBackground:getContentSize()
    local FONT_SIZE = 22
    local FONT_ARIAL = "Arial"

    local pLabel = SpeakerLabel.create(self.m_pDataList[idx+1], FONT_ARIAL, FONT_SIZE);
    pLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
    pLabel:setTag(1)--设置Tag，如果已经生成，则直接进行设置
    pLabel:setAnchorPoint(ccp(0,0))
    cell:addChild(pLabel)
    local sysHead = Resources.DESC_GLOBAL_SYSTEM
    local speakContent = ""
    speakContent = self.m_pDataList[idx + 1]
	local bSystem = false
    local substr = string.sub(speakContent,1,4)
	if (substr ~= nil) then
		if (speakContent == sysHead) then
			bSystem = true
		end
	end
    local color = 65535
    if (bSystem == false) then
        color = 16777215
    end
    pLabel:initLabel(color , self.m_pDataList[idx + 1] , backgroundSize.width * self.m_fXPrecent)
	if (bSystem == true) then
		pLabel:setColor(ccc3(255 , 255 , 0))
    end

    return cell
end

function SpeakerHistoryNode:numberOfCellsInTableView(t)
   if (self.m_pDataList ~= nil) then
        return #self.m_pDataList
   end
   return 0
end

function SpeakerHistoryNode:init(historyString, rectSize)
    local tmpSprite = CCSprite:create(Resources.Resources_Head_Url .. "public/speaker_dropdownbackground.png")
    local contentsize = tmpSprite:getContentSize()
    local rect = CCRectMake(0,0,tmpSprite:getContentSize().width,tmpSprite:getContentSize().height)   --图片的大小
    local rectInsets = CCRectMake(14,28,3,1) --left，right，width，height
    self.m_pDataList = historyString
    self.m_rectSize = rectSize
    if (rectSize.width == 0 or rectSize.height == 0) then
    	rectSize = CCSizeMake(624,200)
    end
    self.m_pBackground= CCScale9Sprite:create(Resources.Resources_Head_Url .. "public/speaker_dropdownbackground.png",rect,rectInsets)
    self.m_pBackground:setContentSize(rectSize)
    self.m_pBackground:setPosition(ccp(self.m_pBackground:getPositionX(), self.m_pBackground:getPositionY()+6))
    self:addChild(self.m_pBackground)

    local contentSize = self.m_pBackground:getContentSize()
    self.m_pBackground:setAnchorPoint(ccp(0.5, 1))
    --调整TableView
    self.m_fXPrecent = 0.9;
    self.m_fXhalfPrecent = 0.45;
    if (self.m_rectSize.width ~= 614) then
    	self.m_fXPrecent = 0.85;
    	self.m_fXhalfPrecent = 0.425;
    end
    self.m_pTableView = CCTableView:create(CCSizeMake(contentSize.width*self.m_fXPrecent, contentSize.height*0.8))
    self.m_pTableView:setPosition(ccp(-contentSize.width*self.m_fXhalfPrecent,-contentSize.height*0.8))
    self.m_pTableView:setDirection(kCCScrollViewDirectionVertical);
    self.m_pTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    self.m_pTableView:setTouchPriority(kCCMenuHandlerPriority)
    self:addChild(self.m_pTableView)
    self.m_pTableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end,CCTableView.kTableViewScroll)
    self.m_pTableView:registerScriptHandler(function(view) return self:scrollViewDidZoom(view) end,CCTableView.kTableViewZoom)
    self.m_pTableView:registerScriptHandler(function(t,cell) return self:tableCellTouched(t,cell) end,CCTableView.kTableCellTouched)
    self.m_pTableView:registerScriptHandler(function(t,idx) return self:cellSizeForTable(t,idx) end,CCTableView.kTableCellSizeForIndex)
    self.m_pTableView:registerScriptHandler(function(t,idx) return self:tableCellAtIndex(t,idx) end,CCTableView.kTableCellSizeAtIndex)
    self.m_pTableView:registerScriptHandler(function(t) return self:numberOfCellsInTableView(t) end,CCTableView.kNumberOfCellsInTableView)  
    self.m_pTableView:reloadData()
    --下拉效果
    self:setScaleX(1)
    self:setScaleY(0.01)
    self:runAction(CCScaleTo:create(0.3, 1, 1))
end

function SpeakerHistoryNode.create(historyString, rectSize)
    local hNode = SpeakerHistoryNode.new()
    if (hNode == nil) then
        return nil
    end
    hNode:initData()
    hNode:init(historyString, rectSize)
    return hNode
end

function SpeakerHistoryNode:ccTouchBegan(x, y)
    return self.m_pTableView:ccTouchBegan(x, y)
end

function SpeakerHistoryNode:ccTouchMoved(x, y)
    self.m_pTableView:ccTouchMoved(x, y)
end

function SpeakerHistoryNode:ccTouchEnded(x, y)
    self.m_pTableView:ccTouchEnded(x, y)
end

function SpeakerHistoryNode:ccTouchCancelled(x, y)
    self.m_pTableView:ccTouchCancelled(x, y)
end

return SpeakerHistoryNode