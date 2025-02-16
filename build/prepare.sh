#!/bin/bash
set -e
mkdir -p /tmp/data
# QQ vscode linux-wifi-hotspot sogoupinyin
# sogoupinyin from https://blog.csdn.net/m0_57309959/article/details/139149823
cp ~/downloads/*.deb /tmp/data
# my live tool, see https://github.com/KZ25T/My-Live-Tools
cp ~/public/mlt /tmp/data
# windows fonts, fix it to your font
cp -r /usr/share/fonts/windows/{consola*,msyh*} /tmp/data
# windows theme, fix it to your theme
cp -r /usr/share/themes/Windows-10-Dark-3.2.1-dark/ /tmp/data
# windows icons, fix it to your icons
cp -r /usr/share/icons/Windows-10-Icons/ /tmp/data/
# userprofile, you should download oh-my-zsh and tldr in it by yourself
cp -r $DEBIAN_PE_DIR/resource $DEBIAN_PE_DIR/build /tmp/data
