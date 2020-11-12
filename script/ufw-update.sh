#!/bin/sh

MAGIC_WORD='from https://api.fastly.com/public-ip-list'

ufw_status(){
    sudo ufw status numbered | grep "${MAGIC_WORD}"
}

get_address(){
    grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\(/[0-9]*\)*"
}

fastly_address(){
    curl -s -o - https://api.fastly.com/public-ip-list | ./jq.py
}

fastly_ips_old=$(tempfile) || exit
fastly_ips_new=$(tempfile) || exit
trap "rm -f -- '$fastly_ips_old' '$fastly_ips_new'" EXIT

ufw_status | get_address | sort > ${fastly_ips_old}
fastly_address | sort > ${fastly_ips_new}

DIFF=`diff -u0 ${fastly_ips_old} ${fastly_ips_new} | tail -n +3`
rm -f -- "$fastly_ips_old" "$fastly_ips_new"
trap - EXIT

echo "${DIFF}" | tee /dev/stderr | while read line; do
    type=`echo $line | cut -b 1`
    ip=`echo $line | cut -b 2-`
    case ${type} in
	"+" )
	    echo sudo ufw allow in from ${ip} to any port ssh comment "${MAGIC_WORD}"
	         sudo ufw allow in from ${ip} to any port ssh comment "${MAGIC_WORD}"
	    ;;
	"-" )
	    echo sudo ufw delete allow in from ${ip} to any port ssh
	    yes| sudo ufw delete allow in from ${ip} to any port ssh
	    ;;
    esac
done
