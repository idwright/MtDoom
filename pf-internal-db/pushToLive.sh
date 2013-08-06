#rsync -av /mnt/vcfdata/processed ec2-46-51-165-182.eu-west-1.compute.amazonaws.com:/mnt/storage/webapp

. ./config_db.sh

DB_ARCHIVE=pf21.sql.gz
mysqldump -u ${APP_DB_USER} -p${APP_DB_PASS} ${APP_DB} | gzip > ${DB_ARCHIVE}
scp ${DB_ARCHIVE} ec2-54-216-32-40.eu-west-1.compute.amazonaws.com:~
scp ${DB_ARCHIVE} 129.67.45.41:/mnt/storage/webapps/

FOLDER=`date +'%Y-%m-%dT%H%M%S'`
ARCHIVE=archive/${FOLDER}
mkdir -p ${ARCHIVE}
cp ${DB_ARCHIVE} ${ARCHIVE}
egrep ':([0-9]*)\.([0-9]*)$' alfresco_file_versions.txt > ${ARCHIVE}/alfresco_file_versions.txt
cp ganesha/data/alfresco.json ${ARCHIVE}
python uploadArchive.py ${FOLDER}
