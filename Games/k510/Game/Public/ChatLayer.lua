--ChatLayer.lua
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")
local SetLogic = require("Lobby/Set/SetLogic")

require("GameLib/common/common")

local ChatLayer=class("ChatLayer",function()
        return CCLayerColor:create(AppConfig.COLOR.ColorLayer_Bg) --AppConfig.COLOR.ColorLayer_Bg
    end)

function ChatLayer:hide() 
    require("Lobby/Common/AnimationUtil").spriteScaleHideAction(self.panel_bg, function()
        self:setVisible(false)
        self:setTouchEnabled(false)
    end, 1)
end

function ChatLayer:show()
    self.clickTable[1].m_actionCallBack(1, self.clickTable[1])
    self:setVisible(true)
    require("Lobby/Common/AnimationUtil").spriteScaleShowAction(self.panel_bg, function()
        self:setTouchEnabled(true)
    end, 1)
    return self    
end

-- 选择标签
function ChatLayer:selectPanel(sender)
    if chatLayer and chatLayer.view then
        local i = sender.id
        if i ~= chatLayer.currentPanel then
            chatLayer.currentPanel = i
            -- 改变标签状态
            for j = 1, 3 do
                local opt = chatLayer.options["opt"..j]
                local s = (i == opt.id) and "czpdk/labelbg%d_selected.png" or "czpdk/labelbg%d_normal.png"
                opt:setNormalImage(loadSprite(string.format(s, j)))
            end
            chatLayer:createDetail(i)
        end
    end
end


function ChatLayer:addEmoteDetail()
    local titleBg, tableView, z, bgsz = self:addTableView(ccp(0, 1), ccp(34, self.bgSize.height - 35))

    local titleSz = titleBg:getContentSize()
    local title = loadSprite("czpdk/chatLab1.png")
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
                ChatLayer.sendMsg(1, k)
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

-- 生成内容列表
function ChatLayer:addChatDetail()
    local titleBg, tableView, z, bgsz = self:addTableView(ccp(1, 1), ccp(self.bgSize.width - 34, self.bgSize.height - 35))

    local titleSz = titleBg:getContentSize()
    local title = loadSprite("czpdk/chatRTitleBg.png")
    title:setPosition(ccp(titleSz.width / 2, titleSz.height / 2))
    titleBg:addChild(title)

    local function showChat(index)
        if index == 1 then
            local lan_set = AppConfig.language[SetLogic.getGameCheckByIndex(3)]
            local quickChatCfg = AppConfig.quickChat[lan_set]
            tableView:setCellSizeFunc(function(tableView,idx) return 74, bgsz.width end)
            tableView:setNumberOfCellsFunc(function() return #quickChatCfg end)
            tableView:setCreateCellFunc(function(idx)
                local layer = CCLayer:create()
                if idx < #quickChatCfg-1 then
                    local sp = loadSprite("czpdk/split.png")
                    sp:setPosition(ccp(bgsz.width / 2, 2))
                    layer:addChild(sp)
                end
                local btn = CCControlButton:create(quickChatCfg[idx+1], "" , 24)
                btn:setPreferredSize(CCSizeMake(bgsz.width,0))
                btn:setAnchorPoint(ccp(0.5,0.5))
                btn:setPosition(ccp(bgsz.width / 2, 30))
                btn:setTouchPriority(z)
                btn:setTitleColorForState(ccc3(83,41,18), CCControlStateNormal)
                btn:addHandleOfControlEvent(function(sender)
                    ChatLayer.sendMsg(2, idx+1)
                end, CCControlEventTouchUpInside)
                layer:addChild(btn)
                return layer
            end)
        else
            tableView:setCellSizeFunc(function(tableView,i) return 60,bgsz.width end)
            tableView:setNumberOfCellsFunc(function()
                local s = chatLayer.chatHistory and #chatLayer.chatHistory or 0
                return s
            end)
            tableView:setCreateCellFunc(function(idx)
                local chat = chatLayer.chatHistory[idx+1]
                if chat then
                    local labelVal = CCLabelTTF:create(chat , "" ,24)
                    labelVal:setHorizontalAlignment(kCCTextAlignmentLeft)
                    labelVal:setDimensions(CCSizeMake(bgsz.width, 0))
                    labelVal:setAnchorPoint(ccp(0,0.5))
                    labelVal:setPosition(ccp(6, 30))
                    labelVal:setColor(ccc3(83,41,18))
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
    local poses = {ccp(titleSz.width / 2 - 85, titleSz.height - 20), ccp(titleSz.width / 2 + 85, titleSz.height - 20)}
    for i,v in ipairs(poses) do
        local btn = CCButton.put(titleBg, CCButton.createCCButtonByFrameName("czpdk/chatLab"..(i + 1).."_normal.png", 
        "czpdk/chatLab"..(i + 1).."_select.png", "czpdk/chatLab"..(i + 1).."_select.png", function(tag, target)
            for j,w in ipairs(self.clickTable) do
                w:setEnabled(true)
                w:getChildByTag(10):setVisible(false)
            end

            target:setEnabled(false)
            target:getChildByTag(10):setVisible(true)
            showChat(i)
        end), v, self.layer_zIndex + 1)

        local btnSp =  loadSprite("czpdk/chatRTitle.png")
        btn:addChild(btnSp, -2, 10)
        btnSp:setVisible(false)
        table.insert(self.clickTable, btn)
    end 

    self.clickTable[1]:setEnabled(false)
    self.clickTable[1]:getChildByTag(10):setVisible(true) 
    showChat(1)  
end

-- 生成内容列表
function ChatLayer:addTableView(ancpos, pos)
    local bgsz = CCSizeMake(386, 432)

    -- 背景框
    local viewbg = loadSprite("czpdk/chatInnerBg.png", true)
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
    local titleBg = loadSprite("czpdk/chatLTitle.png")
    titleBg:setAnchorPoint(ccp(0.5, 1))
    titleBg:setPosition(ccp(bgsz.width / 2, bgsz.height - 12))
    viewbg:addChild(titleBg)

    return titleBg, tableView, z, bgsz
end

function ChatLayer.sendMsg(m, n)
    local r = require("k510/Game/GameLogic").getGameLib()
    if m == 1 then
        if n > 0 and n < 29 then
            r:sendTableChat(string.format('--:%d',n))
        end
        chatLayer:hide()
    elseif m == 2 then
        local lan_set = AppConfig.language[SetLogic.getGameCheckByIndex(3)]
        local quickChatCfg = AppConfig.quickChat[lan_set]
        if n > 0 and n <= #quickChatCfg then
            r:sendTableChat(string.format('@QUICK|%s',n))
        end
        chatLayer:hide()
    else
        if length(n) > 0 then
            r:sendTableChat(subStr(n,1,20))
            chatLayer:hide()
        end
    end
end

function ChatLayer:init()
    self:setVisible(false)
    local screenMidx = AppConfig.SCREEN.CONFIG_WIDTH/ 2
    local screenMidy = AppConfig.SCREEN.CONFIG_HEIGHT/ 2
    local z = kCCMenuHandlerPriority - self.layer_zIndex - 2
    
    self.bgSize = CCSizeMake(850, 570)
    self.currentPanel = 0
    
    -- 背景框
    self.panel_bg = CCLayer:create()
    self:addChild(self.panel_bg)
    self.bg = loadSprite("common/popBg.png", true)
    self.bg:setPreferredSize(self.bgSize)
    self.bg:setPosition(ccp(screenMidx, screenMidy-18))
    self.panel_bg:addChild(self.bg)
    
    self.chatmsgArray = {}
    
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
    local btn_input = CCControlButton:create(loadSprite("czpdk/btn_send.png", true))
    btn_input:setBackgroundSpriteForState(loadSprite("czpdk/btn_send_press.png", true), CCControlStateHighlighted)
    btn_input:setPosition(ccp(self.bgSize.width - 110, 68))
    btn_input:setPreferredSize(CCSizeMake(146,68))
    btn_input:setTouchPriority(z)
    btn_input:addHandleOfControlEvent(function(sender)
        ChatLayer.sendMsg(3, chatLayer.input:getText())
        chatLayer.input:setText("")
    end, CCControlEventTouchUpInside)
    self.bg:addChild(btn_input)
    self.btn_input = btn_input
    
    self.chatList = {{},{},{}}
    
    self.chatHistory = {}
    
    --self:selectPanel({id=2})
    
    -- 注册事件
    self:registerScriptTouchHandler(function(eventType, x, y)
        local s = chatLayer.bgSize
    if eventType == "began" then
            if (x < screenMidx - s.width /2) or (
                x > screenMidx + s.width /2) or (
                y < screenMidy - s.height/2) or (
                y > screenMidy + s.height/2) then
                chatLayer:hide()
            end
            return true
        end
    end, false, kCCMenuHandlerPriority - self.layer_zIndex, true)
end

--刷新聊天数据
function ChatLayer:resetChatMsg(args)
   table.insert(self.chatHistory,args)
   if #self.chatHistory > 10 then
      table.remove(self.chatHistory,1)
   end
end

function ChatLayer.create()
    chatLayer = ChatLayer.new(zindex)
    chatLayer.layer_zIndex = 0
    chatLayer:init()
    return chatLayer
end

return ChatLayer