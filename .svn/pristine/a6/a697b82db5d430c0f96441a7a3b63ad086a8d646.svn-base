--LayerUser.lua
local LayerUser=class("LayerUser",function()
        return CCLayer:create()
    end)

local AppConfig = require("AppConfig")

function LayerUser:init(info, func, addfunc) 
    local CCButton = require("FFSelftools/CCButton")
    local CCCheckbox = require("FFSelftools/CCCheckbox")
    local HallUtils = require("HallUtils")

    self:setContentSize(CCSizeMake(300, 100))

    --个人头像背景
    local pos = ccp(55, 45)
    local faceBg = putControltools(self, createButtonWithFrameName(
        "common/user_face_bg_small.png","common/user_face_bg_small.png","common/user_face_bg_small.png", 0, function()
        func() end), pos, self.layer_zIndex)
    local sz = faceBg:getContentSize()
    
    local faceSp = require("FFSelftools/CCUserFace").create(info.UserID, CCSizeMake(98,98), info.Sex)
    faceSp:setPosition(ccp(sz.width / 2, sz.height / 2))
    faceBg:addChild(faceSp, -1)

    --性别     
    local spriteOK = loadSprite("common/sex_man.png")
    local spriteNO = loadSprite("common/sex_woman.png")
    self.sex_check = CCCheckbox.create(spriteOK, spriteNO, true, true)
    self.sex_check:setScale(0.8)
    local sexpos = ccp(sz.width - 15, 14)
    self.sex_check:setPosition(sexpos)
    self.sex_check:setEnabled(false)
    self.sex_check:setChecked(info.Sex ~= 1)
    faceBg:addChild(self.sex_check)

    --昵称
    self.name_lab = CCLabelTTF:create(info.NewNickName, AppConfig.COLOR.FONT_BLACK, 26)
    self.name_lab:setHorizontalAlignment(kCCTextAlignmentLeft)
    self.name_lab:setAnchorPoint(ccp(0,0.5))
    local namepos = HallUtils.ccpAdd(pos, ccp(sz.width / 2 + 10, 30))
    self.name_lab:setPosition(namepos)
    self.name_lab:setColor(ccc3(0x41, 0x39, 0x32))
    self:addChild(self.name_lab)

    --ID
    local idlab = CCLabelTTF:create("ID:"..info.UserID, AppConfig.COLOR.FONT_BLACK, 26)
    idlab:setHorizontalAlignment(kCCTextAlignmentLeft)
    idlab:setAnchorPoint(ccp(0,0.5))
    idlab:setPosition(HallUtils.ccpAdd(pos, ccp(sz.width / 2 + 10, -30)))
    idlab:setColor(ccc3(0x41, 0x39, 0x32))
    self:addChild(idlab)

    --钻石
    self.diamond_lab = self:createNumberUI("common/diamond.png", 
                    info.DiamondAmount, HallUtils.ccpAdd(namepos, ccp(290, 3)), addfunc)

    --[[
    --金币
    self.gold_lab = self:createNumberUI("common/gold.png", 
                    info.Money, HallUtils.ccpAdd(namepos, ccp(525, 3)), addfunc)
    --self:addDiamondUI(info.DiamondAmount, ccp(270, 40), addfunc)

    if AppConfig.ISAPPLE then
        self.gold_lab:getParent():setVisible(false)
    end
    ]]
end

function LayerUser:createNumberUI(markImg, num, pos, func) 
    local boxBg = loadSprite("lobby/diamondBg.png")
    boxBg:setPosition(pos)
    self:addChild(boxBg)
    local sz = boxBg:getContentSize()

    --标示
    local shineDealy = 0
    local mark = loadSprite(markImg)
    mark:setAnchorPoint(ccp(0, 0.5))
    mark:setPosition(ccp(-30, sz.height / 2))
    boxBg:addChild(mark)
    
    --闪光效果
    local shine = loadSprite("lobby/starLight.png")
    shine:setScale(0.001)
    shine:setOpacity(0)
    mark:addChild(shine)
    mark.shine = shine
    
    local array, array2 = CCArray:create(), CCArray:create()
    -- 闪光位置列表
    if markImg == "common/diamond.png" then
        mark.sz = {ccp(10,38), ccp(41,36), ccp(36,16)}
        array:addObject(CCCallFuncN:create(function(sender)
            local p = sender:getParent()
            sender:setScale(0.001)
            sender:setOpacity(255)
            sender:setPosition(p.sz[math.random(#p.sz)])
        end))
        array:addObject(CCRotateBy:create(6,math.random(270)+90))
        array:addObject(CCDelayTime:create(6))
        shine:runAction(CCRepeatForever:create(CCSequence:create(array)))
        array2:addObject(CCScaleTo:create(2,2))
        array2:addObject(CCDelayTime:create(2))
        array2:addObject(CCFadeOut:create(2))
        array2:addObject(CCDelayTime:create(6))
        shine:runAction(CCRepeatForever:create(CCSequence:create(array2)))
    else
        mark.sz = {ccp(15,42), ccp(44,27), ccp(40,42)}
        array:addObject(CCDelayTime:create(6))
        array:addObject(CCCallFuncN:create(function(sender)
            local p = sender:getParent()
            sender:setScale(0.001)
            sender:setOpacity(255)
            sender:setPosition(p.sz[math.random(#p.sz)])
        end))
        array:addObject(CCRotateBy:create(6,math.random(180)+180))
        shine:runAction(CCRepeatForever:create(CCSequence:create(array)))
        array2:addObject(CCDelayTime:create(6))
        array2:addObject(CCScaleTo:create(2,1.5))
        array2:addObject(CCDelayTime:create(2))
        array2:addObject(CCFadeOut:create(2))
        shine:runAction(CCRepeatForever:create(CCSequence:create(array2)))
    end
    

    local CCButton = require("FFSelftools/CCButton")
    --按钮
    local btnItem = CCButton.put(boxBg, CCButton.createCCButtonByFrameName("common/add.png", 
                "common/add.png", "common/add.png", function()
                func()
            end), ccp(sz.width + 30, sz.height / 2), self.layer_zIndex)
    btnItem:setAnchorPoint(ccp(1, 0.5))
    
    local labelNum = require("Lobby/Info/LayerMoneyBox"):create(CCSizeMake(sz.width, sz.height-7), num)
    labelNum:setPosition(ccp(0, (sz.height-labelNum.letterHeight)/2))
    boxBg:addChild(labelNum)

    return labelNum, boxBg
end

function LayerUser:updataDiamond(num)
    self.diamond_lab:setValue(num)
end

function LayerUser:updataGold(num)
    self.gold_lab:setValue(num)
end

function LayerUser.put(info, super, zindex, func, addfunc)
    local layer = LayerUser.new()
    super:addChild(layer, zindex)
    layer.layer_zIndex = zindex

    layer:init(info, func, addfunc)
    return layer
end

 return LayerUser