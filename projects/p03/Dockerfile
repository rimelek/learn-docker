FROM php:7.4-alpine

LABEL hu.itsziget.ld.project=p03

COPY www /var/www

CMD ["php", "-S", "0.0.0.0:80", "-t", "/var/www"]

# CMD php -S 0.0.0.0:80 -t /var/www
# is the same as
# CMD ["sh", "-c", "php -S 0.0.0.0:80 -t /var/www"]