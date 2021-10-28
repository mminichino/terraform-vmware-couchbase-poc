#!/bin/sh
#
MYUSER=$(id -nu)

sudo -n ls >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Sudo without password is required."
  exit 1
fi

if [ ! -d /usr/local/hostprep ]; then
  which git >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    source /etc/os-release
    case $ID in
    centos)
      sudo yum install -y git
      ;;
    *)
      echo "Unknown Linux distribution $ID"
      exit 1
      ;;
    esac
  fi
  sudo git clone https://github.com/mminichino/hostprep /usr/local/hostprep
fi

sudo /usr/local/hostprep/bin/hostprep.sh -U $MYUSER $@

