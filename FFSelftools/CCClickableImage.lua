
require("CocosExtern")

local CCClickableImage = class("CCClickableImage",function()
        local cc = CCControl:new()
        cc:init()
        return cc
    end)


function CCClickableImage:isTouchInside(touch)
    if(self:getParent() == nil) then
        return false
    end
    local touchLocation = self:getParent():convertToNodeSpace(touch)
    local bBox = self:boundingBox()
    return bBox:containsPoint(touchLocation)
end

function CCClickableImage:onTouchBegan(x,y)   
	local pTouch = ccp(x, y) 
	local isInside = self:isTouchInside(pTouch)
	--print("isEnabled = " , self:isEnabled())
	print("isVisible = " , self:isVisible())
	--print("isInside = ", isInside)
	if (isInside == false or self:isEnabled() == false or self:isVisible() == false) then
		return false       --不再传递给后面的处理函数，传递给下一节点
	end
    return true
end

function CCClickableImage:onTouchEnd(x,y)
	local pTouch = ccp(x, y)
    if (self:isTouchInside(pTouch)) then
		self:sendActionsForControlEvents(CCControlEventTouchUpInside)--符合TouchUpInside的条件    
	end
end

function CCClickableImage:onTouchMoved(x,y)
   
end

function CCClickableImage:onTouch(eventType, x, y)
    if eventType == "excuteScriptTouchHandler" then   
        return self:onTouchBegan(x, y)
    elseif eventType == "moved" then
        self:onTouchMoved(x, y)
    else
        self:onTouchEnd(x, y)
    end
end



function CCClickableImage:setSprite(sprite)
	if (self.m_pSprite ~= nil and self.m_pSprite:getParent() ~= nil) then
		self.m_pSprite:removeFromParentAndCleanup(true)
	end
	self.m_pSprite=sprite
	self.m_pSprite:setPosition( ccp(self.m_pSprite:getContentSize().width*sprite:getScaleX() / 2, self.m_pSprite:getContentSize().height*sprite:getScaleY() / 2) )
    self:addChild(self.m_pSprite)
	self:setContentSize(CCSizeMake(sprite:getContentSize().width * sprite:getScaleX(), sprite:getContentSize().height * sprite:getScaleY()))
end

function CCClickableImage:init(pSprite)

	-- Set the default values
	self:ignoreAnchorPointForPosition(false)

	-- Add the off components
	self.m_pSprite=pSprite
	pSprite:setPosition( ccp(pSprite:getContentSize().width*pSprite:getScaleX() / 2, pSprite:getContentSize().height*pSprite:getScaleY() / 2) )
	self:addChild(pSprite)
 
    local function onLocalTouch(eventType, x, y)
        return self:onTouch(eventType, x, y)
    end


    self:registerScriptTouchHandler(onLocalTouch,false,kCCMenuHandlerPriority,true)
    self:setTouchEnabled(true)

	self:setContentSize(CCSizeMake(pSprite:getContentSize().width * pSprite:getScaleX(), pSprite:getContentSize().height * pSprite:getScaleY()))
end

function CCClickableImage.create(pSprite)
    local ci = CCClickableImage.new()
    if nil == ci then
        return nil
    end

    ci:init(pSprite)

    return ci
end

function CCClickableImage:getContentSize()
	if(self.m_pSprite ~= nil) then
		return self.m_pSprite:getContentSize()
	end
	return CCSizeMake(0,0)
end

return CCClickableImage