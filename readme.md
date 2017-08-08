# vimrc
```
curl https://raw.githubusercontent.com/yqsy/linux_script/master/.vimrc | tee ~/.vimrc
```

# iptables v4/v6 

在centos7上,需要firewalld与开启iptables
```
sudo systemctl stop firewalld.service && sudo systemctl disable firewalld.service
sudo systemctl enable iptables && sudo systemctl enable ip6tables
sudo systemctl start iptables && sudo systemctl start ip6tables
```

清空所有规则
```
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -t raw -F
iptables -t raw -X
```

写入默认的规则
```
rm -f /tmp/{v4,v6}
wget https://raw.githubusercontent.com/yqsy/linux_script/master/v4 -O /tmp/v4
wget https://raw.githubusercontent.com/yqsy/linux_script/master/v6 -O /tmp/v6
iptables-restore < /tmp/v4
ip6tables-restore < /tmp/v6
```