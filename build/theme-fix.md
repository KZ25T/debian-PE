# 自定义主题的修改

## 右键

修改 `/etc/xdg/Thunar/uca.xml`，倒数第二行前添加

```xml
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
```

## 输入法

修改 `/usr/share/fcitx/configdesc/config.desc`

```conf
[Hotkey/SwitchKey]
DefaultValue=Disabled
```

修改 `/usr/share/fcitx/configdesc/profile.desc`

```conf
[Profile/IMName]
DefaultValue=sogoupinyin
[Profile/EnabledIMList]
DefaultValue=sogoupinyin:True,fcitx-keyboard-us:False
```

## 任务栏

修改任务栏配置：`/etc/xdg/xfce4/panel/default.xml` 修改为 `仓库/resource/etc/panel-default.xml`

```bash
sudo cp /mnt/resource/etc/panel-default.xml /media/etc/xdg/xfce4/panel/default.xml
```

## 桌面配置

修改默认桌面环境：`/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml`

```bash
sudo cp /mnt/resource/etc/desktop-default.xml /media/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
```

## 快捷键

修改 `/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml`

```xml
<property name="&lt;Super&gt;d" type="string" value="show_desktop_key"/>
<property name="&lt;Super&gt;r" type="string" value="exo-open --launch TerminalEmulator"/>
<property name="&lt;Super&gt;a" type="string" value="xfce4-appfinder -c">
```

## 窗口

修改 `/usr/share/xfwm4/defaults`

```conf
theme=Windows-10-Dark-3.2.1-dark
title_alignment=left
title_font=Sans 9
workspace_count=1
wrap_windows=false
```

## 主题

修改 `/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml`

```conf
ThemeName=Windows-10-Dark-3.2.1-dark
IconThemeName=Windows-10-Icons
```

## lightdm

修改 `/etc/lightdm/lightdm-gtk-greeter.conf`

```conf
[greeter]
theme-name = Windows-10-Dark-3.2.1-dark
icon-theme-name = Windows-10-Icons
font-name = Consolas 12
```
