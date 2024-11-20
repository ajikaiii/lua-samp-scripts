inicfg = require 'inicfg'
local key = require 'vkeys'
local encoding = require 'encoding'
require 'lib.moonloader'
--local message = require 'lib.samp.events'
local res,samp = pcall(require,'lib.samp.events')

encoding.default = 'UTF-8'
u8 = encoding.CP1251
local mylib = {}

local fonts = {
	--[[
	Arial = 'Arial',
	Arial_Black = 'Arial Black',
	Arial_Narrow = 'Arial Narrow',
	Arial_Unicode_MS = 'Arial Unicode MS',
	Book_Antiqua = 'Book Antiqua',
	Bookman_Old_Style = 'Bookman Old Style'
	]]
	'Arial',
	'Arial Black',
	'Arial Narrow',
	'Arial Unicode MS',
	'Book Antiqua',
	'Bookman Old Style',
	'Calibri',
	'Cambria',
	'Candara',
	'Century',
	'Century',
	'Comic Sans MS',
	'Consolas',
	'Constantia',
	'Corbel',
	'Courier',
	'Franklin',
	'Garamond',
	'Georgia',
	'Impact',
	'Lucida Console',
	'Lucida Sans Unicode',
	'Microsoft Sans Serif',
	'Mistral',
	'Monotype Corsiva',
	'Palatino Linotype',
	'Segoe Print',
	'Segoe Script',
	'Segoe UI',
	'Sylfaen',
	'Tahoma',
	'Times New Roman',
	'Trebuchet MS',
	'Verdana'
}

local font_flags = {
    0x0, --��� ����������
    0x1, --������
    0x2, --���������
    0x4, --�������
    0x8, --����
    0x10, --������������
    0x20 --�����������
}

--[[ local font_flags = {
    NONE      = 0x0,
    BOLD      = 0x1,
    ITALICS   = 0x2,
    BORDER    = 0x4,
    SHADOW    = 0x8,
    UNDERLINE = 0x10,
    STRIKEOUT = 0x20
}
 ]]

local font_flags_name = {
    u8"��� ����������", --��� ����������
    u8"������", --������
    u8"���������", --���������
    "�������", --�������
    "����", --����
    "������������", --������������
    "�����������" --�����������
}


function mylib.hello()
   print('Hello World')
end

function EXPORTS.aboutme()

    id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
    sampAddChatMessage('��� ID: '..id, -1)
    sampAddChatMessage('��� ���: '..sampGetPlayerNickname(id), -1)
    sampAddChatMessage('��� ���: '..sampGetPlayerScore(id), -1)
    sampAddChatMessage('��� ����: '..sampGetPlayerPing(id), -1)
    sampAddChatMessage('��� ��������: '..sampGetPlayerHealth(id), -1)
    sampAddChatMessage('��� �����: '..sampGetPlayerArmor(id), -1)
end








 --������ � ������� (�������� ����������, ������, ����������)

--[[
	function EXPORTS.onDirectoryCreated(directory, path, a, v) 
	��������� ���������� (directory) �� �������������, ���� ���, �������
	��������� ���� (path) �� �������������, ���� ���, �������, ��������� � ���� ������ (a) 

	�������������:
	��������� ������ �������, � ������� ����� ������������ �������:

	local myLib = import 'myLib.lua'
	local inicfg = require 'inicfg'

	local path = getWorkingDirectory() .. "\\config\\��������.ini"
	local MainIni = inicfg.load({
	Main = {
		  main = 0
	  }
	  
	}, path)
	inicfg.save(MainIni,path)

	��� ������������� � ������� �����������:
	myLib.onDirectoryCreated( { "config" }, path, MainIni, "\\��������.ini")
	
]]
function EXPORTS.onDirectoryCreated(directory, path, a, v) 
	for i = 1, #directory do
	  local dir_path = getWorkingDirectory() .. "\\" .. directory[i]
	  if not doesDirectoryExist(dir_path) then createDirectory(dir_path) end
	end
	
	if not doesFileExist(path) then
		  inicfg.save(a, v)
	end
  
	isDirectoryCreated = true
end

function EXPORTS.onDirectoryCreated_(directory) 
	for i = 1, #directory do
	  local dir_path = getWorkingDirectory() .. "\\" .. directory[i]
	  if not doesDirectoryExist(dir_path) then createDirectory(dir_path) end
	end
end

--[[
function OpenFile(arg)

������� ��� �������� ����� � ������ � ����

�������������:
	��������� ������ �������, � ������� ����� ������������ �������:

	local myLib = import 'myLib.lua'

]]
function EXPORTS.onCreatyFile(nameDirectory)
	local ip, port = sampGetCurrentServerAddress()
	local serverIpString = string.format("%s:%d", ip, port)
	local _,myid = sampGetPlayerIdByCharHandle(playerPed)
	mynick = sampGetPlayerNickname(myid)

	if not doesDirectoryExist("moonloader/config//"..ip) then createDirectory("moonloader/config/"..nameDirectory.."/"..ip) end
	local patchFile = "moonloader/config/"..nameDirectory.."/"..ip.."/"..mynick
	return patchFile
end

function EXPORTS.onSaveFile(rwa, patchFile, buff)
	encoding.default = 'UTF-8'
	u8 = encoding.CP1251
	local file = io.open(patchFile..'.txt', 'r+')
	if file == nil then
		--io.close(file)
		file = io.open(patchFile..'.txt', 'w')
	end
	if rwa == 1 then
		file = io.open(patchFile..'.txt', 'r+')
		buff = file:read('*a')
	elseif rwa == 2 then
		file = io.open(patchFile..'.txt', 'w')
		file:write(buff)
	elseif rwa == 3 then
		file = io.open(patchFile..'.txt', 'a')
		file:write("\n" .. buff)
	end
	file:close()
	return buff
end








--������ � ��������������� ������ �� ������ ��������

function EXPORTS.onFonts()
	return fonts
end

function EXPORTS.onFontFlags()
	return font_flags
end

function EXPORTS.onFontFlagsName()
	return font_flags_name
end

function EXPORTS.textToColor(color, MainIni)
	

	
end

function EXPORTS.join_argb(a, r, g, b)
	local argb = b  -- b
	argb = bit.bor(argb, bit.lshift(g, 8))  -- g
	argb = bit.bor(argb, bit.lshift(r, 16)) -- r
	argb = bit.bor(argb, bit.lshift(a, 24)) -- a
	return argb
end






--������ � ���������

function EXPORTS.onReadToArray(patchFile, array)
	encoding.default = 'UTF-8'
	u8 = encoding.CP1251

	local line = ""
	local i = 0
	for line in io.lines(patchFile..'.txt') do
		if string.sub(u8(line), 0, 2) ~= "//" then
			array[i] = u8(line)
			i = i + 1
		end
	end
	return array
end

function EXPORTS.removeObjectInArray(array, j)
	for i = j, #array do
		array[i] = array[i+1]
	end
	return array
end

function EXPORTS.onComparisonOfArrayAndPlayersOnline(array)
	local flag = false
	for j = 1, #array do
		for i in ipairs(getAllChars()) do
			local res, id = sampGetPlayerIdByCharHandle(i)
			if res then
				if sampGetPlayerNickname(id) == array[j] then
					flag = true
					break
				end
			end
		end
		if flag == false then
			table.remove(array, j)
		else 
			flag = false
		end
	end
end

function EXPORTS.onCheckingPlayerOnline(playerId)
	--print(playerId)
	for i, j in ipairs(getAllChars()) do
		--print(i .. "    " .. j)
		local res, id = sampGetPlayerIdByCharHandle(j)
		--print(id)
		if res then
			--print(id)
			if id == playerId then
				--print("123")
				return sampGetPlayerNickname(id)
			end
		end
	end
end

function EXPORTS.comparisonOfNicknames(nick)
	for i = 0, sampGetMaxPlayerId() do -- ���� ������������ ����� (id) �� 0 �� ������������� ������� ���� �� �������
    	if sampIsPlayerConnected(i) then -- ���� � ���� �� ��������� � ������ ��� ���
        	if sampGetPlayerNickname(i) == nick then
				--print("ID" .. i .. "nick " .. sampGetPlayerNickname(i))
				return true
			end
    	end
	end
	return false
end

function EXPORTS.removeLines(file, arg)
    if doesFileExist(file..'.txt') then
        local lines = {}
		local i = 0
		local flag = false
        for line in io.lines(file..'.txt') do 
			if line == arg then
				lines[i] = '**removedline**' 
				flag = true
			else
				lines[i] = line
			end
			--print(lines[i])
			i = i + 1
		end
        local result = {}
        for j = 0, #lines do
            if lines[j] ~= '**removedline**' then table.insert(result, lines[j]) end
        end
        local handle = io.open(file..'.txt', 'w')
        handle:write(table.concat(result, '\n'))
        handle:close()
    end
	return flag
end

function EXPORTS.removingDuplicates(file)
    if doesFileExist(file..'.txt') then
        local lines = {}
		local str = false
        for line in io.lines(file..'.txt') do 
			str = false
			for i = 0, #lines do
				if line == lines[i] then
					str = true
				end
			end
			if not str then
				table.insert(lines, line)
			end
		end
		local handle = io.open(file..'.txt', 'w')
        handle:write(table.concat(lines, '\n'))
        handle:close()
    end
end

function EXPORTS.checkArrayRepeatPlayer(file, nick)
	encoding.default = 'UTF-8'
	u8 = encoding.CP1251

	local lines = {}
	local i = 0
	local flag = false
    for line in io.lines(file..'.txt') do 
		if line == nick or line == "//"..nick then
			if flag == false then
				if string.sub(u8(line), 0, 2) ~= "//" then
					lines[i] = line
				else
					lines[i] = string.gsub(u8(line), "//", "")
				end
				flag = true
			else
				lines[i] = '**removedline**' 
			end
		else
			lines[i] = line
		end
		--print(lines[i])
		i = i + 1
	end
    local result = {}
    for j = 0, #lines do
        if lines[j] ~= '**removedline**' then table.insert(result, lines[j]) end
    end
    local handle = io.open(file..'.txt', 'w')
    handle:write(table.concat(result, '\n'))
    handle:close()
	return flag
end





--�������� �� GALAXY ������

function sampServerFunc()
	local ip, port = sampGetCurrentServerAddress()
	local serverIpString = string.format("%s:%d", ip, port)
	if serverIpString == "80.66.71.70:7777" then
		return true
	elseif serverIpString == "176.32.39.200:7777" then
		return true
	elseif serverIpString == "176.32.39.199:7777" then
		return true
	elseif serverIpString == "176.32.39.198:7777" then
		return true
	elseif serverIpString == "s1.galaxy-rpg.online:7777" then
		return true
	elseif serverIpString == "194.147.32.37:7777" then
		return true
	else
		return false
	end
end







--��������� ������� ��� ��������� ���� ���� IMGUI
function EXPORTS.strToIdKeys(str)
	tKeys = string.split(str, "+")
	if #tKeys ~= 0 then
		for i = 1, #tKeys do
			if i == 1 then
				str = key.name_to_id(tKeys[i], false)
			else
				str = str .. " " .. key.name_to_id(tKeys[i], false)
			end
		end
		return tostring(str)
	else
		return "(("
	end
end

function isKeysDown(keylist, pressed)
    local tKeys = string.split(keylist, " ")
    if pressed == nil then
        pressed = false
    end
    if tKeys[1] == nil then
        return false
    end
    local bool = false
    local key = #tKeys < 2 and tonumber(tKeys[1]) or tonumber(tKeys[2])
    local modified = tonumber(tKeys[1])
    if #tKeys < 2 then
        if not isKeyDown(VK_RMENU) and not isKeyDown(VK_LMENU) and not isKeyDown(VK_LSHIFT) and not isKeyDown(VK_RSHIFT) and not isKeyDown(VK_LCONTROL) and not isKeyDown(VK_RCONTROL) then
            if wasKeyPressed(key) and not pressed then
                bool = true
            elseif isKeyDown(key) and pressed then
                bool = true
            end
        end
    else
        if isKeyDown(modified) and not wasKeyReleased(modified) then
            if wasKeyPressed(key) and not pressed then
                bool = true
            elseif isKeyDown(key) and pressed then
                bool = true
            end
        end
    end
    if nextLockKey == keylist then
        if pressed and not wasKeyReleased(key) then
            bool = false
        else
            bool = false
            nextLockKey = ""
        end
    end
    return bool
end


function string.split(inputstr, sep)
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

function EXPORTS.getDownKeysText()
	tKeys = string.split(getDownKeys(), " ")
	if #tKeys ~= 0 then
		for i = 1, #tKeys do
			if i == 1 then
				str = key.id_to_name(tonumber(tKeys[i]))
			else
				str = str .. "+" .. key.id_to_name(tonumber(tKeys[i]))
			end
		end
		return str
	else
		return "Press key..."
	end
end

function getDownKeys()
    local curkeys = ""
    local bool = false
    for k, v in pairs(key) do
        if isKeyDown(v) and (v == VK_MENU or v == VK_CONTROL or v == VK_SHIFT or v == VK_LMENU or v == VK_RMENU or v == VK_RCONTROL or v == VK_LCONTROL or v == VK_LSHIFT or v == VK_RSHIFT) then
            if v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT then
                curkeys = v
            end
        end
    end
    for k, v in pairs(key) do
        if isKeyDown(v) and (v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT and v ~= VK_LMENU and v ~= VK_RMENU and v ~= VK_RCONTROL and v ~= VK_LCONTROL and v ~= VK_LSHIFT and v ~= VK_RSHIFT) then
            if tostring(curkeys):len() == 0 then
                curkeys = v
            else
                curkeys = curkeys .. " " .. v
            end
            bool = true
        end
    end
    return curkeys, bool
end

function main()
    while not isSampAvailable() do wait(0) end
	repeat
		wait(0)
	until sampIsLocalPlayerSpawned()
  
	wait(1500)
	flag = true
	jobMechanick = false
	sampSendChat("/mm")
	
    while true do
        wait(-1)

    end
end










function samp.onShowDialog(ID, _, caption, button1, _, textd)
    if flag and sampServerFunc() then
        if string.find(caption, u8"����������") then
            flag = false
            for textd in string.gmatch(textd, '[^\r\n]+') do
                if textd:find(u8"������:") then
                    if textd:match(u8"������:...........(%S+)") == u8"�������" then
                        jobMechanick = true
                    end
                end
				if textd:find(u8"���������:") then
					kolvon = textd:match(u8"���������:..........(%d+)")
				end
				if textd:find(u8"���������:") then
					kolvom = textd:match(u8"���������:..........(%d+)")
					print(kolvon, kolvom)
				end
            end
            return false
        else
            setVirtualKeyDown(0x0D, true)
            setVirtualKeyDown(0x0D, false)
        end
    end
end

function EXPORTS.getNMJ()
	return kolvon, kolvom, jobMechanick
end

return {
mylib = mylib,
fonts = fonts
}
