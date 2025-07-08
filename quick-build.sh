#!/bin/bash

# qView 快速打包脚本
# 一键编译并打包

echo "🚀 开始 qView 快速打包流程..."

# 清理并重新编译
echo "📦 清理旧文件..."
make clean 2>/dev/null || true

echo "🔨 编译项目..."
qmake qView.pro
make -j$(nproc)

if [ ! -f "bin/qview" ]; then
    echo "❌ 编译失败，未找到可执行文件"
    exit 1
fi

echo "✅ 编译完成"

# 运行打包脚本
echo "📦 开始打包..."
./build-deb.sh

echo "🎉 全部完成！"
