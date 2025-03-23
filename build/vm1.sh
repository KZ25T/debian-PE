#!/bin/bash
REMAIN_FILES=false
INSTALL_SUFFIX="--no-install-recommends"
os=""
if [[ "$2" == "--nodelete" ]]; then
    REMAIN_FILES=true
    INSTALL_SUFFIX=""
fi
if [[ "$1" == "--debian" ]]; then
    os="debian"
elif [[ "$1" == "--kali-core" ]]; then
    os="kali"
elif [[ "$1" == "--kali-default" ]]; then
    os="kali"
    REMAIN_FILES=true
    INSTALL_SUFFIX="kali-linux-default"
fi
if [[ -z "$os" ]]; then
    echo "Usage: bash vm1.sh [--debian|--kali-core|--kali-default](must-need) [--nodelete]"
    exit 1
fi
set -e
trap 'echo "commamd error: $BASH_COMMAND"' ERR

#  install software
if [[ "$os" == "debian" ]]; then
    sed -i 's/security.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
elif [[ "$os" == "kali" ]]; then
    sed -i 's#http://http.kali.org#https://mirrors.ustc.edu.cn#g' /etc/apt/sources.list
fi
apt update && apt upgrade -y
## These lines represent: Personal Computer Firmware, Server Firmware, System Common Software, Filesystem Drivers, User Common Software, Graphical Interface, Misc, External Software
apt install -y \
firmware-iwlwifi firmware-realtek firmware-brcm80211 firmware-linux firmware-intel-sound firmware-sof-signed firmware-misc-nonfree bluez-firmware intel-microcode amd64-microcode \
firmware-bnx2 firmware-bnx2x  firmware-cavium firmware-myricom firmware-netronome firmware-netxen firmware-qlogic \
alsa-topology-conf alsa-ucm-conf avahi-autoipd bluetooth efibootmgr grub-efi powertop shim-signed shim-unsigned task-laptop usbutils wireless-tools wpasupplicant wireless-regdb \
ntfs-3g btrfs-progs dosfstools mtools squashfs-tools exfatprogs xfsprogs cryptsetup cryptsetup-initramfs \
vim gparted hardinfo plocate sudo zsh ssh ncdu tldr cmake build-essential tree file man-db bash-completion python-is-python3 p7zip-full engrampa \
xorg xfce4 xfce4-goodies lightdm network-manager-gnome xfce4-power-manager xfce4-power-manager-plugins tumbler \
live-boot open-vm-tools-desktop locales librsvg2-common arch-install-scripts udisks2 rsync \
/mnt/*.deb \
${INSTALL_SUFFIX}
## web-browser should install recommends
apt install -y firefox-esr
## remove software
if [[ "$os" == "debian" ]]; then
    apt autoremove -y --purge xterm nano vim-tiny fonts-dejavu-core firmware-amd-graphics
elif [[ "$os" == "kali" && $REMAIN_FILES == false ]]; then
    apt autoremove -y --purge xterm nano vim-tiny firmware-nvidia-graphics firmware-ath9k-htc firmware-atheros firmware-carl9170 firmware-intel-graphics firmware-amd-graphics firmware-intel-misc firmware-libertas firmware-marvell-prestera firmware-mediatek firmware-ti-connectivity firmware-zd1211 kali-linux-firmware
elif [[ "$1" == "--kali-default" ]]; then
    apt autoremove -y --purge zutty
    rm -r /usr/share/icons/Adwaita* /usr/share/icons/Flat*
fi
apt autoremove -y --purge

#  fix setting
## fix editor setting
update-alternatives --set editor /usr/bin/vim.basic
## fix sudo setting
cat <<EOF > /etc/sudoers.d/nopasswd
uid1000 ALL=(ALL:ALL) NOPASSWD:ALL
EOF
passwd -d root
## fix locale setting
dpkg-reconfigure locales
## fix path setting
sed -i '/.*games.*/c\  PATH="/usr/local/bin:/usr/bin:/bin"' /etc/profile
sed -i 's|:/usr/local/games:/usr/games||g' /etc/login.defs
## autologin setting
mkdir -p /etc/lightdm/lightdm.conf.d
cat <<EOF > /etc/lightdm/lightdm.conf.d/autologin.conf
[Seat:*]
autologin-user=uid1000
autologin-user-timeout=0
EOF
## auto create user & start mlt
cat <<EOF > /etc/rc.local
#!/bin/bash
[[ -z "\$(getent passwd 1000)" ]] && adduser --disabled-password --shell /bin/zsh --gecos "" --uid 1000 uid1000 && passwd -d uid1000
/usr/local/bin/mlt -s >>/var/log/mlt.0.log &
exit 0
EOF
chmod a+x /etc/rc.local
mkdir -p /etc/systemd/system/lightdm.service.d
cat <<EOF > /etc/systemd/system/lightdm.service.d/wait-rc.conf
[Unit]
After=rc-local.service
EOF
systemctl daemon-reload
systemctl enable rc-local.service
systemctl enable lightdm.service # start graphics
## fix xdg user dir
sed -i 's/=D/=d/' /etc/xdg/user-dirs.defaults
sed -i 's/=T/=t/' /etc/xdg/user-dirs.defaults
sed -i 's/=P/=p/' /etc/xdg/user-dirs.defaults
sed -i 's/=M/=m/' /etc/xdg/user-dirs.defaults
sed -i 's/=V/=v/' /etc/xdg/user-dirs.defaults
## fix apt config
sed -i 's/main non-free-firmware/main contrib non-free non-free-firmware/' /etc/apt/sources.list
## fix grub config
cp /usr/share/grub/default/grub /etc/default/grub
mkdir -p /etc/default/grub.d
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub.d/os-prober.cfg

#  copy files from outside
cp /mnt/mlt /usr/local/bin
mkdir /usr/local/share/fonts/windows
cp /mnt/{consola*,msyh*} /usr/local/share/fonts/windows
fc-cache -f -v
mkdir /usr/local/share/themes
cp -r /mnt/Windows-10-Dark-3.2.1-dark /usr/local/share/themes
mkdir /usr/local/share/icons
cp -r /mnt/Windows-10-Icons /usr/local/share/icons

#  create user default doc
cp -r /mnt/resource/userprofile/{*,.*} /etc/skel
userdel -r uid1000
if [[ "$os" == "kali" ]]; then
    rm /etc/skel/.config -rf # kali linux does not need cpugraph & terminalrc
    sed -i '/export PATH=\$PATH:\$HOME\/.local\/bin/d' /etc/skel/.zshrc
fi

#  fix theme
## right click
sed -i '/<\/actions>/d' /etc/xdg/Thunar/uca.xml
cat <<EOF >> /etc/xdg/Thunar/uca.xml
  <action>
    <icon>vscode</icon>
    <patterns>*</patterns>
    <range/>
    <name>Code Here</name>
    <command>code %f</command>
    <description>Open with VSCode</description>
    <startup-notify/>
    <directories/>
  </action>
</actions>
EOF
## input method
sed -i '/\[Hotkey\/SwitchKey\]/,/DefaultValue=/ s/DefaultValue=.*/DefaultValue=Disabled/' /usr/share/fcitx/configdesc/config.desc
sed -i '/\[Profile\/IMName\]/,/DefaultValue=/ s/DefaultValue=.*/DefaultValue=sogoupinyin/' /usr/share/fcitx/configdesc/profile.desc
sed -i '/\[Profile\/EnabledIMList\]/,/DefaultValue=/ s/DefaultValue=.*/DefaultValue=sogoupinyin:True,fcitx-keyboard-us:False/' /usr/share/fcitx/configdesc/profile.desc
sed -i '/FontCh=.*/c\FontCh=Microsoft YaHei/' /opt/sogoupinyin/files/share/shell/dict/PCPYDict/env.ini
## panel settings
if [[ "$os" == "debian" ]]; then
    cp /mnt/resource/etc/panel-default-debian.xml /etc/xdg/xfce4/panel/default.xml
elif [[ "$os" == "kali" ]]; then
    cp /mnt/resource/etc/panel-default-kali.xml /etc/xdg/xfce4/panel/default.xml
fi
sed -i '/<property name="power-button-action"/a \ \ \ \ <property name="show-panel-label" type="uint" value="0"/>' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
## desktop settings
cp /mnt/resource/etc/desktop-default.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
## terminal settings
cat <<EOF >> /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-terminal.xml
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfce4-terminal" version="1.0">
  <property name="font-name" type="string" value="Consolas 12"/>
  <property name="misc-menubar-default" type="bool" value="false"/>
  <property name="scrolling-unlimited" type="bool" value="true"/>
</channel>
EOF
## shortcut settings
sed -i '/.*show_desktop_key.*/c\      <property name="&lt;Super&gt;d" type="string" value="show_desktop_key"\/>' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
sed -i '/.*exo-open --launch TerminalEmulator.*/c\      <property name="&lt;Super&gt;r" type="string" value="exo-open --launch TerminalEmulator"\/>' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
sed -i '/.*xfce4-appfinder -c.*/c\      <property name="&lt;Super&gt;a" type="string" value="xfce4-appfinder -c">' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
## windows settings
sed -i 's/^theme=.*/theme=Windows-10-Dark-3.2.1-dark/' /usr/share/xfwm4/defaults
sed -i 's/^title_alignment=.*/title_alignment=left/' /usr/share/xfwm4/defaults
sed -i 's/^title_font=.*/title_font=Sans 9/' /usr/share/xfwm4/defaults
sed -i 's/^workspace_count=.*/workspace_count=1/' /usr/share/xfwm4/defaults
sed -i 's/^wrap_windows=.*/wrap_windows=false/' /usr/share/xfwm4/defaults
## theme settings
sed -i '/    <property name="ThemeName" type="string" value="Xfce"\/>/c\    <property name="ThemeName" type="string" value="Windows-10-Dark-3.2.1-dark"\/>' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
sed -i '/    <property name="IconThemeName" type="string" value="Tango"\/>/c\    <property name="IconThemeName" type="string" value="Windows-10-Icons"\/>' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
## lightdm settings
cat <<EOF > /etc/lightdm/lightdm-gtk-greeter.conf
[greeter]
theme-name = Windows-10-Dark-3.2.1-dark
icon-theme-name = Windows-10-Icons
font-name = Consolas 12
EOF

#  clean language pack & doc & other useless tools
if $REMAIN_FILES; then
    exit 0
fi
rm -rf /var/cache/* /var/log/* /var/lib/apt/lists/{mirror*,security*} /usr/share/doc /usr/share/bug /usr/share/vim/vim90/doc /etc/apt/sources.list.d/* /usr/share/icons/Adwaita /opt/sogoupinyin/files/share/resources/font /usr/share/presage /usr/local/share/themes/Windows-10-Dark-3.2.1-dark/{cinnamon,gnome-shell} /var/lib/dpkg/*-old /usr/share/xfce4/{weather,xkb} /usr/lib/x86_64-linux-gnu/xfce4/panel/plugins/{libweather.so,libxkb.so} /usr/share/themes/* /usr/share/fonts/truetype/* /etc/fonts/conf.avail /usr/share/code/{LICENSES.chromium.html,resources/app/licenses} /usr/share/fonts/X11
if [[ "$os" == "kali" ]]; then
    rm -rf /etc/fonts/conf.d/*dejavu* # delete font file for kali
fi
fc-cache -f -v
shopt -s extglob
rm -rf /usr/share/i18n/locales/!(iso*|trans*|i18n*|C|POSIX|zh_CN)
rm -rf /usr/share/i18n/locales/translit_hangul
rm -rf /usr/share/i18n/charmaps/!(ANSI_*|ISO-8859-1.gz|UTF-8.gz|GB*)
rm -rf /usr/share/vim/vim90/lang/!(zh_CN*|menu_zh_CN*)
rm -rf /usr/share/locale/!(zh_CN|zh_Hans|locale.alias)
rm -rf /usr/share/code/locales/!(zh-CN.pak|en-US.pak)
rm -rf /usr/share/open-vm-tools/messages/!(zh_CN)
rm -rf /usr/share/man/!(man*|zh_CN)
rm -rf /usr/share/help/!(C)
rm -rf /usr/share/vim/vim90/tutor/!(tutor|tutor.zh_cn.utf-8)
rm -rf /opt/microsoft/msedge/locales/!(zh-CN*)
rm -rf /opt/QQ/locales/!(zh-CN*)
rm -rf /opt/sogoupinyin/files/share/resources/skin/!(default|logo|stretchrules.json|InputMode.xml)
rm -rf /usr/share/backgrounds/xfce/!(xfce-leaves.svg)
shopt -u extglob

## pack up system
rm /mnt/filesystem.squashfs || true
mksquashfs / /mnt/filesystem.squashfs -e /vmlinuz -e /vmlinuz.old -e /initrd.img -e /initrd.img.old -e /boot -e /proc -e /sys -e /run -e /srv -e /dev -e /tmp/* -e /tmp/.* -e /mnt -e /lost+found -e /root/.bash_history -e /root/.ssh -e /root/.viminfo -e /etc/fstab -comp xz
cp /vmlinuz /mnt/vmlinuz
cp /initrd.img /mnt/initrd.img
