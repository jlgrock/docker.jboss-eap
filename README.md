# Introduction

Dockerfile to build a Java EE Container Manager Docker image.

# Hardware Requirements

## Memory

- **1GB** is the **standard** memory size. You should up that for production according to your needs.

# How to get the image

## Option 1: Download from a Docker Registry

These builds are not performed by the **Docker Trusted Build** service because it contains proprietary code, but this 
method can be used if using a Private Docker Registry.

```bash
docker pull <private_registry_name>/jlgrock/jboss-eap:$VERSION
```

## Option 2: Building the Image

* [Download JBoss EAP 7.2.0](http://www.jboss.org/products/eap/download/)
* Put the file in the local `eap-files/install_files` directory
* Update the VERSION file
* run `build.sh`

## Building Custom Versions

This script will build the core version of the EAP instance, storing the image to `jlgrock/jboss-eap`. If you drop 
extra WARs into the install directory, you can create a custom deployment. It is suggested that you don't use the 
build script though, as you'll want to store this image to something other than `jlgrock/jboss-eap`. For example, you 
can put webapp.war in there and create an instance called `my/webapp` with the command 
`docker build -q --rm -t my/webapp:$WEBAPP_VERSION`.  Currently, this will only work for the standalone version.  If 
you want to deploy to an clustered environment, you must deploy this manually after restart.

# Available Configuration Parameters

*Please refer the docker run command options for the `--env-file` flag where you can specify all required environment 
variables in a single file. This will save you from writing a potentially long docker run command.*

Below is the complete list of available options that can be used to customize your installation.

- **MODE**: You can either run in `STANDALONE` mode (single server), `DOMAIN_MASTER` (clustered - is required for any 
slaves to be started), or `DOMAIN_SLAVE` (clustered - needs to be linked to the DOMAIN_MASTER).  The default is `STANDARD`.

- **EAP_USERNAME**: The username for accessing the admin console.  By default this is `admin`.  Note that users can be 
changed/added, but currently this doesn't allow for removal without destroying the container.
- **EAP_PASSWORD**: The username for accessing the admin console.  By default this is `admin123!`.  Note that users can 
be changed/added, but currently this doesn't allow for removal without destroying the container.

- **MESSAGE_QUEUE**: Defines which (external) message queue system to connect to. `NONE` and `ARTEMIS`. By default, 
this is `NONE`.  Please note that local artemis is running, but not configured.  You'll need to override the properties 
if you want to use this.
- **MQ_HOST**: The hostname of message queue server. The default is `localhost`.  This should likely either be 
populated using a link (using `--link`) or defining a custom network.  If you don't use a link, you should likely change 
this as Docker doesn't port map to localhost unless you are on Linux.
- **MQ_PORT**: The port exposed by Artemis MQ.  The default is `61616`.
- **MQ_USER_LOGIN**: The login to access the Message Queue.  By default, this is `admin`
- **MQ_USER_PASSWORD**: The password for Message Queue.  By default, this is `admin123!`
- **QUEUES**: A comma-delimited array of Queues or Topics that will be added to the container definition.  JNDI 
resources will be accessible at location of `java:/queue/{QUEUE_NAME}` and the pool name of `{QUEUE_NAME}` (where
"{QUEUE_NAME}" is the name provided in your array of Queues/Topics).  e.g the list `ABC,DEF` will provide the JNDI 
resources `java:/queue/ABC` in the pool `ABC` and `java:/queue/DEF` in the pool `DEF`.

- **DB**: The type of database to attach to the EAP container.  Possible values are `NONE`, `H2`, `POSTGRESQL`, `MYSQL`.  By default, this is `NONE`.  *This still needs to be implemented*
- **DB_HOST**: The hostname of the database to connect to.
- **DB_PORT**: The port of the database to connect to.
- **DB_USERNAME**: The default is `admin`.
- **DB_PASSWORD**: The default is `admin123!`.

- **MIN_SERVER_GROUP_HEAP**: The minimum amount of memory to use for the server group. In standalone mode, this is 
unused.  By default for a domain instance, this is `1000m`.
- **MAX_SERVER_GROUP_HEAP**: The maximum amount of memory to use for the server group. In standalone mode, this is 
unused.  By default for a domain instance, this is `1000m`.
- **MIN_INSTANCE_HEAP**: The minimum amount of memory to use for the instance. By default for a domain instance, 
this is `1303m`.
- **MAX_INSTANCE_HEAP**: The maximum amount of memory to use for the instance. By default for a domain instance, 
this is `1303m`.

- **SSL**: Whether or not to use SSL.  Possible values are `TRUE` and `FALSE`.  By default, this is `FALSE`.
- **KEYSTORE_PASSWORD**: The password used for the Keystore.  Required if `SSL=TRUE`.
- **TRUSTSTORE_PASSWORD**:  The password used for the Truststore.  Required if `SSL=FALSE`.

- **OPTIONS**: The additional options, which are usually defined with `-D<property>=value` format

# Examples of Running a Container

Starting a Standalone EAP instance
```bash
docker run -it --rm -p 9990:9990 jlgrock/jboss-eap:${VERSION}
```

If the entry point needs to be overridden for debugging and other purposes, the following can be used: 
```bash
docker run -it --entrypoint /bin/bash -p 9990:9990 jlgrock/jboss-eap:${VERSION}
```

Starting a Master in a Clustered environment
```bash
docker run -it --rm -p 9990:9990 -e MODE=DOMAIN_MASTER --name eap_master jlgrock/jboss-eap:${VERSION}
```

Adding a Slave in a Clustered environment
```bash
docker run -it --rm -e MODE=DOMAIN_SLAVE --link eap_master:MASTER jlgrock/jboss-eap:${VERSION}
```

Starting a Master in a Clustered environment with an A-MQ connector)
```bash
docker run -it --rm -p 9990:9990 -e MODE=DOMAIN_MASTER -e MESSAGE_QUEUE=ACTIVE_MQ -e MQ_HOST=myhost.bla.com --name eap_master jlgrock/jboss-eap:${VERSION}
```

Adding a Slave in a Clustered environment with an A-MQ connector (linked to master server, activemq server specified)
```bash
docker run -it --rm -e MODE=DOMAIN_SLAVE -e MESSAGE_QUEUE=ARTEMIS -e MQ_HOST=myhost.bla.com --link eap_master:MASTER jlgrock/jboss-eap:${VERSION}
```

Adding a Slave in a Clustered environment with an A-MQ connector (linked to master server and linked to activemq)
```bash
docker run -it --rm -e MODE=DOMAIN_SLAVE -e MESSAGE_QUEUE=ACTIVE_MQ --link eap_master:MASTER --link amq:AMQ jlgrock/jboss-eap:${VERSION}
```
