FROM bearstech/debian:stretch

RUN set -eux \
    &&  apt-get update \
    &&  apt-get install -y --no-install-recommends \
                gettext-base \
                nginx-light \
    &&  apt-get clean \
    &&  rm -rf /var/lib/apt/lists/* \
    # nginx official workaround used to redirect stuff to stdout/err
    &&  ln -sf /proc/1/fd/1 /var/log/nginx/access.log \
    &&  ln -sf /proc/1/fd/2 /var/log/nginx/error.log \
    # Unroot image stuff
    &&  mkdir /run/nginx \
    &&  chown -R www-data:www-data /run/nginx /var/lib/nginx /var/www

# Default config
COPY ./files/nginx.conf /etc/nginx/nginx.conf
COPY ./files/default /etc/nginx/sites-enabled/
COPY ./files/test.html /var/www/html/
COPY ./files/realip.tmpl /etc/nginx/conf.d/realip.tmpl
COPY ./files/entrypoint /usr/local/bin/entrypoint

RUN chown -R www-data /etc/nginx/conf.d

# Specify dedicated user, www-data
USER www-data

EXPOSE 8000
# Nginx is used behind a trusted proxy
ENV SET_REAL_IP_FROM 0.0.0.0/0

ENTRYPOINT ["entrypoint"]
# nginx command
CMD ["nginx", "-g", "daemon off;"]
