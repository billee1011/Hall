
require("CocosExtern")


local LobbyScrollView = class("LobbyScrollView", function(sz)
	return CCScrollView:create(sz)
end)

--设置偏移量上限
function LobbyScrollView:setMaxScrollOffset(offset)
    self.max_offset = offset
end

--设置偏移量
function LobbyScrollView:resetHorizontalScroll(offset)
    local conatainWidth = self.conatain_width
    self.scroll_layer:setContentSize(CCSizeMake(conatainWidth, self.view_size.height))

    if self.conatain_width < self.view_size.width then
        offset = self.view_size.width - conatainWidth
    end

    --设置偏移量
    offset = offset or self.view_size.width - conatainWidth
    self:setContentOffset(ccp(offset, 0))

    return self
end

--设置偏移量
function LobbyScrollView:resetCommonScroll(offset)
    local conatainHeight = self.conatain_height
    self.scroll_layer:setContentSize(CCSizeMake(self.view_size.width, conatainHeight))

    if self.conatain_height < self.view_size.height then
        offset = self.view_size.height - conatainHeight
    end

    --设置偏移量
    offset = offset or self.view_size.height - conatainHeight
    self:setContentOffset(ccp(0, offset))

    return self
end

--获取控件实际高度
function LobbyScrollView:getCommonScrollHeight() 
    return self.conatain_height
end

--获取控件实际高度
function LobbyScrollView:getCommonContainHeight() 
    return self.scroll_layer:getContentSize().height
end

--重设控件实际高度
function LobbyScrollView:resetCommonScrollHeight(height) 
    self.conatain_height = height

    return self
end

--清空
function LobbyScrollView:clearCommonScrollItem()
    self.scroll_layer:removeAllChildrenWithCleanup(true)  
    self.conatain_height = 0
    self.item_table = {}
    return self
end

--添加水平
function LobbyScrollView:addHorizontalScrollItem(item, pos)
    pos = pos or ccp(self.conatain_width, 0)
    item:setPosition(pos)
    self.conatain_width = self.conatain_width + item:getContentSize().width    
    self.scroll_layer:addChild(item)
    
    table.insert(self.item_table, item)
    return self
end

--添加
function LobbyScrollView:addCommonScrollItem(item, pos)
    pos = pos or ccp(0, self.conatain_height)
    item:setPosition(pos)
    self.conatain_height = self.conatain_height + item:getContentSize().height    
    self.scroll_layer:addChild(item)
    
    table.insert(self.item_table, item)
    return self
end

--底部添加
function LobbyScrollView:addCommonScrollItemBottom(item)
    item:setPosition(ccp(0, 0))
    self.conatain_height = self.conatain_height + item:getContentSize().height    
    
    --全部上移
    for i=1,#self.item_table do
        self.item_table[i]:setPositionY(self.item_table[i]:getPositionY() + item:getContentSize().height)
    end

    self.scroll_layer:addChild(item)
    table.insert(self.item_table, item)
    return self
end

--初始化水平
function LobbyScrollView:initHorizontalScroll(sz, pos, priority)
    self.view_size = sz
    self.conatain_width = 0
    self.item_table = {}

    --容器
    self:setTouchPriority(priority)
    self:setDirection(kCCScrollViewDirectionHorizontal)
    self:setAnchorPoint(ccp(0, 0))
    self:setPosition(pos)

    --背景
    self.scroll_layer = CCLayer:create()
    self.scroll_layer:setContentSize(self.view_size)
    self.scroll_layer:setAnchorPoint(ccp(0,0))
    self.scroll_layer:setPosition(ccp(0, 0))
    self:setContainer(self.scroll_layer)    
end

--初始化
function LobbyScrollView:initCommonScroll(sz, pos, priority, topfunc)
    self.view_size = sz
    self.conatain_height = 0
    self.item_table = {}

    --聊天容器
    self:setTouchPriority(priority)
    self:setDirection(kCCScrollViewDirectionVertical)
    self:setAnchorPoint(ccp(0, 0))
    self:setPosition(pos)

    --聊天背景
    self.scroll_layer = CCLayer:create()
    self.scroll_layer:setContentSize(self.view_size)
    self.scroll_layer:setAnchorPoint(ccp(0,0))
    self.scroll_layer:setPosition(ccp(0, 0))
    self:setContainer(self.scroll_layer)

    if topfunc then
        self.topBounced_func = topfunc
        local function scrollViewDidBounced()
            if self:getContentOffset().y < 0 and self.topBounced_func then
                self.topBounced_func()
            end
        end
        self:registerScriptHandler(scrollViewDidBounced,2)
    end
end


--一般水平Scroll
function LobbyScrollView.createHorizontalScroll(sz, pos, priority)
    local item = LobbyScrollView.new(sz)
    item:initHorizontalScroll(sz, pos, priority, topfunc)
    return item
end

--一般通用Scroll
function LobbyScrollView.createCommonScroll(sz, pos, priority, topfunc)
    local item = LobbyScrollView.new(sz)
    item:initCommonScroll(sz, pos, priority, topfunc)
    return item
end

return LobbyScrollView