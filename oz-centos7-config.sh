#!/bin/bash
rpm -qa kernel
yum -y remove kernel-3.10.0-327.el7

# config yum 
echo "retries=5" >>/etc/yum.conf

# init yum 
for i in {1..15}
do
	HTTP_CODE1=`curl -o /etc/yum.repos.d/epel.repo -s -w %{http_code} http://mirrors.aliyun.com/repo/epel-7.repo`
	HTTP_CODE2=`curl -o /etc/yum.repos.d/govm.repo -s -w %{http_code} http://mirrors.rmz.gomo.com/govm.repo`
	HTTP_CODE3=`curl -o /etc/yum.repos.d/CentOS-Base.repo -s -w %{http_code} http://mirrors.aliyun.com/repo/Centos-7.repo`
	[[ $HTTP_CODE1 == 200 ]] && [[ $HTTP_CODE2 == 200 ]] && [[ $HTTP_CODE3 == 200 ]] && break 
done

# openstack instance init 
curl -so /etc/bashrc http://mirrors.rmz.gomo.com/init-instance/bashrc
curl -so /etc/sysctl.conf http://mirrors.rmz.gomo.com/init-instance/sysctl.conf
curl -so /etc/rc.d/rc.local  http://mirrors.rmz.gomo.com/init-instance/rc.local
chmod 755  /etc/rc.d/rc.local

# yum install 
for i in {1..15}
do
	yum update -y 
	res0=$?
	yum install -y acpid vim rsync cloud-init cloud-utils-growpart parted lrzsz tree unzip zabbix-agent salt-minion mtr iftop tcpdump ntpdate rdate strace ntop bind-utils lsof bc telnet htop dstat redhat-lsb-core irqbalance man iptables-services
	res1=$?
	if [[ $res0 -eq 0 ]] && [[ $res1 -eq 0 ]];then
		echo "yum install/update OK"
		break 
	else
		echo "yum install $i failed,total is 15,1s retry..."
		sleep 1
	fi
done

#curl -L -s -o  /tmp/linux-rootfs-resize-master.zip  http://mirrors.rmz.gomo.com/init-instance/linux-rootfs-resize-master.zip
#cd /tmp && unzip linux-rootfs-resize-master.zip && cd linux-rootfs-resize-master/  && ./install
#cd /tmp && rm linux-rootfs-resize-master* -rf

# chkconfig irqbalance on
systemctl disable iptables.service 
systemctl enable irqbalance.service 

# create swapfile
dd if=/dev/zero of=/swapfile bs=1M count=2048
mkswap -f /swapfile
swapon /swapfile
echo "/swapfile swap swap defaults 0 0" >>/etc/fstab
echo "config all, will poweroff..."

poweroff

