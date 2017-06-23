-- /*=================================================================*/
-- /* 文件名   : CS_Message.lua
-- /* 文件描述 : 客户端/服务器的消息码及消息结构定义
-- /* 创建时间 : 2017-02-21
-- /* 创建者   : 秦志刚
-- /* 备注     :
-- /*
-- /*-----------------------------------------------------------------*/
-- /* 修改记录1:
-- /* 修改时间 :
-- /* . . .
-- /*=================================================================*/

local GameCfg =require ("bull/desk/public/GameCfg")
local GameDefs = require("bull/GameDefs")
local Resources=require ("bull/Resources")

local CS_Message={}

--//-------------------消息定义------------------
CS_Message.CMD_PROPERTY=5    --扔道具命令

CS_Message.MJ_CMD_ROOMINFO  = 10  --//房间配置
CS_Message.MJ_DISSOLVE_ROOM  = 11  --//发起解散房间命令  BYTE 发起玩家椅子号
CS_Message.MJ_DISSOLVE_RESULT = 12  --//发送解散房间命令结果， BYTE[4] 各玩家选择结果 0是同意解散 1是不同意
CS_Message.MJ_CMD_SETINFO = 13  --//局数信息命令
CS_Message.MJ_CMD_DissINFO = 14  --//私人场牌局解散时下发
CS_Message.MJ_CMD_Cancel_AutoOut = 15 --//取消托管
CS_Message.MJ_CMD_AUTOOUT = 17 --托管

--为避免和上面定义的消息ID的值重复，所以从100开始 2017-2-20 LUYQ
CS_Message.DN_CMD_ROOMINFO = 100 --房间配置
CS_Message.DN_DISSOLVE_ROOM = 101 --发起解散房间命令  BYTE 发起玩家椅子号
CS_Message.DN_DISSOLVE_RESULT = 102 --发送解散房间命令结果， BYTE[4] 各玩家选择结果
CS_Message.DN_CMD_SETINFO = 103 --局数信息命令
CS_Message.DN_CMD_DissInfo = 104 --私人场牌局解散时下发
CS_Message.DN_CMD_Cancel_AutoOut = 105 --取消托管

CS_Message.SC_GAMEMSG_STAKEREPLY = 0  --服务器向玩家回复下注信息,buf[0-1] ,下注的具体返回值，具体值的意义参考emErrorType 定义
CS_Message.SC_GAMEMSG_BYALLIN = 1         --被别人梭哈
CS_Message.SC_GAMEMSG_SCORE = 2           --一局结束用户的分数,这个发送的是纯利润，也就是具体写进数据库的值
CS_Message.SC_GAMEMSG_GOLD = 3            --一局的奖金,这个是指从奖池里面获得多少金币
CS_Message.SC_GAMEMSG_GAMERULE = 4        --发送游戏规则数据,用户进来的第一时间需要发送规则数据
CS_Message.SC_GAMEMSG_SHOW_HIDECARD = 5   --开底牌
CS_Message.SC_GAMEMSG_BIT = 6             --抢庄
CS_Message.SC_GAMEMSG_MAXSTAKE = 7        --最大下注
CS_Message.SC_GAMEMSG_TONGSHA = 8         --通杀        
CS_Message.SC_GAMEMSG_WINAPOINT = 9       --赢一点
CS_Message.SC_GAMEMSG_GAMERECORD = 10     --游戏牌局记录
CS_Message.SC_GAMEMSG_ACTIVITY = 11       --游戏活动相关的消息，具体参数根据活动不同而不同
CS_Message.SC_GAMEMSG_READY	   = 12		  --逻辑的准备消息
CS_Message.SC_GAMEMSG_SCENE	   = 13		  --场景数据，这个数据是一局游戏结束后，好友桌玩家再进来时要恢复上一局的数据
CS_Message.SC_GAMEMSG_START	   = 14		  --游戏开始，方便更新游戏局数
CS_Message.SC_GAMEMSG_MAX      = 127   --消息的最大ID只能是127.超过这个值发送会失败

CS_Message.ST_RoomInfo={}
function CS_Message.ST_RoomInfo:new(buffer)
    local roomInfo=
    {
        nTurnBasicGold = 0,     --//基本底注
        nCost = 0,              --//台费
        nMinRoomGold = 0,       --//房间下限
        nMaxRoomGold = 0,       --//房间上限
        nRuleID = 0,           --//规则号
        bNoBanker = 0,       --//无庄
        nPlayerNum = 0,      --//人数
    }

    if buffer~=nil then
        local ba = require("ByteArray").new()
        ba:initBuf(buffer)
        roomInfo.nTurnBasicGold  = ba:readInt()
        roomInfo.nCost  = ba:readInt()
        roomInfo.nMinRoomGold  = ba:readInt()
        roomInfo.nMaxRoomGold  = ba:readInt()
        roomInfo.nRuleID  = ba:readInt()
        roomInfo.bNoBanker  = ba:readInt()
        roomInfo.nPlayerNum  = ba:readInt()
    end

    return roomInfo
end

CS_Message.ST_SetInfo={}
function CS_Message.ST_SetInfo:new(buffer)
    local setInfo=
    {
        nRoomID = 0,
        nCurSet = 0,
        nTotalSet = 0,
        cbBaseScore = 0,
        nRoomOwner = 0
    }

    if buffer~=nil then
        local ba = require("ByteArray").new()
        ba:initBuf(buffer)
        setInfo.nRoomID =ba:readInt()
        setInfo.nCurSet=ba:readInt()
        setInfo.nTotalSet =ba:readInt()
        setInfo.cbBaseScore =ba:readInt()
        setInfo.nRoomOwner = ba:readInt()
    end

    return setInfo
end

CS_Message.ST_DissmissInfo={}
function CS_Message.ST_DissmissInfo:new(buffer)
    local vDissmissTable = {}
    if buffer~=nil then
        local ba = require("ByteArray").new()
        ba:initBuf(buffer)
        for i=1,GameDefs.PLAYER_COUNT do
            local dissmissInfo=
            {
                nBullTypeNullToBullType7Count=0,
                nBullType8ToBullType9Count=0,
                nBullType10Count=0,
                nBullTypeBombCount=0,
                nBullType5JqkCount=0,
                nBullType5MinCount=0,
                nWinCount=0,
                nTongShaCount=0,
                nNiuNiuYiShangCount=0,
                nTotalScore=0,
                dwDBID=0,
                szName=""
            }
            dissmissInfo.nBullTypeNullToBullType7Count =ba:readInt()
            dissmissInfo.nBullType8ToBullType9Count=ba:readInt()
            dissmissInfo.nBullType10Count =ba:readInt()
            dissmissInfo.nBullTypeBombCount =ba:readInt()
            dissmissInfo.nBullType5JqkCount =ba:readInt()
            dissmissInfo.nBullType5MinCount =ba:readInt()
            dissmissInfo.nWinCount =ba:readInt()
            dissmissInfo.nTongShaCount =ba:readInt()
            --dissmissInfo.nNiuNiuYiShangCount = ba:readInt()
			dissmissInfo.nNiuNiuYiShangCount = dissmissInfo.nBullTypeBombCount + dissmissInfo.nBullType5JqkCount + 
					dissmissInfo.nBullType5MinCount + dissmissInfo.nBullType10Count
            dissmissInfo.nTotalScore =ba:readInt()
            dissmissInfo.dwDBID =ba:readInt()
            dissmissInfo.szName = getUtf8(ba:readStringSubZero(32))
            cclog("-----------------dissmissInfo.szName = " .. dissmissInfo.szName)
            table.insert(vDissmissTable, dissmissInfo)
        end
    end
    return vDissmissTable
end

CS_Message.ST_GameEnd={}
function CS_Message.ST_GameEnd:new(buffer)
    local gameEnd={}

    if buffer~=nil then
        local ba = require("ByteArray").new()
        ba:initBuf(buffer)
        for i=1,GameDefs.PLAYER_COUNT do
            local nScore = ba:readInt()
            table.insert(gameEnd, nScore)
        end
    end

    return gameEnd
end

CS_Message.ST_Property={}
CS_Message.ST_Property.__index =CS_Message.ST_Property
function CS_Message.ST_Property:new(buffer,nLen)
    local property=
    {
        nPropertyID=0,  --道具ID
        cbToChair=0,    --道具作用椅子
        bSuccess=false, --是否扣费成功
    }

    if buffer~=nil then
        local ba = require("ByteArray").new()
        ba:initBuf(buffer)
        property.nPropertyID =ba:readInt()
        property.cbToChair=ba:readUByte()
        property.bSuccess =ba:readBool()
    end
    
    return property
end

function CS_Message.ST_Property:write(nPropertyID,cbToChair)
       local ba = require("ByteArray").new()
        ba:writeInt(nPropertyID)
        ba:writeUByte(cbToChair)
        ba:writeBool(false)
        ba:setPos(1)
       return  ba
end

--MSG_ROBOT_ACTIVE
function CS_Message.newRobotMsg(buffer)
    local robotMsg={}
    robotMsg.nChair = 0
    robotMsg.bEnableRobot = 0
    if buffer~=nil then
        local ba = require("ByteArray").new()
        ba:initBuf(buffer)
        robotMsg.nChair=ba:readByte()
        robotMsg.bEnableRobot =ba:readByte()
    end
    return robotMsg
end


CS_Message.ST_GangScore={}
CS_Message.ST_GangScore.__index =CS_Message.ST_GangScore
function CS_Message.ST_GangScore:new(buffer,nLen)
    local nGangScore = {}

    if buffer~=nil then
        local ba = require("ByteArray").new()
        ba:initBuf(buffer)
        for i=1, GameDefs.PLAYER_COUNT do
            nGangScore[i] = ba:readInt()
        end
    end
    
    return nGangScore
end


--游戏网络缓存数据
CS_Message.MSG_TYPE_GAMESCENE=1 --游戏场景
CS_Message.MSG_TYPE_GAMEMESSAGE=2 -- 游戏消息
CS_Message.MSG_TYPE_GAMEONENTER=3  --玩家进桌
CS_Message.MSG_TYPE_GAMEEXIT=4  --玩家退出
CS_Message.MSG_TYPE_PLAYERSTATECHANGED=5  --玩家状态改变


CS_Message.CACHE_GAMESCENE={}
function CS_Message.CACHE_GAMESCENE:new(pBuffer,nLen)
    local self=
    {
        buffer = pBuffer,
        nLen = nLen,
        nGameType = CS_Message.MSG_TYPE_GAMESCENE,
    }
    return self
end

CS_Message.CACHE_GAMEMESSAGE={}
function CS_Message.CACHE_GAMEMESSAGE:new(nChair,nCbCmdID,pBuffer,nLen)
    local self=
    {
        chair =nChair,
        cbCmdID = nCbCmdID,
        buffer = pBuffer,
        nLen = nLen,
        nGameType = CS_Message.MSG_TYPE_GAMEMESSAGE,
    }
    return self
end

CS_Message.CACHE_GAMEUSERENTER={}
function CS_Message.CACHE_GAMEUSERENTER:new(nChair,userID,bIsPlayer)
    local self=
    {
        chair =nChair,
        wUserID = userID,
        isPlayer = bIsPlayer,
        nGameType = CS_Message.MSG_TYPE_GAMEONENTER,
    }
    return self
end

CS_Message.CACHE_GAMEUSEREXIT={}
function CS_Message.CACHE_GAMEUSEREXIT:new(nChair,userID,bIsPlayer)
    local self=
    {
        chair =nChair,
        wUserID = userID,
        isPlayer = bIsPlayer,
        nGameType = CS_Message.MSG_TYPE_GAMEEXIT,
    }
    return self
end

CS_Message.CACHE_PLAYERSTATECHANGED={}
function CS_Message.CACHE_PLAYERSTATECHANGED:new(nChair,oldState,newState)
    local self=
    {
        chair =nChair,
        nOldState = oldState,
        nNewState = newState,
        nGameType = CS_Message.MSG_TYPE_PLAYERSTATECHANGED,
    }
    return self
end



CS_Message.stGameRuleBase={}
function CS_Message.stGameRuleBase:new(buffer)
    local obj=
    {
        m_bIsActivityTime = 0,
        m_szPcActivituAddress = {},
        m_szMobileActivituAddress = {},

        m_stCurGameScene = nil,
        m_anTime = {},
        m_lBaseScore = 0,
        m_lTax = 0,
        m_nStake = 0,
        m_lMaxStake = 0,
        m_bNotBanker = 0,
		m_nGameType = 0,
		m_nPlayerCount = 0,
		m_nMaxStake = 0,
        m_byReserved = {},
    }

    if buffer~=nil then
        local ba = require("ByteArray").new()
        ba:initBuf(buffer)
        obj.m_bIsActivityTime = ba:readByte()
        obj.m_szPcActivituAddress = ba:readStringSubZero(100)
        obj.m_szMobileActivituAddress = ba:readStringSubZero(100)

        obj.m_stCurGameScene = GameDefs.GameScene(ba)

        --此处丢失了迷之4字节，后面得查下GameScene是否少读了4字节，by qinzhigang
        local nSecret = ba:readInt()

        for i=1,5 do
            obj.m_anTime[i] = ba:readInt()
        end
        obj.m_lBaseScore = ba:readInt()
        obj.m_lTax = ba:readInt()
        obj.m_nStake = ba:readInt()
        obj.m_lMaxStake = ba:readInt()
        obj.m_bNotBanker = ba:readInt()
		obj.m_nGameType = ba:readInt()
		obj.m_nPlayerCount = ba:readInt()
		obj.m_nMaxStake = ba:readInt()
        for i=1,12 do
            obj.m_byReserved[i] = ba:readByte()
        end
    end

    return obj
end

CS_Message.ST_MSG_BANKER_BID = {}
CS_Message.ST_MSG_BANKER_BID.__index = CS_Message.ST_MSG_BANKER_BID
function CS_Message.ST_MSG_BANKER_BID:new()
    local self=
    {
        cbChair = 0,
        cbWant = 0,
    }
    setmetatable(self, CS_Message.ST_MSG_BANKER_BID)
    return self
end
function CS_Message.ST_MSG_BANKER_BID:Serialize()
    local ba = require("ByteArray").new()
    ba:writeByte(self.cbChair)
    ba:writeByte(self.cbWant)
    ba:setPos(1)
    return ba
end
function CS_Message.ST_MSG_BANKER_BID:DeSerialize(ba)
    self.cbChair = ba:readByte()
    self.cbWant = ba:readByte()
end

CS_Message.ST_MSG_STAKE = {}
CS_Message.ST_MSG_STAKE.__index = CS_Message.ST_MSG_STAKE
function CS_Message.ST_MSG_STAKE:new()
    local self=
    {
        cbChair = 0,
        cbRsrv = {0,0,0},
        lStake = 0,
    }
    setmetatable(self, CS_Message.ST_MSG_STAKE)
    return self
end
function CS_Message.ST_MSG_STAKE:Serialize()
    local ba = require("ByteArray").new()
    ba:writeByte(self.cbChair)
    for i=1,3 do
        ba:writeByte(self.cbRsrv[i])
    end
    ba:writeInt(self.lStake)
    ba:setPos(1)
    return ba
end
function CS_Message.ST_MSG_STAKE:DeSerialize(ba)
    self.cbChair = ba:readByte()
    for i=1,3 do
        self.cbRsrv[i] = ba:readByte()
    end
    self.lStake = ba:readInt()
end

CS_Message.ST_MSG_SHOW = {}
CS_Message.ST_MSG_SHOW.__index = CS_Message.ST_MSG_SHOW
function CS_Message.ST_MSG_SHOW:new()
    local self=
    {
        cbChair = 0,
        cbRsrv = {0,0,0},
        stCards = nil,
    }
    setmetatable(self, CS_Message.ST_MSG_SHOW)
    return self
end
function CS_Message.ST_MSG_SHOW:Serialize()
    local ba = require("ByteArray").new()
    ba:writeByte(self.cbChair)
    for i=1,3 do
        ba:writeByte(self.cbRsrv[i])
    end
    ba:writeByteArray(self.stCards:Serialize())
    ba:setPos(1)
    return ba
end

return CS_Message
