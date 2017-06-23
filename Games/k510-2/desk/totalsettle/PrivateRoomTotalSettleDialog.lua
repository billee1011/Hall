require("CocosExtern")
local AppConfig = require("AppConfig")

local AnimationBaseLayer = require("FFSelftools/AnimationBaseLayer")
local Resources = require("bull/Resources")
local CCButton = require("FFSelftools/CCButton")
local PrivateRoomTotalSettleCellItem = require("bull/desk/totalsettle/PrivateRoomTotalSettleCellItem")

local PrivateRoomTotalSettleDialog = class("PrivateRoomTotalSettleDialog", function()
	--return AnimationBaseLayer.create(ccc4(0,0,0,220))
	--return CCLayerColor:create(AppConfig.COLOR.ColorLayer_Bg)
	return CCLayerColor:create(ccc4(0, 0, 0, 190))
end)

function PrivateRoomTotalSettleDialog:onTouchBegan(x,y)   
	cclog("onTouchBegan")
	return true
end

function PrivateRoomTotalSettleDialog:onTouchEnd(x,y)
end

function PrivateRoomTotalSettleDialog:onTouchMoved(x,y)
end

function PrivateRoomTotalSettleDialog:onTouch(eventType, x, y)
    if eventType == "began" then   
        return self:onTouchBegan(x, y)
    elseif eventType == "moved" then
        self:onTouchMoved(x, y)
    else
        self:onTouchEnd(x, y)
    end
end

function PrivateRoomTotalSettleDialog:add(vSettleInfo)
    local nMaxScore = 0
    local vMaxScoreIndexs = {}
    for i = 1, #vSettleInfo do
        if (vSettleInfo[i].Score >= nMaxScore) then
            if (vSettleInfo[i].Score == nMaxScore) then
                if (vSettleInfo[i].Score ~= 0) then
                    table.insert(vMaxScoreIndexs, i)
                end
            else
                if (vSettleInfo[i].Score ~= 0) then
                    vMaxScoreIndexs = {}
                    table.insert(vMaxScoreIndexs, i)
                end
            end
            nMaxScore = vSettleInfo[i].Score
        end
    end

    for i = 1, #vMaxScoreIndexs do
        vSettleInfo[vMaxScoreIndexs[i]].bIsMaxWinner = true
    end

    return vSettleInfo
end
--[[
nPlayerNum 房间人数
roomOwerID 房主id
roomID		房间号
myChairID	我的椅子号
curSet		当前局数
totalSet	总局数
vSettleInfo 总结算信息
]]
function PrivateRoomTotalSettleDialog:init(nPlayerNum, roomOwerID,roomID,myChairID, curSet,totalSet,vSettleInfo)
	local function onTouch(eventType, x, y)
        if eventType == "began" then
			cclog("onTouch eventType == began")
            return true
        end
    end
    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority - self.zIndex,true)
    self:setTouchEnabled(true)

	vSettleInfo = self:add(vSettleInfo) 

    local winsize = CCDirector:sharedDirector():getWinSize()
    
    self.m_pBG = loadSprite("bull/jiesuanbg.png",true)
    self.m_pBG:setPosition(ccp(winsize.width / 2, winsize.height / 2 + 10))
	self.m_pBG:setPreferredSize(CCSizeMake(1275,517))
    self:addChild(self.m_pBG)
	self.m_pBG:setContentSize(CCSizeMake(1275,517))
    local contentSize = self.m_pBG:getContentSize()

    local pFly = loadSprite("bull/fly.png")
	pFly:setAnchorPoint(ccp(0.5,0))
    pFly:setPosition(ccp(637,472))
    self.m_pBG:addChild(pFly)
    pFly:setZOrder(1)


    local ccLabelColor1 = ccc3(255,255,255)

	local tipInfo = {}
	local tipPos = {ccp(1260,680),ccp(1260,655),ccp(1260,630)}
	
    tipInfo[1] = Resources.getNowTime(0)
	tipInfo[2] = string.format("房号:%d(%d/%d)",roomID,curSet,totalSet)
	tipInfo[3] = (require("bull/LayerDeskRule").getRuleText())
	--szTime = ruleText.."  "..szTime 
	for k,v in pairs(tipInfo) do
		local lab = CCLabelTTF:create(tipInfo[k], Resources.FONT_BLACK, 24)
		lab:setColor(ccLabelColor1)
		lab:setHorizontalAlignment(kCCTextAlignmentRight)
		lab:setAnchorPoint(ccp(1, 0))
		lab:setPosition(tipPos[k])
		self:addChild(lab)
	end
	
    local function onBtnExitClickCallback(tag, target)
        Resources.playGlobeEffect(require("bull/SoundRes").SOUND_PASS)
        --self:hide(self.m_pBG, self.m_onBtnExitClickCallback)
		local GameLibSink = require("bull/GameLibSink")
		GameLibSink.returnToLobby()
    end
    self.pBtnExit = CCButton.createWithFrame("bull/btn_exit.png",false,onBtnExitClickCallback)
	self.pBtnExit:resetTouchPriorty(kCCMenuHandlerPriority - self.zIndex - 1, true)
    self:addChild(self.pBtnExit)

    local function onBtnShareClickCallback(tag, target)
        Resources.playGlobeEffect(require("bull/SoundRes").SOUND_PASS)
        cclog("onShareCallBack")
		self.btnShare:setVisible(false)
		self.pBtnExit:setVisible(false)
		self.pBtnCreate:setVisible(false)
		self.myItem.mark:stopAllActions()
		self.myItem.mark:setOpacity(255)
		shareScreenToWx(1, 75, "斗牛", "好友卓总战绩", function() end)--CJni:shareJni():shareScreenShot
        self.btnShare:setVisible(true)
		self.pBtnExit:setVisible(true)
		self.pBtnCreate:setVisible(true)
		require("Lobby/Common/AnimationUtil").runFlickerAction(self.myItem.mark, true)
    end
    self.btnShare = CCButton.createWithFrame("bull/btn_share.png",false,onBtnShareClickCallback)
	self.btnShare:resetTouchPriorty(kCCMenuHandlerPriority - self.zIndex - 1, true)
    self:addChild(self.btnShare)

	local function onBtnCreateClickCallback(tag, target)	
        Resources.playGlobeEffect(require("bull/SoundRes").SOUND_PASS)
		AudioEngine.stopMusic(true)
        require("LobbyControl").backToHall(true)
    end
    self.pBtnCreate = CCButton.createWithFrame("bull/btn_continue.png",false,onBtnCreateClickCallback)
	self.pBtnCreate:resetTouchPriorty(kCCMenuHandlerPriority - self.zIndex - 1, true)
    self:addChild(self.pBtnCreate)
	
    local y = contentSize.height * 0.12
    local x = 210
	if( not require("AppConfig").ISAPPLE) then
		self.pBtnExit:setPosition(ccp(x + self.pBtnExit:getContentSize().width / 2, y))
		x = x + self.pBtnExit:getContentSize().width + 40	
		self.btnShare:setPosition(ccp(x + self.btnShare:getContentSize().width / 2, y))	
		x = x + self.btnShare:getContentSize().width + 40
		self.pBtnCreate:setPosition(ccp(x + self.pBtnExit:getContentSize().width / 2, y))
	else
		x = 360
		self.pBtnExit:setPosition(ccp(x + self.pBtnExit:getContentSize().width / 2, y))
		x = x + self.pBtnExit:getContentSize().width + 40
		self.pBtnCreate:setPosition(ccp(x + self.pBtnExit:getContentSize().width / 2, y))		
		self.btnShare:setVisible(false)
	end
 
	local x = 0
    local y = 30
    for i = 1, nPlayerNum do
        local pItem = PrivateRoomTotalSettleCellItem.create(vSettleInfo[i],roomOwerID,myChairID == i - 1)
        if (x == 0) then
            x = (contentSize.width - pItem:getContentSize().width * nPlayerNum - (nPlayerNum-1) * 5) / 2
        end
        pItem:setPosition(ccp(x + pItem:getContentSize().width / 2 + 5, y + pItem:getContentSize().height / 2))
        self.m_pBG:addChild(pItem)
        x = x + pItem:getContentSize().width + 5
		
		if myChairID == i - 1 then
			self.myItem = pItem
		end
    end

	--self:show(self.m_pBG, nil, 0.01)

    local pLabelWarn = CCLabelTTF:create(string.format("游戏仅供娱乐\r\n禁止赌博行为"), Resources.FONT_BLACK, 22)
    pLabelWarn:setColor(ccLabelColor1)
    pLabelWarn:setHorizontalAlignment(kCCTextAlignmentLeft)
    pLabelWarn:setAnchorPoint(ccp(0, 0))
    pLabelWarn:setPosition(ccp(20, 630))
    self:addChild(pLabelWarn)
end

function PrivateRoomTotalSettleDialog.create(nPlayerNum, roomOwerID,roomID, myChairID,curSet,totalSet,vSettleInfo,zIndex)
	local pDialog = PrivateRoomTotalSettleDialog.new()
	pDialog.zIndex = zIndex
	pDialog:init(nPlayerNum, roomOwerID,roomID,myChairID, curSet,totalSet,vSettleInfo)
	return pDialog
end

return PrivateRoomTotalSettleDialog