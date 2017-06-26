require("CocosExtern")
local Resources =require("k510/Resources")
local Card = require("k510/Game/Card")
local PlayerCards =class("PlayerCards", function()
    return CCLayer:create()
    end)
PlayerCards._Span = 70
PlayerCards._MaxSpan = 70
PlayerCards._ChairIndex = -1

PlayerCards.FreshCardType = 
{
    SceneChange = 0,
    LiPai = 1,
    PaiXu = 2,
    HuiFu = 3
}

function PlayerCards.create()
    local layer = PlayerCards.new()
    layer:init()
	return layer
end
 
function PlayerCards:touchDoubleDeskTimer()
   
   if self.touchDoubleDeskTimerId == -1 then
        self.touchDoubleTime = 1.5
        local function PlaySoundTimer(delta)
            self.touchDoubleTime = self.touchDoubleTime - delta
            if (self.touchDoubleTime < 0) then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.touchDoubleDeskTimerId)
                self.touchDoubleDeskTimerId = -1
                self.touchDeskNum = 0
            end
        end
        self.touchDoubleDeskTimerId =CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(PlaySoundTimer, 0.1, false)
   end
   
   self.touchDeskNum = self.touchDeskNum + 1
   if self.touchDeskNum == 2 then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.touchDoubleDeskTimerId)
        self.touchDoubleDeskTimerId = -1
        self.touchDeskNum = 0
        self:HuiFu()
   end
end

function PlayerCards:onTouchBegan(x,y)
    self._StartPos = ccp(x,y)
    for i = #self.cardsSpVec,1,-1 do
        if self.cardsSpVec[i]:isVisible() == true then
            local pTouch = ccp(x,y)
            local point = self.cardsSpVec[i]:getCard():convertToNodeSpace(pTouch)
            local rectSize = self.cardsSpVec[i]:getCard():getContentSize()
            local rect = CCRectMake(0,0,rectSize.width,rectSize.height)
            local isClicked = rect:containsPoint(point)
            if isClicked then
                self.cardsSpVec[i]:setMark(true)
                self._ClickCard = true
                self._ClickCardIndex = i
                return
            end
        end
    end

    self:touchDoubleDeskTimer()

    self._ClickCard = false
end

function PlayerCards:onTouchMoved(x,y)
    if self._ClickCard == true then
         self:MoveMarkCards(x,y)
    end
end

function PlayerCards:onTouchEnded(x,y)
     if self._ClickCard == true then
         self:selectCards(x,y)
    end
end

function PlayerCards:setChairIndex(chairIndex)
     self._ChairIndex = chairIndex
end

function PlayerCards:clear()
   self._playerCardsValueLst  = {}
   self._playerPreCardsValueLst = {}
   self:reset()
end

function PlayerCards:init()
    
    self.touchDoubleDeskTimerId = -1
    self.touchDeskNum = 0

    self.winSize = CCSizeMake(require("k510/GameDefs").CommonInfo.View_Width, require("k510/GameDefs").CommonInfo.View_Height)

    self.cardSortWay = nil
    self._playerCardsValueLst = {}
    self._playerPreCardsValueLst = {}

    --手牌
    self.cardsSpVec = {}
    for i = 1,18 do
        local CardSp = Card:create()
        self:addChild(CardSp)
        CardSp:setScale(0.8)
        table.insert(self.cardsSpVec,CardSp)
    end

    local function onNodeEvent(event)
     if event =="exit" then
         CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.touchDoubleDeskTimerId)
     end
    end

    self:registerScriptHandler(onNodeEvent)
    self.cardMoveSp = Card:create()
    self:addChild(self.cardMoveSp)
    self.cardMoveSp:setVisible(false)

    --牌背
    self.fapaiAcSp = Card:create()
    self.fapaiAcSp:setScale(0.8)
    self:addChild(self.fapaiAcSp)
    self.fapaiAcSp:setVisible(false)
end

-- 发牌动画
function PlayerCards:FapaiAction(playerCardCount)
    local cardCount = playerCardCount
    local function moveCallFunc()
        self.fapaiAcSp:setVisible(false)
    end

    local posX,posY = self.cardsSpVec[1]:getCard():getPosition()
    self.fapaiAcSp:setPos(ccp(posX,posY))
    self.fapaiAcSp:setVisible(true)

    for i = 1,#self.cardsSpVec do
        self.cardsSpVec[i]:getCard():setVisible(false)
    end

    for i = 1, cardCount do
        local function delayCallFunc()
            self.cardsSpVec[i]:getCard():setVisible(true)
            if i + 1 > cardCount then
                self.fapaiAcSp:setVisible(false)
            else
                local posX,posY = self.cardsSpVec[i + 1]:getCard():getPosition()
                self.fapaiAcSp:setPos(ccp(posX,posY))
            end
        end

        local callFun = CCCallFunc:create(delayCallFunc)
        local delayoAction = CCDelayTime:create(0.5 /cardCount * i)
        local array = CCArray:create()
        array:addObject(delayoAction)       
        array:addObject(callFun)
        self.cardsSpVec[i]:getCard():runAction(CCSequence:create(array))
        --self.cardsSpVec[i]:getCard():setVisible(false)
   end
end

-- 把牌动画的牌背隐藏
function PlayerCards:setCardBackHide()
   if self.fapaiAcSp:isVisible() then
      self.fapaiAcSp:setVisible(false)
   end
end

-- 设置我的手牌位置
function PlayerCards:setMyCardsPos()
    for i = 1,#self.cardsSpVec do
       self.cardsSpVec[i]:setVisible(false)
    end

   for i = 1,#self._playerCardsValueLst do
       local value = self._playerCardsValueLst[i]
       self.cardsSpVec[i]:setCardSp(i, value)
       self.cardsSpVec[i]:setVisible(true)
   end

    self._offset = 0
    self._Span = (self.winSize.width - 187 - 2*self._offset)/(#self._playerCardsValueLst - 1)
    if self._Span > self._MaxSpan then
        self._Span = self._MaxSpan
        self._offset = (self.winSize.width - 187 - self._Span*(#self._playerCardsValueLst - 1))/2
           
    end

   for i = 1,#self.cardsSpVec do
      self.cardsSpVec[i]:getCard():setPosition(self._offset + self._Span * (i-1),36)
   end
end

function PlayerCards:setPos(point)
   for i = 1,#self.cardsSpVec do
      self.cardsSpVec[i]:setPos(ccp(point.x + self._Span * (i-1),point.y))
   end
end

function PlayerCards:changeCardsPos()
   if self._ClickCardIndex ~= -1 then
      local offset = self._Span
      self.changePosIndex  = -1
      for i = 1,#self.cardsSpVec do
         if self.cardsSpVec[i]:isVisible() == true then
             local Pos1x, Pos1y = self.cardsSpVec[i]:getCard():getPosition()
             local Pos2x, Pos2y = self.cardMoveSp:getCard():getPosition()
             if Pos2x - Pos1x >=0 and  Pos2x - Pos1x <= offset and math.abs(Pos1y - Pos2y) < self.cardMoveSp:getContentSize().height then
                self.changePosIndex = i
                break
             end
         end
      end

      if self.changePosIndex ~= -1 and self.changePosIndex <= #self._playerCardsValueLst then
         local cardsArray = {}
         for i = 1,#self._playerCardsValueLst do      
            if i == self.changePosIndex then
               table.insert(cardsArray,self._playerCardsValueLst[self._ClickCardIndex])
            end

            if i ~= self._ClickCardIndex then
                table.insert(cardsArray,self._playerCardsValueLst[i])
            end

         end

         if #cardsArray ~= 0 then
            self._playerCardsValueLst = cardsArray
         end
      end
   end
end

-- 选择标记的牌
function PlayerCards:selectCards(x,y)
    for i = #self.cardsSpVec,1,-1 do
        if self.cardsSpVec[i]:isVisible() == true then
            self:setCardsUp(i)
        end
    end
end

-- 移动标记牌
function PlayerCards:MoveMarkCards(x,y)
    self._MoveClickCardIndex = -1
    for i = #self.cardsSpVec, 1, -1 do
       if self.cardsSpVec[i]:isVisible() == true then
           --移动时默认Y在牌中间
           local pTouch = ccp(x,self.cardsSpVec[i]:getPos().y+self.cardsSpVec[i].height/2)
           local point = self.cardsSpVec[i]:getCard():convertToNodeSpace(pTouch)
           local rectSize = self.cardsSpVec[i]:getCard():getContentSize()
           local rect = CCRectMake(0,0,rectSize.width,rectSize.height)
           local isClicked = rect:containsPoint(point)
           if isClicked then
                self._MoveClickCardIndex = i
                local f = math.min(self._ClickCardIndex, self._MoveClickCardIndex)
                local t = math.max(self._ClickCardIndex, self._MoveClickCardIndex)
                -- cclog("select card from index : %d to %d", f, t)
                for j = 1, #self.cardsSpVec do
                    if j < f or j > t then
                        self.cardsSpVec[j]:setMark(false)
                    else
                        self.cardsSpVec[j]:setMark(true)
                    end
                    self.cardsSpVec[j]:showMark()
                end
                break
           end
       end
    end
    self._StartPos = ccp(x,y)
end

function PlayerCards:selectCard(index)
    if index > 0 and index < 29 then
       self.cardsSpVec[index]:setSelect(true)
       self.cardsSpVec[index]:setCardsUp()
    end
end

function PlayerCards:setCardsUp(index)
    if index > 0 and index < 29 then
       self.cardsSpVec[index]:setCardsUp()
    end
end

function PlayerCards:reset()
    for i = #self.cardsSpVec,1,-1 do
        self.cardsSpVec[i]:reset()
    end
end

function PlayerCards:clear()
   self._playerCardsValueLst  = {}
   self._playerPreCardsValueLst = {}
   self:reset()
end

-- 最新的牌值,刷新牌值得类型
function PlayerCards:reFreshPlayerCards(playerCardsLst,refeshType)
    if #self._playerCardsValueLst == #playerCardsLst and refeshType ==  self.FreshCardType.SceneChange then
        return
    end

    if refeshType ==  self.FreshCardType.SceneChange then
        self._playerPreCardsValueLst = {}
    else
        self._playerPreCardsValueLst = self._playerCardsValueLst
    end

    if refeshType ==  self.FreshCardType.SceneChange then
        local markTable = {}
        local playerCardsTemp = {}
        for i = 1,#self._playerCardsValueLst do
            table.insert(playerCardsTemp,self._playerCardsValueLst[i])
        end

        if #playerCardsTemp > 0 then
            for i = #playerCardsTemp,1,-1 do
                local isExist = false
                for j = 1,#playerCardsLst do
                    if playerCardsLst[j] == playerCardsTemp[i] and playerCardsLst[j] ~= -1 then
                        table.insert(markTable,playerCardsTemp[i])
                        playerCardsLst[j] = -1
                        playerCardsTemp[i] = -1
                        break
                    end
                end
            end

            local markTableTemp = {}
            for i = #markTable,1,-1 do
               table.insert(markTableTemp,markTable[i])
            end
            markTable = markTableTemp
        else
            markTable = playerCardsLst
        end 
         
        self._playerCardsValueLst = {}
        self._playerCardsValueLst = markTable
    else
        self._playerCardsValueLst = {}
        self._playerCardsValueLst = playerCardsLst
    end

    for i = 1,#self.cardsSpVec do
        self.cardsSpVec[i]:Hide()
    end

    for i = 1,#self._playerCardsValueLst do
		if self.cardsSpVec[i] and self._playerCardsValueLst[i] then
			local value = self._playerCardsValueLst[i]
		    self.cardsSpVec[i]:setCardSp(i, value)
			self.cardsSpVec[i]:Show()
		end
    end

    local o = 127
    self._offset = 0
    if self._ChairIndex == 0 then
        self._Span = (self.winSize.width/2 - o)/(#self._playerCardsValueLst - 1) * 1.2
        if self._Span > self._MaxSpan then self._Span = self._MaxSpan end
        self._offset = self.winSize.width - self._Span*(#self._playerCardsValueLst - 1)/2 - o
        self:setPos(ccp(self._offset,720))

    elseif self._ChairIndex == 1 then
        self._Span = (self.winSize.width - o)/(#self._playerCardsValueLst - 1)
        if self._Span > self._MaxSpan then
            self._Span = self._MaxSpan
            self._offset = (self.winSize.width - o - self._Span*(#self._playerCardsValueLst - 1))/2
        end
        self:setPos(ccp(self._offset,36))

    elseif self._ChairIndex == 2 then
        self._Span = (self.winSize.width/2 - o)/(#self._playerCardsValueLst - 1) * 1.2
        if self._Span > self._MaxSpan then self._Span = self._MaxSpan end
        self._offset = - self._Span*(#self._playerCardsValueLst - 1)/2
        self:setPos(ccp(self._offset,720))

    end
end

-- 理牌
function PlayerCards:LiPai()
   local chooseOutCards ,NormalCards = self:getChooseOutCards()
   if #chooseOutCards > 0 then
        for i = 1, #NormalCards do
           table.insert(chooseOutCards,NormalCards[i])
        end
        self:reFreshPlayerCards(chooseOutCards,self.FreshCardType.LiPai)
   end
end

-- 选中要出的牌
function PlayerCards:getChooseOutCards()
    local ChooseOutCards = {}
    local NormalCards = {}
    for i=1,#self.cardsSpVec do
        if self.cardsSpVec[i]:isSeleted() then
            table.insert(ChooseOutCards,self.cardsSpVec[i]:getCardValue())
        else
            if self.cardsSpVec[i]:isVisible() == true then
                table.insert(NormalCards,self.cardsSpVec[i]:getCardValue())
            end
        end
    end

    return ChooseOutCards,NormalCards
end

-- 恢复
function PlayerCards:HuiFu()
     if #self._playerCardsValueLst > 1 then
         self._playerCardsValueLst = require("k510/Game/Public/ShareFuns").SortCardsByCardType(self._playerCardsValueLst)
         self._playerCardsValueLst = require("k510/Game/Public/ShareFuns").SortCards(self._playerCardsValueLst)
         self:reFreshPlayerCards(self._playerCardsValueLst,self.FreshCardType.HuiFu)
     end
end

-- 排序
function PlayerCards:PaiXu(way)
    self.cardSortWay = way
    local cardLstTemp = {}
    if self.cardSortWay == require("k510/Game/Common").CardSortWay.SORT_VALUE then
        cardLstTemp = require("k510/Game/Public/ShareFuns").SortCards(self._playerCardsValueLst)
    elseif self.cardSortWay == require("k510/Game/Common").CardSortWay.SORT_HUASE then
        cardLstTemp = require("k510/Game/Public/ShareFuns").SortCardsByCardType(self._playerCardsValueLst)
    elseif self.cardSortWay == require("k510/Game/Common").CardSortWay.SORT_TYPE then
       cardLstTemp = require("k510/Game/Public/ShareFuns").SortCards(self._playerCardsValueLst)
       local targetArray = {}
       local leftArray = {}
       for i = 1,#cardLstTemp do
            if cardLstTemp[i] == require("k510/Game/Public/ShareFuns").mainHeartIdx then
               table.insert(targetArray,cardLstTemp[i])
            else
                table.insert(leftArray,cardLstTemp[i])
            end
       end

       leftArray = require("k510/Game/Public/ShareFuns").SortTypeCards(leftArray)
       for i = 1,#leftArray do
          table.insert(targetArray,leftArray[i])
       end   
       cardLstTemp = require("k510/Game/Public/ShareFuns").Copy(targetArray)
    end

     self:reFreshPlayerCards(cardLstTemp,self.FreshCardType.PaiXu)
end

-- 得到我当前的牌值
function PlayerCards:getMyCardsLst()
   return self._playerCardsValueLst
end

return PlayerCards


