#!/bin/bash

set -e

# Install vendors
docker-compose run --rm -u $(id -u):$(id -g) -it app composer install

# Wait for mysql to be up
MYSQL_PING_COMMAND="mysqladmin ping --silent -h localhost -u\$MYSQL_USER -p\$MYSQL_PASSWORD 2>/dev/null"
if ! docker-compose exec database bash -c "$MYSQL_PING_COMMAND"; then
    echo "Waiting for mysql container to be up..."
    sleep 1
    while ! docker-compose exec database bash -c "$MYSQL_PING_COMMAND"; do 
        sleep 1
    done
    echo "Mysql container is up!"
fi

# Wait fot mysql to allow connections
MYSQL_TEST_CONNECTION_COMMAND="mysql -u\$MYSQL_USER -p\$MYSQL_PASSWORD \$MYSQL_DATABASE -e 'SET foreign_key_checks = 0;' 2>/dev/null"
if ! docker-compose exec database bash -c "$MYSQL_TEST_CONNECTION_COMMAND"; then
    echo "Waiting for mysql container to be ready to handle connections..."
    sleep 1
    while ! docker-compose exec database bash -c "$MYSQL_TEST_CONNECTION_COMMAND"; do 
        sleep 1
    done
    echo "Mysql container is ready to handle connections!"
fi
