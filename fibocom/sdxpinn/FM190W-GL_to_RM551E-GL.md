Fibocom Modem Wiki
=================================
> :book: This is a living Wiki. Changes may be made as more discoveries are made or more community software is made. If you feel like you have information to contribute to this wiki please open a pull request.

> :warning: This guide is preliminary and may not be fully completed
## FM190W-GL to RM551E-GL firmware conversion guide

**Requirements**

 - Fibocom FM190W-GL modem
 - m.2 adapter with usb
 - PC with windows 
 - Fibocom [usb drivers](https://www.dropbox.com/scl/fi/veni1yp97axjrp10dn46y/FbUSBDeviceSetup_v2.1.2.5-2.7z?rlkey=dtbw82bb5qjhjd1y71q0z62bz&st=3cby476k&dl=0)
 - Quectel [Qflash](https://mega.nz/file/bdUWiKSQ#7RPymUcm7Rgdjf9mRsWjuf9zXia5qxV7NZWMLruvb5A) software
 - Quectel RM551E-GL [firmware](https://mega.nz/file/aAdVHTST#dOzRfehUUbcUFH3Yoo-n58m68wgHcEXhcnKYuo2nMo4)
 - [QPST software](https://www.dropbox.com/scl/fi/jzxgl5vft4xjsbssrauwa/QPST_2.7.496.zip?rlkey=4ue2vbdtq2o4kd0k0r06kg9ga&st=o3r9rkht&dl=0)
 - RM551 .xqcn restore [file](https://www.dropbox.com/scl/fi/7fkljc2ayfibegclcqq6l/551.xqcn?rlkey=m89k76e7gxue54fmdk27goplw&st=254l7diw&dl=0)

## Firmware Flashing Process 
Make sure you have downloaded and installed all software and drivers from requirements section above. 

 - Plug modem into PC via usb and open device manager. If the Fibocom usb drivers have been installed successfully, you should see **”Ports”** populate in your device manager list a few seconds after plugging in the modem. Click on ports to reveal the list of all available modem ports. Make note of the number of your **DM port**. This is the port we are going to use to flash the firmware.
 - Open **Qflash**  software, select the **COM port** number that corresponds with the **DM port** from device manager and set **Baudrate** to 460800.
 - Click **Load FW Files** and navigate to where you have the RM551 firmware update folder saved. 
 - The file you need is located at **update>firehose>**  prog_firehose_sdx7x.elf
 - Click **Start** once the progress bar finishes the modem is now flashed with Quectel firmware.

## NV Restore Process 

 - Make sure Qflash is closed and modem is still plugged in.
 - Open **QPST software**
 - I’m linking this [guide](https://www.dropbox.com/scl/fi/pofi5g7lz3jcelh6howwx/Qpst-Restore-QCN-20191206.pdf?rlkey=myqimvlsh3a54qy0pbau3bhqo&st=uet6w623&dl=0) to help you follow along with the instructions.
 - If the DM port isn’t automatically detected by QPST, select **Add New Port** from the **Ports** tab.
 - Under the **Start Clients** menu, select **Software Download**
 - Select the **Restore** tab, make sure your **DM port** is selected and load in the RM551 **.xqcn** file that you saved.
 - Make sure Allow ESN mismatch is selected and click **Start**
 - Wait until status says **Memory Restore Completed **

## Congratulations you are now the proud owner of an RMFaux51


