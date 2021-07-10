ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


ESX.RegisterServerCallback('has4n:kira-kontrol', function (source, cb, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getMoney() >= price then
    xPlayer.removeMoney(price)
    cb(true)
    else
        cb(false)
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Paran yok ortak!'})
    end
    kiraladimi = true
end)

ESX.RegisterServerCallback('has4n:aracBirak', function (source, cb)
    cb(true)
end)
