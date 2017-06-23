--LobbyLogic.lua
local LobbyLogic = {}
LobbyLogic.__index = LobbyLogic

local WebRequest = require("GameLib/common/WebRequest")
local json = require("CocosJson")

local HallUtils = require("HallUtils")
local GameConfig = require("GameConfig")
local AppConfig = require("AppConfig")
local LoginLogic = require("Lobby/Login/LoginLogic")

function LobbyLogic.checkGameUpdata()
    local upgrade = require("LobbyControl").platform_upgrade
    if upgrade and upgrade > 0 and upgrade < 3 then
        --大厅已更新，重新登录
        for k,_ in pairs(package.preload) do            
            if string.find(k,"Lobby") == 1 then                   
                package.preload[k] = nil            
            end
        end
        for k,_ in pairs(package.loaded) do        
            if string.find(k,"Lobby") == 1 then                   
                package.loaded[k] = nil            
            end
        end

        package.preload["LobbyControl"] = nil
        package.preload["GameConfig"] = nil
        package.loaded["LobbyControl"] = nil
        package.loaded["GameConfig"] = nil
        require("LobbyControl").reStart()        
        return false
    end

    return true
end

--1.土豪榜；2.消耗榜
function LobbyLogic.getRankList(rankType, func)
    local szData = string.format("UserID=%d&RankType=%d", LoginLogic.UserInfo.UserID, rankType)
    local function httpCallback(isSucceed,tag,data)
        --解析数据
        local isvilad, code, msg, table = WebRequest.parseData(isSucceed, data)
        if isvilad then
            if code == 0 then 
                if #table >= 1 then
                    func(table)
                else
                    msg = "当前排行榜尚未刷新"
                end
            end
            
            require("HallUtils").showWebTip(msg)            
        end 
    end
    
    WebRequest.getData(httpCallback,"GetRankList.aspx",szData, 1)
end

--获取系统消息列表
function LobbyLogic.getSysMessageList(func)
    local szData = string.format("UserID=%d", LoginLogic.UserInfo.UserID)
    local function httpCallback(isSucceed,tag,data)
        --解析数据
        local isvilad, code, msg, table = WebRequest.parseData(isSucceed, data)
        if isvilad then
            cclog(data)
            if code ~= 0 and msg and #msg > 0 then 
                --获取失败
                require("HallUtils").showWebTip(msg)
                return
            end

            func(table)
        end 
    end
    
    WebRequest.getData(httpCallback,"GetSysMessageList.aspx",szData,2,"GetSysMessageList")
end

--删除系统消息
function LobbyLogic.deleteGiftSysMessageTool(msgID)
    local szData = string.format("UserID=%d&SysMsgID=%d", LoginLogic.UserInfo.UserID, msgID)
    -- cclog(szData)
    local function httpCallback(isSucceed,tag,data)
        --解析数据
        local isvilad, code, msg, table = WebRequest.parseData(isSucceed, data)
        if isvilad then
            cclog(data)
            if code ~= 0 then 
                --获取失败
                require("HallUtils").showWebTip(msg)
                return
            end
        end 
    end
    
    WebRequest.getData(httpCallback,"DelSysMessage.aspx",szData,1)
end

--查找好友
function LobbyLogic.getFriendInfoByName(szName)
    if (not szName) or (string.len(szName) < 1) then
        return
    end

    local szData = string.format("NickNameOrID=%s", szName)
    -- cclog(szData)
    local function httpCallback(isSucceed,tag,data)
        --解析数据
        local isvilad, code, msg, table = WebRequest.parseData(isSucceed, data)
        if isvilad then
            cclog(data)
            if code ~= 0 then 
                require("HallUtils").showWebTip(msg)
                return
            end

            --UserID  int Y   用户ID
            --NickName    string  Y   昵称
            --ServerName  string  y   当前所在服务器
            --VIPLevel    int Y   VIP级别
            --FaceID  int Y   头像ID
            --Gold    int Y   金币数
            --Sex int y   性别 1.男；非1.女
            --Changed Int Y   脸谱变化
        end
    end

    WebRequest.getData(httpCallback,"GetApplyFriendByName.aspx",szData)
end

return LobbyLogic
