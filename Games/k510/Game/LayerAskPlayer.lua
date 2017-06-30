--LayerAskPlayer.lua
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")

local LayerAskPlayer=class("LayerAskPlayer",function(super)
    return CCLayerColor:create(AppConfig.COLOR.ColorLayer_Bg)
end)

function LayerAskPlayer.create(super, askType)
    local layer = LayerAskPlayer.new(super)
    layer:init(askType)
	super:addChild(layer)
    return layer
end

function LayerAskPlayer:hide() 
    require("Lobby/Common/AnimationUtil").spriteScaleHideAction(self.panel_bg, function()
        self:setVisible(false)
        self:setTouchEnabled(false)
        self:removeFromParentAndCleanup(true)
    end, 0.8)
end

function LayerAskPlayer:show() 
    self:setVisible(true)    
    require("Lobby/Common/AnimationUtil").spriteScaleShowAction(self.panel_bg, function()
        self:setTouchEnabled(true)
    end, 0.8)

    return self    
end

function LayerAskPlayer:init(askType)
	local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true
        end
    end

    priority = kCCMenuHandlerPriority - 1
    self:registerScriptTouchHandler(onTouch,false, priority, true)
    self:setTouchEnabled(true)
	
	self.curAskType = askType
	
	self.bg_sz = bgsz or CCSizeMake(480, 320)

    --设置背景
    self.panel_bg = loadSprite("common/popBg.png", true)
    self.panel_bg:setPreferredSize(self.bg_sz)
    self:addChild(self.panel_bg)
    self.panel_bg:setPosition(AppConfig.SCREEN.MID_POS)

	self.text = {"是否要与庄家对战","是否要与上家对战","是否要与庄家对战"}
	--标题
    self.tip_lab = CCLabelTTF:create(self.text[askType], AppConfig.COLOR.FONT_ARIAL, 24)
    self.tip_lab:setColor(ccc3(74, 25, 8))
    self.tip_lab:setPosition(ccp(self.bg_sz.width / 2, self.bg_sz.height / 2 + 60))
    self.tip_lab:setDimensions(CCSizeMake(self.bg_sz.width - 80, 0))
    self.tip_lab:setHorizontalAlignment(kCCTextAlignmentCenter)
    self.panel_bg:addChild(self.tip_lab)
	
	self.time = 10
	--计时
	self.timer_lab = CCLabelTTF:create(tostring(self.time), AppConfig.COLOR.FONT_ARIAL, 24)
    self.timer_lab:setColor(ccc3(74, 25, 8))
    self.timer_lab:setPosition(ccp(self.bg_sz.width / 2, self.bg_sz.height / 2 + 20))
    self.timer_lab:setDimensions(CCSizeMake(self.bg_sz.width - 80, 0))
    self.timer_lab:setHorizontalAlignment(kCCTextAlignmentCenter)
    self.panel_bg:addChild(self.timer_lab)
	self.timer_lab:runAction(CCSequence:createWithTwoActions(CCRepeat:create(CCSequence:createWithTwoActions(
	CCDelayTime:create(1),CCCallFunc:create(function()
				self.time = self.time - 1
				self.timer_lab:setString(tostring(self.time))
		end)),10),CCCallFunc:create(function()
				require("k510/Game/GameLogic"):sendAskPlayerReplay(self.curAskType,0)
				self:hide()
		end)))
	
	--是按钮 
	CCButton.put(self.panel_bg, CCButton.createCCButtonByFrameName("common/btn_agree1.png", 
			"common/btn_agree2.png", "common/btn_agree3.png", function()
			require("k510/Game/GameLogic"):sendAskPlayerReplay(self.curAskType,1)
			self:hide()
			end), ccp(self.bg_sz.width/2 - 100, 68),1)
			
	--否按钮
	CCButton.put(self.panel_bg, CCButton.createCCButtonByFrameName("common/btn_refuce1.png", 
		"common/btn_refuce2.png", "common/btn_refuce3.png", function()
		require("k510/Game/GameLogic"):sendAskPlayerReplay(self.curAskType,0)
		self:hide()
		end),ccp(self.bg_sz.width/2 + 100, 68),1)
end

return LayerAskPlayer