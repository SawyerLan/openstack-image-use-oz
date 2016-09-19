# Kickstart file automatically generated by anaconda.

#version=DEVEL
install
lang en_US.UTF-8
keyboard us
network --onboot yes --device eth0 --bootproto static --ip 192.168.4.117 --netmask 255.255.255.0 --gateway 192.168.4.1 --noipv6 --nameserver 192.168.109.254 

rootpw  --iscrypted $6$y4d8SlW6mJ/rK3O6$YfYiuUzFcAK.RP8P8gl1ui8PxE.n9cBWjPT.6hlyXrFfIesYZAamBlXHun1LH3fsqZ/sWN/A1T8VPDHgcgdSH/
firewall --disabled 
authconfig --enableshadow --passalgo=sha512
selinux --disabled
logging --level=debug
# Reboot after installation 
reboot 
# System services
services --disabled="avahi-daemon,iscsi,iscsid,firstboot,kdump" --enabled="network,sshd,rsyslog,tuned"
timezone --utc Asia/Shanghai
bootloader --location=mbr --driveorder=sda --append="crashkernel=auto rhgb quiet console=tty0 console=ttyS0"
# Clear the Master Boot Record
zerombr

# Disk partitioning information 
part / --fstype="ext4" --size=8192 --grow

%post --log=/root/ks-post.log
# get ip 
ifconfig >/root/if.log
/etc/init.d/network restart

# Fetch public key using HTTP
if [ ! -d /root/.ssh ]; then
        mkdir -p /root/.ssh
        chmod 700 /root/.ssh
fi

ATTEMPTS=10
FAILED=0
while [ ! -f /root/.ssh/authorized_keys ]; do
        curl -f http://mirrors.rmz.gomo.com/init-instance/id_rsa.pub >/tmp/metadata-key 2>/dev/null
        if [ $? -eq 0 ]; then
                cat /tmp/metadata-key >> /root/.ssh/authorized_keys
                chmod 0600 /root/.ssh/authorized_keys
                chown -R root.root /root/.ssh/authorized_keys
                restorecon /root/.ssh/authorized_keys
                rm -f /tmp/metadata-key
                echo "Successfully retrieved public key from instance metadata"
        else
                FAILED=`expr $FAILED + 1`
                if [ $FAILED -ge $ATTEMPTS ]; then
                        echo "Failed to retrieve public key from instance metadata after $FAILED attempts, quitting"
                        break
                fi
                echo "Could not retrieve public key from instance metadata (attempt #$FAILED/$ATTEMPTS), retrying in 3 seconds..."
                sleep 3
        fi
done

%end

%packages --nobase
@core
%end