require("CocosExtern")

local CCMoveCheckBox = class("CCMoveCheckBox",function()
	return CCLayer:create()
end)

function CCMoveCheckBox:ctor()
	-- body
	self.m_bIsOpenInLeft = false
	self.m_bIsCheck = false
	self.m_bIsAnimationFinish = true
	self.m_callback = nil
	self.m_pStartPos = ccp(0,0)
	self.m_pOpenTexture = nil
	self.m_pCloseTexture = nil
	self.m_pIconSprite = nil
end

function CCMoveCheckBox:setTarget(pCallback)
	self.m_callback = pCallback
end

function CCMoveCheckBox:setChecked(isCheck) 
	if (self.m_bIsCheck == isCheck) then
		return
	end
    if (self.m_pIconSprite == nil) then
        return
    end
	self.m_bIsCheck = isCheck
	if (self.m_bIsCheck == true) then
		self.m_pIconSprite:setTexture(self.m_pOpenTexture)
	else
		self.m_pIconSprite:setTexture(self.m_pCloseTexture)
	end
	if (self.m_callback) then
		self.m_callback(self)
	end
end

function CCMoveCheckBox:isChecked() 
	return self.m_bIsCheck
end

function CCMoveCheckBox:isMoveFinish() 
	return self.m_bIsAnimationFinish
end

function CCMoveCheckBox:distance(pt1, pt2)
	return sqrt((pt1.x - pt2.x) * (pt1.x - pt2.x) + (pt1.y - pt2.y) * (pt1.y - pt2.y))
end

function CCMoveCheckBox:moveFinish() 
	self:setChecked(not self:isChecked())
	self.m_bIsAnimationFinish = true
end

function CCMoveCheckBox:move(isLeft)
	local function moveFinish() 
		self:setChecked(not self:isChecked())
		self.m_bIsAnimationFinish = true
	end

	self.m_bIsAnimationFinish = false
	local pAction = nil
	if (self:isChecked() == false) then
        local ationArray = CCArray:create()
        local moveto =CCMoveTo:create(0.2, ccp(2, self.m_pIconSprite:getPositionY()))
        local func = CCCallFunc:create(moveFinish)
        ationArray:addObject(moveto)
        ationArray:addObject(func)
		pAction = CCSequence:create(ationArray)
	else
        local ationArray = CCArray:create()
        local moveto =CCMoveTo:create(0.2, ccp(self:getContentSize().width - self.m_pIconSprite:getContentSize().width,self.m_pIconSprite:getPositionY()))
        local func = CCCallFunc:create(moveFinish)
        ationArray:addObject(moveto)
        ationArray:addObject(func)
		pAction = CCSequence:create(ationArray)
	end
	if (pAction ~= nil) then
		self.m_pIconSprite:stopAllActions()
		self.m_pIconSprite:runAction(pAction)
	end
end

function CCMoveCheckBox:init(szBgFilePath,szCloseFilePath, szOpenFilePath,isOpenInLeft, isCheck, pCallback)
	if (szBgFilePath == nil) then
		return nil
	end
	if (szCloseFilePath == nil) then
		return nil
	end
	if (szOpenFilePath == nil) then
		return nil
	end

	local moveCheckBox = self

	local pBg = CCSprite:create(szBgFilePath)
	moveCheckBox:setContentSize(pBg:getContentSize())

	pBg:setPosition(ccp(0,0))
	pBg:setAnchorPoint(ccp(0,0))
	moveCheckBox:addChild(pBg)
	pBg:setVisible(false)

	moveCheckBox.m_bIsCheck = isCheck

	moveCheckBox.m_bIsOpenInLeft = isOpenInLeft
	moveCheckBox.m_pOpenTexture = CCTextureCache:sharedTextureCache():addImage(
			szOpenFilePath)
	moveCheckBox.m_pCloseTexture = CCTextureCache:sharedTextureCache():addImage(
			szCloseFilePath)
	if (moveCheckBox.m_bIsCheck == true) then
		moveCheckBox.m_pIconSprite = CCSprite:createWithTexture(moveCheckBox.m_pOpenTexture)
	else
		moveCheckBox.m_pIconSprite = CCSprite:createWithTexture(moveCheckBox.m_pCloseTexture)
	end
	if (isOpenInLeft == true) then
		if (moveCheckBox.m_bIsCheck) then
			moveCheckBox.m_pIconSprite:setPosition(ccp(0, 3))
		else
			moveCheckBox.m_pIconSprite:setPosition(
				ccp(
						moveCheckBox:getContentSize().width
								- moveCheckBox.m_pIconSprite:getContentSize().width, 3))
		end
	else
		if (m_bIsCheck) then
			moveCheckBox.m_pIconSprite:setPosition(
				ccp(
						moveCheckBox:getContentSize().width
								- moveCheckBox.m_pIconSprite:getContentSize().width, 3))
		else
			moveCheckBox.m_pIconSprite:setPosition(ccp(0, 3))
		end
	end
	moveCheckBox.m_pIconSprite:setAnchorPoint(ccp(0,0))
	moveCheckBox:addChild(moveCheckBox.m_pIconSprite)

	moveCheckBox:setTarget(pCallback)

	return self
end

function CCMoveCheckBox.createByInfo(szBgFilePath,szCloseFilePath, szOpenFilePath,isOpenInLeft, isCheck, pCallback)
	local moveCheckBox = CCMoveCheckBox.new()
	return moveCheckBox:init(szBgFilePath,
			szCloseFilePath, szOpenFilePath,
			isOpenInLeft, isCheck, pCallback)	
end

return CCMoveCheckBox