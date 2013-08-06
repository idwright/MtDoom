HOST=129.67.45.213
rsync -av /mnt/vcfdata/processed ${HOST}:/mnt/storage/webapp
mysqldump -u pf21 -ppf21 pf21 | gzip > pf21.sql.gz
scp pf21.sql.gz ${HOST}:~
scp pf21.sql.gz 129.67.45.41:/mnt/storage/webapps/
