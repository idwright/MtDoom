Iteration=It34
DQXIteration=It34
FILE=${Iteration}.tar.gz
DIR=PfPopGenWeb-${Iteration}
DATABASE=pfpopgen
. ./config.sh
curl -sL --user "${username}:${password}" https://github.com/malariagen/PfPopGenWeb/archive/${FILE} > ${FILE}
tar xf ${FILE}
cd ${DIR}
pip install -r REQUIREMENTS
cd ..
test -d ${Iteration} && rm -rf ${Iteration}
mkdir ${Iteration}
cp -pr ${DIR}/Bitmaps ${Iteration}
cp -pr ${DIR}/scripts ${Iteration}
cp -pr ${DIR}/Doc ${Iteration}
mv ${Iteration}/scripts/Local.example ${Iteration}/scripts/Local
sed -e 's/\(googleAnalyticsId="\)\(\S*\)/\1${analytics_id}";/' -e 's/\(localhost=\)\(\w*\)/\1false/' ${Iteration}/scripts/Local/_SetAnalyticsId.js
sed -i -e 's#/sandbox/keposeda/app#/DQXServer/app#' ${Iteration}/scripts/Local/_SetServerUrl.js
sed -i -e "s/\(theMetaData1\.database = '\)[a-z0-9]*/\1${DATABASE}/" ${Iteration}/scripts/MetaData1.js
cp ${DIR}/PfPopGen.* ${Iteration}
cp ${DIR}/PfPopgen.* ${Iteration}
(cd ${Iteration}
ln -s PfPopGen.htm index.html
)
rm /var/www/PfPopGen
MYDIR=${PWD}
(cd /var/www; ln -s ${MYDIR}/${Iteration} PfPopGen)

FILE=${DQXIteration}.tar.gz
DOWNLOAD=DQX-${FILE}
curl -sL --user "${username}:${password}" https://github.com/malariagen/DQX/archive/${FILE} > ${DOWNLOAD}
tar xf ${DOWNLOAD}
mv DQX-${Iteration} ${Iteration}/scripts/DQX
