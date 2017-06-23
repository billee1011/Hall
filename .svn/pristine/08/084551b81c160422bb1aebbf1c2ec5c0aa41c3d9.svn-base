
require("CocosExtern")


local LobbyTableView = class("LobbyTableView", function(sz)
	return CCTableView:create(sz)
end)

function LobbyTableView:initCommonTable(sz, pos, priority)
    self.view_size = sz
    self.item_table = {}

    self:setVerticalFillOrder(kCCTableViewFillTopDown) 
    self:setAnchorPoint(ccp(0,0))
    self:setPosition(pos)
    self:setTouchPriority(priority) 

    local function cellSizeForTable(t,idx)
        if self.cellSize_func then
            return self.cellSize_func(t,idx)
        else
            return 0, 0
        end
    end

    local function numberOfCellsInTableView()
        if self.cellNum_func then
            return self.cellNum_func()
        else
            return 0
        end
    end

    local function tableCellAtIndex(t, i)
        return self:tableCellAtIndex(t,i)
    end 

    self:registerScriptHandler(cellSizeForTable, CCTableView.kTableCellSizeForIndex)
    self:registerScriptHandler(numberOfCellsInTableView, CCTableView.kNumberOfCellsInTableView)
    self:registerScriptHandler(tableCellAtIndex, CCTableView.kTableCellSizeAtIndex) 
end

--添加列表
function LobbyTableView:updataTableView() 
    self:reloadData()
end

--设置cell大小返回函数
function LobbyTableView:setCellSizeFunc(func)
    self.cellSize_func = func
    return self
end

--设置cell数量返回函数
function LobbyTableView:setNumberOfCellsFunc(func)
    self.cellNum_func = func
    return self
end

--设置创建cell函数
function LobbyTableView:setCreateCellFunc(func)
    self.createCell_func = func
    return self
end

--设置更新cell函数
function LobbyTableView:setUpdateCellFunc(func)
    self.updateCell_func = func
    return self
end

--创建或更新cell
function LobbyTableView:tableCellAtIndex(t, i)
    local cell = t:dequeueCell()
    if (nil == cell) then
        cell = CCTableViewCell:new()
    end
    cell:removeAllChildrenWithCleanup(true)

    if (nil == self.updateCell_func) then
        local item = self.createCell_func(i)
        cell:addChild(item, i + 1)
        self.item_table[i + 1] = item
    else
        self.updateCell_func(cell, i)
    end
    return cell
end

--一般通用
function LobbyTableView.createCommonTable(sz, pos, priority)
    local item = LobbyTableView.new(sz)
    item:initCommonTable(sz, pos, priority)
    return item
end

return LobbyTableView