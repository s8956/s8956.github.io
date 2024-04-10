# @package    MikroTik / RouterOS / GRE
# @author     Kai Kimera <mail@kai.kim>
# @copyright  2024 Library Online
# @license    MIT
# @version    0.1.0
# @link
# -------------------------------------------------------------------------------------------------------------------- #

:local wanInterface "ether1"

# -------------------------------------------------------------------------------------------------------------------- #

:local wanAddress
:local greComment
:local greCommentLen
:local greHost
:local greLocalAddress
:local greRemoteAddressNew
:local greRemoteAddressOld

:set wanAddress [/ip address get [/ip address find interface=$wanInterface] address]
:set wanAddress [:pick $wanAddress 0 [:find $wanAddress "/"]]

:foreach i in=[/interface gre find where comment~"^DOMAIN: "] do={
  :set greComment [/interface gre get $i comment]
  :set greCommentLen [:len $greComment]
  :set greHost [:pick $greComment 8 $greCommentLen]
  :set greLocalAddress [/interface gre get $i local-address]
  :set greRemoteAddressOld [/interface gre get $i remote-address]
  :set greRemoteAddressNew [:resolve $greHost]

  :if ($greRemoteAddressNew != $greRemoteAddressOld) do={
    /interface gre set $i remote-address=$greRemoteAddressNew
    :log info ("Updating " . $greComment . " from " . $greRemoteAddressOld . " to " . $greRemoteAddressNew . ".")
  }

  :if ($wanAddress != $greLocalAddress) do={
    /interface gre set $i local-address=$wanAddress
  }
}
