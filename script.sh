#!/bin/bash
# proof-of-concept to install LAMP & WordPress

# update repositories
sudo apt-get -y update

# install apache
sudo apt-get -y install apache2

# install mysql and configure root password
sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password def222ini'
sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password def222ini'
sudo apt-get -y install mysql-server php-mysql
sudo apt-get -y install php libapache2-mod-php php-mcrypt

# remove default webpage
#sudo mv /var/www/html/index.html /var/www/html/index.html~
sudo echo "Welcome" > /var/www/html/index.html

# configure iptables to allow access to ssh and http
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -P INPUT DROP

# install iptables-persistent to preserve iptables config after reboot
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt-get -y install iptables-persistent

# install wordpress
# first lets install wp-cli
cd /tmp && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo chmod +x /tmp/wp-cli.phar
sudo mv /tmp/wp-cli.phar /usr/local/bin/wp

# lets install wp-core
# we would normally use vhosts, but not needed for this proof-of-concept
# everything is done using root privileges in this scenario, which we normally wouldn't
sudo mkdir /var/www/html/wp && cd /var/www/html/wp && sudo wp core download --allow-root

# create mysql db for wp
mysql -uroot -pdef222ini -s -N -e "CREATE DATABASE wordpress;"
mysql -uroot -pdef222ini -s -N -e "CREATE USER wp1@localhost IDENTIFIED BY 'pwXXX111';"
mysql -uroot -pdef222ini -s -N -e "GRANT ALL PRIVILEGES ON wordpress.* TO wp1@localhost;"

# lets get wp up and running
cd /var/www/html/wp && wp core config --dbname=wordpress --dbuser=wp1 --dbpass=pwXXX111 --allow-root
wp core install --url=http://127.0.0.1/wp/ --title=WordPress --admin_user=wpuser1 --admin_password=wanovNik --admin_email=wp-admin@definiens.com --allow-root










 
