--LayerMoreBtn.lua
local CCButton = require("FFSelftools/CCButton")

local LayerMoreBtn =class("LayerMoreBtn", function()
        return CCLayer:create()
        end)
function LayerMoreBtn:showLayer(isShow)  
	self:setVisible(isShow)
	self.Button_SysSet:setVisible(isShow)
	self.Button_Rule:setVisible(isShow)
	self.Button_Dismiss:setVisible(isShow)
	self.More_Bg:setVisible(isShow)
	
	self.isShow = isShow
	
	self:setTouchEnabled(isShow)
end
function LayerMoreBtn:init()
    --按钮背景
	local winSize =CCDirector:sharedDirector():getWinSize()
	local PreferredWidht,PreferredHeight= 360,70
    local More_Bg = loadSprite("bull/btnMoreBg.png", true)
	More_Bg:setAnchorPoint(ccp(0,0.5))
    More_Bg:setPosition(761,winSize.height - 48)
    self:addChild(More_Bg) 
    More_Bg:setVisible(false)	
--	More_Bg:setPreferredSize(CCSizeMake(PreferredWidht,PreferredHeight))	
	self.More_Bg = More_Bg   
	
		--更多按钮
--[[	self.moreBtn =  CCButton.createWithFrame("public/btn_more1.png",false,function()
		--local layerMoreBtn = require("bull/common/LayerMoreBtn").create(self.m_gameScene,10,self.moreBtn)
		self:showLayer(not self.isShow)
	end)
    self.moreBtn:setPosition(41, PreferredHeight - 130)
     self.More_Bg:addChild(self.moreBtn,1)
	self.moreBtn.setVisible(true)]]
	cclog("LayerMoreBtn:init()")
	-- 设置按钮
    local Button_SysSet = CCButton.createWithFrame("public/anniu_shezhi.png",false,function()
		require("bull/common/LayerGameSet").put(require("bull/GameLibSink").sDeskLayer, 200):show()
	end)
    Button_SysSet:setPosition(115, 50)
    self.More_Bg:addChild(Button_SysSet,1)
    self.Button_SysSet = Button_SysSet
    self.Button_SysSet:resetTouchPriorty(kCCMenuHandlerPriority - self.layer_zindex - 1, true)
	
    -- 规则按钮
    local Button_Rule = CCButton.createWithFrame("public/anniu_guize.png",false,function()
		require("bull/common/LayerGameRule").put(require("bull/GameLibSink").sDeskLayer, 200):show()
	end)
    Button_Rule:setPosition(195, 50)
    self.More_Bg:addChild(Button_Rule,1)
    self.Button_Rule = Button_Rule
	self.Button_Rule:resetTouchPriorty(kCCMenuHandlerPriority - self.layer_zindex - 1, true)

    local Button_Dismiss = CCButton.createWithFrame("public/anniu_jiesan.png",false,function()
		local f = require("Lobby/FriendGame/FriendGameLogic")
		local	GameLibSink = require("bull/GameLibSink")
        if  f.game_abled == true or (GameLibSink.game_lib:getMyDBID() == GameLibSink.openTableUserID) then
           f.showDismissTipDlg(CCDirector:sharedDirector():getRunningScene(),100,	GameLibSink)
        else
            require("HallUtils").showWebTip("游戏未开始时，非房主不能解散房间")
			cclog("Button_Dismiss")
        end
	end)
    Button_Dismiss:setPosition(275, 50)
    self.More_Bg:addChild(Button_Dismiss,1)
    self.Button_Dismiss = Button_Dismiss
	
	self.Button_Dismiss:resetTouchPriorty(kCCMenuHandlerPriority - self.layer_zindex - 1, true)
	
	local function onNodeEvent(event)
        if event == "enter" then	
 
        elseif event =="exit" then
			self:showLayer(false)
			LayerMoreBtn.instance = nil
			cclog("LayerMoreBtn exit")
        end 
    end
	local function onTouch(eventType, x, y)
        if eventType == "began" then
            if not self.More_Bg:boundingBox():containsPoint(self.More_Bg:getParent():convertToNodeSpace(ccp(x,y))) then
                self:showLayer(false)
				return false
            end
			if x > 774 and x < 844 then
				--self:showLayer(false)
				return false
			end
            return true
        end
    end
	self:registerScriptHandler(onNodeEvent)
    self:registerScriptTouchHandler(onTouch,false, kCCMenuHandlerPriority - self.layer_zindex,true)
	self:showLayer(false)
end
function LayerMoreBtn.create(super, zindex)
	if(LayerMoreBtn.instance == nil) then
		
		local layer = LayerMoreBtn.new()	
		layer.super = super
		layer.layer_zindex = zindex
		layer.isShow = false
	
		
		layer:init()
		super:addChild(layer,zindex)		
		LayerMoreBtn.instance = layer
	end
	return LayerMoreBtn.instance
end

return LayerMoreBtn