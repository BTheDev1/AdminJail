fx_version 'cerulean'

game 'gta5'

lua54 'yes'

description "Admin Jail Script Modified By Qvs"

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"config.lua",
	"server/server.lua"
}

client_scripts {
	"config.lua",
	"client/utils.lua",
	"client/client.lua"
}

escrow_ignore {
	'config.lua'
}