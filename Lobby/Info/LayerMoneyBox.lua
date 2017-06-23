-- LayerMoneyBox.lua
-- 目前最大支持到6位数(策划确认16/11/04)
local AppConfig = require("AppConfig")

local LayerMoneyBox=class("LayerMoneyBox",function(sz)
        return CCScrollView:create(sz)
    end)

function LayerMoneyBox:init(sz, num)
    self.sz = sz
    self.rollInterval = 0.2
    self:setDirection(kCCScrollViewDirectionNone)
    self:setAnchorPoint(ccp(0, 0))
    -- 数字标签
    self.targetNum, self.currentNum = num, num
    self.letterStart, self.letterList = 0, {}
    self.letterWidth, self.letterHeight = 18, 24
    local list, left = self:n2s(num), self.letterStart
    for k, v in ipairs(list) do
        local letter = CCLabelAtlas:create(
            v, AppConfig.ImgFilePath.."num_money.png",
            34,43,string.byte('0'))
        letter.value = v
        table.insert(self.letterList, letter)
        letter:setAnchorPoint(ccp(0,0))
        letter:setPosition(ccp(left, 0))
        letter:setScale(0.56)
        left = left + self.letterWidth
        self:addChild(letter)
    end
    -- 检测轮训
    local array = CCArray:create()
    array:addObject(CCCallFuncN:create(updataNumByRollup))
    array:addObject(CCDelayTime:create(self.rollInterval))
    self:runAction(CCRepeatForever:create(CCSequence:create(array)))
    
    return self
end

function LayerMoneyBox:setValue(num)
    if type(num) == "number" then self.targetNum = num end
end

function LayerMoneyBox:create(sz, num)
    if type(num) == "number" then
        local item = LayerMoneyBox.new(sz)
        item:init(sz, num)
        return item
    else
        return CCLayer:create()
    end
end

function LayerMoneyBox:n2s(num)
    local numStr, t = tostring(num), {}
    local s = #numStr
    for i = 1, s do table.insert(t, string.sub(numStr, i, i)) end
    for i = s, 6 do table.insert(t, 1, "") end -- 不足6位补足
    return t
end

function updataNumByRollup(sender)
    if sender.targetNum == sender.currentNum then return end
    local step, tempNum = 1, sender.currentNum
    if sender.targetNum < sender.currentNum then step = -1 end
    local l1, l2 = sender:n2s(sender.targetNum), sender:n2s(tempNum)
    -- 计算本次滚动的中间值
    for k, v in ipairs(l1) do
        l1[k] = (l1[k] == "") and 0 or tonumber(l1[k])
        l2[k] = (l2[k] == "") and 0 or tonumber(l2[k])
        if l2[k] > l1[k] then
            l2[k] = tostring(l2[k] - 1)
        elseif l2[k] < l1[k] then
            l2[k] = tostring(l2[k] + 1)
        end
    end
    tempNum = tonumber(table.concat(l2))
    sender.currentNum = tempNum
    -- 创建标签及动作
    local list = sender:n2s(tempNum)
    for k, v in ipairs(sender.letterList) do
        if v.value ~= list[k] then
            v:runAction(CCSequence:createWithTwoActions(
                CCMoveBy:create(sender.rollInterval, ccp(0, step*sender.sz.height)),
                CCCallFuncN:create(function(sender) sender:removeFromParentAndCleanup(true) end)
            ))
            local letter = CCLabelAtlas:create(
            list[k], AppConfig.ImgFilePath.."num_money.png",
            34,43,string.byte('0'))
            letter.value = list[k]
            letter:setScale(0.56)
            letter:setPosition(ccp((k-1)*sender.letterWidth+sender.letterStart, -step*sender.sz.height))
            letter:runAction(CCMoveBy:create(sender.rollInterval, ccp(0, step*sender.sz.height)))
            sender:addChild(letter)
            sender.letterList[k] = letter
        end
    end
end

 return LayerMoneyBox