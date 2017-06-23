require("CocosExtern")

local Resources = require("bull/Resources")

local TextImgButton = class("TextImgButton", function()
    return CCNode:create()
end)


function TextImgButton:setTouchPriority(nTouchPriority)
    if (self.m_pBGBtn ~= nil) then
        self.m_pBGBtn:setTouchPriority(nTouchPriority)
    end
end

function TextImgButton:init(btnBgFilePath, textFilePath, tag, onControlCallback)
    if (btnBgFilePath == nil) then
        return
    end
    self.m_pBGBtn =  Resources.createButtonTwoStatusWithOneFilePath2(btnBgFilePath, tag, onControlCallback)
    self.m_pBGBtn:setAnchorPoint(ccp(0.5,0.5))
    self:setContentSize(self.m_pBGBtn:getContentSize())
    self.m_pBGBtn:setPosition(ccp(self:getContentSize().width/2,self.m_pBGBtn:getContentSize().height/2))
    self:addChild(self.m_pBGBtn)


    local function controlTouchDown(emptStr,target,event)
        if self.m_pTitleBtn then
            self.m_pTitleBtn:setChecked(true)
        end

        if self.m_pChangeTextBtn then
            self.m_pChangeTextBtn:setChecked(true)
        end
    end

    local function controlDragOutside(emptStr,target,event)
        if self.m_pTitleBtn then
            self.m_pTitleBtn:setChecked(false)
        end

        if self.m_pChangeTextBtn then
            self.m_pChangeTextBtn:setChecked(false)
        end
    end

    local function controlTouchUpInside(emptStr,target,event)
        if self.m_pTitleBtn then
            self.m_pTitleBtn:setChecked(false)
        end

        if self.m_pChangeTextBtn then
            self.m_pChangeTextBtn:setChecked(false)
        end
        onControlCallback(emptStr,target,event)
    end

    if (self.m_pBGBtn ~= nil) then
        if (tag ~= nil) then
            self.m_pBGBtn:setTag(tag)
            self:setTag(tag)
        end
        if (onControlCallback ~= nil) then
            self.m_pBGBtn:addHandleOfControlEvent(controlTouchDown, CCControlEventTouchDown)
            self.m_pBGBtn:addHandleOfControlEvent(controlDragOutside, CCControlEventTouchDragOutside)
            self.m_pBGBtn:addHandleOfControlEvent(controlTouchUpInside,CCControlEventTouchUpInside)
        end
        if (textFilePath ~= nil) then
            self.m_pTitleBtn = Resources.createCheckboxWithSingleFileNormal(textFilePath, 2)
            self.m_pTitleBtn:setPosition(ccp(self.m_pBGBtn:getContentSize().width / 2, self.m_pBGBtn:getContentSize().height/2))
            self.m_pBGBtn:addChild(self.m_pTitleBtn)
        end 
    end
end

function TextImgButton:setEnabled(b)
    if self.m_pBGBtn then
        self.m_pBGBtn:setEnabled(b)
        if b==false then
            if self.m_pTitleBtn then
                self.m_pTitleBtn:setEnabled(b)
                self.m_pTitleBtn:setChecked(true)
            end
        else
            if self.m_pTitleBtn then
                self.m_pTitleBtn:setEnabled(b)
                self.m_pTitleBtn:setChecked(false)
            end
        end
    end
end

function TextImgButton:setColor(color)
     if self.m_pBGBtn then
        self.m_pBGBtn:setColor(color)
    end
end

function TextImgButton:setIsChangeImg(bIsChange)
    if self.m_pChangeTextBtn and self.m_pTitleBtn then
        self.m_pChangeTextBtn:setVisible(bIsChange)
        self.m_pTitleBtn:setVisible(not bIsChange)
    end
end

function TextImgButton:getIsChangeImg()
    if self.m_pChangeTextBtn then
        return self.m_pChangeTextBtn:isVisible()
    end
    return false
end

function TextImgButton:setChangeImgPath(textFilePath)
    if (textFilePath ~= nil) then
        self.m_pChangeTextBtn = Resources.createCheckboxWithSingleFileNormal(textFilePath, 2)
        self.m_pChangeTextBtn:setPosition(ccp(self.m_pBGBtn:getContentSize().width / 2, self.m_pBGBtn:getContentSize().height/2))
        self.m_pChangeTextBtn:setVisible(false)
        self.m_pBGBtn:addChild(self.m_pChangeTextBtn)
    end 
end


function TextImgButton.create(btnBgFilePath, textFilePath, tag, onControlCallback)
    local button = TextImgButton.new()
    button:init(btnBgFilePath, textFilePath, tag, onControlCallback)
    return button
end

return TextImgButton
