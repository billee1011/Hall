--LobbySecondDlg.lua
local AppConfig = require("AppConfig")
local CCButton = require("FFSelftools/CCButton")

local LobbySecondDlg=class("LobbySecondDlg",function()
    return CCLayerColor:create(AppConfig.COLOR.ColorLayer_Bg)
end)

function LobbySecondDlg:hide()
    require("Lobby/Common/AnimationUtil").spriteScaleHideAction(self.panel_bg, function()
        self:setVisible(false)
        self:setTouchEnabled(false)
        if self.close_func then
            self.close_func()
        end        
    end) 
end

--隐藏回调
function LobbySecondDlg:hideCallFunc(func)
    require("Lobby/Common/AnimationUtil").spriteScaleHideAction(self.panel_bg, function()
        self:setVisible(false)
        self:setTouchEnabled(false)
        if func then
            func()       
        end
    end) 
end

function LobbySecondDlg:show() 
    self:setVisible(true)
    require("Lobby/Common/AnimationUtil").spriteScaleShowAction(self.panel_bg, function()
        self:setTouchEnabled(true)
        if self.show_func then
            self.show_func()
        end
    end) 

    return self
end

function LobbySecondDlg:initCommon(confrimfunc, closefunc, priority)
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            return true
        end
    end

    priority = priority or kCCMenuHandlerPriority - 1
    self:registerScriptTouchHandler(onTouch,false, priority, true)
    self:setTouchEnabled(true)

    self.close_func = closefunc
    self.confrim_func = confrimfunc
end

function LobbySecondDlg:initVIP(confrimfunc, closefunc) 
    self:initCommon(confrimfunc, closefunc)

    --设置背景
    self.panel_bg =  CCSprite:create(AppConfig.ImgFilePathName .. "common/vip_dlg_bg.png")
    self.panel_bg:setPosition(AppConfig.SCREEN.MID_POS)
    self:addChild(self.panel_bg)
    self.bg_sz = self.panel_bg:getContentSize()

    --操作按钮 1、关闭按钮 2、信息绑定
    local funcs = {function(tag, target) 
                    self:hide()     
                end,
                function(tag, target)
                    self:hideCallFunc(self.confrim_func)   
                end}    
    local poses = {ccp(self.bg_sz.width, self.bg_sz.height),
                    ccp(self.bg_sz.width*0.5, 120),
                ccp(350, 830),
                }
    local imgs = {"close_out_btn", "common/vip_dlg_btn"}
    for i=1,2 do
        local btnItem = CCButton.createCCButtonByFrameName(imgs[i].."1.png", 
                                imgs[i].."2.png", imgs[i].."2.png", 
                                funcs[i])
        btnItem:setPosition(poses[i])
        self.panel_bg:addChild(btnItem, i)
        btnItem:resetTouchPriorty(kCCMenuHandlerPriority - 2,false)
    end

    self:setVisible(false)
    self:setTouchEnabled(false)  
end

function LobbySecondDlg:changeRefuceAgreenStatue(ctype)
    for i,v in ipairs(self.btn_uis) do
        v:setVisible(false)
    end   

    self.btn_uis[ctype]:setVisible(true)
    self.btn_uis[ctype]:setEnabled(false)
    self.btn_uis[ctype]:setPositionX(self.bg_sz.width*0.5)  
end

function LobbySecondDlg:initRefuceAgreen(msg, bBlock, confrimfunc, closefunc, priority, alignment, bgsz)
    self:initCommon(confrimfunc, closefunc, priority)
    self:addTipMsg(msg, alignment, bgsz)

    --操作按钮 1、关闭按钮 2、信息绑定
    local funcs = {function(tag, target) 
                    if not bBlock then
                        self:hide() 
                    else
                        self.close_func()
                        self:changeRefuceAgreenStatue(1)
                    end    
                end,
                function(tag, target)
                    if not bBlock then
                        self:hideCallFunc(self.confrim_func) 
                    else
                        self.confrim_func()
                        self:changeRefuceAgreenStatue(2)
                    end                    
                end}  



    local poses = {ccp(self.bg_sz.width*0.5 - 100, 68),
                    ccp(self.bg_sz.width*0.5 + 100, 68)
                }
    self.btn_uis = {}                
    local imgs = {"common/btn_refuce", "common/btn_agree"}
    for i=1,2 do
        local btnItem = CCButton.createCCButtonByFrameName(imgs[i].."1.png", 
                                imgs[i].."2.png", imgs[i].."3.png", 
                                funcs[i])
        btnItem:setPosition(poses[i])
        self.panel_bg:addChild(btnItem, i)
        btnItem:resetTouchPriorty(priority - 1,false)

        table.insert(self.btn_uis, btnItem)
    end

    self:setVisible(false)
    self:setTouchEnabled(false)  
end

function LobbySecondDlg:initTip(msg, confrimfunc, closefunc, priority, alignment, bgsz, autoClose)
    self:initCommon(confrimfunc, closefunc, priority)
    self:addTipMsg(msg, alignment, bgsz)

    --操作按钮 1、关闭按钮 2、信息绑定
    local funcs = {function(tag, target) 
                    self:hide()     
                end,
                function(tag, target)
                    if false == autoClose then
                        if self.confrim_func then self.confrim_func() end
                    else
                        self:hideCallFunc(self.confrim_func)   
                    end
                end}    
    local poses = {ccp(self.bg_sz.width*0.5 - 100, 68),
                    ccp(self.bg_sz.width*0.5 + 100, 68)
                }
    local imgs = {"common/common_dlg_nobtn", "common/common_dlg_okbtn"}
    for i=1,2 do
        local btnItem = CCButton.createCCButtonByFrameName(imgs[i].."1.png", 
                                imgs[i].."2.png", imgs[i].."2.png", 
                                funcs[i])
        btnItem:setPosition(poses[i])
        self.panel_bg:addChild(btnItem, i)
        self["btnItem"..i] = btnItem
        btnItem:resetTouchPriorty(priority - 1,false)
    end

    self:setVisible(false)
    self:setTouchEnabled(false)  
end

--无选择提示框
function LobbySecondDlg:initConfirmTip(msg, closefunc, zindex, alignment, bgsz)
    self:initCommon(closefunc, closefunc, kCCMenuHandlerPriority - zindex)
    self:addTipMsg(msg, alignment, bgsz)

    if closefunc then
    --关闭按钮
        local b = CCButton.createCCButtonByFrameName(
            "common/common_dlg_okbtn1.png", "common/common_dlg_okbtn2.png", "common/common_dlg_okbtn1.png", 
            function(tag, target) 
                    self:hide()     
            end)
        CCButton.put(self.panel_bg, b, ccp(self.bg_sz.width*0.5, 68), zindex + 1)
        self.panel_bg.closeBtn = b
    else
        self.tip_lab:setHorizontalAlignment(kCCTextAlignmentLeft)
        self.tip_lab:setPosition(ccp(self.bg_sz.width / 2, self.bg_sz.height / 2))
    end

    self:setVisible(false)
    self:setTouchEnabled(false)  
end

function LobbySecondDlg:addTipMsg(msg, alignment, bgsz)
    alignment = alignment or kCCTextAlignmentLeft
    self.bg_sz = bgsz or CCSizeMake(480, 320)

    --设置背景
    self.panel_bg = loadSprite("common/popBg.png", true)
    self.panel_bg:setPreferredSize(self.bg_sz)
    self:addChild(self.panel_bg)
    self.panel_bg:setPosition(AppConfig.SCREEN.MID_POS)

    self.tip_lab = CCLabelTTF:create(msg, AppConfig.COLOR.FONT_ARIAL, 24)
    self.tip_lab:setColor(ccc3(74, 25, 8))
    self.tip_lab:setPosition(ccp(self.bg_sz.width / 2, self.bg_sz.height / 2 + 40))
    self.tip_lab:setDimensions(CCSizeMake(self.bg_sz.width - 80, 0))
    self.tip_lab:setHorizontalAlignment(alignment)
    self.panel_bg:addChild(self.tip_lab)
end

function LobbySecondDlg:addAddedLab(msg, ypos, ftsz, alignment)
    alignment = alignment or kCCTextAlignmentLeft
    ftsz = ftsz or 24
    local tipLab = CCLabelTTF:create(msg, AppConfig.COLOR.FONT_ARIAL, ftsz)
    tipLab:setColor(ccc3(74, 25, 8))
    tipLab:setPosition(ccp(self.bg_sz.width*0.5, ypos))
    tipLab:setDimensions(CCSizeMake(self.bg_sz.width - 80, 0))
    tipLab:setHorizontalAlignment(alignment)
    self.panel_bg:addChild(tipLab)

    return tipLab
end

function LobbySecondDlg:initProgress(zindex, msg, func) 
    self:initCommon(nil, function()
        self:removeFromParentAndCleanup(true)
        if func then
            func()
        end
    end, kCCMenuHandlerPriority - zindex)

    --设置加载
    self.panel_bg = loadSprite("common/game_progress_img.png")
    self.panel_bg:setPosition(AppConfig.SCREEN.MID_POS)
    self:addChild(self.panel_bg)    

    local actionTime, maxTime = 0.8, 15
    self.progress_count = 1
    local function onActionAnima()
        if self.progress_count > maxTime then
            self:hide()

            if msg then
                require("HallUtils").showWebTip(msg)
            end
            return
        end

        local array = CCArray:create()
        array:addObject(CCRotateBy:create(actionTime, -360))
        array:addObject(CCCallFunc:create(onActionAnima))
        self.progress_count = self.progress_count + 1
        self.panel_bg:runAction(CCSequence:create(array))
    end

    onActionAnima()

end

function LobbySecondDlg:setProgressCount(ncount)
    self.progress_count = ncount
end

function LobbySecondDlg:init(title, confrimfunc, closefunc) 
    self:initCommon(confrimfunc, closefunc)

    --设置背景
    self.panel_bg =  CCSprite:create(AppConfig.ImgFilePathName .. "panel_bg.png")
    self.panel_bg:setPosition(AppConfig.SCREEN.MID_POS)
    self:addChild(self.panel_bg)
    self.bg_sz = self.panel_bg:getContentSize()

    --设置标题
    local title =  CCSprite:create(AppConfig.ImgFilePathName .. title)
    title:setPosition(ccp(self.bg_sz.width*0.5, 655))
    self.panel_bg:addChild(title)

    self:addOperatorBtns({function(tag, target) self:hide() end,
        function(tag, target) self.confrim_func() end})   
end

function LobbySecondDlg:addOperatorBtns(funcs) 
    --操作按钮 1、关闭按钮 2、信息绑定
    local poses = {ccp(self.bg_sz.width - 20, self.bg_sz.height - 20),
                    ccp(self.bg_sz.width*0.5, 120),
                ccp(350, 830),
                }
    local imgs = {"close_btn", "info/bind_confirm_btn"}
    for i=1,2 do
        local btnItem = CCButton.createCCButtonByFrameName(imgs[i].."1.png", 
                                imgs[i].."2.png", imgs[i].."2.png", 
                                funcs[i])
        btnItem:setPosition(poses[i])
        self.panel_bg:addChild(btnItem, i)
        btnItem:resetTouchPriorty(kCCMenuHandlerPriority - 2,false)
    end
end

--添加输入框
function LobbySecondDlg:addEditTable(scales, hides, poses, modes, titles) 
    self.edit_table = require("Lobby/Common/LobbyCommonUI").addEditTable(self.panel_bg, 
                AppConfig.ImgFilePathName.."login/logon_edit_bg.png",
                 scales, hides, poses, modes, AppConfig.COLOR.FONT_ARIAL, 38, AppConfig.COLOR.Text_White, titles)
end

function LobbySecondDlg.create(title, confrimfunc, closefunc)
    local layer = LobbySecondDlg.new()
    layer:init(title, confrimfunc, closefunc)
    return layer
end

function LobbySecondDlg.createVIP(confrimfunc, closefunc)
	local layer = LobbySecondDlg.new()
	layer:initVIP(confrimfunc, closefunc)
	return layer
end

function LobbySecondDlg.createTip(msg, confrimfunc, closefunc, priority, alignment)
    local layer = LobbySecondDlg.new()
    layer:initTip(msg, confrimfunc, closefunc, priority, alignment)
    return layer
end

function LobbySecondDlg.putTip(super, zindex, msg, confrimfunc, closefunc, alignment, bgsz, autoClose)
    local layer = LobbySecondDlg.new()    
    layer:initTip(msg, confrimfunc, closefunc, kCCMenuHandlerPriority - zindex, alignment, bgsz, autoClose)
    super:addChild(layer, zindex)
    return layer
end

function LobbySecondDlg.putRefuceAgreen(super, bBlock, zindex, msg, confrimfunc, closefunc, alignment, bgsz)
    local layer = LobbySecondDlg.new()    
    layer:initRefuceAgreen(msg, bBlock, confrimfunc, closefunc, kCCMenuHandlerPriority - zindex, alignment, bgsz)
    super:addChild(layer, zindex)
    return layer
end

function LobbySecondDlg.putConfirmTip(super, zindex, msg, closefunc, alignment, bgsz)
    local layer = LobbySecondDlg.new()    
    layer:initConfirmTip(msg, closefunc, zindex, alignment, bgsz)
    super:addChild(layer, zindex)
    return layer
end

function LobbySecondDlg.putProgress(msg, func, super)
    local layer = LobbySecondDlg.new()    
    layer:initProgress(100, msg, func)
    super = super or CCDirector:sharedDirector():getRunningScene()
    super:addChild(layer, 100)
    return layer
end

 return LobbySecondDlg