# rancid docker container #

## Description ##

This will actually pull the latest release from https://github.com/haussli/rancid build it and install it.
Adoptations has been done to make it easier to manage outside the docker instance but some things has to done inside the instance to make it work!

## Build/Pull ##

Build locally from a cloned git repository
```
docker build --build-arg UID=<current_user_id:default=1000> \
  --build-arg GID=<current_group_id:default=1000> \
  --build-arg TIMEZONE='<your_time_zone:default=UTC>' \
  -t ipforpat/rancid-git .
```

or build from docker hub

```
docker pull ipforpat/rancid-git
docker build --build-arg UID=<current_user_id:default=1000> \
  --build-arg GID=<current_group_id:default=1000> \
  --build-arg TIMEZONE='<your_time_zone:default=UTC>' \
  -t ipforpat/rancid-git \
  rancid-git
```

or docker-compose from docker hub
```
version: "3.6"
services:
  rancid:
    build:
      context: ipforpat/rancid-git
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
        target: /home/rancid/var
```

## RUN ##

```
mkdir -p <directory_where_you_want_rancid_specific_configurations_and_repos>
mkdir -p <directory_where_you_want_global_configurations>
docker run -d --name rancid-git -v <directory_where_you_want_global_configurations>:/etc/rancid \
  -v <directory_where_you_want_rancid_specific_configurations_and_repos>:/home/rancid biwhite/rancid-git
```

## SETUP ##

This isn't very slick, please feel free to improve on this!

Get a shell on the container:
```
docker exec -it rancid-git bash
```
or via docker compose
```
docker-compose exec rancid bash
```

You'll need to add some devices which you want the configs backed up from for this app to be useful!

```
echo 'LIST_OF_GROUPS="devices"; export LIST_OF_GROUPS' >> <directory_where_you_want_global_configurations>/rancid.conf
```

Whenever adding groups, run rancid-cvs which creates the required folders and
initial git repository for your device group.  This will create a
<directory_where_you_want_rancid_specific_configurations_and_repos>/GROUPNAME/ folder structure containing the git repository.  Do
this as the rancid user so file ownership is set correctly.

```
rancid-cvs
```
Add login details for your devices to the .cloginrc file
```
echo -e 'add user * USERNAME\nadd password * PASSWORD ENABLEPASS\nadd method * ssh telnet\nadd cyphertype * {aes256-cbc}\n' >> <directory_where_you_want_rancid_specific_configurations_and_repos>/.cloginrc
```

Add devices into the list of devices to probe
```
echo device1:cisco:up >> <directory_where_you_want_rancid_specific_configurations_and_repos>/devices/router.db
echo device2:juniper:up >> <directory_where_you_want_rancid_specific_configurations_and_repos>/devices/router.db
```

Perform an initial run to check it all works!

```
rancid-run
```

Logs for any errors in <directory_where_you_want_rancid_specific_configurations_and_repos>/logs/devices._yyyymmdd.hhmmss_

Check config grabs have appeared into <directory_where_you_want_rancid_specific_configurations_and_repos>/devices/configs/_hostname_

Check cron is running as per <directory_where_you_want_global_configurations>/rancid.cron file.

## VOLUMES ##
  * /home/rancid - rancid working directory, logs and device configurations go here
  * /etc/rancid - rancid main configuration and cron file

## ISSUES ##

  * Email output of logs fails, as there's no local SMTP server on this container.
  * chown on /home/rancid volume mapping changes ownership of folder on host.  Need to map this volume owned by user rancid instead of root somehow
  * might want to map /etc/hosts file in so hostname to IP mappings can be stored in there

## CREDITS ##

  * This is an adoptation of the work done by biwhite
    - some texts are directly copied from biwhite's work

## LICENSE ##

  Please read the LICENSE file
