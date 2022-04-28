# docker-liferay-portal-ce 

# [Docker Hub Repository](https://hub.docker.com/r/ibaiborodine/liferay-portal-ce)

### [Release Image Manual](/readme/release-image-manual.md)

# Supported tags and respective `Dockerfile` links

-  [`7.4.3.22-ga22-jdk11-bullseye` (*7.4.3.22-ga22/jdk11-bullseye/Dockerfile*)](https://github.com/igor-baiborodine/docker-liferay-portal-ce/blob/1fa60585d19a3d415bd959832350a50abef82f5c/7.4.3.22-ga22/jdk11-bullseye/Dockerfile)
-  [`7.4.3.22-ga22-jdk8-bullseye` (*7.4.3.22-ga22/jdk8-bullseye/Dockerfile*)](https://github.com/igor-baiborodine/docker-liferay-portal-ce/blob/9b633859f81c0c71ed0b7c5adb2eeb0aab6d6511/7.4.3.22-ga22/jdk8-bullseye/Dockerfile)
-  [`7.4.3.22-ga22-jdk8-alpine` (*7.4.3.22-ga22/jdk8-alpine/Dockerfile*)](https://github.com/igor-baiborodine/docker-liferay-portal-ce/blob/e20b96c0e840ccfad6420ad6d2d79ab5c06f787f/7.4.3.22-ga22/jdk8-alpine/Dockerfile)

`Dockerfile` links for previously supported tags can be found [here](https://github.com/igor-baiborodine/docker-liferay-portal-ce/blob/master/readme/previously-supported-tags.md).

# Quick reference

-	**Where to get help**:  
	[the Liferay Community Forums](https://liferay.dev/forums/-/message_boards/category/243728), [the Docker Community Forums](https://forums.docker.com/), [the Docker Community Slack](https://blog.docker.com/2016/11/introducing-docker-community-directory-docker-community-slack/), or [Stack Overflow](https://stackoverflow.com/search?tab=newest&q=docker)

-	**Where to file issues**:  
	[https://github.com/igor-baiborodine/docker-liferay-portal-ce/issues](https://github.com/igor-baiborodine/docker-liferay-portal-ce/issues)

-	**Maintained by**:  
	[Igor Baiborodine](https://github.com/igor-baiborodine)

-	**Supported architectures**: ([more info](https://github.com/docker-library/official-images#architectures-other-than-amd64))  
	amd64

-	**Source of this description**:  
	[repo's `readme/` directory](https://github.com/igor-baiborodine/docker-liferay-portal-ce/tree/master/readme)

-	**Supported Docker versions**:  
	[the latest release](https://github.com/docker/docker-ce/releases/latest) (down to 1.6 on a best-effort basis)

# What is Liferay Portal?

**Liferay Portal** is an open-source portal framework for building web applications, websites, and portals. It also offers an integrated CMS and may serve as an enterprise integration platform.  

[https://www.liferay.com/downloads-community](https://www.liferay.com/downloads-community)

![logo](https://github.com/igor-baiborodine/docker-liferay-portal-ce/blob/master/readme/logo.png?raw=true)
 
Logo &copy; Liferay, Inc.

# How to use this image

## Start a `liferay-portal` instance

```console
$ docker run --name <container name> -d ibaiborodine/liferay-portal-ce:<tag>
```

... where `<container name>` is the name you want to assign to your container and `<tag>` is the tag specifying the Liferay Portal CE version you want. See the list above for relevant tags.

The default Liferay Portal configuration contains embedded Hypersonic database and Elasticsearch instances. Please note that this setup is not suitable for production.

You can test it at `http://container-ip:8080` in a browser. To get the container IP address, execute the following command:
```console
$ docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container name>
```
... or via the host machine on port 80:
```console
$ docker run --name <container name> -p 80:8080 -d ibaiborodine/liferay-portal-ce:<tag>
```
Then test it at `http://localhost:80` or `http://host-ip:80` in a browser.

If you want to start a `liferay-instance` in debug mode, execute the following:
```console
$ docker run --name <container name> -d ibaiborodine/liferay-portal-ce:<tag> catalina.sh jpda run
```

## ... via [`docker-compose`](https://github.com/docker/compose)

Example `docker-compose.yml` for `liferay-portal`:

```yaml
version: '3.7'

services:
  liferay:
    image: ibaiborodine/liferay-portal-ce
    environment:
      LIFERAY_SETUP_PERIOD_WIZARD_PERIOD_ENABLED: "false"
      LIFERAY_TERMS_PERIOD_OF_PERIOD_USE_PERIOD_REQUIRED: "false"
      LIFERAY_USERS_PERIOD_REMINDER_PERIOD_QUERIES_PERIOD_ENABLED: "false"
      LIFERAY_USERS_PERIOD_REMINDER_PERIOD_QUERIES_PERIOD_CUSTOM_PERIOD_QUESTION_PERIOD_ENABLED: "false"
    ports:
      - "80:8080"
```

Run `docker-compose -f docker-compose.yml up`, wait for it to initialize completely, and visit at `http://localhost:80` or `http://host-ip:80` (as appropriate).

Additional `docker-compose` examples: [Liferay/MySQL](https://github.com/igor-baiborodine/docker-liferay-portal-ce/blob/master/compose/liferay-mysql/docker-compose.yml), [Liferay/MySQL/ElasticSearch](https://github.com/igor-baiborodine/docker-liferay-portal-ce/blob/master/compose/liferay-mysql-elasticsearch/docker-compose.yml)

## Check the Tomcat version information
```console
$ docker run --rm -it ibaiborodine/liferay-portal-ce:<tag> version.sh | grep 'Server version' 
``` 

## Container shell access and viewing Liferay Portal logs
The `docker exec` command allows you to run commands inside a Docker container. The following command will give you a bash shell inside your `liferay-portal` container:
```console
$ docker exec -it <container name> bash
```

The Liferay Portal log is available via the `docker logs` command:
```console
$ docker logs -f <container name>
```

## Configure Liferay Portal via environment variables
You can override [portal.properties](https://github.com/liferay/liferay-portal/blob/master/portal-impl/src/portal.properties) by specifying corresponding environment variables, for example:
```properties
#
# Set this property to true if the Setup Wizard should be displayed the
# first time the portal is started.
#
# Env: LIFERAY_SETUP_PERIOD_WIZARD_PERIOD_ENABLED
#
setup.wizard.enabled=true
```
To override the `setup.wizard.enabled` property, set the `LIFERAY_SETUP_PERIOD_WIZARD_PERIOD_ENABLED` environment variable to `false` when running a new container: 
```console
$ docker run --name <container name> -p 80:8080 -it \ 
    --env LIFERAY_SETUP_PERIOD_WIZARD_PERIOD_ENABLED=false ibaiborodine/liferay-portal-ce:<tag>
```
Also, the environment variables can be set via the `docker-compose.yml` (see example above) or by extending this image (see example below). 

## Health check
This image does not contain an explicit health check. To add a health check, you can run your `liferay-portal` instance with the `--health-*` options:
```console
$ docker run --name <container name> -d \ 
    --health-cmd='curl -fsS "http://localhost:8080/c/portal/layout" || exit 1' \
    --health-start-period=1m \
    --health-interval=1m \
    --health-retries=3 \
    ibaiborodine/liferay-portal-ce:<tag> 
```
... or by extending this image. For a more detailed explanation about why this image does not come with a default `HEALTHCHECK` defined, and for suggestions on how to implement your own health/liveness/readiness checks, read [here](https://github.com/docker-library/faq#healthcheck).

## Deploy modules to a running `liferay-portal` instance
This image exposes an optional `VOLUME` to allow deploying modules to a running container. To enable this option, you will need to:
1.	Create a deploy directory on a suitable volume on your host system, e.g. `/my/own/deploydir`.
2.	Start your `liferay-portal` instance like this:
```console
$ docker run --name <container name> -v /my/own/deploydir:/opt/liferay/deploy -d ibaiborodine/liferay-portal-ce:<tag>
```
The `-v /my/own/deploydir:/opt/liferay/deploy` part of the command mounts the `/my/own/deploydir` directory from the underlying host system as `/opt/liferay/deploy` inside the container to scan for layout templates, portlets, and themes to auto-deploy.

## Where to store documents and media files
By default, Liferay Portal uses a document library store option called `Simple File Store` to store documents and media files on a file system (local or mounted). The store's default root folder is `LIFERAY_HOME/data/document_library`.
There are several ways to store data used by applications that run in Docker containers. One of the options is to create a data directory on the host system (outside the container) and mount this to a directory visible from inside the container. This places the document and media files in a known location on the host system and makes it easy for tools and applications on the host system to access the files. The downside is that the user needs to make sure that the directory exists and that directory permissions and other security mechanisms on the host system are set up correctly.

You will need to:
1.	Create a data directory on a suitable volume on your host system, e.g. `/my/own/liferaydatadir`.
2.	Start your `liferay-portal` instance like this:
```console
$ docker run --name <container name> -v /my/own/liferaydatadir:/opt/liferay/data/document_library -d ibaiborodine/liferay-portal-ce:<tag>
```
The `-v /my/own/liferaydatadir:/opt/liferay/data/document_library` part of the command mounts the `/my/own/liferaydatadir` directory from the underlying host system as `/opt/liferay/data/document_library` inside the container, where Liferay Portal by default will store its documents and media files.

### Caveat
Do not use the default in-memory database(H2) when storing document and media files on the host system. You should configure your `liferay-portal` instance to use an external data source, e.g. MySQL.  

# How to Extend This Image

## Environment variables
If you would like to override the default configuration, i.e. portal properties, you can do that by specifying corresponding environment variables in an image derived from this one:
```dockerfile
FROM ibaiborodine/liferay-portal-ce:<tag>

ENV LIFERAY_SETUP_PERIOD_WIZARD_PERIOD_ENABLED false
ENV LIFERAY_TERMS_PERIOD_OF_PERIOD_USE_PERIOD_REQUIRED false
ENV LIFERAY_USERS_PERIOD_REMINDER_PERIOD_QUERIES_PERIOD_ENABLED false
ENV LIFERAY_USERS_PERIOD_REMINDER_PERIOD_QUERIES_PERIOD_CUSTOM_PERIOD_QUESTION_PERIOD_ENABLED false
```

## Add new files or override existing ones
With another optional `VOLUME` you will be able to customize your `liferay-portal` instance. This volume is defined by `LIFERAY_BASE` environment variable which is set to `/etc/opt/liferay`.

You will need to:
1.	Create a directory on a suitable volume on your host system, e.g. `/my/own/liferaybasedir`.
2.	Start your `liferay-portal` instance like this:
```console
$ docker run --name <container name> -v /my/own/liferaybasedir:/etc/opt/liferay -d ibaiborodine/liferay-portal-ce:<tag>
```
The `-v /my/own/liferaybasedir:/etc/opt/liferay` part of the command mounts the `/my/own/liferaybasedir` directory from the underlying host system as `/etc/opt/liferay` inside the container.

All files and sub-directories with its content placed into the `/my/own/liferaybasedir` will be copied to the `LIFERAY_HOME` directory when the container starts. 

For example:
1. If you need to add `portal-ext.properties` to your `liferay-portal` instance, place the portal-ext.properties file into the `/my/own/liferaybasedir` directory. 
2. If you need to override `setenv.sh` in your `liferay-portal` instance, place the setenv.sh file into the `/my/own/liferaybasedir/tomcat/bin` directory.

## Execute custom shell scripts
To execute shell scripts before Liferay Portal starts, you can use an optional volume `VOLUME` that mapped to container's `/docker-entrypoint-initliferay.d` directory.

You will need to:
1.	Create a directory on a suitable volume on your host system, e.g. `/my/own/liferayinitdir`.
2.	Start your `liferay-portal` instance like this:
```console
$ docker run --name <container name> -v /my/own/liferayinitdir:/docker-entrypoint-initliferay.d -d ibaiborodine/liferay-portal-ce:<tag>
```
The `-v /my/own/liferayinitdir:/docker-entrypoint-initliferay.d` part of the command mounts the `/my/own/liferayinitdir` directory from the underlying host system as `/docker-entrypoint-initliferay.d` inside the container.

All shell scripts placed into the `/my/own/liferayinitdir` directory will be executed before Liferay Portal starts.

# Image Variants

## `ibaiborodine/liferay-portal-ce:<version>-<jdk>-buster`

This is the defacto image which is based on [Debian Linux](https://www.debian.org/), currently `Buster` release. If you are unsure about what your needs are, you probably want to use this one. It is designed to be used both as a throw away container (mount your source code and start the container to start your app), as well as the base to build other images off of.

## `ibaiborodine/liferay-portal-ce:<version>-<jdk>-alpine`

This image is based on the popular [Alpine Linux project](http://alpinelinux.org), available in [the `alpine` official image](https://hub.docker.com/_/alpine). Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

This variant is highly recommended when final image size being as small as possible is desired. The main caveat to note is that it does use [musl libc](http://www.musl-libc.org) instead of [glibc and friends](http://www.etalabs.net/compare_libcs.html), so certain software might run into issues depending on the depth of their libc requirements. However, most software doesn't have an issue with this, so this variant is usually a very safe choice. See [this Hacker News comment thread](https://news.ycombinator.com/item?id=10782897) for more discussion of the issues that might arise and some pro/con comparisons of using Alpine-based images.

# License

**This library, Liferay Portal Community Edition, is free software ("Licensed Software"); you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.**

**This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; including but not limited to, the implied warranty of MERCHANTABILITY, NONINFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.**

**You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to:**
```text
Free Software Foundation, Inc. 51 Franklin Street, Fifth Floor Boston, MA 02110-1301 USA
```

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
