RegisterNetEvent("e_shopandrobbery:waitingNextRobbery",function (key,Name)
    Citizen.CreateThread(function()
        Robbery[key] = {Name = Name}
        Citizen.Wait(Config.TimeReset * 60000)
        TriggerClientEvent("e_shopandrobbery:respawnNPC",-1,key)
        Robbery[key] = nil
    end)
end)

RegisterNetEvent("e_shopandrobbery:Rob",function(key)
    local source = source
    key = key or false
    if key then
        exports.ox_inventory:AddItem(source,'money',Config.Shops[key].Money)
    else
        local random = math.random(Config.CashRegister.min,Config.CashRegister.max)
        exports.ox_inventory:AddItem(source,'money',random)
    end
end)