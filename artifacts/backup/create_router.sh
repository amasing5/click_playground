#!/bin/sh
ip0=`ifconfig eth0 | grep inet | awk '{print $2}'`
netmask0=`ifconfig eth0 | grep mask | awk '{print $4}'`
mac0=`ifconfig eth0 | grep ether | awk '{print $2}'`
ip1=`ifconfig eth1 | grep inet | awk '{print $2}'`
netmask1=`ifconfig eth1 | grep mask | awk '{print $4}'`
mac1=`ifconfig eth1 | grep ether | awk '{print $2}'`

/usr/bin/perl /click_playground/confs/make-ip-conf.pl eth0 $ip0 $netmask0 $mac0 eth1 $ip1 $netmask1 $mac1 > /click_playground/confs/click_playground_router.click
