--LayerNorthCard.lua
local CommonInfo = require("sgmj/GameDefs").CommonInfo
local AppConfig = require("AppConfig")
local SpriteGameCard = require(CommonInfo.Code_Path.."Game/SpriteGameCard")

local LayerNorthCard=class("LayerNorthCard",function()
        return require(CommonInfo.Code_Path.."Game/LayerSouthCard").new()
    end)

function LayerNorthCard:init() 
    self.sprite_card = require(CommonInfo.Code_Path.."Game/SpriteNorthCard")

    --层级
    self.weave_zIndex = 10
    self.downCard_zIndex = 30
    self.hangdCard_zIndex = 20
    self.cardarrow_zIndex = 50
    self.tipcard_zIndex = 55
    self.tip_pos = ccp(CommonInfo.View_Width / 2 + 40, 520)

    --手牌
    self.hand_cards = CCLayer:create()
    self:addChild(self.hand_cards, self.hangdCard_zIndex)
    self.hand_pos = ccp(CommonInfo.View_Width / 2 - 220, CommonInfo.View_Height - 60)    
    self.card_index = nil
    
    self.down_pos = ccp(CommonInfo.View_Width / 2 , 616)
    self.down_posx = CommonInfo.View_Width / 2 - 30
    self.down_lastpos = nil
    self.card_uis = {}
    self.tip_card = nil

    --移动牌的坐标
    self.sord_pos = ccp(self.hand_pos.x + 65, self.hand_pos.y - 10)
    self.space_pos = ccp(0, -20)

    --吃碰杠
    self.weave_cards = CCLayer:create()
    self:addChild(self.weave_cards, self.weave_zIndex)    

    --吃碰杠位置
    self.weave_pos = ccp(self.hand_pos.x - 180, self.hand_pos.y + 12)
    self.weave_count = 0

    self:test()
end

function LayerNorthCard:initPublicHandPais(cards)
    function createSprite(cardIndex, lNum, Max)
        local card = 1
        if cardIndex>lNum and cardIndex <= #cards + lNum then
            card = cards[cardIndex - lNum]
        end

        return self.sprite_card.createPublicHand(cardIndex, cardIndex-1, card)
    end

    local xpos = self.weave_pos.x + 50
    if self.weave_count == 0 then
        xpos = self.hand_pos.x
    end
    self:initHand(ccp(xpos, self.hand_pos.y), #cards, createSprite)

    return self      
end

function LayerNorthCard:initHandPais(data)
    if type(data) == "table" then
        return self:initPublicHandPais(data)
    end

    function createSprite(cardIndex, lNum, Max)
        return self.sprite_card.createHand(cardIndex, cardIndex-1)
    end

    local xpos = self.weave_pos.x + 11
    if self.weave_count == 0 then
        xpos = self.hand_pos.x
    end
    self:initHand(ccp(xpos, self.hand_pos.y), data, createSprite)

    return self    
end

function LayerNorthCard:addCardWall(count)
    local panel  = CCLayer:create()
    self:addChild(panel, self.hangdCard_zIndex) 
    local pos, uis, spacepos, scales = ccp(453, CommonInfo.View_Height - 83), {}, {ccp(3, 12), ccp(0, 0)}, {1, 0.985}
    local start = 15 - count

    local cardIndex
    if start ~= 1 then
        --创建中间牌
        pos.x = pos.x + 18
    end

    local function addWallCard(ctype)
        local sp, spaces, zindex, index
        for j=1,2 do
            sp, spaces, zindex, index = self.sprite_card.createWallCard(ctype, #uis)
            sp:setPosition(ccp(pos.x + spacepos[j].x, pos.y + spacepos[j].y))
            table.insert(uis, index, sp)
            panel:addChild(sp, zindex + 2 - 2 * j)
            sp:setScale(sp:getScale() * scales[j])
        end

        pos.x = pos.x + spaces.x
        pos.y = pos.y + spaces.y         
    end

    --左边牌
    for i=7, start, -1 do
        spacepos[1].x = -1
        spacepos[2].x = 1
        if i == start then
            spacepos[1].x = 0
        end        
        addWallCard(-i)
    end

    for i=1,7 do
        spacepos[1].x = 2
        spacepos[2].x = 0
        if i == 1 then
            spacepos[1].x = 1
        end
        addWallCard(i)
    end

    self.down_cards = CCLayer:create()
    self:addChild(self.down_cards, self.downCard_zIndex)
    
    return uis      
end

function LayerNorthCard:addAnGangCard(pos, count, card)
    local uis, tempPos = {}, ccp(pos.x, pos.y)
    local sp, spaces, zindex
    for i=1,4 do
        local ctype = (3 - count) * 3 + i
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

function LayerNorthCard:addWeaveCard(pos, cards, count, dirct)
    local itemTab, tempPos = {}, ccp(pos.x, pos.y)

    local sp, spaces, zindex, horspace
    for i=1,3 do        
        if dirct == i then
            sp, spaces, zindex, horspace = self.sprite_card.createHorizontalPassed(cards[i], (3 - count) * 2 + i, i)
            sp:setPosition(ccp(pos.x + horspace.x, pos.y + horspace.y))
        else
            sp, spaces, zindex = self.sprite_card.createVerticalPassed(cards[i], (3 - count) * 3 + i)
            sp:setPosition(pos)
        end

        pos.x = pos.x + spaces.x
        pos.y = pos.y + spaces.y 
        self.weave_cards:addChild(sp, zindex + 2 * (4 - count))

        table.insert(itemTab, sp)
    end

    return itemTab, ccp(pos.x - tempPos.x, pos.y - tempPos.y)
end

function LayerNorthCard:createPassed(card)
    self.passed_count = self.passed_count or 0
    local passIndex = 17 - self.passed_count

    local sp, zIndex, scale, downpos
    self.down_pos = ccp(CommonInfo.View_Width / 2 , 616)
    if passIndex >= 0 then
        for i=0,passIndex do
            sp, zIndex, scale = self:getPassedPos(i, card)
        end
    else
        --越界
        sp, zIndex, scale = self:getPassedPos(0, card)
        for i=passIndex,-1 do
            self.down_pos.x = self.down_pos.x - 48 * 0.816 * math.pow(0.98, 2)
        end        
    end
    downpos = ccp(self.down_pos.x, self.down_pos.y)
    self.passed_count = 18 - passIndex

    return sp, downpos, scale, zIndex
end

function LayerNorthCard:getPassedPos(passIndex, card)
    local xIndex, yIndex = passIndex % 6 + 1, 3 - math.floor(passIndex / 6)--几行几列
    local sp, index, zindex = self.sprite_card.createPassed(card, 15 - xIndex)
    local scales = {{0.816, 0.72}, {0.816 * 0.98, 0.72 * 0.98}, {0.816 * math.pow(0.98, 2), 0.72 * math.pow(0.98, 2)}}

    if passIndex == 0 or passIndex == 6 or passIndex == 12 then
        self.down_pos.x = self.down_posx - 66 * scales[yIndex][1]
        self.down_pos.y = self.down_pos.y - 57 * scales[yIndex][2]
    else
        local xposes = {0, -48, -45, -49, -48, -49}
        self.down_pos.x = self.down_pos.x - scales[yIndex][1] * xposes[xIndex]        
    end

    return sp, 3 - yIndex, scales[yIndex]
end

--自己发牌动画
function LayerNorthCard:sendCardAnima(card)
    --self:onAnimaStart()

    local cout = #self.card_uis
    local pos = ccp(self.card_uis[cout]:getPosition())
    pos = self.hand_cards:convertToWorldSpace(pos)    
    self.card_uis[cout]:removeFromParentAndCleanup(true)
    table.remove(self.card_uis, cout)
    
    --提示牌
    local tipSp = SpriteGameCard.createNorthHand()
    self.tip_card = tipSp
    self.tip_card:setPosition(pos)
    self:addChild(self.tip_card, self.tipcard_zIndex)

    --放下牌
    local item, pos, scale, index = self:createPassed(card)
    item:setPosition(self.down_pos)
    item:setVisible(false)
    self.down_cards:addChild(item, 6 + index)
    self.down_card = item
    self.down_lastpos = pos

    self.tip_card:sendNorthCardAnima(function() 
        item:setVisible(true)   
        item:downCardAnima(pos, scale, function()
            self:removeTipCard(tipSp)          
            self:addCardArrowAnima(true, item:getCenterPos())            

            require("Lobby/Set/SetLogic").playGameEffect(AppConfig.SoundFilePathName.."outcard_effect"..AppConfig.SoundFileExtName)
        end)

        --self:onAnimaEnd()
    end, card, self.tip_pos)
	return item
end

--场景恢复添加打出去的牌
function LayerNorthCard:addStaticPassed(card)
    --放下牌
    local item, pos, scale, index = self:createPassed(card)
    item:setScaleX(scale[1])
    item:setScaleY(scale[2])
    item:setPosition(pos)

    self.down_cards:addChild(item, 6 + index)

    self.down_card = item  
	return item
end

function LayerNorthCard.create()
    local layer = LayerNorthCard.new()
    layer:init()
    return layer
end

function LayerNorthCard.put(super, zindex)
    local layer = LayerNorthCard.new()
    super:addChild(layer, zindex)
    layer.layer_zIndex = zindex
    layer.btn_zIndex = zindex + 1

    layer:init()
    return layer
end

return LayerNorthCard
