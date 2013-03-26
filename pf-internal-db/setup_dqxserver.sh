Iteration=It30
FILE=${Iteration}.tar.gz
DOWNLOAD_FILE=${Iteration}.tar.gz
DIR=DQXServer-${Iteration}
. ./config.sh
curl -sL --user "${username}:${password}" https://github.com/malariagen/DQXServer/archive/${FILE} > ${DOWNLOAD_FILE}
tar xf ${DOWNLOAD_FILE}
cd ${DIR}
pip install -r REQUIREMENTS
rm DQXServer
MYDIR=${PWD}
(ln -s ${MYDIR} DQXServer)

sed -i.bak -e "s#\(BASEDIR\)\(\s=\s'\)\(\S*\)'#\1\2${BASEDIR}'#" -e "s#\(DBUSER\)\(\s=\s'\)\(\S*\)'#\1\2${APP_DB_USER}'#" -e "s#\(DBPASS\)\(\s=\s'\)\(\S*\)'#\1\2${APP_DB_PASS}'#" -e "s#\(DB\)\(\s=\s'\)\(\S*\)'#\1\2${APP_DB}'#" config.py

cat > app.wsgi <<+++EOH
import sys
import os
sys.path.append(os.path.dirname(__file__))

+++EOH
cat wsgi_server.py >> app.wsgi
