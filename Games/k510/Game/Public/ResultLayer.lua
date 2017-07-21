require("CocosExtern")
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")
local Resources =require("k510/Resources")
local InviteInfo = require("k510/Game/Common").InviteInfo

local ResultLayer = class("ResultLayer",function()
    return CCLayer:create()
end)


function ResultLayer.create()
    local layer = ResultLayer.new()
    layer:init()
	return layer
end

function ResultLayer:init()
    self.winSize = CCSizeMake(require("k510/GameDefs").CommonInfo.View_Width, require("k510/GameDefs").CommonInfo.View_Height)
	
    local function onTouch(eventType ,x ,y)
        if eventType=="began" then
            self._StartPos = ccp(x,y)
            return true
        elseif eventType=="ended" then
            self:onEnded(x,y)
        end
    end

    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority ,true)
    self:setTouchEnabled(true)

    --单局结算Layer
    self.singleResultLayer = CCLayerColor:create(AppConfig.COLOR.ColorLayer_Bg)
    self:addChild(self.singleResultLayer)
	--self.singleResultLayer:setVisible(false)
	
    --背景
	local singleBg1 = loadSprite("ui/bkg_singlesettle2.png")
    singleBg1:setPosition(ccp(self.winSize.width/2,379))
    self.singleResultLayer:addChild(singleBg1)
	
    local singleBg2 = loadSprite("ui/bkg_singlesettle1.png")
    singleBg2:setPosition(ccp(406,358.6))
    self.singleResultLayer:addChild(singleBg2)

	local singleBg3 = loadSprite("ui/bkg_singlesettle1.png")
	singleBg3:setScaleX(-1)
    singleBg3:setPosition(ccp(874.5,358.3))
    self.singleResultLayer:addChild(singleBg3)
	
	--标题
	local singleTitle = loadSprite("ui/title_singlesettle.png")
    singleTitle:setPosition(ccp(singleBg1:getContentSize().width/2,375))
    singleBg1:addChild(singleTitle)
	
    --准备
    local function readyBtnCallBack()
        local GameLogic = require("k510/Game/GameLogic")
        local layer = GameLogic.StaySceneLayer
        -- 如果是终局则显示总结算
        if require("k510/Game/GameLogic").gameEnded then
            self:setEndGameInfo(layer.gameendlistinfo)
		else
			local f = require("Lobby/FriendGame/FriendGameLogic")
            if f.my_rule then
                -- 更新GameLogic
                GameLogic:refreshGameLogic()
                layer:ControlBtn(layer.menuItemShowTag.HideALL)
                GameLogic:sendStartMsg("单局结算关闭")
                self:hide()
            else
                ccerr("没有下发的规则数据")
            end
        end
    end 

    self.singleReadyBtn = CCButton.createWithFrame("ui/btn_continue.png",false,readyBtnCallBack)
    self.singleResultLayer:addChild(self.singleReadyBtn)
    self.singleReadyBtn:setPosition(ccp(self:getContentSize().width/2,80))

	self.singlePlayerInfo = {}
	local playerPos = {{ccp(425,360),ccp(640,360),ccp(855,360)},--背景板坐标
						{ccp(83,210),ccp(85,120),ccp(85,110),ccp(85,72),ccp(85,24)}}--头像，姓名，id，标识，积分坐标
    for i = 1,3 do
		local playerInfo = {}
		--player
		local playerBkg = loadSprite("ui/bkg_singleplayer.png")
		playerBkg:setPosition(playerPos[1][i])
		self.singleResultLayer:addChild(playerBkg)
		playerInfo.bg = playerBkg
		
        --姓名
        local name = CCLabelTTF:create("","",30)
        playerBkg:addChild(name)
        name:setPosition(playerPos[2][2])
        name:setColor(ccc3(235,242,226))
		playerInfo.nameLabel = name

		--胜负平标识
		local mark = loadSprite("ui/title_draw.png")
		mark:setPosition(playerPos[2][4])
		playerBkg:addChild(mark)
		playerInfo.Mark = mark
		
        --积分
        local score = CCLabelTTF:create("","",40)
        playerBkg:addChild(score)
        score:setPosition(playerPos[2][5])
        score:setColor(ccc3(235,242,226))
		playerInfo.scoreLabel = score
		
		table.insert(self.singlePlayerInfo,playerInfo)
    end

    --总结算
	self.verticalShare  = require("k510/Game/Public/VerticalShare").create() --竖屏分享
	local parent = self:getParent()
	if parent then 
		parent:addChild(self.verticalShare,1)
	else
		self:addChild(self.verticalShare,1)
	end
	self.verticalShare:setAnchorPoint(ccp(0,0))
	self.verticalShare:setPosition(ccp(0,0))
	self.verticalShare:setVisible(false)
	
    self.endResultLayer = CCLayerColor:create(AppConfig.COLOR.ColorLayer_Bg)
    self:addChild(self.endResultLayer)
	
	local endBg1 = loadSprite("ui/bkg_totalsettle2.png")
	endBg1:setScaleX(9)
    endBg1:setPosition(ccp(self.winSize.width/2,self.winSize.height/2+3))
    self.endResultLayer:addChild(endBg1)
	
	local endBg2 = loadSprite("ui/bkg_totalsettle1.png")
	endBg2:setScale(1.255)
    endBg2:setPosition(ccp(138.8,self.winSize.height/2+3.7))
    self.endResultLayer:addChild(endBg2)
	
	local endBg3 = loadSprite("ui/bkg_totalsettle1.png")
	endBg3:setScaleX(-1.255)
	endBg3:setScaleY(1.255)
    endBg3:setPosition(ccp(1141.5,self.winSize.height/2+3.3))
    self.endResultLayer:addChild(endBg3)
	
	local light = loadSprite("ui/total_light.png")
    light:setPosition(ccp(self.winSize.width/2,685))
    self.endResultLayer:addChild(light)
	
	local titlebkg = loadSprite("ui/bkg_totaltitle.png")
    titlebkg:setPosition(ccp(self.winSize.width/2,600))
    self.endResultLayer:addChild(titlebkg)
	
	--标题
	local endTitle = loadSprite("ui/title_totalsettle.png")
    endTitle:setPosition(ccp(self.winSize.width/2,605))
    self.endResultLayer:addChild(endTitle)

    self.endResultLabel = {}
	local endPos = {{ccp(305,375),ccp(640,375),ccp(975,375)},
					{ccp(108,293),ccp(108,216),ccp(108,177),ccp(108,141),ccp(108,104),ccp(108,65),ccp(108,30)}
	}
    for i = 1,3 do
        local labelInfo = {}
        local bg = loadSprite("ui/bkg_totalsettle_player.png")
        bg:setPosition(endPos[1][i])
        self.endResultLayer:addChild(bg)
		labelInfo.bg = bg

        --头像
        --local headframe = loadSprite("czpdk/userinfoframebg.png")
		--bg:addChild(headframe)
  	    --headframe:setPosition(endPos[2][1])
        --labelInfo.head = headframe

        --桌主
        local zhuozhu = loadSprite("ui/zhuozhusp.png")
  	    bg:addChild(zhuozhu,999)
  	    zhuozhu:setPosition(ccp(98, 308))
        zhuozhu:setVisible(false)
        labelInfo.zhuozhu = zhuozhu

        --姓名
        local name = CCLabelTTF:create("","",35)
        bg:addChild(name)
        name:setPosition(endPos[2][2])
        labelInfo.nameLabel = name

        --Id
        local id = CCLabelTTF:create("","",25)
        bg:addChild(id)
        id:setPosition(endPos[2][3])
        labelInfo.idLabel = id

        --IP
        local ip = CCLabelTTF:create("","",25)
        bg:addChild(ip)
        ip:setPosition(endPos[2][4])
        labelInfo.ipLabel = ip
        
        local sameIP = loadSprite("ui/sameIP.png")
        bg:addChild(sameIP)
  	    sameIP:setPosition(ccp(227,161))
        sameIP:setVisible(false)
        labelInfo.sameIP = sameIP

        --胜负局数
        local winnum = CCLabelTTF:create("","",30)
        bg:addChild(winnum)
        winnum:setPosition(endPos[2][5])
        labelInfo.winLabel = winnum

        --总积分
		local totalscore = CCLabelTTF:create("总积分","", 25)
        bg:addChild(totalscore)
        totalscore:setPosition(endPos[2][6])
		
        local totalscore = CCLabelAtlas:create("0", AppConfig.ImgFilePath.."num_roomrecorder.png",32,34,string.byte('+'))
        bg:addChild(totalscore)
		totalscore:setScale(1.2)
		totalscore:setAnchorPoint(ccp(0.5,0.5))
        totalscore:setPosition(endPos[2][7])
        labelInfo.totalscoreLabel = totalscore

        table.insert(self.endResultLabel,labelInfo)
    end

    local function shareBtnCallBack()
        self.shareBtn:setVisible(false)
        self.exitBtn:setVisible(false)
        self.recreateBtn:setVisible(false)
        --self.ruleLabel:setVisible(true)
        --shareScreenToWx(1, 75, InviteInfo.Game_Name, "好友卓总战绩", function() end)
		self.verticalShare:setVisible(true)
		shareScreenToWxEx(self.verticalShare, 1, InviteInfo.Game_Name, "好友卓总战绩", function() 
			self.verticalShare:setVisible(false)
		end )
        self.shareBtn:setVisible(true)
        self.exitBtn:setVisible(true)
        self.recreateBtn:setVisible(true)
        --self.ruleLabel:setVisible(false)
    end 

    -- 分享按钮
    self.shareBtn = CCButton.createWithFrame("ui/btn_share.png",false,shareBtnCallBack)
    self.endResultLayer:addChild(self.shareBtn)
    self.shareBtn:setPosition(ccp(self.winSize.width/2,65))

    -- 返回大厅按钮
    local function exitBtnCallBack()
        AudioEngine.stopMusic(true)
        require("LobbyControl").backToHall()
    end

    self.exitBtn = CCButton.createWithFrame("ui/btn_backhall.png",false,exitBtnCallBack)
    self.endResultLayer:addChild(self.exitBtn)
    self.exitBtn:setPosition(ccp(self.winSize.width/2-340,65))

    -- 继续创建按钮
    local function recreateBtnCallBack()
        AudioEngine.stopMusic(true)
        require("LobbyControl").backToHall(true)
    end

    self.recreateBtn = CCButton.createWithFrame("ui/btn_continue.png",false,recreateBtnCallBack)
    self.endResultLayer:addChild(self.recreateBtn)
    self.recreateBtn:setPosition(ccp(self.winSize.width/2 + 340,65))
    self.endResultLayer:setVisible(false)
    
    --赌博提示
    self.tipGambling = CCLabelTTF:create("游戏仅供娱乐，禁止赌博", "Arial", 24)     
    self.tipGambling:setAnchorPoint(ccp(0, 0.5))
    self.tipGambling:setPosition(ccp(20, self.winSize.height-100))
    self.endResultLayer:addChild(self.tipGambling)
    
    --日期提示
    self.tipDate = CCLabelTTF:create("", "Arial", 24)
	self.tipDate:setHorizontalAlignment(kCCTextAlignmentLeft)
    self.tipDate:setAnchorPoint(ccp(1, 0.5))
    self.tipDate:setPosition(ccp(self.winSize.width-40, self.winSize.height-90))
    self.endResultLayer:addChild(self.tipDate)
    
    --规则说明
    --self.ruleLabel = CCLabelTTF:create("", "Arial", 24)
	--self.ruleLabel:setHorizontalAlignment(kCCTextAlignmentRight)
    --self.ruleLabel:setAnchorPoint(ccp(1, 0.5))
    --self.ruleLabel:setPosition(ccp(self.winSize.width-40, self.winSize.height-80))
    --self.endResultLayer:addChild(self.ruleLabel)
end

function ResultLayer:onEnded(x,y)
    local enPos = ccp(x,y)
    local delta = 5.0
    if math.abs (enPos.x - self._StartPos.x) > delta or math.abs (enPos.y - self._StartPos.y) > delta then
        --not click
		self._StartPos = ccp(-1,-1)
		return
    end
end

function ResultLayer:setOneGameInfo(myDBID)
    cclog("ResultLayer:setOneGameInfo myDBID:%s", tostring(myDBID))
    local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
    local GameLogic = require("k510/Game/GameLogic")
    local layer = GameLogic.StaySceneLayer
    -- 如果有单局结算数据则显示单局结算
    if GameLogic.m_SetScores then
		local userList = GameLogic.userlist
		local c = CCSpriteFrameCache:sharedSpriteFrameCache()
        -- 刷新所有玩家数据
        for k, v in ipairs(GameLogic.m_SetScores) do
            self.singlePlayerInfo[k].nameLabel:setString(getUtf8(v.szUserName))
            self.singlePlayerInfo[k].scoreLabel:setString(string.format("%d",v.nSetScore))
			if v.nSetScore > 0 then
					self.singlePlayerInfo[k].bg:setDisplayFrame(c:spriteFrameByName("ui/bkg_singleplayer_win.png"))
                    self.singlePlayerInfo[k].Mark:setDisplayFrame(c:spriteFrameByName("ui/title_win.png"))
				-- 失败
				elseif v.nSetScore < 0 then
					self.singlePlayerInfo[k].bg:setDisplayFrame(c:spriteFrameByName("ui/bkg_singleplayer_lose.png"))
					self.singlePlayerInfo[k].Mark:setDisplayFrame(c:spriteFrameByName("ui/title_lose.png"))
                else
					self.singlePlayerInfo[k].bg:setDisplayFrame(c:spriteFrameByName("ui/bkg_singleplayer.png"))
					self.singlePlayerInfo[k].Mark:setDisplayFrame(c:spriteFrameByName("ui/title_draw.png"))
            end 
			
			local headSp
			local faceSize = CCSizeMake(105,105)
			headSp = require("FFSelftools/CCUserFace").create(v.nUserDBID, faceSize, v.cbSex)
			if headSp == nil then
				headSp = require("FFSelftools/CCUserFace").createDefault(_,faceSize)
			end
			headSp:setPosition(ccp(83,210))
			self.singlePlayerInfo[k].bg:addChild(headSp)
        end
	
        self:show()
    elseif GameLogic.gameEnded then
        self:setEndGameInfo(layer.gameendlistinfo)
    else
        ccerr("没有结算数据 gameEnded: %s", tostring(GameLogic.gameEnded))
    end
end

function ResultLayer:setEndGameInfo(args)
    local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")
    local InviteInfo = require("k510/Game/Common").InviteInfo
    local GameLogic = require("k510/Game/GameLogic")
    local now = os.date("*t")
    
	self.verticalShare:addGameRuleText() --添加竖屏分享规则
    -- 同IP检测
    local allIPRecorder, sameIPRecorder = {}, {}
    local userList = GameLogic.userlist
    for i, j in pairs(userList) do
        allIPRecorder[j._userDBID] = j._userIP
        for k, v in pairs(userList) do
            if k ~= i and v._userIP == j._userIP and (not sameIPRecorder[v._userDBID]) then
                sameIPRecorder[v._userDBID] = v._userIP
            end
        end
    end
    
	local maxScore = 0
	local minScore = 0
    for i = 1,3 do
        local userinfo = userList[i]
        local id = args[i].UserID
        if id == GameLogic.openTableUserid then
            self.endResultLabel[i].zhuozhu:setVisible(true)
        else
            self.endResultLabel[i].zhuozhu:setVisible(false)
        end

        self.endResultLabel[i].nameLabel:setString(args[i].UserNickName)
        self.endResultLabel[i].idLabel:setString(string.format("ID:%d",id))
        
        if sameIPRecorder[id] then
            self.endResultLabel[i].ipLabel:setString(string.format("IP:%s", sameIPRecorder[id]))
            self.endResultLabel[i].sameIP:setVisible(true)
        else
            self.endResultLabel[i].ipLabel:setString(string.format("IP:%s", allIPRecorder[id]))
            self.endResultLabel[i].sameIP:setVisible(false)
        end
 
        local headSp
        local faceSize = CCSizeMake(110,110)
        if userinfo then
            headSp = require("FFSelftools/CCUserFace").create(id, faceSize, userinfo:getSex())
        else
            headSp = require("FFSelftools/CCUserFace").createDefault(_,faceSize)
        end
		headSp:setPosition(ccp(108,293))
        self.endResultLabel[i].bg:addChild(headSp)
         
        -- 其它数据
        local endResultInfo = require("cjson").decode(args[i].RuleScoreInfo)
        if not endResultInfo then
            AudioEngine.stopMusic(true)
            require("LobbyControl").backToHall()
            return
        end
        self.endResultLabel[i].totalscoreLabel:setString(string.format("%d",endResultInfo.TS))
		if endResultInfo.TS > maxScore then
			maxScore = endResultInfo.TS
		elseif endResultInfo.TS < minScore then
			minScore = endResultInfo.TS
		end
        self.endResultLabel[i].winLabel:setString(string.format("%d胜%d平%d负",endResultInfo.WN,endResultInfo.DN,endResultInfo.LN))
    
		if sameIPRecorder[id] then
			self.verticalShare:createInfoItem(args[i], i, sameIPRecorder[id])
		else
			self.verticalShare:createInfoItem(args[i], i, allIPRecorder[id])
		end
	end
	
	for i = 1,3 do
		local endResultInfo = require("cjson").decode(args[i].RuleScoreInfo)
		if maxScore > 0 and endResultInfo.TS == maxScore then
			local bigwinner = loadSprite("ui/bigwinner.png")
			self.endResultLabel[i].bg:addChild(bigwinner)
			bigwinner:setPosition(ccp(115,-26))
			self.verticalShare:addMarks(i,1)
		elseif minScore < 0 and endResultInfo.TS == minScore then
			self.verticalShare:addMarks(i,2)
		end
	end
	
    -- 更新日期、房间号、规则等标签
    local msg = require("k510/LayerDeskRule").getRuleMsg()
    self.tipDate:setString(string.format("%d-%02d-%02d %02d:%02d",now.year,now.month,now.day,now.hour,now.min))
    --self.ruleLabel:setString(msg)
    --cclog(msg)
    
    self.singleResultLayer:setVisible(false)
    self.endResultLayer:setVisible(true)
    self:show()
end

function ResultLayer:show()
	self:setVisible(true)
    self:setTouchEnabled(true)
	self.singleReadyBtn:setTouchEnabled(true)
    self.shareBtn:setTouchEnabled(true)
    self.exitBtn:setTouchEnabled(true)
    self.recreateBtn:setTouchEnabled(true)
end

function ResultLayer:hide()
	self:setVisible(false)
	self.singleReadyBtn:setTouchEnabled(false)
    self.shareBtn:setTouchEnabled(false)
    self.exitBtn:setTouchEnabled(false)
    self.recreateBtn:setTouchEnabled(false)
    self:setTouchEnabled(false)
end

return ResultLayer