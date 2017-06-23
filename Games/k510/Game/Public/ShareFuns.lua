require("CocosExtern")
local Common = require("k510/Game/Common")

local ShareFuns = {}

--拷贝(checked)
function ShareFuns.Copy(CardArrayIn)
    local CardArrayOut = {}
    for i = 1,#CardArrayIn do
        table.insert(CardArrayOut,CardArrayIn[i])
    end
    return CardArrayOut
end

--添加(checked)
function ShareFuns.Append(CardArrayIn,AppendCardArray)
	for i=1,#AppendCardArray do
		table.insert(CardArrayIn,AppendCardArray[i])
	end
	return CardArrayIn
end

--反转(checked)
function ShareFuns.Reverse(cardArray)
	local size = #cardArray
	if size == 0 then
		return
	end

	local newCardArray ={}
	for i=1,size do
		newCardArray[i] = cardArray[size - i + 1]
	end

	return newCardArray
end


--有没有A(checked)
function ShareFuns.isHasA(cardArray)
	for i = 1,#cardArray do
		if ShareFuns.CardValue(cardArray[i]) == Common.CARDVALUE_A then
			return i
		end
	end

	return -1
end

--有没有2(checked)
function ShareFuns.isHas2(cardArray)
	for i = 1,#cardArray do
		if ShareFuns.CardValue(cardArray[i]) == Common.CARDVALUE_2 then
			return i
		end
	end

	return -1   
end

--有没有黑桃三(checked)
function ShareFuns.isHasHeitao3(cardArray)
	for i = 1,#cardArray do
		if ShareFuns.CardValue(cardArray[i]) == Common.CARDVALUE_3 and ShareFuns.CardType(cardArray[i]) == Common.CARDTYPE_SPADE then
			return i
		end
	end

	return -1   
end

function ShareFuns.isHaveRedJoker(cardArray)
	for i = 1,#cardArray do
		if ShareFuns.CardValue(cardArray[i]) == Common.CARDVALUE_Joker then
			return true
		end
	end
	
	return false
end

--牌值是否连续递增(checked)
function ShareFuns.IsSeqByVal(cardArray)
	local firstval = ShareFuns.CardValue(cardArray[1])	
	for i = 2, #cardArray do
		if firstval ~= ShareFuns.CardValue(cardArray[i]) + i - 1 then
			return false
		end
	end
	return true
end

--取出cardArrayIn中所有同值数量等于nCompare的牌并从cardArrayIn中删除
function ShareFuns.GetSameVal(cardArrayIn,nCompare)
  cardArrayIn = ShareFuns.SortCards(cardArrayIn)
  local cardArrayOut = {}	
	local TempArray = {}

	if  #cardArrayIn < nCompare then
		return false,cardArrayIn, cardArrayOut
	end

	local i = 1
	local cbNums = 1
	while true do
        
		if i > #cardArrayIn then 
			break
		end
        
        TempArray = {}

		table.insert(TempArray,cardArrayIn[i])
		cbNums = 1
		
		for j = i + 1, #cardArrayIn do 

			if ShareFuns.CardValue(cardArrayIn[i]) == ShareFuns.CardValue(cardArrayIn[j]) then				
				table.insert(TempArray,cardArrayIn[j])
				cbNums = cbNums + 1

				if cbNums == nCompare then
					for k = 1,#TempArray do
						table.insert(cardArrayOut,TempArray[k])
					end
					break
				end
			else
				cbNums = 1
				break
			end				
			
			if cbNums == nCompare then
				for k = 1,#TempArray do
					table.insert(cardArrayOut,TempArray[k])
				end
			end
		end
		i = i + cbNums
	end

	if  #cardArrayOut > 0 then
		-- 从in中去掉所有的
		for i = 1,#cardArrayOut do
			local iEquIdx = -1
			for j = 1,#cardArrayIn do			
				if cardArrayOut[i] == cardArrayIn[j] then
					iEquIdx = j
					break
				end
			end

			if  iEquIdx ~= -1 then
				table.remove(cardArrayIn, iEquIdx)
			end
		end

		return true, cardArrayIn, cardArrayOut
	end
	
	return false,cardArrayIn, cardArrayOut
end


--逆时针椅子号
function ShareFuns.AntiClockWise(chair)
	return (chair+Common.PLAYER_COUNT-1)%Common.PLAYER_COUNT
end

--顺时针椅子号
function ShareFuns.ClockWise(chair)
	return (chair+1)%Common.PLAYER_COUNT
end


--获取牌值(checked)
function ShareFuns.CardValue(CardIndex)
	if not(CardIndex >= 0 and CardIndex <= 51) then
		return Common.CARDVALUE_INVALID
	end

	local valueIndex = CardIndex % 13
	local value = valueIndex - 1
	if CardIndex == 53 then
		value = Common.CARDVALUE_Joker
	elseif valueIndex == 0 then
		value = Common.CARDVALUE_A
    elseif valueIndex == 1 then
        value = Common.CARDVALUE_2
	end

	return value
end

--获取花色(checked)
function ShareFuns.CardType(CardIndex)
	local cType = math.floor(CardIndex/13)
	return cType
end

-- 按花色排序, 同花色按从大到小(checked)
function ShareFuns.SortCardsByCardType(cardArray)
    if #cardArray < 2 then return cardArray end
	local tempCardArray = ShareFuns.Copy(cardArray)
    table.sort(tempCardArray, function(a, b)
        if ShareFuns.CardType(a) == ShareFuns.CardType(b) then
            return ShareFuns.CardValue(a) > ShareFuns.CardValue(b)
        else
            return ShareFuns.CardType(a) > ShareFuns.CardType(b)
        end
    end)
	return tempCardArray
end

-- 简单插入排序 从大到小, 同值按花色从大到小(checked)
function ShareFuns.SortCards(cardArray)
    if #cardArray < 2 then return cardArray end
	local tempCardArray = ShareFuns.Copy(cardArray)
    table.sort(tempCardArray, function(a, b)
        if ShareFuns.CardValue(a) == ShareFuns.CardValue(b) then
            return ShareFuns.CardType(a) > ShareFuns.CardType(b)
        else
            return ShareFuns.CardValue(a) > ShareFuns.CardValue(b)
        end
    end)
	return tempCardArray
end

-- 简单插入排序 从小到大, 同值按花色从大到小(checked)
function ShareFuns.SortCardsByMin(cardArray)
    if #cardArray < 2 then return cardArray end
	local tempCardArray = ShareFuns.Copy(cardArray)
    table.sort(tempCardArray, function(a, b)
        if ShareFuns.CardValue(a) == ShareFuns.CardValue(b) then
            return ShareFuns.CardType(a) > ShareFuns.CardType(b)
        else
            return ShareFuns.CardValue(a) < ShareFuns.CardValue(b)
        end
    end)
	return tempCardArray
end

-- 去掉重复的值(checked)
function ShareFuns.GetOnlyInArray(cardArrayIn)
	local cardArrayInTemp = ShareFuns.Copy(cardArrayIn)
	local cardArrayOut = {}
	for i = 1,#cardArrayInTemp do
		if cardArrayInTemp[i] ~= -1 then
			for j = i + 1,#cardArrayInTemp do
				if j > #cardArrayInTemp then
					break
				end

				if ShareFuns.CardValue(cardArrayInTemp[i]) == ShareFuns.CardValue(cardArrayInTemp[j]) then
					cardArrayInTemp[j] = -1
				end
			end

			table.insert(cardArrayOut,cardArrayInTemp[i])
		end
	end

	return cardArrayOut
end

-- 去掉重复的对子(checked)
function ShareFuns.RemoveSameDouble( cardArrayIn )
	local cardArrayInTemp = ShareFuns.Copy(cardArrayIn)
	for i = 1, #cardArrayInTemp - 2, 2 do
	    if ShareFuns.CardValue(cardArrayInTemp[i]) == ShareFuns.CardValue(cardArrayInTemp[i+2]) then			
			cardArrayInTemp[i+2] = -1
			cardArrayInTemp[i+3] = -1
		end
	end
	 
	local ArrayOut = {}
	for i = 1, #cardArrayInTemp, 1 do
		if -1 ~= cardArrayInTemp[i] then
			table.insert(ArrayOut,cardArrayInTemp[i])
		end
	end

	return ArrayOut
end

-- 从一个数组删除一组数组(checked)
function ShareFuns.RemoveAryFromAry(cardArrayIn,cardArrayRemove)
	local cardArrayInTemp = ShareFuns.Copy(cardArrayIn)
	local cardArrayRemoveTemp = ShareFuns.Copy(cardArrayRemove)

	local cardArrayOut = {}
	for i = 1,#cardArrayInTemp do
		for j = 1,#cardArrayRemoveTemp do
			if cardArrayRemoveTemp[j] == cardArrayInTemp[i] and cardArrayRemoveTemp[j] ~= -1 then
				cardArrayRemoveTemp[j] = -1
				cardArrayInTemp[i] = -1
				break
			end
		end
	end

	for i=1,#cardArrayInTemp do
		if cardArrayInTemp[i] ~= -1 then
			table.insert(cardArrayOut,cardArrayInTemp[i])
		end
	end

	return cardArrayOut

end

-- 是不是单张(checked)
function ShareFuns.IsSingle(cardArray)
	return (#cardArray == 1 and ShareFuns.CardValue(cardArray[1]) ~= Common.CARDVALUE_Joker)
end

-- 是不是一对(checked)
function ShareFuns.IsDouble(cardArray)
	if #cardArray == 2 
    and ShareFuns.CardValue(cardArray[1]) == ShareFuns.CardValue(cardArray[2]) then
        return true
	end

	return false
end

-- 是不是三张(checked)
function ShareFuns.IsTriple(cardArray)
	if #cardArray == 3 
    and ShareFuns.CardValue(cardArray[1]) == ShareFuns.CardValue(cardArray[2]) 
    and ShareFuns.CardValue(cardArray[2]) == ShareFuns.CardValue(cardArray[3]) then
        return true
	end

	return false
end

-- 是不是三带对(checked)
function ShareFuns.IsTriAndDouble(cardArray)
    local outCardArray = {}
    if #cardArray ~= 5 then
        return false,outCardArray
    end
	
	if ShareFuns.isHaveRedJoker(cardArray) then
		return false,outCardArray
	end

    local bRet,ArrayIn,ArrayOut = false,{},{}
	ArrayIn = ShareFuns.Copy(cardArray)
	bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal(ArrayIn,3)

    if not bRet then
        return false,outCardArray
    end

    if ShareFuns.CardValue(ArrayIn[1]) == ShareFuns.CardValue(ArrayIn[2]) and ShareFuns.CardValue(ArrayIn[1]) ~= ShareFuns.CardValue(ArrayOut[1]) then
        outCardArray = ShareFuns.Copy(ArrayIn)
        outCardArray = ShareFuns.Append(ArrayOut,outCardArray)--把outCardArray接到ArrayOut后面
        return true,outCardArray
    end

    return false,outCardArray
end

-- 是不是单顺(checked)
function ShareFuns.IsStraight(cardArray)
	if ShareFuns.isHaveRedJoker(cardArray) then
		return false,{}
	end
	
	if pos > 0 then
		return false,{}
	end

	if #cardArray >= 5 then
		local pos2 = ShareFuns.isHas2(cardArray)
		if pos2 < 0 then
			return ShareFuns.isSeqByVal(cardArray),cardArray
		elseif pos2 == 1 then
			if ShareFuns.CardValue(cardArray[#cardArray]) == 1 then -- 有2必定有3,否则不为顺子
				local posA = ShareFuns.isHasA(cardArray)
				local firstval = Common.CARDVALUE_3
				local length = #cardArray - 1
				if posA < 0 then
					for i = length,2,-1 do
						if Common.CARDVALUE_3 ~= ShareFuns.CardValue(cardArray[i]) - length + i then
							return false,{}
						end
					end		
					local tmpArray = {}
					table.insert(tmpArray,cardArray[1])
					cardArray[1] = nil
					ShareFuns.Append(cardArray,tmpArray)					
					return true,cardArray
				elseif posA == 2 then
					for i = length,3,-1 do
						if Common.CARDVALUE_3 ~= ShareFuns.CardValue(cardArray[i]) - length + i then
							return false,{}
						end
					end
					local tmpArray = {}
					for i = 3,#cardArray do
						table.insert(cardArray[i])
					end
					for j = 1,2 do
						table.insert(cardArray[j])
					end
					cardArray = {}
					cardArray = ShareFuns.Copy(tmpArray)					
					return true,cardArray
				end
			end
		end
	end

	return false,{}
end

-- 是不是双顺/连对(checked)
function ShareFuns.IsDoubleStraight(cardArray)
	if	#cardArray < 4 or #cardArray % 2 ~= 0 or ShareFuns.isHaveRedJoker(cardArray) then
		return false,{}
	end

	local singleArray = {}

	--取对子中的单张组成单牌型
	for i = 1,#cardArray - 1,2 do
		if ShareFuns.CardValue(cardArray[i]) == ShareFuns.CardValue(cardArray[i + 1]) then
			table.insert(singleArray,cardArray[i])
		else
			return false,{}
		end
	end

	--判断是否是单顺
	if #singleArray == 2 and ShareFuns.CardValue(singleArray[1]) == 13 and ShareFuns.CardValue(singleArray[2]) == 12 then
		return true,cardArray
	else
		local pos2 = ShareFuns.isHas2(singleArray)
		if pos2 < 0 then
			return ShareFuns.isSeqByVal(singleArray),cardArray
		elseif pos2 == 1 then
			if ShareFuns.CardValue(singleArray[#singleArray]) == 1 then -- 有2必定有3,否则不为顺子
				local posA = ShareFuns.isHasA(singleArray)
				local firstval = Common.CARDVALUE_3
				local length = #singleArray - 1
				if posA < 0 then
					for i = length,2,-1 do
						if Common.CARDVALUE_3 ~= ShareFuns.CardValue(singleArray[i]) - length + i then
							return false,{}
						end
					end	
					local tmpArray = {}
					for i = 3,#cardArray do
						table.insert(cardArray[i])
					end
					for j = 1,2 do
						table.insert(cardArray[j])
					end
					cardArray = {}
					cardArray = ShareFuns.Copy(tmpArray)					
					return true,cardArray
				elseif posA == 2 then
					for i = length,3,-1 do
						if Common.CARDVALUE_3 ~= ShareFuns.CardValue(singleArray[i]) - length + i then
							return false,{}
						end
					end
					local tmpArray = {}
					for i = 5,#cardArray do
						table.insert(cardArray[i])
					end
					for j = 1,4 do
						table.insert(cardArray[j])
					end
					cardArray = {}
					cardArray = ShareFuns.Copy(tmpArray)					
					return true,cardArray
				end
			end
		end
	end

	return false,{}
end

-- 是不是三顺(checked)
function ShareFuns.IsTriStraight(cardArray)
	if #cardArray < 6 or #cardArray%3 ~= 0 or ShareFuns.isHaveRedJoker(cardArray) then
		return false,{}
	end

	local singleArray = {}

	--都是三条
	for i = 1, #cardArray - 2, 3 do
		if ShareFuns.CardValue(cardArray[i]) == ShareFuns.CardValue(cardArray[i + 1]) 
		   and ShareFuns.CardValue(cardArray[i]) == ShareFuns.CardValue(cardArray[i + 2]) then
		   table.insert(singleArray,cardArray[i])
		else
			return false,{}
		end
	end

	--判断是否是单顺
	if #singleArray == 2 and ShareFuns.CardValue(singleArray[1]) == 13 and ShareFuns.CardValue(singleArray[2]) == 12 then
		return true,cardArray
	else
		local pos2 = ShareFuns.isHas2(singleArray)
		if pos2 < 0 then
			return ShareFuns.isSeqByVal(singleArray),cardArray
		elseif pos2 == 1 then
			if ShareFuns.CardValue(singleArray[#singleArray]) == 1 then -- 有2必定有3,否则不为顺子
				local posA = ShareFuns.isHasA(singleArray)
				local firstval = Common.CARDVALUE_3
				local length = #singleArray - 1
				if posA < 0 then
					for i = length,2,-1 do
						if Common.CARDVALUE_3 ~= ShareFuns.CardValue(singleArray[i]) - length + i then
							return false,{}
						end
					end						
					local tmpArray = {}
					for i = 4,#cardArray do
						table.insert(cardArray[i])
					end
					for j = 1,3 do
						table.insert(cardArray[j])
					end
					cardArray = {}
					cardArray = ShareFuns.Copy(tmpArray)					
					return true,cardArray
				elseif posA == 2 then
					for i = length,3,-1 do
						if Common.CARDVALUE_3 ~= ShareFuns.CardValue(singleArray[i]) - length + i then
							return false,{}
						end
					end
					local tmpArray = {}
					for i = 7,#cardArray do
						table.insert(cardArray[i])
					end
					for j = 1,6 do
						table.insert(cardArray[j])
					end
					cardArray = {}
					cardArray = ShareFuns.Copy(tmpArray)					
					return true,cardArray
				end
			end
		end
	end

	return false,{}
end

-- 获取连续三张的最大个数(checked)
function ShareFuns.getTriSeqCount(cardArray)
    -- 三张取单值
	local ArrayTemp = {}
    for i = 1, #cardArray - 2, 3 do
        table.insert(ArrayTemp, cardArray[i])
    end
    ShareFuns.SortCards(ArrayTemp)
    -- 值连续性比较
    local maxSeqCount, seqCount = 0, 1
    for i = 1, #ArrayTemp do
        for j = i+1, #ArrayTemp do
            if ShareFuns.CardValue(ArrayTemp[j-1]) ~= (ShareFuns.CardValue(ArrayTemp[j]) + 1) then
                break
            end
            seqCount = seqCount + 1
        end
        if maxSeqCount < seqCount then maxSeqCount = seqCount end
        seqCount = 1
    end
    
    return maxSeqCount
end

-- 是不是飞机带翅膀(checked)
function ShareFuns.IsPlane(cardArray)
	if #cardArray%2 ~= 0 or ShareFuns.isHaveRedJoker(cardArray) then
		return false
	end
	
	local bRet,ArrayIn,ArrayOut = false,{},{}
	ArrayIn = ShareFuns.Copy(cardArray)
	
	bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal( ArrayIn, 3 )
	if bRet then
		if #ArrayIn%2 == #ArrayOut%3 then
			local ret1,ret2,triArray,douArray = false,false,{},{}
			ret1,triArray = ShareFuns.IsTriStraight(ArrayOut)
			ret2,douArray = ShareFuns.IsDoubleStraight(ArrayIn)
			if ret1 and ret2 then
				cardArray = {}
				cardArray = ShareFuns.Copy(triArray)
				ShareFuns.Append(cardArray,douArray)
				return true,cardArray
			end	
		end
	end

    return false,cardArray
end

-- 是不是炸弹(checked)
function ShareFuns.IsBomb(cardArray,bombStatus)
	if bombStatus == Common.BOMB_STATUS.BombStatus_Quadruple then
		if #cardArray == 4 then
			local cardval = ShareFuns.CardValue(cardArray[1])
			for i = 2,#cardArray do
				if cardval ~= ShareFuns.CardValue(cardArray[i]) then
					return false,{}
				end

			end
			return true,cardArray
		end
	else 
		local bRet,ArrayIn,ArrayOut = false,{},{}
		if #cardArray == 5 then
		   ArrayIn = ShareFuns.Copy(cardArray)
		   bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal( ArrayIn, 4 )
		   if bRet then
				cardArray = ShareFuns.Append(ArrayOut,ArrayIn)
				return true,cardArray
		   end
		end
	end
	return false
end

-- 510k
function ShareFuns.IsFiveTenKing(cardArray)
	if #cardArray == 3 then
		if ShareFuns.CardValue(cardArray[1]) + ShareFuns.CardValue(cardArray[1]) + ShareFuns.CardValue(cardArray[1]) == 22 then
			if ShareFuns.CardValue(cardArray[1]) == 11 and ShareFuns.CardValue(cardArray[1]) == 8 then
				if ShareFuns.CardType(cardArray[1]) == ShareFuns.CardType(cardArray[2]) and ShareFuns.CardType(cardArray[1]) == ShareFuns.CardType(cardArray[3]) then
					return false
				end
				return true
			end
		end
	end
	
	return false
end

-- 纯510k
function ShareFuns.IsPureFiveTenKing(cardArray)
	if #cardArray == 3 then
		if ShareFuns.CardValue(cardArray[1]) + ShareFuns.CardValue(cardArray[1]) + ShareFuns.CardValue(cardArray[1]) == 22 then
			if ShareFuns.CardValue(cardArray[1]) == 11 and ShareFuns.CardValue(cardArray[1]) == 8 then
				if ShareFuns.CardType(cardArray[1]) == ShareFuns.CardType(cardArray[2]) and ShareFuns.CardType(cardArray[1]) == ShareFuns.CardType(cardArray[3]) then
					return true
				end
			end
		end
	end
	
	return false
end

-- 大王
function ShareFuns.IsRedJoker(cardArray)
	if #cardArray == 1 and ShareFuns.CardValue(cardArray[1]) == Common.CARDVALUE_Joker then
		return true
	end
end

-- 获取出牌类型(checked)
function ShareFuns.GetCardSuitType(cardArray,bombStatus)
	local retSt = Common.SUIT_TYPE.suitInvalid
	local tempArray = ShareFuns.Copy(cardArray)

	if ShareFuns.IsSingle(tempArray) then
		retSt = Common.SUIT_TYPE.suitSingle
	elseif ShareFuns.IsDouble(tempArray) then
		retSt = Common.SUIT_TYPE.suitDouble
	elseif ShareFuns.IsTriple(tempArray) then
		retSt = Common.SUIT_TYPE.suitTriple
    elseif ShareFuns.IsFiveTenKing(tempArray) then
		retSt = Common.SUIT_TYPE.suitFourAndSingle
	elseif ShareFuns.IsPureFiveTenKing(tempArray) then
		retSt = Common.SUIT_TYPE.suitFourAndTwo
    elseif ShareFuns.IsRedJoker(tempArray) then
		retSt = Common.SUIT_TYPE.suitFourAndThree
	else
		local bRet = false
		local outArray = {}
		bRet,outArray = ShareFuns.IsStraight(tempArray)
		if bRet == true then
			retSt = Common.SUIT_TYPE.suitStraight
			return retSt,outArray
		end
		
		bRet = false
		outArray = {}
		tempArray = ShareFuns.Copy(cardArray)
		bRet,outArray = ShareFuns.IsDoubleStraight(tempArray)
		if bRet == true then
			retSt = Common.SUIT_TYPE.suitDoubleStraight
			return retSt,outArray
		end
		
		bRet = false
		outArray = {}
		tempArray = ShareFuns.Copy(cardArray)
		bRet,outArray = ShareFuns.IsTriStraight(tempArray)
		if bRet == true then
			retSt = Common.SUIT_TYPE.suitTriStraight
			return retSt,outArray
		end

		bRet = false
		outArray = {}
		tempArray = ShareFuns.Copy(cardArray)
		bRet,outArray = ShareFuns.IsTriAndDouble(tempArray)
		if bRet == true then
			retSt = Common.SUIT_TYPE.suitTriAndDouble
			return retSt,outArray
		end

		bRet = false
		outArray = {}
		tempArray = ShareFuns.Copy(cardArray)
		bRet,outArray = ShareFuns.IsBomb(tempArray,bombStatus)
		if bRet == true then
			retSt = Common.SUIT_TYPE.suitBomb
			return retSt,outArray
		end
		
		bRet = false
		outArray = {}
		tempArray = ShareFuns.Copy(cardArray)
		bRet,outArray = ShareFuns.IsPlane(tempArray)
		if bRet then
			retSt = Common.SUIT_TYPE.suitPlane
			return retSt,outArray
		end
	end

	return retSt,cardArray
end

-- 分解出牌型(checked)
function ShareFuns.DisassembleToOutCard(cardArray)
	local OutCard = {}
	local st,cardArray = ShareFuns.GetCardSuitType(cardArray)
	if st ~= Common.SUIT_TYPE.suitInvalid then
		local OutCard = Common.newMyOutCard()	
        OutCard.suitType = st
        OutCard.suitLen = #cardArray
        OutCard.cards = ShareFuns.Copy(cardArray)
        return true,OutCard
	end
	return false,OutCard
end

-- 比较两手牌的大小(checked)
function ShareFuns.CompareTwoCardSuit(prevOutcard,followOutCard,straightMax)
	if prevOutcard.suitType == followOutCard.suitType then--牌型相同
		if prevOutcard.suitType == Common.suitDoubleStraight or prevOutcard.suitType == Common.suitTriStraight or prevOutcard.suitType == Common.suitPlane then
			if straightMax == Common.STRAIGHT_MAX.StraightMax_KKAA then
				if (ShareFuns.CardValue(prevOutcard.cards[1]))%13 < (ShareFuns.CardValue(followOutCard.cards[1]))%13 then --比较第一张
					return true
				else
					return false
				end
			else 
				if ShareFuns.CardValue(prevOutcard.cards[1]) < ShareFuns.CardValue(followOutCard.cards[1]) then --比较第一张
					return true
				else
					return false
				end
			end
		elseif prevOutcard.suitType == Common.suitStraight then
			if ShareFuns.CardValue(prevOutcard.cards[1]) < ShareFuns.CardValue(followOutCard.cards[1]) then --比较第一张
				return true
			else
				return false
			end
		else
			if prevOutcard.suitLen == followOutCard.suitLen then--张数相同
				if ShareFuns.CardValue(prevOutcard.cards[1]) < ShareFuns.CardValue(followOutCard.cards[1]) then --比较第一张
					return true
				else
					return false
				end
			end
		end
	else--牌型不同
		if followOutCard.suitType == Common.SUIT_TYPE.suitBomb then
			return true
		elseif followOutCard.suitType == Common.SUIT_TYPE.suitRedJoker and prevOutcard.suitType ~= Common.SUIT_TYPE.suitBomb then
			return true
		elseif followOutCard.suitType == Common.SUIT_TYPE.suitPureFiveTenKing and prevOutcard.suitType ~= Common.SUIT_TYPE.suitBomb 
			and prevOutcard.suitType ~= Common.SUIT_TYPE.suitRedJoker then
			return true
		elseif followOutCard.suitType == Common.SUIT_TYPE.suitFiveTenKing and prevOutcard.suitType ~= Common.SUIT_TYPE.suitBomb 
			and prevOutcard.suitType ~= Common.SUIT_TYPE.suitRedJoker and prevOutcard.suitType ~= Common.SUIT_TYPE.suitPureFiveTenKing then
			return true
		end
	end
	return false
end

-- 得到单张(checked)
function ShareFuns.GetSingle(cardArrayIn,nCompare,nNotEqual)
	local bRet = false
	local ArrayIn,ArrayOut = {},{}
	ArrayIn = ShareFuns.Copy(cardArrayIn)
    
	--去掉所有重复的牌
	for iLen = 4, 2, -1 do
		bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal( ArrayIn, iLen )
	end
	local cardArrayOut = {}
    
	--剩下的是手中牌里的所有单张
	if #ArrayIn > 0 then
		--取最小一张大于cbCompaer的牌
		for i = #ArrayIn, 1, -1 do
			if ShareFuns.CardValue(ArrayIn[i]) > ShareFuns.CardValue(nCompare ) and ShareFuns.CardValue(ArrayIn[i]) ~= ShareFuns.CardValue(nNotEqual ) then
				table.insert(cardArrayOut,ArrayIn[i])
				return true,cardArrayOut
			end
		end
	end

	--拆牌 取最小的一张大于nCompare 的牌
	for i = #cardArrayIn, 1, -1 do
		if ShareFuns.CardValue(cardArrayIn[i]) > ShareFuns.CardValue(nCompare ) and ShareFuns.CardValue(cardArrayIn[i]) ~= ShareFuns.CardValue(nNotEqual ) then
			table.insert(cardArrayOut,cardArrayIn[i])
			return true,cardArrayOut
		end
	end

	return false,cardArrayOut
end

-- 得到一对(checked)
function ShareFuns.GetDouble(cardArrayIn,nCompare )
	local cardArrayOut = {}
	if #cardArrayIn < 2 then
		return false,cardArrayOut
	end
	local bRet = false
	local ArrayIn,ArrayOut = {},{}
    
	--优先取已有的对子，先将三张以上的重复牌去掉
	ArrayIn = ShareFuns.Copy(cardArrayIn)
	for iLen = 4, 3, -1 do
		bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal( ArrayIn, iLen )
	end
    -- 然后从剩下的牌中取对子
	ArrayOut = {}
	bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal( ArrayIn, 2 )
	if bRet == true then
		if nCompare == -1 then
			table.insert(cardArrayOut,ArrayOut[#ArrayOut])
			table.insert(cardArrayOut,ArrayOut[#ArrayOut - 1])
			return true,cardArrayOut
		end

		for i = #ArrayOut, 2, -1 do
			if ShareFuns.CardValue(ArrayOut[i]) > ShareFuns.CardValue(nCompare) then
				table.insert(cardArrayOut,ArrayOut[i])
				table.insert(cardArrayOut,ArrayOut[i - 1])
				return true,cardArrayOut
			end
		end
	end

    -- 如果没有对子则从全部牌中再取一次
	ArrayIn = ShareFuns.Copy(cardArrayIn)
	ArrayOut = {}
	bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal( ArrayIn, 2 )
	if bRet == true then
		if nCompare == -1 then
			table.insert(cardArrayOut,ArrayOut[#ArrayOut])
			table.insert(cardArrayOut,ArrayOut[#ArrayOut - 1])
			return true,cardArrayOut
		end

		for i = #ArrayOut, 2, -1 do
			if ShareFuns.CardValue(ArrayOut[i]) > ShareFuns.CardValue(nCompare ) then
				table.insert(cardArrayOut,ArrayOut[i])
				table.insert(cardArrayOut,ArrayOut[i - 1])
				return true,cardArrayOut
			end
		end		
	end
	return false,cardArrayOut
end

function ShareFuns.GetTriple( cardArrayIn,nCompare)
		local cardArrayOut = {}
	if #cardArrayIn < 5 then
		return false,cardArrayOut
	end
	local bRet = false
	local ArrayIn,ArrayOut = {},{}

	-- 优先取三张，先将四张以上的重复牌去掉
	ArrayIn = ShareFuns.Copy(cardArrayIn)
	bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal( ArrayIn, 4 )

	ArrayOut = {}

	-- 取出三条
	bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal( ArrayIn, 3 )
	if bRet then
		for i = #ArrayOut, 3, -1 do
            -- 比较大小
			if ShareFuns.CardValue(ArrayOut[i]) > ShareFuns.CardValue(nCompare ) then
				table.insert(cardArrayOut,ArrayOut[i])
				table.insert(cardArrayOut,ArrayOut[i - 1])
				table.insert(cardArrayOut,ArrayOut[i - 2])
				return true,cardArrayOut
			end
		end
	end
	
	ArrayIn = ShareFuns.Copy(cardArrayIn)
	ArrayOut = {}
	bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal( ArrayIn, 3 )
	if bRet then
		for i = #ArrayOut, 3, -1 do
			-- 比较大小
			if ShareFuns.CardValue(ArrayOut[i]) > ShareFuns.CardValue(nCompare ) then
				table.insert(cardArrayOut,ArrayOut[i])
				table.insert(cardArrayOut,ArrayOut[i - 1])
				table.insert(cardArrayOut,ArrayOut[i - 2])
				return true,cardArrayOut
			end
		end
	end
	return false,cardArrayOut
end

-- 得到三带二(checked)
function ShareFuns.GetTriAndDbl( cardArrayIn,nCompare  )
	local cardArrayOut = {}
	if #cardArrayIn < 5 then
		return false,cardArrayOut
	end
	local bRet = false
	local ArrayIn,ArrayOut = {},{}

	-- 优先取三张，先将四张以上的重复牌去掉
	ArrayIn = ShareFuns.Copy(cardArrayIn)
	bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal( ArrayIn, 4 )

	ArrayOut = {}
	local b1 = false
	local b2 = false

	-- 取出三条
	bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal( ArrayIn, 3 )
	if bRet then
		for i = #ArrayOut, 3, -1 do
            -- 比较大小
			if ShareFuns.CardValue(ArrayOut[i]) > ShareFuns.CardValue(nCompare ) then
				table.insert(cardArrayOut,ArrayOut[i])
				table.insert(cardArrayOut,ArrayOut[i - 1])
				table.insert(cardArrayOut,ArrayOut[i - 2])
				b1 = true
				break
			end
		end
	end
	
	if not b1 then
		ArrayIn = ShareFuns.Copy(cardArrayIn)
		ArrayOut = {}
		bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal( ArrayIn, 3 )
		if bRet then
			for i = #ArrayOut, 3, -1 do
				-- 比较大小
				if ShareFuns.CardValue(ArrayOut[i]) > ShareFuns.CardValue(nCompare ) then
					table.insert(cardArrayOut,ArrayOut[i])
					table.insert(cardArrayOut,ArrayOut[i - 1])
					table.insert(cardArrayOut,ArrayOut[i - 2])
					b1 = true
					break
				end
			end
		end
	end

    -- 如果有三条牌
	if b1 or b2 then
        -- 去除已取到的三条牌
        ArrayIn = ShareFuns.Copy(cardArrayIn)
        ArrayIn = ShareFuns.RemoveAryFromAry(ArrayIn, cardArrayOut)
        
		--从剩下的牌中取两张 
		local ArrayTmp, ArrayDouble = {},{}

        ArrayTmp = ShareFuns.Copy(ArrayIn)
		
        local bRet = false
        
        bRet,ArrayDouble = ShareFuns.GetDouble(ArrayTmp,-1)
		if bRet then
			cardArrayOut = ShareFuns.Append(cardArrayOut,ArrayDouble)
			return true,cardArrayOut
		end
	end
    
	return false,cardArrayOut
end

-- 得到顺子(checked)
function ShareFuns.GetStraight( cardArrayIn,nCompare  )
	local cardArrayOut = {}
	if #cardArrayIn < 5 then
		return false,cardArrayOut
	end

	local tempArray = {}
	tempArray = ShareFuns.Copy(cardArrayIn)

	--去掉重复的值
	local tempArray1 = {}
	tempArray1 = ShareFuns.GetOnlyInArray(tempArray)

	--tempArray1 在这里面找顺子
	if #tempArray1 < 5 then
		return false,cardArrayOut
	end

	local straightArray = {}
	for j = #tempArray1,5,-1 do
		straightArray = {}
		for k = j - 5 + 1,j do
			table.insert(straightArray,tempArray1[k])
		end

		local ret = false
		ret,cardArrayOut = ShareFuns.IsStraight(straightArray)
		if ret then
			if ShareFuns.CardValue(cardArrayOut[1]) > ShareFuns.CardValue(nCompare) then
				return true,cardArrayOut
			end
		end
	end
	
	local pos = ShareFuns.isHas2(tempArray1)
	straightArray = {}
	for i = #tempArray1 - 4,#tempArray1 do
		table.insert(straightArray,tempArray1[i])
	end
	table.insert(straightArray,tempArray1[pos])
	local ret = false
	ret,cardArrayOut = ShareFuns.IsStraight(straightArray)
	if ret then
		if ShareFuns.CardValue(cardArrayOut[1]) > ShareFuns.CardValue(nCompare) then
			return true,cardArrayOut
		end
	end
	return false,cardArrayOut
end

-- 得到双顺(checked)
function ShareFuns.GetDoubleStraight( cardArrayIn,nCompare,straightMax )
	local cardArrayOut = {}
	if #cardArrayIn < 4 then
		return false,cardArrayOut
	end

	local bRet = false
	local ArrayIn,ArrayOut = {},{}
    
	--三张以上的重复牌去掉
	ArrayIn = ShareFuns.Copy(cardArrayIn)
	for iLen = 4, 3, -1 do
		bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal( ArrayIn, iLen )
	end

	bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal( ArrayIn, 2 )
	if bRet then
		if #ArrayOut >= 4 then
			local straightArray = {}
			for j = #ArrayOut,4,-1 do
				straightArray = {}
				for k = j - 4 + 1, j do
					table.insert(straightArray,ArrayOut[k])
				end
				local ret,douArray = ShareFuns.IsDoubleStraight(straightArray)
				if ret then
					if straightMax == Common.STRAIGHT_MAX.StraightMax_KKAA then
						if (ShareFuns.CardValue(douArray[1]))%13 > (ShareFuns.CardValue(nCompare))%13 then
							return true,douArray
						end
					else
						if ShareFuns.CardValue(douArray[1]) > ShareFuns.CardValue(nCompare) then
							return true,douArray
						end
					end
				end
			end
			
			local pos = ShareFuns.isHas2(ArrayOut)
			if pos == 1 then
				straightArray = {}
				for i = #ArrayOut - 2,#ArrayOut do
					table.insert(straightArray,ArrayOut[i])
				end
				for i = 1,2 do
					table.insert(straightArray,ArrayOut[i])
				end
				local ret,douArray = ShareFuns.IsDoubleStraight(straightArray)
				if ret then
					if straightMax == Common.STRAIGHT_MAX.StraightMax_KKAA then
						if (ShareFuns.CardValue(douArray[1]))%13 > (ShareFuns.CardValue(nCompare))%13 then
							return true,douArray
						end
					else
						if ShareFuns.CardValue(douArray[1]) > ShareFuns.CardValue(nCompare) then
							return true,douArray
						end
					end
				end
			end
		end
	end

	ArrayOut = {}
	ArrayIn = ShareFuns.Copy(cardArrayIn)
	bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal( ArrayIn, 2 )
	if bRet then
		--去掉重复的对子
		ArrayOut = ShareFuns.RemoveSameDouble(ArrayOut)

		if #ArrayOut >= nCardLen then
			local straightArray = {}
			for j = #ArrayOut,nCardLen,-1 do
				straightArray = {}
				for k = j - nCardLen + 1,j do
					table.insert(straightArray,ArrayOut[k])
				end

				local ret,douArray = ShareFuns.IsDoubleStraight(straightArray)
				if ret then
					if straightMax == Common.STRAIGHT_MAX.StraightMax_KKAA then
						if (ShareFuns.CardValue(douArray[1]))%13 > (ShareFuns.CardValue(nCompare))%13 then
							return true,douArray
						end
					else
						if ShareFuns.CardValue(douArray[1]) > ShareFuns.CardValue(nCompare) then
							return true,douArray
						end
					end
				end
			end
			
			local pos = ShareFuns.isHas2(ArrayOut)
			if pos == 1 then
				straightArray = {}
				for i = #ArrayOut - 2,#ArrayOut do
					table.insert(straightArray,ArrayOut[i])
				end
				for i = 1,2 do
					table.insert(straightArray,ArrayOut[i])
				end
				local ret,douArray = ShareFuns.IsDoubleStraight(straightArray)
				if ret then
					if straightMax == Common.STRAIGHT_MAX.StraightMax_KKAA then
						if (ShareFuns.CardValue(douArray[1]))%13 > (ShareFuns.CardValue(nCompare))%13 then
							return true,douArray
						end
					else
						if ShareFuns.CardValue(douArray[1]) > ShareFuns.CardValue(nCompare) then
							return true,douArray
						end
					end
				end
			end
		end
	end

	return false,cardArrayOut
end

-- 得到三顺(checked)
function ShareFuns.GetTriStraight( cardArrayIn,nCompare,straightMax  )
	local cardArrayOut = {}
	if #cardArrayIn < 6 then
		return false,cardArrayOut
	end

	local bRet = false
	local ArrayIn,ArrayOut = {},{}
	ArrayIn = ShareFuns.Copy(cardArrayIn)

	-- 四张以上的重复牌
	bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal( ArrayIn, 4 )

    -- 取得所有三张牌
	bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal( ArrayIn, 3 )
	if bRet and #ArrayOut >= 6 then
		local straightArray = {}
		for j = #ArrayOut,6,-1 do
			straightArray = {}
			for k = j - 6 + 1, j do
				table.insert(straightArray,ArrayOut[k])
			end
            table.print(straightArray)
			local ret,douArray = ShareFuns.IsTriStraight(straightArray)
			if ret then
				if straightMax == Common.STRAIGHT_MAX.StraightMax_KKAA then
					if (ShareFuns.CardValue(douArray[1]))%13 > (ShareFuns.CardValue(nCompare))%13 then
						return true,douArray
					end
				else
					if ShareFuns.CardValue(douArray[1]) > ShareFuns.CardValue(nCompare) then
						return true,douArray
					end
				end
			end
		end
		
		local pos = ShareFuns.isHas2(ArrayOut)
			if pos == 1 then
				straightArray = {}
				for i = #ArrayOut - 3,#ArrayOut do
					table.insert(straightArray,ArrayOut[i])
				end
				for i = 1,3 do
					table.insert(straightArray,ArrayOut[i])
				end
				local ret,douArray = ShareFuns.IsTriStraight(straightArray)
				if ret then
					if straightMax == Common.STRAIGHT_MAX.StraightMax_KKAA then
						if (ShareFuns.CardValue(douArray[1]))%13 > (ShareFuns.CardValue(nCompare))%13 then
							return true,douArray
						end
					else
						if ShareFuns.CardValue(douArray[1]) > ShareFuns.CardValue(nCompare) then
							return true,douArray
						end
					end
				end
			end
	end
	
	ArrayOut = {}
	ArrayIn = ShareFuns.Copy(cardArrayIn)
	bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal( ArrayIn, 3 )
	if bRet and #ArrayOut >= 6 then
		local straightArray = {}
		for j = #ArrayOut,6,-1 do
			straightArray = {}
			for k = j - 6 + 1, j do
				table.insert(straightArray,ArrayOut[k])
			end
            table.print(straightArray)
			local ret,douArray = ShareFuns.IsTriStraight(straightArray)
			if ret then
				if straightMax == Common.STRAIGHT_MAX.StraightMax_KKAA then
					if (ShareFuns.CardValue(douArray[1]))%13 > (ShareFuns.CardValue(nCompare))%13 then
						return true,douArray
					end
				else
					if ShareFuns.CardValue(douArray[1]) > ShareFuns.CardValue(nCompare) then
						return true,douArray
					end
				end
			end
		end
		
		local pos = ShareFuns.isHas2(ArrayOut)
			if pos == 1 then
				straightArray = {}
				for i = #ArrayOut - 3,#ArrayOut do
					table.insert(straightArray,ArrayOut[i])
				end
				for i = 1,3 do
					table.insert(straightArray,ArrayOut[i])
				end
				local ret,douArray = ShareFuns.IsTriStraight(straightArray)
				if ret then
					if straightMax == Common.STRAIGHT_MAX.StraightMax_KKAA then
						if (ShareFuns.CardValue(douArray[1]))%13 > (ShareFuns.CardValue(nCompare))%13 then
							return true,douArray
						end
					else
						if ShareFuns.CardValue(douArray[1]) > ShareFuns.CardValue(nCompare) then
							return true,douArray
						end
					end
				end
			end
	end

	return false,cardArrayOut
end

-- 得到飞机(checked)
function ShareFuns.GetPlane( cardArrayIn,nCompare,straightMax  )
	local cardArrayOut = {}
	if #cardArrayIn < 10 then
		return false,cardArrayOut
	end

	local bRet = false
	local ArrayIn,ArrayOut = {},{}
	ArrayIn = ShareFuns.Copy(cardArrayIn)

	--取三顺
	bRet,ArrayOut = ShareFuns.GetTriStraight(ArrayIn,nCompare,straightMax )
	if bRet then
		ArrayIn = {}
		ArrayIn = ShareFuns.Copy(cardArrayIn)
		ArrayIn = ShareFuns.RemoveAryFromAry(ArrayIn, ArrayOut)

        local bRetTemp  = false
        local ArrayWing = {}
		--取翅膀
        bRetTemp,ArrayWing = ShareFuns.GetDoubleStraight(ArrayIn,-1,straightMax)
		if bRetTemp then
			cardArrayOut = ShareFuns.Copy(ArrayOut)
			cardArrayOut = ShareFuns.Append(CardArrayOut,ArrayWing)
			return true,cardArrayOut
		end
	end

	return false,cardArrayOut
end

-- 得到炸弹(checked)
function ShareFuns.GetBomb( cardArrayIn, nCompare, bombStatus)
	local cardArrayOut = {}
	
	if bombStatus == Common.BOMB_STATUS.BombStatus_Quadruple then
		if #cardArrayIn < 4 then
			return false,cardArrayOut
		end
	else
		if #cardArrayIn < 5 then
			return false,cardArrayOut
		end
	end


	local bRet = false
	local ArrayIn,ArrayOut = {},{}
	ArrayIn = ShareFuns.Copy(cardArrayIn)

	bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal(ArrayIn,4)
	if bRet and #ArrayOut >= 4 then
		local bombArray = {}
		for j = #ArrayOut,4,-1 do
			bombArray = {}
			for k = j - 3,j do
				table.insert(bombArray,ArrayOut[k])
			end

			if bombStatus == Common.BOMB_STATUS.BombStatus_QuadrupleOne then
				local ret,singleArray = ShareFuns.GetSingle(ArrayIn)
				if ret then
					bombArray = ShareFuns.Append(bombArray,singleArray)
				end
			end
			
			local ret = false
			ret,bombArray = ShareFuns.IsBomb(bombArray)
			if ret then
				if nCompare == -1 then
					return true,bombArray
				end

				if ShareFuns.CardValue(bombArray[1]) > ShareFuns.CardValue(nCompare)  then
					return true,bombArray
				end
			end
		end
	end

	return false,cardArrayOut
end

function GetFiveTenKing(cardArrayIn)
	local cardArrayOut = {}
	if #cardArrayIn < 3 then
		return false,cardArrayOut
	end
	
	local arrayIn,arrayFive,arrayTen,arrayKing = {},{},{},{}
	local isHaveFive,isHaveTen,isHaveKing = false,false,false
	arrayIn = ShareFuns.Copy(cardArrayIn)
	
	for i = 1,#arrayIn do
		if ShareFuns.CardValue(arrayIn[i]) == 11 then
			table.insert(arrayKing,arrayIn[i])
			isHaveKing = true
		elseif ShareFuns.CardValue(arrayIn[i]) == 8 then
			table.insert(arrayTen,arrayIn[i])
			isHaveTen = true
		elseif ShareFuns.CardValue(arrayIn[i]) == 3 then
			table.insert(arrayFive,arrayIn[i])
			isHaveFive = true
		end
	end
	
	if isHaveFive and isHaveKing and isHaveTen then
		for i = 1,#arrayKing do
			for j = 1,#arrayTen do
				if ShareFuns.CardType(arrayKing[i]) ~= ShareFuns.CardType(arrayTen[j]) then
					table.insert(cardArrayOut,arrayKing[i])
					table.insert(cardArrayOut,arrayTen[j])
					table.insert(cardArrayOut,arrayFive[0])
					return true,cardArrayOut
				end
			end
		end
		
		for i = 1,#arrayFive do
			if ShareFuns.CardType(arrayKing[0]) ~= ShareFuns.CardType(arrayTen[i]) then
				table.insert(cardArrayOut,arrayKing[0])
				table.insert(cardArrayOut,arrayTen[0])
				table.insert(cardArrayOut,arrayFive[i])
				return true,cardArrayOut
			end
		end
	end
	
	return false,cardArrayOut
end

function GetPureFiveTenKing(cardArrayIn)
	local cardArrayOut = {}
	if #cardArrayIn < 3 then
		return false,cardArrayOut
	end
	
	local arrayIn,arrayFive,arrayTen,arrayKing = {},{},{},{}
	local isHaveFive,isHaveTen,isHaveKing = false,false,false
	arrayIn = ShareFuns.Copy(cardArrayIn)
	
	for i = 1,#arrayIn do
		if ShareFuns.CardValue(arrayIn[i]) == 11 then
			table.insert(arrayKing,arrayIn[i])
			isHaveKing = true
		elseif ShareFuns.CardValue(arrayIn[i]) == 8 then
			table.insert(arrayTen,arrayIn[i])
			isHaveTen = true
		elseif ShareFuns.CardValue(arrayIn[i]) == 3 then
			table.insert(arrayFive,arrayIn[i])
			isHaveFive = true
		end
	end
	
	if isHaveFive and isHaveKing and isHaveTen then
		for i = 1,#arrayKing do
			for j = 1,#arrayTen do
				for k = 1,#arrayFive do
					if ShareFuns.CardType(arrayKing[i]) == ShareFuns.CardType(arrayTen[j])
						and ShareFuns.CardType(arrayKing[i]) == ShareFuns.CardType(arrayFive[k]) then
						table.insert(cardArrayOut,arrayKing[i])
						table.insert(cardArrayOut,arrayTen[j])
						table.insert(cardArrayOut,arrayFive[k])
						return true,cardArrayOut
					end
				end
			end
		end
	end
	
	return false,cardArrayOut
end

function GetRedJoker(cardArrayIn)
	local cardArrayOut = {}
	
	for i = 1,#cardArrayIn do
		if ShareFuns.CardType(cardArrayIn[i]) == Common.CARDTYPE_Joker then
			table.insert(cardArrayOut,cardArrayIn[i])
			return true,cardArrayOut
		end
	end
	
	return false,cardArrayOut
end

-- 提示出牌(checked)
function ShareFuns.TipOutCard(lastOutCard,cardArrayHold,bombStatus,straightMax)
	local cardArrayOut = {}
    local lastSt = lastOutCard.suitType
    if lastSt == Common.SUIT_TYPE.suitInvalid or lastSt == Common.suitPass then
    	return false,cardArrayOut
    end

    cardArrayHold = ShareFuns.SortCards(cardArrayHold)
    local arrayInHold = {}
    arrayInHold = ShareFuns.Copy(cardArrayHold)

    local bRet = false
    if lastSt == Common.SUIT_TYPE.suitSingle then
    	bRet,cardArrayOut = ShareFuns.GetSingle(arrayInHold,lastOutCard.cards[1],-1)
    	if bRet then
    		return true,cardArrayOut
    	end
    elseif lastSt == Common.SUIT_TYPE.suitDouble then
    	bRet,cardArrayOut = ShareFuns.GetDouble(arrayInHold,lastOutCard.cards[1])
    	if bRet then
    		return true,cardArrayOut
    	end
	elseif lastSt == Common.SUIT_TYPE.suitTriple then
    	bRet,cardArrayOut = ShareFuns.GetTriple(arrayInHold,lastOutCard.cards[1])
    	if bRet then
    		return true,cardArrayOut
    	end
    elseif lastSt == Common.SUIT_TYPE.suitTriAndDouble then
    	bRet,cardArrayOut = ShareFuns.GetTriAndDbl(arrayInHold,lastOutCard.cards[1])
    	if bRet then
    		return true,cardArrayOut
    	end
    elseif lastSt == Common.SUIT_TYPE.suitStraight then
    	bRet,cardArrayOut = ShareFuns.GetStraight(arrayInHold,lastOutCard.cards[1])
    	if bRet then
    		return true,cardArrayOut
    	end
    elseif lastSt == Common.SUIT_TYPE.suitDoubleStraight then
    	bRet,cardArrayOut = ShareFuns.GetDoubleStraight(arrayInHold,lastOutCard.cards[1],straightMax)
    	if bRet then
    		return true,cardArrayOut
    	end
    elseif lastSt == Common.SUIT_TYPE.suitTriStraight then
    	bRet,cardArrayOut = ShareFuns.GetTriStraight(arrayInHold,lastOutCard.cards[1],straightMax)
    	if bRet then
    		return true,cardArrayOut
    	end
    elseif lastSt == Common.SUIT_TYPE.suitPlane then
    	bRet,cardArrayOut = ShareFuns.GetPlane(arrayInHold,lastOutCard.cards[1],straightMax)
    	if bRet then
    		return true,cardArrayOut
    	end
    elseif lastSt == Common.SUIT_TYPE.suitBomb then
    	bRet,cardArrayOut = ShareFuns.GetBomb(arrayInHold,lastOutCard.cards[1],bombStatus)
    	if bRet then
    		return true,cardArrayOut
    	end
    elseif lastSt == Common.SUIT_TYPE.suitFiveTenKing then
    	bRet,cardArrayOut = ShareFuns.GetPureFiveTenKing(arrayInHold)
    	if bRet then
    		return true,cardArrayOut
		else
			bRet,cardArrayOut = ShareFuns.GetRedJoker(arrayInHold)
			if bRet then
				return true,cardArrayOut
			else
				bRet,cardArrayOut = ShareFuns.GetBomb(arrayInHold,-1,bombStatus)
				if bRet then
					return true,cardArrayOut
				end
			end
    	end
	elseif lastSt == Common.SUIT_TYPE.suitPureFiveTenKing then
    	bRet,cardArrayOut = ShareFuns.GetRedJoker(arrayInHold)
    	if bRet then
    		return true,cardArrayOut
		else
			bRet,cardArrayOut = ShareFuns.GetBomb(arrayInHold,-1,bombStatus)
			if bRet then
				return true,cardArrayOut
			end
    	end
    end

    -- 如果没有合适的牌型则取出炸弹
    if lastSt ~= Common.SUIT_TYPE.suitBomb then
		bRet,cardArrayOut = ShareFuns.GetBomb(arrayInHold,-1,bombStatus)
    	if bRet then
    		return true,cardArrayOut
    	end
    end

    return false,cardArrayOut
end

-- 获取首次出牌(checked)
function ShareFuns.GetFirstCards(cardArrayHold)
    local bRet,ArrayIn,ArrayOut,cardArrayOut = false,{},{},{}
    ArrayIn = ShareFuns.Copy(cardArrayHold)
    
    -- 先取单张
    for i = 4, 2 ,-1 do
        bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal(ArrayIn,i)
    end

    if #ArrayIn > 0 then
        table.insert(cardArrayOut,ArrayIn[#ArrayIn])
        return cardArrayOut
    end

    -- 再取对子
    ArrayIn = ShareFuns.Copy(cardArrayHold)
    for i = 4, 3 ,-1 do
        bRet,ArrayIn,ArrayOut = ShareFuns.GetSameVal(ArrayIn,i)
    end

    if #ArrayIn > 0 then
         table.insert(cardArrayOut,ArrayIn[#ArrayIn])
         table.insert(cardArrayOut,ArrayIn[#ArrayIn-1])
         return cardArrayOut
    end

    -- 再取三带二
    ArrayIn = ShareFuns.Copy(cardArrayHold)
    bRet,cardArrayOut = ShareFuns.GetTriAndDbl(ArrayIn,-1)
    if bRet then
        return cardArrayOut
    end

    -- 再取双顺
    ArrayIn = ShareFuns.Copy(cardArrayHold)
    bRet,cardArrayOut = ShareFuns.GetDoubleStraight(ArrayIn,4,-1)
    if bRet then
        return cardArrayOut
    end

    -- 返回最小一张牌
    return cardArrayHold[#cardArrayHold]
end

-- 下家报单的牌型判定(checked)
function ShareFuns.NotPassBaodanJudge(myHandCards, nextHandCards, arrayOut)
    if #nextHandCards == 1 and #arrayOut == 1 then
        if ShareFuns.CardValue(arrayOut[1]) ~= ShareFuns.CardValue(myHandCards[1]) then
            return true
        end
    end
    return false
end

return ShareFuns