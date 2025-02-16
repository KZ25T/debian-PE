# DIY 你的镜像 - Livecd工具

本镜像内置了我自己写的 livecd 工具，方便你自己自行定制 livecd。该工具的位置：`/usr/local/bin/mlt`，源码：[GitHub](https://github.com/KZ25T/My-Live-Tools)，[Gitee](https://gitee.com/KZ25T/my-live-tools)

## 1. 启动时功能

本系统支持以下功能：

- 在已有系统上添加文件。
  作用：如使得启动后有一个文件 `/home/uid1000/Desktop/picture.png` 和 `/usr/bin/yourcmd`
- 在启动时安装 deb 包。
- 在启动时运行脚本。

## 2. 启动时功能的简要使用方法

1. 在装有本系统镜像的 U 盘上，任选一个分区装载本工具的资源文件。如果您是用 Ventoy 装载的镜像，那么不要放在 Ventoy 分区内（也就是 iso 文件所在的位置），也不要放在 VOTYEFI 分区内（提示：安装 Ventoy 时，可以配置在后边预留一段空间，这段空间可以格式化为一个分区用来放置本工具的资源文件）。
   要求：此分区的文件系统格式为 vfat(fat32), exfat, ext4, xfs, btrfs, iso9660, ntfs 中的一个（一般 U 盘是 exfat），其中 ntfs 调用 ntfs-3g 命令，其他的进行系统调用。
2. 在该分区中创建一个目录 `.live`，其绝对路径为 `/some/mount/point/.live/操作系统名`（操作系统名如 debian 或 kali 等）
3. 若需要使用第一个功能：
   - 找一个工作目录，如 workfolder
   - 创建根目录：`mkdir rootfs`
   - 比如说你希望启动后有 `/home/uid1000/Desktop/picture.png` 和 `/usr/bin/yourcmd`，那么将其移动到 rootfs 下，使得

     ```bash
     $ tree rootfs/ 
     rootfs/
     ├── home
     │   └── uid1000
     │       └── Desktop
     │           └── picture.png
     └── usr
         └── bin
             └── yourcmd
     6 directories, 2 files
     ```

   - 打包：`cd rootfs && zip /some/mount/point/.live/操作系统名/overlay.zip -r .`，即产生 `overlay.zip` 放在 .live 下。
   - 暂不支持加密的 zip 包，或其他的高级设置。
   - 尽量不要在 Windows 上产生该压缩包。如果该压缩包用 Windows 产生，请保证双击打开后即为根目录（可见 home 或 usr 等），且不要使用中文路径或文件名。
   - 提示：如果你是 Ventoy 用户，那么 Ventoy 有类似的功能（但实现原理和我的不一样），参考[相关说明](https://www.ventoy.net/cn/doc_live_injection.html)。（我的功能未经过完备测试，Ventoy 的测试肯定比我强）
   - 提示：本功能的可能用处：
     - 添加常用文件到桌面：`/home/uid1000/Desktop/common-files`
     - 覆盖默认的 zsh 配置：`/home/uid1000/.zshrc`
     - 提供 git 配置，使得开机后的 git 就按照已有的配置：`/home/uid1000/.gitconfig` 和 `.git-credentials`
     - 提供 ssh/gpg 密钥配置：`/home/uid1000/.ssh/` 或 `/home/uid1000/.gnupg/` 使得开机后就能直接 ssh 等。**安全提示：如安装此配置，请谨防相关文件泄漏。**
     - 提供 wifi 配置：`/etc/NetworkManager/system-connections/WIFI名字.nmconnection` 可以开机之后自动连接 wifi
   - 提示：如果希望将一个本 livecd 已有的目录替换为你自己的（比如说，把已有的 `/home/uid1000/.vim` 替换为你自己的），那么请首先在 `preScript`（见下文）中写入命令把原有的目录删除。
4. 若需使用第二个功能：
   - 创建目录：`mkdir /some/mount/point/.live/操作系统名/packages`
   - 将需要安装的 deb 包添加至以上目录内。
   - 本人调用 dpkg 安装，不能使用 apt 处理依赖，请记得下载完整依赖。
   - 小技巧：`apt depends xxx` 查看依赖（请递归查询），`apt download xxx` 下载软件源里的 deb 包。请注意依赖关系及依赖版本，所以最好使用没有依赖的包，比如 wps。
5. 若需使用第三个功能：
   - 如果想在运行前两个功能之前运行某个脚本A，请把脚本放置在 `/some/mount/point/.live/操作系统名/preScript`
   - 如果想在运行前两个功能之后运行某个脚本A，请把脚本放置在 `/some/mount/point/.live/操作系统名/postScript`

## 3. 其他功能

1. `mlt --config-path(或 -c) PATH` 指定配置文件路径，用于当开机时功能所需要的文件不在 `.live/操作系统名` 下时完成此功能，或者用于特殊情况（如 U 盘不是 `/dev/sdX` 的情况等）。PATH 下应当有开机时的三个功能需要的文件。
2. `mlt --mount-dev(或 -m) PATH` 挂载 dev, proc, sys 到 chroot 目录。这对于需要运行 chroot 修复的操作系统很有帮助。相当于：

   ```bash
   mount -t proc  /proc ${PATH}/proc/
   mount -t sysfs /sys  ${PATH}/sys/
   mount --bind /sys/firmware/efi/efivars ${PATH}/sys/firmware/efi/efivars/
   mount --rbind  /dev  ${PATH}/dev/
   mount --rbind  /run  ${PATH}/run/
   mount -t tmpfs  shm  ${PATH}/dev/shm/
   ```

3. `mlt --umount-dev(或 -u) PATH` 卸载上一条挂载的目录。相当于：

   ```bash
   umount ${PATH}/dev/shm
   mount --make-rslave ${PATH}/run/
   umount -R ${PATH}/run/
   mount --make-rslave ${PATH}/dev/
   umount -R ${PATH}/dev/
   umount ${PATH}/sys/firmware/efi/efivars
   umount ${PATH}/sys
   umount ${PATH}/proc
   ```

## 4. 注意事项

1. 本程序的启动时功能只查找装有此 Livecd 镜像的 U 盘的分区，查找顺序为：按照编号数字顺序查找 U 盘各个分区（标签不是 Ventoy 或 VOTYEFI），直到查找到含有 `.live/操作系统名` 目录的分区（且满足上文文件系统）为止。
2. 在启动时本程序运行时，权限为 root，所有挂载的分区为只读挂载。相关内容我只对目录、文件进行了测试，尚不知道对于链接等文件是否会产生不良副作用。`.live/操作系统名` 下的所有文件必须为常规文件或目录，不能为链接等。
3. 使用启动时第一个功能时，不能在某个位置以文件覆盖目录，或者以目录覆盖文件。
4. 启动时的运行顺序为：`preScript`→功能1→功能2→`postScript`，当且仅当能探测到所需文件时才运行。
5. 此工具位置为：`/usr/local/bin/mlt`，为静态编译程序。
6. 开机运行此工具时，`.live` 的位置是 `/tmp/mountpoint/.live`（编写脚本时，如有需要，可以参考）

## 5. 高级定制

只要你给钱，我可以帮你搞定一些定制内容。联系方式：邮箱 `i.k.u.n@qq.com`
