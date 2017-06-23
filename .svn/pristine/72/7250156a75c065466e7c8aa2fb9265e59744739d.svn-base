--local FruitDefs = require("sgmj/FruitDefs")

local ClientFrameSink = { }
ClientFrameSink.__index = ClientFrameSink
function ClientFrameSink:new()
	local self = {}
	setmetatable(self,ClientFrameSink)	
	return self
end

local GameDefs = require("sgmj/GameDefs")
local GameLibSink = require("sgmj/GameLibSink")
local GameLogic = require("sgmj/Game/GameLogic")

function ClientFrameSink:onSceneChanged(pData,nLen)
	if(pData ~= nil) then
		cclog("ClientFrameSink:onSceneChanged nLen = " .. nLen .. ",ba:len = ")
		GameLogic:getInstance():onRecveSocketData({1, {pData, nLen}})
	end
end

function ClientFrameSink:onPlayerStateChanged(chair,oldState,newState)
	
end

function ClientFrameSink:onGetMainVersion()
	return 1
end

function ClientFrameSink:onGetSubVersion()
	return 1
end

function ClientFrameSink:onGameStart()
	
end

function ClientFrameSink:onGameMessage(chair,cbCmdID,data,nLen)
	local ba = require("ByteArray").new()
	if(data ~= nil) then
		ba:initBuf(data)
	end	

	GameLogic:getInstance():onRecveSocketData({2, {chair, cbCmdID, data, nLen}})
end

function ClientFrameSink:onGameSystemMsg(systemMsg)

end

function ClientFrameSink:onGameSystemMsg(systemMsg)
	
end

function ClientFrameSink:onEnterSingleMode()
	
end

function ClientFrameSink:onGameEnd(data,nLen)
	
end

function ClientFrameSink:onGameOption(option)
	
end

function ClientFrameSink:onUserEnterTable(chair,wUserID,isPlayer)
    local pMyself = GameLibSink:getMyInfo()
    if (pMyself and wUserID == pMyself:getUserID()) and isPlayer then
    	--玩家已经坐下
		GameLogic:getInstance():onRecveSocketData({9, pMyself})
    end
end

function ClientFrameSink:onUserExitTable(chair,wUserID,isPlayer)
    if GameLogic.isLogicExist() then
    	local pMyself = GameLibSink:getMyInfo()
    	if pMyself and isPlayer then
    		GameLogic:getInstance():onRecveSocketData({3, {chair, wUserID == pMyself:getUserID()}})
    	end
    end	

    cclog("ClientFrameSink:onUserExitTable "..chair..";"..wUserID)
end

function ClientFrameSink:onDispatch(reserved1,reserved2,resvered3)
	
end

-- 金币超过房间上限
function ClientFrameSink:onNotEnoughGold(nMinGold,nMaxGold)
	
end

-- wUserID，对象
function ClientFrameSink:OnKickFailed(wUserID)
	
end
-- wKickUserID，被谁踢,wBeKickUserID 谁被踢
function ClientFrameSink:OnBeKicked(wKickUserID,wBeKickUserID)
	
end

-- 收到声音广播
function ClientFrameSink:onTableSound(nChair,pBuf,nLen)
	
end

return ClientFrameSink