--LayerBirdResult.lua
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")

local LayerBirdResult=class("LayerBirdResult",function()
    return CCLayerColor:create(AppConfig.COLOR.ColorLayer_Bg)
end)

function LayerBirdResult:show(birds, valids, func) 
    self:setVisible(true)
    self:setTouchEnabled(true)

    self:addBirdTitle()
    self:addGameBird(birds, valids, func)
end

function LayerBirdResult:addBirdTitle()
    local CommonInfo = require("czmj/GameDefs").CommonInfo
    local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")

    local index = FriendGameLogic.my_rule[2][2]
    local title =  loadSprite("czmj/birdTitle"..index..".png")
    title:setPosition(ccp(CommonInfo.View_Width / 2, CommonInfo.View_Height - 120))
    self:addChild(title)

end

function LayerBirdResult:addGameBird(birds, valids, func)
    require("Lobby/Set/SetLogic").playGameEffect(AppConfig.SoundFilePathName.."getbird"..AppConfig.SoundFileExtName)

    local count, pos = #birds, ccp(AppConfig.SCREEN.CONFIG_WIDTH / 2 - 40, AppConfig.SCREEN.CONFIG_HEIGHT / 2)
    local num, space = math.floor(count / 2), 60
    if count % 2 == 0 then
        pos.x = pos.x + space - num * space * 2
    else
        pos.x = pos.x - num * space * 2
    end

    local function spriteScale()
        local arrayScale = CCArray:create()
        arrayScale:addObject(CCScaleTo:create(0.2, 1))
        arrayScale:addObject(CCFadeIn:create(0.2))

        local array = CCArray:create()
        array:addObject(CCFadeOut:create(0))
        array:addObject(CCScaleTo:create(0, 0.9 * 1))
        array:addObject(CCSpawn:create(arrayScale))
        array:addObject(CCDelayTime:create(0.1))

        return array
    end

    local SpriteGameCard = require("czmj/Game/SpriteGameCard")
    local array  = CCArray:create()
    local index, birdSps, validIdx = 1, {}, {}
    for i,v in ipairs(birds) do
        local cardSp = SpriteGameCard.createHand(v) 
        cardSp:setPosition(pos)

        validIdx[i] = false
        local scaleArray = spriteScale()
        if index <= #valids and valids[index] == v then
            --添加牌值
            index = index + 1 
            validIdx[i] = true
        end
        cardSp:setScale(0)
        self:addChild(cardSp)
        pos.x = pos.x + space * 2
        array:addObject(CCTargetedAction:create(cardSp, CCSequence:create(scaleArray)))

        table.insert(birdSps, cardSp)
    end

    array:addObject(CCDelayTime:create(0.3))
    for i,v in ipairs(birdSps) do
        if validIdx[i] then
            --抓鸟成功
            array:addObject(CCTargetedAction:create(v, CCCallFunc:create(function()
                local sprite = loadSprite("mjAnima/img_mjbg.png")
                sprite:setPosition(ccp(v.base_size.width / 2, v.base_size.height / 2))
                v:addChild(sprite, -1)
                require("Lobby/Common/AnimationUtil").runFlickerAction(sprite, true)
            end)))
            array:addObject(CCTargetedAction:create(v, CCMoveBy:create(0.2, ccp(0, -160))))
        else
            --抓鸟失败
            array:addObject(CCTargetedAction:create(v, CCCallFunc:create(function()
                v:addCardMask(ccc4(0, 0, 0, 100))
            end)))
            array:addObject(CCTargetedAction:create(v, CCDelayTime:create(0.1)))
        end
    end
    array:addObject(CCDelayTime:create(1.5))
    array:addObject(CCCallFunc:create(function()
        self:removeFromParentAndCleanup(true)
        func()
    end))

    self:runAction(CCSequence:create(array))
end

function LayerBirdResult:init(func) 
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true
        end
    end
    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority - self.layer_zIndex,true)
    self:setTouchEnabled(true)
end

function LayerBirdResult.put(super, zindex)
    local layer = LayerBirdResult.new()
    layer.layer_zIndex = zindex
    super:addChild(layer, zindex)
    layer:init()
    return layer
end

return LayerBirdResult