Fibocom Modem Wiki
=================================
> :book: This is a living Wiki. Changes may be made as more discoveries are made or more community software is made. If you feel like you have information to contribute to this wiki please open a pull request.

# Install QuecManager

> Use ssh console
>> Visit http://192.168.224.1/cgi-bin/luci/admin/services/ttyd \
>> RM551E-GL login:root / psw:iamromulan\
>> opkg update\
>> opkg upgrade sdxpinn-console-menu\
>> opkg upgrade sdxpinn-mount-fix\
>> \# opkg upgrade sdxpinn-patch # only for R01, not needed for R02\
>> opkg update\
>> opkg install sdxpinn-quecmanager # or sdxpinn-quecmanager-beta

> Or Use menu
>> Visit http://192.168.224.1/cgi-bin/luci/admin/services/ttyd \
>> menu # /usr/bin/menu

> Or use LuCI GUI
>> Visit http://192.168.224.1/cgi-bin/luci/admin/system/opkg \
>> Update lists\
>> Select "sdxpinn-quecmanager" or "sdxpinn-quecmanager-beta"\
>> Install
