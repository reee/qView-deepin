#!/bin/bash

# qView Debian 包构建脚本
# 使用方法: ./build-deb.sh [版本号]
# 例如: ./build-deb.sh 7.1

set -e  # 遇到错误时退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印函数
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查参数
if [ $# -eq 0 ]; then
    VERSION="7.0"
    print_warning "未指定版本号，使用默认版本: $VERSION"
else
    VERSION="$1"
    print_info "使用版本号: $VERSION"
fi

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"

print_info "项目目录: $PROJECT_DIR"

# 检查必要文件
print_info "检查必要文件..."
if [ ! -f "$PROJECT_DIR/qView.pro" ]; then
    print_error "未找到 qView.pro 文件，请确保在正确的目录中运行此脚本"
    exit 1
fi

if [ ! -f "$PROJECT_DIR/bin/qview" ]; then
    print_error "未找到编译好的 qview 可执行文件，请先运行 make"
    exit 1
fi

# 清理旧的构建文件
print_info "清理旧的构建文件..."
rm -rf "$PROJECT_DIR/package-build"
rm -f "$PROJECT_DIR"/qview_*.deb

# 创建包构建目录结构
print_info "创建包目录结构..."
mkdir -p "$PROJECT_DIR/package-build/DEBIAN"
mkdir -p "$PROJECT_DIR/package-build/usr/bin"
mkdir -p "$PROJECT_DIR/package-build/usr/share/applications"
mkdir -p "$PROJECT_DIR/package-build/usr/share/icons/hicolor/16x16/apps"
mkdir -p "$PROJECT_DIR/package-build/usr/share/icons/hicolor/32x32/apps"
mkdir -p "$PROJECT_DIR/package-build/usr/share/icons/hicolor/64x64/apps"
mkdir -p "$PROJECT_DIR/package-build/usr/share/icons/hicolor/128x128/apps"
mkdir -p "$PROJECT_DIR/package-build/usr/share/icons/hicolor/256x256/apps"

# 生成 control 文件
print_info "生成 DEBIAN/control 文件..."
cat > "$PROJECT_DIR/package-build/DEBIAN/control" << EOF
Package: qview
Version: $VERSION-1
Section: graphics
Priority: optional
Architecture: amd64
Depends: libqt5core5a, libqt5gui5, libqt5widgets5, libqt5network5
Maintainer: Local Build <local@example.com>
Description: Practical and minimal image viewer
 qView is an image viewer designed with minimalism and usability in mind.
 It provides a clean, intuitive interface for viewing images with essential
 features for everyday use.
 .
 Features include:
  - Fast and lightweight
  - Supports many common image formats
  - Clean, minimal interface
  - Cross-platform compatibility
EOF

# 复制文件
print_info "复制应用程序文件..."
cp "$PROJECT_DIR/bin/qview" "$PROJECT_DIR/package-build/usr/bin/"
chmod 755 "$PROJECT_DIR/package-build/usr/bin/qview"

print_info "复制桌面文件..."
if [ -f "$PROJECT_DIR/dist/linux/com.interversehq.qView.desktop" ]; then
    cp "$PROJECT_DIR/dist/linux/com.interversehq.qView.desktop" "$PROJECT_DIR/package-build/usr/share/applications/"
else
    print_warning "未找到桌面文件，跳过"
fi

print_info "复制图标文件..."
for size in 16x16 32x32 64x64 128x128 256x256; do
    icon_file="$PROJECT_DIR/dist/linux/hicolor/$size/apps/com.interversehq.qView.png"
    if [ -f "$icon_file" ]; then
        cp "$icon_file" "$PROJECT_DIR/package-build/usr/share/icons/hicolor/$size/apps/"
        print_info "复制了 $size 图标"
    else
        print_warning "未找到 $size 图标文件"
    fi
done

# 设置正确的权限
print_info "设置文件权限..."
find "$PROJECT_DIR/package-build" -type f -exec chmod 644 {} \;
chmod 755 "$PROJECT_DIR/package-build/usr/bin/qview"
chmod 755 "$PROJECT_DIR/package-build/DEBIAN"

# 构建 deb 包
DEB_NAME="qview_${VERSION}-1_amd64.deb"
print_info "构建 deb 包: $DEB_NAME"

if ! dpkg-deb --build "$PROJECT_DIR/package-build" "$PROJECT_DIR/$DEB_NAME"; then
    print_error "构建 deb 包失败"
    exit 1
fi

print_success "deb 包构建成功: $DEB_NAME"

# 显示包信息
print_info "包信息:"
dpkg -I "$PROJECT_DIR/$DEB_NAME"

print_info "包内容:"
dpkg -c "$PROJECT_DIR/$DEB_NAME"

# 清理临时文件
print_info "清理临时文件..."
rm -rf "$PROJECT_DIR/package-build"

print_success "打包完成！"
echo ""
print_info "安装命令:"
echo "  sudo dpkg -i $DEB_NAME"
echo "  sudo apt-get install -f  # 如果有依赖问题"
echo ""
print_info "卸载命令:"
echo "  sudo apt-get remove qview"
