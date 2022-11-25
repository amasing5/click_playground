#!/bin/bash
#click_run.sh -h
while getopts "hc:" OPTION;
        do case $OPTION in
		h)echo "Provide the click config"
		  echo  "run_click.sh -c <config file>"
			exit;;
                c)CONFIG=$OPTARG;;
        esac
        done
if [ ! -n "$CONFIG" ]
	then echo "Invalid arguments: Provide the right set of arguments"
		     echo "For help: run_click.sh -h"
		             exit
fi
echo "Running click_playground with config $CONFIG ...";
/click_playground/click/bin/click /click_playground/confs/$CONFIG
