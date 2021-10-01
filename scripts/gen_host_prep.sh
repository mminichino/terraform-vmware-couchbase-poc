#!/bin/sh

INTERFACE_NAME=$(nmcli -t -f NAME c s --active | head -1)

IP_ADDRESS=$(nmcli c s $INTERFACE_NAME | grep "IP4.ADDRESS" | awk '{print $2}' | sed -e 's/\/.*$//')

HOSTNAME=$(uname -n)

sudo sh -c "sed -i -e \"/$HOSTNAME/d\" -e \"/^$/d\" /etc/hosts"

sudo sh -c "echo \"$IP_ADDRESS $HOSTNAME\" >> /etc/hosts"

sudo systemctl stop firewalld
sudo systemctl disable firewalld

sudo yum install -y chrony
sudo systemctl enable chronyd
sudo systemctl start chronyd

echo "Disabling THP."

sudo bash -c 'cat <<EOF > /etc/init.d/disable-thp
#!/bin/bash
### BEGIN INIT INFO
# Provides:          disable-thp
# Required-Start:    $local_fs
# Required-Stop:
# X-Start-Before:    couchbase-server
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Disable THP
# Description:       disables Transparent Huge Pages (THP) on boot
### END INIT INFO

case $1 in
start)
  if [ -d /sys/kernel/mm/transparent_hugepage ]; then
    echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled
    echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag
  elif [ -d /sys/kernel/mm/redhat_transparent_hugepage ]; then
    echo 'never' > /sys/kernel/mm/redhat_transparent_hugepage/enabled
    echo 'never' > /sys/kernel/mm/redhat_transparent_hugepage/defrag
  else
    return 0
  fi
;;
esac
EOF'

sudo chmod 755 /etc/init.d/disable-thp

sudo chkconfig --add disable-thp

sudo mkdir /etc/tuned/no-thp

sudo bash -c 'cat <<EOF > /etc/tuned/no-thp/tuned.conf
[main]
include=virtual-guest

[vm]
transparent_hugepages=never
EOF'

sudo tuned-adm profile no-thp

echo "Configuring swappiness."

sudo sh -c 'echo "vm.swappiness = 0" >> /etc/sysctl.conf'

echo "Installng software."

sudo yum install -y epel-release
sudo yum install -y bzip2 jq git python-pip wget vim-enhanced xmlstarlet java-1.8.0-openjdk maven nc

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install -y docker-ce docker-ce-cli containerd.io

sudo usermod -a -G docker admin

sudo systemctl start docker
sudo systemctl enable docker

echo "Process Complete."
exit 0
