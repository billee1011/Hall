--FriendGameLogic.lua
local FriendGameLogic = {}
FriendGameLogic.__index = FriendGameLogic
local LobbyControl = require("LobbyControl")
local WebRequest = require("GameLib/common/WebRequest")
local LoginLogic = require("Lobby/Login/LoginLogic")
local AppConfig = require("AppConfig")

FriendGameLogic.games_config = {
    games = {21, 12, 18, 24},
    names = {
                [12] = {"飞鸟红中麻将", "czmj"}, 
                [17] = {"飞鸟红中麻将", "czmj"}, 
                [18] = {"斗牛", "bull"},
                [21] = {"韶关麻将", "sgmj"},
				[24] = {"五十K", "k510"}
            }, 
    rules = {
                [12] = {{8,16},{4,8},{1,2,3},{0,1,2},{0,1},{0,1,2}}, 
                --[13] = {{10,20}, {10,30}, {15,16}, {0,1}},
                --[14] = {}, 
                --[15] = {{10,20},{3,6},{1,2,3},{0,1,2},{0,1},{0,1,2}}, 
			},

    unopened = 0,    
}
 
FriendGameLogic.game_id = nil
FriendGameLogic.game_server = nil
FriendGameLogic.game_mode = nil
FriendGameLogic.game_used = nil
FriendGameLogic.game_type = nil
FriendGameLogic.pay_type = nil

FriendGameLogic.my_rule = {}

--是否存在好友桌：0 不知道，1 存在，2 不存在
FriendGameLogic.exit_table = 0

--保存、获取桌子配置
function FriendGameLogic.writeDeskRule(ruleTable)
    local deskstr = require("cjson").encode(ruleTable)
    CCUserDefault:sharedUserDefault():setStringForKey("desk_rule"..FriendGameLogic.game_id, deskstr) 

    CCUserDefault:sharedUserDefault():setStringForKey("pay_type"..FriendGameLogic.game_id, ""..FriendGameLogic.pay_type)
end

--保存、获取桌子配置
function FriendGameLogic.readDeskRule()
    local deskstr = CCUserDefault:sharedUserDefault():getStringForKey("desk_rule"..FriendGameLogic.game_id)
    local ruleTable
    if deskstr ~= "" then
        ruleTable = require("cjson").decode(deskstr)
    end

    local payStr = CCUserDefault:sharedUserDefault():getStringForKey("pay_type"..FriendGameLogic.game_id)
    FriendGameLogic.pay_type = 60    
    if payStr ~= "" and tonumber(payStr) > 0 then
        FriendGameLogic.pay_type = tonumber(payStr)
    end
    --[[
    if AppConfig.ISAPPLE then
        FriendGameLogic.pay_type = 50
    end
    ]]

    return ruleTable
end

function FriendGameLogic.addGameRule(typeIndex, numIndex) 
    local nodeValue = {typeIndex, FriendGameLogic.game_rule[typeIndex][numIndex]}
    table.insert(FriendGameLogic.my_rule, nodeValue)
end

function FriendGameLogic.getRuleValueByIndex(typeIndex) 
    if #FriendGameLogic.my_rule > 1 then
        for i=2,#FriendGameLogic.my_rule do     
            local index = FriendGameLogic.my_rule[i][1]
            if index == typeIndex then
                return FriendGameLogic.my_rule[i][2]
            end
        end
    end

    return 0
end

function FriendGameLogic.isRulevalid(typeIndex)
    if #FriendGameLogic.my_rule > 1 then
        for i=2,#FriendGameLogic.my_rule do
            if FriendGameLogic.my_rule[i][1] == typeIndex then
                return true
            end
        end
    end

    return false    
end

function FriendGameLogic.getGameRule() 
    if #FriendGameLogic.my_rule < 1 then
        return nil
    end

    local options = {}
    for i=2,#FriendGameLogic.my_rule do
        table.insert(options, FriendGameLogic.my_rule[i])
      end

    FriendGameLogic.game_used = 0
    return FriendGameLogic.game_mode, FriendGameLogic.my_rule[1][2], options
end

--[[
服务器下发的游戏规则解析函数
FriendGameLogic.game_rule = {
    -- 对局数
    count = {8, 16},
    -- 开局费用
    prince = {
        -- 8局费用
        8 = {
            -- 房主支付房主扣除的费用
            sigle = {
                -- 基础房费
                base = 3,
                -- 玩法1(飘5分)附加费用
                r1 = 0,
                -- 玩法2(飘10分)附加费用
                r2 = 0,
            },
            -- 多人支付每人扣除的费用
            mult = {
                base = 1,
                r1 = 0,
                r2 = 0,
            },
        },
        -- 16局费用
        16 = {
            -- 其它如上
            sigle = {
                base = 6,
                r1 = 0,
                r2 = 0,
            },
            mult = {
                base = 2,
                r1 = 0,
                r2 = 0,
            },
        },
    }
}
]]
function FriendGameLogic.analysisRuleData(data)
    FriendGameLogic.my_rule = {}
    FriendGameLogic.game_rule = { count = {}, price = {} }
    for k, v in pairs(data) do
        FriendGameLogic.game_rule.price[tonumber(k)] = clone(data[k])
        table.insert(FriendGameLogic.game_rule.count, tonumber(k))
    end
    table.sort(FriendGameLogic.game_rule.count, function(a,b) return a < b end)
end

--PartnerID   Int n   渠道ID
--GameID  Int n   游戏ID
--UseMode Int n   使用模式 10.局数；20.时间
function FriendGameLogic.getFriendTableRule(mode, backfunc, gameId)  
    FriendGameLogic.game_mode = mode
    FriendGameLogic.game_id = gameId
    local szData = string.format("PartnerID=%d&GameID=%d&UseMode=%d", AppConfig.CONFINFO.PartnerID, FriendGameLogic.game_id, mode)   
    local function httpCallback(isSucceed,tag,data)
        --解析数据
        local isvilad, code, msg, ruleData = WebRequest.parseData(isSucceed, data)
        cclog(data)
        if isvilad then
            if code == 0 and next(ruleData) ~= nil then
                FriendGameLogic.analysisRuleData(ruleData)
                backfunc(true)
                return
            else
                msg = "该游戏尚未开启好友桌功能"
            end

            require("HallUtils").showWebTip(msg)
        end

        backfunc(false) 
    end
    
    WebRequest.getData(httpCallback,"GetFriendTableRule.aspx",szData)      
end

--FriendTableID   Int Y   好友桌唯一ID
--ServerName  String  Y   服务器名称
--InviteCode  string  y   邀请码
--获取用户最近有效的好友卓信息
function FriendGameLogic.getUserExitsFriendTable(backfunc, gameid)
    --校验版本
    if not require("Lobby/LobbyLogic").checkGameUpdata() then
        return
    end

    if FriendGameLogic.exit_table == 2 then
        cclog("不存在未解散房间")
        backfunc()
        return
    end

    local function checkGameUpdata(isvilad, code, msg, table)
        if isvilad then
            if code == 0 and #table > 0 then
                FriendGameLogic.exit_table = 1

                --进入游戏
                FriendGameLogic.game_id = table[1].GameID
                FriendGameLogic.pay_type = table[1].PayType
                FriendGameLogic.enterGameRoom(table[1].ServerName, table[1].FriendTableID, table[1].InviteCode)
            else
                FriendGameLogic.exit_table = 2

                --返回操作
                backfunc()               
            end
        end
    end

    FriendGameLogic.ServerName = nil
    FriendGameLogic.game_id = gameid        

    local userid = LoginLogic.UserInfo.UserID
    local szData = string.format("UserID=%d&PartnerID=%d&GameID=%d", userid, AppConfig.CONFINFO.PartnerID, gameid)   
    cclog(szData)
    local function httpCallback(isSucceed,tag,data)
        --解析数据
        local isvilad, code, msg, table = WebRequest.parseData(isSucceed, data)
        checkGameUpdata(isvilad, code, msg, table)
    end
    
    WebRequest.getData(httpCallback,"GetUserExitsFriendTable.aspx",szData)     
end

--通过邀请码获取好友卓信息
--FriendTableID   Int Y   好友桌唯一ID
--ServerName  String  Y   服务器名称
function FriendGameLogic.getFriendTableByInviteCode(inviteCode, errorfunc) 
    FriendGameLogic.server_name = nil
    local szData = string.format("InviteCode=%s&GameID=%d", inviteCode, FriendGameLogic.game_id)   

    local function httpCallback(isSucceed,tag,data)
        --解析数据
        local isvilad, code, msg, table = WebRequest.parseData(isSucceed, data)
        if isvilad then
            cclog(data)
            if code == 0 and #table > 0 then
                FriendGameLogic.game_id = table[1].GameID or FriendGameLogic.game_id
                FriendGameLogic.pay_type = table[1].PayType
                if table[1].PayType == 60 and table[1].PayAmount > 0 then
                    local tipMsg = string.format("%s 房间号[%s]",
                        FriendGameLogic.games_config.names[FriendGameLogic.game_id][1],
                        tostring(inviteCode)
                    )
                    local shopMsg = string.format(AppConfig.TIPTEXT.Tip_Diamond_Tip2, table[1].PayAmount)
                    
                    local function enterRoomDlg(tipMsg, shopMsg)
                        local hall_layer = LobbyControl.hall_layer
                        local tipDlg
                        tipDlg = require("Lobby/Common/LobbySecondDlg").putTip(hall_layer, 4, tipMsg, function()  
                                if require("Lobby/Login/LoginLogic").UserInfo.DiamondAmount < table[1].PayAmount then
                                    require("Lobby/Common/LobbySecondDlg").putTip(
                                        hall_layer, 5, shopMsg,
                                        function() hall_layer:showStorePanel() end,
                                        function() end
                                    ):show()
                                else
                                    FriendGameLogic.pay_type = table[1].PayType
                                    FriendGameLogic.enterGameRoom(table[1].ServerName, table[1].FriendTableID, inviteCode)
                                    tipDlg:removeFromParentAndCleanup(true)
                                end
                            end, function()
                                tipDlg:removeFromParentAndCleanup(true)
                                if errorfunc then
                                    errorfunc(true)
                                end
                            end,
                        nil, nil, false)
                        tipDlg.tip_lab:setFontSize(28)
                        tipDlg.tip_lab:setPositionY(260)
                        tipDlg:show()
                        return tipDlg
                    end

                    local tipdlg = enterRoomDlg(tipMsg, shopMsg)
                    local txtLab = tipdlg:addAddedLab("多人付费模式，是否加入游戏？", 220, 28)
                    local tipLab = tipdlg:addAddedLab("需支付钻石："..table[1].PayAmount, 150, 28)
                    local tipSz = tipLab:getContentSize()
                    local daimondmark = loadSprite("common/diamond.png")
                    daimondmark:setPosition(ccp(tipSz.width / 2 + 15, tipSz.height / 2))
                    daimondmark:setScale(0.8)
                    tipLab:addChild(daimondmark)
                    return
                else
                    FriendGameLogic.pay_type = table[1].PayType
                    FriendGameLogic.enterGameRoom(table[1].ServerName, table[1].FriendTableID, inviteCode)
                    if errorfunc then
                        errorfunc(true)
                    end
                    return                    
                end            
            end

            if errorfunc then
                errorfunc(false)
            end
            require("HallUtils").showWebTip(msg)
        end 
    end
    
    WebRequest.getData(httpCallback,"GetFriendTableByInviteCode.aspx",szData)      
end

--获取多人模式牌局记录
function FriendGameLogic.getFriendGameTableScores(func, gameids)
    local recordData, index, bVisible, errorTip = {}, 1, false, ""

    --循环获取对局信息
    local function GetFriendTableScore()
        local gameid = gameids[index]
        local wwwroot = FriendGameLogic.getGameServerByID(gameid).WebRoot
        local szData = string.format("UserID=%d", LoginLogic.UserInfo.UserID)
        
        local function httpCallback(isSucceed,tag,data)
            cclog(data..";"..wwwroot)
            
            --解析数据
            local isvilad, code, msg, table = WebRequest.parseData(isSucceed, data)

            errorTip = msg
            if isvilad then
                if code == 0 then
                    if  table and #table > 0 then
                        recordData[gameid] = table
                        bVisible = true
                    end
                else
                    errorTip = AppConfig.TIPTEXT.Tip_GameRecord_Msg
                end
            end

            --判断是否获取所以信息
            if index == #gameids then
                if bVisible then
                    FriendGameLogic.record_data = recordData
                    func(true)
                else
                    if errorTip == "" then errorTip = AppConfig.TIPTEXT.Tip_GameRecord_Msg end
                    require("HallUtils").showWebTip(errorTip)
                    func(false)
                end
            else
                index = index + 1
                GetFriendTableScore()
            end
        end

        cclog(szData..";"..wwwroot)
        WebRequest.getWebData(httpCallback, wwwroot.."GetUserFriendTableScore.aspx",szData)        
    end

    GetFriendTableScore()
end

--获取用户总战绩
--FriendTableID   int Y   好友桌唯一ID
--GameBeginTime   string  Y   游戏开始时间
--InviteCode  string  y   房间邀请码
--MasterNickName  string  Y   桌主昵称
--MasterScore int Y   桌主总战绩
--FriendNickName  string  Y   好友昵称
--FriendScore int Y   好友总战绩
function FriendGameLogic.getUserFriendTableScore(func, gameid)
    local wwwroot = FriendGameLogic.getGameServerByID(gameid).WebRoot
    local szData = string.format("UserID=%d", LoginLogic.UserInfo.UserID)
    
    local function httpCallback(isSucceed,tag,data)
        --解析数据
        local isvilad, code, msg, table = WebRequest.parseData(isSucceed, data)
        if isvilad then
            cclog(data)
            if code == 0 then
                if  table and #table > 0 then
                    FriendGameLogic.game_id = gameid
                    --战绩存在
                    FriendGameLogic.record_data = table
                    func(true)
                    return
                else
                    --战绩为空
                    msg = AppConfig.TIPTEXT.Tip_GameRecord_Msg
                end
            end
            require("HallUtils").showWebTip(msg)
        end 

        func(false)
    end
    WebRequest.getWebData(httpCallback, wwwroot.."GetUserFriendTableScore.aspx",szData)
end

--获取好友桌战绩详细列表
--OrderNum  int Y   局数序号
--GameBeginTime   string  Y   游戏开始时间
--MasterNickName  string  y   桌主昵称
--MasterScore int     桌主本局战绩
--FanShu  int Y   本局番数
--FriendNickName  string  Y   好友昵称
--FriendScore int Y   好友本局战绩
function FriendGameLogic.GetUserFriendTableScoreList(tableID, func)
    local wwwroot = FriendGameLogic.getGameServerByID(FriendGameLogic.game_id).WebRoot
    local szData = string.format("FriendTableID=%d", tableID)
    -- cclog(szData)
    local function httpCallback(isSucceed,tag,data)
        --解析数据
        local isvilad, code, msg, table = WebRequest.parseData(isSucceed, data)
        if isvilad then
            cclog(data)
            if code == 0 then 
                func(table)
                return
            end
            require("HallUtils").showWebTip(msg)
        end 
    end
    WebRequest.getWebData(httpCallback, wwwroot.."GetUserFriendTableScoreList.aspx",szData)
end

--分享牌局生成回放码
function FriendGameLogic.createReplayCode(gamekey, gameid, invite)
    local wwwroot = FriendGameLogic.getGameServerByID(FriendGameLogic.game_id).WebRoot
    local szData = string.format("ServerBatchKey=%s", gamekey)
    cclog(szData)
    local function httpCallback(isSucceed,tag,data)
        --解析数据
        local isvilad, code, msg, table, parseTable = WebRequest.parseData(isSucceed, data)
        if isvilad then
            cclog(data)
            if code == 0 then
                local playcode = ""..gameid..parseTable.ReplayCode
                local title = FriendGameLogic.games_config.names[gameid][1]
                local context = string.format("玩家【%s】给您分享了一个回放码：%s，在大厅战绩界面，点击输入回放码可以查看该牌局！", 
                                LoginLogic.UserInfo.NewNickName, playcode)
                local webdata = require("cjson").encode({PlayCode = playcode, InviteCode = invite})

                local url = AppConfig.WXMsg.App_Url..webdata
                cclog(playcode)
                shareWebToWx(1, url, title, context, function() end)                
                return
            end

            require("HallUtils").showWebTip(msg)
        end 
    end
    
    WebRequest.getWebData(httpCallback, wwwroot.."CreateReplayCode.aspx",szData)
end

--获取牌局回放信息
function FriendGameLogic.getGamePlayRecord(playcode, servercode, func)
    local webUrl, gameid
    if servercode == "" then
        --播放码播放
        gameid = tonumber(string.sub(playcode,1,2))
        local gameServer = FriendGameLogic.getGameServerByID(gameid)
        if gameServer and gameServer.WebRoot then
            webUrl = gameServer.WebRoot
            playcode = tonumber(string.sub(playcode,3,-1))
        else
            require("HallUtils").showWebTip("该回放码格式不正确")
            return
        end
    else
        webUrl = FriendGameLogic.getGameServerByID(FriendGameLogic.game_id).WebRoot
    end

    local szData = string.format("ReplayCode=%d&ServerBatchKey=%s", playcode, servercode)
    -- cclog(szData)

    local function httpCallback(isSucceed,tag,data)
        --解析数据
        local isvilad, code, msg, table, parseTable = WebRequest.parseData(isSucceed, data)
        if isvilad then
            cclog(data) 
            if code == 0 then 
                if parseTable.Action then
                    func(parseTable, gameid)
                    return
                else
                    msg = "该回放码已失效"
                end
            end

            require("HallUtils").showWebTip(msg)
        end 
    end
    
    WebRequest.getWebData(httpCallback, webUrl.."GetGamePlayRecord.aspx",szData)
end

function FriendGameLogic.enterGameRoom(server, tableID, code, gametype) 
    LobbyControl.updataGame(FriendGameLogic.game_id, function()
        FriendGameLogic.server_name = server
        FriendGameLogic.friend_tableID = tableID
        FriendGameLogic.invite_code = code 
        FriendGameLogic.game_type = gametype or 0

        FriendGameLogic.getGameRulePanel()
        FriendGameLogic.enterRoom()
    end, function() end)
end

function FriendGameLogic.enterRoom(super) 
    if FriendGameLogic.enter_progress then
        return
    end

    FriendGameLogic.tip_dlg = nil 
    FriendGameLogic.result_dlg = nil  
    if FriendGameLogic.game_server then
        FriendGameLogic.enter_progress = FriendGameLogic.enter_progress or require("Lobby/Common/LobbySecondDlg").putProgress(
                    "进入游戏失败", function() 
                        FriendGameLogic.enter_progress = nil
                        if LobbyControl.gameSink then
                            LobbyControl.gameSink:exit()                            
                        end
                    end, super)
        FriendGameLogic.enter_progress:setProgressCount(1)

        if not LobbyControl.launchGame(FriendGameLogic.game_server.EnglishName,
                FriendGameLogic.game_server.ServerIP,
                FriendGameLogic.game_server.Port,
                FriendGameLogic.game_server.WebRoot, FriendGameLogic.game_type) then
            FriendGameLogic.enterGameRoomFail()
            require("HallUtils").showWebTip("该游戏正在优化中，敬请期待")
        else
            FriendGameLogic.exit_table = 0
        end
    else
        require("HallUtils").showWebTip("该游戏正在优化中，敬请期待")
    end

    FriendGameLogic.game_over = false
end

function FriendGameLogic.onFriendGameOver()
    FriendGameLogic.game_over = true

    FriendGameLogic.exit_table = 2
end

function FriendGameLogic.checkAppWebData(invitetable)
    if not invitetable or not FriendGameLogic.game_over then
        return
    end

    if invitetable.InviteCode and invitetable.GameID then
        --返回大厅
        if LobbyControl.gameSink then
            LobbyControl.gameSink:exit()
        end
        LobbyControl.backToHall()
        --self:showEnterRoomPanel(invitetable.InviteCode, nil, invitetable.GameID)
    end 
end

function FriendGameLogic.enterGameRoomSuccess() 
    if FriendGameLogic.enter_progress then
        FriendGameLogic.enter_progress:hide()
        FriendGameLogic.enter_progress = nil
    end

    if FriendGameLogic.tip_dlg then
        FriendGameLogic.tip_dlg:removeFromParentAndCleanup(true)
        FriendGameLogic.tip_dlg = nil
    end

    if FriendGameLogic.result_dlg then
        FriendGameLogic.result_dlg:removeFromParentAndCleanup(true)
        FriendGameLogic.result_dlg = nil
    end
end

function FriendGameLogic.enterGameRoomFail(msg) 
    if FriendGameLogic.enter_progress then
        FriendGameLogic.enter_progress:hide()
        FriendGameLogic.enter_progress = nil
    end

    if LobbyControl.gameSink then
        LobbyControl.gameSink:exit()
        require("HallUtils").showWebTip(msg)
    end
end

function FriendGameLogic.getGameRulePanel()
    FriendGameLogic.game_server = FriendGameLogic.getGameServerByID(FriendGameLogic.game_id)
    if FriendGameLogic.game_server then
        return FriendGameLogic.game_server.EnglishName
    end

    return nil
end

function FriendGameLogic.getGameServerByID(gameid)
    for i,v in ipairs(LobbyControl.game_list) do
        if v.GameID == gameid then
            return v
        end
    end

    return nil
end

function FriendGameLogic.showDismissTipDlg(super, zindex, gameSink) 
    FriendGameLogic.onDismissBack()

    local msg = "当前解散，系统将退还钻石"
    if FriendGameLogic.game_used > 0 then
        msg = "牌局进行中，是否继续发起解散？"
    end
    FriendGameLogic.tip_dlg = require("Lobby/Common/LobbySecondDlg").putTip(super, zindex, msg, function()
        if gameSink.game_lib then gameSink.game_lib:dismissFriendTable() end
        FriendGameLogic.tip_dlg:removeFromParentAndCleanup(true)
        FriendGameLogic.tip_dlg = nil
    end, function() FriendGameLogic.tip_dlg:removeFromParentAndCleanup(true) FriendGameLogic.tip_dlg = nil end, kCCTextAlignmentCenter)
    FriendGameLogic.tip_dlg:show()

    return FriendGameLogic.tip_dlg
end

function FriendGameLogic.onDismissBack() 
    if FriendGameLogic.tip_dlg then
        FriendGameLogic.tip_dlg:removeFromParentAndCleanup(true)
    end

    if FriendGameLogic.result_dlg then
        FriendGameLogic.result_dlg:removeFromParentAndCleanup(true)
    end
    
    FriendGameLogic.tip_dlg = nil 
    FriendGameLogic.result_dlg = nil  
end

function FriendGameLogic.addVoteResultDlg(super, zindex, master, masterid, info, cbWaitTime, gameSink) 
    local msg = master.." 发起解散请求，正在等待玩家投票\n"

    local selfAgreen = nil      --自己是否已经同意
    if LoginLogic.UserInfo.UserID == masterid then
        selfAgreen = 2
    end
    local agreetips = {"没投票", "同意", "不同意"}
    for i,v in ipairs(info) do
        msg = msg..v[2].."："..agreetips[v[3] + 1].."\n"

        if LoginLogic.UserInfo.UserID == v[1] and v[3] ~= 0 then
            if selfAgreen == 2 then
                selfAgreen = 1
            else
                selfAgreen = 2
            end 
        end
    end

    if not FriendGameLogic.result_dlg then
        FriendGameLogic.onDismissBack()

        FriendGameLogic.result_dlg = require("Lobby/Common/LobbySecondDlg").putRefuceAgreen(super, true, zindex, msg, 
                        function() if gameSink.game_lib then gameSink.game_lib:voteFriendTable(1) end end, 
                        function() if gameSink.game_lib then gameSink.game_lib:voteFriendTable(0) end end, nil, CCSizeMake(640, 380))

        --添加标题
        FriendGameLogic.result_dlg:addAddedLab("解散房间", 340, 34, kCCTextAlignmentCenter)

        --添加倒计时
        local timeStr = string.format("%02d:%02d", math.floor(cbWaitTime % 86400 % 3600 / 60), 
                cbWaitTime % 86400 % 3600 % 60)
        local timeTTf = FriendGameLogic.result_dlg:addAddedLab(timeStr, 130, 34, kCCTextAlignmentCenter) 

        --倒计时动画
        local function onCheck()
            local temp = "00:00"
            if cbWaitTime > -1 then
                temp = string.format("%02d:%02d", math.floor(cbWaitTime % 86400 % 3600 / 60), 
                    cbWaitTime % 86400 % 3600 % 60)
            else
                return
            end
            cbWaitTime = cbWaitTime - 1

            timeTTf:setString(temp)
            local array = CCArray:create() 
            array:addObject(CCDelayTime:create(1))     
            array:addObject(CCCallFunc:create(onCheck))
            timeTTf:runAction(CCSequence:create(array))
        end 
        if selfAgreen then
            FriendGameLogic.result_dlg:changeRefuceAgreenStatue(selfAgreen)
        end

        onCheck() 
        FriendGameLogic.result_dlg:show()      
    end  

    FriendGameLogic.result_dlg.tip_lab:setString(msg)
end

function FriendGameLogic.showFriendVoteDlg(super, zindex, player, cbWaitTime, gameSink) 
    FriendGameLogic.onDismissBack()

    local msg = player.."发起解散请求，是否同意解散？超过"..cbWaitTime.."秒不选择，默认同意解散！"

    local function votefunc(index)
        FriendGameLogic.tip_dlg:removeFromParentAndCleanup(true)
        FriendGameLogic.tip_dlg = nil
        gameSink.game_lib:voteFriendTable(index)
    end

    FriendGameLogic.tip_dlg = require("Lobby/Common/LobbySecondDlg").putTip(super, zindex, msg, 
        function() votefunc(1) end, function() votefunc(0) end)

    local function onCheck()
        local tip = msg.."("..cbWaitTime..")"
        if cbWaitTime < 1 then
            return          
        end

        FriendGameLogic.tip_dlg.tip_lab:setString(tip)
        local array = CCArray:create() 
        array:addObject(CCDelayTime:create(1))     
        array:addObject(CCCallFunc:create(onCheck))
        cbWaitTime = cbWaitTime - 1
        FriendGameLogic.tip_dlg:runAction(CCSequence:create(array))
    end

    FriendGameLogic.tip_dlg:show()
    onCheck()
end

function FriendGameLogic.showVoteResult(super, zindex, bsuccend, gameSink, info) 
    FriendGameLogic.onDismissBack()
    local agreetips = {"没投票", "同意", "不同意"}

    local msg = ""
    if bsuccend == 0 then
        for i,v in ipairs(info) do
            if v[3] == 2 then
                msg = "由于玩家["..v[2].."]不同意，游戏解散失败"
                break
            end
        end
    else         
        msg = "经玩家"
        for i,v in ipairs(info) do
            msg = msg.."["..v[2].."]"..agreetips[v[3] + 1].."，"
        end
        msg = msg.."游戏解散成功"
    end

    FriendGameLogic.tip_dlg = require("Lobby/Common/LobbySecondDlg").putConfirmTip(super, zindex, msg, 
        function() 
            FriendGameLogic.tip_dlg:removeFromParentAndCleanup(true)
            FriendGameLogic.tip_dlg = nil 
        end)
    FriendGameLogic.tip_dlg:show()
end



return FriendGameLogic
