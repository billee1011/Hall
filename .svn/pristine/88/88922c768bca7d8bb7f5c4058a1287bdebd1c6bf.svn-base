require("CocosExtern")
require("FFSelftools/controltools")

local Resources = require("bull/Resources")

local BaseArmatureLayer = class("BaseArmatureLayer", function()
    return CCLayer:create()
end)

function BaseArmatureLayer:onEnter()
    self:initUI()
end

function BaseArmatureLayer:onExit()
    if self.m_mature then
        self.m_mature:getAnimation():stop()
        self.m_mature = nil
    end
end

function BaseArmatureLayer:init(armatureName,nWithIndex, onMatureFinshCallback,frameClickCallBack)
    self.m_armatureName = armatureName
    self.m_nWithIndex = nWithIndex
    self.m_onMatureFinshCallback = onMatureFinshCallback
    self.m_frameClickCallBack = frameClickCallBack
    local function onNodeEvent(event)
        if event =="enter" then
            self:onEnter()
        elseif event =="exit" then
            self:onExit()
        end        
    end
    self:registerScriptHandler(onNodeEvent)
end

function BaseArmatureLayer:initUI()
    local winSize = CCDirector:sharedDirector():getWinSize()
    self.m_mature= CCArmature:create(self.m_armatureName)
    self.m_mature:getAnimation():playWithIndex(self.m_nWithIndex)
    self.m_mature:setPosition(ccp(winSize.width/2,winSize.height/2))
    self:addChild(self.m_mature)
    local function animationMovementEvent(armature, movementType, movementID)
        if movementType == 1 or movementType == 2 then
            if self.m_onMatureFinshCallback then
                self.m_onMatureFinshCallback()
            end
            armature:getAnimation():stop()
            armature:setVisible(false)
        end
    end
    local function  animationFrameEvent(bone, frameEventName, originFrameIndex, currentFrameIndex)
        if frameEventName == "click" or frameEventName == "open" or  frameEventName == "exit" then
            if self.m_frameClickCallBack then
                self.m_frameClickCallBack(frameEventName)
            end
        end
    end
    self.m_mature:getAnimation():setFrameEventCallFunc(animationFrameEvent)
    self.m_mature:getAnimation():setMovementEventCallFunc(animationMovementEvent)
end

function BaseArmatureLayer:getMature()
    return self.m_mature
end


function BaseArmatureLayer.create(armatureName,nWithIndex,onMatureFinshCallback,frameClickCallBack)
    local baseArmatureLayer = BaseArmatureLayer.new()
    baseArmatureLayer:init(armatureName, nWithIndex,onMatureFinshCallback,frameClickCallBack)
    return baseArmatureLayer
end

return BaseArmatureLayer
