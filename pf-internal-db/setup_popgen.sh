Iteration=It34
DQXIteration=It34
FILE=${Iteration}.tar.gz
DIR=PfPopGenWeb-${Iteration}
DATABASE=pfpopgen
. ~/config.sh
curl -sL --user "${username}:${password}" https://github.com/malariagen/PfPopGenWeb/archive/${FILE} > ${FILE}
tar xf ${FILE}
cd ${DIR}
pip install -r REQUIREMENTS

