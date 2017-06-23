--LayerDeskRule.lua
local LayerDeskRule=class("LayerDeskRule",function()
        return CCLayer:create()
    end)

local AppConfig = require("AppConfig")
local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")


function LayerDeskRule:init(backfunc) 
    local gameId = CCUserDefault:sharedUserDefault():getIntegerForKey("CZMJ_GameId")
    gameId = (gameId == 0) and 12 or gameId
    FriendGameLogic.getFriendTableRule(10, function(bSucceed)
        backfunc(bSucceed)

        if bSucceed then
            self.game_rule = {}
            self.game_rule[gameId] = FriendGameLogic.game_rule
    	
            self.data_index = FriendGameLogic.readDeskRule() or {1, 1, 3, 2, 2, 1, 1}
            self.desk_index = self.data_index[1]
             
            --新增规则
            for i=6,7 do
                self.data_index[i] = self.data_index[i] or 1
            end

            self:initDaimondRule(gameId) 
            self:initGameRule() 

            self.gameId = gameId
        end
    end, gameId)                     
end

function LayerDeskRule:initDaimondRule(gameId)
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

    local tipPay = "3人支付"
    if gameId == 12 then tipPay = "4人支付" end
    
    --支付方式
    addTipTtf(ccp(20, 400), 36, ccp(0, 0.5), "支付方式：")
    local fourLab = addTipTtf(ccp(20, 330), 32, ccp(0, 0.5), tipPay)
    addTipTtf(ccp(20, 250), 32, ccp(0, 0.5), "1人支付")
    local fourBtn, oneBtn
    --选择按钮
    fourBtn = self.layer_super:addCheckBox("", "", ccp(240, 330), panelBg, self.layer_zIndex,
                            function(index, markSp) 
                                oneBtn:getChildByTag(10):setVisible(false)
                                markSp:setVisible(true) 
                                FriendGameLogic.pay_type = 60
                                self:updataDiamondTTf() end, FriendGameLogic.pay_type ~= 50)
    oneBtn = self.layer_super:addCheckBox("", "", ccp(240, 250), panelBg, self.layer_zIndex,
                            function(index, markSp)                                 
                                fourBtn:getChildByTag(10):setVisible(false)
                                markSp:setVisible(true) 
                                FriendGameLogic.pay_type = 50 
                                self:updataDiamondTTf() end, FriendGameLogic.pay_type == 50)

    addTipTtf(ccp(20, 170), 26, ccp(0, 0.5), "所需钻石")
    addTipTtf(ccp(20, 100), 26, ccp(0, 0.5), "剩余钻石")
    local daimondTtf, tips = {}, {"", ""..require("Lobby/Login/LoginLogic").UserInfo.DiamondAmount}

    for i=1,2 do
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
    --二层背景
    local panelBg = loadSprite("common/popBorder.png", true)
    panelBg:setPreferredSize(CCSizeMake(905, 588))
    panelBg:setPosition(ccp(462, 380))
    self:addChild(panelBg) 

    --局数、玩法、可选
    local items, tips, item, lineSp = {}, {"局数：", "玩法：", "", "", ""}
    for i,v in ipairs(tips) do
        local tipsp = CCLabelTTF:create(v, AppConfig.COLOR.FONT_BLACK, 40)
        tipsp:setColor(AppConfig.COLOR.MyInfo_Record_Label)

        item, lineSp = self.layer_super:addCommonItem(tipsp, panelBg, i+1)
        item:setPosition(ccp(2, 590 - 90 * i))
        table.insert(items, item)
    end

    --局数
    local countConfig = FriendGameLogic.game_rule.count
    local msgs = {{}, {}}
    local tips = {{}, {}}
    for i,v in ipairs(countConfig) do
        table.insert(msgs[1], v.."局")
        table.insert(tips[1], "")
    end
    --局数
    local uis, poses, nNumber = {}, {ccp(170, 45), ccp(450, 45), ccp(700, 45)}, self.data_index[1]
    self.layer_super:addCheckGroup(msgs[1], tips[1], poses, items[1], self.layer_zIndex, uis, 
                function(index)
                    self:updataDiamondTTf(index)                    
                end, nNumber)  

    --人数玩法
    self.player_group = {}
    self.player_last = self.data_index[7]
    self.layer_super:addCheckGroup({"4人游戏", "3人游戏"}, {"", ""}, {poses[1], poses[2]}, items[2], self.layer_zIndex, self.player_group, 
                function(index) 
                    self:changeGameType(index)
                end, self.data_index[7])
    
    --飞鸟
    msgs[2] = {"抓飞鸟", "抓159鸟", "抓六鸟"}
    tips[2] = {"抓1张牌，2-9万筒条对\n应得2-9分。1万筒条或\n红中得10分", "抓4张牌，159鸟为中\n鸟，一个鸟1分", "抓6张牌，根据胡的牌\n点数147/258/369各一\n组，一个鸟1分。\n红中自摸为全中"}
    local birdposes = {ccp(170, 45), ccp(700, 45), ccp(450, 45)}
    self.bird_group = {}
    self.layer_super:addCheckGroup(msgs[2], tips[2], birdposes, items[5], self.layer_zIndex, self.bird_group, 
                function(index) self.data_index[2] = index end, self.data_index[2])    

    --[[self.layer_super:addCheckGroup({msgs[2][3]}, {poses[1]}, items[3], self.layer_zIndex, self.bird_group, 
                function(index) self.data_index[2] = index end) 
    self.bird_group[3]:setVisible(false)]]

    --红中赖子
    self.zhong_group = {}
    table.insert(self.zhong_group, 
        self.layer_super:addCheckBox("红中赖子", "红中是万能牌，不能碰、\n杠和打出。四个红中直接\n胡牌", poses[1], items[3], self.layer_zIndex,
                function(index)
                    self.data_index[3] = index + 1 
                    if index == 0 then
                        self.zhong_group[2]:getChildByTag(10):setVisible(false)
                    end
                end, self.data_index[3] > 1))
    table.insert(self.zhong_group, 
        self.layer_super:addCheckBox("无红中加倍", "胡牌如自己手牌中无红\n中，胡牌底分加倍", poses[2], items[3], self.layer_zIndex,
                function(index) 
                    if index == 1 then
                        self.data_index[3] = 3
                        self.zhong_group[1]:getChildByTag(10):setVisible(true)
                    else
                        self.data_index[3] = 2
                    end
                end, self.data_index[3] > 2))

    self.layer_super:addCheckBox("有大胡", "胡牌时牌型为清一色、\n碰碰胡、七对", poses[1], items[4], self.layer_zIndex,
                                function(index) self.data_index[4] = index + 1 end, self.data_index[4] > 1)

    self.layer_super:addCheckBox("只能自摸", "", poses[3], items[3], self.layer_zIndex,
                                function(index) self.data_index[6] = index + 1 end, self.data_index[6] > 1)

    --飘
    self.piao_group = {}
    table.insert(self.piao_group, self.layer_super:addCheckBox("飘5分", "第二局可以选择不飘或\n飘1、3、5分", poses[2], items[4], self.layer_zIndex,
                                function(index) self:onBtnPiao(index, 1) end, self.data_index[5] == 2))
    table.insert(self.piao_group, self.layer_super:addCheckBox("飘3分", "第二局可以选择不飘或\n飘1、2、3分", poses[3], items[4], self.layer_zIndex,
                                function(index) self:onBtnPiao(index, 2) end, self.data_index[5] == 3))
				
end

function LayerDeskRule:onBtnZhong(index) 
    local bCheck = self.zhong_group[2]:getChildByTag(10):isVisible()
    self.zhong_group[2]:setVisible(index ~= 0)
    --self.bird_group[3]:setVisible(index == 0)
    self.data_index[3] = index + 1

    if index == 1 and bCheck then
        self.data_index[3] = 3
        --self.bird_group[1].m_actionCallBack(self.bird_group[1]:getTag(), self.bird_group[1])
    end    
end

function LayerDeskRule:onBtnPiao(index, uiIndex) 
    self.data_index[5] = 1
    for i=1,2 do
        local mark = self.piao_group[i]:getChildByTag(10)
        mark:setVisible(false)

        if index > 0 and uiIndex == i then
            mark:setVisible(true)
            self.data_index[5] = uiIndex + 1
        end
    end   
end


function LayerDeskRule:changeGameType(index)
    if self.player_last == index then return end

    --恢复
    local tempbtn = self.player_group[self.player_last]
    tempbtn.m_actionCallBack(tempbtn:getTag(), tempbtn)
    local gameids, dataIndex = {12, 17}, 7
    local gameId = gameids[index]

    --更新
    local function changePlayer()
        self:removeAllChildrenWithCleanup(true)

        self.data_index[dataIndex] = index
        self:initDaimondRule(gameId) 
        self:initGameRule()  

        self.gameId = gameId      
    end

    if self.game_rule[gameId] then
        FriendGameLogic.game_rule = self.game_rule[gameId]
        FriendGameLogic.game_id = gameId
        
        changePlayer()
    else
        FriendGameLogic.getFriendTableRule(10, function(bSucceed)
            if bSucceed then
                self.game_rule[gameId] = FriendGameLogic.game_rule
                changePlayer()
            end
        end, gameId)
    end    
end

function LayerDeskRule:updataDiamondTTf(index)
    --游戏局数
    self.desk_index = index or self.desk_index
    self.data_index[1] = self.desk_index

    -- 局数选择值
    local cKey = FriendGameLogic.game_rule.count[self.data_index[1]]
    -- 支付模式选择值
    local pKey = FriendGameLogic.pay_type == 60 and "mult" or "single"
    -- 玩法(飘)选择值
    local rKey = self.data_index[5]
    
    -- 价格配置
    local priceConfig = FriendGameLogic.game_rule.price[cKey][pKey]
    -- 基础价格
    local basePrice = priceConfig.base
    -- 玩法附加价格(1为无玩法-不漂)
    local addonPrice = rKey > 1 and priceConfig["r"..rKey-1] or 0
    -- 如果没有玩法附加价格定义则默认为0
    addonPrice = addonPrice or 0
    -- 最终价格(单人需消耗的钻石)
    local price = basePrice + addonPrice
    self.diamond_lab:setString(tostring(price))   
end

--获取游戏规则
function LayerDeskRule:getGameRule()
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
    FriendGameLogic.my_rule = {}
    
    --局数
    table.insert(FriendGameLogic.my_rule, {2, FriendGameLogic.game_rule.count[self.data_index[1]]})

    --抓鸟
    table.insert(FriendGameLogic.my_rule, {3, self.data_index[2]})

    --红中癞子
    if self.data_index[3] > 1 then
        table.insert(FriendGameLogic.my_rule, {4, self.data_index[3] - 1})
    end

    --只能自摸
    if self.data_index[6] > 1 then
        table.insert(FriendGameLogic.my_rule, {7, self.data_index[6] - 1})
    end    

    --大胡
    if self.data_index[4] > 1 then
        table.insert(FriendGameLogic.my_rule, {5, self.data_index[4] - 1})
    end    

    --飘
    if self.data_index[5] > 1 then
        table.insert(FriendGameLogic.my_rule, {100, self.data_index[5] - 1})
    end 

    FriendGameLogic.writeDeskRule(self.data_index)
    FriendGameLogic.enterGameRoom()

    CCUserDefault:sharedUserDefault():setIntegerForKey("CZMJ_GameId", self.gameId)
end

function LayerDeskRule.getInviteMsg()
    local CommonInfo = require("czmj/GameDefs").CommonInfo

    local roominfo = require("cjson").encode({InviteCode = FriendGameLogic.invite_code, GameID = CommonInfo.Game_ID})

    local ruletext, birdtext, roomtext = LayerDeskRule.getRuleText()
    local title = "（"..roomtext.."）"..CommonInfo.Game_Name.."@你"

    local rulemsg = ruletext.."，"..birdtext

    --支付方式
    local paytype = "房主付费"
    if FriendGameLogic.pay_type == 60 then
        paytype = "多人付费"
    end

    return "【"..paytype.."】 "..
            FriendGameLogic.my_rule[1][2].."局，"..rulemsg.."。快来切磋一下吧！", title, roominfo

end

function LayerDeskRule.getRuleText()
    local roomtext = "房间号："..FriendGameLogic.invite_code --..CommonInfo.Game_Name.."："

    --添加游戏规则
    local ruletext = ""
    if #FriendGameLogic.my_rule > 2 then
        tips = {"红中赖子", "有大胡", "飘5分", "只能自摸"}
        for i=3,#FriendGameLogic.my_rule do     
            local index = FriendGameLogic.my_rule[i][1] - 3 
            if index == 97 then
                if FriendGameLogic.my_rule[i][2] == 2 then
                    ruletext = ruletext.."飘3分"
                else
                    ruletext = ruletext.."飘5分"
                end
            else
                ruletext = ruletext..tips[index]
            end

            if i~=#FriendGameLogic.my_rule then
                ruletext = ruletext.."，"
            end

            if index == 1 and FriendGameLogic.my_rule[i][2] == 2 then
                ruletext = ruletext.."无红中加倍，"
            end
        end
    else
        ruletext = ruletext.."无红中赖子，无大胡"
    end

    local tips = {"飞鸟", "159鸟", "六鸟"}
    local birdtext = tips[FriendGameLogic.my_rule[2][2]]

    return ruletext, birdtext, roomtext
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