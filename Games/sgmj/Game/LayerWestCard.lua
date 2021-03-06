--LayerWestCard.lua
local CommonInfo = require("sgmj/GameDefs").CommonInfo
local AppConfig = require("AppConfig")
local LayerWestCard=class("LayerWestCard",function()
        return CCLayer:create()
    end)

function LayerWestCard:init() 
    self.sprite_card = require(CommonInfo.Code_Path.."Game/SpriteWestCard")

    --层级
    self.weave_zIndex = 10
    self.hangdCard_zIndex = 20
    self.downCard_zIndex = 30
    self.cardarrow_zIndex = 50
    self.tipcard_zIndex = 55
    self.tip_pos = ccp(CommonInfo.View_Width / 2 - 233, CommonInfo.View_Height / 2 + 26)
    self.down_pos = ccp(self.tip_pos.x - 20, self.tip_pos.y)
    self.down_lastpos = nil

    --手牌
    self.hand_cards = CCLayer:create()
    self:addChild(self.hand_cards, self.hangdCard_zIndex)
    self.hand_pos = ccp(253, 600)
    self.public_pos = ccp(140, 220)
    self.card_uis = {}
    self.card_index = nil

    --倒下去的牌
    self.down_poses = {ccp(CommonInfo.View_Width / 2 - 205, 462),
            ccp(CommonInfo.View_Width / 2 - 155, 462), ccp(CommonInfo.View_Width / 2 - 105, 462)}
    self.passed_count = 1
    self.tip_card = nil

    --吃碰杠
    self.weave_cards = CCLayer:create()
    self:addChild(self.weave_cards, self.weave_zIndex)    

    --吃碰杠位置
    self.weave_pos = ccp(43, 155)--ccp(40, 140)
    self.weave_count = 0

    --移动牌的坐标
    self.sord_pos = ccp(self.hand_pos.x - 13, self.hand_pos.y - 33)
    self.space_pos = ccp(13, 0)

    --牌墙位置
    self.wall_pos = ccp(325, 590)
    self.wall_space = ccp(-6, 15)

    self:test() 
end

function LayerWestCard:test()
    --[[self:getHandPaisAnima(13, false)
    self:addCardWall(13)
    self:addSordDownPais(13)
    for i=1,18 do
        self:addStaticPassed(0x19)
    end
    --self:initHandPais({1, 2, 3, 4, 5, 6, 7, 8, 9, 0x11, 0x12, 0x13, 0x35})
    

    local ctype,card = 3, 0x19
    for i=1,4 do
        local uis3, pos, dirct = self:addPengWeave({card, card, card}, ctype)
        self:addGangCard(uis3[dirct], card)
        --self:addAnGangWeave(card)
        --self:addGangWeave({card, card, card, card}, ctype)
    end]]
end

function LayerWestCard:addCardWall(count)
    local panel  = CCLayer:create()
    self:addChild(panel, self.downCard_zIndex) 
    local start = 15 - count

    local pos, uis, spacepos = ccp(self.wall_pos.x, self.wall_pos.y), {}, {self.wall_space, ccp(0, 0)}
    for i=1,14 do
        local sp, spaces, zindex, index
        for j=1,2 do
            sp, spaces, zindex, index = self.sprite_card.createWallCard(i, #uis)
            sp:setPosition(ccp(pos.x + spacepos[j].x, pos.y + spacepos[j].y))
            if i >= start then
                table.insert(uis, index, sp)
                panel:addChild(sp, zindex + 2 - j)
            end
        end

        pos.x = pos.x - spaces.x
        pos.y = pos.y - spaces.y 
    end

    self.down_cards = CCLayer:create()
    self:addChild(self.down_cards, self.downCard_zIndex)
    
    return uis      
end

function LayerWestCard:setCardIndex(index)
    self.card_index = index
end

function LayerWestCard:initPublicHandPais(cards)
    function createSprite(cardIndex, lNum, rNum, index)
        local card = 1
        if index ~= 1 then
            if cardIndex>lNum and cardIndex <= #cards + lNum then
                card = cards[cardIndex - lNum]
            end
        else
            if cardIndex>rNum and cardIndex <= #cards + rNum then
                card = cards[cardIndex - rNum]
            end         
        end

        return self.sprite_card.createPublicHand(cardIndex, cardIndex-1, card)
    end

    self:initHand(ccp(self.public_pos.x, self.public_pos.y), #cards, createSprite)

    return self      
end

function LayerWestCard:initHandPais(count)
    function createSprite(cardIndex, lNum, Max)
        return self.sprite_card.createHand(cardIndex, cardIndex-1)
    end

    self:initHand(ccp(self.hand_pos.x, self.hand_pos.y), count, createSprite)

    return self    
end

function LayerWestCard:initHand(pos, count, createSprite)
    self.hand_cards:removeAllChildrenWithCleanup(true)
    self.card_uis = {}
    local mast = 14

    --数据
    local rightNum = math.ceil((14 - count) / 2)
    local leftNum = mast - count - rightNum
    local maxNum = leftNum + count
    local sp, spaces, zindex, index = createSprite(2, leftNum)
    local dirct = index

    local function addCardSprite(cardIndex)
        sp, spaces, zindex, index = createSprite(cardIndex, leftNum, rightNum, dirct)
        sp:setPosition(pos)
        pos.x = pos.x - spaces.x
        pos.y = pos.y - spaces.y 

        self.hand_cards:addChild(sp, zindex)
        table.insert(self.card_uis, index, sp)
    end
    for i=1,mast do
        addCardSprite(i)
    end

    --删除多余的牌
    for i=mast,mast-rightNum+1,-1 do
        self.card_uis[i]:removeFromParentAndCleanup(true)
        table.remove(self.card_uis, i) 
    end
    for i=leftNum,1,-1 do
        self.card_uis[i]:removeFromParentAndCleanup(true)
        table.remove(self.card_uis, i) 
    end

    return self      
end

--背面的牌
function LayerWestCard:addSordDownPais(count)
    local pos = ccp(self.sord_pos.x, self.sord_pos.y)
    self.hand_cards:removeAllChildrenWithCleanup(true)
    self.card_uis = {}

    pos.x = pos.x - self.space_pos.x
    pos.y = pos.y - self.space_pos.y

    for i=1,count do
        local sp, spaces, zindex = self.sprite_card.createVerticalBack(count - i + 1)
        sp:setPosition(pos)
        pos.x = pos.x - spaces.x
        pos.y = pos.y - spaces.y 
        self.hand_cards:addChild(sp, zindex) 
    end

    local array = CCArray:create()
    array:addObject(CCDelayTime:create(0.1))
    array:addObject(CCMoveBy:create(0.1, self.space_pos))
    self.hand_cards:runAction(CCSequence:create(array)) 

    return self   
end

--设置手牌水平位置
function LayerWestCard:updataHorizontalPos()
    local maxSp = self.card_uis[#self.card_uis]
    local space = maxSp:moveSpace()
    maxSp:setPosition(ccp(maxSp:getPositionX() + space.x, maxSp:getPositionY() + space.y)) 
end

function LayerWestCard:createPassed(card)
    local downIndex = self:getParent().downIndex
    local passIndex = self.passed_count
    local sp, spaces, zindex, skewIndex

    if downIndex == 9 then 
        --三人模式
        sp, spaces, zindex, skewIndex = self.sprite_card.createThreePassed(card, passIndex) 
    else
        --四人模式
        sp, spaces, zindex, skewIndex = self.sprite_card.createPassed(card, passIndex)
    end

    if self.passed_count == 1 or self.passed_count == downIndex + 1 or self.passed_count == downIndex * 2 + 1 then
        self.down_pos = ccp(self.down_poses[zindex].x, self.down_poses[zindex].y)
    end

    local tempPos = ccp(self.down_pos.x, self.down_pos.y)
    sp:setPosition(self.down_pos)
    self.down_cards:addChild(sp, zindex + skewIndex) 

    self.down_pos.x = self.down_pos.x - spaces.x
    self.down_pos.y = self.down_pos.y - spaces.y

    self.passed_count = self.passed_count + 1

    return sp, tempPos, zindex + skewIndex
end

--场景恢复添加打出去的牌
function LayerWestCard:addStaticPassed(card)
    --放下牌
    local item = self:createPassed(card)
    self.down_card = item
	return item
end

--场景恢复添加打出去提示牌
function LayerWestCard:addStaticPassedWithTip(card, func)
    --[[self.tip_card = require(CommonInfo.Code_Path.."Game/SpriteGameCard").createNorthHand()
    self:addChild(self.tip_card, self.tipcard_zIndex)

    self.tip_card:changeCardToFront(card, self.tip_pos)]]
    --放下牌
    self:addStaticPassed(card)
    self:addCardArrowAnima(true, require(CommonInfo.Code_Path.."Game/SpriteGameCard").getCardCenterPos(self.down_card))
    cclog("LayerWestCard:addStaticPassedWithTip ")
    func()
end

--添加吃碰组合
function LayerWestCard:addPengWeave(cards, dirct)
    local pos = ccp(self.weave_pos.x, self.weave_pos.y)

    local itemTab, space = self:addWeaveCard(pos, cards, self.weave_count, dirct)
    self.weave_count = self.weave_count + 1

    local black = itemTab[1]:weaveSpace(self.weave_count)
    self.weave_pos.x = self.weave_pos.x + space.x + black.x
    self.weave_pos.y = self.weave_pos.y + space.y + black.y

    pos.x = self.weave_pos.x - black.x
    pos.y = self.weave_pos.y - black.y

    return itemTab, pos, dirct
end

function LayerWestCard:addAnGangWeave(card)

    local pos = ccp(self.weave_pos.x, self.weave_pos.y)

    local uis, space = self:addAnGangCard(pos, self.weave_count, card)
    self.weave_count = self.weave_count + 1
	
    local black = uis[1]:weaveSpace(self.weave_count)
    self.weave_pos.x = self.weave_pos.x + space.x + black.x
    self.weave_pos.y = self.weave_pos.y + space.y + black.y
	return uis
end

--添加杠牌组合
function LayerWestCard:addGangWeave(cards, dirct)
    local uis, pos ,dirction= self:addPengWeave(cards, dirct)
    local sp, spaces, zindex
    if dirct ~= 3 then
        --添加最左边
        local cardtp = self.weave_count * 3 + 1
        sp, spaces, zindex = self.sprite_card.createVerticalPassed(cards[1], cardtp)
        sp:setPosition(pos)
        self.weave_cards:addChild(sp, zindex + 2 * (5 - self.weave_count)) 
    else
        pos = ccp(uis[1]:getPosition())
        local ctype = self.weave_count * 3 - 4
        if ctype < 1 then
            ctype = 17
        end
        sp, spaces, zindex = self.sprite_card.createVerticalPassed(cards[1], ctype)
        sp:setPosition(pos)
        self.weave_cards:addChild(sp, zindex + 2 * (5 - self.weave_count)) 
        for i,v in ipairs(uis) do
            v:setPosition(ccp(v:getPositionX() + spaces.x, v:getPositionY() + spaces.y))
        end
    end

    self.weave_pos.x = self.weave_pos.x + spaces.x
    self.weave_pos.y = self.weave_pos.y + spaces.y
	return uis,dirction
end

function LayerWestCard:addAnGangCard(pos, count, card)
    local uis, tempPos = {}, ccp(pos.x, pos.y)
    local sp, spaces, zindex
    for i=1,4 do
        local ctype = count * 3 + i
        if i ~= 2 then
            sp, spaces, zindex = self.sprite_card.createVerticalBack(ctype)
        else
            sp, spaces, zindex = self.sprite_card.createVerticalPassed(card, ctype)
        end
        sp:setPosition(pos)
        pos.x = pos.x + spaces.x
        pos.y = pos.y + spaces.y 
        self.weave_cards:addChild(sp, zindex + 2 * (4 - count))   
        table.insert(uis, sp)     
    end

    return uis, ccp(pos.x - tempPos.x, pos.y - tempPos.y)
end

function LayerWestCard:addWeaveCard(pos, cards, count, dirct)
    local itemTab, tempPos = {}, ccp(pos.x, pos.y)
    local sp, spaces, zindex, horspace
    for i=1,3 do        
        if dirct == i then
            sp, spaces, zindex, horspace = self.sprite_card.createHorizontalPassed(cards[i], count * 2 + i, i)
            horspace = horspace or ccp(0, 0)
            sp:setPosition(ccp(pos.x + horspace.x, pos.y + horspace.y))
			
        else
            sp, spaces, zindex = self.sprite_card.createVerticalPassed(cards[i], count * 3 + i)
            sp:setPosition(pos)
        end

        pos.x = pos.x + spaces.x
        pos.y = pos.y + spaces.y 
        self.weave_cards:addChild(sp, zindex + 2 * (4 - count))

        table.insert(itemTab, sp)
    end

    return itemTab, ccp(pos.x - tempPos.x, pos.y - tempPos.y)
end

function LayerWestCard:addGangCard(item)
    local xpos = ccp(item:getPosition())
	
    local sp, index, zindex = self.sprite_card.addHorizontalPassed(item)
    self.weave_cards:addChild(sp, zindex)

    sp:setPosition(ccp(xpos.x + index.x, xpos.y + index.y))
    --sp:setScale(0.965) 
	return sp
end

--开场整理牌动画
function LayerWestCard:getHandPaisAnima(count, bBanker)
    self:initHandPais(count)

    require(CommonInfo.Code_Path.."Game/SpriteGameCard").getHandPaisAnima(self, 30, function()
        self.hand_cards:setPosition(ccp(0, 0))
        self:initHandPais(count)
        if bBanker then
            self:updataHorizontalPos()
        end
    end)

    return self    
end

--牌提示动画
function LayerWestCard:addCardArrowAnima(bshow, pos)
    if not self.card_arrow then
        self.card_arrow = loadSprite("mjValue/markArrow.png")
        self:addChild(self.card_arrow, self.cardarrow_zIndex)
        self.card_arrow:setAnchorPoint(ccp(0.5, 0))
        local array  = CCArray:create()
        array:addObject(CCMoveBy:create(0.4, ccp(0, 15)))
        array:addObject(CCMoveBy:create(0.4, ccp(0, -15)))
        self.card_arrow:runAction(CCRepeatForever:create(CCSequence:create(array)))
    end

    self.card_arrow:setPosition(pos)
    self.card_arrow:setVisible(bshow and 
        self == require(CommonInfo.Logic_Path):getInstance():getLastPlayerPanle())
end

function LayerWestCard:sendCardAnima(card, index)
    --self:onAnimaStart()

    local cout = index or #self.card_uis
    local pos = ccp(self.card_uis[cout]:getPosition())
    pos = self.hand_cards:convertToWorldSpace(pos)    
    self.card_uis[cout]:removeFromParentAndCleanup(true)
    table.remove(self.card_uis, cout)
    
    --提示牌
    local tipSp = require(CommonInfo.Code_Path.."Game/SpriteGameCard").createNorthHand()
    self.tip_card = tipSp
    tipSp:setPosition(pos)
    self:addChild(tipSp, self.tipcard_zIndex)

    --倒下去牌
    local cardsp, endpoe, zorder = self:createPassed(card)
    cardsp:setPosition(self.down_pos)
    cardsp:setZOrder(self.tipcard_zIndex - 1)
    cardsp:setVisible(false)
    self.down_card = cardsp
    self.down_lastpos = endpoe

    tipSp:sendNorthCardAnima(function() 
        --self:onAnimaEnd()
        local array = CCArray:create()
        array:addObject(CCMoveTo:create(0.1, endpoe))
        array:addObject(CCCallFunc:create(function() 
            cardsp:setZOrder(zorder)
            self:removeTipCard(tipSp)
            self:addCardArrowAnima(true, require(CommonInfo.Code_Path.."Game/SpriteGameCard").getCardCenterPos(cardsp))
            require("Lobby/Set/SetLogic").playGameEffect(AppConfig.SoundFilePathName.."outcard_effect"..AppConfig.SoundFileExtName)
        end))
        cardsp:setVisible(true)
        cardsp:runAction(CCSequence:create(array))

    end, card, self.tip_pos)
	return cardsp
end

--自己抓牌动画
function LayerWestCard:getCardAnima()
    self.tip_card = nil
    --require(CommonInfo.Logic_Path):getInstance():getLastPlayerPanle():removeTipCard()
    self:getParent():getGameCardAnima(1)

    local count = #self.card_uis
    local cardsp = self.card_uis[count]
    table.insert(self.card_uis, cardsp:addHandCard())

    self:updataHorizontalPos()
end

function LayerWestCard:removeCardAnima()
    self:removeTipCard()

    if self.down_card then
        self.down_card:stopAllActions()
        
        self.passed_count = self.passed_count - 1
        self.down_pos = self.down_lastpos or ccp(self.down_card:getPosition())

        self.down_card:removeFromParentAndCleanup(true)        
        self.down_card = nil 

        self:addCardArrowAnima(false, ccp(-100, -100))       
    end
end

--删除打出提示牌
function LayerWestCard:removeTipCard(tipSp)
    if tipSp then
        --玩家出牌动画回调        
        if tipSp ~= self.tip_card then
            --已经打出新的牌了，删掉即可
            tipSp:removeFromParentAndCleanup(true)
            cclog("LayerWestCard 玩家出牌动画回调：打出去的牌已更新")
            return
        end
    end

    if not self.tip_card then
        return
    end

    self:getParent():hideArrowAnima()
    
    self.tip_card:stopAllActions()
    self.tip_card:removeFromParentAndCleanup(true)

    self.tip_card = nil
end

--吃碰杠动画
function LayerWestCard:onOperatorAnima(removecard, func)
    cclog("xxxxxxxxxxxxxxxxxxxxxxxxx "..#self.card_uis..";"..#removecard)
    self.tip_card = nil
    self:initHandPais(#self.card_uis - #removecard)

    if func then
        func()
    end 
end

function LayerWestCard:onGangAnima(downcard, removecard, dirct, func)
    require(CommonInfo.Logic_Path):getInstance():getLastPlayerPanle():removeCardAnima()

    --添加组合牌
    local uis,dirction= self:addGangWeave(downcard, dirct)

    --返回中心点位置
    self:onOperatorAnima(removecard, func)
	return uis,dirction
end

function LayerWestCard:onChiPengAnima(downcard, removecard, dirct, func)
    require(CommonInfo.Logic_Path):getInstance():getLastPlayerPanle():removeCardAnima()

    --添加组合牌
    local uis, pos, dirction = self:addPengWeave(downcard, dirct)

    --返回中心点位置
    self:onOperatorAnima(removecard, function()
        if func then
            func()
        end
        self:updataHorizontalPos()
    end)

    return uis,dirction
end

function LayerWestCard:onAnGangAnima(downcard, removecard)
    --添加组合牌
    local uis = self:addAnGangWeave(downcard[1])

    --返回中心点位置
    self:onOperatorAnima(removecard, func)
	return uis
end

--碰杠动画
function LayerWestCard:onPengGangAnima(card, item,func)
    --添加杠牌
    local spriteCard =  self:addGangCard(item)

    self:initHandPais(#self.card_uis - 1)

    if func then
        func()
    end
	return spriteCard
end

function LayerWestCard:onAnimaStart()
    require(CommonInfo.Logic_Path):getInstance():setIfGetSocketData(false)
end

function LayerWestCard:onAnimaEnd()
    require(CommonInfo.Logic_Path):getInstance():setIfGetSocketData(true)
end

function LayerWestCard.create()
	local layer = LayerWestCard.new()
	layer:init()
	return layer
end

function LayerWestCard.put(super, zindex)
    local layer = LayerWestCard.new()
    super:addChild(layer, zindex)
    layer.layer_zIndex = zindex
    layer.btn_zIndex = zindex + 1

    layer:init()
    return layer
end

return LayerWestCard
