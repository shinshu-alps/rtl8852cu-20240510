#!/bin/bash

# Tested on Ubuntu 22.04.5 LTS with WI-U3-2400XE2

WIRELESS_REGDB_VERSION=2025.10.07
COUNTRY=JP
sudo apt update
sudo apt install -y build-essential dkms git iw libssl-dev checkinstall pkg-config dbus libdbus-1-dev libdbus-glib-1-2 libdbus-glib-1-dev libreadline-dev libncurses5-dev libnl-genl-3-dev libnl-3-dev

cd /tmp
echo -e "\e[30;33mInstalling rtl8852cu driver....\e[m"
git clone https://github.com/shinshu-alps/rtl8852cu-20240510.git
cd ./rtl8852cu-20240510
sudo sh install-driver.sh NoPrompt
sudo sed -i "10s/.*/options 8852cu rtw_switch_usb_mode=1 rtw_country_code=${COUNTRY}/" /etc/modprobe.d/8852cu.conf


echo -e "\e[30;33mUpdating wireless-regdb...\e[m"
cd ..
wget https://mirrors.edge.kernel.org/pub/software/network/wireless-regdb/wireless-regdb-${WIRELESS_REGDB_VERSION}.tar.xz
tar -Jxvf wireless-regdb-${WIRELESS_REGDB_VERSION}.tar.xz
cd wireless-regdb-${WIRELESS_REGDB_VERSION}/
sudo mv /lib/crda/regulatory.bin /lib/crda/regulatory.bin.bak
sudo cp regulatory.bin /lib/crda
cd ..

STARTUP_SCRIPT="/etc/rc.local"
if [ -f ${STARTUP_SCRIPT} ]; then
  if ! grep "iw reg set ${COUNTRY}" ${STARTUP_SCRIPT}; then
    sudo sed -i -e "$i \iw reg set ${COUNTRY}" ${STARTUP_SCRIPT}
  fi
else
  echo '#!/bin/bash' >> ${STARTUP_SCRIPT}
  echo "iw reg set ${COUNTRY}" >> ${STARTUP_SCRIPT}
  echo 'exit 0' >> ${STARTUP_SCRIPT}
fi
sudo chmod 755 /etc/rc.local

echo -e "\e[30;33mInstalling modified wpa_supplicant...\e[m"
wget https://w1.fi/releases/wpa_supplicant-2.10.tar.gz
tar xzvf wpa_supplicant-2.10.tar.gz
cd wpa_supplicant-2.10/wpa_supplicant/
sed -i -e "887i wpa_s->conf->sae_pwe = 2;" events.c
cp defconfig .config
make BINDIR=/sbin LIBDIR=/lib
sudo install -v -m755 wpa_cli wpa_passphrase wpa_supplicant /sbin/

printf "Reboot now? [Y/n]: "
read yn || yn=Y
case "$yn" in
  [nN]) ;;
  *) sudo reboot ;;
esac
