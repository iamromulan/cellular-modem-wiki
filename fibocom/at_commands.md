> :book: WIP ############### content and formatting to fix

# Sending AT Commands

If you plan to use the RM551E-GL in an ethernet sled you need to edit some modem configurations. Use your favorite serial appplication (i.e TeraTerm)

  AT+QCFG="pcie/mode" // query status
  AT+QCFG="pcie/mode",1 // set mode 
  +QCFG: "pcie/mode",1
  AT+QCFG="usbnet" // query status
  AT+QCFG="usbnet",1 // set mode
  +QCFG: "usbnet",1
  AT+CFUN=1,1 // reboot to apply

  AT+EGMR=0,7 // read IMEI or AT+GSN
  +EGMR: "###############"
  AT+EGMR=1,7,"###############" // [Repairs the IMEI to something else if incorrect]
  AT+CFUN=1,1

  AT+COPS? // query operator
  +COPS: 0,0,"spusu",7
  +COPS: 0,0,"VERY",13

  AT+CGDCONT? // query APN, 1 is for internet, don't touch 2 and 3
  +CGDCONT: 1,"IPV4V6","YOUR_APN_HERE","0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0",0,0,0,0,,,,,,,,,,"",,,,0
  +CGDCONT: 2,"IPV4V6","ims","0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0",0,0,0,0,,,,,,,,,,"",,,,0
  +CGDCONT: 3,"IPV4V6","sos","0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0",0,0,0,1,,,,,,,,,,"",,,,0

  i.e AT+CGDCONT=1,"IP","web"
  i.e AT+CGDCONT=1,"IPV4V6","internet.it"

  AT+CEREG?
  +CREG: 0,0
  AT+CEREG=1 # invia richiesta registrazione cella 4G/LTE, necessaria anche per 5Gnsa
  AT+CEREG?
  +CEREG: 1,1

  AT+C5GREG? # in 5G nsa serve registrazione?
  +C5GREG: 0,0
  AT+C5GREG=1 # invia richiesta registrazione cella 5G
  AT+C5GREG?
  +C5GREG: 1,0

  AT+QMAP="WWAN" (Show currently assigned IPv4 and IPv6 from the provider)
  +QMAP: "WWAN",1,1,"IPV4","10.3.62.201"
  +QMAP: "WWAN",1,1,"IPV6","2a02:b025:11:16dc:e1ae:581:fcbc:823b

  AT+QMAP="LANIP",IP_start_range,IP_end_range,Gateway_IP  (Set IPv4 Start/End range and Gateway IP of DHCP for VLAN0)
  AT+QMAP="LANIP"
  +QMAP: "LANIP",192.168.224.100,192.168.227.99,192.168.224.1

  AT+QMAP="auto_connect"
  +QMAP: "auto_connect",0,1
  +QMAP: "auto_connect",1,0
  +QMAP: "auto_connect",2,0
  +QMAP: "auto_connect",3,0

  AT+QMAP="MPDN_status"
  +QMAP: "MPDN_status",0,0,0,0
  +QMAP: "MPDN_status",1,0,0,0
  +QMAP: "MPDN_status",2,0,0,0
  +QMAP: "MPDN_status",3,0,0,0

  AT+QMBNCFG="AutoSel",0;+QMBNCFG="Deactivate" // set to manual sel
  AT+QMBNCFG="list"
  AT+QMBNCFG="select","ROW_Commercial"
  AT+CFUN=0
  AT+CFUN=1

  AT+QNWPREFCFG="mode_pref"
  +QNWPREFCFG: "mode_pref",AUTO // change to LTE+5Gnsa 
  AT+QNWPREFCFG="mode_pref",NR5G:LTE

  AT+QNWPREFCFG="nr5g_disable_mode"
  +QNWPREFCFG: "nr5g_disable_mode",0

  AT+QCAINFO
  +QCAINFO: "PCC",400,50,"LTE BAND 1",1,201,-75,-11,-44,15
  +QCAINFO: "SCC",3350,100,"LTE BAND 7",1,20,-95,-15,-70,0,0,-,-
  +QCAINFO: "SCC",1500,50,"LTE BAND 3",1,201,-87,-13,-65,0,0,-,-
  +QCAINFO: "SCC",1650,100,"LTE BAND 3",1,201,-89,-15,-64,0,0,-,-

  AT+CGACT?
  +CGACT: 1,1
  +CGACT: 2,1
  +CGACT: 3,0
  AT+CGACT=1 ERRORE
  AT+CGACT=1,1 ERRORE

  AT+QMAPWAC? (get current status of auto connect, 0=disabled 1=enabled)
  AT+QMAPWAC=1 (enable auto connect internet for ethernet)

