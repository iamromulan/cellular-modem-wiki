# RM520N-GL
![](https://github.com/iamromulan/RM520N-GL/blob/main/Images/rm520.png?raw=tru)

The Quectel RM520N-GL is a cellular NR/LTE (5G/4G) M.2 B-Key modem module specially optimized for a variety of applications and usage scenarios utilizing the Qualcomm x62 platform.

You will find Tools, Docs, and Firmware for it here, as well as a .exe (QuecDeploy) that installs everything for windows.

# Table of Contents
- [Connection Methods](#connection-methods)
- [QuecDeploy](#quecdeploy)
- [Where to Buy](#where-to-buy)
- [Toolz](#toolz)
- [Firmware](#firmware)
- [Firmware update instructions](#firmware-update-instructions)
- [Enter Emergency Download Mode](#edl-mode)
- [How to use Qnavigator to send AT commands](#how-to-use-qnavigator-to-send-at-commands)
- [AT commands](#at-commands)
- [Other Docs](#other-docs)
- [Description of antenna connection](#description-of-antenna-connection)
- [Specification](#specification)

## Connection Methods
The modems M.2 B-Key interface is a combination of both USB 3.1 and PCIe 4.0 along with additional pins for things like the SIM slots. For exact information about what pin is what, see the hardware design document. The modem supports being used in 3 different ways:
- USB 3.1
- PCIe EP (Endpoint)
- PCIe RC (Root Complex mode)

>:x: Technically there is a 4th (RGMII) thats similar to PCIe RC, however this method is rarely utilized and will not be covered here. For a while I incorrectly referred to PCIe RC as RGMII, however they are indeed different from each other.

**To further understand; take a look at the following graph:**
![](https://github.com/iamromulan/RM520N-GL/blob/main/Images/connection_methods.png?raw=tru)

- Initiators refers to what is in charge of initially connecting and keeping the connection up. 
     - TE refers to the host (whatever the modem is hooked up to) will be in charge of connection management 
     - AP refers to the Linux OS running on the modem itself (the modem will be in charge of itself)
- Both USB and PCIe can be used at the same time to connect. In PCIe Endpoint mode only the TE initiator is available to be used.
- In TE modes the IP address(es) is always passed through to the host.
- :x:It is recommended to not use PCIe and USB both in a TE mode at the same time. This causes the modem to request 2 IPv4 and IPv6 addresses from the cell carrier. While this is posable, and I have seen it work, it tends to be pretty unstable.
- In AP modes the modems onboard DHCP server is used by default. If you want to enable IP passthrough in AP mode then ``AT+QMAP="mpdn_rule"`` must be used to specify where you want the IP to passthrough to. You have a choice between passing it to a USB device (using an AP protocol) or the PCIe RC's endpoint, like the ethernet chipset of a RJ45/PHY board for example. 

### USB modes
- When presented as a USB  modem to a device/host there are 4 different USB modes (protocols/standards) that it can present itself as. 2 of them, the modem is presented as a full cellular modem to the host and the host will be in charge (TE). Those modes are NDIS (Referred to as QMI in the past) and MBIM. The other 2; ECM and RNDIS; the modem is in charge (AP) and the host will view it as a USB ethernet port. It will simply ask for an IP address and that's it.
- You can view what USB mode the modem is in with the AT command: ``AT+QCFG="usbnet"``
  - To set it to a particular USB mode:
    - ``AT+QCFG="usbnet",0`` (NDIS/QMI) (TE) (Default)
    - ``AT+QCFG="usbnet",1`` (ECM) (AP)
    - ``AT+QCFG="usbnet",2`` (MBIM) (TE)
    - ``AT+QCFG="usbnet",3`` (RNDIS) (AP)
- :bulb: After setting a USB mode reboot to have it  take effect with ``AT+CFUN=1,1``

### PCIe modes
- PCIe devices can take 2 different roles. Its either an endpoint device or a root complex (host) device. For example, a desktop computer/PC has a graphics card or WiFi card installed to a PCIe slot. The computer would be (have) the Root Complex, while the Graphics Card or WiFi card would be the endpoint device.
- To check what PCIe mode the modem is currently in run the AT command ``AT+QCFG="pcie/mode"``
  - To set the PCIe mode to Endpoint mode (TE) run the AT command ``AT+QCFG="pcie/mode",0`` 
  - To set the PCIe mode to Root complex mode (AP) run the AT command ``AT+QCFG="pcie/mode",1``
#### PCIe EP (Endpoint Mode)(TE)
- In PCIe endpoint mode (default) the modem will act as a PCIe endpoint device. It can be installed as a device to system with a PCIe slot/Root Complex.
- :v: I personally have never used the modem in this mode, however I have recently ordered a PCIe adapter to see how the modem works in this mode so I can provide more details here. [Here is what I ordered to test out PCIe EP mode](https://www.aliexpress.us/item/3256805348610910.html?spm=a2g0o.order_list.order_list_main.5.495c1802OmVmY4&gatewayAdapt=glo2usa)

#### PCIe RC (Root Complex Mode)(AP)
- In PCIe root complex mode the modem will act as a PCIe host/root complex device. In this way the modem can be provided with an endpoint device like an Ethernet chipset or a WiFi chipset for it to use. On the RM50x, RM52x, and RM530 modems, after setting this mode you must enable the correct driver for the endpoint device you are using. 
  - For Ethernet chipsets you'll use the ``AT+QETH="eth_driver"`` command to see what driver is currently enabled, and for a list of supported drivers. 
      - For example: ``AT+QETH="eth_driver","r8125",1`` would enable the driver for the RTL8125 ethernet chipset. A good example of a ready to use board with the 2.5Gig RTL8125 ethernet chipset would be the [Rework.Network PHY Board](https://rework.network/collections/lte-home-gateway/products/5g2phy)
   - For WiFi chipsets, for example, you'd use the command ``AT+QCFG="wifi/model","fc64e"`` to select the driver for the fc64e WiFi chip
     - For now, only Quectel WiFi chips can be used. The following models are supported:
       - "fc64e","fc06e","fc06e-33","fc60e","fc08e"
      - :v: I Personaly have not seen a board on the market offering a WiFi chip other than the Quectel EVB kits.

## QuecDeploy:
![Screenshot 2024-07-31 130755](https://github.com/user-attachments/assets/dc351b48-3682-4181-b33c-843136221d1c)

**[QuecDeploy DOWNLOAD](https://github.com/iamromulan/rm520n-gl/releases)**

> :bulb: **Note:**

If you would prefer to simply explorer all of the downloads I can give you; take a look at my [Mega Public Directory](https://mega.nz/folder/CRFWlIpQ#grOByBgkfZe5uLMkX2M2XA)

**What this does**

It is a menu style Powershell script that will let you install Qflash and Qnav. ADB and fastboot are now automatically included with Qflash! It will also let you download firmware and view PDFs for several modems (by linking you to the correct repo). It heavily relies on megatools, a cli for downloading files from mega.nz
All files installed/downloaded will go to C:\Quectel\

## Where to buy

Currently the cheapest place I know to purchase an RM520N-GL modem is: [AliExpress](https://a.aliexpress.com/_mNz3KBw) for $143.19 + shipping


## Toolz:
<details>
   <summary>Windows | View</summary>

[Quectel Windows USB Driver(Q) NDIS V2.7](https://mega.nz/file/zJd1CYbL#OuzK4SaghBZuQ_RLstw--I38179sZM7TkkktL2IIsm4) (Recommended)

[Quectel Windows USB Driver(Q) ECM V1.0](https://mega.nz/file/7IEjESSB#5jj1v7F3WWVfy6cFzdvfCHxaoTENMgBW2v_94NtgpoA)

[Quectel Windows USB Driver(Q) MBIM V1.3](https://mega.nz/file/XRc0nZSQ#9hPjcrasgOQ9ej_tWQhvC6_NQC3iZMIdu0t17sz7AHE)

[Quectel Windows USB Driver(Q) RNDIS V1.1](https://mega.nz/file/vRN1ERaL#0zp9di4iFEaamkczsmw_Xaxr3fcWS7in9ODXZ73l8Lg)

[Quectel Windows PCIe Driver 1.0.0.2](https://mega.nz/file/qVlQFTaL#Fdpcf7jpl-Cg_eoauRU0U1k2jUcF2Zqv88F6SaOf8ig)

[QFlash V7.1 EN](https://mega.nz/file/bdUWiKSQ#7RPymUcm7Rgdjf9mRsWjuf9zXia5qxV7NZWMLruvb5A) 

[QFlash V6.9 EN](https://mega.nz/file/vdFH0LrB#lnrp3G4HEmgcwGTViQzpFm2iNxBYe5k_EkdGRvglJdA)

[QFlash_PCIE_V1.0](https://mega.nz/file/SB9C3JqR#1qrUfTIzL0n-Wwpsnz8MIDjH4rifp5V8Tshax5Te7Ho)

[Qnavigator V1.6.10](https://mega.nz/file/2RMFAbCT#zq3r9TmEF8REXK6PkuAXFiuyPI5Tw4oqYnHGEiSmoD4)

[QCOM V1.8.2](https://mega.nz/file/CVcFgQLI#b1AfPvmIq9N_MHQBi8MkZFphADdW3Af7Hc8kFH0LiW8)

</details>

<details>
   <summary>Linux | View</summary>

[QFirehose V1.4.17](https://mega.nz/file/HNdEHI5I#tbOhCRS5vNZ-J9eEVVD_ip-YrU2cIYeD9bLO0j24gz4)

[Quectel Linux PCIE MHI Driver V1.3.3](https://mega.nz/file/fE8T1bRZ#U3WfgbiJZpui4rQ9zBuQnGuwLJu4FaQJsWYTvvPnHhI)

[Quectel Linux Android SPRD PCIE Driver V1.1.1](https://mega.nz/file/uBk3GDRA#3iILSy8HrFaC9Ug1xV1qmOlsz_UTfM6WD4_0lgFAZ30)

[Quectel Linux Android QMI WWAN_Driver V1.2.1](https://mega.nz/file/LcsVzLjT#jBPdvFz00TBcNef3uQ1KxxnftkVl4qchZ_aTLQuY-2E)

[Quectel Linux Android GobiNet Driver V1.6.3](https://mega.nz/file/TZczXQxa#pEjC2KJoDJISxdgGyNyqOJ3Wf8eNViTdUa5snNL0G8c)

[Quectel Android RIL Driver V3.6.14](https://mega.nz/file/yEs1GTQK#fl-i61X19PEe_zVbKSahlo4SmL10ADfrmZNoJkYLOGs)

</details>

## Firmware:
<details>
   <summary>Stock | View</summary>

| Date | Version | Link |
| --- | --- | --- |
| `2024-10-09` | *RM520NGLAAR01A08M4G* | <a href="https://mega.nz/file/PMNkCLzR#MoLgG9mROATtL5LpYgFiroAudZMOOWCOAumYlPi1NFA">Download</a> |
| `2024-06-20` | *RM520NGLAAR01A08M4G* | <a href="https://mega.nz/file/eBVFhDhZ#1or8iMpmJiIKtZAPjo3rBTL2rit-pMFyZN10VSUzbgg">Download</a> |
| `2024-04-03` | *RM520NGLAAR01A08M4G* | <a href="https://mega.nz/file/ucclVCLT#chq0HzixUTPoNpG9G2duv5Xhj2JChz2ALa6QJpZJ3kY">Download</a> |
| `2024-02-01` | *RM520NGLAAR01A08M4G* | <a href="https://mega.nz/file/2NdzWKJJ#n4EbQkh17Pwfkfxzz-ZbjN5MFK6fJVRgLx6Chh43QRk">Download</a> |
| `2023-07-20` | *RM520NGLAAR01A08M4G* | <a href="https://mega.nz/file/SYMh0YwI#xLaLs8qeOMOmic1wHLROrZedZ3USmNzGrSkFddOiAzk">Download</a> |
| `2023-07-12` | *RM520NGLAAR01A07M4G* | <a href="https://mega.nz/file/LJd2yYxQ#lPdFog6G_5RFdKCltnpGKrblvEFOiW-Ctumz72LNMns">Download</a> |
| `2023-03-27` | *RM520NGLAAR01A07M4G* | <a href="https://mega.nz/file/bFdVlJAB#-vDBJ4ywc4aM68ECG2Sef2i-5VuCHk-is05Y5HRyUJM">Download</a> |
| `2023-01-20` | *RM520NGLAAR01A06M4G* | <a href="https://mega.nz/file/TJ8m1QoB#V7Gt1KHpbQIw8J66wo07PMqamGjQK1uXfu1etbjENvs">Download</a> |
| `2022-12-26` | *RM520NGLAAR01A06M4G* | <a href="https://mega.nz/file/7dVlmaRL#oGc7xp0BwjweSqACmxWHjlAZwVuBNtNa-v1z6ob43oQ">Download</a> |

</details>

<details>
   <summary>Certified | View</summary>

| Date | Version | Link |
| --- | --- | --- |
| `2024-08-09` | *RM520NGLAAR03A04M4G* | <a href="https://mega.nz/file/GYEVXZbT#h4URXFp0VVl4IWklv24bbtKiZU-bWy96WjSeGVu-Li0">Download</a> |
| `2024-03-28` | *RM520NGLAAR03A03M4G* | <a href="https://mega.nz/file/PcV0DDzA#aeQkP3V6WnzvO5BUPTw0Vm1Zdb5n9AA0Zb3ebSsHYlM">Download</a> |
| `2024-01-02` | *RM520NGLAAR03A01M4G* | <a href="https://mega.nz/file/fdE1iY4T#4q_gz03GbQZ6mR3-SdQVptelwNPrklVSPWa1VcH9pVo">Download</a> |
| `2023-11-26` | *RM520NGLAAR03A02M4GA* | <a href="https://mega.nz/file/uZsCkCyL#XxVYTEuPJJOxz1WrSHmkdTbNMvziU9LIDTPIbTh2rkg">Download</a> |
| `2023-07-25` | *RM520NGLAAR03A03M4G* | <a href="https://mega.nz/file/TJFSiBqJ#DVPT-QX60A7pSFVXxxukMDSXTZswTl39XlTEH_NWWpM">Download</a> |
| `2023-05-12` | *RM520NGLAAR03A01M4G* | <a href="https://mega.nz/file/yd8ATTCb#ZIbLL2GWnTG_j8RzMaHV4fN5P6v4zBKc1MLfGX5BXH0">Download</a> |

</details>

<details>
   <summary>Custom | View</summary>
   
| Date | Version | Link | Full Project |
| --- | --- | --- | --- |
| `R01.00.04_2023-11-07` | *Arixolink RM520NGLAAR03A01M4G OCPU_BETA_20230419C* | [Download](https://mega.nz/file/fZcUjCLK#LOav6ZB9ZK15Vm8Nph1s6LpbmHTZNn0f8MsjvFcby1c) | [Download](https://mega.nz/file/mRMVjSxB#EzL7rK5hy2VGXdj31R3jAWFDkncnvwxviaqVRzPcTY0)
   
</details>

## Firmware update instructions:

<details>
   <summary>Windows | View</summary>

Step 1.
> Install modem drivers [Quectel Windows USB Driver(Q) NDIS V2.7](https://mega.nz/file/zJd1CYbL#OuzK4SaghBZuQ_RLstw--I38179sZM7TkkktL2IIsm4)  on your system. The [QuecDeploy](#quecdeploy) tool will help you do this as well. If you don't already have QFlash 7.1 install it from the [QuecDeploy](#quecdeploy) tool or the respective link in [Toolz](#toolz)

Step 2.
> Connect modem to your computer, by USB

Step 3.
> Go to device manager and check if the new COM ports are visible in the system. Restart your computer if the new COM ports are not visible.

![](https://github.com/iamromulan/RM520N-GL/blob/main/Images/devman_ports.png?raw=tru)

> Remember the number of the COM port described as "DM Port".

Step 4.
> Open Qflash 

> Remember to avoid spaces in the path where QFlash is installed to and firmware location
> :bulb: Example: C:\Quectel\Q flash\ is bad while C:\Quectel\Qflash\ is good (If you installed Qflash and downloaded your firmware with [QuecTool](#quectool) then you don't need to worry about this.)
> Click Load FW Files.
![](https://github.com/iamromulan/RM520N-GL/blob/main/Images/qflash_loadfw.png?raw=tru)

> In the new window, go to the `\update\firehose` folder of the firmware and select the `partition_complete` file. Then click the Open button. 

>If you downloaded your firmware with [QuecTool](#quectool) then go to C:\Quectel\firmware\RM520NGL\type\fimrware\update\firehose\

![](https://github.com/iamromulan/RM520N-GL/blob/main/Images/qflash_sel_fw.png?raw=tru)

Step 5.

> Select the COM port number as the DM port from step 3 and set the baud rate to `460800`

![](https://github.com/iamromulan/RM520N-GL/blob/main/Images/portbaudqflash.png?raw=tru)

Step 6.
> Start updating modem firmware.

![](https://github.com/iamromulan/RM520N-GL/blob/main/Images/qflash_start.png?raw=tru)

</details>

<details>
   <summary>Linux (OpenWrt) | View</summary>

Step 1.
> Install the qfirehose package.
> In console, run commands.

``` bash
opkg update
opkg install qfirehose
```
Step 2.
> Using WinSCP, copy the extracted modem firmware to the \tmp folder on the router.

Step 3.
> Start updating modem firmware.
> In console, run command.

``` bash
/usr/bin/qfirehose -f /tmp/RM520NGLAAR03A02M4GA
```

</details>

## EDL Mode

<details>
   <summary> View</summary>
  
### If  for some reason something gets messed up on your modem and you are not able to see the DM port to flash firmware, theres a way to enter EDL mode (Emergency Download Mode)

Typically when you flash firmware the [normal method](#firmware-update-instructions) you use Qflash and select the DM port. When you click start, Qflash tells the DM port (Diagnostics port) to reboot into EDL mode. When the module comes back up only one port will exist: The QDLoader port. This means the modem has entered EDL mode. Qflash will then proceed to flash.

 It is also possible to enter EDL mode by using adb.
The command is:
``adb reboot edl``

However, if you have nothing showing up at all (the modem won't boot) then this is the manual way to enter EDL mode:
### Step 1
Find a m.2 board where the slot is on the edge. That way you can see the back of the module. For this example, I will use the [Rework.Network Ethernet M.2 Board](https://rework.network/collections/lte-home-gateway/products/5g2phy)

It is also possible to take a regular M.2 to USB adapter and cut the board so the back of the modem will be visible. This is dependent on the circuity layout of the particular m.2 to USB adapter board.

### Step 2
**Place the modem in the board and turn it upside down on a static free surface, and connect the USB cable to the board. Be prepared to connect it to you PC but don't do it yet.**

### Step 3

For the RM500-RM530 series modems, you'll need a small wire or cable tie. I ended up striping the ends off a cable tie. See below.....
![](https://github.com/iamromulan/RM521F-GL/blob/main/Images/edl_tool.png?raw=tru)

### Step 4
Open Device manager on your PC and keep and eye on the ports section.
Using the tool from step 3, trip the 2 contacts on the back of the modem **at the same time as plugging the USB to your PC**.  If you are successful, the QDLoader port should instantly appear. You do not need to keep the 2 contacts on the back tripped after you plug it in and see the QDLoader port. If the QDLoader port doesn't show up within 3 seconds, unplug the USB and try again.

For the RM500-RM530 modems these are the correct ports to jump:
![](https://github.com/iamromulan/RM521F-GL/blob/main/Images/edl1.jpg?raw=tru)
**Here is how I did it. Remember plug the USB in at the same time as doing this:**
![](https://github.com/iamromulan/RM521F-GL/blob/main/Images/521_edl.png?raw=tru)

### Step 5

At this point you should see the QDLoader port in device manager:
 ![](https://github.com/iamromulan/RM521F-GL/blob/main/Images/qdloader.png?raw=tru)

Follow the steps from the [normal method](#firmware-update-instructions) and treat the QDLoader port as the DM port.
</details>

## How to use Qnavigator to send AT commands

<details>
   <summary> View</summary>

Connect your modem to your computer by USB. Either through a USB to m.2 B-key sled (should have a sim slot as well) from Amazon or by using a PCIe RC (RJ45 sled) USB C port.
### If you installed by using [QuecDeploy](#quecdeploy): 
You should already have a desktop icon and start menu shortcut for Qnavigator.
#### 1. Open Qnavagator, you'll be presented with this screen, just press escape (ESC) to skip their directions. 
![COM ports](https://github.com/iamromulan/quectel-rgmii-configuration-notes/blob/main/images/qnavfirst.png?raw=true)
#### 2. Uncheck Automatic initialization (circled in red) and click the COM plug icon (circled in green)
![COM ports](https://github.com/iamromulan/quectel-rgmii-configuration-notes/blob/main/images/qnavsec.png?raw=true)
#### 3. Click ok, the correct port will already be auto selected
![qnavCOMport](https://github.com/iamromulan/quectel-rgmii-configuration-notes/blob/main/images/qnavport.png?raw=true)
#### 4. Click Connect to module, then in the lower right type your AT command and press send. The response will be shown above.
![at](https://github.com/iamromulan/quectel-rgmii-configuration-notes/blob/main/images/qnavat.png?raw=true)

</details>

## AT commands:
<details>
   <summary>View</summary>


| Date | Version | Link |
| --- | --- | --- |
| `2024-02-07` | *RM50X and RM52X series modems AT Commands (some apply to RM550/551)* | <a href="https://mega.nz/file/WZsgHZ7C#XcE0LPkzgb_aS7o8yEeCMSEA_YzCxflXBgfxOsOrt3M">View/Download</a> |
| `2023-07-31` | *RM50X and RM52X series modems AT Commands* | <a href="https://mega.nz/file/mNFyxD6K#Y_YVlSEWNn9tz9dpHvY1rSZuDR_gEB6XEVIQ0nGrCJQ">View/Download</a> |
| `2022-08-12` | *RM50X and RM52X series modems AT Commands* | <a href="https://mega.nz/file/WRFQSLIY#leMbHiKL_jmEy2LZMp1-3aI2BLW2m8vkNFl8ApT3FQw">View/Download</a> |
| `2021-08-09` | *RM50X and RM52X series modems AT Commands* | <a href="https://mega.nz/file/vEE1lR4L#FS1_8YIZgqEEcyjWG1__RMI5IeiTc6yrwU9xw6bCpsQ">View/Download</a> |
| `2020-10-09` | *RM50X and RM52X series modems AT Commands* | <a href="https://mega.nz/file/HcVVAA7Q#QuJZIaN0EkBvLYqFhSUCv_qjx0aGsSG04VXUp1huATw">View/Download</a> |

</details>


## Other Docs
<details>
   <summary>General</summary>

[[NEW!] Quectel 5G&LTE-Advanced Module Product Overview V7.1](https://www2.quectel.com/5GLTEAdvance)

[Quectel Product Brochure V7.7](https://mega.nz/file/2Z1HCKLR#8dxbdpXK-CC8_MWnJ_O4ykFqb08ljhzmj0MHK5b1nWI)

[Quectel Product Brochure V7.4](https://mega.nz/file/TEsUkTKD#iJVMKIMRH-gaIwoSZkUDgmAU3s9hjL3I1brFHeV0t-I) (Includes the canceled RM521F-GL module) 

[QCOM User Guide V1.1](https://mega.nz/file/HMsgAI7Q#kVLf7ETrE13zrsUUmdq2NUe2d26ZSkbeqgmNXQ4offw)

[QFlash User Guide V5.5](https://mega.nz/file/KFsHgbSS#kJYBxnQk3--lsXpCg0fz7V7551_GzlDPu27Uo7hPNXo)

[[Updated!] Quectel RM520N-GL Hardware Design](https://mega.nz/file/fRlBgSDb#zusk1tH29-4HGu9tJJfxkpARlbo-LBwz3h4Bqk9qTEI)

[[NEW!] Reference Design](https://mega.nz/file/TcdFgJhQ#C6zNX0rSsrLOFy5bqUk5fnPZ-W7vFQBvh8gVyOxfNmk)

[[NEW!] A/B System Update Guide](https://mega.nz/file/vAcmWAzK#3IkjR9WLL9BQjKV9SEvDsuNgp-g0Bbm-TcLtRqMR6H8)

[[NEW!] DFOTA Upgrade Process](https://mega.nz/file/zAcUEIDL#_qEpH1C3rmDpaKFTUyud4zQY88pUEKrHhN1-qzY21bE)

[[NEW!] TCP/IP Application Note](https://mega.nz/file/Oc1C1DIQ#mucxYGBrauLJAhQUKDuIB9cb_ETuod743XE_eb-boqE)

[[NEW!] Data Call Application Note](https://mega.nz/file/KV1XSYAT#sKN5N1HPjHETpk06zi7s_FXGNR2HaxIp4Qbw_cmy3Vc)

[[NEW!] eSIM LPA Application Note 1.1](https://mega.nz/file/CN1HQKyb#18bN9uZKJf6zInXDhsLWMW1mlP2tkM_QpC1X8i9r_v8)

[[NEW!] eSIM LPA Application Note 1.0](https://mega.nz/file/KU1QWYzC#9CB5ikUD6-YtcUzjaACEeA3YobYJXUhddalFRZ1KTZ4)

[[NEW!] Voice Over ttyUSB Application Note](https://mega.nz/file/aBkDSQAK#JMy2f4n-hMfDHoFbc6uQkOpr-lhc58v6Kqp0-NUH8rE)

[[NEW!] External VoLTE stack Application Note](https://mega.nz/file/KAkFyTJQ#GekOQec5Ma2THtbQRQWfsK9_z6pGpFHe1XYxS1wMw-g)

[[NEW!] File Application Note](https://mega.nz/file/jUEzlYaT#4ayxXXgZ62yr4qUPMneocvm_1ZhZ_N9y1mclvi5rrv4)

[[NEW!] GNSS Application Note](https://mega.nz/file/fY1w3QIK#XyrfW-cIHq30ZsLwFS7pJxc-6ZwAAP32Omh7IPLbSeY)

[[NEW!] HTTP(S) Application Note](https://mega.nz/file/nc810Jhb#gsnFEC8vhGYV_IY6boIKraz-aTnIr8oFOoAuph6lndM)

[[NEW!] Software Thermal Management Guide](https://mega.nz/file/6cNWERgL#hNHEBKAbLoZzzUoBxdzHmyH_TR9cAV1gM5SCCyKLlHA)

[[NEW!] Thermal Design Guide](https://mega.nz/file/bJE1zbDQ#gj1-4KrFbhLLbSUaoaKNhbVRz7M-X5beMXFcwwbyGss)

[[NEW!] 5G Network Status Judgement Introduction](https://mega.nz/file/aIsWgKRB#n7YcwAsreFfCYTcTw0Vk06Y0EQk6yYwa8AwP1IMuRHQ)

[[NEW!] CA Combos Spreadsheet](https://mega.nz/file/HIMRkAwA#7O19pLJwHKF2cYRs_y68sKo2Vd7HmjRmmBrnUOFrSuo)

</details>

<details>
   <summary>[NEW!] QuecOpen</summary>

[DFOTA Generation Tool Directions](https://mega.nz/file/LRVDDYCQ#VFARx9j_0g43LaBS_-4IPDjQwAR55dePl4eVgFQcGXY)

[[NEW!] FullFOTA Update Guide](https://mega.nz/file/qBt3jTBD#f7KaTzcHwtDhBO6pmucQUqjfUh2Ue91ywMasldNrCh4)

[[NEW!] Virtual Port Programming for AT Command Sending and Receiving Guide](https://mega.nz/file/LNMUAarY#auGqgn3m-6_s1v3jOQ3W7YiqfKU_2Obn5mGMzbtPXzY)

[[NEW!] Device Management and Cellular Network Development Guide](https://mega.nz/file/nQdUlS5S#u9NCOPapYfc6LlCzC2SYSPKORokG3NGMwV7L7u_cjRM)

[[NEW!] Linux System Time Synchronization Guide](https://mega.nz/file/3d1HlKYL#j3dEHFOHTpaMbogDgn2WCRSiilWNMzila21eZHwvmok)

[[NEW!] Open-Source Software Package Cross-Compilation Guide](https://mega.nz/file/mdkU1b6A#gjq-N6__TMZrSTe4oXurworrwDlUsCDCCHJg-pQ2fXk)

[[NEW!] SIM and SMS Development Guide](https://mega.nz/file/uQ0BkS5Z#uaSgFc8yEbHKuS0_vefbVeeZHEVsfJ27PhehivArQcw)

[[NEW!] Upgrade via LAN Application Note](https://mega.nz/file/6Q1Q0R5Z#WQyE8ab0PgTkFQDeV_g5qxDom-4KQB2vyvqARyEG09o)

</details>

## Description of antenna connection:
<details>
   <summary>View</summary>
 
![](https://github.com/iamromulan/RM520N-GL/blob/main/Images/520_ant_pairs.png?raw=tru)
![](https://github.com/iamromulan/RM520N-GL/blob/main/Images/520_ant_discrip.png?raw=tru)

</details>

## Specification:
![](https://github.com/iamromulan/RM520N-GL/blob/main/Images/rm520_specs_2.png?raw=tru)
![](https://github.com/iamromulan/RM520N-GL/blob/main/Images/520_salesdoc.png?raw=tru)
![](https://github.com/iamromulan/RM520N-GL/blob/main/Images/rm520_specs.png?raw=tru)
