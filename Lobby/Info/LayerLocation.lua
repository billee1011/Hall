--LayerLocation.lua
require("FFSelftools/AMap")
local AppConfig = require("AppConfig")
local HallUtils = require("HallUtils")
local CCButton = require("FFSelftools/CCButton")

local LayerLocation=class("LayerLocation",function(super, zindex)
    return require("Lobby/LayerPopup").put(super, zindex)
end)

-- 创建界面
function LayerLocation:init(typ)
    self.btn_zIndex = self.layer_zIndex + 1

    self.bgsz = CCSizeMake(920, 640)
    self:addFrameBg("common/popBg.png", self.bgsz)
    self.panel_bg:setPositionY(self.panel_bg:getPositionY() - 20)

    --背景
    self.panel_bg.bg = loadSprite("location/bg.jpg")
    self.panel_bg.bg:setPosition(ccp(460, 370))
    self.panel_bg:addChild(self.panel_bg.bg)
    
    if AppConfig.ISAPPLE then
        local headSp = loadSprite("location/point_other.png")
        headSp:setPosition(ccp(460,450))
        self.panel_bg:addChild(headSp)
        local t, s = "中国地区以外", 0
        if AMap.isReGeo and (AMap.address ~= "") then
            t = string.format("您当前位置:%s\n%s %s", AMap.country, AMap.province, AMap.city)
            s = math.random(1,6)
        end
        local txtHead = CCLabelTTF:create(t, AppConfig.COLOR.FONT_ARIAL, 18)
        txtHead:setAnchorPoint(ccp(0.5, 0))
        txtHead:setColor(ccc3(0, 0, 0))
        txtHead:setPosition(ccp(460, 350))
        self.panel_bg:addChild(txtHead)
            -- 说明
        t = "您所在城市当前有 %d 位玩家在线\n注:定位功能是为玩家在娱乐的同时更好的交友，\n定位结果可能有些偏差，不保证百分百准确，仅做参考"
        local txtDesc = CCLabelTTF:create(string.format(t, s), AppConfig.COLOR.FONT_ARIAL, 18)
        txtDesc:setColor(ccc3(255, 0, 0))
        txtDesc:setPosition(ccp(460, 250))
        self.panel_bg:addChild(txtDesc)
    else
        local headPos = (typ == 3) and {ccp(460, 500), ccp(725, 250), ccp(195,250)} or {ccp(200, 500), ccp(720, 500), ccp(720, 215), ccp(200, 215)}
        local headTxtPos = (typ == 3) and {ccp(460, 540), ccp(725, 210), ccp(195,210)} or {ccp(200, 540), ccp(720, 540), ccp(720, 175), ccp(200, 175)}
        local linePos = (typ == 3) and {ccp(592.5,375), ccp(327.5, 375), ccp(460, 235)} or {ccp(460, 485), ccp(690, 342.5), ccp(460, 200), ccp(230, 342.5), ccp(460, 342.5), ccp(460, 342.5)}
        local lineTxtPos = (typ == 3) and {ccp(80,0), ccp(-80, 0), ccp(0, -30)} or {ccp(0, 30), ccp(80, 0), ccp(0, -30), ccp(-80, 0), ccp(-100, 80), ccp(-145, -65)}
        
        self.headSp, self.headTxt, self.lineSp, self.lineTxt = {}, {}, {}, {}
        -- 创建头像
        for k, v in ipairs(headPos) do
            local headSp = loadSprite("location/point_other.png")
            headSp:setPosition(v)
            self.panel_bg:addChild(headSp)
            self.headSp[k] = headSp
            local txtHead = CCLabelTTF:create("", AppConfig.COLOR.FONT_ARIAL, 18)
            txtHead:setColor(ccc3(0, 0, 0))
            txtHead:setPosition(headTxtPos[k])
            self.panel_bg:addChild(txtHead)
            self.headTxt[k] = txtHead
        end
        -- 创建线条
        if typ == 3 then
            for i = 1, typ do
                local lineSp = (i == 3) and 
                    loadSprite("location/line_horizontal.png") or loadSprite("location/line_diagonal3.png")
                lineSp:setPosition(linePos[i])
                lineSp:setColor(ccc3(10,175,55))
                if i == 2 then lineSp:setFlipX(true) end
                self.panel_bg:addChild(lineSp)
                self.lineSp[i] = lineSp
                local txtLine = CCLabelTTF:create("", AppConfig.COLOR.FONT_ARIAL, 24)
                if i == 1 then
                    txtLine:setHorizontalAlignment(kCCTextAlignmentLeft)
                elseif i == 2 then
                    txtLine:setHorizontalAlignment(kCCTextAlignmentRight)
                end
                txtLine:setColor(ccc3(0, 0, 0))
                txtLine:setPosition(HallUtils.ccpAdd(lineTxtPos[i], linePos[i]))
                self.panel_bg:addChild(txtLine)
                self.lineTxt[i] = txtLine
            end
        elseif typ == 4 then
            for i = 1, typ + 2 do
                local lineSp = (i%2 ==0) and 
                    loadSprite("location/line_vertical.png") or loadSprite("location/line_horizontal.png")
                if i > 4 then lineSp = loadSprite("location/line_diagonal4.png") end
                if i > 5 then lineSp:setFlipX(true) end
                lineSp:setPosition(linePos[i])
                lineSp:setColor(ccc3(10,175,55))
                self.panel_bg:addChild(lineSp)
                self.lineSp[i] = lineSp
                local txtLine = CCLabelTTF:create("", AppConfig.COLOR.FONT_ARIAL, 24)
                if i == 2 then
                    txtLine:setHorizontalAlignment(kCCTextAlignmentLeft)
                elseif i == 4 then
                    txtLine:setHorizontalAlignment(kCCTextAlignmentRight)
                elseif i == 5 then
                    txtLine:setRotation(31)
                elseif i == 6 then
                    txtLine:setRotation(-31)
                end
                txtLine:setColor(ccc3(0, 0, 0))
                txtLine:setPosition(HallUtils.ccpAdd(lineTxtPos[i], linePos[i]))
                self.panel_bg:addChild(txtLine)
                self.lineTxt[i] = txtLine
            end
        end
        
        -- 图例
        local spLegend = loadSprite("location/legend_red.png")
        spLegend:setPosition(ccp(755, 580))
        self.panel_bg:addChild(spLegend)
        local txtLegend = CCLabelTTF:create("小于100米", AppConfig.COLOR.FONT_ARIAL, 16)
        txtLegend:setColor(ccc3(0, 0, 0))
        txtLegend:setPosition(ccp(820, 580))
        self.panel_bg:addChild(txtLegend)
        
        -- 说明
        local txtDesc = CCLabelTTF:create([[为了玩家在娱乐的同时更好的交友特加入定位功能
    注:1. 定位功能可能有些偏差，不保证百分百准确，仅做参考
    　 2. 玩家在楼上楼下等特殊情况可能无法准确显示实际距离
    ]]
    , AppConfig.COLOR.FONT_ARIAL, 18)
        txtDesc:setColor(ccc3(255, 0, 0))
        txtDesc:setPosition(ccp(460, 65))
        self.panel_bg:addChild(txtDesc)
    end
end

-- 更新数据
function LayerLocation:update(typ, userlist, myChair)
    if not AppConfig.ISAPPLE then
        --[[
        print("myChair", myChair)
        for k, v in pairs(userlist) do
            print("======= user [%s] %s =====================", v._chairID, v._name)
            for m, n in pairs(v) do
                print(m, tostring(n))
            end
            print("==========================================")
        end
        ]]
        
        local idx = (typ == 3) and {
            [12] = 1, [13] = 2, [21] = 1, [23] = 3, [31] = 2, [32] = 3
        } or {
            [12] = 1, [13] = 5, [14] = 4, [21] = 1, [23] = 2, [24] = 6,
            [31] = 5, [32] = 2, [34] = 3, [41] = 4, [42] = 6, [43] = 3,
        }
        for i = 1, typ do
            local usr = userlist[i]
            if usr then
                -- 更新头像
                local c = CCSpriteFrameCache:sharedSpriteFrameCache()
                if usr._chairID == myChair then
                    self.headSp[i]:setDisplayFrame(c:spriteFrameByName("location/point_mine.png"))
                else
                    self.headSp[i]:setDisplayFrame(c:spriteFrameByName("location/point_other.png"))
                end
                self.headTxt[i]:setString(string.format("%s(%s)", usr._name, usr._userIP))
                for j = 1, typ do
                    local nUsr = userlist[j]
                    -- 更新距离
                    if j ~= i and nUsr then
                        local k = idx[i*10+j]
                        if usr._longitude ~= 0 and usr._latitude ~= 0 and
                            nUsr._longitude ~= 0 and nUsr._latitude ~= 0 then
                            local dis = AMap:getDist(usr._longitude, usr._latitude, nUsr._longitude, nUsr._latitude)
                            if dis <= 100 then
                                self.lineSp[k]:setColor(ccc3(255, 36, 36))
                            else
                                self.lineSp[k]:setColor(ccc3(10,175,55))
                            end
                            self.lineTxt[k]:setString(self:formatDistance(dis))
                        else
                            self.lineSp[k]:setColor(ccc3(10,175,55))
                            self.lineTxt[k]:setString("未获取定位")
                        end
                    end
                end
            end
        end
    end
end


-- 格式化距离
function LayerLocation:formatDistance(num)
    if num > 10000000 then
        return string.format("约%s万公里", tostring(math.floor(num/1000000)/10))
    elseif num > 10000 then
        return string.format("约%s公里", tostring(math.floor(num/100)/10))
    else
        return string.format("约%s米", tostring(math.floor(num)))
    end
end


function LayerLocation.put(super, zindex, typ, userlist, myChair)
    local layer = LayerLocation.new(super, zindex)
    layer:init(typ)
    layer:update(typ, userlist, myChair)
    return layer
end

return LayerLocation