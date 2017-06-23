require("CocosExtern")
require("FFSelftools/controltools")

local Resources = require("bull/Resources")

local AnimationButton = class("AnimationButton", function()
    return CCLayer:create()
end)

function AnimationButton:onEnter()
    self:initUI()
end

function AnimationButton:onExit()
    if self.m_mature then
        self.m_mature:getAnimation():stop()
        self.m_mature = nil
    end
end

function AnimationButton:init(btnBgFilePath, armatureActionName, tag, onControlCallback)
    self.m_btnBgFilePath = btnBgFilePath
    self.m_armatureActionName = armatureActionName
    self.m_tag = tag
    self.m_onControlCallback = onControlCallback

    local function onNodeEvent(event)
        if event =="enter" then
            self:onEnter()
        elseif event =="exit" then
            self:onExit()
        end        
    end
    self:registerScriptHandler(onNodeEvent)
end

function AnimationButton:initUI()
    if (self.m_btnBgFilePath == nil) then
        return
    end
    self:setTag(self.m_tag)

    self.m_pBGBtn = createButtonWithFilePath(self.m_btnBgFilePath,self.m_tag,self.m_onControlCallback)
    self.m_pBGBtn:setAnchorPoint(ccp(0.5,0.5))
    self:setContentSize(self.m_pBGBtn:getContentSize())
    self.m_pBGBtn:setPosition(ccp(self:getContentSize().width/2,self:getContentSize().height/2))
    self:addChild(self.m_pBGBtn)

    if self.m_armatureActionName~=nil and self.m_armatureActionName~=""  then
        self.m_mature = CCArmature:create("tesupaixing")
        self.m_mature:getAnimation():play(self.m_armatureActionName)
        self.m_mature:setPosition(ccp(self:getContentSize().width/2,self:getContentSize().height/2))
        self.m_pBGBtn:addChild(self.m_mature)

    end
end

function AnimationButton:setEnabled(bIsEnable)
    if self.m_pBGBtn then
        self.m_pBGBtn:setEnabled(bIsEnable)
    end
end

--调用这个目的是按钮不可见或者可见也要改变骨骼,否则骨骼还在运行
function AnimationButton:setBtnIsVisible(bIsVisble)
    self:setVisible(bIsVisble)
    if self.m_mature then
        if bIsVisble then
            self.m_mature:getAnimation():play(self.m_armatureActionName)
        else
            self.m_mature:getAnimation():stop()
        end 
    end
end


function AnimationButton.create(btnBgFilePath, armatureActionName, tag, onControlCallback)
    local animationButton = AnimationButton.new()
    animationButton:init(btnBgFilePath, armatureActionName, tag, onControlCallback)
    return animationButton
end

return AnimationButton
