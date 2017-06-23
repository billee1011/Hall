--LayerLogin.lua
require("CocosExtern")
local LoginLogic = require("Lobby/Login/LoginLogic")
local AppConfig = require("AppConfig")
local HallUtils = require("HallUtils")
local CCButton = require("FFSelftools/CCButton")
local CCCheckbox = require("FFSelftools/CCCheckbox")

local LayerLogin=class("LayerLogin",function()
        return CCLayer:create()
    end)

function LayerLogin:init()
    CCDirector:sharedDirector():getOpenGLView():setDesignResolutionSize(AppConfig.SCREEN.CONFIG_WIDTH,
                 AppConfig.SCREEN.CONFIG_HEIGHT,kResolutionExactFit)
                     
    self.agree = true 
    self.btn_zIndex = 1
    self.panel_zIndex = 2
    
    --设置背景
    self.layer_bg = CCSprite:create("login_bg.jpg")
    self.layer_bg:setScale(1.25)
    self.layer_bg:setPosition(AppConfig.SCREEN.MID_POS)
    self:addChild(self.layer_bg)
    -- self.bg_sz = self.layer_bg:getContentSize()
    self.bg_sz = CCSizeMake(AppConfig.SCREEN.CONFIG_WIDTH, AppConfig.SCREEN.CONFIG_HEIGHT)

    self.img_path = AppConfig.ImgFilePathName
    self:initKeyPad()
    self:addMainPnanel()
end

--响应手机按键
function LayerLogin:initKeyPad()
    self.kekpad_count = 0
    local function KeypadHandler(strEvent)        
        if "backClicked" == strEvent then            
            if self.kekpad_count == 0 then
                self.kekpad_count = getTickCount()
            else
                local last = getTickCount() - self.kekpad_count                
                if last < 100 then
                    self.kekpad_count = 0
                    return
                end
                self.kekpad_count = getTickCount()

                CCDirector:sharedDirector():endToLua()
            end
        end
    end
    self:setKeypadEnabled(true)
    self:registerScriptKeypadHandler(KeypadHandler)      
end

--添加主界面菜单
function LayerLogin:addMainPnanel()
    self.main_panle = CCLayer:create()
    self:addChild(self.main_panle)
    
    --游戏logo
    local logo = loadSprite("gameLogoTitle.png")
    logo:setPosition(ccp(self.bg_sz.width / 2, self.bg_sz.height / 2 + 150))
    self.main_panle:addChild(logo)
    
    --选择按钮
    local spriteOff = loadSprite("login/uncheck.png")
    local spriteOn = loadSprite("login/check.png")
    local check = CCCheckbox.create(spriteOff, spriteOn, true, true)
    check:addHandleOfControlEvent(function(first, target, event)
        self.agree = false
        if target:isChecked() then self.agree = true end
    end, CCControlEventTouchUpInside)
    check:setPosition(ccp(self.bg_sz.width / 2 - 105 , 155))
    check:setChecked(true)
    self.main_panle:addChild(check)

    local versionLab = CCLabelTTF:create("版本："..require("GameConfig").getHallVerName(), "" ,18);
    versionLab:setColor(ccc3(0,0,0))
    versionLab:setAnchorPoint(ccp(1,1))
    versionLab:setPosition(ccp(self.bg_sz.width - 16, self.bg_sz.height - 20))
    self.main_panle:addChild(versionLab)

    local tip = CCLabelTTF:create("抵制不良游戏 拒绝盗版游戏 注意自我保护 谨防受骗上当 适度游戏益脑 沉迷游戏伤身 合理安排时间 享受健康生活" , "" ,18)
    tip:setColor(ccc3(0,0,0))
    tip:setAnchorPoint(ccp(0.5,0.5))
    tip:setPosition(ccp(self.bg_sz.width / 2 , 16))
    self.main_panle:addChild(tip)

    local tip2 = CCLabelTTF:create("粤网文[2016]2467-476号   新广出审[2017]3279 号   ISBN 978-7-7979-6734-1" .. 
        "\n著作权人：犇腾时代科技（深圳）有限公司 经营许可证编号：粤B2-20160555" , "" ,20)
    tip2:setColor(ccc3(0,0,0))
    tip2:setAnchorPoint(ccp(0.5,0.5))
    tip2:setPosition(ccp(self.bg_sz.width / 2 , self.bg_sz.height - 36))
    self.main_panle:addChild(tip2)
    
    local s = "login/agreeMentBtn.png"
    CCButton.put(self.main_panle, CCButton.createCCButtonByFrameName(s, s, s, function()
        self:onShowAgreement()
    end), ccp(self.bg_sz.width / 2 + 25 , 155), 0)
    
    -- CCTV优选品牌标识
    local cctv = loadSprite("login/cctv.png")
    cctv:setPosition(ccp(self.bg_sz.width / 2, 80))
    self.main_panle:addChild(cctv)
    
    local loginTip = CCLabelTTF:create("游戏登录中..." , "" ,24);
    loginTip:setColor(ccc3(0,0,0))
    loginTip:setAnchorPoint(ccp(0.5,0.5))
    loginTip:setPosition(ccp(self.bg_sz.width / 2 , 300))
    self.main_panle:addChild(loginTip)
    self.loginTip = loginTip

    self.action_seces = 0
end

function LayerLogin:addLongonBtn()
    if self.longon_btn then return end
    if self.loginTip then self.loginTip:removeFromParentAndCleanup(true) self.loginTip = nil end

    -- 苹果评审状态下同时显示双按钮
    if AppConfig.ISAPPLE then
        local logonImg = "login/wxlogin"
        self.longon_btn = CCButton.put(self.main_panle, CCButton.createCCButtonByFrameName(
            logonImg..".png", logonImg.."2.png", logonImg..".png", function()
                if self.agree then
                    require("Lobby/Login/LoginLogic").loginByWx()
                else
                    require("HallUtils").showWebTip("请先阅读和同意用户协议")
                end
            end), ccp(self.bg_sz.width / 2 - 200 , 225), 0)
        logonImg = "login/qlogin"
        self.longon_btn2 = CCButton.put(self.main_panle, CCButton.createCCButtonByFrameName(
            logonImg..".png", logonImg.."2.png", logonImg..".png", function()
                if self.agree then
                    require("Lobby/Login/LoginLogic").loginByHistory()
                else
                    require("HallUtils").showWebTip("请先阅读和同意用户协议")
                end
            end), ccp(self.bg_sz.width / 2 + 200, 225), 0)
        -- 如果没有安装微信则隐藏微信登录按钮
        if not CJni:shareJni():isWXInstalled() then
            self.longon_btn:setVisible(false)
            self.longon_btn2:setPosition(ccp(self.bg_sz.width / 2, 225))
        end
    else
        local logonImg = "login/wxlogin"
        self.longon_btn = CCButton.put(self.main_panle, CCButton.createCCButtonByFrameName(
            logonImg..".png", logonImg.."2.png", logonImg..".png", function()
                if self.agree then
                    self:onLogon()
                else
                    require("HallUtils").showWebTip("请先阅读和同意用户协议")
                end
            end), ccp(self.bg_sz.width / 2 , 225), 0)
    end
end

function LayerLogin:onLogon()
    local seces = os.time()
    if seces > self.action_seces + 5 then
        require("Lobby/Login/LoginLogic").quickLogin()
        self.m_actionSeces = seces
    end    
end

function LayerLogin:onShowAgreement()
    agreementPanel = agreementPanel or require("Lobby/Agreement/LayerAgreement").put(self, self.panel_zIndex):show()
end
 
function LayerLogin:onHallUpdata(downloadURL, version, onUpgradeCancel, onUpgradeFinished)
    local function updateHandler(event, value)
        if event == "state" then 
           
        elseif event == "progress" then --显示进度CCProgressFromTo         
            self:setProgress(value)
        elseif event == "success" then --进入游戏 
            self:onProgressOver()
            onUpgradeFinished()
        end
    end

    local function onOKCallBack()  
        self:addProgressUI()
        GameConfig.upgradeDownload(downloadURL,"hall",updateHandler,version)
    end    
    local tmpStr ="全新界面大厅已上线，下载大小为%.02fM,是否需要更新？(不更新也可以正常游戏)，更新后如出现异常，请退出游戏重新打开。"
    local u = require("GameLib/common/Updater"):new()
    local zipSz = u:getDownloadFileLength(downloadURL.."hall_upgrade.zip")
    local str = string.format(tmpStr,zipSz/1024/1024)

    local tipDlg = require("Lobby/Common/LobbySecondDlg").putTip(self, 10, str, 
        onOKCallBack, onUpgradeCancel, kCCTextAlignmentCenter)
    tipDlg:show()

end

function LayerLogin:onHallPartUpdata(upgrade, downloadURL, version, onUpgradeFinished, onUpgradeError)
    local function updateHandler(event, value)
        if event == "state" then 
            --downloadStart、downloadDone、uncompressStart、uncompressStart
            cclog("updateHandler state "..value)
        elseif event == "error" then
            local errorTip
            if value == "errorCreateFile" then errorTip = "大厅更新：创建文件失败"
            elseif value == "errorNetwork" then errorTip = "大厅更新：网络连接错误"
            elseif value == "errorUncompress" then errorTip = "大厅更新：解压游戏失败" 
            elseif value == "errorUnknown" then errorTip = "更新大厅失败" end

            onUpgradeError(errorTip)          
        elseif event == "progress" then --显示进度CCProgressFromTo         
            self:setProgress(value)
        elseif event == "success" then --进入游戏 
            self:onProgressOver()
            onUpgradeFinished()
        end
    end

    local url
    self:addProgressUI()
    if upgrade == 1 then
        url = GameConfig.deltaDownload(downloadURL,"hall", updateHandler, version)
    else
        url = GameConfig.fixDownload(downloadURL,"hall", updateHandler, version)
    end

    return url
end

function LayerLogin:setProgress(value)
    self.level_progress:setPercentage(value)
    local xpos = self.bg_sz.width / 2 - self.progress_sz.width / 2 + value * self.progress_sz.width / 100 + 5
    self.progress_mark:setPositionX(xpos)    
end

function LayerLogin:onProgressOver()
    self:setProgress(100) 
    self.progress_panel:removeFromParentAndCleanup(true)

    require("HallUtils").showWebTip("恭喜游戏大厅完成更新")
end


function LayerLogin:addProgressUI()
    if self.progress_panel then return end

    self.progress_panel = CCLayer:create()
    self:addChild(self.progress_panel)

    local ProgressBackground = loadSprite("common/progress_bg.png")
    self.progress_sz = ProgressBackground:getContentSize()
    ProgressBackground:setPosition(ccp((self.bg_sz.width - self.progress_sz.width) / 2, 300))
    ProgressBackground:setAnchorPoint(ccp(0, 0.5))
    self.progress_panel:addChild(ProgressBackground)

    self.level_progress = CCProgressTimer:create(loadSprite("common/progress_fore.png"))
    self.level_progress:setPosition(ccp(ProgressBackground:getPositionX(), 
        ProgressBackground:getPositionY()))
    self.level_progress:setType(kCCProgressTimerTypeBar)
    self.level_progress:setMidpoint(ccp(0, 0))
    self.level_progress:setBarChangeRate(ccp(1, 0))
    self.level_progress:setAnchorPoint(ccp(0, 0.5))
    self.level_progress:setPercentage(0)
    self.progress_panel:addChild(self.level_progress)

    self.progress_mark = loadSprite("common/progress_mark.png")
    self.progress_mark:setPosition(ccp(self.bg_sz.width / 2 - self.progress_sz.width / 2 + 5, 300))
    self.progress_panel:addChild(self.progress_mark)
end

function LayerLogin.create()
	local layer = LayerLogin.new()
	layer:init()
	return layer
end

function LayerLogin.createScene()
	local layer = LayerLogin.create()
	local scene = CCScene:create()
	scene:addChild(layer)
	return scene, layer
end

 return LayerLogin