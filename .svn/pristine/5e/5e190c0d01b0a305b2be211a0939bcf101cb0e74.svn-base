local FileUtils = require("GameLib/common/FileUtils")
Configger = {}


local uroot = require("Domain").RootFile

-- 输出一个table
-- relativePath是相对于getWritablePath的路径
function Configger.readConfig(path)
	local ret = {}
	if(path == nil) then return ret end
	if not FileUtils.exists(path) then return ret end

	return require("cjson").decode(FileUtils.readFile(path)) or {}
end

-- 返回true or false
function Configger.writeConfig(path,contentTable)
	if(path == nil) then return false end
	if not FileUtils.exists(path) then 
		FileUtils.recursiveMkdir(path)
	end

	FileUtils.writeFile(path,require("cjson").encode(contentTable))
end

return Configger