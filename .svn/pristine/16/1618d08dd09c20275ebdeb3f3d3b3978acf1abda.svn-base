-- 版本号拆分，版本统一为1.2.3
local VersionUtils = {}


function VersionUtils.split(inputstr, sep)
    if inputstr == nil then
        return {"0","0","0"}
    end
	if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t

end

function VersionUtils.getMainVersion(version)
    local v = VersionUtils.split(version,"%.")
	return v[1] or "0"
end

function VersionUtils.getSubVersion(version)
	return VersionUtils.split(version,"%.")[2] or "0"
end

function VersionUtils.getBuildVersion(version)
	return VersionUtils.split(version,"%.")[3] or "0"
end

function VersionUtils.isNew(versionLeft,versionRight)
    local vL = VersionUtils.split(versionLeft,"%.")
    local vR = VersionUtils.split(versionRight,"%.")
    for i = 1,3 do
        local l = tonumber(vL[i] or "0")
        local r = tonumber(vR[i] or "0")
        if l > r then return true 
        elseif l < r then
            return false 
        end
    end
    return false
 end
 
function VersionUtils.isOld(versionLeft,versionRight)
    local vL = VersionUtils.split(versionLeft,"%.")
    local vR = VersionUtils.split(versionRight,"%.")
    for i = 1,3 do
        local l = tonumber(vL[i] or "0")
        local r = tonumber(vR[i] or "0")
        if l < r then return true 
        elseif l > r then
            return false 
        end
    end
    return false
 end

function VersionUtils.getVersionInt(version)
    local v = VersionUtils.split(version,"%.")
    local vi = 0
    if v[3] then vi = vi + tonumber(v[3]) end
    if v[2] then vi = vi + tonumber(v[2]) * 100 end
    if v[1] then vi = vi + tonumber(v[1]) * 10000 end
    return vi
end

return VersionUtils