--LayerRecordDetail.lua
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")
local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")

local LayerRecordDetail=class("LayerRecordDetail",function(super, zindex)
    return require("Lobby/LayerPopup").put(super, zindex)
end)

function LayerRecordDetail:initPanel(data)
    self.btn_zIndex = self.layer_zIndex + 1
    
    --添加背景
    self.bgsz = CCSizeMake(AppConfig.SCREEN.CONFIG_WIDTH, AppConfig.SCREEN.CONFIG_HEIGHT-100)
    self:addFrameBg("common/popBg.png", self.bgsz)
    self.panel_bg:setPositionY(self.panel_bg:getPositionY() - 50)
    self.panel_bg.bgsz = self.bgsz

    --标题
    self.panel_bg.title = loadSprite("lobbyDlg/title_roomrecorder.png")
    self.panel_bg.title:setPosition(ccp(self.bgsz.width / 2, self.bgsz.height+20))
    self.panel_bg:addChild(self.panel_bg.title)  
    

    --颜色背景
    local colorbg =  loadSprite("lobbyDlg/recorderBorder.png", true)
    self.panel_bg:addChild(colorbg)
    colorbg:setPreferredSize(CCSizeMake(self.bgsz.width-100, self.bgsz.height-120))
    colorbg:setPosition(ccp(self.bg_sz.width / 2, self.bg_sz.height / 2 - 30))
    

    --返回按钮 
    CCButton.put(self.panel_bg, CCButton.createCCButtonByFrameName("common/btnReturn.png", 
            "common/btnReturn2.png", "common/btnReturn.png", function()
                self:hide()
            end), ccp(66, 650), self.btn_zIndex)
    --隐藏关闭按钮
    self.close_btn:setVisible(false)

    local gameName = require("Lobby/FriendGame/FriendGameLogic").games_config.names[FriendGameLogic.game_id][2]
    require(gameName.."/LayerDeskRecord").putDetail(self.panel_bg, self.layer_zIndex + 1, data)
end

function LayerRecordDetail.put(super, zindex, data)
    local layer = LayerRecordDetail.new(super, zindex)
    layer:initPanel(data)
    return layer
end

return LayerRecordDetail