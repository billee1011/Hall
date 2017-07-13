--ReplayLayer.lua
local AppConfig = require("AppConfig")
local CommonInfo = require("k510/GameDefs").CommonInfo
local CCButton = require("FFSelftools/CCButton")

local ReplayLayer=class("ReplayLayer",function()
    return CCLayerColor:create(ccc4(0, 0, 0, 0))
end)

function ReplayLayer:init() 
    local CommonInfo = require("czmj/GameDefs").CommonInfo

    --背景
    self.play_ui = loadSprite("ui/lobby_gameplay_btnbg_img.png")
    local bgsz = self.play_ui:getContentSize()
    self.play_ui:setPosition(ccp(CommonInfo.View_Width / 2, 60))
    self:addChild(self.play_ui)

    --上一轮
    self.last_btn = CCButton.put(self.play_ui, CCButton.createCCButtonByFrameName("ui/lobby_gameplay_last_btn1.png", 
            "ui/lobby_gameplay_last_btn2.png", "ui/lobby_gameplay_last_btn1.png", function(tag, target)
                local layer = self:getParent()
                layer.replayStepBack(layer)
                self.timer = 0
            end), 
            ccp(73, bgsz.height / 2), 99)    

    --播放
    self.game_play = CCButton.put(self.play_ui, CCButton.createCCButtonByFrameName("ui/lobby_gameplay_play_btn1.png", 
            "ui/lobby_gameplay_play_btn2.png", "ui/lobby_gameplay_play_btn1.png", function(tag, target)
                self.game_stop:setVisible(true)
                self.game_play:setVisible(false)
                self.timer = 99
                self.isPlaying = true
            end), 
            ccp(73 + 127, bgsz.height / 2), 99)
    self.game_play:setVisible(false)
    
    --暂停
    self.game_stop = CCButton.put(self.play_ui, CCButton.createCCButtonByFrameName("ui/lobby_gameplay_stop_btn1.png", 
            "ui/lobby_gameplay_stop_btn2.png", "ui/lobby_gameplay_stop_btn1.png", function(tag, target)
                self.game_stop:setVisible(false)
                self.game_play:setVisible(true)
                self.isPlaying = false
            end), 
            ccp(73 + 127, bgsz.height / 2), 99)    

    --下一轮
    self.next_btn = CCButton.put(self.play_ui, CCButton.createCCButtonByFrameName("ui/lobby_gameplay_nest_btn1.png", 
            "ui/lobby_gameplay_nest_btn2.png", "ui/lobby_gameplay_nest_btn1.png", function(tag, target)
                local layer = self:getParent()
                self.timer = 99
                layer.replayOnStep(layer, true)
            end), 
            ccp(73 + 127 + 140, bgsz.height / 2), 99) 

    --返回
    CCButton.put(self.play_ui, CCButton.createCCButtonByFrameName("ui/lobby_gameplay_return_btn1.png", 
            "ui/lobby_gameplay_return_btn2.png", "ui/lobby_gameplay_return_btn1.png", function(tag, target)
                self.isPlaying = false
                require("k510/GamePlayLogic"):getInstance():dispose()
            end), 
            ccp(73 + 127 + 140 * 2, bgsz.height / 2), 99)
end

function ReplayLayer.create(super, zindex)
    local layer = ReplayLayer.new()
    layer:init()
    return layer
end

return ReplayLayer