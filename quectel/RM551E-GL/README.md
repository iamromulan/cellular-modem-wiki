# RM551E-GL
![](https://github.com/iamromulan/RM551E-GL/blob/main/Images/RM551.png?raw=tru)
>:warning: The RM551E-GL is brand new and is currently in ES1 phase (Engineering Sample 1) 
>My modem the the above picture, if you read the SN: E1 (ES1) Y24 (2024), D64 (Unknown), Unit 9 (Modem #9)

The Quectel RM551E-GL is a cellular NR/LTE (5G/4G) M.2 B-Key modem module specially optimized for a variety of applications and usage scenarios utilizing the Qualcomm x75 platform.

# SDXPINN Toolkit:
 
 - Openwrt repo + Setup script for the OpenWRT system running on the modem itself
 - https://github.com/iamromulan/quectel-rgmii-toolkit/tree/SDXPINN

You will find Tools, Docs, and Firmware for it here, as well as a .exe (QuecDeploy) that installs everything for windows.

# Table of Contents
- [Connection Methods](#connection-methods)
- [QuecDeploy](#quecdeploy)
- [Where To Buy](#where-to-buy)
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
![](https://github.com/iamromulan/RM551E-GL/blob/main/Images/connection_methods.png?raw=tru)

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
- You will need special [PCIe drivers for windows](https://mega.nz/file/qVlQFTaL#Fdpcf7jpl-Cg_eoauRU0U1k2jUcF2Zqv88F6SaOf8ig) to use the modem over PCIe EP

#### PCIe RC (Root Complex Mode)(AP)
- In PCIe root complex mode the modem will act as a PCIe host/root complex device. In this way the modem can be provided with an endpoint device like an Ethernet chipset or a WiFi chipset for it to use. On the RM50x, RM52x, and RM530 modems, after setting this mode you must enable the correct driver for the endpoint device you are using. 
  - For Ethernet chipsets you'll use the ``AT+QETH="eth_driver"`` command to see what driver is currently enabled, and for a list of supported drivers. 
      - For example: ``AT+QETH="eth_driver","r8125",1`` would enable the driver for the RTL8125 ethernet chipset. A good example of a ready to use board with the 2.5Gig RTL8125 ethernet chipset would be the [Rework.Network PHY Board](rework.network/collections/lte-home-gateway/products/5g2phy)
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

## Where To Buy

The RM551E-GL is back in stock! For the best deal on one of these send [Dexter Labrooy](https://www.facebook.com/dexter.labrooy) a message.

## Toolz:
<details>
   <summary>Windows | View</summary>

[Quectel Windows USB Driver(Q) NDIS V2.7](https://mega.nz/file/zJd1CYbL#OuzK4SaghBZuQ_RLstw--I38179sZM7TkkktL2IIsm4) (Recommended)

[Quectel Windows USB Driver(Q) ECM V1.0](https://mega.nz/file/7IEjESSB#5jj1v7F3WWVfy6cFzdvfCHxaoTENMgBW2v_94NtgpoA)

[Quectel Windows USB Driver(Q) MBIM V1.3](https://mega.nz/file/XRc0nZSQ#9hPjcrasgOQ9ej_tWQhvC6_NQC3iZMIdu0t17sz7AHE)

[Quectel Windows USB Driver(Q) RNDIS V1.1](https://mega.nz/file/vRN1ERaL#0zp9di4iFEaamkczsmw_Xaxr3fcWS7in9ODXZ73l8Lg)

[Quectel Windows PCIe Driver 1.0.0.2](https://mega.nz/file/qVlQFTaL#Fdpcf7jpl-Cg_eoauRU0U1k2jUcF2Zqv88F6SaOf8ig)

[QFlash V7.1 EN](https://mega.nz/file/bdUWiKSQ#7RPymUcm7Rgdjf9mRsWjuf9zXia5qxV7NZWMLruvb5A) 

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
| `2024-08-05` | *RM551EGL00AAR01A01M8G* | <a href="https://mega.nz/file/aAdVHTST#dOzRfehUUbcUFH3Yoo-n58m68wgHcEXhcnKYuo2nMo4">Download</a> |
| `2024-06-24` | *RM551EGL00AAR01A01M8G_BETA (PCIe RC Working)* | <a href="https://mega.nz/file/DQlFiSTA#DwvN0Sw3jSp75yxhb6drmZGB_IiQWhixXsZ8Da-qqeg">Download</a> |
| `2024-04-28` | *RM551EGL00AAR01A01M8G_BETA* | <a href="https://mega.nz/file/jJUWhIgC#inwjWgTnrSU1_H8FRFR_Rm7X_AaqaO8uZVj2Q1Kp1s4">Download</a> |

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

![](https://github.com/iamromulan/RM551E-GL/blob/main/Images/devman_ports.png?raw=tru)

> Remember the number of the COM port described as "DM Port".

Step 4.
> Open Qflash 

> Remember to avoid spaces in the path where QFlash is installed to and firmware location
> :bulb: Example: C:\Quectel\Q flash\ is bad while C:\Quectel\Qflash\ is good (If you installed Qflash and downloaded your firmware with [QuecTool](#quectool) then you don't need to worry about this.)
> Click Load FW Files.
![](https://github.com/iamromulan/RM551E-GL/blob/main/Images/qflash_loadfw.png?raw=tru)

> In the new window, go to the `\update\firehose` folder of the firmware and select the `partition_complete` file. Then click the Open button. 

>If you downloaded your firmware with [QuecTool](#quectool) then go to C:\Quectel\firmware\RM551EGL\type\fimrware\update\firehose\

![](https://github.com/iamromulan/RM551E-GL/blob/main/Images/qflash_sel_fw.png?raw=tru)

Step 5.

> Select the COM port number as the DM port from step 3 and set the baud rate to `460800`

![](https://github.com/iamromulan/RM551E-GL/blob/main/Images/portbaudqflash.png?raw=tru)

Step 6.
> Start updating modem firmware.

![](https://github.com/iamromulan/RM551E-GL/blob/main/Images/qflash_start.png?raw=tru)

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
Find a m.2 board where the slot is on the edge. That way you can see the back of the module. For this example, I will use the [Rework.Network Ethernet M.2 Board](rework.network/collections/lte-home-gateway/products/5g2phy)

It is also possible to take a regular M.2 to USB adapter and cut the board so the back of the modem will be visible. This is dependent on the circuity layout of the particular m.2 to USB adapter board.

### Step 2
**Place the modem in the board and turn it upside down on a static free surface, and connect the USB cable to the board. Be prepared to connect it to you PC but don't do it yet.**

### Step 3

For the RM550/551 modems, you can use a paper clip. Be sure to bend the ends so the sides the paper clip can be used instead of the tips. See below.....
![](https://github.com/iamromulan/RM551E-GL/blob/main/Images/edl_tool.png?raw=tru)

### Step 4
Open Device manager on your PC and keep and eye on the ports section.
Using the tool from step 3, trip the 2 contacts on the back of the modem **at the same time as plugging the USB to your PC**.  If you are successful, the QDLoader port should instantly appear. You do not need to keep the 2 contacts on the back tripped after you plug it in and see the QDLoader port. If the QDLoader port doesn't show up within 3 seconds, unplug the USB and try again.

For the RM550/551 modems these are the correct ports to jump:

**Here is how I did it. Remember plug the USB in at the same time as doing this:**
![](https://github.com/iamromulan/RM551E-GL/blob/main/Images/551_edl.png?raw=tru)

### Step 5

At this point you should see the QDLoader port in device manager:
 ![](https://github.com/iamromulan/RM551E-GL/blob/main/Images/qdloader.png?raw=tru)

Follow the steps from the [normal method](#firmware-update-instructions) and treat the QDLoader port as the DM port.
</details>

## How to use Qnavigator to send AT commands

<details>
   <summary> View</summary>

Connect your modem to your computer by USB. Either through a USB to m.2 B-key sled (should have a sim slot as well) from Amazon or by using a PCIe RC (RJ45 sled) board's USB C port.
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
| `2024-07-11` | *x75 (RM550/RM551) series modems AT Commands* | <a href="https://mega.nz/file/bQ1lTZYZ#xxPMT8PnKlOO6pLQVFgVnP9HDzYWH1W8XdH8B6snJzo">View/Download</a> |
| `2024-02-07` | *RM50X and RM52X series modems AT Commands (some apply to RM550/551)* | <a href="https://mega.nz/file/WZsgHZ7C#XcE0LPkzgb_aS7o8yEeCMSEA_YzCxflXBgfxOsOrt3M">View/Download</a> |

</details>

## Description of antenna connection:
<details>
   <summary>View</summary>

![RM551E-GL_ant_pairs](https://github.com/user-attachments/assets/309702e4-eb05-4748-8366-5ae1115e8921)
![RM551E-GL_ant_descrip](https://github.com/user-attachments/assets/a8b48a52-9af2-4065-82f3-f4a085ed0d20)

</details>

## Other Docs
<details>
   <summary>General</summary>

[[NEW!] Quectel 5G&LTE-Advanced Module Product Overview V7.1](https://www2.quectel.com/5GLTEAdvance)

[Quectel Product Brochure V7.7](https://mega.nz/file/2Z1HCKLR#8dxbdpXK-CC8_MWnJ_O4ykFqb08ljhzmj0MHK5b1nWI)

[Quectel Product Brochure V7.4](https://mega.nz/file/TEsUkTKD#iJVMKIMRH-gaIwoSZkUDgmAU3s9hjL3I1brFHeV0t-I) (Includes the canceled RM521F-GL module) 

[QCOM User Guide V1.1](https://mega.nz/file/HMsgAI7Q#kVLf7ETrE13zrsUUmdq2NUe2d26ZSkbeqgmNXQ4offw)

[QFlash User Guide V5.5](https://mega.nz/file/KFsHgbSS#kJYBxnQk3--lsXpCg0fz7V7551_GzlDPu27Uo7hPNXo)

</details>

## Specification:
![](https://github.com/iamromulan/RM551E-GL/blob/main/Images/551_specs.png?raw=tru)
