FROM rimelek/php:7.1-fpm

COPY www /var/www/html

# A PHP-FPM "www-data" felhasználó nevében fut
RUN chown www-data:www-data -R /var/www/html