--LayerChatShow.lua
local AppConfig = require("AppConfig")

require("GameLib/common/common")
local GameLibSink = require("bull/GameLibSink")
local SetLogic = require("Lobby/Set/SetLogic")
local LayerChatShow=class("LayerChatShow",function()
        return CCLayer:create()
    end)
    
-- 移除表情或气泡
function LayerChatShow.removeItem(item)
    local p, n = item:getParent(), item.name
    if p and n and p[n] then p[n] = nil end
    item:stopAllActions()
    item:removeFromParentAndCleanup(true)
end

-- 创建文字气泡
function LayerChatShow.createPop(m, n, t)
    local padding = CCSizeMake(8, 12)

    --local pos = { ccp(100.5,670.5), ccp(100.5,46.5), ccp(1180.5,670.5) }
	local  basePos = GameLibSink.sDeskLayer.m_aclsPlayer[1].allPlayerPos
	local  nMaxPlayer = GameLibSink.sDeskLayer.realPlayerCnt
	if not basePos then return end
    local textPos = {
		ccp(basePos[1][2].x,basePos[1][2].y + 162),
		ccp(basePos[2][2].x + 116,basePos[2][2].y + 162),
		ccp(basePos[3][2].x + 116,basePos[3][2].y + 162),
		ccp(basePos[4][2].x + 10,basePos[4][2].y + 162),
		ccp(basePos[5][2].x + 10,basePos[5][2].y + 162),
    }
	if nMaxPlayer == 3 then--根据人数特殊布局
		textPos[3] = ccp(basePos[3][2].x + 10,basePos[3][2].y + 162)
	end
    local pop = CCLayer:create()
    local sp = loadSprite("public/popbg.png", true)
    local l = CCLabelTTF:create(n, "" ,24)
    local size = l:getContentSize()
    local a = loadSprite("public/poparrow.png")
    sp:setPreferredSize(CCSizeMake(size.width+padding.width*2,size.height+padding.height*2))
    l:setColor(ccc3(30,63,84))
    if m == 1 or m == 4 or m == 5 then
        sp:setAnchorPoint(ccp(0,0))
        l:setAnchorPoint(ccp(0,0))
        l:setPosition(ccp(padding.width,padding.height))
        a:setPosition(ccp(35,-6))
    else
        sp:setAnchorPoint(ccp(1,0))
        l:setAnchorPoint(ccp(1,0))
        l:setPosition(ccp(-padding.width,padding.height))
        a:setPosition(ccp(-35,-6))
    end
	if m == 3 and nMaxPlayer == 3 then --根据人数特殊布局
		sp:setAnchorPoint(ccp(0,0))
        l:setAnchorPoint(ccp(0,0))
        l:setPosition(ccp(padding.width,padding.height))
        a:setPosition(ccp(35,-6))
	end
    pop:addChild(sp)
    pop:addChild(l)
    pop:addChild(a)
    pop:setPosition(textPos[m])
    pop:runAction(CCSequence:createWithTwoActions(
        CCDelayTime:create(t),
        CCCallFuncN:create(LayerChatShow.removeItem)
    ))
    return pop
end

-- 创建表情
function LayerChatShow:showEmote(m, n)
    local itemName = "emote"..m
	local  basePos = GameLibSink.sDeskLayer.m_aclsPlayer[1].allPlayerPos
	if not basePos then return end
    local emotePos = {
		ccp(basePos[1][2].x + 50,basePos[1][2].y + 110),
		ccp(basePos[2][2].x + 50,basePos[2][2].y + 110),
		ccp(basePos[3][2].x + 50,basePos[3][2].y + 110),
		ccp(basePos[4][2].x + 50,basePos[4][2].y + 110),
		ccp(basePos[5][2].x + 50,basePos[5][2].y + 110),
    }
    local sp, t = self[itemName], self.showDelay
    if sp then
        self[itemName] = nil
        sp:stopAllActions()
        sp:removeFromParentAndCleanup(true)
    end
    -- if sp then self:removeItem(sp, itemName) end
    local sp2 = loadSprite(string.format("emote/emote%d-1.png", n))
    sp2.name = itemName
    sp2:setPosition(emotePos[m])
    local animFrames = CCArray:create()
    for i = 1, 3 do
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(
            string.format("emote/emote%d-%d.png", n, i))
        animFrames:addObject(frame)
    end
    local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.25)
    local animate = CCAnimate:create(animation);
    sp2:runAction(CCRepeatForever:create(animate))    
    sp2:runAction(CCSequence:createWithTwoActions(
        CCDelayTime:create(t),
        CCCallFuncN:create(LayerChatShow.removeItem)
    ))
    self:addChild(sp2)
    sp2:setScale(1.5)
    self[itemName] = sp2
    return true
end

-- 创建快捷
function LayerChatShow:showQuick(m, n)
	local lan_set = AppConfig.language[SetLogic.getGameCheckByIndex(3)]
    local quickChatCfg = AppConfig.quickChat[lan_set]
    local txt, itemName = quickChatCfg[tonumber(n)], "text"..m
    local pop, t = self[itemName], self.showDelay
    if pop then
        self[itemName] = nil
        pop:stopAllActions()
        pop:removeFromParentAndCleanup(true)
    end
    local pop2 = self.createPop(m, txt, t)
    pop2.name = itemName
    self:addChild(pop2)
    self[itemName] = pop2
    return true
end

-- 创建文字
function LayerChatShow:showText(m, n)
    local itemName = "text"..m
    local pop, t = self[itemName], self.showDelay
    if pop then
        self[itemName] = nil
        pop:stopAllActions()
        pop:removeFromParentAndCleanup(true)
    end
    local pop2 = self.createPop(m, n, t)
    pop2.name = itemName
    self:addChild(pop2)
    self[itemName] = pop2
    return true
end

function LayerChatShow:init()
    self.showDelay = 5
    -- 聊天列表轮询 0.5秒1次
    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(0.5))
    arr:addObject(CCCallFuncN:create(function(sender)
        if layerChat and layerChat.chatList then
            local emoteList = layerChat.chatList[1]
            local quickList = layerChat.chatList[2]
            local textList = layerChat.chatList[3]
            if #emoteList > 0 then
                local s, show = emoteList[1], true
                for k, v in pairs(s) do
                    local index = GameLibSink.game_lib:getUser(k):getUserChair()
                    local chair = GameLibSink.sDeskLayer:PosFromChair(index) --GameLibSink.game_lib:getRelativePos(index) + 1
                    show = sender:showEmote(tonumber(chair), tonumber(v))
                    break
                end
                if show then table.remove(emoteList, 1) end
            end
            if #quickList > 0 then
				
                local s, show = quickList[1], true
                for k, v in pairs(s) do
                    local userinfo = GameLibSink.game_lib:getUser(k)
                    local index = GameLibSink.game_lib:getUser(k):getUserChair()
                    local chair = GameLibSink.sDeskLayer:PosFromChair(index) --GameLibSink.game_lib:getRelativePos(index) + 1
                    show = sender:showQuick(tonumber(chair), tonumber(v))
					cclog("quickList"..tonumber(v))
                    --播放语言
					self:playVoiceEffect(userinfo._sex, tonumber(v))
                    --require("phz/Game/GameLogic"):getInstance():getInstance().music:playVoiceEffect(userinfo._sex, tonumber(v))
                    --self:getParent().playerLogo_panel:playVoiceEffect(index, tonumber(v))
                    break
                end
                if show then table.remove(quickList, 1) end
            end
            if #textList > 0 then
                local s, show = textList[1], true
                for k, v in pairs(s) do
                    local index = GameLibSink.game_lib:getUser(k):getUserChair()
                    local chair = GameLibSink.sDeskLayer:PosFromChair(index)--GameLibSink.game_lib:getRelativePos(index) + 1
                    show = sender:showText(tonumber(chair), v)
                    break
                end
                if show then table.remove(textList, 1) end
            end
        end
    end))
    self:runAction(CCRepeatForever:create(CCSequence:create(arr)))
    self:setTouchEnabled(false)
end

function LayerChatShow:playVoiceEffect(sex, chatid)
 --[[   local musicPath = "czmj/music/"
    if chatid > 5 then
        musicPath = "resources/music/mahjong/"
    end

    local sexpath = "man/"
    if sex ~= 1 then
        sexpath = "woman/"
    end
	
    local source = musicPath..sexpath.."chat"..chatid..AppConfig.SoundFileExtName]]
	local lan_set = AppConfig.language[SetLogic.getGameCheckByIndex(3)]
   -- local quickChatCfg = AppConfig.quickChat[lan_set]
	local sex = (sex == 1) and "man" or "woman"
    local word = string.format("resources/music/quickchat/%s/%s/word%d.mp3", lan_set, sex, chatid)
	
	cclog(word)
    SetLogic.playGameEffect(word)
end
function LayerChatShow.put(super, zindex)
    layerChatShow = LayerChatShow.new(zindex)
    layerChatShow.layer_zIndex = zindex
    layerChatShow:init()
    super:addChild(layerChatShow, zindex)
    return layerChatShow
end

return LayerChatShow