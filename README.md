openstack-image-use-oz

Use oz create openstack centos6/7 image.

You can use:
sudo ./oz-centos68.sh 

The oz-centos68.sh will do those:

Step1. OZ install a virtual host

Step2. SSH connect this host and yum update kernel,then reboot host (Because kernel remove need restart)

Step3. SSH connect and config something like yum, service ,and some your custom scripts.

-----------------------------------------
The oz.cfg:
cat /etc/oz/oz.cfg
[paths]
output_dir = /data/www/repo/images/
data_dir = /data/oz
screenshot_dir = /data/oz/screenshots
# sshprivkey = /etc/oz/id_rsa-icicle-gen

[libvirt]
uri = qemu:///system
image_type = raw
# type = kvm
# bridge_name = virbr0
cpus = 2
memory = 2048

[cache]
original_media = yes
modified_media = no
jeos = no

[icicle]
safe_generation = no

-------------------------------------------
My IP config :

eth0      Link encap:Ethernet  HWaddr 00:50:56:A8:04:52  
          inet6 addr: fe80::250:56ff:fea8:452/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:151208506 errors:0 dropped:0 overruns:0 frame:0
          TX packets:5144907 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:96801223327 (90.1 GiB)  TX bytes:20160520733 (18.7 GiB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:11026 errors:0 dropped:0 overruns:0 frame:0
          TX packets:11026 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:13693323 (13.0 MiB)  TX bytes:13693323 (13.0 MiB)

virbr0    Link encap:Ethernet  HWaddr 00:50:56:A8:04:52  
          inet addr:192.168.4.82  Bcast:192.168.4.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:5493149 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3868102 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:1634720469 (1.5 GiB)  TX bytes:20335781596 (18.9 GiB)

-------------------------------------------------
The libvirt config like this:

cat /etc/libvirt/qemu/networks
<!--
WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE 
OVERWRITTEN AND LOST. Changes to this xml configuration should be made using:
  virsh net-edit default
or other application using the libvirt API.
-->

<network>
  <name>default</name>
  <uuid>978ea6c1-8246-4a17-968f-2ea450372984</uuid>
  <forward mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0' />
  <mac address='52:54:00:FB:66:DE'/>
  <ip address='192.168.4.82' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.4.101' end='192.168.4.120' />
    </dhcp>
  </ip>
</network>

