# Introduction

Dockerfile to build a Java EE Container Manager Docker image.

# Hardware Requirements

## Memory

- **1GB** is the **standard** memory size. You should up that for production according to your needs.

# How to get the image

You can either download the image from a docker registry or build it yourself.

## Building the Image

* [Download JBoss EAP](http://www.jboss.org/products/eap/download/)
* Put the file in the local `install_files` directory
* Update the VERSION file
* [Download JBoss A-MQ](http://www.jboss.org/products/amq/download/) to a temporary directory
* Unzip the downloaded file
* navigate to `extras` directory for the ActiveMQ bundle
* Unzip the file in this location
* navigate this unzipped file to the `lib/optional` directory
* copy `activemq-rar-*.rar` file to the local `install_files`
* run `build.sh`
* 
These builds are not performed by the **Docker Trusted Build** service because it contains JBoss proprietary code, but this method can be used if using a [Private Docker Registry](https://docs.docker.com/registry/deploying/).

```bash
docker pull jlgrock/jboss-eap:$VERSION
```

## Building Custom Versions

This script will build the core version of the EAP instance, storing the image to `jlgrock/jboss-eap`. If you drop extra WARs into the install directory, you can create a custom deployment. It is suggested that you don't use the build script though, as you'll want to store this image to something other than `jlgrock/jboss-eap`. For example, you can put webapp.war in there and create an instance called `my/webapp` with the command `docker build -q --rm -t my/webapp:$WEBAPP_VERSION`.  Currently, this will only work for the standalone version.

# Available Configuration Parameters

*Please refer the docker run command options for the `--env-file` flag where you can specify all required environment variables in a single file. This will save you from writing a potentially long docker run command.*

Below is the complete list of available options that can be used to customize your installation.

- **MODE**: You can either run in `STANDARD` mode (single server), `DOMAIN_MASTER` (clustered - is required for any slaves to be started), or `DOMAIN_SLAVE` (clustered - needs to be linked to the DOMAIN_MASTER).  The default is `STANDARD`.
- **EAP_USERNAME**: The username for accessing the admin console.  By default this is `admin`.
- **EAP_PASSWORD**: The username for accessing the admin console.  By default this is `admin123!`.
- **MESSAGE_QUEUE**: The message queue to use.  By default, EAP current uses HornetQ, which is specified by `HORNETQ`.  If this is set to `ACTIVE_MQ`, this will instead use the connector for ActiveMQ/A-MQ.  This will be paired with whatever A-MQ connector that is provided at the time of building.
- **MQ_HOST**: The hostname of ActiveMQ server. The default is `localhost`.
- **MQ_PORT**: The hostname of ActiveMQ server. The default is `61616`.
- **MQ_USER_LOGIN**: The login to access the Message Queue.  If needed, the Default is set to `admin`.
- **MQ_USER_PASSWORD**: The password for Message Queue. If needed, the default is `admin`.
- **MIN_SERVER_GROUP_HEAP**: The minimum amount of memory to use for the server group. In standalone mode, this is unused.  By default for a domain instance, this is `1000m`.
- **MAX_SERVER_GROUP_HEAP**: The maximum amount of memory to use for the server group. In standalone mode, this is unused.  By default for a domain instance, this is `1000m`.
- **MIN_INSTANCE_HEAP**: The minimum amount of memory to use for the instance. By default for a domain instance, this is `1303m`.
- **MAX_INSTANCE_HEAP**: The maximum amount of memory to use for the instance. By default for a domain instance, this is `1303m`.

# Examples of Running a Container

Starting a Standalone EAP instance
```bash
docker run -it --rm -P jlgrock/jboss-eap:6.4.0
```

Starting a Master in a Clustered environment
```bash
docker run -it --rm -P -e MODE=DOMAIN_MASTER --name eap_master jlgrock/jboss-eap:6.4.0
```

Adding a Slave in a Clustered environment
```bash
docker run -it --rm -e MODE=DOMAIN_SLAVE --link eap_master:MASTER jlgrock/jboss-eap:6.4.0
```

Starting a Master in a Clustered environment with an A-MQ connector
```bash
docker run -it --rm -P -p 9990:9990 -e MODE=DOMAIN_MASTER -e MESSAGE_QUEUE=ACTIVE_MQ --name eap_master jlgrock/jboss-eap:6.4.0
```

Adding a Slave in a Clustered environment with an A-MQ connector
```bash
docker run -it --rm -e MODE=DOMAIN_SLAVE -e MESSAGE_QUEUE=ACTIVE_MQ --link eap_master:MASTER jlgrock/jboss-eap:6.4.0
```
