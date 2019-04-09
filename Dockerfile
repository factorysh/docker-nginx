FROM bearstech/debian:stretch

ENV DEBIAN_FRONTEND noninteractive

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
COPY ./files/realip.conf /etc/nginx/conf.d/realip.conf
COPY ./files/entrypoint /usr/local/bin/entrypoint

RUN chown -R www-data /etc/nginx/conf.d
RUN chown -R www-data /var/log/nginx

# Specify dedicated user, www-data
USER www-data

EXPOSE 8000
ARG GIT_VERSION
LABEL com.bearstech.source.nginx=https://github.com/factorysh/docker-nginx/commit/${GIT_VERSION}


ENTRYPOINT ["entrypoint"]
# nginx command
CMD ["nginx", "-g", "daemon off;"]
