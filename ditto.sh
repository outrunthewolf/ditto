#!/bin/bash

# Store some contant data
logo="
  _ __ ___ _   _ _ __   ___
 | '__/ __| | | | '_ \ / __|
 | |  \__ \ |_| | | | | (__
 |_|  |___/\__, |_| |_|\___|
           |___/
"
version="1.0.0"
usage="
\e[93m Usage:\e[39m \n
	[options] command
"
options="
\e[93m Options:\e[39m \n
"
commands="
\e[93mCommands:\e[39m \n
	\e[32m sync\e[39m \t Sync all data in the directory \n
	\e[32m test\e[39m \t Get a break down of any changes that might occur, dry-run \n
	\e[32m debug\e[39m\t Show some helpful things like config data, directory etc...
"

# Get some variables
action="$1"
environment="$2"
current_dir=${PWD}
remote_dir="/home/chris/"
remote_dir_key=${PWD##*/}
config_file="ditto.config"
safety_mode=false

# pull function - to pull all files from live
sync () {
	env=$1

	# Check we have an environment
	if [[ -z $env ]]; then
		echo -e " \e[30;48;5;9m You must specify an environment from the config \e[0m"
		exit 1
	fi

	# Double check we want to do this in safety mode
	if [[ "$safety_mode" = true ]]; then
		echo "You definately want to sync the" $environment "environment and local files?"
		select yn in "y" "n"; do
		    case $yn in
		        n ) return;;
		        n ) exit;;
		    esac
		done
	fi

	# run the rsync command
	rsync -arvz -e 'ssh -p '$staging_port $current_dir $staging_user@$staging_address:$remote_dir --progress --exclude '.git' --exclude 'ditto.*'
	exit 1
}

# advise function - run a dry run
test () {
	env=$1

	# Check we have an environment
	if [[ -z $env ]]; then
		echo -e " \e[30;48;5;9m You must specify an environment from the config \e[0m"
		exit 1
	fi

	rsync -arvz -e 'ssh -p '$staging_port -h --stats $current_dir $staging_user@$staging_address:$remote_dir_key --progress --exclude '.git' --exclude 'ditto.*' --dry-run
	exit 1
}

# Debug
debug () {
	echo -e "\n\e[32m Version:\e[39m" $version
	echo -e "\e[32m Your current directory:\e[39m" $current_dir
	echo -e "\e[32m The remote directory:\e[39m" $remote_dir$remote_dir_key
	echo -e ""
	echo -e "\e[32m Staging point:\e[39m" $staging_user"@"$staging_address":"$staging_port
	echo -e "\e[32m Production point:\e[39m" $production_user"@"$production_address":"$production_port
	echo -e "\n"
	exit 1
}

# Load config variables into the script
load_config () {
	key=$1
	value=$2

	case "$key" in
		"staging_address")
		    staging_address=$value
		    ;;
		"staging_user")
			staging_user=$value
			;;
		"staging_port")
			staging_port=$value
			;;
		*)
		    return
		    ;;
	esac
}

# Check config file and parse
check_config () {
	if [ ! -f $current_dir"/"$config_file ]
	then
	    echo -e " \e[30;48;5;9m I can't find a config file in $current_dir \e[0m"
	    exit 1
	fi

	# Read the config file and get some variables
	i=0
	while read line; do
	  if [[ "$line" =~ ^[^#]*= ]]; then
	    key[i]=${line%%=*}
	    value[i]=${line##*=}
	    load_config ${key[i]} ${value[i]}
	    ((i++))
	  fi
	done < $current_dir"/"$config_file
}

# Fallback for missed commands
help () {
	echo -e "\e[34m$logo\e[39m"
	echo -e "\e[93m Version\e[39m" $version "\n"
	echo -e $usage "\n"
	#echo -e $options "\n"
	echo -e $commands "\n"
	exit 1
}

# Check the config file exists
check_config

# Run commands from action
case "$1" in
"sync")
    sync $environment
    ;;
"test")
	test $environment
	;;
"debug")
	debug
	;;
"help")
	help
	;;
*)
    help
    ;;
esac
