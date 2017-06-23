
require("CocosExtern")


local LobbyEditBox = class("LobbyEditBox", function(sz, sprite)
	return CCEditBox:create(sz, sprite)
end)

--按最大长度设置text
function LobbyEditBox:formEditText(text, lenth)
    local msg = require("HallUtils").getLabText(text, 
        CCLabelTTF:create("", self.edit_ftname, self.edit_ftsize), lenth)
    self:setText(msg)

    return self
end

--设置最大长度
function LobbyEditBox:setEditMaxLen(lenth)
    self.max_width = lenth

    return self    
end

--设置最大中文字数的长度
function LobbyEditBox:setEditMaxText(count)
    self.max_width = CCLabelTTF:create("大", self.edit_ftname, self.edit_ftsize):getContentSize().width * count
    self.font_num = count
    return self    
end

--设置字体
function LobbyEditBox:setEditFont(ftname, ftsize, ftcolor)
    self.edit_ftname, self.edit_ftsize =  ftname, ftsize
    self:setFont(ftname, ftsize)
    if ftcolor then
        self:setFontColor(ftcolor)
    end

    return self
end

--设置完成输入回调
function LobbyEditBox:setEditEndFunc(func)
    self.editend_func = func

    return self
end

--设置完成输入回调
function LobbyEditBox:setEditBeginFunc(func)
    self.editbegin_func = func

    return self
end

function LobbyEditBox:initMaxWidthEdit(pos, priority, holder, text)
    local function editBoxTextEventHandle(strEventName, pSender)
        if strEventName == "began" then
            if self.editbegin_func then
                self.editbegin_func()
            end        	
        elseif strEventName == "ended" then
            local msg = self:getText()
            self:formEditText(msg, self.max_width)

            --最大输入字符提示
            if self.font_num and msg ~= self:getText() then
                require("HallUtils").showWebTip("最大允许输入"..self.font_num.."个中文")
            end
            if self.editend_func then
                self.editend_func(self:getText())
            end
        elseif strEventName == "return" then
        elseif strEventName == "changed" then
        end
    end

    self.max_width = self:getContentSize().width

    self:setPosition(pos)
    self:setAnchorPoint(ccp(0,0.5))  
    
    self:setReturnType(kKeyboardReturnTypeDone) 
    self:setInputMode(kEditBoxInputModeSingleLine)
    self:setTouchPriority(priority)
    self:registerScriptEditBoxHandler(editBoxTextEventHandle)

    if holder then
        self:setPlaceHolder(holder)
    end
    if text then
        self:setText(text)
    end    
end

--一般通用
function LobbyEditBox.createMaxWidthEdit(sz, sprite, pos, priority, holder, text)
    local item = LobbyEditBox.new(sz, sprite)
    item:initMaxWidthEdit(pos, priority, holder, text)
    return item
end

return LobbyEditBox