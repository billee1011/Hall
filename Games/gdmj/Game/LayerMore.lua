--LayerMore.lua
local AppConfig = require("AppConfig")
local CommonInfo = require("gdmj/GameDefs").CommonInfo
local CCButton = require("FFSelftools/CCButton")

local LayerMore=class("LayerMore",function()
        return CCLayerColor:create(ccc4(0, 0, 0, 0))
    end)

function LayerMore:hide() 
    self:setVisible(false)
    self:setTouchEnabled(false)

    return self     
end

function LayerMore:show()
    self:setVisible(true)
    self:setTouchEnabled(true)

    return self    
end

function LayerMore:init()
    self.btn_zIndex = self.layer_zIndex + 1   

    --背景
    local panelBg = loadSprite("mjdesk/btnMoreBg.png", true)
    self:addChild(panelBg)
    panelBg:setAnchorPoint(ccp(1, 0.5))
    panelBg:setPosition(ccp(CommonInfo.View_Width, CommonInfo.View_Height / 2))
    panelBg:setPreferredSize(CCSizeMake(216, CommonInfo.View_Height))

    self:initBtns()

    CCButton.put(self, CCButton.createCCButtonByFrameName("mjdesk/btnShowMore1.png", 
            "mjdesk/btnShowMore2.png", "mjdesk/btnShowMore1.png", function()
                    self:hide()
            end), ccp(CommonInfo.View_Width - 50, CommonInfo.View_Height - 50), self.btn_zIndex)    

    local function onTouch(eventType, x, y)
        if eventType == "began" then
            if x < CommonInfo.View_Width - 240 then
                self:hide()
            end
            return true
        end
    end
    self:registerScriptTouchHandler(onTouch,false, kCCMenuHandlerPriority - self.layer_zIndex,true)
    self:setTouchEnabled(true)

    self:hide()
end

function LayerMore:initBtns()    
    local super = self:getParent()

    --规则、设置、解散
    CCButton.put(self, CCButton.createCCButtonByFrameName("mjdesk/btnGameRule1.png", 
                    "mjdesk/btnGameRule2.png", "mjdesk/btnGameRule1.png", function(tag, target) 
                        super:showGameRule() 
                    end), ccp(CommonInfo.View_Width - 85, CommonInfo.View_Height - 140), self.btn_zIndex)

    CCButton.put(self, CCButton.createCCButtonByFrameName("mjdesk/btnGameSet1.png", 
                    "mjdesk/btnGameSet2.png", "mjdesk/btnGameSet1.png", function(tag, target) 
                        super:showGameSet() 
                    end), ccp(CommonInfo.View_Width - 85, CommonInfo.View_Height - 230), self.btn_zIndex)

    self.game_dismiss = CCButton.put(self, CCButton.createCCButtonByFrameName("mjdesk/btnDismissGame1.png", 
                    "mjdesk/btnDismissGame2.png", "mjdesk/btnDismissGame1.png", function(tag, target) 
                        super:showGameDismiss() 
                    end), ccp(CommonInfo.View_Width - 85, CommonInfo.View_Height - 320), self.btn_zIndex)
    self.game_dismiss:setVisible(false)    
end

function LayerMore.put(super, zindex)
    local layer = LayerMore.new()
    layer.layer_zIndex = zindex
    super:addChild(layer, zindex)
    layer:init()
    return layer, layer.game_dismiss
end

return LayerMore