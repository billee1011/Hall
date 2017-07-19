--SpriteSouthCard.lua
local CommonInfo = require("gdmj/GameDefs").CommonInfo

local SpriteSouthCard=class("SpriteSouthCard",function()
        return require(CommonInfo.Code_Path.."Game/SpriteWestCard").new()
    end)

function SpriteSouthCard:flipUI(xspace)
    self.card_bg:setFlipX(true)
    --self:setFlipX(true)
    return -xspace    
end

----------------------------------------------------------------------------------------------------------------------
function SpriteSouthCard.createPassed(index, ctype)
    local spaceIndex = 0
    if ctype > 18 then 
        --越界处理
        spaceIndex = ctype - 18
        ctype = 18 
    end

    local sprite = SpriteSouthCard.new()
    ctype = (math.ceil(ctype / 6) * 12 - 5 - ctype)
    local skewNum = math.ceil(ctype / 6)

    local space, zindex, skewIndex = sprite:initPassed(index, ctype)
    sprite.card_bg:setFlipX(true)

    --牌值
    local yskews = {4, 6, 8}
    sprite.sprite_card:setSkewY(yskews[skewNum])
    sprite.sprite_card:setRotation(-90)

    --x轴位置
    sprite.sprite_card:setPositionX(sprite.sprite_card:getPositionX() + 4)

    --间距
    local xpaces = {4, 6, 8}
    space.x = xpaces[skewNum] / 1.5
    space.y = -space.y + 1

    return sprite, space, zindex - spaceIndex, skewIndex
end

----------------------------------------------------------------------------------------------------------------------
--三人模式
function SpriteSouthCard:initThreePassed(index, ctype, skewIndex, skewNum)
    local fscale = math.pow(0.956, skewIndex - 1)
    local cardtype = (skewNum - 1) * 3 + 28 + (skewIndex - 6)

    local spaces = {ccp(2, -34*fscale), ccp(3, -34*fscale), ccp(4, -34*fscale)}
    local yskews = {4, 6, 8}
    cclog("三人模式 initThreePassed "..cardtype)
    self.card_bg = loadSprite("mjBack/lmjpassbg_"..cardtype..".png")
    self.base_size = self.card_bg:getContentSize() 
    self.card_bg:setAnchorPoint(ccp(1,0))
    self:addChild(self.card_bg,0,10)
        
    self.sprite_card = loadSprite(string.format("mjValue/sc%x.png", index))
    self.sprite_card:setPosition(ccp(-self.base_size.width/2 - 1, self.base_size.height/2 + 9))
    self.sprite_card:setSkewY(yskews[skewNum])
    self.sprite_card:setRotation(-90)
    self.sprite_card:setScale(0.8 * fscale)   
    self:addChild(self.sprite_card,1,20)

    self.card_index = index
    self.card_type = ctype

    return spaces[skewNum], 4 - skewNum, 6 - skewIndex 
end

function SpriteSouthCard.createThreePassed(index, ctype)
     local spaceIndex = 0
    if ctype > 28 then 
        --越界处理
        spaceIndex = ctype - 18
        ctype = 28 
    end

    --ui位置调整参数
    local xpos, indexnum = -3, 9
    local skewIndex, skewNum = ctype % indexnum, math.ceil(ctype / indexnum)
    if skewIndex == 0 then
        skewIndex = indexnum
    end
    if ctype == 28 then skewIndex = 10 skewNum = 3 end

    if skewIndex < 7 then 
        ctype = (skewNum - 1) * 6 + skewIndex  
        return SpriteSouthCard.createPassed(index, ctype)
    end 

    local sprite = SpriteSouthCard.new()
    local space, zindex, skewIndex = sprite:initThreePassed(index, ctype, skewIndex, skewNum)
    return sprite, space, zindex - spaceIndex, skewIndex
end

function SpriteSouthCard:moveSpace()
    local fscale = math.pow(0.96, 15 - self.card_type)
    return ccp(-5 * fscale, 20 * fscale)
end

function SpriteSouthCard:weaveSpace(index)
    local fscale = math.pow(0.95, index)
    return ccp(-5 * fscale, 20 * fscale)
end

--添加手牌
function SpriteSouthCard:addHandCard()
    local sprite, space, zindex = SpriteSouthCard.createHand(self.card_type - 1, 0)
    if card then
        sprite, space, zindex = SpriteSouthCard.createPublicHand(self.card_type - 1, 0, card)
    end
        
    local zeropos = ccp(self:getPosition())
    sprite:setPosition(ccp(zeropos.x + space.x, zeropos.y + space.y))
    
    self:getParent():addChild(sprite, zindex)
    return sprite
end

--自己显示牌被的牌
function SpriteSouthCard.createHand(ctype, index)
    local sprite = SpriteSouthCard.new()
    local space, zindex = sprite:initHand(ctype)

    space.x = sprite:flipUI(space.x)
    sprite.card_space = space
    return sprite, space, zindex, 1
end

function SpriteSouthCard.createPublicHand(ctype, index, card)
    local zspace = 0
    if ctype > 13 then
        ctype = 13
        zspace = -1
    end

    local sprite, space, zindex = SpriteSouthCard.createVerticalPassed(card, ctype)
    sprite:setScale(0.96)
    space.x = -space.x*0.96
    space.y = -space.y*0.96
    sprite.card_space = space
    return sprite, space, zindex + zspace, index + 1
end

function SpriteSouthCard.createWallCard(ctype, index)
    local sprite = SpriteSouthCard.new()
    local space, zindex = sprite:initWallCard(ctype)

    space.x = sprite:flipUI(space.x)
    return sprite, space, zindex, index + 1
end

function SpriteSouthCard.createHorizontalPassed(index, ctype, dirct)
    local sprite = SpriteSouthCard.new()
    local space, zIndex = sprite:initHorizontalPassed(index, ctype,dirct)
    sprite.card_dirct = dirct

    --牌值
    sprite.sprite_card:setSkewX(-16)
    sprite.sprite_card:setRotation(180)
	
    sprite.sprite_card:setPositionX(sprite.sprite_card:getPositionX() + 6)
	 
    --碰牌位置修正
    local horspace = ccp(3, 0)

    space.x = sprite:flipUI(space.x)
    return sprite, space, zIndex, horspace
end

function SpriteSouthCard.addHorizontalPassed(item,dirct)
    local index, ctype, dirctTemp = item.card_index, item.card_type, item.card_dirct
    local sprite, space, zIndex = SpriteSouthCard.createHorizontalPassed(index, ctype, dirct)

    local spaces = {ccp(-65, 0), ccp(-64, 0), ccp(-62, 0), ccp(-60, 0), 
            ccp(-60, 0), ccp(-58, 0), ccp(-56, 0), ccp(-56, 0), ccp(-54, 0)}

    return sprite, ccp(spaces[ctype].x / 1.5, spaces[ctype].y / 1.5), item:getZOrder()
end

function SpriteSouthCard.createVerticalPassed(index, ctype)
    local sprite = SpriteSouthCard.new()
    local space, zIndex = sprite:initVerticalPassed(index, ctype)

    --牌值
    sprite.sprite_card:setSkewY(20)
    sprite.sprite_card:setRotation(-90)
    sprite.sprite_card:setPositionX(sprite.sprite_card:getPositionX() + 6)

    space.x = sprite:flipUI(space.x)
    sprite.card_space = space
	
    return sprite, space, zIndex
end
function SpriteSouthCard.createVerticalBack(ctype)
    local sprite = SpriteSouthCard.new()
    local space, zIndex = sprite:initVerticalBack(ctype)
    
    space.x = sprite:flipUI(space.x)
    return sprite, space, zIndex
end


 return SpriteSouthCard