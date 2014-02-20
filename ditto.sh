#!/bin/bash

# Super logo
logo="

	 *******   **   **     **           
	/**////** //   /**    /**           
	/**    /** ** ****** ******  ****** 
	/**    /**/**///**/ ///**/  **////**
	/**    /**/**  /**    /**  /**   /**
	/**    ** /**  /**    /**  /**   /**
	/*******  /**  //**   //** //****** 
	///////   //    //     //   //////      

"

# Set some colours
RESTORE='\033[0m'
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
LIGHTGRAY='\033[00;37m'
LRED='\033[01;31m'
LGREEN='\033[01;32m'
LYELLOW='\033[01;33m'
LBLUE='\033[01;34m'
LPURPLE='\033[01;35m'
LCYAN='\033[01;36m'
WHITE='\033[01;37m'

# Version number
version="1.0.0"
# Usage text
usage="
${YELLOW}Usage:${RESTORE} \n
	${GREEN}[options] command${RESTORE}
"
# List of options available text
options="
${YELLOW}Options:${RESTORE} \n
"
# List of commands available text
commands="
${YELLOW}Commands:${RESTORE} \n
	${GREEN} pull/push [environment]${RESTORE}\t Sync all data in the directory \n
	${GREEN} test${RESTORE}\t Get a break down of any changes that might occur, dry-run \n
	${GREEN} debug${RESTORE}\t Show some helpful things like config data, directory etc...
"


# Get some variables
action="$1" # The command the user is executing
environment="$2" # The environment, staging, production etc..
current_dir=${PWD} # The directory theyre working from
remote_dir="/home/chris/" # The remote directory path
remote_dir_key=${PWD##*/} # The remote folder
config_file="ditto.config" # basic config file
safety_mode=false # Safety mode, to stop accidental syncs

# pull function - to pull all files from live
function sync () {
	# environment
	env=$2
	invoke=$1

	# Check we have an environment, or the environment is being overidden by a passed in server string
	if [[ -z $env ]]; then
		echo -e "${RED}You must specify an environment from the config ${RESTORE}"
		exit 1
	fi

	# Double check we want to do this in safety mode
	if [[ "$safety_mode" = true ]]; then
		echo "Are you sure?"
		select yn in "y" "n"; do
		    case $yn in
		        n ) return;;
		        n ) exit;;
		    esac
		done
	fi

	# Get address
	tmp=$env"_address"
	address="${!tmp}"

	# Get user
	tmp=$env"_user"
	user="${!tmp}"

	# Get port
	tmp=$env"_port"
	port="${!tmp}"

	# Check if we're pushing or pulling
	case "$invoke" in
		"push")
		    rsync -arvz -e 'ssh -p '$port . $user@$address:$remote_dir --progress --exclude '.git' --exclude 'ditto.*'
		    ;;
		"pull")
			rsync -arvz -e 'ssh -p '$port $user@$address:$remote_dir $current_dir --progress --exclude '.git' --exclude 'ditto.*'
			;;
		*)
			echo -e "${RED}I don't know whether to push or pull you beast! ${RESTORE}"
			exit 1
		    ;;
	esac
	exit 1
}

# advise function - run a dry run
function test () {
	env=$1

	# Check we have an environment
	if [[ -z $env ]]; then
		echo -e "${RED}You must specify an environment from the config ${RESTORE}"
		exit 1
	fi

	rsync -arvz -e 'ssh -p '$staging_port -h --stats $current_dir $staging_user@$staging_address:$remote_dir_key --progress --exclude '.git' --exclude 'ditto.*' --dry-run
	exit 1
}

# Debug
function debug () {
	echo -e "${GREEN} Version:${RESTORE}" $version
	echo -e "${GREEN} Your current directory:${RESTORE}" $current_dir
	echo -e "${GREEN} The remote directory:${RESTORE}" $remote_dir$remote_dir_key
	echo -e ""
	echo -e "${GREEN} Staging point:${RESTORE}" $staging_user"@"$staging_address":"$staging_port
	echo -e "${GREEN} Production point:${RESTORE}" $production_user"@"$production_address":"$production_port
	echo -e "\n"
	exit 1
}

# Load config variables into the script
function load_config () {
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
function check_config () {
	if [ ! -f $current_dir"/"$config_file ]
	then
	    echo -e "${RED} I can't find a config file in $current_dir ${RESTORE}"
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
function help () {
	echo -e "${BLUE} $logo ${RESTORE}"
	echo -e "${YELLOW}Version${RESTORE}" $version "\n"
	echo -e $usage "\n"
	#echo -e $options "\n"
	echo -e $commands "\n"
	exit 1
}

# Check the config file exists
check_config

# Run commands from action
case "$1" in
"pull")
    sync "$@"
    ;;
"push")
    sync "$@"
    ;;
"test")
	test "$@"
	;;
"debug")
	debug "$@"
	;;
*)
    help
    ;;
esac
