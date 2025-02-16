# 不支持的硬件

为减少体积，本镜像没有安装一些老旧或奇怪的硬件固件。

相比于 Debian 官方的 livecd，这个 livecd 缺少了以下硬件支持。根据 deepseek 的说法，可以分为如下几类：

- 老旧：atmel-firmware  firmware-ipw2x00  firmware-zd1211 firmware-ath9k-htc firmware-atheros
- 奇怪硬件：dahdi-firmware-nonfree  firmware-ast firmware-ivtv  hdmi2usb-fx2-firmware  firmware-tomu  firmware-siano dfu-util firmware-realtek-rtl8723cs-bt
- 树莓派：firmware-libertas

如果您使用以上硬件，可以参考 [自定义系统](./diy.md) 来添加支持。
