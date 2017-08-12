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

## iptables 
```
iptables -A INPUT -p udp --dport 35001 -j ACCEPT
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

## iptables
```
iptables -A INPUT -p tcp --dport 35000 -m state --state NEW -j ACCEPT
iptables -A INPUT -p udp --dport 35000 -j ACCEPT
```

# openwrt shadowsocks and chinadns
```
opkg update
mkdir -p /tmp/my
wget http://openwrt-dist.sourceforge.net/archives/shadowsocks-libev/3.0.8/OpenWrt/ar71xx/libmbedtls_2.5.1-2_ar71xx.ipk  -O /tmp/my/libmbedtls_2.5.1-2_ar71xx.ipk
wget http://openwrt-dist.sourceforge.net/archives/shadowsocks-libev/3.0.8/OpenWrt/ar71xx/libsodium_1.0.12-1_ar71xx.ipk -O /tmp/my/libsodium_1.0.12-1_ar71xx.ipk
wget http://openwrt-dist.sourceforge.net/archives/shadowsocks-libev/3.0.8/OpenWrt/ar71xx/libudns_0.4-1_ar71xx.ipk -O /tmp/my/libudns_0.4-1_ar71xx.ipk
wget http://openwrt-dist.sourceforge.net/archives/shadowsocks-libev/3.0.8/OpenWrt/ar71xx/shadowsocks-libev_3.0.8-1_ar71xx.ipk -O /tmp/my/shadowsocks-libev_3.0.8-1_ar71xx.ipk

opkg install /tmp/my/libmbedtls_2.5.1-2_ar71xx.ipk
opkg install /tmp/my/libsodium_1.0.12-1_ar71xx.ipk
opkg install /tmp/my/libudns_0.4-1_ar71xx.ipk
opkg install /tmp/my/shadowsocks-libev_3.0.8-1_ar71xx.ipk

opkg install openssl-util
wget https://github.com/shadowsocks/luci-app-shadowsocks/releases/download/v1.8.1/luci-app-shadowsocks_1.8.1-1_all.ipk -O /tmp/my/luci-app-shadowsocks_1.8.1-1_all.ipk
opkg install /tmp/my/luci-app-shadowsocks_1.8.1-1_all.ipk

wget https://github.com/aa65535/openwrt-chinadns/releases/download/v1.3.2-4/ChinaDNS_1.3.2-4_ar71xx.ipk -O /tmp/my/ChinaDNS_1.3.2-4_ar71xx.ipk
wget https://github.com/aa65535/openwrt-dist-luci/releases/download/v1.6.1/luci-app-chinadns_1.6.1-1_all.ipk -O /tmp/my/luci-app-chinadns_1.6.1-1_all.ipk

opkg install /tmp/my/ChinaDNS_1.3.2-4_ar71xx.ipk
opkg install /tmp/my/luci-app-chinadns_1.6.1-1_all.ipk

mkdir /etc/shadowsocks
wget -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > /etc/shadowsocks/ignore.list
wget -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > /etc/chinadns_chnroute.txt


wget https://dl.bintray.com/aa65535/openwrt/dns-forwarder/1.2.1/OpenWrt/ar71xx/dns-forwarder_1.2.1-1_ar71xx.ipk -O  /tmp/my/dns-forwarder_1.2.1-1_ar71xx.ipk
wget https://github.com/aa65535/openwrt-dist-luci/releases/download/v1.6.1/luci-app-dns-forwarder_1.6.1-1_all.ipk -O  /tmp/my/luci-app-dns-forwarder_1.6.1-1_all.ipk

opkg install /tmp/my/dns-forwarder_1.2.1-1_ar71xx.ipk
opkg install /tmp/my/luci-app-dns-forwarder_1.6.1-1_all.ipk

# 在页面上配置把
```
