#!/bin/bash
HOST=""
SEGMENTTIME=900
TIMEOUTTIME=1000


check_host () {
	echo "running nmap and saving to host"
	HOST=$(nmap -p 554  -oG - 192.168.1.1/24 | grep rtsp | grep open | awk '{ print $2}')
	echo "done running nmap, host is $HOST"
	if test -z "$HOST" 
	then
	#      echo "\$HOST is empty"
	#	wait 15 seconds then retry
		echo "no host found.... retrying after 15 seconds"
		sleep 15
	else
	#      echo "\$HOST is NOT empty"
		echo "rtsp ip found at $HOST"
	fi
}

capture_rtsp () {
	echo "executing capture_rtsp at $HOST"
	$(timeout --foreground $TIMEOUTTIME bash -c -- "ffmpeg -hide_banner -y -loglevel info -rtsp_transport tcp -use_wallclock_as_timestamps 1 -i rtsp://<username>:<password>@$HOST:554/stream1 -vcodec copy -acodec copy -f segment -reset_timestamps 1 -segment_time $SEGMENTTIME -segment_format mkv -segment_atclocktime 1 -strftime 1 /home/jepes/Videos/%Y%m%d_T%H%M%S.mkv")
	echo "done capture_rtsp segment"
}

echo "start up"
while test -z "$HOST"
do
	echo "running check host"
	check_host
done

echo "starting loop"
while true
do
	# check if host is still up
	echo "cheching if host is still up"
	ping $HOST -c 1
	ret=$?
	if test $ret -ne 0		#check ping return non-zero (failed ping)
	then
		echo "ping to host failed, scanning check_host"
		HOST=""
		check_host
	else
		echo "ping to host okay, proceeding to record..."
		capture_rtsp
	fi
done

