Fibocom Modem Wiki
=================================
> :book: This is a living Wiki. Changes may be made as more discoveries are made or more community software is made. If you feel like you have information to contribute to this wiki please open a pull request.


# Backup firmware with QPST

> :book: During the flashing process the radio calibration will be erased, make sure you have valid backups as reported at [NV Restore Radio Calibration](./flash_firmware_windows.md#nv-restore-radio-calibration)

> Open Qpst Configuration.

> Use the AutoAdd function to autoconnect to proper serial port "DEADD00D sn 4ec33ae0 DIAGnostic" or\
> Select Ports tab.\
> Add New Port.\
> "Show serial and USB/QC diagnostic port only": NO.\
> Add "USB DM Port".\
> Just ignore the other ports "USB NMEA, USB Modem, AT".

![](./images/01_qpst_port.png)

> Navigate to Start Clients > Software Downloads > Backup tab.

> Go to xQCN File field, browse backup directory, give filename and press Start. The file is created into "C:\<path>\DEADD00D_0.xqcn". Wait for the load bar get to the and and look for "Memory Backup Completed" message.

![](./images/02_qpst_backup.png)
![](./images/03_qpst_backup_complete.png)

> Next close QPST window completely even from the system tray.


# Backup firmware with QFIL as well
(To backup few other things, like IMEI.)

> Open QFIL, go to Configuration tab -> Firehose configuration and select Port as per [QFIL Config](./introduction.md#qfil-configuration--usage)

![](./images/06_qfil_backup.png)

> Go to Tools tab.\
> QCN backup restore.\
> Browse and give filename "C:\<path>\00000000.qcn", SPC Code 000000, Enable Multi-SIM YES.\
> Press Backup QCN.\
> Wait for the load bar to finish and look for "Backup QCN Succeeded"

![](./images/07_qfil_backup_success.png)

> Close QCN Backup Restore window.

