--LayerRoom.lua
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")
local FriendGameLogic = require("Lobby/FriendGame/FriendGameLogic")

local LayerRoom=class("LayerRoom",function()
        return CCLayerColor:create(ccc4(0, 0, 0, 0))
    end)

function LayerRoom:hide(func) 
    self:setVisible(false)
    self:setTouchEnabled(false)
    func()
    return self
end

function LayerRoom:show()
    self:setVisible(true)
    self:setTouchEnabled(true)

    return self    
end

function LayerRoom:init()
    self.btn_zIndex = self.layer_zIndex + 1

    self:initGameEnter()

    self:initGameRank()
end

--游戏入口
function LayerRoom:initGameEnter()
    local super, tempBtn = self:getParent()
    self.roomBtns = {}

    local midx, midy = AppConfig.SCREEN.CONFIG_WIDTH / 2, AppConfig.SCREEN.CONFIG_HEIGHT / 2
     local poses = {ccp(midx + 80, midy + 140),ccp(midx + 405, midy + 140),
                    ccp(midx + 80, midy - 60),ccp(midx + 405, midy - 60)}
    local maingame = FriendGameLogic.games_config.games[1]
    for i,v in ipairs(FriendGameLogic.games_config.games) do
        local imgfile = "lobby/gameIcon"..v..".png"
		if v == 24 then
			imgfile = "lobby/gameIcon"..(v-1)..".png"
		end
        if v == FriendGameLogic.games_config.unopened then
            tempBtn = putControltools(self, 
                createButtonWithSprite(loadSprite(imgfile), loadSprite(imgfile, true), 0, function()
                   require("HallUtils").showWebTip("即将开放，敬请期待")     
                end), poses[i], self.btn_zIndex)  
		    local markSp = loadSprite("lobby/unopened .png")
			if markSp then
				tempBtn:addChild(markSp)
				markSp:setPosition(ccp(115,115))
			end				
        else
            tempBtn = putControltools(self, 
                createButtonWithSprite(loadSprite(imgfile), loadSprite(imgfile, true), 0, function()
                   super:getParent():showCreateRoomPanel(v)     
                end), poses[i], self.btn_zIndex)            
        end

        table.insert(self.roomBtns, tempBtn)
    end

    --光效
    local function addFlik(item)
        local effect = loadSprite("lobby/1.png")
        effect:setScale(2)
        effect:setPosition(ccp(132, 40))
        item:addChild(effect)
        local animFrames = CCArray:create()
        for i = 1, 48, 1 do
            local j = i < 9 and i or 1
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(string.format("lobby/%d.png", j))
            animFrames:addObject(frame)
        end
        local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.1)
        local animate = CCAnimate:create(animation)
        effect:runAction(CCRepeatForever:create(animate)) 
    end

    --练习场     
  --[[  local btn = putControltools(self, 
        createButtonWithSprite(loadSprite("lobby/gamePractice.png"), loadSprite("lobby/gamePractice.png", true), 0, function()
           super:getParent():showNormalGame()     
        end), ccp(midx + 110, 155), self.btn_zIndex)
    addFlik(btn)
    table.insert(self.roomBtns, btn)]]

    --加入游戏     
    btn = putControltools(self, 
        createButtonWithSprite(loadSprite("lobby/gameEnter.png"), loadSprite("lobby/gameEnter.png", true), 0, function()
           super:getParent():showEnterGame()   
        end), ccp(midx + 250, 155), self.btn_zIndex)   
    addFlik(btn)
    table.insert(self.roomBtns, btn)

    --[[for i=1,3 do
        local pos = ccp(AppConfig.SCREEN.CONFIG_WIDTH - 300, AppConfig.SCREEN.CONFIG_HEIGHT - 60 - 155 * i)
        local imgfile = string.format("lobby/gametype%d_img.png", i)
        if i == 2 then imgfile = "lobby/gametype4_img.png" end --普通场替换为练习场

        local item = putControltools(self, 
            createButtonWithSprite(loadSprite(imgfile), loadSprite(imgfile, true), 0, function()
            funcs[i]()
        end), pos, self.btn_zIndex)  

        table.insert(self.roomBtns, item)      
        
        -- 好友场按钮光效
        if i <= 2 then
            local effect = loadSprite("lobby/b5.png")
            effect:setScale(2)
            effect:setPosition(ccp(203, 66))
            item:addChild(effect)
            local animFrames = CCArray:create()
            for i = 0, 48, 1 do
                local j = i < 9 and i or 0
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(string.format("lobby/b%d.png", j))
                animFrames:addObject(frame)
            end
            local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.1)
            local animate = CCAnimate:create(animation);
            effect:runAction(CCRepeatForever:create(animate))    
        end
    end 

    function addMark(btn)
        local mark = loadSprite("lobby/gametip_img.png")
        mark:setPosition(ccp(365, 84))
        btn:addChild(mark)
    end
    
    --addMark(self.roomBtns[2])
    addMark(self.roomBtns[3])]]
end

function LayerRoom:initGameRank()
    --添加背景
    self.rank_bg = loadSprite("lobby/rankbg_img.png")
    self.rank_bg:setPosition(ccp(285, AppConfig.SCREEN.CONFIG_HEIGHT - 370))
    self:addChild(self.rank_bg)    
    local bgsz, index = self.rank_bg:getContentSize(), 1

    --提示信息
    local rankTip = CCLabelTTF:create("数据为截至昨天，每天24点更新", AppConfig.COLOR.FONT_BLACK, 21)      
    rankTip:setPosition(ccp(26, 26))
    rankTip:setColor(ccc3(0x83, 0x37, 0x15))
    rankTip:setAnchorPoint(ccp(0, 0.5))
    self.rank_bg:addChild(rankTip, 2)

    --添加标题切换按钮
    --[[
    local clickTable = {}
    local poses = {ccp(bgsz.width / 2 - 94, bgsz.height - 45), ccp(bgsz.width / 2 + 94, bgsz.height - 45)}
    for i,v in ipairs(poses) do
        local btn = CCButton.put(self.rank_bg, CCButton.createCCButtonByFrameName("lobby/rankb_type"..i.."_1.png", 
        "lobby/rankb_type"..i.."_2.png", "lobby/rankb_type"..i.."_2.png", function(tag, target)
            for j,w in ipairs(clickTable) do
                w:setEnabled(true)
                w:getChildByTag(10):setVisible(false)
            end

            target:setEnabled(false)
            target:getChildByTag(10):setVisible(true)
            self:showGameRank(i)
        end), v, self.btn_zIndex)

        local btnSp =  loadSprite("lobby/rankbtn_bg.png")
        btn:addChild(btnSp, -2, 10)
        btnSp:setVisible(false)
        table.insert(clickTable, btn)
    end 
    clickTable[index]:setEnabled(false)
    clickTable[index]:getChildByTag(10):setVisible(true)   
    ]]

    self.rank_lists = {} 
    self:showGameRank(index)
end

function LayerRoom:showGameRank(index)
    for i=1,2 do
        if self.rank_lists[i] then
            self.rank_lists[i]:setVisible(false)
            self.rank_lists[i]:setTouchEnabled(false)
        end
    end

    if not self.rank_lists[index] then
        require("Lobby/LobbyLogic").getRankList(index, function(data)
            if require("LobbyControl").hall_layer and not self.rank_lists[index] then
                self.rank_lists[index] =  require("Lobby/Common/LobbyTableView").createCommonTable(
                    CCSizeMake(386, 332), ccp(20, 44), kCCMenuHandlerPriority - self.btn_zIndex)
                    :setCellSizeFunc(function(t, idx) return 95, 332 end)
                    :setNumberOfCellsFunc(function() return #data end)
                    :setCreateCellFunc((function(idx) 
                        local info = require("Lobby/Login/LoginLogic").UserInfo 
                        local item, bgsz = self:createCellItem(idx, data[idx + 1].NickName, data[idx + 1].UserID, data[idx + 1].Sex, data[idx + 1].FaceID) 
                        self:addRankInfo(item, bgsz, data[idx + 1].NickName, ""..data[idx + 1].RankValue)
                        return item
                    end))
                self.rank_bg:addChild(self.rank_lists[index]) 
                self.rank_lists[index]:updataTableView()                
            end
        end)
    else
        self.rank_lists[index]:setVisible(true)
        self.rank_lists[index]:setTouchEnabled(true)
    end
end

--创建item
function LayerRoom:createCellItem(idx, name, userid, sex, faceid)
    --头像
    local faceSp = require("FFSelftools/CCUserFace").create(userid, CCSizeMake(75,75), sex)

    local item = CCButton.createCCButtonByFrameName("lobby/rankbg1_img.png","lobby/rankbg2_img.png", 
        "lobby/rankbg1_img.png", function()
            self:getParent():getParent():showRankPlayerInfo(faceSp, name, userid)
        end)
    local bgsz = item.m_normalSp:getContentSize()

    --添加排名
    local labItem = CCLabelAtlas:create(""..(idx+1), AppConfig.ImgFilePath.."num_rank.png",38,48,string.byte('0'))
    if idx < 3 then labItem = loadSprite(string.format("lobby/rank%d.png", (idx+1))) end
    labItem:setAnchorPoint(ccp(0.5, 0.5))
    labItem:setPosition(ccp(35, bgsz.height / 2))
    item:addChild(labItem)  

    faceSp:setPosition(ccp(107, bgsz.height / 2))
    item:addChild(faceSp)   

    item:setAnchorPoint(ccp(0, 0))
    return item, bgsz
end

function LayerRoom:addRankInfo(item, bgsz, name, msg)
    local tips, labItem = {name, msg}
    for i,v in ipairs(tips) do
        labItem = CCLabelTTF:create(v, AppConfig.COLOR.FONT_BLACK, 23)
        labItem:setColor(ccc3(0x41, 0x39, 0x32))  
        labItem:setHorizontalAlignment(kCCTextAlignmentLeft)
        labItem:setAnchorPoint(ccp(0, 0.5))     
        labItem:setPosition(ccp(150, bgsz.height / 2 - 40 * i + 60))
        item:addChild(labItem)
    end

    if labItem then
        --标示
        local mark = loadSprite("common/diamond.png")
        mark:setAnchorPoint(ccp(0, 0.5))
        mark:setPosition(ccp(155 + labItem:getContentSize().width, bgsz.height / 2 - 20))
        mark:setScale(0.6)
        item:addChild(mark)
        item:setEnabled(true)
    else
        item:setEnabled(false)
    end
end

function LayerRoom.put(super, zindex)
    local layer = LayerRoom.new()
    layer.layer_zIndex = zindex
    super:addChild(layer, zindex)
    layer:init()
    return layer
end

return LayerRoom