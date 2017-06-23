
local StringWrapper = {}
StringWrapper.__index = StringWrapper

function StringWrapper:new()
	local self = {
		content,
		nPriorty,
		uIndex
	}
	setmetatable(self, StringWrapper)
	return self
end

local Resources = require("bull/Resources")
local SpeakerLabel =require("FFSelftools/SpeakerLabel")


local GameSpeaker = class("GameSpeaker",function ()
      return CCLayer:create()
    end   
)

GameSpeaker.pLabelMsgY=0
GameSpeaker.bgSpDst=0.53

function GameSpeaker:onEnter()
end

function GameSpeaker:onExit()  
end


function GameSpeaker:onNodeEvent(event)
    if event == "enter" then
        self:onEnter()
    elseif event == "exit" then
        self:onExit()
    end
end


function GameSpeaker:onTouchBegan(x,y)   
   return true
end

function GameSpeaker:onTouchEnd(x,y) 
end

function GameSpeaker:onTouchMoved(x,y)
end

function GameSpeaker:onTouchCancel(x,y)
end

function GameSpeaker:runSpeakAction() 

	if(self.m_UserSpeakContent == nil or #self.m_UserSpeakContent == 0) then
        local winSize =CCDirector:sharedDirector():getWinSize()
        self.pContentBg:stopAllActions()
        local actionTo =CCMoveTo:create(0.5, ccp(winSize.width*GameSpeaker.bgSpDst,winSize.height))
        self.pContentBg:runAction(actionTo)
        self.m_bSpeakerRunning =false
		return
	end
	
    local content = self.m_UserSpeakContent[1].content
    local nPriorty = self.m_UserSpeakContent[1].nPriorty
	self.m_pLabelMsg:setColor(ccc3(255,255,255))
	local sysHead = "【系统】"
	local speakContent = content
	
	self.m_pLabelMsg:initLabel(65535 , content, 0)

    local pActionArr = CCArray:create()
    local nTimes =3
    if  nPriorty<=9 then
        nTimes =5
    end
    pActionArr:addObject(CCDelayTime:create(nTimes))

    local function runSpeaker()
        if #self.m_UserSpeakContent>0 then
            table.remove(self.m_UserSpeakContent, 1)
        end
        return self:runSpeakAction()
    end
    
	--pActionArr:addObject(CCCallFunc:create(runSpeaker))
	--self.m_pLabelMsg:runAction(CCSequence:create(pActionArr))

    --文字长移动
    if self.m_pLabelMsg:getContentSize().width>self.pContentBg:getContentSize().width then
       local nLabelX = self.m_pLabelMsg:getContentSize().width -  self.pContentBg:getContentSize().width
       self.m_pLabelMsg:setPosition(ccp(nLabelX/2,GameSpeaker.pLabelMsgY))
       self.pClippingNode:setAnchorPoint(ccp(0.5,0.5))
       self.pClippingNode:setPosition(ccp(self.pContentBg:getContentSize().width/2,self.pContentBg:getContentSize().height/2))
       local moveTo=CCMoveTo:create((self.m_pLabelMsg:getContentSize().width/self.pContentBg:getContentSize().width)*4, 
                                                    ccp(-self.m_pLabelMsg:getContentSize().width+self.pContentBg:getContentSize().width/2,self.m_pLabelMsg:getPositionY()))
       local function callFunction()
            self.m_pLabelMsg:setString(" ")
            self.m_pLabelMsg:setPosition(ccp(0,GameSpeaker.pLabelMsgY))
            self.pClippingNode:setAnchorPoint(ccp(0.5,0.5))
            self.pClippingNode:setPosition(ccp(self.pContentBg:getContentSize().width/2,self.pContentBg:getContentSize().height/2))
            runSpeaker()
       end
       pActionArr:addObject(moveTo)
       pActionArr:addObject(CCCallFunc:create(callFunction))

       self.m_pLabelMsg:runAction(CCSequence:create(pActionArr))
    else 
       self.m_pLabelMsg:setPosition(ccp(0,GameSpeaker.pLabelMsgY))
       self.pClippingNode:setAnchorPoint(ccp(0.5,0.5))
       self.pClippingNode:setPosition(ccp(self.pContentBg:getContentSize().width/2,self.pContentBg:getContentSize().height/2))
       pActionArr:addObject(CCCallFunc:create(runSpeaker))
       self.m_pLabelMsg:runAction(CCSequence:create(pActionArr))
    end

end

function GameSpeaker:speak(speakContent, nPriorty) 
	if (self.m_pLabelMsg ~= nil) then
		local sampleContent = ""
		sampleContent = speakContent
		local strContent = speakContent;
		local wrapper = StringWrapper:new()
		wrapper.uIndex = self.m_nSpeakerIndex
		self.m_nSpeakerIndex = self.m_nSpeakerIndex + 1
		wrapper.nPriorty = nPriorty;
		wrapper.content = strContent;
		table.insert(self.m_UserSpeakContent, wrapper) --将消息发进队列中
		if(#self.m_UserSpeakContent > 1) then
			-- 排序
			--sort(m_UserSpeakContent.begin(), m_UserSpeakContent.end(), sortSpeaker)
            local function sortSpeaker(left,right)
                if (left.nPriorty < right.nPriorty) then
		            return true
                end
	            if (left.nPriorty > right.nPriorty) then
		            return false
                end
	            return left.uIndex < right.uIndex
            end
            table.sort(self.m_UserSpeakContent, sortSpeaker)
		end
		
	end

    if(self.m_bSpeakerRunning == false) then
        self.m_bSpeakerRunning=true
        self:runSpeakAction()
    end
    
    local winSize = CCDirector:sharedDirector():getWinSize()
    if self.pContentBg:getPositionY()~=(winSize.height-self.pContentBg:getContentSize().height) then
        self.pContentBg:stopAllActions()
        local actionTo =CCMoveTo:create(0.5, ccp(winSize.width*GameSpeaker.bgSpDst,winSize.height-self.pContentBg:getContentSize().height))
        self.pContentBg:runAction(actionTo)
    end
    
end

function GameSpeaker:initData()
	
    self.m_UserSpeakContent = {}
    self.m_nSpeakerIndex = 0
  
    local winSize = CCDirector:sharedDirector():getWinSize()
	self.pContentBg = loadSprite("bull/gameSpeak_Img.png")
    self.pContentBg:setAnchorPoint(ccp(0.5,0))
    self.pContentBg:setPosition(ccp(winSize.width*GameSpeaker.bgSpDst,winSize.height))
	self:addChild(self.pContentBg)
	

	self.m_pLabelMsg = SpeakerLabel.create("", Resources.FONT_ARIAL, Resources.FONT_SIZE30)
	self.m_pLabelMsg:setHorizontalAlignment(kCCTextAlignmentLeft)
    self.m_pLabelMsg:setAnchorPoint(ccp(0.5,0))
    self.m_pLabelMsg:setPosition(ccp(0,GameSpeaker.pLabelMsgY))
	
	self.pClippingNode = CCClippingNode:create()
	local pModel = CCSprite:create()
	local contentSize = self.pContentBg:getContentSize()
	pModel:setTextureRect(CCRect(0, 0, contentSize.width,contentSize.height))

	self.pClippingNode:setStencil(pModel)

    self.pClippingNode:addChild(self.m_pLabelMsg)

    self.pClippingNode:setAnchorPoint(ccp(0.5,0.5))
    self.pClippingNode:setPosition(ccp(self.pContentBg:getContentSize().width/2,self.pContentBg:getContentSize().height/2))
    self.pContentBg:addChild(self.pClippingNode)
 

    self.m_bSpeakerRunning =false
	

    local function onNodeEvent(event)
        self:onNodeEvent(event)
    end

    local function onTouch(eventType, x, y)
        if eventType == "began" then   
            return self:onTouchBegan(x, y)
        elseif eventType == "moved" then
            self:onTouchMoved(x, y)
        elseif eventType == "cancelled" then
            self:onTouchCancel(x, y)
        elseif eventType == "ended" then
            self:onTouchEnd(x, y)
        end
    end

	self:registerScriptHandler(onNodeEvent)
    self:setTouchEnabled(true)
    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,false)
end

function GameSpeaker.createGameSpeaker()
	local gameSpeaker = GameSpeaker.new()
	if (gameSpeaker == nil) then
		return nil
	end

	gameSpeaker:initData()
	return gameSpeaker
end

return  GameSpeaker


