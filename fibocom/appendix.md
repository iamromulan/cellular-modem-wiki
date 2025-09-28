# APPEDIX

# ADB operations

> Launch PoweShell-> C:\Windows\system32> \
> adb devices\
> \* daemon not running; starting now at tcp:5037\
> \* daemon started successfully\
>   List of devices attached\
>   cad1fce5	device\
>   d3863fb8	device

> adb shell \
> uname -a \
> Linux RM551E-GL 5.15.144-perf #1 SMP PREEMPT Mon Jun 23 02:28:02 UTC 2025 aarch64 GNU/Linux

> ping 8.8.8.8 -c 3 # or press ctrl+x to exit from pinging \
> in case you loose 100% packet try following tips:
> * run AT+CFUN=1,1
> * double check APN with AT+CGDCONT?
> * power cycle the modem to regain connection

> Manual toolkit installation via ADB \
> cd /tmp && wget -O rcPCIe_SDXPINN_toolkit.sh https://raw.githubusercontent.com/iamromulan/quectel-rgmii-toolkit/SDXPINN/rcPCIe_SDXPINN_toolkit.sh && chmod +x rcPCIe_SDXPINN_toolkit.sh && ./rcPCIe_SDXPINN_toolkit.sh && cd /

# Install zerotier
Use ssh console at http://192.168.224.1/cgi-bin/luci/admin/services/ttyd
opkg update
opkg install luci-app-zerotier
uci set zerotier.sample_config.enabled='1'
uci set zerotier.sample_config.join='<network_id>'
uci commit zerotier
// reboot module to take effect

# Troubleshooting
In case you brick the modem you can try to send 1.8v to the test point on the back of the modem (see attached image)
If you set GTUSBMODE=31, all the serial ports will be lost. To get back them back, put your modem into a openwrt router, and send this command:
\> echo 05c6 90db > /sys/bus/usb-serial/drivers/option1/new_id

# Credits
Thanks to the modems's guru "@iamromulan" and a freindly telegram user "@zigmabeta" that help me to start this step-by-step-guide

Return to the [Introduction](./introduction.md)
