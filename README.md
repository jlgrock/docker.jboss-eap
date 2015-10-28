# Introduction

Dockerfile to build a Java EE Container Manager Docker image.

# Hardware Requirements

## Memory

- **1GB** is the **standard** memory size. You should up that for production according to your needs.

## Storage

- Mostly, ActiveMQ stores things in memory, so no space is needed.  Should you start to persist to disk, consider attaching a data volume.

# How to Build a new Version

* Download JBoss A-MQ from http://www.jboss.org/products/amq/download/
* Put the file in the "install_files" directory
* Update the VERSION file
* run `build.sh`

# Installation

Pull the image from the docker index. This is the recommended method of installation as it is easier to update image. These builds are performed by the **Docker Trusted Build** service.

```bash
docker pull jlgrock/jboss-eap:$VERSION
```

# Building Custom Versions

This script will build the core version of the EAP instance, storing the image to `jlgrock/jboss-eap`. If you drop extra WARs into the install directory, you can create a custom deployment. It is suggested that you don't use this script though, as you'll want to store this image to something other than `jlgrock/jboss-eap`. For example, you can put webapp.war in there and create an instance called `my/webapp`.


