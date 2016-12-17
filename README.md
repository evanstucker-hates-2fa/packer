# packer

# Preventable Perils Preceding Palliative Packer Paradigms

## Overview

Preventable Perils Preceding Palliative Packer Paradigms

In this talk, I'll share my experiences with Packer. First, I'll go over the initial questions of "what is Packer and why do we need it?", then I'll briefly go over the various components and how to cram them into a template. Then I'll entertain and delight you with my initial attempts to get it work, architectural mistakes, and finally, an example of a working Packer configuration that can take you from ISO images to Amazon Machine Images.

I've got about 30 minutes, but be warned: I am still new to Packer, so this may be a bit like the blind leading the blind...

To ensure that this talk is relevant, can I get a show of hands?

Who currently uses Packer?
Who has ever created an operating system image?

## What is Packer?

https://www.packer.io/intro/

## Why use Packer?

https://www.packer.io/intro/why.html

## What do you do when a new major version of your OS is released?

Do you download the ISO, then create a bunch of images manually for each environment you have using tools like these?

- Physical servers: [cobbler import](http://cobbler.github.io/manuals/quickstart/)
- VMware: [Clone a Virtual Machine to a Template in the vSphere Web Client](http://pubs.vmware.com/vsphere-65/index.jsp#com.vmware.vsphere.vm_admin.doc/GUID-FE6DE4DF-FAD0-4BB0-A1FD-AFE9A40F4BFE_copy.html)
- AWS: [Creating an Amazon EBS-Backed Linux AMI](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/creating-an-ami-ebs.html)
- Docker: [Create a base image](https://docs.docker.com/engine/userguide/eng-image/baseimages/)
- OpenStack: [Create images manually](http://docs.openstack.org/image-guide/create-images-manually.html)
- etc.

Packer can create images for (almost?) all of these at once with a single command! I say "almost", because I haven't used Packer to create images for physical servers yet, but it seems like some people have had some success doing that. See https://github.com/mitchellh/packer/issues/955. This post also mentions something call Razor, which I know nothing about: https://github.com/puppetlabs/razor-server/

## How often do you create images?

Most companies I've worked for create new images several months or even years after the latest version of an OS is released. 

## How often do you update your images?

With Packer you can roll your updates into new images easily and deploy servers with all the latest updates already installed. You don't have to wait for a Puppet run or a "yum update" to bring new servers up to date.

## Why shouldn't I just use community images?

Community images are fine, just like "curl | sudo bash" is fine. They get the job done quickly and easily. However, some companies that are run by boring grown-ups think that consistency, control, and compliance are important, so unfortunately, not all of us have the luxury of using anything that boots.

## Random links
 
 Regarding encrypting AMIs:
 https://github.com/mitchellh/packer/issues/3761 was recently closed by https://github.com/mitchellh/packer/pull/4243
 
 
# Creating Operating System Images with Packer

## Introduction

This process will allow you to build consistent, scripted AWS AMIs for both CentOS 7.2 and Oracle Linux 7.2 on a Windows workstation.

We use Packer to build images, because we want:

- a repeatable, scriptable, IaC way to build images
- to upgrade and rebuild the images every quarter
- to be able to easily distribute the images to any platform (AWS, VMware, etc.)

In order for Packer to build images, it needs to run on hardware, because it uses Vagrant and VirtualBox to create a VM that it will then export to AWS (or VMware). Running virtualization software inside VMware or AWS is slow and miserable, but we don't have any physical servers available at the moment, so this document will serve as a high-level guide on setting up all the tools you need on your workstation.

## Install and configure software

Install these:

    Download Packer from https://www.packer.io/downloads.html.
        Windows:
            Extract the zip file.
            Move the "packer_0.10.1_windows_amd64" folder to "C:\Program Files\packer_0.10.1_windows_amd64"
            Add "C:\Program Files\packer_0.10.1_windows_amd64" to your PATH environment variable.
    Download and install Vagrant from https://www.vagrantup.com/downloads.html.
    Download and install VirtualBox from https://www.virtualbox.org/wiki/Downloads.
    Download and install the AWS CLI: http://docs.aws.amazon.com/cli/latest/userguide/installing.html

    Configure AWS CLI with multiple named profiles (http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-quick-configuration):
    :: I recommend that you leave default region set to "None" to avoid doing something in the wrong region by accident.
    aws configure --profile devops
    aws configure --profile iaas

## Get the latest revision of the Packer depot

## Download ISO images

For CentOS 7, I downloaded http://mirrors.cat.pdx.edu/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-1511.iso

For Oracle Linux 7.2, I logged into https://edelivery.oracle.com/osdc/faces/Home.jspx and downloaded V100082-01.iso. 

AWS doesn't currently support Oracle Linux 7.2 - it will fail during the image import process with a message that it's particular kernel version is unsupported. However, you can work around this by switching to the regular kernel instead of the UEK kernel. Once the new image has been created, I'll have Puppet configured to switch it back to the original UEK kernel - probably the newer UEK4 kernel actually...

All of your ISO images should be in the Packer el7 directory.

## Get a default Kickstart file

We always want to start with a clean kickstart file. To get one, you will need to manually create a VM (I used VirtualBox), and don't change ANY settings. If you are forced to enter some information (ex. a root password), then do that, but try to change nothing. Don't mess with the timezone, don't mess with networking, etc. Touch nothing. After the new VM boot, SSH into it, copy the Kickstart file, and put it in the Packer Perforce directory to use as a reference.

RHEL 7 and derivatives usually boot with networking disabled, which is really annoying. Fix it with this:
sed -i 's/^ONBOOT=no/ONBOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-e*
systemctl restart network.service

## Run Packer

Packer often types the boot command wrong. It may enter double or triple characters if your workstation's CPU is even slightly burdened. Because of this, I changed the boot_command in the JSON file from:
"boot_command": [
  "<tab> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter>"
]

to
"boot_command": [
  "<tab> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg"
]

So that I can go back and fix it by hand before booting the system. The SSH timeout is currently set to "10m", so watch the command line and get it booted quickly so it has time to install all the packages and reboot.

That "aws sts" command gives you the privileges to import the image for 1 hour. You cannot extend it. Remember to enter that command before every packer run, or you will likely fail to import the image.

    Open a command prompt.

    Change to the packer code directory.

    Run packer:

        Windows: 
        :: Have to set all yours keys in your environment because Packer doesn't work with AWS profiles yet.
        set devops_access_key=<your devops access key>
        set devops_secret_key=<your devops secret key>
        set iaas_access_key=<your iaas access key>
        set iaas_secret_key=<your iaas secret key>
        aws --profile devops --region us-west-2 sts assume-role --role-arn "arn:aws:iam::REDACTED:role/vmimport" --role-session-name "Packer"
        aws --profile iaas --region us-west-2 sts assume-role --role-arn "arn:aws:iam::REDACTED:role/vmimport" --role-session-name "Packer"
        packer build -var "user=%USERNAME%" -var "home=%USERPROFILE%" el7/iso_to_ami.json

        OS X: 

        Untested, but might work.
        export devops_access_key="your devops access key"
        export devops_secret_key="your devops secret key"
        export iaas_access_key="your iaas access key"
        export iaas_secret_key="your iaas secret key"
        aws  --profile devops --region us-west-2 sts assume-role --role-arn "arn:aws:iam::REDACTED:role/vmimport" --role-session-name "Packer"
        aws  --profile iaas --region us-west-2 sts assume-role --role-arn "arn:aws:iam::REDACTED:role/vmimport" --role-session-name "Packer"
        packer build -var "user=$USER" -var "home=$HOME" el7/iso_to_ami.json

    To encrypt the AMI, and copy it to all regions, get the AMI ID from the output of the packer command, then run something like this (parts you may need to change are in red): 

        Windows: 

            Run this:

            set devops_ol72_ami=ami-11111111
            set devops_centos72_ami=ami-22222222
            set iaas_ol72_ami=ami-33333333
            set iaas_centos72_ami=ami-44444444
            aws --profile devops ec2 copy-image --source-region us-west-2 --source-image-id %devops_ol72_ami% --name "Oracle Linux 7.2" --encrypted --region us-west-2
            aws --profile devops ec2 copy-image --source-region us-west-2 --source-image-id %devops_ol72_ami% --name "Oracle Linux 7.2" --encrypted --region us-east-1
            aws --profile devops ec2 copy-image --source-region us-west-2 --source-image-id %devops_centos72_ami% --name "CentOS 7.2" --encrypted --region us-west-2
            aws --profile devops ec2 copy-image --source-region us-west-2 --source-image-id %devops_centos72_ami% --name "CentOS 7.2" --encrypted --region us-east-1
            aws --profile iaas ec2 copy-image --source-region us-west-2 --source-image-id %iaas_ol72_ami% --name "Oracle Linux 7.2" --encrypted --region us-west-2
            aws --profile iaas ec2 copy-image --source-region us-west-2 --source-image-id %iaas_ol72_ami% --name "Oracle Linux 7.2" --encrypted --region us-east-1
            aws --profile iaas ec2 copy-image --source-region us-west-2 --source-image-id %iaas_centos72_ami% --name "CentOS 7.2" --encrypted --region us-west-2
            aws --profile iaas ec2 copy-image --source-region us-west-2 --source-image-id %iaas_centos72_ami% --name "CentOS 7.2" --encrypted --region us-east-1

            After all the new, encrypted images have been created and tested, delete the old, unencrypted AMIs: 

            aws --profile devops ec2 deregister-image --region us-west-2 --image-id %devops_ol72_ami%
            aws --profile devops ec2 deregister-image --region us-west-2 --image-id %devops_centos72_ami%
            aws --profile iaas ec2 deregister-image --region us-west-2 --image-id %iaas_ol72_ami%
            aws --profile iaas ec2 deregister-image --region us-west-2 --image-id %iaas_centos72_ami%
    Update the AMI IDs in //depot/techops/prodsys/aws/sparkleformation/components/base.rb
    Install  kernel-uek* on the Oracle Linux 7.2 image via Puppet?
    Delete the root password?

## For future use (this doesn't currently work) - How to build a Linux builder

This section describes some code that I created to create a Linux builder that we can all use. It would be faster than using your workstation if it worked. Unfortunately, I couldn't find any physical Linux servers to run it on - all we have is VMs. If that changes in the future, it would be nice to automate building a builder and just spin one up whenever someone wanted to create images.

Before you can create an AMI, you need an image builder. 

Log into dev server.
Go to AWS code dir.

sfn create etucker-imagebuilder --file services__imagebuilder --apply-stack Dev-NetworksInfra...

The private IP address will be displayed when SparkleFormation completes. Log into the private IP.

Run the build_a_builder.sh script: 
source build_a_builder.sh

Log into the builder again and find the VNC port: 
ss -4ln | grep -oE '59[0-9]{2}'

Log into the QEMU VM with VNC so you can watch the kickstart and catch any errors. I recommend using TightVNC Viewer.

# Encrypting Manually

This requires that you have AWS profiles configured and the aws_switch script.

```
packer build -var "home=${HOME}" -var "user=${USER}" centos72/iso_to_ova.json
read -p 'OVA file: ' ova_file

for aws_profile_acct_hash in iaas:REDACTED devops:REDACTED; do
    cut_profile=$(echo $aws_profile_acct_hash | cut -d: -f 1)
    cut_acct_number=$(echo $aws_profile_acct_hash | cut -d: -f 2)
    export AWS_REGION=us-west-2
    export AWS_PROFILE=$cut_profile
    export aws_account=$cut_acct_number
    aws s3 cp $ova_file "s3://packer-${aws_account}-${AWS_REGION}/"
    aws sts assume-role --role-arn "arn:aws:iam::${cut_acct_number}:role/vmimport" --role-session-name "Packer"
    aws ec2 import-image --description "CentOS 7.2 OVA Import" --disk-containers "Description=centos72,Format=ova,UserBucket={S3Bucket=packer-${aws_account}-${AWS_REGION},S3Key=${ova_file}}"
    # Check import status
    #aws ec2 describe-import-image-tasks --import-task-ids import-ami-ffm8jl2d
    read -p 'Centos 7.2 AMI ID: ' centos72_ami_id

    for region in us-west-2 us-east-1; do
        aws ec2 copy-image --source-region us-west-2 --source-image-id $centos72_ami_id --name "Centos 7.2" --encrypted --region $region
    done
done
```

