require("CocosExtern")
require("FFSelftools/controltools")

local Resources = require("Resources")

local CoinInfoItem = class("CoinInfoItem", function()
  return CCNode:create()
end)

CoinInfoItem.TYPE_GOLD = 0
CoinInfoItem.TYPE_DIAMOND = 1
CoinInfoItem.TYPE_QUAN = 5
CoinInfoItem.TYPE_FANGKA = 3

function CoinInfoItem:onEnter()
    local function onHandler(dt)
        self:onTimerHandler(dt)
    end
    self.m_onTimerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onHandler, 0.05, false)
end

function CoinInfoItem:onExit()
    if self.m_onTimerId then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.m_onTimerId)
        self.m_onTimerId = nil
    end
end

function CoinInfoItem:setString(nCoinNum)
  if (self.m_pLabelCoin ~= nil) then
    self.m_pLabelCoin:setString(require("HallUtils").formatGold(nCoinNum, true))
  end
end

function CoinInfoItem:init(szBgUrl, szCoinUrl, szStarUrl, szPayBtnUtl, szCoinNumUrl, nCoinNum, nType, onControlCallback, bIsShowPayButton)
    self.m_nType = nType
    self.onControlCallback = onControlCallback

    self.m_bVisiSatr=true
    self.m_timeCount= 0

    local function onNodeEvent(event)
        if event =="enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    local pBG = nil
    if (szBgUrl == nil) then
        pBG = CCSprite:create("resources/new/gold_base.png")
    else
        pBG = CCSprite:create(szBgUrl)
    end
    self:addChild(pBG)

    local contentSize = pBG:getContentSize()
    self:setContentSize(contentSize)

    local pIcon = nil
    local space = 0
    local yspace = 0
    self.m_pLabelCoin = nil
    if (szCoinNumUrl == nil) then
        self.m_pLabelCoin = CCLabelTTF:create(require("HallUtils").formatGold(nCoinNum, true),"黑体", 30)
    else
        self.m_pLabelCoin = CCLabelBMFont:create(require("HallUtils").formatGold(nCoinNum, true), szCoinNumUrl)
    end
    if (nType == CoinInfoItem.TYPE_GOLD) then
        if (szCoinNumUrl == nil) then
            self.m_pLabelCoin:setColor(Resources.ccGold)
        end
        if (szCoinUrl == nil) then
            pIcon = CCSprite:create("resources/new/gold_icon.png")
        else
            pIcon = CCSprite:create(szCoinUrl)
        end
        if (szStarUrl == nil) then
            self:addStar(pIcon,"resources/new/yellow_star.png",true,self.m_bVisiSatr)
        else
            self:addStar(pIcon,szStarUrl,true,self.m_bVisiSatr)
        end
        yspace = -2
    elseif(nType == CoinInfoItem.TYPE_QUAN) then
        if (szCoinUrl == nil) then
            pIcon = CCSprite:create("resources/new/quan_icon.png")
        else
            pIcon = CCSprite:create(szCoinUrl)
        end
        if (szCoinNumUrl == nil) then
            self.m_pLabelCoin:setColor(Resources.ccFrag)
        end
        space = 5
    elseif (nType == CoinInfoItem.TYPE_FANGKA) then
        if (szCoinNumUrl == nil) then
            self.m_pLabelCoin:setColor(Resources.ccDiamond) 
        end
        if (szCoinUrl == nil) then
            pIcon = CCSprite:create("bull/bullResources/fangka.png")
        else
            pIcon = CCSprite:create(szCoinUrl)
        end
        -- if (szStarUrl == nil) then
        --     self:addStar(pIcon,"resources/new/blue_star.png",false,self.m_bVisiSatr)
        -- else
        --     self:addStar(pIcon,szStarUrl,false,self.m_bVisiSatr)
        -- end
        space = 5
    else
        if (szCoinNumUrl == nil) then
            self.m_pLabelCoin:setColor(Resources.ccDiamond) 
        end
        if (szCoinUrl == nil) then
            --diamond_icon
            pIcon = CCSprite:create("resources/new/diamond_icon.png")
        else
            pIcon = CCSprite:create(szCoinUrl)
        end
        if (szStarUrl == nil) then
            self:addStar(pIcon,"resources/new/blue_star.png",false,self.m_bVisiSatr)
        else
            self:addStar(pIcon,szStarUrl,false,self.m_bVisiSatr)
        end
    end
    pIcon:setPosition(ccp(pIcon:getContentSize().width / 2 + space, contentSize.height / 2 + yspace))
    pBG:addChild(pIcon)

    local xSpace = 0
    if (nType == CoinInfoItem.TYPE_QUAN) then
        xSpace = 4
    end
    self.m_pLabelCoin:setPosition(ccp(pIcon:getPositionX() + pIcon:getContentSize().width / 2 + xSpace, contentSize.height / 2))
    if (szCoinNumUrl == nil) then
        self.m_pLabelCoin:setHorizontalAlignment(kCCTextAlignmentLeft)
    else
        self.m_pLabelCoin:setPositionY(self.m_pLabelCoin:getPositionY() - 3)
    end
    self.m_pLabelCoin:setAnchorPoint(ccp(0, 0.5))
    pBG:addChild(self.m_pLabelCoin)

    local isShow = true
    if (bIsShowPayButton ~= nil) then
        isShow = bIsShowPayButton
    end

    if (isShow == true) then
        local function onBtnCallback(first, target, event)
            if (self.onControlCallback ~= nil) then
                self.onControlCallback(self.m_nType)
            end
        end
        local pBtnPayNow = nil
        if (szPayBtnUtl == nil) then
            pBtnPayNow = createButtonTwoStatusWithOneFilePath("resources/new/charge_plus.png", 0, onBtnCallback)
        else
            pBtnPayNow = createButtonTwoStatusWithOneFilePath(szPayBtnUtl, 0, onBtnCallback)
        end
        pBtnPayNow:setPosition(ccp(contentSize.width - pBtnPayNow:getContentSize().width / 2 - 2, contentSize.height / 2 - 1))
        pBG:addChild(pBtnPayNow)
        pBtnPayNow:setTouchPriority(kCCMenuHandlerPriority)
    end
end

function CoinInfoItem:addStar(pNode,imgSatrPath,bIsRotate,bIsVisi)

    if not bIsVisi then
        return 
    end
    if bIsRotate then
        self.m_starSp=CCSprite:create(imgSatrPath)
        self.m_starSp:setAnchorPoint(ccp(0.5,0.5))
        self.m_starSp:setPosition(ccp(5,10))
        self.m_starSp:setScale(0)
        pNode:addChild(self.m_starSp)
        self.m_starSp:setVisible(false)
        
    else
        local starPos =
        {
            ccp(8 - 3,20 - 7),
            ccp(40 - 3,30 - 7),
            ccp(20 - 3,40 - 7),
            ccp(33 - 3,20 - 7),
        }
        for i=1,#starPos do
            local starSp=CCSprite:create(imgSatrPath)
            starSp:setScale(0)
            starSp:setAnchorPoint(ccp(0.5,0.5))
            starSp:setPosition(starPos[i])
            starSp:setTag(i)
            pNode:addChild(starSp)
        end
        local arrAction =CCArray:create()
        local starSp1= pNode:getChildByTag(1)
        local spTargetAction1 = CCTargetedAction:create(starSp1, CCScaleTo:create(0.5, 1))
        local spTargetAction11 = CCTargetedAction:create(starSp1, CCScaleTo:create(0.5, 0))
        arrAction:addObject(spTargetAction1)

        local starSp4= pNode:getChildByTag(4)
        local spTargetAction4 = CCTargetedAction:create(starSp4, CCScaleTo:create(0.5, 1))
        local spTargetAction44 = CCTargetedAction:create(starSp4, CCScaleTo:create(0.5, 0))
        arrAction:addObject(CCSpawn:createWithTwoActions(spTargetAction4, spTargetAction11))

        local starSp3= pNode:getChildByTag(3)
        local spTargetAction3 = CCTargetedAction:create(starSp3, CCScaleTo:create(0.5, 1))
        local spTargetAction33 = CCTargetedAction:create(starSp3, CCScaleTo:create(0.5, 0))
        arrAction:addObject(CCSpawn:createWithTwoActions(spTargetAction44, spTargetAction3))

        local starSp2= pNode:getChildByTag(2)
        local spTargetAction2 = CCTargetedAction:create(starSp2, CCScaleTo:create(0.5, 1))
        local spTargetAction22 = CCTargetedAction:create(starSp2, CCScaleTo:create(0.5, 0))
        arrAction:addObject(CCSpawn:createWithTwoActions(spTargetAction33, spTargetAction2))
        --arrAction:addObject(CCSpawn:createWithTwoActions(spTargetAction22, spTargetAction1))
        arrAction:addObject(spTargetAction22)
        arrAction:addObject(CCDelayTime:create(1))
        arrAction:addObject(spTargetAction1)


        local repeatForeverAction= CCRepeatForever:create(CCSequence:create(arrAction))
        self:runAction(repeatForeverAction) 
    end  
end

function CoinInfoItem:onTimerHandler(dt)

    if self.m_starSp then
        self.m_timeCount = self.m_timeCount + 1
        local e_rot=2*math.pi/36
        local rot=(self.m_timeCount-1+18)*e_rot
        local x=22+20*math.sin(rot)
        local y=24+20*math.cos(rot)
        self.m_starSp:setPosition(ccp(x,y))
        self.m_starSp:setVisible(true)
        if self.m_timeCount>10 and  self.m_timeCount<=40 then
            local ss =  self.m_starSp:getScale()-0.06
            if ss<= 0 then
                ss = 0
            end
            self.m_starSp:setScale(ss)
        elseif self.m_timeCount>40 then
            --延迟0.05*20
            self.m_starSp:setScale(0)
            self.m_timeCount = 0
        else
            local s  = self.m_timeCount*0.06
            if s>=0.6 then
                s= 0.6
            end
            self.m_starSp:setScale(s)
        end
    end
end

function CoinInfoItem.create(szBgUrl, szCoinUrl, szStarUrl, szPayBtnUtl, szCoinNumUrl, nCoinNum, nType, onControlCallback, bIsShowPayButton)
  local item = CoinInfoItem.new()
  item:init(szBgUrl, szCoinUrl, szStarUrl, szPayBtnUtl, szCoinNumUrl, nCoinNum, nType, onControlCallback, bIsShowPayButton)
  return item
end 

return CoinInfoItem