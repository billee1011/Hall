--LayerChatShow.lua
local AppConfig = require("AppConfig")
local CommonInfo = require("czmj/GameDefs").CommonInfo

require("GameLib/common/common")

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
    local textPos = {
        ccp(12,192),
        ccp(CommonInfo.View_Width - 10, CommonInfo.View_Height - 270),
        ccp(CommonInfo.View_Width - 394, CommonInfo.View_Height - 60),
        ccp(15, CommonInfo.View_Height - 270)
    }
    local pop = CCLayer:create()
    local sp = loadSprite("czmj/popbg.png", true)
    local l = CCLabelTTF:create(n, "" ,24)
    local size = l:getContentSize()
    local a = loadSprite("czmj/poparrow.png")
    sp:setPreferredSize(CCSizeMake(size.width+padding.width*2,size.height+padding.height*2))
    l:setColor(ccc3(30,63,84))
    if m == 1 or m == 4 then
        sp:setAnchorPoint(ccp(0,0))
        l:setAnchorPoint(ccp(0,0))
        l:setPosition(ccp(padding.width,padding.height))
        a:setPosition(ccp(35,-6))
    elseif m == 2 then
        sp:setAnchorPoint(ccp(1,0))
        l:setAnchorPoint(ccp(1,0))
        l:setPosition(ccp(-padding.width,padding.height))
        a:setPosition(ccp(-35,-6))
    elseif m == 3 then
        sp:setAnchorPoint(ccp(1,0))
        l:setAnchorPoint(ccp(1,0))
        l:setPosition(ccp(-padding.width,padding.height))
        a:setRotation(-90)
        a:setPosition(ccp(5,size.height/2+padding.height))
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
    local emotePos = {
        ccp(52, 144),
        ccp(CommonInfo.View_Width - 46, CommonInfo.View_Height / 2 + 36),
        ccp(CommonInfo.View_Width / 2 + 306, CommonInfo.View_Height - 56),
        ccp(70, CommonInfo.View_Height / 2 + 36)
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
    local quickChatCfg = AppConfig.quickChat[require("czmj/Game/LayerGamePlayer").lan_set]

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
                    local index = require(require("czmj/GameDefs").CommonInfo.GameLib_File).game_lib:getUser(k):getUserChair()
                    local chair = require("czmj/Game/GameLogic"):getInstance():getRelativeChair(index)
                    show = sender:showEmote(tonumber(chair), tonumber(v))
                    break
                end
                if show then table.remove(emoteList, 1) end
            end
            if #quickList > 0 then
                local s, show = quickList[1], true
                for k, v in pairs(s) do
                    local index = require(require("czmj/GameDefs").CommonInfo.GameLib_File).game_lib:getUser(k):getUserChair()
                    local chair = require("czmj/Game/GameLogic"):getInstance():getRelativeChair(index)
                    show = sender:showQuick(tonumber(chair), tonumber(v))

                    --播放语言
                    self:getParent().playerLogo_panel:playVoiceEffect(index, tonumber(v))
                    break
                end
                if show then table.remove(quickList, 1) end
            end
            if #textList > 0 then
                local s, show = textList[1], true
                for k, v in pairs(s) do
                    local index = require(require("czmj/GameDefs").CommonInfo.GameLib_File).game_lib:getUser(k):getUserChair()
                    local chair = require("czmj/Game/GameLogic"):getInstance():getRelativeChair(index)
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

function LayerChatShow.put(super, zindex)
    layerChatShow = LayerChatShow.new(zindex)
    layerChatShow.layer_zIndex = zindex
    layerChatShow:init()
    super:addChild(layerChatShow, zindex)
    return layerChatShow
end

return LayerChatShow