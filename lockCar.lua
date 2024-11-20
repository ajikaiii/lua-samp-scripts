script_name("lockCar")
script_author("by_AJIKAIII")

local encoding = require 'encoding'
local myLib = import 'myLib.lua'
local inicfg = require 'inicfg'
local imgui = require 'imgui'
local memory = require 'memory'
local myLib = import 'myLib.lua'
local vkeys = require 'vkeys'
local mimgui = require 'mimgui'
local wm = require('windows.message')


local hotkey = require('mimhotkey') -- подключаем библиотеку
local bindKeys = {16, 49} -- начальные клавиши (если их 2, то необходимо что бы первая клавиша была зажата ДО нажатия на вторую клавишу)

require 'lib.moonloader'
--local message = require 'lib.samp.events'
local res,samp = pcall(require,'lib.samp.events')

local carId = nil
local carStream = false
local freeze = false
local light = 0

encoding.default = 'CP1251'
u8 = encoding.UTF8

local cX, cY, cZ, x, y, z = nil
local fromCar = false
local time = os.clock()
local keyedit = false
local unlock = false
--local resultcar = false
--local vehHandle = 0

show_main_window = imgui.ImBool(false)


local inicfg = require 'inicfg'
local path = getWorkingDirectory() .. "\\config\\lockCar.ini"

local MainIni = inicfg.load({
    Main = {
        Button = "1"
    },
    CarSettings = {
        LockCar = true, 
        Lights = true
    },
	Location = {
		Pos_x = 16,
		Pos_y = 4,
        Pos_x_img = 10,
        Pos_y_img = 2,
		Active = true
	},
	TextSettings = {
		Text = "0",
		Text_color1 = 0.99998998641968,
		Text_color2 = 1,
		Text_color3 = 0.99999815225601,
        Text_fonts = 'Arial Black',
        Text_fonts_id = 1,
        Text_fonts_flag = 4,
        Text_fonts_flag_id = 0,
		Text_size = 9
	}
}, path)
inicfg.save(MainIni,path)


local image = {
    right = getWorkingDirectory()..'\\img\\right.png',
    right_handle = nil,
    left = getWorkingDirectory()..'\\img\\left.png',
    left_handle = nil,
    up = getWorkingDirectory()..'\\img\\up.png',
    up_handle = nil,
    down = getWorkingDirectory()..'\\img\\down.png',
    down_handle = nil
}


local font_flag = require('moonloader').font_flag
local my_font = renderCreateFont(MainIni.TextSettings.Text_fonts, MainIni.TextSettings.Text_size, MainIni.TextSettings.Text_fonts_flag)

local getX = 0
local getY = 0
local fGetXY = false
local remcomplect = 0
local jobMechanick = false

local renderWindow = mimgui.new.bool(true)
--[[ 
local newFrame = mimgui.OnFrame(
    function() return renderWindow[0] end,
    function(self)
        if mimgui.Begin('MimHotKey example', renderWindow) then
            mimgui.Text('Bind Example')
            hotkey.KeyEditor('myBind', 'Chat message')
            --[[
                рисуем кнопку изменения бинда, привязанную к бинду с айди "mybind"
                текст на кнопке: "Chat message"
                размер кнопки не указан (следовательно он будет менятся в зависимости от размеров текста)
            
            mimgui.End()
        end
    end
) 
]]


local checkBox = imgui.ImBool(false)
local checkBoxLockCar = imgui.ImBool(false)
local checkBoxLights = imgui.ImBool(false)

show_main_window = imgui.ImBool(false)
local buff = imgui.ImBuffer(400)
local button = imgui.ImBuffer(400)

button.v = tostring(MainIni.Main.Button)
checkBox.v = MainIni.Location.Active
checkBoxLights.v = MainIni.CarSettings.Lights
checkBoxLockCar.v = MainIni.CarSettings.LockCar

local color = imgui.ImFloat3(1.0, 1.0, 1.0)
local color_otkat = imgui.ImFloat3(1.0, 1.0, 1.0)
local slider = imgui.ImInt(MainIni.TextSettings.Text_size)
local selected_item = imgui.ImInt(MainIni.TextSettings.Text_fonts_id)
local fonts_flag = imgui.ImInt(MainIni.TextSettings.Text_fonts_flag_id)

buff.v = u8(MainIni.TextSettings.Text)
color.v[1] = MainIni.TextSettings.Text_color1
color.v[2] = MainIni.TextSettings.Text_color2
color.v[3] = MainIni.TextSettings.Text_color3
local clr = myLib.join_argb(0, color.v[1] * 255, color.v[2] * 255, color.v[3] * 255)
color_ = '0x' .. 'FF' .. ('%06X'):format(clr)
--print(clr)


function darkgreentheme()
	imgui.SwitchContext()
	local style  = imgui.GetStyle()
	local colors = style.Colors
	local clr    = imgui.Col
	local ImVec4 = imgui.ImVec4
	colors[clr.FrameBg]                = ImVec4(0.76, 0.6, 0, 0.74)--
	colors[clr.FrameBgHovered]         = ImVec4(0.84, 0.68, 0, 0.83)--
	colors[clr.FrameBgActive]          = ImVec4(0.92, 0.77, 0, 0.87)--
	colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)--
	colors[clr.TitleBgActive]          = ImVec4(0.92, 0.77, 0, 0.85)--
	colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)--
	colors[clr.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.84, 0.68, 0, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.92, 0.77, 0, 1.00)
	colors[clr.Button]                 = ImVec4(0.76, 0.6, 0, 0.85)
	colors[clr.ButtonHovered]          = ImVec4(0.84, 0.68, 0, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.92, 0.77, 0, 1.00)
	colors[clr.Header]                 = ImVec4(0.84, 0.68, 0, 0.75)
	colors[clr.HeaderHovered]          = ImVec4(0.84, 0.68, 0, 0.90)
	colors[clr.HeaderActive]           = ImVec4(0.92, 0.77, 0, 1.00)
	colors[clr.Separator]              = colors[clr.Border]
	colors[clr.SeparatorHovered]       = ImVec4(0.84, 0.68, 0, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(0.84, 0.68, 0, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.76, 0.6, 0, 0.25)
	colors[clr.ResizeGripHovered]      = ImVec4(0.84, 0.68, 0, 0.67)
	colors[clr.ResizeGripActive]       = ImVec4(0.92, 0.77, 0, 0.95)
	colors[clr.TextSelectedBg]         = ImVec4(0.52, 0.34, 0, 0.85)
	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
	colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.ComboBg]                = colors[clr.PopupBg]
	colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end
darkgreentheme()


local lock = false

function onLockCar()
    if carId ~= nil then
        --resultcar, vehHandle = sampGetCarHandleBySampVehicleId(carId)
        local result, car = sampGetCarHandleBySampVehicleId(carId)
        --print(" 3456")
        --x, y, z = getCharCoordinates(PLAYER_PED)
        --cX, cY, cZ  = getCarCoordinates(vehHandle)
        --print(cX, cY, "   "..cZ)
        --print(getCarDoorLockStatus(car))
        if lock then
            if os.clock() - time > 10 then
                if result then
                    if getCarDoorLockStatus(car) == 0 then
                        print("    2222")
                        lockCar()
                        --printStyledString("~w~Door car ~r~~h~close", 3000, 7)
                    end
                else
                    lockCar()
                end
                lock = false
                unlock = true
            end
        else
            if result then
                x, y, z = getCharCoordinates(PLAYER_PED)
                cX, cY, cZ  = getCarCoordinates(car)
                if isCharInCar(PLAYER_PED, car) then
                    if getCarDoorLockStatus(car) == 0  --[[and  os.clock() - time > 0.5]] --[[ and not fromCar ]] then
                        --sampSendChat("/lock")
                        lockVeh(carId)
                        --sampAddChatMessage(string.format("{FF0000}Door car close"))
                        printStyledString("~w~Door car ~r~~h~close", 3000, 7)
                        --lock = true
                        --fromCar = true
                        --time = os.clock()
                    end
                --[[ elseif (math.abs(x - cX) > 0 and math.abs(x - cX) < 2) and (math.abs(y - cY) > 0 and math.abs(y - cY) < 2) and (math.abs(z - cZ) > 0 and math.abs(z - cZ) < 2) then
                    if getCarDoorLockStatus(car) == 2 and os.clock() - time > 0.5 then
                        --print(cX, cY, "   "..cZ)
                        sampSendChat("/lock")
                        time = os.clock()
                    end
                elseif getCarDoorLockStatus(car) == 0 and os.clock() - time > 0.5 and fromCar and math.abs(x - cX) < 3 and math.abs(y - cY) < 3 and math.abs(z - cZ) < 3 then
                    sampSendChat("/lock")
                    time = os.clock() ]]
                elseif math.abs(x - cX) < 4 and math.abs(y - cY) < 4 and math.abs(z - cZ) < 4 then
                    if getCarDoorLockStatus(car) == 2  --[[ and os.clock() - time > 0.3 ]] --[[ and not fromCar ]] then
                        --print(cX, cY, "   "..cZ)
                        --sampSendChat("/lock")
                        unlockVeh(carId)
                        --sampAddChatMessage(string.format("{00FF00}Door car open"))
                        --printStringNow("{FF0000}Door car close", 3000) -- 3000ms = 3sec
                        if not unlock then
                            printStyledString("~w~Door car ~g~~h~open", 3000, 7)
                        end
                        --lock = false
                        --time = os.clock()
                    end
                elseif getCarDoorLockStatus(car) == 0 --[[ and  os.clock() - time > 0.5 ]] then
                        --sampSendChat("/lock")
                        lockVeh(carId)
                        --sampAddChatMessage(string.format("{FF0000}Door car close"))
                        --printStringNow("{FF0000}Door car close", 3000) -- 3000ms = 3sec
                        if not unlock then
                            printStyledString("~w~Door car ~r~~h~close", 3000, 7)
                        else
                            unlock = false
                        end
                        --lock = true
                        --time = os.clock()
                else
                    fromCar = false 
                    if unlock then unlock = false end
                end 
            end
        end
        --[[
        if isCharInCar(PLAYER_PED, car) and getCarDoorLockStatus(car) == 0 and os.clock() - time > 2 then
            sampSendChat("/lock")
            lock = true
            time = os.clock()
        end
        ]]
    end
end

function onReceiveRpc(id, bitStream, priority, reliability, orderingChannel, shiftTs)
    --print("  sdwq   ")
    if id == 24 then
        --print("     asdasd")
        local carhandle = storeCarCharIsInNoSave(PLAYER_PED)
        local result, carPlayerId = sampGetVehicleIdByCarHandle(carhandle)
        if result then
            if raknetBitStreamReadInt16(bitStream) == carPlayerId then
                raknetBitStreamReadInt8(bitStream)
                --raknetBitStreamReadInt8(bitStream)
                light = raknetBitStreamReadInt8(bitStream)
                --print(light)
            end
        end
    elseif id == 15 then
        print("freeze  " .. raknetBitStreamReadInt32(bitStream))
    --[[ elseif id == 73 then
        print("style  " .. raknetBitStreamReadInt32(bitStream))
        print("time  " .. raknetBitStreamReadInt32(bitStream))
        local length = raknetBitStreamReadInt32(bitStream)
        print("text" .. (raknetBitStreamReadString(bitStream, length))) ]]
        
    
    end
end

local ftime = 0
local down2 = false
function onLights()
    if isCharInAnyCar(PLAYER_PED) then
        local carhandle = storeCarCharIsInNoSave(PLAYER_PED) -- Получения handle транспорта
        --local engine, doors, lights = GetVehicleStatus(carhandle)
        --[[ if os.clock() - ftime > 2 then
            print("Engine " , engine)
            print("Doors " , doors)
            print("Lights " , lights)
            ftime = os.clock()
        end ]]
        if os.clock() - ftime > 2 and not down2 then 
            local result, number = getNumberSeatByChar(carhandle, PLAYER_PED)
            if not result and not sampIsCursorActive() and not freeze and (light == 0 or light == 255) then
                --SlightsRead(v)
                setVirtualKeyDown(VK_2, true)
                wait(100)
                setVirtualKeyDown(VK_2, false)
                --Slights(carId)
                ftime = os.clock()
            end
        end
        if isKeyJustPressed(VK_2) then
            down2 = not down2
        end
    else
        down2 = false
    end
end

function unlockVeh(v)
	local bs = raknetNewBitStream()
	raknetBitStreamWriteInt16(bs, v)
	raknetBitStreamWriteInt8(bs, 0)
	raknetBitStreamWriteInt8(bs, 0)
	raknetEmulRpcReceiveBitStream(RPC_SCRSETVEHICLEPARAMSFORPLAYER, bs)
	raknetDeleteBitStream(bs)
end

function lockVeh(v)
	local bs = raknetNewBitStream()
	raknetBitStreamWriteInt16(bs, v)
	raknetBitStreamWriteInt8(bs, 0)
	raknetBitStreamWriteInt8(bs, 1)
	raknetEmulRpcReceiveBitStream(RPC_SCRSETVEHICLEPARAMSFORPLAYER, bs)
	raknetDeleteBitStream(bs)
end

function lockCar()
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt32(bs, #("/lock"))
    raknetBitStreamWriteString(bs, "/lock")
    raknetSendRpc(50, bs) -- 52 - id RPC, bs - наш битстрим, который мы объявили выше
    raknetDeleteBitStream(bs)
end

function positionSet()
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt16(bs, 1332) -- изменяем позицию у машины с ID 1023
    raknetBitStreamWriteFloat(bs, 278.5) -- posX
    raknetBitStreamWriteFloat(bs, -1779.1) -- posY
    raknetBitStreamWriteFloat(bs, 3.9) -- posZ
    raknetEmulRpcReceiveBitStream(159, bs) -- id RPC - 159
    raknetDeleteBitStream(bs)
end

--[[ function GetVehicleStatus(handle) -- return: engine, doors, lights
    local memory = require 'memory'

    return isCarEngineOn(handle), memory.getint8(getCarPointer(handle) + 0x4F8) == 2, memory.getint8(getCarPointer(handle) + 0x584) > 0
end ]]
-- Текущая версия скрипта
script_version '1.0.0'
local dlstatus = require('moonloader').download_status

function update()
    local update_url = "https://raw.githubusercontent.com/ajikaiii/lua-samp-scripts/refs/heads/main/myLibUpdate.json"
    local update_path = getWorkingDirectory() .. "/myLibUpdate.json"

    local script_url = ""
    local script_path = getWorkingDirectory() .. "/myLibsa.lua"
    --local updatePath = os.getenv('TEMP')..'\\Update.json'
    -- Проверка новой версии
    
    downloadUrlToFile(update_url, update_path, function(id, status, p1, p2)
        print(status)
        print("       " .. dlstatus.STATUS_ENDDOWNLOADDATA)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            print("pfpfpfpfpfp")
            local file = io.open(update_path, 'r')
            if file and doesFileExist(update_path) then
                local info = decodeJson(file:read("*a"))
                file:close(); os.remove(update_path)
                if info.version ~= thisScript().version then
                    print(thisScript().version)
                    lua_thread.create(function()
                        wait(2000)
                        -- Загрузка скрипта, если версия изменилась
                        downloadUrlToFile(script_url, script_path, function(id, status, p1, p2)
                            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                                -- Обновление успешно загружено, новая версия: info.version
                                thisScript():reload()
                            end
                        end)
                    end)
                else
                    -- Обновлений нет
                end
            end
        end
    end)
end

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
  	while not isSampAvailable() do wait(100) end
        --[[ if not doesFileExist("moonloader/myLibsa.lua") then
            sampAddChatMessage('[{501c5f}Lock Car{FFFFFF}]: Шрифт не был найден, началось автоматическое скачивание, не закрывайте игру!', -1)
            download_id = downloadUrlToFile('https://disk.yandex.ru/d/--GO8n5jaPvviw', 'moonloader/myLibsa.lua', function(id, status, p1, p2)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then sampAddChatMessage('[{501c5f}Lock Car{FFFFFF}]: Скачивание успешно завершено', -1) end
            end)
            --thisScript():reload()
        end ]]
        update()
        myLib.onDirectoryCreated_({ "img" })
        fonka = renderLoadTextureFromFile('moonloader/img/remcomplect.png')
        beskon = renderLoadTextureFromFile('moonloader/img/beskon.png')
        myLib.onDirectoryCreated( { "config" }, path, MainIni, "\\lockCar.ini")
        if doesFileExist(image.right) then
            image.handle_right = imgui.CreateTextureFromFile(image.right)
        end 
        if doesFileExist(image.left) then
            image.handle_left = imgui.CreateTextureFromFile(image.left)
        end 
        if doesFileExist(image.up) then
            image.handle_up = imgui.CreateTextureFromFile(image.up)
        end 
        if doesFileExist(image.down) then
            image.handle_down = imgui.CreateTextureFromFile(image.down)
        end 
	repeat
		wait(0)
	until sampIsLocalPlayerSpawned()
    update()
	sampAddChatMessage(string.format("{FFD700}Скрипт %s. {FFFF00}Использование: /caredit", thisScript().name))
	print(string.format("{FFD700}Скрипт %s. {FFFF00}Использование: /caredit", thisScript().name))
    --local isCarOpened = getCarDoorLockStatus(veh) < 1 -- <veh - хэндл кара>
    sampRegisterChatCommand("caredit", function()
		show_main_window.v = not show_main_window.v
	end)
    sampRegisterChatCommand("setveh", function()
		positionSet()
	end)
    sampRegisterChatCommand("mess", function()
		sampAddChatMessage("Получен ремкомплект!", -1)
        lockCar()
	end)
    sampRegisterChatCommand('mimkotkey', function()
        renderWindow[0] = not renderWindow[0]
    end)
    hotkey.RegisterCallback('myBind', bindKeys, bindCallback)
    --show_main_window.v = true
    --is_changeact = false

    wait(3000)
	--flag = true
	--sampSendChat("/mm")
    _, _, jobMechanick = myLib.getNMJ()

    while true do
        wait(0)

        if MainIni.Location.Active and (remcomplect > 0 or jobMechanick) then
            renderDrawTexture(fonka, MainIni.Location.Pos_x_img, MainIni.Location.Pos_y_img, 25, 25, 0.0, -1)
            if not jobMechanick then
			    renderFontDrawText(my_font, remcomplect, MainIni.Location.Pos_x + MainIni.TextSettings.Text_size * 0.7, MainIni.Location.Pos_y + MainIni.TextSettings.Text_size * 0.3, color_)
            elseif jobMechanick then
                renderDrawTexture(beskon, MainIni.Location.Pos_x_img, MainIni.Location.Pos_y_img, 25, 25, 0.0, -1)

            end
		end

        if not sampIsChatInputActive() and not sampIsDialogActive() then
            if isKeyJustPressed(myLib.strToIdKeys(MainIni.Main.Button)) then
                sampSendChat("/lock")
            end
        end

        if MainIni.CarSettings.LockCar then
            onLockCar()
        end
        if MainIni.CarSettings.Lights then
            onLights()
        end
        --print(myLib.onFonts()[2])
        --if getActiveInterior() ~= 0 then
            --print("ты находишься в интерьере или в виртуаль2ном мире")
        --end
        if wasKeyPressed(vkeys.VK_LBUTTON) and fGetXY then
			fGetXY = false
			MainIni.Location.Pos_x_img = getX
			MainIni.Location.Pos_y_img = getY-15
            MainIni.Location.Pos_x = getX
			MainIni.Location.Pos_y = getY-15
			MainIni.Location.Active = true
			inicfg.save(MainIni, path)
		end

		imgui.Process = show_main_window.v
    end
end

function getNumberSeatByChar(car, ped)
    if doesVehicleExist(car) then
        local max = getMaximumNumberOfPassengers(car)
        for i = 0, max do
            if getCharInCarPassengerSeat(car, i) == ped then
                return true, i
            end
        end
    end
    return false
end

function samp.onSetVehicleNumberPlate(vehId, text)
    res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if res then 
        if text == sampGetPlayerNickname(id) then
            carId = vehId
            --[[ if carId ~= nil then
                resultcar, vehHandle = sampGetCarHandleBySampVehicleId(carId)
            end ]]
        end
    end
end

function samp.onVehicleStreamIn(vehicleId, data)
    if carId ~= nil then
        if vehicleId == carId then
            carStream = true
        end
    end
end

function samp.onSendPlayerSync(data)
    --[[ if data then
        print(data)
    end ]]
    --[[ print(data.keysData)
    if bit.band(data.keysData, 32) > 0 then -- 4 - кнопка атаки (ctrl/LMB)
        --code (Сообщение в чат будет флудить, если что)
        print("     ")
    end ]]
end

local wm = require('windows.message')

function onWindowMessage(msg, wparam, lparam)
    if msg == wm.WM_KEYDOWN then
        print('Нажата клавиша:',wparam) -- сообщ в консоль ( Ё )
    end
end

function samp.onServerMessage(color, text)
    if string.find(text, ".отремонтировал свой транспорт%.") or string.find(text, "Добро пожаловать, (%S+). Для смены места появления воспользуйся командой %/spch%.") then
        print("Нет работы")
        local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        local myNick = sampGetPlayerNickname(id) 
        if string.find(text, myNick .. " отремонтировал свой транспорт%.") then
            print("отремонтировал транспорт")
            remcomplect = remcomplect - 1
            if remcomplect < 0 then
                remcomplect = 0
            end
        elseif string.find(text, "Добро пожаловать, " .. myNick .. "%. Для смены места появления воспользуйся командой %/spch%.") then
            print("Нет работы")
            jobMechanick = false
        end
    elseif string.find(text, "Получен ремкомплект%!") and not string.find(text, ".Получен ремкомплект") then
        print("Получен ремкомплект")
        remcomplect = remcomplect + 1
    elseif string.find(text, "Ремкомплект куплен. Его должно хватить на одну починку твоего авто %(/repcar%)%.") and not string.find(text, ".Ремкомплект куплен. Его должно хватить на одну починку твоего авто %(/repcar%).") then
        print("Получен ремкомплект")
        remcomplect = remcomplect + 1
    elseif string.find(text, "Ремкомплект куплен за %$(%d+)%. Его хватит на 3 починки твоего транспорта %(/repcar%)%.") and not string.find(text, ".Ремкомплект куплен за %$(%d+)%. Его хватит на 3 починки твоего транспорта %(/repcar%).") then
        print("Получен ремкомплект")
        remcomplect = remcomplect + 3
    elseif string.find(text, "У тебя с собой нет ремкомплекта.") and not string.find(text, ".У тебя с собой нет ремкомплекта.") then
        print("Нет ремкомплекта")
        remcomplect = 0
    elseif string.find(text, "Ты был кикнут из (%S+) лидером (%S+) %((.+)%).") and not string.find(text, "(.+)Ты был кикнут из (%S+) лидером (%S+) %((.+)%).") then
        print("Нет работы")
        jobMechanick = false
    end
end
--Ты был кикнут из Yakuza лидером Cas (Причина не указана).

local gettingAJob = false
local ungettingJob = false
local otherWork = false

function samp.onShowDialog(ID, _, caption, button1, _, textd)
    --[[ if flag and myLib.sampServerFunc() then
        if string.find(caption, "Статистика") then
            flag = false
            for textd in string.gmatch(textd, '[^\r\n]+') do
                if textd:find("Работа:") then
                    --print("       ")
                    if textd:match("Работа:...........(%S+)") == "Механик" then
                        jobMechanick = true
                        --print("       ")
                    end
                end
            end
            return false
        else
            setVirtualKeyDown(0x0D, true)
            setVirtualKeyDown(0x0D, false)
        end
    end ]]
    if string.find(textd, "Устроиться на работу?") then
        if string.find(caption, "Механик") then
            print("Механик")
            gettingAJob = true
        elseif textd:match("(%S+)") ~= "Механик" then
            otherWork = true
        end
    elseif string.find(textd, "Желаешь уволиться?") then
        if string.find(caption, "Увольнение") then
            ungettingJob = true
        end
    end
end


function samp.onSendDialogResponse(id, button, list, input)
    if gettingAJob then
        if button == 1 then
            print("Механик true")
            jobMechanick = true
            gettingAJob = false
        end
    elseif ungettingJob or otherWork then
        if button == 1 then
            print("Механик ungetting")
            jobMechanick = false
            ungettingJob = false
            otherWork = false
        end
    end
end

function samp.onSendCommand(cmd)
    if cmd == "/lock" then
        lock = not lock
        unlock = true
        time = os.clock()
        print("      123")
    end
end

function onWindowMessage(msg, wparam, lparam)
    if msg == wm.WM_KEYDOWN then
        keyedit = true
    end
end

function samp.onTogglePlayerControllable(controllable)
    if not controllable then
        freeze = true
        print("freeze true")
    else
        freeze = false
        print("freeze false")
    end
end

function samp.onDisplayGameText(style, time, text)
    --print("   ")
    --print(u8(text))
    if text == "Домашний транспорт\nоткрыт" then
        print("open house car")
    end
end

function textFormat()
	font_flag = require('moonloader').font_flag
	my_font = renderCreateFont(MainIni.TextSettings.Text_fonts, MainIni.TextSettings.Text_size, MainIni.TextSettings.Text_fonts_flag)
end

local arrow_position = {
    wight = 30,
    height = 45
}

function imgui.OnDrawFrame()
	if show_main_window.v then
        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.TwoUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(430, 345), imgui.Cond.TwoUseEver)
		imgui.Begin('Car Setting', show_main_window, imgui.WindowFlags.NoCollapse)
            --imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Настройка Auto-Graffiti").x)/2)
            setPosY = 0
            imgui.SetCursorPosY(33 + setPosY)
            --imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8"Изменить активацию").x-20)/2)

            imgui.BeginChild("changee")
                imgui.TextColored(imgui.ImVec4(1.0, 1.0, 0.7, 1.0), u8"Настройка взаимодействия с домашним автомобилем")
                imgui.SameLine()
            imgui.EndChild()

            
            imgui.SetCursorPosY(65 + setPosY)
            setPosY = 30
            imgui.Separator()
            imgui.Spacing()
            imgui.Spacing()
            imgui.BeginChild('Настройки', imgui.ImVec2(390, 73 + setPosY))
                checkBoxLights.v = MainIni.CarSettings.Lights
                if imgui.Checkbox(u8'Авто - включение фар', checkBoxLights) then
                    MainIni.CarSettings.Lights = checkBoxLights.v
                    inicfg.save(MainIni,path)
                end
                checkBoxLockCar.v = MainIni.CarSettings.LockCar
                if imgui.Checkbox(u8'Авто - открытие/закрытие дверей', checkBoxLockCar) then
                    MainIni.CarSettings.LockCar = checkBoxLockCar.v
                    inicfg.save(MainIni,path)
                end
                imgui.SetCursorPosY(30 + setPosY)
                imgui.TextColored(imgui.ImVec4(1.0, 1.0, 0.7, 1.0), u8"Изменение клавиши открытия двери")
                imgui.Text(u8"Нажмите клавишу для изменения/сохранения")
                imgui.SameLine()
                imgui.SetCursorPosY(46 + setPosY)
                if imgui.Button(button.v) then
                    if button.v ~= "Press key..." then
                        buttonedit = not buttonedit
                        MainIni.Main.Button = tostring(button.v)
                        inicfg.save(MainIni, path)
                    end
                end
                if buttonedit then
                    if myLib.getDownKeysText() then
                        button.v = myLib.getDownKeysText()
                    end
                end
                --imgui.SetCursorPosY(57+44)
            imgui.EndChild()
            --imgui.Spacing()

            imgui.Separator()
            imgui.Spacing()
            imgui.Spacing()
            
            imgui.BeginChild('Позиция', imgui.ImVec2(390, 130))
                checkBox.v = MainIni.Location.Active
                if imgui.Checkbox(u8'Отображение ремкомплектов на экране', checkBox) then
                    MainIni.Location.Active = checkBox.v
                    inicfg.save(MainIni,path)
                end
                imgui.Spacing()
                imgui.Spacing()
                if imgui.Button(u8'Изменить позицию') then
                    fGetXY = true
                end
            
            
                --imgui.ImageButton(image.handle_up, imgui.ImVec2(20, 20), imgui.ImVec2(0,0),  imgui.ImVec2(1,1), -1, imgui.ImVec4(1,1,1,0), imgui.ImVec4(1,1,1,1))
                if image.handle_up then
                    imgui.SetCursorPos(imgui.ImVec2(arrow_position.wight + 15, arrow_position.height + 30))
                    imgui.Image(image.handle_up, imgui.ImVec2(20, 20))
                    if imgui.IsItemClicked() then
                        MainIni.Location.Pos_y = MainIni.Location.Pos_y - 1
                        inicfg.save(MainIni,path)
                    end
                end
                if image.handle_right then
                    imgui.SetCursorPos(imgui.ImVec2(arrow_position.wight + 30, arrow_position.height + 45))
                    imgui.Image(image.handle_right, imgui.ImVec2(20, 20))
                    if imgui.IsItemClicked() then
                        MainIni.Location.Pos_x = MainIni.Location.Pos_x + 1
                        inicfg.save(MainIni,path)
                    end
                end
                if image.handle_left then
                    imgui.SetCursorPos(imgui.ImVec2(arrow_position.wight + 0, arrow_position.height + 45))
                    imgui.Image(image.handle_left, imgui.ImVec2(20, 20))
                    if imgui.IsItemClicked() then
                        MainIni.Location.Pos_x = MainIni.Location.Pos_x - 1
                        inicfg.save(MainIni,path)
                    end
                end
                if image.handle_down then
                    imgui.SetCursorPos(imgui.ImVec2(arrow_position.wight + 15, arrow_position.height + 60))
                    imgui.Image(image.handle_down, imgui.ImVec2(20, 20))
                    if imgui.IsItemClicked() then
                        MainIni.Location.Pos_y = MainIni.Location.Pos_y + 1
                        inicfg.save(MainIni,path)
                    end
                end
                

            
                --imgui.SetCursorPosY(110+44)
                --[[ if imgui.Text(u8"Основной текст на экране") then
                end
                encoding.default = 'UTF-8'
                u8 = encoding.CP1251
                --imgui.SetCursorPosY(140+44)
                imgui.PushItemWidth(200)
                if imgui.InputText('##text1',buff) then

                    MainIni.TextSettings.Text = u8(buff.v)
                    inicfg.save(MainIni,path)
                end

                encoding.default = 'CP1251'
                u8 = encoding.UTF8
                --imgui.SetCursorPosY(175+44)
                
                imgui.PopItemWidth() ]]
            imgui.EndChild()

            setPosY = 47
            --imgui.SetCursorPosY(215+44)
            imgui.SetCursorPosX((160))
            imgui.SetCursorPosY(166 + setPosY)
            imgui.BeginChild('Окно настроек', imgui.ImVec2(260, 115))
                imgui.SetCursorPosY(15)
                if imgui.ColorEdit3(u8'Цвет текста', color) then
                    local clr = myLib.join_argb(0, color.v[1] * 255, color.v[2] * 255, color.v[3] * 255)
                    color_ = '0x' .. 'FF' .. ('%06X'):format(clr)
                    --print(clr)
                    MainIni.TextSettings.Text_color1 = color.v[1]
                    MainIni.TextSettings.Text_color2 = color.v[2]
                    MainIni.TextSettings.Text_color3 = color.v[3]
                    inicfg.save(MainIni,path)
                    --print(('%06X'):format(clr))
                    --cfg.main.color = clr

                end

                if imgui.SliderInt(u8"Размер", slider, 5, 35) then
                    MainIni.TextSettings.Text_size = slider.v
                    inicfg.save(MainIni,path)
                    textFormat()
                end
                if imgui.Combo(u8'Шрифт', selected_item, myLib.onFonts(), -1) then
                    MainIni.TextSettings.Text_fonts =  myLib.onFonts()[selected_item.v+1]
                    MainIni.TextSettings.Text_fonts_id = selected_item.v
                    inicfg.save(MainIni,path)
                    textFormat()
                end
                
                if imgui.Combo(u8'Флаги', fonts_flag, myLib.onFontFlagsName(), -1) then
                    if fonts_flag.v ~= 0 then
                        MainIni.TextSettings.Text_fonts_flag = MainIni.TextSettings.Text_fonts_flag + myLib.onFontFlags()[fonts_flag.v+1]
                    else
                        MainIni.TextSettings.Text_fonts_flag = 0
                    end
                    inicfg.save(MainIni,path)
                    textFormat()
                end
               
            imgui.EndChild()
        imgui.End()
    end
    if fGetXY then
		getX, getY = getCursorPos()
		--sampAddChatMessage(getX)
        renderDrawTexture(fonka, getX, getY-15, 28, 28, 0.0, -1)
		renderFontDrawText(my_font, remcomplect, getX, getY-15, 0xFFFFFFFF)
	end
end
