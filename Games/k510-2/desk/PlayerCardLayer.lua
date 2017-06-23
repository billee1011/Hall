
local Resources = require("bull/Resources")
local SoundRes = require("bull/SoundRes")
local GameCfg = require("bull/desk/public/GameCfg")
local CardSprite = require("bull/desk/CardSprite")
local GameDefs = require("bull/GameDefs")
local GameLibSink = require("bull/GameLibSink")
local PlayerCardLayer =class("PlayerCardLayer",function()
                return CCLayer:create()
                end)

function PlayerCardLayer:onEnter()
    self:initUI()
end

function PlayerCardLayer:onExit()
end

function PlayerCardLayer:resetInit()
    self.m_vMJGroupCard={}
    self.m_vHandSpriteTable={}
end

function PlayerCardLayer:init(pParent)
    self.m_parent = pParent
    self:resetInit()

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
    
    self:registerScriptHandler(onNodeEvent)
    self:setTouchEnabled(true)
    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,false)

end

function PlayerCardLayer:initUI()

end

function PlayerCardLayer:putHandCards(bIsSendCard, bShow, nCount)
    local winSize = CCDirector:sharedDirector():getWinSize()

    local nMjCount = #self.m_vMJGroupCard
    if bIsSendCard then
        nMjCount = nCount
    end
    local nStartX = 0
    local nStartY = 0
    local function touchBeganCallbackHanler(pNode,bIsmove)

    end
    local function touchCardEndCallBack(pNode,bIsmove)

    end
    local function touchCardMoveCallBack(pNode,pos)

    end
    if nMjCount>0 then

        for i=1,#self.m_vHandSpriteTable do
            if self.m_vHandSpriteTable[i] then
                self.m_vHandSpriteTable[i]:removeFromParentAndCleanup(true)
                self.m_vHandSpriteTable[i] = nil
            end
        end
        self.m_vHandSpriteTable={}
		local  basePos = self.m_parent.allPlayerPos
		nStartX = basePos[self.m_parent.m_nPos][6].x
		nStartY = basePos[self.m_parent.m_nPos][6].y
 --[[       if self.m_parent:IsLeftOne() then
            nStartX = basePos[5][2].x + 88--133
            nStartY = basePos[5][2].y - 20 --255
        elseif self.m_parent:IsLeftTwo() then
            nStartX = basePos[4][2].x + 88--237
            nStartY = basePos[4][2].y - 25--445
        elseif self.m_parent:IsRightOne() then
            nStartX = basePos[2][2].x -234 --winSize.width - 393
            nStartY = basePos[2][2].y - 20--255
        elseif self.m_parent:IsRightTwo() then
            nStartX = basePos[3][2].x - 234--winSize.width - 503
            nStartY = basePos[3][2].y - 25 --445
        end]]

        for i=1,nMjCount do
            local function handlerCallBack(nIndex)
                local mjCardSprite = nil
                if self.m_parent:getNiuType() == nil then
                    mjCardSprite = CardSprite.create(nil)
                else
                    mjCardSprite = CardSprite.create(self.m_vMJGroupCard[nIndex])
                end
                if mjCardSprite then
                    mjCardSprite:setIsCanMove(false)
                    mjCardSprite:setTouchBeganCallback(touchBeganCallbackHanler)
                    mjCardSprite:setCallback(touchCardEndCallBack)
                    mjCardSprite:setMoveCallback(touchCardMoveCallBack)
                    mjCardSprite:setClickScale(false)
                    mjCardSprite:setAnchorPoint(ccp(0,0))
                    mjCardSprite:setPosition(ccp(nStartX+(i-1)*33, nStartY))
                    mjCardSprite:setCardSpriteScale(0.66)
                    self:addChild(mjCardSprite,i)
                    if bShow and i==nCount then
                        --mjCardSprite:setOrbitHVCard(true, 0.2)
                        if nCount == #self.m_vMJGroupCard then
                            self.m_bIsShow = false
                        end
                    end
                    table.insert(self.m_vHandSpriteTable, mjCardSprite)
                end
            end
            if bIsSendCard and i==nCount then
                local mjCardSprite = nil
                if self.m_parent:getNiuType() == nil then
                    mjCardSprite = CardSprite.create(nil)
                else
                    mjCardSprite = CardSprite.create(self.m_vMJGroupCard[i])
                end
                if mjCardSprite then
                    mjCardSprite:setIsCanMove(false)
                    mjCardSprite:setClickScale(false)
                    mjCardSprite:setAnchorPoint(ccp(0,0))
                    mjCardSprite:setPosition(ccp(nStartX+(i-1)*30, nStartY+50))
                    mjCardSprite:setCardSpriteScale(0.6)
                    self:addChild(mjCardSprite,i)
                    local function actionOver()
                        handlerCallBack(nCount)
                        if nCount == #self.m_vMJGroupCard then
                            self.m_bIsSending = false
                        end
                    end
                    local array = CCArray:create()
                    array:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(0.1), CCMoveBy:create(0.2, ccp(0, -50))))
                    array:addObject(CCRemoveSelf:create(true))
                    array:addObject(CCCallFunc:create(actionOver))
                    mjCardSprite:runAction(CCSequence:create(array))
                end
            else
                handlerCallBack(i)
            end
        end 
    end
end

function PlayerCardLayer:setGroupCards(vMJGroupCard)
    if not self.isReplay and not self.m_parent:IsValid() then
        return
    end

    local bSendCards = false

    if #self.m_vMJGroupCard == 0 then
        bSendCards = true
    end

    if #vMJGroupCard > 0 then
        for i=1,#vMJGroupCard do
            self.m_vMJGroupCard[i]=vMJGroupCard[i]
        end
    end

    if not self.m_bIsSending then
        if bSendCards == true then
            self.m_bIsSending = true
            for i=1,#self.m_vMJGroupCard do
                local function delayOver()
                    self:putHandCards(true,false,i)
                end
                local arrayAction = CCArray:create()
                arrayAction:addObject(CCDelayTime:create(i*0.1))
                arrayAction:addObject(CCCallFunc:create(delayOver))
                self:runAction(CCSequence:create(arrayAction))
            end
        else
            self:putHandCards(false,false,0)
        end
    end
end

function PlayerCardLayer:getGroupCards()
    return self.m_vMJGroupCard
end

function PlayerCardLayer:showCards()
    if not self.m_bIsShow then
        self.m_bIsShow = true
        for i=1,#self.m_vMJGroupCard do
            local function delayOver()
                self:putHandCards(false,true,i)
            end
            local arrayAction = CCArray:create()
            arrayAction:addObject(CCDelayTime:create(i*0.1))
            arrayAction:addObject(CCCallFunc:create(delayOver))
            self:runAction(CCSequence:create(arrayAction))
        end
    end
end

function PlayerCardLayer:setRoomInfo(roomInfo)
    self.m_roomInfo = roomInfo
end

function PlayerCardLayer:gameOver()
    self:resetInit()
    self:removeAllChildrenWithCleanup(true)
end

function PlayerCardLayer:onTouchBegan(x,y)
   return true
end

function PlayerCardLayer:onMoved(x,y)
   
end

function PlayerCardLayer:onEnded(x,y)
    
end

function PlayerCardLayer.create(pParent,isReplay)
    local playerCardLayer = PlayerCardLayer.new()
    if playerCardLayer==nil then
        return nil
    end
	playerCardLayer.isReplay = isReplay --标记是不是回放
    playerCardLayer:init(pParent)
    return playerCardLayer
end

return PlayerCardLayer