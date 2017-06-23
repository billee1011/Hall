require("CocosExtern")
local GameDefs = require("bull/GameDefs")
local Player =require("bull/desk/Player")
local CCUserFace = require("FFSelftools/CCUserFace")
local Resources=require("bull/Resources")

local GamePlayLogic=class("DeskScene",function()
               return CCLayer:create()
            end)

function GamePlayLogic:initUI(gameAction)
	self:LoadCache()
	
	local strBgImg="bull/images/bg.png"
    self.m_backgroundSp = loadSprite(strBgImg)
	self.m_backgroundSp:setScale(1.25)
    self.m_backgroundSp:setAnchorPoint(ccp(0,0))
    self.m_backgroundSp:setPosition(0,0)
    self:addChild(self.m_backgroundSp)
    
	-- 返回大厅按钮
	local winSize =CCDirector:sharedDirector():getWinSize()
    self.backHomeBtn = require("FFSelftools/CCButton").createWithFrame("bull/goback.png",false,function()
		require("LobbyControl").hall_layer = self.hall_layer
		require("LobbyControl").hall_layer:setVisible(true)
		self:setVisible(false)
		self:removeFromParentAndCleanup(true)
	end)
    self.backHomeBtn:setPosition(ccp(winSize.width - 50,40))
    self:addChild(self.backHomeBtn)
	self.backHomeBtn:resetTouchPriorty(kCCMenuHandlerPriority - 1001, true)
	
	local ruleText = gameAction["roomInfo"]["Cnt"].."人,"
	if gameAction["roomInfo"]["GameType"] ~= nil then --新数据格式
		local gameType = {"看牌抢庄","世界大战","牛牛坐庄","轮流坐庄","牌大坐庄","自由抢庄","房主霸王庄"}
		ruleText = ruleText..gameType[gameAction["roomInfo"]["GameType"]]
	else
		if gameAction["roomInfo"]["Banker"] == 0 then
			ruleText = ruleText.."看牌抢庄"
		elseif gameAction["roomInfo"]["Banker"] == 1 then
			ruleText = ruleText.."世界大战"
		else 
			ruleText = ruleText.."牛牛坐庄"
		end
	end

	self.m_roomRule=CCLabelTTF:create(ruleText, Resources.FONT_BLACK, Resources.FONT_SIZE24)
    self.m_roomRule:setPosition(ccp(winSize.width*0.5,winSize.height*0.5))
    self.m_roomRule:setColor(ccc3(255, 255, 255))
    self:addChild(self.m_roomRule)
    self.m_roomRule:setVisible(true)
	
    self:initPlayers(gameAction)
	
	local function onNodeEvent(event)
       if event == "enter" then	

       elseif event =="exit" then
			cclog("LayerMoreBtn exit")
			self:removeCache()
			GamePlayLogic.gamePlayInstance = nil
       end 
    end
	local function onTouch(eventType, x, y)
		return false
    end
	self:registerScriptHandler(onNodeEvent)
    self:registerScriptTouchHandler(onTouch,false, kCCMenuHandlerPriority- 1000,true)
end
function GamePlayLogic:initPlayers(gameAction)
	local playerCount = gameAction["roomInfo"]["Cnt"]
	self.m_aclsPlayer = {}
    for i =1, playerCount do
		local userInfo = gameAction["userInfo"..i] --具体的用户数据
		local player = Player.createPlayer(i,self,true)
        self.m_aclsPlayer[i] = player
        player:setAnchorPoint(ccp(0,0))
        player:setPosition(ccp(0,0))
        player:setVisible(true)	
		self:addChild(self.m_aclsPlayer[i],2)
		
		--头像移动
		player.m_headImgSp:runAction(CCMoveTo:create(0.2, player.m_headMovePos))
		player:setUsername(userInfo["Name"])
		self:createPlayFace(userInfo["DBID"],userInfo["Sex"],player.m_headImgSp)
		
		if gameAction["roomInfo"]["GameType"] ~= nil then --新数据格式
			if gameAction["roomInfo"]["GameType"] ~= 2 then
			    player:setMaster(userInfo["Banker"] == 1)
				player:setBeiShu(userInfo["BeiShu"])
			end
		else --兼容旧的数据格式
			if(gameAction["roomInfo"]["Banker"] ~= 1) then --有庄
				player:setMaster(userInfo["Banker"] == 1)
				player:setBeiShu(userInfo["BeiShu"])
			end	
		end
			
		player:RefreshGold(userInfo["TScore"])


		player.m_headImgSp:setVisible(true)
		
		
		--牌
		local vMJGroupCard = {}
		for nIndex = 1,5 do
			vMJGroupCard[nIndex] = { m_byCardPoint = userInfo["Card"][nIndex][1],m_byCardStyle = userInfo["Card"][nIndex][2],m_byIsSelect = 0}
		end
	--[[	vMJGroupCard[1] = { m_byCardPoint = 10,m_byCardStyle = 1,m_byIsSelect = 0}
		vMJGroupCard[2] = { m_byCardPoint = 10,m_byCardStyle = 1,m_byIsSelect = 0}
		vMJGroupCard[3] = { m_byCardPoint = 10,m_byCardStyle = 1,m_byIsSelect = 0}
		vMJGroupCard[4] = { m_byCardPoint = 10,m_byCardStyle = 1,m_byIsSelect = 0}
		vMJGroupCard[5] = { m_byCardPoint = 10,m_byCardStyle = 1,m_byIsSelect = 0}]]
		player:getPlayerCardLayer():setGroupCards(vMJGroupCard)
		
		
    end
	local nNiuType = 9
	local array = CCArray:create()
    array:addObject(CCDelayTime:create(1))
    array:addObject(CCCallFunc:create(function()
		for nPos =1, playerCount do
			local userInfo = gameAction["userInfo"..nPos] --具体的用户数据
			self.m_aclsPlayer[nPos]:setNiuType(userInfo["NiuType"])
			self:PlayNiuTypeAnm(nPos,userInfo["NiuType"])
			self:ShowScore(userInfo["CScore"],nPos)
		end
    end))
    self:runAction(CCSequence:create(array))  
end
--创建用户头像
function GamePlayLogic:createPlayFace(userDBID,sex,headImgSp) 
	local faceSprite = CCUserFace.create(userDBID,CCSizeMake(90,90),sex)
	faceSprite = Resources.drawNodeRoundRect(faceSprite, CCRectMake(0,0,90,90), 0, 10, ccc4f(1,0,0,1), ccc4f(1,0,0,1))
 
    faceSprite:setAnchorPoint(ccp(0.5,0))
    faceSprite:setPosition(ccp(headImgSp:getContentSize().width/2,62+90))
    headImgSp:addChild(faceSprite)
end
function GamePlayLogic:PlayNiuTypeAnm(nPos,nNiuType)--播放牛型动画
		if nNiuType == GameDefs.emBullType.BULL_TYPE_INVALID then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_MeiNiu)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_NULL then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_MeiNiu)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_1 then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_Niu1)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_2 then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_Niu2)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_3 then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_Niu3)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_4 then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_Niu4)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_5 then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_Niu5)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_6 then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_Niu6)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_7 then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_Niu7)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_8 then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_Niu8)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_9 then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_Niu9)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_10 then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_NiuNiu)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_BOMB then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_SiZha)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_5_JQK then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_WuHuaNiu)
        elseif nNiuType == GameDefs.emBullType.BULL_TYPE_5_MIN then
            self.m_aclsPlayer[nPos]:setState(Player.STATE.State_WuXiaoNiu)
        end
end
function GamePlayLogic:ShowScore(nScore, nPos)
    local winsize = CCDirector:sharedDirector():getWinSize()
    local function moveFinshCallBack()
        
    end
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
    local labelScore = CCLabelBMFont:create(strScore, szFontFile)
    local fScale = 1.0
    labelScore:setScale(fScale)
	if nPos == 1 then 
		labelScore:setAnchorPoint(ccp(0.5,0.5))
	elseif nPos == 4 or nPos == 5 then
		labelScore:setAnchorPoint(ccp(0,0.5))
	else 
		labelScore:setAnchorPoint(ccp(1,0.5))
	end
    if nPos == 1 then
		labelScore:setPosition(ccp(640,270))
    elseif nPos == 5 then
        labelScore:setPosition(ccp(365,325))
    elseif nPos == 4 then
        labelScore:setPosition(ccp(470,520))
    elseif nPos == 2 then
        labelScore:setPosition(ccp(910,325))
    elseif nPos == 3 then
        labelScore:setPosition(ccp(800,520))
    end
    self:addChild(labelScore,3)

    local array = CCArray:create()
    array:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(0.3), CCMoveBy:create(0.3, ccp(0, 50))))
    labelScore:runAction(CCSequence:create(array))
end
function GamePlayLogic:LoadCache()
	Cache.add({"bull/images/bull"})
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("bull/images/card.plist")
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("bull/images/armature/tesupaixing/tesupaixing.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("bull/images/armature/win/SLTX_shuchu.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("bull/images/armature/touXiang/touxianTX.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("bull/images/armature/touxiangkuang/touxiangkuang.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("bull/images/armature/result/shegnlishibai.ExportJson")
end
function GamePlayLogic:removeCache()
	Cache.removePlist({"emote","bull/images/bull"})
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("bull/images/card.plist")
    CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("bull/images/armature/tesupaixing/tesupaixing.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("bull/images/armature/win/SLTX_shuchu.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("bull/images/armature/touXiang/touxianTX.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("bull/images/armature/touxiangkuang/touxiangkuang.ExportJson")
    CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("bull/images/armature/result/shegnlishibai.ExportJson")
end
--切换到当前层
function GamePlayLogic:replaceMainScence(gameData)
	self:initUI(gameData["Action"])
	local scene = CCDirector:sharedDirector():getRunningScene()
	scene:addChild(self,1)
	
	require("LobbyControl").hall_layer:setVisible(false)
    self.hall_layer = require("LobbyControl").hall_layer
    require("LobbyControl").hall_layer = nil
end
function  GamePlayLogic:getInstance()
	if GamePlayLogic.gamePlayInstance == nil then
		GamePlayLogic.gamePlayInstance = GamePlayLogic.new()
	end
	return GamePlayLogic.gamePlayInstance
end
	
return GamePlayLogic