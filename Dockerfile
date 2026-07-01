FROM php:8.5-fpm-bookworm

RUN apt-get update
RUN apt-get install -y \
            git \
            libzip-dev \
            libkrb5-dev \
            libpng-dev \
            libjpeg-dev \
            libwebp-dev \
            libfreetype6-dev \
            libkrb5-dev \
            libicu-dev \
            zlib1g-dev \
            zip \
            ffmpeg \
            libmemcached11 \
            libmemcachedutil2 \
            build-essential \
            libmemcached-dev \
            gnupg2 \
            libpq-dev \
            libpq5 \
            libz-dev \
            cron \
            nano

# IMAP support. In PHP 8.4+ the imap extension was removed from core and moved to
# PECL, and Debian 13 dropped the libc-client-dev package. We therefore pin to
# bookworm and rebuild the UW IMAP c-client library (headers + lib) from the
# Debian source, then compile the PECL imap extension against it.
RUN set -eux; \
    sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/debian.sources; \
    apt-get update; \
    apt-get install -y dpkg-dev libssl-dev libkrb5-dev; \
    cd /tmp; \
    apt-get source uw-imap; \
    cd uw-imap-2007f~dfsg; \
    apt-get build-dep -y uw-imap; \
    dpkg-buildpackage -B -us -uc -nc; \
    dpkg -i /tmp/mlock_*.deb /tmp/libc-client2007e_*.deb /tmp/libc-client2007e-dev_*.deb; \
    cd /tmp; \
    pecl download imap; \
    tar xf imap-*.tgz; \
    cd imap-*/; \
    phpize; \
    ./configure --with-imap=/usr --with-imap-ssl --with-kerberos; \
    make -j"$(nproc)"; \
    make install; \
    docker-php-ext-enable imap; \
    php -m | grep -qi imap; \
    cd /; \
    rm -rf /tmp/*

RUN rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd \
    --with-webp=/usr/include/ \
    --with-freetype=/usr/include/ \
    --with-jpeg=/usr/include/
RUN docker-php-ext-install gd \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl

RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install exif
RUN docker-php-ext-install fileinfo
RUN pecl install -o -f redis \
&&  rm -rf /tmp/pear \
&&  docker-php-ext-enable redis

RUN curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ENV COMPOSER_ALLOW_SUPERUSER 1

WORKDIR /var/www
