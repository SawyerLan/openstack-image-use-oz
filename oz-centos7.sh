#!/bin/bash

# ssh-keygen
[[ ! -f ~/.ssh/id_rsa.pub ]] && ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa 
cp ~/.ssh/id_rsa.pub /data/www/repo/init-instance/

# oz install 
OZ_HOME="/data/oz/templates"
cd $OZ_HOME
start_time=`date +%s`
echo -e "\033[37;32;1m oz-install start:$start_time ,about need 350s install,please waitting...\033[0m"
oz-install -p -u -d2 -t 2500 -x centos7.xml -a centos7.ks centos7.tdl
done_time=`date +%s`
echo -e "\033[37;32;1m oz-install done:$done_time,use time:`echo $done_time-$start_time|bc` \033[0m"
#cd images
#guestmount -a  centos7.qcow2 -i --rw temp/
#ip=`cat temp/root/if.log |grep "inet addr"|grep -v "127.0" |awk '{print $2}'|awk -F":" '{print $2}'`
ip="192.168.4.117"
#umount temp 

virsh define $OZ_HOME/centos7.xml
virsh start centos7
sleep 6
for i in {1..15}
do
	ping -c 2 $ip
	[[ $? -eq 1 ]] && sleep 3 || break 
done

echo -e "\033[37;32;1m ip:$ip \033[0m"
echo "ssh root@$ip"


for i in {1..15}
do 
	echo "QUIT" |nc -w 2 $ip 22
	if [[ $? -eq 1 ]];then
		echo -e "\033[37;32;1m Can not connect to $ip:22,3s retry... \033[0m"
		sleep 3 
	else
		echo -e "\033[37;32;1m $ip kernel update and reboot... \033[0m"
		ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$ip -C "yum update -y kernel"
		ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$ip -C "rpm -qa kernel"
		ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$ip -C "cat /boot/grub/grub.conf"
		ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$ip -C "poweroff"
		break 
	fi
done
sleep 3
echo -e "\033[37;32;1m Poweron $ip again... \033[0m"
#virsh destroy centos7
# Do not use "virsh destroy centos7",the will cause kernel panic.
for i in {1..15}
do
	virsh start centos7
	[[ $? -eq 0 ]] && break || sleep 2
done

for i in {1..15}
do 
	echo "QUIT" |nc -w 2 $ip 22
	if [[ $? -eq 1 ]];then
		echo -e "\033[37;32;1m Can not connect to $ip:22, 3s retry... \033[0m"
		sleep 3 
	else
		ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$ip -C "curl -sL http://mirrors.rmz.gomo.com/init-instance/oz-centos7-config.sh | sh -v"
		break 
	fi
	[[ $i -eq 15 ]] && echo -e "\033[37;31;1m Oh,something Wrong. Has connected 15 times, but still cannot connect to $ip,oz-install exit \033[0m" && exit
done

sleep 8

for i in {1..15}
do
	if [[ ! -z `virsh list --all |grep centos7 |grep -o "shut off"` ]];then
		echo -e "\033[37;32;1m qemu-img convert -p -c centos7.dsk -O qcow2 centos7-latest.qcow2 \033[0m"
		cd $OZ_HOME/images
		qemu-img convert -p -c centos7.dsk -O qcow2 centos7-latest.qcow2
		[[ $? -eq 0 ]] && break
	else
		sleep 2
		[[ $i -eq 10 ]] && echo -e "\033[37;31;1m Oh,the host seem hasn't been shut down, will execute virsh destroy... \033[0m" && virsh destroy centos7 && sleep 10 && break
	fi
done


echo -e "\033[37;32;1m Clean and config something.. \033[0m"
cd $OZ_HOME
umount $OZ_HOME/images/temp
cd $OZ_HOME/images/
guestmount -a  centos7-latest.qcow2 -i --rw temp/
cd temp
echo "PermitRootLogin no" >>etc/ssh/sshd_config
echo "Port 37856" >>etc/ssh/sshd_config
rm etc/udev/rules.d/70-persistent-net.rules -f 
>etc/resolv.conf
cat >etc/sysconfig/network-scripts/ifcfg-eth0<<EOF
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=dhcp
EOF

cd $OZ_HOME
umount $OZ_HOME/images/temp
rm $OZ_HOME/centos7.xml

echo -e "\033[37;33;1m Wonderfull, everything has Done. \033[0m\n"
echo -e "\033[37;34;1m Get Image:http://mirrors.rmz.gomo.com/images/centos7-latest.qcow2. \033[0m"
echo -e "\033[37;34;1m Image in:/data/www/repo/images/centos7-latest.qcow2. \033[0m"
