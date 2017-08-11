# vimrc
```
curl https://raw.githubusercontent.com/yqsy/linux_script/master/.vimrc | tee ~/.vimrc
```

# iptables v4/v6 

在centos7上,需要firewalld与开启iptables
```
sudo systemctl stop firewalld.service && sudo systemctl disable firewalld.service
yum install -y iptables-services
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

# 树莓派kcptun-service搭建

```
cd ~
wget https://github.com/xtaci/kcptun/releases/download/v20170525/kcptun-linux-arm-20170525.tar.gz
mkdir kcptun-linux-arm-20170525
tar -zxvf kcptun-linux-arm-20170525.tar.gz -C ./kcptun-linux-arm-20170525
sudo cp ./kcptun-linux-arm-20170525/client_linux_arm5 /usr/local/bin/
sudo wget https://raw.githubusercontent.com/yqsy/linux_script/master/kcptun-service-config.json -O /usr/local/etc/kcptun-service-config.json
sudo wget https://raw.githubusercontent.com/yqsy/linux_script/master/kcptun-service -O /etc/init.d/kcptun-service
chmod +x /etc/init.d/kcptun-service
```

```
sudo /etc/init.d/kcptun-service start
sudo /etc/init.d/kcptun-service stop
sudo /etc/init.d/kcptun-service restart
chkconfig kcptun-service on

systemctl status kcptun-service.service
```

# vps kcptun-server搭建
```
wget https://github.com/xtaci/kcptun/releases/download/v20170525/kcptun-linux-amd64-20170525.tar.gz
mkdir kcptun-linux-amd64-20170525
tar -zxvf kcptun-linux-amd64-20170525.tar.gz -C kcptun-linux-amd64-20170525
cp ./kcptun-linux-amd64-20170525/server_linux_amd64 /usr/local/bin/
wget https://raw.githubusercontent.com/yqsy/linux_script/master/kcptun-server-config.json  -O /usr/local/etc/kcptun-server-config.json
wget https://raw.githubusercontent.com/yqsy/linux_script/master/kcptun-server -O /etc/init.d/kcptun-server
chmod +x /etc/init.d/kcptun-server

```

```
/etc/init.d/kcptun-server start
/etc/init.d/kcptun-server stop
/etc/init.d/kcptun-server restart

chkconfig --add kcptun-server
chkconfig kcptun-server on

systemctl status kcptun-server.service
```

# vps shadowsocks-libev搭建

```
yum install gcc gettext autoconf libtool automake make pcre-devel asciidoc xmlto udns-devel libev-devel libsodium-devel mbedtls-devel -y
wget https://github.com/shadowsocks/shadowsocks-libev/releases/download/v3.0.8/shadowsocks-libev-3.0.8.tar.gz
tar -zxvf shadowsocks-libev-3.0.8.tar.gz
cd shadowsocks-libev-3.0.8
./configure --prefix=/usr && make
make install
mkdir -p /etc/shadowsocks-libev
cp ./rpm/SOURCES/etc/init.d/shadowsocks-libev /etc/init.d/shadowsocks-libev
cp ./debian/config.json /etc/shadowsocks-libev/config.json
chmod +x /etc/init.d/shadowsocks-libev
vim /etc/shadowsocks-libev/config.json
```

```
chkconfig --add shadowsocks-libev
chkconfig shadowsocks-libev on
/etc/init.d/shadowsocks-libev start

systemctl status shadowsocks-libev.service
```

