-- 相关常量定义
local Common = {}

Common.PLAYER_COUNT			    = 3		    -- 最大玩家数
Common.MAX_HOLD_CARDS			= 18		-- 最大手持牌张数
Common.INVALID_CHAIR			= 255		-- 无效椅子号
Common.INVALID_CARD_INDEX		= 255		-- 无效的牌值

Common.FULL_COUNT				= 53		-- 53张

Common.HAND_COUNT				= 18		-- 最大牌数

-- 牌值
Common.CARDVALUE_INVALID = -1        --无效值

Common.CARDVALUE_3			 = 1     
Common.CARDVALUE_4			 = 2
Common.CARDVALUE_5			 = 3
Common.CARDVALUE_6			 = 4
Common.CARDVALUE_7			 = 5
Common.CARDVALUE_8			 = 6
Common.CARDVALUE_9			 = 7
Common.CARDVALUE_10		     = 8
Common.CARDVALUE_J			 = 9
Common.CARDVALUE_Q			 = 10
Common.CARDVALUE_K			 = 11
Common.CARDVALUE_A			 = 12
Common.CARDVALUE_2			 = 13
Common.CARDVALUE_Joker		 = 14

--牌的花色
Common.CARDTYPE_INVALID	 = -1       -- 无效值
Common.CARDTYPE_DIAMOND	 = 0	    -- 方块
Common.CARDTYPE_CLUB	 = 1	    -- 梅花
Common.CARDTYPE_HEART	 = 2	    -- 红心
Common.CARDTYPE_SPADE	 = 3        -- 黑桃
Common.CARDTYPE_Joker	 = 4        -- 王

Common.SUIT_Num = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"}
Common.SUIT_Flow = {"♦", "♣", "♥", "♠"}

-- 牌型
Common.SUIT_TYPE =
{
	suitPass = 0,

	suitSingle = 1,							-- 单张
	suitDouble = 2,							-- 对子	
	suitTriple = 3,							-- 三张			只可先手或者收尾出牌

	suitTriAndDouble = 4,					-- 三带对		三张牌点相同的牌，带二张杂牌，如：55566、55567	
	
	suitStraight = 5,						-- 顺子			五张或以上牌点连续的牌 3456789	2不能出现在顺子当中

	suitDoubleStraight = 6,					-- 双顺，连对	2对以上 如3344、445566778899

	suitTriStraight = 7,			        -- 三连			2个(含)以上连续三条。如jjjqqq、444555666777888
	
	suitPlane = 8,							-- 飞机带翅膀	两个或两个以上相连的三同张牌，如：5556667788

	suitFiveTenKing = 9,            		-- 510k			5，10，k

	suitPureFiveTenKing = 10,        		-- 纯510k		三张花色相同510k   

	suitRedJoker = 11,						-- 大王
	
	suitBomb = 12,							-- 炸弹			6666或66661（选择牌型）
    
	suitBaodan = 254,               		-- 报单
	
	suitInvalid = 255			    		-- 无效
}

-- 牌型名称
Common.SUIT_Name =
{
	[0] = "不要",
    [1] = "单张",
    [2] = "对子",
    [3] = "三张",
    [4] = "三带一对",
    [5] = "顺子",
    [6] = "连对",
    [7] = "三连",
    [8] = "飞机带翅膀",
    [9] = "五十K",
    [10] = "同花五十K",
    [11] = "大王",
    [12] = "炸弹",
    [255] = "无效",
}

--游戏阶段
Common.GAME_PHRASE = 
{
	enGame_QiePai   = 0,         -- 切牌阶段
	enGame_InitData = 1,         -- 构造数据阶段（洗牌、发牌）
	enGame_AskPlayer= 2,		 -- 问询玩家决定对战双方的阶段
	enGame_OutCard  = 3,         -- 打牌阶段
	enGame_Over     = 4,         -- 结束阶段
	enGame_Invalid  = 255,       -- 还没有开始
	enGame_Replay   = 999        -- 回放阶段
}

--游戏阶段名称
Common.GAME_PHRASE_NAME = 
{
    [0] = "切牌",
    [1] = "洗牌/发牌",
	[2] = "选择对战双方",
    [3] = "进行中",
    [4] = "结束",
    [255] = "未开始",
    [999] = "回放阶段"
}

--玩家状态
Common.GAME_PLAYER_STATE = 
{
	USER_NO_STATUS = 0,					--没有状态
    USER_FREE_STATUS = 1,			    --在房间站
    USER_WAIT_SIT = 2,					--等待坐下
    USER_SIT_TABLE = 3,					--坐到座位
    USER_READY_STATUS = 4,  			--同意状态
    USER_PLAY_GAME = 5,					--正在游戏
    USER_OFF_LINE = 6,					--用户断线
    USER_WATCH_GAME = 7					--旁观游戏
}

--游戏内协议
Common.GAME_PotoCoL_MessAge = 
{	
    --客户端
    CMD_C_OUT_CARD	= 1,		        -- 出牌
    CMD_Out_CardSound = 2,              -- 发送声音
    -- 服务器
    CMD_S_PRIVATEROOM_INFO	= 21,		-- server下发私人房信息
    CMD_S_TOTAL_SCORE_INFO	= 22,		-- server下发一个开桌的总分数信息
    CMD_DISSOLVE_ROOM = 24,         	-- 发起解散房间命令  BYTE 发起玩家椅子号
    CMD_DISSOLVE_RESULT = 25,	        -- 发送解散房间命令结果， BYTE[4] 各玩家选择结果
    -- 切牌
    CMD_Send_Qie = 5,                   -- 发送切牌选择
    CMD_Out_Qie = 58,                   -- 切牌广播
}

--炸弹类型
Common.BOMB_STATUS = 
{
	BombStatus_Quadruple 	= 0, --四张
	BombStatus_QuadrupleOne = 1	 --四带一
}

Common.STRAIGHT_MAX = 
{
	StraightMax_KKAA = 0,
	StraightMax_AA22 = 1
}

--声音分类
Common.SND_TYPE = 
{
    sndOutCard = 0, --出牌
	sndPass = 1, --不要
	sndBaoDan = 2 --报单了
}

--场景Scene的名字
Common.Scene_Name = 
{
	Scene_WelCome = 0,      --加载场景
    Scene_Main = 1,         --主界面
    Scene_Game = 2,         --游戏内界面
    Scene_CreatePrivate = 3, --创建私人房
    Scene_EnterPrivate = 4  --进入私人房
}

-- 邀请消息
Common.InviteInfo = {
	Game_Name = "五十K",
	Game_ID = 24,
    wxUrl = "http://download.5playing.com.cn/download/czmjdl.html?RoomData=",
}

--排序方式
Common.CardSortWay = 
{
    SORT_TYPE = 0,  --牌型
    SORT_VALUE = 1, --大小
    SORT_HUASE = 2  --花色
}

--每次出过的牌
Common.OutCard = 
{	
    suitType = 0,
    suitLen = 0,
	
    cards = {}
}

function Common.newMyOutCard()
    local outCard = {}

    outCard.suitType = Common.SUIT_TYPE.suitInvalid
	outCard.suitLen = 0	
	
    outCard.cards = {}

    return outCard
end

--出牌反序列化
function Common.newOutCard(ba)
    local outCard = {}

    outCard.suitType = ba:readByte()
    outCard.suitLen = ba:readByte()
    
    outCard.cards = {}

    local logStr = string.format(
        " %d(%s) -> ",
        outCard.suitType,
        Common.SUIT_Name[outCard.suitType]
    )
    for i = 1,outCard.suitLen do
        outCard.cards[i] = ba:readByte()
        logStr = logStr .. string.format(
            "[%d/%s%s] ",
            outCard.cards[i],
            Common.SUIT_Flow[math.floor(outCard.cards[i]/13)+1],
            Common.SUIT_Num[outCard.cards[i]%13+1]
        )
    end

    return outCard, logStr
end

--出牌序列化
function Common.newOutCardSerialize(outCard)
    local s = ""
    local ba = require("ByteArray").new()

    --牌的类型
    ba:writeByte(outCard.suitType)
    
    local logStr = string.format(
        "[%s] 发送出牌数据\n[%d] 打牌: %d(%s) -> ",
        os.date("%c"),
        require("k510/Game/GameLogic").myChair,
        outCard.suitType,
        Common.SUIT_Name[outCard.suitType]
    )

    --牌的长度
    ba:writeByte(outCard.suitLen)
    
    --牌值
    for i = 1, outCard.suitLen do
        ba:writeByte(outCard.cards[i])
        logStr = logStr .. string.format(
            "[%d/%s%s] ",
            outCard.cards[i],
            Common.SUIT_Flow[math.floor(outCard.cards[i]/13)+1],
            Common.SUIT_Num[outCard.cards[i]%13+1]
        )
    end
    
    logStr = logStr .. "\n"
    if debugMode then cc2file(logStr) end
    
    ba:setPos(1)

    -- cclog(s)
    
    return ba
end

-- 一局的分数信息
Common.SetScoreInfo = 
{
	nSetScore = 0,                  --分数 int
	cbLeftCardNum = 0,			    --剩余牌数
}

--单局结算数据反序列化
function Common.newSetScoreInfo(ba)
    local setScoreInfo = {}

    setScoreInfo.nUserDBID  = ba:readInt()
    setScoreInfo.cbSex      = ba:readByte()
    setScoreInfo.szUserName = ba:readStringSubZero(32)
    setScoreInfo.szUserIP   = ba:readStringSubZero(33)
        
    setScoreInfo.nSetScore  = ba:readInt()
    setScoreInfo.cbLeftCardNum = ba:readByte()
    cc2file("分数反序列化 -> DBID: %d, 姓名: %s, IP: %s, 性别: %d, 分数：%d,  剩牌: %d",
        setScoreInfo.nUserDBID, getUtf8(setScoreInfo.szUserName), setScoreInfo.szUserIP, setScoreInfo.cbSex,
        setScoreInfo.nSetScore, setScoreInfo.cbLeftCardNum
    )
    
    return setScoreInfo
end

--[[
    gameScene.nSize = 0
	gameScene.cbSystemPhase = 0         -- 游戏阶段
    -- 切牌阶段数据
	gameScene.cbChairCurQie = 0         -- 当前切牌的人
	gameScene.cbQieAble = 0             -- 可否切牌
	gameScene.cbQieValue = 0            -- 切牌值(0不切 1切 -1未切)
    -- 其它阶段数据
	gameScene.cbChairCurPlayer = 0      -- 当前控制游戏的人
	gameScene.cbRingCount = 0           -- 当前轮的第几手
    gameScene.cbMingPaiCard = 0         -- 谁先出牌
    gameScene.cbAutoOutCardTime = 15    -- 出牌等待时间
]]
-- 场景数据反序列化
function Common.newGameScene(buf, ownerChair)
    cclog("场景数据反序列化")
	if buf == nil then return nil end
    
	local gameScene = {}

    local ba = require("ByteArray").new()
    ba:writeBuf(buf)
	ba:setPos(1)
	gameScene.nSize = ba:readInt()
	gameScene.cbSystemPhase = ba:readByte()
    
    -- 切牌阶段
    if gameScene.cbSystemPhase == Common.GAME_PHRASE.enGame_QiePai then
        gameScene.cbChairCurQie = ba:readByte()
        gameScene.cbQieAble = ba:readByte()
        gameScene.cbQieValue = ba:readByte()
        local logStr = string.format(
            "[%s] 收到场景数据 阶段: %d(%s)  切牌人: %d, 可否切: %d, 切值: %d\n", os.date("%c"),
            gameScene.cbSystemPhase,
            Common.GAME_PHRASE_NAME[gameScene.cbSystemPhase],
            gameScene.cbChairCurQie,
            gameScene.cbQieAble,
            gameScene.cbQieValue
        )
        if debugMode then cc2file(logStr) end
    -- 其它阶段
    else
        -- 当前阶段牌局通用数据
        gameScene.cbChairCurPlayer = ba:readByte()
        gameScene.cbRingCount = ba:readByte()
        gameScene.cbMingPaiCard = ba:readByte()
        gameScene.cbAutoOutCardTime = ba:readByte()
        
        gameScene.m_handCards = {}
        gameScene.m_outCards = {}
        
        local logStr = string.format(
            "[%s] 收到场景数据 阶段: %d(%s)  本轮序号: %d, 庄家: %d, 出牌: %d\n", os.date("%c"),
            gameScene.cbSystemPhase,
            Common.GAME_PHRASE_NAME[gameScene.cbSystemPhase],
            gameScene.cbRingCount,
            gameScene.cbMingPaiCard,
            gameScene.cbChairCurPlayer
        )

        for i = 1, Common.PLAYER_COUNT do
            local nSize = ba:readByte()
            gameScene.m_handCards[i] = {}
            
            -- 如果是结束阶段或是自己的数据则更新手牌
            if gameScene.cbSystemPhase == Common.GAME_PHRASE.enGame_Over or i == ownerChair then
                logStr = logStr .. string.format("[%d] 手牌: ", i-1)
                for j = 1, nSize do
                    gameScene.m_handCards[i][j] = ba:readByte()
                    logStr = logStr .. string.format(
                        "[%d/%s%s] ",
                        gameScene.m_handCards[i][j],
                        Common.SUIT_Flow[math.floor(gameScene.m_handCards[i][j]/13)+1],
                        Common.SUIT_Num[gameScene.m_handCards[i][j]%13+1]
                    )
                end
                logStr = logStr .. "\n"
            -- 否则填充手牌为-1
            else
                for j = 1, nSize do
                    gameScene.m_handCards[i][j] = -1
                end
            end
            
            -- 更新出牌
            local tempStr
            gameScene.m_outCards[i], tempStr = Common.newOutCard(ba)
            
            if gameScene.m_outCards[i].suitLen > 0 then
                logStr = logStr .. string.format("[%d] 出牌: %s\n", i-1, tempStr)
            end
        end
        
        -- 飘数据
        logStr = logStr .. string.format("\n[%s] 更新场景内玩家飘数据: \n", os.date("%c"))
        for i = 1, Common.PLAYER_COUNT do
            gameScene.m_piao[i] = ba:readByte()
            logStr = logStr .. string.format( "[%d]:%d ", i-1, gameScene.m_piao[i] )
        end
        logStr = logStr .. "\n"

        -- 如果是结束阶段更新单局结算数据
        if gameScene.cbSystemPhase == Common.GAME_PHRASE.enGame_Over then
            gameScene.m_SetScores = {}
            logStr = logStr .. string.format("\n[%s] 更新当局分数: \n", os.date("%c"))
            for i = 1,Common.PLAYER_COUNT do
                gameScene.m_SetScores[i] = Common.newSetScoreInfo(ba)
                logStr = logStr .. string.format("[%d] 分数: %d\n", i-1, gameScene.m_SetScores[i].nSetScore)
            end
        end
        
        if debugMode then cc2file(logStr) end
    end
    
	return gameScene
end

-- 一个开桌的总分数信息
Common.TotalScoreInfo = 
{
    nTotalScore = 0,    				-- 总输赢分数
	nSetMaxScore = 0,					-- 最高单局分数

	cbWinSetNum = 0,					-- 赢局数
	cbLostSetNum = 0,					-- 输局数	
}

function Common.newTotalScoreInfo(buf)
    
    local totalScoreInfo = {}
    
    if buf == nil then
		return nil
	end

    local ba = require("ByteArray").new()
    ba:writeBuf(buf)
	ba:setPos(1)

    totalScoreInfo.nTotalScore = ba:readInt()
    totalScoreInfo.nSetMaxScore = ba:readInt()

    totalScoreInfo.cbWinSetNum =  ba:readByte()
    totalScoreInfo.cbLostSetNum =  ba:readByte()
    
    return totalScoreInfo

end

return Common