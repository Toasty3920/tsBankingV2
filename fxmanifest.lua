fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Toasty3920 - TS-Shop'
description 'tsBankingV2 - Visit TS-Shop Discord here: https://discord.gg/9K6GzGAAhd'
version '2.0.0'

client_scripts {
    'client/cl_main.lua',
}

shared_scripts {
    '@es_extended/imports.lua',
    '@es_extended/locale.lua',
    'locales/de.lua',
    'config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_main.lua',
}

ui_page "html/index.html"      -- don't change this!

files {
    "html/index.html",         -- don't change this!
    "html/css/app.css",        -- don't change this!
    "html/script/config.js",   -- don't change this!
    "html/script/app.js",      -- don't change this!
    "html/assets/audio/*.mp3", -- don't change this!
}