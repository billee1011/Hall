--VerticalShare.lua
local AppConfig = require("AppConfig")
local CommonInfo = require("k510/Game/Common").CommonInfo
local VerticalShare=class("VerticalShare",function()
    local sp = loadSprite("k510/images/bkg_share.jpg",true)
	--sp:setScale(0.8)
   -- sp:setRotation(-90)
	return sp
end)
function VerticalShare:init()
	self.itemList = {}
	self.bkSize = self:getContentSize()
	--加载标题
	local titleSp = loadSprite("ui/title_share.png")
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
	
	local QRcode = loadSprite("ui/QRcode.png")
	QRcode:setScale(0.5)
	self:addChild(QRcode)
	QRcode:setPosition(ccp(self.bkSize.width - 120,110))
	
	local text = CCLabelTTF:create("游戏下载二维码", AppConfig.COLOR.FONT_ARIAL, 20)      
    text:setPosition(ccp(self.bkSize.width - 120, 20))
    self:addChild(text) 
end
function VerticalShare:createInfoItem(info, index, ip) -- 创建每个玩家的头像
    local item = loadSprite("ui/shareKuang.png", true)
    local bgsz = CCSizeMake(200, 290)
    item:setPreferredSize(bgsz)   

    self:addPlayerInfo(item, bgsz, info, index, ip)
 
    self:addPlayerScore(item, bgsz, info.Score)
	local poses = {ccp(self.bkSize.width/4,680),ccp(self.bkSize.width*0.75,680),ccp(self.bkSize.width/4,390)}
	self:addChild(item)
	item:setPosition(poses[index])
    table.insert(self.itemList,item)
	
	return item
end

function VerticalShare:addPlayerScore(item, bgsz, score)
    --local markSp = loadSprite("mjResult/scoreMark.png")
    --markSp:setPosition(ccp(bgsz.width / 2, 60))
    --item:addChild(markSp)

	local totalscore = CCLabelTTF:create("总积分","", 25)
    item:addChild(totalscore)
    totalscore:setPosition(ccp(bgsz.width / 2, 65))
		
    local msg = ""..score
    if score > 0 then
        msg = "+"..score
    end
    local labItem = CCLabelAtlas:create(msg, AppConfig.ImgFilePath.."num_roomrecorder.png",32,34,string.byte('+'))
    labItem:setAnchorPoint(ccp(0.5, 0.5))
    labItem:setPosition(ccp(bgsz.width / 2, 35))
	labItem:setScale(1.2)
    item:addChild(labItem)  
end
function VerticalShare:addPlayerInfo(item, bgsz, info, index, ip)
    --头像
    local faceSp = require("FFSelftools/CCUserFace").create(info.UserID, CCSizeMake(115,115), info.Sex)
	faceSp:setPosition(ccp(bgsz.width/2,bgsz.height - 75))
    item:addChild(faceSp)
	
	--[[ local sameIP = loadSprite("ui/sameIP.png")
	item:addChild(sameIP)
	sameIP:setPosition(ccp(150,90))
	sameIP:setVisible(false) ]]

    --昵称、id、ip
    local msgs = {info.UserNickName, "ID:"..info.UserID, "IP:"..ip} 
    local poses = {ccp(36, 140), ccp(36, 115), ccp(36, 90)}   
    local labItem            
    for i,v in ipairs(msgs) do
        labItem = CCLabelTTF:create(v, AppConfig.COLOR.FONT_ARIAL, 23)
        --labItem:setColor(AppConfig.COLOR.MyInfo_Record_Label)        
        labItem:setHorizontalAlignment(kCCTextAlignmentCenter)
        labItem:setAnchorPoint(ccp(0, 0.5))
        labItem:setPosition(poses[i])
        item:addChild(labItem)

        labItem:setString(require("HallUtils").getLabText(v, labItem, 180))     
    end
    labItem:setColor(ccc3(250,55,55))

    --房主标示
    if index == 1 then
        local markSp = loadSprite("ui/zhuozhusp.png")
        markSp:setPosition(ccp(1, item:getContentSize().height))
        markSp:setAnchorPoint(ccp(0, 1))
        item:addChild(markSp)
    end
    --[[ if info.UserID == require("Lobby/Login/LoginLogic").UserInfo.UserID then
    --自己标示
        local markSp =  loadSprite("mjResult/friendSelfMark.png", true)
        markSp:setPreferredSize(CCSizeMake(bgsz.width + 20, bgsz.height + 20))
		markSp:setPosition(ccp(bgsz.width/2, bgsz.height/2))
        item:addChild(markSp) 
    end   ]]  
end
function VerticalShare:addMarks(index,markIndex)
	local img = {"ui/shareWin.png","ui/shareShu.png"}
	local mask = loadSprite(img[markIndex])
	mask:setPosition(ccp(160,220))
	mask:setScale(0.8)
	self.itemList[index]:addChild(mask)
end
function VerticalShare:addGameRuleText()
	local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
	--局数
	local totalCount = FriendGameLogic.my_rule[1][2]
	local curCount = FriendGameLogic.game_used > totalCount and totalCount or FriendGameLogic.game_used
	local ttfLab = CCLabelTTF:create("局数: "..curCount.."/"..totalCount, AppConfig.COLOR.FONT_ARIAL, 25)
	ttfLab:setAnchorPoint(ccp(1, 0.5))
    ttfLab:setPosition(ccp(self.bkSize.width - 65, 225))
	ttfLab:setHorizontalAlignment(kCCTextAlignmentRight)
    self:addChild(ttfLab)
	--房间号
	local roomtext = "房间号: "..tostring(FriendGameLogic.invite_code)
	ttfLab = CCLabelTTF:create(roomtext, AppConfig.COLOR.FONT_ARIAL, 25)
	ttfLab:setAnchorPoint(ccp(0, 0.5))
    ttfLab:setPosition(ccp(60, 225))
    self:addChild(ttfLab)

	--玩法
	ttfLab = CCLabelTTF:create("玩法：", AppConfig.COLOR.FONT_ARIAL, 25,CCSizeMake(300,200),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	ttfLab:setAnchorPoint(ccp(0, 1))
    ttfLab:setPosition(ccp(60, 215))
    self:addChild(ttfLab)
	
	local currentRule = FriendGameLogic.my_rule
	 if #currentRule > 0 then
        local msg = ""
		if currentRule[2] then
			if currentRule[2][2] == 1 then
				msg = msg.."炸弹牌型:四张，"
			else 
				msg = msg.."炸弹牌型:四带一，"
			end
		end
		
        if currentRule[3] then
			if currentRule[3][2] == 1 then
				msg = msg.."连对KKAA最大，"
			else
				msg = msg.."连对AA22最大，"
			end
        end
        if currentRule[4] then
			if currentRule[4][2] == 0 then
				msg = msg.."不显示牌数，"
			else
				msg = msg.."显示牌数，"
			end
        end
        if currentRule[5] then
			if currentRule[5][2] == 0 then
				msg = msg.."不可切牌"
			else
				msg = msg.."可切牌"
			end
        end

        ttfLab:setString("玩法："..msg)
    end
	
    return ttfLab
end
function VerticalShare.create()
    local sp = VerticalShare.new()
    sp:init()
    return sp
end

return VerticalShare