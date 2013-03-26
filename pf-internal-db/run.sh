IMPORT_DIR=PfPopGenWeb/ExternalResources/ImportScripts/
. ./config.sh
cp config.sh alfresco.cfg ganesha/data
#Required for shovel
sed -i.bak -e "s#\(BASEDIR\)\(\s=\s'\)\(\S*\)'#\1\2${BASEDIR}'#" -e "s#\(DBUSER\)\(\s=\s'\)\(\S*\)'#\1\2${APP_DB_USER}'#" -e "s#\(DBPASS\)\(\s=\s'\)\(\S*\)'#\1\2${APP_DB_PASS}'#" -e "s#\(DB\)\(\s=\s'\)\(\S*\)'#\1\2${APP_DB}'#"  -e "s#\(DBSRV\)\(\s=\s'\)\(\S*\)'#\1\2${APP_DB_HOST}'#" PfPopGenWeb/config.py
sed -i.bak -e "s#\('USER':\)\(\s*'\)\(\S*\)'#\1\2${DBUSER}'#" -e "s#\('PASSWORD':\)\(\s*'\)\(\S*\)'#\1\2${DBPASS}'#" -e "s#\('NAME':\)\(\s*'\)\(\S*\)'#\1\2${DB}'#" ganesha/ganesha-app/settings/common.py
SERVER_PID=`sh start_server.sh`
(cd ganesha/data
export PYTHONPATH=$PWD:../ganesha-app/apps/
sh run.sh
)
(cd PfPopGenWeb
export PYTHONPATH=$PWD
shovel create.db
shovel db.import_from_api http://127.0.0.1:8000/api/v1/
cd ExternalResources/sql
mysql -u ${APP_DB_USER} -p${APP_DB_PASS} ${APP_DB} < loadPopulationData.sql
)
kill ${SERVER_PID}
#Replaced with command line args below
#sed -i.bak -e "s#\(ifilename='\)\(\S*\)'#\1../../../ganesha/data/Data/Genome\ annotation\ data/TandemRepeats.dat'#" -e "s#\(ofilename='\)\(\S*\)'#\1tandem.txt'#" ${IMPORT_DIR}/ConvertTandemRepeats.py
sed -i.bak -e "s#\(sourcefilename='\)\(\S*\)'#\1../../../ganesha/data/Data/Genome\ annotation\ data/genes.dat'#" -e "s#\(outputfilename='\)\(\S*\)'#\1annot.txt'#" ${IMPORT_DIR}/TranslateAnnotation.py
rm -rf ${BASEDIR}/GenomeTracks/*
cp -pr ganesha/data/Data/Genome\ annotation\ data/Genome\ accessibility/* ${BASEDIR}/GenomeTracks
(cd ${IMPORT_DIR}
python ConvertTandemRepeats.py ../../../ganesha/data/Data/Genome\ annotation\ data/TandemRepeats.dat tandem.txt
mysql --local-infile=1 -u ${APP_DB_USER} -p${APP_DB_PASS} ${APP_DB} < ImportTandemRepeats.sql

python TranslateAnnotation.py)
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
)
#This takes about 20 hrs
if [ 0 -eq 1 ]
then
cp PfPopGen2.1.cnf /mnt/vcfdata/working
(cd /mnt/vcfdata/working
gunzip -c ../2.1/data.vcf.gz > PfPopGen2.1.vcf
ulimit -Sn 4096
python /mnt/storage/scripts/DQXServer/_CreateDataVCF.py PfPopGen2.1
)
fi
