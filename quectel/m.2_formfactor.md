Quectel Modem Wiki
=================================
> :book: This is a living Wiki. Changes may be made as more discoveries are made or more community software is made. If you feel like you have information to contribute to this wiki please open a pull request.
# Form Factor: M.2

## Connection Methods
The modems M.2 B-Key interface is a combination of both USB 3.1 and PCIe 4.0 along with additional pins for things like the SIM slots. For exact information about what pin is what, see the hardware design document. The modem supports being used in 3 different ways:
- USB 3.1
- PCIe EP (Endpoint)
- PCIe RC (Root Complex mode)

**To further understand; take a look at the following graph:**
![](./images/connection_methods.png)

- Initiators refers to what is in charge of initially connecting and keeping the connection up. 
     - TE refers to the host (whatever the modem is hooked up to) will be in charge of connection management 
     - AP refers to the Linux OS running on the modem itself (the modem will be in charge of itself)
- Both USB and PCIe can be used at the same time to connect. In PCIe Endpoint mode only the TE initiator is available to be used.
- In TE modes the IP address(es) is always passed through to the host.
- :x: It is recommended to not use PCIe and USB both in a TE mode at the same time. This causes the modem to request 2 IPv4 and IPv6 addresses from the cell carrier. While this is posable, and I have seen it work, it tends to be pretty unstable.
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
