Quectel Modem Wiki
=================================
> :book: This is a living Wiki. Changes may be made as more discoveries are made or more community software is made. If you feel like you have information to contribute to this wiki please open a pull request.


# Getting Verizon Working Properly

Verizon's registration process is much different than what we are normally used to where the first APN is used for the data connection.

## Quectel's Officially provided knowledge on this is: 

>[Source]([quick start guide by kasper 2024 05 07a.pdf](https://cnquectel-my.sharepoint.com/:b:/g/personal/america-fae_quectel_com/ERJ819aGZCZAuKNsaIUKYFMB0ITDWIdUUZg0WGGVv_-yAA?e=EFua1W)) on page 30

Verizon has some special requirements with network registration, compared with most other carriers. 

- For LPWA modules, it’s pretty much the same as other carriers. You can setup the APN in PDP#1 

- For LTE and 5G networks, the APN of PDP#1 must be IMS and it is used for initial network attach. 

- PDP#2 (vzwadmin) is used for remote administration, with the OMA-DM or LWM2M protocols. 

- PDP#3 (vzwinternet) is used for data call, it can also be setup by OMA-DM/LWM2M. When you insert a new SIM to the module, the module will talk with the Verizon administration server using the vzwadmin PDP and the correct APN will be set. After that you can setup manually and Verizon won’t push a new APN to the module again unless you swap a SIM. 

- If APNs have been accidentally changed manually, the module won’t register to the network, or strange things can happen. Please reload the default in this case.


# The fix we already know

By default when you insert a Verizon or Verizon MNVO SIM the MBN profile "CDMAless-Verizon" is selected if you have MBN auto selection enabled (``AT+QMBNCFG="AutoSel",1``) 
An MBN is basically a pre-configured profile for a particular provider. To my know

In theory this should just work, but it doesn't. In the past to fix this we would disable automatic MBN selection