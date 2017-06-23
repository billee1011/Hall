--LayerDeskRule.lua
local LayerDeskRule=class("LayerDeskRule",function()
        return CCLayer:create()
    end)

local AppConfig = require("AppConfig")
local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")


function LayerDeskRule:init(backfunc)
    local InviteInfo = require("k510/Game/Common").InviteInfo
    FriendGameLogic.getFriendTableRule(10, function(bSucceed)
        backfunc(bSucceed)
        
        if bSucceed then
            self.data_index = FriendGameLogic.readDeskRule() or {1, 1, 2, 2, 1, 1, 2, 2}
            if #self.data_index ~= 8 then self.data_index = {1, 1, 2, 2, 1, 1, 2, 2} end
            self:initDaimondRule() 
            self:initGameRule()
            self:updataDiamondTTf()
        end
    end, InviteInfo.Game_ID)
end

function LayerDeskRule:initDaimondRule()
    --二层背景
    local panelBg = loadSprite("common/popBorder.png", true)
    panelBg:setPreferredSize(CCSizeMake(270, 440))
    panelBg:setPosition(ccp(1060, 455))
    self:addChild(panelBg) 

    local function addTipTtf(pos, ftsz, ancpos, tip)
        local labItem = CCLabelTTF:create(tip, AppConfig.COLOR.FONT_BLACK, ftsz)
        labItem:setColor(AppConfig.COLOR.MyInfo_Record_Label)        
        labItem:setHorizontalAlignment(kCCTextAlignmentLeft)
        labItem:setAnchorPoint(ancpos)
        labItem:setPosition(pos)
        panelBg:addChild(labItem)

        return labItem
    end


    --支付方式
    addTipTtf(ccp(20, 400), 36, ccp(0, 0.5), "支付方式：")
    local fourLab = addTipTtf(ccp(20, 330), 32, ccp(0, 0.5), "3人支付")
    addTipTtf(ccp(20, 250), 32, ccp(0, 0.5), "1人支付")
    local fourBtn, oneBtn
    --选择按钮
    fourBtn = self.layer_super:addCheckBox("", "", ccp(240, 330), panelBg, self.layer_zIndex,
                            function(index, markSp)
                                oneBtn:getChildByTag(10):setVisible(false)
                                markSp:setVisible(true) 
                                FriendGameLogic.pay_type = 60
                                self:updataDiamondTTf()
                            end, FriendGameLogic.pay_type ~= 50)
    oneBtn = self.layer_super:addCheckBox("", "", ccp(240, 250), panelBg, self.layer_zIndex,
                            function(index, markSp)                                 
                                fourBtn:getChildByTag(10):setVisible(false)
                                markSp:setVisible(true) 
                                FriendGameLogic.pay_type = 50 
                                self:updataDiamondTTf() end, FriendGameLogic.pay_type == 50)

    addTipTtf(ccp(20, 170), 26, ccp(0, 0.5), "所需钻石")
    addTipTtf(ccp(20, 100), 26, ccp(0, 0.5), "剩余钻石")
    local daimondTtf, tips = {}, {"", ""..require("Lobby/Login/LoginLogic").UserInfo.DiamondAmount}

    for i = 1, 2 do
        local pos = ccp(170, 240 - 70 * i)

        local tifmark = loadSprite("gamerule/blackBg.png", true)
        tifmark:setPreferredSize(CCSizeMake(80, 42))
        tifmark:setPosition(pos)
        panelBg:addChild(tifmark)

        local labItem = CCLabelTTF:create(tips[i], AppConfig.COLOR.FONT_BLACK, 26)
        labItem:setPosition(pos)
        panelBg:addChild(labItem)

        local daimondmark = loadSprite("common/diamond.png")
        daimondmark:setPosition(ccp(240, pos.y))
        daimondmark:setScale(0.8)
        panelBg:addChild(daimondmark)

        table.insert(daimondTtf, labItem)
    end

    self.diamond_lab = daimondTtf[1]

    addTipTtf(ccp(140, 30), 30, ccp(0.5, 0.5), "底分：1")

    --提示信息
    local tipmsg = CCLabelTTF:create(AppConfig.TIPTEXT.Tip_FriendDiamond_Msg_New, AppConfig.COLOR.FONT_BLACK, 18)      
    tipmsg:setPosition(ccp(140, -130))
    tipmsg:setColor(ccc3(250,55,55))
    panelBg:addChild(tipmsg)
end

function LayerDeskRule:initGameRule()
    local HallUtils = require("HallUtils")
    --二层背景
    local panelBg = loadSprite("common/popBorder.png", true)
    panelBg:setPreferredSize(CCSizeMake(905, 588))
    panelBg:setPosition(ccp(462, 380))
    self:addChild(panelBg) 
    
    -- 二层页签

    local countConfig = FriendGameLogic.game_rule.count

    --标题
    local items, tips = {}, {"局数：", "炸弹类型：", "最大连对：", "可选："}
    for i,v in ipairs(tips) do
        local tipsp = CCLabelTTF:create(v, AppConfig.COLOR.FONT_BLACK, 35)
        tipsp:setColor(AppConfig.COLOR.MyInfo_Record_Label)

        local item = self.layer_super:addCommonItem(tipsp, panelBg, i+1)
        item:setPosition(ccp(2, 590 - 90 * i))
        table.insert(items, item)
    end

    self.round_group, self.bomb_group, self.straight_group = {}, {}, {}
    local poses, nNumber, nNumber2 = {ccp(190, 45), ccp(470, 45), ccp(720, 45)}, self.data_index[1], self.data_index[2]
    local msgs = {{}, {"四张","四带一"}, {"KKAA最大", "AA22最大"}}
    local tips = {{"",""}, {"将不存在四带一的牌型","将不存在四张相同这种牌型"}, {"AA22是最小连对", "连对最大不能到2"}}
    
    for i,v in ipairs(countConfig) do table.insert(msgs[1], v.."局") end
    
    --局数
    self.layer_super:addCheckGroup(msgs[1], tips[1], poses, items[1], self.layer_zIndex, self.round_group, 
        function(index)
            self.data_index[1] = index
            self:updataDiamondTTf()
        end, nNumber) 

    --炸弹类型
    self.layer_super:addCheckGroup(msgs[2], tips[2], poses, items[2], self.layer_zIndex, self.bomb_group, 
        function(index)
            self.data_index[2] = index
        end, nNumber2)

	--最大连对类型
	self.layer_super:addCheckGroup(msgs[3], tips[3], poses, items[3], self.layer_zIndex, self.straight_group, 
	function(index)
		self.data_index[3] = index
	end, nNumber2)

    --显示牌数
    self.layer_super:addCheckBox("显示牌数", "显示玩家当前剩余手牌数", poses[1], items[4], self.layer_zIndex,
        function(index)
            self.data_index[4] = index + 1
        end, self.data_index[4] > 1)

    --切牌
    self.switchPai = self.layer_super:addCheckBox("可切牌", "游戏开始前可以切牌", poses[2], items[4], self.layer_zIndex,
        function(index)
            self.data_index[5] = index + 1
        end, self.data_index[5] > 1)
        
    --[[
            
    --允许顺过
    self.allowPass = self.layer_super:addCheckBox("允许顺过", "手牌剩三带N牌型时，\n只要三张相同牌点数大\n于上家，牌数少也可以\n管上上家打出的三带N", poses[2], items[3], self.layer_zIndex,
        function(index)
            --self.data_index[5] = index + 1 
            HallUtils.showWebTip("即将开放")
            self.allowPass:getChildByTag(10):setVisible(false)
        end, self.data_index[5] > 1)

    --允许三带两对
    self.allowTriAndTwoDouble = self.layer_super:addCheckBox("三带两对", "3张点数相同的牌可以\n带2个对子打出", poses[3], items[3], self.layer_zIndex,
        function(index)
            --self.data_index[6] = index + 1
            HallUtils.showWebTip("即将开放")
            self.allowTriAndTwoDouble:getChildByTag(10):setVisible(false)
        end, self.data_index[6] > 1)
    ]]
    
end


function LayerDeskRule:updataDiamondTTf()
    if self.data_index[1] then
        -- 局数选择值
        local cKey = FriendGameLogic.game_rule.count[self.data_index[1]]
        -- 支付模式选择值
        local pKey = FriendGameLogic.pay_type == 60 and "mult" or "single"
        -- 玩法(飘)选择值
        --local rKey = self.data_index[7]
        
        -- 价格配置
        local priceConfig = FriendGameLogic.game_rule.price[cKey][pKey]
        -- 基础价格
        local basePrice = priceConfig.base
        -- 玩法附加价格(1为无玩法-不漂)
        --local addonPrice = rKey ~= 1 and priceConfig["r"..rKey-1] or 0
        -- 如果没有玩法附加价格定义则默认为0
        --addonPrice = addonPrice or 0
        -- 最终价格(单人需消耗的钻石)
        local price = basePrice-- + addonPrice
        self.diamond_lab:setString(tostring(price))
    end
end

--获取游戏规则
function LayerDeskRule:getGameRule()
    ccTimeStart = C2dxEx:getTickCount()
    ccTimeAllStart = C2dxEx:getTickCount()
    cc2file("[%s] 开始创建房间", C2dxEx:getTickCount())
    
    -- 客户端钻石数量判断
    local diamond = tonumber(self.diamond_lab:getString())
    if require("Lobby/Login/LoginLogic").UserInfo.DiamondAmount < diamond then
        local hall_layer = require("LobbyControl").hall_layer
        if hall_layer then
            require("Lobby/Common/LobbySecondDlg").putTip(
                hall_layer, 10, AppConfig.TIPTEXT.Tip_Diamond_Tip,
                function() hall_layer:returnMainPanle(function() hall_layer:showStorePanel() end) end,
                function() end
            ):show()
        end
        return
    end
    
    --[[ 需要传递的参数
        1:局数 2, 10
        2:炸弹类型 2222, 22221
        3:最大连对    kk11 1122
        4:显示牌数          0否 1是
		5:切牌              0不切 1切牌
        --5:允许顺过          0否 1是
        --6:允许三带两对      0否 1是
    ]]
    local t = FriendGameLogic.game_rule.count
	
    FriendGameLogic.my_rule = {}
    for i = 1, #self.data_index do
        if i < 2 then
            table.insert(FriendGameLogic.my_rule, {i, t[self.data_index[i]]})
        elseif i < 4 then
			table.insert(FriendGameLogic.my_rule, {i, self.data_index[i]})
		else
            table.insert(FriendGameLogic.my_rule, {i, self.data_index[i]-1})
        end
    end
    -- table.print(FriendGameLogic.my_rule)
    FriendGameLogic.writeDeskRule(self.data_index)
    FriendGameLogic.enterGameRoom()
end

function LayerDeskRule.getInviteMsg()
    local Common = require("k510/Game/Common")
    local InviteInfo = require("k510/Game/Common").InviteInfo
    
    local roominfo = require("cjson").encode({InviteCode = FriendGameLogic.invite_code, GameID = InviteInfo.Game_ID})

    local title = string.format("（房间号：%s）%s@你", tostring(FriendGameLogic.invite_code), InviteInfo.Game_Name)
    
    local msg = "【房主付费】"
    
    if FriendGameLogic.pay_type == 60 then msg = "【多人支付】" end
    
    msg = msg .. string.format("%s局",tostring(FriendGameLogic.my_rule[1][2]))
        
    if FriendGameLogic.my_rule[4][2] == 0 then msg = msg .. "，不显示牌数" end
    
    if FriendGameLogic.my_rule[2][2] == 2 then msg = msg .. "，炸弹四带一" end
    
    if FriendGameLogic.my_rule[3][2] == 2 then msg = msg .. "，AA22最大" end
    
    if FriendGameLogic.my_rule[5][2] == 1 then msg = msg .. "，可切牌" end
    
    msg = msg .. "，快来切磋一下吧！"
    
    --局数
    return msg, title, roominfo
end


function LayerDeskRule.getRuleMsg()
    local Common = require("k510/Game/Common")
    local InviteInfo = require("k510/Game/Common").InviteInfo
    
    local msg = string.format("房间号：%s\n%s：", tostring(FriendGameLogic.invite_code), InviteInfo.Game_Name)
    
    msg = msg .. string.format("%s/%s局",
        tostring(FriendGameLogic.game_used), tostring(FriendGameLogic.my_rule[1][2]))
        
    if FriendGameLogic.my_rule[4][2] == 0 then msg = msg .. "，不显示牌数" end
    
    if FriendGameLogic.my_rule[2][2] == 2 then msg = msg .. "，炸弹四带一" end
    
    if FriendGameLogic.my_rule[3][2] == 2 then msg = msg .. "，AA22最大" end
    
    if FriendGameLogic.my_rule[5][2] == 1 then msg = msg .. "，可切牌" end
    
    return msg
end

function LayerDeskRule.put(super, zindex, backfunc)
    local layer = LayerDeskRule.new()
    layer.layer_zIndex = zindex
    layer.layer_super = super
    super.panel_bg:addChild(layer, zindex)
    layer:setPosition(ccp(20, -50))

    layer:init(backfunc)
    return layer
end

 return LayerDeskRule