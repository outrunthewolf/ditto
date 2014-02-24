ditto
=====

ditto is Rsync for deployment.

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
    
    ``` sh
    staging_user=human
    staging_address=192.168.1.1
    staging_port=22
    production_user=git
    production_address=192.168.1.1
    production_port=22
    ```

You can add as many environments as you like and they will be available to ditto. You can then sync environments with push and pull.

    ``` sh
    $ ditto pull staging # Rsync your staging files against your local files
    $ ditto push production # Rsync your local files against your production files
    ```

To see a full list of commands run

    ``` sh
    $ ditto help
    ```

Important Notes
--------------------

Remember to add ditto config files to your gitignore or you could end up exposing private information.

To-Do
--------------------
- Incorporate more than staging and production in config
- Support custom directories in a config
