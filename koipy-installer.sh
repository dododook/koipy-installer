#!/bin/bash
# =====================================================
# 一键安装 Koipy + Miaospeed + SubStore
# 作者：ChatGPT 帮助生成
# 更新时间：2025-10-27
# =====================================================

echo "🚀 一键部署 Koipy + Miaospeed + SubStore"
echo "====================================================="

# 1. 检查 Docker
if ! command -v docker &> /dev/null; then
  echo "⚙️ 未检测到 Docker，正在安装..."
  apt update -y && apt install -y docker.io
else
  echo "✅ Docker 已安装。"
fi

# 2. 准备安装目录
mkdir -p ~/koipy
cd ~/koipy || exit 1

# 3. 用户交互输入
read -p "请输入 License: " LICENSE
read -p "请输入 Bot Token: " BOT_TOKEN
read -p "请输入 API ID: " API_ID
read -p "请输入 API Hash: " API_HASH
read -p "请输入 Slave ID（例如 SbbieN2e{Q?W）: " SLAVE_ID
read -p "请输入 Slave Token（通常与 Slave ID 相同）: " SLAVE_TOKEN
read -p "请输入 Slave Path（默认 /miaospeed）: " SLAVE_PATH
SLAVE_PATH=${SLAVE_PATH:-/miaospeed}
read -p "请输入 Slave Comment（节点备注）: " SLAVE_COMMENT

# 4. 生成 config.yaml
cat > ./config.yaml <<EOF
license: ${LICENSE}
bot:
  token: ${BOT_TOKEN}
  api_id: ${API_ID}
  api_hash: ${API_HASH}

slaveConfig:
  slaves:
  - address: 127.0.0.1:8765
    id: ${SLAVE_ID}
    token: ${SLAVE_TOKEN}
    path: ${SLAVE_PATH}
    comment: ${SLAVE_COMMENT}
    tls: true
    skipCertVerify: true
    type: miaospeed
    option:
      pingAddress: https://cp.cloudflare.com/generate_204
      uploadURL: https://speed.cloudflare.com/__up
      downloadURL: https://dl.google.com/dl/android/studio/install/3.4.1.0/android-studio-ide-183.5522156-windows.exe
substore:
  enable: true
  backend: http://127.0.0.1:3000
  autoDeploy: false
EOF

echo "✅ 已生成配置文件 ~/koipy/config.yaml"

# 5. 启动 Miaospeed
echo "🚀 启动 Miaospeed..."
docker rm -f miaospeed >/dev/null 2>&1
docker run -dit \
  --name miaospeed \
  --network host \
  --restart always \
  airportr/miaospeed:latest \
  server -bind 0.0.0.0:8765 -path ${SLAVE_PATH} -token ${SLAVE_TOKEN} -mtls

# 6. 启动 SubStore
echo "🚀 启动 SubStore..."
docker rm -f sub-store >/dev/null 2>&1
docker run -dit \
  --name sub-store \
  --network host \
  --restart always \
  xream/sub-store:latest

# 7. 启动 Koipy
echo "🚀 启动 Koipy 主程序..."
docker rm -f koipy >/dev/null 2>&1
docker pull koipy/koipy:latest
docker run -dit \
  --name koipy \
  --network host \
  -v ~/koipy/config.yaml:/app/config.yaml \
  koipy/koipy:latest

echo "====================================================="
echo "🎉 安装完成！"
echo "Bot 已运行：@Koipyspeet_bot"
echo "SubStore 后端：http://127.0.0.1:3000"
echo "Miaospeed 服务：http://127.0.0.1:8765"
echo "配置文件路径：~/koipy/config.yaml"
echo "====================================================="
