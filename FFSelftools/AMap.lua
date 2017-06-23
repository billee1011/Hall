local json = require("CocosJson")

-- 高德地理信息定位SDK控件
--[[ 调用示例
    -- 定位设置
    AMap:set(5, true)
    -- 启动定位
    AMap:start()
    -- 获取定位数据
    local t = AMap:get()
    if t then
        cclog("经度:%s, 纬度:%s", t.latitude, t.longitude)
    else
        cclog("未获取到定位数据")
    end
    -- 获取定位数据格式化字符串
    cclog(AMap:getStr())
]]

AMap = AMap or {
    timestamp = 0,      -- 定位时间
    latitude  = 0,      -- 经度
    longitude = 0,      -- 纬度
    accuracy  = 0,      -- 精度(米)
    address   = "",     -- 地址
    country   = "",     -- 国家
    province  = "",     -- 省份
    city      = "",     -- 城市
    district  = "",     -- 城区
    street    = "",     -- 街道
    cityCode  = "",     -- 城市编码
    adCode    = "",     -- 地区编码
    AOI       = "",     -- 定位点AOI信息
    
    interval  = 10,     -- 默认10秒更新一次数据, 不推荐该值设置在5以下
    isReGeo   = false,  -- 默认不读取逆地理信息(android平台无影响, iOS平台获取逆地理信息会增加一次请求次数)
}

-- 设置参数 inv:更新频率(秒) isReGeo:是否获取逆地理信息
function AMap:set(inv, isReGeo)
    AMap.interval = inv
    AMap.isReGeo  = isReGeo
end

-- 更新数据
function AMap.update(v)
    if v and #v > 0 then
        local loc = json.decode(v)
        for k, v in pairs(loc) do
            if (type(v) == "number" and v > 0) or 
                (type(v) == "string" and v ~= "") then
                AMap[k] = v
            end
        end
    end
end

-- 开始采集数据
function AMap:start()
    -- 高德地理信息定位SDK控件仅在iOS 1.5/android 150以上框架版本可用
    local platform = CCApplication:sharedApplication():getTargetPlatform()
    local limit = (platform == kTargetIphone or platform == kTargetIpad) and 1.5 or 150
    -- cclog("now:%s limit:%s", CJni:shareJni():getVersionCode(), limit)
    if tonumber(CJni:shareJni():getVersionCode()) > limit then
        local k = ((platform == kTargetIphone or platform == kTargetIpad) and AMap.isReGeo) and 2 or 1
        CJni:shareJni():getLocationInfo(AMap.update, 1)
        if k == 2 then CJni:shareJni():getLocationInfo(AMap.update, 2) end
        cclog("AMap is started...")
        -- 启动轮询
        CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
            local platform = CCApplication:sharedApplication():getTargetPlatform()
            for i = 1, k do CJni:shareJni():getLocationInfo(AMap.update, i) end
        end, AMap.interval, false)
    else
        cclog("Platform is too old, can not start AMap...")
    end
end

-- 得到定位数据
function AMap:get()
    if AMap.latitude > 0 and AMap.longitude > 0 then
        local t = {
            timestamp  = AMap.timestamp,
            latitude   = AMap.latitude,
            longitude  = AMap.longitude,
            accuracy   = AMap.accuracy,
        }
        if AMap.isReGeo and (AMap.address ~= "") then
            t.address  = AMap.address
            t.country  = AMap.country
            t.province = AMap.province
            t.city     = AMap.city
            t.district = AMap.district
            t.street   = AMap.street
            t.cityCode = AMap.cityCode
            t.adCode   = AMap.adCode
            t.AOI      = AMap.AOI
        end
        return t
    end
end

-- 得到定位数据格式化字符串
function AMap:getStr()
    -- cclog("Get Data from AMP :")
    -- for k, v in pairs(AMap) do cclog("%s -> %s", k, tostring(v)) end
    if AMap.longitude > 0 and AMap.latitude > 0 then
        local t = string.format("时间: %d\n经度: %s\n纬度: %s\n精度: %s 米",
            AMap.timestamp,
            AMap.longitude,
            AMap.latitude,
            AMap.accuracy
        )
        if AMap.isReGeo and (AMap.address ~= "") then
            t = string.format("%s\n地址: %s\n国家: %s\n省份: %s\n城市: %s\n城区: %s\n街道: %s\n城市编码: %s\n街区编码: %s\nAOI信息:%s",
                t,
                AMap.address,
                AMap.country,
                AMap.province,
                AMap.city,
                AMap.district,
                AMap.street,
                AMap.cityCode,
                AMap.adCode,
                AMap.AOI
            )
        end
        return t
    else
        return "暂未获取定位信息"
    end
end

-- 计算两个位置点之间的距离(单位: 米, 误差: 5) lon1:点1经度 lat1:点1纬度 lon2:点2经度 lat2:点2纬度 
function AMap:getDist(lon1, lat1, lon2, lat2)
    local PI = 3.1415926535897932
    return math.floor((math.acos(math.sin(lat1/180*PI)*math.sin(lat2/180*PI)+math.cos(lat1/180*PI)*math.cos(lat2/180*PI)*math.cos(lon1/180*PI-lon2/180*PI))*180*60/PI)*100000)/100*1.852
end

return AMap