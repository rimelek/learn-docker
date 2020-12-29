FROM itsziget/php:7.4-fpm

LABEL hu.itsziget.ld.project=p06

COPY www /var/www/html

# The scripts interpreted by PHP-FPM executes on behalf of "www-data" user.
RUN chown www-data:www-data -R /var/www/html