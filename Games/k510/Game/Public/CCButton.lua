require("CocosExtern")
local CCButton=class("CCButton")
CCButton.__index =CCButton
CCButton.m_normalSp=nil
CCButton.m_spPress=nil
CCButton.m_spEnable=nil
CCButton.m_imgFilePath=""
CCButton.m_splitImgNum=1
CCButton.m_actionCallBack=nil
CCButton.m_bTouchMove=false
CCButton.m_touchBeginPoint=ccp(0,0)
CCButton.onTouch = nil
CCButton.m_enabel =true
CCButton.m_cbDisPressImg=false

function CCButton.extend(target)
	local t = tolua.getpeer(target)
	if not t then
	t = {}
	tolua.setpeer(target, t)
	end
	setmetatable(t, CCButton)
	return target
end

function CCButton:initUI()
	local winSize = CCDirector:sharedDirector():getWinSize()
	self.m_cbDisPressImg=false
	local  sprite = CCSprite:create(self.m_imgFilePath)
	local texture = sprite:getTexture()
	local rect = sprite:getTextureRect()
	local x = rect.origin.x
	local y = rect.origin.y
	local width = rect.size.width
	local height = rect.size.height

	
	if(self.m_splitImgNum==1)  then--1张图片
		self.m_normalSp = CCSprite:createWithTexture(texture,CCRectMake(x,y,width,height))
		self.m_spPress = CCSprite:createWithTexture(texture,CCRectMake(x,y,width,height))
		self.m_spEnable = CCSprite:createWithTexture(texture, CCRectMake(x,y,width,height))
	elseif(self.m_splitImgNum==2) then--2张图片
		self.m_normalSp = CCSprite:createWithTexture(texture,CCRectMake(x,y,width/2,height))
		self.m_spPress = CCSprite:createWithTexture(texture,CCRectMake(x+width/2,y,width/2,height))
		self.m_spEnable = CCSprite:createWithTexture(texture, CCRectMake(x+width/2,y,width/2,height))
	else --3张图片
		self.m_normalSp = CCSprite:createWithTexture(texture,CCRectMake(x,y,width / 3,height))
		self.m_spPress = CCSprite:createWithTexture(texture,CCRectMake(x + width / 3,y,width / 3,height))
		self.m_spEnable = CCSprite:createWithTexture(texture, CCRectMake(x + width / 3 * 2,y,width / 3,height))
	end

	local normalSpContentSize =self.m_normalSp:getContentSize()

	self.m_normalSp:setAnchorPoint(ccp(0.5,0.5))
	self:setContentSize(normalSpContentSize)
	self:addChild(self.m_normalSp)

	self.m_spPress:setAnchorPoint(ccp(0.5,0.5))
	self.m_spPress:setPosition(ccp(normalSpContentSize.width/2,normalSpContentSize.height/2))
	self.m_spPress:setVisible(false)
	self.m_normalSp:addChild(self.m_spPress)

	self.m_spEnable:setAnchorPoint(ccp(0.5,0.5))
	self.m_spEnable:setPosition(ccp(normalSpContentSize.width/2,normalSpContentSize.height/2))
	self.m_spEnable:setVisible(false)
	self.m_normalSp:addChild(self.m_spEnable)
end

function CCButton:onEnter()
  
end

function CCButton:onExit()
   	self.m_actionCallBack=nil
end

function CCButton:setEnabled(enabel)
	self.m_enabel =enabel
	local temEnabel =false
	if self.m_enabel==true then
	  	temEnabel=false
	else
	  	temEnabel=true
	end
	self.m_spEnable:setVisible(temEnabel)
end

function CCButton:setClickBntNotCallBack(cbCallBACK)
	self.m_enabel =cbCallBACK
end

function CCButton:setIsDisPressImg(cbVis)
	self.m_spPress:setVisible(cbVis)
	self.m_cbDisPressImg=cbVis
end

function CCButton:setDisPressImgAndNotEnabled(cbVis)
      self.m_spPress:setVisible(cbVis)
      self.m_enabel =(not cbVis)
end

function CCButton:isSelfVisible()
	local node = self;
	while node ~= nil do
		if not node:isVisible() then break end
		node = node:getParent()
	end

	return node == nil
end

function CCButton:setChecked(bIsCheck)
    self.m_bIsCheck = bIsCheck
    self.m_spEnable:setVisible(not self.m_bIsCheck)
    self.m_normalSp:setVisible(self.m_bIsCheck)
end

function CCButton:isChecked()
    return self.m_bIsCheck
end

function CCButton:onTouchBegan(x,y)
	if not self:isSelfVisible() then return false end

	self.m_bTouchMove=false
	self.m_touchBeginPoint =ccp(x,y)
	if self.m_normalSp:boundingBox():containsPoint(self.m_normalSp:getParent():convertToNodeSpace(self.m_touchBeginPoint))==true then
		if self.m_enabel==true then
		  	self.m_spPress:setVisible(true)
		end   
		return true
	else
		return false
	end
	return false
end

function CCButton:onMoved(x,y)
   if math.abs(self.m_touchBeginPoint.x-x)>=20 or math.abs(self.m_touchBeginPoint.y-y)>=20  then
	  	self.m_bTouchMove=true
   end
end

function CCButton:onEnded(x,y)
	if  self.m_bTouchMove==false then
	   	if self.m_actionCallBack~=nil and self.m_enabel==true then
			self.m_actionCallBack(self:getTag(),self)
	  	end
	end

	if not self.m_cbDisPressImg then
       self.m_spPress:setVisible(false)
	end
	
end

function CCButton:resetTouchPriorty(p,cbSwallow)
	self:registerScriptTouchHandler(self.onTouch,false,p,cbSwallow)
	self:setTouchEnabled(false)
	self:setTouchEnabled(true)
end

function CCButton.createCCButton(imgFilePath,splitImgNum,actionCallBack)
	local ccButton = CCButton.extend(CCLayer:create())
	if ccButton==nil then
	  	return nil
	end
	ccButton.m_imgFilePath =imgFilePath
	ccButton.m_splitImgNum =splitImgNum
	ccButton.m_actionCallBack =actionCallBack

	local function onNodeEvent(event)
	 	if event =="enter" then
			ccButton:onEnter()
	 	elseif event =="exit" then
			ccButton:onExit()
	 	end	 	
	end

  	local function onTouch(eventType ,x ,y)
		if eventType=="began" then
			return ccButton:onTouchBegan(x,y)
		elseif eventType=="moved" then
			ccButton:onMoved(x,y)
		elseif eventType=="ended" then
			ccButton:onEnded(x,y)
		end
  	end

	ccButton.onTouch = onTouch
	ccButton:initUI()
	ccButton:registerScriptHandler(onNodeEvent)
	ccButton:setTouchEnabled(true)
	ccButton:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,true)
	return ccButton
end

function CCButton:initUIByStatusFilePath(normalPath, clickPath, disablePath)
    local winSize = CCDirector:sharedDirector():getWinSize()
	self.m_cbDisPressImg=false
	
	if(normalPath ~= nil and clickPath ~= nil) then --1张图片
		self.m_normalSp = CCSprite:create(normalPath)
		self.m_spPress = CCSprite:create(clickPath)
	end
    if(disablePath ~= nil) then --2张图片
		self.m_spEnable = CCSprite:create(disablePath)
	else --3张图片
		self.m_spEnable = CCSprite:create(clickPath)
	end

	local normalSpContentSize =self.m_normalSp:getContentSize()

	self.m_normalSp:setAnchorPoint(ccp(0.5,0.5))
	self:setContentSize(normalSpContentSize)
	self:addChild(self.m_normalSp)

	self.m_spPress:setAnchorPoint(ccp(0.5,0.5))
	self.m_spPress:setPosition(ccp(normalSpContentSize.width/2,normalSpContentSize.height/2))
	self.m_spPress:setVisible(false)
	self.m_normalSp:addChild(self.m_spPress)

	self.m_spEnable:setAnchorPoint(ccp(0.5,0.5))
	self.m_spEnable:setPosition(ccp(normalSpContentSize.width/2,normalSpContentSize.height/2))
	self.m_spEnable:setVisible(false)
	self.m_normalSp:addChild(self.m_spEnable)

    self.m_bIsCheck = false
end

function CCButton.createCCButtonByStatusFilePath(normalPath, clickPath, disablePath,actionCallBack)
	local ccButton = CCButton.extend(CCLayer:create())
	if ccButton==nil then
	  	return nil
	end
	ccButton.m_actionCallBack =actionCallBack

	local function onNodeEvent(event)
	 	if event =="enter" then
			ccButton:onEnter()
	 	elseif event =="exit" then
			ccButton:onExit()
	 	end	 	
	end

  	local function onTouch(eventType ,x ,y)
		if eventType=="began" then
			return ccButton:onTouchBegan(x,y)
		elseif eventType=="moved" then
			ccButton:onMoved(x,y)
		elseif eventType=="ended" then
			ccButton:onEnded(x,y)
		end
  	end

	ccButton.onTouch = onTouch
	ccButton:initUIByStatusFilePath(normalPath, clickPath, disablePath)
	ccButton:registerScriptHandler(onNodeEvent)
	ccButton:setTouchEnabled(true)
	ccButton:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,true)
	return ccButton
end

function CCButton:initUIByFrameName(normalFrameName, clickFrameName, disableFrameName)
    local winSize = CCDirector:sharedDirector():getWinSize()
	self.m_cbDisPressImg=false
	
	if(normalFrameName ~= nil and clickPath ~= nil) then --1张图片
		self.m_normalSp = CCSprite:createWithSpriteFrameName(normalFrameName)
		self.m_spPress = CCSprite:createWithSpriteFrameName(clickFrameName)
	end
    if(disablePath ~= nil) then --2张图片
		self.m_spEnable = CCSprite:createWithSpriteFrameName(disableFrameName)
	else --3张图片
		self.m_spEnable = CCSprite:createWithSpriteFrameName(clickFrameName)
	end

	local normalSpContentSize =self.m_normalSp:getContentSize()

	self.m_normalSp:setAnchorPoint(ccp(0.5,0.5))
	self:setContentSize(normalSpContentSize)
	self:addChild(self.m_normalSp)

	self.m_spPress:setAnchorPoint(ccp(0.5,0.5))
	self.m_spPress:setPosition(ccp(normalSpContentSize.width/2,normalSpContentSize.height/2))
	self.m_spPress:setVisible(false)
	self.m_normalSp:addChild(self.m_spPress)

	self.m_spEnable:setAnchorPoint(ccp(0.5,0.5))
	self.m_spEnable:setPosition(ccp(normalSpContentSize.width/2,normalSpContentSize.height/2))
	self.m_spEnable:setVisible(false)
	self.m_normalSp:addChild(self.m_spEnable)

    self.m_bIsCheck = false
end

function CCButton.createCCButtonByFrameName(normalFrameName, clickFrameName, disableFrameName,actionCallBack)
	local ccButton = CCButton.extend(CCLayer:create())
	if ccButton==nil then
	  	return nil
	end
	ccButton.m_actionCallBack =actionCallBack

	local function onNodeEvent(event)
	 	if event =="enter" then
			ccButton:onEnter()
	 	elseif event =="exit" then
			ccButton:onExit()
	 	end	 	
	end

  	local function onTouch(eventType ,x ,y)
		if eventType=="began" then
			return ccButton:onTouchBegan(x,y)
		elseif eventType=="moved" then
			ccButton:onMoved(x,y)
		elseif eventType=="ended" then
			ccButton:onEnded(x,y)
		end
  	end

	ccButton.onTouch = onTouch
	ccButton:initUIByFrameName(normalFrameName, clickFrameName, disableFrameName)
	ccButton:registerScriptHandler(onNodeEvent)
	ccButton:setTouchEnabled(true)
	ccButton:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,true)
	return ccButton
end

function CCButton:initUIByStatusSprite(normalSprite, clickSprite, disableSprite,actionCallBack)
    local winSize = CCDirector:sharedDirector():getWinSize()
	self.m_cbDisPressImg=false
	
	self.m_normalSp = normalSprite
	self.m_spPress = clickSprite
	self.m_spEnable = disableSprite

	local normalSpContentSize =self.m_normalSp:getContentSize()

	self.m_normalSp:setAnchorPoint(ccp(0.5,0.5))
	self:setContentSize(normalSpContentSize)
	self:addChild(self.m_normalSp)

	self.m_spPress:setAnchorPoint(ccp(0.5,0.5))
	self.m_spPress:setPosition(ccp(normalSpContentSize.width/2,normalSpContentSize.height/2))
	self.m_spPress:setVisible(false)
	self.m_normalSp:addChild(self.m_spPress)

	self.m_spEnable:setAnchorPoint(ccp(0.5,0.5))
	self.m_spEnable:setPosition(ccp(normalSpContentSize.width/2,normalSpContentSize.height/2))
	self.m_spEnable:setVisible(false)
	self.m_normalSp:addChild(self.m_spEnable)
end

function CCButton:setActionCallback(actionCallBack)
    self.m_actionCallBack =actionCallBack
end

function CCButton.createCCButtonByStatusSprite(normalSprite, clickSprite, disableSprite,actionCallBack)
	local ccButton = CCButton.extend(CCLayer:create())
	if ccButton==nil then
	  	return nil
	end
	ccButton.m_actionCallBack =actionCallBack

	local function onNodeEvent(event)
	 	if event =="enter" then
			ccButton:onEnter()
	 	elseif event =="exit" then
			ccButton:onExit()
	 	end	 	
	end

  	local function onTouch(eventType ,x ,y)
		if eventType=="began" then
			return ccButton:onTouchBegan(x,y)
		elseif eventType=="moved" then
			ccButton:onMoved(x,y)
		elseif eventType=="ended" then
			ccButton:onEnded(x,y)
		end
  	end

	ccButton.onTouch = onTouch
	ccButton:initUIByStatusSprite(normalSprite, clickSprite, disableSprite,actionCallBack)
	ccButton:registerScriptHandler(onNodeEvent)
	ccButton:setTouchEnabled(true)
	ccButton:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,true)
	return ccButton
end

function CCButton:loadNewTexture(imgFilePath,splitImgNum)

    self.m_imgFilePath =imgFilePath
	self.m_splitImgNum =splitImgNum

    local sprite = CCSprite:create(self.m_imgFilePath)
	local texture = sprite:getTexture()
	local rect = sprite:getTextureRect()
    local x = rect.origin.x
	local y = rect.origin.y
	local width = rect.size.width
	local height = rect.size.height

    if(self.m_splitImgNum==1)  then--1张图片
		self.m_normalSp:setTexture(texture)
        self.m_normalSp:setTextureRect(CCRectMake(x,y,width,height))
        self.m_spPress:setTexture(texture)
        self.m_spPress:setTextureRect(CCRectMake(x,y,width,height))
        self.m_spEnable:setTexture(texture)
        self.m_spEnable:setTextureRect(CCRectMake(x,y,width,height))
	elseif(self.m_splitImgNum==2) then--2张图片
        self.m_normalSp:setTexture(texture)
        self.m_normalSp:setTextureRect(CCRectMake(x,y,width/2,height))
        self.m_spPress:setTexture(texture)
        self.m_spPress:setTextureRect(CCRectMake(x+width/2,y,width/2,height))
        self.m_spEnable:setTexture(texture)
        self.m_spEnable:setTextureRect(CCRectMake(x+width/2,y,width/2,height))
	else --3张图片
        self.m_normalSp:setTexture(texture)
        self.m_normalSp:setTextureRect(CCRectMake(x,y,width / 3,height))
        self.m_spPress:setTexture(texture)
        self.m_spPress:setTextureRect(CCRectMake(x + width / 3,y,width / 3,height))
        self.m_spEnable:setTexture(texture)
        self.m_spEnable:setTextureRect(CCRectMake(x + width / 3 * 2,y,width / 3,height))
	end
end

return CCButton