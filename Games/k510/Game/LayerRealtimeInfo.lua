--LayerRealtimeInfo.lua
local json  = require("CocosJson")
local AppConfig = require("AppConfig")

local LayerRealtimeInfo=class("LayerRealtimeInfo",function()
        return CCLayer:create()
    end)

function LayerRealtimeInfo:init()
    self.timeTxt = CCLabelTTF:create(os.date("%H:%M", os.time()), "Arial", 24)
    self:addChild(self.timeTxt)
    self.batteryBorder = loadSprite("common/batteryBorder.png")
    self.batteryBorder:setPosition(ccp(66,1))
    self:addChild(self.batteryBorder)
    self.batteryLev = loadSprite("common/batteryLev.png")
    self.batteryLev:setAnchorPoint(ccp(1,0.5))
    self.batteryLev:setPosition(ccp(84,1))
    self:addChild(self.batteryLev)
    self.signal = loadSprite("common/wifi4.png")
    self.signal:setPosition(ccp(120,1))
    self:addChild(self.signal)
    -- 2秒刷新一次
    local interval = 2
    local array = CCArray:create()
    array:addObject(CCDelayTime:create(interval))
    array:addObject(CCCallFuncN:create(LayerRealtimeInfo.refresh)) 
    self:runAction(CCRepeatForever:create(CCSequence:create(array)))
end

function LayerRealtimeInfo.refresh(self)
    if CJni:shareJni():isNetworkAvailable() then
        self.timeTxt:setString(os.date("%H:%M", os.time()))
        self.signal:setVisible(true)
    else
        self.timeTxt:setString(os.date("%H:%M", os.time()).."  无网络")
        self.signal:setVisible(false)
    end
    local infoString = CJni:shareJni():getRealTimeInfo()
    if infoString and infoString ~= "" then
        local info = json.decode(infoString)
        if info.BatteryLev then
            local t = math.abs(info.BatteryLev)
            self.batteryLev:setScaleX(t/100)
            -- 信号
            local signalLev, img = 1, "wifi"
            if info.WiFiConnected then
                if AppConfig.ISIOS then
                    signalLev = math.abs(info.WiFiRssi) + 1
                else
                    if info.WiFiRssi <= -110 then
                        signalLev = 1
                    elseif info.WiFiRssi >= -50 then
                        signalLev = 4
                    else
                        signalLev = math.floor((info.WiFiRssi + 110)/38)+1
                    end
                end
                if signalLev > 4 then signalLev = 4 end
            else
                img = "mobile"
                if AppConfig.ISIOS then
                    signalLev = math.abs(info.MobileLev) + 1
                else
                    if info.MobileLev <= -110 then
                        signalLev = 1
                    elseif info.MobileLev >= -60 then
                        signalLev = 5
                    else
                        signalLev = math.floor((info.MobileLev + 110)/10)+1
                    end
                end
                if signalLev > 5 then signalLev = 5 end
            end
            self.signal:setDisplayFrame(
                CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(
                string.format("common/%s%d.png", img, signalLev)))
        end
    end
end

function LayerRealtimeInfo.create()
    local layer = LayerRealtimeInfo.new()
    layer:init()
    return layer
end


return LayerRealtimeInfo