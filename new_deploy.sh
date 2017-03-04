GIT_URL="https://github.com/efeiefei/efeiefei.github.io.git"
PROJECT="efeiefei.github.io"

git clone $GIT_URL --branch master --single-branch .deploy_git
npm install hexo
npm install