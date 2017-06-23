--LoginLogic.lua
local LoginLogic = {}
LoginLogic.__index = LoginLogic

local WebRequest = require("GameLib/common/WebRequest")
local json = require("CocosJson")

local HallUtils = require("HallUtils")
local GameConfig = require("GameConfig")
local AppConfig = require("AppConfig")

require("Cache")

--用户信息结构体
LoginLogic.UserInfo = nil

--设置用户信息
--Face    string  Y   用户自定头像
--UserID  int Y   用户ID
--NewNickName string  y   昵称
--Sex int y   性别 1.男；非1.女
--FaceID  int Y   头像ID
--EPassword   string  Y   密文密码
--DiamondAmount   int Y   钻石
--Money   Int Y   现金
--BankAmount  long    Y   保险柜
--VIPLevel    int Y   VIP等级
--FragNum int y   话费券
--CellPhone   string  y   绑定的手机号
--LoginName   string  y   登录名称
--PayMoney
--IPAddress   string  y   玩家登录IP
function LoginLogic.updateUserInfo(info)
    if info ~= nil then
        local mobile = ""
        if info.CellPhone ~= "" then
            mobile = string.sub(info.CellPhone,1,3)

            local  num = #info.CellPhone
            for i=4, num - 2 do
                mobile = mobile.."*"
            end

            mobile = mobile..string.sub(info.CellPhone, num - 1, num)
        end
        info.CellPhone = mobile

        LoginLogic.UserInfo = nil
        LoginLogic.UserInfo = info
        LoginLogic.UserInfo.IPAddress = info.IPAddress or "127.0.0.1(局域网)"
        LoginLogic.UserInfo.TGCode = info.TGCode or "66666"
        AppConfig.CONFINFO.PartnerID = info.PartnerID or 2

        --签名
        LoginLogic.UserInfo.UserWords = info.UserWords or ""

        --公告标示
        LoginLogic.UserInfo.NoticeIndex = CCUserDefault:sharedUserDefault():getIntegerForKey("notice_index") or 0

        --[[
        local faceData = info.Face
        if string.find(faceData, "http") ~= nil then
            LoginLogic.UserInfo.Face = data
            --通过网址获取
            require("FFSelftools/CCUserFace").getFaceByUrl(faceData, function(data)
                LoginLogic.UserInfo.Face = data
            end)
        elseif faceData~="0x" then
            LoginLogic.UserInfo.Face = HallUtils.string2hex(faceData)
        else
            LoginLogic.UserInfo.Face = ""
        end
        ]]

        CCUserDefault:sharedUserDefault():setIntegerForKey("userid", info.UserID)

        --用户密码
        LoginLogic.UserInfo.UserPwd = nil
        
    end
end

--开始界面登录
function LoginLogic.loginFromStart(loginType)
    LoginLogic.login_type = loginType
    LoginLogic.replaceMainScence()

    if debugMode then Cache.log("登录加载完成后材质使用内存状况") end
end

--开始界面登录
function LoginLogic.quickLoginStart()
    LoginLogic.login_type = loginType
    LoginLogic.replaceMainScence()
    LoginLogic.quickLogin()
end

function LoginLogic.loginByWx()
    --第三方登录
    local function onLogonByWx(jsonStr)
        LoginLogic.loginThirdUser(2001, jsonStr)
    end

    if not LoginLogic.login_type then
        CJni:shareJni():logonWxHistory(onLogonByWx)
    else
        CJni:shareJni():logonByWx(onLogonByWx)
    end
end

function LoginLogic.loginThirdUser(thridId, jsonStr)
    --第三方登录
    cclog("Ai quickLogin "..jsonStr)
    --尝试解析用户数据并校验数据完整(包含openid\unionid\nickname\headimgurl)
    local loginData = require("cjson").decode(jsonStr)
    if loginData 
    and loginData.openid and loginData.unionid 
    and loginData.nickname and loginData.headimgurl then
        local jStr = string.gsub(jsonStr,"&", "%%26")
        local szData = string.format("IMei=%s&ThridTypeID=%d&PartnerID=%d&Version=%s&UserInfo=%s&DeviceInfo=%s", 
            AppConfig.CONFINFO.MobileIMEI, thridId, AppConfig.CONFINFO.PartnerID, GameConfig.getHallVer(), jStr, CJni:shareJni():getDeviceInfo())
        -- cclog(szData)
        local function httpCallback(isSucceed,tag,data)
            --解析数据
            local isvilad, code, msg, table = WebRequest.parseData(isSucceed, data)
            if isvilad then
                cclog(data)
                if code ~= 0 then 
                    HallUtils.showWebTip(msg)              
                else
                    ClientLoginByIMIE = nil
                    LoginLogic.updateUserInfo(table[1]) 
                    require("LobbyControl").onInitLobby() 
                    HallUtils.showWebTip("正在进入大厅")
                end
            end 
        end

        WebRequest.getData(httpCallback,"ThirdUserLoing.aspx",szData)
    -- 如果解析错误则调起微信登录界面
    else
        LoginLogic.login_type = 1
        LoginLogic.loginByWx()
    end
end

function LoginLogic.loginByHistory()
    local name = CCUserDefault:sharedUserDefault():getStringForKey("account")
    local pwd = CCUserDefault:sharedUserDefault():getStringForKey("password")

    local function logoByImei(imei)
        local szData = string.format("IMei=%s&NickName=%s&PartnerID=%d&Version=%s&DeviceInfo=%s", imei, AppConfig.CONFINFO.MobileName,
            AppConfig.CONFINFO.PartnerID, GameConfig.getHallVer(), CJni:shareJni():getDeviceInfo())
        local function httpCallback(isSucceed, tag, data)
            LoginLogic.checkUserInfo(isSucceed, data, imei, "")
        end
        WebRequest.getData(httpCallback,"LoginByIMei.aspx",szData)
    end

    if name ~= nil and name ~= "" and not LoginLogic.login_type then
        logoByImei(name)
    else
        logoByImei(AppConfig.CONFINFO.MobileIMEI)     
    end
end

function LoginLogic.quickLogin()
    -- 读取用户协议本地存档
    local agree = CCUserDefault:sharedUserDefault():getStringForKey("agree")
    -- 如果没有同意过用户协议则弹出用户协议窗口
    if agree == "" then
        LoginLogic.main_layer:onShowAgreement()
        agreementPanel.btn_close:setVisible(false)
        agreementPanel.btn_agree:setVisible(true)
        local arrayAction = CCArray:create()
        arrayAction:addObject(CCCallFuncN:create(function(s)
            if s.timer > 0 then
                s:getTitleLabel():setString(string.format("剩余时间%d秒", s.timer))
                s.timer = s.timer - 1
            else
                s:setEnabled(true)
                s:setBackgroundSpriteForState(loadSprite("common/btnOKBg1.png", true), CCControlStateNormal)
                s:getTitleLabel():setString("同意用户协议")
                s:stopAllActions()
            end
        end))
        arrayAction:addObject(CCDelayTime:create(1))
        agreementPanel.btn_agree:runAction(
            CCRepeatForever:create(CCSequence:create(arrayAction)))
    -- 如果同意过用户协议则判定自动登录
    else
        -- 苹果评审状态下不自动登录
        if not AppConfig.ISAPPLE then
            if AppConfig.ISWIN32 then 
                LoginLogic.loginByHistory()
            else       
                LoginLogic.loginByWx()
            end
        end
    end
    --LoginLogic.loginByHistory()

    --[[local data = {
        openid="OPENID",
        nickname="NICKNAME",
        sex=1,
        province="PROVINCE",
        city="CITY",
        country="COUNTRY",
        headimgurl= "http://wx.qlogo.cn/mmopen/g3MonUZtNHkdmzicIlibx6iaFqAc56vxLSUfpb6n5WKSYVY0ChQKkiaJSgQ1dZuTOgvLLrhJbERQQ4eMsv84eavHiaiceqxibJxCfHe/0",
        privilege={"PRIVILEGE1", "PRIVILEGE2"},
        unionid= " o6_bmasdasdsad6_2sgVt7hMZOPfL"
    }
    
    local jsonStr = HallUtils.table2str(data)
    LoginLogic.loginThirdUser(2001, jsonStr)]]
end

--替换到登录主界面
function LoginLogic.replaceMainScence()
    require("LobbyControl").removeHallCache()
    require("LobbyControl").loadingCache()
    local scence, layer = require("Lobby/Login/LayerLogin").createScene()
    CCDirector:sharedDirector():replaceScene(scence)
    --设置当前操作UI
    LoginLogic.main_layer = layer
    LoginLogic.main_layer:initKeyPad()
end

--游客登录
function LoginLogic.loginByIMEI()
    -- 从jni函数中获取IMEI，deviceName as nickname    
    local szData = string.format("IMei=%s&NickName=%s&PartnerID=%d&Version=%s&DeviceInfo=%s", AppConfig.CONFINFO.MobileIMEI, 
        AppConfig.CONFINFO.MobileName, AppConfig.CONFINFO.PartnerID,GameConfig.getHallVer(), CJni:shareJni():getDeviceInfo())

    local function httpCallback(isSucceed, tag, data)
        LoginLogic.checkUserInfo(isSucceed, data, AppConfig.CONFINFO.MobileIMEI, "")
    end

    WebRequest.getData(httpCallback,"LoginByIMei.aspx",szData)
end

function LoginLogic.changeFace(faceIconID, faceIcon, func)
    -- 校验长度
    if string.len(faceIcon) > 16350 then
        HallUtils.showWebTip(AppConfig.TIPTEXT.Tip_Info_Error_Photo)
        return
    end
    
    LoginLogic.UserInfo.Face = faceIcon
    LoginLogic.UserInfo.FaceID = faceIconID

    local szData = string.format("UserID=%d&FaceID=%d&Face=%s",LoginLogic.UserInfo.UserID, faceIconID,
                            HallUtils.hex2string(faceIcon, string.len(faceIcon)))
    -- cclog(szData)
    local function httpCallback(isSucceed,tag,data)
        --解析数据
        local isvilad, code, msg, table = WebRequest.parseData(isSucceed, data)
        if isvilad then
            cclog(data)
            if code ~= 0 then 
                HallUtils.showWebTip(msg)
            end
        end
        if func then
            func()
        end
    end

    WebRequest.getData(httpCallback,"ChangeFace.aspx",szData)
end

--修改昵称
function LoginLogic.changeNickName(name, func)
    if name == "" then
        HallUtils.showWebTip("昵称不能为空")
        return
    end

    if name == LoginLogic.UserInfo.NewNickName then
        return
    end

    if not HallUtils.isNickName(name) then
        HallUtils.showWebTip(AppConfig.TIPTEXT.Tip_Name_Error)
        return
    end

    local szData = string.format("UserID=%s&NickName=%s", LoginLogic.UserInfo.UserID, name)
    -- cclog(szData)
    local function httpCallback(isSucceed,tag,data)
        --解析数据
        local isvilad, code, msg, table = WebRequest.parseData(isSucceed, data)
        if isvilad then
            cclog(data)
            if code ~= 0 then 
                HallUtils.showWebTip(msg)
            else
                LoginLogic.UserInfo.NewNickName = name
            end
        end

        func() 
    end

    WebRequest.getData(httpCallback,"ChangeNickName.aspx",szData)
end

--更新用户签名档
function LoginLogic.updateUserWords(userWords, func)
    if userWords == LoginLogic.UserInfo.UserWords then
        return
    end

    local szData = string.format("UserID=%s&Md5Pwd=%s&UserWords=%s", LoginLogic.UserInfo.UserID, 
                LoginLogic.UserInfo.EPassword, userWords)
    local function httpCallback(isSucceed,tag,data)
        --解析数据
        local isvilad, code, msg, table = WebRequest.parseData(isSucceed, data)
        if isvilad then
            cclog(data)
            if code ~= 0 then 
                HallUtils.showWebTip(msg)
            else
                LoginLogic.UserInfo.UserWords = userWords
            end
        end

        func(LoginLogic.UserInfo.UserWords) 
    end

    WebRequest.getData(httpCallback,"UpdateUserWords.aspx",szData)
end

--获取用户详细信息
function LoginLogic.getUserInfo(userid, func)
    local szData = string.format("UserID=%d", userid)
    local function httpCallback(isSucceed,tag,data)
        --解析数据
        local isvilad, code, msg, table = WebRequest.parseData(isSucceed, data)
        if isvilad then
            cclog(data)
            if code ~= 0 then 
                HallUtils.showWebTip(msg)
            elseif #table > 0 then
                func(table[1])
            end
        end
    end

    WebRequest.getData(httpCallback,"GetUserInfo.aspx",szData)
end

--修改性别
function LoginLogic.changeSex(sex, func)
    local szData = string.format("UserID=%s&Sex=%d", LoginLogic.UserInfo.UserID, sex)
    -- cclog(szData)
    local function httpCallback(isSucceed,tag,data)
        --解析数据
        local isvilad, code, msg, table = WebRequest.parseData(isSucceed, data)
        if isvilad then
            cclog(data)
            if code ~= 0 then 
                HallUtils.showWebTip(msg)
                return
            end

            LoginLogic.UserInfo.Sex = sex
            func()
        end 
    end

    WebRequest.getData(httpCallback,"ChangeSex.aspx",szData)
end

--修改玩家邀请码
function LoginLogic.ChangeTGCode(tgCode, func)
    if tgCode == "" or string.len(tgCode) < 5 then
        HallUtils.showWebTip("邀请码格式不对")
        return
    end

    local szData = string.format("UserID=%s&TGCode=%s&Md5Pwd=%s", LoginLogic.UserInfo.UserID, tgCode, LoginLogic.UserInfo.EPassword)
    -- cclog(szData)
    local function httpCallback(isSucceed,tag,data)
        --解析数据
        local isvilad, code, msg, table, parseTable = WebRequest.parseData(isSucceed, data)
        if isvilad then
            cclog(data)
            if code ~= 0 then 
                HallUtils.showWebTip(msg)
                return
            end

            LoginLogic.UserInfo.TGCode = tgCode
            AppConfig.CONFINFO.PartnerID = parseTable.PartnerID
            func(tgCode)
        end 
    end

    WebRequest.getData(httpCallback,"ChangeTGCode.aspx",szData)
end

--查询申请人信息
function LoginLogic.getSubmitResult(func)
    local szData = string.format("UserID=%s", LoginLogic.UserInfo.UserID)
    local function httpCallback(isSucceed,tag,data)
        local isvilad, code, msg, table, parseTable = WebRequest.parseData(isSucceed, data)
        if isvilad then func(code, msg, table) end 
    end
    WebRequest.getData(httpCallback,"GetUserAgentApply.aspx",szData)
end

--提交申请人信息
function LoginLogic.submitForTG(szName, szPhone, szWX, func)
    local szData = string.format("UserID=%s&Md5Pwd=%s&RealName=%s&PhoneNum=%s&WxID=%s",
        LoginLogic.UserInfo.UserID, LoginLogic.UserInfo.EPassword,szName,szPhone,szWX)
    -- cclog(szData)
    local function httpCallback(isSucceed,tag,data)
        local isvilad, code, msg, table, parseTable = WebRequest.parseData(isSucceed, data)
        -- print(isSucceed,tag, isvilad, code, msg, table)
        if isvilad then func(code, msg, table) end 
    end
    WebRequest.getData(httpCallback,"UserApplyAgent.aspx",szData)
end

-- 数据检测
function LoginLogic.checkUserInfo(isSucceed, data, name, password)
    --解析数据
    local isvilad, code, msg, table = WebRequest.parseData(isSucceed, data)
    if isvilad then
        if code == 0 and table[1].UserID > 0 then
            ClientLoginByIMIE = true
            LoginLogic.onLoginSuccess(table[1], name, password)
            return true
        end 

        HallUtils.showWebTip(msg)    
    end

    return false
end

--获取自定义头像
function LoginLogic.getFace(userid, func)    
    if type(userid) ~= "number" then return end
    userid = tonumber(userid)
    if userid < 1 then return end

    local szData = string.format("UserID=%d", userid)
    -- cclog(szData)
    local function httpCallback(isSucceed,tag,data)
        --解析数据
        local isvilad, code, msg, table = WebRequest.parseData(isSucceed, data)
        local faceData, changed
        if isvilad then
            if code ~= 0 then 
                require("HallUtils").showWebTip(msg)
            elseif #table >= 1 then
               faceData, changed = table[1].Face, table[1].Changed 
               --cclog(faceData..";"..changed)
            end
        end

        func(faceData, changed)
    end
    
    WebRequest.getData(httpCallback,"GetFace.aspx",szData)
end

--登录、注册失败
function LoginLogic.onLoginFailed(failedType, msg)
    if failedType == -1 then
        msg = AppConfig.TIPTEXT.Tip_ACOUNT_FOBID
    end

    --失败回调
    HallUtils.showWebTip(msg)
end

-- 登陆成功，进行关键数据的加载
function LoginLogic.onLoginSuccess(data, name, password)
    --保存数据
    LoginLogic.updateUserInfo(data)
    CCUserDefault:sharedUserDefault():setStringForKey("account", name)
    LoginLogic.UserInfo.UserPwd = password
    CCUserDefault:sharedUserDefault():setStringForKey("password", password) 

    require("LobbyControl").onInitLobby()
end

-- 完成关键资源加载，释放登录资源
function LoginLogic.onLoginFinished()
    if LoginLogic.main_layer then
        --取消定时器
        if LoginLogic.main_layer.find_panle ~= nil then
            LoginLogic.main_layer.find_panle:releaseTimer()
        end

        LoginLogic.main_layer:removeFromParentAndCleanup(true)
        LoginLogic.main_layer = nil
    end
end

function LoginLogic.showTipDlg(msg, okfunc, nofunc)
    local tipDlg = require("Lobby/Common/LobbySecondDlg").putTip(LoginLogic.main_layer, 10, msg, 
        okfunc, nofunc, kCCTextAlignmentCenter)
    tipDlg:show()
end

return LoginLogic
