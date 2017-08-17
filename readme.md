<!-- TOC -->

- [.vimrc](#vimrc)
- [iptables v4/v6](#iptables-v4v6)
- [vps kcptun-server](#vps-kcptun-server)
    - [iptables](#iptables)
- [vps shadowsocks-libev](#vps-shadowsocks-libev)
    - [iptables](#iptables-1)
- [openwrt shadowsocks and chinadns and dns forwarder](#openwrt-shadowsocks-and-chinadns-and-dns-forwarder)
- [树莓派kcptun-service](#树莓派kcptun-service)
- [树莓派shadowsocks-libev-redir](#树莓派shadowsocks-libev-redir)
    - [增加NAT Chain](#增加nat-chain)
    - [过滤目的ss服务器地址](#过滤目的ss服务器地址)
    - [过滤保留,私有,回环地址](#过滤保留私有回环地址)
    - [过滤大陆地址](#过滤大陆地址)
        - [查看ipset](#查看ipset)
    - [重定向至ss-redir](#重定向至ss-redir)
    - [保存iptables](#保存iptables)
- [树莓派shadowsocks-libev-tunnel](#树莓派shadowsocks-libev-tunnel)
- [树莓派chinadns](#树莓派chinadns)
- [树莓派开启ip包转发](#树莓派开启ip包转发)
- [树莓派dnsmasq,dns转发](#树莓派dnsmasqdns转发)
    - [查看使用的dns服务器](#查看使用的dns服务器)

<!-- /TOC -->
# .vimrc
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

一定要注意保存
```
service iptables save
service ip6tables save
```

```
/etc/sysconfig/iptables
/etc/sysconfig/ip6tables
```

# vps kcptun-server
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

systemctl status kcptun-server.service -l
```

## iptables 
```
iptables -A INPUT -p udp --dport 35001 -j ACCEPT
```


# vps shadowsocks-libev

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

systemctl status shadowsocks-libev.service -l
```

## iptables
```
iptables -A INPUT -p tcp --dport 35000 -m state --state NEW -j ACCEPT
iptables -A INPUT -p udp --dport 35000 -j ACCEPT
```

# openwrt shadowsocks and chinadns and dns forwarder
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

# 树莓派kcptun-service

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

systemctl status kcptun-service.service -l
```

# 树莓派shadowsocks-libev-redir
```
sudo apt-get update
sudo apt-get install libpcre3-dev -y
sudo apt-get install libudns-dev -y
sudo apt-get install libev-dev -y
sudo apt-get install iptables-persistent -y


export LIBSODIUM_VER=1.0.13
wget https://download.libsodium.org/libsodium/releases/libsodium-$LIBSODIUM_VER.tar.gz
tar xvf libsodium-$LIBSODIUM_VER.tar.gz
pushd libsodium-$LIBSODIUM_VER
./configure --prefix=/usr && make
sudo make install
popd
sudo ldconfig


export MBEDTLS_VER=2.5.1
wget https://tls.mbed.org/download/mbedtls-$MBEDTLS_VER-gpl.tgz
tar xvf mbedtls-$MBEDTLS_VER-gpl.tgz
pushd mbedtls-$MBEDTLS_VER
make SHARED=1 CFLAGS=-fPIC
sudo make DESTDIR=/usr install
popd
sudo ldconfig


wget https://github.com/shadowsocks/shadowsocks-libev/releases/download/v3.0.8/shadowsocks-libev-3.0.8.tar.gz
tar -zxvf shadowsocks-libev-3.0.8.tar.gz
cd shadowsocks-libev-3.0.8
./configure --prefix=/usr --disable-documentation
sudo make install

sudo cp ./debian/shadowsocks-libev-redir@.service /lib/systemd/system/shadowsocks-libev-redir.service
sudo vim /lib/systemd/system/shadowsocks-libev-redir.service
sudo mkdir -p  /etc/shadowsocks-libev
sudo cp ./debian/config.json /etc/shadowsocks-libev/redir.json
sudo vim /etc/shadowsocks-libev/redir.json
add "local_address":"0.0.0.0",
```

```
sudo systemctl daemon-reload
sudo systemctl enable shadowsocks-libev-redir
sudo systemctl start shadowsocks-libev-redir
sudo systemctl status shadowsocks-libev-redir -l
```

## 增加NAT Chain
```
sudo iptables -t nat -N SHADOWSOCKS
```

## 过滤目的ss服务器地址
```
sudo iptables -t nat -A SHADOWSOCKS -d 45.32.17.217 -j RETURN
```

## 过滤保留,私有,回环地址
```
sudo iptables -t nat -A SHADOWSOCKS -d 0.0.0.0/8 -j RETURN
sudo iptables -t nat -A SHADOWSOCKS -d 10.0.0.0/8 -j RETURN
sudo iptables -t nat -A SHADOWSOCKS -d 127.0.0.0/8 -j RETURN
sudo iptables -t nat -A SHADOWSOCKS -d 169.254.0.0/16 -j RETURN
sudo iptables -t nat -A SHADOWSOCKS -d 172.16.0.0/12 -j RETURN
sudo iptables -t nat -A SHADOWSOCKS -d 192.168.0.0/16 -j RETURN
sudo iptables -t nat -A SHADOWSOCKS -d 224.0.0.0/4 -j RETURN
sudo iptables -t nat -A SHADOWSOCKS -d 240.0.0.0/4 -j RETURN
```

## 过滤大陆地址
```
sudo apt-get install ipset -y
curl -sL http://f.ip.cn/rt/chnroutes.txt | egrep -v '^$|^#' > cidr_cn
sudo ipset -N cidr_cn hash:net
for i in `cat cidr_cn`; do echo ipset -A cidr_cn $i >> ipset.sh; done
chmod +x ipset.sh && sudo ./ipset.sh
sudo mkdir -p /etc/sysconfig
sudo ipset -S  | sudo tee /etc/sysconfig/ipset.cidr_cn
sudo vim /etc/rc.local
add
ipset restore < /etc/sysconfig/ipset.cidr_cn
sudo iptables -t nat -A SHADOWSOCKS -m set --match-set cidr_cn dst -j RETURN
```

### 查看ipset
```
sudo ipset list 
```

## 重定向至ss-redir
```
sudo iptables -t nat -A SHADOWSOCKS -p tcp -j REDIRECT --to-ports 1080
sudo iptables -t nat -A OUTPUT -p tcp -j SHADOWSOCKS
```

## 保存iptables
```
sudo service netfilter-persistent save
sudo vim /etc/rc.local
add
iptables-restore < /etc/iptables/rules.v4
iptables-restore < /etc/iptables/rules.v6 
```

# 树莓派shadowsocks-libev-tunnel
```
sudo cp ./debian/shadowsocks-libev-tunnel@.service /lib/systemd/system/shadowsocks-libev-tunnel.service
sudo vim /lib/systemd/system/shadowsocks-libev-tunnel.service
add -L 8.8.4.4:53 -U
sudo mkdir -p /etc/shadowsocks-libev
sudo cp ./debian/config.json /etc/shadowsocks-libev/tunnel.json
sudo vim /etc/shadowsocks-libev/tunnel.json
add "local_address":"0.0.0.0",
```

```
sudo systemctl daemon-reload
sudo systemctl enable shadowsocks-libev-tunnel
sudo systemctl start shadowsocks-libev-tunnel
sudo systemctl status shadowsocks-libev-tunnel -l
```

# 树莓派chinadns
```
cd ..
wget https://github.com/shadowsocks/ChinaDNS/releases/download/1.3.2/chinadns-1.3.2.tar.gz
tar -zxvf chinadns-1.3.2.tar.gz
cd chinadns-1.3.2
./configure
make
sudo make install

sudo wget https://raw.githubusercontent.com/yqsy/linux_script/master/chinadns.service -O /lib/systemd/system/chinadns.service
```

```
sudo systemctl daemon-reload
sudo systemctl enable chinadns
sudo systemctl start chinadns
sudo systemctl status chinadns -l
```

# 树莓派开启ip包转发
```
sudo vim /etc/sysctl.conf
net.ipv4.ip_forward=1
sudo sysctl -p
```

# 树莓派dnsmasq,dns转发
```
sudo apt-get install dnsmasq -y
sudo vim /etc/dnsmasq.conf
no-resolv 
server=202.38.93.153 
server=202.141.162.123

sudo systemctl restart  dnsmasq.service
```

## 查看使用的dns服务器
```
sudo vim /etc/resolv.conf
```