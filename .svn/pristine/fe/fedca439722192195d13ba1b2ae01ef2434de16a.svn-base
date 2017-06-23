--LayerChat.lua
local AppConfig = require("AppConfig")
local CommonInfo = require("czmj/GameDefs").CommonInfo
local CCButton = require("FFSelftools/CCButton")

require("GameLib/common/common")

local LayerChat=class("LayerChat",function()
        return CCLayerColor:create(AppConfig.COLOR.ColorLayer_Bg) --AppConfig.COLOR.ColorLayer_Bg
    end)

function LayerChat:hide() 
    require("Lobby/Common/AnimationUtil").spriteScaleHideAction(self.panel_bg, function()
        self.clickTable[1].m_actionCallBack(1, self.clickTable[1])
        self:setVisible(false)
        self:setTouchEnabled(false)
    end, 1)
end

function LayerChat:show()
    self:setVisible(true)
    self.clickTable[1].m_actionCallBack(1, self.clickTable[1])

    require("Lobby/Common/AnimationUtil").spriteScaleShowAction(self.panel_bg, function()
        self:setTouchEnabled(true)
    end, 1)
    return self    
end

-- 选择标签
function LayerChat:selectPanel(sender)
    if layerChat and layerChat.view then
        local i = sender.id
        if i ~= layerChat.currentPanel then
            layerChat.currentPanel = i
            -- 改变标签状态
            for j = 1, 3 do
                local opt = layerChat.options["opt"..j]
                local s = (i == opt.id) and "czmj/labelbg%d_selected.png" or "czmj/labelbg%d_normal.png"
                opt:setNormalImage(loadSprite(string.format(s, j)))
            end
            layerChat:createDetail(i)
        end
    end
end


function LayerChat:addEmoteDetail()
    local titleBg, tableView, z, bgsz = self:addTableView(ccp(0, 1), ccp(34, self.bgSize.height - 35))

    local titleSz = titleBg:getContentSize()
    local title = loadSprite("czmj/chatLab1.png")
    title:setPosition(ccp(titleSz.width / 2, titleSz.height / 2))
    titleBg:addChild(title)

    tableView:setCellSizeFunc(function(tableView,idx) return 90,bgsz.width end)
    tableView:setNumberOfCellsFunc(function() return 7 end)
    tableView:setCreateCellFunc(function(idx)
        local path = AppConfig.ImgFilePathName
        local layer = CCLayer:create()
        for j = 1, 4 do
            local k = idx*4 + j
            local sp = string.format("emote/emote%d-1.png", k)
            local btn = CCButton.createWithFrame(sp,false, function(e,s)
                LayerChat.sendMsg(1, k)
            end)
            btn:resetTouchPriorty(z, false)
            btn:setPosition(ccp(j*90-35,45))
            btn.id = k
            layer:addChild(btn)
        end
        return layer
    end)

    tableView:updataTableView()
end

function LayerChat:updataQuickChat()

end

-- 生成内容列表
function LayerChat:addChatDetail()
    local titleBg, tableView, z, bgsz = self:addTableView(ccp(1, 1), ccp(self.bgSize.width - 34, self.bgSize.height - 35))

    local titleSz = titleBg:getContentSize()
    local title = loadSprite("czmj/chatRTitleBg.png")
    title:setPosition(ccp(titleSz.width / 2, titleSz.height / 2))
    titleBg:addChild(title)

    local function showChat(index)
        if index == 1 then
            local quickChatCfg = AppConfig.quickChat[require("czmj/Game/LayerGamePlayer").lan_set]

            tableView:setCellSizeFunc(function(tableView,idx) return 74,bgsz.width end)
            tableView:setNumberOfCellsFunc(function() return #quickChatCfg end)
            tableView:setCreateCellFunc(function(idx)
                local AppConfig = require("AppConfig")
                local layer = CCLayer:create()
                if idx < #quickChatCfg - 1 then
                    local sp = loadSprite("czmj/split.png")
                    sp:setPosition(ccp(bgsz.width / 2, 2))
                    layer:addChild(sp)
                end

                local quickIndex = idx + 1
                local btn = CCControlButton:create(quickChatCfg[quickIndex], "" , 24)
                btn:setPreferredSize(CCSizeMake(bgsz.width,0))
                btn:setAnchorPoint(ccp(0.5,0.5))
                btn:setPosition(ccp(bgsz.width / 2, 30))
                btn:setTouchPriority(z)
                btn:addHandleOfControlEvent(function(sender)
                    LayerChat.sendMsg(2, quickIndex)
                end, CCControlEventTouchUpInside)
                layer:addChild(btn)
                return layer
            end)
        else
            tableView:setCellSizeFunc(function(tableView,i) return 60,bgsz.width end)
            tableView:setNumberOfCellsFunc(function()
                local s = layerChat.chatHistory and #layerChat.chatHistory or 0
                return s
            end)
            tableView:setCreateCellFunc(function(idx)
                local r = require(CommonInfo.GameLib_File).game_lib._gameRoom
                local uid, udbid = r.m_mySelf:getUserID(), r.m_mySelf:getUserDBID()
                local chat = layerChat.chatHistory[idx+1]
                if chat then
                    local labelVal = CCNode:create()
                    for k, v in pairs(chat) do
                        local chair = require("czmj/Game/GameLogic"):getInstance():getRelativeChair(k)
                        local name = r:getUser(k):getUserName()
                        labelVal = CCLabelTTF:create(string.format("%s说:%s",name,tostring(v)) , "" ,24)
                        labelVal:setHorizontalAlignment(kCCTextAlignmentLeft)
                        labelVal:setDimensions(CCSizeMake(bgsz.width, 0))
                        labelVal:setAnchorPoint(ccp(0,0.5))
                        labelVal:setPosition(ccp(6, 30))
                        if k == uid then labelVal:setColor(ccc3(255,210,0)) end
                        break
                    end
                    return labelVal
                else
                    return CCNode:create()
                end
            end) 
        end

        tableView:updataTableView()

        self.clickIndex = index
    end

    --添加标题切换按钮
    self.clickTable = {}
    local poses = {ccp(titleSz.width / 2 - 85, titleSz.height - 29), ccp(titleSz.width / 2 + 85, titleSz.height - 29)}
    for i,v in ipairs(poses) do
        local btn = CCButton.put(titleBg, CCButton.createCCButtonByFrameName("czmj/chatLab"..(i + 1).."_normal.png", 
        "czmj/chatLab"..(i + 1).."_select.png", "czmj/chatLab"..(i + 1).."_select.png", function(tag, target)
            for j,w in ipairs(self.clickTable) do
                w:setEnabled(true)
                w:getChildByTag(10):setVisible(false)
            end

            target:setEnabled(false)
            target:getChildByTag(10):setVisible(true)
            showChat(i)
        end), v, self.layer_zIndex + 1)

        local btnSp =  loadSprite("czmj/chatRTitle.png")
        btn:addChild(btnSp, -2, 10)
        btnSp:setVisible(false)
        table.insert(self.clickTable, btn)
    end 

    self.clickTable[1]:setEnabled(false)
    self.clickTable[1]:getChildByTag(10):setVisible(true) 
    showChat(1)  
end

-- 生成内容列表
function LayerChat:addTableView(ancpos, pos)
    local bgsz = CCSizeMake(386, 432)

    -- 背景框
    local viewbg = loadSprite("czmj/chatInnerBg.png", true)
    viewbg:setPreferredSize(bgsz)
    viewbg:setAnchorPoint(ancpos)
    viewbg:setPosition(pos)
    self.bg:addChild(viewbg)

    local z = kCCMenuHandlerPriority - self.layer_zIndex - 1

    -- 详细内容
    local tableView = require("Lobby/Common/LobbyTableView").createCommonTable(
        CCSizeMake(bgsz.width, bgsz.height - 60), ccp(0, 5), z)
    viewbg:addChild(tableView)

    --添加标题
    local titleBg = loadSprite("czmj/chatLTitle.png")
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(ccp(bgsz.width / 2, bgsz.height - 3))
    viewbg:addChild(titleBg)

    return titleBg, tableView, z, bgsz
end

function LayerChat.sendMsg(m, n)
    local r = require(CommonInfo.GameLib_File).game_lib._gameRoom
    if m == 1 then
        if n > 0 and n < 29 then
            r:sendChat(string.format('@EMOTE|%s',n), false)
        end
        layerChat:hide()
    elseif m == 2 then
        if n > 0 and n < 11 then
            r:sendChat(string.format('@QUICK|%s',n), false)
        end
        layerChat:hide()
    else
        if length(n) > 0 then
            r:sendChat(string.format('@TEXTC|%s',subStr(n,1,20)), false)
            layerChat:hide()
        end
    end
end

function LayerChat:init()
    self:setVisible(false)
    local screenMidx = AppConfig.SCREEN.CONFIG_WIDTH/ 2
    local screenMidy = AppConfig.SCREEN.CONFIG_HEIGHT/ 2
    local z = kCCMenuHandlerPriority - self.layer_zIndex - 2
    
    self.bgSize = CCSizeMake(850, 570)
    self.currentPanel = 0
    
    -- 背景框
    self.panel_bg = CCLayer:create()
    self:addChild(self.panel_bg)
    self.bg = loadSprite("czmj/chatBg.png", true)
    self.bg:setPreferredSize(self.bgSize)
    self.bg:setPosition(ccp(screenMidx, screenMidy-18))
    self.panel_bg:addChild(self.bg)
    
    self:addEmoteDetail()

    self:addChatDetail()
    
    -- 输入ui
    local input = CCEditBox:create(CCSizeMake(620,50), loadSprite("common/input.png", true))
    input:setPosition(ccp(self.bgSize.width / 2 - 70, 70))
    input:setFontSize(24)
    input:setFontColor(ccc3(0,0,0))
    input:setTouchPriority(z)
    self.bg:addChild(input)
    self.input = input
    local btn_input = CCControlButton:create(loadSprite("czmj/btn_send.png", true))
    btn_input:setBackgroundSpriteForState(loadSprite("czmj/btn_send_press.png", true), CCControlStateHighlighted)
    btn_input:setPosition(ccp(self.bgSize.width - 110, 68))
    btn_input:setPreferredSize(CCSizeMake(146,68))
    btn_input:setTouchPriority(z)
    btn_input:addHandleOfControlEvent(function(sender)
        LayerChat.sendMsg(3, layerChat.input:getText())
        layerChat.input:setText("")
    end, CCControlEventTouchUpInside)
    self.bg:addChild(btn_input)
    self.btn_input = btn_input
    
    self.chatList = {{},{},{}}
    
    self.chatHistory = {}
    
    --self:selectPanel({id=2})
    
    -- 注册事件
    self:registerScriptTouchHandler(function(eventType, x, y)
        local s = layerChat.bgSize
    if eventType == "began" then
            if (x < screenMidx - s.width /2) or (
                x > screenMidx + s.width /2) or (
                y < screenMidy - s.height/2) or (
                y > screenMidy + s.height/2) then
                layerChat:hide()
            end
            return true
        end
    end, false, kCCMenuHandlerPriority - self.layer_zIndex, true)
end

function LayerChat.put(super, zindex)
    layerChat = LayerChat.new(zindex)
    layerChat.layer_zIndex = zindex
    layerChat:init()
    super:addChild(layerChat, zindex)
    return layerChat
end

return LayerChat