fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Aimeri'
description 'Aimeri Dumpster Diving'
version '2.0.0'

shared_scripts {
    '@oxlib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'ox_lib',
    'ox_target',
    'ox_inventory'
}

/*
CREATE TABLE IF NOT EXISTS aimeri_dumpster (
    id INT NOT NULL AUTO_INCREMENT,
    dumpster_name VARCHAR(255) NOT NULL,
    owner_cid VARCHAR(50) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY unique_dumpster (dumpster_name)
);
*/