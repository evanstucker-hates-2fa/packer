# packer

## Overview

In this talk, I'll share my experiences with Packer. First, I'll go over the initial questions of "what is Packer and why do we need it?", then I'll briefly go over the various components and how to cram them into a template. Then I'll entertain and delight you with my initial attempts to get it work, architectural mistakes, and finally, an example of a working Packer configuration that can take you from ISO images to Amazon Machine Images.

I've got about 30 minutes, but be warned: I am still new to Packer, so this may be a bit like the blind leading the blind...

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

## How often do you update your servers?



## Are the images really identical?

Not really, but they're as close as you can get right now. AWS images will need to have cloud-init installed, vSphere images will need VMWare Tools, and VirtualBox images will need VirtualBox Guest Additions. But they're more similar than using community images on all of those platforms.

## Why shouldn't I just use community images?

Community images are fine, just like "curl | sudo bash" is fine. They get the job done quickly and easily. However, if you work for a company that isn't 










