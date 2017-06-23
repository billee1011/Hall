--LuaTableView.lua
-- 此TableView只为了解决Scale后常规CCTableView无法点击的BUG，功能不完善
require("CocosExtern")
local LuaTableView = class("LuaTableView",function()
		return CCLayer:create()
	end)

function LuaTableView:ctor()
	self.m_pIndices = {}
end

function LuaTableView:init(size)
	local function onTouch(eventType, x, y)
        if eventType == "began" then                        
            return self:ccTouchBegan(x,y)
        end
        if eventType == "moved" then
        	self:ccTouchMoved(x, y)
        end
        if eventType == "ended" then
        	self:ccTouchEnded(x, y)
    	end
    end
    self:registerScriptTouchHandler(onTouch,false,kCCMenuHandlerPriority,true)
    self:setTouchEnabled(true)


	self:setContentSize(size)
	self:setAnchorPoint(ccp(0,0))
	local pScrollView = CCScrollView:create(size)
	pScrollView:setTouchPriority(kCCMenuHandlerPriority)
	pScrollView:setDirection(kCCScrollViewDirectionVertical)
	pScrollView:setAnchorPoint(ccp(0, 0))	
	self.m_container = CCLayer:create()


	pScrollView:setContainer(self.m_container)
	self.m_pScrollView = pScrollView
	self:addChild(pScrollView)

	local function scrollViewDidScroll(scrollView)
		self:scrollViewDidScroll(scrollView)
	end

	self.m_pScrollView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)

	self:updateCellPositions()
end

function LuaTableView:getContainer()
	return self.m_container
end

function LuaTableView:cellAtIndex(idx)
	local found = nil
	for i=1,#self.m_pIndices do
		if self.m_pIndices[i]:getIdx() == idx then
			return self.m_pIndices[i]
		end
	end
   	return nil
end

function LuaTableView:updateCellPositions()
    self.m_vCellsPositions = {}
    if self.m_cellCountCallback == nil then return end
    local cellCount = self.m_cellCountCallback()
    if (cellCount == 0) then
    	return
    end

    local currentPos = 0
    local cellSize = self.m_cellSizeCallback()
    for  i=1 , cellCount do    
        self.m_vCellsPositions[i] = currentPos   
        currentPos = currentPos + cellSize.height     
    end
    self.m_vCellsPositions[cellCount + 1] = currentPos--1 extra value allows us to get right/bottom of the last cell    
end

function LuaTableView:indexFromOffset(offset)
	offset.y = self.m_container:getContentSize().height - offset.y
	local cellCount = self.m_cellCountCallback()
	local low = 1
    local high = cellCount
    local search = offset.y

    while high >= low  	do
    	local index = low + math.floor((high - low) / 2)
	    local cellStart = self.m_vCellsPositions[index]
	    local cellEnd = self.m_vCellsPositions[index + 1]

	    if (search >= cellStart and search <= cellEnd) then	    
	        return index
	    elseif search < cellStart then	    
	        high = index - 1	    
	    else	    
	        low = index + 1
	    end	    
	end
    

    if low <= 0 then
        return 0
    end

    return -1
end

function LuaTableView:offsetFromIndex(idx)
	local offset = ccp(0, self.m_vCellsPositions[idx])
    local cellSize = self.m_cellSizeCallback()   
    offset.y = self.m_container:getContentSize().height - offset.y - cellSize.height    
    return offset
end

function LuaTableView:setIndexForCell(idx,cell)
	cell:setAnchorPoint(ccp(0,0))
	cell:setPosition(self:offsetFromIndex(idx))
	cell:setIdx(idx)
	self.m_pIndices[#self.m_pIndices + 1] = cell
	if cell:getParent() ~= self.m_container then
		self.m_container:addChild(cell)
	end
end

function LuaTableView:updateCellAtIndex(idx)
	if idx <= 0 then return end
	local cellCount = self.m_cellCountCallback()
	if cellCount == 0 then
		return
	end
	if idx > cellCount then return end
	local cell = self.m_cellCreateCallback(self,idx - 1)
	self:setIndexForCell(idx,cell)
end

function LuaTableView:scrollViewDidScroll(scrollView)
	local cellCount = self.m_cellCountCallback()
	if cellCount == 0 then
		return
	end
	local startIdx = 0
	local endIdx = 0
	local idx = 0
	local maxIdx = cellCount - 1
	local offset = self.m_pScrollView:getContentOffset()
	offset.y = offset.y * -1
	offset.y = offset.y + self:getContentSize().height
	startIdx = self:indexFromOffset(offset)
	if startIdx < 0 then
		startIdx = cellCount
	end
    offset = self.m_pScrollView:getContentOffset()
    offset.y = offset.y * -1
	--offset.y = offset.y - self:getContentSize().height
	endIdx   = self:indexFromOffset(offset)
	if endIdx < 0 then
		endIdx = cellCount
	end
    --cclog("LuaTableView:scrollViewDidScroll start = %d,end = %d,%f",startIdx,endIdx,self.m_pScrollView:getContentOffset().y)
	for i=startIdx,endIdx do
		-- 这里还要判断是否已经创建过
		if self:cellAtIndex(i) == nil then
			self:updateCellAtIndex(i)
		end
	end
end

function LuaTableView:setCellCreateCallback(cellCreateCallback)
	self.m_cellCreateCallback = cellCreateCallback
end

function LuaTableView:setCellCountCallback(cellCountCallback)
	self.m_cellCountCallback = cellCountCallback
end

function LuaTableView:setCellSizeCallBack(cellSizeCallback)
	self.m_cellSizeCallback = cellSizeCallback
end

function LuaTableView:setCellTouchCallBack(cellTouchCallBack)
	self.m_cellTouchCallBack = cellTouchCallBack
end

function LuaTableView:reloadData()
	if self.m_cellCountCallback == nil then return end
	if self.m_cellSizeCallback == nil then return end
	if self.m_cellCreateCallback == nil then return end
	self.m_pIndices = {}
	local bFirst = false
	if self.m_container:getChildrenCount() == 0 then 
		bFirst = true
	end
	local offset = self.m_pScrollView:getContentOffset()
	self.m_container:removeAllChildrenWithCleanup(true)
	local cellCount = self.m_cellCountCallback()

	local cellSize = self.m_cellSizeCallback()
	local y = cellSize.height * (cellCount)
	self.m_container:setContentSize(CCSize(self:getContentSize().width,y))
	self:updateCellPositions()	
	
	self.m_pScrollView:setContentOffset(ccp(0,self.m_pScrollView:minContainerOffset().y))	
	self:scrollViewDidScroll(self.m_pScrollView)	
	self.m_pScrollView:updateInset()
end

function LuaTableView:ccTouchEnded(x, y)	
	if self.m_cellTouchCallBack == nil then return end
    if (self.m_pTouchedCell ~= nil) then    	
       	self.m_cellTouchCallBack(self.m_pTouchedCell)
        self.m_pTouchedCell = nil        
    end
end

function LuaTableView:ccTouchBegan(x, y)
	cclog("LuaTableView:ccTouchBegan 11")
	if not self:isVisible() then return end
	cclog("LuaTableView:ccTouchBegan 22")
	local point = self:convertToNodeSpace(ccp(x, y))
	local contentSize = self:getContentSize()
	if point.x < 0 or point.y < 0 or point.x > contentSize.width or point .y > contentSize.height then
		return
	end

    local point = self.m_container:convertToNodeSpace(ccp(x, y))
   
    local index = self:indexFromOffset(point)
    if index <= 0 then
    	self.m_pTouchPoint = nil
    	return
    end

    self.m_pTouchedCell = self:cellAtIndex(index)

    if self.m_pTouchedCell ~= nil then
    	self.m_touchX = x
    	self.m_touchY = y
    end 
	return self.m_pTouchedCell ~= nil	
end

function LuaTableView:ccTouchMoved(x, y)
    if (self.m_pTouchedCell ~= nil) then    	    	
    	if self.m_touchX ~= nil and self.m_touchY ~= nil then
    		local offset = math.abs(x - self.m_touchX) + math.abs(y - self.m_touchY)
    		if offset < 5 then    			
    			return
    		end
    	end
    	self.m_pTouchedCell = nil
    end
    cclog("LuaTableView:ccTouchMoved")
end

function LuaTableView:ccTouchCancelled(x, y)
    if (self.m_pTouchedCell ~= nil) then    	
        self.m_pTouchedCell = nil
    end
end

function LuaTableView.create(size)
	local layer = LuaTableView.new()
	layer:init(size)
	return layer
end

return LuaTableView