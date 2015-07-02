#!/bin/sh
# chkconfig: 345 99 99
### BEGIN INIT INFO
# Provides:		ISEI, Okayama University
# Required-Start:	$local_fs $remote_fs $network $syslog
# Required-Stop:	$local_fs $remote_fs $network $syslog
# Default-Start:	2 3 4 5
# Default-Stop:		0 1 6
# Short-Description:	Medusa rock sample management software
# Description:		Medusa rock sample management software
### END INIT INFO

# Source function library
. /etc/rc.d/init.d/functions

# Environment variables
RAILS_ENV="production"

# Feel free to change any of the following variables for your app:
APP_ROOT=/srv/medusa/current
APP_USER=medusa
PID=${APP_ROOT}/tmp/pids/unicorn.pid
OPTIONS="--path /medusa"
CMD="RBENV_ROOT=~/.rbenv RBENV_VERSION=2.1.0 ~/.rbenv/bin/rbenv bundle exec unicorn_rails -c ${APP_ROOT}/config/unicorn/production.rb -E ${RAILS_ENV} -D ${OPTIONS}"

action="$1"
RETVAL=0
prog="medusa"

cd ${APP_ROOT} || exit 1

start() {
	echo -n $"Starting $prog: "
	daemon --pidfile=${PID} --user=${APP_USER} "cd ${APP_ROOT} && ${CMD}"
	RETVAL=$?
	echo
}

stop() {
	echo -n $"Stopping $prog: "
	killproc -p ${PID} ${prog} -QUIT
	RETVAL=$?
	echo
}

force_stop() {
	echo -n $"Force-Stopping $prog: "
	killproc -p ${PID} ${prog} -TERM
	RETVAL=$?
	echo	
}

reload() {
	echo -n $"Reloading $prog: "
	killproc -p ${PID} ${prog} -HUP
	RETVAL=$?
	echo
}

rh_status() {
	status -p ${PID} ${prog}
}

case $action in
	start)
		start
		;;
	stop)
		stop
		;;
	status)
		rh_status
		;;
	force-stop)
		force_stop
		;;
	restart)
		stop
		sleep 2
		start
		;;
	reload)
		reload
		;;
	*)
		echo >&2 "Usage: $0 <start|stop|restart|status|force-stop|status>"
		exit 1
		;;
esac
exit 0		