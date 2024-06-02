local Blips = {}
local shopsNpc = {}
local Keys = {
    ['ESC'] = 322, ['F1'] = 288, ['F2'] = 289, ['F3'] = 170, ['F5'] = 166, ['F6'] = 167, ['F7'] = 168, ['F8'] = 169, ['F9'] = 56, ['F10'] = 57,
    ['~'] = 243, ['1'] = 157, ['2'] = 158, ['3'] = 160, ['4'] = 164, ['5'] = 165, ['6'] = 159, ['7'] = 161, ['8'] = 162, ['9'] = 163, ['-'] = 84, ['='] = 83, ['BACKSPACE'] = 177,
    ['TAB'] = 37, ['Q'] = 44, ['W'] = 32, ['E'] = 38, ['R'] = 45, ['T'] = 245, ['Y'] = 246, ['U'] = 303, ['P'] = 199, ['['] = 39, [']'] = 40, ['ENTER'] = 18,
    ['CAPS'] = 137, ['A'] = 34, ['S'] = 8, ['D'] = 9, ['F'] = 23, ['G'] = 47, ['H'] = 74, ['K'] = 311, ['L'] = 182,
    ['LEFTSHIFT'] = 21, ['Z'] = 20, ['X'] = 73, ['C'] = 26, ['V'] = 0, ['B'] = 29, ['N'] = 249, ['M'] = 244, [','] = 82, ['.'] = 81,
    ['LEFTCTRL'] = 36, ['LEFTALT'] = 19, ['SPACE'] = 22, ['RIGHTCTRL'] = 70,
    ['HOME'] = 213, ['PAGEUP'] = 10, ['PAGEDOWN'] = 11, ['DEL'] = 178,
    ['LEFT'] = 174, ['RIGHT'] = 175, ['TOP'] = 27, ['DOWN'] = 173,
}

local function createBlip(coords)
    local blip = AddBlipForCoord(coords.x,coords.y,coords.z)
    SetBlipSprite(blip, 59)
    SetBlipColour(blip,  69)
    SetBlipAlpha(blip, 250)
    SetBlipScale(blip, 0.8)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('24/7 | Superette')
    EndTextCommandSetBlipName(blip)
    return blip
end

local function createNpc(pedPos)
    local ped_hash = GetHashKey(Config.pedModel)
	RequestModel(ped_hash)
	while not HasModelLoaded(ped_hash) do
		Citizen.Wait(1)
	end	
	local shopNPC = CreatePed(1, ped_hash, pedPos.x, pedPos.y, pedPos.z-1, pedPos.h, false, true)
	SetPedDiesWhenInjured(shopNPC, false)
	SetPedCanPlayAmbientAnims(shopNPC, true)
	SetPedCanRagdollFromPlayerImpact(shopNPC, false)
	SetEntityInvincible(shopNPC, true)
	FreezeEntityPosition(shopNPC, true)
    return shopNPC
end



Citizen.CreateThread(function ()

    while not ESX.PlayerLoaded do
        Citizen.Wait(0)
    end

    local listRobbery = lib.callback.await("o_shopandrobbery:getListRobbery")
    DebugPrint("CreateNpc on Spawn")
    for k,v in pairs(Config.Shops) do
        Blips[#Blips+1] = createBlip(v.ShopPos)
        if listRobbery[k] == nil then
            if not DoesEntityExist(v.Ped) then
                v.Ped = createNpc(v.PedPos)
                shopsNpc[#shopsNpc+1] = v
            end
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)
        for k,v in pairs(shopsNpc) do
            local pedcoords = GetEntityCoords(v.Ped)
            if (GetDistanceBetweenCoords(coords,pedcoords,false) < 4.0) then
                sleep = 5
                DrawText3Ds(pedcoords.x, pedcoords.y, pedcoords.z+1.0, 'Comment puis-je vous aider ?')
                local weaponShow = IsPedArmed(ped,1)
                local aiming, targetPed = GetEntityPlayerIsFreeAimingAt(PlayerId())
                if IsPlayerFreeAiming(PlayerId()) and targetPed == v.Ped then
                    weaponShow = true
                end
                if weaponShow then
                    local canInteract = lib.callback.await("e_shopandrobbery:CountPolice")
                    if canInteract then
                        FreezeEntityPosition(v.Ped, false)
						SetBlockingOfNonTemporaryEvents(v.Ped, true)
						StartAnim(v.Ped, 'anim@mp_player_intuppersurrender', 'enter')
						local displaying = true
                        TaskGoToCoordAnyMeans(v.Ped, v.PedWalks.x, v.PedWalks.y, v.PedWalks.z, 1.5)
                        Citizen.CreateThread(function()
							Wait(3000)
							displaying = false
						end)
						while displaying do
							Wait(0)
							local coordsPed = GetEntityCoords(v.Ped, false)             
							DrawText3Ds(coordsPed['x'], coordsPed['y'], coordsPed['z'] + 1.2, "Je suis déjà en train d'ouvrir")
						end
                        local atlocation = false
						Citizen.CreateThread(function()
							Wait(10000)
							if atlocation then
								SetEntityCoords(v.Ped, v.PedWalks.x, v.PedWalks.y, v.PedWalks.z-1)
								SetEntityHeading(v.Ped, v.PedWalks.h)
							end
						end)
						while true do
							local coords2 = GetEntityCoords(v.Ped)
							if(GetDistanceBetweenCoords(coords2,  v.PedWalks.x, v.PedWalks.y, v.PedWalks.z, true) < 1.5) then
								atlocation = true
								SetEntityCoords(v.Ped, v.PedWalks.x, v.PedWalks.y, v.PedWalks.z-1)
								SetEntityHeading(v.Ped, v.PedWalks.h)
								break
							end
							Citizen.Wait(5)
						end
                        ClearPedTasks(v.Ped)
						FreezeEntityPosition(v.Ped, true)
						StartAnim(v.Ped, 'amb@prop_human_bum_bin@idle_a', 'idle_a')

                        local coordsPED = GetEntityCoords(v.Ped)
                        local time = v.Time
                        local pack = nil

                        Citizen.CreateThread(function()
							time += 1
							while true do
								time -= 1
								Citizen.Wait(1000)
								if time <= 0 then
                                    lib.notify({
                                        title = 'Braquage de superette',
                                        description = 'Argent liquide prêt à être retiré',
                                        type = 'success',
                                        position = 'top-left'
                                    })
                                    TriggerServerEvent("o_shopandrobbery:waitingNextRobbery",k,v.Name)
									ClearPedTasks(v.Ped)
									StartAnim(v.Ped, 'anim@heists@box_carry@', 'idle')
                                    pack = CreateObject(GetHashKey('prop_cash_case_02'), coordsPED.x, coordsPED.y, coordsPED.z,  true,  true, true)
									AttachEntityToEntity(pack, v.Ped, GetPedBoneIndex(v.Ped, 57005), 0.20, 0.05, -0.25, 260.0, 60.0, 0, true, true, false, true, 1, true)
									break
								end
							end
						end)

                        Citizen.CreateThread(function()
                            while true do
                                if v.CashRegister1 then
                                    if not v.CashRegister1.robbed and (GetDistanceBetweenCoords(coords, v.CashRegister1.x, v.CashRegister1.y, v.CashRegister1.z, true) < 1.5) then
                                        DrawMarker(25, v.CashRegister1.x, v.CashRegister1.y, v.CashRegister1.z-1, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 69, 255, 66, 100, false, true, 2, false, false, false, false)
                                        ShowFloatingHelpNotification("~INPUT_PICKUP~ - Pour voler la caisse", vector3(v.CashRegister1.x, v.CashRegister1.y, v.CashRegister1.z))
                                        if IsControlJustReleased(0, Keys['E']) and not IsPedInAnyVehicle(ped, false) then
                                            SetEntityCoords(ped, v.CashRegister1.x, v.CashRegister1.y, v.CashRegister1.z-1)
                                            SetEntityHeading(ped, v.CashRegister1.h)
                                            StartAnim(ped, "anim@gangops@facility@servers@bodysearch@", "player_search")
                                            if lib.progressCircle({
                                                duration = 4500,
                                                position = 'bottom',
                                                label = 'Taking money...',
                                                useWhileDead = false,
                                                canCancel = true,
                                                disable = {
                                                    car = true,
                                                    move = true
                                                },
                                            }) then
                                                v.CashRegister1.robbed = true
                                                -- TriggerServer For money
                                            end
                                        end
                                    end
                                else
                                    v.CashRegister1.robbed = true
                                end
                                if v.CashRegister2 then
                                    if not v.CashRegister2.robbed and (GetDistanceBetweenCoords(coords, v.CashRegister2.x, v.CashRegister2.y, v.CashRegister2.z, true) < 1.5) then
                                        DrawMarker(25, v.CashRegister2.x, v.CashRegister2.y, v.CashRegister2.z-1, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 69, 255, 66, 100, false, true, 2, false, false, false, false)
                                        ShowFloatingHelpNotification("~INPUT_PICKUP~ - Pour voler la caisse", vector3(v.CashRegister2.x, v.CashRegister2.y, v.CashRegister2.z))
                                        if IsControlJustReleased(0, Keys['E']) and not IsPedInAnyVehicle(ped, false) then
                                            SetEntityCoords(ped, v.CashRegister2.x, v.CashRegister2.y, v.CashRegister2.z-1)
                                            SetEntityHeading(ped, v.CashRegister2.h)
                                            StartAnim(ped, "anim@gangops@facility@servers@bodysearch@", "player_search")
                                            if lib.progressCircle({
                                                duration = 4500,
                                                position = 'bottom',
                                                label = 'Taking money...',
                                                useWhileDead = false,
                                                canCancel = true,
                                                disable = {
                                                    car = true,
                                                    move = true
                                                },
                                            }) then
                                                v.CashRegister2.robbed = true
                                                -- TriggerServer For money
                                            end
                                        end
                                    end
                                else
                                    v.CashRegister2.robbed = true
                                end
                                if v.CashRegister2.robbed and v.CashRegister1.robbed then
                                    break
                                end
                                Citizen.Wait(5)
                            end
                        end)

                        while true do
                            coords = GetEntityCoords(ped)
							if time > 0 then
								if(GetDistanceBetweenCoords(coords, coordsPED.x, coordsPED.y, coordsPED.z, true) < 3.5) then
									DrawText3Ds(coordsPED.x, coordsPED.y, coordsPED.z+1.0, 'Temps restant: '..tostring(time))
								end
                            else
                                if(GetDistanceBetweenCoords(coords, coordsPED.x, coordsPED.y, coordsPED.z, true) < 1.5) then
                                    DrawText3Ds(coordsPED.x, coordsPED.y, coordsPED.z+1, "Pour prendre l'argent, appuyez sur [~r~E~w~]")
                                    if IsControlJustReleased(0, Keys['E']) and not IsPedInAnyVehicle(ped, false) then
										FreezeEntityPosition(v.Ped, false)
										TaskTurnPedToFaceEntity(v.Ped, ped, 0.2)
										StartAnim(ped, "anim@gangops@facility@servers@bodysearch@", "player_search")
										lib.progressCircle({
											duration = 6500,
											position = 'bottom',
											label = "Taking money...",
											useWhileDead = false,
											canCancel = true,
											disable = {
												car = true,
												move = true
											},
										})
                                        -- TriggerServer For money

                                        ClearPedTasks(v.Ped)
										TaskPlayAnim(v.Ped, 'anim@heists@box_carry@', "exit", 3.0, 1.0, -1, 49, 0, 0, 0, 0)
										DeleteEntity(pack)
										break
                                    end
                                end
							end
                            Citizen.Wait(5)
                        end
                        Citizen.Wait(5000)
                        DeletePed(v.Ped)
                        v.Ped = nil
                        shopsNpc[v] = v
                    else
                        lib.notify({
                            title = 'Braquage de superette',
                            description = 'pas assez de policier en ville',
                            type = 'error'
                        })
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

RegisterNetEvent("o_shopandrobbery:respawnNPC")
AddEventHandler("o_shopandrobbery:respawnNPC",function(key)
    for k,v in pairs(shopsNpc) do
        if v.Name == shopsNpc[key].Name then
            if not DoesEntityExist(v.Ped) then
                v.Ped = createNpc(v.PedPos)
                v.CashRegister1.robbed = false
                v.CashRegister2.robbed = false
                shopsNpc[key] = v
            end
            break
        end
    end
end)

