-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy#7666"
description "Ownable properties for ND Framework"
version "1.0.0"

fx_version "cerulean"
game "gta5"
lua54 "yes"

files {
    "ui/**"
}
ui_page "ui/index.html"

shared_scripts {
    "@ox_lib/init.lua",
    "config.lua"
}
server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/**"
}
client_scripts {
    "client/main.lua",
    "client/elevators.lua"
}

dependencies {
    "oxmysql",
    "ox_lib",
    "ND_Core",
    "ND_Doorlocks"
}
