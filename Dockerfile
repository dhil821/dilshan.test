########################################################################################################################
#### PHP
########################################################################################################################
FROM php:7.3-apache

# Fix debconf warnings upon build
ARG DEBIAN_FRONTEND=noninteractive

# Run apt update and install some dependancies needed for docker-php-ext
RUN apt update && apt install -y apt-utils mariadb-client pngquant unzip zip libpng-dev libmcrypt-dev git \
  curl libzip-dev libicu-dev libxml2-dev libssl-dev libsqlite3-dev libsqlite3-0

# Install PHP extensions
RUN docker-php-ext-install mysqli bcmath gd intl xml pdo_mysql pdo_sqlite hash zip dom session opcache exif

RUN a2dissite 000-default.conf

COPY docker/php/conf.d/app.dev.ini $PHP_INI_DIR/conf.d/zzz_app.dev.ini

# Update web root to public
# See: https://hub.docker.com/_/php#changing-documentroot-or-other-apache-configuration
ENV APACHE_DOCUMENT_ROOT /var/www/app/public_html
#RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
#RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
COPY ./docker/apache/website.conf /etc/apache2/sites-available/website.conf
RUN a2ensite website.conf

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && ln -s $(composer config --global home) /root/composer
ENV PATH=$PATH:/root/composer/vendor/bin COMPOSER_ALLOW_SUPERUSER=1

# Install prestissimo (composer plugin). Plugin that downloads packages in parallel to speed up the installation process
# After release of Composer 2.x, remove prestissimo, because parallelism already merged into Composer 2.x branch:
# https://github.com/composer/composer/pull/7904

# Enable mod_rewrite
RUN a2enmod rewrite

WORKDIR /var/www

#Install Composer
COPY . /var/www/

EXPOSE 80