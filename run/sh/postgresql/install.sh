#!/usr/bin/env bash

_dirname=$(realpath $(cd "$(dirname "$0")"; pwd))

cd $_dirname

if [ ! -f /etc/init.d/postgresql ]; then
sudo apt-get install postgresql -y
sudo apt-get install postgresql-client -y
sudo /etc/init.d/postgresql start
sudo sed -i -e '2i \/etc/init.d/postgresql start\n' /etc/rc.local
fi

DB_USER=psql
DB_NAME=$DB_USER
sudo -u postgres createuser --superuser $DB_USER
sudo -u postgres createdb --owner=$DB_USER $DB_NAME
PASSWORD=`openssl rand -base64 128|tr -dc A-Za-z0-9|tail -c20`

DB_HOST=127.0.0.1

sudo apt-get install wget ca-certificates -y
chmod 777 /tmp
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
rm /etc/apt/sources.list.d/pgdg.list
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
sudo apt-get update
sudo apt install pgadmin4 -y

mkdir -p /home/pgadmin4/.pgadmin
sudo chown -R www:www /home/pgadmin4

cat > /usr/share/pgadmin4/web/config_local.py <<EOF
import os
DATA_DIR = os.path.realpath(u'/home/pgadmin4/.pgadmin/')
LOG_FILE = os.path.join(DATA_DIR, 'pgadmin4.log')
SQLITE_PATH = os.path.join(DATA_DIR, 'pgadmin4.db')
SESSION_DB_PATH = os.path.join(DATA_DIR, 'sessions')
STORAGE_DIR = os.path.join(DATA_DIR, 'storage')
SERVER_MODE = False
EOF


pip3 install gunicorn

sudo -u postgres psql -U postgres -d postgres -c "alter user $DB_USER with password '$PASSWORD';"

cd /etc/supervisor/conf.d
ln -s $_dirname/supervisor/*.conf .
sudo supervisorctl reload

echo -e "\n用户名 $DB_USER"
echo -e "数据库 $DB_NAME"
echo -e "密码 $PASSWORD\n"
echo -e "\n访问命令\npsql postgresql://$DB_USER:$PASSWORD@$DB_HOST/$DB_NAME\n"

