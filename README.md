# Reverse Tunnel RDP

A bash script used to setup and manage an SSH reverse tunnel for RDP connections.

When a linux desktop is sitting behind a firewall or NAT router it can be 
difficult to setup a remote desktop connection to an external client. One method 
of establishing a connection is to forward the RDP socket from the linux 
desktop to a host on the other side of the firewall or NAT router.

This bash script is used to establish an SSH tunnel from the linux desktop to a 
remote host and forward the RDP port from the linux desktop through the SSH 
tunnel to a port on the host system.

Once the tunnel is established an external client that has access to the external 
host system can then connect to the forwarded RDP port on the host machine and 
have the connection stream forwarded through the SSH tunnel to the isolated 
linux desktop.


## Connection diagram

```
-----------------                                                  ---------------
| linux desktop | (RDP port) <----- SSH Tunnel ------> (host port) | host system |
-----------------                                                  ---------------
                                                                    (host port)
                                                                         ^
                                                                         |
                                                                         |
                                                                         v
                                                                  -----------------
                                                                  | remote client |
                                                                  -----------------
```

The bash script is executed on the isolated linux desktop and establishes an 
SSH connection to the host system using a known user account on the host system.
A tunnel is established on the SSH connection and forwards the RDP port on the 
linux desktop to the host system.

An remote RDP client, running on the host system or on some other system that 
has access to the host system, connects to the forwarded port on the host 
system and the connection is forwarded through the tunnel to the isolated 
linux desktop.


## Configuration

The configuration settings in the script may need to be modified for your 
specific setup.

SSHPORT=22

The SSHPORT variable defines the port used on the host system for SSH connections.

RDPPORT=3389

The RDPPORT variable defines the RDP port used on the isolated linux desktop.

TUNNELPORT=23389

The TUNNELPORT variable defines the port that will be used on the host system 
for port forwarding. This can be the same as the RDPPORT or a custom port 
number if the RDP port is in use on the host system or is restricted.

TUNNELBINDADDRESS="0.0.0.0"

The TUNNELBINDADDRESS defines the address on the host system to which the 
tunnel port will be bound. The default when no address is provided is to 
bind to localhost. If the tunnel port must be accessed from a system other 
than the host system then the TUNNELBINDADDRESS must be set to 0.0.0.0 or 
a specific network address on the host system. NOTE: It may be necessary 
to edit the /etc/ssh/sshd_config file on the host system and set the 
GatewayPorts to clientspecified to allow binding to addresses other than 
localhost.

DEFAULTHOST="remotehost.local"
DEFAULTUSER="remoteuser"

The DEFAULTHOST and DEFAULTUSER variables provide default values when the 
user is prompted for connection details. Setting these to known values from 
the host system makes using the script more convenient.


## Script Execution

On the isolated linux desktop system open a terminal, cd into the directory 
where the reversetunnelrdp files are stored, and execute the reversetunnelrdp.sh 
script file.

> ./reversetunnelrdp.sh

When the script executes you will be prompted to enter the host system domain 
name or IP address.

Next you will be prompted for the user name on the host system that will be 
used for the SSH connection.

And finally you will be prompted for the password for the user on the hsot 
system.

After answering the three prompts the linux desktop system will attempt to 
establish an SSH connection to the host system using the provided credentials.
If successful then the SSH connection will be used to establish a tunnel and 
the RDP port on the linux desktop will be forwarded to the host system.

The SSH tunnel will remain connected until you press enter in the terminal.
Once enter is pressed the SSH tunnel will be disconnected.


## RDP Connection

After the script is executed and the SSH tunnel is established you can 
connect to the tunnel port on the host system with an RDP client.

> rdesktop -u desktopuser -p desktoppassword remotehost.local:23389

NOTE: The RDP server must be running on the linux desktop and accepting 
connections. The user credentials used in the RDP client are defined by 
the RDP server running on the linux desktop. These are not the same 
credentials used for the SSH connection or the user account on the 
linux desktop. See the RDP server configuration on the linux desktop 
for the credentials.


## Executing as Desktop Application

The reversetunnelrdp.desktop file is included and can be placed in a 
user's .local/share/applications/ directory to make the script 
available as an application for a user on the linux desktop.
