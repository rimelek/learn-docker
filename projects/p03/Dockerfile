FROM php:7.1-alpine

COPY www /var/www

CMD ["php", "-S", "0.0.0.0:80", "-t", "/var/www"]

# CMD php -S 0.0.0.0:80 -t /var/www
# is the same as
# CMD ["sh", "-c", "php -S 0.0.0.0:80 -t /var/www"]