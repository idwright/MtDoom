Iteration=It30
FILE=${Iteration}.tar.gz
DOWNLOAD_FILE=${Iteration}.tar.gz
DIR=DQXServer-${Iteration}
. ./config.sh
curl -sL --user "${username}:${password}" https://github.com/malariagen/DQXServer/archive/${FILE} > ${DOWNLOAD_FILE}
tar xf ${DOWNLOAD_FILE}
cd ${DIR}
pip install -r REQUIREMENTS
rm /var/www/DQXServer
MYDIR=${PWD}
(cd /var/www; ln -s ${MYDIR} DQXServer)
#config.py is not used see /etc/apache2/sites-enables/000-default
sed -i -e 's#C:/Data/Test/Genome#/srv/Data/Genome#' config.py

cat > app.wsgi <<+++EOH
import sys
import os
sys.path.append(os.path.dirname(__file__))

+++EOH
cat wsgi_server.py >> app.wsgi
