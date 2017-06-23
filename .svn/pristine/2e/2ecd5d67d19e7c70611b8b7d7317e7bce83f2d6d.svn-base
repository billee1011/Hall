--LayerGameOption.lua
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")
local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")

local LayerGameOption =class("LayerGameOption",function()
    return CCLayerColor:create(AppConfig.COLOR.ColorLayer_Bg)
end)
function LayerGameOption:init()
	local bk = loadSprite("sgmj/GameOption_bk.png", true)
	bk:setPreferredSize(CCSizeMake(775,475))
	bk:setPosition(ccp(640,360))
	self:addChild(bk)
	
	local bk1 = loadSprite("sgmj/GameOption_bk1.png", true)
	bk1:setPreferredSize(CCSizeMake(726,407))
	bk1:setPosition(ccp(640,360))
	self:addChild(bk1)
	
	local bk2 = loadSprite("sgmj/GameOption_bk2.png")
	bk2:setPosition(ccp(600,120))
	bk1:addChild(bk2)
	
	local title = loadSprite("sgmj/GameOption_title.png")
	title:setPosition(ccp(640,627))
	self:addChild(title)
	
	local function createLable(super,msg,pos)
		local lable = CCLabelTTF:create(msg, "黑体", 25)
		lable:setPosition(pos)
		lable:setColor(AppConfig.COLOR.MyInfo_Record_Label)
		lable:setAnchorPoint(ccp(0,0.5))
		--lable:setHorizontalAlignment(kCCTextAlignmentCenter)
		super:addChild(lable)
		return lable
	end
	local titleMsg = {"鬼牌：","买马：","玩法："}
	local poses = { ccp(13,380),ccp(13,290),ccp(13,200)}
	for i = 1,#titleMsg do
		createLable(bk1,titleMsg[i],poses[i])
		if i ~= #titleMsg then
			createLable(bk1,"......................................................",ccp(13,430 - i*90))
		end
	end
	local tipText = {
	 {"鸡胡","做牌"},
	 {"无鬼","白板做鬼","翻鬼","无鬼翻倍"},
	 {"无马","买2马","买4马","买6马","买8马","买10马"},
	 {"马跟底分","马跟到底","马跟2倍","马跟4倍","马跟8倍","马跟16倍"}
	}
	--鬼牌
	local ruleData = FriendGameLogic.getRuleValueByIndex(4)
	local magicCardIndex = Bit:_and(ruleData,0x000000FF)
	local notMagicDouble = Bit:_and(ruleData,0x0000FF00)
	
	local ruletext = tipText[2][magicCardIndex]		--鬼牌
	if notMagicDouble == 0x200 then --无鬼翻倍
		ruletext = ruletext.."、无鬼翻倍"
	end
	createLable(bk1,ruletext,ccp(125,380))
	
	--马牌数量
	ruleData = FriendGameLogic.getRuleValueByIndex(5)
	ruletext = tipText[3][ruleData]
	
	--马分
	if FriendGameLogic.getRuleValueByIndex(3) == 2 and 
		FriendGameLogic.getRuleValueByIndex(5) > 1 then --
		ruleData = FriendGameLogic.getRuleValueByIndex(6)
		if ruleData > 1 then 
			ruletext = ruletext.."、"..tipText[4][ruleData]
		end
			--马跟杠
		if FriendGameLogic.getRuleValueByIndex(7) == 1 then
			ruletext = ruletext.."、马跟杠"
		end
	end

	createLable(bk1,ruletext,ccp(125,290))
	
	--具体玩法
	local options = require("sgmj/LayerDeskRule").options
	local gameOption = FriendGameLogic.getRuleValueByIndex(9)--游戏选项
	local gameType = {}
	if Bit:_and(gameOption,options["FB"]) ~= 0 then
		gameType = {"","跟庄","抢杠马*2",
					"对对胡4倍","混一色4倍","混对8倍",
					"清一色8倍","七小对8倍","清对16倍",
					"幺九16倍","全风32倍","带19万(十三幺、全幺32倍)","牌型分翻倍"
					}
	else
		gameType = {"","跟庄","抢杠马*2",
					"对对胡2倍","混一色2倍","混对4倍",
					"清一色4倍","七小对4倍","清对8倍",
					"幺九8倍","全风16倍","带19万(十三幺、全幺16倍)","牌型分翻倍"
					}
	end
	local optionName = {"","GZ","QGMFB","DDH","HYS","HD","QYS","QXD","QD","YJ","QF","D19","FB"}
	local text,count,pose = nil,0,ccp(125,200)
	
		--可吃胡
	local chiHuMsg = {"可吃胡","可吃胡幺九","可吃胡全风","可吃胡全幺","可吃胡十三幺","不可吃胡"}
	
	if FriendGameLogic.getRuleValueByIndex(3) == 2 then
		ruleData = FriendGameLogic.getRuleValueByIndex(8)--可吃胡
		if ruleData >= 1 and ruleData <= 6 then
		  text = chiHuMsg[ruleData]
		  count = 1
		end
	end
	for i = 0,#gameType - 1 do
		if gameType[i+1] ~= "" then
			if Bit:_and(gameOption,options[optionName[i+1]]) ~= 0 then

				count = count + 1
				if count == 1 then
					text = gameType[i+1]
				else
					text = text.."、"..gameType[i+1]
				end
			end
			if (i + 1)% 3 == 0 then
				if text then
					 createLable(bk1,text,pose)
					 text = nil
					 pose.y = pose.y - 45
					 count = 0
				end
			end
		end
	end
	if text then
		createLable(bk1,text,pose)
		text = nil
		pose.y = pose.y - 45
	end
	
	
	    --关闭按钮 
    CCButton.put(self, CCButton.createCCButtonByFrameName("common/btnClose.png", 
            "common/btnClose2.png", "common/btnClose.png", function()
             self:setTouchEnabled(false)
			 self:removeFromParentAndCleanup(true)
            end), ccp(1007,570), self.layer_zIndex + 1)
	local function onTouch(eventType, x, y)
		cclog("eventType")
        if eventType == "began" then
		--	self:setTouchEnabled(false)
		--	self:removeFromParentAndCleanup(true)
            return true
        end
    end
    self:registerScriptTouchHandler(onTouch,false, kCCMenuHandlerPriority - self.layer_zIndex,true)
	self:setTouchEnabled(true)
end
function LayerGameOption.create(super,zIndex)
	local layer = LayerGameOption.new()
    layer.layer_zIndex = zIndex
    super:addChild(layer, zIndex)
    layer:init()
    return layer
end
return LayerGameOption