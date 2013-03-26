(cd ganesha/ganesha-app
python manage.py runserver --settings=settings.development &
PPPID=$!
sleep 10
SERVER_PID=`ps -deaf | grep python | awk -v ppid=${PPPID} '{if ($3 == ppid) { print $2} }'`
echo ${SERVER_PID}
)
