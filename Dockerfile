ARG DEBIAN_DISTRO=stretch
FROM bearstech/debian:${DEBIAN_DISTRO}

RUN set -eux \
    &&  apt-get update \
    &&  apt-get install -y --no-install-recommends \
                nginx-light \
    &&  apt-get clean \
    &&  rm -rf /var/lib/apt/lists/* \
    # nginx official workaround used to redirect stuff to stdout/err
    &&  ln -sf /dev/stdout /var/log/nginx/access.log \
    &&  ln -sf /dev/stderr /var/log/nginx/error.log \
    # Unroot image stuff
    &&  mkdir /run/nginx \
    &&  chown -R www-data:www-data /run/nginx /var/lib/nginx /var/www

# Specify dedicated user, www-data
USER www-data

# Default config
COPY ./files/nginx.conf /etc/nginx/nginx.conf
COPY ./files/default /etc/nginx/sites-enabled/
COPY ./files/test.html /var/www/html/

# nginx command
CMD ["nginx", "-g", "daemon off;"]
