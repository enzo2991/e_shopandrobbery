fx_version 'cerulean'
game 'gta5'

author 'Enzo2991 | Enzo Galantino'
description 'shop and shop robbery'
version '1.0.0'
lua54 'yes'

client_scripts {
    'client/bridge.lua',
    'client/function.lua',
    'client/shop.lua',
    'client/robbery.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    'server/callback.lua'
}


dependencies {
    'ox_inventory',
    'ox_target'
}