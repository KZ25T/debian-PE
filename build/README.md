# 构建说明

## 0. 准备环境

一台正常运行的 linux 系统（不限发行版），一个老的 Debian livecd 镜像（可以使用当前这个），Debian 安装器，qemu 虚拟机，20GB 以上硬盘空间。

下载 Debian 安装器：[https://mirrors.ustc.edu.cn/](https://mirrors.ustc.edu.cn/) 获取安装镜像 -> Debian -> 12.9.0 Network Installer

以下命令可能需要你自己调整一些目录。

## 1. 准备资源

设定 `$DEBIAN_PE_DIR` 为本仓库目录。

```bash
# 主机
# 你最好先看看脚本里写了啥
bash $DEBIAN_PE_DIR/build/prepare.sh
```

## 2. 安装系统

```bash
# 主机
qemu-img create -f qcow2 debian.qcow2 20G
qemu-system-x86_64 -m 24G -smp 8 -cpu host -enable-kvm  -virtfs local,id=share1,path=/tmp/data,mount_tag=hostshare,security_model=none,readonly=off -cdrom ~/downloads/debian-12.9.0-amd64-netinst.iso -hda ./debian.qcow2 -boot d
```

安装系统时，刚打开的时候语言选 C，最后选择软件包的时候取消全部勾选。

## 3. 构建系统

```bash
# 主机
qemu-system-x86_64 -m 24G -smp 4 -cpu host -enable-kvm  -virtfs local,id=share1,path=/tmp/data,mount_tag=hostshare,security_model=none,readonly=off -hda ./debian.qcow2
```

进入虚拟机，登陆后执行：

```bash
# 虚拟机
mount -t 9p -o trans=virtio,version=9p2000.L hostshare /mnt
bash /mnt/build/vm1.sh --debian # or --kali-core, --kali-default
shutdown now
```

运行 `vm1.sh` 的时候需要手动确认几次，全选 `Yes`。选择语言的时候选上 `zh-CN.UTF8`，系统默认语言选 `C.UTF8` 即可。除此之外，本脚本已实现全自动运行。

脚本最后会修理主题，这一部分已经实现全自动化运行。

## 4. 打包镜像

```bash
cd /dev/shm
7z x ~/desktop/debian-live-2025.iso -o./cdrom
sudo rm -r cdrom/live/{\[BOOT\],vmlinuz,initrd.img,filesystem.squashfs}
sudo cp /tmp/data/{filesystem.squashfs,vmlinuz,initrd.img} cdrom/live/
sudo xorriso -as mkisofs -R -r -J -joliet-long -l -cache-inodes -iso-level 3 -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin -partition_offset 16 -publisher "github:KZ25T" -V "DebianLive" --modification-date=2025021613200000 -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -append_partition 2 0x01 ~/desktop/efi.img  -o my.iso cdrom
```

得到 `my.iso` 为构建镜像。

其中 cdrom 是我自己写的 grub，参考 [Windows-like-grub](github.com/KZ25T/Windows-like-grub.git)
