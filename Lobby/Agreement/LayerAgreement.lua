--LayerAgreement.lua
local AppConfig = require("AppConfig")
local AgreementTxt = require("Lobby/Agreement/Agreement")
local CCButton = require("FFSelftools/CCButton")

local LayerAgreement=class("LayerAgreement",function()
        return CCLayerColor:create(ccc4(0, 0, 0, 175))
    end)

function LayerAgreement:hide() 
    require("Lobby/Common/AnimationUtil").spriteScaleHideAction(self.panel_bg, function()
        self:setVisible(false)
        self:setTouchEnabled(false)
        agreementPanel = nil
    end, 1)
end

function LayerAgreement:show()
    self:setVisible(true)
    require("Lobby/Common/AnimationUtil").spriteScaleShowAction(self.panel_bg, function()
        self:setTouchEnabled(true)
    end, 1)
    return self    
end

function LayerAgreement:init()
    local sWidth, sHeight =  AppConfig.SCREEN.CONFIG_WIDTH,  AppConfig.SCREEN.CONFIG_HEIGHT
    local screenMidx, screenMidy = sWidth/ 2, sHeight/ 2
    
    self.btn_zIndex = 1
    self.panel_zIndex = 2
    self.bgSize = CCSizeMake(sWidth-40, sHeight-40)
    
    self.panel_bg = CCLayer:create()
    self:addChild(self.panel_bg)
    
    -- 背景框
    local bg = loadSprite("common/popBg.png", true)
    bg:setPreferredSize(self.bgSize)
    bg:setPosition(ccp(screenMidx, screenMidy))
    self.panel_bg:addChild(bg, kCCMenuHandlerPriority - self.panel_zIndex)
    
    -- 滚动窗口
    local scrollSz = CCSizeMake(self.bgSize.width-80, self.bgSize.height-80)
    local scroll =  require("Lobby/Common/LobbyScrollView").createCommonScroll(
        scrollSz, ccp((sWidth-scrollSz.width)/2, (sHeight-scrollSz.height)/2), kCCMenuHandlerPriority - self.btn_zIndex - 1)
    scroll:setTouchPriority(kCCMenuHandlerPriority - self.layer_zIndex - 1)
    self.panel_bg:addChild(scroll)

    for k, v in ipairs(AgreementTxt) do
        local ttfLab = CCLabelTTF:create(v, AppConfig.COLOR.FONT_ARIAL, 16)
        ttfLab:setHorizontalAlignment(kCCTextAlignmentLeft)
        ttfLab:setDimensions(CCSizeMake(scrollSz.width-20, 0))
        ttfLab:setAnchorPoint(ccp(0, 0))
        ttfLab:setColor(ccc3(74, 25, 8))
        if k == 1 then -- 标题
            ttfLab:setFontSize(32)
            ttfLab:setHorizontalAlignment(kCCTextAlignmentCenter)
        end
        scroll:addCommonScrollItemBottom(ttfLab)
    end
    scroll:resetCommonScroll()
    
    -- 关闭按钮
    local btn_close = CCControlButton:create(loadSprite("common/btnClose.png", true))
    btn_close:setPreferredSize(CCSizeMake(69,70))
    btn_close:setPosition(ccp(sWidth-36, sHeight-36))
    btn_close:setTouchPriority(kCCMenuHandlerPriority - self.layer_zIndex - 1)
    btn_close:addHandleOfControlEvent(function(sender)
            self:hide()
    end, CCControlEventTouchUpInside)
    self.panel_bg:addChild(btn_close)
    self.btn_close = btn_close
    
    -- 同意按钮
    local btn_agree = CCControlButton:create(
        CCLabelTTF:create("同意用户协议", AppConfig.COLOR.FONT_ARIAL, 24),
        loadSprite("common/btnNOBg1.png", true)
    )
    btn_agree:setTitleColorForState(
        ccc3(255,255,255),
        CCControlStateHighlighted
    )
    btn_agree:setPreferredSize(CCSizeMake(200,55))
    btn_agree:setPosition(ccp(sWidth/2, 36))
    btn_agree:setTouchPriority(kCCMenuHandlerPriority - self.layer_zIndex - 1)
    btn_agree:addHandleOfControlEvent(function(sender)
        CCUserDefault:sharedUserDefault():setStringForKey("agree", "agree")
        self:hide()
    end, CCControlEventTouchUpInside)
    btn_agree.timer = 10
    btn_agree:setVisible(false)
    btn_agree:setEnabled(false)
    self.panel_bg:addChild(btn_agree)
    self.btn_agree = btn_agree
    
    
    -- 注册事件
    self:registerScriptTouchHandler(function(eventType, x, y)
        if eventType == "began" then
            return true
        end
    end, false, kCCMenuHandlerPriority - self.layer_zIndex, true)
end

function LayerAgreement.put(super, zindex)
    layerAgreeMent = LayerAgreement.new(zindex)
    layerAgreeMent.layer_zIndex = zindex
    layerAgreeMent:init()
    super:addChild(layerAgreeMent, zindex)
    return layerAgreeMent
end

return LayerAgreement