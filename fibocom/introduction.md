Fibocom Modem Wiki
=================================
> :book: This is a living Wiki. Changes may be made as more discoveries are made or more community software is made. If you feel like you have information to contribute to this wiki please open a pull request.

# Introduction to Fibocom Modems

To do: Add info here

# Prerequisites for Windows PC

Install drivers from https://www.dropbox.com/scl/fi/veni1yp97axjrp10dn46y/FbUSBDeviceSetup_v2.1.2.5-2.7z?rlkey=dtbw82bb5qjhjd1y71q0z62bz&st=3cby476k&dl=0

Install QPST_2.7.496_installer.zip from https://mega.nz/folder/CRFWlIpQ#grOByBgkfZe5uLMkX2M2XA/file/ndt2RRyJ

Install QFIL (see QuecDeploy)

Install serial communication application (i.e TeraTerm).

# Connect to the modem

Insert the FM190W modem into m.2-to-usb adapter. In case your Windows system autoconnects the the FM190W, go to "Control Panel\Network and Internet\Network Connections and Network" and disable network interface for the modem.
The FM190W (hardware version 01, rev4) is delivered in AT+GTUSBMODE=32 functionality and exposes 4 serial ports and you will get DIAG + MODEM + AT + PIPE + RMNET functionality. In case you need to change GTUSBMODE consult Fibocom AT Commands pdf guide on https://github.com/KFOq/Doc/blob/main/Fibocom_AT%20Commands%20User%20Manual_MBB_V2.4.pdf and use the serial port application (i.e TeraTerm) to send specific AT commands.
