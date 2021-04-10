#!/bin/bash
echo "That script will install nginx, PostgreSQL, rsyslog-pgsql and other dependencies"
echo "Also it will configure nginx as reverse proxy, configure capturing logs to file system and sending them to PostgreSQL"

# Installing nginx and PostgreSQL
apt update
apt install sudo nginx -y
apt install postgresql postgresql-contrib -y
apt install systemctl -y
apt install ufw -y
echo "-------------- Installation of binaries are finished -------------- "

# Configuring firewall
sudo ufw allow "Nginx Full" 
echo "-------------- Firewall configured --------------"

# Removing default web-site
sudo unlink /etc/nginx/sites-enabled/default 

#cd /etc/nginx/sites-available/reverse-proxy.conf

domain=$1
forwardto=$2

cat >/etc/nginx/sites-available/reverse-proxy.conf <<EOL
log_format json_output '{"time_local": "\$time_local", '
   '"path": "\$request_uri", '
   '"ip": "\$remote_addr", '
   '"time": "\$time_iso8601", '
   '"user_agent": "\$http_user_agent", '
   '"user_id_got": "\$uid_got", '
   '"user_id_set": "\$uid_set", '
   '"remote_user": "\$remote_user", '
   '"request": "\$request", '
   '"request_body": "\$request_body", '
   '"status": "\$status", '
   '"body_bytes_sent": "\$body_bytes_sent", '
   '"request_time": "\$request_time", '
   '"http_referrer": "\$http_referer" }';

server {
        listen 80;
        listen [::]:80;
        server_name ${domain};
        location / {
                    if (\$request_method = POST) {
                       access_log /var/log/nginx/reverse-access.log json_output;
                    }

                    if (\$request_method = PUT) {
                       access_log /var/log/nginx/reverse-access.log json_output;
                    }

                    if (\$request_method = DELETE) {
                       access_log /var/log/nginx/reverse-access.log json_output;
                    }

                    proxy_pass ${forwardto};
            }
}
EOL

# Adding symbol link of created config to enabled sites folder
ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf

# Restarting nginx proccess
sudo systemctl restart nginx
echo "-------------- Reverse proxy configured --------------"

# Installing lets encrypt bot and configure SSL
#apt-get update
#apt-get install software-properties-common
#add-apt-repository ppa:certbot/certbot
#apt-get update
#apt-get install python3-certbot-nginx

#certbot --nginx

# Creating database, user and granting access

pg_ctlcluster 12 main start


sudo -u postgres psql -c 'CREATE DATABASE proxy_logs;' 
sudo -u postgres psql -c "CREATE ROLE user1 WITH LOGIN encrypted password 'password';" 
sudo -u postgres psql -d proxy_logs -c "CREATE TABLE accesslog (id serial NOT NULL PRIMARY KEY, log_line json NOT NULL, created_at TIMESTAMP NOT NULL);"
sudo -u postgres psql -d proxy_logs -c "GRANT ALL PRIVILEGES ON DATABASE proxy_logs TO user1;" 
sudo -u postgres psql -d proxy_logs -c "GRANT ALL PRIVILEGES ON ALL TABLES in SCHEMA public to user1;" 
sudo -u postgres psql -d proxy_logs -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES in SCHEMA public to user1;"


# Configuring rsyslog-pgsql
sudo apt-get update & sudo apt-get install rsyslog-pgsql -y
cp ./51-reverse-proxy.conf /etc/rsyslog.d/
sudo service rsyslog restart
echo "-------------- Configuring rsyslog finished -------------- "
echo "You can try to go to ${domain} in your browser and check that traffic will flow through reverse proxy"
echo "To see that data is saved locally you can execute that command to see logs: cat /var/log/nginx/reverse-access.log"
echo "Or you can connect to PostgreSQL proxy_logs database and execute that querry: select * from accesslog;"