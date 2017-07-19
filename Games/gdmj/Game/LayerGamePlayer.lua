--LayerGamePlayer.lua
local CommonInfo = require("gdmj/GameDefs").CommonInfo
local AppConfig = require("AppConfig")
local SetLogic = require("Lobby/Set/SetLogic")

local LayerGamePlayer=class("LayerGamePlayer",function()
        return CCLayer:create()
    end)

LayerGamePlayer.music_path = CommonInfo.Music_Path
function LayerGamePlayer.updataMusicPath()
    if SetLogic.getGameCheckByIndex(3) ~= 1 then
        LayerGamePlayer.music_path = CommonInfo.Music_Path
    else
        LayerGamePlayer.music_path = CommonInfo.Putonghua_Path
    end
end

function LayerGamePlayer:init()
    self.gold_table = {}
    self.logo_table = {}
    self.voice_table = {"woman/", "woman/", "woman/", "woman/"}

    self.piao_tag = 1
    self.banker_tag = 2
    self.offline_tag = 3
    self.golgtip_tag = 4
	self.jianren_tag = 5
    math.randomseed(os.time())

    LayerGamePlayer.updataMusicPath()
end

function LayerGamePlayer:playVoiceEffect(index, chatid)
	
	local lan_set = AppConfig.language[SetLogic.getGameCheckByIndex(3)]
	local source = string.format("resources/music/quickchat/%s/%sword%d.mp3", lan_set, self.voice_table[index + 1], chatid)
    SetLogic.playGameEffect(source)
end

function LayerGamePlayer:playCardVoice(index, card)
    local source = LayerGamePlayer.music_path..self.voice_table[index + 1]..string.format("card%x", card)..AppConfig.SoundFileExtName
    SetLogic.playGameEffect(source)
end

function LayerGamePlayer:playOperatorVoice(index, cmd, ctype)
    ctype = ctype or math.random(2)
    local source = LayerGamePlayer.music_path..self.voice_table[index + 1]..string.format("operate%x", cmd).."_"..ctype..AppConfig.SoundFileExtName
    SetLogic.playGameEffect(source)
end

function LayerGamePlayer:addUserLogo(userInfo)
    local index = userInfo._chairID
    local chair = require("gdmj/GamePlayLogic"):getInstance():getRelativeChair(index)
    self:addCommonPlayer(userInfo, index, chair, userInfo._score)
end

function LayerGamePlayer:addPlayerLogo(userInfo)
    local index = userInfo._chairID
    local chair = require("gdmj/Game/GameLogic"):getInstance():getRelativeChair(index)
    self:addCommonPlayer(userInfo, index, chair, userInfo._score)
end

function LayerGamePlayer:addCommonPlayer(userInfo, index, chair, socre)
    local poses = {ccp(45, 120), ccp(CommonInfo.View_Width - 45, CommonInfo.View_Height / 2 + 40),
                    ccp(CommonInfo.View_Width / 2 + 305, CommonInfo.View_Height - 68), ccp(45, CommonInfo.View_Height / 2 + 40)}
    
    if not self.gold_table[index + 1] then
        local faceSp = require("FFSelftools/CCUserFace").create(userInfo._userDBID, CCSizeMake(66,66), userInfo._sex)
        local logoBg, goldTTf = self:createPlayerLogo(faceSp, poses[chair], socre, userInfo) 

        self.logo_table[index + 1] = logoBg
        self.gold_table[index + 1] = goldTTf  

        self.voice_table[index + 1] = "man/"
        if userInfo._sex ~= 1 then
            self.voice_table[index + 1] = "woman/"
        end 

        --self:updataPlayerPiao({index, 1})
        --self:updataPlayerOffLine(index, true)
    else
        self:updataPlayerGold(index, socre)     
    end
end

function LayerGamePlayer:clearAllPlayer()
    for i=1,require("gdmj/Game/GameLogic"):getInstance().cbPlayerNum do
        if self.logo_table[i] then
            self.logo_table[i]:removeFromParentAndCleanup(true)
            self.gold_table[i] = nil
            self.logo_table[i] = nil
        end

        self.banker_mark = nil
    end
end

function LayerGamePlayer:clearPlayerByInfo(index)
    if not self.logo_table[index + 1] then
        return
    end

    local banker = self.logo_table[index + 1]:getChildByTag(self.banker_tag)
    if banker then
        banker:removeFromParentAndCleanup(true)
        self.banker_mark = nil
    end
    self.logo_table[index + 1]:removeFromParentAndCleanup(true)
    self.gold_table[index + 1] = nil
    self.logo_table[index + 1] = nil
end

function LayerGamePlayer:updataPlayerGold(chair, gold)
    if self.gold_table[chair + 1] then
        self.gold_table[chair + 1]:setString(require("HallUtils").formatGold(gold))
    end
end

function LayerGamePlayer:removeMark(index, tag)
    local mark = self.logo_table[index]:getChildByTag(tag)
    if mark then
        mark:removeFromParentAndCleanup(true)
    end
end

function LayerGamePlayer:removeTagMarks(tag)
    for i=1,require("gdmj/Game/GameLogic"):getInstance().cbPlayerNum do
        local mark = self.logo_table[i]:getChildByTag(tag)
        if mark then
            mark:removeFromParentAndCleanup(true)
        end
    end    
end

function LayerGamePlayer:clearAllMark()
    for i=1,require("gdmj/Game/GameLogic"):getInstance().cbPlayerNum do
        if self.logo_table[i] then
            self:removeMark(i, self.piao_tag)

            self:removeMark(i, self.golgtip_tag)
            
			self:removeMark(i, self.jianren_tag)
			
            self.logo_table[i].animate:setVisible(false)

            --self:updataPlayerPiao({i - 1, 3})
        end
    end  

    if self.banker_mark then
        self.banker_mark:removeFromParentAndCleanup(true)
        self.banker_mark = nil
    end
end

function LayerGamePlayer:updataPlayerBanker(chair)
    if self.logo_table[chair + 1] then
        self.banker_mark = loadSprite("mjdesk/bankerMark.png")
        self.logo_table[chair + 1]:addChild(self.banker_mark, 20, self.banker_tag)
        self.banker_mark:setPosition(ccp(10, self.logo_sz.height-10))   
    end
end

function LayerGamePlayer:updataPlayerPiao(values)
    local chair, score = values[1], values[2]
    if not self.logo_table[chair + 1] then
        return
    end

    local piao = self.logo_table[chair + 1]:getChildByTag(self.piao_tag)
    if piao then
        piao:removeFromParentAndCleanup(true)
    end

    local mark = loadSprite("mjdesk/tipMark.png")
    self.logo_table[chair + 1]:addChild(mark, 0, self.piao_tag)
    mark:setAnchorPoint(ccp(1, 0))
    mark:setPosition(ccp(78, 35)) 
    local sz = mark:getContentSize()

    local piaoLab = CCLabelTTF:create("飘"..score.."分", AppConfig.COLOR.FONT_ARIAL, 18)
    mark:addChild(piaoLab)
    piaoLab:setPosition(ccp(sz.width / 2 + 2, sz.height / 2))

end
function LayerGamePlayer:updataPlayerJianRen(chair)
    if not self.logo_table[chair + 1] then
        return
    end

    local jianRen = self.logo_table[chair + 1]:getChildByTag(self.jianren_tag)
    if jianRen then
        jianRen:removeFromParentAndCleanup(true)
    end

    local mark = loadSprite("mjdesk/tipMark.png")
    self.logo_table[chair + 1]:addChild(mark, 0, self.jianren_tag)
    mark:setAnchorPoint(ccp(1, 0))
    mark:setPosition(ccp(78, 35)) 
    local sz = mark:getContentSize()

    local jianRenLab = CCLabelTTF:create("煎牌", AppConfig.COLOR.FONT_ARIAL, 18)
    mark:addChild(jianRenLab)
    jianRenLab:setPosition(ccp(sz.width / 2 + 2, sz.height / 2))
end
function LayerGamePlayer:clearGoldResult()
end

function LayerGamePlayer:addGoldResult(scores)
    for i,v in ipairs(scores) do        
        if not self.logo_table[i] then
            return
        end

        local labItem = self.logo_table[i]:getChildByTag(self.golgtip_tag)
        if labItem then
            labItem:removeFromParentAndCleanup(true)
        end

        if v >= 0 then
            labItem = CCLabelAtlas:create(string.format("/%d", v),
                            CommonInfo.Mj_Path.."num_addgold.png",74, 96,string.byte('/'))
        elseif v < 0 then
            labItem = CCLabelAtlas:create(string.format("/%d", -v),
                            CommonInfo.Mj_Path.."num_reducegold.png",74, 96,string.byte('/'))
        end

        local pos = ccp(0, 0)
        labItem:setAnchorPoint(ccp(0, 0.5))
        local index = require(CommonInfo.Logic_Path):getInstance():getRelativeChair(i - 1)
        if index == 2 then
            pos = ccp(30, 0)
            labItem:setAnchorPoint(ccp(1, 0.5))
        end
        labItem:setPosition(pos)
        labItem:setVisible(false)
        self.logo_table[i]:addChild(labItem, 50, self.golgtip_tag)

        local array = CCArray:create()
        array:addObject(CCShow:create())
        array:addObject(CCFadeTo:create(0, 0))
        array:addObject(CCFadeTo:create(0.3, 255))
        array:addObject(CCMoveBy:create(0.5, ccp(0, 80)))
        labItem:runAction(CCSequence:create(array))
    end
end

--玩家离线
function LayerGamePlayer:updataPlayerOffLine(chair, boff)
    local mark = self.logo_table[chair + 1]:getChildByTag(self.offline_tag)
    if boff then
        --离线
        if not mark then
            mask = loadSprite("mjdesk/logoBg.png")
            mask:setPosition(ccp(self.logo_sz.width / 2, self.logo_sz.height / 2))
            self.logo_table[chair + 1]:addChild(mask, 30, self.offline_tag)  

            local offSp = loadSprite("mjdesk/offLine.png")
            offSp:setPosition(ccp(self.logo_sz.width / 2, self.logo_sz.height / 2 + 15))
            mask:addChild(offSp)
        end 
    else
        if mark then
            mark:removeFromParentAndCleanup(true)             
        end           
    end      
end

function LayerGamePlayer:updataPlayerOperator(chair, able)
    for i=1,require("gdmj/Game/GameLogic"):getInstance().cbPlayerNum do
        if self.logo_table[i] then
            self.logo_table[i].animate:setVisible(false)
        end
    end

    if self.logo_table[chair + 1] then
        self.logo_table[chair + 1].animate:setVisible(able)
    end       
end

function LayerGamePlayer:createPlayerLogo(facesp, pos, bean, userInfo) 
    --头像背景
    local logoBg = nil
    logoBg = createButtonWithOneStatusFrameName("mjdesk/logoBg.png", 0, function()
            if not logoBg.addInfo then
                require("Lobby/Login/LoginLogic").getUserInfo(userInfo._userDBID, function(userinfo)
                    logoBg.addInfo = userinfo
                    self:getParent():showPlayerDetail(facesp, userInfo._name, 
                                userInfo._userDBID, userInfo._userIP, logoBg.addInfo)
                end)
            else
                self:getParent():showPlayerDetail(facesp, userInfo._name, 
                            userInfo._userDBID, userInfo._userIP, logoBg.addInfo)      
            end
        end)
    putControltools(self, logoBg, pos, self.layer_zIndex)
    self.logo_sz = logoBg:getContentSize()

    --头像动画框
    local animateSp = loadSprite("mjAnima/img_logo_bg_flik1.png")
    local animFrames = CCArray:create()
    for i = 1, 2 do
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(string.format("mjAnima/img_logo_bg_flik%d.png", i))
        animFrames:addObject(frame)
    end
    local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.25)
    local animate = CCAnimate:create(animation);
    animateSp:runAction(CCRepeatForever:create(animate))
    animateSp:setPosition(ccp(self.logo_sz.width / 2, self.logo_sz.height / 2))
    animateSp:setVisible(false)
    logoBg:addChild(animateSp, 10)
    logoBg.animate = animateSp


    --logo
    facesp:setPosition(ccp(self.logo_sz.width / 2, 72))
    logoBg:addChild(facesp, 0, 0)

    local labItem = CCLabelTTF:create("", AppConfig.COLOR.FONT_ARIAL, 16)
    local poses = {ccp(self.logo_sz.width / 2, 28), ccp(self.logo_sz.width / 2, 10)}
    local msgs = {require("HallUtils").getLabText(userInfo._name, labItem, self.logo_sz.width),
                    require("HallUtils").formatGold(bean)}
    for i,v in ipairs(poses) do
        labItem = CCLabelTTF:create(msgs[i], AppConfig.COLOR.FONT_ARIAL, 16)
        labItem:setAnchorPoint(ccp(0.5, 0.5))
        labItem:setPosition(v)
        labItem:setHorizontalAlignment(kCCTextAlignmentCenter)
        logoBg:addChild(labItem)
    end

    if AppConfig.ISAPPLE then
        logoBg:setTouchEnabled(false)
    end 

    logoBg.userInfo = userInfo

    return logoBg, labItem
end

function LayerGamePlayer.create()
    local layer = LayerGamePlayer.new()
    layer:init()
    return layer
end

function LayerGamePlayer.put(super, zindex)
    local layer = LayerGamePlayer.new()
    layer.layer_zIndex = zindex
    super:addChild(layer, zindex)
    layer:init()
    return layer
end

 return LayerGamePlayer