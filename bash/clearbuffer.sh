sudo service postgresql stop
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
sudo service postgresql start
sudo -u postgres psql -d dojo
