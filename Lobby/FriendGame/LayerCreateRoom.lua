--LayerCreateRoom.lua
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")
local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")

local LayerCreateRoom=class("LayerCreateRoom",function(super, zindex)
    return require("Lobby/LayerPopup").put(super, zindex)
end)

function LayerCreateRoom:hide(func) 
    --self:returnLobby()
    self:setTouchEnabled(false)

    local array  = CCArray:create()

    local hidearray = CCArray:create()
    hidearray:addObject(CCFadeTo:create(0.2, 0))
    hidearray:addObject(CCTargetedAction:create(self.panel_bg, 
        CCMoveBy:create(0.2, ccp(0, AppConfig.SCREEN.CONFIG_HEIGHT))))
    array:addObject(CCSpawn:create(hidearray))

    array:addObject(CCCallFunc:create(function()
        self:setVisible(false)
        self:removeFromParentAndCleanup(true)
        if func then
            func()
        end
    end))
    self:runAction(CCSequence:create(array))
end

function LayerCreateRoom:show() 
    if self:isVisible() then
        return
    end

    local array  = CCArray:create()
    array:addObject(CCFadeTo:create(0, 0))

    --逐渐显示，下拉
    local showarray = CCArray:create()
    showarray:addObject(CCFadeTo:create(0.2, 90))
    showarray:addObject(CCTargetedAction:create(self.panel_bg, 
        CCMoveBy:create(0.2, ccp(0, -AppConfig.SCREEN.CONFIG_HEIGHT))))
    array:addObject(CCSpawn:create(showarray))

    array:addObject(CCCallFunc:create(function()
        self:selectGame() 

        self:setTouchEnabled(true)
        if show_func then
            self.show_func()
        end
    end))
    self:runAction(CCSequence:create(array))
    self:setVisible(true)
    self:setTouchEnabled(false)

    return self    
end

function LayerCreateRoom:initPanel()
    --添加背景
    self.panel_bg = loadSprite("common/popBg.png", true)
    self.panel_bg:setPreferredSize(CCSizeMake(1248, 655))
    self.bg_sz = self.panel_bg:getContentSize()
    self:addChild(self.panel_bg)
    self.panel_bg:setPosition(ccp(AppConfig.SCREEN.CONFIG_WIDTH / 2, AppConfig.SCREEN.CONFIG_HEIGHT + AppConfig.SCREEN.CONFIG_HEIGHT / 2 - 35))     

    --确定按钮 
    self.btn_create = CCButton.put(self.panel_bg, CCButton.createCCButtonByFrameName("gamerule/btnCreateRule.png", 
            "gamerule/btnCreateRule2.png", "gamerule/btnCreateRule.png", function()
                if self.rule_panel then
                    self.rule_panel:getGameRule()
                end
            end), ccp(1080, 125), self.btn_zIndex) 

    --返回按钮 
    CCButton.put(self.panel_bg, CCButton.createCCButtonByFrameName("common/btnReturn.png", 
            "common/btnReturn2.png", "common/btnReturn.png", function()
                self:getParent():returnMainPanle()
            end), ccp(40, self.bg_sz.height + 25), self.btn_zIndex)

    --重新刷新按钮
    self.tip_panel = require("Lobby/LayerPopup").createTipBtn("读取游戏信息失败，", function()
        self:selectGame() end, kCCMenuHandlerPriority - self.btn_zIndex, self.panel_bg)    
    self.tip_panel:setPosition(ccp(0, -30))

    self:setUpdateState()

    self:addGameChoice() 

    self:setVisible(false)
end

function LayerCreateRoom:addGameChoice()     
    self.panel_bg.gameTitle = {}
    local maingame = FriendGameLogic.games_config.games[1]

    self.bSelected = false --是否正在操作，尚未返回
	
    for i,v in ipairs(FriendGameLogic.games_config.games) do		
		if v == 24 then
			self.panel_bg.gameTitle[v] = CCButton.put(self.panel_bg, CCButton.createCCButtonByFrameName("gamerule/btnGame"..(v-1).."Rule2.png", 
                "gamerule/btnGame"..(v-1).."Rule1.png", "gamerule/btnGame"..(v-1).."Rule1.png", function()
                    self:selectGame(v)
                end), ccp(self.bg_sz.width / 2 - 620 + 250 * i, self.bg_sz.height+30), self.btn_zIndex)
				
		else
			self.panel_bg.gameTitle[v] = CCButton.put(self.panel_bg, CCButton.createCCButtonByFrameName("gamerule/btnGame"..v.."Rule2.png", 
                "gamerule/btnGame"..v.."Rule1.png", "gamerule/btnGame"..v.."Rule1.png", function()
                    self:selectGame(v)
                end), ccp(self.bg_sz.width / 2 - 620 + 250 * i, self.bg_sz.height+30), self.btn_zIndex)
		end

        if v == FriendGameLogic.games_config.unopened then
            local s = loadSprite("gamerule/createRuleMark.png")
            s:setPosition(ccp(80,2))
            self.panel_bg.gameTitle[v]:addChild(s)

            self.panel_bg.gameTitle[v].m_actionCallBack = function() require("HallUtils").showWebTip("即将开放，敬请期待") end    
        end

        self.panel_bg.gameTitle[v]:setEnabled(i ~= 1)
    end

    --标题
    --[[
    if AppConfig.ISAPPLE then
        self.panel_bg.gameTitle[maingame]:setPositionX(self.bg_sz.width / 2)
        self.panel_bg.gameTitle[maingame]:setEnabled(false)

        for k, v in pairs(self.panel_bg.gameTitle) do
            if k ~= maingame then
                v:setVisible(false)
            end
        end

        self.select_game = maingame
    else
    ]]
        local gameid = CCUserDefault:sharedUserDefault():getIntegerForKey("defaultGameId")
        gameid = (gameid == 0) and maingame or gameid

        self.select_game = gameid       
    -- end
end

--设置重新刷新按钮状态
function LayerCreateRoom:setUpdateState(bvalue)
    if bvalue == nil then
        self.tip_panel:setVisible(false)
        self.btn_create:setVisible(false)
        return
    end

    self.tip_panel:setVisible(not bvalue)
    self.btn_create:setVisible(bvalue)
end

-- 选择游戏
function LayerCreateRoom:selectGame(gameId)
    if self.bSelected then return end
    self.bSelected = true

    self.select_game = gameId or self.select_game
    for k, v in pairs(self.panel_bg.gameTitle) do
        v:setEnabled(k ~= self.select_game) 
    end

    local gameName = FriendGameLogic.games_config.names[self.select_game][2]

    local function updataGameBack(bUpdated)
        --游戏更新回调
        if bUpdated then
            local fileName = gameName .. "/LayerDeskRule"
            self.rule_panel = require(fileName).put(self, self.layer_zIndex + 1,                    function(bSucceed) 
                        self:setUpdateState(bSucceed)
                        self.bSelected = false 
                    end)
        else
            if require("HallUtils").isFileExit(gameName .. "/LayerDeskRule.lua") or 
                require("HallUtils").isFileExit("Games/"..gameName .. "/LayerDeskRule.lua") then
                self.rule_panel = require(gameName .. "/LayerDeskRule").put(self, self.layer_zIndex + 1, 
                    function(bSucceed) 
                        self:setUpdateState(bSucceed)
                        self.bSelected = false 
                    end)    
            end            
        end

        CCUserDefault:sharedUserDefault():setIntegerForKey("defaultGameId", self.select_game)        
    end

    --游戏更新检查
    if self.rule_panel then 
        self.rule_panel:removeFromParentAndCleanup(true) 
        self.rule_panel = nil 
    end

    self:setUpdateState()
    require("LobbyControl").updataGame(self.select_game, updataGameBack, function()
        self:setUpdateState(false)
        self.bSelected = false
    end)
end

    
function LayerCreateRoom:addCommonItem(imgSp, super, idx) 
    local item = CCLayerColor:create(ccc4(0,0,0,0))
    item:setContentSize(CCSizeMake(901, 90))
    
    -- 兼容之前接口，全部改造完成后替换
    if idx then
        if (idx%2==1) then
            item:setColor(ccc3(255,244,210))
            item:setOpacity(255)
        end
        imgSp:setPosition(ccp(90, 45))
        item:addChild(imgSp, 0, 10)
        super:addChild(item)
        return item
    else
        imgSp:setPosition(ccp(90, 45))
        item:addChild(imgSp, 0, 10)

        local lineSp = loadSprite("gamerule/createRuleLine.png")
        lineSp:setPosition(ccp(435, 3))
        item:addChild(lineSp)

        super:addChild(item)

        return item, lineSp
    end
end

--创建进度条
function LayerCreateRoom:addProcess(number, msgs, pos, super, func) 
    local bgSp = loadSprite("lobby_createroom_processbg_img.png")
    local upSp = loadSprite("lobby_createroom_processup_img.png")
    local bgsz, upsz, upUI, labUI = bgSp:getContentSize(), upSp:getContentSize(), {}, {}
    local space = bgsz.width / (number - 1)

    --标记节点
    for i=1,number - 2 do
        local pos = ccp(space * i, bgsz.height / 2)
        local bgBallSp = loadSprite("lobby_createroom_processbgball_img.png")
        bgBallSp:setPosition(ccp(pos.x, bgsz.height / 2))
        local upBallSp = loadSprite("lobby_createroom_processupball_img.png")
        upBallSp:setPosition(ccp(pos.x, upsz.height / 2))
        bgSp:addChild(bgBallSp)   
        upSp:addChild(upBallSp)  

        upBallSp:setVisible(false)
        table.insert(upUI, upBallSp)
    end

    --滑动条
    local pSlider = CCControlSlider:create(bgSp, upSp, 
                    loadSprite("lobby_createroom_process_btn.png"))
    pSlider:setAnchorPoint(ccp(0, 0))
    pSlider:setPosition(pos)
    pSlider:setMinimumValue(1 - 0.015 * number) 
    pSlider:setMaximumValue(number + 0.015 * number)
    pSlider:setMaximumAllowedValue(number)
    pSlider:setMinimumAllowedValue(1)
    pSlider:setValue(1)

    local function updataLabByIndex(labIndex)
        --修改标示文字颜色 
        for i,v in ipairs(labUI) do
            v:setColor(AppConfig.COLOR.Text_Yellow)
            v:setFontSize(36)
        end
        labUI[labIndex]:setColor(AppConfig.COLOR.Login_Error_Lab)
        labUI[labIndex]:setFontSize(44)
    end

    local function valueChanged(strEventName, pSender)
        if nil == pSender or pSender:isSelected() then
            return
        end  
        
        local index = pSender:getValue()
        index = math.floor(index + 0.5)
        pSender:setSelected(true)
        pSender:setValue(index)
        pSender:setSelected(false)

        for i,v in ipairs(upUI) do
            if i + 1 < index then
                v:setVisible(true)
            else
                v:setVisible(false)
            end
        end   

        updataLabByIndex(index)
        func(index)
    end      
    pSlider:addHandleOfControlEvent(valueChanged, CCControlEventValueChanged)
    super:addChild(pSlider)

    --添加文字标示
    for i,v in ipairs(msgs) do
        local pos = ccp(space * (i - 1), 50)
        if i==1 then
            pos.x = pos.x + 10 
        elseif i==#msgs then
            pos.x = pos.x - 15
        end

        local ttfLab = CCLabelTTF:create(v, AppConfig.COLOR.FONT_BLACK, 24)
        ttfLab:setPosition(pos)
        ttfLab:setAnchorPoint(ccp(0.5, 0))
        pSlider:addChild(ttfLab)  
        table.insert(labUI, ttfLab)      
    end
    pSlider:setValue(1)

    return pSlider
end

function LayerCreateRoom:addGameTypeTitle(super, titles, func, index)
    local nCount = #titles
    local itemSz = CCSizeMake(904 / nCount, 65)

    local gameType = {}
    for i,v in ipairs(titles) do
        local btnSps = {}
        for j=1,3 do
            local btnSp = loadSprite("gamerule/tab.png", true)
            if j ~= 1 then btnSp = loadSprite("gamerule/tab_s.png", true) end

            local tipLab = CCLabelTTF:create(v, AppConfig.COLOR.FONT_BLACK , 32)
            tipLab:setColor(AppConfig.COLOR.MyInfo_Record_Label)
            tipLab:setPosition(ccp(itemSz.width / 2, itemSz.height / 2))
            btnSp:addChild(tipLab)

            btnSp:setPreferredSize(itemSz)
            table.insert(btnSps, btnSp)
        end

        gameType[i] = CCButton.put(super, CCButton.createCCButtonByStatusSprite(
                btnSps[1], btnSps[2], btnSps[3], function()
                    func(i)
                end), ccp(itemSz.width * i - itemSz.width / 2 + 1, 590 - 35), self.btn_zIndex)

        gameType[i]:setEnabled(i ~= index)
    end

    return gameType
end

function LayerCreateRoom:addCheckGroup(msgs, tips, poses, super, zindex, grop, func, gropIndex) 
    local count = #grop
    local function onBtnCheck(tag, target, idx)
        local i = target:getTag()
        for m, n in ipairs(grop) do
            local s = n:getChildByTag(10)
            s:setVisible(false)
            if m == i then s:setVisible(true) end
        end
        func(i)
    end

    for k, v in ipairs(msgs) do
        local t = count+k
        local btn = CCControlButton:create(loadSprite("common/checkPoint1.png", true))
        btn:setPreferredSize(CCSizeMake(81,81))
        btn:setAnchorPoint(ccp(0.5, 0.5))
        btn:setPosition(poses[k])
        btn:setTouchPriority(kCCMenuHandlerPriority - self.btn_zIndex + 1)
        btn:setZoomOnTouchDown(false)
        btn:setEnabled(true)
        btn:addHandleOfControlEvent(function() LayerCreateRoom.initTip(btn) end,   CCControlEventTouchDown)
        btn:addHandleOfControlEvent(function() LayerCreateRoom.removeTip(btn); onBtnCheck(t, btn, t) end, CCControlEventTouchUpInside)
        btn:addHandleOfControlEvent(function() LayerCreateRoom.removeTip(btn) end, CCControlEventTouchUpOutside)
        btn:addHandleOfControlEvent(function() LayerCreateRoom.removeTip(btn) end, CCControlEventTouchCancel)
        btn.tipTxt = tips[k]
        btn.m_actionCallBack = onBtnCheck
        super:addChild(btn, zindex, t)
        

        local btnSp = loadSprite("common/checkPoint2.png")
        btnSp:setPosition(ccp(40.5, 40.5))
        btn:addChild(btnSp, 0, 10)
        btnSp:setVisible(false)

        local labItem = CCControlButton:create(v, AppConfig.COLOR.FONT_BLACK , 32)
        labItem:setAnchorPoint(ccp(0, 0.5))
        labItem:setPosition(ccp(65, 40.5))
        labItem:setTouchPriority(kCCMenuHandlerPriority - self.btn_zIndex + 1)
        labItem:setTitleColorForState(AppConfig.COLOR.MyInfo_Record_Label, CCControlStateNormal)
        labItem:setTitleColorForState(AppConfig.COLOR.MyInfo_Record_Label, CCControlStateHighlighted)
        labItem:setZoomOnTouchDown(false)
        labItem:setEnabled(true)
        labItem:addHandleOfControlEvent(function() LayerCreateRoom.initTip(labItem) end,   CCControlEventTouchDown)
        labItem:addHandleOfControlEvent(function() LayerCreateRoom.removeTip(labItem) end, CCControlEventTouchUpInside)
        labItem:addHandleOfControlEvent(function() LayerCreateRoom.removeTip(labItem) end, CCControlEventTouchUpOutside)
        labItem:addHandleOfControlEvent(function() LayerCreateRoom.removeTip(labItem) end, CCControlEventTouchCancel)
        labItem.tipTxt = tips[k]
        labItem.target = btn
        btn:addChild(labItem, 0, 20)

        table.insert(grop, btn)
    end

    local j = gropIndex or 1
    onBtnCheck(0, grop[j], j)
end

function LayerCreateRoom:addCheckBox(msg, tip, pos, super, zindex, func, bshow)
    local function onBtnCheck(tag, target)
        local markSp = target:getChildByTag(10)
        markSp:setVisible(not markSp:isVisible())
        local idx = markSp:isVisible() and 1 or 0  
        func(idx, markSp)
    end
    
    local btn = CCControlButton:create(loadSprite("common/check_border.png", true))
    btn:setPreferredSize(CCSizeMake(81,81))
    btn:setAnchorPoint(ccp(0.5, 0.5))
    btn:setPosition(pos)
    btn:setTouchPriority(kCCMenuHandlerPriority - self.btn_zIndex + 1)
    btn:setZoomOnTouchDown(false)
    btn:setEnabled(true)
    btn:addHandleOfControlEvent(function() LayerCreateRoom.initTip(btn) end,   CCControlEventTouchDown)
    btn:addHandleOfControlEvent(function() LayerCreateRoom.removeTip(btn); onBtnCheck(1, btn) end, CCControlEventTouchUpInside)
    btn:addHandleOfControlEvent(function() LayerCreateRoom.removeTip(btn) end, CCControlEventTouchUpOutside)
    btn:addHandleOfControlEvent(function() LayerCreateRoom.removeTip(btn) end, CCControlEventTouchCancel)
    btn.tipTxt = tip
    btn.m_actionCallBack = onBtnCheck
    super:addChild(btn, zindex)
    
    local btnSp = loadSprite("common/check.png")
    btnSp:setPosition(ccp(40.5, 40.5))
    btn:addChild(btnSp, 0, 10)
    btnSp:setVisible(bshow)

    local labItem = CCControlButton:create(msg, AppConfig.COLOR.FONT_BLACK , 32)
    labItem:setAnchorPoint(ccp(0, 0.5))
    labItem:setPosition(ccp(65, 40.5))
    labItem:setTouchPriority(kCCMenuHandlerPriority - self.btn_zIndex + 1)
    labItem:setTitleColorForState(AppConfig.COLOR.MyInfo_Record_Label, CCControlStateNormal)
    labItem:setTitleColorForState(AppConfig.COLOR.MyInfo_Record_Label, CCControlStateHighlighted)
    labItem:setZoomOnTouchDown(false)
    labItem:setEnabled(true)
    labItem:addHandleOfControlEvent(function() LayerCreateRoom.initTip(labItem) end,   CCControlEventTouchDown)
    labItem:addHandleOfControlEvent(function() LayerCreateRoom.removeTip(labItem) end, CCControlEventTouchUpInside)
    labItem:addHandleOfControlEvent(function() LayerCreateRoom.removeTip(labItem) end, CCControlEventTouchUpOutside)
    labItem:addHandleOfControlEvent(function() LayerCreateRoom.removeTip(labItem) end, CCControlEventTouchCancel)
    labItem.tipTxt = tip
    labItem.target = btn
    btn:addChild(labItem)

    return btn
end

--添加底分
function LayerCreateRoom:initBaseScore(super, poses) 
    local imgs = {"gamerule/game_fen_ttf.png", "common/diamond.png"}
    local diamondLab = nil
    for i,v in ipairs(imgs) do
        local mark = loadSprite(v)
        mark:setAnchorPoint(ccp(1, 0.5))
        mark:setPosition(poses[i])
        super:addChild(mark)

        diamondLab = CCLabelTTF:create("1", AppConfig.COLOR.FONT_BLACK, 40)
        diamondLab:setColor(AppConfig.COLOR.MyInfo_Record_Label)        
        diamondLab:setHorizontalAlignment(kCCTextAlignmentLeft)
        diamondLab:setAnchorPoint(ccp(0, 0.5))
        diamondLab:setPosition(ccp(poses[i].x + 10, poses[i].y))
        super:addChild(diamondLab)
    end

    return diamondLab
end

-- 生成提示
function LayerCreateRoom.initTip(sender)
    -- 关联目标选中
    if sender.target then
        local btn = sender.target
        local t = btn:getTag()
        if btn.m_actionCallBack then
            btn.m_actionCallBack(t,btn,t)
        end
	end
    -- 生成提示
    if (not sender.tip) and sender.tipTxt and sender.tipTxt ~= "" then
        local padding = CCSizeMake(17, 17)
        sender.tip = CCLayer:create()
        -- 箭头
        local ar = loadSprite("common/pop_arrow.png")
        ar:setAnchorPoint(ccp(0.5, 0))
        ar:setPosition(ccp(0, 0))
        sender.tip:addChild(ar, 2)
        -- 文字
        local txt = CCLabelTTF:create(sender.tipTxt, AppConfig.COLOR.FONT_ARIAL, 26)
        txt:setHorizontalAlignment(kCCTextAlignmentLeft)
        txt:setAnchorPoint(ccp(0.5, 0.5))
        txt:setColor(AppConfig.COLOR.MyInfo_Record_Label)
        -- 尺寸
        local size = txt:getContentSize()
        txt:setPosition(ccp(0, 8+size.height/2+padding.height))
        sender.tip:addChild(txt, 3)
        -- 背景
        local bg = loadSprite("common/pop_main.png", true)
        bg:setPreferredSize(CCSizeMake(size.width+padding.width*2,size.height+padding.height*2))
        bg:setPosition(ccp(0, 8+size.height/2+padding.height))
        sender.tip:addChild(bg, 1)
        
        -- 位置
        local np, ns = ccp(sender:getPosition()), sender:getContentSize()
        sender.tip:setPosition(ccp(np.x+ns.width/2, np.y+ns.height/2+2))
        sender:getParent():addChild(sender.tip)
    end
end

-- 删除提示
function LayerCreateRoom.removeTip(sender)
    if sender.tip then
        sender.tip:removeFromParentAndCleanup(true)
        sender.tip = nil
    end
end

function LayerCreateRoom.put(super, zindex)
    local layer = LayerCreateRoom.new(super, zindex)
    layer:initPanel()
    return layer
end

return LayerCreateRoom