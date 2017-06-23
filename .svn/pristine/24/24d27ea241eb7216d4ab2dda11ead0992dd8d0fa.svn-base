--LayerGameRecord.lua
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")
local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")

local LayerGameRecord=class("LayerGameRecord",function(super, zindex)
    return require("Lobby/LayerPopup").put(super, zindex)
end)

function LayerGameRecord:initPanel()
    self.btn_zIndex = self.layer_zIndex + 1
    
    --添加背景
    self.bgsz = CCSizeMake(AppConfig.SCREEN.CONFIG_WIDTH, AppConfig.SCREEN.CONFIG_HEIGHT-100)
    self:addFrameBg("common/popBg.png", self.bgsz)
    self.panel_bg:setPositionY(self.panel_bg:getPositionY() - 50)
    self.panel_bg.bgsz = self.bgsz

    --标题
    local gamesConfig = require("Lobby/FriendGame/FriendGameLogic").games_config
    local defaultGame = nil
    self.panel_bg.gameTitle = {}

    for i,v in ipairs(gamesConfig.games) do
        if v ~= gamesConfig.unopened then
            self.panel_bg.gameTitle[v] = CCButton.put(self.panel_bg, CCButton.createCCButtonByFrameName("gamerule/btnGame"..v.."Rule1.png", 
                    "gamerule/btnGame"..v.."Rule2.png", "gamerule/btnGame"..v.."Rule2.png", function()
                        if gamesConfig.names[v] then
                            self:loadRecorder(v, gamesConfig.names[v][2])
                        end
                    end), ccp(self.bg_sz.width / 2 - 620 + 250 * i, self.bg_sz.height+30), self.btn_zIndex)
            --if AppConfig.ISAPPLE and v ~= 12 then
            --    self.panel_bg.gameTitle[v]:setVisible(false)
            --end
        end
        if i == 1 then defaultGame = v end
    end

    --返回按钮 
    CCButton.put(self.panel_bg, CCButton.createCCButtonByFrameName("common/btnReturn.png", 
            "common/btnReturn2.png", "common/btnReturn.png", function()
                self:hide()
            end), ccp(66, 650), self.btn_zIndex)
    --隐藏关闭按钮
    self.close_btn:setVisible(false)

    --if not AppConfig.ISAPPLE then
        CCButton.put(self.panel_bg, CCButton.createCCButtonByFrameName("lobbyDlg/btn_checkothers1.png", 
                "lobbyDlg/btn_checkothers2.png", "lobbyDlg/btn_checkothers1.png", function()
                    self:inputBatchKey()
                end), ccp(AppConfig.SCREEN.CONFIG_WIDTH - 130, 565), self.btn_zIndex)
    --elseif self.panel_bg.gameTitle[12] then
    --    self.panel_bg.gameTitle[12]:setPositionX(AppConfig.SCREEN.CONFIG_WIDTH/2)
    --end
    
    -- 容器
    self.panel = CCLayerColor:create(ccc4(0, 0, 0, 0),self.panel_bg.bgsz.width,self.panel_bg.bgsz.height)
    self.panel.bgsz = self.panel_bg.bgsz
    self.panel_bg:addChild(self.panel, self.btn_zIndex)
    
    if defaultGame then
        self:loadRecorder(defaultGame, gamesConfig.names[defaultGame][2])
    end
    
    self.bSelected = false --是否正在操作，尚未返回
end

-- 获取记录数据
function LayerGameRecord:loadRecorder(idx, gamename)    
    --cclog("LayerGameRecord:loadRecorder  "..idx.." : "..gamename)
    if idx ~= self.selectGame then
        self:initPage(idx, gamename)
    end
end

-- 动态创建界面
function LayerGameRecord:initPage(idx, gameName)
    if self.bSelected then return end
    self.bSelected = true

    --cclog("LayerGameRecord:initPage")
    self.selectGame = idx
    self.selectGameName = gameName
    -- 更改页签状态
    for k, v in pairs(self.panel_bg.gameTitle) do
        if k == self.selectGame then
            v:setChecked(true)
        else
            v:setChecked(false)
        end
    end

    local tipPanel
    local function updataRecord()
        -- 创建内容
        self.panel:removeAllChildrenWithCleanup(true)
        tipPanel = require("Lobby/LayerPopup").createTipBtn("获取战绩信息失败，", 
                updataRecord, kCCMenuHandlerPriority - self.btn_zIndex - 1, self.panel)
        tipPanel:setVisible(false)

        local HallUtils = require("HallUtils")
        if HallUtils.isFileExit(gameName .. "/LayerDeskRecord.lua") or 
            HallUtils.isFileExit("Games/"..gameName .. "/LayerDeskRecord.lua") then
                require(self.selectGameName.."/LayerDeskRecord").putRecord(self.panel, self.layer_zIndex + 1,
                    function(bSucceed)
                        --获取战绩成功回调
                        if bSucceed then
                            tipPanel:removeFromParentAndCleanup(true)
                        else
                            tipPanel:setVisible(true)
                        end

                        self.bSelected = false
                    end)
        else
            tipPanel:setVisible(true)
            HallUtils.showWebTip("请前往创建房间界面下载"..FriendGameLogic.games_config.names[idx][1].."游戏后，方可查看战绩")
        end
    end

    updataRecord()
end

function LayerGameRecord:inputBatchKey()
    local function hide()
        self.batch_panel:removeFromParentAndCleanup(true)
        self.batch_panel = nil
    end

    local sz = CCSizeMake(600, 360)
    self.batch_panel = require("Lobby/Common/LobbySecondDlg").putTip(self.panel_bg, self.btn_zIndex + 1, "", 
                            function() 
                                local playStr = self.batch_panel.panel_bg.editText:getText()
                                --直接输入，设播放吗为666666
                                LayerGameRecord.playVideo(playStr, 666666)
                                hide()
                            end, 
                            function() hide() end, nil, sz)

    self.batch_panel:addAddedLab("查看回放", sz.height - 60, 44, kCCTextAlignmentCenter)

    --添加回放输入框
    self.batch_panel.panel_bg.editText = require("Lobby/Common/LobbyEditBox").createMaxWidthEdit(
            CCSizeMake(350, 52), loadSprite("common/input.png", true),
            ccp((sz.width - 350) / 2, sz.height / 2 + 10), 
            kCCMenuHandlerPriority - self.btn_zIndex - 2, "请输入回放码")
            :setEditFont(AppConfig.COLOR.FONT_ARIAL, 24, AppConfig.COLOR.MyInfo_Record_Label)   
    self.batch_panel.panel_bg:addChild(self.batch_panel.panel_bg.editText) 

    self.batch_panel:show()
end

function LayerGameRecord.playVideo(playStr, inviteCode)
    local playcode = tonumber(playStr)
    if playcode and playStr == ""..playcode then
        FriendGameLogic.getGamePlayRecord(playcode, "", function(gamedata, gameid)
            local HallUtils = require("HallUtils")
            local gameName = FriendGameLogic.games_config.names[gameid][2]
            if HallUtils.isFileExit(gameName .. "/GamePlayLogic.lua") or 
                HallUtils.isFileExit("Games/"..gameName .. "/GamePlayLogic.lua") then
                if inviteCode then
                    FriendGameLogic.invite_code = inviteCode
                end

                FriendGameLogic.game_id = gameid or FriendGameLogic.game_id
                require(gameName .. "/GamePlayLogic"):getInstance():replaceMainScence(gamedata)                
            else
                HallUtils.showWebTip("请前往创建游戏界面下载"..FriendGameLogic.games_config.names[gameid][1].."，方可查看")
            end
        end)        
    end 
end

function LayerGameRecord.put(super, zindex)
    local layer = LayerGameRecord.new(super, zindex)
    layer:initPanel()
    return layer
end

return LayerGameRecord