<?php

class Ditto {
	# Store some contant data
	protected $logo="
                                                                                                                                                                 
                                                                                      
	";
	protected $version="1.0.0";
	protected $usage=" \e[93m Usage:\e[39m \n [options] command";
	protected $options="\e[93m Options:\e[39m \n";
	protected $commands="\e[93mCommands:\e[39m \n
		\e[32m sync\e[39m \t Sync all data in the directory \n
		\e[32m test\e[39m \t Get a break down of any changes that might occur, dry-run \n
		\e[32m debug\e[39m\t Show some helpful things like config data, directory etc...";

	# Get some variables
	$action="$1"
	environment="$2"
	current_dir=${PWD}
	remote_dir="/home/chris/"
	remote_dir_key=${PWD##*/}
	config_file="ditto.config"
	safety_mode=false
}


?>