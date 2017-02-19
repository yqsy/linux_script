#basic
yum update -y
yum install -y vim
yum install -y net-tools
yum install -y curl
yum install -y git
yum install -y gcc
LANG="en_US.utf8"


# python3.4
# wget https://www.python.org/ftp/python/3.4.4/Python-3.4.4.tgz
# tar xzf Python-3.4.4.tgz
# cd Python-3.4.4
# ./configure
# make altinstall
# cd ..
# rm -rf Python-3.4.4
# rm -rf Python-3.4.4.tgz

# python 2.6
if ! ls /usr/local/bin | grep python2.6; then
    wget https://www.python.org/ftp/python/2.6.8/Python-2.6.8.tgz
    tar xzf Python-2.6.8.tgz
    cd Python-2.6.8
    ./configure
    make altinstall
    cd ..
    rm -rf Python-2.6.8
    rm -rf Python-2.6.8.tgz
fi

# denyhosts
yum install denyhosts
systemctl enable denyhosts.service
systemctl start denyhosts.service


# docker
if ! rpm -qa | grep docker-engine; then
# DaoCloud script
    curl -sSL https://get.daocloud.io/docker | sh
fi
systemctl enable docker.service
systemctl start docker.service

## ~/.vimrc
curl https://raw.githubusercontent.com/yqsy/linux_script/master/.vimrc | tee ~/.vimrc
