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

localectl set-locale LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
echo export LC_ALL=en_US.UTF-8 >> ~/.bashrc

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
  systemctl enable docker.service
  systemctl start docker.service
fi

## ~/.vimrc
curl https://raw.githubusercontent.com/yqsy/linux_script/master/.vimrc | tee ~/.vimrc
