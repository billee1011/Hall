-- require("GameLib/gamelib/place/GamePlace")
require("GameLib/gamelib/place/PlazaCmds")
require("GameLib/common/IconvString")

CGameLibLua = { }
CGameLibLua.__index = CGameLibLua

CGameLibLua._sink = nil
CGameLibLua._nGameID = 0
CGameLibLua._gameVersion = 0
CGameLibLua._gamePlace = nil
CGameLibLua._gameRoom = nil
CGameLibLua._clientframeSink = nil
CGameLibLua._nMinGold = 0
CGameLibLua._nMaxGold = 0
CGameLibLua.m_nPartnerID = 0
CGameLibLua._publicUserInfo = nil

CGameLibLua.ClientInfo = tagClientInfo:new()
CGameLibLua.VersionInfo = tagVersionInfo:new()

CGameLibLua.TIMER_REFRESH_GOLD = 1
CGameLibLua.PULSE = nil

CGameLibLua.instance = nil


function CGameLibLua:new()
    -- private method:
    local self = { }
    cclog("CGameLibLua:new()")
    setmetatable(self, CGameLibLua)
    CGameLibLua.instance = self
    return self
end

function CGameLibLua:createGamelib(nGameID, nGameVersion, pGameLibSink, pClientFrameSink,
        nPartnerID, nClientVersion, logonIP, logonPort, webRoot)
    cclog("logonIP = %s,logonPort = %d nClientVersion = %d", logonIP, logonPort, nClientVersion)
    self._sink = pGameLibSink
    self._nGameID = nGameID
    self._gameVersion = nGameVersion

    self._publicUserInfo = require("Lobby/Login/LoginLogic").UserInfo


    self.ClientInfo.dwComputerID[1] = 123
    self.ClientInfo.dwComputerID[2] = 456
    self.ClientInfo.dwComputerID[3] = 789
    self.ClientInfo.szComputerName = "cocos2d-x lua"
    local winsize = CCDirector:sharedDirector():getWinSize()
    self.ClientInfo.dwSystemVer[1] = winsize.width * 0x10000 + winsize.height
    self.ClientInfo.dwSystemVer[2] = nClientVersion

    self.VersionInfo.dwBuildVer = nClientVersion
    self.VersionInfo.dwInstallVer = 2015
    self.VersionInfo.dwSubBuildVer = nClientVersion

    self.m_nPartnerID = nPartnerID

    self._gamePlace = require("GameLib/gamelib/place/GamePlace"):new(self)
    self._gameRoom = require("GameLib/gamelib/room/GameRoom"):new(self)
    self._gameRoom:setSink(self._sink)
    self._gameRoom:setClientFrameSink(pClientFrameSink)
    self._gamePlace:setSink(pGameLibSink)
    self._gamePlace:setGameID(nGameID)

    self:setPlazaPort(logonPort)
    self:setPlazaIP(logonIP)
    --self:setWebRoot(webRoot)
    self:getGameInfo()

    self:startTimer()
end

function CGameLibLua:getGameInfo()
    self._gamePlace:getGameInfo()
end

function CGameLibLua:getPublicUserInfo()
    return self._publicUserInfo
end

-- 启动定时器    
function CGameLibLua:startTimer()
    if self.PULSE ~= nil then
        return
    end

    local function onPulse()
        if self.PULSE ~= nil then
            self:pulse()
        end
    end
    self.PULSE = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onPulse, 0.03, false)
end

function CGameLibLua:releaseTimer()
    if self.PULSE ~= nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.PULSE)
        self.PULSE = nil
    end
end

function CGameLibLua:stopReconnect()
    if self._gameRoom ~= nil then
        self._gameRoom:stopCheckPing()
    end
end

function CGameLibLua:startCheckPing()
    if self._gameRoom ~= nil then
        self._gameRoom:startCheckPing()
    end
end

function CGameLibLua:release()
    self:releaseTimer()
    if self._gameRoom ~= nil then
        self._gameRoom:clear()
    end    
    self._gamePlace:release()

    -- self._gamePlace = nil
end

function CGameLibLua:getGameID()
    -- cclog("CGameLibLua:getGameID() = " .. self._nGameID)
    return self._nGameID
end

function CGameLibLua:getGameLibSink()
    return self._sink
end

function CGameLibLua:getClientFrameSink()
    return self._clientframeSink
end

function CGameLibLua:getPartnerID()
    return self.m_nPartnerID
end

function CGameLibLua:getVersionCode()
    return self.VersionInfo.dwBuildVer
end

function CGameLibLua:getClientInfo()
    return self.ClientInfo
end

function CGameLibLua:getVersionInfo()
    return self.VersionInfo
end

function CGameLibLua:getMinGold()
    return self._nMinGold
end

function CGameLibLua:getMaxGold()
    return self._nMaxGold
end

function CGameLibLua:pulse()
    if self._gamePlace ~= nil then
        self._gamePlace:pulse()
    end
    if self._gameRoom ~= nil then
        self._gameRoom:pulse()
    end
end

function CGameLibLua:setPlazaIP(plazaIP)
    self._gamePlace:setServerIP(plazaIP)
end

function CGameLibLua:setPlazaPort(port)
    self._gamePlace:setPort(port)
end

function CGameLibLua:loginByUserID(userID, pass)
    return self._gamePlace:loginByUserID(userID, pass)
end

function CGameLibLua:loginByUserName(userName, pass)
    -- cclog("loginByUserName name = %s:%s",userName,pass)
    return self._gamePlace:loginByUserName(userName, pass)
end

function CGameLibLua:autoRegister()
    return false
end

function CGameLibLua:registerUser(userName, passWord, sex, faceID, realName, realID)
    return self._gamePlace:registerUser(userName, passWord, sex, faceID, realName, realID)
end

function CGameLibLua:getGameStation(stationID)
    return self._gamePlace:getGameStation(stationID)
end

function CGameLibLua:getGameServer(gameserverID)
    return self._gamePlace:getGameServer(gameserverID)
end

function CGameLibLua:getStationList()
    return self._gamePlace:getStationList()
end

function CGameLibLua:getGameServerList(stationID)
    return self._gamePlace:getGameServerList(stationID)
end

function CGameLibLua:getAllGameServerList()
    return self._gamePlace:getAllGameServerList()
end

function CGameLibLua:enterGameRoom(roomID, cbShake)
    local szGameRoomName = nil
    local gameServer = self:getGameServer(roomID)

    if gameServer == nil then
        return ""
    end

    local logonInfo = self._gamePlace:getUserLoginInfo()
    local publicUserInfo = self:getPublicUserInfo()
    cclog("CGameLibLua:enterGameRoom %s", getUtf8(gameServer.szGameRoomName))
    if not self._gameRoom:enterGameRoom(gameServer, publicUserInfo.UserID, publicUserInfo.EPassword, self._gameVersion, cbShake, 0, nil) then
        return ""
    end
    self._nMinGold = gameServer.dwMinGold
    self._nMaxGold = gameServer.dwMaxGold
    if szGameRoomName == nil then
        szGameRoomName = gameServer.szGameRoomName
    end
    return szGameRoomName
end

function CGameLibLua:autoEnterGameRoom(lpszStation)
    local logonInfo = self._gamePlace:getUserLoginInfo()

    local room = self._gamePlace:getAutoEnterRoom(lpszStation)

    return self:onEnterRoom(room)
end

function CGameLibLua:autoEnterFriendRoom(serverName, forbidName)
    local room = self._gamePlace:getPrivateRoom(serverName, forbidName)
    return self:onEnterRoom(room)
end

function CGameLibLua:autoEnterRoomByName(serverName)
    local room = self._gamePlace:searchRoomByName(serverName)
    return self:onEnterRoom(room)
end

function CGameLibLua:onEnterRoom(room)
    if (room ~= nil) then
        self:enterGameRoom(room.dwServerID, 0)
        self._nMinGold = room.dwMinGold
        self._nMaxGold = room.dwMaxGold
        local pStation = self._gamePlace:getGameStation(room.dwStationID)
        if (pStation) then
            return pStation.szStationName
        end
        return getUtf8(room.szGameRoomName)
    end
    return nil
end

function CGameLibLua:leaveGameRoom()
    if (self._gameRoom ~= nil) then
        self._gameRoom:leftRoom()
    end
end

function CGameLibLua:getMyself()
    return self._gameRoom:getMyself()
end

function CGameLibLua:getMyDBID()
    return self._gameRoom:getMyDBID()
end

function CGameLibLua:getUser(wUserID)
    return self._gameRoom:getUser(wUserID)
end

function CGameLibLua:getUserByDBID(dwUserDBID)
    return self._gameRoom:getUserByDBID(dwUserDBID)
end


function CGameLibLua:sitTable(tableID, cbChair)
    if (self._nGameID == 125) then
        return self._gameRoom:sendWatchMessage(0, 0)
    end

    return self._gameRoom:enterTable(tableID, cbChair)
end

function CGameLibLua:autoSit()
    cclog("autoSit gameid = %d", self._nGameID)
    if (self._nGameID == 88) then
        return self._gameRoom:sendWatchMessage(0, 0)
    end
    return self._gameRoom:autoSit()
end


function CGameLibLua:openSingleMode()
    return false
end

function CGameLibLua:isPlaying()
    local p = self:getMyself()
    if p == nil then
        return false
    end
    return p:isPlayer()
end

function CGameLibLua:sendOldGameCmd(cbCmdID, data, nLen)
    return self._gameRoom:sendOldGameCmd(cbCmdID, data, nLen)
end

function CGameLibLua:sendReadyCmd()
    return self._gameRoom:sendReady()
end

function CGameLibLua:getUserByChair(cbChair)
    return self._gameRoom:getUserByChair(cbChair)
end

function CGameLibLua:sendGameCmd(cbMainCmd, cbSubCmd, data, nLen)
    return self._gameRoom:sendGameCmd(cbMainCmd, cbSubCmd, data, nLen)
end

function CGameLibLua:sendOldCmd(cbCmdID, data, nLen)
    return self._gameRoom:sendOldCmd(cbCmdID, data, nLen)
end

function CGameLibLua:setClientFrameSink(sink)
    self._clientframeSink = sink
    self._gameRoom:setClientFrameSink(sink)
end

function CGameLibLua:standUp()
    self._gameRoom:standup()
end

function CGameLibLua:getCurrentServer()
    return self._gameRoom:getCurrentServer()
end

function CGameLibLua:watch(t, c)
    self._gameRoom:sendWatchMessage(t, c)
end

function CGameLibLua:getUserLogonInfo()
    return self._gamePlace:getUserLoginInfo()
end

function CGameLibLua:getVIPInfo(nLevel)
    return self._gamePlace:getVIPInfo(nLevel)
end

function CGameLibLua:getVIPInfoWakeng(nLevel)
    return self._gamePlace:getVIPInfoWakeng(nLevel)
end


function CGameLibLua:getMailList()
    self._gamePlace:getMailList()
end

function CGameLibLua:readMail(nUserMailID)
    self._gamePlace:readMail(nUserMailID)
end

function CGameLibLua:deleteMail(nUserMailID)
    self._gamePlace:deleteMail(nUserMailID)
end

function CGameLibLua:deleteMails(szMails)
    self._gamePlace:deleteMails(szMails)
end

function CGameLibLua:getOneGameServerInStation(nStationID)
    return self._gamePlace:getOneGameServerInStation(nStationID)
end

function CGameLibLua:getStationOnlineCount(nStationID)
    return self._gamePlace:getStationOnlineCount(nStationID)
end

function CGameLibLua:yuanbaoBuyGold(nYuanbao)
    self._gamePlace:yuanbaoBuyGold(nYuanbao)
end

function CGameLibLua:BuyProperty(nPropertyID)
    self._gamePlace:BuyProperty(nPropertyID)
end

function CGameLibLua:refreshGold()
    -- cclog("CGameLibLua:refreshGold()")
    if (self._gameRoom ~= nil and self._gameRoom:isServicing()) then
        self._gameRoom:refreshGold()
    end
    --  else
    self._gamePlace:getUserGameInfo()
end

function CGameLibLua:sendSpeaker(lpszMsg)
    nMoneyNeed = 500
    if (self._nGameID == gamelibcommon.GAMEID_WAKENG) then
        nMoneyNeed = 300
    end
    if (string.find(lpszMsg, "在下恭候您的大驾") ~= nil) then
        nMoneyNeed = 0
    end
    if (self._gameRoom ~= nil and self._gameRoom:isServicing()) then
        local pUser = self._gameRoom:getMyself()
        if (pUser == nil) then
            return self._gamePlace:sendSpeaker(lpszMsg)
        end
        if (self:getFreeSpeakerLeft() > 0) then
            return self._gamePlace:sendSpeaker(lpszMsg)
        end
        if (pUser:getGold() < nMoneyNeed + self._nMinGold) then
            cclog("CGameLibLua:sendSpeaker return 11,%d < %d + %d",
            pUser:getGold(), nMoneyNeed, self._nMinGold)
            self._sink:onSendSpeakerRet(11)
            return false
        end
    end
    return self._gamePlace:sendSpeaker(lpszMsg)
end

function CGameLibLua:changeUserInfo(lpszUserWord)
    self._gamePlace:changeUserInfo(getGBK(lpszUserWord))
end

function CGameLibLua:getUserFaceData(dwUserDBID)
    self._gamePlace:getUserFaceData(dwUserDBID)
end

function CGameLibLua:getTaskList()
    self._gamePlace:getTaskList()
end

function CGameLibLua:taskGift(nTaskID)
    self._gamePlace:taskGift(nTaskID)
end

function CGameLibLua:setWebRoot(lpszRoot)
    self._gamePlace:setWebRoot(lpszRoot)
end

function CGameLibLua:sendTableChat(lpszMsg)
    return self._gameRoom:sendTableChat(lpszMsg)
end

function CGameLibLua:getRelativePos(cbChair)
    if (not self._gameRoom:isServicing()) then
        return cbChair
    end
    return self._gameRoom:getRelativePos(cbChair)
end

function CGameLibLua:getRealChair(cbPos)
    if (not self._gameRoom:isServicing()) then
        return cbPos
    end
    return self._gameRoom:getRealChair(cbPos)
end

function CGameLibLua:updateMyScore()
    if (not self._gameRoom:isServicing()) then
        return
    end
    local pMyself = self._gameRoom:getMyself()
    if (pMyself == nil) then
        return
    end
    local p = self._gamePlace:getUserLoginInfo()
    p.dwGold = pMyself:getGold()
    self._publicUserInfo.nGold = p.dwGold
    p.nWin = pMyself:getScoreField(gamelibcommon.enScore_Win)
    p.nLose = pMyself:getScoreField(gamelibcommon.enScore_Loss)
    p.nDraw = pMyself:getScoreField(gamelibcommon.enScore_Draw)
    p.nFlee = pMyself:getScoreField(gamelibcommon.enScore_Flee)
    p.nWeekWinAmount = pMyself:getScoreField(gamelibcommon.enScore_WeekTopWin)
    p.nMaxWinAmount = pMyself:getScoreField(gamelibcommon.enScore_TopWin)
    -- 如果我的金币不足房间下限，触发一个破产保护
    if (pMyself:getGold() < self:getCurrentRoomMinGold()) then
        self:bankruptProtect()
    end
    --      self._clientframeSink.onNotEnoughGold(getCurrentRoomMinGold(),getCurrentRoomMaxGold())
    --  else

end

function CGameLibLua:updateMyFame()
    if (not self._gameRoom:isServicing()) then
        return
    end
    local pMyself = self._gameRoom:getMyself()
    if (pMyself == nil) then
        return
    end
    local p = self._gamePlace:getUserLoginInfo()
    p.cbGameTitleLevel = pMyself:getGameTitleLevel()
    p.nGameTitleScore = pMyself:getGameTitleScore()
end

function CGameLibLua:updateMyFragCount(nCount)
    local p = self._gamePlace:getUserLoginInfo()
    p.nFrag = nCount
end

function CGameLibLua:getCurrentRoomMinGold()
    return self._nMinGold
end

function CGameLibLua:getCurrentRoomMaxGold()
    return self._nMaxGold
end

function CGameLibLua:formatMoney(lMoney)
    local ret = nil
    local bNegative = false
    if lMoney < 0 then bNegative = true end

    local lValue = math.abs(lMoney)

    if (lValue < 10000) then
        lpsz =(bNegative and "-" or "") .. lValue
        return lpsz
    end
    if (lValue < 100000000) then
        return string.format("%s%d %04d", bNegative and "-" or "", lValue / 10000, lValue % 10000)
    end

    return string.format("%s%d %04d %04d", bNegative and "-" or "", lValue / 100000000,(lValue % 100000000) / 10000, lValue % 10000)
end

function CGameLibLua:bankruptProtect()
    self._gamePlace:getBankruptProtect()
end

function CGameLibLua:getSystemProperties()
    return self._gamePlace:getSystemProperties()
end

function CGameLibLua:getUserProperties()
    self._gamePlace:getUserProperties()
end

function CGameLibLua:useProperty(nPropertyID, nCount, nToUserID)
    -- 先到GamePlace看是否为属性，如果不是，则到gameroom中发送命令到服务器进行消耗道具使用。
    if (not self._gamePlace:useProperty(nPropertyID, nCount, nToUserID)) then
        self._gameRoom:useProperty(nPropertyID, nCount, nToUserID)
    end
end

function CGameLibLua:getUserPropertyFlag(nToUserID)
    self._gamePlace:getUserPropertyFlag(nToUserID)
end

function CGameLibLua:getFriendList()
    self._gamePlace:getFriendList()
end

-- 申请添加好友
function CGameLibLua:applyFriend(nToUserID)
    self._gamePlace:ApplyAddFriend(nToUserID)
end

-- 获取申请列表
function CGameLibLua:getFriendApplyList()
    self._gamePlace:getFriendApplyList()
end

-- 同意添加好友
function CGameLibLua:agreeAddFriend(nToUserID)
    self._gamePlace:AgreeAddFriend(nToUserID)
end

-- 删除好友
function CGameLibLua:deleteFriend(nToUserID)
    self._gamePlace:DeleteFriend(nToUserID)
end

-- 获取查找的用户信息
function CGameLibLua:getFriendInfo(nToUserID, handle)
    self._gamePlace:getFriendInfo(nToUserID, handle)
end

function CGameLibLua:getFriendInfoByName(szName, handle)
    self._gamePlace:getFriendInfoByName(szName, handle)
end

function CGameLibLua:getBankInfo()
    self._gamePlace:getBankInfo()
end
-- 修改密码
function CGameLibLua:changeBankPassword(lpszOldPassword, lpszNewPassword)
    self._gamePlace:changeBankPassword(lpszOldPassword, lpszNewPassword)
end
-- 存
function CGameLibLua:bankIn(nGold)
    self._gamePlace:bankIn(nGold)
end
-- 取
function CGameLibLua:bankOut(nGold, lpszPassword)
    self._gamePlace:bankOut(nGold, lpszPassword)
end

function CGameLibLua:refuseAddFriend(nToUserID)
    self._gamePlace:refuseAddFriend(nToUserID)
end

function CGameLibLua:GetPayAmount()
    return self._gamePlace:GetPayAmount()
end

function CGameLibLua:sendMail(nToUserID, szContent)
    self._gamePlace:sendMail(nToUserID, szContent)
end

function CGameLibLua:enterGameRoomByType(nRoomType, PlayType)
    local pRoom = self._gamePlace:enterGameRoomByType(nRoomType, PlayType)
    if (pRoom == nil) then
        self:autoEnterGameRoom("")
        return true
    end
    local logonInfo = self._gamePlace:getUserLoginInfo()
    local publicUserInfo = self:getPublicUserInfo()
    cclog("CGameLibLua:enterGameRoom " .. getUtf8(pRoom.szGameRoomName))
    if (not self._gameRoom:enterGameRoom(pRoom, publicUserInfo.UserID,
        publicUserInfo.EPassword, self._gameVersion, false, 0, nil)) then
        return ""
    end
    self._nMinGold = pRoom.dwMinGold
    self._nMaxGold = pRoom.dwMaxGold

    return true
end

function CGameLibLua:getRecommendPlayType()
    return self._gamePlace:getRecommendPlayType()
end

-- 输出三个数据 bool,rEnterVipLevelNeeded,rCreateTableVIPLevelNeeded,rMinGoldNeeded
function CGameLibLua:hasPrivteRoom()
    return self._gamePlace:hasPrivateRoom()
end

function CGameLibLua:getAllRoomByJudge(judgefunc)
    return self._gamePlace:getAllRoomByJudge(judgefunc)
end

function CGameLibLua:createPrivateTable(lpszPassword)
    if (lpszPassword == nil or string.len(lpszPassword) < 1) then
        cclog("CGameLibLua:createPrivateTable !lpszPassword or len < 1")
        return false
    end
    local gameServer = self._gamePlace:getPrivateRoom()
    if (gameServer == nil) then
        cclog("CGameLibLua:createPrivateTable no private room")
        return false
    end

    local logonInfo = self._gamePlace:getUserLoginInfo()
    return self._gameRoom:createPrivateTable(gameServer, self._publicUserInfo.UserID,
    self._publicUserInfo.EPassword, self._gameVersion, lpszPassword)
end

function CGameLibLua:enterPrivateTable(lpszPassword)
    if (lpszPassword == nil or string.len(lpszPassword) < 1) then
        return false
    end
    local gameServer = self._gamePlace:getPrivateRoom()
    if (gameServer == nil) then
        return false
    end
    local logonInfo = self._gamePlace:getUserLoginInfo()
    return self._gameRoom:enterPrivateTable(gameServer, self._publicUserInfo.UserID,
    self._publicUserInfo.EPassword, self._gameVersion, lpszPassword)
end

function CGameLibLua:createFriendTable(nPartner)
    return self._gameRoom:createFriendTable(nPartner)
end

function CGameLibLua:dismissFriendTable()
    return self._gameRoom:dismissFriendTable()
end

function CGameLibLua:voteFriendTable(agree)
    return self._gameRoom:voteFriendTable(agree)
end

function CGameLibLua:returnFriendTable(tableid, code)
    return self._gameRoom:returnFriendTable(tableid, code)
end

function CGameLibLua:kickUserOutOfTable(wUserID)
    return false
    -- return self._gameRoom:kickUserOutOfTable(wUserID)
end

function CGameLibLua:allInAction()
    self._gamePlace:allInAction()
end

function CGameLibLua:getFreeSpeakerLeft()
    return self._gamePlace:getFreeSpeakerLeft()
end

function CGameLibLua:isMyFriend(nUserDBID)
    return self._gamePlace:isMyFriend(nUserDBID)
end

function CGameLibLua:getBankruptCount()
    return self._gamePlace:getBankruptCount()
end

function CGameLibLua:checkNew()
    self._gamePlace:SetActive()
end

function CGameLibLua:amITableOP()
    return self._gameRoom:amITableOP()
end

function CGameLibLua:httpRequest(szFileName, szData, szTag, pCallBack, bPlatform)
    return self._gamePlace:httpRequest(szFileName, szData, szTag, pCallBack, bPlatform)
end

function CGameLibLua:getWebRoot()
    return self._gamePlace:getWebRoot()
end

function CGameLibLua:getNewStatus()
    self:checkNew()
end

function CGameLibLua:isInPrivateRoom()
    if (self._gameRoom:isServicing()) then
        return self._gameRoom:isPrivteRoom()
    end
    return false
end

function CGameLibLua:finishTask(nTaskID)
    return self._gamePlace:finishTask(nTaskID)
end

function CGameLibLua:getMyMemberInfo()
    return self._gamePlace:getMyMemberInfo()
end

function CGameLibLua:getContinueAwardInfo()
    return self._gamePlace:getContinueAwardInfo()
end

function CGameLibLua:sendSoundToTableUser(pBuf, nLen)
    return self._gameRoom:sendSoundToTableUser(pBuf, nLen)
end

function CGameLibLua:isInReview()
    return require("LobbyControl").isInReview()
end

function CGameLibLua:isShowAD()
    return self._gamePlace:isShowAD()
end

function CGameLibLua:isSnow()
    return self._gamePlace:isSnow()
end

function CGameLibLua:getLoginAward()
    self._gamePlace:getLoginAward()
end

function CGameLibLua:getVIPUpgradeAward()
    self._gamePlace:getVIPUpgradeAward()
end

function CGameLibLua:getGameTitleInfoList()
    return self._gamePlace:getGameTitleInfoList()
end

function CGameLibLua:delayRefreshGold(fSecond)
    -- undone
    -- GameLibTimer:getInstance().setTimer(TIMER_REFRESH_GOLD,nMSces,this,0)	
    local timerid = nil
    local function onTimer()
        self:refreshGold()
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(timerid)
    end
    timerid = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTimer, fSecond, false)
end

-- 如果为true，则表示成功提交，客户端等待结果
-- 如果为false，则表示失败，通常是所带金币不足或者VIP等级不足
function CGameLibLua:gameBankIn(nGold)
    return self._gameRoom:gameBankIn(nGold)
end

-- 如果为true，则表示成功提交，客户端等待结果
-- 如果为false，则表示失败，保险柜金币不足
function CGameLibLua:gameBankOut(nGold, szPassword)
    return self._gameRoom:gameBankOut(nGold, szPassword)
end

function CGameLibLua:enterGameRoomByIP(ipaddress, port)
    -- 找到对应的服务器
    local publicUserInfo = self:getPublicUserInfo()
    return self._gameRoom:enterGameRoomByIP(ipaddress, port,
    publicUserInfo.UserID, publicUserInfo.EPassword, self._gameVersion,
    self._gamePlace:getServerByIPAndPort(ipaddress, port))
end

function CGameLibLua:roomTransfer(toUserDBID, amount, szPassword)
    return self._gameRoom:transfer(toUserDBID, amount, szPassword)
end

-- 获取我的网络延时
function CGameLibLua:getNetLag()
    return self._gameRoom:getNetLag()
end

-- 获取桌子列表
function CGameLibLua:GetTableList()
    return self._gameRoom:getTableList()
end

-- 获取桌子
function CGameLibLua:getTable(tableID)
    return self._gameRoom:getTable(tableID)
end

-- 发送桌子聊天
function CGameLibLua:sendHallChat(lpszMsg)
    return self._gameRoom:sendHallChat(lpszMsg)
end

function CGameLibLua:getUserList()
    return self._gameRoom:getUserList()
end
