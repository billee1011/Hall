--LayerGame.lua
local CommonInfo = require("czmj/GameDefs").CommonInfo
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")

local LayerGame=class("LayerGame",function()
        return CCLayer:create()
    end)

LayerGame.checkLocation = false

function LayerGame:init(playerNum) 
    self.player_num = playerNum or 4

    self.tipdlg_zIndex = 11
    self.result_zIndex = 9
    self.freindresult_zIndex = 8
    self.start_zIndex = 8

    self.panle_zIndex = 7
    self.more_zIndex = 6
    self.voice_zIndex = 6

    self.anima_zIndex = 5
    self.btn_zIndex = 5
    self.logo_zIndex = 4
    self.downcard_zIndex = 3
    self.card_zIndex = 2
    self.upcard_zIndex = 1
    
    --牌墙参数
    self.card_dirct = 0

    self.dice_table = {}
    self.realysp_table = {}

    --发牌数据
    self.send_cout = {4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 2, 1, 1, 1}
    self.downIndex = 6 --一行显示倒下去个数
    if self.player_num == 3 then
        self.send_cout = {4, 4, 4, 4, 4, 4, 4, 4, 4, 2, 1, 1}
        self.downIndex = 9
    end

    require("czmj/Game/GameLogic").loadingCache()

    --设置背景
    local bg =  loadSprite("czmj/images/MJDeskBg.jpg")
    bg:setScale(1.25)
    bg:setPosition(ccp(CommonInfo.View_Width / 2, CommonInfo.View_Height / 2))
    self:addChild(bg)

    self:initTimerUI()

    self.playerLogo_panel = require(CommonInfo.Code_Path.."Game/LayerGamePlayer").put(self, self.logo_zIndex)

    local versionlab = CCLabelTTF:create(""..require("GameConfig").getGameConfig("czmj").version, 
                                                AppConfig.COLOR.FONT_ARIAL, 16)      
    versionlab:setPosition(ccp(12, 12))
    versionlab:setAnchorPoint(0, 0.5)
    versionlab:setColor(ccc3(0x14, 0x32, 0x2f))
    self:addChild(versionlab)

    --标题
    local titleSp = loadSprite("czmj/images/gameTitle.png")
    titleSp:setPosition(ccp(CommonInfo.View_Width / 2, 310))
    self:addChild(titleSp)

    local function onNodeEvent(event)
        if event =="exit" then
            self:onExit()
        elseif event == "enter" then
            self:onEnter()           
        end     
    end
    self:registerScriptHandler(onNodeEvent)
    
    if debugMode then
        local function KeypadHandler(strEvent)
            if "backClicked" == strEvent and CJni:shareJni().showTextureCache then
                CJni:shareJni():showTextureCache()
            end
        end
        self:registerScriptKeypadHandler(KeypadHandler)
        self:setKeypadEnabled(true)
    end
    self.touch_enable = true
end

function LayerGame:onEnter()
    require("Lobby/Set/SetLogic").playGameGroundMusic(AppConfig.SoundFilePathName.."gaming"..AppConfig.SoundFileExtName)
end

function LayerGame:onExit()
    self:stopAllActions()
    self:gameExit()
end

function LayerGame:initGameUI() 
    CommonInfo.Logic_Path = "czmj/Game/GameLogic"

    -- 聊天
    self:initVoiceUI()

    self:initChatUI()
    
    self:initRealtimeInfoUI()

    self:initBtns() 

    --if debugMode then Cache.log("进入游戏房间后材质使用内存状况") end
end

--播放相关ui
function LayerGame:initPlayUI()
    CommonInfo.Logic_Path = "czmj/GamePlayLogic"

    self.play_panel = require(CommonInfo.Code_Path.."Game/LayerPlayGame").put(self, self.tipdlg_zIndex)
end

function LayerGame:getPlayerLogoSp(chair)
    return self.playerLogo_panel.logo_table[chair + 1]:getChildByTag(0)
end

function LayerGame:showPlayerDetail(faceSp, name, userid, ip, addInfo)
    self.current_panel = require("Lobby/Info/LayerInfo").putPlayer(
               self, self.panle_zIndex, faceSp, name, userid, ip, addInfo):show() 
end

function LayerGame:showPlayersSameIPs(users)
    if not AppConfig.ISAPPLE then
        --提示 请注意场内玩家有相同ip地址
        require("HallUtils").showWebTip("请注意场内玩家有相同ip地址", nil, nil, ccp(CommonInfo.View_Width / 2, 480))
        local HallUtils = require("HallUtils")

        for i=1,4 do
            if users[i - 1] then
                local index = require(CommonInfo.Logic_Path):getInstance():getRelativeChair(i - 1)
                local pos = ccp(40, -48)
                if index == 2 then
                    pos.x = pos.x - 65
                elseif index ~= 3 then
                    pos.x = pos.x + 65
                end

                HallUtils.showWebTip(users[i - 1].ip, self.playerLogo_panel.logo_table[i], 32, pos, 6)                
            end 
        end      
    end 
end

function LayerGame:test()
 
end

function LayerGame:initBtns()
    --开始游戏
    self.game_start = CCButton.put(self, CCButton.createCCButtonByFrameName("mjdesk/btnGameSart1.png", 
            "mjdesk/btnGameSart2.png", "mjdesk/btnGameSart1.png", function(tag, target)
                require(CommonInfo.Logic_Path):getInstance():onAutoRealy()
            end), ccp(CommonInfo.View_Width / 2, 90), self.btn_zIndex)
    self.game_start:setVisible(false)

    --返回
    self.game_returnBtn = CCButton.put(self, CCButton.createCCButtonByFrameName("mjdesk/btnExitGame1.png", 
            "mjdesk/btnExitGame2.png", "mjdesk/btnExitGame1.png", function(tag, target)
                self:showExitDlg()
            end), ccp(50, CommonInfo.View_Height - 50), self.btn_zIndex)

    --聊天
    CCButton.put(self, CCButton.createCCButtonByFrameName("mjdesk/btnGameChat1.png", 
            "mjdesk/btnGameChat2.png", "mjdesk/btnGameChat1.png", function(tag, target)
                self:showGameChat()
            end), ccp(CommonInfo.View_Width - 50, 290), self.btn_zIndex)

    if require("Lobby/FriendGame/FriendGameLogic").game_type ~= 1 then
        --定位
        self.locationBtn = CCButton.createCCButtonByFrameName("mjdesk/btn_loc1.png",
            "mjdesk/btn_loc2.png", "mjdesk/btn_loc1.png",function()
            self:showPlayerLocation()
        end)

        if not LayerGame.checkLocation then
            --设置提醒动画
            local animFrames = CCArray:create()
            for i = 1,6 do
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(
                    string.format("mjdesk/btn_loc_%d.png", i))
                animFrames:addObject(frame)
            end
            local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.1)
            local animate = CCAnimate:create(animation);
            self.locationBtn.m_normalSp:runAction(CCRepeatForever:create(animate))
        end
        local btn = CCButton.put(self, self.locationBtn, 
            ccp(CommonInfo.View_Width - 50, CommonInfo.View_Height - 137), self.btn_zIndex)

    end

    --更多
    self:addMoreCheck()
end

--创建聊天
function LayerGame:initChatUI()
    self.layerChat = require(CommonInfo.Code_Path.."Game/LayerChat").put(self, self.panle_zIndex)
    self.layerChatShow = require(CommonInfo.Code_Path.."Game/LayerChatShow").put(self, self.panle_zIndex)
    self.layerChat.layerShow = self.layerChatShow
end

--显示聊天
function LayerGame:showGameChat()
    self.layerChat:show()
    self.current_panel = self.layerChat
end

-- 语音聊天按钮及相关UI
function LayerGame:initVoiceUI()
    -- cclog("LayerGame:initVoiceUI: ")
    self.voicePanel = require(CommonInfo.Code_Path.."Game/LayerVoice").create()
    self:addChild(self.voicePanel, self.voice_zIndex)
end

-- 电量、信号及相关UI
function LayerGame:initRealtimeInfoUI()
    cclog("LayerGame:initRealtimeInfoUI: ")
    self.realtimeInfoPanel = require(CommonInfo.Code_Path.."Game/LayerRealtimeInfo").create()
    self.realtimeInfoPanel:setPosition(CommonInfo.View_Width - 235, CommonInfo.View_Height - 32)
    self:addChild(self.realtimeInfoPanel, self.panle_zIndex)
end

--添加好友卓提示
function LayerGame:initFriendGameUI() 
    if not self.residue_friendgame then
        local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")

        local bg = loadSprite("mjdesk/residueBg.png", true)
        local bgsz = CCSizeMake(135, 60)
        bg:setPreferredSize(bgsz)
        bg:setPosition(ccp(160, CommonInfo.View_Height - 44))
        self:addChild(bg, self.btn_zIndex)

        --房间号、局数
        local labmsgs = {"房间 "..FriendGameLogic.invite_code, "局数 "..FriendGameLogic.game_used.."/"..FriendGameLogic.my_rule[1][2]}
        for i=1,2 do
            self.residue_friendgame = CCLabelTTF:create(labmsgs[i], 
                                                        AppConfig.COLOR.FONT_ARIAL, 20)  
            self.residue_friendgame:setAnchorPoint(ccp(0, 0.5))                                                        
            self.residue_friendgame:setPosition(ccp(10, bgsz.height / 2 + 40 - 26 * i))
            bg:addChild(self.residue_friendgame)
        end
        self:updataReturnBtn()
        
        self:initFriendGameRule()

        return true
    else
        self:updataFriendGameUI(0)
    end

    return false
end

function LayerGame:initFriendGameRule() 
    local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")

    --类型标示 
    local marks,xspace,bLaizi = {}, 20
    --人数标识
    table.insert(marks, loadSprite("czmj/playerNumber_"..self.player_num..".png"))
    --规则信息
    if #FriendGameLogic.my_rule > 2 then
        for i=3,#FriendGameLogic.my_rule do
            local index = FriendGameLogic.my_rule[i][1] - 3
            local value = FriendGameLogic.my_rule[i][2]

            if index == 97 then
                --飘修改
                table.insert(marks, loadSprite("czmj/gameRule3_"..value..".png"))
            else
                table.insert(marks, loadSprite("czmj/gameRule"..index..".png"))
                if index == 1 then
                    bLaizi = true
                    if value == 2 then
                        --红中赖子
                        table.insert(marks, loadSprite("czmj/gameRule0.png"))
                    end
                end
            end
        end
    end

    --无红中赖子
    if not bLaizi then
        table.insert(marks, 1, loadSprite("czmj/gameRule-1.png"))        
    end

    local function addDianMark()
        --添加逗号
        local dianSp = loadSprite("czmj/commaMark.png")
        dianSp:setAnchorPoint(ccp(0, 1))
        dianSp:setPosition(ccp(CommonInfo.View_Width / 2 - 305 + xspace, CommonInfo.View_Height / 2 + 240))
        xspace = xspace + dianSp:getContentSize().width + 6
        self:addChild(dianSp)
    end
    for i,v in ipairs(marks) do
        if i > 1 then
            addDianMark()            
        end   

        --类型标示
        v:setAnchorPoint(ccp(0, 0.5))
        v:setPosition(ccp(CommonInfo.View_Width / 2 - 305 + xspace, CommonInfo.View_Height / 2 + 240))
        xspace = xspace + v:getContentSize().width
        self:addChild(v)              
    end 

    --鸟
    if #marks > 0 then
        addDianMark()
    end
    local birdsp = loadSprite("czmj/gameBird"..FriendGameLogic.my_rule[2][2]..".png")
    birdsp:setAnchorPoint(ccp(0, 0.5))
    birdsp:setPosition(ccp(CommonInfo.View_Width / 2 - 305 + xspace, CommonInfo.View_Height / 2 + 240))
    self:addChild(birdsp)  
end

function LayerGame:addFriendInviteUI() 
    if not self.invite_btn then
        self.invite_btn = CCButton.put(self, CCButton.createCCButtonByFrameName("mjdesk/btnInviteFriend1.png", 
                "mjdesk/btnInviteFriend2.png", "mjdesk/btnInviteFriend1.png", 
                function()
                    if ClientLoginByIMIE then
                        require("HallUtils").showWebTip("采用微信方式登录才能邀请好友")
                        return
                    end
                    local now, all = require(CommonInfo.Logic_Path):getInstance():getPlayeCount()

                    --微信好友
                    local msg, titile, roominfo = require("czmj/LayerDeskRule").getInviteMsg()
                    if now > 0 then 
                        local tipMsgs = {"一", "二", "三", "四",}
                        titile = titile.."，"..tipMsgs[now].."缺"..tipMsgs[(all - now)] 
                    end

                    local url = AppConfig.WXMsg.App_Url..roominfo
                    shareWebToWx(1, url, titile, msg, function()end)
                end), ccp(CommonInfo.View_Width / 2, CommonInfo.View_Height / 2 - 145), self.btn_zIndex)                           
    end

    local FriendLogic = require("Lobby/FriendGame/FriendGameLogic")
    self.invite_btn:setVisible(not AppConfig.ISAPPLE and not FriendLogic.game_abled and FriendLogic.game_type == 0)
end

function LayerGame:setTimerFunc(labttf, msg, timeSeces, clearFunc, ctype)
    local pDirector, secesTimer = CCDirector:sharedDirector()
    local function timerFunc()
        if secesTimer == nil then
            return
        end

        local temp = "00:00:00"
        timeSeces = timeSeces - 1
        if timeSeces > 0 then
            temp = string.format("%02d:%02d:%02d", 
                math.floor(timeSeces % 86400 / 3600), math.floor(timeSeces % 86400 % 3600 / 60), timeSeces % 86400 % 3600 % 60)
        end
        if ctype then
            temp = string.sub(temp,4,-1)
        end
        labttf:setString(msg..temp)


        if timeSeces < 0 then
            clearFunc()
        end
    end

    secesTimer = pDirector:getScheduler():scheduleScriptFunc(timerFunc,1,false)
    return secesTimer
end

function LayerGame:addFriendTableTime(exprireTime, validTime) 
    if not require("Lobby/FriendGame/FriendGameLogic").game_abled then
        self:clearFriendValidTimerUI()

        --尚未开始有效时间
        local tipbg =  loadSprite("lobby_message_tip_bg.png")
        tipbg:setPosition(ccp(AppConfig.SCREEN.CONFIG_WIDTH / 2, AppConfig.SCREEN.CONFIG_HEIGHT / 2 + 110)) 
        self:addChild(tipbg, self.voice_zIndex)   
        local bgsz = tipbg:getContentSize()

        local msgs, posy = {"30分钟未开始游戏，系统自动解散房间", string.format("%02d:%02d", 
                    math.floor(validTime % 86400 % 3600 / 60), validTime % 86400 % 3600 % 60)}, {bgsz.height / 2 + 26, bgsz.height / 2 - 26}
        local ftsz, tempLab = {26, 40}
        for i,v in ipairs(ftsz) do
            tempLab = CCLabelTTF:create(msgs[i], AppConfig.COLOR.FONT_ARIAL, v)
            tempLab:setPosition(ccp(bgsz.width / 2, posy[i]))
            tempLab:setDimensions(CCSizeMake(bgsz.width, 0))
            tempLab:setHorizontalAlignment(kCCTextAlignmentCenter)
            tipbg:addChild(tempLab)
        end 

        self.friendValid_timerBg = tipbg
        self.friendValid_timer = self:setTimerFunc(tempLab, "", validTime, function()
            if self.friendValid_timer ~= nil then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.friendValid_timer)
                self.friendValid_timer = nil       
            end
        end, 1)  

        --self:clearFriendValidTimerUI()  
    end
    
    --[[房间剩余时间
    self.friendExprire_ttf = CCLabelTTF:create("", 
                                                AppConfig.COLOR.FONT_ARIAL, 30)  
    self.friendExprire_ttf:setAnchorPoint(ccp(0, 0.5))                                                        
    self.friendExprire_ttf:setPosition(ccp(25, CommonInfo.View_Height - 145))
    self:addChild(self.friendExprire_ttf)
    self.friendExprire_timer = self:setTimerFunc(self.friendExprire_ttf, "有效时间 ", exprireTime, function()
        if self.friendExprire_timer ~= nil then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.friendExprire_timer)
            self.friendExprire_timer = nil       
        end
    end)
    self.friendExprire_ttf:setVisible(false)]]
end

function LayerGame:updataFriendGameUI(nCount) 
    local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")

    self.residue_friendgame:setString("局数 "..FriendGameLogic.game_used.."/"..FriendGameLogic.my_rule[1][2])
    self:addFriendInviteUI()

    if self.game_dismiss then
        self.game_dismiss:setVisible(FriendGameLogic.game_type == 0)
    end

    self:updataReturnBtn()

    self:clearFriendValidTimerUI()   
end

function LayerGame:updataReturnBtn() 
    local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
    self.game_returnBtn:setVisible(not FriendGameLogic.game_abled)

    if FriendGameLogic.game_abled then
        self.residue_friendgame:getParent():setPositionX(80)
    else
        self.residue_friendgame:getParent():setPositionX(160)
    end   

    if FriendGameLogic.game_type == 1 then
        --练习场，设置退出按钮
        self.residue_friendgame:getParent():setPositionX(160)
        self.game_returnBtn:setVisible(true)
    end
end

function LayerGame:addMoreCheck()
    if require("Lobby/FriendGame/FriendGameLogic").game_type ~= 1 then
        local morePanel, dismisBtn = require(CommonInfo.Code_Path.."Game/LayerMore").put(self, self.more_zIndex)
        self.morePanel = morePanel
        self.game_dismiss = dismisBtn

        CCButton.put(self, CCButton.createCCButtonByFrameName("mjdesk/btnShowMore1.png", 
                "mjdesk/btnShowMore2.png", "mjdesk/btnShowMore1.png", function()
                        morePanel:show()
                end), ccp(CommonInfo.View_Width - 50, CommonInfo.View_Height - 50), self.btn_zIndex)
    end
end

--清空游戏桌
function LayerGame:resetGameDesk()
    self:clearGameDesk()
    self:clearResultDesk()
end

--清空游戏桌
function LayerGame:clearGameDesk()
    if self.player_panel then
        for i=1,4 do
            if self.player_panel[i] then
                self.player_panel[i]:removeFromParentAndCleanup(true)
            end
        end
        self.player_panel = nil
    end

    self:playTimerAnima()

    self.playerLogo_panel:clearAllMark()
end

--清空游戏桌
function LayerGame:clearResultDesk()
    --飘
    if self.piao_panel then
        self.piao_panel:removeFromParentAndCleanup(true)
        self.piao_panel = nil
    end

    if self.result_panel then
        self.result_panel:removeFromParentAndCleanup(true)
        self.result_panel = nil
    end
end

function LayerGame:gameStart(meChair, func)
    self.player_panel[meChair + 1]:gameStart(func) 
    for i,v in ipairs(self.dice_table) do
        v:removeFromParentAndCleanup(true)
    end
    self.dice_table = {}
    --self.friendExprire_ttf:setVisible(true)
end

function LayerGame:stopGameOperator()
    self.player_panel[require(CommonInfo.Logic_Path):getInstance().wChair + 1]:gameEnd()

    --取消倒计时
    self:playTimerAnima()   

    if self.current_panel and self.current_panel:isVisible() then
        self.current_panel:hide()
        self.current_panel = nil
    end
end

function LayerGame:gameEnd()
    self.residue_bg:removeFromParentAndCleanup(true)
    self.residue_bg = nil

    local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
    if require("Lobby/FriendGame/FriendGameLogic").game_type == 1 then
        --练习场重置游戏局数
        FriendGameLogic.game_used = 0
        FriendGameLogic.game_abled = false
        self:updataReturnBtn()
    end    
    --self.game_start:setVisible(true)
end

function LayerGame:gameExit()
    self:clearSecesTimerScript()

    require("CocosAudioEngine")
    AudioEngine.stopMusic(true)

    require("Lobby/Set/SetLogic").saveSet()
    require("Lobby/Set/SetLogic").music_path = nil
end

--添加自己的牌墙
function LayerGame:addPlayerPanel(chair, banker, sameIPs, backfunc)
    local dictype, dicnum = self:initCardPanle(banker)
    self:playDiceAnima(dictype, dicnum, function()
        self:playGameCardAnima()
        self:startCardAnim(chair, banker, sameIPs, backfunc)
    end)

    self:playGameRealyAnima()

    return self
end

function LayerGame:initCardPanle(banker)
    self.playerLogo_panel:updataPlayerBanker(banker)
    self.card_count = require(CommonInfo.Logic_Path):getInstance().cbGameCardCount
    local cardnums, carduis = {14, 14, 14, 14}, {}
    if self.card_count ~= 112 then
        cardnums = {14, 13, 13, 14}
    end

    --动画位置
    self.anim_poses = {}
    local animposes = {ccp(CommonInfo.View_Width / 2, 185), 
            ccp(CommonInfo.View_Width - 245, CommonInfo.View_Height / 2 + 30), ccp(CommonInfo.View_Width / 2, CommonInfo.View_Height / 2 + 200),
            ccp(250, CommonInfo.View_Height / 2 + 30)}

    local tempPanel = {}
    self.player_panel = {}
    local files = {"LayerMyCard", "LayerSouthCard", "LayerNorthCard", "LayerWestCard"}
    local zindex = {3, 4, 2, 1}
    for i,v in ipairs(zindex) do
        local chair = require(CommonInfo.Logic_Path):getInstance():getAbsolutelyChair(v)
        self.player_panel[chair + 1] = require(CommonInfo.Code_Path.."Game/"..files[v]).put(self, self.downcard_zIndex)
        self.anim_poses[chair + 1] = animposes[v]

        --创建牌墙
        if self.player_num == 4 then
            carduis[chair + 1] = self.player_panel[chair + 1]:addCardWall(cardnums[v])
        else
            --三人固定牌墙顺序
            carduis[v] = self.player_panel[chair + 1]:addCardWall(cardnums[v])
        end
    end

    --设置牌墙   
    self:addResidueCardUI()
    return self:setSiceData(carduis)
end

function LayerGame:startCardAnim(chair, banker, sameIPs, backfunc)
    --动画
    local array = CCArray:create()
    for i=1,self.player_num do
        local index = i - 1
        if chair ~= index then
            local count = 13
            if banker == index then
                count = 14
                array:addObject(CCCallFunc:create(function() self.player_panel[i]:getHandPaisAnima(count,  true) end))
            else
                array:addObject(CCCallFunc:create(function() self.player_panel[i]:getHandPaisAnima(count,  false) end))
            end
            
        end      
    end            
    array:addObject(CCCallFunc:create(function()         
        self.player_panel[chair + 1]:getHandPaisAnima(function()
            self:playTimerAnima(banker)

            if sameIPs then
                self:showPlayersSameIPs(sameIPs)
            end

            self:gameStart(chair, backfunc)
        end, chair == banker)  
    end))
    self:runAction(CCSequence:create(array))  
end

--添加自己的牌墙
function LayerGame:addPlayerStaticPanel(chair, cards, counts)
    for i=1,self.player_num do
        if chair + 1 == i then
            self.player_panel[i]:initHandPais(cards)
        else
            self.player_panel[i]:initHandPais(counts[i])
        end      
    end 

    return self    
end

function LayerGame:addOpenStaticPanel(chair, cards)
    for i=1,self.player_num do
        if chair + 1 == i then
            self.player_panel[i]:initHandPais(cards[i])
        else
            self.player_panel[i]:initPublicHandPais(cards[i])
        end
    end 

    return self    
end

--添加弃掉的牌
function LayerGame:addPlayerStaticDiscardCard(chair, banker, cbDiscardCard, bGameing)
    self:initCardPanle(banker)

    for i,v in ipairs(cbDiscardCard) do
        for j,w in ipairs(v) do
            self.player_panel[i]:addStaticPassed(w)
        end

    end

    if bGameing then self:playGameRealyAnima() end
    
    return self    
end

--显示游戏规则
function LayerGame:showGameRule() 
    if not self.rule_panel then
        self.rule_panel = require(CommonInfo.Code_Path.."LayerGameRule").put(self, self.panle_zIndex)
    end

    self.rule_panel:show()
    self.current_panel = self.rule_panel
end

--显示游戏规则
function LayerGame:showGameSet() 
    self.current_panel = require(CommonInfo.Code_Path.."Game/LayerGameSet").put(self, self.panle_zIndex):show()
end

--截屏
function LayerGame:shareToWx() 
    if ClientLoginByIMIE then
        require("HallUtils").showWebTip("采用微信方式登录才能截屏上报问题")
        return
    end
    self.morePanel:hide()
    shareScreenToWx(1, 75, "截屏", "游戏截图上报", function() end)
end

function LayerGame:showGameDismiss()     
    require("Lobby/FriendGame/FriendGameLogic").showDismissTipDlg(self, self.panle_zIndex, require(CommonInfo.GameLib_File))
end

function LayerGame:showPlayerLocation() 
    local GameLogic = require("czmj/Game/GameLogic"):getInstance()
    local chair = GameLogic.wChair
    local userList = require("HallUtils").tableDup(GameLogic.user_list)

    local users = {}
    for k, v in pairs(userList) do
        if v ~= 0 then
            table.insert(users, v)
        end
    end

    if not LayerGame.checkLocation then
        self.locationBtn.m_normalSp:stopAllActions()
        self.locationBtn.m_normalSp:setDisplayFrame(
            CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("mjdesk/btn_loc1.png")
        )
        LayerGame.checkLocation = true
    end
    self.current_panel = require("Lobby/Info/LayerLocation").put(self, self.panle_zIndex, 
        self.player_num, users, chair):show()
end


--显示游戏规则
function LayerGame:showExitDlg() 
    require(CommonInfo.Logic_Path):getInstance():returnToLobby()
end

function LayerGame:delayExitGame() 
    --require("HallUtils").showWebTip("您的游戏已解散，3s后自动返回大厅")
    self:clearFriendValidTimerUI()

    local array = CCArray:create()
    array:addObject(CCDelayTime:create(1))
    array:addObject(CCCallFunc:create(function()
        if not require(CommonInfo.Logic_Path):getInstance().bGameEnd then
            require(CommonInfo.Logic_Path):getInstance():returnToLobby()
        end
    end))

    self:runAction(CCSequence:create(array))    
end

--添加玩家输赢特效
function LayerGame:addGoldResult(scores, func, clearfunc)
    self.playerLogo_panel:addGoldResult(scores)

    --设置回调函数
    local array = CCArray:create()
    array:addObject(CCDelayTime:create(2.8))
    array:addObject(CCCallFunc:create(func))
    array:addObject(CCDelayTime:create(0.2))
    array:addObject(CCCallFunc:create(function()
        self.playerLogo_panel:removeTagMarks(4)
        clearfunc()
    end))

    self:runAction(CCSequence:create(array))  
end

function LayerGame:addBirdPanel(birds, valids, func) 
    require(CommonInfo.Code_Path.."Game/LayerBirdResult").put(self, self.freindresult_zIndex)
                :show(birds, valids, func)
    return self
end

function LayerGame:waitForPiao(scese)
    if not self.result_panel then
        if self.piao_panel then
            self.piao_panel:show()
        elseif require("czmj/Game/GameLogic").isLogicExist() then
            self.game_start:setVisible(true)
            require("czmj/Game/GameLogic"):getInstance():onEnterGameView()
        end
    end

    return self
end

function LayerGame:addPiaoPanel(score)
    if not self.piao_panel then
        self.piao_panel = require(CommonInfo.Code_Path.."Game/LayerPiao").put(self, self.freindresult_zIndex, score)
    end

    if not self.result_panel then
        self.piao_panel:show()
    end
	--self.game_start:setVisible(false) 
    return self
end

function LayerGame:addPiaoMark()
    --飘
    if not self.result_panel then
        --显示所有玩家的飘
        for i,v in ipairs(require(CommonInfo.Logic_Path):getInstance().bIsPiao) do
            self.playerLogo_panel:updataPlayerPiao(v)
        end
    end

    return self
end

function LayerGame:addResultPanel(ctype) 
    local function resultBack()
        self.result_panel:removeFromParentAndCleanup(true)
        self.result_panel = nil 
        require(CommonInfo.Logic_Path):getInstance().bGameEndState = 2

        --清空桌面
        self:clearGameDesk()

        if self.freindresult_panel then
            self.freindresult_panel:show()
            return
        else
            if require("Lobby/FriendGame/FriendGameLogic").isRulevalid(100) then
                self:addPiaoPanel(5)
                self:addPiaoMark()
            end

            self:waitForPiao(0)
        end
    end

    if ctype then
        self.result_panel = require(CommonInfo.Code_Path.."Game/LayerGameResult").put(self, self.result_zIndex, ctype, function(tag, target)                            
                                resultBack()
                            end)
    else
        self.result_panel = require(CommonInfo.Code_Path.."Game/LayerGameResult").putLiuJu(self, self.result_zIndex, function(tag, target)                            
                                resultBack()
                            end)        
    end
    
    return self
end

function LayerGame:addFriendResultPanel(info)
    --self.game_start:setVisible(false)
    self.freindresult_panel = require(CommonInfo.Code_Path.."LayerDeskResult").put(self, self.freindresult_zIndex, info)
    if not self.result_panel then
        --中途解散
        self.freindresult_panel:show()
        
        if self.player_panel and 
            self.player_panel[require(CommonInfo.Logic_Path):getInstance().wChair + 1] then
            --正在游戏中，停止游戏操作
            self:stopGameOperator()

            self:gameEnd()
        end
    end
end

--添加剩余牌数提示
function LayerGame:addResidueCardUI() 
    self.residue_bg = loadSprite("mjdesk/residueBg.png", true)
    local bgsz = CCSizeMake(86, 44)
    self.residue_bg:setPreferredSize(bgsz)
    self.residue_bg:setPosition(ccp(200, CommonInfo.View_Height - 44))
    self:addChild(self.residue_bg, self.btn_zIndex)
    
    local mark = loadSprite("mjBack/mjbg_201.png")
    mark:setScale(0.55)
    mark:setPosition(ccp(20, bgsz.height / 2))
    self.residue_bg:addChild(mark)

    self.residue_card = CCLabelAtlas:create(""..self.card_count, CommonInfo.Mj_Path.."num_residue.png",14,24,string.byte('0'))
    self.residue_card:setAnchorPoint(ccp(0, 0.5))
    self.residue_card:setPosition(ccp(35, bgsz.height / 2))
    self.residue_bg:addChild(self.residue_card)

    if require("Lobby/FriendGame/FriendGameLogic").game_type == 1 then
        --练习场
        self.residue_bg:setPositionX(280)
    end    
end

--游戏牌墙发牌
function LayerGame:playGameCardAnima()
    --发牌
    local array = CCArray:create()
    for i,v in ipairs(self.send_cout) do
        array:addObject(CCDelayTime:create(0.15))
        array:addObject(CCCallFunc:create(function() self:getGameCardAnima(v) end))
    end

    self:runAction(CCSequence:create(array))

end

--设置牌墙起始位置
function LayerGame:setSiceData(carduis)
    local logic = require(CommonInfo.Logic_Path):getInstance()
    local cardType, cardNum = logic.cbSiceData[1], logic.cbSiceData[2]
    if cardType < cardNum then
        cardType, cardNum = cardNum, cardType
    end

    --设置牌墙
    self.card_table = {}
    local cardDirc = (cardType + logic.wBankerUser - 1) % 4
    for i=1,4 do
        local wallIndex = (cardDirc - i + 4) % 4 + 1
        for j,v in ipairs(carduis[wallIndex]) do
            table.insert(self.card_table, v)
        end
    end

    --设置牌墙起始位置
    local start = 2 * cardNum - 2
    local uis = require("HallUtils").tableDup(self.card_table)
    for i=1,self.card_count do
        local index = start + i
        if index > self.card_count then
            index = index % self.card_count
        end
        self.card_table[i] = uis[index]
    end

    return cardType, cardNum
end

--设置取牌方向
function LayerGame:setCardDirct(dirct)
    self.card_dirct = dirct or 0
end

function LayerGame:removeOneCard()
    local count = #self.card_table

    if self.card_dirct == 0 or count == 1 then
        --顺序获取
        self.card_table[1]:removeFromParentAndCleanup(true)
        table.remove(self.card_table, 1)
    else
        if self.card_table[count].card_type ~= self.card_table[count - 1].card_type then
            self.card_table[count]:removeFromParentAndCleanup(true)
            table.remove(self.card_table, count)
        else
            self.card_table[count - 1]:removeFromParentAndCleanup(true)
            table.remove(self.card_table, count - 1)            
        end
    end

    self:setCardDirct()

    return true
end

--获取牌墙的牌
function LayerGame:getGameCardAnima(count)
    for i=1,count do
        if not self:removeOneCard() then
            break
        end
    end

    --刷新剩余牌数
    local num = #self.card_table
    local str = ""..num
    if num < 10 then
        str = "0"..num
    end

    self.residue_card:setString(str)
end

function LayerGame:hideArrowAnima()
    for i=1,self.player_num do
        self.player_panel[i]:addCardArrowAnima(false, ccp(-100, -100))
    end
end

--添加倒计时UI
function LayerGame:initTimerUI() 
    local timerBg = loadSprite("mjdesk/mjTimerBg.png")

    local bgsz = timerBg:getContentSize()
    timerBg:setPosition(ccp(CommonInfo.View_Width / 2, 417))
    self:addChild(timerBg)  

    self:initTimerSecesUI()
end

--倒计时
function LayerGame:initTimerSecesUI()
    --游戏倒计时
    self.timer_atls = CCLabelAtlas:create("00",  CommonInfo.Mj_Path.."num_scese.png",25,30,string.byte('0'))
    self.timer_atls:setAnchorPoint(ccp(0.5, 0.5))
    self.timer_atls:setPosition(ccp(CommonInfo.View_Width / 2, 423))
    self:addChild(self.timer_atls)
    self.timer_atls:setVisible(false)
end

function LayerGame:setTimerDirct(index)
    self.timer_dirct = loadSprite("mjdesk/mjTimerDirct"..index..".png")
    self.timer_dirct:setPosition(ccp(CommonInfo.View_Width / 2, 417))
    self:addChild(self.timer_dirct)

    --三人模式隐藏方位
    if self.player_num == 3 then self.timer_dirct:setVisible(false) end

    local AnimationUtil = require("Lobby/Common/AnimationUtil")
    self.direct_flicker = {}
    for i=1,self.player_num do
        local chair = require(CommonInfo.Logic_Path):getInstance():getRelativeChair(i - 1) - 1
        if chair == 0 then
            self.direct_flicker[i] = loadSprite("mjdesk/mjTimerFlicker_2_3.png")
        else
            self.direct_flicker[i] = loadSprite("mjdesk/mjTimerFlicker_"..(3 - chair).."_4.png")
        end
        --self.direct_flicker[i] = loadSprite("img_timer_flicker_"..index.."_"..i..".png")

        self.direct_flicker[i]:setPosition(ccp(CommonInfo.View_Width / 2, 417))
        self:addChild(self.direct_flicker[i])
        AnimationUtil.runFlickerAction(self.direct_flicker[i], true)
        self.direct_flicker[i]:setVisible(false)
    end
  
end

function LayerGame:playTimerSecesAnima(seces)
    function clearSecesTimerScript()
        if self.seces_timer ~= nil then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.seces_timer)
            self.seces_timer = nil       
        end
    end

    clearSecesTimerScript()
    self.timer_atls:setVisible(true)

    --倒计时
    local pDirector = CCDirector:sharedDirector()
    local function timerFunc()
        if self.seces_timer == nil then
            return
        end

        seces = seces - 1
        local str = ""..seces
        if seces < 10 then
            str = "0"..seces
        end

        --显示倒计时数字
        self.timer_atls:setString(str)
        --判断
        if seces < 1 then
            clearSecesTimerScript()
        end 
        
        -- 震动
        local SetLogic = require("Lobby/Set/SetLogic")
        if require(CommonInfo.Logic_Path).isLogicExist() and
            require(CommonInfo.Logic_Path):getInstance().bSender then
            if seces <= 3 then
                SetLogic.playGameShake(100)
                SetLogic.playGameEffect(AppConfig.SoundFilePathName.."warn_effect"..AppConfig.SoundFileExtName)
            else                
                --SetLogic.playGameEffect(AppConfig.SoundFilePathName.."second_effect"..AppConfig.SoundFileExtName)
            end
        end
    end
    self.seces_timer = self.seces_timer or pDirector:getScheduler():scheduleScriptFunc(timerFunc,1,false)
end

function LayerGame:clearFriendValidTimerUI()
    if self.friendValid_timerBg ~= nil then
        self.friendValid_timerBg:removeFromParentAndCleanup(true)
        self.friendValid_timerBg = nil       
    end

    if self.friendValid_timer ~= nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.friendValid_timer)
        self.friendValid_timer = nil       
    end

end

function LayerGame:clearSecesTimerScript()
    if self.seces_timer ~= nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.seces_timer)
        self.seces_timer = nil       
    end

    if self.friendExprire_timer ~= nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.friendExprire_timer)
        self.friendExprire_timer = nil       
    end

    self:clearFriendValidTimerUI()   
end

--打色动画
function LayerGame:playDiceAnima(cardType, cardNum, backfunc)
    require("Lobby/Set/SetLogic").playGameEffect(AppConfig.SoundFilePathName.."dice_effect"..AppConfig.SoundFileExtName)

    local array  = CCArray:create()
    local dices, pos = {}, ccp(CommonInfo.View_Width / 2, 425)
    local function addTwoDice(numbers, index, secs, ration, func)
        local twoDice = {}
        local arrayRotate = CCArray:create()

        for j=1,2 do
            local rotate = CCArray:create()
            twoDice[j] = loadSprite("mjdesk/dice"..numbers[j]..".png")
            twoDice[j]:setPosition(pos)
            twoDice[j]:setVisible(false)
            self:addChild(twoDice[j])
            twoDice[j]:setRotation(720 * index)

            rotate:addObject(CCShow:create())
            rotate:addObject(CCRotateBy:create(secs, ration))

            arrayRotate:addObject(CCTargetedAction:create(twoDice[j], CCSequence:create(rotate)))
        end
        array:addObject(CCSpawn:create(arrayRotate))
        array:addObject(CCCallFunc:create(function()
            if func then
                func()
            else
                twoDice[1]:removeFromParentAndCleanup(true)
                twoDice[2]:removeFromParentAndCleanup(true)
            end
        end))

        twoDice[1]:setAnchorPoint(ccp(1, 0.5))
        twoDice[2]:setAnchorPoint(ccp(0, 0.5))

        return twoDice
    end

    math.randomseed(os.time())  
    ----然后不断产生随机数  
    for i=1,7 do
        local secs = 0.15 + math.abs(i - 4) * 0.05
        addTwoDice({math.random(6), math.random(6)}, i, secs, 720)
    end
    self.dice_table = addTwoDice({cardType, cardNum}, 13, 0.35, 720, function()
        backfunc()
    end)

    self:runAction(CCSequence:create(array))
end

function LayerGame:playTimerAnima(chair)
    for i=1,self.player_num do
        self.direct_flicker[i]:setVisible(false)
    end
    self.timer_atls:setVisible(false)
    if self.seces_timer ~= nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.seces_timer)
        self.seces_timer = nil       
    end        

    if chair and self.direct_flicker[chair + 1] then
        self.direct_flicker[chair + 1]:setVisible(true)
        self:playTimerSecesAnima(10)
        self.playerLogo_panel:updataPlayerOperator(chair, true)
    end
end

function LayerGame:playOperatorAnima(img, chair, func)
    local sprite = loadSprite("mjAnima/img_operator_"..img..".png")
    sprite:setPosition(self.anim_poses[chair + 1])
    self:addChild(sprite, self.anima_zIndex)

    require("Lobby/Common/AnimationUtil").spriteScaleAction(sprite, function()
        sprite:removeFromParentAndCleanup(true)
        if func then
            func()
        end
    end)
end

function LayerGame:onUserRealy(chair)
    if chair == 1 then
        --自己已经准备
        self.game_start:setVisible(false)   

        if self.player_panel then
            for i=1,4 do
                if self.player_panel[i] then
                    self.player_panel[i]:removeFromParentAndCleanup(true)
                end
            end
            self.player_panel = nil
        end

        self:playTimerAnima()
        
        self:clearResultDesk()        
    end
end

--游戏准备动画
function LayerGame:playGameRealyAnima(bshow, index)
    if bshow then        
        if self.realysp_table[index + 1] then
            return
        end

        local chair = require(CommonInfo.Logic_Path):getInstance():getRelativeChair(index)
        local poses = {ccp(CommonInfo.View_Width / 2,  145), ccp(CommonInfo.View_Width - 293, CommonInfo.View_Height / 2 + 66),
                ccp(CommonInfo.View_Width / 2,  613), ccp(300, CommonInfo.View_Height / 2 + 66)}
        self:onUserRealy(chair)

        local bgsprite = loadSprite("mjdesk/realyTip.png")
        local bgsz = bgsprite:getContentSize()
        bgsprite:setPosition(poses[chair])
        self:addChild(bgsprite, self.anima_zIndex)
        self.realysp_table[index + 1] = bgsprite

        local array = CCArray:create()
        for i=1,4 do
            local dot = loadSprite("mjdesk/waitPt.png")
            dot:setPosition(ccp(bgsz.width + 20 * i, bgsz.height / 2))            
            bgsprite:addChild(dot, i, i)
            dot:setOpacity(0)
            array:addObject(CCTargetedAction:create(dot, CCFadeIn:create(0.3)))
        end   
        array:addObject(CCCallFunc:create(function()
            for i=1,4 do
                bgsprite:getChildByTag(i):setOpacity(0)
            end
        end))     
        bgsprite:runAction(CCRepeatForever:create(CCSequence:create(array)))

    elseif index then
        local item = self.realysp_table[index + 1]
        if item then
            item:removeFromParentAndCleanup(true)
            self.realysp_table[index + 1] = nil
        end
    else
        for i=1,self.player_num do
            if self.realysp_table[i] then
                self.realysp_table[i]:removeFromParentAndCleanup(true)
                self.realysp_table[i] = nil
            end
        end
    end
end

function LayerGame.create(playerNum)
    local layer = LayerGame.new()
    layer:init(playerNum)
    layer:test()
    return layer
end

function LayerGame.createScene(playerNum)
	local layer = LayerGame.create(playerNum)
	local scene = CCScene:create()
	scene:addChild(layer)
	return scene, layer
end

 return LayerGame