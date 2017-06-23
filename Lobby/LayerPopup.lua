--LayerPopup.lua
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")

local LayerPopup=class("LayerPopup",function()
    return CCLayerColor:create(AppConfig.COLOR.ColorLayer_Bg)
end)

function LayerPopup:hide(func) 
    self:returnLobby()
    
    require("Lobby/Common/AnimationUtil").spriteScaleHideAction(self.panel_bg, function()
        self:setVisible(false)
        self:setTouchEnabled(false)
        self:removeFromParentAndCleanup(true)
        if func then
            func()
        end       
        --self.close_func()
    end)
end

function LayerPopup:show() 
    if self:isVisible() then
        return
    end
    if self.panel_bg then
        self:setVisible(true)    
        require("Lobby/Common/AnimationUtil").spriteScaleShowAction(self.panel_bg, function()
            self:setTouchEnabled(true)
            if show_func then
                self.show_func()
            end
        end)
    end
    return self    
end

function LayerPopup:init() 
    self.btn_zIndex = self.layer_zIndex + 1   

    local function onTouch(eventType, x, y)
    if eventType == "began" then
        return true
    end
    end
    self:registerScriptTouchHandler(onTouch,false, kCCMenuHandlerPriority - self.layer_zIndex,true)
    self:setTouchEnabled(true)
    self:setVisible(false)
end

function LayerPopup:addPanelBg(bgImg, bgSz) 
    self.panel_bg = loadSprite(bgImg, true)
    self.bg_sz = bgSz
    self:initPanelBg()
end

function LayerPopup:addFrameBg(bgImg, bgSz) 
    self:addPanelBg(bgImg, bgSz) 
    --[[
    local frameBg = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(bgImg) 
    self.panel_bg = loadSprite(bgImg, true)
    self.bg_sz = bgSz
    self:initPanelBg()
    ]]
end

function LayerPopup:initPanelBg()
    self:addChild(self.panel_bg)
    self.panel_bg:setPreferredSize(self.bg_sz)

    self.panel_bg:setPosition(ccp(AppConfig.SCREEN.CONFIG_WIDTH/ 2, AppConfig.SCREEN.CONFIG_HEIGHT / 2))

    --关闭按钮 
    self.close_btn = CCButton.put(self.panel_bg, CCButton.createCCButtonByFrameName("common/btnClose.png", 
            "common/btnClose2.png", "common/btnClose.png", function()
                    self:hide()
            end), ccp(self.bg_sz.width - 20, self.bg_sz.height - 20), self.btn_zIndex)    
end

--创建刷新按钮
function LayerPopup.createTipBtn(text, func, z, parent)
    local panel = CCLayer:create()
    local screenMidx = AppConfig.SCREEN.CONFIG_WIDTH/ 2
    local screenMidy = AppConfig.SCREEN.CONFIG_HEIGHT/ 2
    parent:addChild(panel)

    --提示文字
    local ttfTip = CCLabelTTF:create(text, AppConfig.COLOR.FONT_BLACK, 30)
    ttfTip:setPosition(ccp(screenMidx, screenMidy))
    ttfTip:setAnchorPoint(ccp(1, 0.5))
    ttfTip:setColor(ccc3(74, 25, 8))
    panel:addChild(ttfTip)

    --文字按钮
    local btnSprite = {}
    for i=1,3 do
        local ttfLab = CCLabelTTF:create("点击重新获取", AppConfig.COLOR.FONT_BLACK, 30)
        local width = ttfLab:getContentSize().width
        local oneLab = CCLabelTTF:create("_", AppConfig.COLOR.FONT_ARIAL, 32)
        local lineLab = CCLabelTTF:create(string.rep("_", width / oneLab:getContentSize().width), 
                                                AppConfig.COLOR.FONT_ARIAL, 32)
        lineLab:setPosition(ccp(width*0.5, 15))
        lineLab:setColor(ccc3(0x63, 0xB8, 0xFF)) 
        ttfLab:addChild(lineLab)
        ttfLab:setColor(ccc3(0x63, 0xB8, 0xFF))

        if i == 2 then ttfLab:setScale(1.1) end

        table.insert(btnSprite, ttfLab)
    end
    local ttfItem = CCButton.createCCButtonByStatusSprite(btnSprite[1], btnSprite[2], btnSprite[3],func)
    ttfItem:setPosition(ccp(screenMidx, screenMidy))
    ttfItem:setAnchorPoint(ccp(0, 0.5))
    ttfItem:resetTouchPriorty(z, true)
    panel:addChild(ttfItem)

    return panel
end

function LayerPopup:returnLobby()
    self:getParent().current_panel = nil
    self:getParent():getParent().current_panel = nil
end

function LayerPopup.put(super, zindex)
    local layer = LayerPopup.new()
    super:addChild(layer, zindex)
    layer.layer_zIndex = zindex

    layer:init()
    return layer
end

return LayerPopup