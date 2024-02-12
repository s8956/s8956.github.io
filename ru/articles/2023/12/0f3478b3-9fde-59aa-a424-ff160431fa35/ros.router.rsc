# @package    MikroTik / RouterOS
# @author     Kai Kimera <mail@kai.kim>
# @copyright  2023 Library Online
# @license    MIT
# @version    0.1.0
# @link       https://lib.onl/ru/articles/2023/12/0f3478b3-9fde-59aa-a424-ff160431fa35/
# -------------------------------------------------------------------------------------------------------------------- #

:local bridge "bridge1"
:local adminPassword "cDFymu2aML"
:local routerName "GW01"

/interface bridge
add name=$bridge

/interface list
add name=WAN
add name=LAN

/interface bridge port
:for i from=2 to=10 do={
  add bridge=$bridge interface=("ether" . $i)
}

/interface list member
add interface=ether1 list=WAN
add interface=$bridge list=LAN

/ip pool
add name=dhcp ranges=10.0.100.1-10.0.200.254

/ip dhcp-server
add address-pool=dhcp interface=$bridge name=dhcp1

/ip neighbor discovery-settings
set discover-interface-list=LAN

/ip address
add address=10.0.0.1/16 interface=$bridge network=10.0.0.0

/ip dhcp-client
add interface=ether1

/ip dhcp-server lease
# add address=10.0.10.1 mac-address=11:11:11:11:11:11 comment="SERVER01"

/ip dhcp-server network
add address=10.0.0.0/16 dns-server=10.0.0.1 domain=home.lan gateway=10.0.0.1 ntp-server=10.0.0.1

/ip dns
set allow-remote-requests=yes servers=1.1.1.1,1.0.0.1

/ip dns static
add address=10.0.0.1 name=gw01.lan

/ip firewall filter
add action=accept chain=input connection-state=established,related,untracked comment="[ACCEPT] Established, Related, Untracked"
add action=drop chain=input connection-state=invalid comment="[DROP] Invalid"
add action=accept chain=input protocol=icmp comment="[ACCEPT] ICMP"
add action=accept chain=input dst-port=9090,22022 protocol=tcp comment="[ROS] WinBox and SSH"
add action=drop chain=input in-interface-list=!LAN comment="[DROP] All not coming from LAN"
# add action=accept chain=forward ipsec-policy=in,ipsec comment="[ACCEPT] In IPsec policy"
# add action=accept chain=forward ipsec-policy=out,ipsec comment="[ACCEPT] Out IPsec policy"
add action=fasttrack-connection chain=forward connection-state=established,related comment="[ROS] FastTrack"
add action=accept chain=forward connection-state=established,related,untracked comment="[ROS] FastTrack"
add action=drop chain=forward connection-state=invalid comment="[DROP] Invalid"
add action=drop chain=forward connection-nat-state=!dstnat connection-state=new in-interface-list=WAN comment="[DROP] All from WAN not DSTNATed"

/ip firewall nat
add action=masquerade chain=srcnat out-interface-list=WAN

/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set ssh port=22022
set api disabled=yes
set winbox port=9090
set api-ssl disabled=yes

/system clock
set time-zone-name=Europe/Moscow

/system identity
set name=$routerName

/system ntp client
set enabled=yes

/system ntp server
set enabled=yes manycast=yes multicast=yes

/system ntp client servers
add address=time.cloudflare.com

/tool bandwidth-server
set enabled=no

/tool mac-server
set allowed-interface-list=none

/tool mac-server ping
set enabled=no

/user
set [find name="admin"] password=$adminPassword
