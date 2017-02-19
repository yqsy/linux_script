kernel_full=`uname -r`
kernel_version=`echo $kernel_full | awk -F '-' '{ print $1 }'`
machine=`uname -m`
release_version=`cat /etc/redhat-release`

echo "====================================="
echo "kernel_full: $kernel_full"
echo "kernel_version: $kernel_version"
echo "machine: $machine"
echo "release_version: $release_version"
echo "ssh port will be changed to 58888"
echo "====================================="

if ! echo $release_version | grep CentOS | grep 7.3; then
  echo "Now only support CentOS Linux release 7.3.1611"
  exit 1
fi

#basic
yum update -y
yum install -y vim
yum install -y net-tools
yum install -y curl
yum install -y git
yum install -y gcc

yum install -y epel-release
yum install -y iperf3
yum install -y augeas
LANG="en_US.utf8"


# docker
# https://docs.docker.com/datacenter/ucp/1.1/installation/system-requirements/
# Linux kernel version 3.10 or higher
if [ $kernel_version \> '3.10' ] ||
   [ $kernel_version = '3.10' ]
then
  if ! rpm -qa | grep docker-engine; then
  # DaoCloud script
      curl -sSL https://get.daocloud.io/docker | sh
  fi
  systemctl enable docker
  systemctl start docker
fi

## ~/.vimrc
curl https://raw.githubusercontent.com/yqsy/linux_script/master/.vimrc | tee ~/.vimrc


augtool --autosave 'set /files/etc/ssh/sshd_config/Port 58888'
systemctl restart sshd

iptables -F
iptables -X
iptables -Z
