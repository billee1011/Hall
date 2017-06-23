--LayerMyCard.lua
local CommonInfo = require("sgmj/GameDefs").CommonInfo
local AppConfig = require("AppConfig")
local OperateCmd = require(CommonInfo.Code_Path.."GameDefs").OperateCmd

local SpriteGameCard = require(CommonInfo.Code_Path.."Game/SpriteGameCard")
local CCButton = require("FFSelftools/CCButton")
local SetLogic = require("Lobby/Set/SetLogic")

--[[----------------- 下面是debug代码 --------------------- ]]
debugCheckCard = false

function checkCards(t, s)
    if not debugCheckCard then return end
    local Logic = require(CommonInfo.Logic_Path):getInstance()
    local hasErr = false
    log2File(string.format("========================= %s =========================",s))
    for k, v in ipairs(t.card_uis) do
        log2File("[%s] idx:%s	value:%s	real:%s", k, v.carddata_index, v.card_index, Logic:getMineCards()[v.carddata_index])
        if v.card_index ~= Logic:getMineCards()[v.carddata_index] then
            hasErr = true
        end
    end
    log2File("========================= cbCardData =========================")
    for k, v in ipairs(Logic:getMineCards()) do
        log2File("[%s] %s", k, v)
    end
    if hasErr then
        log2File("========================= ERROR!!! =========================")
        t.hand_cards:runAction(CCBlink:create(15, 50))
    else
        log2File("============================================================")
    end
end
----------------------------------------------------------- ]]

local LayerMyCard=class("LayerMyCard",function()
        return require(CommonInfo.Code_Path.."Game/LayerWestCard").new()
    end)

function LayerMyCard:init() 
    self.sprite_card = require(CommonInfo.Code_Path.."Game/SpriteGameCard")

    self.operator_pos = ccp(CommonInfo.View_Width - 250, 185)
    self.operator_btns = {}

    self.touch_seces=0
    
    self.isStart = false

    --层级
    self.downCard_zIndex = 1
    self.weave_zIndex = 10
    self.hangdCard_zIndex = 20
    self.operator_zIndex = 30
    self.cardarrow_zIndex = 40
    self.tutorial_zIndex = 15

    self.left_pos = ccp(110, -3)    --牌墙起始点

    self.outline = 190              -- 出牌线Y坐标
    self.all_cards_pos = {}         -- 所有牌的位置信息
    self.card_fly_Speed = 15000     -- 牌的飞行速度
    self.operator_items = {}
    
    self.tutorialLayer = {}         -- 教程

    self.down_pos = ccp(CommonInfo.View_Width / 2 , 333)
    self.down_posx = CommonInfo.View_Width / 2 - 3
    self.down_lastpos = nil
    self.tip_card = nil

    --手牌
    self.hand_cards = CCLayer:create()
    self:addChild(self.hand_cards, self.hangdCard_zIndex)
    self.card_index = nil

    --吃碰杠
    self.weave_cards = CCLayer:create()
    self:addChild(self.weave_cards, self.weave_zIndex) 

    --移动牌的坐标
    self.sord_pos = ccp(400, 40)
    self.space_pos = ccp(0, 40)

    --吃碰杠位置
    self.weave_zeropos = ccp(CommonInfo.View_Width - 20, 0)
    self.weave_pos = ccp(CommonInfo.View_Width - 20, 0)
    self.weave_count = 0

    self:test()
end

function LayerMyCard:addGangBtn(cards)
    local itemIndex = 2
    if #cards > 1 then
        self:addFlickerBtn("gang", function()
            if self.operator_items[itemIndex] then
                self:showOperatorItems(itemIndex)
                return
            end

            local items = {}
            for i,v in ipairs(cards) do
                local item = createButtonWithFilePath("mjdesk/chiBg.png", nil, function()
                        require(CommonInfo.Logic_Path):getInstance().cbOperateCard = v
                        require(CommonInfo.Logic_Path):getInstance():sendOperateCard(OperateCmd.Gang)
                        self:clearOperatorBtn()
                    end, nil, CCSizeMake(254, 106))
                item:setTouchPriority(kCCMenuHandlerPriority - self.btn_zIndex - 1)
                item:setPosition(ccp(CommonInfo.View_Width - 170 - 265 * i, self.operator_pos.y - 6))
                self:addChild(item, self.operator_zIndex)
                table.insert(items, item)

                --创建麻将子
                for j=1,4 do
                    local mjSp = SpriteGameCard.createHand(v)
                    mjSp:setScale(0.7)
                    local pos = ccp(mjSp.base_size.width * (j - 1) * 0.7 + 14, 13)
                    mjSp:setPosition(pos)
                    item:addChild(mjSp, j, j)
                end 
            end 
            self.operator_items[itemIndex] = items
            self:addCancelBtn()
            self:showOperatorItems(itemIndex)
        end)  
    else
        self:addFlickerBtn("gang", function()
            require(CommonInfo.Logic_Path):getInstance().cbOperateCard = cards[1]
            require(CommonInfo.Logic_Path):getInstance():sendOperateCard(OperateCmd.Gang)
            self:clearOperatorBtn()
        end)           
    end
end

--显示操作选项
function LayerMyCard:showOperatorItems(index)
    for i,v in ipairs(self.operator_items[index]) do
        v:setVisible(true)
    end  
    for i=1,#self.operator_btns - 1 do
        self.operator_btns[i]:setVisible(false)
    end   
    self.operator_btns[#self.operator_btns]:setVisible(true)     
end

--添加取消按钮
function LayerMyCard:addCancelBtn()
    if self.cancel_btn then
        return
    end


    self.cancel_btn = self:addFlickerBtn("cancel", function()
        for i=1,2 do
            if self.operator_items[i] then
                for j,v in ipairs(self.operator_items[i]) do
                    v:setVisible(false)
                end            
            end
        end

        for i,v in ipairs(self.operator_btns) do
            v:setVisible(true)
        end
        self.operator_btns[#self.operator_btns]:setVisible(false)
    end)
    self.cancel_btn:setPosition(ccp(CommonInfo.View_Width - 230, self.operator_pos.y))
end

function LayerMyCard:addOperatorBtn(img, func)
    self:addFlickerBtn(img, function()
            func()
            self:clearOperatorBtn()
        end)
end

function LayerMyCard:addFlickerBtn(img, func)
    if TutorialLogic_SGMJ then
        TutorialLogic_SGMJ:check(self, 0)
    end

    local item, s9Sp = createButtonWithOneStatusFrameName("mjAnima/btn_operator_"..img.."1.png", nil, function()
            func()
        end)
    item:setTouchPriority(kCCMenuHandlerPriority - self.btn_zIndex)
    item:setPosition(self.operator_pos)
    self:addChild(item, self.operator_zIndex)

    self.operator_pos.x = self.operator_pos.x - 190  
    table.insert(self.operator_btns, item)

    local uis = {}
    for i=2,3 do
        local sprite = loadSprite("mjAnima/btn_operator_"..img..""..i..".png")
        sprite:setPosition(ccp(s9Sp:getContentSize().width / 2, s9Sp:getContentSize().height / 2))
        s9Sp:addChild(sprite, -1)
        table.insert(uis, sprite)
    end
    require("Lobby/Common/AnimationUtil").runFlickerAction(uis[1], true, uis[2])   

    return item
end

function LayerMyCard:clearOperatorBtn()
    if #self.operator_btns < 1 then
        return
    end

    for i,v in ipairs(self.operator_btns) do
        v:removeFromParentAndCleanup(true)
    end

    self.operator_btns = {}
    self.operator_pos.x = CommonInfo.View_Width - 250

    for i=1,2 do
        if self.operator_items[i] then
            for j,v in ipairs(self.operator_items[i]) do
                v:removeFromParentAndCleanup(true)
            end            
        end
    end
    self.operator_items = {}

    self.cancel_btn = nil
end

--开始游戏
function LayerMyCard:gameStart(func) 
    local array = CCArray:create()
    array:addObject(CCDelayTime:create(0.3))
    array:addObject(CCCallFunc:create(function()        
        --整理
        self.isStart = true
        self:sortCard(true, "开始游戏") 
        self:initTouch()
        if TutorialLogic_SGMJ then
            TutorialLogic_SGMJ:check(self, 5)
        end
        func()
    end)) 
    self:runAction(CCSequence:create(array))
end

function LayerMyCard:gameEnd() 
    self:setTouchEnabled(false)
    self.touch_enable = false
end

function LayerMyCard:initTouch() 
    local function onTouch(eventType, x, y)
        if not self.touch_enable then
            return false
        end

        if eventType=="began" then
            return self:onTouchBegan(x, y)
        elseif eventType=="moved" then
            self:onMoved(x,y)
        elseif eventType=="ended" then
            self:onEnded(x,y)
        end
    end
    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority - self.layer_zIndex,true)
    self:setTouchEnabled(true)
    self.touch_enable = true
    
    checkCards(self, "Start ...")
end

function LayerMyCard:addCardWall(count)
    self.down_cards = CCLayer:create()
    self:addChild(self.down_cards, self.downCard_zIndex)

    local panel  = CCLayer:create()
    self:addChild(panel, self.downCard_zIndex) 
    local pos, uis, spacepos, scales = ccp(386, 150), {}, {ccp(-3, 13), ccp(0, 0)}, {1, 0.985}
    local start = 15 - count

    local cardIndex
    if start ~= 1 then
        --创建中间牌
        pos.x = pos.x + 26
    end

    local function addWallCard(ctype)
        local sp, spaces, zindex, index
        for j=1,2 do
            sp, spaces, zindex, index = self.sprite_card.createWallCard(ctype, #uis)
            sp:setPosition(ccp(pos.x + spacepos[j].x, pos.y + spacepos[j].y))
            table.insert(uis, index, sp)
            panel:addChild(sp, zindex + 2 - 2 * j)
            sp:setScale(sp:getScale() * scales[j])
        end

        pos.x = pos.x + spaces.x
        pos.y = pos.y + spaces.y         
    end

    --左边牌
    for i=7, start, -1 do
        spacepos[1].x = -1
        spacepos[2].x = 1
        if i == start then
            spacepos[1].x = 1
        end        
        addWallCard(-i)
    end

    for i=1,7 do
        spacepos[1].x = 3
        spacepos[2].x = 0
        if i == 1 then
            spacepos[1].x = 2
        end
        addWallCard(i)
    end

    return uis      
end

function LayerMyCard:getHandRightOffset()
    return 67 + self.weave_zeropos.x - self.weave_pos.x
end

function LayerMyCard:initHandPais(carddata)
    local pai = SpriteGameCard.createHand(carddata[1])    
    local count = #carddata

    if self.operate_cards then
        self.operate_cards:removeFromParentAndCleanup(true)
    end

    -- 计算牌墙位置
    local Logic = require(CommonInfo.Logic_Path):getInstance()
    local cardWidth, rightOffset = pai.base_size.width * count, self:getHandRightOffset()
    if Logic:mineIsSender() then
        cardWidth = cardWidth + pai.base_size.width / 3
    else
        cardWidth = cardWidth + pai.base_size.width * 4 / 3
    end

    self.operate_cards = CCLayerColor:create(ccc4(0, 0, 0, 0), cardWidth, pai.base_size.height + 30)
    self.operate_cards:setPosition(ccp(CommonInfo.View_Width - cardWidth - rightOffset + 15, 1))
   
    self.card_uis = {}
    for i=1,count do
        local item = SpriteGameCard.createHand(carddata[i])
        local pos = ccp(pai.base_size.width * (i - 1), 0)
        item.carddata_index = i
        item:setPosition(pos)
        self.operate_cards:addChild(item, i, i)
        table.insert(self.card_uis, item)
    end

    self:addChild(self.operate_cards, self.hangdCard_zIndex)
    self.card_index = nil

    return self    
end

--刷新手牌
function LayerMyCard:updataMineHandPais(carddata)
    if self.card_index then
        self.card_uis[self.card_index]:onBtnCard(0)
        self.card_index = nil
    end
    for i,v in ipairs(self.card_uis) do
        v.carddata_index = i
        if v.card_index ~= carddata[i] then
            v:updataValue(carddata[i])
        end
    end
    self:updataHorizontalPos()
    checkCards(self, "after updataMineHandPais")
    return self    
end

function LayerMyCard:sortCard(force, desc)
    if not self.card_uis then
        return
    end
    
    -- 如果强制、或单击出牌、或自动排序
    -- print(force, desc, SetLogic.getOutCardType(), SetLogic.getCardOrderType())
    -- if force or SetLogic.getOutCardType() == 1 or SetLogic.getCardOrderType() == 1 then
    if force or SetLogic.getCardOrderType() == 1 then
        self:updataMineHandPais(require(CommonInfo.Logic_Path):getInstance():sortMineCards())
        cclog("Logic:sortMineCards by LayerMyCard:sortCard from ".. desc)
    end
end

function LayerMyCard:setCardIndex(index)
    self.card_index = index
end

function LayerMyCard:enterBackGround()
    -- cclog("LayerMyCard:enterBackGround")
    if not self.card_uis then
        return
    end
        
    if self.card_index then
        self.card_uis[self.card_index]:onBtnCard(0)
        self.card_index = nil
    end
    self:updataHorizontalPos()
	
end

function LayerMyCard:onTouchBegan(x, y)
    -- cclog("LayerMyCard:onTouchBegan")
    local point, pai = ccp(x,y), self.card_uis[1]
    self.collapsed = false
    self.all_cards_boundingBox = {}
    
    -- 恢复所有牌状态
    for i,v in ipairs(self.card_uis) do
        if v:getScale() > 1 then v:onBtnCard(0) self:updataHorizontalPos() end
    end
    -- 如果在牌墙范围内
    if self.operate_cards:boundingBox():containsPoint(point) then
        local layerpos = self.operate_cards:convertToNodeSpace(point)
        -- 判断是否有牌被选中
        for i,v in ipairs(self.card_uis) do
            if v:boundingBox():containsPoint(layerpos) then
                v:onBtnCard()
                self.card_index = i
                self.targetIndex = i
                self.card_pos = ccp(v:getPositionX(), 0)
                self:updataHorizontalPos()
                -- 缓存所有牌判定范围
                for i,v in ipairs(self.card_uis) do
                    local t = v:boundingBox()
                    table.insert(self.all_cards_boundingBox, CCRectMake(t.origin.x, 0, t.size.width, CommonInfo.View_Height))
                end
                return true
            end
        end
    --[[
    -- 如果在牌墙范围外
    else
        -- 单击出牌方式下恢复选中牌
        if SetLogic.getOutCardType() == 1 and self.card_index then
            self.card_uis[self.card_index]:onBtnCard(0)
            self:updataHorizontalPos()
            self.card_index = nil
            self.card_pos = nil
        end
    ]]
    end
    return true
end

function LayerMyCard:onMoved(x,y)
    -- print("LayerMyCard:onMoved")
    local Logic = require(CommonInfo.Logic_Path):getInstance()
    local point, pai = ccp(x,y), SpriteGameCard.createHand(1)
    local layerpos = self.operate_cards:convertToNodeSpace(point)
    --[[
    -- 单击出牌方式
    if SetLogic.getOutCardType() == 1 then
        if self.operate_cards:boundingBox():containsPoint(point) then
            --在牌墙范围
            for i,v in ipairs(self.card_uis) do
                -- 如果有牌命中则变更选中牌
                if v:boundingBox():containsPoint(layerpos) then
                    if self.card_index ~= i then
                        if self.card_index then self.card_uis[self.card_index]:onBtnCard(0) end
                        v:onBtnCard(1)
                        self.card_index = i
                        self.card_pos = ccp(v:getPositionX(), 0)
                        self:updataHorizontalPos()
                        return
                    end
                end
            end
        end
    -- 拖曳出牌方式
    else
    ]]
        -- 如果有选中牌则牌跟随移动
        if self.card_index and self.card_uis[self.card_index] then
            local card = self.card_uis[self.card_index]
            local w = self.operate_cards:getPositionX()
            card:setPosition(ccpSub(point, 
                ccp(pai.base_size.width*0.625+w,
                pai.base_size.height*0.625)
            ))
            -- 如果非自动排序
            if SetLogic.getCardOrderType() ~= 1 then
                -- 如果出牌状态且牌高于出牌线则收拢手牌
                if Logic:mineIsSender() and card:getPositionY() >= self.outline then
                    self:collapseCards()
                -- 否则则显示插牌位置
                else
                    local boxs, tIdx = self.all_cards_boundingBox, self.card_index
                    local count = #self.card_uis
                    if layerpos.x <= boxs[1].origin.x then
                        tIdx = 1
                    elseif layerpos.x >= boxs[count].origin.x + pai.base_size.width then
                        tIdx = count
                    else
                        for i, box in ipairs(self.all_cards_boundingBox) do
                            if box:containsPoint(layerpos) then
                                tIdx = i
                                break
                            end
                        end
                        
                    end
                    self:updataOtherHorizontalPos(tIdx, self.collapsed)
                end
            end
        end
    -- end
end

function LayerMyCard:onEnded(x,y)
    -- cclog("LayerMyCard:onEnded", x, y)
    local point, Logic = ccp(x,y), require(CommonInfo.Logic_Path):getInstance()
    local pai = SpriteGameCard.createHand(1)
    local seces = os.time()
    --[[ 单击出牌
    if SetLogic.getOutCardType() == 1 then
        if self.operate_cards:boundingBox():containsPoint(point) then
            --在牌墙范围
            local layerpos = self.operate_cards:convertToNodeSpace(point)
            for i,v in ipairs(self.card_uis) do
                if v:boundingBox():containsPoint(layerpos) then
                    --打牌          
                    Logic:sendOutCard(v.carddata_index)
                    self.targetIndex = nil
                    self.all_cards_boundingBox = nil
                    return
                end
            end
        else
            local seces = os.time()
            if seces <= self.touch_seces + 1 then
                self:sortCard(true, "单击出牌双击排序")
                self:updataHorizontalPos()
                self.touch_seces = 0
                if TutorialLogic_SGMJ then
                    TutorialLogic_SGMJ:check(self, 4)
                end  
            else
                self.touch_seces = seces
            end
        end
    -- 拖曳出牌
    else
    ]]
        --出牌状态下的判定
        if Logic:mineIsSender() and self.card_index then
            local card = self.card_uis[self.card_index]
            if not card.touch_seces then card.touch_seces = 0 end
            -- 如果位置高于出牌线或两次点击时间间隔小于1秒则出牌
            if card and (card:getPositionY() >= self.outline or seces <= card.touch_seces + 1) then
                card.touch_seces = seces
                if Logic:sendOutCard(card.carddata_index) then
                    self.touch_seces = 0
                    self.targetIndex = nil
                    self.all_cards_boundingBox = nil
                    return
                end
            end
        end
        -- 非出牌状态下
        if self.card_index then
            local card = self.card_uis[self.card_index]
            local cx, tIdx, tp = card:getPositionX(), self.card_index, self.card_pos
            card.touch_seces = seces
            -- 如果非自动排序
            if SetLogic.getCardOrderType() ~= 1 then
                if self.targetIndex and self.targetIndex ~= self.card_index then
                    tIdx = self.targetIndex
                    tp = ccp(self.card_uis[tIdx]:getPositionX(), 0)
                    table.remove(self.card_uis, self.card_index)
                    table.insert(self.card_uis, tIdx, card)
                end
            end
            self:onAnimaStart()
            -- 摆牌后检测
            if self.card_index ~= tIdx then 
                if TutorialLogic_SGMJ then
                    TutorialLogic_SGMJ:check(self, 3)
                end
            end
            local duration = ccpDistance(ccp(card:getPosition()), tp)/self.card_fly_Speed
            if self.card_index > tIdx then
                for j = tIdx+1, self.card_index do
                    local mc = self.card_uis[j]
                    mc:runAction(CCMoveBy:create(duration, ccp(pai.base_size.width*mc:getScale(), 0)))
                end
            else
                for j = self.card_index, tIdx-1 do
                    local mc = self.card_uis[j]
                    mc:runAction(CCMoveBy:create(duration, ccp(-pai.base_size.width*mc:getScale(), 0)))
                end
            end
            local arr = CCArray:create()
            arr:addObject(CCMoveTo:create(duration ,tp ))
            arr:addObject(CCCallFuncN:create(function(sender)
                local Logic = require(CommonInfo.Logic_Path):getInstance()
                local panel = Logic.main_layer.player_panel[Logic.wChair + 1]
                panel:updataHorizontalPos()
                panel.card_index = nil
                panel.card_pos = nil
                panel:onAnimaEnd()
            end))
            card:runAction(CCSequence:create(arr))
            
            checkCards(self, "card switch self:"..self.card_index.."  target:"..tIdx)
        else
            if seces <= self.touch_seces + 1 then
                self:sortCard(true, "拖曳出牌双击排序")
                self:updataHorizontalPos()
                self.touch_seces = 0
                if TutorialLogic_SGMJ then
                    TutorialLogic_SGMJ:check(self, 4)
                end                
            else
                self.touch_seces = seces
            end
        end
    -- end
    self.all_cards_boundingBox = nil
end

--设置手牌水平位置
function LayerMyCard:updataHorizontalPos()
    local isSender = require(CommonInfo.Logic_Path):getInstance():mineIsSender()

    local space, count = 0, #self.card_uis
    local maxSp = self.card_uis[count]
    for i = 1,count do
        if self.card_index and self.card_index == i then
            self.card_uis[i]:setZOrder(999)
        else
            self.card_uis[i]:setZOrder(i)
        end
        self.card_uis[i]:stopAllActions()
        self.card_uis[i]:setPositionX(space)
        self.card_uis[i]:setPositionY(0)
        space = space + maxSp.base_size.width * self.card_uis[i]:getScale()
    end
    if isSender and count%3 == 2 then
        maxSp:setPositionX(maxSp:getPositionX() + maxSp.base_size.width / 3)
    end
end

--设置非选中手牌水平位置（显示插牌位置）
function LayerMyCard:updataOtherHorizontalPos(tIdx, force)
    -- print("updataOtherHorizontalPos", tIdx, self.card_index)
    if (self.targetIndex ~= tIdx) or (force) then
        local space, count = 0, #self.card_uis
        local w = SpriteGameCard.createHand(1).base_size.width
        local r, s = w * 5 / 4, {}
        for i = 1, count do table.insert(s, i) end
        table.remove(s, self.card_index)
        table.insert(s, tIdx, self.card_index)
        for i = 1, count do
            if s[i] ~= self.card_index then
                local c = self.card_uis[s[i]]
                c:stopAllActions()
                c:setPositionX(space)
                space = space + w
            else
                space = space + r
            end
        end
        self.targetIndex = tIdx
        self.collapsed = false
    end
end

-- 收拢手牌
function LayerMyCard:collapseCards()
    if self.targetIndex then
        local space, count = 0, #self.card_uis
        local w = SpriteGameCard.createHand(1).base_size.width
        local s = {}
        for i = 1, count do table.insert(s, i) end
        table.remove(s, self.card_index)
        table.insert(s, self.targetIndex, self.card_index)
        for i = 1, count do
            if s[i] ~= self.card_index then
                local c = self.card_uis[s[i]]
                c:stopAllActions()
                c:setPositionX(space)
                space = space + w
            end
        end
        self.collapsed = true
    end
end

function LayerMyCard:createPassed(card)
    self.passed_count = self.passed_count or 0
    local passIndex = self.passed_count

    local sp, downpos, scale, zIndex
    self.down_pos = ccp(CommonInfo.View_Width / 2 , 333)
    for i=0,passIndex do
        sp, downpos, scale, zIndex = self:getPassedPos(i, card)
    end

    self.passed_count = passIndex + 1
    return sp, downpos, scale, zIndex
end

function LayerMyCard:getPassedPos(passIndex, card)
    local downIndex = self:getParent().downIndex
    local spaceIndex = 0
    --最大牌数
    if downIndex == 6 then
        --四人模式
        if passIndex > 17 then passIndex = 17 end
    else
        --三人模式
        if passIndex > 27 then spaceIndex = passIndex - 27 passIndex = 27 end        
    end

    local xIndex, yIndex = passIndex % downIndex + 1, 3 - math.floor(passIndex / downIndex)--几行几列
    if passIndex == 27 then xIndex, yIndex = 10, 1 end

    local sp, index, zindex = SpriteGameCard.createVerticalPassed(card, 15 - xIndex)
    local scales = {{1, 1}, {0.98, math.pow(0.98, 2)}, {math.pow(0.98, 2), math.pow(0.98, 3) * 0.90}}

    if passIndex == 0 or passIndex == downIndex or passIndex == downIndex * 2 then
        self.down_pos.x = self.down_posx - 66 * scales[yIndex][1]
        self.down_pos.y = self.down_pos.y - 57 * scales[yIndex][2]
    else
        local xposes = {0, -48, -45, -49, -48, -49, -48, -48, -48, -48}
        self.down_pos.x = self.down_pos.x - scales[yIndex][1] * xposes[xIndex]        
    end

    return sp, self.down_pos, scales[yIndex], xIndex + spaceIndex
end

--场景恢复添加打出去的牌
function LayerMyCard:addStaticPassed(card)
    --放下牌
    local item, pos, scale, index = self:createPassed(card)
    item:setScaleX(scale[1])
    item:setScaleY(scale[2])
    item:setPosition(pos)

    self.down_cards:addChild(item, 6 - index)

    self.down_card = item
	return item
end

--场景恢复添加打出去提示牌
function LayerMyCard:addStaticPassedWithTip(card, func)
    --放下牌
    self:addStaticPassed(card)

    self:addCardArrowAnima(true, self.down_card:getCenterPos())

    func()
end

--开场整理牌动画
function LayerMyCard:getHandPaisAnima(func, bBanker)
    local Logic = require(CommonInfo.Logic_Path):getInstance()
    self:initHandPais(Logic:getMineCards())

    SpriteGameCard.getHandPaisAnima(self, 50, function()
        self.hand_cards:removeAllChildrenWithCleanup(true)
        self:initHandPais(Logic:sortMineCards())

        local array, scese = CCArray:create(), 0.1
        --是否为庄家，向右移动牌
        if bBanker then
            if TutorialLogic_SGMJ then
                TutorialLogic_SGMJ:check(self, 1)
            end            
            
            array:addObject(CCTargetedAction:create(self.card_uis[#self.card_uis], 
                CCMoveBy:create(0.1, ccp(self.card_uis[#self.card_uis].base_size.width / 3, 0))))
            scese = 0.01
        end
        array:addObject(CCDelayTime:create(scese))
        array:addObject(CCCallFunc:create(func))
        self:runAction(CCSequence:create(array))
    end, function() self.operate_cards:removeFromParentAndCleanup(true) self.operate_cards = nil end)

    return self    
end

function LayerMyCard:moveCardAnima()
    local sp = self.card_uis[#self.card_uis]
    sp:runAction(CCMoveBy:create(0.1, ccp(sp.base_size.width / 3, 0)))
end

--删除打出提示牌
function LayerMyCard:removeTipCard(tipSp)
    if tipSp then
        --玩家出牌动画回调
        if tipSp ~= self.tip_card then
            --已经打出新的牌了，删掉即可
            tipSp:removeFromParentAndCleanup(true)
            cclog("玩家出牌动画回调：打出去的牌已更新")
            return
        end
    end

    if not self.tip_card then
        return
    end

    --隐藏打出牌的箭头
    self:getParent():hideArrowAnima()
    self.touch_enable = true
    self:sortCard(nil, "LayerMyCard:sendCardAnima")

    self.tip_card:stopAllActions()
    self.tip_card:removeFromParentAndCleanup(true)

    self.tip_card = nil
end

--自己发牌动画
function LayerMyCard:sendCardAnima(card)
    self.touch_enable = false

    --log2File("sendcard : ".. self.card_index)
    --cclog("xxxxxxxxx sendCardAnima "..self.card_index..";"..self.card_uis[self.card_index].card_index)

    --清空操作按钮
    self:clearOperatorBtn()
    
    -- 关闭发牌教程、检查摆牌教程
    if TutorialLogic_SGMJ then
        TutorialLogic_SGMJ:check(self, 2)
    end

    local tipSp = self.card_uis[self.card_index]
    local w = SpriteGameCard.createHand(1).base_size.width
    
    -- 手动维护carddata_index
    for k, v in ipairs(self.card_uis) do
        if v.carddata_index > self.card_uis[self.card_index].carddata_index then
            v.carddata_index = v.carddata_index - 1
        end
    end
    -- 删除手牌数据
    table.remove(self.card_uis, self.card_index)
    self.card_index = nil

    --移动牌
    local cout = #self.card_uis
    for i = 1, cout do
        self.card_uis[i]:runAction(CCMoveTo:create(0.2, ccp(w*(i-1), 0)))
    end

    --放下牌
    local item, pos, scale, index = self:createPassed(card)
    item:setPosition(ccp(CommonInfo.View_Width / 2 + 40, 200))
    item:setVisible(false)
    self.down_cards:addChild(item, 6 - index)
    self.down_card = item
    self.down_lastpos = pos
    
    self.tip_card = tipSp    
    tipSp:sendCardAnima(function()
        item:setVisible(true)
        item:downCardAnima(pos, scale, function() 
            self:removeTipCard(tipSp)           
            self:addCardArrowAnima(true, item:getCenterPos())
            SetLogic.playGameEffect(AppConfig.SoundFilePathName.."outcard_effect"..AppConfig.SoundFileExtName)
            checkCards(self, "after sendCard")
        end)
    end, self.operate_cards:convertToNodeSpace(ccp(CommonInfo.View_Width / 2 - 40, 200)))
    return item
end

--自己抓牌动画
function LayerMyCard:getCardAnima(card, func)
    self.tip_card = nil

    self:getParent():getGameCardAnima(1)

    local cout = #self.card_uis
    local pai = SpriteGameCard.createHand(card)

    local pos = ccp(self.card_uis[cout]:getPositionX() + pai.base_size.width * (4 / 3), 20)
    -- 如果存在拖曳牌
    local box = self.all_cards_boundingBox
    if box and #box > 0 then
        pos = ccp(box[#box].origin.x + pai.base_size.width, 20)
        table.insert(box, CCRectMake(pos.x, 0, pai.base_size.width, CommonInfo.View_Height))
    end
    pai.carddata_index = cout + 1
    pai:setPosition(pos)
    self.operate_cards:addChild(pai, cout + 1, cout + 1)

    local array = CCArray:create()
    array:addObject(CCTargetedAction:create(pai, CCMoveBy:create(0.1, ccp(0, -20))))
    array:addObject(CCCallFunc:create(function()
        --替换牌
        table.insert(self.card_uis, pai)
        if func then
            func()
        end

        self:updataHorizontalPos()
        self:onAnimaEnd()
        checkCards(self, "get new card:"..pai.card_index)

        if TutorialLogic_SGMJ then
            TutorialLogic_SGMJ:check(self, 1)
        end        
        
        SetLogic.playGameEffect(AppConfig.SoundFilePathName.."sendcard_effect"..AppConfig.SoundFileExtName)
    end))
    self:runAction(CCSequence:create(array))
end

--吃碰杠动画
function LayerMyCard:onOperatorAnima(removecard, func)
    --log2File("[[onOperatorAnima]]")
    self.tip_card = nil
    self:sortCard(nil, "LayerMyCard:onOperatorAnima")

    --删除手牌数据
    local Logic = require(CommonInfo.Logic_Path):getInstance()
    local indexs = Logic:removeMineCards(removecard)

    --删除手牌
    local count, lSpace, rSpace = #indexs, 0, 0    --左右移动距离
    for i, v in ipairs(indexs) do
        for m, n in ipairs(self.card_uis) do
            if n.carddata_index == v then
                for p, q in ipairs(self.card_uis) do
                    if q.carddata_index > v then
                        q.carddata_index = q.carddata_index - 1
                    end
                end
                n:removeFromParentAndCleanup(true)
                table.remove(self.card_uis, m)
                break
            end
        end
    end

    local pai = SpriteGameCard.createHand(1)
    local w, cc = pai.base_size.width, #self.card_uis
    local cardWidth, rightOffset = w * (cc+1/3), self:getHandRightOffset()
    if #removecard >= 3 then
        --暗杠
        cardWidth = cardWidth + w
    end

    -- 重新调整牌墙位置
    self.operate_cards:setContentSize(CCSizeMake(cardWidth, pai.base_size.height + 30))
    
    local array = CCArray:create()
    array:addObject(CCMoveTo:create(0.2, ccp(CommonInfo.View_Width - cardWidth - rightOffset, -3)))
    array:addObject(CCCallFunc:create(function() self:updataHorizontalPos() end))
    self.operate_cards:runAction(CCSequence:create(array))

    checkCards(self, "after remove")
end

function LayerMyCard:onGangAnima(downcard, removecard, dirct)
    require(CommonInfo.Logic_Path):getInstance():getLastPlayerPanle():removeCardAnima()

    --添加组合牌
    local uis = self:addGangWeave(downcard, dirct)

    --返回中心点位置
    self:onOperatorAnima(removecard)
	return uis
end

function LayerMyCard:onChiPengAnima(downcard, removecard, dirct, backfunc)
    require(CommonInfo.Logic_Path):getInstance():getLastPlayerPanle():removeCardAnima()

    --添加组合牌 uis 就是碰的三张牌
    local uis,  pos, dirction  = self:addPengWeave(downcard, dirct)

    --返回中心点位置
    self:onOperatorAnima(removecard, function()
        if backfunc then
            backfunc()
        end
        self:moveCardAnima()
    end)

    if TutorialLogic_SGMJ then
        TutorialLogic_SGMJ:check(self, 1)
    end    
    return uis,dirction
end

function LayerMyCard:onAnGangAnima(downcard, removecard)
    --local maxSp = self.card_uis[#self.card_uis]
    --maxSp:setPositionX((maxSp:getPositionX() - maxSp.base_size.width / 3))

    --添加组合牌
    local uis = self:addAnGangWeave(downcard[1])

    --返回中心点位置
    self:onOperatorAnima(removecard)
	return uis
end

function LayerMyCard:onPengGangAnima(card, item)
    self:onAnimaStart()

    --整理手牌
    local count = #self.card_uis
    local cardSp = self.card_uis[count - 1]
    self:sortCard(nil, "LayerMyCard:onPengGangAnima")
    self.card_uis[count]:setPositionX(cardSp:getPositionX() + cardSp.base_size.width * cardSp:getScale())
    
    --添加杠牌
    local spriteCard = self:addGangCard(item)

    local indexs = require(CommonInfo.Logic_Path):getInstance():removeMineCards(card)
    local cindex = indexs[1]
    for k,v in ipairs(self.card_uis) do
        if v.carddata_index == cindex then
            cindex = k
            break
        end
    end
    local space = self.card_uis[cindex].base_size.width * self.card_uis[cindex]:getScale()
    for k,v in ipairs(self.card_uis) do
        if v.carddata_index > self.card_uis[cindex].carddata_index then
            v.carddata_index = v.carddata_index - 1
        end
    end
    self.card_uis[cindex]:removeFromParentAndCleanup(true)
    table.remove(self.card_uis, cindex)

    --移动手牌
    local array  = CCArray:create()
    local movearray = CCArray:create()
    movearray:addObject(CCTargetedAction:create(self, CCDelayTime:create(0.1)))
    
    for i,v in ipairs(self.card_uis) do
        if i >= cindex then
            --牌右侧
            movearray:addObject(CCTargetedAction:create(v, CCMoveBy:create(0.1, ccp(-space, 0))))
        end
    end
    array:addObject(CCSpawn:create(movearray))
    array:addObject(CCCallFunc:create(function()
        self:onAnimaEnd() 
    end))
    self:runAction(CCSequence:create(array)) 
	
	return spriteCard
end

function LayerMyCard:startOperatorTimer()

end

function LayerMyCard:startOutCardTimer()

end

function LayerMyCard:onAnimaStart()
    self.touch_enable = false
    require(CommonInfo.Logic_Path):getInstance():setIfGetSocketData(false) 
end

function LayerMyCard:onAnimaEnd()
    self.touch_enable = true
    require(CommonInfo.Logic_Path):getInstance():setIfGetSocketData(true)    
end

function LayerMyCard.create()
    local layer = LayerMyCard.new()
    layer:init()
    -- layer:test()
    return layer
end

function LayerMyCard.put(super, zindex)
    local layer = LayerMyCard.new()
    super:addChild(layer, zindex)
    layer.layer_zIndex = zindex
    layer.btn_zIndex = zindex + 1

    layer:init()
    return layer
end

 return LayerMyCard