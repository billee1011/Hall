--LayerGameOption.lua
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")
local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")

local LayerGameOption =class("LayerGameOption",function()
    return CCLayerColor:create(AppConfig.COLOR.ColorLayer_Bg)
end)
function LayerGameOption:init()
	local bk = loadSprite("gdmj/GameOption_bk.png", true)
	bk:setPreferredSize(CCSizeMake(775,475))
	bk:setPosition(ccp(640,360))
	self:addChild(bk)
	
	local bk1 = loadSprite("gdmj/GameOption_bk1.png", true)
	bk1:setPreferredSize(CCSizeMake(726,407))
	bk1:setPosition(ccp(640,360))
	self:addChild(bk1)
	
	local bk2 = loadSprite("gdmj/GameOption_bk2.png")
	bk2:setPosition(ccp(600,120))
	bk1:addChild(bk2)
	
	local title = loadSprite("gdmj/GameOption_title.png")
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
	local poses = { ccp(13,380),ccp(13,310),ccp(13,240)}
	for i = 1,#titleMsg do
		createLable(bk1,titleMsg[i],poses[i])
		if i ~= #titleMsg then
			createLable(bk1,"......................................................",ccp(13,poses[i].y - 25))
		end
	end
	local tipText = {
	 {"无鬼","白板做鬼","翻鬼","无鬼翻倍"},
	 {"无马","买2马","买4马","买6马","买8马","买10马"},
	}
	--鬼牌
	local ruleData = FriendGameLogic.getRuleValueByIndex(4)
	local magicCardIndex = Bit:_and(ruleData,0x000000FF)
	local notMagicDouble = Bit:_and(ruleData,0x0000FF00)
	
	local ruletext = tipText[1][magicCardIndex]		--鬼牌
	if notMagicDouble == 0x200 then --无鬼翻倍
		ruletext = ruletext.."、无鬼翻倍"
	end
	createLable(bk1,ruletext,ccp(125,poses[1].y))
	
	--马牌数量
	ruleData = FriendGameLogic.getRuleValueByIndex(5)
	ruletext = tipText[2][ruleData]
	
	--马分
	if  ruleData > 1 then --马牌数量 > 1
		ruleData = FriendGameLogic.getRuleValueByIndex(6)
		if ruleData == 1 then 
			ruletext = ruletext.."、马跟底分"
		end
	end

	createLable(bk1,ruletext,ccp(125,poses[2].y))
	
	--具体玩法
	local options = require("gdmj/LayerDeskRule").options
	local gameOption = FriendGameLogic.getRuleValueByIndex(8)--游戏选项
	
	local gameType,optionName = {},{}
	if FriendGameLogic.getRuleValueByIndex(3) == 2 then
		gameType = {"跟庄","抢杠马*2","抢杠胡全包","12张落地全包","杠爆全包","杠开翻倍","节节高","无字牌",
					"碰碰胡2倍","混一色2倍","七小对3倍","清一色5倍","豪华七小对6倍","混幺九7倍","清幺九9倍",
					 "字一色9倍","大三元10倍","大四喜10倍","十三幺13倍","天地胡13倍"}
		optionName = {"GZ","QGMFB","QGHQB","DDQB","GBQB","GKFB","JJG","WZP",
						"DDH","HYS","QXD","QYS","SQXD","HYJ","QYJ",
						"ZYS","DSY","DSX","SSY","TDH",
						}
	else
		gameType = {"跟庄","抢杠马*2","抢杠胡全包","12张落地全包","杠爆全包","杠开翻倍","节节高","无字牌"
					 ,"","七小对2倍","豪华七小对4倍"}
		optionName = {"GZ","QGMFB","QGHQB","DDQB","GBQB","GKFB","JJG","WZP","","QXD","SQXD"}
	end
	local text,count,pose = nil,0,ccp(125,poses[3].y)
	
	--可吃胡
--[[	local chiHuMsg = {"鸡胡不能吃胡","任意吃胡","不能吃胡"}	
	ruleData = FriendGameLogic.getRuleValueByIndex(7)--可吃胡
	if ruleData >= 1 and ruleData <= 3 then
		text = chiHuMsg[ruleData]
		count = 1
	end]]
	
	for i = 0,#gameType - 1 do
		if gameType[i+1] ~= "" then
			local valid = Bit:_and(gameOption,options[optionName[i+1]])
			if valid ~= 0 then

				count = count + 1
				if count == 1 then
					text = gameType[i+1]
				else
					text = text.."、"..gameType[i+1]
				end
			end
			if count ~= 0 and count % 4 == 0 then
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