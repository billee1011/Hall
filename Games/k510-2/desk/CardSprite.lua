
local GameDefs = require("bull/GameDefs")
local Resources = require("bull/Resources")
local CardSprite =class("CardSprite",function()
                return CCLayer:create()
                end)

CardSprite.GRAY_COLOR = ccc3(166, 166, 166)
CardSprite.NORMAL_COLOR = ccc3(255, 255, 255)

function CardSprite:onEnter()
    self:initUI()
end

function CardSprite:onExit()
end

function CardSprite:init(stCard)
    self.m_stCard = stCard
    self.m_orginPos=ccp(0,0)
    self.m_bClickToGray = false
    self.m_bIsCanMove = false
    self.m_bIsCanClick = true
    self.m_bIsCanMoveNoLimt = false
    self.m_bIsChangeOrder = false
    self.m_bIsClickScale = true
    self.m_bGary =false

    local function onNodeEvent(event)
        if event =="enter" then
            self:onEnter()
        elseif event =="exit" then
            self:onExit()
        end        
    end

    local function onTouch(eventType ,x ,y)
        if eventType=="began" then
          return self:onTouchBegan(x,y)
        elseif eventType=="moved" then
          self:onMoved(x,y)
        elseif eventType=="ended" then
          self:onEnded(x,y)
        end
    end
    self.onTouch = onTouch
    self:registerScriptHandler(onNodeEvent)
    self:setTouchEnabled(true)
    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority+1,true)

    if self.m_stCard == nil then
        self.m_pFilePath = "cardback.png"
    else
        self.m_pFilePath = string.format("card%d_%d.png", self.m_stCard.m_byCardStyle, self.m_stCard.m_byCardPoint)
    end

    local pFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(self.m_pFilePath)
    self.m_normalSp = CCSprite:createWithSpriteFrame(pFrame)

    if not self.m_normalSp then
        return false
    end
    self:addChild(self.m_normalSp)
    return true
end

function CardSprite:initUI()
    local spRect = self.m_normalSp:getTextureRect()
    self:setContentSize(CCSize(spRect.size.width, spRect.size.height))
    self.m_normalSp:setAnchorPoint(ccp(0.5,0.5))
    self.m_normalSp:setPosition(ccp(self:getContentSize().width/2, self:getContentSize().height/2))
    self.m_orginPos = ccp(self:getPosition())
    

    local pFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("cardback.png")
    self.m_hideSp = CCSprite:createWithSpriteFrame(pFrame)
    self.m_hideSp:setAnchorPoint(ccp(0.5,0.5))
    self.m_hideSp:setPosition(ccp(self:getContentSize().width/2, self:getContentSize().height/2))
    self.m_hideSp:setVisible(false)
    self:addChild(self.m_hideSp)

 --[[   local normalSpSize = self.m_normalSp:getContentSize()
    self.m_cardArrowSp = CCSprite:create("bull/bullResources/DeskScene/tingPaiArrow.png")
    self.m_cardArrowSp:setAnchorPoint(ccp(0.5,0))
    self.m_cardArrowSp:setPosition(ccp(normalSpSize.width/2,normalSpSize.height))
    self.m_cardArrowSp:setVisible(false)
    self.m_normalSp:addChild(self.m_cardArrowSp)]]

    if self.m_bGary then
        self.m_normalSp:setColor(CardSprite.GRAY_COLOR)
    end
end

function CardSprite:isSelfVisible()
    local node = self
    while node ~= nil do
        if not node:isVisible() then break end
        node = node:getParent()
    end

    return node == nil
end

function CardSprite:setCard(stCard)
    self.m_stCard  = stCard
end

function CardSprite:getCard()
    return self.m_stCard
end


function CardSprite:containPoint(x,y)
    return self.m_normalSp:boundingBox():containsPoint(self.m_normalSp:getParent():convertToNodeSpace(ccp(x,y)))
end

function CardSprite:getTouchEndPos()
    return self.m_endPoint
end

function CardSprite:setCallback(callbackHanler)
    self.m_actionCallBack = callbackHanler
end

function CardSprite:setTouchBeganCallback(touchBeganCallbackHanler)
    self.m_touchBeganActionCallBack = touchBeganCallbackHanler
end

function CardSprite:setMoveCallback(moveCallbackHanler)
    self.m_moveActionCallBack = moveCallbackHanler
end

function CardSprite:setGray(bIsGray)
    self.m_bGary=bIsGray
end

function CardSprite:setClickToGray(bIsGray)
    self.m_bClickToGray = bIsGray
end

function CardSprite:setClickScale(bIsScale)
    self.m_bIsClickScale = bIsScale
end

function CardSprite:setChangeZOrder(bIsChangeOrder)
    self.m_bIsChangeOrder = bIsChangeOrder
end

function CardSprite:getIsCanMove()
    return self.m_bIsCanMove
end

function CardSprite:setIsCanMove(bIsCanMove)
    self.m_bIsCanMove = bIsCanMove
end

function CardSprite:getIsCanClick()
    return self.m_bIsCanClick
end

function CardSprite:setIsCanClick(bIsCanClick)
    self.m_bIsCanClick = bIsCanClick
end

function CardSprite:setIsCanMoveNoLimt(bIsCanMoveNoLimt)
    self.m_bIsCanMoveNoLimt = bIsCanMoveNoLimt
end

function CardSprite:getCardSpriteOrginPos()
    return self.m_orginPos
end

function CardSprite:setCardSpritePos(pos)
    self.m_orginPos = pos
    self:setPosition(self.m_orginPos)
end


function CardSprite:setCardSpriteScale(nScale)
    if self.m_normalSp then
        self.m_normalSp:setScale(nScale)
    end
    if self.m_hideSp then
        self.m_hideSp:setScale(nScale)
    end
end

function CardSprite:setCardArrowIsVis(bIsVis)
    if self.m_cardArrowSp then
        self.m_cardArrowSp:setVisible(bIsVis)
    end
end

function CardSprite:setCardColorIsGray(bIsGray)
    if self.m_normalSp then
        if bIsGray then
            self.m_normalSp:setColor(CardSprite.GRAY_COLOR)
        else
            self.m_normalSp:setColor(CardSprite.NORMAL_COLOR)
        end
    end
end

function CardSprite:setNormalSpriteIsVis( bIsVis )
    if self.m_normalSp then
        self.m_normalSp:setVisible(visible)
    end
end

function CardSprite:setBackSpriteIsVis(bIsVis)
    if self.m_hideSp then
        self.m_hideSp:setVisible(bIsVis)
    end
end

function CardSprite:setOrbitHVCard(bIsHorizontalOrbit,nDeley,callback)
    self.m_normalSp:setVisible(false)
    local orbitFront = nil
    local orbitBack =  nil
    if bIsHorizontalOrbit then
        orbitFront = CCOrbitCamera:create(0.1,1,0,-270,-90,0,0) --270 90
        orbitBack =  CCOrbitCamera:create(0.1,1,0,0,-90,0,0)
    else
        orbitFront = CCOrbitCamera:create(0.1,1,0,180,180,90,0)
        orbitBack =  CCOrbitCamera:create(0.1,1,0,180,0,90,0)
    end

    local actionArrayFront=CCArray:create()
    actionArrayFront:addObject(CCShow:create())
    actionArrayFront:addObject(orbitBack)
    actionArrayFront:addObject(CCHide:create())

    local cardFontAction = CCTargetedAction:create(self.m_normalSp,CCSequence:createWithTwoActions(CCShow:create(),orbitFront))
    actionArrayFront:addObject(cardFontAction)

    local function callfunc()
        if callback then
            callback(self)
        end
    end

    if nDeley then
        actionArrayFront:addObject(CCDelayTime:create(nDeley))
        actionArrayFront:addObject(CCCallFunc:create(callfunc))
    end

    self.m_hideSp:runAction(CCSequence:create(actionArrayFront))
end
     
function CardSprite:onTouchBegan(x,y)
    if self.m_bIsCanClick == false then
        return true
    end
    if not self:isSelfVisible() then return false end
    self.m_bTouchMove=false
    self.m_bTouchBegan =false
    self.m_touchBeginPoint =ccp(x,y)
    self.m_endPoint = ccp(x,y)
    if self:containPoint(x,y)==true then
        self.m_bTouchBegan = true
        if self.m_touchBeganActionCallBack then
            self.m_touchBeganActionCallBack(self,ccp(x,y))
        end
        if self.m_bIsChangeOrder then
            self:setZOrder(self:getZOrder()+1)
        end
        if self.m_bClickToGray then
            self.m_normalSp:setColor(CardSprite.GRAY_COLOR)
        end
        if self.m_bIsClickScale then
            self.m_normalSp:setScale(1.1)
        end
        return true
    else
        return false
    end
    return true
end

function CardSprite:onMoved(x,y)
    local nDst = 30
    if self.m_bIsCanMove and self.m_bTouchBegan then
        if math.abs(self.m_touchBeginPoint.x-x)>=nDst or math.abs(self.m_touchBeginPoint.y-y)>=nDst  then
            self.m_bTouchMove=true
            if self.m_bIsCanMoveNoLimt == false then
                self.m_bTouchBegan = false
            end
            local point = ccp(self:getPosition())
            self:setPosition(ccp(point.x+(x-self.m_endPoint.x),point.y+(y-self.m_endPoint.y)))
            if self.m_moveActionCallBack then
                self.m_moveActionCallBack(self,ccp(x,y))
            end
        end
    end
    self.m_endPoint = ccp(x,y)
end

function CardSprite:onEnded(x,y)
    if not self:isSelfVisible() then return end
    self.m_endPoint = ccp(x,y)
    if self.m_bTouchBegan then
        if self.m_bIsClickScale then
            self.m_normalSp:setScale(1.0)
        end
        if  self.m_bIsChangeOrder then
            self:setZOrder(self:getZOrder()-1)
        end
        if self.m_actionCallBack~=nil then
            self.m_bTouchBegan = false
            self.m_actionCallBack(self,false)
        end
    end
    if self.m_bClickToGray then
        self.m_normalSp:setColor(CardSprite.NORMAL_COLOR) 
    end
end

function CardSprite:resetTouchPriorty(priorty,cbSwallow)
    self:registerScriptTouchHandler(self.onTouch,false,priorty,cbSwallow)
    self:setTouchEnabled(false)
    self:setTouchEnabled(true)
end

function CardSprite.create(stCard)
    local cardSprite = CardSprite.new()
    if cardSprite==nil then
        return nil
    end
    if not cardSprite:init(stCard) then
        return nil
    end
    return cardSprite
end

return CardSprite
