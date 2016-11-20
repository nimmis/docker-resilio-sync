BitTorrent Sync using Resilio Sync
==================================

This is a small container [![](https://images.microbadger.com/badges/image/nimmis/resilio-sync.svg)](https://microbadger.com/images/nimmis/resilio-sync "Get your own image badge on microbadger.com") using Resilio Sync client to syncronize data between clients.

Sync skips the cloud and finds the shortest path between devices when transferring data. No Cloud. No uploading to third party servers. Just fast, simple file syncing.

Based on my alpine micro container with glibc [![](https://images.microbadger.com/badges/image/nimmis/alpine-glibc.svg)](https://microbadger.com/images/nimmis/alpine-glibc "Get your own image badge on microbadger.com") please visit [nimmis/alpine-glibc](https://registry.hub.docker.com/u/nimmis/alpine-glibc/) for more information.

This container can run in two different mode:

* web gui mode, all configuration done thru a web interface
* sync mode, sync predefined directory with secret key supplied or generated

# Global settings

These setting applies to both web gui and sync mode

### RSLSYNC_NAME

This variable defines the name shown on other nodes, if not defined it will get the name shown with the command *hostname*

This will start a container with then name **database**

	docker run -d -e RSLSYNC_NAME=database -p 33333:33333 nimmis/resilio-sync
	
### syncing local files

Inside the container the /data is the default sync directory, to link this to a local file system you can use the **-v** flag

To sync the the directory /home/joe you can run

	 docker run -d -v /home/joe:/data -p 33333:33333 nimmis/resilio-sync
	 	
# web gui mode

This setting activates a web gui to configure the Resilio Sync client

### RSLSYNC_USER

This variable defines the username used to login to the web interface. 

**Setting this variable activates the web gui mode.**

### RSLSYNC_PASS

This variable defines the password used to login to the web interface. If this variable is not defined or empty an random password will be generated. The password can be retrieved from the log.

	docker run -d -e RSLSYNC_USER=joe --name sync -p 8888:8888 -p 33333:33333 nimmis/resilio-sync
	docker logs sync
	Run scripts in /etc/run_once
	WEBUI mode activated
	RSLSYNC_PASS not set, password generated, use M2FlMjNkOG as password

In this case you should login with user **joe** and password **M2FlMjNkOG**

# Sync mode

The sync mode version is made for syncing one directory only (you can manualy configure multiple directories), each directory (or sync point) need a uniq secret key. If you need several different directories synced, start a container for each directory

### RSLSYNC_SECRET

This variable contains the secret key fore this directory, if empty or missing a new secret key is generated. This key can then be used to start more sync klient for the data.

### Run container on first sync node

The first nod creates a uniq secret used to sync all nodes, map the directory you wan't to be syncronized to /data in the container.

Example synk the directory /home/me/data on first nod giving it the name syncnode

	docker run -d -v /home/me/data:/data --name sync -p 33333:33333 nimmis/resilio-sync


to see the secret code to use on the other nodes, look at the log-output from the container

	> docker logs -f sync
	Run scripts in /etc/run_once
	non-WEBUI mode activated, /data is synced
	add -e RSLSYNC_SECRET=AF2INNKYP672IGIIDTDWWVUBGP2AQRFKX to your other nodes to sync
	Run scripts is /etc/run_always
	Started runsvdir, PID is 14
	wait for processes to start....
	rsyslogd: imklog: cannot open kernel log (/proc/kmsg): Operation not permitted.
	rsyslogd: activation of module imklog.so failed [v8.18.0 try http://www.rsyslog.com/e/2145 ]
	run: rslsync: (pid 19) 5s
	run: crond: (pid 20) 5s
	run: rsyslogd: (pid 21) 5s

press CTRL-C to exit log

## run container on more sync nodes

To get the other nodes to sync with the first, they have to have the same secret key. 
You add the key with -e RSLSYNC_SECRET=<secret key>, start with the secret code created 
by the first sync container. The local director does not have to be the same as on the 
first container but all sub-folders will be the same. So starting a second sync container
on another docker machine using local directory /home/you/sync-backup and using the secret
key obtained from the first sync node example above 

	docker run -d -v /home/you/sync-backup:/data --name syncnode2 -P 33333:33333 -e RSLSYNC_SECRET=AF2INNKYP672IGIIDTDWWVUBGP2AQRFKX nimmis/resilio-sync

NOTE!!!!! DO NOT USE the secret key in this example, use the one you got from the first sync node run.

