Quectel Modem Wiki
=================================
> :book: This is a living Wiki. Changes may be made as more discoveries are made or more community software is made. If you feel like you have information to contribute to this wiki please open a pull request.


# Getting Verizon Working Properly

Verizon's registration process is much different than what we are normally used to where the first APN is used for the data connection.

> :warning: This has only been tested on the RM551E-GL so far.
## Quectel's Officially provided knowledge on this is: 

>[Source]([quick start guide by kasper 2024 05 07a.pdf](https://cnquectel-my.sharepoint.com/:b:/g/personal/america-fae_quectel_com/ERJ819aGZCZAuKNsaIUKYFMB0ITDWIdUUZg0WGGVv_-yAA?e=EFua1W)) on page 30

Verizon has some special requirements with network registration, compared with most other carriers. 

- For LPWA modules, it’s pretty much the same as other carriers. You can setup the APN in PDP#1 

- For LTE and 5G networks, the APN of PDP#1 must be IMS and it is used for initial network attach. 

- PDP#2 (vzwadmin) is used for remote administration, with the OMA-DM or LWM2M protocols. 

- PDP#3 (vzwinternet) is used for data call, it can also be setup by OMA-DM/LWM2M. When you insert a new SIM to the module, the module will talk with the Verizon administration server using the vzwadmin PDP and the correct APN will be set. After that you can setup manually and Verizon won’t push a new APN to the module again unless you swap a SIM. 

- If APNs have been accidentally changed manually, the module won’t register to the network, or strange things can happen. Please reload the default in this case.


# The problem

The default MBN profile ``CDMAless-Verizon`` is automatically selected when you insert a Verizon SIM; As long as you have MBN auto selection turned on ``AT+QMBNCFG="AutoSel",1``. It does indeed set up the PDP contexts with the correct APNs and such, as detailed in the previous section. The first 2 PDP contexts automatically activate, and we can see this with the ``AT+CGACT?`` command. IMS and VZWADMIN activate but the 3rd (VZWINTERNET) which is what is used for the data call never does. You'd think simply running ``AT+CGACT=1,3`` would be enough but it isn't. That 3rd PDP context does activate and get an IP with that command, but a data call isn't initiated with it.
# The fix we already know

In the past to fix this we would: 
1. Disable automatic MBN selection ``AT+QMBNCFG="AutoSel",0`` 
2. Deactivate the currently selected profile with ``AT+QMBNCFG="deactivate"``
3. Then select the generic MBN profile ``AT+QMBNCFG="select","ROW_Commercial"`` 
4. From there, reboot, then manually set the VZWINTERNET APN in PDP context 1 with ``AT+CGDCONT=1,"IPV4V6","VZWINTERNET"``
5. Disconnect ``AT+CFUN=0`` then reconnect ``AT+CFUN=0`` and your up and running.
The downside to doing this is SMS needs the IMS APN set to work, along with other important things that come with the Verizon MBN profile. I also noticed connection stability isn't quite where it should be either. 

# How to make it work with the default MBN

As previously discussed, only the first 2 PDP contexts activate, and even when manually activating the 3rd one it doesn't make a difference since the data call isn't initiated with it.

While using an AP connection mode like ECM, RNDIS, or PCe RC I've discovered that you can use the ``AT+QMAP="mpdn_rule"`` command to set a data connection rule specifying what PDP context to use. When you send the command ``AT+QMAP="WWAN"`` it displays what the IPv4 and IPv6 addresses are for the active data call along with what PDP context it's using for said data call. 
For example:
```
AT+QMAP="WWAN"
+QMAP: "WWAN",1,1,"IPV4","your IPv4 address"
+QMAP: "WWAN",1,1,"IPV6","your IPv6 address"
```

The first value after ``WWAN`` indicates that it is connected with an IP address assignment (1 for connected with assignment, and 0 for not)

The second value indicates what PDP context is being used. In the example provided it's using 1 like we normally would use.

Since for Verizon we need to make the data call happen with PDP context 3 we can use the command:
```
AT+QMAP="mpdn_rule",0,3,0,0,1
``` 
This means: Set Rule 0, using PDP context 3, using VLAN 0 (none), with no IP passthrough, and auto connect on. After sending this command PDP 3 automatically activate and the data call initiates using PDP context 3.

Afterwards we can see:

```
AT+QMAP="WWAN"
+QMAP: "WWAN",1,3,"IPV4","your IPv4 address here"
+QMAP: "WWAN",1,3,"IPV6","your IPv6 address here"
```

**This solution gets both Data and SMS working!** 😁

As of **The December 2024 firmware**:

On the RM551E-GL (SDXPINN) I've noticed some strange issues with the QMAP command set. 

:warning: ⚠️ **Do not release the rule with ``AT+QMAP="mpdn_rule",0`` and then reboot.** : warning: ⚠️ 

Simply releasing the rule will not set the data call to use PDP context 1 again, and rebooting after releasing the rule seems to break the ability to set it again. Flashing fresh firmware seems to be the only way to fix it when it enters this state.

Instead, release the rule 
```
AT+QMAP="mpdn_rule",0
```

Then immediately set a new rule
```
AT+QMAP="mpdn_rule",0,1,0,0,1
```

That should make the the data call initiates with PDP context 1 again. 
