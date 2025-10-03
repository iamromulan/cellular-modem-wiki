Quectel Modem Wiki
=================================
> :book: This is a living Wiki. Changes may be made as more discoveries are made or more community software is made. If you feel like you have information to contribute to this wiki please open a pull request.

# Preparing Enviroment
Online resources like flashing applications and firmwares are available from [QuecDeploy](https://github.com/iamromulan/QuecDeploy/releases/latest) or from my [Mega Public Folder](https://mega.nz/folder/CRFWlIpQ#grOByBgkfZe5uLMkX2M2XA).

>:bulb: Both the path to flashing application and your extracted firmware must not have spaces in it. Example: C:\Quectel\Q flash\ is bad while C:\Quectel\Qflash\ is good. If you installed flashing applications and got your firmware through QuecDeploy, then you don't have to worry about this.

Step 1.
> Install [QuecDeploy](https://github.com/iamromulan/QuecDeploy/releases/latest)

Step 2.
> Install the latest NDIS driver. (Note that only one driver can be installed at once besides the ECM driver). 

Step 3.
> Connect modem to your computer, by USB, inserting the module into m.2-to-usb adapter.

Step 4.
> Go to device manager and check if the new COM ports are visible in the system. Restart your computer if the new COM ports are not visible.\
> Remember the number of the COM port described as "DM Port".

![](./images/devman_ports.png)

Step 5.
> Install QPST (under Qualcomm Tools) from [QuecDeploy](https://github.com/iamromulan/QuecDeploy/releases/latest). \
> Install QFIL from [QuecDeploy](https://github.com/iamromulan/QuecDeploy/releases/latest). \
> Install serial communication application QNavigator from [QuecDeploy](https://github.com/iamromulan/QuecDeploy/releases/latest) or [TeraTerm](https://sourceforge.net/projects/tera-term/files/latest/download).
