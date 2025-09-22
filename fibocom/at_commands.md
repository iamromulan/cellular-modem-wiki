Fibocom Modem Wiki
=================================
> :book: This is a living Wiki. Changes may be made as more discoveries are made or more community software is made. If you feel like you have information to contribute to this wiki please open a pull request.

# Sending AT Commands

If you plan to use the RM551E-GL in an ethernet sled you need to edit some modem configurations. Most of these steps are optional since the custom firmwares are pre-configured. Use your favorite serial appplication (i.e TeraTerm) on the AT Port of your serial connection. 

// query status 0 // ADB status and unlock\
AT+QCFG="usbcfg" // query status\
  +QCFG: "usbcfg",0x2C7C,0x0122,1,1,1,1,1,<0>,0 // if initial response is locked <0>\
AT+QSECCFG="adb_auth",""\
AT+QCFG="usbcfg",0x2C7C,0x0122,1,1,1,1,1,1,0 // Enable ADB

// query status 1
AT+QCFG="pcie/mode";+QCFG="usbnet";+EGMR=0,7;+CGDCONT?;+CEREG?;+C5GREG?;+COPS?;+QNWPREFCFG="mode_pref";+QMAP="WWAN"

// set values 1
AT+EGMR=1,7,"<YOUR_IMEI_HERE>";+QCFG="pcie/mode",1;+QCFG="usbnet",1;+CGDCONT=1,"IPV4V6","<YOUR_APN_HERE>";+CEREG=2;+C5GREG=2
// AT+EGMR=1,7,"<YOUR_IMEI_HERE>" // repairs IMEI
// AT+QCFG="pcie/mode",1;+QCFG="usbnet",1 // set Dual PHY 2.5
// AT+CGDCONT=1,"IPV4V6","<YOUR_APN_HERE>" 
// AT+CEREG=2;+C5GREG=2
// AT+QNWPREFCFG="mode_pref",NR5G:LTE


// query status 2
AT+QMBNCFG="AutoSel";+QMBNCFG="select";+QMBNCFG="list"

// set values 2
AT+QMBNCFG="AutoSel",0;+QMBNCFG="Deactivate";+QMBNCFG="select","ROW_Commercial"
// AT+QMBNCFG="AutoSel",0
// AT+QMBNCFG="Deactivate" // if this option is already deactivated ì, yuo'll receive error
// AT+QMBNCFG="select","ROW_Commercial"


// query status 3
AT+QCAINFO;+CGACT?;+QMAPWAC? // "1" to enable auto connect internet for ethernet


// query and set APN - status 4
AT+CGDCONT?
  +CGDCONT: 1,"IPV4V6","","0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0",0,0,0,0,,,,,,,,,," // <MISSING_APN!!!>
AT+CGDCONT=1,"IPV4V6","<YOUR_APN_HERE>"


// turn off and on FUNctionality to take effect
AT+CFUN=0;+CFUN=1
AT+CFUN=1,1

// force all values to take effect
POWER CYCLE the modem+m.2 adaptor to force effect to all changes

