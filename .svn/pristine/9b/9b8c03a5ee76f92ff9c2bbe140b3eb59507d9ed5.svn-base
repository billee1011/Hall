require("CocosExtern")

local AnimationBaseLayer = require("FFSelftools/AnimationBaseLayer")
local Resources = require("bull/Resources")
local GameCfg = require("bull/desk/public/GameCfg")
local GameDefs = require("bull/GameDefs")
local CCButton = require("FFSelftools/CCButton")
local GameLibSink = require("bull/GameLibSink")
local GameOverDialog = class("GameOverDialog", function()
	return AnimationBaseLayer.create(ccc4(0,0,0,100))
end)

function GameOverDialog:init()  
 --[[   if not self:getIsPrivateRoom()then
        local function onLeveGame(tag,target)
			local GameLibSink = require("bull/GameLibSink")
			GameLibSink.returnToLobby()
        end
        local pBtnExit =  CCButton.createWithFrame("bull/btn_exit.png",false,onLeveGame)
        pBtnExit:setPosition(ccp(340 + pBtnExit:getContentSize().width / 2, 50 + pBtnExit:getContentSize().height / 2))
        self:addChild(pBtnExit)
    end]]

    local function onBtnReadyClickCallback(tag, target)
		if self.parent ~= nil and self.parent.totalScoreInfo ~= nil then
			self.parent:showTotalSettle(true,self.parent.totalScoreInfo)
		else
			require("bull/SendCMD").sendCMD_PO_RESTART()
		end
		
        --self:showDlg(false)
		
    end
	local pBtnReady = CCButton.createWithFrame("bull/btn_continue.png",false,onBtnReadyClickCallback)
  --  if self:getIsPrivateRoom()then
        pBtnReady:setPosition(ccp(520 + pBtnReady:getContentSize().width / 2, 50 + pBtnReady:getContentSize().height / 2))
 --   else
 --       pBtnReady:setPosition(ccp(680 + pBtnReady:getContentSize().width / 2, 50 + pBtnReady:getContentSize().height / 2))
  --  end
    self:addChild(pBtnReady)
	pBtnReady:resetTouchPriorty(kCCMenuHandlerPriority - 1,true)
	
	self.lableList = {}
	local function onNodeEvent(event)
        if event == "enter" then	
 
        elseif event =="exit" then
			self:showDlg(false)
			cclog("LayerMoreBtn exit")
        end 
    end
	local function onTouch(eventType ,x ,y)
        if eventType=="began" then
            return true
        elseif eventType=="moved" then
        elseif eventType=="ended" then
        end
    end
	self:registerScriptHandler(onNodeEvent)
    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,true)
	self:showDlg(false)
end

function GameOverDialog:getIsPrivateRoom()
    local gamelib = require("bull/GameLibSink").game_lib
    return gamelib:isInPrivateRoom()
end
function GameOverDialog:setPlayerData(stGameEnd, aclsPlayer,nMaxPlayer)
	tablePrint(stGameEnd)
	for i=0,GameDefs.PLAYER_COUNT-1 do
        local nPos = self:PosFromChair(i)
        if aclsPlayer[nPos]:IsValid() then
            self:setWaveScore(stGameEnd.nScore[i+1], nPos,nMaxPlayer)
        end
    end
end
function GameOverDialog:showDlg(isShow)
	self:setVisible(isShow)
	self:setTouchEnabled(isShow)
	if not isShow then
		for i = 1,GameDefs.PLAYER_COUNT do
			self:hideScore(i)
		end
	end
end
function GameOverDialog:hideScore(nPos)
	if(self.lableList[nPos] ~= nil) then
		self.lableList[nPos]:setVisible(false)
	end
end

function GameOverDialog:setWaveScore(nScore, nPos,nMaxPlayer)
    local winsize = CCDirector:sharedDirector():getWinSize()
    local function moveFinshCallBack()
        
    end
	cclog("nScore:"..nScore)
    local szFontFile = ""
    if (nScore > 0) then
        szFontFile = "bull/images/number/jiafen.fnt"
    else
        szFontFile = "bull/images/number/koufen.fnt"
    end
    local strScore = tostring(nScore)
    if (nScore > 0) then
        strScore = "+" .. strScore
    end
	if(self.lableList[nPos] ~= nil) then
		self.lableList[nPos]:removeFromParentAndCleanup(true)
		self.lableList[nPos] = nil
	end
	self.lableList[nPos] = CCLabelBMFont:create(strScore, szFontFile)
	self.parent:addChild(self.lableList[nPos],3)
	if nPos == 1 then 
		self.lableList[nPos]:setAnchorPoint(ccp(0.5,0.5))
	elseif nPos == 2 then
		self.lableList[nPos]:setAnchorPoint(ccp(1,0.5))
	elseif nPos == 3 then
		self.lableList[nPos]:setAnchorPoint(ccp(nMaxPlayer == 3 and 0 or 1,0.5))
	elseif nPos == 4 then
		self.lableList[nPos]:setAnchorPoint(ccp(nMaxPlayer == 3 and 1 or 0,0.5))
	elseif nPos == 5 then
		self.lableList[nPos]:setAnchorPoint(ccp(0,0.5))
	end
	local  basePos = GameLibSink.sDeskLayer.m_aclsPlayer[1].allPlayerPos
	self.lableList[nPos]:setPosition(basePos[nPos][7])
--[[	if self:IsMe(nPos) then
		self.lableList[nPos]:setPosition(ccp(640,270))
	elseif self:IsLeftOne(nPos) then
		self.lableList[nPos]:setPosition(ccp(365,325))
	elseif self:IsLeftTwo(nPos) then
		self.lableList[nPos]:setPosition(ccp(470,520))
	elseif self:IsRightOne(nPos) then
		self.lableList[nPos]:setPosition(ccp(910,325))
	elseif self:IsRightTwo(nPos) then
		self.lableList[nPos]:setPosition(ccp(800,520))
	end]]
	self.lableList[nPos]:setVisible(true)
	
    local array = CCArray:create()
    array:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(0.3), CCMoveBy:create(0.3, ccp(0, 50))))
    --array:addObject(CCDelayTime:create(1))
    --array:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.2, ccp(0, 50)), CCFadeOut:create(0.2)))
    --array:addObject(CCCallFunc:create(moveFinshCallBack))
    self.lableList[nPos]:runAction(CCSequence:create(array))
end

function GameOverDialog:IsMe(nPos)
    return nPos==1
end

function GameOverDialog:IsRightOne(nPos)
    return  nPos==2
end

function GameOverDialog:IsRightTwo(nPos)
    return  nPos==3
end

function GameOverDialog:IsLeftOne(nPos)
    return  nPos==5
end

function GameOverDialog:IsLeftTwo(nPos)
    return  nPos==4
end

function GameOverDialog:PosFromChair(cbChair)
   -- local gamelib = require("bull/GameLibSink").game_lib
    --return gamelib:getRelativePos(cbChair) + 1
	return self.parent:PosFromChair(cbChair)
end

function GameOverDialog:ChairFromPos(nPos)
 --   local gamelib = require("bull/GameLibSink").game_lib
 --   return gamelib:getRealChair(nPos)
		return self.parent:ChairFromPos(nPos)
end

function GameOverDialog.create(parent)
	local pDialog = GameOverDialog.new()
	pDialog.parent = parent
	pDialog:init()
	return pDialog
end

return GameOverDialog