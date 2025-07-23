FROM wordpress:latest
EXPOSE 80

# Install Xdebug via PECL
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Configure Xdebug for remote debugging
RUN echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.log=/tmp/xdebug.log" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Install WP-CLI
RUN apt-get update && apt-get install -y curl \
    && curl -L https://github.com/wp-cli/wp-cli/releases/download/v2.10.0/wp-cli-2.10.0.phar -o wp-cli.phar \
    && php wp-cli.phar --info \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp-cli \
    && rm -rf /var/lib/apt/lists/*

# Create WP-CLI wrapper that automatically adds --allow-root
RUN echo '#!/bin/bash\nphp /usr/local/bin/wp-cli "$@" --allow-root' > /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp
