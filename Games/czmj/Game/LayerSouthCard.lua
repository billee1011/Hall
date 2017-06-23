--LayerSouthCard.lua
local CommonInfo = require("czmj/GameDefs").CommonInfo

local SpriteCard = require(CommonInfo.Code_Path.."Game/SpriteGameCard")

local LayerSouthCard=class("LayerSouthCard",function()
        return require(CommonInfo.Code_Path.."Game/LayerWestCard").new()
    end)

function LayerSouthCard:init() 
    self.sprite_card = require(CommonInfo.Code_Path.."Game/SpriteSouthCard")

    --层级
    self.weave_zIndex = 10
    self.hangdCard_zIndex = 20
    self.downCard_zIndex = 30
    self.cardarrow_zIndex = 50
    self.tipcard_zIndex = 55
    self.tip_pos = ccp(CommonInfo.View_Width / 2 + 313, CommonInfo.View_Height / 2 + 26)
    self.down_pos = ccp(self.tip_pos.x + 20, self.tip_pos.y)
    self.down_lastpos = nil

    --手牌
    self.hand_cards = CCLayer:create()
    self:addChild(self.hand_cards, self.hangdCard_zIndex)
    self.hand_pos = ccp(CommonInfo.View_Width - 254, 600)
    self.public_pos = ccp(CommonInfo.View_Width - 133, 220)
    self.card_uis = {}
    self.card_index = nil
    
    --倒下去的牌
    self.down_poses = {ccp(CommonInfo.View_Width / 2 + 294, 333),
            ccp(CommonInfo.View_Width / 2 + 238, 333), ccp(CommonInfo.View_Width / 2 + 180, 333)}
    self.passed_count = 1
    self.tip_card = nil
    
    --吃碰杠
    self.weave_cards = CCLayer:create()
    self:addChild(self.weave_cards, self.weave_zIndex)    

    --吃碰杠位置
    self.weave_pos = ccp(CommonInfo.View_Width - 205, CommonInfo.View_Height - 70)
    self.weave_count = 0

    --移动牌的坐标
    self.sord_pos = ccp(self.hand_pos.x + 13, self.hand_pos.y - 33)
    self.space_pos = ccp(-26, 0)

    --牌墙位置
    self.wall_pos = ccp(CommonInfo.View_Width - 324, 590)
    self.wall_space = ccp(6, 15)
    self:test()
end

--添加吃碰组合
function LayerSouthCard:addPengWeave(cards, dirct)
    local pos = ccp(self.weave_pos.x, self.weave_pos.y)

    local itemTab, space = self:addWeaveCard(pos, cards, 3 - self.weave_count, 4 - dirct)
    self.weave_count = self.weave_count + 1
    for i,v in ipairs(itemTab) do
        v:setPosition(ccp(v:getPositionX()-space.x, v:getPositionY()-space.y))
    end

    local black = itemTab[1]:weaveSpace(5 - self.weave_count)
    self.weave_pos.x = self.weave_pos.x - space.x - black.x
    self.weave_pos.y = self.weave_pos.y - space.y - black.y

    pos.x = self.weave_pos.x + black.x
    pos.y = self.weave_pos.y + black.y

    return itemTab, pos, 4 - dirct
end

function LayerSouthCard:addAnGangWeave(card)
    local pos = ccp(self.weave_pos.x, self.weave_pos.y)

    local uis, space = self:addAnGangCard(pos, 3 - self.weave_count, card)
    self.weave_count = self.weave_count + 1
    for i,v in ipairs(uis) do
        v:setPosition(ccp(v:getPositionX()-space.x, v:getPositionY()-space.y))        
    end

    local black = uis[1]:weaveSpace(5 - self.weave_count)
    self.weave_pos.x = self.weave_pos.x - space.x - black.x
    self.weave_pos.y = self.weave_pos.y - space.y - black.y
end

--添加杠牌组合
function LayerSouthCard:addGangWeave(cards, dirct)
    local uis, pos = self:addPengWeave(cards, dirct)
    local count, cardDirct = 5 - self.weave_count, 4 - dirct
    local sp, spaces, zindex
    if cardDirct == 1 then
        --添加最左边
        local cardtp = uis[3].card_type + 1
        sp, spaces, zindex = self.sprite_card.createVerticalPassed(cards[1], cardtp)
        sp:setPosition(ccp(uis[3]:getPosition()))

        spaces = uis[3]:getSpace()
        self.weave_cards:addChild(sp, zindex + 2 * (5 - count)) 
        for i,v in ipairs(uis) do
            v:setPosition(ccp(v:getPositionX() - spaces.x, v:getPositionY() - spaces.y))
        end        
    else
        local ctype = uis[1].card_type - 1
        if ctype < 1 then
            ctype = 17
        end
        sp, spaces, zindex = self.sprite_card.createVerticalPassed(cards[1], ctype)
        sp:setPosition(ccp(pos.x - spaces.x, pos.y - spaces.y))
        self.weave_cards:addChild(sp, zindex + 2 * (5 - count)) 
    end

    self.weave_pos.x = self.weave_pos.x - spaces.x
    self.weave_pos.y = self.weave_pos.y - spaces.y
end

function LayerSouthCard.create()
    local layer = LayerSouthCard.new()
    layer:init()
    return layer
end

function LayerSouthCard.put(super, zindex)
    local layer = LayerSouthCard.new()
    super:addChild(layer, zindex)
    layer.layer_zIndex = zindex
    layer.btn_zIndex = zindex + 1

    layer:init()
    return layer
end

return LayerSouthCard
