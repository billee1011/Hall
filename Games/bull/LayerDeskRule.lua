--LayerDeskRule.lua
local LayerDeskRule=class("LayerDeskRule",function()
        return CCLayer:create()
    end)

local AppConfig = require("AppConfig")
local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
--[[ 游戏规则格式
{
     count = {
         [1] = 1,
         [2] = 10,
     },
     price = {
         [1] = {
             mult = {
                 base = 1,
                 r1 = 0,
                 r2 = 0,
             },
             single = {
                 base = 2,
                 r1 = 0,
                 r2 = 0,
             },
         },
         [10] = {
             mult = {
                 base = 2,
                 r1 = 0,
                 r2 = 0,
             },
             single = {
                 base = 4,
                 r1 = 0,
                 r2 = 0,
             },
         },
     },
 }]]
function LayerDeskRule:init(backfunc) 
    local gameId = CCUserDefault:sharedUserDefault():getIntegerForKey("bull_GameId")
	cclog("gameId:"..gameId)
    gameId = (gameId == 0) and 18 or 18
    FriendGameLogic.getFriendTableRule(10, function(bSucceed)
        backfunc(bSucceed)
		
        if bSucceed then
            self.game_rule = FriendGameLogic.game_rule --局数和价格规则

			-- 上一次选择的数据
			--data_index = {局数，类型，人数,最大倍数}
            self.data_index = FriendGameLogic.readDeskRule() or {1,1,1,1}
			
			if(#self.data_index ~= 4) then self.data_index = {1,1,1,1} end
			self.gameCountIndex = self.data_index[1]
			self.gameTypeIndex = self.data_index[2]
			self.playerCountIndex = self.data_index[3]
			self.maxStakeIndex = self.data_index[4]
			
            self:initDaimondRule() 
            self:initGameRule() 
			
            self.gameId = gameId
        end
    end, gameId)                     
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

    local tipPay = (self.playerCountIndex + 1) .."人支付"
    
    --支付方式
    addTipTtf(ccp(20, 400), 36, ccp(0, 0.5), "支付方式：")
	--多人支付标签
    self.multPayLab = addTipTtf(ccp(20, 330), 32, ccp(0, 0.5), tipPay)
    addTipTtf(ccp(20, 250), 32, ccp(0, 0.5), "1人支付")
    local multBtn, oneBtn
    --选择按钮
    multBtn = self.layer_super:addCheckBox("", "", ccp(240, 330), panelBg, self.layer_zIndex,
                            function(index, markSp) 
                                oneBtn:getChildByTag(10):setVisible(false)
                                markSp:setVisible(true) 
                                FriendGameLogic.pay_type = 60
                                self:updataDiamondTTf() end, FriendGameLogic.pay_type ~= 50)
    oneBtn = self.layer_super:addCheckBox("", "", ccp(240, 250), panelBg, self.layer_zIndex,
                            function(index, markSp)                                 
                                multBtn:getChildByTag(10):setVisible(false)
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

	--所需宝石标签
    self.diamond_lab = daimondTtf[1]

    addTipTtf(ccp(140, 30), 30, ccp(0.5, 0.5), "底分：1")

	    --提示信息
    local tipmsg = CCLabelTTF:create(AppConfig.TIPTEXT.Tip_FriendDiamond_Msg_New, AppConfig.COLOR.FONT_BLACK, 18)      
    tipmsg:setPosition(ccp(140, -130))
    tipmsg:setColor(ccc3(250,55,55))
    panelBg:addChild(tipmsg)

end

function LayerDeskRule:initGameRule()
	print("function LayerDeskRule:initGameRule()")
    local HallUtils = require("HallUtils")

    --二层背景
    local panelBg = loadSprite("common/popBorder.png", true)
    panelBg:setPreferredSize(CCSizeMake(905, 588))
    panelBg:setPosition(ccp(462, 380))
    self:addChild(panelBg) 

    --局数、玩法、可选
    local items, tips = {}, {"局数：","人数：","","玩法: ","","","下注："}
    for i,v in ipairs(tips) do
        local tipsp = CCLabelTTF:create(v, AppConfig.COLOR.FONT_BLACK, 40)
        tipsp:setColor(AppConfig.COLOR.MyInfo_Record_Label)

        local item = self.layer_super:addCommonItem(tipsp, panelBg,i+1)
		item:setContentSize(CCSizeMake(901, 85))
		item:setZOrder(20 - i)
        item:setPosition(ccp(2, 590 - 85 * i))
        table.insert(items, item)
    end

    --局数 {count = {} price ={}}
    local countConfig = self.game_rule.count
    local msgs = {{}, {}}
    local tips = {{}, {}}
    for i,v in ipairs(countConfig) do
        table.insert(msgs[1], v.."局")
        table.insert(tips[1], "")
    end
    --局数
    local uis, poses = {}, {ccp(170, 45), ccp(450, 45), ccp(170, -45), ccp(450, -45)}
    self.layer_super:addCheckGroup(msgs[1], tips[1], poses, items[1], self.layer_zIndex, uis, 
                function(index)
                    self:changeGameCount(index) 
					cclog("局数选择: "..self.game_rule.count[index]) 					
                end, self.gameCountIndex)  
	--类型
	local gameTypeTip = {"看牌抢庄","世界大战","牛牛坐庄","轮流坐庄","牌大坐庄","自由抢庄","房主霸王庄"}
	poses = {ccp(170, 45), ccp(450, 45), ccp(730, 45), 
			ccp(170, -45),ccp(450, -45), ccp(730, -45),ccp(170, -135)}
	local gameTypeBtn = {}
    self.layer_super:addCheckGroup(gameTypeTip, {}, poses, items[4], self.layer_zIndex+10, gameTypeBtn, 
                function(index)
					self.gameTypeIndex = index                          
                end, self.gameTypeIndex) 
	--人数
	poses = {ccp(170, 45), ccp(450, 45), ccp(170, -45), ccp(450, -45)}
	local playerCnt = {"2人","3人","4人","5人"}
    self.layer_super:addCheckGroup(playerCnt, "", poses, items[2], self.layer_zIndex, {}, 
                function(index)
                    cclog("人数选择："..(index + 1))					
					self:changePlayerCount(index)				
                end, self.playerCountIndex) 
	--倍数
    poses = {ccp(170, 45), ccp(450, 45)}
	local stake = {"最大下注5倍","最大下注10倍"}
	local stakeBtn ={}
	self.layer_super:addCheckGroup(stake, "", poses, items[7], self.layer_zIndex, stakeBtn, 
                function(index)
                    cclog("倍数选择选择："..(index *5))
					self.maxStakeIndex = index					
                end, self.maxStakeIndex) 
end
--改变游戏人数
function LayerDeskRule:changePlayerCount(index)
	self.multPayLab:setString((index+1).."人支付")
	self.playerCountIndex = index;
	self:updataDiamondTTf()
end
--改变游戏局数
function LayerDeskRule:changeGameCount(index)
	self.gameCountIndex = index;
	self:updataDiamondTTf()
end


function LayerDeskRule:updataDiamondTTf()
	cclog("function LayerDeskRule:updataDiamondTTf(index)")
	--游戏局数
	local gameCount = self.game_rule.count[self.gameCountIndex]
	--支付模式
	local payMode = FriendGameLogic.pay_type == 60 and "mult" or "single"
	--人数
	local playerCount = self.playerCountIndex + 1
	--拿到具体的价格表
	local priceTbale = self.game_rule.price[gameCount][payMode]
	
	local payPrice = priceTbale.base
--根据人数再加支付宝石
	local field = {"r97","r98","r99"}
	if priceTbale[field[self.playerCountIndex - 1]] ~= nil then
		payPrice = payPrice + priceTbale[field[self.playerCountIndex - 1]]
	end
	self.diamond_lab:setString(tostring(payPrice))
	
end

--获取游戏规则
function LayerDeskRule:getGameRule()
	cclog("function LayerDeskRule:getGameRule()")
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
    table.insert(FriendGameLogic.my_rule, {2,self.game_rule.count[self.gameCountIndex]})

   --玩法
	table.insert(FriendGameLogic.my_rule, {3,self.gameTypeIndex})

    --人数
    table.insert(FriendGameLogic.my_rule, {101,self.playerCountIndex + 1})
	
	--最大下注
	table.insert(FriendGameLogic.my_rule, {4,self.maxStakeIndex*5})
	
	self.data_index[1] = self.gameCountIndex
	self.data_index[2] = self.gameTypeIndex
	self.data_index[3] = self.playerCountIndex
	self.data_index[4] = self.maxStakeIndex
	
    FriendGameLogic.writeDeskRule(self.data_index)
    FriendGameLogic.enterGameRoom()

    CCUserDefault:sharedUserDefault():setIntegerForKey("bull_GameId", self.gameId)
end

function LayerDeskRule.getInviteMsg() --邀请好友的消息
    cclog("function LayerDeskRule.getInviteMsg()")
    local roominfo = require("cjson").encode({InviteCode = FriendGameLogic.invite_code, GameID = 18})

    local ruletext, roomtext = LayerDeskRule.getRuleText()
    local title = "("..roomtext..")".."斗牛".."@你"

    local rulemsg = ruletext --.."，"..birdtext

    --支付方式
    local paytype = "房主付费"
    if FriendGameLogic.pay_type == 60 then
        paytype = "多人付费"
    end

    return "【"..paytype.."】 "..
            FriendGameLogic.my_rule[1][2].."局，"..rulemsg.."。快来切磋一下吧！", title, roominfo

end

function LayerDeskRule.getRuleText()--结算规则文本提示
	cclog("function LayerDeskRule.getRuleText()")
    local roomtext = "房间号："..tostring(FriendGameLogic.invite_code) --..CommonInfo.Game_Name.."："

	local gameType = {"看牌抢庄","世界大战","牛牛坐庄","轮流坐庄","牌大坐庄","自由抢庄","房主霸王庄"}
	local ruletext = FriendGameLogic.my_rule[3][2].."人,"
	
	ruletext = ruletext.. gameType[FriendGameLogic.my_rule[2][2]]
	
	if FriendGameLogic.my_rule[2][2] ~= 2 then 
		ruletext = ruletext.."(最大下注"..FriendGameLogic.my_rule[4][2].."倍)"
	end
 
    return ruletext, roomtext
end

function LayerDeskRule.put(super, zindex, backfunc)
	print("function LayerDeskRule.put(super, zindex, backfunc)")
    local layer = LayerDeskRule.new()
    layer.layer_zIndex = zindex
    layer.layer_super = super
    super.panel_bg:addChild(layer, zindex)
    layer:setPosition(ccp(20, -50))

    layer:init(backfunc)
    return layer
end

 return LayerDeskRule