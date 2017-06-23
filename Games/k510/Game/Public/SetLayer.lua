--LayerGameSet.lua
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")
local CCCheckbox = require("FFSelftools/CCCheckbox")
local SetLogic = require("Lobby/Set/SetLogic")

local LayerGameSet=class("LayerGameSet",function(super, zindex)
    return require("Lobby/Set/LayerSet").new(super, zindex)
end)

function LayerGameSet:hide(func) 
    require("Lobby/Common/AnimationUtil").spriteScaleHideAction(self.panel_bg, function()
        self:setVisible(false)
        self:setTouchEnabled(false)
        local SetLogic = require("Lobby/Set/SetLogic")
        local Logic = require("czmj/Game/GameLogic"):getInstance()
        SetLogic.saveSet()
        
        if func then
            func()
        end
        
        self:removeFromParentAndCleanup(true)
    end, 0.8)
end

function LayerGameSet:show() 
    self:setVisible(true)    
    require("Lobby/Common/AnimationUtil").spriteScaleShowAction(self.panel_bg, function()
        self:setTouchEnabled(true)
        if show_func then
            self.show_func()
        end
    end, 0.8)

    return self    
end


function LayerGameSet:addLanguageCheck(super, poses) 
    local titleImg = {"common/ttf_language.png", "common/ttf_ptlanguage.png", "common/ttf_czlanguage.png"}
    self:createItemTitle(super, titleImg, poses)

    poses = {ccp(poses[2].x - 85, poses[2].y), ccp(poses[3].x - 85, poses[3].y)}

    local index = SetLogic.getGameCheckByIndex(3)
    self:addRadioTypeBtn(super, poses, index, function(cbtype)
        SetLogic.setGameCheckByIndex(3, cbtype)
    end)
end

function LayerGameSet:initCustom()
    self.bgsz = CCSizeMake(786, 465)

    self:addPanelBg("common/popBg.png", self.bgsz)
    self.panel_bg:setPositionY(self.panel_bg:getPositionY() - 20)
    --设置标题
    local title = loadSprite("common/title_setup.png")
    title:setPosition(ccp(self.bg_sz.width / 2, self.bg_sz.height + 20))
    self.panel_bg:addChild(title)
    
    -- 分割线
    for i = 1, 3 do
        local line = loadSprite("common/horizLine.png")
        line:setPosition(ccp(self.bgsz.width/2, 100 * i + 45))
        line:setScaleX((self.bgsz.width-80)/line:getContentSize().width)
        self.panel_bg:addChild(line)
    end
    
    -- 提示文字
    local tip = CCLabelTTF:create("", AppConfig.COLOR.FONT_ARIAL, 24)
    tip:setColor(ccc3(255,0,0))
    tip:setPosition(ccp(self.bgsz.width / 2, 42))
    self.panel_bg:addChild(tip)
    self.tip = tip

    -- 音乐设置
    self:addMusicCheck(self.panel_bg, {ccp(100, 390), ccp(100, 290)})
    
    -- 震动设置
    self:addShakeCheck(self.panel_bg, ccp(100, 190)) 
    
    -- 设置语言
    self:addLanguageCheck(self.panel_bg, {ccp(100, 90),ccp(285, 90),ccp(655, 90)})
end

function LayerGameSet.create(super, zindex)
    local layer = LayerGameSet.new(super, zindex)
    layer:initCustom()
    return layer
end

return LayerGameSet