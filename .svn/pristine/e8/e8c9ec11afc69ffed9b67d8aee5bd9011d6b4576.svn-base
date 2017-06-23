--LayerNotice.lua
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")

local LayerNotice=class("LayerNotice",function(super, zindex)
    return require("Lobby/LayerPopup").put(super, zindex)
end)

function LayerNotice:init(typ, data)
    self.btn_zIndex = self.layer_zIndex + 1
    if typ == 1 then
        self.bg_sz = data:getContentSize()
        self.panel_bg = data
        self:addChild(self.panel_bg)
        self.panel_bg:setPosition(ccp(AppConfig.SCREEN.CONFIG_WIDTH/ 2, AppConfig.SCREEN.CONFIG_HEIGHT / 2))
        --关闭按钮 
        self.close_btn = CCButton.put(self.panel_bg, CCButton.createCCButtonByFrameName("common/btnClose.png", 
                "common/btnClose2.png", "common/btnClose.png", function()
                        self:hide()
                end), ccp(self.bg_sz.width - 10, self.bg_sz.height - 10), self.btn_zIndex)
    elseif typ == 2 then
        self.bgsz = CCSizeMake(AppConfig.SCREEN.CONFIG_WIDTH*0.7, AppConfig.SCREEN.CONFIG_HEIGHT*0.7)
        self:addFrameBg("common/popBg.png", self.bgsz)
        self.panel_bg:setPositionY(self.panel_bg:getPositionY() - 20)

        --标题
        self.panel_bg.title = loadSprite("lobby/title_notice.png")
        self.panel_bg.title:setPosition(ccp(self.bg_sz.width / 2, self.bg_sz.height+20))
        self.panel_bg:addChild(self.panel_bg.title)

        --确定按钮 
        CCButton.put(self.panel_bg, CCButton.createCCButtonByFrameName("common/common_dlg_okbtn1.png", 
                "common/common_dlg_okbtn2.png", "common/common_dlg_okbtn1.png", 
                function() self:hide() end), ccp(self.bg_sz.width/2, 60), self.btn_zIndex)
        --隐藏关闭按钮
        self.close_btn:setVisible(false)

        -- 滚动窗口
        self.panel_bg.scroll =  require("Lobby/Common/LobbyScrollView").createCommonScroll(
            CCSizeMake(self.bgsz.width-80, self.bgsz.height-120), ccp(40, 80), kCCMenuHandlerPriority - self.btn_zIndex)
        self.panel_bg.scroll:setTouchPriority(kCCMenuHandlerPriority - self.btn_zIndex)
        self.panel_bg:addChild(self.panel_bg.scroll)

        self.panel_bg.scroll.tip_lab = CCLabelTTF:create(data, AppConfig.COLOR.FONT_ARIAL, 24)
        self.panel_bg.scroll.tip_lab:setColor(ccc3(74, 25, 8))
        self.panel_bg.scroll.tip_lab:setDimensions(CCSizeMake(self.bg_sz.width - 80, 0))
        self.panel_bg.scroll.tip_lab:setHorizontalAlignment(kCCTextAlignmentLeft)

        self.panel_bg.scroll.tip_lab:setAnchorPoint(0, 0)
        self.panel_bg.scroll:addCommonScrollItem(self.panel_bg.scroll.tip_lab)
        self.panel_bg.scroll:resetCommonScroll()
    end
end

function LayerNotice:updataMsg()
    require("LobbyControl").getPlatformMessage(1, function(data)
        self.tip_panel:removeFromParentAndCleanup(true)

        local msg = data[1].MsgContent

        msg = require("HallUtils").textDataStr(msg, 2)
        self.panel_bg.scroll.tip_lab:setString(msg)
     
        self.panel_bg.scroll:resetCommonScrollHeight(self.panel_bg.scroll.tip_lab:getContentSize().height)
        self.panel_bg.scroll:resetCommonScroll()        
    end)
end

function LayerNotice.put(super, zindex, typ, data)
    local layer = {}
    function layer:show() end
    if super then
        layer = LayerNotice.new(super, zindex)
        layer:init(typ, data)
    end
    return layer
end

return LayerNotice