--VerticalShare.lua
local AppConfig = require("AppConfig")
local CommonInfo = require("gdmj/GameDefs").CommonInfo
local VerticalShare=class("VerticalShare",function()
    local sp = loadSprite("gdmj/images/shareBk.jpg",true)
	--sp:setScale(1.25)
   -- sp:setRotation(-90)
	return sp
end)
function VerticalShare:init()
	self.itemList = {}
	self.bkSize = self:getContentSize()
	--加载标题
	local titleSp = loadSprite("share/shareTitle.png")
	self:addChild(titleSp)
	titleSp:setPosition(ccp(self.bkSize.width/2,self.bkSize.height - 110))
	-- 提示文字
	local labItem = CCLabelTTF:create("游戏内容仅做娱乐用途，禁止用于赌博行为！", AppConfig.COLOR.FONT_ARIAL, 20)        
    labItem:setPosition(ccp(self.bkSize.width/2,self.bkSize.height - 10))
	--labItem:setColor(ccc3(0,0,0))
    self:addChild(labItem) 

	--游戏结束时间
    local tipmsg = CCLabelTTF:create(""..require("HallUtils").getTime(), AppConfig.COLOR.FONT_ARIAL, 20)      
    tipmsg:setPosition(ccp(self.bkSize.width - 65, self.bkSize.height - 190))
    tipmsg:setAnchorPoint(ccp(1, 0.5))
    self:addChild(tipmsg) 
end
function VerticalShare:createInfoItem(info, index) -- 创建每个玩家的头像
    local item = loadSprite("share/shareKuang.png", true)
    local bgsz = CCSizeMake(183, 276)
    item:setPreferredSize(bgsz)   

    self:addPlayerInfo(item, bgsz, info, index)
 
    self:addPlayerScore(item, bgsz, info.Score)
	local poses = {ccp(self.bkSize.width/4,680),ccp(self.bkSize.width*0.75,680),ccp(self.bkSize.width/4,390),ccp(self.bkSize.width*0.75,390)}
	self:addChild(item)
	item:setPosition(poses[index])
    table.insert(self.itemList,item)
	
	return item
end

function VerticalShare:addPlayerScore(item, bgsz, score)
    local markSp = loadSprite("mjResult/scoreMark.png")
    markSp:setPosition(ccp(bgsz.width / 2, 60))
    item:addChild(markSp)

    local msg = ""..score
    if score > 0 then
        msg = "+"..score
    end
    local labItem = CCLabelAtlas:create(msg, CommonInfo.Mj_Path.."num_score.png",40,43,string.byte('+'))
    labItem:setAnchorPoint(ccp(0.5, 0.5))
    labItem:setPosition(ccp(bgsz.width / 2, 25))
    labItem:setScale(0.8)
    item:addChild(labItem)  
end
function VerticalShare:addPlayerInfo(item, bgsz, info, index)
    --头像
    local faceSp = require("FFSelftools/CCUserFace").create(info.UserID, CCSizeMake(110,110), info.Sex)
	faceSp:setPosition(ccp(bgsz.width/2,bgsz.height - 75))
    item:addChild(faceSp)

    --昵称、id、ip
    local msgs = {info.UserNickName, "ID:"..info.UserID, info.UserIP} 
    local poses = {ccp(36, 130), ccp(36, 110), ccp(36, 90)}   
    local labItem            
    for i,v in ipairs(msgs) do
        labItem = CCLabelTTF:create(v, AppConfig.COLOR.FONT_ARIAL, 16)
        --labItem:setColor(AppConfig.COLOR.MyInfo_Record_Label)        
        labItem:setHorizontalAlignment(kCCTextAlignmentLeft)
        labItem:setAnchorPoint(ccp(0, 0.5))
        labItem:setPosition(poses[i])
        item:addChild(labItem)

        labItem:setString(require("HallUtils").getLabText(v, labItem, 180))     
    end
    labItem:setColor(ccc3(250,55,55))

    --房主标示
    if index == 1 then
        local markSp = loadSprite("mjResult/wornMark.png")
        markSp:setPosition(ccp(bgsz.width/2, 155))
        markSp:setAnchorPoint(ccp(0.5, 0.5))
        item:addChild(markSp)
    end
    if info.UserID == require("Lobby/Login/LoginLogic").UserInfo.UserID then
    --自己标示
        local markSp =  loadSprite("mjResult/friendSelfMark.png", true)
        markSp:setPreferredSize(CCSizeMake(bgsz.width + 20, bgsz.height + 20))
		markSp:setPosition(ccp(bgsz.width/2, bgsz.height/2))
        item:addChild(markSp) 
    end    
end
function VerticalShare:addMarks(index,markIndex)
	local img = {"share/shareWin.png","share/shareShu.png"}
	local mask = loadSprite(img[markIndex])
	mask:setPosition(ccp(20,195))
	mask:setScale(0.8)
	self.itemList[index]:addChild(mask)
end
function VerticalShare:addGameRuleText()
	
	local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
	--局数
	local totalCount = FriendGameLogic.my_rule[1][2]
	local curCount = FriendGameLogic.game_used > totalCount and totalCount or FriendGameLogic.game_used
	local ttfLab = CCLabelTTF:create("局数: "..curCount.."/"..totalCount, AppConfig.COLOR.FONT_ARIAL, 20)
	ttfLab:setAnchorPoint(ccp(1, 0.5))
    ttfLab:setPosition(ccp(self.bkSize.width - 65, 225))
	ttfLab:setHorizontalAlignment(kCCTextAlignmentRight)
    self:addChild(ttfLab)
	--房间号
	local roomtext = "房间号: "..tostring(FriendGameLogic.invite_code)
	ttfLab = CCLabelTTF:create(roomtext, AppConfig.COLOR.FONT_ARIAL, 20)
	ttfLab:setAnchorPoint(ccp(0, 0.5))
    ttfLab:setPosition(ccp(65, 225))
    self:addChild(ttfLab)
   
    local function createLable(msg,pos,size)
		local lable = CCLabelTTF:create(msg, "黑体", size)
		lable:setPosition(pos)
		lable:setColor(ccc3(255,255,255))
		lable:setAnchorPoint(ccp(0,0.5))
		--lable:setHorizontalAlignment(kCCTextAlignmentCenter)
		self:addChild(lable)
		return lable
	end
    local titleMsg = {"鬼牌：","买马：","玩法："}
	local poses = { ccp(65,180),ccp(65,155),ccp(65,130)}
	for i = 1,#titleMsg do
		ttfLab =  createLable(titleMsg[i],poses[i],20)
		--ttfLab:setColor(ccc3(255,255,255))
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
	createLable(ruletext,ccp(125,poses[1].y),18)
	
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

	createLable(ruletext,ccp(125,poses[2].y),18)
	
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
	local text,count,pose = nil,0,ccp(120,130)
	
	--可吃胡
--[[	local chiHuMsg = {"鸡胡不能吃胡","任意吃胡","不能吃胡"}	
	ruleData = FriendGameLogic.getRuleValueByIndex(7)--可吃胡
	if ruleData >= 1 and ruleData <= 3 then
		text = chiHuMsg[ruleData]
		count = 1
	end]]
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
			if count ~= 0 and count % 4 == 0 then
				if text then
					 createLable(text,pose,18)
					 text = nil
					 pose.y = pose.y - 25
					 count = 0
				end
			end
		end
	end
	if text then
		createLable(text,pose,18)
		text = nil
		pose.y = pose.y - 45
	end

    return ttfLab
end
function VerticalShare.create()
    local sp = VerticalShare.new()
    sp:init()
    return sp
end

return VerticalShare