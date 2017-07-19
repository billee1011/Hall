--LayerGameResult.lua
local AppConfig = require("AppConfig")
local CommonInfo = require("gdmj/GameDefs").CommonInfo
local CCButton = require("FFSelftools/CCButton")
local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
--单局结算界面
local LayerGameResult=class("LayerGameResult",function()
    return CCLayerColor:create(AppConfig.COLOR.ColorLayer_Bg)
end)

function LayerGameResult:hide() 
    require("Lobby/Common/AnimationUtil").spriteScaleHideAction(self.panle_bg, function()
        self:setVisible(false)
        self:setTouchEnabled(false)
        self:releaseTimer()

        self.close_func()
    end)
end

function LayerGameResult:show(func) 
    self:setVisible(true)
    require("Lobby/Common/AnimationUtil").spriteScaleShowAction(self.panle_bg, function()
        self:setTouchEnabled(true)
        if func then
            func()
        end        
    end)    
end

function LayerGameResult:initLiuJu(func) 
    self.close_func = func

    self.panle_bg =  loadSprite("gameResult/liuMark.png")
    self.bg_sz = self.panle_bg:getContentSize()
    self.panle_bg:setPosition(ccp(CommonInfo.View_Width / 2, CommonInfo.View_Height / 2 + 100))
    self:addChild(self.panle_bg)

    self:initCommon({ccp(-460, 280), ccp(self.bg_sz.width / 2, -200)}) 
	
	self.validHorse = {{},{},{},{}} --每个人命中的马牌
end

function LayerGameResult:init(ctype, func) 
	self.validHorse = {{},{},{},{}} --每个人命中的马牌
	
    self.close_func = func

    self.panle_bg = loadSprite("gameResult/resultBg.png", true)
    self.bg_sz = CCSizeMake(1268, 646)
    self.panle_bg:setPreferredSize(self.bg_sz)   
    self.panle_bg:setPosition(ccp(CommonInfo.View_Width / 2, CommonInfo.View_Height / 2 - 33))

    local ancposes, poses, flowerSp = {ccp(1, 1), ccp(0, 0)}, {ccp(self.bg_sz.width, self.bg_sz.height), ccp(0, 0)}
    for i,v in ipairs(ancposes) do
        flowerSp = loadSprite("gameResult/darkFlower.png")
        flowerSp:setAnchorPoint(v)
        self.panle_bg:addChild(flowerSp) 
        flowerSp:setPosition(poses[i]) 
    end
    flowerSp:setScale(1.5)
    flowerSp:setFlipX(true)
    flowerSp:setFlipY(true)
    self:addChild(self.panle_bg)

    local title = loadSprite("gameResult/resultMark"..ctype..".png")
    self.panle_bg:addChild(title)
    title:setPosition(ccp(self.bg_sz.width / 2, self.bg_sz.height))

    self:initCommon({ccp(40, self.bg_sz.height + 26), ccp(self.bg_sz.width / 2, 40)})   

    --分享
    self.shareBtn = CCButton.put(self.panle_bg, CCButton.createCCButtonByFrameName("gameResult/btnShare1.png", 
            "gameResult/btnShare2.png", "gameResult/btnShare1.png", function()
                for i,v in ipairs(self.btn_uis) do
                    v:setVisible(false)
                end

                shareScreenToWx(1, 75, CommonInfo.Game_Name, "单局战绩", function() end)

                for i,v in ipairs(self.btn_uis) do
                    v:setVisible(true)
                end
            end), ccp(self.bg_sz.width - 40, self.bg_sz.height + 20), self.btn_zIndex)
    table.insert(self.btn_uis, self.shareBtn) 

   if AppConfig.ISAPPLE then
       self.shareBtn:setVisible(false)         
    end
    --if debugMode then Cache.log("游戏进行中材质使用内存峰值状况") end
end

function LayerGameResult:initCommon(poses) 
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true
        end
    end
    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority - self.layer_zIndex,true)
    self:setTouchEnabled(true)
    self.btn_zIndex = self.layer_zIndex + 1

    self.btn_uis = {}
    --[[返回
    addBtn("lobby_return_btn", poses[1], function(tag, target)
        self:hide()
    end)]]

    --继续
    local continueBtn = CCButton.put(self.panle_bg, CCButton.createCCButtonByFrameName("gameResult/btnContinue1.png", 
            "gameResult/btnContinue2.png", "gameResult/btnContinue1.png", function()
                self:hide(1) 
            end), poses[2], self.btn_zIndex)
    table.insert(self.btn_uis, continueBtn)
    
    local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
    --返回大厅
    if FriendGameLogic.game_type == 1 then
        continueBtn:setPositionX(poses[2].x - 190)

        local returnBtn = CCButton.put(self.panle_bg, CCButton.createCCButtonByFrameName("gameResult/btnLobby1.png", 
                    "gameResult/btnLobby2.png", "gameResult/btnLobby1.png", function()
                        require(CommonInfo.Logic_Path):getInstance():returnToLobby()
                    end), ccp(poses[2].x + 190, poses[2].y), self.btn_zIndex)    
          
        table.insert(self.btn_uis, returnBtn)                    
    end

    self:setVisible(false)
    self:setTouchEnabled(false)
end

function LayerGameResult:releaseTimer()
    if self.sms_timer ~= nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.sms_timer)
        self.sms_timer = nil       
    end
end

function LayerGameResult:addResultInfo(playerNum, scores, downCaeds, handCards, huCard, cbBanker, cbWiner, cbProve, cbChair, nHuright,cbAllPayUser)
	--	cbAllPayUser 包赔用户
	local yspace, xpos = 130, 166
    if playerNum == 3 then yspace = 170 xpos = 175 end

	self.playerNum = playerNum
	self.cbBanker = cbBanker -- 庄家用户
	cclog("庄家是:"..cbBanker)
    --积分列表
    for i=1,playerNum do
        local idx = i - 1
        --是否为庄家
        local bBanker = cbBanker == idx
        --是否胡牌
        local bHu = cbWiner[i] == 1
        --是否自摸
        local bzimo = bHu and i - 1 == cbProve
        --是否点炮
        local bpao = idx == cbProve
        --飘分参数
        local piao = 0
        for j,v in ipairs(require(CommonInfo.Logic_Path):getInstance().bIsPiao) do
            if v[1] == i - 1 then
                piao = v[2]
                break
            end
        end
        
        local item = loadSprite("gameResult/resultLine.png", true)
        local bgsz = CCSizeMake(1192, item:getContentSize().height)
        item:setPreferredSize(bgsz)

        --创建头像
		
        local faceBg = self:addPlayerLogo(item, bgsz, bBanker, piao, idx)

        self:addGameInfo(item, bgsz, bHu, scores[i], downCaeds[i], 
            handCards[i], huCard, bpao, bzimo, nHuright[i],cbAllPayUser == idx,idx)

        item:setPosition(ccp(self.bg_sz.width / 2, self.bg_sz.height - xpos - yspace * idx))
        self.panle_bg:addChild(item)
    end

    return self   
end

--创建item
function LayerGameResult:addGameInfo(item, bgsz, bHu, scores, downCaeds, handCards, huCard, bpao, bzimo, huright,bBaoPei,cbChair) 
    --积分信息 胡、杠、鸟、总积分
    local msgs = {"胡:"..scores.nHuScore, "杠:"..scores.nGangScore}
	if FriendGameLogic.getRuleValueByIndex(5) > 1 then --选了有马
		table.insert(msgs,"马:"..scores.nHorseScore)
	end
	local ruleData = FriendGameLogic.getRuleValueByIndex(8)--游戏选项
	
	if Bit:_and(ruleData,0x00000080) ~= 0 then --连赢
		if scores.nContinuousWinScore > 0  then
		  table.insert(msgs,string.format("节节高:%d(%d连)",scores.nContinuousWinScore,scores.nContinuousWinScore/(2*(self.playerNum - 1))))
		else
			table.insert(msgs,"节节高:"..scores.nContinuousWinScore)
		end
	end
	if Bit:_and(ruleData,0x00000001) ~= 0 then 
		table.insert(msgs,"跟庄:"..scores.nCallBankerScore)
	end
	
	local poses =  {ccp(273, 113), ccp(499, 113), ccp(596 + 165, 113)}
	if #msgs == 5 then
		poses = {ccp(273, 113), ccp(596 - 185, 113), ccp(534, 113), ccp(699, 113),ccp(596+263, 113)}
	elseif #msgs == 4 then
		poses = {ccp(273, 113), ccp(596 - 128, 113), ccp(596 + 68, 113), ccp(596+263, 113)}
	end
	
	for i = #msgs,1,-1 do
		local ttfLab = CCLabelTTF:create(msgs[i], AppConfig.COLOR.FONT_ARIAL, 24)
        ttfLab:setPosition(poses[i])
        item:addChild(ttfLab)
	end
    local msg = ""..scores.nTotoalScore
    if scores.nTotoalScore > 0 then
        msg = "+"..scores.nTotoalScore
    end

    local labItem = CCLabelAtlas:create(msg, CommonInfo.Mj_Path.."num_score.png",40, 43,string.byte('+'))
    labItem:setAnchorPoint(ccp(0, 0.5))
    labItem:setPosition(ccp(bgsz.width - 120, 60))
	labItem:setScale(0.85)
    item:addChild(labItem)

    if bHu then
        --胡牌标示
        self:addHuMark(item, bzimo, huright)

        self:addHuCard(item, bgsz, downCaeds, handCards, huCard,cbChair)      
    else
        if not bBaoPei and bpao then
            local mark = loadSprite("gameResult/huMark0.png")
            mark:setPosition(ccp(170, 53))
            item:addChild(mark) 
        end
		--包赔标识
		if bBaoPei then
			local mark = loadSprite("gdmj/img_pei_mark.png")
			item:addChild(mark)
			mark:setScale(1.2)
			mark:setPosition(ccp(170, 53)) 
		end
        self:addHuCard(item, bgsz, downCaeds, handCards,0,cbChair)
    end
    
    item:setPosition(ccp(self.bg_sz.width / 2, 6))

    return item
end

function LayerGameResult:addPlayerLogo(item, bgsz, bBanker, piao, chair)
    local info = self:getParent().playerLogo_panel.logo_table[chair + 1].userInfo
    --require(CommonInfo.Logic_Path):getInstance():getUserByChair(chair)
    
  --[[  if info._userDBID == require("Lobby/Login/LoginLogic").UserInfo.UserID then
    --自己标示
        local panelBg = loadSprite("gameResult/selfMark.png", true)
        item:addChild(panelBg)
        panelBg:setPosition(ccp(bgsz.width / 2, 66))
        panelBg:setPreferredSize(CCSizeMake(813, panelBg:getContentSize().height))
    end ]]

    local faceSp = self:getParent():getPlayerLogoSp(chair)
    faceSp = require("FFSelftools/CCUserFace").clone(faceSp, CCSizeMake(140,140))
    local faceBg, sz = require("Lobby/Info/LayerInfo").createLogo(faceSp)
    faceSp:setPosition(ccp(sz.width / 2, sz.height / 2 - 2))
    faceBg:setScale(0.6)

    --昵称
    local ttfLab = CCLabelTTF:create(info._name, AppConfig.COLOR.FONT_ARIAL, 40)
    ttfLab:setPosition(ccp(sz.width / 2, -25))
    faceBg:addChild(ttfLab)

	--添加方位标识
	local nPos = require(CommonInfo.Logic_Path):getInstance():getRelativeChair(chair) - 1
	local directSp = loadSprite("gdmj/direct_"..nPos..".png")
	directSp:setAnchorPoint(ccp(1,0.5))
	directSp:setPosition(ccp(-10,sz.height / 2))
	directSp:setScale(1.66)
	faceBg:addChild(directSp)
	
    if bBanker then
        --庄家标示
        local mark = loadSprite("mjdesk/bankerMark.png")
        faceBg:addChild(mark)
        mark:setScale(1 / 0.7)
        mark:setPosition(ccp(10, sz.height-10)) 
    end
	
    if piao > 0 then
        local mark = loadSprite("mjdesk/tipMark.png")
        faceBg:addChild(mark)
        mark:setAnchorPoint(ccp(1, 0))
        mark:setPosition(ccp(170, 0)) 
        local sz = mark:getContentSize()

        local piaoLab = CCLabelTTF:create("飘"..piao.."分", AppConfig.COLOR.FONT_ARIAL, 18)
        mark:addChild(piaoLab)
        piaoLab:setPosition(ccp(sz.width / 2 + 2, sz.height / 2))

        mark:setScale(1 / 0.7)        
    end
	
    faceBg:setPosition(ccp(56, 80))
    item:addChild(faceBg) 
    return faceBg
end

function LayerGameResult:addHuMark(item, bzimo, huright)
    local HuType = require("gdmj/GameDefs").HuType
    local mark = nil
    if bzimo then--胡牌标示     
		if Bit:_and(huright, HuType.QING_GANG_HU) == HuType.QING_GANG_HU then   --抢杠胡  
            mark = loadSprite("gameResult/huMark2.png")
		else
            mark = loadSprite("gameResult/huMark3.png")
		end
 
    else --非自摸
		if Bit:_and(huright, HuType.QING_GANG_HU) == HuType.QING_GANG_HU then   --抢杠胡  
            mark = loadSprite("gameResult/huMark2.png")
		else
            mark = loadSprite("gameResult/huMark1.png")
		end
    end
	mark:setPosition(ccp(170, 57))
    item:addChild(mark)

	local tipMsg = {
		GANG_BAO_HU	 =		"杠爆",									--杠爆胡
		GANG_KAI_HU  =		"杠开",									--杠开胡
		QING_GANG_HU =		"抢杠",									--抢杠胡
		JIAN_REN_HU	 =		"12张落地",								--尖人胡牌
		
		SI_GUI_PAI	 = 		"四鬼牌",									--四鬼牌
		PENG_PENG	 =		"对对胡",									--碰碰和
		HUN_YI_SE	 =		"混一色",									--混一色
		QI_DUI		 =		"七小对",									--七对
		QING_YI_SE	 =		"清一色",									--清一色
		SUPER_QI_DUI =		"豪华七小对",								--豪华七小对
		YAO_JIU		 =		"混幺九",									--幺九（混幺九）
		QUAN_YAO	 =		"清幺九",									--全幺(清幺九）
		QUAN_FENG	 =		"字一色",									--全风（字一色）
		SHI_SAN_YAO	 =		"十三幺",									--十三幺
		DA_SAN_YUAN	 =		"大三元",									--大三元
		DA_SI_XI	 =		"大四喜",									--大四喜
		TIAN_HU		 =      "天胡",										--天胡
		DI_HU		 =      "地胡",										--地胡
	}

	local humark = {}
    for k,v in pairs(HuType) do
        if v~=HuType.QING_GANG_HU and v~=HuType.GANG_BAO_HU and v~= HuType.JIAN_REN_HU and 
		   v~=HuType.GANG_KAI_HU and Bit:_and(huright, v) == v then
			  table.insert(humark,tipMsg[k] )
        end
    end
	local msg = ""
	if #humark > 0 then	
        for i,v in ipairs(humark) do
            if i > 1 then
                --添加逗号
                msg = msg..","
            end 
			msg = msg..humark[i]
        end  
	end
	local bGangBao = Bit:_and(huright, HuType.GANG_BAO_HU) == HuType.GANG_BAO_HU
	local bGangKai = Bit:_and(huright, HuType.GANG_KAI_HU) == HuType.GANG_KAI_HU
	local bJianPai = Bit:_and(huright, HuType.JIAN_REN_HU) == HuType.JIAN_REN_HU
	if bGangBao then --杠爆胡
		msg = msg.."(杠爆)"
	elseif bGangKai then
		if bJianPai then
			msg = msg.."(杠开、12张落地)"
		else
			msg = msg.."(杠开)"
		end	
	elseif bJianPai then
		msg = msg.."(12张落地)"
	end
	cclog(msg)
	if msg and msg ~= "" then
		local cardTip = CCLabelTTF:create(msg, AppConfig.COLOR.FONT_ARIAL, 16)
		cardTip:setAnchorPoint(ccp(0, 0.5))
        cardTip:setPosition(ccp(245, 17))
		cardTip:setColor(ccc3(255,207,14))
		cardTip:setHorizontalAlignment(kCCTextAlignmentLeft)
        item:addChild(cardTip)
	end
end

function LayerGameResult:addHuCard(super, bgsz, downCaeds, handCards, huCard,cbChair)
    local SpriteGameCard = require(CommonInfo.Code_Path.."Game/SpriteGameCard")

    local fscale = 0.6
	local directMsg = {"我","下家","对家","上家"}
    local function addCard(card, cardpos, index,provide)
        local item = nil
        if card > 0 then
            item = SpriteGameCard.createHand(card) 
            item.card_bg:setFlipY(true) 
            item.sprite_card:setPositionY(item.sprite_card:getPositionY() + 10)
            if item.laizi_mark then
                item.laizi_mark:setPositionY(item.laizi_mark:getPositionY() + 15)
            end
			--provide 谁出分
			if provide and  provide >= 0 and provide < self.playerNum then				
				local nPos = require(CommonInfo.Logic_Path):getInstance():getRelativeChair(provide)
				
				local ttfLab = CCLabelTTF:create(directMsg[nPos], AppConfig.COLOR.FONT_ARIAL, 15)
				super:addChild(ttfLab,2)
				ttfLab:setColor(ccc3(255,0,0))
				ttfLab:setPosition(ccp(cardpos.x + 70,cardpos.y - 10))
			end
        else
            item = SpriteGameCard.createMyCardBack()
        end
        item:setScale(fscale)

        cardpos.x = cardpos.x + (item.base_size.width) * fscale
        item:setPosition(cardpos)        
        super:addChild(item)

        return item
    end

    --手牌
    local huPos, pos, space = nil, ccp(190, 25), 10 * fscale
    for i,v in ipairs(handCards) do
        local item = addCard(v, pos, i - 1)
        if huCard == v then
            huPos = ccp(item:getPositionX(), item:getPositionY())
        end
    end
    if huPos then
        --添加胡的标示
        local mark = loadSprite("mjValue/markHu.png")
        mark:setPosition(ccp(huPos.x + 12, huPos.y + 54))
        mark:setScale(0.9)
        super:addChild(mark, 1)
    end
    pos.x = pos.x + 10 * fscale

    --倒下去的牌
    if #downCaeds > 0 then
        for i=#downCaeds, 1, -1 do 
            local v = downCaeds[i]
            local items = {}
            for j=1,3 do
                table.insert(items, addCard(v[4 - j], pos, j))
            end 

            --杠牌
            if #v == 5 then
				--前面三张为0就是暗杠
				local payUser = (v[1] ~= 0 or cbChair ~= v[5]) and v[5] or nil --出分的人
				
                addCard(v[4], ccp(items[1]:getPosition()), 2,payUser):setPositionY(22 + 18 * fscale)
            end
            pos = ccp(pos.x + space, 25)        
        end
    end
	--添加命中的马牌
	local horseX,horseY = 950,40
	if self.validHorse and self.validHorse[cbChair+1] then
		if #self.validHorse[cbChair+1] > 0 then
			local mark = loadSprite("gdmj/hitHorse.png")
			mark:setAnchorPoint(ccp(0,0.5))
			mark:setPosition(ccp(horseX,110))
			mark:setScale(0.7)
			super:addChild(mark)
		end
		if #self.validHorse[cbChair+1] >  5 then horseY = 65 end
		for i = 1,#self.validHorse[cbChair + 1] do
			local sp = SpriteGameCard.createHand(self.validHorse[cbChair + 1][i]) 
            sp.card_bg:setFlipY(true) 
            sp.sprite_card:setPositionY(sp.sprite_card:getPositionY() + 10)
			sp:setScale(0.3)
			sp:setPosition(ccp(horseX,horseY))
			super:addChild(sp)
			horseX = horseX + (sp.base_size.width) * 0.3
			
			sp:addCardMask(ccc4(254,254,65, 100))
			
			if sp.laizi_mark then
                sp.laizi_mark:setVisible(false)
            end
			if i == 5 then
				horseY = horseY - (sp.base_size.height) * 0.3 - 3
				horseX = 950
			end
		end
	end
	
end

function LayerGameResult:addBirdMark(birds, valids)
    local  states = {} --判断哪些马牌是有有效的
	for i = 1,#birds do	
		states[i] = false
		for j = 1,#valids do
			if valids[j] == birds[i] then
				states[i] = true
				break
			end
		end
	end
	local gameLogicInstance = require(CommonInfo.Logic_Path):getInstance()
	local bankerChair = gameLogicInstance.wBankerUser or 0
	self.validHorse = {{},{},{},{}} --每个人命中的马牌
	for i = 1,#birds do
		if states[i] == true then
			local chair = (Bit:_and(birds[i],0x0F) - 1 + bankerChair)% gameLogicInstance.cbPlayerNum -- 算出每张牌对应的椅子号
			table.insert(self.validHorse[chair+1],birds[i])
		end
	end
	
    local ruletext1, ruletext2,birdtext, roomtext = require("gdmj/LayerDeskRule").getRuleText()

    local ttfLab = CCLabelTTF:create(birdtext, AppConfig.COLOR.FONT_ARIAL, 24)
    ttfLab:setAnchorPoint(ccp(1, 0.5))
    ttfLab:setPosition(ccp(80, 40))
    self.panle_bg:addChild(ttfLab)

    local SpriteGameCard = require("gdmj/Game/SpriteGameCard")
    local bValidCard = false
	local myChair = gameLogicInstance.wChair
    for i,v in ipairs(birds) do
        local cardSp = SpriteGameCard.createHand(v) 
        cardSp:setPosition(ccp(53 + cardSp.base_size.width / 2 * i, 13))
		
--[[		bValidCard = false
		for k = 1,#self.validHorse[myChair + 1] do
			if self.validHorse[myChair + 1][k] == v then
				bValidCard = true
				break
			end
		end
        if bValidCard then            
          --  cardSp:addCardMask(ccc4(254,254,65, 100))
        else
          --  cardSp:addCardMask(ccc4(0, 0, 0, 100))
        end]]

        cardSp:setScale(0.5)
        self.panle_bg:addChild(cardSp)
    end

    local msg = roomtext.."\n"..ruletext1.."\n"..ruletext2 --..CommonInfo.Game_Name.."："
    ttfLab = CCLabelTTF:create(msg, AppConfig.COLOR.FONT_ARIAL, 16)
    ttfLab:setHorizontalAlignment(kCCTextAlignmentRight)
    ttfLab:setAnchorPoint(ccp(1, 0.5))
    ttfLab:setPosition(ccp(self.bg_sz.width - 20, 46))
    self.panle_bg:addChild(ttfLab)    
end

function LayerGameResult.create(ctype, func)
    local layer = LayerGameResult.new()
    layer:init(ctype, func)
    return layer
end

function LayerGameResult.createLiuJu(func)
    local layer = LayerGameResult.new()
    layer:initLiuJu(func)
    return layer
end

function LayerGameResult.put(super, zindex, ctype, func)
    local layer = LayerGameResult.new()
    super:addChild(layer, zindex)
    layer.layer_zIndex = zindex

    layer:init(ctype, func)
    return layer
end

function LayerGameResult.putLiuJu(super, zindex, func)
    local layer = LayerGameResult.new()
    super:addChild(layer, zindex)
    layer.layer_zIndex = zindex

    layer:initLiuJu(func)
    return layer
end

return LayerGameResult