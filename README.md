# packer

## Overview

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










