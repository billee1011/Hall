
 require "GameLib/common/PropertyInfo"
 local Resources = require("bull/Resources")
 local SoundRes = require("bull/SoundRes")

 local PropertyAnimationLayer =class("PropertyAnimationLayer", function()
                                                             return CCLayer:create()
                                                             end
                                                             ) 

PropertyAnimationLayer.m_startPoint=ccp(0,0)
PropertyAnimationLayer.m_endPoint=ccp(0,0)
PropertyAnimationLayer.m_nPropertyId=10

function PropertyAnimationLayer:init()

    self.m_startPoint=ccp(0,0)
    self.m_endPoint=ccp(0,0)
    self.m_nPropertyId=10
end


function PropertyAnimationLayer:initUI()

   

    if(self.m_nPropertyId<=0) then
        return
    end

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("bull/bullResources/DeskScene/property/eggAnimate/eggAnimate.plist")
    
    --PropertyInfo
    local GameLibSink =require("bull/GameLibSink")
    local pVect=GameLibSink.m_gameLib:getSystemProperties()
    local nSize = #pVect

    for i=1, nSize, 1 do
    
        if(self.m_nPropertyId ==pVect[i].nPropertyID) then
            self.m_nPropertyId = i
            break
        end
    end
    
    if(self.m_nPropertyId>6) then
        return 
    end
    local str=string.format("bull/bullResources/DeskScene/property/egg_item_%d.png",self.m_nPropertyId)
 
    local pEggItemSp=CCSprite:create(str)
    pEggItemSp:setScale(1.3)
  
    -- local nDisX=105+20 --//图片大小的一半210
    -- local nDisY=60
    local nDisX=80
    local nDisY=80
    -- if(self.m_endPoint.x>500) then
    --     nDisX=105
    --     nDisY=60+20
    -- end
    

    pEggItemSp:setPosition(ccp(self.m_startPoint.x+nDisX,self.m_startPoint.y+nDisY))
    local moveTo=CCMoveTo:create(0.5, ccp(self.m_endPoint.x+nDisX,self.m_endPoint.y+nDisY))

    local function _animateCallFunc()
        self:animateCallFunc()
    end

    local callFunc=CCCallFunc:create(_animateCallFunc)

    local pSeq =nil
    local actionArr = CCArray:create()
    if(self.m_nPropertyId==1 or self.m_nPropertyId==3 or self.m_nPropertyId==4) then
    
        local pRotate = CCRotateBy:create(0.5,360)
        actionArr:addObject(CCSpawn:createWithTwoActions(moveTo,pRotate))
        actionArr:addObject(CCRemoveSelf:create(true))
        actionArr:addObject(callFunc)
        pSeq =CCSequence:create(actionArr)
    
    else
        actionArr:addObject(moveTo)
        actionArr:addObject(CCRemoveSelf:create(true))
        actionArr:addObject(callFunc)
        pSeq=CCSequence:create(actionArr)
    end
    pEggItemSp:runAction(pSeq)
    self:addChild(pEggItemSp)
    
    local eggEffect=
    {
        SoundRes.SOUND_JIDANG,SoundRes.SOUND_MEIGUI,SoundRes.SOUND_CHUIZI,SoundRes.SOUND_BAOZAI,SoundRes.SOUND_BEIZI
    }

    SoundRes.playGlobalEffect(eggEffect[self.m_nPropertyId])

    cclog("PropertyAnimationLayer:initUI() end")
end

function PropertyAnimationLayer:onEnter()

    self:initUI()
end

function PropertyAnimationLayer:onExit()
    self:removeAllChildrenWithCleanup(true)
end


function PropertyAnimationLayer:animateCallFunc()

    local  nItemFrameNum={11,17,5,16,5}
    local strArrName={"egg_item_%d.png","flower_item_%d.png","hammer_item_%d.png","explor_item_%d.png","beer_item_%d.png"}
    
    local str =string.format(strArrName[self.m_nPropertyId],1)
    
    local pEggItemSp=CCSprite:createWithSpriteFrameName(str)
    pEggItemSp:setAnchorPoint(ccp(0,0))
    
    local nDisX=-20
    local nDisY=10
    
    pEggItemSp:setPosition(ccp(self.m_endPoint.x+nDisX,self.m_endPoint.y+nDisY))
    self:addChild(pEggItemSp)
    
    local pAnimation = CCAnimation:create()
    for  i=1, nItemFrameNum[self.m_nPropertyId], 1 do
        str =string.format(strArrName[self.m_nPropertyId],i)
        pAnimation:addSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(str))
    end
    pAnimation:setDelayPerUnit(0.15)
    local pAnimate=CCAnimate:create(pAnimation)
    local function _reMoveParentCallFunc()
         self:reMoveParentCallFunc()
    end
    local callFunc=CCCallFunc:create(_reMoveParentCallFunc)
    local actionA =CCArray:create()
    actionA:addObject(pAnimate)
    actionA:addObject(CCRemoveSelf:create(true))
    actionA:addObject(callFunc)
    pEggItemSp:runAction(CCSequence:create(actionA))
    
end

function  PropertyAnimationLayer:reMoveParentCallFunc()
    self:removeFromParentAndCleanup(true)
end

function PropertyAnimationLayer:setProperty(startPoint, endPoint, nPropertyId)

    self.m_startPoint =startPoint
    self.m_endPoint = endPoint
    self.m_nPropertyId =nPropertyId
end

function PropertyAnimationLayer.createPropertyAnimationLayerLayer()
   local propertyAnimationLayer = PropertyAnimationLayer.new()
  
   if propertyAnimationLayer==nil then
      return nil
   end
  
  local function onNodeEvent(event)
     if event =="enter" then
        propertyAnimationLayer:onEnter()
     elseif event =="exit" then
        propertyAnimationLayer:onExit()
     end        
  end
  propertyAnimationLayer:init()
  propertyAnimationLayer:registerScriptHandler(onNodeEvent)
  return propertyAnimationLayer
end

return  PropertyAnimationLayer


