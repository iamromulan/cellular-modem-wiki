Quectel RGMII Configuration Notes
=================================

Many of Quectel's modems support directly connecting to a PCIe Ethernet chipset. This is useful to use the cellular connection as a WAN interface - you can just plug the modem into the WAN port on your router, do a bit of configuration, and you're good to go. Performance is good, and the modem's onboard connection management often works better than the scripts many routers use to try to keep the connection up.
 - 

> :warning: This is a living document. Changes may be made as more discoverys are made or more software is made

If you would like to support [Nate Carlson's](https://github.com/natecarlson) work to document this, and help them purchase additional hardware for more hacking (without having to take one of my active modems down), you can click the link below. To be clear, please only do this if you actually want to; any future work they do will always be publicly available. Questions and suggestions can be discussed under issues. 

<a href="https://www.buymeacoffee.com/natecarlson" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>

# Table of Contents
- [Quectel RGMII Configuration Notes](#quectel-rgmii-configuration-notes)
- [Table of Contents](#table-of-contents)
- [Hardware Recommendations](#hardware-recommendations)
- [Known issues](#known-issues)
  - [Modem does not automatically connect at startup](#modem-does-not-automatically-connect-at-startup)
- [Basic configuration](#basic-configuration)
  - [Additional notes](#additional-notes)
  - [AT over Ethernet](#at-over-ethernet)
  - [Enabling IP Passthrough](#enabling-ip-passthrough)
    - [QMAP Method](#qmap-method)
    - [RGMII Method](#rgmii-method)
  - [Specifying a custom APN](#specifying-a-custom-apn)
  - [Changing modem IP address with AT command](#changing-modem-ip-address-with-at-command)
- [Advanced configuration](#advanced-configuration)
  - [Getting ADB Access](#getting-adb-access)
  - [Starting an FTP server](#starting-an-ftp-server)
  - [Changing modem IP address](#changing-modem-ip-address)
  - [TTL Modification](#ttl-modification)
    - [Installing TTL Override:](#installing-ttl-override)
    - [Removing TTL Override](#removing-ttl-override)
  - [Enable Qualcomm Webserver](#enable-qualcomm-webserver)
  - [Enable journald logging](#enable-journald-logging)
  - [Other interesting things to check over ADB](#other-interesting-things-to-check-over-adb)
    - [Making sure you're connected to the right modem](#making-sure-youre-connected-to-the-right-modem)
    - [AT Command Access from ADB](#at-command-access-from-adb)

# Hardware Recommendations

I've only used one adapter personally; it's sold on Aliexpress as "5G to 2.5Gbps Ethernet(RJ45) board,USB3.0-C,DC5.5 input, support RM520N-GL RM510Q-GL RM500Q-GL/CN,RTL8125 case", and can either be purchased with or without an RM520N-GL. You can buy it as a bare board or as a kit, including an enclosure, pigtails, fan, heatsink, and antennas. The antennas and heatsink I don't realy care for. I'd recomend getting a higher quality copper heatsink and using antennas of your prefrence. I'd also recomend a 12v 5A power adapter to go along with this.


![](images/mcuzoneboard.webp)

![](images/mcuzonekit.webp)


Here's the seller I purchased from:
https://a.aliexpress.com/_m0hVDKO


Side note - From what i understand, the InvisaGig product sold by Wireless Haven is an RGMII M.2 to Ethernet board with a custom case, copper heatsink on the RM520 coupled with a fan and proper ventilation on the case. They embed a custom GUI in the RM520N, which makes configuration simpler, no need for a USB connection at all. A guide on installing a community made version of a custom GUI will be covered later on in this document. The InvisaGig is expensive compared to DIY, but they also offer a warranty and support. If you're interested:
https://thewirelesshaven.com/shop/modems-hotspots/invisagig/


(If you are using an Invisagig, please don't do any of the stuff mentioned below. Use their UI, or ask for support instead. You're paying a premium to not have to deal with this.)

# Known issues

## Modem does not automatically connect at startup

Some are reporting that when you reboot the modem, it will start in CFUN=0 (minimal function) mode. To get it to connect, you need to issue `AT+CFUN=1`.

I have experienced this myself, but I have found that running the following AT commands via the USB AT port fixes this.
```bash
AT+CFUN=1,1
```
Wait for the modem to reboot then run
```bash
AT+QPRTPARA=1
```
If you are running into this still and the above did not work, a quick and easy hack is to install the ttl mod, but uncomment the line in `ttl-override` (which gets pushed to `/etc/initscripts/ttl-override`):
* Note that if this ttl mod is installed, then the simpleadmin web GUI's TTL will not work (covered later in this doc)

```bash
# If your modem is starting in CFUN=0 mode, uncomment this to pass CFUN=1 to it. Hack, but we'll still keep working to figure out what is causing it.
# echo -e "AT+CFUN=1\r\n" > /dev/smd7
```

Remove the `# ` from before the echo line.

# Basic configuration

It is recommended to Flash the latest firmware avalible before continuing. It will wipe any custom software previosly installed by adb. Use Qflash for windows or Qfirehose for Linux. This prosedure is documented for windows in my RM520 repository.

```
AT+QCFG="data_interface",1,0
AT+QCFG="pcie/mode",1
AT+QETH="eth_driver","r8125",1
AT+QMAPWAC=1
```

What these commands do:
* `AT+QCFG="data_interface"`: Configures network port/diag port communication via PCIe and USB. First parameter is for network communication; 0 is USB and 1 is PCIe. Second parameter is for diagnostics port; only option is 0 for USB.
* `AT+QCFG="pcie/mode"`: 1 = RC (Root Complex), IE host. 0 = EP (Endpoint), for use in a device that has the RC
* `AT+QETH="eth_driver","r8125",1`: This configures which ethernet driver to load at module boot. You can run `AT+QETH="eth_driver"` to get a list of options; I believe only one can be enabled. The first parameter is the name of the driver, and the second parameter is a bool to enable or disable.

If you want to be able to send AT commands via Ethernet, you can also add:
```
AT+QETH="eth_at","enable"
```

This will enable an AT interface on port 1555. See below section [AT over Ethernet](#at-over-ethernet) for more details.

..and then reboot the module with `AT+CFUN=1,1`.

## Additional notes

It looks like there are multiple ways to configure these modules. This is the most widely-referenced method I've seen referenced, including in Quectel's documentation for the M.2 EVB board. Similar methods of configuring this feature appear to be `AT+QETH="rgmii"` and various functions of `AT+QMAP`. If someone has a good understanding of which mode to use when, please open an issue or pull request!

## AT over Ethernet

If you enabled AT over Ethernet, anyone behind the modem will be able to send whatever AT commands they want to it -- there is no authentication for the protocol. Just to warn ya.

Their interface is not like the Netgear Nighthawk interface, where you can just telnet into the port and start issuing commands; they use a not-complex-but-not-telnet protocol. They don't have official docs on it, and just released a sample C application. I have a hacked-up Python script that is a bit easier to use, available at:
https://github.com/natecarlson/quectel-rgmii-at-command-client

## Enabling IP Passthrough

By default, the modem acts as a true NAT router for IPv4, and serves addresses via IPv6. The modem's IPv4 address is 192.168.225.1 - this can't be changed via AT commands (and Quectel doesn't officially support changing it), but it is possible - see Advanced below.

In any case, if you want to pass through the IPv4 (and possibly IPv6? Not sure if the modem passes through the v6 address and lets you use the delegated subnet behind your router or not; I will have to test.) addresses that are assigned, you can!

As with enabling ethernet mode to start with, it appears there are multiple ways to enable IP Passthrough.

> :warning: **BE CAREFUL**: I haven't managed to get either of these methods to work properly in my testing yet. If you have, feel free to share!

### QMAP Method

> :warning: **BE CAREFUL**: I haven't managed to get either of these methods to work properly in my testing yet. If you have, feel free to share!

This is the method that is documented in the RM520N AT command manual that I have, so I've tested this method.

To enable IP passthrough:
```
at+qmap="mpdn_rule",0,1,1,1,1,"FF:FF:FF:FF:FF:FF"
```

Parameters:
* First = mPDN rule number, range 0-3 (unless you're doing something complicated, you'll use 0.)
* Second = APN Profile ID (CGDCONT) to use. You'll probably want 1.
* Third = IP Passthrough mode. 0 = disabled, 1 = enabled for ethernet, 2 = enabled for WiFi, 3 = enabled for USB-ECM/RNDIS. You'll probably want 1.
* Fourth = autoconnect. Use 1.
* Fifth = IPPT Mode. If set to 0, disabled? 1 or 2 make the next field the MAC address you want to pass through to. If you don't specify this, but have IPPT enabled, the first computer to connect will get the pass-through address, and any additional computers will get a private NAT'd IP.
* Sixth = MAC address to pass through to. `FF:FF:FF:FF:FF:FF` will select the first host that gets a DHCP lease.


### RGMII Method

> :warning: **BE CAREFUL**: I haven't managed to get either of these methods to work properly in my testing yet. If you have, feel free to share!

If we were using `AT+QETH="rgmii"` to enable Ethernet mode, we'd probably want to use that for this too. Note that this mode is documented in the AT command guide for the older RM50x modules, and is not documented in the AT command guide for the RM520 modules - at least the versions of the manuals I have.

If you want to go that route, you can try:

```
AT+QETH="ipptmac",XX:XX:XX:XX:XX:XX
AT+QETH="rgmii","ENABLE",1,1,1
```
* AT+QETH="ipptmac", the first parameter, formatted as `XX:XX:XX:XX:XX:XX`, should be the MAC address of the device you want to receive the IP passthrough.
* AT+QETH="rgmii":
  * First parameter is "ENABLE" or "DISABLE", to enable or disable RGMII mode.
  * Second parameter is the voltage to use for RGMII. `0`=1.8v and `1`=2.5v. I would recommend running `AT+QETH="rgmii"`, and get the current version from the first line it prints: `+QETH: "RGMII","DISABLE",1,-1` -- it's the '1' after the disable.
  * Third parameter is for IP Passthrough. `-1` = no data call, `0` = COMMON-RGMII (not passthrough), `1` = IP Passthrough-RGMII
  * Optional fourth parameter is if you want to specify a CGDCONT profile to use for this. `0` = not configured, `1` = configured.
  * Optional fifth parameter is the CGDCONT profile ID, 1-8.

## Specifying a custom APN

If the modem doesn't automatically connect, it's likely that you need to manually configure the APN. It's done the same way that you configure the APN on the modem when using it via USB/etc.

> :warning: **TODO**: Finish filling out this section!

## Changing modem IP address with AT command

There are plenty of reasons that you might need to change the IP of the modem.. IE, you might have multiple modems connected to the same router for WAN load balancing or bonding, or it might conflict with your internal network IP ranges, or (other reasons.) On recent modems, Quectel does have a command to do this!

The command is:
```
AT+QMAP="LANIP",<dhcp-start>,<dhcp-end>,<router-ip>,<apply?>
AT+QMAP="LANIP",192.168.227.20,192.168.227.100,192.168.227.1,1
```

The 'apply?' is if the router should apply the changes immediately, or wait until reboot.

# Advanced configuration

These modems are a full-fledged Linux router under the hood. Once you've got access, you can modify anything you want on the filesystem. It's pretty cool, and also kind of dangerous.. but neat. The access is via 'adb' - the same tool used to do fun stuff to Android phones.

## Getting ADB Access

To get access, you need to get a key salt from the modem, get the result from Quectel, unlock the modem, and then enable ADB.

To get the key, run the AT command "AT+QADBKEY?". The modem will reply with:
```
AT+QADBKEY?
+QADBKEY: 12345678
OK
```

You then can head over to the Quectel forums (https://forums.quectel.com/), create an account, and post asking for the key. There are also tools available on the great wide internet that will generate the key for previous modems.. but they don't quite work for RM5XX's; the result is a little bit too long.

Once you have received the unlock key, you apply it like:
```
AT+QADBKEY="0jXKXQwSwMxYoeg"
```

Then, to actually enable ADB, run `AT+QCFG="usbcfg"`, take the output, change the second-to-last 0 to 1, and then send the new usbcfg string to the modem (do _NOT_ just copy/paste what's below; the USB VID/PID for your modem are very likely different):

```control
AT+QCFG="usbcfg"
+QCFG: "usbcfg",0x2C7C,0x0801,1,1,1,1,1,0,0 // Initial response
AT+QCFG="usbcfg",0x2C7C,0x0801,1,1,1,1,1,1,0 // Enable ADB
```

And reboot with `AT+CFUN=1,1` to actually apply.

Once the modem is back online, you should be able to use ADB to manage the modem on the host connect to it with USB. Basic commands:

- `adb shell` - root shell on the modem
- `adb pull /path/to/file` - download a file from the modem
- `adb push /path/to/file` - upload a file to the modem

So far, I have been unsuccessful with my attempts to get ADB to listen on the ethernet interface. Warning - `adb tcp <port>` will crash both ADB and all the other serial ports expoised via USB until the modem is restarted.

## Starting an FTP server

Once you have root access to the modem, if you want you can start a temporary FTP server to let you transfer files over the network instead of adb. It will run until you ctrl-c it. Be careful here, it allows full unauthenticated access to the filesystem to whoever can access any of the IPs (if you have a routed public IP, vi that too unless you add firewall rules!) You can change the IP to the modem's LAN address (192.168.225.1 by default) if you'd like.

```bash
tcpsvd -vE 0.0.0.0 21 ftpd /
```

When you connect via FTP, you can just leave the username and password blank.

Note that the BusyBox binary on the modem is compiled without FTP write support. If you would like to enable write support, you can copy files/busybox-armv7l somewhere on the modem (anything under /usrdata is persistent; for this example I created /usrdata/bin), and call that binary instead, with a '-w' flag between ftpd and /; I would also recommend using the current busybox for tcpsvd. You'll also need to add '-A' to ftpd for anonymous access. Example command:

```bash
/usrdata/bin/busybox-armv7l tcpsvd -xE 0.0.0.0 21 /usrdata/bin/busybox-armv7l ftpd -wA /
```

## Changing modem IP address

**NOTE**: I am leaving this here for reference sake, but on modern modems, you can indeed change the IP with an AT command. Please reference: [Changing modem IP address with AT command
](#changing-modem-ip-address-with-at-command)

There are plenty of reasons that you might need to change the IP of the modem.. IE, you might have multiple modems connected to the same router for WAN load balancing or bonding, or it might conflict with your internal network IP ranges, or (other reasons.) Unfortunately, Quectel doesn't officially support this, and there is no AT command to do so. However, it's not hard to do.

Make sure you've gained ADB access as described above.

WARNING: You're modifying files on the modem's root filesystem here. If you break it, you buy it, and can keep both pieces!

1. Log into the modem via `adb shell` (If you have multiple modems connected via USB that have ADB enabled, you can get a list of modems with `adb devices`, and connect to the one you want via `adb -s <number> shell`)
2. Change to the `/etc` directory
3. Open `/etc/data/mobileap_cfg.xml` in an editor, and change each occurence of 192.168.225 to whatever you want - for mine, I just went to 192.168.226.
4. Exit ADB, and reboot the router with `AT+CFUN=1,1`

Note that the 192.168.225.1 address is also referenced in `/etc/ql_nf_preload.conf`; I haven't modified that file and everything seems to work, but just so ya know.

## TTL Modification

This is a Linux router using iptables - so you can add iptables rules to override the outgoing TTL. Certain cell plans may require this for various reasons.

It's probably worth noting that this will also work for modems connected via a USB enclosure.. what this does is directly change the TTL/HL when packets leave the modem, so it really doesn't matter how it's connected to your network.

Make sure you've gained ADB access as described above.

WARNING: You're modifying files on the modem's root filesystem here. If you break it, you buy it, and can keep both pieces!

Files:
* `files/ttl-override`: A simple shell script to start/stop the TTL override. Set the desired TTL with the 'TTLVALUE=' at the top of the script; the default is 64, which will make all packets appear as coming from the modem itself.
* `files/ttl-override.service`: A systemd service to start said script

### Installing TTL Override:

* Mount the root filesystem read-write:
```
adb shell mount -o remount,rw /
```
* Push the files to the system:
```
adb push ttl-override /etc/initscripts
adb push ttl-override.service /lib/systemd/system
```
* symlink the systemd unit, reload systemd, start the service, and remount root as ro again:
```
adb shell chmod +x /etc/initscripts/ttl-override
adb shell ln -s /lib/systemd/system/ttl-override.service /lib/systemd/system/multi-user.target.wants/
adb shell systemctl daemon-reload
adb shell systemctl start ttl-override
adb shell mount -o remount,ro /
```
* The TTL rules will already be active - but you can reboot the modem with `AT+CFUN=1,1` and verify that the rules are automatically added at startup.
* After it comes back up, you can verify the TTL:
```
$ adb shell iptables -t mangle -vnL | grep TTL
 1720  107K TTL        all  --  *      rmnet+  0.0.0.0/0            0.0.0.0/0            TTL set to 64
$ adb shell ip6tables -t mangle -vnL | grep HL
    0     0 HL         all      *      rmnet+  ::/0                 ::/0                 HL set to 64
```

If you want to validate that it's working, you can use "adb shell", and run tcpdump on the network-side interface, specifying that interface's IP as the source (feel free to do that instead of pasting my long ugly string):
```
/ # tcpdump -s0 -v -n -i rmnet_data1 src `ip addr show dev rmnet_data1 | grep '^    inet ' | awk '{ print $2 }' | awk -F'/' '{ print $1 }'`
tcpdump: listening on rmnet_data1, link-type LINUX_SLL (Linux cooked v1), capture size 65535 bytes
17:12:03.064808 IP (tos 0x0, ttl 64, id 55285, offset 0, flags [DF], proto ICMP (1), length 212)
    10.200.255.210 > 8.8.4.4: ICMP echo request, id 16940, seq 2, length 192
```

Note the "ttl 64" - it's working, yay! (The traffic needs to be coming from a host behind the modem for it to really count, which this was.)

### Removing TTL Override

If, for some reason, you want to remove the TTL override, you would need to run:
```
adb shell /etc/initscripts/ttl-override stop
adb shell mount -o remount,rw /
adb shell rm -v /etc/initscripts/ttl-override /lib/systemd/system/ttl-override.service /lib/systemd/system/multi-user.target.wants/ttl-override.service
adb shell mount -o remount,ro /
adb shell systemctl daemon-reload
```
..no need to reboot.

## Enable Qualcomm Webserver

> :bowtie: This section was contributed by [GitHub user aesthernr](https://github.com/aesthernr). Thanks for the contribution!

Qualcomm provides their OEMs with a tool called QCMAP, which is used to manage the WAN connection, modem IP configuration, etc. They also provide a simple web interface that is supposed to be able to manage some features of the modem. On RM500Q's, it was enable by default, but didn't actually work. The pieces for it are present on the RM520, and it does work, it just needs some work to enable it!

- Mount the root filesystem read-write:

```bash
adb shell mount -o remount,rw /
```

- Push the files to the system:

```bash
cd /path/to/quectel-rgmii-configuration-notes/files
adb push qcmap_httpd.service /lib/systemd/system
adb push qcmap_web_client.service /lib/systemd/system
```

- Reset the username/password to admin/admin. You will be able to update this after first login.

```bash
adb push lighttpd.user /data/www
adb shell chmod www-data:www-data /data/www/lighttpd.user
```

- Symlink the systemd unit, reload systemd, start the service, and remount root as ro again:

```bash
adb shell chmod +x /etc/initscripts/start_qcmap_httpd
adb shell chmod +x /etc/initscripts/start_qcmap_web_client_le
adb shell ln -s /lib/systemd/system/qcmap_httpd.service /lib/systemd/system/multi-user.target.wants/
adb shell ln -s /lib/systemd/system/qcmap_web_client.service /lib/systemd/system/multi-user.target.wants/
adb shell systemctl daemon-reload
adb shell systemctl start qcmap_httpd
adb shell systemctl start qcmap_web_client
adb shell mount -o remount,ro /
```

- Open your Browser to [http://192.168.225.1/QCMAP.html](http://192.168.225.1/QCMAP.html) (replace the IP if necessary) - you can authenicate as admin/admin. It will prompt you to change your password after login. Note that WLAN settings will not do anything unless you have a supported wireless card connected via PCIe; that is out of scope for this document. It's also unknown if all the other functions will work as expected - however, a factory reset should wipe out all of these settings.

## Enable journald logging

By default, journald is masked on the modem - IE, nothing systemd does will end up having persistent logs. To fix this, we need to manually modify files in the root filesystem, as /etc isn't available at the point this is started.

Before enabling, I would recommend modifying /lib/systemd/journald.conf.d/00-systemd-conf.conf with some tweaks to prevent it from using lots of space:

```bash
adb shell mount -o remount,rw /
adb shell
# vi /lib/systemd/journald.conf.d/00-systemd-conf.conf
###edit params as below, and then save changes, and exit the shell###
adb shell mount -o remount,ro /
```

The config file by default has:

```bash
[Journal]
ForwardToSyslog=yes
RuntimeMaxUse=64M
```

I would recommend:

```bash
[Journal]
ForwardToSyslog=no
RuntimeMaxUse=16M
Storage=volatile
# Lots of spammy units, so limit the logging bursts.
RateLimitIntervalSec=5m
RateLimitBurst=100
```

This disables forwarding to the syslog daemon (to avoid taking up space twice), forces runtime (RAM) storage, and limits it to 16mb. It also enables fairly aggressive rate limiting, so that apps like ipacm won't force constant rotation.  (Each service gets its own rate limit.)

Here's how to enable the service:

```bash
adb shell mount -o remount,rw /
adb shell rm /lib/systemd/system/sysinit.target.wants/systemd-journald.service /lib/systemd/system/sockets.target.wants/systemd-journald.socket /lib/systemd/system/sockets.target.wants/systemd-journald-dev-log.socket
adb shell ln -s /lib/systemd/system/systemd-journald.service /lib/systemd/system/sysinit.target.wants/systemd-journald.service
adb shell ln -s /lib/systemd/system/systemd-journald.socket /lib/systemd/system/sockets.target.wants/systemd-journald.socket
adb shell systemctl daemon-reload
adb shell systemctl start systemd-journald.socket systemd-journald.service systemd-journald-dev-log.socket
# Also, to avoid lots of junk about write perms on unit files.. if you push the systemd units from a windows box, you might need to clean this up more often!
adb shell chmod 644 /lib/systemd/system/*.service /lib/systemd/system/*.socket /lib/systemd/system/*.conf
adb shell chmod 644 /lib/systemd/system/dbus.service.d/dbus.conf /lib/systemd/system/systemrw.mount.d/systemrw.conf
adb shell mount -o remount,ro /
```

Then, we have to unmount the mounted /etc directory, and remove the underlying masking of journald. We'll need to reboot the system to get the real /etc back:

```bash
adb shell umount -l /etc
adb shell mount -o remount,rw /
adb shell rm /etc/systemd/system/systemd-journald.service
adb shell mount -o remount,ro /
adb shell sync
adb shell reboot -f
```

If you also want to enable audit logs, also do the following as part of the above:

```bash
adb shell rm /lib/systemd/system/sockets.target.wants/systemd-journald-audit.socket
adb shell ln -s /lib/systemd/system/systemd-journald-audit.socket /lib/systemd/system/sockets.target.wants/systemd-journald-audit.socket
```

I am leaving systemd-journal-flush disabled (masked), as we don't want to write the logging data to persistent storage. Well - if you do you can change the Storage to "persistent" in the config file, and also symlink the systemd-journal-flush to actually switch from volitile to persistent storage on bootup.

## Other interesting things to check over ADB

### Making sure you're connected to the right modem

If you have multiple modems connected to one host, as I do, it can be hard to remember which serial number is which modem. There is a file in /etc that at least shows you the model number:

```
/ # cat /etc/quectel-project-version
Project Name: RM520NGL_VC
Project Rev : RM520NGLAAR01A07M4G_01.201
Branch  Name: SDX6X
Custom  Name: STD
Package Time: 2023-03-14,09:49
```

### AT Command Access from ADB

It appears that the following processes are used to expose the serial ports via USB:
```
  155 root      0:00 /usr/bin/port_bridge at_mdm0 at_usb0 0
  162 root      0:00 /usr/bin/port_bridge smd7 at_usb2 1
```

The daemon for AT over Ethernet also interfaces with smd7:
```
/tmp # fuser /dev/smd7
162 809
/tmp # ps | grep -E '(162|809)'
  162 root      0:00 /usr/bin/port_bridge smd7 at_usb2 1
  809 root     28:22 /usr/bin/ql_nw_service
23314 root      0:00 grep -E (162|809)
/tmp # lsof -p 809 2>/dev/null | grep -Ev '/usr/bin|/lib/|/dev/null|/$'
COMMAND   PID     USER   FD      TYPE     DEVICE SIZE/OFF  NODE NAME
ql_nw_ser 809        0    3u     unix 0x00000000      0t0 18565 type=SEQPACKET
ql_nw_ser 809        0    4u     sock        0,8      0t0 18740 protocol: QIPCRTR
ql_nw_ser 809        0    5r     FIFO       0,11      0t0 18741 pipe
ql_nw_ser 809        0    6w     FIFO       0,11      0t0 18741 pipe
ql_nw_ser 809        0    7u     sock        0,8      0t0 18863 protocol: QIPCRTR
ql_nw_ser 809        0    8r     FIFO       0,11      0t0 18864 pipe
ql_nw_ser 809        0    9w     FIFO       0,11      0t0 18864 pipe
ql_nw_ser 809        0   10u      CHR      246,4      0t0  6291 /dev/smd7
ql_nw_ser 809        0   11u     IPv4      20353      0t0   TCP *:1555 (LISTEN)
ql_nw_ser 809        0   12u  a_inode       0,12        0  6222 [eventpoll]
```

So, a simple way to send/receive commands.. open two adb shell sessions to the modem, in one, run `cat /dev/smd7`. In the other, you run the AT commands. Example:

Listening shell:
```
/ # cat /dev/smd7
AT
OK
ATI
Quectel
RM520N-GL
Revision: RM520NGLAAR01A07M4G

OK
```

Command shell:
```
/tmp # echo -e 'AT \r' > /dev/smd7
/tmp # echo -e 'ATI \r' > /dev/smd7
```

It appears that smd11 and at_mdm0 can also be used for this. On a default-ish modem, it appears that smd7 and at_mdm0 are both used by running daemons, so I picked smd11 for my AT daemon. There is a service called 'quectel-uart-smd.service', in it's unit file it disables the quectel_uart_smd, and says that smd11 is used by MCM_atcop_svc. However, I see no signs of that on the system.. so I think it's probably the safest to use.
