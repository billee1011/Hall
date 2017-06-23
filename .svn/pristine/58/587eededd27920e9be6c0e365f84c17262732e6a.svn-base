--HallUtils.lua
require("CocosExtern")
local HallUtils = {}
HallUtils.__index = HallUtils
require("Bit")

--ui字符串转换为数据库格式 ctype 1：text装换，2：数据库返回
function HallUtils.textDataStr(text, ctype)
    local changeStr = {{" ", "spc"}, {"\n", "cr"}}
    for i,v in ipairs(changeStr) do
        if ctype == 2 then
            v[1], v[2] = v[2], v[1]
        end
        text = (string.gsub(text,v[1], v[2]))
    end

    return text;
end

--deep copy
function HallUtils.tableDup(ori_tab)
    if (type(ori_tab) ~= "table") then
        return nil;
    end
    local new_tab = {};
    for i,v in pairs(ori_tab) do
        local vtyp = type(v);
        if (vtyp == "table") then
            new_tab[i] = HallUtils.tableDup(v);
        elseif (vtyp == "thread") then 
            new_tab[i] = v;
        elseif (vtyp == "userdata") then
            new_tab[i] = v;
        else
            new_tab[i] = v;
        end
    end
    return new_tab;
end

function HallUtils.table2str(ori_tab,tab)
    tab = tab or ""
    if (type(ori_tab) ~= "table") then
        return nil
    end
    local logstr=  "{"
    local hasMember = false
    for i,v in pairs(ori_tab) do
        hasMember = true
        logstr = logstr .. "\n"    
        if type(i) == "number" then
            logstr = logstr .. "\t"..tab.."["..i.."]".."="
        else
            logstr = logstr .. "\t"..tab..i.."="
        end
        local vtyp = type(v)
        if v == nil then
            logstr = logstr .."[nil]"        
        elseif (vtyp == "table") then
            logstr = logstr .. HallUtils.table2str(v,"\t"..tab)
        elseif (vtyp == "thread") then
            logstr = logstr .."[thread]"
        elseif (vtyp == "userdata") then
            logstr = logstr .."[userdata]"
        elseif (vtyp == "number") then
            logstr = logstr ..v
        elseif (vtyp == "string") then
            logstr = logstr .."\""..v.."\""
        elseif (vtyp == "boolean") then
            logstr = logstr ..(v and "true" or "false")
        else
            logstr = logstr .."[unknow]"        
        end
        logstr = logstr..","
    end
    if hasMember then --去掉最后一个逗号
        logstr = string.sub(logstr,1,-2) 
    end
    logstr=  logstr.."\n"..tab.."}"
    return logstr
end

function HallUtils.string2hex(str)	
    str = string.gsub(str, "0x", "")
    local function parseByte(c)         
        if c >= string.byte('a') then
            return c - string.byte('a') + 10 
        end
    
        if c >= string.byte('A') then
            return c - string.byte('A') + 10
        end    
        return c - string.byte('0')
    end
    

    local len = string.len(str)
    local ba = require("ByteArray").new()
    for i=1,len,2 do
        local b1 = parseByte(string.byte(string.sub(str,i)))
        local b2 = parseByte(string.byte(string.sub(str,i + 1)))
        local b =  b1 * 0x10 + b2
        --cclog("string2hex %x,b1 =%d,b2=%d",b,b1,b2)
        ba:writeByte(b)
    end
    ba:setPos(1)
    return ba:getBuf()
end

function HallUtils.hex2string(hex,len)
    --local str, n = hex:gsub("(%x%x)[ ]?", function(word)    return string.char(tonumber(word, 16)) end)        
    --return str
    local str = ""
    for i=1,len do
        str = string.format("%s%02X",str,string.byte(string.sub(hex,i)))
    end
    return str
end

--判断邮件格式是否正确
function HallUtils.isRightEmail(str)
    if string.len(str or "") < 6 then 
        return false 
    end
    local b,e = string.find(str or "", '@')
    local bstr = ""
    local estr = ""
    if b then
        bstr = string.sub(str, 1, b-1)
        estr = string.sub(str, e+1, -1)
    else
        return false
    end

    -- check the string before '@'
    local p1,p2 = string.find(bstr, "[%w_]+")
    if (p1 ~= 1) or (p2 ~= string.len(bstr)) then return false end

    -- check the string after '@'
    if string.find(estr, "^[%.]+") then return false end
    if string.find(estr, "%.[%.]+") then return false end
    if string.find(estr, "@") then return false end
    if string.find(estr, "[%.]+$") then return false end

    _,count = string.gsub(estr, "%.", "")
    if (count < 1 ) or (count > 3) then
     return false
    end

    return true
 end

--判断是否为手机号码 "^1[3|4|5|7|8]\d{9}$";
function HallUtils.isPhoneNumber(str)
    if string.len(str or "") ~= 11 then 
        return false 
    end

    return string.match(str,"%d+") == str
end

--判断是否为有效昵称 
function HallUtils.isNickName(str)
    return true
end

--判断账户格式是否正确 return string.match(str,"[%d%a]+@%a+.%a+") == str
function HallUtils.isAccount(str)
    local size = string.len(str or "")
    if size < 6 or size > 16 then
        return false
    end

    if not string.match(str,"%a+") then
        return false
    end

    return string.match(str,"%w+") == str
end

--判断密码格式是否正确 return string.match(str,"[%d%a]+@%a+.%a+") == str
function HallUtils.isPassWord(str)
    local size = string.len(str or "")
    if size < 6 or size > 12 then
        return false
    end

    return string.match(str,"%w+") == str
end

function HallUtils.isFileExit(file)
    local downPath = require("Domain").HallFile .. file
    local myPath = "Hall/" .. file

    local FileUtils = require("GameLib/common/FileUtils")
    return FileUtils.exists(downPath) or FileUtils.exists(myPath)
end

--获取字符可用字段
function HallUtils.getLabText(str, text, uilen)
  text:setString("大")
  local bwidth = text:getContentSize().width
  text:setString("1")
  local swidth = text:getContentSize().width
  
  local j, index, ilen = 1, 1, 0
  local strlen = string.len(str)
  while j < strlen do
    index = j
    if 0x80 ~= Bit:_and(0xC0, string.byte(str, j)) then
        if 0x80 == Bit:_and(0xC0, string.byte(str, j + 1)) then
            --为中文
            ilen = ilen + bwidth
            j = j + 2
        else
            --为英文
            ilen = ilen + swidth
        end
    end

    j = j + 1
    if ilen > uilen then
      return string.sub(str, 1, index - 1)
    end
  end

  return str
end

--获取字符包含文字个数
function HallUtils.getTextCount(text)
  local j, count, ilen = 1, 0, 0
  while j <= strlen do
    if 0x80 ~= Bit:_and(0xC0, string.byte(str, j)) then
        count = count + 1
    end

    j = j + 1
  end

  return str
end

--获取时间
function HallUtils.getTime()
    local temp_date = os.date("*t")
    return string.format("%d-%02d-%02d %02d:%02d",temp_date.year,temp_date.month,temp_date.day,temp_date.hour,temp_date.min)
end

function HallUtils.getScoreStr(score)
    local scoreStr = ""..score
    if score > 0 then
        scoreStr = "+"..score
    end

    return scoreStr 
end

function HallUtils.formatGold(gold, remaindot)
    remaindot = remaindot or true
    if (math.abs(gold) < 100000) then       
        local finalstring = string.format("%d", gold)
        return finalstring
    end
    if (math.abs(gold) >= 100000 and math.abs(gold) < 100000000) then
        --大于等于10W的，小于9999W的，整数就不显示小数点，非整数取一位小数（不需要四舍五入）
        if (remaindot == true) then
            local leftNum = gold % 10000
            if (leftNum == 0) then
                local finalstring = string.format(("%d万"), gold / 10000)
                return finalstring
            else
                local finalstring = string.format("%.1f万", gold / 10000.0)
                return finalstring
            end
        end
        local finalstring = string.format("%d万", gold / 10000.0)
        return finalstring
    end
    if (math.abs(gold) >= 100000000 and math.abs(gold) <= 2000000000) then
        --大于等于1亿，且小于20亿
        if (remaindot == true) then
            local leftNum = gold % 100000000
            if (leftNum == 0) then
                local finalstring = string.format("%d亿", gold / 100000000)
                return finalstring
            else
                --cclog("%d,%d,%d",gold,gold/100000000,gold%100000000 / 10000)
                local finalstring = string.format("%d亿%d万", math.floor(gold / 100000000) , math.floor((gold % 100000000) / 10000))
                return finalstring
            end
        else
            local finalstring = string.format("%d亿", math.floor(gold / 100000000.0))
            return finalstring
        end
    end

    if math.abs(gold) <= 100000000000 then
        return string.format("%d亿", math.floor(gold / 100000000))
    end
    --大于1000亿，就是无限
    if (remaindot == true) then
        return "无限"
    else
        return "无限"
    end
end

function HallUtils.guid()
    local seed = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}
    local tb = {}
    for i=1,32 do
        table.insert(tb,seed[math.random(1,16)])
    end
    return table.concat(tb)        
end

function HallUtils.ccpAdd(pos1, pos2)
    return ccp(pos1.x + pos2.x, pos1.y + pos2.y)
end

function HallUtils.drawNodeRoundRect(pItem, borderWidth, radius, color, fillColor)
    local w_ = pItem:getContentSize().width * pItem:getScaleX()
    local h_ = pItem:getContentSize().height * pItem:getScaleY()
    x_ = 0
    y_ = 0    
    local rect = CCRectMake(x_, y_, w_,h_)
    local drawNode = CCDrawNode:create()
    -- segments表示圆角的精细度，值越大越精细
    local segments    = 50
    local origin      = ccp(rect.origin.x, rect.origin.y)
    local destination = ccp(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)
    local points      = {}

    -- 算出1/4圆
    local coef     = math.pi * 2 / segments
    local vertices = {}

    for i=0, segments do
        local rads = (segments - i) * coef
        local x    = radius * math.sin(rads)
        local y    = radius * math.cos(rads)

        table.insert(vertices, ccp(x, y))
    end

    local tagCenter      = ccp(0, 0)
    local minX           = math.min(origin.x, destination.x)
    local maxX           = math.max(origin.x, destination.x)
    local minY           = math.min(origin.y, destination.y)
    local maxY           = math.max(origin.y, destination.y)
    local dwPolygonPtMax = (segments + 1) * 4
    local pPolygonPtArr  = {}

    --cclog("min max = %f,%f,%f,%f",minX,maxX,minY,maxY)

    -- 左上角
    tagCenter.x = minX + radius
    tagCenter.y = maxY - radius

    --cclog("左下角 %f,%f",tagCenter.x,tagCenter.y)

    for i=0, segments do
        local x = tagCenter.x - vertices[i + 1].x
        local y = tagCenter.y + vertices[i + 1].y

        table.insert(pPolygonPtArr, ccp(x, y))
    end

      -- 右上角
    tagCenter.x = maxX - radius
    tagCenter.y = maxY - radius
    --cclog("左上角 %f,%f",tagCenter.x,tagCenter.y)

    for i=0, segments do
        local x = tagCenter.x + vertices[#vertices - i].x
        local y = tagCenter.y + vertices[#vertices - i].y

        table.insert(pPolygonPtArr, ccp(x, y))
    end

      -- 右下角
    tagCenter.x = maxX - radius
    tagCenter.y = minY + radius

    for i=0, segments do
        local x = tagCenter.x + vertices[i + 1].x
        local y = tagCenter.y - vertices[i + 1].y

        table.insert(pPolygonPtArr, ccp(x, y))
    end
    --cclog("右上角 %f,%f",tagCenter.x,tagCenter.y)

      -- 左下角
    tagCenter.x = minX + radius
    tagCenter.y = minY + radius
    --cclog("右下角 %f,%f",tagCenter.x,tagCenter.y)

    local points = CCPointArray:create(segments)
    for i=0, segments do
        local x = tagCenter.x - vertices[#vertices - i].x
        local y = tagCenter.y - vertices[#vertices - i].y        
        points:addControlPoint(ccp(x, y))
    end

    if fillColor == nil then
        fillColor =ccc4f(0, 0, 0, 0)
    end

    drawNode:drawPolygon(points:fetchPoints(), points:count(), fillColor, borderWidth, color)    
    local pCliper = CCClippingNode:create()
    pCliper:setStencil(drawNode)
    pItem:setAnchorPoint(ccp(0.5,0.5))
    pItem:setPosition(ccp(pItem:getContentSize().width * pItem:getScaleX() * 0.5, pItem:getContentSize().height * pItem:getScaleY() * 0.5))
    pCliper:addChild(pItem)
    pCliper:setContentSize(CCSize(w_,h_))
    return pCliper
end

function HallUtils.removeCacheFiles(files)
    local frameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
    local textureCache = CCTextureCache:sharedTextureCache()

    for i,v in ipairs(files) do
        ccprint("removeCacheFiles: %s.plist", v)
        frameCache:removeSpriteFramesFromFile(v..".plist")
        textureCache:removeTextureForKey(v..".pvr.ccz")
    end
end

function HallUtils.isIAippSupport()
    --[[if require("HallControl").isInReview() then
        return false
    end
    if not require("HallControl"):instance():isAppStore() then
        return false
    end
    local partnerID = CJni:shareJni():getPartnerID()
    local versionCode = CJni:shareJni():getVersionCode()
    if partnerID == 11 and versionCode < 227 then  -- 挖坑
        return false
    end
    if partnerID == 1 and versionCode < 326 then  -- zjh
        return false
    end
    if partnerID == 31 and versionCode < 110 then  -- lhb
        return false
    end   
    return true]]
end

function HallUtils.isNoLotery()
    local partnerID = CJni:shareJni():getPartnerID()
    return partnerID == 219 or partnerID == 221
end

--提示信息
function HallUtils.showWebTip(msg, super, ftsz, pos, secs)
    local DialogMessage = require("FFSelftools/MessageLayer").create(msg, ftsz, pos, secs)
    super = super or CCDirector:sharedDirector():getRunningScene()
    super:addChild(DialogMessage)
end


--显示菊花
function HallUtils.showNetWaiting(enable)
    local delay = 1.5
    local AppConfig = require("AppConfig")
    local scene = CCDirector:sharedDirector():getRunningScene()
    if scene then
        if enable then
            if not scene.netWaitingLayer then
                local layer = CCLayerColor:create(AppConfig.COLOR.ColorLayer_Bg)
                layer:setOpacity(0)

                layer:registerScriptTouchHandler(function(eventType, x, y)
                    if eventType == "began" then return true end end, 
                    false, kCCMenuHandlerPriority - 9999, true)
                layer:setTouchEnabled(true)

                local sp =  loadSprite("common/game_progress_img.png")
                sp:setPosition(AppConfig.SCREEN.MID_POS)
                sp:setVisible(false)
                sp:runAction(CCRepeatForever:create(CCRotateBy:create(0.8, -360)))
                layer:addChild(sp)
                layer.sp = sp
                local array = CCArray:create()
                array:addObject(CCDelayTime:create(delay))
                array:addObject(CCCallFuncN:create(function(sender) sender:setOpacity(90) sender.sp:setVisible(true) end))
                layer:runAction(CCSequence:create(array))
                scene:addChild(layer, 9999)
                scene.netWaitingLayer = layer
            end
        else
            if scene.netWaitingLayer then
                scene.netWaitingLayer:removeFromParentAndCleanup(true)
                scene.netWaitingLayer = nil
            end
        end
    end
end

-- 创建Sprite精灵的通用方法
function loadSprite(fileName, isScale9Sprite)
    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName( fileName )
    if isScale9Sprite then
        if frame then
            return CCScale9Sprite:createWithSpriteFrameName( fileName )
        else
            return CCScale9Sprite:create( fileName )
        end
    else
        if frame then
            return CCSprite:createWithSpriteFrameName( fileName )
        else
            return CCSprite:create( fileName )
        end
    end
end

function class(classname, super)
    local superType = type(super)
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            for k,v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
            cls.ctor = function() end
        end

        cls.__cname = classname
        cls.__ctype = 1

        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k,v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:ctor(...)
            return instance
        end

    else
        -- inherited from Lua Object
        if super then
            cls = {}
            setmetatable(cls, {__index = super})
            cls.super = super
        else
            cls = {ctor = function() end}
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls

        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end

    return cls
end

function handler(obj, method)
    return function(...)
        return method(obj, ...)
    end
end

return HallUtils
