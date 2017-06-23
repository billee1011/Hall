--LayerInfo.lua
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")

local LayerInfo=class("LayerInfo",function(super, zindex)
    return require("Lobby/LayerPopup").put(super, zindex)
end)


function LayerInfo:initRankPlayer(faceSp, name, uerid)
    self.btn_zIndex = self.layer_zIndex + 1

    local bgsz = CCSizeMake(702, 320)
    self:addFrameBg("common/popBg.png", bgsz)

    faceSp = require("FFSelftools/CCUserFace").clone(faceSp, CCSizeMake(140,140))
    local faceBg, sz = LayerInfo.createLogo(faceSp)
    faceBg:setPosition(ccp(140, bgsz.height/2))
    self.panel_bg:addChild(faceBg)

    --昵称、id
    local tipPos = ccp(305, bgsz.height - 30)
    local imgs = {"common/info_name_ttf.png", "common/info_id_ttf.png"}
    local msgs = {name, ""..uerid}                
    for i,v in ipairs(imgs) do
        local pos = ccp(tipPos.x, tipPos.y - 60 * i)
        self:addItemInfo(pos, v, msgs[i])
    end

    self:addStaticSignature(ccp(tipPos.x, tipPos.y - 180), "")
end

function LayerInfo:initPlayer(faceSp, name, uerid, ip, addInfo)
    self.btn_zIndex = self.layer_zIndex + 1

    local bgsz = CCSizeMake(702, 320)
    self:addFrameBg("common/popBg.png", bgsz)

    local face = require("FFSelftools/CCUserFace").clone(faceSp, CCSizeMake(140,140))
    self:addInfo(face, name, uerid, ip,
        ccp(140, bgsz.height - 120), ccp(305, bgsz.height - 10), 45)

    self:addStaticSignature(ccp(305, bgsz.height - 230), addInfo.UserWords)
end

function LayerInfo:initInfo() 
    self.btn_zIndex = self.layer_zIndex + 1

    local bgsz = CCSizeMake(702, 320)
    self:addFrameBg("common/popBg.png", bgsz)

    local info = require("Lobby/Login/LoginLogic").UserInfo
    local faceSp = require("FFSelftools/CCUserFace").create(info.UserID, CCSizeMake(140,140), info.Sex)
    self:addInfo(faceSp, info.NewNickName, info.UserID, info.IPAddress,
        ccp(140, bgsz.height - 120), ccp(305, bgsz.height - 10), 45)

    self:addSignatureInfo(ccp(305, bgsz.height - 230), info.UserWords)
    
    --输入标示
    local mark = loadSprite("lobby/pen_mark.png")
    mark:setPosition(ccp(640, 72))
    self.panel_bg:addChild(mark, 1)  
    --切换按钮
    CCButton.put(self.panel_bg, CCButton.createCCButtonByFrameName("common/set_account_btn1.png", 
            "common/set_account_btn2.png", "common/set_account_btn1.png", function()
                self:hide(function() require("LobbyControl").onFlashEnd(1) end)
            end), ccp(140, 80), self.btn_zIndex)
end

function LayerInfo:addInfo(faceSp, name, dbid, ip, logoPos, tipPos, space)
    space = space or 60

    local faceBg, sz = LayerInfo.createLogo(faceSp)
    faceBg:setPosition(logoPos)
    self.panel_bg:addChild(faceBg)

    --昵称、id、ip
    local imgs = {"common/info_name_ttf.png", "common/info_id_ttf.png", "common/info_ip_ttf.png"}
    local msgs = {name, ""..dbid, ip}
    local templab                
    for i,v in ipairs(imgs) do
        local pos = ccp(tipPos.x, tipPos.y - space * i)
        templab = self:addItemInfo(pos, v, msgs[i])
    end

    local iptxt = (string.gsub(""..ip,"%(", "\n"))
    if iptxt and iptxt ~= ip then
        iptxt = (string.gsub(iptxt,"%)", "\n"))
        local oldSz = templab:getContentSize()
        --存在地址参数
        templab:setString(iptxt)
        local newSz = templab:getContentSize() 
        templab:setPositionY(templab:getPositionY() - (newSz.height - oldSz.height) / 2)
    end
end

function LayerInfo:addStaticSignature(pos, msg)
    local editTTf, labTTf = self:addSignatureInfo(pos, msg)
    editTTf:setTouchEnabled(false)
    labTTf:setColor(ccc3(0x8a,0x0a,0x0a))
end

function LayerInfo:updateUserWords(wordMsg)
    if wordMsg == "" then
        wordMsg = "这家伙太懒了，一片云彩都没留下"
    end

    self.panel_bg.signatureLab:setString(wordMsg)
    self.panel_bg.signatureEdit:setText(" ")
end

function LayerInfo:addSignatureInfo(pos, msg)
    local mark = loadSprite("common/info_signature_ttf.png", true)
    mark:setAnchorPoint(ccp(1, 0.5))
    mark:setPosition(pos)
    self.panel_bg:addChild(mark)  

    --输入控件
    local inputBg = loadSprite("common/popBorder.png", true)
    local bgsz = CCSizeMake(340, 72)
    inputBg:setPreferredSize(bgsz)

    local labItem, signatureEdit = CCLabelTTF:create("这家伙太懒了，一片云彩都没留下", AppConfig.COLOR.FONT_ARIAL, 26)
    labItem:setColor(AppConfig.COLOR.MyInfo_Record_Label)        
    labItem:setAnchorPoint(ccp(0, 1))
    labItem:setDimensions(CCSizeMake(bgsz.width-10, 0))
    labItem:setHorizontalAlignment(kCCTextAlignmentLeft)
    labItem:setPosition(ccp(pos.x + 30, pos.y + 32))

    signatureEdit = require("Lobby/Common/LobbyEditBox").createMaxWidthEdit(bgsz, inputBg,
            ccp(pos.x + 20, pos.y + 30), kCCMenuHandlerPriority - self.btn_zIndex, 
            "这家伙太懒了，一片云彩都\n没留下                                  ", "")
            :setEditFont(AppConfig.COLOR.FONT_ARIAL, 26)
            :setEditMaxText(24)
            :setEditBeginFunc(function() 
                local textStr = labItem:getString()
                if textStr ~= "" then
                    signatureEdit:setText(textStr)
                end
            end)
            :setEditEndFunc(function(text) 
                if text ~= "" then
                    signatureEdit:setText(" ")
                    labItem:setString(text)
                end

                require("Lobby/Login/LoginLogic").updateUserWords(text, function(userWord)
                    self:updateUserWords(userWord)
                end)           
            end)
            
    self.panel_bg:addChild(signatureEdit)
    signatureEdit:setAnchorPoint(ccp(0, 1))
    self.panel_bg.signatureEdit = signatureEdit

    self.panel_bg:addChild(labItem) 
    self.panel_bg.signatureLab = labItem

    self:updateUserWords(msg)

    return signatureEdit, labItem
end

function LayerInfo:addItemInfo(pos, markImg, msg)
    local mark = loadSprite(markImg)
    mark:setAnchorPoint(ccp(1, 0.5))
    mark:setPosition(pos)
    self.panel_bg:addChild(mark)

    local labItem = CCLabelTTF:create(msg, AppConfig.COLOR.FONT_ARIAL, 26)
    labItem:setColor(AppConfig.COLOR.MyInfo_Record_Label)        
    labItem:setHorizontalAlignment(kCCTextAlignmentLeft)
    labItem:setAnchorPoint(ccp(0, 0.5))
    labItem:setPosition(ccp(pos.x + 20, pos.y))
    self.panel_bg:addChild(labItem)  

    return labItem
end

function LayerInfo.createLogo(faceSp)
    --头像
    local faceBg = loadSprite("common/user_face_bg.png")
    local sz = faceBg:getContentSize()

    faceSp:setPosition(ccp(sz.width / 2, sz.height / 2))
    faceBg:addChild(faceSp, -1)

    --性别
    local spriteSex = loadSprite("common/sex_man.png")
    if faceSp.sex ~= 1 then
        spriteSex = loadSprite("common/sex_woman.png")
    end
    spriteSex:setAnchorPoint(ccp(1, 0))
    faceBg:addChild(spriteSex)
    spriteSex:setPosition(ccp(sz.width - 15, 8))
    -- spriteSex:setScale(0.8)

    return faceBg, sz
end

function LayerInfo.put(super, zindex)
    local layer = LayerInfo.new(super, zindex)

    layer:initInfo()
    return layer
end

function LayerInfo.putPlayer(super, zindex, faceSp, name, uerid, ip, addInfo)
    local layer = LayerInfo.new(super, zindex)

    layer:initPlayer(faceSp, name, uerid, ip, addInfo)
    return layer
end

function LayerInfo.putRankPlayer(super, zindex, faceSp, name, uerid)
    local layer = LayerInfo.new(super, zindex)

    layer:initRankPlayer(faceSp, name, uerid)
    return layer
end

return LayerInfo