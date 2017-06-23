require "lfs"

FileUtils = {}

function FileUtils.writeFile(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end

function FileUtils.readFile(path)
    return C2dxEx:getFileData(path)
end

function FileUtils.exists(path)
    return C2dxEx:isFileExist(path)
end

function FileUtils.mkdir(path)
    if not FileUtils.exists(path) then
        return lfs.mkdir(path)
    end
    return true
end

function FileUtils.recursiveMkdir(path)
    path = string.gsub(path,"\\","/")
    
    local lastDir = nil
    while true do
        local split = string.find(path,"/")
        if(split == nil) then
            return
        end
        local dir = string.sub(path,1,split - 1)
        path = string.sub(path,split + 1)
        
        lastDir = (lastDir == nil) and dir or (lastDir .. "/" ..dir)
        --print(string.format("path = %s,dir = %s",path,lastDir))
        FileUtils.mkdir(lastDir)
    end
end

function FileUtils.rmdir(path)
    if FileUtils.exists(path) then
        local function _rmdir(path)
            local iter, dir_obj = lfs.dir(path)
            while true do
                local dir = iter(dir_obj)
                if dir == nil then break end
                if dir ~= "." and dir ~= ".." then
                    local curDir = path .."/" .. dir
                    local mode = lfs.attributes(curDir, "mode") 
                    if mode == "directory" then
                        _rmdir(curDir)
                    elseif mode == "file" then
                        os.remove(curDir)
                    end
                end
            end
            
            local succ, des = lfs.rmdir(path)
            if des then print(des) end
            return succ
        end
        _rmdir(path)
    end
    return true
end

function FileUtils.getFolderSize(path)
    local ret = 0
    if FileUtils.exists(path) then
        local function _getSize(path)
            local iter, dir_obj = lfs.dir(path)
            local size = 0
            while true do
                local dir = iter(dir_obj)
                if dir == nil then break end
                if dir ~= "." and dir ~= ".." then
                    local curDir = path .."/" .. dir
                    local mode = lfs.attributes(curDir, "mode") 
                    if mode == "directory" then
                        size = size + _getSize(curDir)
                    elseif mode == "file" then
                        size = size + lfs.attributes(curDir, "size") 
                    end
                end
            end     
            return size           
        end
        ret = ret + _getSize(path)
    end
    return ret
end

function FileUtils.copyFile(src,dest)
	local srcData = FileUtils.readFile(src)
	if srcData == nil then return end
	FileUtils.recursiveMkdir(dest)
	FileUtils.writeFile(dest,srcData)
end

function FileUtils.copyDirectory(src,dest)    
	if src == nil or dest == nil then return end
	FileUtils.recursiveMkdir(dest)
	local iter, dir_obj = lfs.dir(src) 
   	while true do
        local dir = iter(dir_obj)
        if dir == nil then break end
        if dir ~= "." and dir ~= ".." then
        	local srcDir = src..dir
        	local destDir = dest..dir
        	local mode = lfs.attributes(srcDir, "mode") 
            if mode == "directory" then
                --FileUtils.mkdir(destDir.."/")
                FileUtils.copyDirectory(srcDir .. "/",destDir .. "/")
            elseif mode == "file" then
                FileUtils.copyFile(srcDir,destDir)
            end
        end
   	end
end

return FileUtils