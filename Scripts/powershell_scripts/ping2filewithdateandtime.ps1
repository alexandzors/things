# This script will drop pingoutput.txt into the current running directory where this script was executed from.

ping <#Insert ping option here. ie -n NUMBER#> localhost|ForEach{"{0} - {1}" -f (Get-Date),$_} > pingoutput.txt

# I DO NOT RECOMMEND USING -t with this script without doing an edit that will eventually stop this script from running. Otherwise you will have to find the powershell execution
# task and end it to stop the execution!

# PING OPTIONS. These can be found by typing "ping /help" in powershell or cmd.
# -t             Ping the specified host until stopped. To see statistics and continue - type Control-Break; To stop - type Control-C.
# -a             Resolve addresses to hostnames.
# -l size        Send buffer size.
# -f             Set Don't Fragment flag in packet (IPv4-only).
# -i TTL         Time To Live.
# -v TOS         Type Of Service (IPv4-only. This setting has been deprecated and has no effect on the type of service field in the IP Header).
# -r count       Record route for count hops (IPv4-only).
# -s count       Timestamp for count hops (IPv4-only).
# -j host-list   Loose source route along host-list (IPv4-only).
# -k host-list   Strict source route along host-list (IPv4-only).
# -w timeout     Timeout in milliseconds to wait for each reply.
# -R             Use routing header to test reverse route also (IPv6-only). Per RFC 5095 the use of this routing header has been deprecated. Some systems may drop echo requests if this header is used.
# -S srcaddr     Source address to use.
# -c compartment Routing compartment identifier.
# -p             Ping a Hyper-V Network Virtualization provider address.
# -4             Force using IPv4.
# -6             Force using IPv6.