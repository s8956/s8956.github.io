# @package    MikroTik / RouterOS / IPsec
# @author     Kai Kimera <mail@kai.kim>
# @copyright  2024 Library Online
# @license    MIT
# @version    0.1.0
# @link       https://lib.onl/ru/articles/2024/03/54a2b39f-38b4-5f0c-9b54-310f853da38f/
# -------------------------------------------------------------------------------------------------------------------- #

:local ipsSecret "pa$$word"
:local ipsInterface "WAN"
:local ipsProfileName "ipsec-sts"

# -------------------------------------------------------------------------------------------------------------------- #

:local ipsLocalName "GW1"
:local ipsLocalNetwork "10.1.0.0/16"

# -------------------------------------------------------------------------------------------------------------------- #

:local ipsRemoteName "GW2"
:local ipsRemoteNetwork "10.2.0.0/16"
:local ipsRemoteWanIp "gw2.example.com"

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

/ip ipsec profile
add dh-group=ecp384 enc-algorithm=aes-256 name=$ipsProfileName

/ip ipsec proposal
add auth-algorithms=sha256 enc-algorithms=aes-256-cbc pfs-group=ecp384 name=$ipsProfileName

/ip ipsec peer
add address=$ipsRemoteWanIp exchange-mode=ike2 name=$ipsRemoteName profile=$ipsProfileName \
  comment="$ipsRemoteName"

/ip ipsec identity
add peer=$ipsRemoteName secret="$ipsSecret" \
  comment="$ipsRemoteName"

/ip ipsec policy
add src-address=$ipsLocalNetwork dst-address=$ipsRemoteNetwork tunnel=yes action=encrypt \
  proposal=$ipsProfileName peer=$ipsRemoteName \
  comment="$ipsLocalName-$ipsRemoteName"

/ip firewall nat
add chain=srcnat action=accept src-address=$ipsLocalNetwork dst-address=$ipsRemoteNetwork place-before=0 \
  comment="[IPsec] $ipsLocalName-$ipsRemoteName"

/ip firewall filter
add action=accept chain=input dst-port=500,4500 in-interface-list=$ipsWan protocol=udp \
  comment="[ROS] IPsec"
add action=accept chain=input in-interface-list=$ipsWan protocol=ipsec-esp \
  comment="[ROS] IPsec"

# Use IP/Firewall/Raw to bypass connection tracking, that way eliminating need of filter rules and reducing load on CPU
# by approximately 30%.

/ip firewall raw
add action=notrack chain=prerouting src-address=$ipsRemoteNetwork dst-address=$ipsLocalNetwork \
  comment="[IPsec] $ipsRemoteName-$ipsLocalName"
add action=notrack chain=prerouting src-address=$ipsLocalNetwork dst-address=$ipsRemoteNetwork \
  comment="[IPsec] $ipsLocalName-$ipsRemoteName"
