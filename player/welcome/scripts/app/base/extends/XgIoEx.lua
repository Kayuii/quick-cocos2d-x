--[[
	Io Extension
	@Author: ccb
	@Date: 2017-06-10 
]]
require "lfs";
local fileUtils = cc.FileUtils:getInstance();

--[[ 加载lua文件 ]]
function loadLua(fpath)
	local str = fileUtils:getFileData(fpath);
	if str then
		return loadstring(str)();
	end
end

--[[ 加载lua文件 ]]
function loadLuaEx(fpath)
	local str = fileUtils:getFileData(xg.const.UPDATE_STORAGE_PATH .. fpath);
	if not str then
		str = fileUtils:getFileData(fpath);
	end
	return loadstring(str)();
end

--[[ 加载lua内存文件 ]]
function loadLuaData(data)
	local chunk, errorInfo = loadstring(data);
	if not chunk then
		print("loadLuaData error:", errorInfo);
	else
		return chunk();
	end
end

--[[ 获取可写路径 ]]
function getwritablepath()
	return fileUtils:getWritablePath();
end

--[[ 获取文件路径 ]]
function checkDirPath(dpath)
	if not fileUtils:isFileExist(dpath) then
		lfs.mkdir(dpath);
	end

	return dpath;
end

--[[ 获取文件的md5 ]]
function getFileMd5(fpath)
	if fileUtils:isFileExist(fpath) then
		return crypto.md5file(fpath);
	end
end

--[[ 读文件 ]]
function readFile(path)
	local function doRead()
		local f = assert(io.open(path, 'rb'));
		if f then
			local cont = f:read("*a");
			f:close();
			return cont;
		else
			return nil;
		end
	end
	local str = "";
	if try and type(try) == "function" then
		try{
			function()
				str = doRead();
			end,
		};
	else
		str = doRead();
	end
	return str;
end

--[[ 写文件 ]]
function writeFile(path, data, mode)
	local fp, fn = ospathsplit(path);
	checkDirPath(fp);
	printf("写文件 fp:%s fn:%s", fp, fn);

	local function doWrite()
		mode = mode or 'wb';
		local f = assert(io.open(path, mode));
		if f then
			f:write(data);
			f:close();
		end
		return f ~= nil;
	end
	local bret = false;
	if try and type(try) == "function" then
		try{
			function()
				bret = doWrite();
			end,
		};
	else
		bret = doWrite();
	end
	return bret;
end

--[[ 创建文件夹 ]]
function createDirectoryEx(path)
	local tagp = "";
	local arrpath = {};
	
	-- 分割路径保存到table
	for s in string.gmatch(path, string.format("([^'%s']+)", device.directorySeparator)) do
		if s ~= nil then
			table.insert(arrpath, s);
		end
	end

	-- 遍历并拼接路径检测是否存在，不存在则新建
	for k, v in ipairs(arrpath) do
		tagp = (k == 1) and v or string.format("%s%s%s", tagp, device.directorySeparator, v);
		checkDirPath(tagp);
	end
	return tagp;
end

--[[ 获取目标目录下的所有文件路径 ]]
function getpathfiles(rootpath, pathes)
	pathes = pathes or {};
	rootpath = rootpath or '.';
	if fileUtils:isFileExist(rootpath) then 
		for entry in lfs.dir(rootpath) do
			if entry ~= '.' and entry ~= '..' then
				local path = rootpath .. '/' .. entry;
				local attr = lfs.attributes(path);
				if attr then
					if attr.mode == 'directory' then
						getpathfiles(path, pathes);
					else
						table.insert(pathes, path);
					end
				end
			end
		end
	end
	return pathes;
end

--[[ 移除目标目录下的所有文件 ]]
function rmvallfilesindir(rootpath)
	rootpath = rootpath or '.';
	if fileUtils:isFileExist(rootpath) then 
		for entry in lfs.dir(rootpath) do
			if entry ~= '.' and entry ~= '..' then
				local path = rootpath .. '/' .. entry;
				local attr = lfs.attributes(path);
				if attr then
					if attr.mode == 'directory' then
						rmvallfilesindir(path);
					else
						os.remove(path);
					end
				end
			end
		end
	end
end

--[[ 获取路径，文件名 ]]
function ospathsplit(path)
	local apath = nil;
	local fileName = nil;
	if device.platform == "windows" then
		apath = string.match(path, "(.+)\\[^\\]*%.%w+$");
		fileName = string.match(path, ".+\\([^\\]*%.%w+)$");
	else
		apath = string.match(path, "(.+)/[^/]*%.%w+$");
		fileName = string.match(path, ".+/([^/]*%.%w+)$");
	end

	return apath, fileName;
end

--[[ 获取文件名，文件扩展名 ]]
function filesplitex(file)
	if not file then return end

	local fName = nil;
	local fExName = file:match(".+%.(%w+)$");
	local idx = file:match(".+()%.%w+$");
	if idx then
		fName = file:sub(1, idx - 1);
	end

	return fName, fExName;
end

--[[ 获取文件名，文件扩展名 ]]
function ospathsplitex(path)
	local fName = nil;
	local fExName = nil;
	if device.platform == "windows" then
		fName = string.match(path, ".+\\([^\\]*%.%w+)$");
	else
		fName = string.match(path, ".+/([^/]*%.%w+)$");
	end
	if fName then
		fName, fExName = filesplitex(fName);
	end

	return fName, fExName;
end

--[[ 拼接路径 ]]
function ospathconcat(p1, p2)
	if not p1 then return end
	p2 = p2 or "";
	
	local ditspt;
	if string.match(p1, "[(\\)(/)]+$") then
		ditspt = "";
		p1 = string.gsub(p1, "[(\\)(/)]+$", device.directorySeparator);
	else
		ditspt = device.directorySeparator;
	end
	local tag = p1 .. ditspt .. p2;
	tag = string.gsub(tag, "[(\\)(/)]+", device.directorySeparator);

	return tag;
end

--[[ url转路径 ]]
function url2path(url)
	local tag = url;
	if device.platform == "windows" then
		tag = string.gsub(tag, '/', device.directorySeparator);
	end
	return tag;
end
