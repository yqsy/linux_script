kernel_full=`uname -r`
kernel_version=`echo $kernel_full | awk -F '-' '{ print $1 }'`
machine=`uname -m`
release_version=`cat /etc/redhat-release`

echo "====================================="
echo "kernel_full: $kernel_full"
echo "kernel_version: $kernel_version"
echo "machine: $machine"
echo "release_version: $release_version"
echo "====================================="

if ! echo $release_version | grep CentOS; then
  echo "Now only support CentOS Linux release"
  exit 1
fi


iptables -F
iptables -X
iptables -Z
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

yum install -y wget
localectl set-locale LANG=en_US.UTF-8
echo export LC_ALL=en_US.UTF-8 >> ~/.bashrc

echo -n "Need China repos? >"
read -p "(default: no) yes or no" china_repos
echo "You Enter: $china_repos"

# repos
if [ "$china_repos" == "yes" ]
then
  mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
  wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo
  yum clean all
  yum makecache
fi

yum update -y

# epel repos
yum install -y epel-release

#basic
yum install -y vim
yum install -y curl net-tools telnet
yum install -y git gcc gcc-c++ gdb python34 autoconf libtool cmake clang
yum install -y iperf3  tcpdump
yum install -y augeas

wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
rm -rf get-pip.py

# docker
# https://docs.docker.com/datacenter/ucp/1.1/installation/system-requirements/
# Linux kernel version 3.10 or higher
if [ $kernel_version \> '3.10' ] ||
   [ $kernel_version = '3.10' ]
then
  if ! rpm -qa | grep docker-engine; then
    yum install -y docker
  fi
  systemctl enable docker.service
  systemctl start docker.service

  # docker repos
  if [ "$china_repos" == "yes" ]
  then
    curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://0541a772.m.daocloud.io &&
    systemctl restart docker
  fi
fi

## ~/.vimrc
curl https://raw.githubusercontent.com/yqsy/linux_script/master/.vimrc | tee ~/.vimrc
