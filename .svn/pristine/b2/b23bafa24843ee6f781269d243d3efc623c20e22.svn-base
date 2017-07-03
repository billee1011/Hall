require("CocosExtern")
local Common = require("k510/Game/Common")
local GameLogic = require("k510/Game/GameLogic")
local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")

local CountDownLayer = class("CountDownLayer",function()
    return CCLayer:create()
end)

function CountDownLayer.create()
    local layer = CountDownLayer.new()
    layer:init()
	return layer
end

function CountDownLayer.update(layer)
    local gameStarted = FriendGameLogic.game_used and (FriendGameLogic.game_used > 0)
    local v, e = GameLogic.validTime, GameLogic.exprireTime
    if (not gameStarted) and v and v > 0 then
        layer.timeLabel:setString(string.format(
            "%02d:%02d",
            math.floor(v % 86400 % 3600 / 60),
            v % 86400 % 3600 % 60
        ))
        layer:setVisible(true)
        GameLogic.validTime = GameLogic.validTime - 1
    else
        GameLogic.validTime = 0
        layer:setVisible(false)
    end
end

function CountDownLayer:init()
    self.winSize = CCSizeMake(require("k510/GameDefs").CommonInfo.View_Width, require("k510/GameDefs").CommonInfo.View_Height)

    --背景
    local bg = loadSprite("lobby_message_tip_bg.png")
    self:addChild(bg)
    bg:setPosition(self.winSize.width/2,self.winSize.height/2+60)

    bgSize = bg:getContentSize()
    
    -- 标题
    titleLabel = CCLabelTTF:create("30分钟未开始游戏，系统自动解散房间", "", 26)
    titleLabel:setPosition(ccp(bgSize.width / 2, bgSize.height / 2 + 26))
    bg:addChild(titleLabel)
    
    self.timeLabel = CCLabelTTF:create("", "", 40)
    self.timeLabel:setPosition(ccp(bgSize.width / 2, bgSize.height / 2 - 26))
    bg:addChild(self.timeLabel)
    
    local array  = CCArray:create()
    array:addObject(CCCallFuncN:create(self.update))
    array:addObject(CCDelayTime:create(1))
    self:runAction(
        CCRepeatForever:create(CCSequence:create(array))
    )
end

function CountDownLayer:hide()
    self:setVisible(false)
end

return CountDownLayer