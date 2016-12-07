#!/bin/bash

# This prepares a stock CentOS 7 server to build AWS AMIs with Packer.

if [[ $0 != '-bash' ]]; then
    echo -e "ERROR: Run this using this command to ensure that environment variables are preserved in the running shell:\n    source $0"
    exit
fi

# Verify that this is not run as root.
if [[ $USER == 'root' ]]; then
   echo "ERROR: Do not run this as root or with sudo."
   exit
fi

# Install AWS CLI. This is kinda stupid. I need to update this code to just
# install EPEL and python-pip and use the pip install method.
curl -O https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# Get AWS keys. This is also stupid - I copied/improved a decent aws_switch script - I should update this to use that.
read -p 'AWS Access Key Id: '
export AWS_ACCESS_KEY_ID="${REPLY}"
read -p 'AWS Secret Access Key: '
export AWS_SECRET_ACCESS_KEY="${REPLY}"

# Test AWS
AWS_DEFAULT_REGION=us-west-2 aws ec2 describe-regions

# This was for VirtualBox - it didn't work. Trying QEMU now.
#read -p "The kernel-devel package version and the current running kernel version must match for this process to complete successfully. If you have already upgraded the server, then enter \"upgraded\" and press Enter."
#if [[ $REPLY != 'upgraded' ]]; then
#    exit
#fi

# Ensure that we are in the user's home directory.
cd ~

curl -O https://releases.hashicorp.com/packer/0.10.1/packer_0.10.1_linux_amd64.zip
sudo yum install -y unzip
unzip packer_0.10.1_linux_amd64.zip

# Putting this in your home bin directory, because there's already another
# packer executable installed at /usr/sbin/packer from cracklib-dicts that we
# can't uninstall. Also, renaming it to packer.io so we don't have to run it
# with an absolute path.
mkdir "${HOME}/bin"
mv packer "${HOME}/bin/packer.io"
rm packer_0.10.1_linux_amd64.zip

# Installing jq because it's a nice tool for messing with JSON.
curl -LO https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
chmod +x jq-linux64
mv jq-linux64 bin/jq

# Install Vagrant
curl -O https://releases.hashicorp.com/vagrant/1.8.5/vagrant_1.8.5_x86_64.rpm
sudo yum install -y vagrant_1.8.5_x86_64.rpm
rm vagrant_1.8.5_x86_64.rpm

# This was for VirtualBox - it didn't work. Trying QEMU now.
# Install VirtualBox
#curl -O http://download.virtualbox.org/virtualbox/5.1.6/VirtualBox-5.1-5.1.6_110634_el7-1.x86_64.rpm
#sudo yum install -y VirtualBox-5.1-5.1.6_110634_el7-1.x86_64.rpm
#rm VirtualBox-5.1-5.1.6_110634_el7-1.x86_64.rpm
#sudo yum install -y gcc make kernel-devel
#sudo /sbin/vboxconfig

# Install QEMU
sudo yum install -y qemu-kvm
# Work around this stupid bug:
# Build 'qemu' errored: Failed creating Qemu driver: exec: "qemu-system-x86_64": executable file not found in $PATH
export PATH=$PATH:/usr/libexec
sudo cp -l /usr/libexec/qemu-kvm /usr/libexec/qemu-system-x86_64
