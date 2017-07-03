require("CocosExtern")
local GameUser = {}
GameUser.__index = GameUser

function GameUser:new()
    local self = {
        isZhuang = false,
        gameOldStatus = 0,
	    gameNewStatus = 0,
        rank = 255,         -- 排名
        timeOutCounts = 0,  -- 超时次数
	    handCards = {},     -- 手牌
        outCards = nil,     -- 打出去的牌
        cbLeftCardNum = 0,
        scores = 0,         -- 总分数
        nSetScore = 0,      -- 当前局分数
    }
    setmetatable(self,GameUser)
    return self
end

setmetatable(GameUser, require("GameLib/gamelib/UserInfo"))

function GameUser:refresh()
    self.rank = 255
    self.timeOutCounts = 0
    self.cbLeftCardNum = 0
	self.handCards = {}
    self.outCards = nil
    self.preOutCards = nil
    self.scores = 0
    self.nSetScore = 0
end

function GameUser:setGameOldStatus(status)
	self.gameOldStatus = status
end

function GameUser:getGameOldStatus()
	return self.gameOldStatus
end

function GameUser:setGameNewStatus(status)
	self.gameNewStatus = status
	self.gameNewStatus = status
end

function GameUser:getGameNewStatus()
	return self.gameNewStatus
end

function GameUser:setRank(rank)
	self.rank = rank
end

function GameUser:getRank()
	return self.rank
end

function GameUser:setTimeOutCounts(timeOutCounts)
	self.timeOutCounts = timeOutCounts
end

function GameUser:getTimeOutCounts()
	return self.timeOutCounts
end

function GameUser:setLeftCardNum(num)
	self.cbLeftCardNum = num
end

function GameUser:getLeftCardNum()
	return self.cbLeftCardNum
end

function GameUser:setHandCards(handCards)
    self.handCards = {}
	self.handCards = handCards
end

function GameUser:getHandCards()
	return self.handCards
end

function GameUser:getGameStatus()
	return self.gameStatus
end

function GameUser:setScores(scores)
	self.scores = scores
end

function GameUser:getScores()
	return self.scores
end

function GameUser:setCurrentScore(scores)
	self.nSetScore = scores
end

function GameUser:getCurrentScore()
	return self.nSetScore
end

-- OutCards整个结构
function GameUser:setOutCardStruct(outCards)
    --[[ if outCards.suitType == require("k510/Game/Common").SUIT_TYPE.suitDouble or outCards.suitType == require("k510/Game/Common").SUIT_TYPE.suitThree 
        or outCards.suitType == require("k510/Game/Common").SUIT_TYPE.suitStraight or outCards.suitType == require("k510/Game/Common").SUIT_TYPE.suitDoubleStraight
        or outCards.suitType == require("k510/Game/Common").SUIT_TYPE.suitTriStraight or outCards.suitType == require("k510/Game/Common").SUIT_TYPE.suitBomb then
        
        outCards.cards = require("k510/Game/Public/ShareFuns").SortCardsByCardType(outCards.cards)
        outCards.cards = require("k510/Game/Public/ShareFuns").SortCardsByMin(outCards.cards)

    elseif outCards.suitType == require("k510/Game/Common").SUIT_TYPE.suitTriAndSingle or outCards.suitType == require("k510/Game/Common").SUIT_TYPE.suitTriAndDouble then
        -- 飞机不能简单按从大到小排序 or outCards.suitType == require("k510/Game/Common").SUIT_TYPE.suitPlane then
        
        outCards.cards = require("k510/Game/Public/ShareFuns").SortCardsByMin(outCards.cards)
        local bRet,ArrayIn,ArrayOut = require("k510/Game/Public/ShareFuns").GetSameVal(outCards.cards,3)
        outCards.cards = require("k510/Game/Public/ShareFuns").Append(ArrayOut,ArrayIn)

    elseif outCards.suitType == require("k510/Game/Common").SUIT_TYPE.suitFourAndSingle or outCards.suitType == require("k510/Game/Common").SUIT_TYPE.suitFourAndTwo 
        or outCards.suitType == require("k510/Game/Common").SUIT_TYPE.suitFourAndThree  then

        outCards.cards = require("k510/Game/Public/ShareFuns").SortCardsByMin(outCards.cards)
        local bRet,ArrayIn,ArrayOut = require("k510/Game/Public/ShareFuns").GetSameVal(outCards.cards,4)
        outCards.cards = require("k510/Game/Public/ShareFuns").Append(ArrayOut,ArrayIn)
    end

    if require("k510/Game/GameLogic").gamePhase == require("k510/Game/Common").GAME_PHRASE.enGame_InitData then
        outCards.suitType = require("k510/Game/Common").SUIT_TYPE.suitInvalid
    end ]]

	self.outCards = outCards
end

-- 出的牌
function GameUser:getOutCards()
    local cards = self.outCards and self.outCards.cards or {}
    return cards
end

-- 出的牌的牌型
function GameUser:getOutCardType()
    local cardType = -1
    if self.outCards ~= nil then
        cardType = self.outCards.suitType
    end
    return cardType
end

-- 庄家
function GameUser:setZhuang(isZhuang)
   self.isZhuang = isZhuang
end

function GameUser:getZhuang()
   return self.isZhuang
end


return GameUser