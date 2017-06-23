--LayerPiao.lua
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")

local LayerPiao=class("LayerPiao",function()
    return CCLayerColor:create(ccc4(0, 0, 0, 0))
end)

function LayerPiao:show()
    self:setVisible(true)
    self:setTouchEnabled(true)
end

function LayerPiao:init() 
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true
        end
    end
    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority - self.layer_zIndex,true)
    self:setTouchEnabled(true)
    self.btn_zIndex = self.layer_zIndex + 1

    local function addBtnMark(btn, img)
        local mark = loadSprite(img)
        btn:addChild(mark)
        mark:setPosition(ccp(0, 3))
    end

    --不飘
    local leftpos = ccp(AppConfig.SCREEN.CONFIG_WIDTH / 2 - 90 * 3, AppConfig.SCREEN.CONFIG_HEIGHT / 2 - 100)
    local btnNO = CCButton.put(self, CCButton.createCCButtonByFrameName("common/btnNOBg1.png", "common/btnNOBg2.png", "common/btnNOBg1.png", 
            function()
                require("czmj/Game/GameLogic"):getInstance():sendPiao(1, 0)
                require("czmj/Game/GameLogic"):getInstance():onEnterGameView()
            end), leftpos, self.btn_zIndex)    
    addBtnMark(btnNO, "czmj/btnNOPiaoTTF.png")

    --飘
    local piaoType = require("czmj/Game/GameLogic"):getInstance().bPiaoType
                    or require("Lobby/FriendGame/FriendGameLogic").getRuleValueByIndex(100)
    local piaoScores = {1, 3, 5}
    if piaoType == 2 then
        piaoScores = {1, 2, 3}
    end
    for i,v in ipairs(piaoScores) do
        leftpos.x = leftpos.x + 180
        local btnOK = CCButton.put(self, CCButton.createCCButtonByFrameName("common/btnOKBg1.png", "common/btnOKBg2.png", "common/btnOKBg1.png", 
                function()
                    require("czmj/Game/GameLogic"):getInstance():sendPiao(1, v)
                    require("czmj/Game/GameLogic"):getInstance():onEnterGameView()
                end), leftpos, self.btn_zIndex)    
        addBtnMark(btnOK, "czmj/btnPiao"..v.."TTF.png")
    end

    self:setVisible(false)
    self:setTouchEnabled(false)    
end

function LayerPiao:initChoice(score) 
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true
        end
    end
    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority - self.layer_zIndex,true)
    self:setTouchEnabled(true)
    self.btn_zIndex = self.layer_zIndex + 1

    --提示
    local tipbg = loadSprite("lobby_message_tip_bg.png")
    tipbg:setPosition(ccp(AppConfig.SCREEN.CONFIG_WIDTH / 2, AppConfig.SCREEN.CONFIG_HEIGHT / 2 + 110)) 
    self:addChild(tipbg)   
    local bgsz = tipbg:getContentSize()

    local ypos = {bgsz.height / 2 + 30, bgsz.height / 2 - 20}
    local msgs = {"请选择当前是否要“飘”", "计分时自摸所有玩家增减："..score.."\n计分时吃胡点炮玩家增减："..score}
    for i,v in ipairs(ypos) do
        local tiplab = CCLabelTTF:create(msgs[i], AppConfig.COLOR.FONT_ARIAL, 24)
        tiplab:setPosition(ccp(bgsz.width / 2, v))
        tiplab:setDimensions(CCSizeMake(bgsz.width, 0))
        tiplab:setHorizontalAlignment(kCCTextAlignmentCenter)
        tipbg:addChild(tiplab)
    end

    --不飘、飘
    local imgs = {"czmj/btnNoPiao", "czmj/btnPiao"}
    local poses = {ccp(AppConfig.SCREEN.CONFIG_WIDTH / 2 - 120, AppConfig.SCREEN.CONFIG_HEIGHT / 2 - 80),
                ccp(AppConfig.SCREEN.CONFIG_WIDTH / 2 + 120, AppConfig.SCREEN.CONFIG_HEIGHT / 2 - 80)}
    for i,v in ipairs(imgs) do
        CCButton.put(self, CCButton.createCCButtonByFrameName(v.."1.png", v.."2.png", v.."1.png", 
                function()
                    require("czmj/Game/GameLogic"):getInstance():sendPiao(i - 1)
                    require("czmj/Game/GameLogic"):getInstance():onEnterGameView()
                end), poses[i], self.btn_zIndex)
    end

    self:setVisible(false)
    self:setTouchEnabled(false)    
end

function LayerPiao.put(super, zindex, score)
    local layer = LayerPiao.new()
    layer.layer_zIndex = zindex
    super:addChild(layer, zindex)
    layer:init(score)
    return layer
end

return LayerPiao