Fibocom Modem Wiki
=================================
> :book: This is a living Wiki. Changes may be made as more discoveries are made or more community software is made. If you feel like you have information to contribute to this wiki please open a pull request.

# Introduction to Fibocom Modems

To do: Add info here

# Prerequisites for Windows PC

> Install the latest NDIS Driver + ECM driver.\
> Get it from [QuecDeploy](https://github.com/iamromulan/QuecDeploy/releases) or\
> from my [Mega Public Folder](https://mega.nz/folder/CRFWlIpQ#grOByBgkfZe5uLMkX2M2XA) or\
> from https://www.dropbox.com/scl/fi/veni1yp97axjrp10dn46y/FbUSBDeviceSetup_v2.1.2.5-2.7z?rlkey=dtbw82bb5qjhjd1y71q0z62bz&st=3cby476k&dl=0

> Install QPST_2.7.496_installer.zip from https://mega.nz/folder/CRFWlIpQ#grOByBgkfZe5uLMkX2M2XA/file/ndt2RRyJ

> Install QFIL (see QuecDeploy)

> Install serial communication application (i.e TeraTerm).

# Connect to the modem

> Connect modem to your computer, by USB, inserting the FM190W modem into m.2-to-usb adapter. If your Windows system autoconnects the the FM190W, go to "Control Panel\Network and Internet\Network Connections and Network" and disable network interface for the modem.

> The FM190W (hardware version 01, rev4) is delivered in AT+GTUSBMODE=32 functionality and exposes 4 serial ports and you will get DIAG + MODEM + AT + PIPE + RMNET functionality. In case you need to change GTUSBMODE consult Fibocom AT Commands pdf guide on https://github.com/KFOq/Doc/blob/main/Fibocom_AT%20Commands%20User%20Manual_MBB_V2.4.pdf and use the serial port application (i.e TeraTerm) to send specific AT commands.

> Go to device manager and check if the new COM ports are visible in the system. Restart your computer if the new COM ports are not visible.

![](./images/devman_ports.png)

> Remember the number of the COM port described as DIAGnostic "DM Port".

# Launch QuecDeploy

> Goto Firmware downloads -> RM551E-GL -> R01 -> Custom Firmware -> Select the needed version
> The zip file will be downloaded to "C:\Quectel\firmware\RM551EGL\R01\Custom\<version>_iamromulan_basic_eth"
> Flash "basic_eth" if you plan to use the RM551E-GL in an ethernet sled.

# File Path Note

>:bulb: Both the path to Qflash and your extracted firmware must not have spaces in it. Example: C:\Quectel\Q flash\ is bad while C:\Quectel\Qflash\ is good. If you installed Qflash and got your firmware through [QuecDeploy](https://github.com/iamromulan/QuecDeploy/releases) then you don't have to worry about this. 

# Firmware flashing

> You'll need a bunch of ubi files and others along with a firehose folder. Copy everything in there into the firehose folder. Make sure the path to the firmware doesn't have any spaces in it at all, like "C:\Users\user name\firmware" is bad. "C:\Users\username\firmware" is good. This is why I just use C:\Quectel for QuecDeploy.
> Once the flash completes wait for the ports to come back up in device manager. Once they come back, wait about 30 seconds +/- for the second reboot to occur. AT+QCFG= pcie/mode,1 and AT+QCFG=usbnet,1 are sent then it reboots. Once the second reboot occurs ethernet will be working with Luci and SSH acess at 192.168.224.1. Pre-set root password is "iamromulan".

