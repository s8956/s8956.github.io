# Mikrotik RouterOS script for CloudFlare DDNS
#
# @package    RouterOS
# @author     Kai Kimera <mail@kai.kim>
# @copyright  2023 Library Online
# @license    MIT
# @version    0.0.1
# @link       https://lib.onl
# -------------------------------------------------------------------------------------------------------------------- #

# RouterOS: WAN interface name.
:local rosWanInterface "ether1"

# RouterOS: Enables trust chain validation from local certificate store.
# 'no'  | Disable certificate check.
# 'yes' | Enable certificate check.
:local rosCheckCert "no"

# CloudFlare: API token.
:local cfToken ""

# CloudFlare: Domain.
:local cfDomain "example.com"

# CloudFlare: Zone ID.
:local cfZoneID ""

# CloudFlare: DNS ID.
:local cfDnsID ""

# CloudFlare: Domain record type.
:local cfRecordType "A"

# CloudFlare: Debug mode.
# 0 | Disable debug mode.
# 1 | Enable debug mode.
:local cfDebug 0

# -------------------------------------------------------------------------------------------------------------------- #

# IP on WAN interface.
:local srcIP

# IP on CloudFlare domain.
:local dstIP

# Get RouterOS WAN IP.
:set srcIP [/ip address get [/ip address find interface=$rosWanInterface ] address]
:set srcIP [:pick $srcIP 0 [:find $srcIP "/"]]

# Get CloudFlare domain IP.
:set dstIP [:resolve $cfDomain]

# Build CloudFlare API (v4).
:local cfAPI "https://api.cloudflare.com/client/v4/zones/"
:set cfAPI ($cfAPI . "$cfZoneID/dns_records/$cfDnsID")
:local cfAPIHeader "Authorization: Bearer $cfToken, Content-Type: application/json"
:local cfAPIData "{\"type\":\"$cfRecordType\",\"name\":\"$cfDomain\",\"content\":\"$srcIP\"}"

# Write debug info to log.
:if ($cfDebug) do={
  :log info ("CloudFlare: Domain = $cfDomain")
  :log info ("CloudFlare: Domain IP (dstIP) = $dstIP")
  :log info ("CloudFlare: WAN IP (srcIP) = $srcIP")
  :log info ("CloudFlare: CloudFlare API (cfAPI) = $cfAPI&content=$srcIP")
}

# Compare and update CF if necessary.
:if ($dstIP != $srcIP) do={
  :log info ("CloudFlare: Updating $cfDomain, setting $srcIP = $cfDomain")
  /tool fetch \
    mode=https \
    http-method=put \
    http-header-field="$cfAPIHeader" \
    http-data="$cfAPIData" url="$cfAPI" \
    check-certificate=$rosCheckCert \
    output=user as-value
  /ip dns cache flush
}
