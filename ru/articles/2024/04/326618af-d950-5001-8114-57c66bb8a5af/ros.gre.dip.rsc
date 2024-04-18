# @package    MikroTik / RouterOS / GRE / Dynamic IP
# @author     Kai Kimera <mail@kai.kim>
# @copyright  2024 Library Online
# @license    MIT
# @version    0.1.0
# @link       https://lib.onl/ru/articles/2024/04/326618af-d950-5001-8114-57c66bb8a5af/
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

:foreach i in=[/interface gre find where comment~"^HOST: "] do={
  :set greComment [/interface gre get $i comment]
  :set greCommentLen [:len $greComment]
  :set greHost [:pick $greComment 6 $greCommentLen]
  :set greLocalAddress [/interface gre get $i local-address]
  :set greRemoteAddressOld [/interface gre get $i remote-address]
  :set greRemoteAddressNew [:resolve $greHost]

  :if ($greRemoteAddressNew != $greRemoteAddressOld) do={
    /interface gre set $i remote-address=$greRemoteAddressNew
    :log info ("Updating GRE remote address (" . $greComment . ") from " . $greRemoteAddressOld . " to " . $greRemoteAddressNew . ".")
  }

  :if ($wanAddress != $greLocalAddress) do={
    /interface gre set $i local-address=$wanAddress
    :log info ("Updating GRE local address from " . $greLocalAddress . " to " . $wanAddress . ".")
  }
}
