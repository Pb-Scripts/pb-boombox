fx_version 'cerulean'
game 'gta5'
lua54 'yes'

client_script 'client.lua'
server_script 'server.lua'

shared_script {
    'shared.lua',
    '@pb_utils/init.lua',
}

dependencies {
    'pb-utils',
    'xsound'
}
