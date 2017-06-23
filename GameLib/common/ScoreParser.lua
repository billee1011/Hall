--[[

struct ScoreColumnDesc
{
	unsigned char	cbLength		-- 数据长度
	unsigned char	cbScoreField	-- 分数字段,参看前面的定义
	unsigned char	cbDataType		-- 数据类型,见Data_Type定义
	char	szDesc[16]
	ScoreColumnDesc()
	{
		memset(this,0,sizeof(ScoreColumnDesc))
	}
}

-- 扩展一个列信息
struct ScoreColumnDetailInfo : public ScoreColumnDesc
{
	unsigned int dwOffSet	-- 就加一个在buffer中的偏移量
	ScoreColumnDetailInfo()
	{
		dwOffSet = 0
	}
}
]]

local ScoreColumnDesc = {cbLength,cbScoreField,cbDataType,szDesc}
ScoreColumnDesc.__index = ScoreColumnDesc
function ScoreColumnDesc:new(buffer,nLen)
	local self = {
		cbLength = 0,
		cbScoreField = 0,
		cbDataType = 0,
		szDesc = "Desc"
	}
	setmetatable(self,ScoreColumnDesc)

	if(buffer == nil)	then-- 新建一个对象
		return self
	end
	-- 从buffer中解析
	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)
	self.cbLength = ba:readUByte()	
	self.cbScoreField = ba:readUByte()
	self.cbDataType = ba:readUByte()
	self.szDesc = ba:readStringSubZero(16)
	return self
end

--序列化
function ScoreColumnDesc:Serialize()
	local ba = require("ByteArray").new()
	ba:writeUByte(self.cbLength)
	ba:writeUByte(self.cbScoreField)
	ba:writeUByte(self.cbDataType)
	self.szDesc = string.sub(self.szDesc,1,15)
	ba:writeString(self.szDesc)
	for i=string.len(self.szDesc) + 1,16 do
		ba:writeByte(0)
	end
	ba:setPos(1)
	return ba
end

--获取长度
function ScoreColumnDesc:getLen()
	return 19
end


local ScoreColumnDetailInfo = {scoreColumnDesc,dwOffset}
ScoreColumnDetailInfo.__index = ScoreColumnDetailInfo

-- new 一个对象或者从buffer中解析一个对象
function ScoreColumnDetailInfo:new(buffer,nLen)
	local self = {
		scoreColumnDesc = ScoreColumnDesc:new(buffer,nLen),
		dwOffset = 0
	}
	setmetatable(self,ScoreColumnDetailInfo)

	if(buffer == nil)	then-- 新建一个对象
		return self
	end
	-- 从buffer中解析
	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(scoreColumnDesc:getLen() + 1)
	self.dwOffset = ba:readUInt()	
	return self
end

--序列化
function ScoreColumnDetailInfo:Serialize()
	local ba = require("ByteArray").new()
	ba:writeByteArray(scoreColumnDesc:Serialize())
	ba:writeUInt(self.dwOffset)
	ba:setPos(1)
	return ba
end

--获取长度
function ScoreColumnDetailInfo:getLen()
	return ScoreColumnDesc:getLen() + 4
end

----------------------------- ScoreParser ------------------------------

local CScoreParser = {}
CScoreParser.__index = CScoreParser
function CScoreParser:new() --private method.
    local store = nil

    return function(self)
        if store then return store end
        local o = {
        	m_pHeader = nil,
        	m_nHeaderLen = 0,
        	m_nScoreBufLen = 0,
        	m_bInitalized = false,
        	m_pHeaders = {}
    	}
        setmetatable(o, self)
        self.__index = self
        store = o
        cclog("CScoreParser")
   		return o
    end
end

function CScoreParser:IsInitialized()
	return self.m_bInitalized
end

function CScoreParser:GetScoreField(scoreBuffer,nBufLen,nField)
	-- 应该强制给的buffer的长度是对的
	if self.m_nScoreBufLen == 0 or self.m_nHeaderLen == 0 then
		-- 还没有初始化
		cclog("CScoreParser::GetScoreField() error -- the header is null,ScoreBufLen = "
			.. self.m_nScoreBufLen .. ", HeaderLen = " .. self.m_nHeaderLen)
			
		return 0
	end
	--
	if nBufLen <= 0 then
		cclog("CScoreParser::GetScoreField() error -- the buffer length <= 0")
		return 0
	end
	
	if nBufLen ~= self.m_nScoreBufLen then
		cclog("CScoreParser::GetScoreField() error -- the length mismatch the header,".. nBufLen .. "," .. self.m_nScoreBufLen)
		return 0
	end

	if #self.m_mapHeaders == 0 then 
		cclog("CScoreParser::GetScoreField() error -- #self.m_pHeaders == 0")
		return 0 
	end

	local find = nil
	for i=1,#self.m_mapHeaders do
		if self.m_mapHeaders[i].scoreColumnDesc.cbScoreField == nField then
			find = self.m_mapHeaders[i]
			break
		end
	end

	
	if find == nil then 
		--cclog("GetScoreField field not fount!" .. ",field = " .. nField)
		return 0 
	end
	
	local ba = require("ByteArray").new()
	ba:writeBuf(scoreBuffer)
	ba:setPos(find.dwOffSet)
	--cclog("GetScoreField offset = " .. find.dwOffSet .. ",field = " .. nField .. ",Find.field = " .. find.scoreColumnDesc.cbScoreField)
	--cclog("GetScoreField ba:len = " .. ba:getLen() .. ",buflen = " .. nBufLen)
	return ba:readInt()
end


function CScoreParser:SetScoreHeader(lpScoreHeader,nLen)
	local nFieldLen = ScoreColumnDesc:getLen()
	self.m_bInitialized = false
	if nLen <= 0 then return false end
	

	-- 给的长度是否符合列长度的倍数
	if nLen % nFieldLen ~= 0 then return false end

	self.m_nHeaderLen = nLen
	self.m_pHeader = lpScoreHeader

	--memcpy(m_pHeader,lpScoreHeader,nLen)

	-- 这里对这个头进行分析
	-- 删除所有
	--m_mapHeaders.RemoveAll()
	self.m_mapHeaders = {}
	-- 列数量
	local nColumnCount = self.m_nHeaderLen / nFieldLen
	cclog("nColumnCount = %d",nColumnCount)

	-- 偏移
	self.m_nScoreBufLen = 0
	local ba = require("ByteArray").new()
	ba:writeBuf(lpScoreHeader)
	for i=1,nColumnCount do
		ba:setPos((i - 1) * nFieldLen + 1)
		local desc = ScoreColumnDesc:new(ba:readBuf(nFieldLen),nFieldLen)
		local detail = ScoreColumnDetailInfo:new()
		detail.scoreColumnDesc = desc
		detail.dwOffSet = self.m_nScoreBufLen + 1
		self.m_nScoreBufLen  = self.m_nScoreBufLen + desc.cbLength
		self.m_mapHeaders[i] = detail
		--cclog("SetScoreHeader index " .. i .. ": field = " .. desc.cbScoreField .. ",offset = " .. detail.dwOffSet)
	end
	

	-- 设置成功
	self.m_bInitialized = true
	return true
end

CScoreParser.instance = CScoreParser:new() 

return CScoreParser