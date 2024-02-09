#!/bin/bash
# WARN!
# Ubuntu & Debian OS Only!

# Check if the script is run by the root user
if [ "$(id -u)" -eq 0 ]; then
    echo "The script is run by the root user."
    # Place the commands that require administrative privileges here
else
    echo "This script requires administrative privileges. Please run the script with sudo."
fi

# Check if a domain is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <your_domain>"
    exit 1
fi

# Check if the sudo command is available
if ! command -v sudo &> /dev/null; then
    echo "The sudo command is not available. Installing sudo..."
    # Install sudo (may require administrative privileges)
    su -c "apt-get update && apt-get install -y sudo" 
fi

domain=$1
webroot="/var/www/$domain"

# Create web root directory
echo "Creating web root directory: $webroot"
sudo mkdir -p $webroot
sudo chown www-data:www-data $webroot

# Update package list

echo "Updating package list..."
sudo apt update > /dev/null 2>&1

# Install software-properties-common to add repositories
echo "Installing software-properties-common..."
sudo apt install -y software-properties-common > /dev/null 2>&1

# Add PHP repository
echo "Adding PHP repository..."
sudo add-apt-repository -y ppa:ondrej/php > /dev/null 2>&1

# Update package list again
echo "Updating package list after adding repository..."
sudo apt update > /dev/null 2>&1

# Install Nginx
echo "Installing Nginx..."
sudo apt install -y nginx > /dev/null 2>&1

# Install MySQL Server
echo "Installing MySQL Server..."
sudo apt install -y mariadb-server > /dev/null 2>&1
sudo mysql_secure_installation 

# Install PHP 8.1 and required extensions
echo "Installing PHP 8.1 and required extensions..."
sudo apt install -y php8.1-fpm php8.1-mysql > /dev/null 2>&1

# Configure Nginx to use PHP
echo "Configuring Nginx to use PHP..."
sudo nano /etc/nginx/sites-available/$domain > /dev/null 2>&1

# Create Nginx server block configuration
sudo tee /etc/nginx/sites-available/$domain > /dev/null <<EOL
server {
    listen 80;
    server_name $domain;
    root $webroot;

    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    error_log  /var/log/nginx/$domain_error.log;
    access_log /var/log/nginx/$domain_access.log;
}
EOL

# Create a symbolic link to enable the site
sudo ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/

# Test Nginx configuration
echo "Testing Nginx configuration..."
sudo nginx -t > /dev/null 2>&1

# Reload Nginx to apply changes
echo "Reloading Nginx..."
sudo systemctl reload nginx > /dev/null 2>&1

# Restart PHP-FPM
echo "Restarting PHP-FPM..."
sudo systemctl restart php8.1-fpm > /dev/null 2>&1

# Create info.php
echo "Creating info.php..."
echo "<?php phpinfo(); ?>" | sudo tee $webroot/info.php > /dev/null 2>&1

# Set proper permissions for the info.php file
sudo chown www-data:www-data $webroot/info.php > /dev/null 2>&1

# Restart Nginx to apply new configuration
echo "Restarting Nginx..."
sudo systemctl restart nginx > /dev/null 2>&1

clear 
echo "LEMP stack has been installed and configured for $domain"
