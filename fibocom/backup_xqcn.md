WIP images needed

# Backup factory firmware with QPST

> Open Qpst Configuration and use the AutoAdd function to autoconnect to proper serial port (COM6) AutoAdd DEADD00D sn 4ec33ae0 [DIAGnostic]. Just ignore the other ports: (COM3) USB NMEA, (COM4) USB Modem, (COM5) AT. (Select Ports tab > Add New Port > (Show serial and USB/QC diagnostic port only: NO)).

> Navigate to Start Clients > Software Downloads > Backup tab.

> Go to xQCN File field, browse backup directory, give filename and press Start. The file is created into "C:\appligio\fibocom\fm190w_backup\DEADD00D_0.xqcn". Wait for the load bar get to the and and look for "Memory Backup Completed" message.

> Next close QPST completely even from the system tray.

# Backup factory firmware with QFIL as well
(to backup few other things, like IMEI)

> Open QFIL. 

> Go to Tools tab -> QCN backup restore -> Browse and give filename "C:\appligio\fibocom\fm190w_backup\00000000.qcn", SPC Code 000000, Enable Multi-SIM yes -> Press Backup QCN -> Wait for the load bar to finish and look for "Backup QCN Succeeded"

> Close QCN Backup Restore window

> Go to Configuration tab -> Firehose configuration:
> Download protocol can stay default Sahara.
> The device type is NAND.
> No validation.
> Don't use the auto backup restore QCN options on the right.
> "*Reset after download" just means it'll reboot after it finishes so keep that checked.
> The big thing here is to select "*Erase all before download". This will erase what you backed up into the xqcn and allow a full clean flash to occur with the 551 firmware.

*I've done one backup with this "flagged" and one "unflagged".
