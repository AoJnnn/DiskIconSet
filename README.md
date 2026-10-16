# U 盘图标设置工具

这是一个不需要安装运行库的 VBScript 小工具。运行 `UsbIconSet.vbs` 后，它会：

1. 把自身加入当前用户的 Windows 启动项；
2. 立即处理当前已连接的可移动磁盘；
3. 后台监听之后插入的 U 盘；
4. 将同目录的 `ico.ico` 复制到 U 盘根目录，并生成 `autorun.inf`。

## 使用方法

1. 将 `UsbIconSet.vbs` 和 `ico.ico` 放在同一个目录；
2. 双击运行 `UsbIconSet.vbs`；
3. 之后插入 U 盘即可。首次运行后可以关闭脚本窗口，下一次开机将自动运行。

Windows 可能会因为安全策略不显示旧式 `autorun.inf` 图标，这是系统限制，不是脚本错误。拔出并重新插入 U 盘，或在资源管理器中刷新后查看。

## 停止自启动

删除当前用户启动目录中的 `UsbIconSet.lnk` 即可：

`%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`
