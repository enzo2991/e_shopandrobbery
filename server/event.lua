RegisterNetEvent("o_shopandrobbery:waitingNextRobbery",function (key,Name)
    Citizen.CreateThread(function()
        Robbery[key] = {Name = Name}
        Citizen.Wait(Config.TimeReset * 60000)
        TriggerClientEvent("o_shopandrobbery:respawnNPC",-1,key)
        Robbery[key] = nil
    end)
end)