Nginx images for docker by bearstech
=====================================

Available image:

[bearstech/nginx](https://hub.docker.com/r/bearstech/nginx/)

Dockerfiles
-----------

Dockerfiles are available at https://github.com/factorysh/docker-nginx


Usage
------

```
docker run --rm -v `pwd`:/var/www/html bearstech/nginx
```

Default home is `/var/www/html`.

It's recommended to override the `default` vhost file in your own image for
fine tuning.


Entrypoint
----------

An [ENTRYPOINT](https://docs.docker.com/engine/reference/builder/#entrypoint)
will generate all dynamique configuration when.

The template engine is minimalist:
[envsubst](https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html)

All files found in `/etc/nginx/conf.d/*.tmpl` will be compiled to `.conf` files
by the engine.

