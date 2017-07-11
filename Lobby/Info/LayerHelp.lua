--LayerHelp.lua
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")
local loginLogic = require("Lobby/Login/LoginLogic")

require("Cache")

local LayerHelp=class("LayerHelp",function(super, zindex)
    return require("Lobby/LayerPopup").put(super, zindex)
end)

function LayerHelp:init() 
    self.btn_zIndex = self.layer_zIndex + 1
    
    --添加背景
    self.bgsz = CCSizeMake(AppConfig.SCREEN.CONFIG_WIDTH-40, AppConfig.SCREEN.CONFIG_HEIGHT-110)
    self:addFrameBg("help/border1.png", self.bgsz)
    self.panel_bg:setPositionY(self.panel_bg:getPositionY() - 55)
    self.panel_bg.bgsz = self.bgsz
    
    -- 右侧背景
    self.rbg = loadSprite("help/border2.png", true)
    self.rbg.bgsz = CCSizeMake(970,570)
    self.rbg:setPreferredSize(self.rbg.bgsz)
    self.rbg:setPosition(ccp(self.bgsz.width/2+125,self.bgsz.height/2))
    self.panel_bg:addChild(self.rbg)
    -- 容器
    self.panel = CCLayerColor:create(ccc4(0, 0, 0, 0),self.rbg.bgsz.width,self.rbg.bgsz.height)
    self.panel:setPosition(ccp((self.bgsz.width-self.rbg.bgsz.width)/2+125,(self.bgsz.height-self.rbg.bgsz.height)/2))
    self.panel_bg:addChild(self.panel)

    --标题
    local gamesConfig = require("Lobby/FriendGame/FriendGameLogic").games_config
    self.panel_bg.gameTitle = {}

    for i,v in ipairs(gamesConfig.games) do
		if v == 24 then
		        self.panel_bg.gameTitle[v] = CCButton.put(self.panel_bg, CCButton.createCCButtonByFrameName("gamerule/btnGame"..(v-1).."Rule1.png", 
                "gamerule/btnGame"..(v-1).."Rule2.png", "gamerule/btnGame"..(v-1).."Rule2.png", function()
                    self:initPage(v, 1)
                end), ccp(self.bg_sz.width / 2 - 620 + 250 * i, self.bg_sz.height+33), self.btn_zIndex)
		else
		        self.panel_bg.gameTitle[v] = CCButton.put(self.panel_bg, CCButton.createCCButtonByFrameName("gamerule/btnGame"..v.."Rule1.png", 
                "gamerule/btnGame"..v.."Rule2.png", "gamerule/btnGame"..v.."Rule2.png", function()
                    self:initPage(v, 1)
                end), ccp(self.bg_sz.width / 2 - 620 + 250 * i, self.bg_sz.height+33), self.btn_zIndex)
		end

        if v == gamesConfig.unopened then
            local s = loadSprite("gamerule/createRuleMark.png")
            s:setPosition(ccp(80,2))
            self.panel_bg.gameTitle[v]:addChild(s)            
        end
    end
            
    -- 页签
    local ttf = {"help/ttf_rule.png", "help/ttf_create.png", "help/ttf_enter.png", "help/ttf_agent.png"}
    self.panel_bg.opt = {}
    for i = 1, 4 do
        table.insert(self.panel_bg.opt, CCButton.put(self.panel_bg, CCButton.createCCButtonByFrameName("help/btn_selected.png", 
            "help/btn_unselect.png", "help/btn_unselect.png", function()
                self:initPage(self.selectGame, i)
            end), ccp(148, self.bgsz.height-i*105-40), self.btn_zIndex))
        local s = loadSprite(ttf[i])
        s:setPosition(ccp(0,5))
        self.panel_bg.opt[i]:addChild(s)
    end

    --返回按钮 
    CCButton.put(self.panel_bg, CCButton.createCCButtonByFrameName("common/btnReturn.png", 
            "common/btnReturn2.png", "common/btnReturn.png", function()
                Cache.removePlist("help")
                if debugMode then Cache.log("帮助关闭后材质使用内存状况") end
                self:hide()
            end), ccp(46, 650), self.btn_zIndex)
    --隐藏关闭按钮
    self.close_btn:setVisible(false)
    
    --默认选择游戏一
    self:initPage(require("Lobby/FriendGame/FriendGameLogic").games_config.games[1], 1, 0.25)
end

-- 动态创建帮助界面
function LayerHelp:initPage(game, opt, delayTime)
    local d = delayTime or 0
    local utils = require("HallUtils")
    if game == require("Lobby/FriendGame/FriendGameLogic").games_config.unopened then
        utils.showWebTip("即将开放，敬请期待")
        return
    end
    if game ~= self.selectGame or opt ~= self.selectOpt then
        -- 更改页签状态
        self.selectGame = game
        self.selectOpt = opt
        for k, v in pairs(self.panel_bg.gameTitle) do
            if k == self.selectGame then
                v:setChecked(true)
            else
                v:setChecked(false)
            end
        end
        for k, v in pairs(self.panel_bg.opt) do
            if k == self.selectOpt then
                v:setChecked(true)
            else
                v:setChecked(false)
            end
        end
        -- 创建内容
        self.panel:removeAllChildrenWithCleanup(true)
        -- 规则
        if self.selectOpt == 1 then
            local scroll =  require("Lobby/Common/LobbyScrollView").createCommonScroll(
                CCSizeMake(self.rbg.bgsz.width-120, self.rbg.bgsz.height-40), ccp(60, 20), kCCMenuHandlerPriority - self.btn_zIndex)
            self.panel:addChild(scroll)
            scroll.selectGame = self.selectGame
            scroll.itemWidth = self.rbg.bgsz.width-120
            scroll:runAction(CCSequence:createWithTwoActions(
                CCDelayTime:create(d),
                CCCallFuncN:create(LayerHelp.createRuleText)
            ))
        -- 创建
        elseif self.selectOpt == 2 then
            local s = loadSprite("help/image_create.png")
            s:setPosition(ccp(self.rbg.bgsz.width/2, self.rbg.bgsz.height/2))
            self.panel:addChild(s)
        -- 进入
        elseif self.selectOpt == 3 then
            local s = loadSprite("help/image_enter.png")
            s:setPosition(ccp(self.rbg.bgsz.width/2, self.rbg.bgsz.height/2))
            self.panel:addChild(s)
        -- 代理
        elseif self.selectOpt == 4 then
            for i = 3, 5 do
                local t = CCLabelTTF:create(AppConfig.TIPTEXT["Tip_TGCode_Msg"..i], AppConfig.COLOR.FONT_ARIAL, 26)
                t:setColor(AppConfig.COLOR.MyInfo_Record_Label)
                t:setDimensions(CCSizeMake(self.rbg.bgsz.width-120, 0))
                t:setHorizontalAlignment(kCCTextAlignmentLeft)
                t:setAnchorPoint(ccp(0,0.5))
                t:setPosition(ccp(60, self.rbg.bgsz.height - i * 120 + 280))
                self.panel:addChild(t)
            end
            CCButton.put(self.panel, CCButton.createCCButtonByFrameName("help/btn_follow.png", 
            "help/btn_follow2.png", "help/btn_follow.png", function()
                utils.showWebTip("功能尚未开放")
            end), ccp(self.rbg.bgsz.width/2, 80), self.btn_zIndex)
        end
    end
end


function LayerHelp.createRuleText(scroll)
    --local ruleText = require("Lobby/Info/GameRuleText")[scroll.selectGame]
	
	local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
	if scroll.selectGame == FriendGameLogic.games_config.unopened then return  end
	
	local gameName = FriendGameLogic.games_config.names[scroll.selectGame][2]
	local ruleText = require(gameName.."/GameRuleText")
	if ruleText == nil then return end
	
    for k, v in ipairs(ruleText) do
        local ttfLab = CCLabelTTF:create(v[1], AppConfig.COLOR.FONT_ARIAL, v[2])
        ttfLab:setHorizontalAlignment(kCCTextAlignmentLeft)
        ttfLab:setDimensions(CCSizeMake(scroll.itemWidth-40, 0))
        ttfLab:setAnchorPoint(ccp(0, 0))
        ttfLab:setColor(ccc3(74, 25, 8))
        scroll:addCommonScrollItemBottom(ttfLab) 
        local ttfsapce = CCLabelTTF:create(" ", AppConfig.COLOR.FONT_ARIAL, v[2] / 2)
        scroll:addCommonScrollItemBottom(ttfsapce)       
    end
    scroll:resetCommonScroll()
end

function LayerHelp.put(super, zindex)
    Cache.add("help")
    if debugMode then Cache.log("帮助加载完成后材质使用内存状况") end
    local layer = LayerHelp.new(super, zindex)
    layer:init()
    return layer
end

return LayerHelp