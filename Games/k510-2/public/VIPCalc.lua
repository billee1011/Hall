
local VIPCalc = {}
VIPCalc.__index = VIPCalc

function VIPCalc.getGoldFromRMB(rmbfen)
	local gold = 0
    local Resources = require("bull/Resources")
    local int = Resources.getIntPart(rmbfen * 0.01)
	gold = int * 10000
	return gold
end

function VIPCalc.getVipChargeAwardFromRMB(rmbfen, viplevel)
	local nbaseGold = VIPCalc.getGoldFromRMB(rmbfen)
    local gameLib = require("bull/GameLibSink").m_gameLib
	local info = gameLib:getVIPInfo(viplevel)
	if (info == nil) then
		return 0
	end
	return nbaseGold * info.nPaySendRatio / 100
end

function VIPCalc.getVIPNameColor(nLevel)
    local gameLib = require("bull/GameLibSink").m_gameLib
	local info = gameLib:getVIPInfo(nLevel)
	if (info == nil) then
		return 0
	end
	return info.nNameColor
end

function VIPCalc.getVIPBankLimit(nLevel)
    local gameLib = require("bull/GameLibSink").m_gameLib
	local info = gameLib:getVIPInfo(nLevel)
	if (info == nil) then
		return 0
	end
	return info.nBankLimit
end

function VIPCalc.getVIPFriendLimit(nLevel)
    local gameLib = require("bull/GameLibSink").m_gameLib
	local info = gameLib:getVIPInfo(nLevel)
	if (info == nil) then
		return 0
	end
	return info.nFriendLimit
end

function VIPCalc.getFreeSpeakerCount(nLevel)
    local gameLib = require("bull/GameLibSink").m_gameLib
	local info = gameLib:getVIPInfo(nLevel)
	if (info == nil) then
		return 0
	end
	return info.nFreeSpeaker
end

function VIPCalc.getVipCount()
	local nRet = 0
    local gameLib = require("bull/GameLibSink").m_gameLib
	while(true) do
		local info = gameLib:getVIPInfo(nRet)
		if (info ~= nil) then
			nRet = nRet + 1
		else
			break
		end
	end
	return nRet
end

function VIPCalc.getVipLevelPayAmount(nVipLevel)
	local nRet = 0
    local gameLib = require("bull/GameLibSink").m_gameLib
	while (true) do
		local info = gameLib:getVIPInfo(nRet)
		if (info ~= nil) then
			if (info.nLevel == nVipLevel + 1) then
				return info.nNeedPayMoney
			end
			nRet = nRet + 1
		else
			break
		end
	end
	if (nRet == VIPCalc.getVipCount() - 1) then
		return 0
	end
	return 0
end

--获取当前职称等级最大分数
function VIPCalc.getCurrentLevelGameTitleInfoMaxScoreByLevel(nLevel)
	local pInfo = VIPCalc.getGameTitleInfoByLevel(nLevel)
	if (pInfo == nil) then
		return 1
	end
	if (pInfo.nNeedExp > 0) then
		return pInfo.nNeedExp
	end
	return 1
end

function VIPCalc.getNextLevelPercent(nLevel, nScore)
	local fMaxScore = VIPCalc.getCurrentLevelGameTitleInfoMaxScoreByLevel(nLevel)
	return fMaxScore / nScore
end

return VIPCalc
