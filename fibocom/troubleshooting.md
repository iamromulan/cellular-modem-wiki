# ADB operations

Launch PoweShell-> C:\Windows\system32>
adb devices
  * daemon not running; starting now at tcp:5037
  * daemon started successfully
  List of devices attached
  cad1fce5	device
  d3863fb8	device

adb shell
uname -a
  Linux RM551E-GL 5.15.144-perf #1 SMP PREEMPT Mon Jun 23 02:28:02 UTC 2025 aarch64 GNU/Linux

ping 8.8.8.8 -c 3 # or press ctrl+x to exit from pinging
  in case you loose 100% packet run "AT+CFUN=1,1" or power cycle the modem to regain connection

# NO -> cd /tmp && wget -O rcPCIe_SDXPINN_toolkit.sh https://raw.githubusercontent.com/iamromulan/quectel-rgmii-toolkit/SDXPINN/rcPCIe_SDXPINN_toolkit.sh && chmod +x rcPCIe_SDXPINN_toolkit.sh && ./rcPCIe_SDXPINN_toolkit.sh && cd /
