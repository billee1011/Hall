require("CocosExtern")
local MessageLayer = class("MessageLayer", function()
    local winsize=CCDirector:sharedDirector():getWinSize()
    return CCLayerColor:create(ccc4(0, 0, 0, 0),winsize.width,winsize.height)
end)


function MessageLayer:init(msg, ftsz, pos, secs)

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            self:removeFromParentAndCleanup(true)
            self = nil
            return true
        elseif eventType == "ended" then
            --
        end    
    end
    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority-1,true)
    self:setTouchEnabled(true)

    local winsize=CCDirector:sharedDirector():getWinSize()
    ftsz = ftsz or 30

    local pLabelMsg=CCLabelTTF:create(msg, "Arial", ftsz)
    pLabelMsg:setAnchorPoint(ccp(0.5,0.5))

    local bgLayer =CCLayerColor:create(ccc4(0,0,0,100),pLabelMsg:getContentSize().width*1.1,pLabelMsg:getContentSize().height*1.3)

    pos = pos or ccp(winsize.width / 2, winsize.height / 2)
    pos = ccp(pos.x - bgLayer:getContentSize().width / 2, pos.y)
    bgLayer:setPosition(pos)
    bgLayer:setAnchorPoint(ccp(0.5,0.5))
    pLabelMsg:setPosition(ccp(bgLayer:getContentSize().width*0.5,bgLayer:getContentSize().height*0.5))
    
    bgLayer:addChild(pLabelMsg)
    self:addChild(bgLayer)
      
    local function onDelayClose()
        self:removeFromParentAndCleanup(true)
    end
    secs = secs or 3
    performWithDelay(self,onDelayClose, secs)    
end

function MessageLayer.create(msg, ftsz, pos, secs)    
    local layer = MessageLayer.new()
    layer:init(msg, ftsz, pos, secs)
    
    return layer
end

return MessageLayer