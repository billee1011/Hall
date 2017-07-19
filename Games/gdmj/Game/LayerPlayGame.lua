--LayerPlayGame.lua
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")

local LayerPlayGame=class("LayerPlayGame",function()
    return CCLayerColor:create(ccc4(0, 0, 0, 0))
end)

function LayerPlayGame:init(score) 
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true
        end
    end
    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority - self.layer_zIndex,true)
    self:setTouchEnabled(true)
    self.btn_zIndex = self.layer_zIndex + 1

    self:initPlayUI()

    local function onNodeEvent(event)
        if event =="exit" then
            self:stopAllActions()
            cclog("on LayerPlayGame exit")
        end
    end
    self:registerScriptHandler(onNodeEvent)    
end

--播放相关ui
function  LayerPlayGame:initPlayUI()
    local CommonInfo = require("gdmj/GameDefs").CommonInfo

    --背景
    self.play_ui = loadSprite("mjdesk/lobby_gameplay_btnbg_img.png")
    local bgsz = self.play_ui:getContentSize()
    self.play_ui:setPosition(ccp(CommonInfo.View_Width / 2, 240))
    self:addChild(self.play_ui, self.btn_zIndex)

    --上一轮
    self.last_btn = CCButton.put(self.play_ui, CCButton.createCCButtonByFrameName("mjdesk/lobby_gameplay_last_btn1.png", 
            "mjdesk/lobby_gameplay_last_btn2.png", "mjdesk/lobby_gameplay_last_btn2.png", function(tag, target)
                self.is_playlast = true
                self.last_btn:setEnabled(false)
            end), 
            ccp(73, bgsz.height / 2), self.btn_zIndex)    

    --播放
    self.game_play = CCButton.put(self.play_ui, CCButton.createCCButtonByFrameName("mjdesk/lobby_gameplay_play_btn1.png", 
            "mjdesk/lobby_gameplay_play_btn2.png", "mjdesk/lobby_gameplay_play_btn2.png", function(tag, target)
                self.game_stop:setVisible(true)
                self.game_play:setVisible(false)
                self.is_stop = false
            end), 
            ccp(73 + 127, bgsz.height / 2), self.btn_zIndex)
    self.game_play:setVisible(false)
    
    --暂停
    self.game_stop = CCButton.put(self.play_ui, CCButton.createCCButtonByFrameName("mjdesk/lobby_gameplay_stop_btn1.png", 
            "mjdesk/lobby_gameplay_stop_btn2.png", "mjdesk/lobby_gameplay_stop_btn2.png", function(tag, target)
                self.game_stop:setVisible(false)
                self.game_play:setVisible(true)
                self.is_stop = true
            end), 
            ccp(73 + 127, bgsz.height / 2), self.btn_zIndex)    

    --下一轮
    self.next_btn = CCButton.put(self.play_ui, CCButton.createCCButtonByFrameName("mjdesk/lobby_gameplay_nest_btn1.png", 
            "mjdesk/lobby_gameplay_nest_btn2.png", "mjdesk/lobby_gameplay_nest_btn2.png", function(tag, target)
                self.is_playnext = true
                self.next_btn:setEnabled(false)
            end), 
            ccp(73 + 127 + 140, bgsz.height / 2), self.btn_zIndex) 

    --返回
    CCButton.put(self.play_ui, CCButton.createCCButtonByFrameName("mjdesk/lobby_gameplay_return_btn1.png", 
            "mjdesk/lobby_gameplay_return_btn2.png", "mjdesk/lobby_gameplay_return_btn2.png", function(tag, target)
                require("gdmj/GamePlayLogic"):getInstance():dispose()
            end), 
            ccp(73 + 127 + 140 * 2, bgsz.height / 2), self.btn_zIndex) 

    self.is_stop = false
end

function LayerPlayGame:setPlayState(bvalue)
    self.is_playing = bvalue
end

function LayerPlayGame:startCheckStatus()
    local delayTime = 1
    
    local function onCheck()
        if self.is_playing then
            if self.is_playnext then
                require("gdmj/GamePlayLogic"):getInstance():playNext()
                self.is_playnext = false
                self.next_btn:setEnabled(true)
            elseif self.is_playlast then
                require("gdmj/GamePlayLogic"):getInstance():playLast()
                self.is_playlast = false
                self.last_btn:setEnabled(true)
            elseif not self.is_stop then
                require("gdmj/GamePlayLogic"):getInstance():playNextOeprator()
            end
        end

        local array = CCArray:create() 
        array:addObject(CCDelayTime:create(delayTime))     
        array:addObject(CCCallFunc:create(onCheck))
        self:runAction(CCSequence:create(array))
    end

    onCheck()    
end

function LayerPlayGame.put(super, zindex)
    local layer = LayerPlayGame.new()
    layer.layer_zIndex = zindex
    super:addChild(layer, zindex)
    layer:init()
    return layer
end

return LayerPlayGame