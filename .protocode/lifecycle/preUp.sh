#!/bin/bash

set -e

# Install intelephense extension for vscode
code --install-extension bmewburn.vscode-intelephense-client

# Get vars declared globally in protocode to update values in .env file accordingly
export $(grep -v '^#' .protocode-runtime/.env | xargs)

# Create local setting file
if [ ! -f web/sites/default/settings.php ]; then
    cat web/sites/default/default.settings.php | sudo tee web/sites/default/settings.php >/dev/null
    sudo chown $(id -u):$(id -g) web/sites/default/settings.php

    CONFIG_DIR_HASH=$(head -c 55 /dev/urandom | base64 | tr -d '=' | tr '/' '_' | tr '+' '-')

    echo "
\$databases['default']['default'] = array (
    'database' => '$DB_NAME',
    'username' => '$DB_USER',
    'password' => '$DB_PASSWORD',
    'prefix' => '',
    'host' => '$DB_HOST',
    'port' => '$DB_PORT',
    'isolation_level' => 'READ COMMITTED',
    'namespace' => 'Drupal\\mysql\\Driver\\Database\\mysql',
    'driver' => 'mysql',
    'autoload' => 'core/modules/mysql/src/Driver/Database/mysql/',
);
\$settings['config_sync_directory'] = 'sites/default/files/config_$CONFIG_DIR_HASH/sync';
" >> web/sites/default/settings.php

    sudo mkdir -p web/sites/default/files/config_$CONFIG_DIR_HASH/sync
    sudo chown $(id -u):$(id -g) web/sites/default/files/config_$CONFIG_DIR_HASH

    SALT_HASH=$(head -c 55 /dev/urandom | base64 | tr -d '=' | tr '/' '_' | tr '+' '-')
    sudo sed -i "s/\$settings\['hash_salt'\] = ''/\$settings\['hash_salt'\] = '$SALT_HASH'/" web/sites/default/settings.php
fi
