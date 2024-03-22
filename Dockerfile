ARG PHPVER=8.3

FROM composer:latest as composer
FROM php:${PHPVER}-alpine as builder

# Package dependencies
RUN \
    apk update && \
    apk add \
        curl  \
        icu-dev \
        libpng-dev \
        libpq-dev \
        linux-headers \
        hiredis-dev \
        git \
        zip \
        build-base \
        autoconf \
        openssh-client \
    && \
    docker-php-source extract && \
    sh -c 'for mod in gd intl opcache pdo_pgsql pdo_mysql pgsql ; do echo Installing $mod; docker-php-ext-configure $mod ; docker-php-ext-install $mod ; done' && \
    sh -c 'for mod in apcu redis mailparse xdebug ; do echo Installing $mod; pecl install -o -f $mod ; docker-php-ext-enable --ini-name foo.ini $mod ; done' && \
    sh -c 'for mod in pdo_pgsql ; do echo Installing $mod; pecl install -o -f $mod ; docker-php-ext-enable --ini-name foo.ini $mod ; done' && \
    docker-php-source delete

# Composer
WORKDIR /app
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Create the application directory
RUN mkdir var && \
    chown www-data: var
COPY public public
COPY src src
COPY .env ./
COPY composer.json ./
# COPY composer.lock ./
RUN composer install --optimize-autoloader

# tar the binary artifacts created above for COPY/untar in later stage
RUN tar -C / -czvf /app/root.tar.gz \
        /usr/local/etc /usr/local/lib/php/extensions

FROM php:${PHPVER}-fpm-alpine

# # App dependencies from builder stage
COPY --from=builder --chown=www-data:www-data /app /app

RUN apk update && \
    apk add \
        runit \
        nginx \
        hiredis \
        libpng \
        libpq \
        gettext \
        icu && \
    tar -C / -xzf /app/root.tar.gz && rm -f /app/root.tar.gz

# # Multiservice scaffolding
COPY docker/runit /etc/runit
COPY docker/nginx/http.d /etc/nginx/http.d
COPY docker/php-fpm.d/app.conf /usr/local/etc/php-fpm.d/app.conf

RUN \
    mkdir /s && \
    ln -s /etc/runit/php-fpm /s/php-fpm && chmod +x /etc/runit/php-fpm/run && \
    ln -s /etc/runit/nginx /s/nginx && chmod +x /etc/runit/nginx/run;

WORKDIR /app/public

CMD ["runsvdir", "-P", "/s"]
