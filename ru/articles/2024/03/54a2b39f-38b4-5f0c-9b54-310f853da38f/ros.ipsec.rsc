# @package    MikroTik / RouterOS / IPsec
# @author     Kai Kimera <mail@kai.kim>
# @copyright  2024 Library Online
# @license    MIT
# @version    0.1.0
# @link
# -------------------------------------------------------------------------------------------------------------------- #

# Connection interface.
:local ipsWan "WAN"

# Common name.
:local ipsName "ipsec-sts"

# Secret phrase.
:local ipsSecret "pa$$word"

# Local network address.
:local ipsSrcAddress "10.1.0.0/16"

# Remote network address.
:local ipsDstAddress "10.2.0.0/16"

# Remote peer address.
:local ipsPeerAddress "gw1.example.com"

# -------------------------------------------------------------------------------------------------------------------- #

/ip ipsec profile
add dh-group=ecp384 enc-algorithm=aes-256 name="$ipsName"

/ip ipsec proposal
add auth-algorithms=sha256 enc-algorithms=aes-256-cbc pfs-group=ecp384 name="$ipsName"

/ip ipsec peer
add address="$ipsPeerAddress" exchange-mode=ike2 name="$ipsName" profile="$ipsName"

/ip ipsec identity
add peer="$ipsName" secret="$ipsSecret"

/ip ipsec policy
add src-address=$ipsSrcAddress dst-address=$ipsDstAddress tunnel=yes action=encrypt proposal="$ipsName" peer="$ipsName"

/ip firewall nat
add chain=srcnat action=accept src-address=$ipsSrcAddress dst-address=$ipsDstAddress place-before=0 \
  comment="[IPsec] $ipsName"

/ip firewall filter
add action=accept chain=input dst-port=500,4500 in-interface-list=$ipsWan protocol=udp \
  comment="[ROS] IPsec"
add action=accept chain=input in-interface-list=$ipsWan protocol=ipsec-esp \
  comment="[ROS] IPsec"

# Use IP/Firewall/Raw to bypass connection tracking, that way eliminating need of filter rules and reducing load on CPU
# by approximately 30%.

/ip firewall raw
add action=notrack chain=prerouting src-address=$ipsDstAddress dst-address=$ipsSrcAddress \
  comment="[IPsec] $ipsName"
add action=notrack chain=prerouting src-address=$ipsSrcAddress dst-address=$ipsDstAddress \
  comment="[IPsec] $ipsName"
