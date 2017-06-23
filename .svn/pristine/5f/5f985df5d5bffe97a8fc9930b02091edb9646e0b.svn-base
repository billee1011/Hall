
require("CocosExtern")

local CCCheckbox = class("CCCheckbox",function()
		local c = CCControl:new()
        c:init()
        return c
	end)

function CCCheckbox:isTouchInside(touch)
    local touchLocation = self:getParent():convertToNodeSpace(touch)
    local bBox = self:boundingBox() 
    return bBox:containsPoint(touchLocation)
end

function CCCheckbox:onTouchBegan(x,y)	
	if not self:isEnabled() then return false end
	if not self:isVisible() then return false end
	local pTouch = ccp(x, y) 	
	return self:isTouchInside(pTouch)
end

function CCCheckbox:onTouchEnd(x,y)
	local pTouch = ccp(x, y)
    if (self:isTouchInside(pTouch)) then    	
		if(self.m_bAutoChangeState) then
			self.m_bIsCheck = not self.m_bIsCheck		
			self:updateStatue()
		end
		self:sendActionsForControlEvents(CCControlEventTouchUpInside)
	end
end


function CCCheckbox:onTouch(eventType, x, y)
    if eventType == "began" then   
        return self:onTouchBegan(x, y)
    elseif eventType == "ended" then  
        self:onTouchEnd(x, y)
    end
end

function CCCheckbox:setChecked(isChecked) 
	self.m_bIsCheck = isChecked
	self:updateStatue()
end 

function CCCheckbox:isChecked() 
 	return self.m_bIsCheck
end

function CCCheckbox:setStatus(isChecked)
	self.m_bIsCheck = isChecked
	self:updateStatue()	
end

function CCCheckbox:getColor()
    return self.m_color
end

function CCCheckbox:setColor(color)
    if (self.m_pOffSprite == nil or self.m_pOnSprite == nil) then
		return
	end
    if (self.m_pOffSprite:isVisible() == true) then
        self.m_pOffSprite:setColor(color)
    end
    if (self.m_pOnSprite:isVisible() == true) then
        self.m_pOnSprite:setColor(color)
    end
end

function CCCheckbox:updateStatue() 
	if (self.m_pOffSprite == nil or self.m_pOnSprite == nil) then
		return
	end
	self.m_yOffset = self.m_yOffset or 0
	if self.m_yOffset == 0 and self.m_bIsCheck then
		self:setPositionY(self:getPositionY() + self.m_checkedOffsetY)
		self.m_yOffset = self.m_checkedOffsetY
	end
	if self.m_yOffset ~= 0 and not self.m_bIsCheck then
		self.m_yOffset = 0
		self:setPositionY(self:getPositionY() - self.m_checkedOffsetY)
	end
	self.m_pOnSprite:setVisible(self.m_bIsCheck)
	self.m_pOffSprite:setVisible(not self.m_bIsCheck)	
end

function CCCheckbox:init(pSpriteOff,pSpriteOn,bAutoChangeStatus,checkedOffsetY)
	if checkedOffsetY == nil then 
		checkedOffsetY = 0
	end

	if type(checkedOffsetY) ~= "number" then
		checkedOffsetY = 0
	end
    self.m_bAutoChangeState = bAutoChangeStatus or false
	self.m_bIsCheck = false
	self.m_pOnSprite = pSpriteOn
	self.m_pOffSprite = pSpriteOff
	self.m_color = pSpriteOn:getColor()
	self.m_checkedOffsetY = checkedOffsetY

	-- Set the default values
	self.m_bIsCheck = false
	self:ignoreAnchorPointForPosition(false)

	-- Add the off components
	pSpriteOff:setPosition(ccp(pSpriteOff:getContentSize().width * 0.5,pSpriteOff:getContentSize().height * 0.5))
	self:addChild(pSpriteOff)
	

	pSpriteOn:setPosition(ccp(pSpriteOn:getContentSize().width * 0.5,pSpriteOn:getContentSize().height * 0.5))
	pSpriteOn:setVisible(false)
	self:addChild(pSpriteOn)

	local function onTouch(eventType, x, y)
		return self:onTouch(eventType,x,y)
	end

    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,true)
    self:setTouchEnabled(true)
    self:setContentSize(pSpriteOff:getContentSize())
    self:setEnabled(true)
end

function CCCheckbox.create(pSpriteOff,pSpriteOn,bAutoChangeStatus,checkedOffsetY)
	checkedOffsetY = checkedOffsetY or 0
	local winSize = CCDirector:sharedDirector():getWinSize()	
    local cb = CCCheckbox.new()
        if nil == cb then
        return nil
    end
	cb:init(pSpriteOff,pSpriteOn,bAutoChangeStatus or false,checkedOffsetY)
	
	return cb
end

function CCCheckbox.createByFile(filename)
	local sprite = CCSprite:create(filename)

    local texture = sprite:getTexture()
    local rect =sprite:getTextureRect()
    local x = rect.origin.x
  	local y = rect.origin.y
  	local width = rect.size.width
  	local height = rect.size.height

    local normal = CCSprite:createWithTexture(texture, CCRectMake(x,y,width / 2,height))
    local selected = CCSprite:createWithTexture(texture, CCRectMake(x + width / 2,y,width / 2,height))

    return CCCheckbox.create(normal, selected, true)
end

function CCCheckbox.createWithSingleFile(szFilePath, nStatus)
	local sprite= CCSprite:create(szFilePath)
    local texture = sprite:getTexture()
    local rect = sprite:getTextureRect()
    local x = rect.origin.x
    local y = rect.origin.y
    local width = rect.size.width / nStatus
    local height = rect.size.height
    local normal = CCSprite:createWithTexture(texture,CCRectMake(x,y,width,height))
    local press = CCSprite:createWithTexture(texture,CCRectMake(x+width,y,width,height))
    local CCCheckbox = require("FFSelftools/CCCheckbox")
	return CCCheckbox.create(press, normal, false)
end

return CCCheckbox