Fibocom Modem Wiki
=================================
> :book: This is a living Wiki. Changes may be made as more discoveries are made or more community software is made. If you feel like you have information to contribute to this wiki please open a pull request.

# Install QuecManager

> Use ssh console
>> Visit http://192.168.224.1/cgi-bin/luci/admin/services/ttyd \
>> RM551E-GL login:root / psw:iamromulan\
>> opkg update\
>> \# opkg upgrade sdxpinn-console-menu # (not needed for R02)\
>> \# opkg upgrade sdxpinn-mount-fix # (not needed for R02)\
>> \# opkg upgrade sdxpinn-patch # (not needed for R02)\
>> opkg update\
>> opkg install sdxpinn-quecmanager # or sdxpinn-quecmanager-beta

![](./images/19_firefox_quecmanager.png)

![](./images/20_firefox_quecmanager_success.png)

> Or Use "menu" command
>> Visit http://192.168.224.1/cgi-bin/luci/admin/services/ttyd \
>> menu # /usr/bin/menu

> Or use LuCI GUI
>> Visit http://192.168.224.1/cgi-bin/luci/admin/system/opkg \
>> Update lists\
>> Select "sdxpinn-quecmanager" or "sdxpinn-quecmanager-beta"\
>> Install
