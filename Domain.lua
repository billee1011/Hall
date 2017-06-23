--[[ Domain.lua
正式服 http://platform.5playing.com.cn/platform/
乐视服 http://platform.5playing.xin/platform/
内网服 http://192.168.2.222:8001/
]]

local Domain = {}

if lanMode then
	Domain.WebRoot = "http://192.168.2.222:8001/"  --"http://platform.5playing.xin/platform/"
	Domain.PayRoot = "http://platform.5playing.xin/payment/"	
else
	Domain.WebRoot = "http://sg.platform.5playing.com/platform/"
	Domain.PayRoot = "http://sg.platform.5playing.com/payment/"
end

-- Domain.WebRoot = "http://192.168.2.222:8001/"
Domain.TestWebRoot = "http://120.132.83.181:8111/platform/"

Domain.Phone = "4006 619 828"
Domain.QQ = "2351133900"

--下载文件目录
Domain.RootFile = CCFileUtils:sharedFileUtils():getWritablePath() .. "com.benteng.games.platform/"
--大厅文件目录
Domain.HallFile = Domain.RootFile .. "Hall/"

return Domain