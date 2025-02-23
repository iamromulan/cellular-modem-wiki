Quectel Modem Wiki
=================================
> :book: This is a living Wiki. Changes may be made as more discoveries are made or more community software is made. If you feel like you have information to contribute to this wiki please open a pull request.

## RM551 4CA Fix

This guide will help you load a new carrier aggregation file into the NV file system of your modem if you are having trouble aggregating 4 5g channels on T-Mobile’s SA 5g network. Typically this happens on towers equipped with Nokia antennas. 

**Requirements**

 - [QPST Software](https://www.dropbox.com/scl/fi/jzxgl5vft4xjsbssrauwa/QPST_2.7.496.zip?rlkey=4ue2vbdtq2o4kd0k0r06kg9ga&st=9sv0ts85&dl=0)
 - [Carrier Aggregation File](https://www.dropbox.com/scl/fi/f250bpn68op6l6z8bpzu7/plmn2cacombos_nr.mdb?rlkey=he8nitlsheeifk5n050fd6v6e&st=30rkizcj&dl=0)


## File Loading Process 

 - Open QPST with your modem plugged into your PC and make sure you have added the Diagnostic/DM Port.
 - Click **Start Clients** from the top menu and open **EFS Explorer**.
 - Expand the **mdb** folder and click on the **nr** folder
 - *On the right side of EFS Explorer, you will see the current .mdb files located inside this folder*
 - Now drag and drop the **Carrier Aggregation File** from the requirements section into this folder.
 - [Here](https://www.dropbox.com/scl/fi/l8kqg94f52p3anedlsp88/IMG_5581.JPG?rlkey=ckidq4119p4it96fpfgu49hxo&st=6u3akdrq&dl=0) is a picture to help you visualize what you are doing.

## Deleting Carrier Aggregation File

Always give the modem a few reboot cycles if you are having connection issues after the new .mdb file before resorting to deleting. This file does not work for all towers. It was made by Quectel for a customer using a tower with Nokia antennas and their specific tower logs in mind.

**Process to Delete**

 - Open Qnavigator or any command terminal to run AT commands and issue **AT+CFUN=0** command
 - Now issue **AT+QNVFD="/mdb/nr/plmn2cacombos_nr.mdb"** in a command terminal.
 - Now reboot with **AT+CFUN=1,1**
 - After reboot confirm CFUN is set to 1 by sending **AT+CFUN?** command.
 - If modem returns 0, send **AT+CFUN=1**
 


> Written with [StackEdit](https://stackedit.io/).
