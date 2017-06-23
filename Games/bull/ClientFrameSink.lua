local Resources = require("bull/Resources")
local GameLibSink = require("bull/GameLibSink")
require("AudioEngine")

local ClientFrameSink = { }
ClientFrameSink.__index = ClientFrameSink

ClientFrameSink.N_DELAYTIME = 0.2

function ClientFrameSink:new()
	local self = {}	
	setmetatable(self,ClientFrameSink)	
	return self
end

function ClientFrameSink:onSceneChanged(pData,nLen)

--[[	if not GameLibSink.game_lib:isServicing() then
		return
	end]]
	cclog("ClientFrameSink:onSceneChanged nLen = " .. nLen)
	if GameLibSink.sDeskLayer then
		GameLibSink.sDeskLayer:onSceneChanged(pData,nLen)
--[[	else
		local function callback()
			self:onSceneChanged(pData,nLen)
		end
		delayAction(callback,ClientFrameSink.N_DELAYTIME)]]
	end
end

function ClientFrameSink:onPlayerStateChanged(chair,oldState,newState)
--[[	if not GameLibSink.game_lib:isServicing() then
		return
	end]]
    cclog("ClientFrameSink:onPlayerStateChanged")

    if GameLibSink.sDeskLayer then
	    GameLibSink.sDeskLayer:onPlayerStateChanged(chair,oldState,newState)
--[[	else
		local function callback()
			self:onPlayerStateChanged(chair,oldState,newState)
		end
		delayAction(callback,ClientFrameSink.N_DELAYTIME)]]
    end
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
--[[	if not GameLibSink.game_lib:isServicing() then
		return
	end]]
	cclog("ClientFrameSink:onGameMessage chair = %d, nLen = %d, cbCmdID = %d" , chair, nLen, cbCmdID)
	if GameLibSink.sDeskLayer then
		GameLibSink.sDeskLayer:onGameMessage(chair,cbCmdID,data,nLen)
--[[	else
		local function callback()
			self:onGameMessage(chair,cbCmdID,data,nLen)
		end
		delayAction(callback,ClientFrameSink.N_DELAYTIME)]]
	end
end

function ClientFrameSink:onGameSystemMsg(systemMsg)
	cclog("ClientFrameSink:onGameStart")
end

function ClientFrameSink:onEnterSingleMode()
	cclog("ClientFrameSink:onEnterSingleMode")
end

function ClientFrameSink:onGameEnd(data,nLen)
	cclog("ClientFrameSink:onGameEnd")
end

function ClientFrameSink:onGameOption(option)
	cclog("ClientFrameSink:onGameOption")
end

function ClientFrameSink:onUserEnterTable(chair,wUserID,isPlayer)
	cclog("ClientFrameSink:onUserEnterTable")
	local pMyself = GameLibSink:getMyInfo()
	
	--获取不到自己的信息直接忽略数据
	if not pMyself or pMyself:getUserChair() < 0 or pMyself:getUserChair() >= 5 then
		return
	end
	if GameLibSink.sDeskLayer == nil then
		local DeskScene = require("bull/desk/DeskScene")
		local pScene = DeskScene.createDeskScene()
		CCDirector:sharedDirector():replaceScene(pScene)
	end
	cclog("ClientFrameSink:onUserEnterTable %d %s",wUserID,isPlayer and "player" or "not player")
	
	if GameLibSink.sDeskLayer then
		GameLibSink.sDeskLayer:onUserEnterTable(chair,wUserID,isPlayer)
	end
	
	
    if (pMyself and wUserID == pMyself:getUserID()) and isPlayer then
    	--玩家本人已经坐下
        cclog("ClientFrameSink:onUserEnterTable")
        require("Lobby/FriendGame/FriendGameLogic").enterGameRoomSuccess()
    end
end

function ClientFrameSink:onUserExitTable(chair,wUserID,isPlayer)
--[[	if not GameLibSink.game_lib:isServicing() then
		return
	end]]
	cclog("ClientFrameSink:onUserExitTable userID = %d %s",wUserID,isPlayer and "isPlayer" or "not player")
	if GameLibSink.sDeskLayer then
		GameLibSink.sDeskLayer:onUserExitTable(chair,wUserID,isPlayer)
--[[	else
		local function callback()
			self:onUserExitTable(chair,wUserID,isPlayer)
		end
		delayAction(callback,ClientFrameSink.N_DELAYTIME)]]
	end
end

function ClientFrameSink:onDispatch(reserved1,reserved2,resvered3)
	cclog("ClientFrameSink:onDispatch")
end

-- 金币超过房间上限
function ClientFrameSink:onNotEnoughGold(nMinGold,nMaxGold)
	cclog("ClientFrameSink:onNotEnoughGold")
end

-- wUserID，对象
function ClientFrameSink:OnKickFailed(wUserID)
	cclog("ClientFrameSink:OnKickFailed")
    local pUserInfo = GameLibSink.game_lib:getUser(wUserID)
	if (pUserInfo == nil) then
		return
	end
	--Resources.ShowToast(string.format("踢出%s失败!", pUserInfo.getUserName()))
end

-- wKickUserID，被谁踢,wBeKickUserID 谁被踢
function ClientFrameSink:OnBeKicked(wKickUserID,wBeKickUserID)
	cclog("ClientFrameSink:OnBeKicked")  
end

-- 收到声音广播
function ClientFrameSink:onTableSound(nChair,pBuf,nLen)
	cclog("ClientFrameSink:onTableSound  ")
end

return ClientFrameSink