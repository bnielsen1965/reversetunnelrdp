#!/bin/bash

SSHPORT=22
RDPPORT=3389
TUNNELPORT=23389
TUNNELBINDADDRESS="0.0.0.0"
DEFAULTHOST="remotehost.local"
DEFAULTUSER="remoteuser"
MASTERSOCKET="/tmp/reversetunnelrdp.sock"


echoerr () {
	printf "%s\n" "$*" >&2;
}

tunnel_connect () {
	local user=$1
	local password=$2
	local host=$3
	if [ -S "$MASTERSOCKET" ]; then
		echoerr "Tunnel appears to exist already, attempting close..."
		local result=$(tunnel_disconnect $host)
		if [ $result -ne 0 ]; then
			echoerr "Failed to close tunnel, manual intervention required."
			exit $result
		fi	       
	fi
	echoerr "Connecting tunnel with local port $RDPPORT to $host port $TUNNELPORT with user $user over ssh port $SSHPORT..."
	sshpass -p "$password" ssh -o ExitOnForwardFailure=yes -f -M -S $MASTERSOCKET -N -T -C -R "$TUNNELBINDADDRESS:$TUNNELPORT:localhost:$RDPPORT" -p $SSHPORT $user@$host
	echo "$?"
}

tunnel_disconnect () {
	local host=$1
	echoerr "Closing tunnel to $host..."
	ssh -S $MASTERSOCKET -O exit $host
	echo "$?"
}


echo "Remote Desktop Reverse Tunnel"

read -p "Remote host [$DEFAULTHOST]: " HOST
HOST=${HOST:-$DEFAULTHOST}

read -p "Remote user [$DEFAULTUSER]: " USER
USER=${USER:-$DEFAULTUSER}

read -s -p "Remote password: " PASSWORD
echo ""

RESULT=$(tunnel_connect $USER $PASSWORD $HOST)

if [ $RESULT -eq 0 ]; then
	echo "Connected"
	read -p "Press enter to end reverse tunnel session."
	RESULT=$(tunnel_disconnect $HOST)
else
	echo "Connection failed."
fi

echo "Exiting..."
sleep 10

