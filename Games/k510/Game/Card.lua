require("CocosExtern")
local Resources = require("k510/Resources")
local Card=class("Card",function()
    return CCLayer:create()
    end)
Card.__index =Player

function Card.create()
    local layer = Card.new()
    layer:init()
	return layer
end

function Card:init()
	self._value = 0
    
    self.width = 156
    self.height = 210
    
	self._isSelete = false  --最终选中
	self._isMark = false    --移动是选中
    
    -- 牌背
	self._CardSp = loadSprite("pai/back.png")
	self._CardSp:setAnchorPoint(0.0,0.0)
    -- 牌值
    self._CardValue = CCSprite:create()
    self._CardValue:setPosition(ccp(36, 162))
    self._CardValue:setVisible(false)
    self._CardSp:addChild(self._CardValue)
    -- 大花
    self._CardBType = CCSprite:create()
    self._CardBType:setPosition(ccp(105, 66))
    self._CardBType:setVisible(false)
    self._CardSp:addChild(self._CardBType)
    -- 小花
    self._CardSType = CCSprite:create()
    self._CardSType:setPosition(ccp(36, 110))
    self._CardSType:setVisible(false)
    self._CardSp:addChild(self._CardSType)

    self:addChild(self._CardSp)
    self._CardSp:setPosition(400,400)

end

function Card:setPos(point)
	self._CardSp:setPosition(point)
end

function Card:setScale(scale)
	self._CardSp:setScale(scale)
end

function Card:setCardSp(idx, cardValue)
    local c = CCSpriteFrameCache:sharedSpriteFrameCache()
	self._value = cardValue
    if cardValue >= 0 then
        local cardTypeStr

        local cardNum = cardValue % 13 + 1
        local cardType = math.floor(cardValue / 13)
        local value = cardType % 2 * 100 + cardNum

        self._CardSp:setDisplayFrame(c:spriteFrameByName("pai/front.png"))
        self._CardValue:setDisplayFrame(c:spriteFrameByName(string.format("pai/%d.png", value)))
        self._CardBType:setDisplayFrame(c:spriteFrameByName(string.format("pai/b%d.png", cardType)))
        self._CardSType:setDisplayFrame(c:spriteFrameByName(string.format("pai/s%d.png", cardType)))
        self._CardValue:setVisible(true)
        self._CardBType:setVisible(true)
        self._CardSType:setVisible(true)
    else
        self._CardSp:setDisplayFrame(c:spriteFrameByName("pai/back.png"))
        self._CardValue:setVisible(false)
        self._CardBType:setVisible(false)
        self._CardSType:setVisible(false)
    end
end

function Card:getCard()
   return self._CardSp
end

-- 根据选中状态设置牌弹起状态
function Card:setCardsUp()
	self.offset = 20
    if self:getMark() then
        self:setSelect(not self:isSeleted())
    end
	if self:isSeleted() then
		self._CardSp:setPositionY(36 + self.offset )
	else
		self._CardSp:setPositionY(36)
	end
    self:setMark(false)
    self:showMark()
end

-- 牌显示
function Card:Show()
   self:setVisible(true)
end

-- 牌隐藏
function Card:Hide()
    self:setVisible(false)
    self._isSelete = false
    self._isMark = false
    self._CardSp:setColor(ccc3(255, 255, 255))
    self._CardValue:setColor(ccc3(255, 255, 255))
    self._CardBType:setColor(ccc3(255, 255, 255))
    self._CardSType:setColor(ccc3(255, 255, 255))
end

-- 标记为选中
function Card:setMark(marked)
	self._isMark = marked
end

-- 显示选中状态
function Card:showMark()
    if self._isMark then
        self._CardSp:setColor(ccc3(100, 100, 100))
        self._CardValue:setColor(ccc3(100, 100, 100))
        self._CardBType:setColor(ccc3(100, 100, 100))
        self._CardSType:setColor(ccc3(100, 100, 100))
    else
        self._CardSp:setColor(ccc3(255, 255, 255))
        self._CardValue:setColor(ccc3(255, 255, 255))
        self._CardBType:setColor(ccc3(255, 255, 255))
        self._CardSType:setColor(ccc3(255, 255, 255))
    end
end

-- 获取选中标记
function Card:getMark()
	return self._isMark
end

-- 设置弹起标记
function Card:setSelect(selected)
	self._isSelete = selected
end

-- 是否弹起
function Card:isSeleted()
	return self._isSelete
end

-- 牌重置
function Card:reset()
    self:setMark(false)
	self.offset = 20
	if self._isSelete == true then
		self._CardSp:setPositionY(self._CardSp:getPositionY() - self.offset )
	end 
    self._isSelete = false
end

function Card:getCardValue()
	return self._value
end

function Card:setCardPos(pos)
	self._CardSp:setPosition(pos)
end

function Card:getPos()
	return ccp(self._CardSp:getPositionX(), self._CardSp:getPositionY())
end

return Card