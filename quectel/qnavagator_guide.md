Quectel Modem Wiki
=================================
> :book: This is a living Wiki. Changes may be made as more discoveries are made or more community software is made. If you feel like you have information to contribute to this wiki please open a pull request.

# How to use Qnavigator to send AT commands


Connect your modem to your computer by USB. Either through a USB to m.2 B-key sled (should have a sim slot as well) from Amazon or by using a PCIe RC (RJ45 sled) USB port.
### If you installed by using [QuecDeploy](#quecdeploy): 
You should already have a desktop icon and start menu shortcut for Qnavigator.
#### 1. Open Qnavagator, you'll be presented with this screen, just press escape (ESC) to skip their directions. 
![COM ports](./images/qnavfirst.png)
#### 2. Uncheck Automatic initialization (circled in red) and click the COM plug icon (circled in green)
***:warning: This is super important. If you leave it checked a bunch of unwanted commands will automatically be sent.***
![COM ports](./images/qnavsec.png)
#### 3. Click ok, the correct port will already be auto selected
![qnavCOMport](./images/qnavport.png)
#### 4. Click Connect to module, then in the lower right type your AT command and press send. The response will be shown above.
![at](./images/qnavat.png)


Looking for AT Commands? Check out the [Helpful Quectel AT Command list][./Quectel_AT_list.md]