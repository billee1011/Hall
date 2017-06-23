require("FFSelftools/controltools")

local Resources = require("bull/Resources")
local GameLibSink = require("bull/GameLibSink")
local SpeakerHistoryNode = require(Resources.Code_Head_Url .. "public/SpeakerHistoryNode")
local SpeakerLabel = require("FFSelftools/SpeakerLabel")

local Speaker = class("Speaker",function()
	return CCLayer:create()
end)

Speaker.SPEAKER_TYPE_NULL = 4
Speaker.SPEAKER_TYPE_HALL = 0
Speaker.SPEAKER_TYPE_DESK = 1
Speaker.SPEAKER_TYPE_FRUITMACHINE = 2
Speaker.SPEAKER_TYPE_LHB = 3

function Speaker:onTouchBegan(x,y)
	if (self:isVisible() == false) then
		return false
	end

	if (self.m_bIsCanTouch == false) then
		return false
	end

	local touchPoint = self:convertToNodeSpace(ccp(x,y))
	local rect = self.m_pEditBox:boundingBox()
	--[[cclog("Speaker:onTouchBegan touchPoint(%f,%f),edit(%f,%f,%f,%f)",
		touchPoint.x,touchPoint.y,
		rect.origin.x,rect.origin.y,rect.size.width,rect.size.height)]]

	if (self.m_pEditBox:isEnabled() == true
			and rect:containsPoint(touchPoint) == false) then
		self.m_pEditBox:setEnabled(false)
		self.m_pEditBox:setPlaceHolder("")
		self.m_pEditBox:setText("")
		self.m_pLabelMsg:setVisible(true)
		return false
	end
	
	if (self.m_pEditBox:isEnabled() == false) then
		if (self.m_pEditBox:boundingBox():containsPoint(touchPoint)) then
			local rectSize = CCSizeMake(0,0)
			if self.m_pHistory == nil then
				self.m_pHistory = SpeakerHistoryNode.create(self.m_HistoryContent,rectSize)
				local space = 7
				self.m_pHistory:setPosition(ccp(0, -self.m_pEditBox:getContentSize().height * 0.5 + space))
				self.m_pHistory:setVisible(false)
				self:addChild(self.m_pHistory)
			end
			if self.m_pHistory:isVisible() == false then
				self.m_pHistory:setSpeakerHistrory(self.m_HistoryContent)
			else
				self.m_pHistory:setVisible(false)	
			end
			return true
		end
		if (self.m_pHistory ~= nil and self.m_pHistory:isVisible()) then			
			if (not self.m_pHistory:boundingBox():containsPoint(touchPoint)) then			
				self.m_pHistory:setVisible(false)
			end
			return true
		end
	end
	return false
end

function Speaker:onTouch(eventType, x, y)
    if eventType == "began" then   
        return self:onTouchBegan(x, y)    
    end
end


function Speaker:hide()
	self:setVisible(false)
end

function Speaker:runSpeakAction() 
	if(self.m_UserSpeakContent == nil or #self.m_UserSpeakContent == 0) then
		self.m_bSpeakerRunning = false
		return
	end

	self.m_bSpeakerRunning = true

	--如果List持续不为0，此动作会持续进行
	self.m_fSysSpeakBuf = 30
	self.m_pLabelMsg:setVisible(true)
	local fSpeakerTime = 0
	local pActionArr = CCArray:create()
	pActionArr:addObject(CCFadeOut:create(0.5))
	-- 滚动文字
	self.m_pLabelMsg:setPosition(ccp(0,self.m_pLabelMsg:getPositionY()))
    --删除第一条
    local content = self.m_UserSpeakContent[1].content
    table.remove(self.m_UserSpeakContent, 1)
	--加入到历史列表中,超出30条就清除最后一条
    table.insert(self.m_HistoryContent, 1, content)
	if (#self.m_HistoryContent > 30) then
		table.remove(self.m_HistoryContent, 1)
    end
	self.m_pLabelMsg:setColor(ccc3(255,255,255))
	local sysHead = Resources.DESC_GLOBAL_SYSTEM
	local speakContent = content
	local isSystem = false
	if (string.sub(speakContent,1,4) ~= nil) then 
		if (speakContent == sysHead) then
			isSystem = true
		end
	end
	self.m_pLabelMsg:initLabel(65535 , content, 0)

	local textSize = self.m_pEditBox:getContentSize()

	local posx = self.m_pEditBox:getPositionX()	+ self.m_pEditBox:getContentSize().width
	self.m_pLabelMsg:setPosition(ccp(posx, self.m_pLabelMsg:getPositionY()))
	local pActionArr2 = CCArray:create()
	pActionArr2:addObject(CCMoveTo:create(0,
		ccp(self.m_pEditBox:getPositionX()	+ self.m_pEditBox:getContentSize().width,self.m_pLabelMsg:getPositionY())))
	local overHwidth = math.max(0,(self.m_pLabelMsg:getContentSize().width - (textSize.width * 0.95)) * 0.5)
	local moveTime = (self.m_pLabelMsg:getContentSize().width / textSize.width)*6  + 5
	if (overHwidth > 0) then
		local moveX = -self.m_pLabelMsg:getContentSize().width
		pActionArr2:addObject(CCMoveTo:create(moveTime,ccp(moveX, self.m_pLabelMsg:getPositionY())))
	else
		moveTime = 15
		pActionArr2:addObject(CCMoveTo:create(moveTime, ccp(-textSize.width, self.m_pLabelMsg:getPositionY())))
	end
    local function hide()
	    self:setVisible(false)
    end

	if (isSystem == true) then 
		pActionArr:addObjectsFromArray(pActionArr2)
	else
		pActionArr:addObjectsFromArray(pActionArr2)
	end
	
	pActionArr:addObject(CCFadeIn:create(0.5))
	pActionArr:addObject(CCDelayTime:create(0.2))

    local function runSpeaker()
        return self:runSpeakAction()
    end
	pActionArr:addObject(CCCallFunc:create(runSpeaker))

	self.m_pLabelMsg:runAction(CCSequence:create(pActionArr))
end

function Speaker:speak(speakContent, nPriorty) 
	if (self.m_pLabelMsg ~= nil) then
		local sampleContent = ""
		sampleContent = speakContent
		local strContent = speakContent
		local wrapper = {}
		wrapper.uIndex = self.m_nSpeakerIndex
		self.m_nSpeakerIndex = self.m_nSpeakerIndex + 1
		wrapper.nPriorty = nPriorty
		wrapper.content = strContent
		table.insert(self.m_UserSpeakContent, wrapper)
		if(#self.m_UserSpeakContent > 1) then			
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
		if(self.m_bSpeakerRunning == false) then
			self:runSpeakAction()
        end
	end
end

function Speaker:setIsCanTouch(isCanTouch)
    self.m_bIsCanTouch = isCanTouch
end

function Speaker:getIsCanTouch()
    return self.m_bIsCanTouch
end

function Speaker:initData(szBGFileName, szBtnSpeakerUrl, szFreeLabaBG, GameLibSink)
    local function onTouch(eventType, x, y)
        return self:onTouch(eventType, x, y)
    end

    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,true)
    self:setTouchEnabled(true)
    self:setKeypadEnabled(true)

    self.m_UserSpeakContent = {}
    self.m_HistoryContent = {}
    self.m_nSpeakerIndex = 0
    self.m_bIsCanTouch = true
    self.m_pLabaNum = nil

    local function editBoxTextEventHandle(strEventName,pSender)
		local edit = tolua.cast(pSender,"CCEditBox")
		local strFmt 
		if strEventName == "return" then			
            local szContent = edit:getText()
	        if (string.len(szContent) > 0) then		
                local gameLib = GameLibSink.m_gameLib     
                if (gameLib ~= nil) then   
		            gameLib:sendSpeaker(szContent)
                end
		        self.m_pEditBox:setPlaceHolder("")
		        self.m_pEditBox:setEnabled(false)
		        self.m_pEditBox:setText("")
		        self.m_pLabelMsg:setVisible(true)
	        end		
		end
	end

    --[[local speakerBackgroundSp = CCSprite:create(Resources.Resources_Head_Url .. "room/speaker_background.png")
	speakerBackgroundSp:setAnchorPoint(ccp(0.5, 0))
	speakerBackgroundSp:setPosition(ccp(winsize.width/2, winsize.height * 0.85-10))
	self:addChild(speakerBackgroundSp)]]
	local tEditBox = CCSprite:create(szBGFileName)
	self.m_pEditBox = CCEditBox:create(tEditBox:getContentSize(), CCScale9Sprite:create(szBGFileName))
	self.m_pEditBox:setEnabled(false)
	self.m_pEditBox:setReturnType(kKeyboardReturnTypeSend)
    self.m_pEditBox:registerScriptEditBoxHandler(editBoxTextEventHandle)
	self.m_pEditBox:setPlaceholderFont(Resources.FONT_ARIAL, Resources.FONT_SIZE)
	self.m_pEditBox:setPlaceholderFontColor(ccc3(255,255,255))
    self.m_pEditBox:setMaxLength(40)
    self.m_pEditBox:setFont(Resources.FONT_ARIAL, Resources.FONT_SIZE)
    self.m_pEditBox:setTouchPriority(kCCMenuHandlerPriority)
	self:addChild(self.m_pEditBox)

	self.m_pLabelMsg = SpeakerLabel.create(" ", Resources.FONT_ARIAL, 24)
	self.m_pLabelMsg:setHorizontalAlignment(kCCTextAlignmentLeft)
	self.m_pLabelMsg:setAnchorPoint(ccp(0.5,0))
	self.m_pLabelMsg:setPosition(ccp(0,0))

	local pClippingNode = CCClippingNode:create()
	pClippingNode:addChild(self.m_pLabelMsg)

	self.m_pClippingModel = CCSprite:create()
	local contentSize = self.m_pEditBox:getContentSize()
	self.m_pClippingModel:setTextureRect(
			CCRect(0, 0, contentSize.width * 0.95 * self:getScale(),
					contentSize.height * self:getScale()))

	pClippingNode:setStencil(self.m_pClippingModel)
	self:addChild(pClippingNode)

    function onSpeakerClick(first, target, e)
        if (target == nil) then
            return
        end
	    if (self.m_pHistory ~= nil) then
		    self.m_pHistory:removeFromParentAndCleanup(true)
		    self.m_pHistory = nil
	    end
	    if (self.m_pBtnSpeaker ~= nil) then
		    if (self.m_pEditBox:isEnabled()) then
			    self.m_pEditBox:setEnabled(false)
			    self.m_pEditBox:setText("")
			    self.m_pEditBox:setPlaceHolder("")
			    self.m_pLabelMsg:setVisible(true)
		    else
			    self.m_pEditBox:setEnabled(true)
			    local nleftLaba = 0
                local ganeLib = GameLibSink.m_gameLib
                if (gameLib ~= nil) then
                    nleftLaba = gameLib:getFreeSpeakerLeft()
                end
			    if (nleftLaba ~= 0) then
				    self.m_pEditBox:setPlaceHolder(string.format(Resources.DESC_FREESPEAKER_NUM , nleftLaba))
			    else
				    self.m_pEditBox:setPlaceHolder(Resources.DESC_SPEAKER_SENDTIPS)
			    end
			    self.m_pLabelMsg:setVisible(false)
			    self.m_pEditBox:setText("")
			    self.m_pEditBox:sendActionsForControlEvents(CCControlEventTouchUpInside)
		    end
	    end
    end

	self.m_pBtnSpeaker = createButtonWithFilePath(szBtnSpeakerUrl, 0, onSpeakerClick)
	self.m_pBtnSpeaker:setPosition(ccp(tEditBox:getContentSize().width * 0.5 + 15, -2))
	self:addChild(self.m_pBtnSpeaker)

    local gameLib = GameLibSink.m_gameLib
	self.m_nleftLaba = 0
    if (gameLib ~= nil) then
        self.m_nleftLaba = gameLib:getFreeSpeakerLeft()
    end
	self.m_freeLabaNum = CCSprite:create(szFreeLabaBG)
	self.m_freeLabaNum:setAnchorPoint(ccp(0, 0))
	self.m_freeLabaNum:setPosition(ccp(self.m_pBtnSpeaker:getContentSize().width - self.m_freeLabaNum:getContentSize().width, self.m_pBtnSpeaker:getContentSize().height - self.m_freeLabaNum:getContentSize().height))
	self.m_freeNum = CCLabelTTF:create(string.format("%d", self.m_nleftLaba), Resources.FONT_ARIAL_BOLD, 15)
	self.m_freeNum:setPosition(ccp(self.m_freeLabaNum:getContentSize().width / 2, self.m_freeLabaNum:getContentSize().height / 2))
	self.m_freeLabaNum:addChild(self.m_freeNum)
	if (self.m_nleftLaba == 0) then
		self.m_freeLabaNum:setVisible(false)
	else
		self.m_freeLabaNum:setVisible(true)
	end
	self.m_pBtnSpeaker:addChild(self.m_freeLabaNum) 

	self:runSpeakAction()
	if (self.m_UserSpeakContent ~= nil and #self.m_UserSpeakContent) then
		self.m_fSysSpeakBuf = 0
	end
end

function Speaker:setLeftLaba()
    local gameLib = GameLibSink.m_gameLib
    if (gameLib ~= nil) then
	    self.m_nleftLaba = gameLib:getFreeSpeakerLeft()
	    if (self.m_nleftLaba ~= 0) then
		    self.m_freeNum:setString(string.format("%d", self.m_nleftLaba))
		    self.m_freeLabaNum:setVisible(true)
	    else
		    self.m_freeLabaNum:setVisible(false)
	    end
    end
end

function Speaker.create(szBGFileName, szBtnSpeakerUrl, szFreeLabaBG, GameLibSink)
	local speaker = Speaker.new()
	if (speaker == nil) then
		return nil
	end
	speaker:initData(szBGFileName, szBtnSpeakerUrl, szFreeLabaBG, GameLibSink)
	return speaker
end

return Speaker