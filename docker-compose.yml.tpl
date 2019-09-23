version: "3.5"
services:
  iris:
    build: .
    image: iris-custom:v0.1.0
    container_name: iris
    hostname: iris
    ports:
    - 51773:51773
    - 52773:52773
    networks:
    - iris

  nginx:
    image: nginx:1.17.3
    container_name: nginx
    hostname: nginx
    volumes:
    - ./default.conf:/etc/nginx/conf.d/default.conf:ro
    - ${SSL_CERT_PATH}:${SSL_CERT_PATH}:ro
    - ${SSL_PRIVATE_KEY}:${SSL_PRIVATE_KEY}:ro
    ports:
    - 80:80
    - 443:443
    networks:
    - iris

networks:
  iris:
    name: iris


