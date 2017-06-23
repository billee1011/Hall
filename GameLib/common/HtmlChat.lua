-- struct HtmlChat
-- {
-- 	int _dwSubCode;			// 瀛愬懡浠ょ爜
-- 	int _dwSpeaker;			// 璇磋瘽鑰?
-- 	int _dwListener;			// 鎺ユ敹鑰?
-- 	int _dwChannelIDLength;	// 棰戦亾缂撳啿闀垮害
-- 	char  _szContent[1024];
-- 	HtmlChat()
-- 	{
-- 		memset(this,0,sizeof(HtmlChat));
-- 	}
-- 	int getLength()
-- 	{
-- 		return 16 + _dwChannelIDLength + strlen(_szContent + 4);
-- 	}
-- }

local HtmlChat = {}
HtmlChat.__index = HtmlChat

function HtmlChat:new(buffer , nLen)
	local self = {
		_dwSubCode = 0,
		_dwSpeaker = 0,
		_dwListener = 0,
		_dwChannelIDLength = 0,
		_szContent = "_szContent"
	}

	setmetatable(self, HtmlChat)

	if (buffer == nil) then
		return self
	end

	local ba = require("ByteArray").new()
	ba:writeBuf(buffer)
	ba:setPos(1)

	self._dwSubCode = ba:readInt()
	self._dwSpeaker = ba:readInt()
	self._dwListener = ba:readInt()
	self._dwChannelIDLength = ba:readInt()
    cclog("HtmlChat:new(buffer , nLen) "..self._dwSpeaker..";"..self._dwSubCode..";"..self._dwListener)
    
	self._szContent = ba:readBuf(nLen - ba:getPos() + 1)
	return self
end

function HtmlChat:Serialize()
	local ba = require("ByteArray").new()
	ba:writeInt(self._dwSubCode)
	ba:writeInt(self._dwSpeaker)
	ba:writeInt(self._dwListener)
	ba:writeInt(self._dwChannelIDLength)
	ba:writeBuf(self._szContent)
	return ba
end

function HtmlChat:setChatMsg(msg)
	local ba = require("ByteArray").new()
	ba:writeInt(0)
	ba:writeString(msg)
	ba:writeByte(0)
	self._szContent = ba:getBuf()
end

function HtmlChat:getLength()
	return 16 + self._dwChannelIDLength + string.len(string.sub(self._szContent,5))
end

function HtmlChat:getChatMsg()
	if(self._dwSubCode == 0 or self._dwSubCode == 9) then
		local msg = self:RemoveAllHtmlTag(string.sub(self._szContent,self._dwChannelIDLength + 1))
		require("GameLib/common/IconvString")
		return getUtf8(msg)
	end
	
	return ""
end

function HtmlChat:RemoveAllHtmlTag(lpszMsg)	
	return string.gsub(lpszMsg,"<[^>]*>","")
end

return HtmlChat