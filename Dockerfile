ARG DEBIAN_VERSION

FROM bearstech/debian:${DEBIAN_VERSION}

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



ENTRYPOINT ["entrypoint"]
# nginx command
CMD ["nginx", "-g", "daemon off;"]

# generated labels

ARG GIT_VERSION
ARG GIT_DATE
ARG BUILD_DATE

LABEL com.bearstech.image.revision_date=${GIT_DATE}

LABEL org.opencontainers.image.authors=Bearstech

LABEL org.opencontainers.image.revision=${GIT_VERSION}
LABEL org.opencontainers.image.created=${BUILD_DATE}

LABEL org.opencontainers.image.url=https://github.com/factorysh/docker-nginx
LABEL org.opencontainers.image.source=https://github.com/factorysh/docker-nginx/blob/${GIT_VERSION}/Dockerfile
