#!/bin/sh

echo "Creating admin user."

sudo groupadd -g 1001 admin
sudo useradd -u 1001 -g admin admin
sudo usermod -a -G wheel admin
sudo sed -i -e 's/^# %wheel/%wheel/' /etc/sudoers
sudo mkdir ~admin/.ssh
sudo chown admin:admin ~admin/.ssh
sudo chmod 700 ~admin/.ssh
sudo cp ~/.ssh/authorized_keys ~admin/.ssh/authorized_keys
sudo chmod 600 ~admin/.ssh/authorized_keys
sudo chown admin:admin ~admin/.ssh/authorized_keys

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
