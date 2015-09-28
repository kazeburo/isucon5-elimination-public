#! /bin/bash

host=${ISUCON5_DB_HOST:=localhost}
port=${ISUCON5_DB_PORT:=3306}

while true ; do
  /usr/bin/mysqladmin -u root ping && break
  echo "waiting mysql $host:$port"
  /bin/sleep 1
done

echo "mysql ready"

/bin/cat /var/lib/mysql/isucon5q/*.ibd > /dev/null 

echo 'select * from entries force index(primary) limit 5000' | /usr/bin/mysql -h $host -P $port -u root isucon5q > /dev/null &
echo 'select * from comments force index(primary)' | /usr/bin/mysql -h $host -P $port -u root isucon5q > /dev/null &
echo 'select * from footprints force index(primary)' | /usr/bin/mysql -h $host -P $port -u root isucon5q > /dev/null &
wait

exec /home/isucon/.local/perl/bin/carton exec -- start_server --path /tmp/app.sock  --backlog 16384 -- plackup -s Gazelle --workers=10 --max-reqs-per-child 500000 --min-reqs-per-child 400000 -E production -a app.psgi
