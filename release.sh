cd "$HOME"

ln -sf /data/data/com.termux/files/usr/etc/termux/mirrors/europe/packages.termux.dev \
      /data/data/com.termux/files/usr/etc/termux/chosen_mirrors

pkg update && pkg upgrade -y -o Dpkg::Options::="--force-confnew"

pkg install -y git nodejs

git clone https://github.com/print-yuhuan/SillyTavern-Termux.git

cd SillyTavern-Termux

npm install

# 启动开发测试运行：
npm run docs:dev

# 发布到 GitHub Pages：
npm run docs:build:gh
npm run docs:deploy

# 发布到自定义域名：
npm run docs:build:custom
npm run docs:deploy
