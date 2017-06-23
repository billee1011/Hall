local GameDefs = {}

GameDefs.PLAYER_COUNT = 5
GameDefs.MAX_CARD_COUNT = 5

--牌的点数
GameDefs.emCardPoint = {
	CARD_POINT_INVALID = 0, --无效点数
	CARD_POINT_A = 1,
	CARD_POINT_2 = 2,
	CARD_POINT_3 = 3,
	CARD_POINT_4 = 4,
	CARD_POINT_5 = 5,
	CARD_POINT_6 = 6,
	CARD_POINT_7 = 7,
	CARD_POINT_8 = 8,
	CARD_POINT_9 = 9,
	CARD_POINT_10 = 10,
	CARD_POINT_J = 11,
	CARD_POINT_Q = 12,
	CARD_POINT_K = 13,
	CARD_POINT_HIDE = 14, --隐藏牌
}

--牌花色
GameDefs.emCardStyle = {
	CARD_STYLE_INVALID = 0, --无效花色	
	CARD_STYLE_DIAMOND = 1, --方块
	CARD_STYLE_CLUB = 2, --梅花
	CARD_STYLE_HEART = 3, --红桃
	CARD_STYLE_SPADE = 4, --黑桃
	CARD_STYLE_HIDE = 5, --隐藏牌
}

--牛的类型
GameDefs.emBullType = {
	BULL_TYPE_INVALID = 0, --无效类型
	BULL_TYPE_NULL = 1,
	BULL_TYPE_1 = 2,
	BULL_TYPE_2 = 3,
	BULL_TYPE_3 = 4,
	BULL_TYPE_4 = 5,
	BULL_TYPE_5 = 6,
	BULL_TYPE_6 = 7,
	BULL_TYPE_7 = 8,
	BULL_TYPE_8 = 9,
	BULL_TYPE_9 = 10,
	BULL_TYPE_10 = 11,
	BULL_TYPE_BOMB = 12,
	BULL_TYPE_5_JQK = 13,
	BULL_TYPE_5_MIN = 14,
	BULL_TYPE_EXIST_BULL = 15, --这个是在提示玩家手上的牌是否组成牛的时候用
}

--用户的游戏状态
GameDefs.emPlayerState = {
	PLAYER_STATE_NONE = 0, --桌子上没人
	PLAYER_STATE_FREE = 1,--自由状态，坐下而未准备
	PLAYER_STATE_READY = 2, --已准备
	PLAYER_STATE_PLAYING = 3,--正常进行游戏中

	--[[弃牌,过牌,全下 超级斗牛独有]]
	PLAYER_STATE_FOLD = 4, --弃牌
	PLAYER_STATE_CHECK = 5, --过牌
	PLAYER_STATE_ALLIN = 6,  --全下
};

--游戏场景的更新，都必须有相应的cmd类型
--emCmdType 仅用于场景的更新
GameDefs.emCmdType = {
	CMD_TYPE_INVALID = 0,	--无效命令
	CMD_TYPE_DEAL = 1,			--发牌
	CMD_TYPE_STAKE = 2,			--下注
	CMD_TYPE_ALLIN_OTHER = 3,	--梭人
	CMD_TYPE_CHECK = 4,			--过牌
	CMD_TYPE_FOLD = 5,			--弃牌
	CMD_TYPE_CHECKOUT = 6,		--结算	
	CMD_TYPE_SORT_CARD = 7,		--组牌
	CMD_TYPE_BANKER_BID = 8,	--庄家竞争
	CMD_TYPE_BANKER_SET = 9,	-- 确定庄家
	CMD_TYPE_REVERT = 10,		--好友桌一局结束再回来恢复数据
};

GameDefs.emGameSection = {
	GAME_SECTION_READY = 0,		--自由状态，等待玩家准备阶段
	GAME_SECTION_BANKER_BID = 1,    -- 竞争庄家 
	GAME_SECTION_FIRST_STAKE = 2,	--第一轮下注阶段
	GAME_SECTION_SECOND_STAKE = 3,	--第二轮下注
	GAME_SECTION_THIRD_STAKE = 4,   --第三轮下注
	GAME_SECTION_CARD_SORT = 5,     -- 组牌
	GAME_SECTION_CHECK_OUT = 6,		--结算阶段
	GAME_SECTION_INVALID = 0xFF     --无效阶段
}

GameDefs.EN_BANKER_BID = {
	EN_BANKER_BID_NONE = 0,     -- 未表态
	EN_BANKER_BID_WANT = 1,     -- 想要
	EN_BANKER_BID_WONT = 2,     -- 不想
	EN_BANKER_BID_MUST = 3,     -- 超级抢庄
}

--客户端向服务器发送消息ID
GameDefs.emClientToServerGameMsg = {
	CS_GAMEMSG_STAKE = 0, --下注
	CS_GAMEMSG_FOLD = 1,		--弃牌
	CS_GAMEMSG_ALLIN_OTHER = 2,	--梭人
    CS_GAMEMSG_ANMEND = 3,		--动画结束
	CS_GAMEMSG_SHOW_HIDE_CARD = 4, --开底牌
	CS_GAMEMSG_BID = 5,			--抢庄
	CS_GAMEMSG_SHOW = 6,		--组牌
	CS_GAMEMSG_READY = 7,		--向游戏逻辑发送准备
	CS_GAMEMSG_MAX = 127	--消息的最大ID只能是127.超过这个值发送会失败
};	

--[[
--单张牌的类型
function GameDefs.stSingleCardType(ba)
	local singleCardType = {}
	singleCardType.m_byCardPoint = ba:readByte()
	singleCardType.m_byCardStyle = ba:readByte()
	singleCardType.m_byIsSelect = ba:readByte()
	return singleCardType
end

function GameDefs.stBullData(ba)
	local bullData = {}
	bullData.m_byBullType = ba:readByte()
	bullData.m_maxSingleCardType = GameDefs.stSingleCardType(ba)
	return bullData
end

function GameDefs.stCardGroup(ba)
	local cardGroup = {}
	cardGroup.m_stMaxRullData = GameDefs.stBullData(ba)
	cardGroup.m_arrCard = {}
	for i=1,GameDefs.MAX_CARD_COUNT do
		cardGroup.m_arrCard[i] = GameDefs.stSingleCardType(ba)
	end
	cardGroup.m_nCurCardCount = ba:readInt()
	cardGroup.m_bIsSort = ba:readByte()
	return cardGroup
end
]]

--单张牌的类型
GameDefs.stSingleCardType = {}
GameDefs.stSingleCardType.__index = GameDefs.stSingleCardType
function GameDefs.stSingleCardType:new()
    local self=
    {
        m_byCardPoint = 0,
        m_byCardStyle = 0,
        m_byIsSelect = 0,
    }
    setmetatable(self, GameDefs.stSingleCardType)
    return self
end
function GameDefs.stSingleCardType:Serialize()
    local ba = require("ByteArray").new()
    ba:writeByte(self.m_byCardPoint)
    ba:writeByte(self.m_byCardStyle)
    ba:writeByte(self.m_byIsSelect)
    ba:setPos(1)
    return ba
end
function GameDefs.stSingleCardType:DeSerialize(ba)
    self.m_byCardPoint = ba:readByte()
	self.m_byCardStyle = ba:readByte()
	self.m_byIsSelect = ba:readByte()
end
function GameDefs.stSingleCardType:IsHide()
    if self.m_byCardStyle == GameDefs.emCardStyle.CARD_STYLE_HIDE and self.m_byCardPoint == GameDefs.emCardPoint.CARD_POINT_HIDE then
    	return true
    end
    return false
end
function GameDefs.stSingleCardType:IsValid()
    if self.m_byCardStyle == GameDefs.emCardStyle.CARD_STYLE_INVALID and self.m_byCardPoint == GameDefs.emCardPoint.CARD_POINT_INVALID then
    	return false
    end
    return true
end

GameDefs.stBullData = {}
GameDefs.stBullData.__index = GameDefs.stBullData
function GameDefs.stBullData:new()
    local self=
    {
        m_byBullType = 0,
        m_maxSingleCardType = GameDefs.stSingleCardType:new(),
    }
    setmetatable(self, GameDefs.stBullData)
    return self
end
function GameDefs.stBullData:Serialize()
    local ba = require("ByteArray").new()
    ba:writeByte(self.m_byBullType)
    ba:writeByteArray(self.m_maxSingleCardType:Serialize())
    ba:setPos(1)
    return ba
end
function GameDefs.stBullData:DeSerialize(ba)
    self.m_byBullType = ba:readByte()
	self.m_maxSingleCardType = GameDefs.stSingleCardType:new()
	self.m_maxSingleCardType:DeSerialize(ba)
end

GameDefs.stCardGroup = {}
GameDefs.stCardGroup.__index = GameDefs.stCardGroup
function GameDefs.stCardGroup:new()
    local self=
    {
        m_stMaxRullData = GameDefs.stBullData:new(),
        m_arrCard = {},
        m_nCurCardCount = 0,
        m_bIsSort = 0,
    }
    setmetatable(self, GameDefs.stCardGroup)
    return self
end
function GameDefs.stCardGroup:Serialize()
    local ba = require("ByteArray").new()
    ba:writeByteArray(self.m_stMaxRullData:Serialize())
    for i=1,GameDefs.MAX_CARD_COUNT do
    	ba:writeByteArray(self.m_arrCard[i]:Serialize())
	end
	ba:writeInt(self.m_nCurCardCount)
	ba:writeByte(self.m_bIsSort)
    ba:setPos(1)
    return ba
end
function GameDefs.stCardGroup:DeSerialize(ba)
	self.m_stMaxRullData = GameDefs.stBullData:new()
	self.m_stMaxRullData:DeSerialize(ba)
	for i=1,GameDefs.MAX_CARD_COUNT do
		self.m_arrCard[i] = GameDefs.stSingleCardType:new()
		self.m_arrCard[i]:DeSerialize(ba)
	end
	self.m_nCurCardCount = ba:readInt()
	self.m_bIsSort = ba:readByte()
end
function GameDefs.stCardGroup:Sort()
	for i=1, self.m_nCurCardCount do
		for j=i+1, self.m_nCurCardCount do
			if self.m_arrCard[i].m_byCardPoint < self.m_arrCard[j].m_byCardPoint then
				local oneCard = self.m_arrCard[i]
				self.m_arrCard[i] = self.m_arrCard[j]
				self.m_arrCard[j] = oneCard
			elseif self.m_arrCard[i].m_byCardPoint == self.m_arrCard[j].m_byCardPoint then
				if self.m_arrCard[i].m_byCardStyle < self.m_arrCard[j].m_byCardStyle then
					local oneCard = self.m_arrCard[i]
					self.m_arrCard[i] = self.m_arrCard[j]
					self.m_arrCard[j] = oneCard
				end
			end
		end
	end
end

function GameDefs.GameScene(ba)
	local gs = {}
	gs.m_cbActionChair = ba:readByte()
	gs.m_cbCommand = ba:readByte()
	gs.m_cbGameSection = ba:readByte()

	gs.m_cbPlayerState = {}
	for i=1,GameDefs.PLAYER_COUNT do
		gs.m_cbPlayerState[i] = ba:readByte()
	end

	gs.m_allPlayerCard = {}
	for i=1,GameDefs.PLAYER_COUNT do
		gs.m_allPlayerCard[i] = GameDefs.stCardGroup:new()
		gs.m_allPlayerCard[i]:DeSerialize(ba)
		--gs.m_allPlayerCard[i]:Sort()
	end

	gs.m_uPlayerGold = {}
	for i=1,GameDefs.PLAYER_COUNT do
		gs.m_uPlayerGold[i] = ba:readUInt()
	end

	gs.m_cbBanker = ba:readByte()
	gs.m_lParam = ba:readInt()

	gs.m_acbBankerBid = {}
	for i=1,GameDefs.PLAYER_COUNT do
		gs.m_acbBankerBid[i] = ba:readByte()
	end

	gs.m_alStake = {}
	for i=1,GameDefs.PLAYER_COUNT do
		gs.m_alStake[i] = ba:readInt()
	end

	gs.m_isShow = {}
	for i=1,GameDefs.PLAYER_COUNT do
		gs.m_isShow[i] = ba:readByte()
	end

	gs.m_byReserver = {}
	for i=1,20 do
		gs.m_byReserver[i] = ba:readByte()
	end
	
	return gs
end

function GameDefs.ST_GameEnd(ba)
	local gameEnd = {}
	gameEnd.nScore = {}
	for i=1,GameDefs.PLAYER_COUNT do
		gameEnd.nScore[i] = ba:readInt()
	end
	return gameEnd
end

return GameDefs
