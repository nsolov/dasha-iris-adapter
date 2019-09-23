#!/usr/bin/env bash

NGINX_CONF=default.conf
DOCKER_COMPOSE=docker-compose.yml

function env_vars_substitution() {
  source vars
  export DOMAIN SSL_CERT_PATH SSL_PRIVATE_KEY

  envsubst '${DOMAIN},${SSL_CERT_PATH},${SSL_PRIVATE_KEY}' < ${NGINX_CONF}.tpl > ${NGINX_CONF}
  envsubst '${DOMAIN},${SSL_CERT_PATH},${SSL_PRIVATE_KEY}' < ${DOCKER_COMPOSE}.tpl > ${DOCKER_COMPOSE}
}

function clean() {
  rm -f ${NGINX_CONF} ${DOCKER_COMPOSE}
}

case ${1} in
  start)
    env_vars_substitution
    sudo docker-compose build --no-cache
    sudo docker-compose up -d
    ;;
  iris-logs)
    sudo docker logs -f --tail 10 iris
    ;;
  nginx-logs)
    sudo docker logs -f --tail 10 nginx
    ;;
  iris-exec)
    sudo docker exec -it iris bash
    ;;
  stop)
    env_vars_substitution
    sudo docker-compose down 
    ;;
  *)
    echo "Usage: ${0} <start|iris-logs|nginx-logs|iris-exec|stop>"
    clean
    exit 1
esac

clean

exit 0
