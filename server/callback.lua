lib.callback.register("e_shopandrobbery:getListRobbery",function()
    return Robbery
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


