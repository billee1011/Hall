require("GameLib/gamelib/frame/FrameCmds")
require("GameLib/common/common")

local ClientFrame = {}
ClientFrame.__index = ClientFrame

function ClientFrame:new(gameRoom,gameLib)
	local self = {
		m_sink = nil,
		m_myself = nil,
		m_gameRoom = gameRoom,
		m_bDismissed = false,
		m_chairCount = 0,
		m_nSceneStatus = 0,
		m_pGameLib = gameLib,
		m_cachedCmds = {}
	}
	setmetatable(self,ClientFrame)
	self:clear()
	return self
end

function ClientFrame:clear()
	self._mySelf = nil
	self.m_bDismissed = false
	self.m_chairCount = 2
	self.m_nSceneStatus = FrameCmds.SCENE_STATUS_FREE
	self.m_cachedCmds = {}
end

function ClientFrame:setMyself(myself)
	self._mySelf = myself
end

function ClientFrame:setSink(sink)
	self.m_sink = sink
	self.m_cachedCmds = {}
end

function ClientFrame:meEnterGame(cbChairCount) 
	cclog("meEnterGame")
	self.m_chairCount = cbChairCount
	local frameVersion = 1310761
	local ba = require("ByteArray").new()
	ba:writeInt(frameVersion)
	self:sendGameCmd(FrameCmds.CLIENTSITE_FRAME_VERSION, ba:getBuf(),4)
	local version = VERSION_STRUCT:new(self.m_sink:onGetMainVersion(),self.m_sink:onGetSubVersion(),0)
	local baVersion = version:Serialize()
	self:sendGameCmd(FrameCmds.CLIENTSITE_REQUEST_VERIFY_VERSION, baVersion:getBuf(),baVersion:getLen())
	self.m_cachedCmds = {}
end

function ClientFrame:recvGameCmd(buf,nLen)
	local dataLen = nLen - 2

	if dataLen < 0 then return false end
	local data = GAME_DATA:new(buf,nLen)

	if self.m_sink ==  nil then
		local cmdBuf = CmdBuffer:new(buf,nLen)
		self.m_cachedCmds[#self.m_cachedCmds + 1] = cmdBuf
		return true
	end


	if (data.cCmdID >= FrameCmds.SERVERSITE_MSG) then
		self:recvFrameCmd(data.cChairID, data.cCmdID, data.data, nLen - 2)
		return true
	end
	self.m_sink:onGameMessage(data.cChairID, data.cCmdID, data.data, nLen - 2)
	return true
end



function ClientFrame:changePlayerStatus(chair,newStatus,oldStatus) 
	if (chair == -1) then
		for i=1,self.m_chairCount do
			local user = self.m_gameRoom:getUserByChair(i - 1)
			if user ~= nil then
				self.m_sink:onPlayerStateChanged(i - 1, oldStatus, newStatus)
			end
		end
	else 
		self.m_sink:onPlayerStateChanged(chair, oldStatus, newStatus)
	end
end

function ClientFrame:sendGameCmd(cmdID,buf,nLen) 
	self.m_gameRoom:sendOldCmd(cmdID, buf, nLen)
end

function ClientFrame:recvFrameCmd(chairID,cmdID,lpBuf,nLen) 
	if (nLen < 0) then return end
		
	--int i
	if cmdID == FrameCmds.SERVERSITE_PERSONAL_SCENE or cmdID ==  FrameCmds.SERVERSITE_SCENE then
		self.m_nSceneStatus = FrameCmds.SCENE_STATUS_PLAYING
		self.m_bDismissed = false

		-- cclog("SERVERSITE_PERSONAL_SCENE nLen = %d",nLen)
		self.m_sink:onSceneChanged(string.sub(lpBuf,5), nLen - 4)
	end

	if cmdID == FrameCmds.SERVERSITE_FIRST_SCENE then
		cclog("SERVERSITE_FIRST_SCENE nLen = %d",nLen)
		self:changePlayerStatus(-1, gamelibcommon.USER_PLAY_GAME, gamelibcommon.USER_READY_STATUS)
		self.m_nSceneStatus = FrameCmds.SCENE_STATUS_PLAYING
		self.m_bDismissed = false

		if (self._mySelf:isPlayer()) then
			self:sendGameCmd(FrameCmds.CLIENTSITE_CONFIRM_START, nil, 0)
		end

		self.m_sink:onSceneChanged(string.sub(lpBuf,5), nLen - 4)
		self.m_sink:onGameStart()
	end
	if cmdID == FrameCmds.SERVERSITE_GAME_OVER then
	
		self.m_nSceneStatus = FrameCmds.SCENE_STATUS_FREE
		--changePlayerStatus(-1, USER_FREE_STATUS, USER_PLAY_GAME)
		self.m_sink:onGameEnd(lpBuf, nLen)
	end
	if cmdID == FrameCmds.SERVERSITE_GAME_DISMISS then	
		self.m_nSceneStatus = FrameCmds.SCENE_STATUS_FREE
		self.m_bDismissed = true
		self:changePlayerStatus(-1, gamelibcommon.USER_SIT_TABLE, gamelibcommon.USER_PLAY_GAME)
		if (nLen > 0) then
			self.m_sink:onDispatch(FrameCmds.DISPID_ON_GAME_DISMISS, 0, 0)
		end		
	end
	
	--[[if cmdID == FrameCmds.SERVERSITE_GAMEOPTION then
		local ba = require("ByteArray").new()
		ba:initBuf(lpBuf)
		self.m_sink:onGameOption(ba:readUInt())
	end]]

	if cmdID == FrameCmds.SERVERSITE_SOFT_READY then
		if nLen < 4 then return end
		local ba = require("ByteArray").new()
		ba:initBuf(lpBuf)
		self:changePlayerStatus(ba:readInt(), gamelibcommon.USER_READY_STATUS, gamelibcommon.USER_SIT_TABLE)
	end

	if cmdID == FrameCmds.SERVERSITE_MASTER_KICK then
		if nLen < 3 then return end
		local ba = require("ByteArray").new()
		ba:initBuf(lpBuf)

		local cbType = ba:readUByte()
		local wUserID = ba:readUShort()
		if(cbType == 0) then
			self.m_sink:OnKickFailed(wUserID)
		else
			local wBeKickUserID = 0xFFFF
			if nLen >= 5 then wBeKickUserID = ba:readUShort() end
			self.m_sink:OnBeKicked(wUserID,wBeKickUserID)
		end		
	end

	if cmdID ==  FrameCmds.SERVERSITE_FUNCTIONAL_MSGBOX then
		local nMinGold = self.m_pGameLib:getCurrentRoomMinGold()
		local nMaxGold = self.m_pGameLib:getCurrentRoomMaxGold()

		if self.m_gameRoom:isPrivteRoom() then
			local ba = require("ByteArray").new()
			ba:initBuf(lpBuf)
			--[[Functional_MsgBox msgData
			memcpy(&msgData,lpBuf,MIN(nLen,sizeof(Functional_MsgBox)))
			sscanf(msgData.szContent,"%d,%d",&nMinGold,&nMaxGold)]]
			if(nMaxGold == 0) then
				nMaxGold = 2000000000
			end
		end
		self.m_sink:onNotEnoughGold(nMinGold,nMaxGold)
	end
	if cmdID == FrameCmds.SERVERSITE_SOUND then
		self.m_sink:onTableSound(chairID,lpBuf,nLen)
	end
	if cmdID == FrameCmds.SERVERSITE_SYSTEMMESSAGE then		
		local ba = require("ByteArray").new()
		ba:initBuf(lpBuf)
		local systemMsg = ba:readStringSubZero(nLen)
		self.m_sink:onGameSystemMsg(getUtf8(systemMsg))
	end
end

return ClientFrame