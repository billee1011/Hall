--LayerGameResult.lua
local AppConfig = require("AppConfig")
local CommonInfo = require("czmj/GameDefs").CommonInfo
local CCButton = require("FFSelftools/CCButton")
local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")

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
end

function LayerGameResult:init(ctype, func) 
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

function LayerGameResult:addResultInfo(playerNum, scores, downCaeds, handCards, huCard, cbBanker, cbWiner, cbProve, cbChair, nHuright)
    local yspace, xpos = 130, 166
    if playerNum == 3 then yspace = 170 xpos = 175 end

    --积分列表
    for i=1,playerNum do
        local idx = i - 1
        --是否为庄家
        local bBanker = cbBanker == idx
        --是否胡牌
        local bHu = cbWiner == idx
        --是否自摸
        local bzimo = cbWiner == cbProve
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
            handCards[i], huCard, bpao, bzimo, nHuright)

        item:setPosition(ccp(self.bg_sz.width / 2, self.bg_sz.height - xpos - yspace * idx))
        self.panle_bg:addChild(item)
    end

    return self   
end

--创建item
function LayerGameResult:addGameInfo(item, bgsz, bHu, scores, downCaeds, handCards, huCard, bpao, bzimo, huright) 
    --积分信息 胡、杠、鸟、总积分
    local poses = {ccp(bgsz.width / 2 - 293, 110), ccp(bgsz.width / 2, 110), ccp(bgsz.width / 2 + 195, 110)}
    if FriendGameLogic.isRulevalid(100) then
        poses = {ccp(bgsz.width / 2 - 293, 110), ccp(bgsz.width / 2 - 98, 110), ccp(bgsz.width / 2 + 98, 110), ccp(bgsz.width / 2 + 293, 110)}
    end
    local msgs = {"胡："..scores.nHuScore, "杠："..scores.nGangScore, "鸟："..scores.nBirdScore, "飘："..scores.nPiaoScore}
    for i,v in ipairs(poses) do
        local ttfLab = CCLabelTTF:create(msgs[i], AppConfig.COLOR.FONT_ARIAL, 24)
        ttfLab:setPosition(v)
        item:addChild(ttfLab)
    end
    local msg = ""..scores.nTotoalScore
    if scores.nTotoalScore > 0 then
        msg = "+"..scores.nTotoalScore
    end
    local labItem = CCLabelAtlas:create(msg, CommonInfo.Mj_Path.."num_score.png",40, 43,string.byte('+'))
    labItem:setAnchorPoint(ccp(0, 0.5))
    labItem:setPosition(ccp(bgsz.width - 160, 50))
    item:addChild(labItem)

    if bHu then
        --胡牌标示
        self:addHuMark(item, bzimo, huright)

        self:addHuCard(item, bgsz, downCaeds, handCards, huCard)      
    else
        if bpao then
            local mark = loadSprite("gameResult/huMark0.png")
            mark:setPosition(ccp(200, 53))
            item:addChild(mark) 
        end
        self:addHuCard(item, bgsz, downCaeds, handCards)
    end
    
    item:setPosition(ccp(self.bg_sz.width / 2, 6))

    return item
end

function LayerGameResult:addPlayerLogo(item, bgsz, bBanker, piao, chair)
    local info = self:getParent().playerLogo_panel.logo_table[chair + 1].userInfo
    --require(CommonInfo.Logic_Path):getInstance():getUserByChair(chair)
    
    if info._userDBID == require("Lobby/Login/LoginLogic").UserInfo.UserID then
    --自己标示
        local panelBg = loadSprite("gameResult/selfMark.png", true)
        item:addChild(panelBg)
        panelBg:setPosition(ccp(bgsz.width / 2, 66))
        panelBg:setPreferredSize(CCSizeMake(813, panelBg:getContentSize().height))
    end 

    local faceSp = self:getParent():getPlayerLogoSp(chair)
    faceSp = require("FFSelftools/CCUserFace").clone(faceSp, CCSizeMake(140,140))
    local faceBg, sz = require("Lobby/Info/LayerInfo").createLogo(faceSp)
    faceSp:setPosition(ccp(sz.width / 2, sz.height / 2 - 2))
    faceBg:setScale(0.6)

    --昵称
    local ttfLab = CCLabelTTF:create(info._name, AppConfig.COLOR.FONT_ARIAL, 40)
    ttfLab:setPosition(ccp(sz.width / 2, -25))
    faceBg:addChild(ttfLab)

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

    faceBg:setPosition(ccp(86, 80))
    item:addChild(faceBg) 
    return faceBg
end

function LayerGameResult:addHuMark(item, bzimo, huright)
    local HuType = require("czmj/GameDefs").HuType
    local mark
    if bzimo then
        --胡牌标示
        mark = loadSprite("gameResult/huMark3.png")
    elseif Bit:_and(huright, HuType.QiangGang_hu) == HuType.QiangGang_hu then     
        --抢杠胡
        mark = loadSprite("gameResult/huMark2.png")
    else
        mark = loadSprite("gameResult/huMark1.png")
    end
    mark:setPosition(ccp(200, 57))
    item:addChild(mark)

    --类型标示
    local humark = {}
    for k,v in pairs(HuType) do
        if v~=HuType.QiangGang_hu and Bit:_and(huright, v) == v then
            table.insert(humark, loadSprite("gameResult/huType"..v..".png"))
        end
    end
    if #humark > 0 then
        local leftmark = loadSprite("gameResult/huLeft.png")
        local sz = leftmark:getContentSize()
        local function addMark(file)
            local marksp = loadSprite(file)
            marksp:setAnchorPoint(ccp(0, 0.5))
            marksp:setPosition(ccp(sz.width, sz.height / 2))
            leftmark:addChild(marksp)
            sz.width = sz.width + marksp:getContentSize().width
        end

        for i,v in ipairs(humark) do
            if i > 1 then
                --添加逗号
                addMark("gameResult/huMiddle.png")
            end

            --类型标示
            v:setAnchorPoint(ccp(0, 0.5))
            v:setPosition(ccp(sz.width, sz.height / 2))
            leftmark:addChild(v) 
            sz.width = sz.width + v:getContentSize().width           
        end

        addMark("gameResult/huRight.png")    
        leftmark:setPosition(ccp(200 - sz.width / 2, 20))
        item:addChild(leftmark)   
    end
end

function LayerGameResult:addHuCard(super, bgsz, downCaeds, handCards, huCard)
    local SpriteGameCard = require(CommonInfo.Code_Path.."Game/SpriteGameCard")

    local fscale = 0.6
    local function addCard(card, cardpos, index)
        local item = nil
        if card > 0 then
            item = SpriteGameCard.createHand(card) 
            item.card_bg:setFlipY(true) 
            item.sprite_card:setPositionY(item.sprite_card:getPositionY() + 10)
            if item.laizi_mark then
                item.laizi_mark:setPositionY(item.laizi_mark:getPositionY() + 15)
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
    local huPos, pos, space = nil, ccp(220, 10), 10 * fscale
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
            if #v == 4 then
                addCard(v[4], ccp(items[1]:getPosition()), 2):setPositionY(10 + 18 * fscale)
            end
            pos = ccp(pos.x + space, 10)        
        end
    end
end

function LayerGameResult:addBirdMark(birds, valids)    
    local ruletext, birdtext, roomtext = require("czmj/LayerDeskRule").getRuleText()

    local ttfLab = CCLabelTTF:create(birdtext, AppConfig.COLOR.FONT_ARIAL, 24)
    ttfLab:setAnchorPoint(ccp(1, 0.5))
    ttfLab:setPosition(ccp(120, 40))
    self.panle_bg:addChild(ttfLab)

    local SpriteGameCard = require("czmj/Game/SpriteGameCard")
    local index = 1
    for i,v in ipairs(birds) do
        local cardSp = SpriteGameCard.createHand(v) 
        cardSp:setPosition(ccp(93 + cardSp.base_size.width / 2 * i, 13))

        if index <= #valids and valids[index] == v then            
            cardSp:addCardMask(ccc4(254,254,65, 100))
            index = index + 1
        else
            cardSp:addCardMask(ccc4(0, 0, 0, 100))
        end

        cardSp:setScale(0.5)
        self.panle_bg:addChild(cardSp)
    end

    local msg = roomtext.."\n"..ruletext --..CommonInfo.Game_Name.."："
    ttfLab = CCLabelTTF:create(msg, AppConfig.COLOR.FONT_ARIAL, 22)
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