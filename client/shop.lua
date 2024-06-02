if Config.ox_inventoryShop then
    exports.ox_target:addModel(GetHashKey(Config.pedModel),{
        label = "Magasin",
        distance = 2.0,
        icon = "fas fa-shopping-basket",
        onSelect = function (data)
            exports.ox_inventory:openInventory('shop', { type = Config.inventory })
        end
    })
end