Quectel Modem Wiki
=================================
> :book: This is a living Wiki. Changes may be made as more discoveries are made or more community software is made. If you feel like you have information to contribute to this wiki please open a pull request.


This page is meant to serve as a quick reference Quectel AT command list for easy copy/pasting. 
Full AT Command docs can be found in my :arrow_right: [Mega Public Folder](https://mega.nz/folder/CRFWlIpQ#grOByBgkfZe5uLMkX2M2XA) :arrow_left:
# General Commands

| AT Command    | Description                                                        |
| ------------- | ------------------------------------------------------------------ |
| `AT`          | The most basic AT Command. Used to check for basic AT response.    |
| `ATI`         | Get the Make/Model/Short firmware version                          |
| `AT+QGMR`     | Check what the full firmware version is                            |
| `AT+CFUN=0`   | Sets the modem in a minimal function state/disables RF/disconnects |
| `AT+CFUN=1`   | Sets the modem in a fully functional state/enables RF/will connect |
| `AT+CFUN=1,1` | Reboots the module, starts up in full function state (should)      |
*more to come*