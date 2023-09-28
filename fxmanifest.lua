fx_version 'cerulean'
game 'gta5'
lua54 'yes'

files {
    'locales/*.json'
}

client_script 'client.lua'
server_script 'server.lua'

shared_script {
    '@ox_lib/init.lua',
    '@pb-utils/init.lua'
}

dependencies {
    'pb-utils',
    'xsound'
}
