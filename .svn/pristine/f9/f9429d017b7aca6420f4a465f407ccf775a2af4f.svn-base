require "iconv"
function getUtf8(inString)
	local outString = iconv.luaiconv(inString,"GBK","UTF-8")
	if outString == "" and string.len(inString) > 1 then
		--截断字符串处理
		outString = iconv.luaiconv(string.sub(inString,1,-2),"GBK","UTF-8")
	end
	return outString
end

function getGBK(inString)
	return iconv.luaiconv(inString,"UTF-8","GBK")
end