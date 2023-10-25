cat >dockerfile <<EOF
FROM   nexus-01.keli.vip/base/node:latest as naive-admin-pro-build 
COPY naive-admin-pro .
RUN cp -rf /cache/ node_modules
RUN  npm install pnpm -g && rm -rf dist/* &&    pnpm run build 
FROM   nexus-01.keli.vip/base/php:latest
WORKDIR /var/www
COPY cloud7/docker/php/php.ini /usr/local/etc/php/php.ini
COPY cloud7/docker/nginx /etc/nginx/conf.d
RUN rm -rf /var/www/*
COPY cloud7/public /var/www/public
COPY cloud7/dist /var/www/dist
COPY --from=naive-admin-pro-build  /build/dist  /var/www/dist
COPY cloud7/storage /tmp/storage
COPY . .
RUN  usermod --shell /bin/bash www-data  && chown -R www-data:www-data .

RUN su - www-data -c  "composer install"
ENV TZ  Asia/Shanghai
ENV LANG  "C.UTF-8"
ENV MODE  "production"

# ENTRYPOINT ["/usr/bin/dumb-init", "--"]
# CMD ["bash", "-c","-x", "php bin/laravels start -i  & nginx -g 'daemon off;'"
EOF

git clone -b cloud7-dev git@github.com:innet8/naive-admin-pro.git naive-admin-pro
git clone -b k8s-deploy git@github.com:innet8/cloud7.git cloud7
echo "10.20.217.87  nexus-01.keli.vip" >>/etc/hosts
echo "admin" | docker login nexus-01.keli.vip --username admin --password-stdin

docker build -t nexus-01.keli.vip/cloud7:test
