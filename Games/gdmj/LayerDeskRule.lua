--LayerDeskRule.lua
local LayerDeskRule=class("LayerDeskRule",function()
        return CCLayer:create()
    end)
--创建房间的时候给玩家选择的界面
local AppConfig = require("AppConfig")
local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
LayerDeskRule.options = {--选项表
				GZ 		= 0x00000001, --跟庄
				QGMFB 	= 0x00000002, --抢杠马*2
				QGHQB 	= 0x00000004,  --抢杠胡全包
				GBQB 	= 0x00000008,  --杠爆全包
				DDQB 	= 0x00000010,  --十二张落地全包，也就是单吊
				GKFB	= 0x00000020,	--杠开翻倍
				WZP		= 0x00000040,   --无字牌
				JJG		= 0x00000080,	--节节高
				QXD		= 0x00000100,	--七小对
				SQXD	= 0x00000200,	-- 豪华七小对
				DDH		= 0x00000400,	--对对胡
				HYS		= 0x00000800,	-- 混一色
				QYS		= 0x00001000,	-- 清一色
				HYJ		= 0x00002000,	-- 混幺九（幺九牌）
				QYJ		= 0x00004000,	-- 清幺九(全幺）
				ZYS		= 0x00008000,	--字一色（全风）
				DSY		= 0x00010000,	--大三元
				DSX		= 0x00020000,	--大四喜
				SSY		= 0x00040000,	--十三幺
				TDH		= 0x00080000,	--天地胡
			}
function LayerDeskRule:init(backfunc) 
    local gameId = CCUserDefault:sharedUserDefault():getIntegerForKey("gdmj_GameId")
	gameId = 25
    FriendGameLogic.getFriendTableRule(10, function(bSucceed)
        backfunc(bSucceed)

        if bSucceed then
            self.game_rule = FriendGameLogic.game_rule --局数和价格规则
			-- 上一次选择的数据
			--data_index = {局数，鬼牌类型,无鬼是否翻倍，买马数量，马分类型,吃胡选项，游戏选项}
            self.data_index = FriendGameLogic.readDeskRule() or {1,3,0x100,4,1,3,0x00000FFF}
			
			if(#self.data_index ~= 7) then self.data_index = {1,3,0x100,4,1,3,0x00000FFF} end
			self.gameCountIndex = self.data_index[1] 
			self.magicCardIndex = self.data_index[2]
			self.notMagicDouble = self.data_index[3] --无鬼翻倍 0x100 不翻倍、 0x200翻倍
			self.horseCardCountIndex = self.data_index[4] --买马数量
			self.horseScoreIndex = self.data_index[5]	 --马分
			self.chiHuSelectIndex = self.data_index[6] --哪些牌可吃胡
			self.gameOptions = self.data_index[7] 
			
			
			self.selectGameType = 2
			
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

    local tipPay = "4人支付"
    
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
function LayerDeskRule:addGameRuleType(super)
    local function changeLableTag(index)
    end
    local titles, gameTypes = {"推到胡", "做牌推倒胡",}
    gameTypes = self.layer_super:addGameTypeTitle(super, titles, function(index)
		self.selectGameType = index
		super:removeFromParentAndCleanup(true)
		self.optionBtnGrop = {}
		self:initGameRule()
    end, self.selectGameType)
	
	return true
end

function LayerDeskRule:initGameRule()
	print("function LayerDeskRule:initGameRule()")
    local HallUtils = require("HallUtils")

    --二层背景
    local panelBg = loadSprite("common/popBorder.png", true)
    panelBg:setPreferredSize(CCSizeMake(905, 588))
    panelBg:setPosition(ccp(462, 380))
    self:addChild(panelBg)  

	if not self:addGameRuleType(panelBg) then
		return
	end
	if self.selectGameType == 1 then
		self:initGameType_TDH(panelBg)
	elseif self.selectGameType == 2 then
		self:initGameType_ZPTDH(panelBg)
	end
end
function LayerDeskRule:initGameType_TDH(super)
		    --局数、玩法、可选
	local height,fontSize = 60,38
    local items, tips = {}, {"局数：", "鬼牌: ","买马：","玩法：","","","","",""}
    for i,v in ipairs(tips) do
         local tipsp = CCLabelTTF:create(v, AppConfig.COLOR.FONT_BLACK, fontSize)
        tipsp:setColor(AppConfig.COLOR.MyInfo_Record_Label)

        local item = self.layer_super:addCommonItem(tipsp,super,i)
		tipsp:setPosition(ccp(90,height/2))
		item:setContentSize(CCSizeMake(901, height))
		item:setZOrder(50-i)
		
        if (525 - height * i) < 0 then
			item:setPosition(ccp(2,3))
		else
			item:setPosition(ccp(2, 525 - height * i))
		end
		
		item:setColor(ccc3(255,244,210))
		item:setOpacity(255)
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
    local uis, poses = {}, {ccp(170, height/2 - 5), ccp(450, height/2 - 5)}
    self.layer_super:addCheckGroup(msgs[1], tips[1], poses, items[1], self.layer_zIndex, uis, 
                function(index)
                    self:changeGameCount(index) 
					cclog("局数选择: "..self.game_rule.count[index]) 					
                end, self.gameCountIndex) 
	--鬼牌类型
	local magicMsg = {"无鬼","白板做鬼","翻鬼"}
	poses = {ccp(145, height/2 - 5), ccp(450, height/2 - 5)}
	self.notMagicDoubleBtn = self.layer_super:addCheckBox("无鬼牌翻倍", "", poses[2], items[2], self.layer_zIndex,
                            function(index, markSp) 
								if self.magicCardIndex == 1 then
									markSp:setVisible(false)
									self.notMagicDouble = 0x100
									require("HallUtils").showWebTip("有鬼牌的玩法才能选无鬼翻倍")
									return
								end
								self.notMagicDouble = index == 1 and 0x200 or 0x100
							end, self.notMagicDouble == 0x200)
							
	self.magicCardBtn = require("Lobby/Common/LobbyDropDownList").create(items[2],poses[1],magicMsg,function(index)
							self.magicCardIndex = index
							if index == 1 and self.notMagicDoubleBtn ~= nil then
								self.notMagicDoubleBtn:getChildByTag(10):setVisible(false)
								self.notMagicDouble = 0x100
							end
							cclog("鬼牌选择："..magicMsg[index]) 
						end,self.magicCardIndex)
	--买马
	poses = {ccp(145, height/2), ccp(450, height/2), ccp(690, height/2)}
	local horseCnt = {"无马","买2马","买4马","买6马","买8马","买10马"}
	self.buyHorseBtn = require("Lobby/Common/LobbyDropDownList").create(items[3],poses[1],horseCnt,function(index)
							self.horseCardCountIndex = index
							cclog("买马选择："..horseCnt[index])
						end,self.horseCardCountIndex)
	self.layer_super:addCheckBox("马跟到底", "", poses[2], items[3], self.layer_zIndex,
                            function(index, markSp) 
								self.horseScoreIndex = index
							end,self.horseScoreIndex == 1)
	-- 玩法
	poses = {ccp(175, height/2), ccp(450, height/2), ccp(690, height/2)}
	local gameType = {"跟庄","抢杠马*2","抢杠胡全包","12张落地全包","杠爆全包","杠开翻倍","节节高","无字牌"
					 ,"","七小对2倍","豪华七小对4倍"}
	local optionName = {"GZ","QGMFB","QGHQB","DDQB","GBQB","GKFB","JJG","WZP","","QXD","SQXD"}
	for i = 0,#gameType - 1 do
		if gameType[i+1] ~= "" then
			self.layer_super:addCheckBox(gameType[i+1], "", poses[i%3 + 1], items[math.floor(4+ (i)/3)], self.layer_zIndex,
                function(index, markSp)
					self:selectOptionBtn(optionName[i+1],index == 1)
				end,Bit:_and(self.gameOptions,self.options[optionName[i+1]]) ~= 0)	
		end
	end
end
function LayerDeskRule:initGameType_ZPTDH(super)
		    --局数、玩法、可选
	local height,fontSize = 60,38
    local items, tips = {}, {"局数：", "鬼牌: ","买马：","玩法：","","","","",""}
    for i,v in ipairs(tips) do
         local tipsp = CCLabelTTF:create(v, AppConfig.COLOR.FONT_BLACK, fontSize)
        tipsp:setColor(AppConfig.COLOR.MyInfo_Record_Label)

        local item = self.layer_super:addCommonItem(tipsp,super,i)
		tipsp:setPosition(ccp(90,height/2))
		item:setContentSize(CCSizeMake(901, height))
		item:setZOrder(50-i)
		
        if (525 - height * i) < 0 then--590
			item:setPosition(ccp(2,3))
			--item:setPosition(ccp(2, 525 - height * i))
		else
			item:setPosition(ccp(2, 525 - height * i))
		end
		
		item:setColor(ccc3(255,244,210))
		item:setOpacity(255)
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
    local uis, poses = {}, {ccp(170, height/2 - 5), ccp(450, height/2 - 5)}
    self.layer_super:addCheckGroup(msgs[1], tips[1], poses, items[1], self.layer_zIndex, uis, 
                function(index)
                    self:changeGameCount(index) 
					cclog("局数选择: "..self.game_rule.count[index]) 					
                end, self.gameCountIndex) 
	--鬼牌类型
	local magicMsg = {"无鬼","白板做鬼","翻鬼"}
	poses = {ccp(145, height/2), ccp(450, height/2)}
	self.notMagicDoubleBtn = self.layer_super:addCheckBox("无鬼牌翻倍", "", poses[2], items[2], self.layer_zIndex,
                            function(index, markSp) 
								if self.magicCardIndex == 1 then
									markSp:setVisible(false)
									self.notMagicDouble = 0x100
									require("HallUtils").showWebTip("有鬼牌的玩法才能选无鬼翻倍")
									return
								end
								self.notMagicDouble = index == 1 and 0x200 or 0x100
							end, self.notMagicDouble == 0x200)
							
	self.magicCardBtn = require("Lobby/Common/LobbyDropDownList").create(items[2],poses[1],magicMsg,function(index)
							self.magicCardIndex = index
							if index == 1 and self.notMagicDoubleBtn ~= nil then
								self.notMagicDoubleBtn:getChildByTag(10):setVisible(false)
								self.notMagicDouble = 0x100
							end
							cclog("鬼牌选择："..magicMsg[index]) 
						end,self.magicCardIndex)
	--买马
	poses = {ccp(145, height/2), ccp(450, height/2)}
	local horseCnt = {"无马","买2马","买4马","买6马","买8马","买10马"}
	self.buyHorseBtn = require("Lobby/Common/LobbyDropDownList").create(items[3],poses[1],horseCnt,function(index)
							self.horseCardCountIndex = index
							cclog("买马选择："..horseCnt[index])
						end,self.horseCardCountIndex)
	self.layer_super:addCheckBox("马跟到底", "", poses[2], items[3], self.layer_zIndex,
                            function(index, markSp) 
								self.horseScoreIndex = index
							end,self.horseScoreIndex == 1)	
	-- 具体选项
	self:createOptionBtn(height,items)
end
function LayerDeskRule:createOptionBtn(height,items)
	if self.optionBtnGrop ~= nil then
		for i = 1,#self.optionBtnGrop do
			self.optionBtnGrop[i]:removeFromParentAndCleanup(true)
		end
	end
	self.optionBtnGrop = {}
	local poses = {ccp(175, height/2), ccp(450, height/2), ccp(690, height/2)}
	local gameType = {"跟庄","抢杠马*2","抢杠胡全包","12张落地全包","杠爆全包","杠开翻倍","节节高","无字牌",
					"碰碰胡2倍","混一色2倍","七小对3倍","清一色5倍","豪华七小对6倍","混幺九7倍","清幺九9倍",
					 "字一色9倍","大三元10倍","大四喜10倍","十三幺13倍","天地胡13倍"}
	local optionName = {"GZ","QGMFB","QGHQB","DDQB","GBQB","GKFB","JJG","WZP",
						"DDH","HYS","QXD","QYS","SQXD","HYJ","QYJ",
						"ZYS","DSY","DSX","SSY","TDH",
						}
	local btn = nil
	for i = 0,#gameType - 1 do
		if gameType[i+1] ~= "" then
			btn = self.layer_super:addCheckBox(gameType[i+1], "", ccp(poses[i%3 + 1].x,poses[i%3 + 1].y - math.floor(i/3)*48), items[4], self.layer_zIndex,
                function(index, markSp)
					self:selectOptionBtn(optionName[i+1],index == 1)				
				end,Bit:_and(self.gameOptions,self.options[optionName[i+1]]) ~= 0)
			table.insert(self.optionBtnGrop, btn)
		end
	end
--	self:createChiHuBtn(height,items)
end
function LayerDeskRule:createChiHuBtn(height,items)
	--创建可吃胡选项
	local chiHuMsg = {"鸡胡不能吃胡","任意吃胡","不能吃胡"}
	self.chiHuSelectIndex = self.chiHuSelectIndex >= #chiHuMsg and 3 or self.chiHuSelectIndex
	self.chiHuBtn = require("Lobby/Common/LobbyDropDownList").create(items[4],ccp(145, height/2),chiHuMsg,function(index)
							cclog("可吃胡选择："..chiHuMsg[index])
							self.chiHuSelectIndex = index
						end,self.chiHuSelectIndex)
end
function LayerDeskRule:selectOptionBtn(optionName,bSelect)
	if bSelect then -- 选中
		local data = Bit:_or(self.gameOptions,self.options[optionName])
		self.gameOptions = data
	else					
		local data = Bit:_not(self.options[optionName])
		data = Bit:_and(self.gameOptions,data)
		self.gameOptions = data
	end
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

	--拿到具体的价格表
	local priceTbale = self.game_rule.price[gameCount][payMode]
	
	local payPrice = priceTbale.base

	-- 玩法附加价格(1为无玩法-不漂)
    local addonPrice = 0--self.piaoFenIndex > 1 and priceTbale["r"..self.piaoFenIndex-1] or 0
	
	--最终的钻石数量
	payPrice = payPrice + addonPrice
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
    
    --局数，固定下标2
    table.insert(FriendGameLogic.my_rule, {2,self.game_rule.count[self.gameCountIndex]})
	--游戏类型
	table.insert(FriendGameLogic.my_rule, {3,self.selectGameType})
   --鬼牌
	table.insert(FriendGameLogic.my_rule, {4,Bit:_or(self.magicCardIndex,self.notMagicDouble)})
   --买马数量
    table.insert(FriendGameLogic.my_rule, {5,self.horseCardCountIndex })
   
    table.insert(FriendGameLogic.my_rule, {6,self.horseScoreIndex}) --买马怎么算分
	
	table.insert(FriendGameLogic.my_rule, {7,3}) --可吃胡 
    
	table.insert(FriendGameLogic.my_rule, {8,self.gameOptions}) 
	
   --飘分，固定下标100
    table.insert(FriendGameLogic.my_rule, {100, 0})

	self.data_index[1] = self.gameCountIndex
	self.data_index[2] = self.magicCardIndex
	self.data_index[3] = self.notMagicDouble
	
	self.data_index[4] = self.horseCardCountIndex
	self.data_index[5] = self.horseScoreIndex
	self.data_index[6] = self.chiHuSelectIndex
	self.data_index[7] = self.gameOptions

    FriendGameLogic.writeDeskRule(self.data_index)
    FriendGameLogic.enterGameRoom()

    CCUserDefault:sharedUserDefault():setIntegerForKey("gdmj_GameId", self.gameId)
end

function LayerDeskRule.getInviteMsg() --邀请好友的消息
    cclog("function LayerDeskRule.getInviteMsg()")
    local roominfo = require("cjson").encode({InviteCode = FriendGameLogic.invite_code, GameID = 21})

    local ruletext1,ruletext2,horseCard, roomtext = LayerDeskRule.getRuleText()
    local title = "("..roomtext..")".."广东麻将".."@你"

    local rulemsg = ruletext1..","..ruletext2--.."，"..birdtext

    --支付方式
    local paytype = "房主付费"
    if FriendGameLogic.pay_type == 60 then
        paytype = "多人付费"
    end
    return "【"..paytype.."】 "..
            FriendGameLogic.my_rule[1][2].."局，"..rulemsg.."。快来切磋一下吧！", title, roominfo

end
function LayerDeskRule.getRuleText()--结算规则文本提示
	local tipText = {
	 {"推到胡","做牌推到胡"},
	 {"无鬼","白板做鬼","翻鬼","无鬼翻倍"},
	 {"无马","买2马","买4马","买6马","买8马","买10马"},
	 {"鸡胡不能吃胡","任意吃胡","不能吃胡"}
	}
    local roomtext = "房间号："..tostring(FriendGameLogic.invite_code) --..CommonInfo.Game_Name.."："

	local ruletext1 = ""
	local ruleData = FriendGameLogic.getRuleValueByIndex(3)
	ruletext1 = ruletext1..tipText[1][ruleData].."," --游戏类型
	
	ruleData = FriendGameLogic.getRuleValueByIndex(4)
	local magicCardIndex = Bit:_and(ruleData,0x000000FF)
	local notMagicDouble = Bit:_and(ruleData,0x0000FF00)
	
	ruletext1 = ruletext1..tipText[2][magicCardIndex]		--鬼牌
	if notMagicDouble == 0x200 then --无鬼翻倍
		ruletext1 = ruletext1.."(无鬼翻倍)"
	end
	--马牌数量
	ruleData = FriendGameLogic.getRuleValueByIndex(5)
	ruletext1 = ruletext1..","..tipText[3][ruleData]
	
	--马分
	if  ruleData > 1 then 	--选择了买马的情况下才显示马分
		if FriendGameLogic.getRuleValueByIndex(6) == 1 then
			ruletext1 = ruletext1..",马跟底分"
		end
	end

	--跟庄
	local ruletext2 = ""
	ruleData = FriendGameLogic.getRuleValueByIndex(8)--游戏选项
	if Bit:_and(ruleData,LayerDeskRule.options.GZ) ~= 0 then
		ruletext2 = ruletext2.."跟庄"
	end
	if Bit:_and(ruleData,LayerDeskRule.options.QGMFB) ~= 0 then
		ruletext2 = ruletext2..",抢杠马*2"
	end
	if Bit:_and(ruleData,LayerDeskRule.options.QGHQB) ~= 0 then
		ruletext2 = ruletext2..",抢杠胡全包"
	end
	if Bit:_and(ruleData,LayerDeskRule.options.DDQB) ~= 0 then
		ruletext2 = ruletext2..",12张落地全包"
	end
	if Bit:_and(ruleData,LayerDeskRule.options.GBQB) ~= 0 then
		ruletext2 = ruletext2..",杠爆全包"
	end
	if Bit:_and(ruleData,LayerDeskRule.options.GKFB) ~= 0 then
		ruletext2 = ruletext2..",杠开翻倍"
	end
	if Bit:_and(ruleData,LayerDeskRule.options.JJG) ~= 0 then
		ruletext2 = ruletext2..",节节高"
	end
	if Bit:_and(ruleData,LayerDeskRule.options.WZP) ~= 0 then
		ruletext2 = ruletext2..",无字牌"
	end
--[[	if FriendGameLogic.getRuleValueByIndex(3) == 2 then
		ruleData = FriendGameLogic.getRuleValueByIndex(7)--可吃胡
		if ruleData >= 1 and ruleData <= 3 then
		   ruletext2 = ruletext2..","..tipText[5][ruleData]
		end
	end]]	
    return ruletext1,ruletext2, tipText[3][FriendGameLogic.getRuleValueByIndex(5)],roomtext
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