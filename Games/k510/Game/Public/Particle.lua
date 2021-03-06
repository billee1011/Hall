
--扑克逻辑类定义
local Particle = class("Particle")

--扑克逻辑类对象实例化
function Particle.create()
    local particle = Particle.new()
    return particle
end

--扑克逻辑类对象属性   初始化值
function Particle:ctor()
    self.visibleSize = CCDirector:sharedDirector():getVisibleSize()
end
--------------------自定义

----拖尾粒子效果
--@param parentNode 父节点  , particleNum 粒子数量 , position 位置 , texturePathStr 纹理图路径
--@return
function Particle:CreateParticleTailing(parentNode,particleNum,position,texturePathStr)
    local tempParticle = CCParticleSystemQuad:new()
    tempParticle:initWithTotalParticles(particleNum)
    tempParticle:setTexture( CCTextureCache:sharedTextureCache():addImage(texturePathStr) )
    tempParticle:setPosition(position)
    parentNode:addChild(tempParticle)
    
    --参数设置
    tempParticle:setDuration(0.2)
    tempParticle:setGravity(ccp(0, 0))
    tempParticle:setAngle(0)
    tempParticle:setAngleVar(360)
    tempParticle:setSpeed(50)
    tempParticle:setSpeedVar(10)
    tempParticle:setRadialAccel(10)
    tempParticle:setRadialAccelVar(0)
    tempParticle:setTangentialAccel(10)
    tempParticle:setTangentialAccelVar(0)
    --            tempParticle:setPosition(160, 240)
    tempParticle:setPosVar(ccp(0, 0))
    tempParticle:setLife(1)
    tempParticle:setLifeVar(0)
    tempParticle:setStartSpin(0)
    tempParticle:setStartSizeVar(0)
    tempParticle:setEndSpin(0)
    tempParticle:setEndSpinVar(0)
    tempParticle:setStartColor(ccc4f(255, 255, 255, 255))
    tempParticle:setStartColorVar(ccc4f(255, 255, 255, 0))
    tempParticle:setEndColor(ccc4f(255, 255, 255, 0))
    tempParticle:setEndColorVar(ccc4f(0, 0, 0, 0))
    tempParticle:setStartSize(64.0)
    tempParticle:setStartSizeVar(30.0)
    tempParticle:setEndSize(-1)
    tempParticle:setEmissionRate(tempParticle:getTotalParticles() / tempParticle:getLife())
    tempParticle:setBlendAdditive(true)
    tempParticle:setAutoRemoveOnFinish(true)
    
    return tempParticle
end

----圆形进度条粒子效果
--@param parentNode 父节点  , particleNum 粒子数量 , position 位置 , texturePathStr 纹理图路径
--@return
function Particle:CreateParticleCircleProgress(parentNode,particleNum,position,radiusValue,times,texturePathStr)
    --添加2个父节点
    local tempNode1 = CCNode:create()
    tempNode1:setPosition(position)
    tempNode1:setTag(100)
    parentNode:addChild(tempNode1)
    
    local tempNode2 = CCNode:create()
    tempNode2:setPosition(ccp(0,radiusValue))
    tempNode1:addChild(tempNode2)
    --添加粒子
    local tempParticle = CCParticleSystemQuad:new()
    tempParticle:initWithTotalParticles(particleNum)
    tempParticle:setTexture( CCTextureCache:sharedTextureCache():addImage(texturePathStr) )
--    tempParticle:setPosition(position)
    tempNode2:addChild(tempParticle)
    
    --参数设置
    tempParticle:setDuration(-1)
    tempParticle:setGravity(ccp(0, 0))
    tempParticle:setAngle(180)
    tempParticle:setAngleVar(10)
    tempParticle:setSpeed(30)
    tempParticle:setSpeedVar(10)
    tempParticle:setRadialAccel(30)
    tempParticle:setRadialAccelVar(30)
    tempParticle:setTangentialAccel(10)
    tempParticle:setTangentialAccelVar(0)
    --            tempParticle:setPosition(160, 240)
    tempParticle:setPosVar(ccp(0, 0))
    tempParticle:setLife(1)
    tempParticle:setLifeVar(0)
    tempParticle:setStartSpin(0)
    tempParticle:setStartSizeVar(0)
    tempParticle:setEndSpin(0)
    tempParticle:setEndSpinVar(0)
    tempParticle:setStartColor(ccc4f(255, 255, 255, 255))
    tempParticle:setStartColorVar(ccc4f(255, 255, 255, 100))
    tempParticle:setEndColor(ccc4f(255, 255, 255, 0))
    tempParticle:setEndColorVar(ccc4f(0, 0, 0, 0))
    tempParticle:setStartSize(30)
    tempParticle:setStartSizeVar(10)
    tempParticle:setEndSize(-1)
    tempParticle:setEmissionRate(tempParticle:getTotalParticles() / tempParticle:getLife())
    tempParticle:setBlendAdditive(true)
    tempParticle:setAutoRemoveOnFinish(true)
    
    local function RemoveCallBack()
        tempNode1:removeFromParentAndCleanup(true)
    end
    
    local array  = CCArray:create()
    array:addObject(CCRotateTo:create(times,720))
    array:addObject(CCFadeOut:create(0.5))
    array:addObject(CCCallFunc:create(RemoveCallBack))
    tempNode1:runAction(CCSequence:create(array))
    
    return tempParticle , tempNode1
end

----进度条粒子效果
--@param parentNode 父节点  , particleNum 粒子数量 , position 位置 , texturePathStr 纹理图路径
--@return
function Particle:CreateParticleRectangleProgress(parentNode,particleNum,position,radiusValue,times,texturePathStr)
    
end

--------------------------系统自带

----爆炸粒子效果
--@param
--@return
function Particle:CreateParticleExplosion(parentNode,particleNum,position,texturePathStr)
    local tempParticle = CCParticleSystemQuad:new()
    tempParticle:initWithTotalParticles(particleNum)
    tempParticle:setTexture( CCTextureCache:sharedTextureCache():addImage(texturePathStr) )
    tempParticle:setPosition(position)
    tempParticle:setDuration(0.1)
    tempParticle:setLife(0.5)
    tempParticle:setLifeVar(0)
    tempParticle:setStartColor(ccc4f(255, 255, 255, 255))
    tempParticle:setStartColorVar(ccc4f(255, 255, 255, 255))
    tempParticle:setEndColor(ccc4f(0, 0, 0, 0))
    tempParticle:setEndColorVar(ccc4f(0, 0, 0, 0))
    tempParticle:setStartSize(64.0)
    tempParticle:setStartSizeVar(30.0)
    tempParticle:setSpeed(80)
    tempParticle:setSpeedVar(30)
    tempParticle:setAutoRemoveOnFinish(true)
    parentNode:addChild(tempParticle)
    
    return tempParticle
end

----烟花粒子效果
--@param
--@return
function Particle:CreateParticleFireworks(parentNode,particleNum,position,texturePathStr)
    local tempParticle = CCParticleSystemQuad:new()
    tempParticle:initWithTotalParticles(particleNum)
    tempParticle:setTexture( CCTextureCache:sharedTextureCache():addImage(texturePathStr) )
    tempParticle:setPosition(position)
    tempParticle:setDuration(1)
    tempParticle:setLife(2)
    tempParticle:setLifeVar(0)
    tempParticle:setStartColor(ccc4f(255, 255, 255, 255))
    tempParticle:setStartColorVar(ccc4f(255, 255, 255, 255))
    tempParticle:setEndColor(ccc4f(0, 0, 0, 0))
    tempParticle:setEndColorVar(ccc4f(0, 0, 0, 0))
    tempParticle:setStartSize(64.0)
    tempParticle:setStartSizeVar(30.0)
    tempParticle:setSpeed(80)
    tempParticle:setSpeedVar(30)
    tempParticle:setAutoRemoveOnFinish(true)
    parentNode:addChild(tempParticle)

    return tempParticle
end

----火焰粒子效果
--@param
--@return
function Particle:CreateParticleFire(parentNode,particleNum,position,texturePathStr)
    local tempParticle = CCParticleSystemQuad:new()
    tempParticle:initWithTotalParticles(particleNum)
    tempParticle:setTexture( CCTextureCache:sharedTextureCache():addImage(texturePathStr) )
    tempParticle:setPosition(position)
    tempParticle:setDuration(1)
    tempParticle:setLife(2)
    tempParticle:setLifeVar(0)
    tempParticle:setStartColor(ccc4f(255, 255, 255, 255))
    tempParticle:setStartColorVar(ccc4f(255, 255, 255, 255))
    tempParticle:setEndColor(ccc4f(0, 0, 0, 0))
    tempParticle:setEndColorVar(ccc4f(0, 0, 0, 0))
    tempParticle:setStartSize(64.0)
    tempParticle:setStartSizeVar(30.0)
    tempParticle:setSpeed(80)
    tempParticle:setSpeedVar(30)
    tempParticle:setAutoRemoveOnFinish(true)
    parentNode:addChild(tempParticle)

    return tempParticle
end

----流星粒子效果
--@param
--@return
function Particle:CreateParticleMeteor(parentNode,particleNum,position,texturePathStr)
    local tempParticle = CCParticleSystemQuad:new()
    tempParticle:initWithTotalParticles(particleNum)
    tempParticle:setTexture( CCTextureCache:sharedTextureCache():addImage(texturePathStr) )
    tempParticle:setPosition(position)
    tempParticle:setDuration(1)
    tempParticle:setLife(2)
    tempParticle:setLifeVar(0)
    tempParticle:setStartColor(ccc4f(255, 255, 255, 255))
    tempParticle:setStartColorVar(ccc4f(255, 255, 255, 255))
    tempParticle:setEndColor(ccc4f(0, 0, 0, 0))
    tempParticle:setEndColorVar(ccc4f(0, 0, 0, 0))
--    tempParticle:setStartSize(64.0)
--    tempParticle:setStartSizeVar(30.0)
--    tempParticle:setSpeed(80)
--    tempParticle:setSpeedVar(30)
    tempParticle:setAutoRemoveOnFinish(true)
    parentNode:addChild(tempParticle)

    return tempParticle
end

----漩涡粒子效果
--@param
--@return
function Particle:CreateParticleSpiral(parentNode,particleNum,position,texturePathStr)
    local tempParticle = CCParticleSystemQuad:new()
    tempParticle:initWithTotalParticles(particleNum)
    tempParticle:setTexture( CCTextureCache:sharedTextureCache():addImage(texturePathStr) )
    tempParticle:setPosition(position)
    tempParticle:setDuration(1)
    tempParticle:setLife(2)
    tempParticle:setLifeVar(0)
    tempParticle:setStartColor(ccc4f(255, 255, 255, 255))
    tempParticle:setStartColorVar(ccc4f(255, 255, 255, 255))
    tempParticle:setEndColor(ccc4f(0, 0, 0, 0))
    tempParticle:setEndColorVar(ccc4f(0, 0, 0, 0))
    tempParticle:setStartSize(64.0)
    tempParticle:setStartSizeVar(30.0)
    tempParticle:setSpeed(80)
    tempParticle:setSpeedVar(30)
    tempParticle:setAutoRemoveOnFinish(true)
    parentNode:addChild(tempParticle)

    return tempParticle
end

----雪粒子效果
--@param
--@return
function Particle:CreateParticleSnow(parentNode,particleNum,position,texturePathStr)
    local tempParticle = CCParticleSystemQuad:new()
    tempParticle:initWithTotalParticles(particleNum)
    tempParticle:setTexture( CCTextureCache:sharedTextureCache():addImage(texturePathStr) )
    tempParticle:setPosition(position)
    tempParticle:setDuration(1)
    tempParticle:setLife(2)
    tempParticle:setLifeVar(0)
    tempParticle:setStartColor(ccc4f(255, 255, 255, 255))
    tempParticle:setStartColorVar(ccc4f(255, 255, 255, 255))
    tempParticle:setEndColor(ccc4f(0, 0, 0, 0))
    tempParticle:setEndColorVar(ccc4f(0, 0, 0, 0))
    tempParticle:setStartSize(64.0)
    tempParticle:setStartSizeVar(30.0)
    tempParticle:setSpeed(80)
    tempParticle:setSpeedVar(30)
    tempParticle:setAutoRemoveOnFinish(true)
    parentNode:addChild(tempParticle)

    return tempParticle
end

----烟粒子效果
--@param
--@return
function Particle:CreateParticleSmoke(parentNode,particleNum,position,texturePathStr)
    local tempParticle = CCParticleSystemQuad:new()
    tempParticle:initWithTotalParticles(particleNum)
    tempParticle:setTexture( CCTextureCache:sharedTextureCache():addImage(texturePathStr) )
    tempParticle:setPosition(position)
    tempParticle:setDuration(1)
    tempParticle:setLife(2)
    tempParticle:setLifeVar(0)
    tempParticle:setStartColor(ccc4f(255, 255, 255, 255))
    tempParticle:setStartColorVar(ccc4f(255, 255, 255, 255))
    tempParticle:setEndColor(ccc4f(0, 0, 0, 0))
    tempParticle:setEndColorVar(ccc4f(0, 0, 0, 0))
    tempParticle:setStartSize(64.0)
    tempParticle:setStartSizeVar(30.0)
    tempParticle:setSpeed(80)
    tempParticle:setSpeedVar(30)
    tempParticle:setAutoRemoveOnFinish(true)
    parentNode:addChild(tempParticle)

    return tempParticle
end

----太阳粒子效果
--@param
--@return
function Particle:CreateParticleSun(parentNode,particleNum,position,texturePathStr)
    local tempParticle = CCParticleSystemQuad:new()
    tempParticle:initWithTotalParticles(particleNum)
    tempParticle:setTexture( CCTextureCache:sharedTextureCache():addImage(texturePathStr) )
    tempParticle:setPosition(position)
    tempParticle:setDuration(2)
    tempParticle:setLife(2)
    tempParticle:setLifeVar(0)
    tempParticle:setStartColor(ccc4f(255, 255, 255, 255))
    tempParticle:setStartColorVar(ccc4f(0, 0, 0, 0))
    tempParticle:setEndColor(ccc4f(255, 255, 255, 255))
    tempParticle:setEndColorVar(ccc4f(0, 0, 0, 0))
    tempParticle:setStartSize(44.0)
    tempParticle:setStartSizeVar(10.0)
    tempParticle:setSpeed(350)
    tempParticle:setSpeedVar(250)
    tempParticle:setAutoRemoveOnFinish(true)
    parentNode:addChild(tempParticle)

    return tempParticle
end

----雨粒子效果
--@param
--@return
function Particle:CreateParticleRain(parentNode,particleNum,position,texturePathStr)
    local tempParticle = CCParticleSystemQuad:new()
    tempParticle:initWithTotalParticles(particleNum)
    tempParticle:setTexture( CCTextureCache:sharedTextureCache():addImage(texturePathStr) )
    tempParticle:setPosition(position)
    tempParticle:setDuration(1)
    tempParticle:setLife(5)
    tempParticle:setLifeVar(0)
    tempParticle:setStartColor(ccc4f(255, 255, 255, 255))
    tempParticle:setStartColorVar(ccc4f(255, 255, 255, 255))
    tempParticle:setEndColor(ccc4f(0, 0, 0, 0))
    tempParticle:setEndColorVar(ccc4f(0, 0, 0, 0))
    tempParticle:setStartSize(44.0)
    tempParticle:setStartSizeVar(1)
    tempParticle:setSpeed(380)
    tempParticle:setSpeedVar(180)
    tempParticle:setAutoRemoveOnFinish(true)
    parentNode:addChild(tempParticle)

    return tempParticle
end

return Particle