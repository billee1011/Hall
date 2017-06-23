--SpriteNorthCard.lua
local CommonInfo = require("sgmj/GameDefs").CommonInfo

local SpriteNorthCard=class("SpriteNorthCard",function()
        return require(CommonInfo.Code_Path.."Game/SpriteGameCard").new()
    end)

function SpriteNorthCard:flipUI(xspace)
    self.card_bg:setFlipX(true)
    --self:setFlipX(true)
    return -xspace    
end

function SpriteNorthCard:moveSpace()
    local fscale = 0.6
    return ccp(-12 * fscale, 0)
end

function SpriteNorthCard:weaveSpace()
    local fscale = 0.6
    return ccp(-12 * fscale, 0)
end

function SpriteNorthCard:getSpace()
    return self.card_space
end

function SpriteNorthCard:initHand()
    --背景 "base_100.png"
    self.card_bg = loadSprite("mjBack/mjbg_200.png")
    self.base_size = self.card_bg:getContentSize()
    self.card_bg:setAnchorPoint(ccp(1,0))

    self.card_front = loadSprite("mjBack/mjbg_100.png")
    self.card_front:setVisible(false)
    self.card_front:setScale(0.45)
    self.card_front:setAnchorPoint(ccp(1,0))

    self:addChild(self.card_bg,0,10)
    self:addChild(self.card_front)
end

--添加手牌
function SpriteNorthCard:addHandCard(card)
    local sprite, space, zindex = SpriteNorthCard.createHand()
    if card then
        sprite, space, zindex = SpriteNorthCard.createPublicHand(self.card_type - 1, 0, card)
    end

    local zeropos = ccp(self:getPosition())
    sprite:setPosition(ccp(zeropos.x + self.card_space.x, zeropos.y + self.card_space.y))
    
    self:getParent():addChild(sprite, zindex)
    return sprite
end

function SpriteNorthCard.createHand()
    local sprite = SpriteNorthCard.new()
    sprite:initHand()

    sprite.card_space = ccp(-33, 0)
    return sprite, sprite.card_space, 1, 1
end

function SpriteNorthCard.createPublicHand(ctype, index, card)
    local sprite, space, zindex = SpriteNorthCard.createVerticalPassed(card, ctype)
    sprite.card_space = space
    return sprite, space, 15 - zindex, index + 1
end

function SpriteNorthCard.createVerticalBack(ctype)
    local sprite = SpriteNorthCard.new()
    local space, zIndex = sprite:initVerticalBack(ctype)
    --sprite.card_bg:setFlipX(true)
    
    sprite.card_bg:setFlipX(true)
    zIndex = 15 - zIndex

    space.x = space.x * 0.6
    sprite:setScale(0.6)
    return sprite, space, zIndex
end

function SpriteNorthCard:initHorizontalPassed(index, ctype,dirct)
    local xpos = {2, 2, 1, 0, 0, 0, 0, -1, -2, -2, -2, -2}
    local yskew = {17, 14, 11, 9, 7, 4, 3, 2, -1, -2, -3, -5}
    self.card_bg = loadSprite("mjBack/bmjpasshorbg_"..ctype..".png")
    self.base_size = self.card_bg:getContentSize() 
    self.card_bg:setAnchorPoint(ccp(1,0))
    self:addChild(self.card_bg,0,10)
    self.card_bg:setFlipX(true)

    self.sprite_card = loadSprite(string.format("mjValue/lc%x.png", index))
    self.sprite_card:setPosition(ccp(-self.base_size.width/2 - xpos[ctype], self.base_size.height/2 + 9))
    self.sprite_card:setSkewY(-yskew[ctype])
    self.sprite_card:setRotation(90)
    self.sprite_card:setScale(0.6)
    self:addChild(self.sprite_card,1,20)

	--[[if dirct and dirct >= 1 and dirct <= 3 then  --这里是最上面玩家的碰牌箭头
		--方向指示箭头 指示是碰谁的牌
		local rotation = {90,185,-90}
		self.directArrowSp = loadSprite("sgmj/DirectArrow.png")
		self.card_bg:addChild(self.directArrowSp)
		self.directArrowSp:setRotation(rotation[dirct])
		self.directArrowSp:setPosition(ccp(self.base_size.width/2 , -10))
	end ]]
	
    self.card_index = index
    self.card_type = ctype
    --{14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 2, 3, 15}
    local zindexs = {14, 13, 11, 10, 8, 7, 5, 4, 2, 7, 8, 9}

    local spaces = {-30, -27, -24, -20, -16, -14, -8, -6, -7, -8, -8, -5}

    return ccp(-self.base_size.width - spaces[ctype] / 1.5, 0), zindexs[ctype]
end

function SpriteNorthCard.createHorizontalPassed(index, ctype, dirct)
    local sprite = SpriteNorthCard.new()

    local space, zIndex = sprite:initHorizontalPassed(index, ctype,dirct)
    space.x = space.x * 0.6
    --space.y = -sprite.base_size.height * 0.6 
    sprite:setScale(0.6)

    sprite.card_bg:setAnchorPoint(ccp(1,0))
    sprite.card_dirct = dirct

    --碰牌位置修正
    local horspace = ccp(0, 9)

    return sprite, space, zIndex, horspace
end

function SpriteNorthCard.addHorizontalPassed(item,dirct)
    local index, ctype = item.card_index, item.card_type
    local sprite = SpriteNorthCard.new()
    local space = sprite:initHorizontalPassed(index, ctype,dirct)
    sprite.card_dirct = item.card_dirct
    local spaces = {-13, -12, -9, -8, -6, -4, -3, -1, -1, 0, 1, 2}
    sprite:setScale(0.6)
    return sprite, ccp(spaces[ctype] * 0.6 / 1.5, -26), item:getZOrder()
end

function SpriteNorthCard:initNorthVerticalPassed(index, ctype,dirct)
    local xpos = {7, 7, 6, 5, 4, 4, 4, 2, 1, 1, 1, 1, 0, 1, 1, -2, 7}
    local xskew = {-16, -14, -13, -11, -10, -8, -7, -5, -4, -3, -2, 0, 0, 1, 2, 4, -16}
    self.card_bg = loadSprite("mjBack/bmjpassbg_"..ctype..".png")
    self.base_size = self.card_bg:getContentSize() 
    self.card_bg:setAnchorPoint(ccp(1,0))
    self:addChild(self.card_bg,0,10)
    self.card_bg:setFlipX(true)

    self.sprite_card = loadSprite(string.format("mjValue/sc%x.png", index))
    self.sprite_card:setPosition(ccp(-self.base_size.width/2 - xpos[ctype] / 1.5, self.base_size.height/2 + 8))
    self.sprite_card:setSkewX(-xskew[ctype])
    self:addChild(self.sprite_card,1,20)
    self.sprite_card:setRotation(180)

    self.card_index = index
    self.card_type = ctype
    
    local zindexs = {14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 2, 3, 15}
                                                                        ----
    local spaces = {-38, -35, -31, -28, -26, -20, -18, -15, -11, -9, -6, -6, -5, -11, -12, -15, -38}
    return  ccp(-self.base_size.width - spaces[ctype] / 1.5, 0), zindexs[ctype]
end

function SpriteNorthCard.createVerticalPassed(index, ctype)
    local sprite = SpriteNorthCard.new()
    local space, zIndex = sprite:initNorthVerticalPassed(index, ctype)

    space.x = space.x * 0.6
    sprite:setScale(0.6)    
    sprite.card_space = space
    return sprite, space, zIndex
end

function SpriteNorthCard.createPassed(index, ctype)
    local sprite = SpriteNorthCard.new()
    local space, zIndex = sprite:initVerticalPassed(index, ctype) 
    sprite.sprite_card:setRotation(180)
    sprite.sprite_card:setPositionY(sprite.base_size.height/2 + 9)

    return sprite, space, zIndex
end

function SpriteNorthCard.createWallCard(ctype, index)
    local sprite, tempType = SpriteNorthCard.new(), ctype
    ctype = math.abs(ctype)
    local space, zIndex = sprite:initWallCard(ctype)
    zIndex = 15 - index
    if tempType < 0 then
        sprite.card_bg:setFlipX(true)
        zIndex = 8 + tempType
    end
    sprite:setScale(0.7)
    space.x = space.x * 0.7

    return sprite, space, zIndex, index + 1
end

 return SpriteNorthCard