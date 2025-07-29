cd "$HOME"

ln -sf /data/data/com.termux/files/usr/etc/termux/mirrors/europe/packages.termux.dev \
      /data/data/com.termux/files/usr/etc/termux/chosen_mirrors

pkg update && pkg upgrade -y -o Dpkg::Options::="--force-confnew"

pkg install -y git nodejs

git clone https://github.com/print-yuhuan/SillyTavern-Termux.git

cd SillyTavern-Termux

npm install

npm run docs:dev

# 发布到 GitHub Pages：
npm run docs:build:gh
npm run docs:deploy

# 发布到自定义域名：
npm run docs:build:custom
npm run docs:deploy
