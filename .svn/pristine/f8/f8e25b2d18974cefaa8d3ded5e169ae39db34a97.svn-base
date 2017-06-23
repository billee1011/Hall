--LayerEnterRoom.lua
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")

local LayerEnterRoom=class("LayerEnterRoom",function(super, zindex)
    return require("Lobby/LayerPopup").put(super, zindex)
end)

function LayerEnterRoom:init()
    self:setOpacity(205)
    self.btn_zIndex = self.layer_zIndex + 1

    self.bgsz = CCSizeMake(610, 580)
    self:addFrameBg("lobby/enterroombg_s9img.png", self.bgsz)
    self.panel_bg:setPositionY(self.panel_bg:getPositionY() - 10)

    --添加标题
    local title =  loadSprite("lobby/room_enter_title.png")
    title:setPosition(ccp(self.bgsz.width / 2, self.bgsz.height - 10))
    self.panel_bg:addChild(title)   

    --进入房间
    local labItem = CCLabelTTF:create("请输入房间号", AppConfig.COLOR.FONT_ARIAL, 28)                 
    labItem:setPosition(ccp(self.bgsz.width / 2, self.bgsz.height - 60))
    labItem:setColor(ccc3(251, 255, 144))
    self.panel_bg:addChild(labItem)

    local linebg =  loadSprite("lobby/room_linebg.png", true)
    linebg:setPreferredSize(CCSizeMake(540, 90))
    linebg:setPosition(ccp(self.bgsz.width / 2, self.bgsz.height - 126))
    self.panel_bg:addChild(linebg) 
       
    --房间号码
    self.room_labs, self.number_index = {}, 1
    for i=1,6 do
        local pos = ccp(self.bgsz.width / 2 + 90 * i - 312, self.bgsz.height - 120)
        local labItem = CCLabelTTF:create("", AppConfig.COLOR.FONT_ARIAL, 68)       
        labItem:setPosition(pos)
        self.panel_bg:addChild(labItem)
        table.insert(self.room_labs, labItem)

        local lineSp =  loadSprite("lobby/room_line.png")
        lineSp:setPosition(ccp(pos.x, pos.y - 40))
        self.panel_bg:addChild(lineSp)
    end

    self:addOperatorBtns(self.panel_bg)
end

function LayerEnterRoom:addOperatorBtns(bg)
    self.panel_btns = {}
    
    --添加按钮    
    function addRoomBtn(markSp, pos, func)
        local item = CCButton.put(bg, CCButton.createCCButtonByFrameName("lobby/room_itembtn1.png", 
                "lobby/room_itembtn2.png", "lobby/room_itembtn1.png", func), pos, self.btn_zIndex)
        local itemSz = item.m_normalSp:getContentSize()

        --标示
        markSp:setAnchorPoint(ccp(0.5, 0.5))
        item:addChild(markSp)
        table.insert(self.panel_btns, item)
    end

    function inputNumber(num, dirc)
        if dirc > 0 then
            if self.number_index > 6 then 
                self.number_index = 6                 
            end  
            self.room_labs[self.number_index]:setString(""..num)
            if self.number_index == 6 then
                self:sendEnterRoomMsg()
            end
            self.number_index = self.number_index + 1                      
        else
            self.number_index = self.number_index - 1
            if self.number_index < 1 then
                self.number_index = 1
            end 
            self.room_labs[self.number_index]:setString("")           
        end      
    end    

    local posx, posy, xspace, yspace = 113, 356, 190, 96
    --数字1~9
    for i=1,9 do
        local pos = ccp(posx + (i - 1) % 3 * xspace, posy - math.floor((i - 1)/ 3) * yspace)
        local numSp = CCLabelAtlas:create(""..i, AppConfig.ImgFilePath.."num_room.png",30,45,string.byte('0'))
        addRoomBtn(numSp, pos, function()
            inputNumber(i, 1)
        end)
    end
    addRoomBtn(CCLabelAtlas:create("0", AppConfig.ImgFilePath.."num_room.png",
        30,45,string.byte('0')), ccp(posx + 1 * xspace, posy - 3 * yspace), function()
        inputNumber(0, 1)
    end)

    CCButton.put(bg, CCButton.createCCButtonByFrameName("lobby/room_resetbtn1.png", 
                "lobby/room_resetbtn2.png", "lobby/room_resetbtn1.png", function()
                    self:clearAllNumber(true)
                end), ccp(posx + 0 * xspace, posy - 3 * yspace), self.btn_zIndex)


    CCButton.put(bg, CCButton.createCCButtonByFrameName("lobby/room_deletebtn1.png", 
                "lobby/room_deletebtn2.png", "lobby/room_deletebtn1.png", function()
                    inputNumber("", -1)
                end), ccp(posx + 2 * xspace, posy - 3 * yspace), self.btn_zIndex)     
end

function LayerEnterRoom:clearAllNumber(bSuccend)
    local function resetNumbers()
        for i=1,6 do
            self.room_labs[i]:setString("")
        end
        self.number_index = 1
    end

    if bSuccend then
        resetNumbers()
    else
        require("Lobby/Set/SetLogic").playGameShake(300)  
        
        self:setAllEnable(false)

        local array, duration, xspace = CCArray:create(), 0.05, 20
        local moveAction = CCMoveBy:create(duration, ccp(xspace, 0))
        array:addObject(CCRepeat:create(CCSequence:createWithTwoActions(moveAction, moveAction:reverse()), 4))
        array:addObject(CCDelayTime:create(0.1))

        array:addObject(CCCallFunc:create(function()
            resetNumbers()
            self:setAllEnable(true)        
        end))

        self.panel_bg:runAction(CCSequence:create(array))
    end
   
end

function LayerEnterRoom:setAllEnable(bvalue)
    for i,v in ipairs(self.panel_btns) do
        v:setEnabled(bvalue)
    end

    self:setTouchEnabled(bvalue)
end

--发送进桌消息
function LayerEnterRoom:sendEnterRoomMsg()
    if self.number_index >= 6 and self.room_labs[6]:getString() ~= "" then
        local inviteCode = ""
        for i=1,6 do
            inviteCode = inviteCode..self.room_labs[i]:getString()
        end

        self:getParent():showEnterRoomPanel(inviteCode, function(bSuccend) self:clearAllNumber(bSuccend) end, gameid)
    end
end

function LayerEnterRoom.put(super, zindex)
    local layer = LayerEnterRoom.new(super, zindex)
    layer:init()
    return layer
end

return LayerEnterRoom