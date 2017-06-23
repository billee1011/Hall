--AnimationUtil.lua
local AnimationUtil = {}
AnimationUtil.__index = AnimationUtil

local AppConfig = require("AppConfig")


--金币动画
function AnimationUtil.playCoinArmature(super, func)
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(AppConfig.ImgFilePathName.."armature/jinbi.ExportJson")
    local mature= CCArmature:create("jinbi")
    mature:setScale(1.5)
    mature:getAnimation():playWithIndex(0)
    mature:setPosition(AppConfig.SCREEN.MID_POS)
    super:addChild(mature)

    local function animationMovementEvent(armature,  movementType, movementID)
        if (movementType ==1) then
            armature:removeFromParentAndCleanup(true)
            if func then
                func()
            end
        end
    end
    mature:getAnimation():setMovementEventCallFunc(animationMovementEvent)
end

--闪烁动画
function AnimationUtil.runFlickerAction(node, isRuning, nodesp)
    if isRuning then
        local array  = CCArray:create()
        if nodesp then
            array:addObject(CCTargetedAction:create(node, CCFadeTo:create(0, 0)))
            array:addObject(CCTargetedAction:create(nodesp, CCFadeTo:create(0, 255)))
            array:addObject(CCTargetedAction:create(nodesp, CCDelayTime:create(0.5)))
            array:addObject(CCTargetedAction:create(nodesp, CCFadeTo:create(0, 0)))
            array:addObject(CCTargetedAction:create(node, CCFadeTo:create(0, 255)))
            array:addObject(CCTargetedAction:create(node, CCDelayTime:create(0.5)))
        else
            array:addObject(CCTargetedAction:create(node, CCFadeTo:create(0.3, 0)))
            array:addObject(CCTargetedAction:create(node, CCDelayTime:create(0.5)))
            array:addObject(CCTargetedAction:create(node, CCFadeTo:create(0.3, 255)))
            array:addObject(CCTargetedAction:create(node, CCDelayTime:create(0.5)))
        end
        node:runAction(CCRepeatForever:create(CCRepeatForever:create(CCSequence:create(array))))
    else
        node:stopAllActions()
    end
end

--精灵盖章动画
function AnimationUtil.spriteScaleAction(node, callfunc)
    local fscale = node:getScale()
    node:setScale(0)

    local array = CCArray:create()
    array:addObject(CCShow:create())
    array:addObject(CCScaleTo:create(0.2, fscale * 1.8))
    array:addObject(CCDelayTime:create(0.2))
    array:addObject(CCScaleTo:create(0.2, fscale * 0.8))
    array:addObject(CCDelayTime:create(0.3))
    --array:addObject(CCScaleTo:create(0, fscale * 2))
    --array:addObject(CCScaleTo:create(1, fscale * 0.8))

    if (callfunc ~= nil) then
        --array:addObject(CCHide:create())
        array:addObject(CCCallFunc:create(callfunc))
    end

    --array:addObject(CCDelayTime:create(2))
    --node:runAction(CCRepeatForever:create(CCSequence:create(array)))
    node:runAction(CCSequence:create(array))
end

--精灵放大弹出动画
function AnimationUtil.spriteScaleShowAction(node, callfunc, fscale)
    fscale = fscale or 1
    node:setScale(0)
    
    local arrayScale = CCArray:create()
    arrayScale:addObject(CCScaleTo:create(0.2, fscale))
    arrayScale:addObject(CCFadeIn:create(0.2))

    local array = CCArray:create()
    array:addObject(CCFadeOut:create(0))
    array:addObject(CCScaleTo:create(0, 0.9 * fscale))
    array:addObject(CCSpawn:create(arrayScale))

    if (callfunc ~= nil) then
        array:addObject(CCCallFunc:create(callfunc))
    end

    node:runAction(CCSequence:create(array))
end


--精灵缩小隐藏动画
function AnimationUtil.spriteScaleHideAction(node, callfunc, fscale)
    local arrayScale = CCArray:create()
    fscale = fscale or 1
    arrayScale:addObject(CCScaleTo:create(0.2, 0.9 * fscale))

    local array = CCArray:create()
    array:addObject(CCSpawn:create(arrayScale))
    if (callfunc ~= nil) then
        array:addObject(CCCallFunc:create(callfunc))
    end

    node:runAction(CCSequence:create(array))
end

--翻牌动画动画
function AnimationUtil.FlipCardAction(bg, front, secs, array)
    array = array or CCArray:create()
    array:addObject(CCTargetedAction:create(bg, CCOrbitCamera:create(secs, 1, 0, 0, 90, 0, 0)))
    array:addObject(CCTargetedAction:create(bg, CCHide:create()))

    array:addObject(CCTargetedAction:create(front, CCShow:create()))
    array:addObject(CCTargetedAction:create(front, CCSpawn:createWithTwoActions(
        CCScaleTo:create(secs, 1), CCOrbitCamera:create(secs,1, 0, 270, 90, 0, 0))))

    --array:addObject(CCTargetedAction:create(nodesp, CCDelayTime:create(5)))
    --array:addObject(CCTargetedAction:create(nodesp, CCOrbitCamera:create(secs,1, 0, 270, 90, 0, 0)))

    return array
end

--向里翻牌动画
function AnimationUtil.FlipUpAction(bg, front, secs, array)
    array = array or CCArray:create()
    array:addObject(CCTargetedAction:create(bg, CCOrbitCamera:create(secs, 1, 0, 0, -45, 90, 0)))
    array:addObject(CCTargetedAction:create(bg, CCHide:create()))

    array:addObject(CCTargetedAction:create(front, CCShow:create()))
    array:addObject(CCTargetedAction:create(front, CCSpawn:createWithTwoActions(
        CCScaleTo:create(secs, 1), CCOrbitCamera:create(secs,1, 0, 45, -45, 90, 0))))

    --array:addObject(CCTargetedAction:create(nodesp, CCDelayTime:create(5)))
    --array:addObject(CCTargetedAction:create(nodesp, CCOrbitCamera:create(secs,1, 0, 270, 90, 0, 0)))

    return array
end

return AnimationUtil
