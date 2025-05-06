Quectel Modem Wiki
=================================
> :book: This is a living Wiki. Changes may be made as more discoveries are made or more community software is made. If you feel like you have information to contribute to this wiki please open a pull request.

# RM551E-GL T-Mobile NR SA 4CA Patches

>:bulb: This is method is working on Quectel Base firmware on or before December 2024 and all iamromulan custom firmware. Stock March firmware should be avoided.  

If your RM551E-GL is having trouble getting 4xCA on SA NR on the default T-Mobile MBN: `Commercial-TMO` or the generic (more stable) MBN `ROW_Commercial` then you'll want to add a file to the EFS. This can be achieved through QPST's EFS browser (Installable via [QuecDeploy](https://github.com/iamromulan/quecdeploy/)) or more simply by using the AT+QNV AT command set.

## Commercial-TMO MBN patch

Send the following command to create a new file/overwrite a file in the EFS with the HEX contents you want. 

Send this command to add the file that gets 4xCA working 
`AT+QNVFW="/mdb/nr/plmn2cacombos_nr.mdb",010175516c616f636d6d000000000000000000000000000000000000020001015ab106bb002f00006a34519700000000001b0000002000009c786163606000e009e2408c014206c2248161060d3015000179113b17007800cb9c3233d47533cd7431920686e6d68e000c01281a04`

 Then reboot `AT+CFUN=1,1`

If you don't have 4xCA it either means the cell site you are at does not have 4xCA or you need to reboot again.

If you feel the need to delete the file the process is:
`AT+CFUN=0` (Must be in CFUN 0 minimal function to delete from the EFS)
`AT+QNVFD="/mdb/nr/plmn2cacombos_nr.mdb"`
`AT+CFUN=1,1` (reboot)

## ROW_Commercial MBN patch

If you find that the Commercial-TMO MBN causes connection stability issues for you then you may want to switch to using the ROW_Commercial MBN instead. This take a bit more to get working, and if you ever re-enable MBN auto selection or select an MBN then this will be undone.

Here is the process assuming you currently have auto select enabled and are using the default Commercial-TMO MBN. Do these in this order exactly:

`AT+QMBNCFG="autosel",0`
`AT+QMBNCFG="deactivate"`
`AT+QMBNCFG="select","ROW_Commercial"`  
`AT+CFUN=1,1` (reboot)

When it comes back up you should be switched to using the `ROW_Commercial` MBN.
You can confirm this by running the command: `AT+QMBNCFG="list"` and checking to see if `ROW_Commercial` is the first one listed. If so lets continue. You will notice that your APN is probably cleared, this is normal as `AT+QMBNCFG="deactivate"` has that effect. You will need to run it again though so we will set an APN in the end.

Next up:

`AT+QMBNCFG="deactivate"`

`AT+QNVFW="/mdb/nr/plmn2cacombos_nr.mdb",010175516c616f636d6d000000000000000000000000000000000000020001015ab106bb002f00006a34519700000000001b0000002000009c786163606000e009e2408c014206c2248161060d3015000179113b17007800cb9c3233d47533cd7431920686e6d68e000c01281a04`

`AT+QNVFW="/mdb/nr/plmn2features_sub.mdb",01015175616C636F6D6D00000000000000000000000000000000000000020101544B15540100000000000000000000002C00000050000000789C63616060B000E2098C40428181818301028481100492A0B410945682D24650DA094A074169007DE502EA0D001200789C636666601067606060046100012D0020`

`AT+QNVFW="/nv/item_files/modem/nr5g/RRC/cap_control_nrca_5x_f_plus_t_band_combos",010101000000`

`AT+QNVFW="/nv/item_files/modem/nr5g/RRC/cap_control_nrca_4x_fdd_band_combos",0100`

`AT+QNVFW="/nv/item_files/modem/nr5g/RRC/cap_control_nrca_4x_f_plus_t_band_combos_v2",3F000000000000000101010101010000`

`AT+QNVFW="/nv/item_files/modem/nr5g/RRC/cap_control_nrca_3x_f_plus_t_band_combos",010101010101`

`AT+QNVFW="/nv/item_files/modem/nr5g/RRC/cap_control_nrca_2x_f_plus_t_band_combos",01`

`AT+QNVFW="/nv/item_files/modem/nr5g/RRC/cap_control_nrca_3x_t_plus_t_band_combos",01`

`AT+QNVFW="/nv/item_files/modem/nr5g/RRC/cap_control_nrca_4x_f_plus_t_band_combos",010101`

`AT+CFUN=1,1`

When it comes back up set your APN manually by sending `AT+CGDCONT=1,"IPV4V6","fast.t-mobile.com"` or `AT+CGDCONT=1,"IPV4V6","fbb.home"` then either do a full reboot or `AT+CFUN=0` then `AT+CFUN=1` 

Keep in mind MBN settings are for the whole modem and not the SIM slot. If you have a 2nd SIM and switch to it you will need to set your APN every time since the MBN will no longer do that for you. Most carriers work fine with the generic MBN so this should be fine. You may use QuecManager to set an APN profile for a SIM/ICCID so a particular APN is auto applied when you switch slots/that ICCID is active. 