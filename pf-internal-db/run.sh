#!/bin/bash -x
IMPORT_DIR=PfPopGenWeb/ExternalResources/ImportScripts/
RUN_DIR=${PWD}
export RUN_DIR
. ./config.sh
cp config.sh alfresco.cfg ganesha/data
#Required for shovel
sed -i.bak -e "s#\(BASEDIR\)\(\s=\s'\)\(\S*\)'#\1\2${BASEDIR}'#" -e "s#\(DBUSER\)\(\s=\s'\)\(\S*\)'#\1\2${APP_DB_USER}'#" -e "s#\(DBPASS\)\(\s=\s'\)\(\S*\)'#\1\2${APP_DB_PASS}'#" -e "s#\(DB\)\(\s=\s'\)\(\S*\)'#\1\2${APP_DB}'#"  -e "s#\(DBSRV\)\(\s=\s'\)\(\S*\)'#\1\2${APP_DB_HOST}'#" PfPopGenWeb/config.py
sed -i.bak -e "s#\('USER':\)\(\s*'\)\(\S*\)'#\1\2${DBUSER}'#" -e "s#\('PASSWORD':\)\(\s*'\)\(\S*\)'#\1\2${DBPASS}'#" -e "s#\('NAME':\)\(\s*'\)\(\S*\)'#\1\2${DB}'#" ganesha/ganesha-app/settings/common.py
#SERVER_PID=`sh start_server.sh`
#Do this now so you're paying attention
(cd PfPopGenWeb
export PYTHONPATH=$PWD
shovel db.delete
)
(cd ganesha/ganesha-app
python manage.py syncdb --settings=settings.development
)
(cd PfPopGenWeb
export PYTHONPATH=$PWD
)
echo "Start the server start_server.sh"
read
(cd ganesha/data
export PYTHONPATH=$PWD:../ganesha-app/apps/
sh run.sh > ${RUN_DIR}/alfresco_file_versions.txt
python load_samples.py
mysql -u ${DBUSER} -p${DBPASS} ${DB} < sql/merge_sample_contexts.sql
)
#Nasty hack as doesn't work the same way in and out
(cd ganesha/ganesha-app/apps/ganesha
sed -i.bak 's/#contact_person = F/contact_person = F/' api.py
)
#Allow time for reloading
sleep 5
(cd PfPopGenWeb
export PYTHONPATH=$PWD
shovel db.create
shovel db.import_from_api http://127.0.0.1:8000/api/v1/
cd ExternalResources/ImportScripts
mysql -u ${APP_DB_USER} -p${APP_DB_PASS} ${APP_DB} < loadPopulationData.sql
)
#Put back the original
(cd ganesha/ganesha-app/apps/ganesha
mv api.py.bak api.py
)
#Replaced with command line args below
#sed -i.bak -e "s#\(ifilename='\)\(\S*\)'#\1../../../ganesha/data/Data/Genome\ annotation\ data/TandemRepeats.dat'#" -e "s#\(ofilename='\)\(\S*\)'#\1tandem.txt'#" ${IMPORT_DIR}/ConvertTandemRepeats.py
sed -i.bak -e "s#\(sourcefilename='\)\(\S*\)'#\1../../../ganesha/data/Data/Genome\ annotation\ data/genes.dat'#" -e "s#\(outputfilename='\)\(\S*\)'#\1annot.txt'#" ${IMPORT_DIR}/TranslateAnnotation.py
rm -rf ${BASEDIR}/GenomeTracks/*
cp -pr ganesha/data/Data/Genome\ annotation\ data/Genome\ accessibility/* ${BASEDIR}/GenomeTracks
(cd ${IMPORT_DIR}
python ConvertTandemRepeats.py ../../../ganesha/data/Data/Genome\ annotation\ data/TandemRepeats.dat tandem.txt
mysql --local-infile=1 -u ${APP_DB_USER} -p${APP_DB_PASS} ${APP_DB} < ImportTandemRepeats.sql

python TranslateAnnotation.py
mysql --local-infile=1 -u ${APP_DB_USER} -p${APP_DB_PASS} ${APP_DB} < pfannotrel.sql

)
#kill ${SERVER_PID}
echo "Stop the server"
read
#This takes about 1 hr per track
(cd DQXServer
sed -i.bak -e 's/^srcFile=/#srcFile=/'  -e 's/^sys.argv=/#sys.argv=/'  -e 's/^sourcedir=/#sourcedir=/' _CreateDataVCF.py
for i in ../../data/GenomeTracks/*
do
	if [ -f $i/`basename $i`.zip ]
	then
		(cd $i;unzip -o `basename $i`.zip)
		(cd $i;fromdos *.txt)
		python _CreateFilterBankData.py $i Summ01
	fi
done
cp -pr ../../data/GenomeTracks /mnt/vcfdata/processed
)
#This takes about 20 hrs
if [ 0 = 1 ]
then
cp PfPopGenWeb/meta/PfPopGen2.1.cnf /mnt/vcfdata/working
(cd /mnt/vcfdata/working
gunzip -c ../2.1/data.vcf.gz > PfPopGen2.1.vcf
ulimit -Sn 4096
python /mnt/storage/scripts/DQXServer/_CreateDataVCF.py PfPopGen2.1
)
fi
