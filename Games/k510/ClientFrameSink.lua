
local Resources = require("k510/Resources")
local GameLogic = require("k510/Game/GameLogic")
local GameLibSink = require("k510/GameLibSink")
local Common = require("k510/Game/Common")
local ClientFrameSink = {}

ClientFrameSink.__index = ClientFrameSink

function ClientFrameSink:new()
	local self = {}
	setmetatable(self,ClientFrameSink)	
	return self
end

function ClientFrameSink:onSceneChanged(pData,nLen)
	-- local ba = require("ByteArray").new()
	-- if(pData ~= nil) then
	-- ba:initBuf(pData)
	-- end
	cclog("ClientFrameSink:onSceneChanged 0x80+1 nLen = %d", nLen)

	if (GameLogic:getStaySceneName() == Common.Scene_Name.Scene_Game) then
        GameLogic:onSceneChanged(pData,nLen)
    end
end

function ClientFrameSink:onPlayerStateChanged(chair,oldState,newState)
	cclog("ClientFrameSink:onPlayerStateChanged: "..chair)
    if (GameLogic:getStaySceneName() == Common.Scene_Name.Scene_Game) then
        GameLogic:setUserGameStatus(chair,oldState,newState)
        GameLogic:onSceneChanged(pData,nLen)
    end
end

function ClientFrameSink:onGetMainVersion()
	return 256
end

function ClientFrameSink:onGetSubVersion()
	return 1
end

function ClientFrameSink:onGameStart()
	cclog("ClientFrameSink:onGameStart")
	if (GameLogic:getStaySceneName() == Common.Scene_Name.Scene_Game) then
        GameLogic:onGameStart()
    end
end

function ClientFrameSink:onGameMessage(chair,cbCmdID,data,nLen)
	-- local ba = require("ByteArray").new()
	-- if(data ~= nil) then
	-- ba:initBuf(data)
	-- end
    GameLogic:OnGameMessage(chair,cbCmdID,data,nLen)
end

function ClientFrameSink:onEnterSingleMode()
	cclog("ClientFrameSink:onEnterSingleMode")
end

function ClientFrameSink:onGameEnd(data,nLen)
	cclog("ClientFrameSink:onGameEnd")
    if (GameLogic:getStaySceneName() == Common.Scene_Name.Scene_Game) then
        GameLogic:onGameEnd()
    end
end

function ClientFrameSink:onGameOption(option)
	cclog("ClientFrameSink:onGameOption")
	
end

function ClientFrameSink:onUserEnterTable(chair,wUserID,isPlayer)
    local pMyself = GameLibSink.game_lib:getMyself()
    if (pMyself and wUserID == pMyself:getUserID()) and isPlayer then
    	--玩家本人已经坐下
        cclog("ClientFrameSink:onUserEnterTable")
        require("Lobby/FriendGame/FriendGameLogic").enterGameRoomSuccess()
        GameLogic:replaceMainScence()
    end
    GameLogic:onUserEnterTable(chair,wUserID,isPlayer)
end

function ClientFrameSink:onUserExitTable(chair,userID,isPlayer)
	cclog("ClientFrameSink:onUserExitTable")
	if isPlayer then
        GameLogic:onUserExitTable(chair,wUserID,isPlayer)
    end
end

function ClientFrameSink:onDispatch(reserved1,reserved2,resvered3)
	cclog("ClientFrameSink:onDispatch")
end

-- 超级豆超过房间上限
function ClientFrameSink:onNotEnoughGold(nMinGold,nMaxGold)
	cclog("ClientFrameSink:onNotEnoughGold")
end

-- wUserID，对象
function ClientFrameSink:OnKickFailed(wUserID)
	cclog("ClientFrameSink:OnKickFailed")
end
-- wKickUserID，被谁踢,wBeKickUserID 谁被踢
function ClientFrameSink:OnBeKicked(wKickUserID,wBeKickUserID)
	cclog("ClientFrameSink:OnBeKicked")
end

-- 收到声音广播
function ClientFrameSink:onTableSound(nChair,pBuf,nLen)
	cclog("ClientFrameSink:onTableSound")
end

-- 收到系统消息
function ClientFrameSink:onGameSystemMsg(msg)
    cclog("ClientFrameSink:onGameSystemMsg %s", msg)
end

return ClientFrameSink