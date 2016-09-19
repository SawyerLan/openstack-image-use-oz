openstack-image-use-oz

Use oz create openstack centos6/7 image.

You can use:
sudo ./oz-centos68.sh 

The oz-centos68.sh will do those:

Step1. OZ install a virtual host

Step2. SSH connect this host and yum update kernel,then reboot host (Because kernel remove need restart)

Step3. SSH connect and config something like yum, service ,and some your custom scripts.

See detial in Wiki
https://github.com/SawyerLan/openstack-image-use-oz/wiki
