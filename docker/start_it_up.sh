export MY_ADDR=`getent hosts $HOSTNAME | awk '{print $1}'`
bin/fake_sqs --database /var/data/fake_sqs/database.yml --bind $MY_ADDR --port 4568
