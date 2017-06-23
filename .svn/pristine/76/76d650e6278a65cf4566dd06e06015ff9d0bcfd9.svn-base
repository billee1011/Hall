

local Resources =require("bull/Resources")
local SoundRes =require("bull/SoundRes")
local GameCfg =require("bull/desk/public/GameCfg")
local GlobalMsg =require("bull/public/GlobalMsg")

local Timer =class("Timer",function()
    return CCLayer:create()
end)


function Timer:init(onHandler,timeImgName,imgWidth,imgHeight)
    local function onNodeEvent(event)
        if event =="enter" then
            self:onEnter()
        elseif event =="exit" then
            self:onExit()
        end        
    end
    self.m_onHandler = onHandler
    self:registerScriptHandler(onNodeEvent)

    self.m_pImgClock =nil
    self.m_labelNum=nil
    self.m_fTime = 0
    self.m_flag=-1
    self.schedulerId=nil
    self.m_timeCount=0

    self.m_bPlayEffect=true

    self:setContentSize(CCSize(156, 134))

    self:setVisible(false)

    self.m_pImgClock = loadSprite("bull/clock.png")
    self.m_pImgClock:setAnchorPoint(ccp(0, 0))
    self.m_pImgClock:setPosition(ccp(0, 0))
    self:addChild(self.m_pImgClock)

    self.m_labelNum = CCLabelBMFont:create("","bull/images/number/clocknum.fnt")
    self.m_labelNum:setAnchorPoint(ccp(0.5, 0.5))
	self.m_labelNum:setScale(1.2)
    self.m_labelNum:setPosition(ccp(self:getContentSize().width/2,self:getContentSize().height/2 - 5))
    self.m_pImgClock:addChild(self.m_labelNum)
end

function Timer:initUI()

    local function updateTimer(delta)
        local delt =tonumber(string.format("%d", delta))

        self.m_fTime =self.m_fTime-delt

        if self.m_fTime>=0 then
            self.m_labelNum:setString(string.format("%02d", self.m_fTime))
        end

        if (self.m_fTime < 0) then
            if (self:isVisible()) then

                self:setVisible(false)
                if self.m_onHandler then
                    self.m_onHandler()
                else
                    --require("Resources").
					require("GameLib/common/EventDispatcher"):instance():dispatchEvent(GameCfg.WAKENG_MSG_TIME_OUT, self.m_flag)
                    self.m_flag=-1
                end
               
            end

        elseif(self.m_fTime==3 ) then
            if self.m_bPlayEffect then
              --[[  if (GlobalMsg:instance():isVibratorOpen() == true) then
                    local sJniSelfTools = CJni:shareJni()
                    sJniSelfTools:Vibrate()
                end]]
				SoundRes.playGameShake(100)
                SoundRes.playGlobalEffect(SoundRes.SOUND_CLOCKTIME)
            end
        end
    end

    self.schedulerId =CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTimer, 1.0,false)
    
end

function Timer:onEnter()
    self:initUI()
end

function Timer:onExit()
   CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
end

function Timer:Start(nTime,nFlag)
    self.m_timeCount = nTime
    self.m_fTime =nTime +1
    self.m_flag =nFlag
    self.m_labelNum:setString(string.format("%02d", nTime))
    self:setVisible(true)
end

function Timer:Stop()
    self:stopAllActions()
    self:setVisible(false)
    self.m_fTime = 0
end

function Timer:setIsPlayingEffect(bIsPlaying)
    self.m_bPlayEffect = bIsPlaying
end

function Timer.createTimer(onHandler,timeImgName,imgWidth,imgHeight)
    local timerLayer =Timer.new()
    if timerLayer ==nil then
        return nil 
    end
    timerLayer:init(onHandler,timeImgName,imgWidth,imgHeight)
    return timerLayer
end

return Timer