FROM php:8.3-alpine

LABEL hu.itsziget.ld.project=p04

COPY www /var/www

CMD ["php", "-S", "0.0.0.0:80", "-t", "/var/www"]
