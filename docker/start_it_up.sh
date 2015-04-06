export MY_ADDR=`/sbin/ip route|awk '/default/ { print $3 }'`
bin/fake_sqs --database /var/data/fake_sqs/database.yml --bind $MY_ADDR --port 4568
