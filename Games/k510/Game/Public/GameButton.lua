require("CocosExtern")
local Resources = require("Resources")

local GameButton = class("GameButton", function()
	return CCLayer:create()
end)

function GameButton:onTouchBegan(x,y)
	if self:isVisible() == false then return false end
	if (self.m_bIsEnabled == false) then return false end

	self.m_bTouchMove=false
	self.m_touchBeginPoint =ccp(x,y)
	if self.m_pNormalBGSp:boundingBox():containsPoint(self.m_pNormalBGSp:getParent():convertToNodeSpace(self.m_touchBeginPoint))==true then
	  	self.m_pNormalBGSp:setVisible(false)  
	  	self.m_pPressBGSp:setVisible(true)
        if (self.m_pContentNormalSp ~= nil) then
	  	    self.m_pContentNormalSp:setVisible(false)  
        end
        if (self.m_pContentPressSp ~= nil) then
	  	    self.m_pContentPressSp:setVisible(true)
        end
		return true
	else
		return false
	end
	return false
end

function GameButton:onMoved(x,y)
   if math.abs(self.m_touchBeginPoint.x-x)>=20 or math.abs(self.m_touchBeginPoint.y-y)>=20  then
	  	self.m_bTouchMove=true
   end
   if self.m_pNormalBGSp:boundingBox():containsPoint(self.m_pNormalBGSp:getParent():convertToNodeSpace(self.m_touchBeginPoint))==true then
   		self.m_pPressBGSp:setVisible(true)
   		self.m_pNormalBGSp:setVisible(false)  

        if (self.m_pContentNormalSp ~= nil) then
	  	    self.m_pContentNormalSp:setVisible(false)  
        end
        if (self.m_pContentPressSp ~= nil) then
	  	    self.m_pContentPressSp:setVisible(true)
        end
   else
   		self.m_pNormalBGSp:setVisible(true)  
  		self.m_pPressBGSp:setVisible(false)

        if (self.m_pContentNormalSp ~= nil) then
	  	    self.m_pContentNormalSp:setVisible(true)  
        end
        if (self.m_pContentPressSp ~= nil) then
	  	    self.m_pContentPressSp:setVisible(false)
        end
   end
end

function GameButton:onEnded(x,y)
	if self.m_pNormalBGSp:boundingBox():containsPoint(self.m_pNormalBGSp:getParent():convertToNodeSpace(self.m_touchBeginPoint))==true then
		if self.m_bTouchMove==false then
		   	if self.m_actionCallBack~=nil then
				self.m_actionCallBack(self:getTag(),self)
		  	end
		end
	end
	self.m_pNormalBGSp:setVisible(true)  
  	self.m_pPressBGSp:setVisible(false)

    if (self.m_pContentNormalSp ~= nil) then
	  	self.m_pContentNormalSp:setVisible(true)  
    end
    if (self.m_pContentPressSp ~= nil) then
	  	self.m_pContentPressSp:setVisible(false)
    end
end

function GameButton:resetTouchPriorty(p,cbSwallow)
	self:registerScriptTouchHandler(self.onTouch,false,p,cbSwallow)
	self:setTouchEnabled(false)
	self:setTouchEnabled(true)
end

function GameButton:setEnabled(bIsEnabled)
	if (self.m_bIsEnabled == bIsEnabled) then
		return
	end
	self.m_bIsEnabled = bIsEnabled
	if (bIsEnabled == true) then
		self.m_pNormalBGSp:setVisible(true)
		self.m_pPressBGSp:setVisible(false)

        if (self.m_pContentNormalSp ~= nil) then
	  	    self.m_pContentNormalSp:setVisible(true)  
        end
        if (self.m_pContentPressSp ~= nil) then
	  	    self.m_pContentPressSp:setVisible(false)
        end
	else
		self.m_pNormalBGSp:setVisible(false)
		self.m_pPressBGSp:setVisible(true)

        if (self.m_pContentNormalSp ~= nil) then
	  	    self.m_pContentNormalSp:setVisible(false)  
        end
        if (self.m_pContentPressSp ~= nil) then
	  	    self.m_pContentPressSp:setVisible(true)
        end
	end
end

function GameButton:isEnabled()
	return self.m_bIsEnabled
end


function GameButton:init(szBGUrl, pContentUrl, tag, actionCallBack)
	self.m_pNormalBGSp = CCSprite:create(szBGUrl)
    self.m_pPressBGSp = CCSprite:create(szBGUrl)

  	local function onTouch(eventType ,x ,y)
		if eventType=="began" then
			return self:onTouchBegan(x,y)
		elseif eventType=="moved" then
			self:onMoved(x,y)
		elseif eventType=="ended" then
			self:onEnded(x,y)
		end
  	end

  	self.m_actionCallBack = actionCallBack
	self.onTouch = onTouch
	self:setTouchEnabled(true)
	self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,true)

	local contentSize = self.m_pNormalBGSp:getContentSize()
	self:setContentSize(contentSize)

	self.m_pNormalBGSp:setAnchorPoint(ccp(0.5,0.5))
	self:addChild(self.m_pNormalBGSp)

	self.m_pPressBGSp:setAnchorPoint(ccp(0.5,0.5))
	self.m_pPressBGSp:setVisible(false)
	self:addChild(self.m_pPressBGSp)

	self.m_pContentNormalSp = CCSprite:create(pContentUrl)
    self.m_pContentPressSp = CCSprite:create(pContentUrl)

	self.m_pContentNormalSp:setAnchorPoint(ccp(0.5,0.5))
	self.m_pContentNormalSp:setVisible(true)
	self:addChild(self.m_pContentNormalSp)

	self.m_pContentPressSp:setAnchorPoint(ccp(0.5,0.5))
	self.m_pContentPressSp:setVisible(false)
	self:addChild(self.m_pContentPressSp)

    self.m_bIsEnabled = true
    self.m_bTouchMove = false
    self.m_bIsChecked = false
    self.m_nGold = 0

    self.m_touchBeginPoint = ccp(0,0)

    self:setTag(tag)
end

function GameButton.create(szBGUrl, pContentUrl, tag, actionCallBack)
	local pButton = GameButton.new()
	pButton:init(szBGUrl, pContentUrl, tag, actionCallBack)
	return pButton
end

return GameButton