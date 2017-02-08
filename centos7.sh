#basic
yum update -y
yum install -y vim
yum install -y net-tools
yum install -y curl
yum install -y git
LANG="en_US.utf8"



# docker
if ! rpm -qa | grep docker-engine; then
# DaoCloud script
    curl -sSL https://get.daocloud.io/docker | sh
fi
systemctl enable docker.service
systemctl start docker

## ~/.vimrc
curl https://raw.githubusercontent.com/yqsy/linux_script/master/.vimrc | tee ~/.vimrc

