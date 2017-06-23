--TutorialLogic.lua

TutorialLogic = TutorialLogic or {}

TutorialAutoCloseTime = 4

TutorialName = {"发牌", "摆牌", "双击"}

-- 初始化教程记录(测试用)
function TutorialLogic:resetRecorder(t)
    -- print("TutorialLogic:resetRecorder")
    CCUserDefault:sharedUserDefault():setStringForKey("tutorialForSend", "")
    CCUserDefault:sharedUserDefault():setStringForKey("tutorialForOrder", "")
    CCUserDefault:sharedUserDefault():setStringForKey("tutorialForAutoOrder", "")
end

-- 读取教程记录
function TutorialLogic:getRecorder(panel)
    self.learnedSend = self.learnedSend or CCUserDefault:sharedUserDefault():getStringForKey("tutorialForSend") ~= ""
    self.learnedOrder = self.learnedOrder or CCUserDefault:sharedUserDefault():getStringForKey("tutorialForOrder") ~= ""
    self.learnedAutoOrder = self.learnedAutoOrder or CCUserDefault:sharedUserDefault():getStringForKey("tutorialForAutoOrder") ~= ""
    -- 如果所有教程(除滑动出牌外)完成则释放图集，否则加载图集
    local path = require("czmj/GameDefs").CommonInfo.Img_Path
    local f = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("czmjtutorial/tipOrder.png")
    if self.learnedOrder and self.learnedAutoOrder and f then
        Cache.removePlist{path.."czmjtutorial"}
    elseif not f then
        Cache.add{path.."czmjtutorial"}
    end
    -- 判定当前教程
    if not self.isLearning then
        self.isLearning = -1
        local t = panel.tutorialLayer
        if t then
            for i = 1, #t do
                if t[i] and t[i]:isVisible() then
                    self.isLearning = i
                    break
                end
            end
        end
    end
    -- print(os.time(), "教程读取", self.learnedSend, self.learnedOrder, self.learnedAutoOrder, self.isLearning)
end

-- 更新教程记录
function TutorialLogic:setRecorder(t)
    -- print(os.time(), "记录教程 "..TutorialName[t])
    -- print("TutorialLogic:setRecorder", os.time(), t)
    if t == 1 then
        CCUserDefault:sharedUserDefault():setStringForKey("tutorialForSend", "Done")
        self.learnedSend = true
    elseif t == 2 then
        CCUserDefault:sharedUserDefault():setStringForKey("tutorialForOrder", "Done")
        self.learnedOrder = true
    elseif t == 3 then
        CCUserDefault:sharedUserDefault():setStringForKey("tutorialForAutoOrder", "Done")
        self.learnedAutoOrder = true
    end
end

-- 发牌教程判定 id:1
function TutorialLogic:checkSend(panel)
    -- print(os.time(), "发牌教程检查中...", "当前教程状态：", self.isLearning)
    if self.isLearning < 0 then
        local CommonInfo = require("czmj/GameDefs").CommonInfo
        local Logic = require(CommonInfo.Logic_Path):getInstance()
        local isSender = Logic:mineIsSender()
        local sendType = require("Lobby/Set/SetLogic").getOutCardType()
        -- print(string.format("是否学过:%s  发牌方式:%s  是否出牌:%s 手牌张数:%s",self.learnedSend, sendType, isSender, #panel.card_uis))
        if (not self.learnedSend) and sendType ~= 1 and isSender then
            self:showTutorial(panel, 1)
            return true
        end
    elseif self.isLearning == 1 then
        return true
    end
    return false
end

-- 摆牌教程判定 id:2
function TutorialLogic:checkOrder(panel)
    -- print(os.time(), "摆牌教程检查中...", "当前教程状态：", self.isLearning)
    if self.isLearning < 0 then
        local orderType = require("Lobby/Set/SetLogic").getCardOrderType()
        -- print(string.format("是否学过:%s  摆牌方式:%s",self.learnedOrder, orderType))
        if (not self.learnedOrder) and orderType ~= 1 then
            self:showTutorial(panel, 2)
            return true
        end
    elseif self.isLearning == 2 then
        return true
    end
    return false
end

-- 双击摆牌教程判定 id:3
function TutorialLogic:checkAutoOrder(panel)
    -- print(os.time(), "双击教程检查中...", "当前教程状态：", self.isLearning)
    if self.isLearning < 0 then
        local orderType = require("Lobby/Set/SetLogic").getCardOrderType()
        -- print(string.format("是否学过:%s  摆牌方式:%s",self.learnedAutoOrder, orderType))
        if (not self.learnedAutoOrder) and orderType ~= 1 then
            self:showTutorial(panel, 3)
            return true
        end
    elseif self.isLearning == 3 then
        return true
    end
    return false
end

-- 创建教程
TutorialLogic.createTutorial = {
    -- 出牌教程(已取消)
    [1] = function()
        --[[
        local AppConfig = require("AppConfig")
        local screenMidx = AppConfig.SCREEN.CONFIG_WIDTH/ 2
        local screenMidy = AppConfig.SCREEN.CONFIG_HEIGHT/ 2
        local layer = CCLayer:create()
        local line = loadSprite("czmjtutorial/line.png")
        line:setPosition(ccp(screenMidx, 140))
        local tip = loadSprite("czmjtutorial/tipSend.png")
        tip:setPosition(ccp(screenMidx, 206))
        local arrow = loadSprite("czmjtutorial/arrowup.png")
        arrow:setPosition(ccp(screenMidx+426, 200))
        local hand = loadSprite("czmjtutorial/hand.png")
        hand:setPosition(ccp(screenMidx+455, 152))
        layer:addChild(line)
        layer:addChild(tip)
        layer:addChild(arrow)
        layer:addChild(hand)
        local array = CCArray:create()
        array:addObject(CCMoveBy:create(1, ccp(0, 68)))
        array:addObject(CCCallFuncN:create(function(sender)        
            sender:setPosition(ccp(sender:getPositionX(), sender:getPositionY()-68))
        end)) 
        array:addObject(CCDelayTime:create(0.5))
        hand:runAction(CCRepeatForever:create(CCSequence:create(array)))
        return layer
        ]]
        return CCLayer:create()
    end,
    -- 摆牌教程
    [2] = function()
        local AppConfig = require("AppConfig")
        local screenMidx = AppConfig.SCREEN.CONFIG_WIDTH/ 2
        local screenMidy = AppConfig.SCREEN.CONFIG_HEIGHT/ 2
        local layer = CCLayer:create()
        local line = loadSprite("czmjtutorial/arrowleft.png")
        line:setPosition(ccp(screenMidx-100, 168))
        local line2 = loadSprite("czmjtutorial/arrowleft.png")
        line2:setPosition(ccp(screenMidx+100, 168))
        line2:setRotation(180)
        local tip = loadSprite("czmjtutorial/tipOrder.png")
        tip:setPosition(ccp(screenMidx, 205))
        local hand = loadSprite("czmjtutorial/hand.png")
        hand:setPosition(ccp(screenMidx, 140))
        layer:addChild(line)
        layer:addChild(line2)
        layer:addChild(tip)
        layer:addChild(hand)
        local array = CCArray:create()
        array:addObject(CCMoveBy:create(1, ccp(-150, 0)))
        array:addObject(CCMoveBy:create(2, ccp(300, 0)))
        array:addObject(CCMoveBy:create(1, ccp(-150, 0)))
        hand:runAction(CCRepeatForever:create(CCSequence:create(array)))
        local array2 = CCArray:create()
        array2:addObject(CCDelayTime:create(TutorialAutoCloseTime))
        array2:addObject(CCCallFuncN:create(function(sender)        
            TutorialLogic:hideTutorial(require("czmj/Game/GameLogic"):getInstance():getMyPanel(), 2)
        end)) 
        layer:runAction(CCSequence:create(array2))
        return layer
    end,
    -- 自动摆牌教程
    [3] = function()
        local AppConfig = require("AppConfig")
        local layer = CCLayer:create()
        local hand = loadSprite("czmjtutorial/press1.png")
        hand:setPosition(ccp(AppConfig.SCREEN.CONFIG_WIDTH-168, 168))
        local tip = loadSprite("czmjtutorial/tipAutoOrder.png")
        tip:setPosition(ccp(AppConfig.SCREEN.CONFIG_WIDTH-306, 168))
        layer:addChild(hand)
        layer:addChild(tip)
        local animFrames = CCArray:create()
        animFrames:addObject(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("czmjtutorial/press2.png"))
        animFrames:addObject(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("czmjtutorial/press1.png"))
        local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.25)
        local animate = CCAnimate:create(animation);
        hand:runAction(CCRepeatForever:create(animate))
        local array2 = CCArray:create()
        array2:addObject(CCDelayTime:create(TutorialAutoCloseTime))
        array2:addObject(CCCallFuncN:create(function(sender)        
            TutorialLogic:hideTutorial(require("czmj/Game/GameLogic"):getInstance():getMyPanel(), 3)
        end)) 
        layer:runAction(CCSequence:create(array2))
        return layer
    end
}

-- 显示教程
function TutorialLogic:showTutorial(panel, t)
    panel.tutorialLayer = panel.tutorialLayer or {}
    -- print(os.time(), "检查是否开启教程 "..TutorialName[t])
    if self.createTutorial[t] then
        local layer = self.createTutorial[t]()
        panel:addChild(layer, panel.tutorial_zIndex)
        panel.tutorialLayer[t] = layer
        self.isLearning = t
        -- print(os.time(), TutorialName[t].."教程开启!!!")
    end
end

-- 关闭指定教程
function TutorialLogic:hideTutorial(panel, t)
    -- print(os.time(), "检查是否关闭教程 "..TutorialName[t])
    if panel.tutorialLayer and panel.tutorialLayer[t] then
        panel.tutorialLayer[t]:setVisible(false)
        panel.tutorialLayer[t]:removeFromParentAndCleanup(true)
        panel.tutorialLayer[t] = nil
        if self.isLearning == t then self.isLearning = -1 end
        self:setRecorder(t)
        -- print(os.time(), TutorialName[t].."教程关闭!!!")
    end
end

-- 关闭所有教程
function TutorialLogic:hideAllTutorials(panel)
    if panel.tutorialLayer and #panel.tutorialLayer > 0 then
        for i = 1, #panel.tutorialLayer do
            self:hideTutorial(panel, i)
        end
    end
end

-- 教程检查
function TutorialLogic:check(panel, t)
    -- print("--------------------------------------")
    -- print(os.time(), "开始检查点:"..t)
    if self.checkPoint[t] then
        self:getRecorder(panel)
        self.checkPoint[t](panel)
    end
end

-- 教程检查点
--[[
1 开场、摸牌、吃碰杠     检查发牌教程
2 打牌                   关闭发牌教程、检查摆牌教程
3 完成摆牌               关闭摆牌教程、检查自动摆牌教程
4 双击摆牌               关闭自动摆牌教程
5 关闭设置               检查发牌教程(优先)、检查摆牌教程
]]
TutorialLogic.checkPoint = {
    [0] = function(panel)
        TutorialLogic:hideAllTutorials(panel)
    end,
    [1] = function(panel)
        TutorialLogic:checkSend(panel)
    end,
    [2] = function(panel)
        TutorialLogic:hideTutorial(panel, 1)
        TutorialLogic:checkOrder(panel)
    end,
    [3] = function(panel)
        TutorialLogic:hideTutorial(panel, 2)
        TutorialLogic:checkAutoOrder(panel)
    end,
    [4] = function(panel)
        TutorialLogic:hideTutorial(panel, 3)
    end,
    [5] = function(panel)
        if panel.isStart then
            local sLogic = require("Lobby/Set/SetLogic")
            if sLogic.getOutCardType() == 1 then TutorialLogic:hideTutorial(panel, 1) end
            if sLogic.getCardOrderType() == 1 then TutorialLogic:hideTutorial(panel, 2) end
            if not TutorialLogic:checkSend(panel) then
                TutorialLogic:checkOrder(panel)
            end
        end
    end
}