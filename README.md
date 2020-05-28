# RANCiD docker container #

![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/ipforpat/rancid-git) |
![Docker Pulls](https://img.shields.io/docker/pulls/ipforpat/rancid-git) |
![GitHub issues](https://img.shields.io/github/issues-raw/paddy01/rancid-git) |
![GitHub repo size](https://img.shields.io/github/repo-size/paddy01/rancid-git) |
![GitHub last commit](https://img.shields.io/github/last-commit/paddy01/rancid-git) |
![Maintenance](https://img.shields.io/maintenance/yes/2020)

## Description ##

This will actually pull the latest release from https://github.com/haussli/rancid build it and install it.
Adaptations has been done to make it easier to manage outside the docker instance but some things has to done inside the instance to make it work!

## Build/Pull ##

Build locally from a cloned git repository
```
git pull https://github.com/paddy01/rancid-git.git rancid

cd rancid

docker build \
  --build-arg UID=<current_user_id:default=1000> \
  --build-arg GID=<current_group_id:default=1000> \
  --build-arg TIMEZONE='<your_time_zone:default=UTC>' \
  -t ipforpat/rancid-git .
```
(not tested)

or from docker hub
```
docker pull ipforpat/rancid-git
```
(works but not recommended if you wish to modify uid,gid and timezone)

or Docker Compose using github as base
```
version: "3"
services:
  rancid:
    image: ipforpat/rancid-git
    build:
      context: https://github.com/paddy01/rancid-git.git
      args:
        UID: <current_user_id:default=1000>
        GID: <current_group_id:default=1000>
        TIMEZONE: '<your_time_zone:default=UTC>'
    volumes:
      - type: bind
        source: <directory_where_you_want_global_configurations>
        target: /etc/rancid
      - type: bind
        source: <directory_where_you_want_rancid_specific_configurations_and_repos>
        target: /home/rancid
```
(this is the recommended - and tested - method if you expect to modify uid, gid and/or timezone with ease)

## RUN ##

```
mkdir -p <directory_where_you_want_rancid_specific_configurations_and_repos>
mkdir -p <directory_where_you_want_global_configurations>
docker run -d --name rancid-git -v <directory_where_you_want_global_configurations>:/etc/rancid \
  -v <directory_where_you_want_rancid_specific_configurations_and_repos>:/home/rancid ipforpat/rancid-git
```
or Docker Compose simply
```
docker-compose up -d
```

## SETUP ##

This isn't very slick, please feel free to improve on this!

You'll need to add some devices which you want the configs backed up from for this app to be useful!

```
echo 'LIST_OF_GROUPS="devices"; export LIST_OF_GROUPS' >> <directory_where_you_want_global_configurations>/rancid.conf
```
Get a shell on the container:
```
docker exec -itu rancid rancid-git bash
```
or via Docker Compose
```
docker-compose exec -u rancid rancid bash
```

Whenever adding groups, run rancid-cvs which creates the required folders and
initial git repository for your device group.  This will create a
<directory_where_you_want_rancid_specific_configurations_and_repos>/var/GROUPNAME/ folder structure containing the git repository.  Do
this as the rancid user so file ownership is set correctly.

```
docker exec -itu rancid rancid-git rancid-cvs
```
with Docker Compose
```
docker-compose exec -u rancid rancid rancid-cvs
```

Add login details for your devices to the .cloginrc file
```
echo -e 'add user * USERNAME\nadd password * PASSWORD ENABLEPASS\nadd method * ssh telnet\nadd cyphertype * {aes256-cbc}\n' >> <directory_where_you_want_rancid_specific_configurations_and_repos>/.cloginrc
```
or edit .cloginrc in <directory_where_you_want_rancid_specific_configurations_and_repos>

Add devices into the list of devices to probe
```
echo device1:cisco:up >> <directory_where_you_want_rancid_specific_configurations_and_repos>/var/devices/router.db
echo device2:juniper:up >> <directory_where_you_want_rancid_specific_configurations_and_repos>/var/devices/router.db
```

Perform an initial run to check it all works!

```
docker exec -itu rancid rancid-run
```
or with Docker Compose
```
docker-compose exec -u rancid rancid rancid-run
```

Logs for any errors in <directory_where_you_want_rancid_specific_configurations_and_repos>/var/logs/devices._yyyymmdd.hhmmss_

Check config grabs have appeared into <directory_where_you_want_rancid_specific_configurations_and_repos>/var/devices/configs/_hostname_

Check cron is running as per <directory_where_you_want_global_configurations>/rancid.cron file.

## VOLUMES ##
  * /home/rancid - rancid working directory, logs and device configurations go here
  * /etc/rancid - rancid main configuration and cron file

## ISSUES ##

  * Email output of logs fails, as there's no local SMTP server on this container.
  * might want to map /etc/hosts file in so hostname to IP mappings can be stored in there

## CREDITS ##

  * This is an adaptation of the work done by biwhite
    - some texts are directly copied from biwhite's work

## LICENSE ##

  Please read the LICENSE file
