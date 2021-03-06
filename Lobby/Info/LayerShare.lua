--LayerShare.lua
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")

local LayerShare=class("LayerShare",function(super, zindex)
    return require("Lobby/LayerPopup").put(super, zindex)
end)

function LayerShare:initShare()
    --添加背景
    self:addFrameBg("common/popBg.png", CCSizeMake(500, 300))

    --添加标题
    local title =  loadSprite("lobbyDlg/share.png")
    title:setPosition(ccp(self.bg_sz.width / 2, self.bg_sz.height - 60))
    self.panel_bg:addChild(title)         
    
    --添加分享
    local imgs = {"lobbyDlg/group.png", "lobbyDlg/circle.png"}
    local pos = ccp(self.bg_sz.width / 2 - 300, self.bg_sz.height / 2 - 32)
    for i,v in ipairs(imgs) do
        putControltools(self.panel_bg, createButtonWithOneStatusFrameName(v, nil, function()
            self:shareWxWeb(i)
        end), ccp(pos.x + 200 * i, pos.y), self.btn_zIndex)
    end  
end

function LayerShare:shareWxWeb(wxType)
    local LoginLogic = require("Lobby/Login/LoginLogic")

    local textMsg = AppConfig.WXMsg.App_Context
    local titleMsg = string.format(AppConfig.WXMsg.App_Title, tostring(LoginLogic.UserInfo.NewNickName))

    -- 获取用户代理信息
    LoginLogic.getSubmitResult(function(code, msg, t)
        local tcode
        if code == 0 and t[1] and 1 == t[1].Status then tcode = t[1].TGCode end
        if tcode then
            titleMsg = titleMsg .. string.format("，填写邀请码【%s】送8颗钻石", tostring(tcode))
        else
           -- titleMsg = titleMsg .. "，随时随地玩一局"
        end

        shareWebToWx(wxType, AppConfig.WXMsg.App_Url, titleMsg, textMsg, function(result)
            if result == "true" then
                local szData = string.format("UserID=%d&ShareType=%d&ShareContent=",LoginLogic.UserInfo.UserID, wxType)
                require("GameLib/common/WebRequest").getData(nil,"UserWeiXinShare.aspx",szData)
                cclog("分享微信成功")
            end
        end)
        self:hide()        
    end) 
end

function LayerShare.put(super, zindex)
    local layer = LayerShare.new(super, zindex)
    layer:initShare()
    return layer
end

return LayerShare