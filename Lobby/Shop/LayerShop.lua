--LayerShop.lua
local AppConfig = require("AppConfig")
local LoginLogic = require("Lobby/Login/LoginLogic")
local WebRequest = require("GameLib/common/WebRequest")
local json = require("CocosJson")
local CCButton = require("FFSelftools/CCButton")

local LayerShop=class("LayerShop",function()
        return CCLayerColor:create(AppConfig.COLOR.ColorLayer_Bg)
    end)

function LayerShop:hide() 
    require("Lobby/Common/AnimationUtil").spriteScaleHideAction(self.panel_bg, function()
        self:setVisible(false)
        self:setTouchEnabled(false)
        self.closeHandler()
    end, 1)
end

function LayerShop:show()
    self:setVisible(true)
    require("Lobby/Common/AnimationUtil").spriteScaleShowAction(self.panel_bg, function()
        self:setTouchEnabled(true)
    end, 1)
    return self    
end

--爱贝支付回调
function iapppayCallPayBack(result, sign, info)
    cclog(string.format("[IAPPPAY.onPayResult] %s  %s  %s", result, sign, info))
    local AppConfig = require("AppConfig")
    require("HallUtils").showWebTip(AppConfig.iapppay_result[result])
    if result == 0 then layerShop:hide() end
    layerShop:setEnable(true)
end

--苹果支付回调
function appStoreCallPayBack(szRecieptLen, szReciept)
    local udbid = LoginLogic.UserInfo.UserID
    if (szRecieptLen and szReciept) and szRecieptLen > 0 then
        local szData = string.format("userDBID=%d&szbtReceipt=%s",udbid, WebRequest.encodeURI(szReciept))
        WebRequest.getPayData(function(isSucceed,tag,data)
            if(not isSucceed) then
                require("HallUtils").showWebTip("购买凭证验证失败")
                return
            else
                layerShop:hide()
            end    
        end, "AppleVerify.aspx", szData)
    end
    layerShop:setEnable(true)
end

function LayerShop.buy(event, sender)
    if AppConfig.ISWIN32 then
        require("HallUtils").showWebTip("当前设备系统无法进行支付")
        return
    end
    
    -- ios支付
    if AppConfig.ISAPPLE then
        layerShop:setEnable(false)
        require("HallUtils").showWebTip("正在准备支付, 请稍候...")
        CJni:shareJni():sendPayCommand(0, 0, sender.ProductID, "", 0, 0, appStoreCallPayBack)
        return
    end
    
    local udbid = LoginLogic.UserInfo.UserID
    local platform = AppConfig.ISIOS and 1 or 2
    local szData = string.format("UserID=%d&GameID=%d&Price=%d&ProductID=%s&OSType=%d",
        udbid, 0, sender.RMBMoney, sender.ProductID, platform)
    layerShop.ProductID   = sender.ProductID
    layerShop.ProductName = sender.ProductName
    layerShop.RMBMoney    = sender.RMBMoney
    
    cclog("LayerShop.buy: "..szData)
    require("HallUtils").showWebTip("正在生成订单, 请稍候...")
    layerShop:setEnable(false)
    WebRequest.getPayData(function(isSucceed,tag,data)
        local udbid = require("Lobby/Login/LoginLogic").UserInfo.UserID
        if isSucceed and data then
            local t = json.decode(data)
            if t.orderid and tonumber(t.orderid) > 0 then
                cclog("Start pay for orderid: "..t.orderid)
                -- 爱贝支付
                -- IAPPPAY:callPay(
                --     tonumber(layerShop.ProductID), tostring(t.orderid), layerShop.RMBMoney/100,
                --     layerShop.ProductName, tostring(udbid), iapppayCallPayBack)
                
                -- 微信支付
                layerShop:setEnable(true)
                CJni:shareJni():payByWx(tostring(t.orderid), layerShop.ProductName, tostring(layerShop.RMBMoney))
                    
                layerShop.ProductID = nil
                layerShop.RMBMoney = nil
                return
            end
        end
        layerShop:setEnable(true)
        require("HallUtils").showWebTip(AppConfig.TIPTEXT.Tip_GetPayOrder_failed)
    end, "wxGenOrder.aspx", szData)
end

function LayerShop:init()
    self:setVisible(false)
    self.bgSize = CCSizeMake(1236, 590)
    self.btns = {}
    
    local screenMidx = AppConfig.SCREEN.CONFIG_WIDTH/ 2
    local screenMidy = AppConfig.SCREEN.CONFIG_HEIGHT/ 2 - 30
    local path, z = AppConfig.ImgFilePath, kCCMenuHandlerPriority - self.layer_zIndex - 1
    
    -- 背景框
    self.panel_bg = CCLayer:create()
    self:addChild(self.panel_bg)
    self.bg = loadSprite("common/popBg.png", true)
    self.bg:setPreferredSize(self.bgSize)
    self.bg:setPosition(ccp(screenMidx, screenMidy))
    self.panel_bg:addChild(self.bg)
    
    -- 标题
    self.title =  loadSprite("lobbyDlg/title_shop.png")
    self.title:setPosition(ccp(self.bgSize.width / 2, self.bgSize.height + 30))
    self.bg:addChild(self.title)
    
    -- 关闭按钮
    local btn_close = CCControlButton:create(loadSprite("common/btnClose.png", true))
    btn_close:setBackgroundSpriteForState(loadSprite("common/btnClose2.png", true), CCControlStateHighlighted)
    btn_close:setPreferredSize(CCSizeMake(69,70))
    btn_close:setPosition(ccp(self.bgSize.width - 10, self.bgSize.height - 10))
    btn_close:setTouchPriority(z)
    btn_close:addHandleOfControlEvent(function(sender)
        require("Lobby/Set/SetLogic").playGameEffect(AppConfig.SoundFilePathName.."button_effect"..AppConfig.SoundFileExtName)
        self:hide()
    end, CCControlEventTouchUpInside)
    self.btn_close = btn_close
    self.bg:addChild(self.btn_close)

    -- 注册事件
    self:registerScriptTouchHandler(function(eventType, x, y)
        if eventType == "began" then
            return true
        end
    end, false, kCCMenuHandlerPriority - self.layer_zIndex, true)

    self.tip_panel = require("Lobby/LayerPopup").createTipBtn("读取商城信息失败，", function()
        self:initWebData(z) end, z, self)    

    self:initWebData(z)
end

function LayerShop:initWebData(z)
    self.tip_panel:setVisible(false)

    local platform = AppConfig.ISIOS and 1 or 2
    local szData = string.format("PartnerID=%d&OSType=%d&AppID=%s&UserID=%d", 0, platform, AppConfig.CONFINFO.AppName, LoginLogic.UserInfo.UserID)
    WebRequest.getData(function(isSucceed,tag,data)
        --解析数据
        -- cclog("resp: %s", data)
        local isvilad, code, msg, table = WebRequest.parseData(isSucceed, data)
        if isvilad then
            if code == 0 then 
                self.tip_panel:removeFromParentAndCleanup(true)

                self.shoplist = table

                --创建商城列表
                local tgcode = ""..LoginLogic.UserInfo.TGCode
                local tableView =  require("Lobby/Common/LobbyTableView").createCommonTable(
                    CCSizeMake(self.bgSize.width - 80, 420), ccp(40, 70), z)
                    :setCellSizeFunc(function(t, idx) return 400, 260 end)
                    :setNumberOfCellsFunc(function() return #self.shoplist end)
                    :setCreateCellFunc((function(idx) 
                        local index = idx + 1
                        local buydata = self.shoplist[index]

                        --背景
                        local item 
                        item = CCButton.createCCButtonByFrameName("lobbyDlg/border.png","lobbyDlg/border.png", 
                            "lobbyDlg/border.png", function() LayerShop.buy(nil, item) end)
                        item.ProductID   = buydata.ProductID
                        item.ProductName = buydata.ProductName
                        item.RMBMoney    = buydata.RMBMoney
                        local bgsz = item.m_normalSp:getContentSize()
                        item:setPosition(ccp(bgsz.width / 2, bgsz.height / 2 - 12))
                        item:resetTouchPriorty(z, false)
                        item.m_spPress:setScale(1.05)

                        --钻石数量
                        local goldlab = CCLabelTTF:create(tostring(buydata.GoldMoney).."钻石", AppConfig.COLOR.FONT_ARIAL_BOLD, 35)
                        goldlab:setPosition(ccp(0, bgsz.height / 2 - 40))
                        item:addChild(goldlab)

                        --钻石标识
                        cclog("钻石标识："..buydata.RMBMoney)
                        local markIndex = 6
                        if buydata.RMBMoney < 1000 then
                            markIndex = 1
                        elseif buydata.RMBMoney < 2000 then
                            markIndex = 2
                        elseif buydata.RMBMoney < 6000 then
                            markIndex = 3   
                        elseif buydata.RMBMoney < 10000 then
                            markIndex = 4       
                        elseif buydata.RMBMoney < 60000 then
                            markIndex = 5                                        
                        end
                        local goldMark = loadSprite(string.format("lobbyDlg/diamond%s.png", markIndex))
                        goldMark:setPosition(ccp(0, 15))
                        item:addChild(goldMark)

                        --支付按钮
                        local buyBtn = putControltools(item, createButtonWithFilePath("lobbyDlg/buybg.png", 0, function() end), 
                            ccp(0, 50-bgsz.height / 2), self.layer_zIndex + 1) 
                        local rmblab = CCLabelTTF:create(tostring(buydata.RMBMoney / 100).."元", AppConfig.COLOR.FONT_ARIAL_BOLD, 40)
                        rmblab:setPosition(ccp(80, 35))
                        rmblab:setColor(ccc3(0x84, 0x2c, 0x0d))
                        buyBtn:addChild(rmblab)  

                        buyBtn.ProductID   = buydata.ProductID
                        buyBtn.ProductName = buydata.ProductName
                        buyBtn.RMBMoney    = buydata.RMBMoney
                        buyBtn:addHandleOfControlEvent(LayerShop.buy, CCControlEventTouchUpInside)

                        --添加标识
                        if Bit:_and(1, buydata.IsCommend) ~= 0 then
                            --热销
                            local spSale = loadSprite("lobbyDlg/hot.png")
                            spSale:setPosition(ccp(bgsz.width / 2 - 42,bgsz.height / 2 - 39))
                            item:addChild(spSale)
                        end

                        if Bit:_and(2, buydata.IsCommend) ~= 0 then
                            --推荐
                            local spSale = loadSprite("lobbyDlg/jian.png")
                            spSale:setPosition(ccp(30 - bgsz.width / 2, bgsz.height / 2 - 105))
                            item:addChild(spSale)                
                        end

                        if tgcode ~= "66666" then
                            --额外赠送
                            local labBg = loadSprite("lobbyDlg/buytip.png")
                            labBg:setPosition(ccp(10, 130 - bgsz.height / 2))
                            item:addChild(labBg) 

                            local bigLab = CCLabelTTF:create("多赠送"..tostring(buydata.GiveRatio).."%", AppConfig.COLOR.FONT_ARIAL_BOLD, 30)
                            bigLab:setPosition(ccp(85, 35))
                            labBg:addChild(bigLab) 

                            local smallLab = CCLabelTTF:create("即送"..tostring(buydata.GiveAmount).."个钻石", AppConfig.COLOR.FONT_ARIAL_BOLD, 16)
                            smallLab:setAnchorPoint(ccp(1, 0.5))
                            smallLab:setPosition(ccp(170, 10))
                            labBg:addChild(smallLab)            
                        end 

                        return item
                    end))
                tableView:setDirection(kCCScrollViewDirectionHorizontal)
                self.bg:addChild(tableView) 
                tableView:updataTableView()

                local tipmsg = "您已绑定邀请码"..tgcode.."，充值获得额外赠送钻石"
                if tgcode == "66666" then
                    local maxRatio = 0
                    for i,v in ipairs(self.shoplist) do
                        if tonumber(v.GiveRatio) > maxRatio then
                            maxRatio = tonumber(v.GiveRatio)
                        end
                    end

                    local msgs = {"您未绑定邀请码，绑定邀请码最多可获得额外 ", tostring(maxRatio).."%", " 的赠送钻石"} 
                    local xpos = 200
                    for i,v in ipairs(msgs) do
                        local ftsz = 30
                        if i == 2 then ftsz = 40 end

                        local tiplab = CCLabelTTF:create(v, AppConfig.COLOR.FONT_ARIAL_BOLD, ftsz)
                        tiplab:setAnchorPoint(ccp(0, 0.5))
                        tiplab:setPosition(ccp(xpos, self.bgSize.height - 70))
                        tiplab:setColor(ccc3(0xff, 0x0, 0x0))
                        self.bg:addChild(tiplab)
                        if AppConfig.ISAPPLE then tiplab:setVisible(false) end

                        xpos= xpos + tiplab:getContentSize().width
                    end
                else
                    local tiplab = CCLabelTTF:create("您已绑定邀请码"..tgcode.."，充值获得额外赠送钻石", 
                                AppConfig.COLOR.FONT_ARIAL_BOLD, 30)
                    tiplab:setPosition(ccp(self.bgSize.width / 2, self.bgSize.height - 70))
                    tiplab:setColor(ccc3(0xff, 0x0, 0x0))
                    self.bg:addChild(tiplab)
                    if AppConfig.ISAPPLE then tiplab:setVisible(false) end
                end     

                return
            end
        end

        require("HallUtils").showWebTip(AppConfig.TIPTEXT.Tip_GetPayList_failed)
        self.tip_panel:setVisible(true)
    end, "GetDiamondChargeList.aspx", szData)
end

function LayerShop:setEnable(t)
    for k, v in ipairs(self.btns) do v:setEnabled(t) end
    self.btn_close:setEnabled(t)
end

function LayerShop.put(super, zindex, closeHandler)
    -- IAPPPAY = IAPPPAYTool:getInstance()
    layerShop = LayerShop.new(zindex)
    layerShop.layer_zIndex = zindex
    layerShop.closeHandler = closeHandler    
    layerShop:init()
    super:addChild(layerShop, zindex)
    return layerShop
end

return LayerShop