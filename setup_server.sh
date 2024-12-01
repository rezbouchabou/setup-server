#!/bin/bash

# Setup Server: Nginx, MariaDB, PHP, phpMyAdmin, Redis, Memcached and Composer on Debian/Ubuntu

# Update package lists and upgrade system
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Nginx
echo "Installing Nginx..."
sudo apt install -y nginx

# Install PHP and extensions
echo "Installing PHP and necessary extensions..."
sudo apt install -y php php-cli php-fpm php-common php-json php-mbstring php-zip php-xml php-tokenizer php-curl php-gd php-bcmath php-exif php-intl php-soap php-xdebug php-opcache php-pdo php-mysql php-ctype php-fileinfo php-filter php-hash php-openssl php-pcre php-session php-dom php-imagick

# Install MariaDB
echo "Installing MariaDB..."
sudo apt install -y mariadb-server mariadb-client

# Secure MariaDB installation
echo "Securing MariaDB installation..."
sudo mysql_secure_installation

# Install Composer
echo "Installing Composer..."
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

# Install Redis
echo "Installing Redis..."
sudo apt install -y redis-server
sudo systemctl enable redis
sudo systemctl start redis

# Install Memcached
echo "Installing Memcached..."
sudo apt install -y memcached php-memcached

# Install phpMyAdmin
echo "Installing phpMyAdmin..."
sudo apt install -y phpmyadmin

# Link phpMyAdmin to Nginx
echo "Configuring phpMyAdmin with Nginx..."
sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Adjust PHP settings for phpMyAdmin
echo "Configuring PHP for phpMyAdmin..."
sudo sed -i 's/^;max_input_vars =.*/max_input_vars = 3000/' /etc/php/*/fpm/php.ini

# Detect installed PHP version
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")

# Restart PHP-FPM with the detected version
echo "Restarting PHP-FPM for PHP $PHP_VERSION..."
sudo systemctl restart php$PHP_VERSION-fpm

# Restart Nginx to apply changes
echo "Restarting Nginx to apply changes..."
sudo systemctl restart nginx

# Enable and start services
echo "Starting and enabling services..."
sudo systemctl enable nginx
sudo systemctl start nginx
sudo systemctl enable php-fpm
sudo systemctl start php-fpm
sudo systemctl enable mariadb
sudo systemctl start mariadb
sudo systemctl restart memcached

# Verify installation
echo "Installation complete! Verifying versions..."
nginx -v
php -v
mysql --version
composer --version
redis-server --version
memcached -h | head -1
phpmyadmin_version=$(dpkg -s phpmyadmin | grep Version)
echo "phpMyAdmin version: $phpmyadmin_version"

echo "All components installed successfully!"
