--HallControl.lua
require("GameLib/gamelib/CGameLib")
require("GameLib/common/common")
local Resources = require("Resources")
--local txml = require("FFSelftools/txml")
local json = require("CocosJson")

local HallControl = {}
HallControl.__index = HallControl

local WebRequest = require("GameLib/common/WebRequest")
local getData = WebRequest.getData
local SAFEATOI = WebRequest.SAFEATOI
local SAFEATOI64 = WebRequest.SAFEATOI64
local SAFESTRING = WebRequest.SAFESTRING
local appleChargeVerify = require("HallLayers/AppleChargeVerify"):instance()

local VersionUtils = require("GameLib/common/VersionUtils")

function HallControl:new() --private method:
    local store = nil

    return function(self)
        if store then return store end 
        local o =  {}
        setmetatable(o, self)
        self.__index = self

        store = o
        return o
    end
end

HallControl.instance = HallControl:new()
HallControl.NOUPDATADOWNGAME=0
HallControl.FULLDOWNLOAD =1
HallControl.UPGRADEDOWNLOAD =2
HallControl.FIXDOWNLOAD =3
HallControl.DELTADOWNLOAD =4


--消息枚举
HallControl.ENUMMODIFYNICK =4   --修改昵称
HallControl.ENUMMODIFYSEX =5    --修改性别
HallControl.ENUMCHANGEFACE =6   --修改图像
HallControl.ENUMBINDEMAIL =7    --绑定邮箱
HallControl.ENUMLOGINSUCCESS =8  --登陆成功
HallControl.ENUMMODIFYPASSWORD =9 --修改密码
HallControl.m_goodsList = {}
HallControl.m_chargeInfoList = {}

local uroot = require("Domain").HallFile
-- 个人信息公共数据
require("PublicUserInfo")
HallControl.publicUserInfo = PublicUserInfo:new()

HallControl.webRoot = require("Domain").WebRoot

function HallControl:getTargetPlatform()
    return CCApplication:sharedApplication():getTargetPlatform()    
end

function HallControl.getRootAndResult(data)
    if not data then return nil end
    if string.len(data) == 0 then return nil end
	local xml = tinyxml:new()
	xml:LoadMemory(data)
	local root = xml:FirstChildElement("root")
	return root
end

--获取用户信息
function HallControl:getPublicUserInfo()
    return self.publicUserInfo
end

--设置用户信息
function HallControl:setPublicUserInfo(table)
    if table ~= nil then
        self.publicUserInfo.userDBID = userDBID
        self.publicUserInfo.nDiamond = SAFEATOI(userInfo["d"])
        self.publicUserInfo.email = SAFESTRING(userInfo["m"])
        self.publicUserInfo.encryptPassword = SAFESTRING(userInfo["ep"])
        local faceData = SAFESTRING(userInfo["f"])
        self.publicUserInfo.nFaceID = SAFEATOI(userInfo["fid"])
        self.publicUserInfo.nickName = SAFESTRING(userInfo["n"])            
        self.publicUserInfo.sex = SAFEATOI(userInfo["s"])
        self.publicUserInfo.nGold = SAFEATOI(userInfo["mo"])
        self.publicUserInfo.vipLevel = SAFEATOI(userInfo["vl"])
        self.publicUserInfo.nFrag = SAFEATOI(userInfo["fr"])
        self.publicUserInfo.bankAmount = SAFEATOI(userInfo["ba"])
        if faceData~="0x" then
            self.publicUserInfo.faceData = require("HallUtils"):string2hex(faceData)
        else
            self.publicUserInfo.faceData= nil
        end
    end
end

function HallControl:setWebRoot(webRoot)
    self.webRoot = webRoot
end

function HallControl:getUserDBID()
	return self.publicUserInfo.userDBID
end

function HallControl:getPartnerID()
    return 0
end

function HallControl:isLogined()
    return self.publicUserInfo.userDBID ~= 0
end

function HallControl:getShoppingList()
    local shoppintList = {}
    -- 过滤掉特殊的
    for i=1,#self.m_goodsList do
        if self.m_goodsList[i].m_iP ~= "Ming2"
            and self.m_goodsList[i].m_iP ~= "Ming8" then            
            pushTable(shoppintList,self.m_goodsList[i])
        end
    end
    return shoppintList
end

function HallControl:payByProductID(productID,handle)
    for k,v in pairs(self.m_goodsList) do
        if v.m_iP == productID then
            self:pay(v,handle)
            return
        end
    end
    if handle then handle(0) end
end

function HallControl:getEXchangeList()
    return self.m_chargeInfoList
end

function HallControl:getAddress(file)
    return self.webRoot .. "/" .. file
end

function HallControl:bindEmail(email,password,handle)
    if not self:isNetworkAvailable() then return end        
    local szData = string.format("UserID=%d&Password=%s&Email=%s",self.publicUserInfo.userDBID,password,email)
    local function httpCallback(isSucceed,tag,data)
        if(not isSucceed) then cclog("HallControl:bindEmail() failed") return end
        local root = HallControl.getRootAndResult(data)
		local ep = SAFESTRING(root:QueryString("ep"))
        local resoult = SAFESTRING(root:QueryInt("r"))
        if resoult==1 then
            self.publicUserInfo.encryptPassword = ep
            CCUserDefault:sharedUserDefault():setStringForKey("account",email)
            CCUserDefault:sharedUserDefault():setStringForKey("password",password)
        end
        if handle then handle(self.ENUMBINDEMAIL,resoult) end
    end
    getData(httpCallback,self:getAddress("BindEmail.aspx"),szData)
end

function HallControl:register(email,password,handle)
    if not self:isNetworkAvailable() then return end        
    local szData = string.format("Password=%s&Email=%s&PartnerID=%d&Version=%s&Imei=%s&NickName=1",
        password,email,CJni:shareJni():getPartnerID(),GameConfig.getHallVer(),
        CJni:shareJni():getIMEI())
    local function httpCallback(isSucceed,tag,data)        
        if(not isSucceed) then 
            cclog("HallControl:register() failed %s",data) 
            return 
        end
        local root = HallControl.getRootAndResult(data)       
        local resoult = SAFESTRING(root:QueryInt("r"))
        if resoult==1 then 
            CCUserDefault:sharedUserDefault():setStringForKey("account",email)
            CCUserDefault:sharedUserDefault():setStringForKey("password",password)
        end
        if handle then handle(resoult) end
    end
    getData(httpCallback,self:getAddress("Register.aspx"),szData)
end

function HallControl:loginByIMEI(imei,nickname,isQQlogin)
    if not self:isNetworkAvailable() then return end    
    -- 从jni函数中获取IMEI，deviceName as nickname    
    local  jni= CJni:shareJni()
    local szData = string.format("IMei=%s&NickName=%s&PartnerID=%d&Version=%s",imei,
    nickname,jni:getPartnerID(),GameConfig.getHallVer())
    
    local function httpCallback(isSucceed,tag,data)
        if(not isSucceed) then cclog("HallControl:loginByIMEI() failed") 
            --if handle then handle(false) end
            self:onLoginFailed()
            return 
        end
        local root = txml.getRoot(data)
		local index,userInfo = txml.FirstChildElement(root,"User")
        if userInfo then
            local userDBID= SAFEATOI(userInfo["id"])            
            if userDBID <= 0 then 
                self:onLoginFailed(userDBID)
                return
            end
            self.publicUserInfo.userDBID =userDBID
            self.publicUserInfo.nDiamond = SAFEATOI(userInfo["d"])
            self.publicUserInfo.email = SAFESTRING(userInfo["m"])
            self.publicUserInfo.encryptPassword = SAFESTRING(userInfo["ep"])
            local faceData = SAFESTRING(userInfo["f"])
            self.publicUserInfo.nFaceID = SAFEATOI(userInfo["fid"])
            self.publicUserInfo.nickName = SAFESTRING(userInfo["n"])            
            self.publicUserInfo.sex = SAFEATOI(userInfo["s"])
            self.publicUserInfo.nGold = SAFEATOI(userInfo["mo"])
            self.publicUserInfo.vipLevel = SAFEATOI(userInfo["vl"])
            self.publicUserInfo.nFrag = SAFEATOI(userInfo["fr"])
            self.publicUserInfo.bankAmount = SAFEATOI(userInfo["ba"])
            if faceData~="0x" then
                self.publicUserInfo.faceData = require("HallUtils"):string2hex(faceData)
            else
                self.publicUserInfo.faceData= nil
            end
            --if handle then 
            --    handle(self.publicUserInfo.userDBID>0)
            --end 
            CCUserDefault:sharedUserDefault():setStringForKey("account","")
            CCUserDefault:sharedUserDefault():setStringForKey("password","")    
            if not isQQlogin then
                CCUserDefault:sharedUserDefault():setStringForKey("QQLogin","")
            end      
            self:onLoginSuccess()
            if handle then handle() end
        else
            self:onLoginFailed()
        end
    end
    getData(httpCallback,self:getAddress("LoginByIMei.aspx"),szData)
end

function HallControl:loginByEmail(email,password,rememberPassword)
    if not self:isNetworkAvailable() then return end        
    local  jni= CJni:shareJni()
    local szData = string.format("Email=%s&Password=%s&IMei=%s&PartnerID=%d&Version=%s",email,password,jni:getIMEI(),jni:getPartnerID(),GameConfig.getHallVer())
    local function httpCallback(isSucceed,tag,data)
        require("HallLayers/LoadingLayer").HideLoadingLayer()
        if(not isSucceed) then cclog("HallControl:loginByEmail() failed") 
           self:onLoginFailed()
            return 
        end        
        local root = txml.getRoot(data)
		local index,userInfo = txml.FirstChildElement(root,"User")
        if userInfo then
            local userDBID= SAFEATOI(userInfo["id"])
            if userDBID <= 0 then 
                self:onLoginFailed(userDBID)
                return
            end
            CCUserDefault:sharedUserDefault():setStringForKey("QQLogin","")
            self.publicUserInfo.userDBID =userDBID
            self.publicUserInfo.nDiamond = SAFEATOI(userInfo["d"])
            self.publicUserInfo.email = SAFESTRING(userInfo["m"])
            self.publicUserInfo.encryptPassword = SAFESTRING(userInfo["ep"])
            local faceData = SAFESTRING(userInfo["f"])
            self.publicUserInfo.nFaceID = SAFEATOI(userInfo["fid"])
            self.publicUserInfo.nickName = SAFESTRING(userInfo["n"])            
            self.publicUserInfo.sex = SAFEATOI(userInfo["s"])
            self.publicUserInfo.nGold = SAFEATOI(userInfo["mo"])
            self.publicUserInfo.vipLevel = SAFEATOI(userInfo["vl"])
            self.publicUserInfo.nFrag = SAFEATOI(userInfo["fr"])            
            self.publicUserInfo.bankAmount = SAFEATOI(userInfo["ba"])
            if faceData~="0x" then
                self.publicUserInfo.faceData = require("HallUtils"):string2hex(faceData)
            else
                self.publicUserInfo.faceData= nil
            end
            if rememberPassword then
                CCUserDefault:sharedUserDefault():setStringForKey("account",email)
                CCUserDefault:sharedUserDefault():setStringForKey("password",password)
            else
                CCUserDefault:sharedUserDefault():setStringForKey("password","")
            end
            self:onLoginSuccess()
        else
            self:onLoginFailed()
        end
    end
    getData(httpCallback,self:getAddress("LoginByEmail.aspx"),szData)
end

function HallControl:requestGameList()
    if not self:isNetworkAvailable() then return end      
    local function httpCallback(isSucceed,tag,data)
        if(not isSucceed) then cclog("HallControl:getGameList() failed") return end
        --cclog(data)
        --local root = HallControl.getRootAndResult(data)
        local root = txml.getRoot(data)
        local index,pGameInfo = txml.FirstChildElement(root,"Game")    
        self.m_gameList = {}        
        while pGameInfo do
            local p = require("GameInfo").new()    
            p.m_iId= SAFEATOI(pGameInfo["id"])
            p.m_sCn= SAFESTRING(pGameInfo["cn"])
            p.m_sEn= SAFESTRING(pGameInfo["en"])
            p.m_iIv= SAFESTRING(pGameInfo["iv"])
            p.m_sServeIp =SAFESTRING(pGameInfo["s"])
            p.m_iPort= SAFEATOI(pGameInfo["p"])
            p.m_sVersion= SAFESTRING(pGameInfo["v"])
            p.m_sDir= SAFESTRING(pGameInfo["d"])
            p.m_sWr = SAFESTRING(pGameInfo["wr"])
            -- 如果直接进入游戏，则过滤掉不相干的游戏
            local bGameAddToTable = true
            if self.m_szDirectInGame ~= nil and string.len(self.m_szDirectInGame) > 0 then 
                if p.m_sEn ~= self.m_szDirectInGame and self.m_szDirectInGame ~= "hall" then
                    bGameAddToTable = false
                end
            end
            if bGameAddToTable then
                pushTable(self.m_gameList,p)
            end
            --cclog("pGameInfo = " .. str)
            index,pGameInfo = txml.NextChildElement(index,root,"Game")
            -- 如果GameConfig中游戏版本不存在，则手动添加
            GameConfig.reloadGameVersion(p.m_sEn)
        end   
    
        --if handle then handle(self.m_gameList) end --回调拉取游戏列表数据
        require("HallLayers/LoadingLayer").HideLoadingLayer()
        -- 下载游戏ICON
        self:updataGameListIcon()
    end
    local szData = string.format("PartnerID=%d",CJni:shareJni():getPartnerID())
    getData(httpCallback,self:getAddress("GetGameList.aspx"),szData)
end

function HallControl:getGameList()   
    return self.m_gameList
end

--遍历游戏列表ICON是否存在  不存在添加游戏ICON
function HallControl:updataGameListIcon()
    if not self:isNetworkAvailable() then return end    
    require("GameConfig")    
    local function updateHandler(event, value)
        if event == "success" then
            cclog("HallControl:isExistGameList" .. value)
        end        
    end
    for _,v in ipairs(self.m_gameList) do  
        
        GameConfig.addGame(v.m_sEn,v.m_sDir,v.m_iIv,updateHandler)
        --GameConfig.addGame(v.m_sEn,"http://platform.ss2007.com/" .. v.m_sEn .. "/",v.m_iIv,handle or updateHandler)
    end 
    self:onLoginFinished()  
end

--获取当前未删除游戏列表
function HallControl:getExistGameList()
    local existGameList ={}
    for _,v in ipairs(self.m_gameList) do  
        local curConfig = GameConfig.getGameConfig(v.m_sEn)
        local curMainVersion= VersionUtils.getMainVersion(curConfig["version"])
        local curSubVersion= VersionUtils.getSubVersion(curConfig["version"])
        local curBuildVersion= VersionUtils.getBuildVersion(curConfig["version"])
        -- 如果安装包本身所带，则不能删除

        if curMainVersion~="0" or (curSubVersion~="0" or curBuildVersion~="0") then
            if GameConfig.isGameDeletable(v.m_sEn) then
                pushTable(existGameList,v)
            end
        end
    end
    return existGameList
end
--选择当前游戏是否需要升级（fullDownload，upgradeDownload，fixDownload）
function HallControl:isUpdataGame(gameName)
    require("GameConfig")
    require("GameLib/common/VersionUtils")
    local curConfig = GameConfig.getGameConfig(gameName)
    local curMainVersion= tonumber(VersionUtils.getMainVersion(curConfig["version"]))
    local curSubVersion= tonumber(VersionUtils.getSubVersion(curConfig["version"]))
    local curBuildVersion= tonumber(VersionUtils.getBuildVersion(curConfig["version"]))
    for _,config in pairs(self.m_gameList) do
        if config.m_sEn==gameName   then
            cclog("isUpdataGame %d,%d,%d,%s,%s",curMainVersion,curSubVersion,curBuildVersion,config.m_sVersion,curConfig["version"])
            if not VersionUtils.isNew(config.m_sVersion,curConfig["version"]) then
               return self.NOUPDATADOWNGAME     --当前游戏无需更新
            end
            if curMainVersion < tonumber(VersionUtils.getMainVersion(config.m_sVersion)) then
                return self.FULLDOWNLOAD        --更新完整数据包
            elseif curSubVersion < tonumber(VersionUtils.getSubVersion(config.m_sVersion)) then
                return self.UPGRADEDOWNLOAD     --更新部分数据包
            elseif curBuildVersion == tonumber(VersionUtils.getBuildVersion(config.m_sVersion)) - 1 then
                return self.DELTADOWNLOAD
            elseif curBuildVersion < tonumber(VersionUtils.getBuildVersion(config.m_sVersion)) then
                return self.FIXDOWNLOAD         --微更新数据包无需提示
            end
        end
    end
    return self.FULLDOWNLOAD
end

--获取平台信息判断是否需要更新
function HallControl:getPlatformInfo()    
    local  jni= CJni:shareJni()
    local szData = string.format("PartnerID=%d&version=%s",jni:getPartnerID(),GameConfig.getHallVer())
    local function httpCallback(isSucceed,tag,data)
        cclog(data);
        if(not isSucceed) then cclog("HallControl:getPlatformInfo() failed") return end
        local root = txml.getRoot(data)
        if not root then return end
        self.m_adURL = SAFESTRING(root.xarg["au"])
        self.m_bShowAD = (SAFEATOI(root.xarg["as"]) == 1)
        local index,version = txml.FirstChildElement(root,"Version")
        if not version then return end
        local downLoadUrl = SAFESTRING(version["d"])
        local hallVersion = SAFESTRING(version["v"])       
        local curConfig = GameConfig.getGameConfig("hall")
       

        if VersionUtils.isNew(hallVersion,curConfig["version"]) then
            if tonumber(VersionUtils.getSubVersion(hallVersion)) == 
                tonumber(VersionUtils.getSubVersion(curConfig["version"])) then

                if tonumber(VersionUtils.getBuildVersion(hallVersion)) == 
                    tonumber(VersionUtils.getBuildVersion(curConfig["version"])) + 1 then
                    GameConfig.deltaDownload(downLoadUrl,"hall",nil,hallVersion)
                else
                    -- 下载更新
                    GameConfig.fixDownload(downLoadUrl,"hall",nil,hallVersion)
                end
            else
                -- 提示更新
                cclog("提示更新 %s.%s",hallVersion,curConfig["version"])
                self.m_bPlatformUpgrade = true
                self.m_szDownloadURL = downLoadUrl
                self.m_version = hallVersion
            end
        end        
    end
    getData(httpCallback,self:getAddress("GetPlatformInfo.aspx"),szData)  
end

--修改用户昵称
function HallControl:modifyNickName(nickName,handle)
    if not self:isNetworkAvailable() then return end      
    local  jni= CJni:shareJni()
    local szData = string.format("UserID=%d&NickName=%s",self.publicUserInfo.userDBID,nickName)
    -- cclog("UserID=%s,NickName=%s",self.publicUserInfo.userDBID,nickName)
    local function httpCallback(isSucceed,tag,data)
        if(not isSucceed) then cclog("HallControl:modifyNickName() failed") return end
	    cclog(data)
	    local root = HallControl.getRootAndResult(data)
        local resoult = SAFEATOI(root:QueryString("r"))
        if handle then handle(self.ENUMMODIFYNICK,resoult) end
    end
    getData(httpCallback,self:getAddress("ChangeNickName.aspx"),szData)  
end

--修改性别
function HallControl:modifySex(sex,handle)
    if not self:isNetworkAvailable() then return end    
    local szData = string.format("UserID=%d&Sex=%s",self.publicUserInfo.userDBID,sex)
    local function httpCallback(isSucceed,tag,data)
        if(not isSucceed) then cclog("HallControl:modifySex() failed") return end	    
	    local root = HallControl.getRootAndResult(data)
        local resoult = SAFEATOI(root:QueryString("r"))
        if resoult == 1 then
            self.publicUserInfo.sex = sex
            require("Resources").dispatchEvent(Resources.onSexChanged,sex)
        end

        if handle then handle(self.ENUMMODIFYSEX,resoult) end
    end
    getData(httpCallback,self:getAddress("ChangeSex.aspx"),szData)  
end

--修改图像
function HallControl:changeFace(faceIconID,faceIcon,handle)
    -- 校验长度
    if string.len(faceIcon) > 16350 then
        local scene =CCDirector:sharedDirector():getRunningScene()
        local DialogMessage =require("FFSelftools/MessageLayer").create("对不起，您传入的图片尺寸过大导致失败，请先进行裁剪或者更换其他图片")
        scene:addChild(DialogMessage)
        return
    end
    if not self:isNetworkAvailable() then return end    
    local szData = string.format("UserID=%d&FaceID=%d&Face=%s",self.publicUserInfo.userDBID,faceIconID,
                require("HallUtils"):hex2string(faceIcon,string.len(faceIcon)))
    local function httpCallback(isSucceed,tag,data)
        if(not isSucceed) then cclog("HallControl:changeFace() failed") return end
	    --cclog(data)
	    local root = HallControl.getRootAndResult(data)
        local result = SAFEATOI(root:QueryString("r"))
        if result == 1 and string.len(faceIcon) > 0 then
            self.publicUserInfo.faceData = faceIcon
            self.publicUserInfo.nFaceID = faceIconID
        end
        if handle then handle(self.ENUMCHANGEFACE,result) end
    end
    --cclog("changeFace : %s,data = %s",self:getAddress("ChangeFace.aspx"),szData)
    getData(httpCallback,self:getAddress("ChangeFace.aspx"),szData)
end
--修改密码
function HallControl:modifyPassword(oldPassword,newPassword,handle)
    if not self:isNetworkAvailable() then return end      
    local szData = string.format("UserID=%d&opwd=%s&npwd=%s",self.publicUserInfo.userDBID,oldPassword,newPassword)
    local function httpCallback(isSucceed,tag,data)
        if(not isSucceed) then cclog("HallControl:modifyPassword() failed") return end
	    cclog(data)
	    local root = HallControl.getRootAndResult(data)
        local resoult = SAFEATOI(root:QueryString("r"))
        if handle then handle(self.ENUMMODIFYPASSWORD,resoult) end
    end
    getData(httpCallback,self:getAddress("ChangePassword.aspx"),szData)
end

--获取商城产品列表
function HallControl:requestShoppingList()
    if not self:isNetworkAvailable() then return end        
    if self.m_goodsList~=nil and #self.m_goodsList>0 then
        --if handle then handle(self.m_goodsList) end 
        return
    end
    local  jni= CJni:shareJni()
    local szData = string.format("partnerid=%d&version=%s",jni:getPartnerID(),GameConfig.getHallVer())
    local function httpCallback(isSucceed,tag,data)
    if(not isSucceed) then cclog("HallControl:getShoppingList() failed") return end
		--local root = HallControl.getRootAndResult(data)
        local root = txml.getRoot(data)
		local index,pGoodsInfo = txml.FirstChildElement(root,"ChargeInfo")
		while pGoodsInfo do
            local p = require("GoodsInfo").new()
            p.m_iGm= SAFEATOI(pGoodsInfo["gm"])
            p.m_iRmb= SAFEATOI(pGoodsInfo["rmb"])
            p.m_cbIc= SAFEATOI(pGoodsInfo["ic"])
            p.m_sPn = SAFESTRING(pGoodsInfo["pn"])
            p.m_iP= SAFESTRING(pGoodsInfo["p"])
            p.m_iMmp= SAFESTRING(pGoodsInfo["mmp"])
            p.m_cbMt= SAFEATOI(pGoodsInfo["mt"])
            p.m_iMmgm= SAFEATOI(pGoodsInfo["mmgm"])            
            -- mm审核期特殊处理
            local partnerID = CJni:shareJni():getPartnerID()
            if partnerID == 15 or partnerID == 25 then
                if string.len(p.m_iMmp) > 1 then                    
                    p.m_iGm = p.m_iMmgm
                end
            end
			pushTable(self.m_goodsList,p)
			index,pGoodsInfo = txml.NextChildElement(index,root,"ChargeInfo")
		end
        --if handle then handle(self.m_goodsList) end --回调拉取游戏列表数据
    end
    getData(httpCallback,self:getAddress("GetDiamondChargeList.aspx"),szData)
end

--获取充值金额
function HallControl:getRechargeInfo(handle)
    if not self:isNetworkAvailable() then return end     
    local szData = string.format("userid=%d",self:getUserDBID())    
    local function httpCallback(isSucceed,tag,data)
        if(not isSucceed) then cclog("HallControl:getRechargeInfo() failed") return end
        local root = txml.getRoot(data)
		--local root = HallControl.getRootAndResult(data)
		local index,pGoodsInfo = txml.FirstChildElement(root,"user")
        local nPayMoney = SAFEATOI(pGoodsInfo["pm"])
        local changed = (self.publicUserInfo.payAmount ~= nPayMoney)        
        self.publicUserInfo.payAmount = nPayMoney
        if handle then handle(changed) end --回调拉取游戏列表数据
    end
    getData(httpCallback,self:getAddress("GetInfo.aspx"),szData)
end

--通过邮箱获取密码
function HallControl:getPasswordByEmail(email,handle)
    if not self:isNetworkAvailable() then return end      
    local szData = string.format("EMail=%s&GameID=%d",email,self:getUserDBID())
    local function httpCallback(isSucceed,tag,data)
        if(not isSucceed) then cclog("HallControl:getPasswordByEmail() failed") return end
        local str = SAFESTRING(data)
        if handle then handle(str) end --获取密码
    end
    getData(httpCallback,self:getAddress("GetPswByEmail.aspx"),szData)
end

--获取修改昵称所需钻石数
function HallControl:getModifyNickDiamond(handle)
     if not self:isNetworkAvailable() then return end    
    local szData = string.format("UserID=%d",self:getUserDBID())
    local function httpCallback(isSucceed,tag,data)
        if(not isSucceed) then cclog("HallControl:getModifyNickDiamond() failed") return end
	    cclog(data)
	    local root = HallControl.getRootAndResult(data)
        local pDiamond = root and root:FirstChildElement("Diamond") or nil	
        local money = SAFEATOI(pDiamond:QueryInt("param"))
        if handle then handle(money) end
    end
    getData(httpCallback,self:getAddress("GetChangedInfo.aspx"),szData)
end

--获取钻石兑换列表
function HallControl:requestEXchangeList()   
    if not self:isNetworkAvailable() then return end    
    local function httpCallback(isSucceed,tag,data)
        if(not isSucceed) then cclog("HallControl:requestEXchangeList() failed") return end
		local root = txml.getRoot(data)
		local index,pChargeInfo = txml.FirstChildElement(root,"ChargeInfo")
        self.m_chargeInfoList = {}
		while pChargeInfo do
            local p = {}
            p.nDiamond= SAFEATOI(pChargeInfo["da"])
            p.nGm= SAFEATOI(pChargeInfo["gm"])            
            p.bIc= SAFEATOI(pChargeInfo["ic"])           
            p.nGoodGm = SAFEATOI(pChargeInfo["sgm"])            
			pushTable(self.m_chargeInfoList,p)
			index,pChargeInfo = txml.NextChildElement(index,root,"ChargeInfo")
		end       
    end
    getData(httpCallback,self:getAddress("GetDiamondExchangeList.aspx"),nil)
end

function HallControl:exchangeGold(nDiamond,handle,gameID,useGood)
    if not self:isNetworkAvailable() then return end    
    gameID = gameID or 0
    if self.publicUserInfo.nDiamond < nDiamond then
        if handle then handle(11,0,0) end 
        return
    end
    local szData = string.format("userid=%d&diamond=%d&GameID=%d&pwd=%s&UseGoods=%d",self:getUserDBID(),nDiamond,gameID,
        self.publicUserInfo.encryptPassword,useGood and 1 or 0)
    cclog("exchangeGold %s",szData)
    local function httpCallback(isSucceed,tag,data)
        if(not isSucceed) then cclog("HallControl:exchangeGold() failed") return end
		local root = HallControl.getRootAndResult(data)
		local result= SAFEATOI(root:QueryInt("r")) --操作结果：1=操作成功  11=钻石不足  12=兑换产品不存在
        local nExDiamond= SAFEATOI(root:QueryInt("da")) --兑换后的钻石
        local nGold = SAFEATOI(root:QueryInt("nm")) --兑换后的金币
        self.publicUserInfo.nGold = nGold
        self.publicUserInfo.nDiamond = nExDiamond
        if handle then handle(result,nExDiamond,nGold) end 
    end
    getData(httpCallback,self:getAddress("DiamondExchangeGold.aspx"),szData)
end

function HallControl:startSchedule(handle,fTime)
    local pDirector = CCDirector:sharedDirector()
    self.pmFuncId = pDirector:getScheduler():scheduleScriptFunc(
        function (event)          
            --关闭定时器            
            pDirector:getScheduler():unscheduleScriptEntry(self.pmFuncId)
            --获取充值金额
            self:getRechargeInfo(handle)
        end,
        fTime,
        false
        )
end
--判断充值是否成功
function HallControl:detectionRecharge(handle)
    local nTime =0
    local function onHandle(changed)
        cclog("detectionRecharge changed = %s",changed and "true" or "false")
        if changed then
          if handle then handle(1) end
          return
        end          
        if nTime<60 then
            nTime = nTime+1
            self:startSchedule(onHandle,3)       
        end 
    end
    self:startSchedule(onHandle,3)
end

-- 添加充值记录
function HallControl:addChargeRecord(nDiamondAmount)
    --cclog("HallControl:addChargeRecord %d",nDiamondAmount)
    local index = CCUserDefault:sharedUserDefault():getIntegerForKey("recharge")
    if index==nil or index==0 then       
        index = 1
    else
        index = index + 1        
    end
    CCUserDefault:sharedUserDefault():setIntegerForKey("recharge",index)
    
    local str = string.format("diamond%d",index)
    CCUserDefault:sharedUserDefault():setIntegerForKey(str,nDiamondAmount)
    str = string.format("time%d",index)
    CCUserDefault:sharedUserDefault():setStringForKey(str,require("HallUtils"):getTime())
end
-- 获取充值记录，返回table
function HallControl:getChargeRecords()
    local records = {}
    local count = CCUserDefault:sharedUserDefault():getIntegerForKey("recharge")
    cclog("HallControl:getChargeRecords count = %d",count)
    if count == nil or count == 0 then
        return records
    end
    for i=1,count do
        local record = {}
        record.m_iDiamond = CCUserDefault:sharedUserDefault():getIntegerForKey(string.format("diamond%d",i))
        record.m_sTime = CCUserDefault:sharedUserDefault():getStringForKey(string.format("time%d",i))
        pushTable(records,record)
    end
    return records
end

--[[充值接口 goods 商品信息  onPayHandle  结果回调
参数  resoult  0-充值失败  1-充值成功  11 -成功记录表中已经包含相同的transactionid 12-产品id不能存在
]]
function HallControl:pay(goods,onPayHandle)        
    local function onPayResult(nResult) --充值结果返回
        local str =""
        if  nResult == 1  then           
            --刷新自己的充值金额
            self:getRechargeInfo()        
            --if onPayHandle then onPayHandle(1) end
            self.publicUserInfo.nDiamond = self.publicUserInfo.nDiamond + goods.m_iGm
            --添加充值记录
            self:addChargeRecord(goods.m_iGm)          
        end 
        if onPayHandle then onPayHandle(nResult) end           
    end

    if not self:isAppStore() then    
       	local function onPayEnd(nResult,strProductID)
            cclog("onPayEnd %d,%s",nResult,strProductID)
            if nResult==1 then
                --str="提交充值订单成功!"
                --订单提交成功后检测充值是否成功
                self:detectionRecharge(onPayResult)
                if self:isWIN32() then
                    require("HallLayers/LoadingLayer").HideLoadingLayer()
                end
            else
                 if onPayHandle then onPayHandle(0)  end   
            end
	    end
       
        if CJni:shareJni():getPartnerID() == 219 and goods.m_iRmb <= 200 then
            local function onOther()
                CJni:shareJni():sendPayCommand(self:getUserDBID(),goods.m_iRmb,goods.m_iP,"123",goods.m_iGm,goods.m_cbMt,onPayEnd)
            end
            local function onAipp()
                CJni:shareJni():sendPayCommand(self:getUserDBID(),goods.m_iRmb,goods.m_iP,"",goods.m_iGm,goods.m_cbMt,onPayEnd)
            end
            require("HallLayers/charge/PaySelect").showPaySelect(onOther,onAipp,"resources/new/charge/sms_pay.jpg")
        else
            -- 如果是海马充值，给个提示
            if CJni:shareJni():getPartnerID() == 53 or CJni:shareJni():getPartnerID() == 67 then
                local function onMsgOK()
                    CJni:shareJni():sendPayCommand(self:getUserDBID(),goods.m_iRmb,goods.m_iP,goods.m_iMmp,goods.m_iGm,goods.m_cbMt,onPayEnd)
                end
                Resources.showOKDialog("温馨提示：使用海马币方式充值只能获取一半钻石",onMsgOK)
                return
            end
            --进入充值界面
            CJni:shareJni():sendPayCommand(self:getUserDBID(),goods.m_iRmb,goods.m_iP,goods.m_iMmp,goods.m_iGm,goods.m_cbMt,onPayEnd)
        end
    else
        -- 这里判断是否使用爱贝支付
        local function onAppStore()
            local function onPayEnd(szRecieptLen,szReciept)
                local str =""
                if szRecieptLen>0 then
                    --订单提交成功后检测充值是否成功
                    appleChargeVerify:verifyReceipt(self:getUserDBID(),szReciept,onPayResult,false)
                    --self:verifyReceipt(szReciept,onPayResult)
                else
                    if onPayHandle then onPayHandle(0)    end  
                end
            end
            --进入充值界面
             CJni:shareJni():sendPayCommand(self:getUserDBID(),goods.m_iRmb,goods.m_iP,goods.m_iMmp,goods.m_iGm,0,onPayEnd)
        end

        local function onAipp()
            local function onPayEnd(nResult,strProductID)
                cclog("onAipp PayEnd %d,%s",nResult,strProductID)
                if nResult==1 then                   
                    self:detectionRecharge(onPayResult)
                   
                else
                     if onPayHandle then onPayHandle(0)  end   
                end
            end
            --进入充值界面
            CJni:shareJni():sendPayCommand(self:getUserDBID(),goods.m_iRmb,goods.m_iP,goods.m_iMmp,goods.m_iGm,1,onPayEnd)
        end
        if require("HallUtils").isIAippSupport() then
            -- 弹出对话框选择支付类型
            --require("Resources").showOkCancelDialog("请选择支付方式",onAppStore,onAipp,"AppStore","其他")            
            require("HallLayers/charge/PaySelect").showPaySelect(onAppStore,onAipp)
        else
            onAppStore()
        end
    end        
end

--检测是否有网络网络
function HallControl:isNetworkAvailable()
    --判断网络是否存在
    require("FFSelftools/controltools")
    local Resources =require("Resources")
    local function onExitCallBack(tag,sender)
        CCDirector:sharedDirector():endToLua()
    end
    local function onCancelExitCallBack(tag,sender)

    end

    if not CJni:shareJni():isNetworkAvailable() then
        require("Resources").showOkCancelDialog("网络不太稳定，请检测网络设置",onCancelExitCallBack,onExitCallBack)
        require("HallLayers/LoadingLayer").HideLoadingLayer()         
        return false
	end
    return true
end

-- 启动游戏
function HallControl:launchGame(gameName,logonIP,logonPort,webRoot)
    -- 如果我当前不再大厅界面则不启动游戏
    if self.m_szCurrentGame ~= nil and string.len(self.m_szCurrentGame) > 0 then
        return
    end
    -- 如果是飓风互动，需要延时启动
    if self.m_delayLaunchGame then return end    
    local ok,  ge = pcall(function()
                return require(gameName .. "/GameEntrance")
            end)
    cclog(gameName .. "/GameEntrance")
    if ok then 
        ge.run(self,logonIP,logonPort,webRoot)
        self.m_szCurrentGame = gameName
        return true
    else
        GameConfig.removeGame(gameName)
    end
    return false    
end



-- 返回大厅
function HallControl:backToHall()
    require("CocosLib/AudioEngine")
    if self.m_szCurrentGame ~= nil and string.len(self.m_szCurrentGame) > 0 then
        for k,_ in pairs(package.loaded) do 
            if string.find(k,self.m_szCurrentGame) == 1 then                
                package.loaded[k] = nil
                --cclog("unloading %s",k)
            end
        end
    end

    --[[for k,v in pairs(package.loaded) do
        cclog("loaded:%s,%s",k,v)
    end]]

    self.m_szCurrentGame = ""
   
    if (AudioEngine.isMusicPlaying() == true) then
        AudioEngine.stopMusic(true)
	end
    AudioEngine.stopAllEffects()
   
    --pDirector:getOpenGLView():setDesignResolutionSize(480, 800,kResolutionExactFit)

    require("HallLayers/HallPlatformLayer").createScene(true)
end

function HallControl:gotoLoginPage()
    CCDirector:sharedDirector():replaceScene(require("HallLayers/login/LoginLayer").createScene())
end

function HallControl:upgradeHall(onUpgradeHallEnd)    
    if not self.m_bPlatformUpgrade then
        self:onUpgradeHallEnd()
        return
    end
    local function onUpgradeCancel()        
        self:onUpgradeHallEnd()
        return
    end

    local function onUpgradeFinished()
        -- 这里需要卸载hall相关的模块，重新加载
        for k,_ in pairs(package.preload) do            
            if string.find(k,"HallLayers") == 1 then                   
                package.preload[k] = nil            
            end
        end
        for k,_ in pairs(package.loaded) do        
            if string.find(k,"HallLayers") == 1 then                   
                package.loaded[k] = nil            
            end
        end
        package.preload["HallControl"] = nil
        package.preload["GameConfig"] = nil
        package.loaded["HallControl"] = nil
        package.loaded["GameConfig"] = nil
        require("HallControl"):start(true)
    end    
    CCDirector:sharedDirector():replaceScene(require("HallLayers/UpgradeHall").createScene(
        self.m_szDownloadURL,self.m_version,onUpgradeCancel,onUpgradeFinished))
end

function HallControl:onUpgradeHallEnd()
    cclog("HallControl:onUpgradeHallEnd()")
    -- 如果是WIN32 则跳转至登陆界面
    if self:isWIN32() then
        -- 是否直接进入游戏
        self:requestDirectInGame()       
        self:gotoLoginPage()
        return
    end

    if not self:isAppStore() then
    -- 显示欢迎界面
        CCDirector:sharedDirector():replaceScene(require("HallLayers/WelcomeLayer").createScene())
    end
    -- 是否直接进入游戏
    self:requestDirectInGame()       

    -- 是否开放平台？
    local function onLogonOpenPlatform(result,userid,userName)
        if result == 1 then 
            self:loginByIMEI(userid,userName)
            
            if self:isJufengPlatform() then
                cclog("isJufengPlatform")
                self.m_delayLaunchGame = true                
                local pDirector = CCDirector:sharedDirector()

                self.pmFuncId1 = pDirector:getScheduler():scheduleScriptFunc(
                function (event)          
                    --关闭定时器  
                    cclog("onDelayEvent")          
                    pDirector:getScheduler():unscheduleScriptEntry(self.pmFuncId1)
                    self.m_delayLaunchGame = false                    
                end,
                5,
                false
             )
            end
        else
            CJni:shareJni():logonOpenPlatform(onLogonOpenPlatform)
        end
    end

    -- 是否QQ登陆
    local qqLogin = CCUserDefault:sharedUserDefault():getStringForKey("QQLogin")
    if qqLogin ~= nil and qqLogin ~= "" then
        local function onQQLogin(openID,nickname)
            self:loginByIMEI(openID,nickname,true)
        end
        CJni:shareJni():QQLogin(onQQLogin)
        return
    end

    if not CJni:shareJni():logonOpenPlatform(onLogonOpenPlatform) then
        local str =CCUserDefault:sharedUserDefault():getStringForKey("account")
        if str~=nil and str ~="" then
            self:loginByEmail(str,CCUserDefault:sharedUserDefault():getStringForKey("password"),true)        
        else
            self:loginByIMEI(CJni:shareJni():getIMEI(),CJni:shareJni():getDeviceName())
        end
    end  
end

function HallControl:onFlashEnd()
    -- 如果大厅需要提示升级，则弹出下载界面
    local function onUpgradeHallEnd()
        self:onUpgradeHallEnd()
    end
    self:upgradeHall(onUpgradeHallEnd)    
end

-- 大厅启动函数
function HallControl:start(restart)  
    cclog("%s",HallControl.webRoot)
    -- 先初始化游戏配置    
    require("GameConfig")
    GameConfig.init()    
    local function onFlashEnd()
        self:onFlashEnd()  
    end

    local table = {}
    table["info"] = "myinfo"
    local jsonstr = json.encode(table)
    cclog("%s",jsonstr)
    local data = json.decode(jsonstr);
    cclog("%s",data.info)

     -- 获取并更新大厅信息   
    self:getPlatformInfo()
    if restart then
        CCDirector:sharedDirector():replaceScene(require("HallLayers/FlashLayer").createScene(onFlashEnd))
    else
        CCDirector:sharedDirector():runWithScene(require("HallLayers/FlashLayer").createScene(onFlashEnd))
    end
end

-- 登陆成功，进行关键数据的加载
function HallControl:onLoginSuccess()
     --获取玩家充值金额
    self:getRechargeInfo()
    -- 获取游戏列表
    self:requestGameList()
    -- 获取充值列表
    self:requestShoppingList()
    -- 获取兑换列表
    self:requestEXchangeList()
    -- 获取vip列表
    require("HallWebRequest").requestVipInfo()
    -- 开始轮询状态
    require("HallWebRequest").checkNewStatus()
end

-- 登陆完成
function HallControl:onLoginFinished()
    --加载关键信息，在加载完游戏列表后，才进入主界面
    if not self:directInGame() then
        require("HallLayers/HallPlatformLayer").createScene()
    end

    if self:isAppStore() then
        appleChargeVerify:retryWhenLogin()       
    end
end

-- 登陆失败
function HallControl:onLoginFailed(failedType)
    local scene = CCDirector:sharedDirector():getRunningScene()
    if failedType == nil or failedType ~= -1 then
        local DialogMessage = require("FFSelftools/MessageLayer").create("登陆游戏失败，账号或密码错误")
        scene:addChild(DialogMessage)
        return
    end

    if failedType == -1 then
        local function onOKCallBack()
            self:gotoLoginPage()
        end
        local str ="对不起，您的账号因违规处于封禁状态\n，请使用其他帐号或寻求客服帮助"
        local pOkSprite = createButtonWithFilePath(Resources.Img_Hall_ButtonYes,1)
        local pCancelSprite = createButtonWithFilePath(Resources.Img_Hall_Cancel,1)
        local DialogMessage =require("FFSelftools/DialogLayer").create(Resources.Img_Hall_ChangeNameDilogBox,str,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,
                                                pOkSprite,pCancelSprite,onOKCallBack,onOKCallBack,ccc3(0x23,0x84,0xef))
        scene:addChild(DialogMessage)
    end
end

function HallControl:requestDirectInGame()
    self.m_szDirectInGame = ""
    local function httpCallback(isSucceed,tag,data)
        if(not isSucceed) then cclog("HallControl:requestDirectInGame() failed") 
            self.m_szDirectInGame = "hall"
            return 
        end
        self.m_szDirectInGame = data
        if self:isAppStore() then         
            if string.len(data) <= 0 then
                -- 显示欢迎界面
                CCDirector:sharedDirector():replaceScene(require("HallLayers/WelcomeLayer").createScene())
            else
                 -- app store版本删除掉已下载的游戏
                if data ~= "hall" then
                    GameConfig.removeGame(self.m_szDirectInGame)
                end
            end
        end
    end
    local szData = string.format("PartnerID=%d&VersionCode=%d",CJni:shareJni():getPartnerID(),CJni:shareJni():getVersionCode())
    -- cclog(szData)
    getData(httpCallback,self:getAddress("IsDirectInGame.aspx"),szData)
end

-- 是否直接进入游戏
function HallControl:directInGame()
    if not self:isDirectInGame() then return false end
    
    --self:launchGame(gameName, logonIP, logonPort, webRoot)
    -- 找到游戏信息
    for _,config in pairs(self.m_gameList) do
        if config.m_sEn == self.m_szDirectInGame then
            self:launchGame(config.m_sEn,config.m_sServeIp,config.m_iPort,config.m_sWr)
            return true
        end
    end
    return true
end

-- 是否直进入游戏
function HallControl:isDirectInGame()
    return false
end

function HallControl:isWIN32()
    --if true then return false end
    local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
    return targetPlatform == kTargetWindows
end

-- 是否苹果官方版本
function HallControl:isIOS()
    local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
    return targetPlatform == kTargetIphone or targetPlatform == kTargetIpad
end

function HallControl:isAppStore()    
    if not self:isIOS() then return false end
    local nPartnerID = CJni:shareJni():getPartnerID()
    return nPartnerID == 1 or nPartnerID == 11 or nPartnerID == 31 or nPartnerID == 10 or (nPartnerID >= 19 and nPartnerID < 24)
end

function HallControl:isJufengPlatform()
    local nPartnerID = CJni:shareJni():getPartnerID()
    return nPartnerID == 7 or nPartnerID == 17
end

-- 切换游戏，切换前请先调用m_gameLib:release()
function HallControl:changeGame(newGameName)
    local curGameName = self.m_szCurrentGame
    if curGameName == nil or newGameName == nil then
        return
    end
    if curGameName == newGameName then
        return
    end
    -- 找到游戏
    local gameConfig = nil
    for _,config in pairs(self.m_gameList) do
        if config.m_sEn == newGameName then
            gameConfig = config
            break
        end
    end
    if gameConfig == nil then
        return
    end

    -- 先卸载掉当前游戏
    for k,_ in pairs(package.loaded) do 
        if string.find(k,self.m_szCurrentGame) == 1 then                
            package.loaded[k] = nil            
        end
    end    

    self:launchGame(gameConfig.m_sEn,gameConfig.m_sServeIp,gameConfig.m_iPort,gameConfig.m_sWr)
end

-- 临时切换至测试服
function HallControl:changeToTestEnv()
    HallControl.webRoot = require("Domain").TestWebRoot
    self:start(true)
end

function HallControl.isInReview()    
    local self = HallControl:instance()
    if not self:isAppStore() then
        return false
    end
    return self.m_szDirectInGame ~= nil and string.len(self.m_szDirectInGame) > 0
end

function HallControl.isNoLotery()
    local partnerID = CJni:shareJni():getPartnerID()
    return partnerID == 219 or partnerID == 221
end

-- 不要在此类中添加函数
return HallControl
