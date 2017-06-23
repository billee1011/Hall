
local Resources = require("bull/Resources")
local SoundRes = require("bull/SoundRes")
local GameCfg = require("bull/desk/public/GameCfg")
local CardSprite = require("bull/desk/CardSprite")
local GameDefs = require("bull/GameDefs")
local GameLibSink = require("bull/GameLibSink")

local MainPlayerCardLayer =class("MainPlayerCardLayer",function()
                return CCLayer:create()
                end)

MainPlayerCardLayer.N_UP_Y=40
MainPlayerCardLayer.DST_W=0

function MainPlayerCardLayer:onEnter()
    self:initUI()
end

function MainPlayerCardLayer:onExit()
end

function MainPlayerCardLayer:resetInit()
    self.m_vMJGroupCard={}
    self.m_vHandSpriteTable={}
    self.m_vCurrSelectCard={}
end

function MainPlayerCardLayer:init(pParent)
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

function MainPlayerCardLayer:initUI()

end

function MainPlayerCardLayer:takeCardUp(vUpCards)
    if (vUpCards == nil or #vUpCards < 1) then
        return
    end
    for i = 1, #self.m_vHandSpriteTable do
        for j = 1, #vUpCards do
            if (vUpCards[j] == self.m_vHandSpriteTable[i].m_nCardValue) then
                local pMjOrginPos = ccp(self.m_vHandSpriteTable[i]:getCardSpriteOrginPos().x,self.m_vHandSpriteTable[i]:getCardSpriteOrginPos().y)
                self.m_vHandSpriteTable[i]:setPosition(ccp(pMjOrginPos.x,pMjOrginPos.y+MainPlayerCardLayer.N_UP_Y))
            end
        end
    end 
end

function MainPlayerCardLayer:setOneCardNotVis(nCardValue)
    local nSize = #self.m_vHandSpriteTable
    for i=nSize,1,-1 do
        local mjSp = self.m_vHandSpriteTable[i]
        if mjSp and mjSp.m_nCardValue==nCardValue then
            mjSp:setVisible(false)
            break
        end
    end
end

function MainPlayerCardLayer:putHandCards(bIsSendCard, bAddCard, bShowCard,nCount)
    local winSize = CCDirector:sharedDirector():getWinSize()

    local nMjCount = #self.m_vMJGroupCard
    if bIsSendCard then
        nMjCount = nCount
    end
    local nStartX = (winSize.width - GameDefs.MAX_CARD_COUNT * 140) / 2 + 20
    local nStartY = 30
    local function touchBeganCallbackHanler(pNode,bIsmove)

    end
    local function touchCardEndCallBack(pNode,bIsmove)
        self:cardSpriteClickCallBack(pNode,bIsmove)
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

        for i=1,nMjCount do
            local function handlerCallBack(nIndex)
                local mjCardSprite = CardSprite.create(self.m_vMJGroupCard[nIndex])
                if mjCardSprite then
                    if not self.isReplay and self.m_parent:getGameSceneLayer():getGameSection() == GameDefs.emGameSection.GAME_SECTION_CARD_SORT then
                        mjCardSprite:setIsCanClick(true)
                    else
                        mjCardSprite:setIsCanClick(false)
                    end
					if bShowCard == true then 
						mjCardSprite:setIsCanClick(false)
					end
                    mjCardSprite:setTouchBeganCallback(touchBeganCallbackHanler)
                    mjCardSprite:setCallback(touchCardEndCallBack)
                    mjCardSprite:setMoveCallback(touchCardMoveCallBack)
                    mjCardSprite:setClickScale(false)
                    mjCardSprite:setAnchorPoint(ccp(0,0))
                    mjCardSprite:setPosition(ccp(nStartX+(i-1)*140, nStartY))
                    self:addChild(mjCardSprite,i+10)
                    if bAddCard  then 
						if self.m_parent:getIsSeeCardBeforeStake() == false then --非看牌抢庄每张牌都要翻转
							mjCardSprite:setOrbitHVCard(true, 0.2)
						elseif i == nCount then
							mjCardSprite:setOrbitHVCard(true, 0.2)
						end
                        
                    end
                    table.insert(self.m_vHandSpriteTable, mjCardSprite)

                    if self.m_parent:getNiuType() == nil then
                        if self:isCardSelected(self.m_vMJGroupCard[i]) == true then
                            local pMjOrginPos = ccp(mjCardSprite:getCardSpriteOrginPos().x,mjCardSprite:getCardSpriteOrginPos().y)
                            mjCardSprite:setPosition(ccp(pMjOrginPos.x,pMjOrginPos.y+MainPlayerCardLayer.N_UP_Y))
                        end
                    else
                        nStartX = 520
                        nStartY = 150
                        mjCardSprite:setIsCanMove(false)
                        mjCardSprite:setPosition(ccp(nStartX+(i-1)*33, nStartY))
                        mjCardSprite:setCardSpriteScale(0.66)
                    end
                end
            end
            if bIsSendCard and i==nCount then
                local mjCardSprite = CardSprite.create(self.m_vMJGroupCard[i])
                if mjCardSprite then
                    mjCardSprite:setIsCanClick(false)
                    mjCardSprite:setIsCanMove(false)
                    mjCardSprite:setClickScale(false)
                    mjCardSprite:setAnchorPoint(ccp(0,0))
                    mjCardSprite:setPosition(ccp(nStartX+(i-1)*140, nStartY+80))
				   
                    self:addChild(mjCardSprite,i)
                    local function actionOver()
                        handlerCallBack(nCount)
                        if nCount == #self.m_vMJGroupCard then
                            self.m_bIsSending = false
                        end
                    end
                    local array = CCArray:create()
                    array:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(0.1), CCMoveBy:create(0.2, ccp(0, -80))))
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

function MainPlayerCardLayer:cardSpriteClickCallBack(pNode,bIsmove)
    local pMjOrginPos = ccp(pNode:getCardSpriteOrginPos().x,pNode:getCardSpriteOrginPos().y)
    local pMjPos = ccp(pNode:getPosition())

    if (pMjPos.y==pMjOrginPos.y+MainPlayerCardLayer.N_UP_Y) or bIsmove==true then
        pNode:setPosition(pMjOrginPos)
        self:removeSelectCard(pNode:getCard())
    else
        if #self.m_vCurrSelectCard < 3 then
            pNode:setPosition(ccp(pMjOrginPos.x,pMjOrginPos.y+MainPlayerCardLayer.N_UP_Y))
            self:addSelectCard(pNode:getCard())
        end
    end
	cclog("cardSpriteClickCallBack")
    self:sendSelectCards()
    SoundRes.playGlobalEffect(SoundRes.SOUND_SELECTMAJIANG)
end

function MainPlayerCardLayer:addSelectCard(pCard)
    local nCount = #self.m_vCurrSelectCard
    if nCount >= 3 then
        return
    end
    for i=1,nCount do
        local oneCard = self.m_vCurrSelectCard[i]
        if oneCard.m_byCardStyle == pCard.m_byCardStyle and oneCard.m_byCardPoint == pCard.m_byCardPoint then
            return
        end
    end
    pCard.m_byIsSelect = 1
    table.insert(self.m_vCurrSelectCard, pCard)
end

function MainPlayerCardLayer:removeSelectCard(pCard)
    local nCount = #self.m_vCurrSelectCard
    for i=1,nCount do
        local oneCard = self.m_vCurrSelectCard[i]
        if oneCard.m_byCardStyle == pCard.m_byCardStyle and oneCard.m_byCardPoint == pCard.m_byCardPoint then
            pCard.m_byIsSelect = 0
            oneCard.m_byIsSelect = 0
            table.remove(self.m_vCurrSelectCard, i)
            return
        end
    end
end

function MainPlayerCardLayer:isCardSelected(pCard)
    local nCount = #self.m_vCurrSelectCard
    for i=1,nCount do
        local oneCard = self.m_vCurrSelectCard[i]
        if oneCard.m_byCardStyle == pCard.m_byCardStyle and oneCard.m_byCardPoint == pCard.m_byCardPoint then
            return true
        end
    end
    return false
end

function MainPlayerCardLayer:sendSelectCards()
	--self.m_parent是player,self.m_parent.m_parents desk
	self.m_parent.m_parent:onNotifyListenCard()
	--require("GameLib/common/EventDispatcher"):instance():dispatchEvent(GameCfg.NOTIFICATION_LISTENCARD, self.m_vCurrSelectCard)
   -- require("Resources").dispatchEvent(GameCfg.NOTIFICATION_LISTENCARD, self.m_vCurrSelectCard)
end

function MainPlayerCardLayer:resetSelectCards()
    self.m_vCurrSelectCard = {}
    self:sendSelectCards()
end

function MainPlayerCardLayer:getSelectCards()
    return self.m_vCurrSelectCard
end

function MainPlayerCardLayer:getUnSelectCards()
    local vUnSelectCards = {}
    local nCount = #self.m_vMJGroupCard
    for i=1,nCount do
        local oneCard = self.m_vMJGroupCard[i]
        if self:isCardSelected(oneCard) == false then
            table.insert(vUnSelectCards, oneCard)
        end
    end
    return vUnSelectCards
end

function MainPlayerCardLayer:setGroupCards(vMJGroupCard)
    local bSendCards = false
    local bAddCards = false
	
    if #self.m_vMJGroupCard == 0 then
        bSendCards = true
    else
        if self.m_vMJGroupCard[GameDefs.MAX_CARD_COUNT]:IsHide() and vMJGroupCard[GameDefs.MAX_CARD_COUNT]:IsHide() == false then
            bAddCards = true
        end
        if self.m_vMJGroupCard[GameDefs.MAX_CARD_COUNT]:IsValid() == false and vMJGroupCard[GameDefs.MAX_CARD_COUNT]:IsValid() then
            bAddCards = true
        end
    end

    if #vMJGroupCard > 0 then
        for i=1,#vMJGroupCard do
            self.m_vMJGroupCard[i]=vMJGroupCard[i]
        end
    end

    if not self.m_bIsSending then
    
        if bSendCards == true then
            self.m_bIsSending = true
            for i=1,#vMJGroupCard do
                local function delayOver()
                    self:putHandCards(true,false,false,i)
                end
                local arrayAction = CCArray:create()
                arrayAction:addObject(CCDelayTime:create(i*0.1))
                arrayAction:addObject(CCCallFunc:create(delayOver))
                self:runAction(CCSequence:create(arrayAction))
            end
        else
            if bAddCards == true then
				--for i = 1, 5 do
					--self:putHandCards(false,true,false,GameDefs.MAX_CARD_COUNT)
					self:putHandCards(false,true,false,GameDefs.MAX_CARD_COUNT)
			--	end
            else
                self:putHandCards(false,false,false,0)
            end
        end

    end
end

function MainPlayerCardLayer:getGroupCards()
    return self.m_vMJGroupCard
end

function MainPlayerCardLayer:showCards()
    self:putHandCards(false,false,true,0)
end

function MainPlayerCardLayer:setRoomInfo(roomInfo)
    self.m_roomInfo = roomInfo
end

function MainPlayerCardLayer:gameOver()
    self:resetSelectCards()
    self:resetInit()
    self:removeAllChildrenWithCleanup(true)
end

function MainPlayerCardLayer:onTouchBegan(x,y)
    return true
end

function MainPlayerCardLayer:onMoved(x,y)

end

function MainPlayerCardLayer:onEnded(x,y)

end

function MainPlayerCardLayer.create(pParent,isReplay)
    local mainPlayerCardLayer = MainPlayerCardLayer.new()
    if mainPlayerCardLayer==nil then
        return nil
    end
	mainPlayerCardLayer.isReplay = isReplay
    mainPlayerCardLayer:init(pParent)
    return mainPlayerCardLayer
end

return MainPlayerCardLayer