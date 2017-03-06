# Nginx
# select image
FROM bearstech/jessie:latest

# update stuff
RUN apt-get update
RUN apt-get upgrade -y
# install nginx
RUN apt-get install -y nginx-light

# nginx official workaround used to redirect stuff to stdout/err
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# Unroot image stuff
RUN touch /var/run/nginx.pid
RUN chown -R www-data:www-data /var/run/nginx.pid /var/lib/nginx

# Specify dedicated user, www-data
USER www-data

# Default config
COPY ./rsrc/nginx.conf /etc/nginx/nginx.conf
COPY ./rsrc/default /etc/nginx/sites-enabled/

# expose port
EXPOSE 8000

# nginx command
CMD ["nginx", "-g", "daemon off;"]
