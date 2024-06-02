local robbery = {}

lib.callback.register("o_shopandrobbery:getListRobbery",function()
    return robbery
end)

lib.callback.register("e_shopandrobbery:CountPolice",function ()
    local police = 0
    if Framework == 'esx' then
        for _,v in pairs(ESX.GetExtendedPlayers()) do
            if v.job.name == Config.PoliceJob then
                police += 1
            end
        end
    elseif Framework == 'qb' then
    else
        -- custom framework
    end
    if police >= Config.RequirePolice then
        return true
    end
    return false
end)


RegisterNetEvent("o_shopandrobbery:waitingNextRobbery",function (key,Name)
    Citizen.CreateThread(function()
        robbery[key] = {Name = Name}
        Citizen.Wait(Config.TimeReset * 60000)
        TriggerClientEvent("o_shopandrobbery:respawnNPC",-1,key)
        robbery[key] = nil
    end)
end)