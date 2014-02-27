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
version="1.0.1"
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
remote_dir=${PWD} # The remote directory path
remote_dir_key=${PWD##*/} # The remote folder
config_file="ditto.config" # basic config file
safety_mode=true # Safety mode, to stop accidental syncs

# pull function - to pull all files from live
function sync () {
	# environment
	env=$2
	invoke=$1

	# Check the config file exists
	check_config

	# Check environment
	check_environment $env

	# Get address
	tmp=$env"_address"
	find_config_key "${tmp}"
	address=$result
	unset result

	# Get user
	tmp=$env"_user"
	find_config_key "${tmp}"
	user=$result
	unset result

	# Get port
	tmp=$env"_port"
	find_config_key "${tmp}"
	port=$result
	unset result

	# Look for a remote directory in the config
	find_config_key "remote_address"
	tmp=$result
	unset result

	# Check if we need to override the original remote directory
	if [[ ! -z $tmp ]]; then
		remote_dir=$tmp
	fi

	# Look for safety mode in config
	find_config_key "safety_mode"
	tmp=$result
	unset result

	# Check if we need to override the original safety mode
	if [[ ! -z $tmp ]]; then
		safety_mode=$tmp
	fi

	# Double check we want to do this in safety mode
	if [[ "$safety_mode" = true ]]; then
		read -p "Continue to ${invoke} ${env} (y/n)?" choice
		case "$choice" in
			y|Y )

				;;
			n|N )
				echo -e "${YELLOW} Sync cancelled ${RESTORE}"
				exit 1
				;;
			* )
				echo -e "${YELLOW} Sync cancelled ${RESTORE}"
				exit 1
		esac
	fi

	# Check if we're pushing or pulling
	case "$invoke" in
		"push")
		    rsync -arvz -e 'ssh -p '$port . $user@$address:$remote_dir --progress --exclude '.git' --exclude 'ditto.*'
		    ;;
		"pull")
			rsync -arvz -e 'ssh -p '$port $user@$address:$remote_dir $current_dir --progress --exclude '.git' --exclude 'ditto.*'
			;;
		*)
			echo -e "${RED} I don't know whether to push or pull you beast! ${RESTORE}"
			exit 1
		    ;;
	esac
	exit 1
}

# advise function - run a dry run
function test () {
	env=$2
	invoke=$1

	# Check we have an environment
	if [[ -z $env ]]; then
		echo -e "${RED} You must specify an environment to affect from your ditto config ${RESTORE}"
		exit 1
	fi

	rsync -arvz -e 'ssh -p '$staging_port -h --stats $current_dir $staging_user@$staging_address:$remote_dir_key --progress --exclude '.git' --exclude 'ditto.*' --dry-run
	exit 1
}

# Show some useful information about the destinations
function debug () {
	# Load in config variables
	check_config

	# Show some data
	echo -e "${GREEN} Version:${RESTORE}" $version
	echo -e "${GREEN} Your current directory:${RESTORE}" $current_dir
	echo -e "${GREEN} The remote directory:${RESTORE}" $remote_dir$remote_dir_key
	echo -e ""

	# Loop config variables to show avilable
	for (( x=0 ; x < ${#configKey[@]}; x++ ))
	do
	    echo -e "${GREEN}" "${configKey[$x]}" ":${RESTORE}" "${configValue[$x]}"
	done

	# Get outta there
	echo -e "\n"
	exit 1
}

# Locate an array key based on a string
function find_config_key () {
	key=$1

	# test loop
	for (( x=0 ; x < ${#configKey[@]}; x++ ))
	do
	    if [ $key == "${configKey[$x]}" ]
	    then
	    	result="${configValue[$x]}"
	    fi
	done
}

# Check config file and parse
function check_config () {
	# Check for a config file
	if [ ! -f $current_dir"/"$config_file ]
	then
	    echo -e "${RED} I can't find a config file in $current_dir ${RESTORE}"
	    exit 1
	fi

	# Read the config file and get some variables
	i=0
	while read line; do
	  if [[ "$line" =~ ^[^#]*= ]]; then
	    configKey[$i]=${line%%=*}
	    configValue[$i]=${line##*=}
	    ((i++))
	  fi
	done < $current_dir"/"$config_file

	# Check the config file contains something
	if [[ $i -le 0 ]];
	then
		echo -e "${RED} Your ditto config contains no real information ${RESTORE}"
	    exit 1
	fi
}

# Check we have an environment, or the environment is being overidden by a passed in server string
function check_environment () {
	env=$1

	if [[ -z $env ]]; then
		echo -e "${RED} You must specify an environment from the config ${RESTORE}"
		exit 1
	fi
}

# Fallback for missed commands
function help () {
	echo -e "${BLUE} $logo ${RESTORE}"
	echo -e "${YELLOW}Version${RESTORE}" $version "\n"
	echo -e $usage "\n"
	echo -e $commands "\n"
	exit 1
}

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
