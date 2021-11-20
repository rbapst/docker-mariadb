#!/bin/bash

# Create dummy init DB file
MY_DB=my-db

mkdir initdb.d
cat << EOF > initdb.d/createdb.sql
USE $MY_DB;

DROP TABLE IF EXISTS \`Table1\`;
CREATE TABLE \`Table1\` (
  \`id\` int(2) NOT NULL,
  \`text\` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (\`id\`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
EOF

DB_PASS=$(openssl rand -base64 12)
ROOT_PASS=$(openssl rand -base64 12)
DB_USER=apiuser
DOCKER_NETWORK=db-network
DOCKER_NAME=my-mariadb

docker network create ${DOCKER_NETWORK}
docker run --detach --network ${DOCKER_NETWORK} --name ${DOCKER_NAME} -v $PWD/initdb.d:/docker-entrypoint-initdb.d --env MARIADB_USER=${DB_USER} --env MARIADB_PASSWORD=${DB_PASS} --env MARIADB_ROOT_PASSWORD={ROOT_PASS} --env MARIADB_DATABASE=$MY_DB mariadb:latest

echo $DB_USER password = $DB_PASS
echo root password = $ROOT_PASS
echo docker run -it --network db-network --rm mariadb mysql -h $DOCKER_NAME -u $DB_USER -p

