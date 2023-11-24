#
# PHP Dependencies
#
FROM composer:2 as vendor

# Needed dependencies from composer.json
COPY composer.json composer.lock ./

# Install with --no-dev for production
RUN composer install \
#    --no-dev \
    --ignore-platform-reqs \
    --no-interaction \
    --no-progress \
    --no-ansi \
    --no-plugins \
    --no-scripts \
    --prefer-dist

#
# Frontend
#
FROM node:18 as frontend

COPY --chown=www-data:www-data . /app
# Add composer dependencies
COPY --chown=www-data:www-data --from=vendor /app/vendor/ /app/vendor/

WORKDIR /app

RUN node --version
RUN npm --version
# RUN npm install -g npm && npm --version
RUN npm install --verbose
RUN npm run build

#
# Application
#
FROM php:8.2-apache

MAINTAINER Patrick Brisacier <pbrisacier@mncc.fr>

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions \
        intl \
        pdo_mysql \
        pdo_pgsql

# PHP configuration
# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Copy application files
# See .dockerignore to know which files and directories are excluded
COPY --chown=www-data:www-data . /var/www/html
# Add composer dependencies
COPY --chown=www-data:www-data --from=vendor /app/vendor/ /var/www/html/vendor/
# Add npm dependencies
COPY --chown=www-data:www-data --from=frontend /app/public/build/ /var/www/html/public/build/

# Rights on directories and files
# RUN chown -R www-data:www-data /var/www/html \
#     && find /var/www/html -type f -exec chmod 644 {} \; \
#     && find /var/www/html -type d -exec chmod 755 {} \; \
#     && chmod -R ug+rwx /var/www/html/storage /var/www/html/bootstrap/cache

RUN chmod -R ug+rwx /var/www/html/storage /var/www/html/bootstrap/cache

COPY <<-EOT /etc/apache2/sites-available/laravel.conf
<VirtualHost *:80>
  DocumentRoot /var/www/html/public
  <Directory /var/www/html/public>
    AllowOverride All
  </Directory>
</VirtualHost>
EOT

RUN a2dissite 000-default.conf \
    && a2enmod rewrite \
    && a2ensite laravel.conf


# # Optimizing Configuration loading
# RUN php artisan config:cache
# # Optimizing Route loading
# RUN php artisan route:cache
# # Optimizing View loading
# RUN php artisan view:cache



# Start script
COPY <<-"EOT" /usr/local/bin/start
#!/usr/bin/env bash
# See: https://laravel-news.com/laravel-scheduler-queue-docker
set -e
role=${CONTAINER_ROLE:-app}
queue_name=${QUEUE_NAME:-default}
if [[ "$role" = "app" ]]; then
    echo "Start apache..."
    exec apache2-foreground
elif [[ "$role" = "queue" ]]; then
    while [[ true ]]
    do
      echo "Running the queue..."
      (cd /var/www/html && php artisan queue:work --queue=$queue_name --stop-when-empty --verbose --tries=3 --timeout=90)
      echo "Queue empty... wait some seconds..."
      sleep 13
    done
elif [[ "$role" = "scheduler" ]]; then
    echo "Migrate database if needed..."
    (cd /var/www/html && php artisan migrate --step --force)
    if [[ -f /var/www/html/database/seeders/DatabaseSeeder.php ]]; then
        echo "Apply DatabaseSeeder..."
        (cd /var/www/html && php artisan db:seed)
    fi
    echo "Launch schedule:run every minute..."
    while [[ true ]]
    do
      (cd /var/www/html && php artisan schedule:run --verbose --no-interaction)
      sleep 60
    done
else
    echo "Could not match the container role \"$role\""
    exit 1
fi
EOT
RUN chmod u+x /usr/local/bin/start


WORKDIR /var/www/html

# Launch our start script
CMD ["/usr/local/bin/start"]
