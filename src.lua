---@diagnostic disable: need-check-nil, lowercase-global
-- // functions \\ --
function reversetb(t)local t2={}for i,v in pairs(t)do t2[v]=i end return t2 end
local noprint = false
function exit()if not noprint then io.write("Exiting in:")wait(.5)io.write(" 3..")wait(.5)io.write(" 2..")wait(.5)io.write(" 1..")wait(.4)end end
function printf(s,...)if not noprint then io.write(s:format(...).."\n")end end
function print(...)if not noprint then io.write(... .. "\n") end end
function findInArgs(strpattern)strpattern=strpattern..":"for _, v in ipairs(arg)do if v:find(strpattern)then local endval = string.sub(v,#strpattern+1):gsub("\"",''):gsub(" ", '_') return endval ~= '' and endval end end end
function wait(seconds) local start = os. time() repeat until os. time() > start + seconds end
function file_exists(name)local f=io.open(name,"r")if f~=nil then io.close(f)return true else return false end end
function string.split(inputstr, sep) if sep == nil then sep = "%s" end local t={} for str in string.gmatch(inputstr, "([^"..sep.."]+)") do table.insert(t, str) end return t end

-- // building \\ --
local args = reversetb(arg)
local buildfile, buildname, cd, isCMenu, username = findInArgs"file", findInArgs"as", findInArgs'in' or io.popen"cd":read'*l', findInArgs'CMenu' == '1', io.popen"echo %USERPROFILE%":read'*l'
local safecd = cd:gsub(username or 'asdfasdf', '<currentuser>')
if not buildfile and file_exists("main.lua") and not arg[1] then
    buildfile = "main.lua"
end
noprint = args["noprint"] or isCMenu

if arg[1] == "project" or arg[1] == "proj" then
    noprint = true
    buildfile = "main.lua"
    buildname = "Main.exe"
elseif arg[1] == "buildexec" then
    noprint = true
    buildfile = "build"
    buildname = "build"
end

if arg[1] and arg[1]:sub(0, 2) == 'C:' and not arg[3] then
---@diagnostic disable-next-line: cast-local-type
    buildfile = string.split(arg[1], "\\")
    buildfile = buildfile[#buildfile]

    if string.split(buildfile, "%.")[2] ~= "lua" then
        print("This program cannot be used to open that file with. " .. string.split(buildfile, "%.")[2])
        return exit()
    end
end

print "[[[[ LUA Executable Building tool by Tanoshii#0001 ]]]]"
print("Building in: "..safecd)

local function askFor(Type)
    if Type == 'missing' then
        if not buildfile then askFor 'file' end
        if not buildname then askFor 'name' end

        return
    end

    -- build name & file

    io.write("Please enter build "..Type..": ")
    local read = io.read()
    if read:gsub(' ','') ~= '' then
        if Type == 'name' then
            buildname = read
        else
            buildfile = read
        end
    end
end

local function addExtensions()
    if not buildname:find'.exe' then buildname = buildname .. ".exe" end
    if not buildfile:find'.lua' then buildfile = buildfile .. ".lua" end
end

if not arg[1] then

    askFor 'name'
    askFor 'file'

end

if not buildfile and arg[1] and buildname then
---@diagnostic disable-next-line: undefined-field
    buildname = buildfile:gsub(".lua", '')
end

if buildfile and arg[1] and not buildname and not buildfile:find'main' then
    buildname = buildfile:gsub(".lua", '')
end

if noprint and not buildname and buildfile then
    buildname = buildfile:gsub('.exe', '')
end

repeat askFor 'missing' until buildname and buildfile

addExtensions()
printf("Building \"%s\" as \"%s\"\n", buildfile, buildname)

local status = os.execute("%CD%/etc/srlua/glue.exe %CD%/etc/srlua/srlua.exe "..buildfile.." "..buildname)
if status ~= 0 then
    noprint = false
    print("|^^^^^\tError occured.\t|")
    printf("---------------\nstatus code: %i\nbuildfile  : %s\nbuildname  : %s\ncurrentdir : %s\n---------------\n", status, buildfile, buildname, safecd)
else
    printf("Successfully built \"%s\" as \"%s\" in \"%s\".", buildfile, buildname, safecd)
end

exit()

return status