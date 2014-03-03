ditto
=====

Ditto is Rsync for deployment.

Sometimes you dont want to worry about running git, composer or other commands on your production servers. Ditto uses rsync to duplicate applications quickly and easily across many environments.

### Dependencies & Support
Ditto has been tested and runs in the following shells:

- zsh
- bash
- fish

If you run any other shell environments and ditto runs fine in those, please help me keep these updated.

Installation
--------------------

1. Clone

``` sh
$ git clone https://github.com/outrunthewolf/ditto.git
```

2. Make ditto executable and global

``` sh
$ chmod +x ditto.sh
$ mv ditto.sh /usr/local/bin/ditto
```

Usage
--------------------

Ditto requires a configuration file for the various environments you'd like to keep in sync. Your configuration file will be in the root directory, the same place as your git files are stored.

### Config file example
```sh
staging_user=human
staging_address=192.168.1.1
staging_port=22
production_user=git
production_address=192.168.1.1
production_port=22
safety_mode=true
remote_directory=/home/user/app
```

You can add as many environments as you like and they will be available to ditto. You can then sync environments with push and pull.

``` sh
$ ditto pull staging # Rsync your staging files against your local files
$ ditto push production # Rsync your local files against your production files
```

### Remote directories
The remote directory for ditto to push to defaults to your current directory. You can override this in the config file

``` sh
remote_directory=/home/use/app
```

### Safety Mode
Ditto contains a safety mode on push and pull, the safety mode is enabled by default but you can override it by specifying the following in the config file

``` sh
safety_mode=false
```

### Help
To see a full list of commands run

``` sh
$ ditto help
```

Important Notes
--------------------

Remember to add ditto and any config files to your gitignore or you could end up exposing private information.
