FROM rimelek/php:8.3-fpm

LABEL hu.itsziget.ld.project=p05

COPY www /var/www/html

# The scripts interpreted by PHP-FPM executes on behalf of "www-data" user.
RUN chown www-data:www-data -R /var/www/html