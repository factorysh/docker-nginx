Nginx images for docker
=======================

La home par défaut est `/var/www/html`.

Il est recommandé d'écraser le fichier `default` dans sa propre image,
pour avoir des réglages fin et spécifiques.

Le virtualhosting et le SSL sera géré en amont, ce n'est pas le rôle de l'image nginx.

Entrypoint
----------

Un [ENTRYPOINT](https://docs.docker.com/engine/reference/builder/#entrypoint)
va générer tous les fichiers de configurations dynamiques avant de
lancer la *command*.

Le système de de template est le très simpliste
[envsubst](https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html)

Tous les fichiers `/etc/nginx/conf.d/*.tmpl` vont être mouliné en `.conf`
pour peu que le fichier n'existe pas déjà.

