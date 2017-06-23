
local WebRequest = {}
local json = require("CocosJson")

WebRequest.webRoot = require("Domain").WebRoot
WebRequest.payRoot = require("Domain").PayRoot
WebRequest.Blocked = {}
--WebRequest.IsCallBack = true
WebRequest.__index = WebRequest
CCHttpClient:getInstance():setTimeoutForConnect(8)
CCHttpClient:getInstance():setTimeoutForRead(8)

function WebRequest.SAFEATOI(str)    
    return (str == nil) and 0 or (tonumber(str) == nil and 0 or tonumber(str))
end

function WebRequest.SAFEATOI64(str)  
    return WebRequest.SAFEATOI(str)
end

function WebRequest.SAFESTRING(str)
    return (str == nil) and "" or str
end

--解析数据
function WebRequest.parseData(isSucceed, str)
    --状态吗、错误提示、数据
    local isvalid, code, msg, table, parseTable = false, -1, "", {}, nil

    if(isSucceed) then
        if str ~= nil then
            parseTable = json.decode(str);
            if nil ~= parseTable then
                code = parseTable.code
                msg = parseTable.msg
                table = parseTable.list or {}
                isvalid = true
            end
        end
    end

    return isvalid, code, msg, table, parseTable
end

--检测是否有网络网络
function WebRequest.isNetworkAvailable(notShow)
    --判断网络是否存在
    if not CJni:shareJni():isNetworkAvailable() then
        if not notShow then
            require("HallUtils").showWebTip("网络不太稳定，请检测网络设置")
        end
        return false
    end
    return true
end

function WebRequest.getData(callback,url,data,btype,tag,post)
    if not btype then
        --加载模式
        url = WebRequest.getAddress(url)
        WebRequest.getWebData(callback,url,data,tag,post)
    elseif btype == 1 then
        --非加载不阻塞
        url = WebRequest.getAddress(url)
        WebRequest.getWebData(callback,url,data,tag,post,true)     
    else
        --非加载阻塞
        WebRequest.getBlockData(callback,url,data,tag,post)  
    end
end

function WebRequest.getBlockData(callback,url,data,tag,post)
    tag = tag or " "
    url = WebRequest.getAddress(url)

    if not WebRequest.isNetworkAvailable(true) or WebRequest.Blocked[tag] then
        return
    end

    local request = CCLuaHttpRequest:create()
    if post == nil then post = true end
	
	cclog("%s?%s", url, tostring(data))
    request:setUrl(url)
    request:setTag(tag or "")
    request:setRequestType(post and CCHttpRequest.kHttpPost or CCHttpRequest.kHttpGet) 
    if(data ~= nil)  then
        request:setRequestData(data,string.len(data))
    else
        request:setRequestData("",1)
    end

    request:setResponseScriptCallback(function(isSucceed,tag,data)
		if data then cclog(tostring(data)) end
        WebRequest.Blocked[tag] = nil
        if(callback ~= nil) then            
            callback(isSucceed,tag,data)
        end
    end)

    WebRequest.Blocked[tag] = true
    CCHttpClient:getInstance():send(request)
    request:release()
end

function WebRequest.getPayData(callback,url,data,tag,post)
    url = WebRequest.getPayAddress(url)

    WebRequest.getWebData(callback,url,data,tag,post)
end

function WebRequest.getWebData(callback,url,data,tag,post,notShow)
    if not notShow then require("HallUtils").showNetWaiting(true) end

    local request = CCLuaHttpRequest:create()
    if post == nil then post = true end

    cclog("%s?%s", url, tostring(data))
    request:setUrl(url)
    request:setTag(tag or "")
    request:setRequestType(post and CCHttpRequest.kHttpPost or CCHttpRequest.kHttpGet) 
    if(data ~= nil)  then
        request:setRequestData(data,string.len(data))
    else
        request:setRequestData("",1)
    end

    request:setResponseScriptCallback(function(isSucceed,tag,data)
        --if not WebRequest.IsCallBack then return end

        if(callback ~= nil) then
			if data then print(data) end
            callback(isSucceed,tag,data)
        end

        if not notShow then 
            require("HallUtils").showNetWaiting(false)
            --获取到数据错误
            if not isSucceed then
                require("HallUtils").showWebTip("网络不太稳定，获取网络数据失败") 
            end            
        end
    end)

    CCHttpClient:getInstance():send(request)
    request:release()
end

function WebRequest.encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

--获取web地址
function WebRequest.getAddress(file)
    return WebRequest.webRoot .. "/" .. file
end

--获取pay地址
function WebRequest.getPayAddress(file)
    return WebRequest.payRoot .. "/" .. file
end

return WebRequest