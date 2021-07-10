ESX = nil
local coreLoaded = false
Citizen.CreateThread(function()
    while ESX == nil do
      TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
      Citizen.Wait(200)-- Saniye Bekletme
    end
    coreLoaded = true
  end)
  

local npcCoord = {
    {
        ped = 0xF9FD068C,
        coord = vector4(4495.9907226562, -4517.873046875, 3.4123611450195, 33.0),
        name = "has4n#0001",
        carModel = `winky`,
        carSpawn = vector4(4493.9526367188, -4510.12890625, 3.1910510063171, 286.0),
        price = 100
    },
    {
        ped = 0xF9FD068C,
        coord = vector4(1887.5219726562, 2594.7673339844, 44.671928405762, 102.0),
        name = "has4n#0001",
        carModel = `dilettante`,
        carSpawn = vector4(1882.9090576172, 2592.0261230469, 44.672019958496, 2.0),
        price = 100
    },
    {
        ped = 0x4A8E5536,
        coord = vector4(-1798.1485595703, -1225.0150146484, 0.5970861911774, 109.0),
        name = "has4n#0001",
        carModel = `dinghy`,
        carSpawn = vector4(-1789.4418945312, -1232.3885498047, -0.007099891547, 240.0),
        price = 1000
    },
    {
        ped = 0x4A8E5536,
        coord = vector4(-717.364, -1325.89, 0.6016, 109.0),
        name = "has4n#0001",
        carModel = `avisa`,
        carSpawn = vector4(-716.585, -1338.85, -0.212, 240.0),
        price = 1000
    },
    {
        ped = 0xD7606C30,
        coord = vector4(-163.224, -2129.91, 15.705, 200.0),
        name = "Go Kart Kiralama",
        carModel = `veto2`,
        carSpawn = vector4(-161.763, -2138.31, 15.705, 295.0),
        price = 250
    }
} -- avisa

local kiraladimi = false

Citizen.CreateThread(function()
    for i=1, #npcCoord do
        local data = npcCoord[i]
        exports["has4n-kiralik"]:pedcreate("kiralikarac-"..i, data.ped, data.coord.x, data.coord.y, data.coord.z, data.coord.w)

        local blip = AddBlipForCoord(data.coord.x, data.coord.y, data.coord.z)
        SetBlipSprite(blip, 500)
        SetBlipDisplay(blip, 2)
        SetBlipScale (blip, 0.55)
        SetBlipColour(blip, 2)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Araç Kiralama Merkezi")
        EndTextCommandSetBlipName(blip)
        SetModelAsNoLongerNeeded(Pedhash)
    end
   
    while true do
        local time = 250
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        if coreLoaded then
            for i=1, #npcCoord do
                local data = npcCoord[i]
                local mesafe = #(vector3(data.coord.x, data.coord.y, data.coord.z) - playerCoords)
                local yazi = ""..data.name
                if mesafe < 8 then 
                    time = 1
                    if not IsPedInAnyVehicle(playerPed) then
                        if mesafe < 3 then
                            yazi = "[E] "..data.name
                            if IsControlJustReleased(0, 38) then
                                menuAc(data.carModel, data.carSpawn, data.price)
                            end
                        end
                    else
                        yazi = "[E] Kiralık Aracını Teslim Et!"
                        local Arac = GetVehiclePedIsUsing(playerPed)
                        local Plaka = ESX.Math.Trim(GetVehicleNumberPlateText(Arac))
                    
                        if IsControlJustReleased(0, 38) and kiraladimi then
                            if string.starts(Plaka, "KIRALIK") then

                                for i=1, GetVehicleModelNumberOfSeats(GetEntityModel(Arac)) do
                                    if i ~= 1 then
                                        if not IsVehicleSeatFree(Arac, i-2) then 
                                            ESX.ShowNotification('Araçta Başkaları Varken Aracı İade Edemezsin')
                                            return
                                        end
                                    end
                                end

                                ESX.TriggerServerCallback("has4n:aracBirak", function(durum)
                                    if durum then
                                        if DoesEntityExist(Arac) then
                                            TaskLeaveVehicle(playerPed, Arac, 0)
                                            while IsPedInVehicle(playerPed, Arac, true) do
                                                Citizen.Wait(0)
                                            end
                                            kiraladimi = false
                                            NetworkFadeOutEntity(Arac, true, true)
                                            Citizen.Wait(100)
                                            ESX.Game.DeleteVehicle(Arac)
                                            ESX.ShowNotification("Aracı İade Ettin!")
                                        end
                                    end
                                end)
                            else
                                ESX.ShowNotification("Bu Araç Kiralık Değil!", "error")
                            end
                        else


                        end
                    end
                    DrawText3D(data.coord.x, data.coord.y, data.coord.z+2.0, yazi, 0.40)
                end
            end
        end
        Citizen.Wait(time)
    end  
end)


function menuAc(carModel, carSpawn, price)
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'is_araci', {
        title    = "İş Aracı Kiralama Hizmeti",
        align    = 'left',
        elements = { 
            {label = "Aracı Kirala: "..price.."$", value= "kirala"}
        }
    }, function(data, menu)
        if data.current.value == "kirala" and not kiraladimi then
            menu.close()
            ESX.TriggerServerCallback("has4n:kira-kontrol", function(durum)
                if durum then
                    
                    local playerPed = PlayerPedId()
                    local playerCoords = GetEntityCoords(playerPed)
                    local Arac = GetVehiclePedIsUsing(playerPed)
                    local plaka = ESX.Math.Trim(GetVehicleNumberPlateText(Arac))
                    kiraladimi = true
                    ESX.Game.SpawnVehicles(carModel, function(yourVehicle)
                        local vehicleProps = {}
                        vehicleProps.plate = plaka
                        ESX.Game.SetVehicleProperties(yourVehicle, vehicleProps)
                        SetVehicleNumberPlateText(yourVehicle, 'KIRALIK')
                        NetworkFadeInEntity(yourVehicle, true, true)
                        TaskWarpPedIntoVehicle(PlayerPedId(), yourVehicle, -1)
                        SetVehicleHasBeenOwnedByPlayer(yourVehicle, true)
                        local id = NetworkGetNetworkIdFromEntity(yourVehicle)
                        SetNetworkIdCanMigrate(id, true)
                        SetVehicleFuelLevel(yourVehicle, 90.0)
                        DecorSetFloat(yourVehicle, "_FUEL_LEVEL", 90.0)
                        TriggerEvent("x-hotwire:give-keys", yourVehicle)                    
                        ESX.ShowNotification("Araç çıkartıldı")
                    end, {x=carSpawn.x, y=carSpawn.y, z=carSpawn.z, h=carSpawn.w }, true)
                else
                end
            end, price)
        else
            ESX.ShowNotification('Zaten bir araç kiraladın ilk önce onu teslim et!','error')
        end
    end, function(data, menu)
        menu.close()      
    end)
end

function string.starts(String,Start)
    return string.sub(String,1,#Start)==Start
end

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end
