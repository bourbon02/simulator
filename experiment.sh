#!/bin/bash
#
# Sample script to setup and run an experiment
#

#
# create a directory to save experiment ouptput
#
DIR=base-line-`date +%F`
mkdir $DIR
cat $0 > $DIR/experiment.config # the config is this script
echo [Saving experiment output to $DIR/]

#
# Start two services s0 and s1, with s0 calling s1
#
echo [Starting services]
node service.js --port 3000 --type serial --services http://127.0.0.1:3001 > $DIR/s0.csv &
node service.js --port 3001 --type timed --mean 200 --std 50 --error_rate 0.1 > $DIR/s1.csv &

sleep 2 # give services time to start up, before running the experiment

#
# Use ab command to execute the experiment
#
echo [Running experiment]
ab -l -n 1000 -c 10 -e $DIR/ab.csv http://127.0.0.1:3000/ > $DIR/ab.output

#
# Combine the *.csv files generated by the services into one
#
echo [Processing experiment logs]
node merge-output.js $DIR/s0.csv $DIR/s1.csv > $DIR/merged-results.csv

#
# clean up all of the child processes started by this script
#
echo [Cleaning up child processes]
pkill -P $$
