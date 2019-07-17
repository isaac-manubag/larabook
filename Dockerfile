# PHP Images can be found at https://hub.docker.com/_/php/
FROM php:7.3-alpine3.9

# The application will be copied in /var/www/html and the original document root will be replaced in the apache configuration 
COPY . /var/www/html/ 

# Custom Document Root
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Concatenated RUN commands
RUN apk add --update \
    bash \
    apache2 \
    php7-apache2 \
    php7-mbstring \
    php7-session \
    php7-json \
    php7-pdo \
    php7-openssl \
    php7-tokenizer \
    php7-pdo \
    php7-pdo_mysql \
    php7-xml \
    php7-simplexml \
    php7-dom \
    && chmod -R 777 /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html \
    && mkdir -p /run/apache2 \
    && sed -i '/LoadModule rewrite_module/s/^#//g' /etc/apache2/httpd.conf \
    && sed -i '/LoadModule session_module/s/^#//g' /etc/apache2/httpd.conf \
    && sed -ri -e 's!/var/www/localhost/htdocs!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/httpd.conf \
    && sed -i 's/AllowOverride\ None/AllowOverride\ All/g' /etc/apache2/httpd.conf \
    && docker-php-ext-install pdo_mysql \
    && rm  -rf /tmp/* /var/cache/apk/*

# Register the COMPOSER_HOME environment variable
ENV COMPOSER_HOME /composer

# Add global binary directory to PATH and make sure to re-export it
ENV PATH /composer/vendor/bin:$PATH

# Allow Composer to be run as root
ENV COMPOSER_ALLOW_SUPERUSER 1

# Setup the Composer installer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
  && php /tmp/composer-setup.php --install-dir=/usr/bin --filename=composer


# Launch the httpd in foreground
CMD rm -rf /run/apache2/* || true && /usr/sbin/httpd -DFOREGROUND

# FROM php:7.2-apache

# RUN apt-get update

# # 1. development packages
# RUN apt-get install -y \
#     git \
#     zip \
#     curl \
#     sudo \
#     unzip \
#     libicu-dev \
#     libbz2-dev \
#     libpng-dev \
#     libjpeg-dev \
#     libmcrypt-dev \
#     libreadline-dev \
#     libfreetype6-dev \
#     g++

# # 2. apache configs + document root
# ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
# RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
# RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# # 3. mod_rewrite for URL rewrite and mod_headers for .htaccess extra headers like Access-Control-Allow-Origin-
# RUN a2enmod rewrite headers

# # 4. start with base php config, then add extensions
# RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

# RUN docker-php-ext-install \
#     bz2 \
#     intl \
#     iconv \
#     bcmath \
#     opcache \
#     calendar \
#     mbstring \
#     pdo_mysql \
#     zip

# # 5. composer
# COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# # 6. we need a user with the same UID/GID with host user
# # so when we execute CLI commands, all the host file's ownership remains intact
# # otherwise command from inside container will create root-owned files and directories
# ARG uid
# RUN useradd -G www-data,root -u $uid -d /home/devuser devuser
# RUN mkdir -p /home/devuser/.composer && \
#     chown -R devuser:devuser /home/devuser