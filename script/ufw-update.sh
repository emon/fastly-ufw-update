#!/bin/sh

set -e

at_exit(){
    decho 3 "at_exit called"
    [ -n "${tempdir-}" ] && rm -rf "$tempdir" && decho 3 "rm -rf $tempdir"
}

log(){
    LOG_LEVEL=$1; shift
    case ${LOG_LEVEL} in
	0) LOG_PRIORITY=notice ;;
	1) LOG_PRIORITY=info ;;
	2) LOG_PRIORITY=debug ;;
	*) LOG_PRIORITY=debug ;;
    esac
    logger -p local0.${LOG_PRIORITY} --id=$$ "[${LOG_PRIORITY}] $*"
    decho ${LOG_LEVEL} "$*"
}

decho(){
    LOG_LEVEL=$1; shift

    if [ "$DEBUG_LEVEL" -ge "$LOG_LEVEL" ]; then
       echo "$*" > /dev/stderr
    fi

}

ufw_status(){
    sudo ufw status numbered | grep "${MAGIC_WORD}"
}

get_address(){
    grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\(/[0-9]*\)*"
}

fastly_address(){
     fastly_json="$tempdir/json"
     curl -f -s -o "$fastly_json" https://api.fastly.com/public-ip-list
     $(dirname $(realpath "$0"))/jq.py < "$fastly_json"
}

ufw_diff(){
    fastly_ips_old="$tempdir/ips_old"
    fastly_ips_new="$tempdir/ips_new"

    ufw_status | get_address | sort > "${fastly_ips_old}"
    fastly_address | sort > "${fastly_ips_new}"

    diff -u0 "${fastly_ips_old}" "${fastly_ips_new}" | tail -n +3
}

ufw_apply(){
    while read line; do
	type=`echo $line | cut -b 1`
	ip=`echo $line | cut -b 2-`
	case ${type} in
	    "+" )
		log 1 sudo ufw allow in from ${ip} to any port ssh comment "${MAGIC_WORD}"
	              sudo ufw allow in from ${ip} to any port ssh comment "${MAGIC_WORD}"
		;;
	    "-" )
		log 1 sudo ufw delete allow in from ${ip} to any port ssh
		yes | sudo ufw delete allow in from ${ip} to any port ssh
		;;
	esac
    done
}

MAGIC_WORD='from https://api.fastly.com/public-ip-list'
DEBUG_LEVEL=${DEBUG_LEVEL:-0}
decho 3 "DEBUG_LEVEL=${DEBUG_LEVEL}"
CMD="$1"
SUBCMD="$2"

trap at_exit EXIT
trap 'rc=$?; trap - EXIT; at_exit; exit $?' INT PIPE TERM
tempdir=$(mktemp -d) || exit
decho 3 "tempdir=${tempdir}"

log 2 $0 ${CMD}
case ${CMD} in
    show)
	case ${SUBCMD} in
	    local)
		echo "# local ufw rules"
		ufw_status | get_address | sort
		;;
	    remote)
		echo "# fastly's latest rules"
		fastly_address
		;;
	    '')
		echo "# local ufw rules"
		ufw_status | get_address | sort
		echo "# fastly's latest rules"
		fastly_address
		;;
	    *)
		echo "invalid subcommand" > /dev/stderr
		;;
	    esac
	;;
    diff)
	ufw_diff
	;;
    apply)
	ufw_diff | ufw_apply
	;;
    *)
	echo "Usage: $0 [command]"
	echo " show        - show local and fastly's latest rules"
	echo " show local  - show local ufw rules"
	echo " show remote - show fastly's latest rules"
	echo " diff        - diff local and remote"
	echo " apply       - apply latest rules"
	;;
esac
log 2 finished
