firewall-cmd --zone=public --add-port=9001/tcp --permanent
firewall-cmd --zone=public --add-port=9002/tcp --permanent
firewall-cmd --reload
