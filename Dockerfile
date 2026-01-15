# October CMS 1.1.12 Dockerfile
FROM php:7.4-apache

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
  apt-get update && apt-get install -y cron git-core nodejs jq unzip vim zip \
  libjpeg-dev libpng-dev libpq-dev libsqlite3-dev libwebp-dev libzip-dev && \
  rm -rf /var/lib/apt/lists/* && \
  docker-php-ext-configure zip --with-zip && \
  docker-php-ext-configure gd --with-jpeg --with-webp && \
  docker-php-ext-install exif gd mysqli opcache pdo_pgsql pdo_mysql zip

RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
  } > /usr/local/etc/php/conf.d/docker-oc-opcache.ini

RUN { \
    echo 'log_errors=on'; \
    echo 'display_errors=off'; \
    echo 'upload_max_filesize=32M'; \
    echo 'post_max_size=32M'; \
    echo 'memory_limit=128M'; \
  } > /usr/local/etc/php/conf.d/docker-oc-php.ini

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN a2enmod rewrite

# Configure Apache AllowOverride for .htaccess
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Clone October CMS 1.1.12
RUN git clone --depth 1 --branch v1.1.12 https://github.com/octobercms/october.git .

# Allow git to treat /var/www/html as a safe directory during build
RUN git config --global --add safe.directory /var/www/html

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer config --no-plugins allow-plugins.composer/installers true && \
  composer config --no-plugins allow-plugins.october/rain true && \
  composer config --global audit.block-insecure false

# Setup October CMS
RUN composer install --no-interaction --prefer-dist --no-scripts && \
  composer clearcache

COPY config/docker /usr/src/octobercms-config-docker

RUN  git status && git checkout modules/. && \
  rm -rf .git && \
  echo 'APP_ENV=docker' > .env && \
  mv /usr/src/octobercms-config-docker config/docker

# Set proper permissions
RUN mkdir -p /var/www/html/storage/logs && \
  chown -R www-data:www-data /var/www/html && \
  chmod -R 775 /var/www/html/storage /var/www/html/plugins /var/www/html/themes && \
  find . -type d \( -path './plugins' -or -path './storage' -or -path './themes' -or -path './plugins/*' -or -path './storage/*' -or -path './themes/*' \) -exec chmod g+ws {} \;


RUN echo "* * * * * /usr/local/bin/php /var/www/html/artisan schedule:run > /proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/october-cron && \
  crontab /etc/cron.d/october-cron

RUN echo 'exec php artisan "$@"' > /usr/local/bin/artisan && \
  echo 'exec php artisan tinker' > /usr/local/bin/tinker && \
  echo '[ $# -eq 0 ] && exec php artisan october || exec php artisan october:"$@"' > /usr/local/bin/october && \
  sed -i '1s;^;#!/bin/bash\n[ "$PWD" != "/var/www/html" ] \&\& echo " - Helper must be run from /var/www/html" \&\& exit 1\n;' /usr/local/bin/artisan /usr/local/bin/tinker /usr/local/bin/october && \
  chmod +x /usr/local/bin/artisan /usr/local/bin/tinker /usr/local/bin/october

COPY docker-oc-entrypoint /usr/local/bin/

EXPOSE 80

ENTRYPOINT ["docker-oc-entrypoint"]
CMD ["apache2-foreground"]
