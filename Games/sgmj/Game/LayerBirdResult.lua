--LayerBirdResult.lua
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")

local LayerBirdResult=class("LayerBirdResult",function()
    return CCLayerColor:create(AppConfig.COLOR.ColorLayer_Bg)
end)

function LayerBirdResult:show(birds, poses, states, func) 
    self:addBirdTitle()
    self:setVisible(true)    
    self:setTouchEnabled(true)

    require("Lobby/Common/AnimationUtil").spriteScaleShowAction(self.title, function()
        self:addGameBird(birds, poses, states, func)
    end)
end

function LayerBirdResult:addBirdTitle()
    local title =  loadSprite("sgmj/img_horse_title.png")
    title:setPosition(ccp(640, 600))
    self:addChild(title) 
	self.title = title
end

function LayerBirdResult:addGameBird(birds, poses, states, func)
    require("Lobby/Set/SetLogic").playGameEffect(AppConfig.SoundFilePathName.."getbird"..AppConfig.SoundFileExtName)

    local count, pos = #birds, ccp(AppConfig.SCREEN.CONFIG_WIDTH / 2 - 40, 250)
    local num, space = math.floor(count / 2), 80
    if count % 2 == 0 then
        pos.x = pos.x + space - num * space * 1.5
    else
        pos.x = pos.x - num * space * 1.5
    end

    local function spriteScale(speed)
        speed = speed or 1
        local arrayScale = CCArray:create()
        arrayScale:addObject(CCScaleTo:create(0.2 * speed, 1))
        arrayScale:addObject(CCFadeIn:create(0.2 * speed))

        local array = CCArray:create()
        array:addObject(CCFadeOut:create(0))
        array:addObject(CCScaleTo:create(0, 0.9 * 1))
        array:addObject(CCSpawn:create(arrayScale))
        array:addObject(CCDelayTime:create(0.1 * speed))

        return array
    end

    local SpriteGameCard = require("sgmj/Game/SpriteGameCard")
    local array  = CCArray:create()
    local birdSps = {}
    for i,v in ipairs(birds) do
        local cardSp = SpriteGameCard.createHand(v) 
        cardSp:setPosition(pos)

        local scaleArray = spriteScale()
        cardSp:setScale(0)
        self:addChild(cardSp)
        pos.x = pos.x + space * 1.5
        array:addObject(CCTargetedAction:create(cardSp, CCSequence:create(scaleArray)))

        table.insert(birdSps, cardSp)
    end

    --添加标识
    for i,v in ipairs(birdSps) do
        --添加中鸟标识
        v.lightSp = loadSprite("sgmj/img_horse_light.png")
        v.lightSp:setPosition(ccp(v.base_size.width / 2, v.base_size.height / 2))
        v.lightSp:setScale(0)
        v:addChild(v.lightSp, -1)

        v.markSp = loadSprite("sgmj/img_horse_mark.png")
        v.markSp:setPosition(ccp(15, v.base_size.height - 18))
        v.markSp:setScale(0)
        v:addChild(v.markSp)
    end

    --显示一下
    array:addObject(CCDelayTime:create(0.4))    
    array:addObject(CCTargetedAction:create(self.title,CCFadeOut:create(0.1)))

    for i,v in ipairs(birdSps) do
        --跳转到指定位置
        if not b159 then
            array:addObject(CCTargetedAction:create(v, 
                CCEaseIn:create(CCMoveTo:create(0.3, poses[i]), 0.05)))
			poses[i].x = poses[i].x + space -- 没显示一张牌，位置向后移动一张牌的宽度
        end
        
        if states[i] then
            --播放中鸟光
            array:addObject(CCTargetedAction:create(v, CCCallFunc:create(function()
                local arrayLight = CCArray:create()
                arrayLight:addObject(CCScaleTo:create(0.1, 1)) 
                arrayLight:addObject(CCRotateBy:create(20, -7200))
                v.lightSp:runAction(CCSequence:create(arrayLight))

                v.markSp:runAction(CCSequence:create(spriteScale(0.5)))
            end)))
        end
    end

    array:addObject(CCDelayTime:create(2))
    array:addObject(CCCallFunc:create(function()
        self:removeFromParentAndCleanup(true)
        func()
    end))

    self:runAction(CCSequence:create(array))
end

function LayerBirdResult:init()
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true
        end
    end
    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority - self.layer_zIndex,true)
    self:setTouchEnabled(false)

    self:setVisible(false)
end

function LayerBirdResult.put(super, zindex)
    local layer = LayerBirdResult.new()
    layer.layer_zIndex = zindex
    super:addChild(layer, zindex)
    layer:init()
    return layer
end

return LayerBirdResult