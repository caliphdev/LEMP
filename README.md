# LEMP Stack Installation Script

This script automates the installation of the LEMP (Linux, Nginx, MySQL, PHP) stack on a Debian-based system. It also includes configuration for Nginx to use PHP and creates a basic info.php file for testing.

## Usage

Run the following command in your terminal to download and execute the script:

```bash
wget https://raw.githubusercontent.com/caliphdev/LEMP/main/ilemp.sh
chmod +x lemp.sh
./lemp.sh your_domain
```

Replace `your_domain` with your actual domain.

## Configuration

The script creates an Nginx server block configuration for the specified domain. The web root directory is set to `/var/www/your_domain`. The script also creates a symbolic link to enable the site.

## Files Created

- `/etc/nginx/sites-available/your_domain`: Nginx server block configuration.
- `/var/www/your_domain`: Web root directory.
- `/var/www/your_domain/info.php`: PHP info file for testing.

## Contributing

If you'd like to contribute to this project, please follow the guidelines outlined in the [Contributing](CONTRIBUTING.md) file.

## License

This project is licensed under the [MIT License](LICENSE).
