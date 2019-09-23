server {
  listen 80;
  server_name ${DOMAIN};

  location / {
    proxy_pass http://iris:52773;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    # WebSocket support
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";     
  }
}

server {
  listen 443 ssl;
  server_name ${DOMAIN};

  ssl_certificate ${SSL_CERT_PATH};
  ssl_certificate_key ${SSL_PRIVATE_KEY};

  location / {
    proxy_pass http://iris:52773;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    # WebSocket support
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";    
  }
}

