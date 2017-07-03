require("CocosExtern")

local Resources = require("k510/Resources")

local LoadingLayer = class("LoadingLayer", function ()
return (CCLayerColor:create(ccc4(0, 0, 0, 0), 800, 480))
end)


function LoadingLayer:init()
    
    self.winSize = CCSizeMake(require("k510/GameDefs").CommonInfo.View_Width, require("k510/GameDefs").CommonInfo.View_Height)


    self.loading_icon = nil
    self.loading_rotateSp = nil

    self.m_fOverTime = 15

    local function update(dt)
        if (self.m_fOverTime > 0) then
            self.m_fOverTime = self.m_fOverTime - dt
        end
        
        if(self.m_fOverTime <= 0) then
            self:removeFromParentAndCleanup(true)
        end

    end
    self:scheduleUpdateWithPriorityLua(update, 1)
end

function LoadingLayer:onExit()

end

function LoadingLayer:onEnter()
    local winSize = CCDirector:sharedDirector():getWinSize()
    
    self.loading_icon = loadSprite("loading/loading_icon.png")
    self.loading_icon:setPosition(ccp(winSize.width*0.5, winSize.height*0.5))
    self:addChild(self.loading_icon)

    self.loading_rotateSp = loadSprite("loading/loading_circle.png")
    self.loading_rotateSp:setPosition(ccp(winSize.width*0.5, winSize.height*0.5))
    self:addChild(self.loading_rotateSp)

    self.loading_rotateSp:runAction(CCRepeatForever:create(CCRotateBy:create(1,180)))
end



function LoadingLayer.create()
   
    local layer = LoadingLayer:new()

    if (nil == layer) then
        return nil
    end
    --LoadingLayer.this = layer
    -- myGMLayer = layer

    layer:init()

    local function onNodeEvent(event)
        if event == "enter" then
            layer:onEnter()
        elseif event == "exit" then
            layer:onExit()
        end
    end


    layer:registerScriptHandler(onNodeEvent)
    layer:setTag(Resources.Tag.LOADING_LAYER_TAG)
    return layer
end

function LoadingLayer.ShowLoadingLayer()
    if(CCDirector:sharedDirector():getRunningScene():getChildByTag(Resources.Tag.LOADING_LAYER_TAG) == nil) then
        local layer = LoadingLayer.create()
        CCDirector:sharedDirector():getRunningScene():addChild(layer)
    else
        self.m_fOverTime = 15
    end

end

function LoadingLayer.HideLoadingLayer()
     if(CCDirector:sharedDirector():getRunningScene():getChildByTag(Resources.Tag.LOADING_LAYER_TAG) ~= nil) then
       
        CCDirector:sharedDirector():getRunningScene():removeChildByTag(Resources.Tag.LOADING_LAYER_TAG, true)
    end
end

return LoadingLayer