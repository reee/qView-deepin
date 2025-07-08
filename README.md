# qView Debian 打包说明

本目录包含了用于创建 qView Debian 包的脚本和配置文件。

## 打包脚本

### 1. `build-deb.sh` - 主要打包脚本

功能完整的打包脚本，包含错误检查、彩色输出和详细日志。

**使用方法:**
```bash
# 使用默认版本号 (7.0)
./build-deb.sh

# 指定版本号
./build-deb.sh 7.1
```

**功能特性:**
- 自动检查必要文件
- 清理旧的构建文件
- 创建完整的包目录结构
- 复制所有必要文件（可执行文件、桌面文件、图标）
- 设置正确的文件权限
- 构建 deb 包
- 显示包信息和内容
- 自动清理临时文件

### 2. `quick-build.sh` - 快速打包脚本

一键完成编译和打包的便捷脚本。

**使用方法:**
```bash
./quick-build.sh
```

**功能:**
- 自动清理旧文件
- 重新编译项目
- 调用主打包脚本
- 适合开发过程中的快速测试

## 手动编译和打包

如果您想手动执行步骤：

```bash
# 1. 编译项目
qmake qView.pro
make

# 2. 打包
./build-deb.sh
```

## 安装生成的包

```bash
# 安装
sudo dpkg -i qview_7.0-1_amd64.deb

# 如果有依赖问题，修复依赖
sudo apt-get install -f

# 卸载
sudo apt-get remove qview
```

## 目录结构

```
debian/
├── changelog          # 包变更日志
├── compat            # debhelper 兼容性级别
├── control           # 包控制信息
├── copyright         # 版权信息
├── qview.install     # 安装文件列表
└── rules             # 构建规则

build-deb.sh          # 主打包脚本
quick-build.sh        # 快速打包脚本
PACKAGING.md          # 本文件
```

## 故障排除

### 常见问题

1. **编译失败**
   - 确保安装了 Qt5 开发包：`sudo apt install qtbase5-dev qttools5-dev-tools`

2. **缺少依赖**
   - 检查系统是否安装了必要的 Qt5 运行时库

3. **权限问题**
   - 确保脚本有执行权限：`chmod +x build-deb.sh quick-build.sh`

### 自定义打包

如果需要修改包信息，编辑以下文件：
- `debian/control` - 包描述和依赖
- `debian/changelog` - 版本历史
- `build-deb.sh` - 修改默认设置

## 注意事项

- 打包前确保项目已经成功编译
- 生成的 deb 包适用于 amd64 架构
- 如需支持其他架构，需要修改 control 文件中的 Architecture 字段
